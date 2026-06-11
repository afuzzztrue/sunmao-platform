package com.sunmao.ljx.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.sunmao.ljx.entity.Course;
import com.sunmao.ljx.entity.CourseDownload;
import com.sunmao.ljx.mapper.CourseDownloadMapper;
import com.sunmao.ljx.mapper.CourseMapper;
import com.sunmao.ljx.service.CourseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 教程课程服务实现类
 */
@Service
public class CourseServiceImpl extends ServiceImpl<CourseMapper, Course> implements CourseService {

    @Autowired
    private CourseDownloadMapper courseDownloadMapper;

    @Override
    public List<Course> getCoursesByCategory(Integer categoryId) {
        return baseMapper.selectByCategoryId(categoryId);
    }

    @Override
    public List<Course> getCoursesByDifficulty(Integer difficulty) {
        return baseMapper.selectByDifficulty(difficulty);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void recordDownload(Integer courseId, Integer userId) {
        CourseDownload download = courseDownloadMapper.selectByUserAndCourse(userId, courseId);
        if (download == null) {
            download = new CourseDownload();
            download.setUserId(userId);
            download.setCourseId(courseId);
            download.setCreateTime(LocalDateTime.now());
            courseDownloadMapper.insert(download);
            baseMapper.incrementDownloadCount(courseId);
        }
    }

    @Override
    public List<Map<String, Object>> getUserDownloads(Integer userId, Integer limit) {
        if (limit == null || limit <= 0) limit = 100;
        return courseDownloadMapper.selectUserDownloadsWithCourse(userId, limit);
    }
}
