-- ================================================================
-- 榫卯非遗文化传承平台 - 完整数据库初始化脚本
-- --------------------------------------------------------------
-- 版本:       v1.0 (2026-06-12 整合版)
-- 适用数据库:  MySQL 8.0+ (已用 8.0.46 测试)
-- 端口:        3307
-- 字符集:      utf8mb4 / utf8mb4_unicode_ci
-- 存储引擎:    InnoDB
-- 整合来源:
--   1. init_database.sql                          (14 张原表 + 商城 2 张)
--   2. seed_products.sql                          (15 条商品)
--   3. migrations/2026-06-10-my-tabs-backend...   (feedback + 偏好 + 快照)
-- --------------------------------------------------------------
-- 一键执行: 在 DBeaver 选中整个脚本, Ctrl+A → Ctrl+Enter
-- 或命令行:
--   mysql -uroot -p12345 -P3307 < schema_mysql8_full.sql
-- --------------------------------------------------------------
-- 脚本可重复执行 (开头先 DROP 所有表, 末尾再次启用外键检查)
-- ================================================================


-- ================================================================
-- 第一部分: 准备工作
-- ================================================================

-- 1.1 关闭外键检查 (允许 DROP 顺序无关, CREATE 顺序无关)
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 1.2 创建数据库 (如不存在)
CREATE DATABASE IF NOT EXISTS `ljx_platform`
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE      utf8mb4_unicode_ci;

-- 1.3 切换到目标库
USE `ljx_platform`;


-- ================================================================
-- 第二部分: 清理旧表 (按依赖关系倒序, 子表先删)
-- ================================================================

DROP TABLE IF EXISTS `feedback`;        -- 用户反馈
DROP TABLE IF EXISTS `product_order`;   -- 商城订单 (依赖 product / user)
DROP TABLE IF EXISTS `product`;         -- 商城商品
DROP TABLE IF EXISTS `course_download`;  -- 课程下载
DROP TABLE IF EXISTS `course`;          -- 教程课程
DROP TABLE IF EXISTS `user_work`;       -- 用户作品
DROP TABLE IF EXISTS `footprint`;        -- 浏览足迹
DROP TABLE IF EXISTS `follow`;          -- 关注关系
DROP TABLE IF EXISTS `collect_record`;  -- 收藏记录
DROP TABLE IF EXISTS `comment`;         -- 评论
DROP TABLE IF EXISTS `like_record`;     -- 点赞记录
DROP TABLE IF EXISTS `post`;            -- 动态帖子
DROP TABLE IF EXISTS `article`;         -- 内容文章
DROP TABLE IF EXISTS `category`;        -- 内容分类
DROP TABLE IF EXISTS `banner`;          -- 轮播图
DROP TABLE IF EXISTS `sys_config`;      -- 系统配置
DROP TABLE IF EXISTS `user`;            -- 用户


-- ================================================================
-- 第三部分: 建表 (按依赖关系正序, 父表先建)
-- ================================================================

