# 榫卯非遗文化传承平台 — 项目交付说明

> **作者**：钟景胜（2026 年 6 月 11 日截至）
> **读者**：项目团队成员 / 中期答辩观众
> **目的**：万一我临时有事无法到场讲解，团队成员通过本文档也能全面了解项目，包括环境、启动、踩过的坑、所用版本号
> **来源**：本文档事实全部来自 `C:\Users\Afuz.AFUZZZZZZZZ\Desktop\期中答辩展示\截止至6月11日关于榫卯项目的全对话.txt`（3364 行）以及 6/11 当天下午的 Git 协作与 baseMapper bug 修复对话

---

## 0. 写在前面

本项目从 2026 年 5 月 27 日开始，到 6 月 11 日截止，历经 **16 天** 改造。期间经历了：

- 登录注册修复（参考宿享通项目）
- 后端代码解析（按阿里 Java 手册审查）
- MySQL 5.5 → 8.0 升级（含 3306/3307 端口冲突排查）
- 仿照健身房项目做全面改造（管理员 + AI 导师 + 商城 + 工具图片修复）
- UI 全面现代化（榫卯匠心主题）
- 8 个"我的"Tab 后端对接（含 6/11 当天的 baseMapper bug 修复）

下文会逐一展开。

---

## 1. 项目简介

**榫卯非遗文化传承平台** 是一个基于**微信小程序**的非物质文化遗产数字化传承平台。榫卯是中国传统木结构建筑与家具的连接工艺，不用钉子不用胶水，靠木构件凹凸咬合即可牢固结合。本项目旨在让用户在小程序中：

- 浏览榫卯结构、家具、木料、历史、教程等内容
- 上传自己的木工作品、点赞收藏感兴趣的内容
- 在商城购买榫卯工艺品、木料、工具、课程
- 与 AI "榫卯文化导师"对话，学习非遗知识
- 浏览历史足迹、下载过的课程、管理订单

**目标用户**：木工爱好者 / 传统文化学习者 / 非遗传承人 / 普通消费者

**业务模型**：内容展示 + 社交互动 + 教程学习 + 电商交易 + AI 咨询（5 大模块）

---

## 2. 核心功能

### 2.1 底部 Tab 栏（4 个一级 Tab）

| Tab | 路径 | 核心内容 | 状态 |
|---|---|---|---|
| 首页 | `pages/index/index` | 轮播图 + 热门文章 + 榫卯建筑卡片 | ✅ 已接后端 |
| 分类 | `pages/sort/sort` | 3 大难度等级（入门/学者/大师）9 种榫卯结构 + 弹窗详情 + 一键跳转商城 | ✅ 已接后端 |
| 商城 | `pages/shop/shop` | 5 子 tab（全部/家具/木料/工具/课程）15+ 商品 | ✅ 已接后端 |
| 我的 | `pages/my/my` | 用户信息 + 8 个菜单入口 + 顶栏设置/搜索 | ✅ 已接后端 |

> 📌 **重要变更**：原"动态"Tab 已删除，被"商城"Tab 替换（详见 §10.3）。

### 2.2 商城 5 子 Tab

| 子 Tab | 二级分类 ID | 演示商品示例 |
|---|---|---|
| 全部 | 不限 | 15 件全部商品 |
| 家具 | 1 | 明式圈椅 ¥8800、官帽椅 ¥12800、平头案 ¥16800、博古架 ¥9800 |
| 木料 | 2 | 小叶紫檀 ¥2800、黄花梨 ¥6800、酸枝 ¥1800、金丝楠 ¥3600、鸡翅木 ¥980 |
| 工具 | 4 | 大师五件套 ¥1280、日式平刨 ¥680、机械鸠尾榫导板 ¥398 |
| 课程 | 5 | 入门 30 天 ¥299、家具复制 ¥699、古建筑解析 ¥499 |

### 2.3 分类 3 子 Tab（按难度分级）

| 子 Tab | 颜色 | 9 种结构 |
|---|---|---|
| 🟢 入门 | 竹青 `#5B8A4A` | 半隐燕尾榫 · 全隐斗底槽 · 口袋榫 |
| 🟡 学者 | 金楠 `#B8860B` | 圆木哨 · 粽角榫 · 抱肩榫 |
| 🔴 大师 | 朱砂 `#C4493D` | 楔钉榫 · 格角榫 · 插肩榫 |

### 2.4 "我的" 8 个二级页面 + 2 顶栏入口

| 入口 | 路径 | 功能 |
|---|---|---|
| 我的足迹 | `pages/footprint/footprint` | 按时间分组 + 时间筛选 |
| 我的作品 | `pages/works/works` | 顶部统计 + 发布按钮 |
| 已下载的课程 | `pages/downloads/downloads` | 进度条 + 继续学习 + 多选删除 |
| 我的点赞 | `pages/likes/likes` | 跨类型筛选 + 取消点赞 |
| 帮助与反馈 | `pages/help/help` | FAQ + 反馈表单（写入 `feedback` 表） |
| 客服中心 | `pages/support/support` | 联系方式 + 快捷入口 |
| AI 文化导师 | `pages/chat/chat` | DeepSeek 接入 |
| 用户管理 | `pages/admin/admin` | **仅管理员可见** user_type=2 |
| 顶栏 ⚙️ 设置 | `pages/settings/settings` | 偏好消息/深色/字体/语言 |
| 顶栏 🔍 搜索 | `pages/global-search/global-search` | 跨 5 表聚合搜索 |

### 2.5 "我的订单" 6 子 Tab

| 子 Tab | 过滤条件 | 后端 status |
|---|---|---|
| 全部 | 全部订单 | 任意 |
| 待支付 | `status == 0` | 0=待支付 |
| 待发货 | `status == 1` | 1=已支付（待发货） |
| 待收货/使用 | `status == 2` | 2=已发货（待收货） |
| 评价 | `status == 3` | 3=已完成（待评价） |
| 售后 | `status == 4` | 4=已取消 / 售后 |

---

## 3. 技术栈与软件版本（**重点**）

> 答辩时这一节很重要，每一项都用到的具体版本号都列出来。

### 3.1 运行环境

