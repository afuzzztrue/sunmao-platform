package com.sunmao.ljx.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.sunmao.ljx.entity.Course;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

/**
 * 教程课程数据访问层
 */
@Mapper
public interface CourseMapper extends BaseMapper<Course> {

    @Select("SELECT * FROM course WHERE category_id = #{categoryId} AND status = 1 ORDER BY sort_order, create_time DESC")
    List<Course> selectByCategoryId(@Param("categoryId") Integer categoryId);

    @Select("SELECT * FROM course WHERE difficulty = #{difficulty} AND status = 1 ORDER BY sort_order")
    List<Course> selectByDifficulty(@Param("difficulty") Integer difficulty);

    @Update("UPDATE course SET view_count = view_count + 1 WHERE course_id = #{courseId}")
    int incrementViewCount(@Param("courseId") Integer courseId);

    @Update("UPDATE course SET download_count = download_count + 1 WHERE course_id = #{courseId}")
    int incrementDownloadCount(@Param("courseId") Integer courseId);
}
