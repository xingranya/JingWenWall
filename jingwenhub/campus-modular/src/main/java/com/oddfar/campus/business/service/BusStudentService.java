package com.oddfar.campus.business.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.oddfar.campus.business.domain.entity.BusStudentEntity;

import java.math.BigDecimal;

/**
 * 学生信息扩展服务接口
 * 
 * @author jingwen
 */
public interface BusStudentService extends IService<BusStudentEntity> {
    
    /**
     * 根据 openid 查询学生信息
     * 
     * @param openid 微信OpenID
     * @return 学生信息
     */
    BusStudentEntity getByOpenid(String openid);
    
    /**
     * 根据 userId 查询学生信息
     * 
     * @param userId 系统用户ID
     * @return 学生信息
     */
    BusStudentEntity getByUserId(Long userId);
    
    /**
     * 根据学号查询学生信息
     * 
     * @param studentNo 学号
     * @return 学生信息
     */
    BusStudentEntity getByStudentNo(String studentNo);
    
    /**
     * 查询学生信息及关联的用户信息
     * 
     * @param studentId 学生ID
     * @return 学生信息(含用户昵称、头像等)
     */
    BusStudentEntity getStudentWithUserInfo(Long studentId);
    
    /**
     * 根据userId查询学生信息及关联的用户信息
     * 
     * @param userId 用户ID
     * @return 学生信息(含用户昵称、头像等)
     */
    BusStudentEntity getStudentWithUserInfoByUserId(Long userId);
    
    /**
     * 创建学生信息 (微信登录时使用)
     * 
     * @param userId 系统用户ID
     * @param openid 微信OpenID
     * @param unionid 微信UnionID (可选)
     * @return 学生信息
     */
    BusStudentEntity createStudent(Long userId, String openid, String unionid);
    
    /**
     * 更新学生基本信息
     * 
     * @param student 学生信息
     * @return 是否成功
     */
    boolean updateStudentInfo(BusStudentEntity student);
    
    /**
     * 更新学生钱包余额
     * 
     * @param studentId 学生ID
     * @param amount 变化金额(正数增加,负数减少)
     * @return 是否成功
     */
    boolean updateBalance(Long studentId, BigDecimal amount);
    
    /**
     * 更新学生信用分
     * 
     * @param studentId 学生ID
     * @param score 变化分数
     * @return 是否成功
     */
    boolean updateCreditScore(Long studentId, Integer score);
    
    /**
     * 设置骑手认证状态
     * 
     * @param studentId 学生ID
     * @param isRunner 是否骑手 (0否 1是)
     * @return 是否成功
     */
    boolean setRunnerStatus(Long studentId, Integer isRunner);
    
    /**
     * 设置实名认证状态
     * 
     * @param studentId 学生ID
     * @param isVerified 是否认证 (0否 1是)
     * @return 是否成功
     */
    boolean setVerifiedStatus(Long studentId, Integer isVerified);
    
    /**
     * 检查openid是否已存在
     * 
     * @param openid 微信OpenID
     * @return 是否存在
     */
    boolean existsByOpenid(String openid);
}
