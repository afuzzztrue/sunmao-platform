package com.sunmao.ljx.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 轮播图实体类
 * 对应数据库表: banner
 */
@Data
@TableName("banner")
public class Banner {

    @TableId(type = IdType.AUTO)
    private Integer bannerId;

    private String title;

    private String imageUrl;

    private String linkUrl;

    private Integer linkType;

    private Integer linkId;

    private Integer sortOrder;

    private Integer status;

    private LocalDateTime createTime;
}
