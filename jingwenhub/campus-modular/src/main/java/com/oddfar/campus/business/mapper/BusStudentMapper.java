package com.oddfar.campus.business.mapper;

import com.oddfar.campus.business.domain.entity.BusStudentEntity;
import com.oddfar.campus.common.core.BaseMapperX;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * 学生信息扩展表 Mapper
 * 
 * @author jingwen
 */
@Mapper
public interface BusStudentMapper extends BaseMapperX<BusStudentEntity> {
    
    /**
     * 根据 openid 查询学生信息
     * 
     * @param openid 微信OpenID
     * @return 学生信息
     */
    BusStudentEntity selectByOpenid(@Param("openid") String openid);
    
    /**
     * 根据 userId 查询学生信息
     * 
     * @param userId 系统用户ID
     * @return 学生信息
     */
    BusStudentEntity selectByUserId(@Param("userId") Long userId);
    
    /**
     * 根据学号查询学生信息
     * 
     * @param studentNo 学号
     * @return 学生信息
     */
    BusStudentEntity selectByStudentNo(@Param("studentNo") String studentNo);
    
    /**
     * 查询学生信息及关联的用户信息
     * 
     * @param studentId 学生ID
     * @return 学生信息(含用户昵称、头像等)
     */
    BusStudentEntity selectStudentWithUserInfo(@Param("studentId") Long studentId);
    
    /**
     * 根据userId查询学生信息及关联的用户信息
     * 
     * @param userId 用户ID
     * @return 学生信息(含用户昵称、头像等)
     */
    BusStudentEntity selectStudentWithUserInfoByUserId(@Param("userId") Long userId);
    
    /**
     * 更新学生钱包余额
     * 
     * @param studentId 学生ID
     * @param amount 变化金额(正数增加,负数减少)
     * @return 影响行数
     */
    int updateBalance(@Param("studentId") Long studentId, @Param("amount") java.math.BigDecimal amount);
    
    /**
     * 更新学生信用分
     * 
     * @param studentId 学生ID
     * @param score 变化分数
     * @return 影响行数
     */
    int updateCreditScore(@Param("studentId") Long studentId, @Param("score") Integer score);
}
