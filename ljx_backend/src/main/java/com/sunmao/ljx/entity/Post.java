package com.sunmao.ljx.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 动态帖子实体类
 * 对应数据库表: post
 */
@Data
@TableName("post")
public class Post {

    @TableId(type = IdType.AUTO)
    private Integer postId;

    private Integer userId;

    private String content;

    private String images;

    private String location;

    private Integer likeCount;

    private Integer commentCount;

    private Integer shareCount;

    private Integer postType;

    private Integer status;

    private LocalDateTime createTime;
}
