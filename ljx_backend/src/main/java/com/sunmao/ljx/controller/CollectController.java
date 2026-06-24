package com.sunmao.ljx.controller;

import com.sunmao.ljx.common.Result;
import com.sunmao.ljx.service.CollectService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 收藏控制器 (6/26 新增, 聚焦"我的 → 我的收藏"页面)
 *
 * 文章维度收藏/取消收藏仍走 /api/article/collect (ArticleController)
 * 这里只负责"我的收藏"列表查询
 */
@RestController
@RequestMapping("/api/collect")
public class CollectController {

    @Autowired
    private CollectService collectService;

    /**
     * 我的收藏列表
     */
    @GetMapping("/my/{userId}")
    public Result<List<Map<String, Object>>> myCollects(@PathVariable Integer userId,
                                                          @RequestParam(defaultValue = "50") Integer limit) {
        return Result.success(collectService.myCollects(userId, limit));
    }
}
