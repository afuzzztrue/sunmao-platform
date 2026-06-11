-- ========================================================
-- 迁移脚本: 2026-06-10-my-tabs-backend-integration
-- 作者: 钟景胜
-- 说明: 为"我的"页面 8 个 tab 接入后端所需的所有 DDL
--   1) 新建 feedback 表（用户反馈 + 客服咨询）
--   2) user 表加 preferences JSON 列
--   3) footprint 表加 snapshot 字段（标题/封面/作者快照）
--   4) sys_config 写入客服联系方式
-- 兼容: MySQL 8.0+
-- 执行方式: 在 DBeaver 选中 ljx_platform 库，整段执行
-- ========================================================

SET FOREIGN_KEY_CHECKS = 0;

-- --------------------------------------------------------
-- 1) 用户反馈表 feedback
--    用于"帮助与反馈"页 + "客服中心"页提交
--    fb_type: 1功能建议 2联系客服 3举报 4bug 5商务
-- --------------------------------------------------------
DROP TABLE IF EXISTS `feedback`;
CREATE TABLE `feedback` (
  `feedback_id` INT NOT NULL AUTO_INCREMENT COMMENT '反馈ID，主键',
  `user_id`     INT DEFAULT NULL COMMENT '提交用户ID，未登录可空',
  `fb_type`     TINYINT NOT NULL DEFAULT 1 COMMENT '1功能建议 2联系客服 3举报 4bug 5商务',
  `content`     TEXT NOT NULL COMMENT '反馈正文',
  `contact`     VARCHAR(100) DEFAULT NULL COMMENT '联系方式（手机/邮箱/微信）',
  `device`      VARCHAR(255) DEFAULT NULL COMMENT '提交设备UA',
  `status`      TINYINT NOT NULL DEFAULT 0 COMMENT '0未处理 1已查看 2已回复 3已关闭',
  `reply`       TEXT DEFAULT NULL COMMENT '客服回复内容',
  `reply_time`  DATETIME DEFAULT NULL COMMENT '回复时间',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
  PRIMARY KEY (`feedback_id`),
  KEY `idx_fb_user`   (`user_id`),
  KEY `idx_fb_type`   (`fb_type`),
  KEY `idx_fb_status` (`status`),
  KEY `idx_fb_create` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户反馈表';


-- --------------------------------------------------------
-- 2) user 表加 preferences JSON 列
--    存储消息通知/深色模式/字体大小/语言
--    示例: {"notify":true,"darkMode":false,"fontSize":"标准","language":"zh-CN"}
-- --------------------------------------------------------
ALTER TABLE `user`
  ADD COLUMN `preferences` JSON DEFAULT NULL
    COMMENT '用户偏好 {notify, darkMode, fontSize, language}';


-- --------------------------------------------------------
-- 3) footprint 表加 snapshot 字段
--    浏览文章时把标题/封面/作者快照写入足迹
--    目的: 文章被删除后足迹仍能展示
-- --------------------------------------------------------
ALTER TABLE `footprint`
  ADD COLUMN `snapshot_title`  VARCHAR(200) DEFAULT NULL COMMENT '文章标题快照',
  ADD COLUMN `snapshot_cover`  VARCHAR(500) DEFAULT NULL COMMENT '文章封面快照',
  ADD COLUMN `snapshot_author` VARCHAR(100) DEFAULT NULL COMMENT '文章作者快照';


-- --------------------------------------------------------
-- 4) 客服联系配置（sys_config）
--    "客服中心"页 + 复制联系方式从这张表读
-- --------------------------------------------------------
INSERT INTO `sys_config` (`config_key`, `config_value`, `description`) VALUES
('service_phone',  '400-888-8888',     '客服电话'),
('service_email',  'support@sunmao.com','客服邮箱'),
('service_wechat', 'sunmao_helper',    '客服微信'),
('service_weibo',  '@榫卯非遗官方',     '官方微博'),
('service_hours',  '工作日 9:00-18:00', '服务时间')
ON DUPLICATE KEY UPDATE config_value = VALUES(config_value);


SET FOREIGN_KEY_CHECKS = 1;
