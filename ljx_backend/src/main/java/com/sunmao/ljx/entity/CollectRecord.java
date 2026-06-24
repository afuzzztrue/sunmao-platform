package com.sunmao.ljx.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 收藏记录实体类
 * 对应数据库表: collect_record
 *
 * 6/26 升级: 新增 targetType + targetId 字段, 对齐 like_record 结构,
 * 支持收藏 5 种类型 (1文章 2帖子 3课程 4作品 5结构).
 * 老数据 (articleId != null, targetType IS NULL) 视为 type=1, targetId=articleId.
 */
@Data
@TableName("collect_record")
public class CollectRecord {

    @TableId(type = IdType.AUTO)
    private Integer collectId;

    private Integer userId;

    /** 老字段: 收藏的文章 ID, 保留用于向下兼容, targetType=1 时与 targetId 同步 */
    private Integer articleId;

    /** 6/26 新增: 1文章 2帖子 3课程 4作品 5结构 */
    private Integer targetType;

    /** 6/26 新增: 对应类型的目标 ID */
    private Integer targetId;

    private LocalDateTime createTime;
}
