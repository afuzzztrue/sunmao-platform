-- ================================================================
-- 榫卯非遗文化传承平台 - 完整数据库初始化脚本 v2.1
-- --------------------------------------------------------------
-- 版本:       v2.1 (2026-06-26 整合版, 含 6 个问题修复)
-- 适用数据库:  MySQL 8.0+ (已用 8.0.46 测试)
-- 端口:        3307
-- 字符集:      utf8mb4 / utf8mb4_unicode_ci
-- 存储引擎:    InnoDB
-- --------------------------------------------------------------
-- 整合来源 (全部已并入此文件, 旧文件归档到 sql/archive/):
--   1. init_database.sql                                  (14 张原表)
--   2. seed_products.sql                                  (15 条商品)
--   3. migrations/2026-06-10-my-tabs-backend-integration  (feedback + 偏好 + 快照)
--   4. schema_mysql8_full.sql v1.0                       (商城 2 张表)
--   5. seed_articles_admin1.sql                          (admin1 + 12 article + 12 work)
--   6. migrations/2026-06-26-fix-4-issues                (collect/footprint 加 target_type + target_id)
-- --------------------------------------------------------------
-- 表总数: 17 张
--   user, sys_config, category, banner, article, post,
--   like_record, comment, collect_record, follow, footprint,
--   course, course_download, user_work, product, product_order, feedback
-- --------------------------------------------------------------
-- v2.1 变更 (2026-06-26):
--   * collect_record 加 target_type + target_id 列, article_id 改为可空 (兼容老数据)
--   * footprint     加 target_type + target_id 列, article_id 改为可空
--   * collect_record 去掉 uk_collect_user_article 唯一约束 (改为普通索引, 支持多态收藏)
-- --------------------------------------------------------------
-- 种子数据:
--   1 个 admin1 管理员用户
--   5 个内容分类
--   4 张首页轮播图
--   5 条系统配置
--   12 篇文章 (admin1 发布)
--   12 条用户作品 (admin1 发布)
--   15 件商城商品
-- --------------------------------------------------------------
-- 执行方式:
--   1. 命令行: mysql -uroot -p12345 -P3307 < ljx_platform_v2_init.sql
--   2. DBeaver: 先在 ljx_platform 库 → 打开文件 → Ctrl+A → Ctrl+Enter
-- --------------------------------------------------------------
-- 脚本可重复执行 (开头先 DROP 所有表, 末尾再次启用外键检查)
-- ================================================================


-- ================================================================
-- 第一部分: 准备工作
-- ================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;


-- ================================================================
-- 第二部分: 清理旧表 (按依赖关系倒序, 子表先删)
-- ================================================================

DROP TABLE IF EXISTS `feedback`;        -- 用户反馈
DROP TABLE IF EXISTS `product_order`;   -- 商城订单
DROP TABLE IF EXISTS `product`;         -- 商城商品
DROP TABLE IF EXISTS `course_download`; -- 课程下载
DROP TABLE IF EXISTS `course`;          -- 教程课程
DROP TABLE IF EXISTS `user_work`;       -- 用户作品
DROP TABLE IF EXISTS `footprint`;       -- 浏览足迹
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
-- 第三部分: 建表 (17 张, 按依赖关系正序, 父表先建)
-- ================================================================

