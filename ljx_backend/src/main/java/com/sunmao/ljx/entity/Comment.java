package com.sunmao.ljx.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 评论实体类
 * 对应数据库表: comment
 */
@Data
@TableName("comment")
public class Comment {

    @TableId(type = IdType.AUTO)
    private Integer commentId;

    private Integer userId;

    private Integer targetType;

    private Integer targetId;

    private Integer parentId;

    private String content;

    private Integer likeCount;

    private Integer status;

    private LocalDateTime createTime;
}
