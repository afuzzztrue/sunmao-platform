package com.sunmao.ljx.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 课程下载记录实体类
 * 对应数据库表: course_download
 */
@Data
@TableName("course_download")
public class CourseDownload {

    @TableId(type = IdType.AUTO)
    private Integer downloadId;

    private Integer userId;

    private Integer courseId;

    private LocalDateTime createTime;
}
