package com.sunmao.ljx.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Web MVC config.
 *
 * 6/26 调整: /uploads/** 改由 UploadFileController 接管 (更稳定)
 * 这里只保留 /static/** 默认静态资源
 */
@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Value("${ljx.upload.dir:${user.dir}/uploads}")
    private String uploadDir;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // /uploads/** 不再走 addResourceHandler (避免 Windows 长路径解析异常)
        // 改由 UploadFileController.serveFile 用 FileSystemResource 提供

        // classpath:/static/ for default static resources (保留)
        registry.addResourceHandler("/static/**")
                .addResourceLocations("classpath:/static/");
    }
}
