-- ========================================================
-- 榫卯非遗文化传承平台 - 完整数据库初始化脚本
-- 适配 MySQL 8.0+ (端口 3307)
-- 数据库名: ljx_platform
-- 字符集: utf8mb4  排序规则: utf8mb4_unicode_ci
-- ========================================================

-- 第一步：创建数据库
CREATE DATABASE IF NOT EXISTS `ljx_platform`
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE `ljx_platform`;

SET FOREIGN_KEY_CHECKS = 0;

-- ========================================================
-- 1. 用户表 (user)
-- ========================================================
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `user_id`      INT          NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `openid`       VARCHAR(64)  DEFAULT NULL COMMENT '微信openid',
  `unionid`      VARCHAR(64)  DEFAULT NULL COMMENT '微信unionid',
  `nickname`     VARCHAR(100) DEFAULT NULL COMMENT '昵称',
  `avatar`       VARCHAR(500) DEFAULT NULL COMMENT '头像URL',
  `phone`        VARCHAR(20)  DEFAULT NULL COMMENT '手机号（注册账号）',
  `email`        VARCHAR(100) DEFAULT NULL COMMENT '邮箱（注册账号）',
  `password`     VARCHAR(255) DEFAULT NULL COMMENT '密码 MD5',
  `gender`       TINYINT      DEFAULT 0  COMMENT '性别: 0未知 1男 2女',
  `province`     VARCHAR(50)  DEFAULT NULL COMMENT '省份',
  `city`         VARCHAR(50)  DEFAULT NULL COMMENT '城市',
  `study_hours`  INT          DEFAULT 0  COMMENT '学习时长(小时)',
  `user_type`    TINYINT      DEFAULT 0  COMMENT '类型: 0普通用户 1传承人 2管理员',
  `status`       TINYINT      DEFAULT 1  COMMENT '状态: 0禁用 1正常',
  `create_time`  DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`  DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uk_user_openid` (`openid`),
  UNIQUE KEY `uk_user_phone`  (`phone`),
  UNIQUE KEY `uk_user_email`  (`email`),
  KEY `idx_user_type`         (`user_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- ========================================================
-- 2. 内容分类表 (category)
-- ========================================================
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category` (
  `category_id` INT          NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `name`        VARCHAR(50)  NOT NULL COMMENT '分类名称',
  `parent_id`   INT          DEFAULT 0  COMMENT '父分类ID, 0=根',
  `sort_order`  INT          DEFAULT 0  COMMENT '排序号',
  `icon`        VARCHAR(500) DEFAULT NULL COMMENT '图标URL',
  `description` VARCHAR(255) DEFAULT NULL COMMENT '描述',
  `status`      TINYINT      DEFAULT 1  COMMENT '0禁用 1启用',
  `create_time` DATETIME     DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`category_id`),
  KEY `idx_category_parent` (`parent_id`),
  KEY `idx_category_sort`   (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='内容分类表';

-- ========================================================
-- 3. 内容文章表 (article)
-- ========================================================
DROP TABLE IF EXISTS `article`;
CREATE TABLE `article` (
  `article_id`    INT          NOT NULL AUTO_INCREMENT COMMENT '文章ID',
  `category_id`   INT          NOT NULL COMMENT '分类ID',
  `user_id`       INT          NOT NULL COMMENT '发布者ID',
  `title`         VARCHAR(200) NOT NULL COMMENT '标题',
  `summary`       VARCHAR(500) DEFAULT NULL COMMENT '摘要',
  `content`       TEXT         DEFAULT NULL COMMENT '正文 HTML',
  `cover_image`   VARCHAR(500) DEFAULT NULL COMMENT '封面图',
  `images`        TEXT         DEFAULT NULL COMMENT '图片列表 JSON',
  `tags`          VARCHAR(255) DEFAULT NULL COMMENT '标签',
  `location`      VARCHAR(100) DEFAULT NULL COMMENT '地理位置',
  `view_count`    INT          DEFAULT 0  COMMENT '浏览数',
  `like_count`    INT          DEFAULT 0  COMMENT '点赞数',
  `comment_count` INT          DEFAULT 0  COMMENT '评论数',
  `collect_count` INT          DEFAULT 0  COMMENT '收藏数',
  `is_hot`        TINYINT      DEFAULT 0  COMMENT '热门: 0否 1是',
  `is_banner`     TINYINT      DEFAULT 0  COMMENT '轮播: 0否 1是',
  `sort_order`    INT          DEFAULT 0  COMMENT '排序',
  `status`        TINYINT      DEFAULT 1  COMMENT '0草稿 1发布 2下架',
  `create_time`   DATETIME     DEFAULT CURRENT_TIMESTAMP,
  `update_time`   DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`article_id`),
  KEY `idx_article_category`    (`category_id`),
  KEY `idx_article_user`        (`user_id`),
  KEY `idx_article_hot`         (`is_hot`),
  KEY `idx_article_status`      (`status`),
  KEY `idx_article_create_time` (`create_time`),
  FULLTEXT KEY `ft_article_title` (`title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='内容文章表';

-- ========================================================
-- 4. 动态帖子表 (post)
-- ========================================================
DROP TABLE IF EXISTS `post`;
CREATE TABLE `post` (
  `post_id`       INT      NOT NULL AUTO_INCREMENT COMMENT '帖子ID',
  `user_id`       INT      NOT NULL COMMENT '发布者ID',
  `content`       TEXT     NOT NULL COMMENT '内容',
  `images`        TEXT     DEFAULT NULL COMMENT '图片 JSON',
  `location`      VARCHAR(100) DEFAULT NULL COMMENT '位置',
  `like_count`    INT      DEFAULT 0  COMMENT '点赞数',
  `comment_count` INT      DEFAULT 0  COMMENT '评论数',
  `share_count`   INT      DEFAULT 0  COMMENT '分享数',
  `post_type`     TINYINT  DEFAULT 0  COMMENT '0普通 1热门',
  `status`        TINYINT  DEFAULT 1  COMMENT '0删除 1正常',
  `create_time`   DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`post_id`),
  KEY `idx_post_user`        (`user_id`),
  KEY `idx_post_type`        (`post_type`),
  KEY `idx_post_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='动态帖子表';

-- ========================================================
-- 5. 点赞记录表 (like_record)
-- ========================================================
DROP TABLE IF EXISTS `like_record`;
CREATE TABLE `like_record` (
  `like_id`     INT      NOT NULL AUTO_INCREMENT,
  `user_id`     INT      NOT NULL COMMENT '用户ID',
  `target_type` TINYINT  NOT NULL COMMENT '目标类型: 1文章 2帖子',
  `target_id`   INT      NOT NULL COMMENT '目标ID',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`like_id`),
  UNIQUE KEY `uk_like_user_target` (`user_id`, `target_type`, `target_id`),
  KEY `idx_like_target` (`target_type`, `target_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='点赞记录表';

-- ========================================================
-- 6. 评论表 (comment)
-- ========================================================
DROP TABLE IF EXISTS `comment`;
CREATE TABLE `comment` (
  `comment_id`  INT      NOT NULL AUTO_INCREMENT,
  `user_id`     INT      NOT NULL COMMENT '评论者ID',
  `target_type` TINYINT  NOT NULL COMMENT '目标类型: 1文章 2帖子',
  `target_id`   INT      NOT NULL COMMENT '目标ID',
  `parent_id`   INT      DEFAULT 0  COMMENT '父评论ID',
  `content`     TEXT     NOT NULL COMMENT '内容',
  `like_count`  INT      DEFAULT 0,
  `status`      TINYINT  DEFAULT 1 COMMENT '0删除 1正常',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`comment_id`),
  KEY `idx_comment_target` (`target_type`, `target_id`),
  KEY `idx_comment_user`   (`user_id`),
  KEY `idx_comment_parent` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='评论表';

-- ========================================================
-- 7. 收藏记录表 (collect_record)
-- ========================================================
DROP TABLE IF EXISTS `collect_record`;
CREATE TABLE `collect_record` (
  `collect_id`  INT      NOT NULL AUTO_INCREMENT,
  `user_id`     INT      NOT NULL,
  `article_id`  INT      NOT NULL,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`collect_id`),
  UNIQUE KEY `uk_collect_user_article` (`user_id`, `article_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='收藏记录表';

-- ========================================================
-- 8. 关注关系表 (follow)
-- ========================================================
DROP TABLE IF EXISTS `follow`;
CREATE TABLE `follow` (
  `follow_id`      INT      NOT NULL AUTO_INCREMENT,
  `user_id`        INT      NOT NULL COMMENT '关注者ID',
  `follow_user_id` INT      NOT NULL COMMENT '被关注者ID',
  `create_time`    DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`follow_id`),
  UNIQUE KEY `uk_follow_user` (`user_id`, `follow_user_id`),
  KEY `idx_followed_user_id`  (`follow_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='关注关系表';

-- ========================================================
-- 9. 浏览足迹表 (footprint)
-- ========================================================
DROP TABLE IF EXISTS `footprint`;
CREATE TABLE `footprint` (
  `footprint_id` INT      NOT NULL AUTO_INCREMENT,
  `user_id`      INT      NOT NULL,
  `article_id`   INT      NOT NULL,
  `create_time`  DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`footprint_id`),
  KEY `idx_footprint_user` (`user_id`),
  KEY `idx_footprint_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='浏览足迹表';

-- ========================================================
-- 10. 教程课程表 (course)
-- ========================================================
DROP TABLE IF EXISTS `course`;
CREATE TABLE `course` (
  `course_id`     INT          NOT NULL AUTO_INCREMENT,
  `category_id`   INT          NOT NULL COMMENT '分类ID',
  `user_id`       INT          NOT NULL COMMENT '讲师ID',
  `title`         VARCHAR(200) NOT NULL COMMENT '标题',
  `description`   TEXT         DEFAULT NULL,
  `cover_image`   VARCHAR(500) DEFAULT NULL COMMENT '封面图',
  `video_url`     VARCHAR(500) DEFAULT NULL,
  `duration`      INT          DEFAULT 0  COMMENT '时长(分钟)',
  `difficulty`    TINYINT      DEFAULT 1  COMMENT '1入门 2进阶 3高级 4大师',
  `view_count`    INT          DEFAULT 0,
  `like_count`    INT          DEFAULT 0,
  `download_count` INT         DEFAULT 0,
  `sort_order`    INT          DEFAULT 0,
  `status`        TINYINT      DEFAULT 1  COMMENT '0下架 1上架',
  `create_time`   DATETIME     DEFAULT CURRENT_TIMESTAMP,
  `update_time`   DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`course_id`),
  KEY `idx_course_category`  (`category_id`),
  KEY `idx_course_user`      (`user_id`),
  KEY `idx_course_status`    (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='教程课程表';

-- ========================================================
-- 11. 课程下载记录表 (course_download)
-- ========================================================
DROP TABLE IF EXISTS `course_download`;
CREATE TABLE `course_download` (
  `download_id` INT      NOT NULL AUTO_INCREMENT,
  `user_id`     INT      NOT NULL,
  `course_id`   INT      NOT NULL,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`download_id`),
  UNIQUE KEY `uk_download_user_course` (`user_id`, `course_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='课程下载记录表';

-- ========================================================
-- 12. 用户作品表 (user_work)
-- ========================================================
DROP TABLE IF EXISTS `user_work`;
CREATE TABLE `user_work` (
  `work_id`       INT          NOT NULL AUTO_INCREMENT,
  `user_id`       INT          NOT NULL,
  `title`         VARCHAR(200) NOT NULL COMMENT '作品标题',
  `description`   TEXT         DEFAULT NULL,
  `images`        TEXT         DEFAULT NULL COMMENT '图片 JSON',
  `like_count`    INT          DEFAULT 0,
  `comment_count` INT          DEFAULT 0,
  `status`        TINYINT      DEFAULT 1 COMMENT '0删除 1正常',
  `create_time`   DATETIME     DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`work_id`),
  KEY `idx_work_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户作品表';

-- ========================================================
-- 13. 轮播图表 (banner)
-- ========================================================
DROP TABLE IF EXISTS `banner`;
CREATE TABLE `banner` (
  `banner_id`  INT          NOT NULL AUTO_INCREMENT,
  `title`      VARCHAR(100) DEFAULT NULL,
  `image_url`  VARCHAR(500) NOT NULL,
  `link_url`   VARCHAR(500) DEFAULT NULL,
  `link_type`  TINYINT      DEFAULT 1 COMMENT '1文章 2外部链接',
  `link_id`    INT          DEFAULT NULL COMMENT '关联文章ID',
  `sort_order` INT          DEFAULT 0,
  `status`     TINYINT      DEFAULT 1 COMMENT '0禁用 1启用',
  `create_time` DATETIME    DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`banner_id`),
  KEY `idx_banner_sort`   (`sort_order`),
  KEY `idx_banner_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='轮播图表';

-- ========================================================
-- 14. 系统配置表 (sys_config)
-- ========================================================
DROP TABLE IF EXISTS `sys_config`;
CREATE TABLE `sys_config` (
  `config_id`    INT          NOT NULL AUTO_INCREMENT,
  `config_key`   VARCHAR(100) NOT NULL COMMENT '配置键',
  `config_value` TEXT         DEFAULT NULL COMMENT '配置值',
  `description`  VARCHAR(255) DEFAULT NULL,
  `create_time`  DATETIME     DEFAULT CURRENT_TIMESTAMP,
  `update_time`  DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`config_id`),
  UNIQUE KEY `uk_config_key` (`config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统配置表';

-- ========================================================
-- 15. 商城商品表 (product) ★ 新增
-- ========================================================
DROP TABLE IF EXISTS `product`;
CREATE TABLE `product` (
  `product_id`   INT            NOT NULL AUTO_INCREMENT COMMENT '商品ID',
  `product_name` VARCHAR(200)   NOT NULL COMMENT '商品名称',
  `category_id`  INT            NOT NULL COMMENT '分类ID: 1家具 2木料 3工具 4课程',
  `price`        DECIMAL(10,2)  NOT NULL COMMENT '价格',
  `cover_image`  VARCHAR(500)   DEFAULT NULL COMMENT '封面图',
  `description`  TEXT           DEFAULT NULL COMMENT '详情',
  `stock`        INT            DEFAULT 0  COMMENT '库存',
  `status`       TINYINT        DEFAULT 1  COMMENT '0下架 1上架',
  `create_time`  DATETIME       DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`product_id`),
  KEY `idx_product_category` (`category_id`),
  KEY `idx_product_status`   (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商城商品表';

-- ========================================================
-- 16. 商城订单表 (product_order) ★ 新增
-- ========================================================
DROP TABLE IF EXISTS `product_order`;
CREATE TABLE `product_order` (
  `order_id`     INT            NOT NULL AUTO_INCREMENT COMMENT '订单ID',
  `product_id`   INT            NOT NULL COMMENT '商品ID',
  `product_name` VARCHAR(200)   NOT NULL COMMENT '商品名称(冗余)',
  `user_id`      INT            NOT NULL COMMENT '买家ID',
  `quantity`     INT            NOT NULL DEFAULT 1 COMMENT '数量',
  `total_price`  DECIMAL(10,2)  NOT NULL COMMENT '总价',
  `status`       TINYINT        DEFAULT 0  COMMENT '0待付款 1已付款 2已发货 3已完成 4已取消',
  `create_time`  DATETIME       DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`order_id`),
  KEY `idx_order_user`    (`user_id`),
  KEY `idx_order_product` (`product_id`),
  KEY `idx_order_status`  (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商城订单表';

SET FOREIGN_KEY_CHECKS = 1;

-- ========================================================
-- 初始化种子数据
-- ========================================================

-- 分类数据（5个榫卯分类）
INSERT INTO `category` (`name`, `parent_id`, `sort_order`, `icon`, `description`, `status`, `create_time`) VALUES
('结构', 0, 1, '../images/结构-1.png', '榫卯结构相关内容', 1, NOW()),
('家具', 0, 2, '../images/家具-1.png', '传统家具相关内容', 1, NOW()),
('木料', 0, 3, '../images/紫檀木.png', '木料材质相关内容', 1, NOW()),
('历史', 0, 4, '../images/唐代.png',   '榫卯历史相关内容', 1, NOW()),
('教程', 0, 5, '../images/入门.png',   '制作教程相关内容', 1, NOW());

-- 轮播图数据
INSERT INTO `banner` (`title`, `image_url`, `link_type`, `sort_order`, `status`, `create_time`) VALUES
('轮播图1', '../images/轮播-1.jpg', 1, 1, 1, NOW()),
('轮播图2', '../images/轮播-2.jpg', 1, 2, 1, NOW()),
('轮播图3', '../images/轮播-3.jpg', 1, 3, 1, NOW()),
('轮播图4', '../images/轮播-4.jpg', 1, 4, 1, NOW());

-- ========================================================
-- 执行完毕后手动操作:
-- 1. 小程序注册一个新用户
-- 2. 将注册的用户设为管理员:
--    UPDATE user SET user_type = 2 WHERE user_id = (你的实际user_id);
-- 3. 执行 seed_products.sql 插入商城演示商品
-- ========================================================
