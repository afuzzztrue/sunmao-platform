package com.sunmao.ljx.controller;

import com.sunmao.ljx.common.Result;
import com.sunmao.ljx.service.LikeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 点赞控制器（聚焦"我的 → 我的点赞"页面）
 *
 * 取消点赞走 /api/article/like 或 /api/post/like（已在 ArticleController/PostController 中）
 */
@RestController
@RequestMapping("/api/like")
public class LikeController {

    @Autowired
    private LikeService likeService;

    /**
     * 我的点赞列表
     */
    @GetMapping("/my/{userId}")
    public Result<List<Map<String, Object>>> myLikes(@PathVariable Integer userId,
                                                      @RequestParam(defaultValue = "50") Integer limit) {
        return Result.success(likeService.myLikes(userId, limit));
    }
}
