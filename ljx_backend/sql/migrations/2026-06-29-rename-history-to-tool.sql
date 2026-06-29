-- ================================================================
-- 6/29 迁移: category_id=4 从"历史"改名为"工具"
-- 原因: 首页 index.js 的"工具"tab cid=4, 但 DB 里 category_id=4 是"历史"
-- 改名后首页"工具"tab 能正确显示 category_id=4 的文章
-- ================================================================

UPDATE `category`
   SET `name` = '工具',
       `description` = '工具相关内容',
       `icon` = '../images/tool-set.png'
 WHERE `category_id` = 4;

-- 验证
SELECT category_id, name, description FROM category ORDER BY category_id;
