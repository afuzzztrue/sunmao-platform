package com.sunmao.ljx.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.sunmao.ljx.common.Result;
import com.sunmao.ljx.entity.Feedback;
import com.sunmao.ljx.service.FeedbackService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;

/**
 * 用户反馈控制器
 *
 * RESTful 约定：
 *   POST /api/feedback/submit  用户提交反馈
 *   GET  /api/feedback/list    管理后台分页查询（预留）
 */
@RestController
@RequestMapping("/api/feedback")
public class FeedbackController {

    @Autowired
    private FeedbackService feedbackService;

    /**
     * 提交反馈
     * 入参 JSON 示例:
     * {
     *   "userId": 1,            // 可选，未登录时为空
     *   "fbType": 1,            // 1功能建议 2联系客服 3举报 4bug 5商务
     *   "content": "反馈正文",
     *   "contact": "13800000000"
     * }
     */
    @PostMapping("/submit")
    public Result<Void> submit(@RequestBody Feedback feedback, HttpServletRequest request) {
        String ua = request.getHeader("User-Agent");
        if (ua != null && ua.length() > 250) ua = ua.substring(0, 250);
        feedback.setDevice(ua);
        feedbackService.submit(feedback);
        return Result.success();
    }

    /**
     * 反馈分页列表（管理后台用，前端不调用）
     */
    @GetMapping("/list")
    public Result<IPage<Feedback>> list(@RequestParam(defaultValue = "1") Integer page,
                                          @RequestParam(defaultValue = "20") Integer size,
                                          @RequestParam(required = false) Integer status,
                                          @RequestParam(required = false) Integer fbType) {
        return Result.success(feedbackService.pageQuery(page, size, status, fbType));
    }
}
