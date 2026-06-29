package com.sunmao.ljx.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * 上传文件服务控制器
 * 6/29 重写: 替代 WebMvcConfig.addResourceHandler, 解决 /uploads/** 500 错误
 *
 * 原因: WebMvcConfig.addResourceHandler 在 Windows 长路径下不稳定
 * 改用 Controller + FileSystemResource 直接读盘
 *
 * 接口: GET /uploads/{date}/{filename}
 * 例如: GET /uploads/2026-06-24/abc.jpg
 */
@RestController
public class UploadFileController {

    private static final Logger log = LoggerFactory.getLogger(UploadFileController.class);

    @Value("${ljx.upload.dir:${user.dir}/uploads}")
    private String uploadDir;

    @GetMapping("/uploads/{date}/{filename:.+}")
    public ResponseEntity<Resource> serveFile(@PathVariable String date,
                                               @PathVariable String filename) {
        try {
            Path basePath = Paths.get(uploadDir).toAbsolutePath().normalize();
            Path filePath = basePath.resolve(date).resolve(filename).normalize();

            if (!filePath.startsWith(basePath)) {
                log.warn("path traversal blocked: {}", filePath);
                return ResponseEntity.status(403).build();
            }

            File file = filePath.toFile();
            if (!file.exists() || !file.isFile()) {
                log.warn("file not found: {}", filePath);
                return ResponseEntity.notFound().build();
            }

            String contentType = Files.probeContentType(filePath);
            MediaType mediaType = (contentType != null)
                ? MediaType.parseMediaType(contentType)
                : MediaType.APPLICATION_OCTET_STREAM;

            Resource resource = new FileSystemResource(file);
            return ResponseEntity.ok()
                    .contentType(mediaType)
                    .contentLength(file.length())
                    .header(HttpHeaders.CACHE_CONTROL, "max-age=86400")
                    .body(resource);
        } catch (Exception e) {
            log.error("serve file error: /uploads/{}/{}", date, filename, e);
            return ResponseEntity.status(500).build();
        }
    }
}
