package com.oddfar.campus.business.task;

import com.oddfar.campus.business.service.CampusFileService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.Scheduled;

/**
 * 删除信息墙没用文件定时任务
 * 注意:首次启动时如果文件过多可能会导致启动缓慢,建议先禁用定时任务
 */
@Configuration
// 临时禁用定时任务,等项目正常运行后再开启
// @EnableScheduling
public class CampusFileTask {
    @Autowired
    private CampusFileService campusFileService;

    // 每小时执行一次
    @Scheduled(cron = "0 0 */1 * * ?")
//    @Scheduled(cron = "0/5 * * * * ??")
    private void configureTasks() {
        campusFileService.removeCampusFile();
    }
}
