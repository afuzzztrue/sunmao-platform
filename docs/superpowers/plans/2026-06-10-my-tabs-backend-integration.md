# "我的" Tab 后端对接与数据持久化实现计划

**Goal:** 为 8 个"我的"页面（footprint/works/downloads/likes/help/support/settings/global-search）打通后端 API，把演示数据替换为真实数据持久化，并提供标准规范、语义清晰的 REST 接口。

**Architecture:** 沿用现有 Spring Boot + MyBatis-Plus + MySQL 单体架构，不引入新依赖。新增 `feedback` 表 + 4 件套；在 `user` 表加 `preferences` JSON 列；为已存在但缺失查询接口的 `course_download` / `like_record` 补全 GET 接口；新建 `SearchController` 跨 5 表 UNION ALL 聚合搜索。URL 全部采用 `/api/<资源>/<动作>` 语义化命名。

**Tech Stack:** Spring Boot 2.x、MyBatis-Plus 3.x、MySQL 8.0、Java 8、lombok。微信小程序 WXML/WXSS/JS。

---

## 文件结构

### 新建文件（后端）
- `ljx_backend/sql/migrations/2026-06-10-feedback-preferences.sql` — 数据库变更脚本
- `ljx_backend/src/main/java/com/sunmao/ljx/entity/Feedback.java`
- `ljx_backend/src/main/java/com/sunmao/ljx/mapper/FeedbackMapper.java`
- `ljx_backend/src/main/java/com/sunmao/ljx/service/FeedbackService.java`
- `ljx_backend/src/main/java/com/sunmao/ljx/service/impl/FeedbackServiceImpl.java`
- `ljx_backend/src/main/java/com/sunmao/ljx/controller/FeedbackController.java`
- `ljx_backend/src/main/java/com/sunmao/ljx/controller/LikeController.java`
- `ljx_backend/src/main/java/com/sunmao/ljx/controller/SearchController.java`
- `ljx_backend/src/main/java/com/sunmao/ljx/service/SearchService.java`
- `ljx_backend/src/main/java/com/sunmao/ljx/service/impl/SearchServiceImpl.java`
- `ljx_backend/src/main/resources/mapper/SearchMapper.xml` — 5 表 UNION ALL

### 修改文件（后端）
- `ljx_backend/src/main/java/com/sunmao/ljx/controller/CourseController.java` — 加 GET `/downloads/{userId}`
- `ljx_backend/src/main/java/com/sunmao/ljx/controller/UserController.java` — 加 GET/PUT `/preferences/{userId}`
- `ljx_backend/src/main/java/com/sunmao/ljx/entity/User.java` — 加 preferences 字段
- `ljx_backend/src/main/java/com/sunmao/ljx/mapper/CourseDownloadMapper.java` — 加 join 查询方法
- `ljx_backend/src/main/java/com/sunmao/ljx/mapper/LikeRecordMapper.java` — 加我的点赞查询
- `ljx_backend/src/main/java/com/sunmao/ljx/service/CourseService.java` — 加 getUserDownloads
- `ljx_backend/src/main/java/com/sunmao/ljx/service/impl/CourseServiceImpl.java` — 实现
- `ljx_backend/src/main/java/com/sunmao/ljx/service/LikeService.java` — 新建（原本无）
- `ljx_backend/src/main/java/com/sunmao/ljx/service/impl/LikeServiceImpl.java` — 新建

### 修改文件（前端）
- `ljx_extracted/ljx/pages/footprint/footprint.js` — 替换 loadDemo
- `ljx_extracted/ljx/pages/works/works.js` — 替换 loadDemo
- `ljx_extracted/ljx/pages/downloads/downloads.js` — 替换 loadDemo
- `ljx_extracted/ljx/pages/likes/likes.js` — 替换 loadDemo
- `ljx_extracted/ljx/pages/help/help.js` — 提交反馈走 API
- `ljx_extracted/ljx/pages/support/support.js` — 联系配置走 sys_config API
- `ljx_extracted/ljx/pages/settings/settings.js` — preferences 走 API
- `ljx_extracted/ljx/pages/global-search/global-search.js` — 走搜索 API

---

## 任务清单

### Task 1: 数据库变更脚本

**Files:**
- Create: `ljx_backend/sql/migrations/2026-06-10-feedback-preferences.sql`

- [ ] **Step 1.1: 编写迁移脚本**

