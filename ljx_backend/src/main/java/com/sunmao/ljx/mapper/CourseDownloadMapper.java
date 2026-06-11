package com.sunmao.ljx.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.sunmao.ljx.entity.CourseDownload;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

/**
 * 课程下载记录数据访问层
 */
@Mapper
public interface CourseDownloadMapper extends BaseMapper<CourseDownload> {

    @Select("SELECT * FROM course_download WHERE user_id = #{userId} AND course_id = #{courseId} LIMIT 1")
    CourseDownload selectByUserAndCourse(@Param("userId") Integer userId, @Param("courseId") Integer courseId);

    /**
     * 查询用户的已下载课程，关联 course 表返回完整信息
     * 用于"我的 → 已下载的课程"页面
     */
    @Select("SELECT cd.download_id    AS downloadId, " +
            "       cd.course_id      AS courseId, " +
            "       cd.create_time    AS downloadTime, " +
            "       c.title           AS title, " +
            "       c.cover_image     AS coverImage, " +
            "       c.duration        AS duration, " +
            "       c.difficulty      AS difficulty, " +
            "       c.user_id         AS teacherId, " +
            "       u.nickname        AS teacherName " +
            "FROM course_download cd " +
            "LEFT JOIN course c ON c.course_id = cd.course_id " +
            "LEFT JOIN user u   ON u.user_id   = c.user_id " +
            "WHERE cd.user_id = #{userId} " +
            "ORDER BY cd.create_time DESC " +
            "LIMIT #{limit}")
    List<Map<String, Object>> selectUserDownloadsWithCourse(@Param("userId") Integer userId,
                                                             @Param("limit") Integer limit);
}
