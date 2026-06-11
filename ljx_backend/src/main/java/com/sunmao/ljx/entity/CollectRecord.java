package com.sunmao.ljx.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 收藏记录实体类
 * 对应数据库表: collect_record
 */
@Data
@TableName("collect_record")
public class CollectRecord {

    @TableId(type = IdType.AUTO)
    private Integer collectId;

    private Integer userId;

    private Integer articleId;

    private LocalDateTime createTime;
}
