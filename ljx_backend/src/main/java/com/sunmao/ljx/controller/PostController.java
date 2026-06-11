package com.sunmao.ljx.controller;

import com.sunmao.ljx.common.Result;
import com.sunmao.ljx.entity.Post;
import com.sunmao.ljx.service.PostService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 动态帖子控制器
 */
@RestController
@RequestMapping("/api/post")
public class PostController {

    @Autowired
    private PostService postService;

    @GetMapping("/list")
    public Result<List<Post>> getPostList(@RequestParam(defaultValue = "1") Integer page,
                                           @RequestParam(defaultValue = "10") Integer size) {
        return Result.success(postService.getPostList(page, size));
    }

    @GetMapping("/user/{userId}")
    public Result<List<Post>> getUserPosts(@PathVariable Integer userId) {
        return Result.success(postService.getUserPosts(userId));
    }

    @PostMapping("/publish")
    public Result<Void> publishPost(@RequestBody Post post) {
        postService.save(post);
        return Result.success();
    }

    @PostMapping("/like")
    public Result<Void> toggleLike(@RequestParam Integer postId,
                                    @RequestParam Integer userId) {
        postService.toggleLike(postId, userId);
        return Result.success();
    }
}
