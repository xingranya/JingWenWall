package com.oddfar.campus.business.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.oddfar.campus.business.domain.entity.BusStudentEntity;
import com.oddfar.campus.business.mapper.BusStudentMapper;
import com.oddfar.campus.business.service.BusStudentService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.Date;

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
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateBalance(Long studentId, BigDecimal amount) {
        int rows = busStudentMapper.updateBalance(studentId, amount);
        if (rows > 0) {
            log.info("更新学生余额成功, studentId: {}, amount: {}", studentId, amount);
            return true;
        }
        return false;
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
