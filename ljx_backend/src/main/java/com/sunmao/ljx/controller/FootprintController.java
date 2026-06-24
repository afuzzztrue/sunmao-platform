package com.sunmao.ljx.controller;

import com.sunmao.ljx.common.Result;
import com.sunmao.ljx.entity.Footprint;
import com.sunmao.ljx.service.FootprintService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 足迹控制器
 * 6/26 升级: 新增 GET /api/footprint/my/{userId} 走 LEFT JOIN 拿真实标题/封面
 */
@RestController
@RequestMapping("/api/footprint")
public class FootprintController {

    @Autowired
    private FootprintService footprintService;

    /**
     * 兼容老接口: 返回原始 Footprint 实体
     */
    @GetMapping("/user/{userId}")
    public Result<List<Footprint>> getUserFootprints(@PathVariable Integer userId,
                                                      @RequestParam(defaultValue = "20") Integer limit) {
        return Result.success(footprintService.getUserFootprints(userId, limit));
    }

    /**
     * 6/26 新增: 我的足迹 (含真实标题/封面) - 走 5 表 LEFT JOIN
     * GET /api/footprint/my/{userId}?limit=100
     */
    @GetMapping("/my/{userId}")
    public Result<List<Map<String, Object>>> myFootprints(@PathVariable Integer userId,
                                                           @RequestParam(defaultValue = "100") Integer limit) {
        return Result.success(footprintService.myFootprints(userId, limit));
    }

    /**
     * 记录足迹 (被 article-detail 页面 onLoad 调用)
     */
    @PostMapping("/add")
    public Result<Void> addFootprint(@RequestParam Integer userId,
                                      @RequestParam Integer articleId,
                                      @RequestParam(required = false) String snapshotTitle,
                                      @RequestParam(required = false) String snapshotCover,
                                      @RequestParam(required = false) String snapshotAuthor) {
        footprintService.addFootprint(userId, articleId, snapshotTitle, snapshotCover, snapshotAuthor);
        return Result.success();
    }

    /**
     * 6/26 新增: 通用版本, 支持记录 5 种类型的足迹
     * POST /api/footprint/add2
     * params: userId, targetType, targetId
     */
    @PostMapping("/add2")
    public Result<Void> addFootprint2(@RequestParam Integer userId,
                                       @RequestParam Integer targetType,
                                       @RequestParam Integer targetId) {
        footprintService.addFootprintV2(userId, targetType, targetId);
        return Result.success();
    }
}
