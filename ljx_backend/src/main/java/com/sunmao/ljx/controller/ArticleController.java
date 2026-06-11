package com.sunmao.ljx.controller;

import com.sunmao.ljx.common.Result;
import com.sunmao.ljx.entity.Article;
import com.sunmao.ljx.service.ArticleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

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

    @PostMapping("/like")
    public Result<Void> toggleLike(@RequestParam Integer articleId,
                                    @RequestParam Integer userId) {
        articleService.toggleLike(articleId, userId);
        return Result.success();
    }

    @PostMapping("/collect")
    public Result<Void> toggleCollect(@RequestParam Integer articleId,
                                       @RequestParam Integer userId) {
        articleService.toggleCollect(articleId, userId);
        return Result.success();
    }
}