-- ------------------------------------------------------------
-- 3.1 用户表 user
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `user_id`      INT          NOT NULL                AUTO_INCREMENT              COMMENT '用户ID, 主键',
  `openid`       VARCHAR(64)  DEFAULT NULL                                    COMMENT '微信openid',
  `unionid`      VARCHAR(64)  DEFAULT NULL                                    COMMENT '微信unionid',
  `nickname`     VARCHAR(100) DEFAULT NULL                                    COMMENT '昵称',
  `avatar`       VARCHAR(500) DEFAULT NULL                                    COMMENT '头像URL',
  `phone`        VARCHAR(20)  DEFAULT NULL                                    COMMENT '手机号(注册账号)',
  `email`        VARCHAR(100) DEFAULT NULL                                    COMMENT '邮箱(注册账号)',
  `password`     VARCHAR(255) DEFAULT NULL                                    COMMENT '密码 MD5',
  `gender`       TINYINT      DEFAULT 0                                       COMMENT '性别: 0未知 1男 2女',
  `province`     VARCHAR(50)  DEFAULT NULL                                    COMMENT '省份',
  `city`         VARCHAR(50)  DEFAULT NULL                                    COMMENT '城市',
  `study_hours`  INT          DEFAULT 0                                       COMMENT '学习时长(小时)',
  `user_type`    TINYINT      DEFAULT 0                                       COMMENT '类型: 0普通 1传承人 2管理员',
  `status`       TINYINT      DEFAULT 1                                       COMMENT '状态: 0禁用 1正常',
  `preferences`  JSON         DEFAULT NULL                                    COMMENT '用户偏好 {notify, darkMode, fontSize, language}',
  `create_time`  DATETIME     DEFAULT CURRENT_TIMESTAMP                       COMMENT '创建时间',
  `update_time`  DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uk_user_openid` (`openid`),
  UNIQUE KEY `uk_user_phone`  (`phone`),
  UNIQUE KEY `uk_user_email`  (`email`),
  KEY        `idx_user_type`  (`user_type`),
  KEY        `idx_user_status`(`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';


