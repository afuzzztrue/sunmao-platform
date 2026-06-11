package com.sunmao.ljx.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 浏览足迹实体类
 * 对应数据库表: footprint
 */
@Data
@TableName("footprint")
public class Footprint {

    @TableId(type = IdType.AUTO)
    private Integer footprintId;

    private Integer userId;

    private Integer articleId;

    private LocalDateTime createTime;

    private String snapshotTitle;

    private String snapshotCover;

    private String snapshotAuthor;
}
