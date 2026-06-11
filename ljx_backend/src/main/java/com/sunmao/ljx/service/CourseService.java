package com.sunmao.ljx.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.sunmao.ljx.entity.Course;

import java.util.List;
import java.util.Map;

/**
 * 教程课程服务接口
 */
public interface CourseService extends IService<Course> {

    List<Course> getCoursesByCategory(Integer categoryId);

    List<Course> getCoursesByDifficulty(Integer difficulty);

    void recordDownload(Integer courseId, Integer userId);

    /**
     * 获取用户已下载课程（关联 course 表）
     */
    List<Map<String, Object>> getUserDownloads(Integer userId, Integer limit);
}
