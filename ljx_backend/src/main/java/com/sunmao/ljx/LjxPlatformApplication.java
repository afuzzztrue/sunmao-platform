package com.sunmao.ljx;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.sunmao.ljx.mapper")
public class LjxPlatformApplication {

    public static void main(String[] args) {
        SpringApplication.run(LjxPlatformApplication.class, args);
    }
}
