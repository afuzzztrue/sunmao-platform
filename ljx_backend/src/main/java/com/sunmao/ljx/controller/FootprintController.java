package com.sunmao.ljx.controller;

import com.sunmao.ljx.common.Result;
import com.sunmao.ljx.entity.Footprint;
import com.sunmao.ljx.service.FootprintService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 浏览足迹控制器
 */
@RestController
@RequestMapping("/api/footprint")
public class FootprintController {

    @Autowired
    private FootprintService footprintService;

    @GetMapping("/user/{userId}")
    public Result<List<Footprint>> getUserFootprints(@PathVariable Integer userId,
                                                      @RequestParam(defaultValue = "20") Integer limit) {
        return Result.success(footprintService.getUserFootprints(userId, limit));
    }

    @PostMapping("/add")
    public Result<Void> addFootprint(@RequestParam Integer userId,
                                      @RequestParam Integer articleId,
                                      @RequestParam(required = false) String snapshotTitle,
                                      @RequestParam(required = false) String snapshotCover,
                                      @RequestParam(required = false) String snapshotAuthor) {
        footprintService.addFootprint(userId, articleId, snapshotTitle, snapshotCover, snapshotAuthor);
        return Result.success();
    }
}
