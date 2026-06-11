package com.sunmao.ljx.controller;

import com.sunmao.ljx.common.Result;
import com.sunmao.ljx.entity.Course;
import com.sunmao.ljx.service.CourseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 教程课程控制器
 */
@RestController
@RequestMapping("/api/course")
public class CourseController {

    @Autowired
    private CourseService courseService;

    @GetMapping("/category/{categoryId}")
    public Result<List<Course>> getCoursesByCategory(@PathVariable Integer categoryId) {
        return Result.success(courseService.getCoursesByCategory(categoryId));
    }

    @GetMapping("/difficulty/{difficulty}")
    public Result<List<Course>> getCoursesByDifficulty(@PathVariable Integer difficulty) {
        return Result.success(courseService.getCoursesByDifficulty(difficulty));
    }

    @PostMapping("/download")
    public Result<Void> recordDownload(@RequestParam Integer courseId,
                                        @RequestParam Integer userId) {
        courseService.recordDownload(courseId, userId);
        return Result.success();
    }

    /**
     * 获取用户已下载课程列表（用于"我的 → 已下载的课程"）
     */
    @GetMapping("/downloads/{userId}")
    public Result<List<Map<String, Object>>> getUserDownloads(@PathVariable Integer userId,
                                                                @RequestParam(defaultValue = "100") Integer limit) {
        return Result.success(courseService.getUserDownloads(userId, limit));
    }
}