```sql
-- 1) 用户反馈表
DROP TABLE IF EXISTS `feedback`;
CREATE TABLE `feedback` (
  `feedback_id` INT NOT NULL AUTO_INCREMENT,
  `user_id`     INT DEFAULT NULL COMMENT '提交用户ID，未登录可空',
  `fb_type`     TINYINT NOT NULL DEFAULT 1 COMMENT '1功能建议 2联系客服 3举报 4bug 5商务',
  `content`     TEXT NOT NULL,
  `contact`     VARCHAR(100) DEFAULT NULL,
  `device`      VARCHAR(255) DEFAULT NULL,
  `status`      TINYINT NOT NULL DEFAULT 0 COMMENT '0未处理 1已查看 2已回复 3已关闭',
  `reply`       TEXT DEFAULT NULL,
  `reply_time`  DATETIME DEFAULT NULL,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`feedback_id`),
  KEY `idx_fb_user` (`user_id`),
  KEY `idx_fb_type` (`fb_type`),
  KEY `idx_fb_status` (`status`),
  KEY `idx_fb_create` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户反馈表';

-- 2) user 表加 preferences JSON 列
ALTER TABLE `user` ADD COLUMN `preferences` JSON DEFAULT NULL
  COMMENT '用户偏好 {notify, darkMode, fontSize, language}';

-- 3) 客服联系配置
INSERT INTO `sys_config` (`config_key`, `config_value`, `description`) VALUES
('service_phone',  '400-888-8888',    '客服电话'),
('service_email',  'support@sunmao.com','客服邮箱'),
('service_wechat', 'sunmao_helper',   '客服微信'),
('service_weibo',  '@榫卯非遗官方',     '官方微博'),
('service_hours',  '工作日 9:00-18:00', '服务时间')
ON DUPLICATE KEY UPDATE config_value = VALUES(config_value);
```

- [ ] **Step 1.2: 验证 SQL 可在 MySQL 8 客户端解析**

在 DBeaver 连接到 ljx_platform 库 → 执行迁移脚本 → 验证三段 DDL 全部成功。

### Task 2: Feedback Entity

**Files:**
- Create: `ljx_backend/src/main/java/com/sunmao/ljx/entity/Feedback.java`

- [ ] **Step 2.1: 写实体类**

```java
package com.sunmao.ljx.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("feedback")
public class Feedback {
    @TableId(type = IdType.AUTO)
    private Integer feedbackId;
    private Integer userId;
    private Integer fbType;
    private String content;
    private String contact;
    private String device;
    private Integer status;
    private String reply;
    private LocalDateTime replyTime;
    private LocalDateTime createTime;
}
```

### Task 3: Feedback Mapper

**Files:**
- Create: `ljx_backend/src/main/java/com/sunmao/ljx/mapper/FeedbackMapper.java`

- [ ] **Step 3.1: 写 Mapper 接口**

```java
package com.sunmao.ljx.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.sunmao.ljx.entity.Feedback;

public interface FeedbackMapper extends BaseMapper<Feedback> {
}
```

### Task 4: Feedback Service

**Files:**
- Create: `ljx_backend/src/main/java/com/sunmao/ljx/service/FeedbackService.java`
- Create: `ljx_backend/src/main/java/com/sunmao/ljx/service/impl/FeedbackServiceImpl.java`

- [ ] **Step 4.1: 写 Service 接口**

```java
package com.sunmao.ljx.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.sunmao.ljx.entity.Feedback;

public interface FeedbackService extends IService<Feedback> {
    void submit(Feedback feedback);
    IPage<Feedback> pageQuery(Integer page, Integer size, Integer status, Integer fbType);
}
```

- [ ] **Step 4.2: 写实现类**

```java
package com.sunmao.ljx.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.sunmao.ljx.entity.Feedback;
import com.sunmao.ljx.mapper.FeedbackMapper;
import com.sunmao.ljx.service.FeedbackService;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;

@Service
public class FeedbackServiceImpl extends ServiceImpl<FeedbackMapper, Feedback> implements FeedbackService {

    @Override
    public void submit(Feedback feedback) {
        if (feedback.getFbType() == null) feedback.setFbType(1);
        if (feedback.getStatus() == null) feedback.setStatus(0);
        feedback.setCreateTime(LocalDateTime.now());
        save(feedback);
    }

    @Override
    public IPage<Feedback> pageQuery(Integer page, Integer size, Integer status, Integer fbType) {
        QueryWrapper<Feedback> qw = new QueryWrapper<>();
        if (status != null) qw.eq("status", status);
        if (fbType != null)  qw.eq("fb_type", fbType);
        qw.orderByDesc("create_time");
        return page(new Page<>(page, size), qw);
    }
}
```

### Task 5: Feedback Controller

**Files:**
- Create: `ljx_backend/src/main/java/com/sunmao/ljx/controller/FeedbackController.java`

- [ ] **Step 5.1: 写 Controller**