-- ------------------------------------------------------------
-- 3.2 系统配置表 sys_config
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `sys_config`;
CREATE TABLE `sys_config` (
  `config_id`    INT          NOT NULL                AUTO_INCREMENT     COMMENT '配置ID',
  `config_key`   VARCHAR(100) NOT NULL                                   COMMENT '配置键 (唯一)',
  `config_value` TEXT         DEFAULT NULL                               COMMENT '配置值',
  `description`  VARCHAR(255) DEFAULT NULL                               COMMENT '配置说明',
  `create_time`  DATETIME     DEFAULT CURRENT_TIMESTAMP                  COMMENT '创建时间',
  `update_time`  DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`config_id`),
  UNIQUE KEY `uk_config_key` (`config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统配置表 (键值对)';


-- ------------------------------------------------------------
-- 3.3 内容分类表 category (树形)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category` (
  `category_id`  INT          NOT NULL                AUTO_INCREMENT  COMMENT '分类ID',
  `name`         VARCHAR(50)  NOT NULL                                  COMMENT '分类名称',
  `parent_id`    INT          DEFAULT 0                                 COMMENT '父分类ID, 0=根',
  `sort_order`   INT          DEFAULT 0                                 COMMENT '排序号 (升序)',
  `icon`         VARCHAR(500) DEFAULT NULL                              COMMENT '分类图标URL',
  `description`  VARCHAR(255) DEFAULT NULL                              COMMENT '分类描述',
  `status`       TINYINT      DEFAULT 1                                 COMMENT '状态: 0禁用 1启用',
  `create_time`  DATETIME     DEFAULT CURRENT_TIMESTAMP                 COMMENT '创建时间',
  PRIMARY KEY (`category_id`),
  KEY `idx_category_parent` (`parent_id`),
  KEY `idx_category_sort`   (`sort_order`),
  KEY `idx_category_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='内容分类表';


-- ------------------------------------------------------------
-- 3.4 轮播图表 banner
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `banner`;
CREATE TABLE `banner` (
  `banner_id`    INT          NOT NULL                AUTO_INCREMENT  COMMENT '轮播图ID',
  `title`        VARCHAR(100) DEFAULT NULL                              COMMENT '标题',
  `image_url`    VARCHAR(500) NOT NULL                                  COMMENT '图片URL',
  `link_url`     VARCHAR(500) DEFAULT NULL                              COMMENT '跳转URL',
  `link_type`    TINYINT      DEFAULT 1                                 COMMENT '跳转类型: 1文章 2外部链接',
  `link_id`      INT          DEFAULT NULL                              COMMENT '关联ID (文章ID等)',
  `sort_order`   INT          DEFAULT 0                                 COMMENT '排序号',
  `status`       TINYINT      DEFAULT 1                                 COMMENT '状态: 0禁用 1启用',
  `create_time`  DATETIME     DEFAULT CURRENT_TIMESTAMP                 COMMENT '创建时间',
  PRIMARY KEY (`banner_id`),
  KEY `idx_banner_sort`   (`sort_order`),
  KEY `idx_banner_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='首页轮播图表';


-- ------------------------------------------------------------
-- 3.5 内容文章表 article
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `article`;
CREATE TABLE `article` (
  `article_id`    INT          NOT NULL                AUTO_INCREMENT  COMMENT '文章ID',
  `category_id`   INT          NOT NULL                                  COMMENT '分类ID',
  `user_id`       INT          NOT NULL                                  COMMENT '发布者ID',
  `title`         VARCHAR(200) NOT NULL                                  COMMENT '标题',
  `summary`       VARCHAR(500) DEFAULT NULL                              COMMENT '摘要',
  `content`       LONGTEXT     DEFAULT NULL                              COMMENT '正文 (HTML/富文本)',
  `cover_image`   VARCHAR(500) DEFAULT NULL                              COMMENT '封面图URL',
  `images`        TEXT         DEFAULT NULL                              COMMENT '图片列表 JSON',
  `tags`          VARCHAR(255) DEFAULT NULL                              COMMENT '标签 逗号分隔',
  `location`      VARCHAR(100) DEFAULT NULL                              COMMENT '地理位置',
  `view_count`    INT          DEFAULT 0                                 COMMENT '浏览数',
  `like_count`    INT          DEFAULT 0                                 COMMENT '点赞数',
  `comment_count` INT          DEFAULT 0                                 COMMENT '评论数',
  `collect_count` INT          DEFAULT 0                                 COMMENT '收藏数',
  `is_hot`        TINYINT      DEFAULT 0                                 COMMENT '是否热门: 0否 1是',
  `is_banner`     TINYINT      DEFAULT 0                                 COMMENT '是否轮播: 0否 1是',
  `sort_order`    INT          DEFAULT 0                                 COMMENT '排序',
  `status`        TINYINT      DEFAULT 1                                 COMMENT '状态: 0草稿 1发布 2下架',
  `create_time`   DATETIME     DEFAULT CURRENT_TIMESTAMP                 COMMENT '创建时间',
  `update_time`   DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`article_id`),
  KEY         `idx_article_category`    (`category_id`),
  KEY         `idx_article_user`        (`user_id`),
  KEY         `idx_article_hot`         (`is_hot`),
  KEY         `idx_article_banner`      (`is_banner`),
  KEY         `idx_article_status`      (`status`),
  KEY         `idx_article_create_time` (`create_time`),
  FULLTEXT KEY `ft_article_title`       (`title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='内容文章表';


-- ------------------------------------------------------------
-- 3.6 动态帖子表 post
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `post`;
CREATE TABLE `post` (
  `post_id`       INT           NOT NULL                AUTO_INCREMENT  COMMENT '帖子ID',
  `user_id`       INT           NOT NULL                                  COMMENT '发布者ID',
  `content`       TEXT          NOT NULL                                  COMMENT '帖子内容',
  `images`        TEXT          DEFAULT NULL                              COMMENT '图片列表 JSON',
  `location`      VARCHAR(100)  DEFAULT NULL                              COMMENT '发布位置',
  `like_count`    INT           DEFAULT 0                                 COMMENT '点赞数',
  `comment_count` INT           DEFAULT 0                                 COMMENT '评论数',
  `share_count`   INT           DEFAULT 0                                 COMMENT '分享数',
  `post_type`     TINYINT       DEFAULT 0                                 COMMENT '帖子类型: 0普通 1热门',
  `status`        TINYINT       DEFAULT 1                                 COMMENT '状态: 0删除 1正常',
  `create_time`   DATETIME      DEFAULT CURRENT_TIMESTAMP                 COMMENT '创建时间',
  PRIMARY KEY (`post_id`),
  KEY `idx_post_user`        (`user_id`),
  KEY `idx_post_type`        (`post_type`),
  KEY `idx_post_status`      (`status`),
  KEY `idx_post_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='动态帖子表';


-- ------------------------------------------------------------
-- 3.7 点赞记录表 like_record (target_type 多态)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `like_record`;
CREATE TABLE `like_record` (
  `like_id`      INT      NOT NULL                AUTO_INCREMENT  COMMENT '点赞ID',
  `user_id`      INT      NOT NULL                                  COMMENT '点赞用户ID',
  `target_type`  TINYINT  NOT NULL                                  COMMENT '目标类型: 1文章 2帖子 3课程 4作品 5结构',
  `target_id`    INT      NOT NULL                                  COMMENT '目标ID',
  `create_time`  DATETIME DEFAULT CURRENT_TIMESTAMP                 COMMENT '点赞时间',
  PRIMARY KEY (`like_id`),
  UNIQUE KEY `uk_like_user_target` (`user_id`, `target_type`, `target_id`),
  KEY        `idx_like_target`     (`target_type`, `target_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='点赞记录表';


-- ------------------------------------------------------------
-- 3.8 评论表 comment (target_type 多态 + parent 自关联)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `comment`;
CREATE TABLE `comment` (
  `comment_id`  INT      NOT NULL                AUTO_INCREMENT  COMMENT '评论ID',
  `user_id`     INT      NOT NULL                                  COMMENT '评论者ID',
  `target_type` TINYINT  NOT NULL                                  COMMENT '目标类型: 1文章 2帖子',
  `target_id`   INT      NOT NULL                                  COMMENT '目标ID',
  `parent_id`   INT      DEFAULT 0                                 COMMENT '父评论ID, 0=一级评论',
  `content`     TEXT     NOT NULL                                  COMMENT '评论内容',
  `like_count`  INT      DEFAULT 0                                 COMMENT '点赞数',
  `status`      TINYINT  DEFAULT 1                                 COMMENT '状态: 0删除 1正常',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP                 COMMENT '创建时间',
  PRIMARY KEY (`comment_id`),
  KEY `idx_comment_target` (`target_type`, `target_id`),
  KEY `idx_comment_user`   (`user_id`),
  KEY `idx_comment_parent` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='评论表';


-- ------------------------------------------------------------
-- 3.9 收藏记录表 collect_record
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `collect_record`;
CREATE TABLE `collect_record` (
  `collect_id`  INT      NOT NULL                AUTO_INCREMENT  COMMENT '收藏ID',
  `user_id`     INT      NOT NULL                                  COMMENT '用户ID',
  `article_id`  INT      NOT NULL                                  COMMENT '文章ID',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP                 COMMENT '收藏时间',
  PRIMARY KEY (`collect_id`),
  UNIQUE KEY `uk_collect_user_article` (`user_id`, `article_id`),
  KEY        `idx_collect_article`    (`article_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='收藏记录表';


-- ------------------------------------------------------------
-- 3.10 关注关系表 follow
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `follow`;
CREATE TABLE `follow` (
  `follow_id`       INT      NOT NULL                AUTO_INCREMENT  COMMENT '关注ID',
  `user_id`         INT      NOT NULL                                  COMMENT '关注者ID',
  `follow_user_id`  INT      NOT NULL                                  COMMENT '被关注者ID',
  `create_time`     DATETIME DEFAULT CURRENT_TIMESTAMP                 COMMENT '关注时间',
  PRIMARY KEY (`follow_id`),
  UNIQUE KEY `uk_follow_user`         (`user_id`, `follow_user_id`),
  KEY        `idx_followed_user_id`   (`follow_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='关注关系表';


-- ------------------------------------------------------------
-- 3.11 浏览足迹表 footprint (带快照字段)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `footprint`;
CREATE TABLE `footprint` (
  `footprint_id`     INT          NOT NULL                AUTO_INCREMENT  COMMENT '足迹ID',
  `user_id`          INT          NOT NULL                                  COMMENT '用户ID',
  `article_id`       INT          NOT NULL                                  COMMENT '文章ID',
  `snapshot_title`   VARCHAR(200) DEFAULT NULL                              COMMENT '文章标题快照 (防删除后空)',
  `snapshot_cover`   VARCHAR(500) DEFAULT NULL                              COMMENT '文章封面快照',
  `snapshot_author`  VARCHAR(100) DEFAULT NULL                              COMMENT '文章作者快照',
  `create_time`      DATETIME     DEFAULT CURRENT_TIMESTAMP                 COMMENT '浏览时间',
  PRIMARY KEY (`footprint_id`),
  KEY `idx_footprint_user` (`user_id`),
  KEY `idx_footprint_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='浏览足迹表';


-- ------------------------------------------------------------
-- 3.12 教程课程表 course
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `course`;
CREATE TABLE `course` (
  `course_id`      INT          NOT NULL                AUTO_INCREMENT  COMMENT '课程ID',
  `category_id`    INT          NOT NULL                                  COMMENT '分类ID',
  `user_id`        INT          NOT NULL                                  COMMENT '讲师ID',
  `title`          VARCHAR(200) NOT NULL                                  COMMENT '课程标题',
  `description`    TEXT         DEFAULT NULL                              COMMENT '课程描述',
  `cover_image`    VARCHAR(500) DEFAULT NULL                              COMMENT '封面图',
  `video_url`      VARCHAR(500) DEFAULT NULL                              COMMENT '视频URL',
  `duration`       INT          DEFAULT 0                                 COMMENT '时长(分钟)',
  `difficulty`     TINYINT      DEFAULT 1                                 COMMENT '难度: 1入门 2进阶 3高级 4大师',
  `view_count`     INT          DEFAULT 0                                 COMMENT '观看数',
  `like_count`     INT          DEFAULT 0                                 COMMENT '点赞数',
  `download_count` INT          DEFAULT 0                                 COMMENT '下载数',
  `sort_order`     INT          DEFAULT 0                                 COMMENT '排序',
  `status`         TINYINT      DEFAULT 1                                 COMMENT '状态: 0下架 1上架',
  `create_time`    DATETIME     DEFAULT CURRENT_TIMESTAMP                 COMMENT '创建时间',
  `update_time`    DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`course_id`),
  KEY `idx_course_category` (`category_id`),
  KEY `idx_course_user`     (`user_id`),
  KEY `idx_course_difficulty` (`difficulty`),
  KEY `idx_course_status`   (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='教程课程表';


-- ------------------------------------------------------------
-- 3.13 课程下载记录表 course_download
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `course_download`;
CREATE TABLE `course_download` (
  `download_id` INT      NOT NULL                AUTO_INCREMENT  COMMENT '下载ID',
  `user_id`     INT      NOT NULL                                  COMMENT '用户ID',
  `course_id`   INT      NOT NULL                                  COMMENT '课程ID',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP                 COMMENT '下载时间',
  PRIMARY KEY (`download_id`),
  UNIQUE KEY `uk_download_user_course` (`user_id`, `course_id`),
  KEY        `idx_download_course`    (`course_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='课程下载记录表';


-- ------------------------------------------------------------
-- 3.14 用户作品表 user_work
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `user_work`;
CREATE TABLE `user_work` (
  `work_id`       INT          NOT NULL                AUTO_INCREMENT  COMMENT '作品ID',
  `user_id`       INT          NOT NULL                                  COMMENT '作者ID',
  `title`         VARCHAR(200) NOT NULL                                  COMMENT '作品标题',
  `description`   TEXT         DEFAULT NULL                              COMMENT '作品描述',
  `images`        TEXT         DEFAULT NULL                              COMMENT '作品图片 JSON',
  `like_count`    INT          DEFAULT 0                                 COMMENT '点赞数',
  `comment_count` INT          DEFAULT 0                                 COMMENT '评论数',
  `status`        TINYINT      DEFAULT 1                                 COMMENT '状态: 0删除 1正常',
  `create_time`   DATETIME     DEFAULT CURRENT_TIMESTAMP                 COMMENT '创建时间',
  PRIMARY KEY (`work_id`),
  KEY `idx_work_user`   (`user_id`),
  KEY `idx_work_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户作品表';


-- ------------------------------------------------------------
-- 3.15 商城商品表 product ★ 6/9 新增
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `product`;
CREATE TABLE `product` (
  `product_id`   INT            NOT NULL                AUTO_INCREMENT  COMMENT '商品ID',
  `product_name` VARCHAR(200)   NOT NULL                                  COMMENT '商品名称',
  `category_id`  INT            NOT NULL                                  COMMENT '商品分类: 1家具 2木料 3工具 4课程',
  `price`        DECIMAL(10,2)  NOT NULL                                  COMMENT '价格 (元)',
  `cover_image`  VARCHAR(500)   DEFAULT NULL                              COMMENT '封面图',
  `description`  TEXT           DEFAULT NULL                              COMMENT '商品详情',
  `stock`        INT            DEFAULT 0                                 COMMENT '库存',
  `status`       TINYINT        DEFAULT 1                                 COMMENT '状态: 0下架 1上架',
  `create_time`  DATETIME       DEFAULT CURRENT_TIMESTAMP                 COMMENT '创建时间',
  `update_time`  DATETIME       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`product_id`),
  KEY `idx_product_category` (`category_id`),
  KEY `idx_product_status`   (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商城商品表';


-- ------------------------------------------------------------
-- 3.16 商城订单表 product_order ★ 6/9 新增
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `product_order`;
CREATE TABLE `product_order` (
  `order_id`     INT            NOT NULL                AUTO_INCREMENT  COMMENT '订单ID',
  `product_id`   INT            NOT NULL                                  COMMENT '商品ID',
  `product_name` VARCHAR(200)   NOT NULL                                  COMMENT '商品名 (冗余防商品改名)',
  `user_id`      INT            NOT NULL                                  COMMENT '买家ID',
  `quantity`     INT            NOT NULL DEFAULT 1                        COMMENT '数量',
  `total_price`  DECIMAL(10,2)  NOT NULL                                  COMMENT '总价',
  `status`       TINYINT        DEFAULT 0                                 COMMENT '0待支付 1已支付 2已发货 3已完成 4已取消',
  `create_time`  DATETIME       DEFAULT CURRENT_TIMESTAMP                 COMMENT '下单时间',
  `update_time`  DATETIME       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`order_id`),
  KEY `idx_order_user`    (`user_id`),
  KEY `idx_order_product` (`product_id`),
  KEY `idx_order_status`  (`status`),
  KEY `idx_order_time`    (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商城订单表';


-- ------------------------------------------------------------
-- 3.17 用户反馈表 feedback ★ 6/10 新增
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `feedback`;
CREATE TABLE `feedback` (
  `feedback_id`  INT          NOT NULL                AUTO_INCREMENT  COMMENT '反馈ID',
  `user_id`      INT          DEFAULT NULL                              COMMENT '提交用户ID, 未登录可空',
  `fb_type`      TINYINT      NOT NULL DEFAULT 1                        COMMENT '反馈类型: 1功能建议 2联系客服 3举报 4bug 5商务',
  `content`      TEXT         NOT NULL                                  COMMENT '反馈正文',
  `contact`      VARCHAR(100) DEFAULT NULL                              COMMENT '联系方式 (手机/邮箱/微信)',
  `device`       VARCHAR(255) DEFAULT NULL                              COMMENT '提交设备 (User-Agent)',
  `status`       TINYINT      NOT NULL DEFAULT 0                        COMMENT '处理状态: 0未处理 1已查看 2已回复 3已关闭',
  `reply`        TEXT         DEFAULT NULL                              COMMENT '客服回复内容',
  `reply_time`   DATETIME     DEFAULT NULL                              COMMENT '回复时间',
  `create_time`  DATETIME     DEFAULT CURRENT_TIMESTAMP                 COMMENT '提交时间',
  PRIMARY KEY (`feedback_id`),
  KEY `idx_fb_user`   (`user_id`),
  KEY `idx_fb_type`   (`fb_type`),
  KEY `idx_fb_status` (`status`),
  KEY `idx_fb_create` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户反馈表 (含客服咨询)';


-- 恢复外键检查
SET FOREIGN_KEY_CHECKS = 1;


-- ================================================================
-- 第四部分: 种子数据
-- ================================================================

-- ------------------------------------------------------------
-- 4.1 5 个榫卯内容分类
-- ------------------------------------------------------------
INSERT INTO `category` (`name`, `parent_id`, `sort_order`, `icon`, `description`, `status`) VALUES
('结构', 0, 1, '../images/结构-1.png', '榫卯结构相关内容',     1),
('家具', 0, 2, '../images/家具-1.png', '传统家具相关内容',     1),
('木料', 0, 3, '../images/紫檀木.png', '木料材质相关内容',     1),
('历史', 0, 4, '../images/唐代.png',   '榫卯历史相关内容',     1),
('教程', 0, 5, '../images/入门.png',   '制作教程相关内容',     1);


-- ------------------------------------------------------------
-- 4.2 4 张首页轮播图
-- ------------------------------------------------------------
INSERT INTO `banner` (`title`, `image_url`, `link_type`, `sort_order`, `status`) VALUES
('轮播图1', '../images/轮播-1.jpg', 1, 1, 1),
('轮播图2', '../images/轮播-2.jpg', 1, 2, 1),
('轮播图3', '../images/轮播-3.jpg', 1, 3, 1),
('轮播图4', '../images/轮播-4.jpg', 1, 4, 1);


-- ------------------------------------------------------------
-- 4.3 5 行系统配置 (含客服联系信息)
-- ------------------------------------------------------------
INSERT INTO `sys_config` (`config_key`, `config_value`, `description`) VALUES
('service_phone',  '400-888-8888',      '客服电话'),
('service_email',  'support@sunmao.com', '客服邮箱'),
('service_wechat', 'sunmao_helper',     '客服微信'),
('service_weibo',  '@榫卯非遗官方',      '官方微博'),
('service_hours',  '工作日 9:00-18:00',  '服务时间');


-- ------------------------------------------------------------
-- 4.4 15 件商城商品 (4 家具 + 5 木料 + 3 工具 + 3 课程)
-- ------------------------------------------------------------
INSERT INTO `product` (`product_name`, `category_id`, `price`, `cover_image`, `description`, `stock`, `status`) VALUES
-- 家具 (category_id=1)
('明式圈椅',         1,  8800.00, '../images/家具.jpg',     '精选老榆木手工打造, 明式经典制式, 线条洗练, 坐感舒适, 每一处接合皆采用传统燕尾榫。尺寸: 68×55×98cm。',         5, 1),
('四出头官帽椅',     1, 12800.00, '../images/家具-1.png',   '取材百年酸枝木, 搭脑两端出头上翘, 扶手外撇, 靠背板S形雕花, 透榫结构稳固耐用。',                              3, 1),
('明式平头案',       1, 16800.00, '../images/家具-2.png',   '紫光檀材质, 案面一木对开, 冰盘沿线脚精致, 罗锅枨加矮佬造法, 是书房陈设雅器。尺寸: 180×60×80cm。',          2, 1),
('榫卯博古架',       1,  9800.00, '../images/家具-3.png',   '全榫卯结构无钉无胶, 多宝格设计可自由组合, 黑胡桃木搭配黄铜配件, 现代与古典的完美融合。',                    6, 1),

-- 木料 (category_id=2)
('印度小叶紫檀',     2,  2800.00, '../images/紫檀木.png',   '学名檀香紫檀, 油性足密度高, 料质细腻, 适合雕刻及高档家具。规格: 长约30-50cm, 直径约8-12cm (单根价)。',     20, 1),
('海南黄花梨老料',   2,  6800.00, '../images/黄花梨.png',   '降香黄檀老料, 纹理绚丽多变, 鬼脸纹隐现, 降香味醇厚持久, 是榫卯家具顶级用材。规格: 长约25-40cm。',           8, 1),
('老挝大红酸枝',     2,  1800.00, '../images/红木.png',     '交趾黄檀, 色泽深红至紫褐, 木质坚硬, 纹理直而美观, 适合明式家具和文玩小件制作。通货规格。',                 15, 1),
('缅甸金丝楠',       2,  3600.00, '../images/楠木.png',     '桢楠属优质料, 色泽金黄悦目, 纹理含金丝, 精油香气淡雅防虫, 千年不腐之木。老料规格。',                       10, 1),
('非洲鸡翅木',       2,   980.00, '../images/鸡翅木.png',   '纹理呈V字型, 酷似鸡翅羽毛, 密度适中, 适合榫卯初学者练习加工。通货规格, 性价比极高。',                     30, 1),

-- 工具 (category_id=3)
('榫卯大师五件套',   3,  1280.00, '../images/tool-set.png', '含平凿、圆凿、斜凿、直角规、划线器, 铬钒合金锻造, 黄檀把手, 附赠蠊皮磨刀石一块。入门必备。',              50, 1),
('日式平刨',         3,   680.00, '../images/tool-plane.png','高碳钢刨刃, 白橡木刨台, 刃宽42mm, 适合榫卯精准合缝调修。日本工艺标准。',                                   25, 1),
('机械鸠尾榫导板',   3,   398.00, '../images/tool-jig.png', '铝合金CNC精密加工, 可调节式导轨, 配合修边机使用, 批量制作燕尾榫的效率利器。',                            40, 1),

-- 课程 (category_id=4)
('榫卯入门: 30天从零到熟练', 4, 299.00, '../images/入门.png',  '视频课程共24节, 总时长8小时。从工具认知、画线、开榫到组装, 手把手教学。附赠图纸电子版。',           999, 1),
('明式家具复制实战',           4, 699.00, '../images/进阶.png',  '高级课程共18节, 以王世襄旧藏明式圈椅为蓝本, 全程复刻教学含料单及1:1图纸。',                      999, 1),
('古建筑榫卯结构解析',         4, 499.00, '../images/高级.png',  '深度课程共12节, 系统讲解唐宋明清不同时期斗栱、柱头、梁架榫卯系统的演变与受力分析。',             999, 1);


-- ================================================================
-- 第五部分: 启用/校验
-- ================================================================

-- 5.1 重新启用外键检查 (二次保险)
SET FOREIGN_KEY_CHECKS = 1;

-- 5.2 输出初始化结果
SELECT '=== 数据库初始化完成 ===' AS message;

SELECT
  (SELECT COUNT(*) FROM `category`)      AS categories,
  (SELECT COUNT(*) FROM `banner`)        AS banners,
  (SELECT COUNT(*) FROM `product`)       AS products,
  (SELECT COUNT(*) FROM `sys_config`)   AS sys_configs,
  (SELECT COUNT(*) FROM `article`)      AS articles,
  (SELECT COUNT(*) FROM `user`)          AS users;

SELECT '=== 表清单 ===' AS message;
SHOW TABLES;


-- ================================================================
-- 部署完成后手动操作:
-- ================================================================
-- 1. 小程序注册新用户 (通过 /pages/register/register)
-- 2. 查到该用户的 user_id, 设置为管理员:
--      UPDATE user SET user_type = 2 WHERE user_id = <你的ID>;
-- 3. (可选) 配置 DeepSeek API Key:
--      编辑 ljx_backend/src/main/resources/application.yml
--      将 deepseek.api.key 改为真实 Key
-- ================================================================
