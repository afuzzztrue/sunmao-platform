package com.sunmao.ljx.controller;

import com.sunmao.ljx.common.Result;
import com.sunmao.ljx.entity.UserWork;
import com.sunmao.ljx.service.UserWorkService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 用户作品控制器
 */
@RestController
@RequestMapping("/api/work")
public class UserWorkController {

    @Autowired
    private UserWorkService userWorkService;

    @GetMapping("/user/{userId}")
    public Result<List<UserWork>> getUserWorks(@PathVariable Integer userId) {
        return Result.success(userWorkService.getUserWorks(userId));
    }

    @PostMapping("/publish")
    public Result<Void> publishWork(@RequestBody UserWork work) {
        userWorkService.save(work);
        return Result.success();
    }
}
