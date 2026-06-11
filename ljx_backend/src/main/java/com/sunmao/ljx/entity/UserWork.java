package com.sunmao.ljx.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 用户作品实体类
 * 对应数据库表: user_work
 */
@Data
@TableName("user_work")
public class UserWork {

    @TableId(type = IdType.AUTO)
    private Integer workId;

    private Integer userId;

    private String title;

    private String description;

    private String images;

    private Integer likeCount;

    private Integer commentCount;

    private Integer status;

    private LocalDateTime createTime;
}
