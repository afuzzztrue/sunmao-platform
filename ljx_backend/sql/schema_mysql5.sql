-- ========================================================
-- 榫卯非遗文化传承平台 - 数据库脚本
-- 兼容 MySQL 5.0+ 规范
-- 字符集: utf8mb4 (MySQL 5.5+), 如使用MySQL 5.0请改为 utf8
-- ========================================================

SET FOREIGN_KEY_CHECKS = 0;

-- --------------------------------------------------------
-- 1. 用户表 (User)
-- 存储平台注册用户和微信用户信息
-- --------------------------------------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `user_id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '用户ID，主键',
  `openid` VARCHAR(64) DEFAULT NULL COMMENT '微信openid',
  `unionid` VARCHAR(64) DEFAULT NULL COMMENT '微信unionid',
  `nickname` VARCHAR(100) DEFAULT NULL COMMENT '用户昵称',
  `avatar` VARCHAR(500) DEFAULT NULL COMMENT '头像URL',
  `phone` VARCHAR(20) DEFAULT NULL COMMENT '手机号',
  `email` VARCHAR(100) DEFAULT NULL COMMENT '邮箱',
  `password` VARCHAR(255) DEFAULT NULL COMMENT '登录密码（加密存储）',
  `gender` TINYINT(1) DEFAULT '0' COMMENT '性别：0未知 1男 2女',
  `province` VARCHAR(50) DEFAULT NULL COMMENT '省份',
  `city` VARCHAR(50) DEFAULT NULL COMMENT '城市',
  `study_hours` INT(11) DEFAULT '0' COMMENT '学习时长（小时）',
  `user_type` TINYINT(1) DEFAULT '0' COMMENT '用户类型：0普通用户 1传承人 2管理员',
  `status` TINYINT(1) DEFAULT '1' COMMENT '状态：0禁用 1正常',
  `create_time` DATETIME DEFAULT NULL COMMENT '创建时间',
  `update_time` DATETIME DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uk_user_openid` (`openid`),
  UNIQUE KEY `uk_user_phone` (`phone`),
  UNIQUE KEY `uk_user_email` (`email`),
  KEY `idx_user_nickname` (`nickname`),
  KEY `idx_user_type` (`user_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='用户表';


-- --------------------------------------------------------
-- 2. 内容分类表 (Category)
-- 树形结构存储内容分类：结构、家具、木料、历史、教程
-- --------------------------------------------------------
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category` (
  `category_id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '分类ID，主键',
  `name` VARCHAR(50) NOT NULL COMMENT '分类名称',
  `parent_id` INT(11) DEFAULT '0' COMMENT '父分类ID，0表示根分类',
  `sort_order` INT(11) DEFAULT '0' COMMENT '排序号',
  `icon` VARCHAR(500) DEFAULT NULL COMMENT '分类图标URL',
  `description` VARCHAR(255) DEFAULT NULL COMMENT '分类描述',
  `status` TINYINT(1) DEFAULT '1' COMMENT '状态：0禁用 1启用',
  `create_time` DATETIME DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`category_id`),
  KEY `idx_category_parent` (`parent_id`),
  KEY `idx_category_sort` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='内容分类表';


-- --------------------------------------------------------
-- 3. 内容文章表 (Article)
-- 存储首页内容卡片、热门内容、分类下的文章
-- --------------------------------------------------------
DROP TABLE IF EXISTS `article`;
CREATE TABLE `article` (
  `article_id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '文章ID，主键',
  `category_id` INT(11) NOT NULL COMMENT '所属分类ID',
  `user_id` INT(11) NOT NULL COMMENT '发布者用户ID',
  `title` VARCHAR(200) NOT NULL COMMENT '文章标题',
  `summary` VARCHAR(500) DEFAULT NULL COMMENT '文章摘要',
  `content` TEXT COMMENT '文章内容（富文本/HTML）',
  `cover_image` VARCHAR(500) DEFAULT NULL COMMENT '封面图片URL',
  `images` TEXT DEFAULT NULL COMMENT '文章图片列表（JSON格式）',
  `tags` VARCHAR(255) DEFAULT NULL COMMENT '标签，逗号分隔',
  `location` VARCHAR(100) DEFAULT NULL COMMENT '地理位置',
  `view_count` INT(11) DEFAULT '0' COMMENT '浏览次数',
  `like_count` INT(11) DEFAULT '0' COMMENT '点赞次数',
  `comment_count` INT(11) DEFAULT '0' COMMENT '评论次数',
  `collect_count` INT(11) DEFAULT '0' COMMENT '收藏次数',
  `is_hot` TINYINT(1) DEFAULT '0' COMMENT '是否热门：0否 1是',
  `is_banner` TINYINT(1) DEFAULT '0' COMMENT '是否轮播：0否 1是',
  `sort_order` INT(11) DEFAULT '0' COMMENT '排序号',
  `status` TINYINT(1) DEFAULT '1' COMMENT '状态：0草稿 1已发布 2下架',
  `create_time` DATETIME DEFAULT NULL COMMENT '创建时间',
  `update_time` DATETIME DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`article_id`),
  KEY `idx_article_category` (`category_id`),
  KEY `idx_article_user` (`user_id`),
  KEY `idx_article_hot` (`is_hot`),
  KEY `idx_article_banner` (`is_banner`),
  KEY `idx_article_status` (`status`),
  KEY `idx_article_create_time` (`create_time`),
  FULLTEXT KEY `ft_article_title` (`title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='内容文章表';


-- --------------------------------------------------------
-- 4. 动态帖子表 (Post)
-- 动态广场的用户发布内容
-- --------------------------------------------------------
DROP TABLE IF EXISTS `post`;
CREATE TABLE `post` (
  `post_id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '帖子ID，主键',
  `user_id` INT(11) NOT NULL COMMENT '发布用户ID',
  `content` TEXT NOT NULL COMMENT '帖子内容',
  `images` TEXT DEFAULT NULL COMMENT '图片列表（JSON格式）',
  `location` VARCHAR(100) DEFAULT NULL COMMENT '发布位置',
  `like_count` INT(11) DEFAULT '0' COMMENT '点赞数',
  `comment_count` INT(11) DEFAULT '0' COMMENT '评论数',
  `share_count` INT(11) DEFAULT '0' COMMENT '分享数',
  `post_type` TINYINT(1) DEFAULT '0' COMMENT '帖子类型：0普通 1热门',
  `status` TINYINT(1) DEFAULT '1' COMMENT '状态：0删除 1正常',
  `create_time` DATETIME DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`post_id`),
  KEY `idx_post_user` (`user_id`),
  KEY `idx_post_type` (`post_type`),
  KEY `idx_post_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='动态帖子表';


-- --------------------------------------------------------
-- 5. 点赞记录表 (LikeRecord)
-- 用户对文章或帖子的点赞记录
-- --------------------------------------------------------
DROP TABLE IF EXISTS `like_record`;
CREATE TABLE `like_record` (
  `like_id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '点赞ID，主键',
  `user_id` INT(11) NOT NULL COMMENT '用户ID',
  `target_type` TINYINT(1) NOT NULL COMMENT '点赞目标类型：1文章 2帖子',
  `target_id` INT(11) NOT NULL COMMENT '点赞目标ID',
  `create_time` DATETIME DEFAULT NULL COMMENT '点赞时间',
  PRIMARY KEY (`like_id`),
  UNIQUE KEY `uk_like_user_target` (`user_id`, `target_type`, `target_id`),
  KEY `idx_like_target` (`target_type`, `target_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='点赞记录表';


-- --------------------------------------------------------
-- 6. 评论表 (Comment)
-- 文章和帖子的评论
-- --------------------------------------------------------
DROP TABLE IF EXISTS `comment`;
CREATE TABLE `comment` (
  `comment_id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '评论ID，主键',
  `user_id` INT(11) NOT NULL COMMENT '评论用户ID',
  `target_type` TINYINT(1) NOT NULL COMMENT '评论目标类型：1文章 2帖子',
  `target_id` INT(11) NOT NULL COMMENT '评论目标ID',
  `parent_id` INT(11) DEFAULT '0' COMMENT '父评论ID，0为一级评论',
  `content` TEXT NOT NULL COMMENT '评论内容',
  `like_count` INT(11) DEFAULT '0' COMMENT '点赞数',
  `status` TINYINT(1) DEFAULT '1' COMMENT '状态：0删除 1正常',
  `create_time` DATETIME DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`comment_id`),
  KEY `idx_comment_target` (`target_type`, `target_id`),
  KEY `idx_comment_user` (`user_id`),
  KEY `idx_comment_parent` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='评论表';


-- --------------------------------------------------------
-- 7. 收藏记录表 (CollectRecord)
-- 用户收藏文章记录
-- --------------------------------------------------------
DROP TABLE IF EXISTS `collect_record`;
CREATE TABLE `collect_record` (
  `collect_id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '收藏ID，主键',
  `user_id` INT(11) NOT NULL COMMENT '用户ID',
  `article_id` INT(11) NOT NULL COMMENT '文章ID',
  `create_time` DATETIME DEFAULT NULL COMMENT '收藏时间',
  PRIMARY KEY (`collect_id`),
  UNIQUE KEY `uk_collect_user_article` (`user_id`, `article_id`),
  KEY `idx_collect_user` (`user_id`),
  KEY `idx_collect_article` (`article_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='收藏记录表';


-- --------------------------------------------------------
-- 8. 关注关系表 (Follow)
-- 用户之间的关注关系
-- --------------------------------------------------------
DROP TABLE IF EXISTS `follow`;
CREATE TABLE `follow` (
  `follow_id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '关注ID，主键',
  `user_id` INT(11) NOT NULL COMMENT '关注者用户ID',
  `follow_user_id` INT(11) NOT NULL COMMENT '被关注用户ID',
  `create_time` DATETIME DEFAULT NULL COMMENT '关注时间',
  PRIMARY KEY (`follow_id`),
  UNIQUE KEY `uk_follow_user` (`user_id`, `follow_user_id`),
  KEY `idx_follow_user_id` (`user_id`),
  KEY `idx_followed_user_id` (`follow_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='关注关系表';


-- --------------------------------------------------------
-- 9. 浏览足迹表 (Footprint)
-- 用户浏览文章的历史记录
-- --------------------------------------------------------
DROP TABLE IF EXISTS `footprint`;
CREATE TABLE `footprint` (
  `footprint_id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '足迹ID，主键',
  `user_id` INT(11) NOT NULL COMMENT '用户ID',
  `article_id` INT(11) NOT NULL COMMENT '文章ID',
  `create_time` DATETIME DEFAULT NULL COMMENT '浏览时间',
  PRIMARY KEY (`footprint_id`),
  KEY `idx_footprint_user` (`user_id`),
  KEY `idx_footprint_article` (`article_id`),
  KEY `idx_footprint_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='浏览足迹表';


-- --------------------------------------------------------
-- 10. 教程课程表 (Course)
-- 技艺教程模块的课程信息
-- --------------------------------------------------------
DROP TABLE IF EXISTS `course`;
CREATE TABLE `course` (
  `course_id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '课程ID，主键',
  `category_id` INT(11) NOT NULL COMMENT '所属分类ID',
  `user_id` INT(11) NOT NULL COMMENT '讲师用户ID',
  `title` VARCHAR(200) NOT NULL COMMENT '课程标题',
  `description` TEXT DEFAULT NULL COMMENT '课程描述',
  `cover_image` VARCHAR(500) DEFAULT NULL COMMENT '封面图片',
  `video_url` VARCHAR(500) DEFAULT NULL COMMENT '视频URL',
  `duration` INT(11) DEFAULT '0' COMMENT '课程时长（分钟）',
  `difficulty` TINYINT(1) DEFAULT '1' COMMENT '难度：1入门 2进阶 3高级 4大师',
  `view_count` INT(11) DEFAULT '0' COMMENT '观看次数',
  `like_count` INT(11) DEFAULT '0' COMMENT '点赞数',
  `download_count` INT(11) DEFAULT '0' COMMENT '下载次数',
  `sort_order` INT(11) DEFAULT '0' COMMENT '排序号',
  `status` TINYINT(1) DEFAULT '1' COMMENT '状态：0下架 1上架',
  `create_time` DATETIME DEFAULT NULL COMMENT '创建时间',
  `update_time` DATETIME DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`course_id`),
  KEY `idx_course_category` (`category_id`),
  KEY `idx_course_user` (`user_id`),
  KEY `idx_course_difficulty` (`difficulty`),
  KEY `idx_course_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='教程课程表';


-- --------------------------------------------------------
-- 11. 课程下载记录表 (CourseDownload)
-- 用户下载课程的记录
-- --------------------------------------------------------
DROP TABLE IF EXISTS `course_download`;
CREATE TABLE `course_download` (
  `download_id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '下载ID，主键',
  `user_id` INT(11) NOT NULL COMMENT '用户ID',
  `course_id` INT(11) NOT NULL COMMENT '课程ID',
  `create_time` DATETIME DEFAULT NULL COMMENT '下载时间',
  PRIMARY KEY (`download_id`),
  UNIQUE KEY `uk_download_user_course` (`user_id`, `course_id`),
  KEY `idx_download_user` (`user_id`),
  KEY `idx_download_course` (`course_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='课程下载记录表';


-- --------------------------------------------------------
-- 12. 用户作品表 (UserWork)
-- 用户发布的作品展示
-- --------------------------------------------------------
DROP TABLE IF EXISTS `user_work`;
CREATE TABLE `user_work` (
  `work_id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '作品ID，主键',
  `user_id` INT(11) NOT NULL COMMENT '用户ID',
  `title` VARCHAR(200) NOT NULL COMMENT '作品标题',
  `description` TEXT DEFAULT NULL COMMENT '作品描述',
  `images` TEXT DEFAULT NULL COMMENT '作品图片（JSON格式）',
  `like_count` INT(11) DEFAULT '0' COMMENT '点赞数',
  `comment_count` INT(11) DEFAULT '0' COMMENT '评论数',
  `status` TINYINT(1) DEFAULT '1' COMMENT '状态：0删除 1正常',
  `create_time` DATETIME DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`work_id`),
  KEY `idx_work_user` (`user_id`),
  KEY `idx_work_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='用户作品表';


-- --------------------------------------------------------
-- 13. 轮播图表 (Banner)
-- 首页轮播图管理
-- --------------------------------------------------------
DROP TABLE IF EXISTS `banner`;
CREATE TABLE `banner` (
  `banner_id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '轮播图ID，主键',
  `title` VARCHAR(100) DEFAULT NULL COMMENT '轮播图标题',
  `image_url` VARCHAR(500) NOT NULL COMMENT '图片URL',
  `link_url` VARCHAR(500) DEFAULT NULL COMMENT '跳转链接',
  `link_type` TINYINT(1) DEFAULT '1' COMMENT '跳转类型：1文章 2外部链接',
  `link_id` INT(11) DEFAULT NULL COMMENT '关联ID',
  `sort_order` INT(11) DEFAULT '0' COMMENT '排序号',
  `status` TINYINT(1) DEFAULT '1' COMMENT '状态：0禁用 1启用',
  `create_time` DATETIME DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`banner_id`),
  KEY `idx_banner_sort` (`sort_order`),
  KEY `idx_banner_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='轮播图表';


-- --------------------------------------------------------
-- 14. 系统配置表 (SysConfig)
-- 系统参数配置
-- --------------------------------------------------------
DROP TABLE IF EXISTS `sys_config`;
CREATE TABLE `sys_config` (
  `config_id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '配置ID，主键',
  `config_key` VARCHAR(100) NOT NULL COMMENT '配置键',
  `config_value` TEXT DEFAULT NULL COMMENT '配置值',
  `description` VARCHAR(255) DEFAULT NULL COMMENT '配置说明',
  `create_time` DATETIME DEFAULT NULL COMMENT '创建时间',
  `update_time` DATETIME DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`config_id`),
  UNIQUE KEY `uk_config_key` (`config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='系统配置表';


SET FOREIGN_KEY_CHECKS = 1;


-- ========================================================
-- 初始化数据
-- ========================================================

-- 初始化分类数据
INSERT INTO `category` (`name`, `parent_id`, `sort_order`, `icon`, `description`, `status`, `create_time`) VALUES
('结构', 0, 1, '../images/结构-1.png', '榫卯结构相关内容', 1, NOW()),
('家具', 0, 2, '../images/家具-1.png', '传统家具相关内容', 1, NOW()),
('木料', 0, 3, '../images/紫檀木.png', '木料材质相关内容', 1, NOW()),
('历史', 0, 4, '../images/唐代.png', '榫卯历史相关内容', 1, NOW()),
('教程', 0, 5, '../images/入门.png', '制作教程相关内容', 1, NOW());

-- 初始化轮播图数据
INSERT INTO `banner` (`title`, `image_url`, `link_type`, `sort_order`, `status`, `create_time`) VALUES
('轮播图1', '../images/轮播-1.jpg', 1, 1, 1, NOW()),
('轮播图2', '../images/轮播-2.jpg', 1, 2, 1, NOW()),
('轮播图3', '../images/轮播-3.jpg', 1, 3, 1, NOW()),
('轮播图4', '../images/轮播-4.jpg', 1, 4, 1, NOW());

-- 初始化热门内容
INSERT INTO `article` (`category_id`, `user_id`, `title`, `summary`, `content`, `cover_image`, `tags`, `location`, `is_hot`, `status`, `create_time`) VALUES
(4, 1, '太和殿：榫卯之巅', '作为现存中国最大的木构建筑，太和殿通过成千上万个复杂的榫卯构件交织，无需一颗钉子，经受了数百年的风雨与地震。', '太和殿详细内容...', '../images/太和殿.jpg', '宫殿建筑,榫卯', '北京·故宫', 1, 1, NOW()),
(4, 1, '山西·大同寺', '方形，高43.5 米，外观三层、实则五层（明三暗二），典型辽金风格。2008 年依辽代形制复建，纯木榫卯、无钉无铆。', '大同寺详细内容...', '../images/宗教建筑.jpg', '宗教建筑,辽金', '山西·大同', 1, 1, NOW()),
(2, 1, '明式家具：极简结构', '明式家具以其极简的结构和设计而闻名，将榫卯结构发挥到了艺术极致，线条洗练，严丝合缝。', '明式家具详细内容...', '../images/家具.jpg', '家具美学,明式', '明式风骨', 1, 1, NOW());