| 软件 | 版本 | 备注 |
|---|---|---|
| **操作系统** | Windows 11（2024 年安装） | 用户环境 |
| **JDK** | 1.8.0_171 | 后端编译运行所需，IDEA 必须配 JDK 1.8（不是 JRE） |
| **Maven** | IDEA 内置（3.x） | `ljx_backend/pom.xml` |
| **MySQL 5.5（旧）** | 5.5 | 端口 3306，**已废弃**，新数据不再写入 |
| **MySQL 8.0（新）** | 8.0.46 | 端口 3307，**当前主用**，库 `ljx_platform` |
| **DBeaver** | 社区版（最新） | 图形化管理 MySQL |
| **IntelliJ IDEA** | 社区版（最新） | Java 后端开发 |
| **微信开发者工具** | 2.01.2510290 | 小程序编译预览 |
| **小程序基础库** | 3.15.2 | 详见 `project.config.json:3` |
| **小程序 AppID** | `wxb999f19c2210b1a4` | `project.config.json:39` |
| **Git** | 2.35.1.2 | 团队协作，6/11 当天安装配置 |
| **PowerShell** | Windows 默认 | 项目用过的命令行工具 |

### 3.2 后端依赖（pom.xml）

| 依赖 | 版本 | 用途 |
|---|---|---|
| Spring Boot | 2.7.18 | 主框架 |
| MyBatis-Plus | 3.5.5 | ORM 增强 |
| mysql-connector-java | 8.0.33 | MySQL 驱动 |
| Druid | 1.2.20 | 连接池 |
| JJWT | 0.9.1 | JWT 鉴权（**当前未启用，userId 走 URL/Body**） |
| Fastjson2 | 2.0.43 | JSON 处理 |
| Lombok | 最新 | 注解简化代码（**必须启用 Annotation Processors**） |
| spring-boot-starter-validation | 2.7.18 | 参数校验 |
| spring-boot-starter-test | 2.7.18 | 测试（test scope） |

### 3.3 前端基础库

| 项 | 值 | 备注 |
|---|---|---|
| 框架 | 微信小程序原生 | wxml + wxss + js |
| 编译类型 | miniprogram | `project.config.json:2` |
| ES6 | 启用 | `setting.es6 = true` |
| PostCSS | 启用 | `setting.postcss = true` |
| swc | 禁用 | `setting.disableSWC = true` |
| 组件框架 | glass-easel | `componentFramework` |
| 网络请求 | `wx.request` | 配合 `app.globalData.baseUrl` |
| 本地存储 | `wx.setStorageSync` / `getStorageSync` | 存 userId/token/nickname |

### 3.4 第三方服务

| 服务 | 用途 | 状态 |
|---|---|---|
| DeepSeek API | AI 导师聊天 | ⚠️ 需用户自行去 https://platform.deepseek.com 注册并替换 `application.yml` 中的 `your-deepseek-api-key` |

---

## 4. 环境准备（**重点**）

### 4.1 必须安装的软件清单

| # | 软件 | 关键配置 |
|---|---|---|
| 1 | JDK 1.8（**不是 JRE**） | IDEA `File → Project Structure → SDK → JDK 1.8.x` |
| 2 | Maven | IDEA 自带 |
| 3 | MySQL 8.0 | 端口 **3307**（不要用默认 3306，会与旧 5.5 冲突）；服务名 `MySQL80`；**取消勾选** "Start the MySQL Server at System Startup"（与旧 5.5 保持一致的"手动启动"模式） |
| 4 | DBeaver | 连接字符串 `jdbc:mysql://localhost:3307/ljx_platform`，需在驱动属性中加 `allowPublicKeyRetrieval=true` 和 `useSSL=false` |
| 5 | IntelliJ IDEA 社区版 | 安装 Lombok 插件；启用 `Settings → Build, Execution, Deployment → Compiler → Annotation Processors` |
| 6 | 微信开发者工具 | 导入 `ljx_extracted/ljx` 目录，AppID 见上 |
| 7 | Git 2.35+ | 6/11 当天安装；如遇 22 端口被墙，需配置 SSH 走 443 端口（详见 §10.6） |

### 4.2 数据库用户与密码

```
host: localhost
port: 3307
database: ljx_platform
username: root
password: 12345
charset: utf8mb4
collation: utf8mb4_unicode_ci
```

> **重要**：MySQL 8.0 默认认证插件是 `caching_sha2_password`，需加 `allowPublicKeyRetrieval=true`。或者在 MySQL 命令行中 `ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '12345';` 改为兼容模式。

---

## 5. 项目结构

```
fstRepo-main/                                # 项目根
├── README.md                                # ⭐ 本文档
├── .gitignore                               # Git 忽略配置（target/ .idea/ *.iml 等）
├── docs/                                    # 项目级技术文档
│   ├── 2026-06-09-shop-tool-images-fix.md   # 工具图片 webp 教训
│   ├── 2026-06-10-login-placeholder-bugfix.md
│   └── superpowers/plans/                   # 实施计划
│       ├── 2026-06-09-sunmao-renovation.md
│       └── 2026-06-10-my-tabs-backend-integration.md
├── ljx_backend/                             # Spring Boot 后端
│   ├── pom.xml                              # Maven 依赖
│   ├── sql/
│   │   ├── schema_mysql8_full.sql          # ⭐ v1.0 整合脚本（17 张表 + 29 条种子，一键部署）
│   │   ├── schema_mysql5.sql                # 旧 MySQL 5.5 脚本（已废弃，仅历史归档）
│   │   ├── schema_mysql8.sql                # MySQL 8.0 早期版本（已被 _full 取代）
│   │   ├── init_database.sql                # 早期初始化脚本（已被 _full 取代）
│   │   ├── seed_products.sql                # 商城种子（已被 _full 集成）
│   │   └── migrations/
│   │       └── 2026-06-10-my-tabs-backend-integration.sql  # 增量迁移（已被 _full 集成）
│   ├── src/main/
│   │   ├── java/com/sunmao/ljx/
│   │   │   ├── common/                      # 通用工具：Result/PageResult/异常
│   │   │   ├── config/                      # 配置：MyBatis-Plus/CORS
│   │   │   ├── controller/                  # ⭐ 14 个 REST Controller
│   │   │   │   ├── AdminController.java     # 管理员用户 CRUD
│   │   │   │   ├── ArticleController.java
│   │   │   │   ├── BannerController.java
│   │   │   │   ├── CategoryController.java
│   │   │   │   ├── ChatController.java      # AI 聊天（DeepSeek）
│   │   │   │   ├── CourseController.java
│   │   │   │   ├── FeedbackController.java  # 反馈 + 客服咨询
│   │   │   │   ├── FollowController.java
│   │   │   │   ├── FootprintController.java
│   │   │   │   ├── LikeController.java      # 点赞列表
│   │   │   │   ├── PostController.java
│   │   │   │   ├── ProductController.java   # 商城
│   │   │   │   ├── SearchController.java    # 跨 5 表搜索
│   │   │   │   ├── UserController.java
│   │   │   │   └── UserWorkController.java
│   │   │   ├── entity/                      # ⭐ 16 个 Entity
│   │   │   ├── mapper/                      # ⭐ 17 个 Mapper（含 SearchMapper.xml）
│   │   │   ├── service/                     # 接口 + impl/ 实现
│   │   │   └── LjxPlatformApplication.java  # 启动类（端口 8081）
│   │   └── resources/
│   │       ├── application.yml              # ⭐ 配置（端口 3307、MyBatis-Plus、DeepSeek）
│   │       └── mapper/SearchMapper.xml      # 5 表 UNION ALL
│   ├── 后端代码解析.md                       # 各文件 AI vs 作者占比
│   ├── 前后端模块对应解析.md                 # 前端页面 ↔ 后端 Controller 对应表
│   └── 数据库设计思路.txt                    # 数据库设计原文档
│
└── ljx_extracted/ljx/                       # 微信小程序前端
    ├── app.js                               # ⭐ 全局（baseUrl / 用户状态）
    ├── app.json                             # ⭐ TabBar 配置 + 页面注册
    ├── app.wxss                             # ⭐ 全局样式（榫卯匠心主题）
    ├── project.config.json                  # 微信开发者工具配置
    └── pages/
        ├── index/                           # 首页
        ├── sort/                            # 分类（结构难度分级）
        ├── shop/                            # 商城（5 子 tab）
        ├── product/                         # 商品详情
        ├── order/                           # 我的订单（6 子 tab + sticky）
        ├── order-search/                    # 订单搜索（独立页）
        ├── my/                              # 我的（8 菜单 + 2 顶栏）
        ├── login/                           # 登录
        ├── register/                        # 注册
        ├── chat/                            # AI 导师
        ├── admin/                           # 用户管理（管理员）
        ├── admin-edit/                      # 编辑用户
        ├── footprint/                       # 我的足迹
        ├── works/                           # 我的作品
        ├── downloads/                       # 已下载课程
        ├── likes/                           # 我的点赞
        ├── help/                            # 帮助与反馈
        ├── support/                         # 客服中心
        ├── settings/                        # 设置
        ├── global-search/                   # 全局搜索
        └── images/                          # 图片资源（icon/封面/结构/工具/木料等）
```

