package com.sunmao.ljx.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("product_order")
public class ProductOrder {

    @TableId(type = IdType.AUTO)
    private Integer orderId;

    private Integer productId;

    private String productName;

    private Integer userId;

    private Integer quantity;

    private BigDecimal totalPrice;

    private Integer status;

    private LocalDateTime createTime;
}
