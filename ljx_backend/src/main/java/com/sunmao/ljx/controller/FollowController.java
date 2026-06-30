package com.sunmao.ljx.controller;

import com.sunmao.ljx.common.Result;
import com.sunmao.ljx.service.FollowService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 关注关系控制器
 */
@RestController
@RequestMapping("/api/follow")
public class FollowController {

    @Autowired
    private FollowService followService;

    @PostMapping("/toggle")
    public Result<Void> toggleFollow(@RequestParam Integer userId,
                                      @RequestParam Integer followUserId) {
        followService.toggleFollow(userId, followUserId);
        return Result.success();
    }

    @GetMapping("/count/{userId}")
    public Result<Map<String, Integer>> getFollowCount(@PathVariable Integer userId) {
        Map<String, Integer> result = new HashMap<>();
        result.put("followCount", followService.getFollowCount(userId));
        result.put("followerCount", followService.getFollowerCount(userId));
        return Result.success(result);
    }

    @GetMapping("/list/{userId}")
    public Result<List<Map<String, Object>>> getFollowList(@PathVariable Integer userId) {
        return Result.success(followService.getFollowList(userId));
    }

    @GetMapping("/fans/{userId}")
    public Result<List<Map<String, Object>>> getFollowerList(@PathVariable Integer userId) {
        return Result.success(followService.getFollowerList(userId));
    }

    @GetMapping("/status")
    public Result<Map<String, Boolean>> isFollowing(@RequestParam Integer userId,
                                                    @RequestParam Integer followUserId) {
        Map<String, Boolean> result = new HashMap<>();
        result.put("following", followService.isFollowing(userId, followUserId));
        return Result.success(result);
    }
}
