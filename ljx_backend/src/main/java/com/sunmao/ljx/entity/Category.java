package com.sunmao.ljx.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 内容分类实体类
 * 对应数据库表: category
 */
@Data
@TableName("category")
public class Category {

    @TableId(type = IdType.AUTO)
    private Integer categoryId;

    private String name;

    private Integer parentId;

    private Integer sortOrder;

    private String icon;

    private String description;

    private Integer status;

    private LocalDateTime createTime;
}
