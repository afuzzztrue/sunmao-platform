package com.sunmao.ljx.controller;

import com.sunmao.ljx.common.Result;
import com.sunmao.ljx.entity.Article;
import com.sunmao.ljx.service.ArticleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 文章控制器
 */
@RestController
@RequestMapping("/api/article")
public class ArticleController {

    @Autowired
    private ArticleService articleService;

    @GetMapping("/hot")
    public Result<List<Article>> getHotList(@RequestParam(defaultValue = "10") Integer limit) {
        return Result.success(articleService.getHotList(limit));
    }

    @GetMapping("/category/{categoryId}")
    public Result<List<Article>> getListByCategory(@PathVariable Integer categoryId) {
        return Result.success(articleService.getListByCategory(categoryId));
    }

    @GetMapping("/detail/{articleId}")
    public Result<Article> getDetail(@PathVariable Integer articleId) {
        return Result.success(articleService.getDetail(articleId));
    }

    /**
     * 7/1 新增: 显式增加文章浏览量
     * 由文章详情页 onLoad 调用，确保只有真正查看详情时才 +1
     */
    @PostMapping("/view/{articleId}")
    public Result<Void> incrementViewCount(@PathVariable Integer articleId) {
        articleService.incrementViewCount(articleId);
        return Result.success();
    }

    /**
     * 7/1 新增: 查询某用户发布的文章列表
     * 用于"我的"页面"我的作品"二级 tab
     */
    @GetMapping("/user/{userId}")
    public Result<List<Article>> getUserArticles(@PathVariable Integer userId) {
        return Result.success(articleService.getUserArticles(userId));
    }

    @PostMapping("/like")
    public Result<Map<String, Object>> toggleLike(@RequestParam Integer articleId,
                                                   @RequestParam Integer userId) {
        // 6/26 升级: 返回 {liked: true/false, likeCount: 新的点赞数}
        // 前端用此同步本地状态, 避免"已点赞状态下再点导致本地+1 后端-1"的不一致
        Map<String, Object> data = new HashMap<>();
        data.put("liked", articleService.toggleLikeAndReturn(articleId, userId));
        // 重新读一次当前 likeCount 给前端
        Article a = articleService.getById(articleId);
        if (a != null) {
            data.put("likeCount", a.getLikeCount());
        }
        return Result.success(data);
    }

    @PostMapping("/collect")
    public Result<Map<String, Object>> toggleCollect(@RequestParam Integer articleId,
                                                      @RequestParam Integer userId) {
        // 6/26 升级: 返回 {collected: true/false, collectCount: 新的收藏数}
        Map<String, Object> data = new HashMap<>();
        data.put("collected", articleService.toggleCollectAndReturn(articleId, userId));
        Article a = articleService.getById(articleId);
        if (a != null) {
            data.put("collectCount", a.getCollectCount());
        }
        return Result.success(data);
    }

    /**
     * 6/26 新增: 查询用户对某篇文章的点赞/收藏状态
     * 用于文章详情页 onLoad 初始化本地 liked/collected 状态
     * GET /api/article/status?articleId=1&userId=12
     */
    @GetMapping("/status")
    public Result<Map<String, Boolean>> getUserStatus(@RequestParam Integer articleId,
                                                       @RequestParam(required = false) Integer userId) {
        return Result.success(articleService.getUserStatus(articleId, userId));
    }

    /**
     * 创建文章 (6/25 新增)
     * 入参: Article JSON (userId/categoryId/title/summary/content/coverImage/images/tags/location)
     * 返回: { articleId: 新插入的 ID }
     */
    @PostMapping("/create")
    public Result<Map<String, Integer>> create(@RequestBody Article article) {
        Integer articleId = articleService.create(article);
        Map<String, Integer> data = new HashMap<>();
        data.put("articleId", articleId);
        return Result.success(data);
    }
}
