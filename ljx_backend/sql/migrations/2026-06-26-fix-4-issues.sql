-- ========================================================
-- 迁移脚本: 2026-06-26-fix-4-issues
-- 作者: 钟景胜
-- 说明: 6/26 修复 6 个问题所需 DDL
-- 兼容: MySQL 8.0.29+ (用 ADD COLUMN IF NOT EXISTS 幂等语法)
-- 执行方式: 在 DBeaver 选中 ljx_platform 库, Ctrl+A 全选执行
-- 关键: MySQL 8.0.29+ 原生支持 ADD COLUMN IF NOT EXISTS, 重复执行不会报错
-- ========================================================

SET FOREIGN_KEY_CHECKS = 0;

-- ========================================================
-- 1) collect_record 表: 加 target_type + target_id 列
-- ========================================================
ALTER TABLE `collect_record`
  ADD COLUMN IF NOT EXISTS `target_type` TINYINT DEFAULT NULL COMMENT '1-2-3-4-5' AFTER `article_id`,
  ADD COLUMN IF NOT EXISTS `target_id`   INT    DEFAULT NULL COMMENT 'target id' AFTER `target_type`,
  ADD KEY        IF NOT EXISTS `idx_collect_user_target` (`user_id`, `target_type`, `target_id`);

-- ========================================================
-- 2) footprint 表: 加 target_type + target_id 列
-- ========================================================
ALTER TABLE `footprint`
  ADD COLUMN IF NOT EXISTS `target_type` TINYINT DEFAULT NULL COMMENT '1-2-3-4-5' AFTER `article_id`,
  ADD COLUMN IF NOT EXISTS `target_id`   INT    DEFAULT NULL COMMENT 'target id' AFTER `target_type`,
  ADD KEY        IF NOT EXISTS `idx_fp_user_target` (`user_id`, `target_type`, `target_id`);

-- ========================================================
-- 3) 补齐老数据
-- ========================================================
UPDATE `collect_record`
   SET `target_type` = 1,
       `target_id`   = `article_id`
 WHERE `target_type` IS NULL
   AND `article_id` IS NOT NULL;

UPDATE `footprint`
   SET `target_type` = 1,
       `target_id`   = `article_id`
 WHERE `target_type` IS NULL
   AND `article_id` IS NOT NULL;

SET FOREIGN_KEY_CHECKS = 1;

-- ========================================================
-- 验证 (应该看到 4 行)
-- ========================================================
SELECT table_name, column_name, data_type, is_nullable
  FROM information_schema.columns
 WHERE table_schema = DATABASE()
   AND table_name IN ('collect_record', 'footprint')
   AND column_name IN ('target_type', 'target_id')
 ORDER BY table_name, column_name;
