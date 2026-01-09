package com.oddfar.campus.business.domain.vo;

import com.oddfar.campus.business.domain.entity.BusStudentEntity;
import lombok.Data;

/**
 * 微信登录响应VO
 * 
 * @author jingwen
 */
@Data
public class WxLoginVO {
    
    /**
     * JWT Token
     */
    private String token;
    
    /**
     * 用户ID (sys_user)
     */
    private Long userId;
    
    /**
     * 学生ID (bus_student)
     */
    private Long studentId;
    
    /**
     * 用户昵称
     */
    private String nickName;
    
    /**
     * 用户头像
     */
    private String avatar;
    
    /**
     * 手机号
     */
    private String phonenumber;
    
    /**
     * 是否新用户
     */
    private Boolean isNewUser;
    
    /**
     * 是否实名认证
     */
    private Integer isVerified;
    
    /**
     * 是否骑手
     */
    private Integer isRunner;
    
    /**
     * 信用分
     */
    private Integer creditScore;
    
    /**
     * 从学生实体构建VO
     */
    public static WxLoginVO fromStudent(BusStudentEntity student, String token, boolean isNewUser) {
        WxLoginVO vo = new WxLoginVO();
        vo.setToken(token);
        vo.setUserId(student.getUserId());
        vo.setStudentId(student.getStudentId());
        vo.setNickName(student.getNickName());
        vo.setAvatar(student.getAvatar());
        vo.setPhonenumber(student.getPhonenumber());
        vo.setIsNewUser(isNewUser);
        vo.setIsVerified(student.getIsVerified());
        vo.setIsRunner(student.getIsRunner());
        vo.setCreditScore(student.getCreditScore());
        return vo;
    }
}
