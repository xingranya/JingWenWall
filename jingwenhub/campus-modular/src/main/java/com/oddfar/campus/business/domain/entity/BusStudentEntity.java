package com.oddfar.campus.business.domain.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

/**
 * 学生信息扩展表 (与 sys_user 1:1 关联)
 * 
 * @author jingwen
 */
@Data
@TableName("bus_student")
public class BusStudentEntity implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    /**
     * 主键ID
     */
    @TableId(value = "student_id", type = IdType.AUTO)
    private Long studentId;
    
    /**
     * 关联 sys_user 的 user_id
     */
    private Long userId;
    
    /**
     * 微信 OpenID
     */
    private String openid;
    
    /**
     * 微信 UnionID
     */
    private String unionid;
    
    /**
     * 学号
     */
    private String studentNo;
    
    /**
     * 真实姓名
     */
    private String realName;
    
    /**
     * 学院
     */
    private String college;
    
    /**
     * 专业
     */
    private String major;
    
    /**
     * 年级
     */
    private String grade;
    
    /**
     * 信用分 (初始100)
     */
    private Integer creditScore;
    
    /**
     * 钱包余额
     */
    private BigDecimal balance;
    
    /**
     * 是否实名认证 (0否 1是)
     */
    private Integer isVerified;
    
    /**
     * 是否认证骑手 (0否 1是)
     */
    private Integer isRunner;
    
    /**
     * 逻辑删除
     */
    @TableLogic
    @JsonIgnore
    private Integer delFlag;
    
    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date createTime;
    
    /**
     * 更新时间
     */
    @TableField(fill = FieldFill.UPDATE)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date updateTime;
    
    // ========== 非数据库字段 (关联查询) ==========
    
    /**
     * 用户昵称 (来自 sys_user)
     */
    @TableField(exist = false)
    private String nickName;
    
    /**
     * 用户头像 (来自 sys_user)
     */
    @TableField(exist = false)
    private String avatar;
    
    /**
     * 手机号 (来自 sys_user)
     */
    @TableField(exist = false)
    private String phonenumber;
    
    /**
     * 用户名 (来自 sys_user)
     */
    @TableField(exist = false)
    private String userName;
}