---

## 6. 启动顺序与流程（**重点**）

> 团队成员第一次接手项目时，按这个顺序操作。

### 第一步：启动 MySQL 8.0（3307 端口）

1. 打开 `services.msc`
2. 找到 `MySQL80` 服务
3. 右键 → 启动（如果状态不是 Running）
4. **不要开机自启动**（与 MySQL 5.5 保持一致的"手动"模式）

### 第二步：初始化数据库（一键脚本 ⭐）

> 6/12 整合后，**只用一个 SQL 脚本**就能建好所有 17 张表 + 29 条种子数据。
> 旧的 `init_database.sql` / `schema_mysql8.sql` / `seed_products.sql` / `migrations/` 已被本脚本**完全取代**，无需再单独执行。

#### DBeaver 方式（推荐）

1. DBeaver 连接 `localhost:3307`（账号 root / 12345，驱动属性加 `allowPublicKeyRetrieval=true&useSSL=false`）
2. 文件 → 打开 File → 选 `ljx_backend/sql/schema_mysql8_full.sql`
3. **Ctrl+A 全选 → Ctrl+Enter 执行**
4. 脚本末尾会自动 `SELECT COUNT(*)` 和 `SHOW TABLES`，应看到：
   ```
   === 数据库初始化完成 ===
   categories=5  banners=4  products=15  sys_configs=5  articles=0  users=0
   === 表清单 ===
   (17 张表)
   ```

#### 命令行方式

```powershell
mysql -uroot -p12345 -P3307 < ljx_backend\sql\schema_mysql8_full.sql
```

#### 脚本特性

- ✅ **可重跑**：开头 `DROP TABLE IF EXISTS` + `SET FOREIGN_KEY_CHECKS=0`，重复执行不会出错
- ✅ **建库 + 建表 + 种子数据** 一步到位
- ✅ **17 张表**（14 原项目 + 2 商城 + 1 反馈）+ `user.preferences` JSON 列 + `footprint.snapshot_*` 3 列
- ✅ **种子数据**：5 分类 + 4 轮播图 + 5 系统配置 + 15 商品 = 29 条
- ✅ **MySQL 8.0 规范**：`utf8mb4` / `InnoDB` / `uk_`/`idx_`/`ft_` 索引前缀 / JSON 类型 / FULLTEXT 索引

#### 验证

```sql
SHOW TABLES;  -- 应看到 17 张表
SELECT COUNT(*) FROM product;  -- 15 件商品
SELECT COUNT(*) FROM sys_config;  -- 5 行系统配置
```

### 第三步：启动后端（IDEA）

1. 用 IDEA 打开 `ljx_backend` 目录
2. 检查 JDK：右下角状态栏 → Project SDK = **JDK 1.8**（不是 JRE）
3. 启用 Lombok：`Settings → Build, Execution, Deployment → Compiler → Annotation Processors` 勾选 `Enable annotation processing`
4. 重新加载 Maven：右侧 Maven 面板 → 🔄 → 右键 `pom.xml` → Maven → Reload Project
5. 找到 `src/main/java/com/sunmao/ljx/LjxPlatformApplication.java` → 点击运行 ▶
6. 看到 `Tomcat started on port(s): 8081` 和 `Started LjxPlatformApplication in X.XXX seconds` 表示成功

**健康检查**：
```bash
# 这是 POST 接口，浏览器 GET 会返回 500 但能证明服务启动成功
curl -X POST "http://localhost:8081/api/user/login?account=test&password=123456"
```

### 第四步：启动小程序（微信开发者工具）

1. 打开微信开发者工具
2. 导入项目 → 目录选 `ljx_extracted/ljx` → AppID 自动填入 `wxb999f19c2210b1a4`
3. 等待编译完成
4. 检查 `app.js` 中的 `baseUrl` 指向 `http://localhost:8081`（默认就是）
5. 点击"编译"按钮（Ctrl+B / Cmd+B）
6. 模拟器中应看到 4 个底部 Tab：首页 / 分类 / 商城 / 我的

### 第五步：注册账号并测试

1. 切到"我的" Tab → 点击"点击登录"
2. 点击"注册账号" → 填写：
   - 账号：`13812345678`（手机号，**必须 ≥ 4 位**）
   - 密码：`123456`（**必须 ≥ 6 位**）
   - 昵称：任意
3. 注册成功后自动跳回"我的" Tab，看到昵称 + 8 个菜单入口

> 📌 也可以使用测试账号（仅前端有效，不写入数据库）：账号 `test` / 密码 `123456`

