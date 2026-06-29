package com.sunmao.ljx.controller;

import com.sunmao.ljx.common.Result;
import com.sunmao.ljx.entity.User;
import com.sunmao.ljx.service.FollowService;
import com.sunmao.ljx.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * 用户控制器
 */
@RestController
@RequestMapping("/api/user")
public class UserController {

    @Autowired
    private UserService userService;

    @Autowired
    private FollowService followService;

    @PostMapping("/register")
    public Result<User> register(@RequestParam String phone,
                                  @RequestParam String email,
                                  @RequestParam String password,
                                  @RequestParam String nickname) {
        User user = userService.register(phone, email, password, nickname);
        return Result.success(user);
    }

    @PostMapping("/login")
    public Result<Map<String, Object>> login(@RequestParam String account,
                                              @RequestParam String password) {
        User user = userService.login(account, password);
        Map<String, Object> result = new HashMap<>();
        result.put("userId", user.getUserId());
        result.put("nickname", user.getNickname());
        result.put("avatar", user.getAvatar());
        result.put("phone", user.getPhone());
        result.put("email", user.getEmail());
        result.put("studyHours", user.getStudyHours());
        result.put("userType", user.getUserType());
        result.put("status", user.getStatus());
        return Result.success(result);
    }

    @PostMapping("/wxLogin")
    public Result<Map<String, Object>> wxLogin(@RequestParam String openid,
                                                @RequestParam(required = false) String unionid,
                                                @RequestParam(required = false) String nickname,
                                                @RequestParam(required = false) String avatar) {
        User user = userService.wxLogin(openid, unionid, nickname, avatar);
        Map<String, Object> result = new HashMap<>();
        result.put("userId", user.getUserId());
        result.put("nickname", user.getNickname());
        result.put("avatar", user.getAvatar());
        result.put("phone", user.getPhone());
        result.put("email", user.getEmail());
        result.put("studyHours", user.getStudyHours());
        result.put("userType", user.getUserType());
        result.put("status", user.getStatus());
        return Result.success(result);
    }

    @GetMapping("/info/{userId}")
    public Result<Map<String, Object>> getUserInfo(@PathVariable Integer userId) {
        User user = userService.getById(userId);
        if (user == null) {
            return Result.error("用户不存在");
        }
        Map<String, Object> result = new HashMap<>();
        result.put("userId", user.getUserId());
        result.put("nickname", user.getNickname());
        result.put("avatar", user.getAvatar());
        result.put("studyHours", user.getStudyHours());
        result.put("followCount", followService.getFollowCount(userId));
        result.put("followerCount", followService.getFollowerCount(userId));
        return Result.success(result);
    }

    @PostMapping("/update")
    public Result<Void> updateUser(@RequestBody User user) {
        userService.updateById(user);
        return Result.success();
    }

    /**
     * 读取用户偏好（JSON 字符串）
     */
    @GetMapping("/preferences/{userId}")
    public Result<String> getPreferences(@PathVariable Integer userId) {
        return Result.success(userService.getPreferences(userId));
    }

    /**
     * 写入用户偏好（请求体为 JSON 字符串）
     */
    @PutMapping("/preferences/{userId}")
    public Result<Void> updatePreferences(@PathVariable Integer userId,
                                           @RequestBody String preferencesJson) {
        userService.updatePreferences(userId, preferencesJson);
        return Result.success();
    }
}
