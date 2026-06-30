package com.sunmao.ljx.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("product")
public class Product {

    @TableId(type = IdType.AUTO)
    private Integer productId;

    private String productName;

    private Integer categoryId;

    private Integer courseId;

    private BigDecimal price;

    private String coverImage;

    private String description;

    private Integer stock;

    private Integer status;

    private LocalDateTime createTime;
}
