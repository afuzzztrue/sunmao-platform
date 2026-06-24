package com.sunmao.ljx.controller;

import com.sunmao.ljx.common.BusinessException;
import com.sunmao.ljx.common.Result;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;

/**
 * 文件上传控制器
 * 6/25 新增 (项目第 5 轮改进)
 * 6/26 升级: 修复 NoSuchFileException, 改用配置文件指定的上传根目录
 *
 * 接口:
 *   POST /api/upload    单/多文件上传, 字段名 files
 *   返回 { code:200, data:["/uploads/2026-06-25/xxx.jpg", ...] }
 *
 * 限制:
 *   - 单文件 <= 5MB
 *   - 类型: image/jpeg | image/png | image/webp | image/gif
 *   - 存储: ${ljx.upload.dir}/yyyy-MM-dd/<UUID>.<ext>
 *     默认 ${user.dir}/uploads (兼容 mvn spring-boot:run 与 jar 启动)
 */
@RestController
@RequestMapping("/api")
public class UploadController {

    /** 允许的 MIME 类型 */
    private static final Set<String> ALLOWED_TYPES = new HashSet<>(Arrays.asList(
            "image/jpeg", "image/jpg", "image/png", "image/webp", "image/gif"
    ));

    /** 单文件最大 5MB */
    private static final long MAX_FILE_SIZE = 5L * 1024 * 1024;

    /**
     * 上传根目录 (从 application.yml 注入, 默认 user.dir/uploads)
     * 6/26 修复: 用配置文件指定绝对路径, 避免 Spring Boot 工作目录是 Temp 时
     * 相对路径 "uploads" 解析到 C:\Users\...\AppData\Local\Temp\... 导致 NoSuchFileException
     */
    @Value("${ljx.upload.dir:${user.dir}/uploads}")
    private String uploadDir;

    /**
     * 多文件上传
     * 表单字段: files (可重复)
     */
    @PostMapping("/upload")
    public Result<List<String>> upload(@RequestParam("files") MultipartFile[] files) {
        if (files == null || files.length == 0) {
            throw new BusinessException("请选择文件");
        }

        // 1. 创建日期子目录
        String dateStr = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
        File dateDir = new File(uploadDir, dateStr);
        if (!dateDir.exists() && !dateDir.mkdirs()) {
            throw new BusinessException("无法创建上传目录: " + dateDir.getAbsolutePath());
        }

        // 2. 遍历文件, 校验 + 保存
        List<String> urls = new ArrayList<>(files.length);
        for (MultipartFile file : files) {
            if (file.isEmpty()) {
                continue;
            }

            // 2.1 大小校验
            if (file.getSize() > MAX_FILE_SIZE) {
                throw new BusinessException(
                    String.format("文件 [%s] 超过 5MB (%.2fMB)",
                        file.getOriginalFilename(),
                        file.getSize() / 1024.0 / 1024.0)
                );
            }

            // 2.2 类型校验 (双重: contentType + 后缀)
            String contentType = file.getContentType();
            String originalName = file.getOriginalFilename();
            String ext = getFileExtension(originalName);

            if (contentType == null || !ALLOWED_TYPES.contains(contentType.toLowerCase())) {
                throw new BusinessException(
                    "文件类型不支持: " + contentType + " (仅支持 jpg/png/webp/gif)"
                );
            }
            if (!isAllowedExtension(ext)) {
                throw new BusinessException(
                    "文件扩展名不支持: ." + ext + " (仅支持 jpg/png/webp/gif)"
                );
            }

            // 2.3 生成 UUID 文件名 + 保存
            String savedName = UUID.randomUUID().toString().replace("-", "") + "." + ext;
            File dest = new File(dateDir, savedName);
            try {
                file.transferTo(dest);
            } catch (IOException e) {
                throw new BusinessException("文件保存失败: " + e.getMessage());
            }

            // 2.4 返回 URL 路径
            urls.add("/uploads/" + dateStr + "/" + savedName);
        }

        if (urls.isEmpty()) {
            throw new BusinessException("未上传任何有效文件");
        }
        return Result.success(urls);
    }

    /**
     * 提取文件扩展名 (转小写, 不含点)
     */
    private String getFileExtension(String filename) {
        if (filename == null || filename.isEmpty()) {
            return "";
        }
        int dot = filename.lastIndexOf('.');
        if (dot < 0 || dot == filename.length() - 1) {
            return "";
        }
        return filename.substring(dot + 1).toLowerCase();
    }

    /**
     * 校验扩展名
     */
    private boolean isAllowedExtension(String ext) {
        if (ext == null || ext.isEmpty()) {
            return false;
        }
        return ext.equals("jpg") || ext.equals("jpeg")
                || ext.equals("png") || ext.equals("webp")
                || ext.equals("gif");
    }
}

