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
 * 6/26 新增: 替代 WebMvcConfig.addResourceHandler, 解决 /uploads/** 500 错误
 *
 * 原因:
 *   - Windows 长路径 + 中文用户名 + addResourceHandler 的 file: 前缀解析在某些场景下抛异常
 *   - 用 Controller + FileSystemResource 走 ResponseEntity, 路径可控, 错误可控
 *
 * 接口:
 *   GET /uploads/{date}/{filename:.+}
 *   例如: /uploads/2026-06-24/abc.jpg
 */
@RestController
public class UploadFileController {

    private static final Logger log = LoggerFactory.getLogger(UploadFileController.class);

    @Value("${ljx.upload.dir:${user.dir}/uploads}")
    private String uploadDir;

    /**
     * 6/26 新增: 静态服务 /uploads/{date}/{filename}
     */
    @GetMapping("/uploads/{date}/{filename:.+}")
    public ResponseEntity<Resource> serveFile(@PathVariable String date,
                                               @PathVariable String filename) {
        try {
            // 1. 路径拼接 + 规范化 (防 ../ 越权)
            Path basePath = Paths.get(uploadDir).toAbsolutePath().normalize();
            Path filePath = basePath.resolve(date).resolve(filename).normalize();

            // 2. 安全校验: 解析后的路径必须在 basePath 下
            if (!filePath.startsWith(basePath)) {
                log.warn("非法路径访问: {}", filePath);
                return ResponseEntity.status(403).build();
            }

            File file = filePath.toFile();
            if (!file.exists() || !file.isFile()) {
                log.warn("文件不存在: {}", filePath);
                return ResponseEntity.notFound().build();
            }

            // 3. 探测 MIME
            String contentType = Files.probeContentType(filePath);
            MediaType mediaType = (contentType != null)
                ? MediaType.parseMediaType(contentType)
                : MediaType.APPLICATION_OCTET_STREAM;

            // 4. 构造 Resource, 返回
            Resource resource = new FileSystemResource(file);
            return ResponseEntity.ok()
                    .contentType(mediaType)
                    .contentLength(file.length())
                    .header(HttpHeaders.CACHE_CONTROL, "max-age=86400")
                    .body(resource);
        } catch (Exception e) {
            log.error("服务上传文件失败: /uploads/{}/{}", date, filename, e);
            return ResponseEntity.status(500).build();
        }
    }
}