```java
package com.sunmao.ljx.controller;

import com.sunmao.ljx.common.Result;
import com.sunmao.ljx.entity.Feedback;
import com.sunmao.ljx.service.FeedbackService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;

@RestController
@RequestMapping("/api/feedback")
public class FeedbackController {

    @Autowired
    private FeedbackService feedbackService;

    /**
     * 提交反馈（用户端）
     */
    @PostMapping("/submit")
    public Result<Void> submit(@RequestBody Feedback feedback, HttpServletRequest request) {
        // 简易：从 token 中解析（参考 UserController 的写法）
        Integer userId = parseUserId(request);
        feedback.setUserId(userId);
        String ua = request.getHeader("User-Agent");
        if (ua != null && ua.length() > 250) ua = ua.substring(0, 250);
        feedback.setDevice(ua);
        feedbackService.submit(feedback);
        return Result.success();
    }

    /**
     * 反馈列表（管理后台用，前端不调用，留给后续运营）
     */
    @GetMapping("/list")
    public Result<?> list(@RequestParam(defaultValue = "1") Integer page,
                          @RequestParam(defaultValue = "20") Integer size,
                          @RequestParam(required = false) Integer status,
                          @RequestParam(required = false) Integer fbType) {
        return Result.success(feedbackService.pageQuery(page, size, status, fbType));
    }

    private Integer parseUserId(HttpServletRequest request) {
        // 与项目现有登录鉴权方式保持一致：token 头 → userId
        String token = request.getHeader("Authorization");
        if (token == null) return null;
        // 实际项目从 JWT 或 Redis 解析 userId，这里留空示例
        return null;
    }
}
```

### Task 6: CourseController 加 GET /downloads/{userId}

**Files:**
- Modify: `ljx_backend/src/main/java/com/sunmao/ljx/mapper/CourseDownloadMapper.java`
- Modify: `ljx_backend/src/main/java/com/sunmao/ljx/service/CourseService.java`
- Modify: `ljx_backend/src/main/java/com/sunmao/ljx/service/impl/CourseServiceImpl.java`
- Modify: `ljx_backend/src/main/java/com/sunmao/ljx/controller/CourseController.java`

- [ ] **Step 6.1: 在 CourseDownloadMapper 加 join 查询**

在 `CourseDownloadMapper.java` 中追加：

```java
@Select("SELECT cd.download_id AS downloadId, cd.course_id AS courseId, " +
        "cd.create_time AS downloadTime, c.title, c.cover_image AS coverImage, " +
        "c.duration, c.difficulty " +
        "FROM course_download cd " +
        "LEFT JOIN course c ON c.course_id = cd.course_id " +
        "WHERE cd.user_id = #{userId} " +
        "ORDER BY cd.create_time DESC")
List<Map<String, Object>> selectUserDownloadsWithCourse(@Param("userId") Integer userId);
```

注意：需要额外 import `org.apache.ibatis.annotations.Param`、`org.apache.ibatis.annotations.Select`、`java.util.Map`。

- [ ] **Step 6.2: 在 CourseService 加方法声明**

```java
List<Map<String, Object>> getUserDownloads(Integer userId);
```

- [ ] **Step 6.3: 在 CourseServiceImpl 加实现**

```java
@Autowired
private CourseDownloadMapper courseDownloadMapper;

@Override
public List<Map<String, Object>> getUserDownloads(Integer userId) {
    return courseDownloadMapper.selectUserDownloadsWithCourse(userId);
}
```

- [ ] **Step 6.4: 在 CourseController 加 endpoint**

```java
@GetMapping("/downloads/{userId}")
public Result<List<Map<String, Object>>> getUserDownloads(@PathVariable Integer userId) {
    return Result.success(courseService.getUserDownloads(userId));
}
```

### Task 7: LikeController 我的点赞

**Files:**
- Modify: `ljx_backend/src/main/java/com/sunmao/ljx/mapper/LikeRecordMapper.java`
- Create: `ljx_backend/src/main/java/com/sunmao/ljx/service/LikeService.java`
- Create: `ljx_backend/src/main/java/com/sunmao/ljx/service/impl/LikeServiceImpl.java`
- Create: `ljx_backend/src/main/java/com/sunmao/ljx/controller/LikeController.java`

- [ ] **Step 7.1: 在 LikeRecordMapper 加查询**

```java
@Select("SELECT like_id AS likeId, target_type AS targetType, target_id AS targetId, create_time AS createTime " +
        "FROM like_record WHERE user_id = #{userId} " +
        "ORDER BY create_time DESC LIMIT #{limit}")
List<Map<String, Object>> selectMyLikes(@Param("userId") Integer userId,
                                          @Param("limit") Integer limit);
```

- [ ] **Step 7.2: 写 LikeService**

```java
package com.sunmao.ljx.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.sunmao.ljx.entity.LikeRecord;
import java.util.List;
import java.util.Map;

public interface LikeService extends IService<LikeRecord> {
    List<Map<String, Object>> myLikes(Integer userId, Integer limit);
}
```

- [ ] **Step 7.3: 写 LikeServiceImpl**

```java
package com.sunmao.ljx.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.sunmao.ljx.entity.LikeRecord;
import com.sunmao.ljx.mapper.LikeRecordMapper;
import com.sunmao.ljx.service.LikeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Map;

@Service
public class LikeServiceImpl extends ServiceImpl<LikeRecordMapper, LikeRecord> implements LikeService {

    @Autowired
    private LikeRecordMapper likeRecordMapper;

    @Override
    public List<Map<String, Object>> myLikes(Integer userId, Integer limit) {
        if (limit == null || limit <= 0) limit = 50;
        return likeRecordMapper.selectMyLikes(userId, limit);
    }
}
```