### 第六步：设置管理员（演示用）

```sql
-- 在 DBeaver 中执行（user_id 替换为你的实际 ID）
UPDATE user SET user_type = 2 WHERE user_id = 1;
```

重新登录后，"我的" Tab 会多出"用户管理"入口。

---

## 7. 演示账号与测试场景

### 7.1 演示账号

| 类型 | 账号 | 密码 | 说明 |
|---|---|---|---|
| 测试账号（前端假登录） | `test` | `123456` | 不走后端，仅 `wx.setStorageSync` 存到本地 |
| 普通用户 | `13812345678` | `123456` | 注册后自动获得，user_type=0 |
| 管理员 | （自己注册后手动改） | 123456 | 注册后 `UPDATE user SET user_type=2` |

### 7.2 推荐演示路径

按这个路径走能展示全部核心功能：

1. **首页** → 看轮播图 + 热门文章
2. **分类** → 选"大师" → 点击"楔钉榫" → 弹窗 → "一键跳转商城"
3. **商城** → 切到"家具" → 点击"明式圈椅" → "立即购买" → 自动跳到"我的订单"
4. **我的订单** → 在"待支付"里看刚才下的订单 → 点"取消订单"
5. **我的** → 8 个菜单逐一点击 → 重点演示"AI 导师"和"用户管理"
6. **管理员功能**（如已设置）→ 用户管理 → 搜索/编辑/删除用户

---

## 8. 数据库设计

### 8.1 表清单（共 **17 张表**）

| # | 表名 | 用途 | 来源 |
|---|---|---|---|
| 1 | `user` | 用户 | 原项目 |
| 2 | `category` | 内容分类 | 原项目 |
| 3 | `article` | 内容文章 | 原项目 |
| 4 | `post` | 动态帖子 | 原项目 |
| 5 | `like_record` | 点赞记录 | 原项目 |
| 6 | `comment` | 评论 | 原项目 |
| 7 | `collect_record` | 收藏记录 | 原项目 |
| 8 | `follow` | 关注关系 | 原项目 |
| 9 | `footprint` | 浏览足迹 | 原项目 |
| 10 | `course` | 教程课程 | 原项目 |
| 11 | `course_download` | 课程下载记录 | 原项目 |
| 12 | `user_work` | 用户作品 | 原项目 |
| 13 | `banner` | 轮播图 | 原项目 |
| 14 | `sys_config` | 系统配置 | 原项目 |
| 15 | `feedback` | **新增** 用户反馈 + 客服咨询 | 6/10 |
| 16 | `product` | **新增** 商城商品 | 6/9 |
| 17 | `product_order` | **新增** 商城订单 | 6/9 |

**统计**：原项目 14 张 + 6/9 新增 2 张（product、product_order）+ 6/10 新增 1 张（feedback）= **17 张**

> 📌 **表结构扩展**（修改现有表，不算新表）：
> - `user.preferences` JSON 列（6/10，存用户偏好）
> - `footprint.snapshot_title / snapshot_cover / snapshot_author` 三列（6/10，浏览快照） |

### 8.2 关键表结构

#### 8.2.1 `feedback`（6/10 新增）

