package com.sunmao.ljx.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 内容文章实体类
 * 对应数据库表: article
 */
@Data
@TableName("article")
public class Article {

    @TableId(type = IdType.AUTO)
    private Integer articleId;

    private Integer categoryId;

    private Integer userId;

    private String title;

    private String summary;

    private String content;

    private String coverImage;

    private String images;

    private String tags;

    private String location;

    private Integer viewCount;

    private Integer likeCount;

    private Integer commentCount;

    private Integer collectCount;

    private Integer isHot;

    private Integer isBanner;

    private Integer sortOrder;

    private Integer status;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}
