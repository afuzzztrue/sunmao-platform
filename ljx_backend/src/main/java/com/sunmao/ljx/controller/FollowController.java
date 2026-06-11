package com.sunmao.ljx.controller;

import com.sunmao.ljx.common.Result;
import com.sunmao.ljx.service.FollowService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
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
}
