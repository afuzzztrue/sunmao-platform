-- ================================================================
-- 榫卯非遗文化传承平台 - 管理员作品种子数据
-- --------------------------------------------------------------
-- 版本:       v1.0 (2026-06-24)
-- 适用数据库:  MySQL 8.0+
-- 端口:        3307
-- 库名:        ljx_platform
-- --------------------------------------------------------------
-- 作用: 为 admin1 管理员用户批量生成 12 条文章 + 12 条作品
-- 触发场景: 6/24 首页空白, 瀑布流无数据
-- 覆盖: 5 个内容分类 (结构/家具/木料/历史/教程)
-- --------------------------------------------------------------
-- 执行: 在 DBeaver 选中整个脚本, Ctrl+A → Ctrl+Enter
--   或命令行:
--     mysql -uroot -p12345 -P3307 ljx_platform < seed_articles_admin1.sql
-- --------------------------------------------------------------
-- 脚本可重复执行 (开头先 DELETE 旧数据)
-- ================================================================


-- ================================================================
-- 第一部分: 准备工作
-- ================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

USE `ljx_platform`;


-- ================================================================
-- 第二部分: 创建 admin1 用户
-- ================================================================

-- 2.1 删除旧 admin1 (按 nickname 唯一标识, 不会误删其他用户)
DELETE FROM `user` WHERE `nickname` = 'admin1';

-- 2.2 插入 admin1
--   user_type = 2  (管理员)
--   status    = 1  (正常)
--   password  = MD5('admin123')  (演示用密码)
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

-- 2.3 取出 admin1 的 user_id, 后续 INSERT 全部引用
SELECT `user_id` INTO @admin1_id FROM `user` WHERE `nickname` = 'admin1' LIMIT 1;

SELECT CONCAT('admin1 user_id = ', @admin1_id) AS step;


-- ================================================================
-- 第三部分: 清理 admin1 旧数据 (保证可重跑)
-- ================================================================

DELETE FROM `article`   WHERE `user_id` = @admin1_id;
DELETE FROM `user_work` WHERE `user_id` = @admin1_id;

SELECT CONCAT('清理完毕, 准备插入新数据') AS step;


-- ================================================================
-- 第四部分: 12 条 article (首页瀑布流数据源)
-- ================================================================

-- 4.1 结构类 (category_id=1) - 3 条
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


-- 4.2 家具类 (category_id=2) - 3 条
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
   '<h2>形制特征</h2><p>案面平直, 牙板与腿足以夹头榫接合, 牙板上常挖"壸门"形亮脚...</p><h2>使用场景</h2><p>平头案常置于书房中, 上可置文房四宝、卷轴书籍, 兼具陈设与实用功能...</p>',
   '../images/家具-3.png',
   JSON_ARRAY('../images/家具-3.png', '../images/家具-4.png'),
   '平头案,书房,明式家具',
   '上海', 2890, 367, 49, 102, 1, 0, 90, 1, NOW());


-- 4.3 木料类 (category_id=3) - 2 条
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


-- 4.4 历史类 (category_id=4) - 2 条
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


-- 4.5 教程类 (category_id=5) - 2 条
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


-- ================================================================
-- 第五部分: 12 条 user_work (admin1 的"我的作品"页面数据源)
-- ================================================================
-- 注意: works.js 调用的 /api/work/user/{userId} 查的是 user_work 表
--       images 字段是 JSON 字符串, 这里用 JSON_ARRAY 转换

-- 5.1 结构类 - 3 条作品
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


-- 5.2 家具类 - 3 条作品
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


-- 5.3 木料类 - 2 条作品
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


-- 5.4 历史类 - 2 条作品
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


-- 5.5 教程类 - 2 条作品
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


-- ================================================================
-- 第六部分: 启用外键检查 + 校验
-- ================================================================

SET FOREIGN_KEY_CHECKS = 1;

SELECT '=== 种子数据插入完成 ===' AS message;

SELECT
  (SELECT COUNT(*) FROM `user`      WHERE `nickname` = 'admin1')            AS admin1_count,
  (SELECT COUNT(*) FROM `article`   WHERE `user_id` = @admin1_id)            AS articles_for_admin1,
  (SELECT COUNT(*) FROM `user_work` WHERE `user_id` = @admin1_id)            AS works_for_admin1,
  (SELECT SUM(`view_count`) FROM `article` WHERE `user_id` = @admin1_id)     AS total_views,
  (SELECT SUM(`like_count`) FROM `article` WHERE `user_id` = @admin1_id)     AS total_likes;

SELECT
  `category_id`,
  (SELECT `name` FROM `category` WHERE `category_id` = a.`category_id`) AS category_name,
  COUNT(*) AS article_count
FROM `article` a
WHERE `user_id` = @admin1_id
GROUP BY `category_id`
ORDER BY `category_id`;


-- ================================================================
-- 部署完成后手动操作:
-- ================================================================
-- 1. 在 DBeaver 中运行本脚本
-- 2. 在微信开发者工具"编译" → 首页瀑布流应出现 12 条 article
-- 3. 用 admin1 (手机号 13800000001, 密码 admin123) 登录
-- 4. 进入"我的作品"页面, 应看到 12 条 user_work 记录
-- 5. 验证 SQL:
--      SELECT * FROM article WHERE user_id = @admin1_id;
--      SELECT * FROM user_work WHERE user_id = @admin1_id;
-- ================================================================