```sql
CREATE TABLE feedback (
  feedback_id INT NOT NULL AUTO_INCREMENT,
  user_id INT DEFAULT NULL,                  -- 未登录可空
  fb_type TINYINT NOT NULL DEFAULT 1,        -- 1功能建议 2联系客服 3举报 4bug 5商务
  content TEXT NOT NULL,
  contact VARCHAR(100) DEFAULT NULL,
  device VARCHAR(255) DEFAULT NULL,          -- 存 User-Agent
  status TINYINT NOT NULL DEFAULT 0,          -- 0未处理 1已查看 2已回复 3已关闭
  reply TEXT DEFAULT NULL,
  reply_time DATETIME DEFAULT NULL,
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (feedback_id),
  KEY idx_fb_user (user_id),
  KEY idx_fb_type (fb_type),
  KEY idx_fb_status (status),
  KEY idx_fb_create (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

#### 8.2.2 `product`（6/9 新增）

```sql
CREATE TABLE product (
  product_id    INT AUTO_INCREMENT PRIMARY KEY,
  product_name  VARCHAR(255) NOT NULL,
  category_id   INT DEFAULT 1,                 -- 1家具 2木料 3工艺品 4工具 5课程
  price         DECIMAL(10,2) DEFAULT 0,
  cover_image   VARCHAR(500),
  description   TEXT,
  stock         INT DEFAULT 0,
  status        TINYINT DEFAULT 1,             -- 1上架 0下架
  create_time   DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

#### 8.2.3 `product_order`（6/9 新增）

```sql
CREATE TABLE product_order (
  order_id      INT AUTO_INCREMENT PRIMARY KEY,
  product_id    INT NOT NULL,
  product_name  VARCHAR(255),
  user_id       INT NOT NULL,
  quantity      INT DEFAULT 1,
  total_price   DECIMAL(10,2),
  status        TINYINT DEFAULT 0,             -- 0待支付 1已支付 2已发货 3已完成 4已取消
  create_time   DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

#### 8.2.4 `user`（扩展列）

```sql
ALTER TABLE user ADD COLUMN preferences JSON DEFAULT NULL;
-- 存 {"notify": true, "darkMode": false, "fontSize": "标准", "language": "zh-CN"}
```

#### 8.2.5 `footprint`（扩展列）

```sql
ALTER TABLE footprint ADD COLUMN snapshot_title VARCHAR(200);
ALTER TABLE footprint ADD COLUMN snapshot_cover VARCHAR(500);
ALTER TABLE footprint ADD COLUMN snapshot_author VARCHAR(100);
```

### 8.3 表设计原则

- 所有主键 `AUTO_INCREMENT` 自增整数
- 微信 openid、手机号、邮箱建立 UNIQUE 索引
- 外键关联字段（如 `category_id`、`user_id`）建立普通索引
- 状态字段、排序字段、创建时间建立索引
- 文章标题建立 FULLTEXT 全文索引（用于搜索）
- **实体是数据载体**（不是独立的一层），Controller/Service/Mapper 各层都使用 Entity 对象传递数据

> ⚠️ 阿里 Java 手册规约：数据对象应命名为 `xxxDO`、Controller 返回应使用 `xxxVO`、Service 层间传递应使用 `xxxDTO`。本项目为微信小程序中小型项目，**简化分层**：直接使用 `Entity` 命名并在 Controller 层用 `Map<String, Object>` 过滤敏感字段。这与阿里规约略有差异，是有意为之的简化。详见 `前后端模块对应解析.md` 文档说明。

---

## 9. REST API 全览（语义化命名）

### 9.1 用户与认证

| URL | Method | 说明 |
|---|---|---|
| `/api/user/login` | POST | 账号密码登录（account+password） |
| `/api/user/register` | POST | 注册（account+password+nickname） |
| `/api/user/info/{id}` | GET | 获取用户信息 |
| `/api/user/update` | POST | 更新用户信息 |
| `/api/user/preferences/{userId}` | GET | 读偏好 |
| `/api/user/preferences/{userId}` | PUT | 写偏好 |

### 9.2 内容与分类

| URL | Method | 说明 |
|---|---|---|
| `/api/banner/list` | GET | 首页轮播图 |
| `/api/category/list` | GET | 全部分类 |
| `/api/article/hot` | GET | 热门文章 |
| `/api/article/category/{id}` | GET | 按分类查文章 |
| `/api/article/{id}` | GET | 文章详情 |
| `/api/article/{id}/like` | POST | 切换点赞 |
| `/api/article/{id}/collect` | POST | 切换收藏 |

### 9.3 社交与互动

| URL | Method | 说明 |
|---|---|---|
| `/api/post/list` | GET | 动态列表（**已废弃，无前端使用**） |
| `/api/post/publish` | POST | 发帖 |
| `/api/follow/count/{id}` | GET | 关注/粉丝数 |
| `/api/follow/toggle` | POST | 切换关注 |
| `/api/footprint/user/{userId}` | GET | 我的足迹 |
| `/api/footprint/add` | POST | 添加足迹（带 snapshot） |

### 9.4 教程与作品

| URL | Method | 说明 |
|---|---|---|
| `/api/course/list` | GET | 课程列表 |
| `/api/course/downloads/{userId}` | GET | 我的下载 |
| `/api/work/user/{userId}` | GET | 我的作品 |
| `/api/work/publish` | POST | 发布作品 |

### 9.5 商城（6/9 新增）

| URL | Method | 说明 |
|---|---|---|
| `/api/product/list` | GET | 商品列表 |
| `/api/product/detail/{id}` | GET | 商品详情 |
| `/api/product/search?keyword=` | GET | 搜索商品 |
| `/api/product/order/create` | POST | 创建订单 |
| `/api/product/order/my` | GET | 我的订单 |
| `/api/product/order/cancel` | POST | 取消订单（6/9 新增） |
| `/api/product/order/delete` | POST | 删除订单（6/10 新增，售后期校验） |
| `/api/admin/product/add` | POST | 上架商品（管理员） |
| `/api/admin/product/update` | POST | 编辑商品（管理员） |
| `/api/admin/product/delete` | POST | 下架商品（管理员） |

### 9.6 反馈与客服（6/10 新增）

| URL | Method | 说明 |
|---|---|---|
| `/api/feedback/submit` | POST | 提交反馈/咨询 |
| `/api/feedback/list` | GET | 反馈列表（管理） |

### 9.7 AI 与搜索（6/9 + 6/10 新增）

| URL | Method | 说明 |
|---|---|---|
| `/api/chat/query` | POST | AI 聊天（DeepSeek） |
| `/api/search/global?keyword=&limit=` | GET | 全局搜索（5 表 UNION ALL） |
| `/api/like/my/{userId}` | GET | 我的点赞列表 |

### 9.8 管理员（6/9 新增）

| URL | Method | 说明 |
|---|---|---|
| `/api/admin/user/list` | GET | 用户列表（需 user_type=2） |
| `/api/admin/user/search?keyword=` | GET | 搜索用户 |
| `/api/admin/user/add` | POST | 新增用户 |
| `/api/admin/user/update` | POST | 修改用户 |
| `/api/admin/user/delete` | POST | 删除用户 |

---

## 10. 遇到的问题与解决方案（**重点**）

> 全部来自 `截止至6月11日关于榫卯项目的全对话.txt`。每条问题都按**真实问题 → 原因 → 解决**三段式记录，方便答辩时讲解。

### 10.1 后端问题

#### 🔴 问题 1：启动报 `userMapper` 找不到（6/11 当天）

**对话原文**：
> "我将这个项目前后端关机重启后，现在打开了 MySQL 数据库，但是想重新启动后端时提示报错如图，我执行了 clean 和 compile 再尝试运行后端还是如图所示"

**根因**：`UserServiceImpl.java:119/124` 用了 `userMapper.selectPreferences(...)`，但 `ServiceImpl<UserMapper, User>` 继承 MyBatis-Plus 内部 mapper 暴露为 `baseMapper` 字段，不是 `userMapper`。

**修复**：`userMapper` → `baseMapper`（2 处）

**类比**：MyBatis-Plus 约定 —— 继承 `ServiceImpl<M, T>` 必须用 `baseMapper` 访问 mapper。本项目所有 Service 实现类都是这个用法。

**为什么之前能跑现在不能**（6/11 当天下午的提问）：
> "为什么我关机重启电脑前这个后端能跑通，现在不行了？"

**答**：之前能跑 = 之前用的是旧的 `.class` 字节码（Maven 检测到 `.java` 比 `.class` 旧时不会自动重编）；现在不能 = 重启后第一次启动触发了全量编译，遇到 `userMapper` 错误直接失败。**不是重启导致的故障，而是新加的代码本身是坏的，重启只是把旧 `.class` 掩盖的 bug 暴露了**。

#### 🟡 问题 2：`Unsupported character encoding 'utf8mb4'`

**对话原文**：
> "2026-06-09 15:33:30.845 ... init datasource error, url: jdbc:mysql://localhost:3307/ljx_platform?characterEncoding=utf8mb4 ... java.sql.SQLException: Unsupported character encoding 'utf8mb4'"

**根因**：JDBC 驱动不认识 `utf8mb4`（那是 MySQL 内部的字符集名），必须用 `UTF-8`。数据库层面依然是 `utf8mb4`，JDBC 驱动会自动映射。

**修复**：`characterEncoding=utf8mb4` → `characterEncoding=UTF-8`

#### 🟡 问题 3：`Common package does not exist`（6/9 15:28）

**对话原文**：
> "我在第三步的双击 compile 的时候它定位到很多方法不存在，然后我运行 LjxPlatformApplication 提示 ... 程序包 com.sunmao.ljx.common 不存在"

**根因**：IDEA 的 Maven 依赖没下载好或缓存问题。

**修复步骤**：
1. 确认 JDK 1.8（不是 JRE）
2. Maven → 重新加载项目（Reload Project）
3. 启用 Lombok 注解处理器
4. 必要时 Invalidate Caches
5. 重新 compile

#### 🟡 问题 4：用户表无 account 字段（6/9 15:09）

**对话原文**：
> "我在设置管理员账号那一步输入了那一句语句，把我的用户 id 设置为 10001 ... 为什么在 user 表里查不到 id 信息"

**根因**：`user_id` 是自增主键，第一个用户通常是 `1` 而不是 `10001`。此外 `account` 字段在 user 表中不存在（被后端解析为 `phone` 或 `email`）。

**修复**：用 `SELECT user_id, nickname, phone, email FROM user;` 查真实 ID，根据结果中的 `phone` 或 `email` 设置。

#### 🟡 问题 5：user 表为空（6/9 15:11）

**对话原文**：
> "select 后发现 user 表是空的"

**根因**：用户数据实际存储在 MySQL 5.5（3306 端口）的旧库，而新后端配置改到了 3307 端口的 MySQL 8.0。

**修复**：在 3307 端口的 MySQL 8.0 中重新注册用户（前端会写到新库）。或迁移旧数据。

#### 🟡 问题 6：`token.replace is not a function`（5/27 16:41）

**对话原文**：
> "我使用这个用户登录时提示报错，console 的信息显示如下 ... TypeError: token.replace is not a function"

**根因**：后端 `/api/user/login` 返回 `Map<String, Object>`（含 userId、nickname、avatar、studyHours），前端 `login.js` 误当成字符串处理，调用 `.replace()` 失败。

**修复**：
```js
// 修改前
const token = res.data.data;
const userId = parseInt(token.replace('jwt_token_', ''));
// 修改后
const userData = res.data.data;
const userId = userData.userId;
```

### 10.2 前端问题

#### 🟡 问题 7：登录页 placeholder 截断（6/10 14:58）

**对话原文**：
> "我是 26 年 6 月 10 日 14 点 58 分，我重新打开前端小程序，发现我的登录和注册界面中的提示文字出现了问题，如图所示文字只能有一半能够正确显示"

**根因**：`<input>` 是微信原生组件，外层 wxss 的 `line-height` 在 iOS 真机被系统忽略；`padding: 34rpx` 上下加上 30rpx 字号，导致 placeholder 文字被从中间切掉一半。

**修复**：拆 `input-wrapper` 96rpx 容器 + 内层 `<input>` 用 `transparent + height:96rpx + line-height:96rpx`，让文字完美垂直居中。

> ⚠️ **风险声明**：本机 PowerShell 未识别 git 命令，无法验证"昨天没改过"这个陈述。能确认的是本会话内 6/10 之前没动过这两个文件，但用户是否动过、工具是否自动更新、是否缓存 都无法核实。详见 `docs/2026-06-10-login-placeholder-bugfix.md` 第九节。

#### 🟡 问题 8：Edit 工具"部分写入"（6/10 16:40）

**对话原文**：
> "我已经热重载了但是点击那行字依旧没有反应，所做的更改完全没有生效 ... 但是我发现退出登录后在未登录下方的'点击登陆'四个小字是可以正常点击跳转的"

**根因**：上一轮看似一次性成功执行了所有 Edit，但实际只写入了部分修改（wxss 写入了，wxml 和 data 没写入）。点击无反应是因为 `catchtap` 事件没注册。

**修复**：重新 Read 文件实际状态，定位缺失的 Edit，重新执行。

**经验**：以后多文件多步骤改动，必须以 Read 工具的最终回读为准判断是否真的写入；不能只靠"Edit 返回 success"判断。

#### 🟡 问题 9："点击登录"失效（6/10 16:47）

**对话原文**：
> "现在我发现退出登录后点击'点击登陆'四个字又跳转不到登录界面了"

**根因**：上一轮让 `scrollToLogout` 在未登录时 return，但 `catchtap` 又阻止冒泡，导致未登录时点击无任何反应。

**修复**：把"判断 + 跳转"集中在 `handleSubtitleTap` 一处，已登录 → 滚动 + 脉冲动画；未登录 → `wx.navigateTo('/pages/login/login')`。外层 `.profile-content` 的 `bindtap="goToLogin"` 仍保留作为兜底。

### 10.3 UI 问题

#### 🟡 问题 10：UI 不符合当代设计潮流（6/9 15:59）

**对话原文**：
> "我认为现在这个小程序可能在 ui 设计方面不符合当代的设计潮流，这会使得用户体验感不佳"

**解决方案**：创建「榫卯匠心 Sunmao Artisan」自定义设计系统：

| 色彩角色 | 色值 | 命名 | 用途 |
|---|---|---|---|
| 主色 | `#3E2723` | 紫檀 | 导航栏、按钮、标题 |
| 辅色 | `#D4A45A` | 金丝楠 | 强调、标签、价格 |
| 背景 | `#F5F0E8` | 宣纸 | 全局底色 |
| 文字 | `#1A1A1A` | 墨色 | 正文 |
| 高亮 | `#C4493D` | 朱砂 | 重要提醒、退出按钮 |

20 个文件重写：3 个全局（app.wxss / app.json / seed_products.sql）+ 16 个页面 WXSS+WXML。

#### 🟡 问题 11：工具商品图片无法显示（6/9 17:22）

**对话原文**：
> "请重新搜索 ...\pages\images\ 这个路径，查找对应相关的三张 png 格式的照片，然后重新修改代码，使得这三种图片能正常在小程序中的商城 tab 下的二级 tab 工具中正常显示"

**根因**：
- 前端 `shop.js` 的 `DEMO_TOOLS` 三个商品图片字段都为空
- 后端 `seed_products.sql` 写的是 `工具.png/工具-2.png/工具-3.png`（实际不存在）

**修复**：
- 前端：补 `../images/tool-set.png` / `tool-plane.png` / `tool-jig.png`
- 后端：同步 `cover_image` 字段

#### 🟡 问题 12：百度下载 jpg 实为 webp（6/9 17:43）

**对话原文**（用户原话，一字未删）：
> "实际上我原本是从百度中下载的图片，下载的图片我将图片命名为中文名图片，然后将格式改为 jpg 保存，但是在百度网页使用图片另存为的方式下载的图片只有文件名是 jpg 的，虽然文件后缀显示也是 jpg，但是文件的文件头实际为 webp，所有我为了解决这个问题，使用了截图软件将图片截图为 png 格式，然后再插入 shop.js，然后再 ctrl+b 热重载结果发现图片仍然没有显示，最后我在 dbeaver 中使用了第二步方式 A 同款 sql 语句在数据库中运行脚本后再次在小程序开发工具中 ctrl+b 热重载才使得图片正常显示的"

**核心经验**：
- 百度"另存为" ≠ 真 jpg（实际是 webp）
- 中文文件名是隐藏坑
- 前端降级 ≠ 后端免维护
- Ctrl+B 不会重置数据库

详见 `docs/2026-06-09-shop-tool-images-fix.md` 第八章。

#### 🟡 问题 13：动态 Tab 是否应保留？（6/9 11:30）

**对话原文**：
> "我注意到健身房项目的数据库设计中有健身房课程信息之类的商业化信息和表，但是我的榫卯微信小程序项目中没有商业化的内容，现在我想为我的榫卯小程序也添加商业化内容，请问应该怎么修改进？在什么板块改进？我的小程序现在底部的四个 tab 功能上是否重复？有无将哪个 tab 替换为商城的可能？"

**决策**：替换"动态"为"商城"。理由：
- 动态页 `place.js` 数据全部硬编码，没有后端接口支持
- 首页和分类内容重叠
- 商城有天然商业逻辑：看教程 → 买木材/工具 → 欣赏作品 → 下单购买
- 新 TabBar：首页 → 分类 → 商城 → 我的

### 10.4 数据库问题

#### 🟡 问题 14：MySQL 5.5 vs 8.0 端口冲突（5/28 + 6/9）

**对话原文**：
> "我需要将哪些东西改为 3307 端口以避免与我原来的 3306 端口的数据库冲突"

**解决方案**：
| 地方 | 原值 | 改为 |
|---|---|---|
| MySQL Installer 端口 | 3306 | 3307 |
| 后端 `application.yml` | 3306 | 3307 |
| 命令行连接 | 默认 3306 | 加 `-P 3307` |
| DBeaver JDBC URL | 默认 | 加 `&allowPublicKeyRetrieval=true&useSSL=false` |

#### 🟡 问题 15：DBeaver 连接 3307 失败（6/9 10:47）

**对话原文**：
> "我现在用 dbeaver 管理我的数据库，但是我为啥连接不上 3307 端口的 MySQL8，我已经通过 service.msc 查看其服务已经开启"

**根因**：MySQL 8.0 默认 `caching_sha2_password` 认证，DBeaver 默认不允许公钥检索。

**解决方案**：
- **方案 A**（推荐）：`ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '12345';`
- **方案 B**：DBeaver 驱动属性加 `allowPublicKeyRetrieval=true`

#### 🟡 问题 16：MySQL 5.5 vs 8.0 "本地系统"vs"网络服务"差异（6/9 10:38）

**对话原文**：
> "为什么这个新的 MySQL8 是网络服务，而旧的 MySQL5 是本地系统"

**解释**：
- MySQL 5.5 默认"本地系统账户"（Local System，权限大）
- MySQL 8.0 推荐"网络服务"（Network Service，最小权限原则）
- 对功能无影响，建议保持默认"网络服务"

#### 🟡 问题 17：建库后表不存在（6/9 11:06）

**对话原文**：
> "image_1.png ... Table 'ljx_platform.article' doesn't exist"

**根因**：只执行了建库语句和 INSERT，没执行 CREATE TABLE。

**修复**：在 DBeaver 中打开 `schema_mysql8.sql` 全选执行（含 CREATE TABLE）。

#### 🟡 问题 18：取消开机自启动（6/9 10:25）

**对话原文**：
> "我想让这个新添加的 MySQL8 不要开机自启动，就保持和我现在的数据库 MySQL5 一样需要我在 service.msc 手动找到 MySQL 服务手动开启，需要怎么做"

**修复**：安装时取消勾选 "Start the MySQL Server at System Startup"。

### 10.5 测试与工具问题

#### 🟡 问题 19：MySQL Installer 下载选错（5/28 11:14）

**对话原文**：
> "我选择方法一，在访问网站后结果如图。哪一个是我要下载的？"

**决策**：下载第二个（565.9M 完整离线版）而非 2.1M Web 安装版。

#### 🟡 问题 20：Git SSH 22 端口被墙（6/11）

**对话原文**：
> "我点 Add SSH key 后结果如图所示，但是我还没有输入 GitHub 密码确认，我现在该怎么做"

**根因**：国内网络封锁 GitHub 的 22 端口。

**解决方案**：在 `~/.ssh/config` 中配置：
```
Host github.com
    Hostname ssh.github.com
    Port 443
    User git
```

验证：`ssh -T git@github.com` → `Hi afuzzztrue! You've successfully authenticated`

#### 🟡 问题 21：测试模式账号不写入数据库（5/27 16:35）

**对话原文**：
> "你说你帮我创建的测试用户在数据库的 user 表，但是我查询了我的 MySQL 数据库中的 ljx_platform 库中的 user 表中并无任何数据"

**解释**：测试账号（test/123456）走前端 `wx.setStorageSync` 存到本地缓存，**不会发送任何请求到后端**。只有真正走 `/api/user/register` 注册的用户才会进数据库。

#### 🟡 问题 22：`user_type=2` 才能看到"用户管理"入口

**测试场景**：在 3307 端口 MySQL 8.0 中注册用户后，admin 设置 `user_type=2`，重启小程序登录，应看到"用户管理"入口。

### 10.6 数据流与架构问题

#### 🟡 问题 23：数据流写错（5/28 10:07）

**对话原文**：
> "你的数据流写错了吧，怎么 mapper 后面到 entity 的？"

**错误**：`Controller → Service → Mapper → Entity → MySQL`
**正确**：`Controller → Service → Mapper → MySQL`

**解释**：Entity 是数据载体，不是独立的一层。详见 `前后端模块对应解析.md` "特别说明"章节。

#### 🟡 问题 24：阿里 Java 手册与项目命名冲突（5/28 10:40）

**冲突**：
- 阿里规约：数据对象应命名为 `xxxDO`
- 项目实际：`User.java` / `Article.java` 等 `Entity` 命名
- 阿里规约：Controller 返回应使用 VO
- 项目实际：直接返回 Map 或 Entity

**最终决策**（用户原话）：
> "帮我在文档中注明吧"

**方案**：在文档开头添加"特别说明"章节，注明本项目为微信小程序后端采用简化分层架构（Controller→Service→Mapper→Entity），Controller 层通过 Map 手动封装响应数据已过滤敏感字段（如 password、openid）。如后续项目扩展，可按阿里规约添加 VO/DTO 分层。

---

## 11. 风险声明与已知问题

> 按阿里规约"信息存在冲突或无法溯源时明确指出风险，不给出误导性结论"的要求。

| # | 风险 | 严重度 | 详细说明 |
|---|---|---|---|
| 1 | **无 JWT/token 鉴权** | 🔴 高 | userId 走 URL/Body，**生产环境必须加权限拦截器**；当前 Authorization header 取 token 仅做占位 |
| 2 | **DeepSeek API Key 未配置** | 🔴 高 | `application.yml` 中是 `your-deepseek-api-key` 占位符，需用户自行去 https://platform.deepseek.com 注册获取 |
| 3 | **MD5 密码加密** | 🟡 中 | 项目原作者实现，非最佳安全实践但保持兼容 |
| 4 | **sysConfig Controller 不存在** | 🟡 中 | `support.js` 联系方式仍为静态，未从数据库动态化 |
| 5 | **like_record.targetType 扩展** | 🟡 中 | 原 schema 注释 1文章 2帖子，本计划扩展为 1~5。若历史数据用了其他枚举值，前端 type 路由会错位 |
| 6 | **DELETE 已下载课程接口未实现** | 🟢 低 | `downloads.js` 的删除仅前端过滤，未真正从 `course_download` 表删除 |
| 7 | **course.chapters / user_work.viewCount 字段不存在** | 🟢 低 | 前端暂时显示为 0，需补 DDL 或调整接口 |
| 8 | **app.clearLoginInfo() 未确认** | 🟡 中 | `settings.js` 调用但 `app.js` 是否提供该方法未校验 |
| 9 | **"我的"页面三处图片引用不存在** | 🟢 低 | `my.wxml:90/100/110` 引用 `structure-1.png/2.png/3.png` 不存在，任务范围外未修 |
| 10 | **图片 webp 伪装 jpg** | 🟢 低 | 用户已亲历，建议未来用 hex 头部校验文件类型 |
| 11 | **Edit 工具"部分写入"** | 🟡 中 | 多文件多步骤改动必须 Read 回读校验 |
| 12 | **Git SSH 22 端口被墙** | 🟢 低 | 已绕过（443 端口），仅限 push 时使用 |
| 13 | **place 页面残留** | 🟢 低 | 已删除 `pages/place/` 4 个文件，但 `app.json` 仍引用 `place-0.png/place-1.png` 作为商城 Tab 的 icon（视觉延续） |
| 14 | **登录页 placeholder 截断原因不明** | 🟢 低 | 6 种假设（基础库升级/工具缓存/设备差异/字体降级/用户未察觉的改动/昨日"正常"本就是误判），无法定因。详见 `docs/2026-06-10-login-placeholder-bugfix.md` 第九节 |

---

## 12. 待办事项

### 12.1 当前未实现的功能

- [ ] 真实微信支付对接（`/api/product/order/pay` 接口 + `wx.requestPayment`）
- [ ] 真实用户头像上传（当前使用本地 `kk.png` 演示）
- [ ] Web 管理后台（健身房项目的 A+B 方案中 B 部分）
- [ ] SysConfig Controller（动态加载联系方式）
- [ ] DELETE 已下载课程接口
- [ ] 用户管理页面管理员鉴权（当前仅靠前端 `userType === 2` 隐藏入口，后端无拦截）
- [ ] JWT 鉴权中间件
- [ ] MD5 改为 BCrypt 加密
- [ ] "我的"页面三处缺失图片（structure-1/2/3.png）

### 12.2 文档待办

- [x] 后端代码解析（AI vs 作者）
- [x] 前后端模块对应解析
- [x] 工具图片 webp 教训
- [x] 登录页 placeholder bug 修复
- [x] 8 tab 后端对接实施计划
- [x] 10 阶段改造实施计划
- [x] **本文档（项目交付说明）**
- [x] **整合 SQL 部署脚本**（`schema_mysql8_full.sql` v1.0）

---

## 13. 文档索引

| 文档 | 路径 | 用途 |
|---|---|---|
| **项目交付说明** | `README.md` | ⭐ 本文 - 给团队成员/答辩观众的全景文档 |
| 后端代码解析 | `ljx_backend/后端代码解析.md` | 各文件 AI vs 作者占比 |
| 前后端模块对应解析 | `ljx_backend/前后端模块对应解析.md` | 前端页面 ↔ 后端 Controller |
| 数据库设计思路 | `ljx_backend/数据库设计思路.txt` | 数据库设计原文档 |
| ⭐ **整合部署脚本** | `ljx_backend/sql/schema_mysql8_full.sql` | v1.0 一键部署（17 张表 + 29 条种子，可重跑）|
| 工具图片修复 | `docs/2026-06-09-shop-tool-images-fix.md` | 商城工具 Tab webp 教训 |
| 登录页 bug 修复 | `docs/2026-06-10-login-placeholder-bugfix.md` | placeholder 截断问题 + 6 种无法定因假设 |
| 10 阶段改造计划 | `docs/superpowers/plans/2026-06-09-sunmao-renovation.md` | 管理员/AI/商城 3 大模块改造 |
| 8 tab 后端对接计划 | `docs/superpowers/plans/2026-06-10-my-tabs-backend-integration.md` | "我的" 8 菜单 + 顶栏 2 入口对接 |

---

## 附录 A：答辩速查 Q&A

**Q1：这个项目最难的部分是什么？**
A：UI 全面现代化（榫卯匠心主题），需要重写 20 个文件但保持 JS 逻辑不变。

**Q2：后端有没有用 Spring Security？**
A：没有。用了 MyBatis-Plus + Druid 连接池。鉴权走 URL/Body 传 userId，是已知风险（见 §11 风险 1）。

**Q3：数据库用了什么版本？**
A：MySQL 8.0.46（3307 端口）。旧 MySQL 5.5（3306 端口）已废弃。

**Q4：AI 聊天是接入什么模型？**
A：DeepSeek API。`application.yml` 中配置 `https://api.deepseek.com/v1/chat/completions`。

**Q5：6/11 启动报错是什么原因？**
A：MyBatis-Plus 约定。继承 `ServiceImpl<M, T>` 必须用 `baseMapper` 访问 mapper。我之前误用了 `userMapper` 字段名。重启只是把旧 `.class` 掩盖的 bug 暴露了。

**Q6：项目用了几张数据库表？**
A：**17 张**。14 张原项目 + 3 张新增（feedback / product / product_order）。另有 `user.preferences` 和 `footprint.snapshot_*` 是修改现有表的列，不算新表。

**Q7：底部 Tab 怎么从 4 个变 4 个的？**
A：原来的 4 个是"首页/分类/动态/我的"，把"动态"（半成品、无后端）替换为"商城"。最终的 4 个是"首页/分类/商城/我的"。

**Q8：测试账号是什么？**
A：账号 `test` / 密码 `123456`，但**这是前端假登录**，数据存在 `wx.setStorageSync` 本地缓存，不进数据库。

---

**文档完成日期**：2026-06-11
**整理人**：钟景胜（借助 TRAE AI 助手）
**总字数**：约 15000 字
