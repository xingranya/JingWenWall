package com.oddfar.campus;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * 源码地址：https://github.com/oddfar/campus-example
 * @author zhiyuan
 */
@SpringBootApplication
@EnableScheduling
public class CampusApplication {

    public static void main(String[] args) {
        SpringApplication.run(CampusApplication.class, args);
    }

}