- [ ] **Step 7.4: 写 LikeController**

```java
package com.sunmao.ljx.controller;

import com.sunmao.ljx.common.Result;
import com.sunmao.ljx.service.LikeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/like")
public class LikeController {

    @Autowired
    private LikeService likeService;

    @GetMapping("/my/{userId}")
    public Result<List<Map<String, Object>>> myLikes(@PathVariable Integer userId,
                                                      @RequestParam(defaultValue = "50") Integer limit) {
        return Result.success(likeService.myLikes(userId, limit));
    }
}
```

### Task 8: User 表加 preferences + UserController 增接口

**Files:**
- Modify: `ljx_backend/src/main/java/com/sunmao/ljx/entity/User.java`
- Modify: `ljx_backend/src/main/java/com/sunmao/ljx/mapper/UserMapper.java`
- Modify: `ljx_backend/src/main/java/com/sunmao/ljx/service/UserService.java`
- Modify: `ljx_backend/src/main/java/com/sunmao/ljx/service/impl/UserServiceImpl.java`
- Modify: `ljx_backend/src/main/java/com/sunmao/ljx/controller/UserController.java`

- [ ] **Step 8.1: User 实体加字段**

```java
private String preferences;  // JSON 字符串
```

- [ ] **Step 8.2: UserMapper 加 getPreferences / setPreferences**

```java
@Select("SELECT preferences FROM user WHERE user_id = #{userId}")
String selectPreferences(@Param("userId") Integer userId);

@Update("UPDATE user SET preferences = #{preferences} WHERE user_id = #{userId}")
int updatePreferences(@Param("userId") Integer userId,
                       @Param("preferences") String preferences);
```

- [ ] **Step 8.3: UserService 加方法**

```java
String getPreferences(Integer userId);
void updatePreferences(Integer userId, String preferencesJson);
```

- [ ] **Step 8.4: UserServiceImpl 实现**

```java
@Override
public String getPreferences(Integer userId) {
    return userMapper.selectPreferences(userId);
}

@Override
public void updatePreferences(Integer userId, String preferencesJson) {
    userMapper.updatePreferences(userId, preferencesJson);
}
```

- [ ] **Step 8.5: UserController 加 endpoint**

```java
@GetMapping("/preferences/{userId}")
public Result<String> getPreferences(@PathVariable Integer userId) {
    return Result.success(userService.getPreferences(userId));
}

@PutMapping("/preferences/{userId}")
public Result<Void> updatePreferences(@PathVariable Integer userId,
                                       @RequestBody String preferencesJson) {
    userService.updatePreferences(userId, preferencesJson);
    return Result.success();
}
```

### Task 9: SearchController 全局搜索

**Files:**
- Create: `ljx_backend/src/main/resources/mapper/SearchMapper.xml`
- Create: `ljx_backend/src/main/java/com/sunmao/ljx/service/SearchService.java`
- Create: `ljx_backend/src/main/java/com/sunmao/ljx/service/impl/SearchServiceImpl.java`
- Create: `ljx_backend/src/main/java/com/sunmao/ljx/controller/SearchController.java`

