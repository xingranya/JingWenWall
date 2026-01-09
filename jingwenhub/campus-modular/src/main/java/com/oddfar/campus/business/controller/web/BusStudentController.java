package com.oddfar.campus.business.controller.web;

import com.oddfar.campus.business.domain.entity.BusStudentEntity;
import com.oddfar.campus.business.service.BusStudentService;
import com.oddfar.campus.common.annotation.ApiResource;
import com.oddfar.campus.common.domain.R;
import com.oddfar.campus.common.domain.entity.SysUserEntity;
import com.oddfar.campus.common.enums.ResBizTypeEnum;
import com.oddfar.campus.common.utils.SecurityUtils;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 学生信息 Controller (小程序端)
 * 
 * @author jingwen
 */
@RestController
@RequestMapping("/student")
@Api(tags = "【小程序】学生信息")
@ApiResource(name = "学生信息管理", appCode = "campus", resBizType = ResBizTypeEnum.BUSINESS)
public class BusStudentController {
    
    @Autowired
    private BusStudentService busStudentService;
    
    /**
     * 获取当前登录学生的信息
     */
    @GetMapping("/get/info")
    @ApiOperation("获取当前学生信息")
    public R getInfo() {
        try {
            // 获取当前登录用户的 userId
            Long userId = SecurityUtils.getUserId();
            
            // 根据 userId 查询学生信息及关联的用户信息
            BusStudentEntity student = busStudentService.getStudentWithUserInfoByUserId(userId);
            
            if (student == null) {
                return R.error("学生信息不存在");
            }
            
            return R.ok(student);
        } catch (Exception e) {
            return R.error("获取学生信息失败: " + e.getMessage());
        }
    }
    
    /**
     * 更新学生基本信息
     */
    @PutMapping("/update/info")
    @ApiOperation("更新学生基本信息")
    public R updateInfo(@RequestBody BusStudentEntity student) {
        try {
            // 获取当前登录用户的 userId
            Long userId = SecurityUtils.getUserId();
            
            // 查询当前学生信息
            BusStudentEntity currentStudent = busStudentService.getByUserId(userId);
            if (currentStudent == null) {
                return R.error("学生信息不存在");
            }
            
            // 只允许更新部分字段
            currentStudent.setRealName(student.getRealName());
            currentStudent.setCollege(student.getCollege());
            currentStudent.setMajor(student.getMajor());
            currentStudent.setGrade(student.getGrade());
            currentStudent.setStudentNo(student.getStudentNo());
            
            boolean result = busStudentService.updateStudentInfo(currentStudent);
            
            return result ? R.ok("更新成功") : R.error("更新失败");
        } catch (Exception e) {
            return R.error("更新学生信息失败: " + e.getMessage());
        }
    }
}