-- ------------------------------------------------------------
-- 3.1 用户表 user
-- ------------------------------------------------------------
CREATE TABLE `user` (
  `user_id`      INT          NOT NULL AUTO_INCREMENT COMMENT '用户ID, 主键',
  `openid`       VARCHAR(64)  DEFAULT NULL COMMENT '微信openid',
  `unionid`      VARCHAR(64)  DEFAULT NULL COMMENT '微信unionid',
  `nickname`     VARCHAR(100) DEFAULT NULL COMMENT '昵称',
  `avatar`       VARCHAR(500) DEFAULT NULL COMMENT '头像URL',
  `phone`        VARCHAR(20)  DEFAULT NULL COMMENT '手机号(注册账号)',
  `email`        VARCHAR(100) DEFAULT NULL COMMENT '邮箱(注册账号)',
  `password`     VARCHAR(255) DEFAULT NULL COMMENT '密码 MD5',
  `gender`       TINYINT      DEFAULT 0    COMMENT '性别: 0未知 1男 2女',
  `province`     VARCHAR(50)  DEFAULT NULL COMMENT '省份',
  `city`         VARCHAR(50)  DEFAULT NULL COMMENT '城市',
  `study_hours`  INT          DEFAULT 0    COMMENT '学习时长(小时)',
  `user_type`    TINYINT      DEFAULT 0    COMMENT '类型: 0普通 1传承人 2管理员',
  `status`       TINYINT      DEFAULT 1    COMMENT '状态: 0禁用 1正常',
  `preferences`  JSON         DEFAULT NULL COMMENT '用户偏好 {notify, darkMode, fontSize, language}',
  `create_time`  DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
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
CREATE TABLE `sys_config` (
  `config_id`    INT          NOT NULL AUTO_INCREMENT COMMENT '配置ID',
  `config_key`   VARCHAR(100) NOT NULL COMMENT '配置键 (唯一)',
  `config_value` TEXT         DEFAULT NULL COMMENT '配置值',
  `description`  VARCHAR(255) DEFAULT NULL COMMENT '配置说明',
  `create_time`  DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`  DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`config_id`),
  UNIQUE KEY `uk_config_key` (`config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统配置表 (键值对)';


-- ------------------------------------------------------------
-- 3.3 内容分类表 category (树形)
-- ------------------------------------------------------------
CREATE TABLE `category` (
  `category_id`  INT          NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `name`         VARCHAR(50)  NOT NULL COMMENT '分类名称',
  `parent_id`    INT          DEFAULT 0    COMMENT '父分类ID, 0=根',
  `sort_order`   INT          DEFAULT 0    COMMENT '排序号 (升序)',
  `icon`         VARCHAR(500) DEFAULT NULL COMMENT '分类图标URL',
  `description`  VARCHAR(255) DEFAULT NULL COMMENT '分类描述',
  `status`       TINYINT      DEFAULT 1    COMMENT '状态: 0禁用 1启用',
  `create_time`  DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`category_id`),
  KEY `idx_category_parent` (`parent_id`),
  KEY `idx_category_sort`   (`sort_order`),
  KEY `idx_category_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='内容分类表';


-- ------------------------------------------------------------
-- 3.4 轮播图表 banner
-- ------------------------------------------------------------
CREATE TABLE `banner` (
  `banner_id`    INT          NOT NULL AUTO_INCREMENT COMMENT '轮播图ID',
  `title`        VARCHAR(100) DEFAULT NULL COMMENT '标题',
  `image_url`    VARCHAR(500) NOT NULL COMMENT '图片URL',
  `link_url`     VARCHAR(500) DEFAULT NULL COMMENT '跳转URL',
  `link_type`    TINYINT      DEFAULT 1    COMMENT '跳转类型: 1文章 2外部链接',
  `link_id`      INT          DEFAULT NULL COMMENT '关联ID (文章ID等)',
  `sort_order`   INT          DEFAULT 0    COMMENT '排序号',
  `status`       TINYINT      DEFAULT 1    COMMENT '状态: 0禁用 1启用',
  `create_time`  DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`banner_id`),
  KEY `idx_banner_sort`   (`sort_order`),
  KEY `idx_banner_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='首页轮播图表';


-- ------------------------------------------------------------
-- 3.5 内容文章表 article
-- ------------------------------------------------------------
CREATE TABLE `article` (
  `article_id`    INT          NOT NULL AUTO_INCREMENT COMMENT '文章ID',
  `category_id`   INT          NOT NULL COMMENT '分类ID',
  `user_id`       INT          NOT NULL COMMENT '发布者ID',
  `title`         VARCHAR(200) NOT NULL COMMENT '标题',
  `summary`       VARCHAR(500) DEFAULT NULL COMMENT '摘要',
  `content`       LONGTEXT     DEFAULT NULL COMMENT '正文 (HTML/富文本)',
  `cover_image`   VARCHAR(500) DEFAULT NULL COMMENT '封面图URL',
  `images`        TEXT         DEFAULT NULL COMMENT '图片列表 JSON',
  `tags`          VARCHAR(255) DEFAULT NULL COMMENT '标签 逗号分隔',
  `location`      VARCHAR(100) DEFAULT NULL COMMENT '地理位置',
  `view_count`    INT          DEFAULT 0    COMMENT '浏览数',
  `like_count`    INT          DEFAULT 0    COMMENT '点赞数',
  `comment_count` INT          DEFAULT 0    COMMENT '评论数',
  `collect_count` INT          DEFAULT 0    COMMENT '收藏数',
  `is_hot`        TINYINT      DEFAULT 0    COMMENT '是否热门: 0否 1是',
  `is_banner`     TINYINT      DEFAULT 0    COMMENT '是否轮播: 0否 1是',
  `sort_order`    INT          DEFAULT 0    COMMENT '排序',
  `status`        TINYINT      DEFAULT 1    COMMENT '状态: 0草稿 1发布 2下架',
  `create_time`   DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
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
CREATE TABLE `post` (
  `post_id`       INT          NOT NULL AUTO_INCREMENT COMMENT '帖子ID',
  `user_id`       INT          NOT NULL COMMENT '发布者ID',
  `content`       TEXT         NOT NULL COMMENT '帖子内容',
  `images`        TEXT         DEFAULT NULL COMMENT '图片列表 JSON',
  `location`      VARCHAR(100) DEFAULT NULL COMMENT '发布位置',
  `like_count`    INT          DEFAULT 0    COMMENT '点赞数',
  `comment_count` INT          DEFAULT 0    COMMENT '评论数',
  `share_count`   INT          DEFAULT 0    COMMENT '分享数',
  `post_type`     TINYINT      DEFAULT 0    COMMENT '帖子类型: 0普通 1热门',
  `status`        TINYINT      DEFAULT 1    COMMENT '状态: 0删除 1正常',
  `create_time`   DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  PRIMARY KEY (`post_id`),
  KEY `idx_post_user`        (`user_id`),
  KEY `idx_post_type`        (`post_type`),
  KEY `idx_post_status`      (`status`),
  KEY `idx_post_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='动态帖子表';


-- ------------------------------------------------------------
-- 3.7 点赞记录表 like_record (target_type 多态)
-- ------------------------------------------------------------
CREATE TABLE `like_record` (
  `like_id`      INT      NOT NULL AUTO_INCREMENT COMMENT '点赞ID',
  `user_id`      INT      NOT NULL COMMENT '点赞用户ID',
  `target_type`  TINYINT  NOT NULL COMMENT '目标类型: 1文章 2帖子 3课程 4作品 5结构',
  `target_id`    INT      NOT NULL COMMENT '目标ID',
  `create_time`  DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',
  PRIMARY KEY (`like_id`),
  UNIQUE KEY `uk_like_user_target` (`user_id`, `target_type`, `target_id`),
  KEY        `idx_like_target`     (`target_type`, `target_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='点赞记录表';


-- ------------------------------------------------------------
-- 3.8 评论表 comment (target_type 多态 + parent 自关联)
-- ------------------------------------------------------------
CREATE TABLE `comment` (
  `comment_id`  INT      NOT NULL AUTO_INCREMENT COMMENT '评论ID',
  `user_id`     INT      NOT NULL COMMENT '评论者ID',
  `target_type` TINYINT  NOT NULL COMMENT '目标类型: 1文章 2帖子',
  `target_id`   INT      NOT NULL COMMENT '目标ID',
  `parent_id`   INT      DEFAULT 0    COMMENT '父评论ID, 0=一级评论',
  `content`     TEXT     NOT NULL COMMENT '评论内容',
  `like_count`  INT      DEFAULT 0    COMMENT '点赞数',
  `status`      TINYINT  DEFAULT 1    COMMENT '状态: 0删除 1正常',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  PRIMARY KEY (`comment_id`),
  KEY `idx_comment_target` (`target_type`, `target_id`),
  KEY `idx_comment_user`   (`user_id`),
  KEY `idx_comment_parent` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='评论表';


-- ------------------------------------------------------------
-- 3.9 收藏记录表 collect_record (target_type 多态)
-- ------------------------------------------------------------
CREATE TABLE `collect_record` (
  `collect_id`  INT      NOT NULL AUTO_INCREMENT COMMENT '收藏ID',
  `user_id`     INT      NOT NULL COMMENT '用户ID',
  `article_id`  INT      DEFAULT NULL COMMENT '老字段: 文章ID (兼容老数据)',
  `target_type` TINYINT  DEFAULT NULL COMMENT '目标类型: 1文章 2帖子 3课程 4作品 5结构',
  `target_id`   INT      DEFAULT NULL COMMENT '目标ID (按 target_type 解释)',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
  PRIMARY KEY (`collect_id`),
  KEY        `idx_collect_user`         (`user_id`),
  KEY        `idx_collect_article`      (`article_id`),
  KEY        `idx_collect_user_target`  (`user_id`, `target_type`, `target_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='收藏记录表 (多态: target_type + target_id)';


-- ------------------------------------------------------------
-- 3.10 关注关系表 follow
-- ------------------------------------------------------------
CREATE TABLE `follow` (
  `follow_id`       INT      NOT NULL AUTO_INCREMENT COMMENT '关注ID',
  `user_id`         INT      NOT NULL COMMENT '关注者ID',
  `follow_user_id`  INT      NOT NULL COMMENT '被关注者ID',
  `create_time`     DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '关注时间',
  PRIMARY KEY (`follow_id`),
  UNIQUE KEY `uk_follow_user`         (`user_id`, `follow_user_id`),
  KEY        `idx_followed_user_id`   (`follow_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='关注关系表';


-- ------------------------------------------------------------
-- 3.11 浏览足迹表 footprint (target_type 多态 + 快照字段)
-- ------------------------------------------------------------
CREATE TABLE `footprint` (
  `footprint_id`     INT          NOT NULL AUTO_INCREMENT COMMENT '足迹ID',
  `user_id`          INT          NOT NULL COMMENT '用户ID',
  `article_id`       INT          DEFAULT NULL COMMENT '老字段: 文章ID (兼容老数据)',
  `target_type`      TINYINT      DEFAULT NULL COMMENT '目标类型: 1文章 2帖子 3课程 4作品 5结构',
  `target_id`        INT          DEFAULT NULL COMMENT '目标ID (按 target_type 解释)',
  `snapshot_title`   VARCHAR(200) DEFAULT NULL COMMENT '标题快照 (防删除后空)',
  `snapshot_cover`   VARCHAR(500) DEFAULT NULL COMMENT '封面快照',
  `snapshot_author`  VARCHAR(100) DEFAULT NULL COMMENT '作者快照',
  `create_time`      DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '浏览时间',
  PRIMARY KEY (`footprint_id`),
  KEY `idx_footprint_user`        (`user_id`),
  KEY `idx_footprint_time`        (`create_time`),
  KEY `idx_footprint_user_target` (`user_id`, `target_type`, `target_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='浏览足迹表 (多态: target_type + target_id)';


-- ------------------------------------------------------------
-- 3.12 教程课程表 course
-- ------------------------------------------------------------
CREATE TABLE `course` (
  `course_id`      INT          NOT NULL AUTO_INCREMENT COMMENT '课程ID',
  `category_id`    INT          NOT NULL COMMENT '分类ID',
  `user_id`        INT          NOT NULL COMMENT '讲师ID',
  `title`          VARCHAR(200) NOT NULL COMMENT '课程标题',
  `description`    TEXT         DEFAULT NULL COMMENT '课程描述',
  `cover_image`    VARCHAR(500) DEFAULT NULL COMMENT '封面图',
  `video_url`      VARCHAR(500) DEFAULT NULL COMMENT '视频URL',
  `duration`       INT          DEFAULT 0    COMMENT '时长(分钟)',
  `difficulty`     TINYINT      DEFAULT 1    COMMENT '难度: 1入门 2进阶 3高级 4大师',
  `view_count`     INT          DEFAULT 0    COMMENT '观看数',
  `like_count`     INT          DEFAULT 0    COMMENT '点赞数',
  `download_count` INT          DEFAULT 0    COMMENT '下载数',
  `sort_order`     INT          DEFAULT 0    COMMENT '排序',
  `status`         TINYINT      DEFAULT 1    COMMENT '状态: 0下架 1上架',
  `create_time`    DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`    DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`course_id`),
  KEY `idx_course_category`   (`category_id`),
  KEY `idx_course_user`       (`user_id`),
  KEY `idx_course_difficulty` (`difficulty`),
  KEY `idx_course_status`     (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='教程课程表';


-- ------------------------------------------------------------
-- 3.13 课程下载记录表 course_download
-- ------------------------------------------------------------
CREATE TABLE `course_download` (
  `download_id` INT      NOT NULL AUTO_INCREMENT COMMENT '下载ID',
  `user_id`     INT      NOT NULL COMMENT '用户ID',
  `course_id`   INT      NOT NULL COMMENT '课程ID',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '下载时间',
  PRIMARY KEY (`download_id`),
  UNIQUE KEY `uk_download_user_course` (`user_id`, `course_id`),
  KEY        `idx_download_course`    (`course_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='课程下载记录表';


-- ------------------------------------------------------------
-- 3.14 用户作品表 user_work
-- ------------------------------------------------------------
CREATE TABLE `user_work` (
  `work_id`       INT          NOT NULL AUTO_INCREMENT COMMENT '作品ID',
  `user_id`       INT          NOT NULL COMMENT '作者ID',
  `title`         VARCHAR(200) NOT NULL COMMENT '作品标题',
  `description`   TEXT         DEFAULT NULL COMMENT '作品描述',
  `images`        TEXT         DEFAULT NULL COMMENT '作品图片 JSON',
  `like_count`    INT          DEFAULT 0    COMMENT '点赞数',
  `comment_count` INT          DEFAULT 0    COMMENT '评论数',
  `status`        TINYINT      DEFAULT 1    COMMENT '状态: 0删除 1正常',
  `create_time`   DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`work_id`),
  KEY `idx_work_user`   (`user_id`),
  KEY `idx_work_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户作品表';


-- ------------------------------------------------------------
-- 3.15 商城商品表 product
-- ------------------------------------------------------------
CREATE TABLE `product` (
  `product_id`   INT            NOT NULL AUTO_INCREMENT COMMENT '商品ID',
  `product_name` VARCHAR(200)   NOT NULL COMMENT '商品名称',
  `category_id`  INT            NOT NULL COMMENT '商品分类: 1家具 2木料 3工具 4课程',
  `price`        DECIMAL(10,2)  NOT NULL COMMENT '价格 (元)',
  `cover_image`  VARCHAR(500)   DEFAULT NULL COMMENT '封面图',
  `description`  TEXT           DEFAULT NULL COMMENT '商品详情',
  `stock`        INT            DEFAULT 0    COMMENT '库存',
  `status`       TINYINT        DEFAULT 1    COMMENT '状态: 0下架 1上架',
  `create_time`  DATETIME       DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`  DATETIME       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`product_id`),
  KEY `idx_product_category` (`category_id`),
  KEY `idx_product_status`   (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商城商品表';


-- ------------------------------------------------------------
-- 3.16 商城订单表 product_order
-- ------------------------------------------------------------
CREATE TABLE `product_order` (
  `order_id`     INT            NOT NULL AUTO_INCREMENT COMMENT '订单ID',
  `product_id`   INT            NOT NULL COMMENT '商品ID',
  `product_name` VARCHAR(200)   NOT NULL COMMENT '商品名 (冗余防商品改名)',
  `user_id`      INT            NOT NULL COMMENT '买家ID',
  `quantity`     INT            NOT NULL DEFAULT 1    COMMENT '数量',
  `total_price`  DECIMAL(10,2)  NOT NULL COMMENT '总价',
  `status`       TINYINT        DEFAULT 0    COMMENT '0待支付 1已支付 2已发货 3已完成 4已取消',
  `create_time`  DATETIME       DEFAULT CURRENT_TIMESTAMP COMMENT '下单时间',
  `update_time`  DATETIME       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`order_id`),
  KEY `idx_order_user`    (`user_id`),
  KEY `idx_order_product` (`product_id`),
  KEY `idx_order_status`  (`status`),
  KEY `idx_order_time`    (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商城订单表';


-- ------------------------------------------------------------
-- 3.17 用户反馈表 feedback
-- ------------------------------------------------------------
CREATE TABLE `feedback` (
  `feedback_id`  INT          NOT NULL AUTO_INCREMENT COMMENT '反馈ID',
  `user_id`      INT          DEFAULT NULL COMMENT '提交用户ID, 未登录可空',
  `fb_type`      TINYINT      NOT NULL DEFAULT 1    COMMENT '反馈类型: 1功能建议 2联系客服 3举报 4bug 5商务',
  `content`      TEXT         NOT NULL COMMENT '反馈正文',
  `contact`      VARCHAR(100) DEFAULT NULL COMMENT '联系方式 (手机/邮箱/微信)',
  `device`       VARCHAR(255) DEFAULT NULL COMMENT '提交设备 (User-Agent)',
  `status`       TINYINT      NOT NULL DEFAULT 0    COMMENT '处理状态: 0未处理 1已查看 2已回复 3已关闭',
  `reply`        TEXT         DEFAULT NULL COMMENT '客服回复内容',
  `reply_time`   DATETIME     DEFAULT NULL COMMENT '回复时间',
  `create_time`  DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
  PRIMARY KEY (`feedback_id`),
  KEY `idx_fb_user`   (`user_id`),
  KEY `idx_fb_type`   (`fb_type`),
  KEY `idx_fb_status` (`status`),
  KEY `idx_fb_create` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户反馈表 (含客服咨询)';


-- 启用外键检查
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
('工具', 0, 4, '../images/tool-set.png', '工具相关内容',       1),
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
-- 4.4 1 个 admin1 管理员用户
-- ------------------------------------------------------------
INSERT INTO `user`
  (`openid`, `nickname`, `avatar`, `phone`, `email`, `password`,
   `gender`, `province`, `city`, `study_hours`, `user_type`, `status`,
   `preferences`, `create_time`)
VALUES
  (NULL, 'admin1', '../images/我的作品.png', '13800000001',
   'admin1@sunmao.com', MD5('admin123'),
   1, '浙江', '杭州', 168, 2, 1,
   JSON_OBJECT('notify', true, 'darkMode', false, 'fontSize', '标准', 'language', 'zh-CN'),
   NOW());

-- 4.4.1 取出 admin1 的 user_id (供后续 article / user_work 引用)
SELECT `user_id` INTO @admin1_id FROM `user` WHERE `nickname` = 'admin1' LIMIT 1;


-- ------------------------------------------------------------
-- 4.5 12 篇文章 (admin1 发布, 覆盖 5 个分类)
-- ------------------------------------------------------------

-- 4.5.1 结构类 (category_id=1) - 3 条
INSERT INTO `article`
  (`category_id`, `user_id`, `title`, `summary`, `content`, `cover_image`,
   `images`, `tags`, `location`, `view_count`, `like_count`, `comment_count`,
   `collect_count`, `is_hot`, `is_banner`, `sort_order`, `status`, `create_time`)
VALUES
  (1, @admin1_id, '燕尾榫：千年不倒的榫卯之王',
   '燕尾榫是榫卯结构中最具代表性的形式, 以其头榫大、尾榫小, 形似燕尾而得名。',
   '<h2>燕尾榫的历史</h2><p>燕尾榫最早见于距今约 7000 年前的河姆渡遗址...</p><h2>制作工艺</h2><p>燕尾榫的关键在于斜度比例, 一般 1:6 至 1:8 之间...</p>',
   '../images/结构-1.png',
   JSON_ARRAY('../images/结构-1.png', '../images/结构-2.png'),
   '燕尾榫,榫卯之王,经典结构',
   '浙江·宁波', 2580, 326, 48, 92, 1, 0, 100, 1, NOW()),

  (1, @admin1_id, '银锭榫：明式家具的灵魂榫卯',
   '银锭榫又称银锭扣, 是明式家具中用于连接两根直角相交木构件的金属扣件替代品。',
   '<h2>结构特点</h2><p>银锭榫呈"银锭"形状, 中间收腰, 两端大头, 巧妙利用了力学上的抗拉原理...</p><h2>应用场景</h2><p>常见于案形结体、桌形结体的枨子与腿足接合处...</p>',
   '../images/结构-2.png',
   JSON_ARRAY('../images/结构-2.png'),
   '银锭榫,明式家具,接合',
   '江苏·苏州', 1820, 245, 32, 68, 1, 0, 95, 1, NOW()),

  (1, @admin1_id, '抱肩榫：案形结体的支撑核心',
   '抱肩榫是案类家具中腿足与案面相交处的关键榫卯, 兼具结构与装饰双重作用。',
   '<h2>结构原理</h2><p>抱肩榫由挂榫与销榫组合而成, 将案面的承重有效传递至四足...</p>',
   '../images/结构-3.png',
   JSON_ARRAY('../images/结构-3.png', '../images/结构-4.png'),
   '抱肩榫,案,承重结构',
   '北京', 1340, 198, 24, 51, 0, 0, 90, 1, NOW());


-- 4.5.2 家具类 (category_id=2) - 3 条
INSERT INTO `article`
  (`category_id`, `user_id`, `title`, `summary`, `content`, `cover_image`,
   `images`, `tags`, `location`, `view_count`, `like_count`, `comment_count`,
   `collect_count`, `is_hot`, `is_banner`, `sort_order`, `status`, `create_time`)
VALUES
  (2, @admin1_id, '明式圈椅：极简主义的东方巅峰',
   '明式圈椅以"圆"为核心, 由搭脑延伸至扶手形成流畅的曲线, 是中国家具艺术的代表作。',
   '<h2>造型之美</h2><p>明式圈椅整体由"圆"贯穿, 椅圈、联帮棍、鹅脖均采用圆材, 刚柔并济...</p><h2>比例精要</h2><p>椅圈与座面的黄金比例约为 3:2, 扶手高度与人手臂自然下垂位齐平...</p>',
   '../images/家具-1.png',
   JSON_ARRAY('../images/家具-1.png', '../images/家具.jpg'),
   '圈椅,明式,极简,东方美学',
   '江苏·苏州', 4250, 586, 87, 156, 1, 0, 100, 1, NOW()),

  (2, @admin1_id, '四出头官帽椅：文人情思的物化',
   '四出头官帽椅因搭脑两端、扶手两端均出头而得名, 整体造型端庄稳重, 极具书卷气。',
   '<h2>命名由来</h2><p>椅形似宋代官帽, 故名"官帽椅", 突出部位象征"出仕"之意...</p><h2>雕饰之美</h2><p>靠背板常浮雕"福、禄、寿"或花卉纹, 透雕与浮雕相间...</p>',
   '../images/家具-2.png',
   JSON_ARRAY('../images/家具-2.png', '../images/家具-3.png'),
   '官帽椅,文人家具,雕饰',
   '浙江·东阳', 3120, 412, 56, 113, 1, 0, 95, 1, NOW()),

  (2, @admin1_id, '明式平头案：书房必备雅器',
   '平头案是案形结体中最为简洁的一种, 案面平直, 无翘头, 适合放置于书房正中。',
   '<h2>形制特征</h2><p>案面平直, 牙板与腿足以夹头榫接合, 牙板上常挖"壶门"形亮脚...</p><h2>使用场景</h2><p>平头案常置于书房中, 上可置文房四宝、卷轴书籍, 兼具陈设与实用功能...</p>',
   '../images/家具-3.png',
   JSON_ARRAY('../images/家具-3.png', '../images/家具-4.png'),
   '平头案,书房,明式家具',
   '上海', 2890, 367, 49, 102, 1, 0, 90, 1, NOW());


-- 4.5.3 木料类 (category_id=3) - 2 条
INSERT INTO `article`
  (`category_id`, `user_id`, `title`, `summary`, `content`, `cover_image`,
   `images`, `tags`, `location`, `view_count`, `like_count`, `comment_count`,
   `collect_count`, `is_hot`, `is_banner`, `sort_order`, `status`, `create_time`)
VALUES
  (3, @admin1_id, '紫檀：木中黄金的鉴别与保养',
   '小叶紫檀学名檀香紫檀, 产自印度迈索尔, 密度高达 1.05-1.26g/cm³, 是红木之首。',
   '<h2>鉴别要点</h2><p>真紫檀入水即沉, 划纸留红痕, 浸酒精有橙黄色荧光...</p><h2>保养禁忌</h2><p>忌水、忌汗、忌暴晒、忌空调直吹, 宜用手盘养形成包浆...</p>',
   '../images/紫檀木.png',
   JSON_ARRAY('../images/紫檀木.png'),
   '紫檀,红木,鉴别,保养',
   '广东·江门', 5680, 723, 124, 218, 1, 0, 100, 1, NOW()),

  (3, @admin1_id, '黄花梨：行云流水的木中贵族',
   '海南黄花梨学名降香黄檀, 纹理绚丽多变, 鬼脸、鬼眼天成, 是明清宫廷御用木材。',
   '<h2>纹理美学</h2><p>黄花梨纹理以"鬼脸"为最, 此外还有"狐狸脸""婴儿面""老人的胡须"等雅称...</p><h2>市价走向</h2><p>近 30 年价格涨幅超 300 倍, 顶级老料每斤已破万元...</p>',
   '../images/黄花梨.png',
   JSON_ARRAY('../images/黄花梨.png', '../images/红木.png'),
   '黄花梨,降香黄檀,鬼脸纹',
   '海南·海口', 4350, 562, 96, 178, 1, 0, 95, 1, NOW());


-- 4.5.4 历史类 (category_id=4) - 2 条
INSERT INTO `article`
  (`category_id`, `user_id`, `title`, `summary`, `content`, `cover_image`,
   `images`, `tags`, `location`, `view_count`, `like_count`, `comment_count`,
   `collect_count`, `is_hot`, `is_banner`, `sort_order`, `status`, `create_time`)
VALUES
  (4, @admin1_id, '唐宋斗栱：东方建筑的力学之美',
   '斗栱是中国木构建筑特有的构件, 位于柱顶、额枋之上, 兼具结构与装饰双重功能。',
   '<h2>唐代斗栱</h2><p>唐代斗栱硕大, 出檐深远, 柱头铺作与补间铺作区分明显...</p><h2>宋代演变</h2><p>《营造法式》系统总结了宋代斗栱形制, 规定"材份"作为基本模数...</p>',
   '../images/唐代.png',
   JSON_ARRAY('../images/唐代.png', '../images/宋代.png'),
   '斗栱,唐代,宋代,营造法式',
   '山西·五台山', 1980, 234, 38, 76, 0, 0, 90, 1, NOW()),

  (4, @admin1_id, '明清家具：中国工艺的黄金时代',
   '明嘉靖至清乾隆年间是中国硬木家具的鼎盛期, 形成了"明式"与"清式"两大风格。',
   '<h2>明式家具</h2><p>以"简、厚、精、雅"为特点, 重材质本真之美, 少雕饰...</p><h2>清式家具</h2><p>由乾隆时期转向繁缛雕饰, 追求富贵华丽, 出现"通雕"满工...</p>',
   '../images/明清.png',
   JSON_ARRAY('../images/明清.png', '../images/家具.jpg'),
   '明清家具,明式,清式',
   '北京·故宫', 2340, 298, 45, 88, 0, 0, 85, 1, NOW());


-- 4.5.5 教程类 (category_id=5) - 2 条
INSERT INTO `article`
  (`category_id`, `user_id`, `title`, `summary`, `content`, `cover_image`,
   `images`, `tags`, `location`, `view_count`, `like_count`, `comment_count`,
   `collect_count`, `is_hot`, `is_banner`, `sort_order`, `status`, `create_time`)
VALUES
  (5, @admin1_id, '榫卯入门：30天从零到熟练',
   '本教程为零基础爱好者设计, 共 24 节视频, 总时长 8 小时, 涵盖工具、画线、开榫、组装全流程。',
   '<h2>第 1 周: 工具认知</h2><p>认识锯、刨、凿、尺、规等基础工具...</p><h2>第 2 周: 画线技术</h2><p>掌握"墨斗弹线""角尺校验"等关键画线技能...</p><h2>第 3 周: 基础榫卯</h2><p>制作燕尾榫、银锭榫等入门级榫卯结构...</p><h2>第 4 周: 实战组装</h2><p>完成小方凳的独立制作, 掌握完整工艺流程...</p>',
   '../images/入门.png',
   JSON_ARRAY('../images/入门.png', '../images/tool-set.png'),
   '入门,教程,30天,零基础',
   '全国', 6750, 892, 156, 312, 1, 0, 100, 1, NOW()),

  (5, @admin1_id, '明式家具复制实战：圈椅复刻全记录',
   '以王世襄旧藏明式圈椅为蓝本, 全程记录选料、放样、开榫、雕饰、组装的 18 节实战课程。',
   '<h2>选料要点</h2><p>圈椅用料以老榆木、缅甸柚木为主, 纹理通直, 油性适中...</p><h2>关键工艺</h2><p>圈椅弯弧需用火烤+水冷定型, 误差控制在 2mm 以内...</p><h2>复刻难点</h2><p>联帮棍的 S 形曲线是整件作品的灵魂, 需多次刮修...</p>',
   '../images/进阶.png',
   JSON_ARRAY('../images/进阶.png'),
   '进阶教程,明式圈椅,复刻,实战',
   '江苏·苏州', 4520, 567, 98, 198, 1, 0, 95, 1, NOW());


-- ------------------------------------------------------------
-- 4.6 12 条用户作品 (admin1 的"我的作品"页面数据源)
-- ------------------------------------------------------------

-- 4.6.1 结构类 - 3 条作品
INSERT INTO `user_work`
  (`user_id`, `title`, `description`, `images`, `like_count`, `comment_count`, `status`, `create_time`)
VALUES
  (@admin1_id, '燕尾榫练习件 - 抽屉',
   '新手练习燕尾榫的开榫作品, 选材缅甸柚木, 共 8 对燕尾榫。',
   JSON_ARRAY('../images/结构-1.png', '../images/结构-2.png'),
   68, 12, 1, DATE_SUB(NOW(), INTERVAL 25 DAY)),

  (@admin1_id, '银锭榫接合的小方凳',
   '采用银锭榫接合, 不用一钉一胶, 完全传统工艺。',
   JSON_ARRAY('../images/结构-2.png'),
   45, 8, 1, DATE_SUB(NOW(), INTERVAL 20 DAY)),

  (@admin1_id, '抱肩榫案面研究',
   '复刻明式平头案的抱肩榫结构, 详细记录了斜度与公差数据。',
   JSON_ARRAY('../images/结构-3.png', '../images/结构-4.png'),
   32, 5, 1, DATE_SUB(NOW(), INTERVAL 15 DAY));


-- 4.6.2 家具类 - 3 条作品
INSERT INTO `user_work`
  (`user_id`, `title`, `description`, `images`, `like_count`, `comment_count`, `status`, `create_time`)
VALUES
  (@admin1_id, '明式圈椅 - 老榆木全榫卯',
   '历时 45 天独立完成的明式圈椅, 选用 30 年老榆木, 全榫卯无钉。',
   JSON_ARRAY('../images/家具-1.png', '../images/家具.jpg'),
   312, 56, 1, DATE_SUB(NOW(), INTERVAL 60 DAY)),

  (@admin1_id, '四出头官帽椅 - 酸枝木',
   '复刻王世襄款四出头官帽椅, 取材老挝酸枝, 透雕靠背板。',
   JSON_ARRAY('../images/家具-2.png', '../images/家具-3.png'),
   218, 42, 1, DATE_SUB(NOW(), INTERVAL 50 DAY)),

  (@admin1_id, '明式平头案 - 紫光檀',
   '1.8 米紫光檀平头案, 案面一木对开, 罗锅枨加矮佬。',
   JSON_ARRAY('../images/家具-3.png', '../images/家具-4.png'),
   189, 36, 1, DATE_SUB(NOW(), INTERVAL 40 DAY));


-- 4.6.3 木料类 - 2 条作品
INSERT INTO `user_work`
  (`user_id`, `title`, `description`, `images`, `like_count`, `comment_count`, `status`, `create_time`)
VALUES
  (@admin1_id, '小叶紫檀手串定制',
   '选用 2.0cm 印度小叶紫檀老料, 手工车制, 颗颗纹理清晰。',
   JSON_ARRAY('../images/紫檀木.png'),
   156, 28, 1, DATE_SUB(NOW(), INTERVAL 30 DAY)),

  (@admin1_id, '海南黄花梨茶则',
   '取自海南黄花梨根料, 纹理绚丽, 制作茶则一把。',
   JSON_ARRAY('../images/黄花梨.png', '../images/红木.png'),
   98, 18, 1, DATE_SUB(NOW(), INTERVAL 22 DAY));


-- 4.6.4 历史类 - 2 条作品
INSERT INTO `user_work`
  (`user_id`, `title`, `description`, `images`, `like_count`, `comment_count`, `status`, `create_time`)
VALUES
  (@admin1_id, '唐式斗栱 1:5 模型',
   '按佛光寺东大殿实物等比缩小, 全榫卯制作的教学模型。',
   JSON_ARRAY('../images/唐代.png', '../images/宋代.png'),
   87, 14, 1, DATE_SUB(NOW(), INTERVAL 75 DAY)),

  (@admin1_id, '明清家具纹样图谱',
   '手绘整理 88 种明清家具经典纹样, 含详细尺寸标注。',
   JSON_ARRAY('../images/明清.png', '../images/家具.jpg'),
   124, 23, 1, DATE_SUB(NOW(), INTERVAL 35 DAY));


-- 4.6.5 教程类 - 2 条作品
INSERT INTO `user_work`
  (`user_id`, `title`, `description`, `images`, `like_count`, `comment_count`, `status`, `create_time`)
VALUES
  (@admin1_id, '《榫卯入门 30 天》课程配套教具',
   '为入门课程制作的全套教学用榫卯模型, 含 6 种基础榫卯。',
   JSON_ARRAY('../images/入门.png', '../images/tool-set.png'),
   245, 48, 1, DATE_SUB(NOW(), INTERVAL 12 DAY)),

  (@admin1_id, '《明式圈椅复制》视频课程教具',
   '为进阶课程录制的全套 1:1 教学图纸 + 实物样件。',
   JSON_ARRAY('../images/进阶.png'),
   178, 32, 1, DATE_SUB(NOW(), INTERVAL 8 DAY));


-- ------------------------------------------------------------
-- 4.7 15 件商城商品 (4 家具 + 5 木料 + 3 工具 + 3 课程)
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
-- 第五部分: 启用外键检查 + 校验
-- ================================================================

SET FOREIGN_KEY_CHECKS = 1;

-- ================================================================
-- 部署完成后手动操作:
-- ================================================================
-- 1. 在 DBeaver 中执行本脚本 (确保当前数据库连接已选 ljx_platform)
-- 2. 后端 Spring Boot 启动: 运行 LjxPlatformApplication.java
-- 3. 微信开发者工具导入 ljx_extracted/ljx, 清缓存, 编译
-- 4. admin1 登录信息:
--      手机号: 13800000001
--      密码:   admin123
-- 5. 验证首页瀑布流: 应显示 12 张 article 卡片
-- 6. 验证我的作品: 应显示 12 张 user_work 卡片
-- ================================================================