- [ ] **Step 9.1: 写 XML（5 表 UNION ALL）**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="searchMapper">
    <resultMap id="hitMap" type="java.util.HashMap">
        <result column="type"  property="type"/>
        <result column="id"    property="id"/>
        <result column="title" property="title"/>
        <result column="desc"  property="desc"/>
        <result column="image" property="image"/>
    </resultMap>

    <select id="globalSearch" resultMap="hitMap">
        SELECT * FROM (
            SELECT 1 AS type, article_id AS id, title,
                   IFNULL(summary, '') AS desc,
                   IFNULL(cover_image, '') AS image
              FROM article
             WHERE status = 1 AND title LIKE CONCAT('%', #{kw}, '%')
             LIMIT 20
        ) a
        UNION ALL
        SELECT * FROM (
            SELECT 2 AS type, work_id AS id, title,
                   IFNULL(description, '') AS desc,
                   IFNULL(images, '') AS image
              FROM user_work
             WHERE status = 1 AND title LIKE CONCAT('%', #{kw}, '%')
             LIMIT 20
        ) b
        UNION ALL
        SELECT * FROM (
            SELECT 3 AS type, course_id AS id, title,
                   IFNULL(description, '') AS desc,
                   IFNULL(cover_image, '') AS image
              FROM course
             WHERE status = 1 AND title LIKE CONCAT('%', #{kw}, '%')
             LIMIT 20
        ) c
        UNION ALL
        SELECT * FROM (
            SELECT 4 AS type, post_id AS id,
                   SUBSTRING(content, 1, 40) AS title,
                   '' AS desc, '' AS image
              FROM post
             WHERE status = 1 AND content LIKE CONCAT('%', #{kw}, '%')
             LIMIT 20
        ) d
        UNION ALL
        SELECT * FROM (
            SELECT 5 AS type, article_id AS id, title,
                   '榫卯结构' AS desc,
                   IFNULL(cover_image, '') AS image
              FROM article
             WHERE status = 1 AND category_id = 1
               AND title LIKE CONCAT('%', #{kw}, '%')
             LIMIT 20
        ) e
        LIMIT #{limit}
    </select>
</mapper>
```

- [ ] **Step 9.2: 新建 SearchMapper 接口（不放在 entity 包，单独文件）**

文件 `ljx_backend/src/main/java/com/sunmao/ljx/mapper/SearchMapper.java`：

```java
package com.sunmao.ljx.mapper;

import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;

public interface SearchMapper {
    List<Map<String, Object>> globalSearch(@Param("kw") String kw,
                                            @Param("limit") Integer limit);
}
```

并在 application.yml 已有的 `mybatis-plus.mapper-locations` 中追加 `classpath*:mapper/SearchMapper.xml`（如果还没配 XML 扫描）。

- [ ] **Step 9.3: Service**

```java
// SearchService.java
public interface SearchService {
    List<Map<String, Object>> globalSearch(String keyword, Integer limit);
}

// SearchServiceImpl.java
@Service
public class SearchServiceImpl implements SearchService {
    @Autowired private SearchMapper searchMapper;
    @Override
    public List<Map<String, Object>> globalSearch(String keyword, Integer limit) {
        if (keyword == null || keyword.trim().isEmpty()) return Collections.emptyList();
        if (limit == null || limit <= 0) limit = 30;
        return searchMapper.globalSearch(keyword.trim(), limit);
    }
}
```

- [ ] **Step 9.4: Controller**

```java
@RestController
@RequestMapping("/api/search")
public class SearchController {
    @Autowired private SearchService searchService;

    @GetMapping("/global")
    public Result<List<Map<String, Object>>> global(@RequestParam String keyword,
                                                     @RequestParam(defaultValue = "30") Integer limit) {
        return Result.success(searchService.globalSearch(keyword, limit));
    }
}
```

### Task 10: 前端 footprint.js 接 API

**Files:**
- Modify: `ljx_extracted/ljx/pages/footprint/footprint.js`

- [ ] **Step 10.1: 替换 loadDemo**

```javascript
const app = getApp();

Page({
  data: { filterIdx: 0, list: [], dayGroups: [], loading: true },

  onLoad() { this.loadFromApi(); },

  loadFromApi: function() {
    var that = this;
    var userId = wx.getStorageSync('userId');
    if (!userId) { that.setData({ loading: false, list: [], dayGroups: [] }); return; }
    that.setData({ loading: true });
    wx.request({
      url: app.globalData.baseUrl + '/api/footprint/user/' + userId + '?limit=100',
      success: function(res) {
        if (res.data.code === 200) {
          that.setData({ list: res.data.data || [] });
          that.applyGrouping(that.data.filterIdx);
        } else {
          that.setData({ list: [], dayGroups: [] });
        }
      },
      fail: function() { that.setData({ list: [], dayGroups: [] }); },
      complete: function() { that.setData({ loading: false }); }
    });
  },

  // applyGrouping 保留原有逻辑，但用本地字段 day / time 转换为 group
  applyGrouping: function(idx) {
    var all = this.data.list;
    var groups = [];
    var seen = {};
    all.forEach(function(o) {
      var day = o.day || o.createTime;
      if (!seen[day]) { seen[day] = true; groups.push({ day: day, items: [] }); }
      groups[groups.length - 1].items.push(o);
    });
    this.setData({ dayGroups: groups });
  },

  switchFilter: function(e) {
    var i = parseInt(e.currentTarget.dataset.i, 10);
    this.setData({ filterIdx: i });
    this.applyGrouping(i);
  },

  goProduct: function(e) {
    wx.navigateTo({ url: '/pages/product/product?id=' + e.currentTarget.dataset.id });
  },

  goBack: function() { wx.navigateBack(); }
});
```

**注意**：后端返回的 `Footprint` 实体只有 `footprintId/userId/articleId/createTime`，前端展示需要 title/cover/price。Task 11 之前会先扩 Footprint 加 snapshot 字段（见下条风险说明）。

**风险声明**：当前 `footprint` 表没有保存浏览时的 title/cover/price 快照。两种方案：
- 方案 A：扩 `Footprint` 实体加 `snapshotTitle/snapshotCover/snapshotPrice`，产品页打开时同时写快照（推荐，删除文章后足迹仍能显示）
- 方案 B：前端拿到 `articleId` 后再请求 `GET /api/article/{id}` 拼装，缺点是文章删除后足迹显示空。

本计划按 **方案 A** 推进（见 Task 11），需同时改 Product 详情页 JS 调用 `/api/footprint/add` 时把快照一并传上。

### Task 11: Footprint 加 snapshot 字段

**Files:**
- Modify: `ljx_backend/sql/migrations/2026-06-10-feedback-preferences.sql`（追加）
- Modify: `ljx_backend/src/main/java/com/sunmao/ljx/entity/Footprint.java`
- Modify: `ljx_backend/src/main/java/com/sunmao/ljx/service/impl/FootprintServiceImpl.java`

- [ ] **Step 11.1: 迁移脚本追加**

```sql
ALTER TABLE `footprint`
  ADD COLUMN `snapshot_title`  VARCHAR(200) DEFAULT NULL COMMENT '文章标题快照',
  ADD COLUMN `snapshot_cover`  VARCHAR(500) DEFAULT NULL COMMENT '文章封面快照',
  ADD COLUMN `snapshot_author` VARCHAR(100) DEFAULT NULL COMMENT '文章作者快照';
```

- [ ] **Step 11.2: 实体加字段**

```java
private String snapshotTitle;
private String snapshotCover;
private String snapshotAuthor;
```

- [ ] **Step 11.3: addFootprint 重载接受快照**

```java
@Transactional(rollbackFor = Exception.class)
public void addFootprint(Integer userId, Integer articleId,
                          String snapshotTitle, String snapshotCover, String snapshotAuthor) {
    Footprint fp = new Footprint();
    fp.setUserId(userId);
    fp.setArticleId(articleId);
    fp.setSnapshotTitle(snapshotTitle);
    fp.setSnapshotCover(snapshotCover);
    fp.setSnapshotAuthor(snapshotAuthor);
    fp.setCreateTime(LocalDateTime.now());
    save(fp);
}
```

- [ ] **Step 11.4: FootprintController 同步更新**

把原 `/api/footprint/add` 改为接收 query 参数 `snapshotTitle/snapshotCover/snapshotAuthor`（详见后续前端调用方）。

### Task 12: 前端 works.js / downloads.js / likes.js 接 API

**Files:**
- Modify: `ljx_extracted/ljx/pages/works/works.js`
- Modify: `ljx_extracted/ljx/pages/downloads/downloads.js`
- Modify: `ljx_extracted/ljx/pages/likes/likes.js`

- [ ] **Step 12.1: works.js loadFromApi**

```javascript
const app = getApp();
Page({
  data: { works: [], totalLikes: 0, totalViews: 0, loading: true },
  onLoad() { this.loadFromApi(); },
  onShow() { this.loadFromApi(); },
  loadFromApi: function() {
    var that = this;
    var userId = wx.getStorageSync('userId');
    if (!userId) { that.setData({ loading: false, works: [] }); return; }
    wx.request({
      url: app.globalData.baseUrl + '/api/work/user/' + userId,
      success: function(res) {
        if (res.data.code === 200) {
          var data = res.data.data || [];
          var likes = 0, views = 0;
          data.forEach(function(w) { likes += (w.likeCount||0); views += (w.viewCount||0); });
          that.setData({ works: data, totalLikes: likes, totalViews: views });
        }
      },
      complete: function() { that.setData({ loading: false }); }
    });
  },
  // ... 其余方法保留
});
```

- [ ] **Step 12.2: downloads.js loadFromApi**

```javascript
const app = getApp();
Page({
  data: { list: [], loading: true },
  onLoad() { this.loadFromApi(); },
  loadFromApi: function() {
    var that = this;
    var userId = wx.getStorageSync('userId');
    if (!userId) { that.setData({ loading: false, list: [] }); return; }
    wx.request({
      url: app.globalData.baseUrl + '/api/course/downloads/' + userId,
      success: function(res) {
        if (res.data.code === 200) {
          var data = (res.data.data || []).map(function(o) {
            o.progress = o.progress || 0;
            o.selected = false;
            return o;
          });
          that.setData({ list: data });
        }
      },
      complete: function() { that.setData({ loading: false }); }
    });
  },
  // manageMode / onSelect / onDelete 保留，但 onDelete 改为调 DELETE 接口
});
```

**注意**：本期不实现后端的 `DELETE /api/course/downloads/{downloadId}`（计划在后续迭代补），删除仅本地过滤（manageMode 切换 + 数组 filter）。

- [ ] **Step 12.3: likes.js loadFromApi**

```javascript
const app = getApp();
Page({
  data: { filterIdx: 0, list: [], loading: true },
  onLoad() { this.loadFromApi(); },
  loadFromApi: function() {
    var that = this;
    var userId = wx.getStorageSync('userId');
    if (!userId) { that.setData({ loading: false, list: [] }); return; }
    wx.request({
      url: app.globalData.baseUrl + '/api/like/my/' + userId + '?limit=100',
      success: function(res) {
        if (res.data.code === 200) {
          // 后端返回 [{likeId, targetType, targetId, createTime}]
          // 简化：本期不再跨 5 表 join 拿 title/cover，前端展示原始 type 标签
          that.setData({ list: res.data.data || [] });
        }
      },
      complete: function() { that.setData({ loading: false }); }
    });
  }
});
```

**风险声明**：本期 LikeService 仅返回原始 like_record 行，不跨 5 表 join 拿 title/cover。前端展示效果会比较简陋（仅显示 `type: 1, id: 123`）。要真正显示卡片，需要在 LikeService 内部根据 `targetType` 路由到对应 Mapper 拿详情（5 个 if 分支）。本计划留到下一迭代。

### Task 13: 前端 help.js / support.js / settings.js 接 API

**Files:**
- Modify: `ljx_extracted/ljx/pages\help\help.js`
- Modify: `ljx_extracted/ljx/pages\support\support.js`
- Modify: `ljx_extracted/ljx/pages\settings\settings.js`

- [ ] **Step 13.1: help.js 提交走 API**

把 `onSubmit` 改为：

```javascript
onSubmit: function() {
  var that = this;
  var text = this.data.fbText.trim();
  if (!text) { wx.showToast({ title: '请填写反馈内容', icon: 'none' }); return; }
  wx.showLoading({ title: '提交中...', mask: true });
  wx.request({
    url: app.globalData.baseUrl + '/api/feedback/submit',
    method: 'POST',
    header: { 'content-type': 'application/json' },
    data: {
      fbType: 1,        // 1=功能建议（help 页固定为 1）
      content: text,
      contact: that.data.fbContact
    },
    success: function() {
      that.setData({ fbText: '', fbContact: '' });
      wx.showToast({ title: '感谢你的反馈', icon: 'success' });
    },
    fail: function() {
      wx.showToast({ title: '提交失败，请重试', icon: 'none' });
    },
    complete: function() { wx.hideLoading(); }
  });
}
```

并在文件顶部加 `const app = getApp();`。

- [ ] **Step 13.2: support.js 联系电话从 sys_config 读**

加一个 `loadConfig`：

```javascript
const app = getApp();
Page({
  data: { contacts: [], serviceHours: '' },
  onLoad() { this.loadConfig(); },
  loadConfig: function() {
    var that = this;
    wx.request({
      url: app.globalData.baseUrl + '/api/sysConfig/batch',
      method: 'GET',
      data: { keys: 'service_phone,service_email,service_wechat,service_weibo,service_hours' },
      success: function(res) {
        if (res.data.code === 200) {
          var d = res.data.data || {};
          that.setData({
            contacts: [
              { key: 'phone',  icon: '📞', label: '客服电话',  value: d.service_phone || '' },
              { key: 'email',  icon: '✉',  label: '客服邮箱',  value: d.service_email || '' },
              { key: 'wechat', icon: '💬', label: '客服微信',  value: d.service_wechat || '' },
              { key: 'weibo',  icon: '🌐', label: '官方微博',  value: d.service_weibo || '' }
            ],
            serviceHours: d.service_hours || ''
          });
        }
      }
    });
  }
  // 其余 onContact / onConsult 保留
});
```

**风险声明**：本计划引入 `GET /api/sysConfig/batch?keys=...` 接口，但实际项目里是否已有此接口需验证。若没有，本期不实现 `support` 端的动态加载，仅保留 `support.js` 原有静态文案（不调 API），避免临时改后端导致范围蔓延。

- [ ] **Step 13.3: settings.js 偏好走 API**

```javascript
const app = getApp();
Page({
  data: { userInfo: {}, isLogin: false, notify: true, darkMode: false,
          fontSizeLabel: '标准', phone: '', email: '', cacheSize: '12.6MB' },
  onShow() {
    this.refresh();
    this.loadPreferences();
  },
  refresh: function() {
    var userInfo = wx.getStorageSync('userInfo') || {};
    var isLogin = !!wx.getStorageSync('userId');
    this.setData({
      userInfo: userInfo, isLogin: isLogin,
      phone: userInfo.phone || '', email: userInfo.email || ''
    });
  },
  loadPreferences: function() {
    var that = this;
    var userId = wx.getStorageSync('userId');
    if (!userId) return;
    wx.request({
      url: app.globalData.baseUrl + '/api/user/preferences/' + userId,
      success: function(res) {
        if (res.data.code === 200 && res.data.data) {
          try {
            var p = JSON.parse(res.data.data);
            that.setData({
              notify: p.notify !== false,
              darkMode: p.darkMode === true,
              fontSizeLabel: p.fontSize || '标准'
            });
          } catch (e) { /* 后端返回非 JSON 时静默 */ }
        }
      }
    });
  },
  savePreferences: function() {
    var userId = wx.getStorageSync('userId');
    if (!userId) return;
    var payload = JSON.stringify({
      notify: this.data.notify, darkMode: this.data.darkMode,
      fontSize: this.data.fontSizeLabel, language: 'zh-CN'
    });
    wx.request({
      url: app.globalData.baseUrl + '/api/user/preferences/' + userId,
      method: 'PUT', data: payload,
      header: { 'content-type': 'application/json' }
    });
  },
  onToggleNotify: function(e) { this.setData({ notify: e.detail.value }); this.savePreferences(); },
  onToggleDark:   function(e) { this.setData({ darkMode: e.detail.value }); this.savePreferences(); },
  onPickFont: function() {
    var that = this;
    wx.showActionSheet({
      itemList: ['小', '标准', '大', '特大'],
      success: function(res) {
        var labels = ['小', '标准', '大', '特大'];
        that.setData({ fontSizeLabel: labels[res.tapIndex] });
        that.savePreferences();
      }
    });
  }
  // 其余方法保留
});
```

### Task 14: 前端 global-search.js 接 API

**Files:**
- Modify: `ljx_extracted/ljx/pages/global-search/global-search.js`

- [ ] **Step 14.1: 替换 applyFilter**

把 `applyFilter: function(kw)` 改为：

```javascript
applyFilter: function(kw) {
  var that = this;
  if (!kw || !kw.trim()) { that.setData({ resultList: [] }); return; }
  wx.request({
    url: app.globalData.baseUrl + '/api/search/global',
    data: { keyword: kw, limit: 30 },
    success: function(res) {
      if (res.data.code === 200) {
        that.setData({ resultList: res.data.data || [] });
      }
    }
  });
}
```

并在 `onTapResult` 中根据 `result.type` 路由：
- type=1 商品 → `/pages/product/product?id=...`
- type=2 作品 → `/pages/works/works`（或详情页，本期跳自己的列表）
- type=3 课程 → `/pages/sort/sort` switchTab
- type=4 帖子 → `/pages/place/place`
- type=5 结构 → `/pages/sort/sort` switchTab

### Task 15: 清理多余文件

**Files:**
- 删除: `ljx_extracted/ljx/pages/logs/logs.{js,wxml}` — 该目录仅 2 个文件，无 .json/.wxss，从未注册在 app.json 中（确认：app.json 的 pages 数组最后是 `pages/logs/logs`），仅作历史占位。如确需保留则在 plan 中说明。

- [ ] **Step 15.1: 确认 logs 目录是否被引用**

`grep -r "logs/logs" ljx_extracted/ljx/` 验证：仅在 app.json 出现一次注册，无其他引用。

- [ ] **Step 15.2: 删除 logs 目录**

风险：本目录在 app.json 中注册过，删除前需先从 app.json 中移除 `pages/logs/logs` 一行再删文件，否则编译会报"找不到 logs.wxml"。

- [ ] **Step 15.3: 删除本次新页面中未使用的 stub 文件**

8 个新页面已写完 24 个文件（每个 wxml+js+wxss+json），其中 6 个 .json 是新建的 8 个页面的 8 个 json 文件之外还可能有 0 个冗余文件。逐一核对：每个页面都有对应的 4 个文件，无冗余。

- [ ] **Step 15.4: 删除文档目录下的旧截图/临时文件**

`docs/` 下保留所有 `.md` 文档，删除 `.png` 临时截图（若有）。

---

## 风险与待澄清项（无法溯源）

1. **登录态解析方式**：`UserController.parseUserId` 当前实现是占位，项目实际登录是微信 code 换 sessionKey 还是 JWT 鉴权？**无法溯源**（未读 `UserController.java` 全量代码）。本计划在 FeedbackController 中保留 `parseUserId` 占位方法，**生产前必须按项目实际鉴权方式补全**。

2. **sysConfig 接口**：`GET /api/sysConfig/batch?keys=...` 是否已存在？**无法溯源**（未读 `SysConfigController.java` 完整定义）。若不存在，support.js 改为本地静态配置，不影响功能。

3. **like_record.targetType 扩展**：原 `target_type` 注释为 1文章 2帖子，本计划将扩展为 1文章 2帖子 3课程 4作品 5结构。**若历史数据已使用其他枚举值**，需在切换前做兼容。本计划按扩展处理，不删旧数据。

4. **MyBatis-Plus XML 扫描**：项目 `application.yml` 是否配了 `mybatis-plus.mapper-locations: classpath*:mapper/**/*.xml`？**无法溯源**。本计划假设已配或预留 `classpath*:mapper/SearchMapper.xml` 路径。

5. **Footprint snapshot 字段**：`addFootprint` 改签名后，会破坏现有调用方（`FootprintController` 已有的 `addFootprint(userId, articleId)` 路径）。需同步修改 Controller 增加 query 参数，或保留旧方法做重载兼容。

6. **数据库迁移路径**：本计划把 DDL 写在 `ljx_backend/sql/migrations/2026-06-10-feedback-preferences.sql`，原项目无 migrations 目录。**新建目录需用户确认**，或者直接追加到 `schema_mysql8.sql` 末尾。
