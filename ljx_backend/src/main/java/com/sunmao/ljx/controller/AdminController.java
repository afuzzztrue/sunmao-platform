package com.sunmao.ljx.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.sunmao.ljx.common.Result;
import com.sunmao.ljx.entity.User;
import com.sunmao.ljx.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.DigestUtils;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    @Autowired
    private UserService userService;

    @GetMapping("/user/list")
    public Result<Map<String, Object>> userList(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        Page<User> userPage = new Page<>(page, size);
        userService.page(userPage, new LambdaQueryWrapper<User>()
                .orderByDesc(User::getCreateTime));
        Map<String, Object> result = new HashMap<>();
        result.put("list", userPage.getRecords());
        result.put("total", userPage.getTotal());
        result.put("page", page);
        result.put("size", size);
        return Result.success(result);
    }

    @GetMapping("/user/search")
    public Result<List<User>> userSearch(@RequestParam String keyword) {
        List<User> list = userService.list(new LambdaQueryWrapper<User>()
                .like(User::getNickname, keyword)
                .or()
                .like(User::getPhone, keyword)
                .or()
                .like(User::getEmail, keyword));
        return Result.success(list);
    }

    @PostMapping("/user/add")
    public Result<User> userAdd(@RequestParam String account,
                                 @RequestParam String password,
                                 @RequestParam(required = false, defaultValue = "") String nickname) {
        String phone = account.contains("@") ? null : account;
        String email = account.contains("@") ? account : null;
        User user = userService.register(phone, email, password, nickname);
        return Result.success(user);
    }

    @PostMapping("/user/update")
    public Result<Void> userUpdate(@RequestBody User user) {
        if (user.getUserId() == null) {
            return Result.error("userId不能为空");
        }
        if (StringUtils.hasText(user.getPassword())) {
            user.setPassword(DigestUtils.md5DigestAsHex(
                    user.getPassword().getBytes(StandardCharsets.UTF_8)));
        }
        user.setUpdateTime(LocalDateTime.now());
        userService.updateById(user);
        return Result.success();
    }

    @PostMapping("/user/delete")
    public Result<Void> userDelete(@RequestParam Integer userId) {
        if (userId == null) {
            return Result.error("userId不能为空");
        }
        userService.removeById(userId);
        return Result.success();
    }
}
