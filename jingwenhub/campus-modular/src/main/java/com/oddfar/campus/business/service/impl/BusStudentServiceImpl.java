package com.oddfar.campus.business.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.oddfar.campus.business.domain.entity.BusStudentEntity;
import com.oddfar.campus.business.mapper.BusStudentMapper;
import com.oddfar.campus.business.service.BusStudentService;
import com.oddfar.campus.common.core.RedisCache;
import com.oddfar.campus.common.exception.ServiceException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.Date;
import java.util.concurrent.TimeUnit;

/**
 * 学生信息扩展服务实现
 * 
 * @author jingwen
 */
@Slf4j
@Service
public class BusStudentServiceImpl extends ServiceImpl<BusStudentMapper, BusStudentEntity> 
        implements BusStudentService {
    
    @Autowired
    private BusStudentMapper busStudentMapper;

    @Autowired
    private RedisCache redisCache;
    
    @Override
    public BusStudentEntity getByOpenid(String openid) {
        return busStudentMapper.selectByOpenid(openid);
    }
    
    @Override
    public BusStudentEntity getByUserId(Long userId) {
        return busStudentMapper.selectByUserId(userId);
    }
    
    @Override
    public BusStudentEntity getByStudentNo(String studentNo) {
        return busStudentMapper.selectByStudentNo(studentNo);
    }
    
    @Override
    public BusStudentEntity getStudentWithUserInfo(Long studentId) {
        return busStudentMapper.selectStudentWithUserInfo(studentId);
    }
    
    @Override
    public BusStudentEntity getStudentWithUserInfoByUserId(Long userId) {
        return busStudentMapper.selectStudentWithUserInfoByUserId(userId);
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public BusStudentEntity createStudent(Long userId, String openid, String unionid) {
        // 检查是否已存在
        if (existsByOpenid(openid)) {
            log.warn("学生信息已存在, openid: {}", openid);
            return getByOpenid(openid);
        }
        
        BusStudentEntity student = new BusStudentEntity();
        student.setUserId(userId);
        student.setOpenid(openid);
        student.setUnionid(unionid);
        student.setCreditScore(100);  // 初始信用分
        student.setBalance(BigDecimal.ZERO);  // 初始余额
        student.setIsVerified(0);  // 未实名
        student.setIsRunner(0);  // 非骑手
        student.setDelFlag(0);
        student.setCreateTime(new Date());
        
        this.save(student);
        log.info("创建学生信息成功, userId: {}, openid: {}", userId, openid);
        
        return student;
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateStudentInfo(BusStudentEntity student) {
        student.setUpdateTime(new Date());
        return this.updateById(student);
    }
    
    /**
     * 更新学生钱包余额（并发安全）
     * 使用分布式锁 + MyBatis-Plus乐观锁双重保护
     *
     * @param studentId 学生ID
     * @param amount    变化金额（正数增加，负数减少）
     * @return true=更新成功；false=更新失败
     * @throws ServiceException 余额不足或获取锁失败时抛出异常
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateBalance(Long studentId, BigDecimal amount) {
        String lockKey = "lock:student:balance:" + studentId;

        try {
            // 1. 获取分布式锁（防止并发操作）
            Boolean locked = redisCache.tryLock(lockKey, 5, TimeUnit.SECONDS);
            if (!locked) {
                throw new ServiceException("操作频繁，请稍后再试");
            }

            // 2. 查询当前学生信息
            BusStudentEntity student = getById(studentId);
            if (student == null) {
                throw new ServiceException("学生信息不存在");
            }

            // 3. 检查余额是否足够（扣款场景）
            if (amount.compareTo(BigDecimal.ZERO) < 0) {
                BigDecimal requiredAmount = amount.abs();
                if (student.getBalance().compareTo(requiredAmount) < 0) {
                    throw new ServiceException("余额不足，当前余额：" + student.getBalance() + "元");
                }
            }

            // 4. 计算新余额并使用乐观锁更新
            BigDecimal newBalance = student.getBalance().add(amount);
            student.setBalance(newBalance);

            // MyBatis-Plus会自动使用@Version字段进行乐观锁控制
            int rows = busStudentMapper.updateById(student);

            if (rows == 0) {
                // 乐观锁冲突，说明被其他线程修改了
                throw new ServiceException("余额更新失败，请重试");
            }

            // 5. 记录余额变动日志
            recordBalanceLog(studentId, amount, newBalance);

            return true;

        } finally {
            // 6. 释放分布式锁
            redisCache.unlock(lockKey);
        }
    }

    /**
     * 记录余额变动日志
     *
     * @param studentId 学生ID
     * @param amount    变化金额
     * @param newBalance 新余额
     */
    private void recordBalanceLog(Long studentId, BigDecimal amount, BigDecimal newBalance) {
        String operation = amount.compareTo(BigDecimal.ZERO) >= 0 ? "增加" : "减少";
        log.info("学生余额变动: studentId={}, operation={}, amount={}, newBalance={}",
                studentId, operation, amount.abs(), newBalance);
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateCreditScore(Long studentId, Integer score) {
        int rows = busStudentMapper.updateCreditScore(studentId, score);
        if (rows > 0) {
            log.info("更新学生信用分成功, studentId: {}, score: {}", studentId, score);
            return true;
        }
        return false;
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean setRunnerStatus(Long studentId, Integer isRunner) {
        LambdaUpdateWrapper<BusStudentEntity> wrapper = new LambdaUpdateWrapper<>();
        wrapper.eq(BusStudentEntity::getStudentId, studentId)
               .set(BusStudentEntity::getIsRunner, isRunner)
               .set(BusStudentEntity::getUpdateTime, new Date());
        return this.update(wrapper);
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean setVerifiedStatus(Long studentId, Integer isVerified) {
        LambdaUpdateWrapper<BusStudentEntity> wrapper = new LambdaUpdateWrapper<>();
        wrapper.eq(BusStudentEntity::getStudentId, studentId)
               .set(BusStudentEntity::getIsVerified, isVerified)
               .set(BusStudentEntity::getUpdateTime, new Date());
        return this.update(wrapper);
    }
    
    @Override
    public boolean existsByOpenid(String openid) {
        LambdaQueryWrapper<BusStudentEntity> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(BusStudentEntity::getOpenid, openid);
        return this.count(wrapper) > 0;
    }
}
