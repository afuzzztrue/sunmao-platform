package com.sunmao.ljx.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 教程课程实体类
 * 对应数据库表: course
 */
@Data
@TableName("course")
public class Course {

    @TableId(type = IdType.AUTO)
    private Integer courseId;

    private Integer categoryId;

    private Integer userId;

    private String title;

    private String description;

    private String coverImage;

    private String videoUrl;

    private Integer duration;

    private Integer difficulty;

    private Integer viewCount;

    private Integer likeCount;

    private Integer downloadCount;

    private Integer sortOrder;

    private Integer status;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}
