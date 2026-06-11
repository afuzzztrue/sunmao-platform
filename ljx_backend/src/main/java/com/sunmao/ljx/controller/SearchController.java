package com.sunmao.ljx.controller;

import com.sunmao.ljx.common.Result;
import com.sunmao.ljx.service.SearchService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 全局搜索控制器
 * 用于"我的 → 顶栏搜索图标"
 *
 * 跨域聚合：文章 / 作品 / 课程 / 帖子 / 榫卯结构
 * 返回字段: {type, id, title, desc, image}
 *   type 1=文章  2=作品  3=课程  4=帖子  5=结构
 */
@RestController
@RequestMapping("/api/search")
public class SearchController {

    @Autowired
    private SearchService searchService;

    @GetMapping("/global")
    public Result<List<Map<String, Object>>> global(@RequestParam String keyword,
                                                     @RequestParam(defaultValue = "30") Integer limit) {
        return Result.success(searchService.globalSearch(keyword, limit));
    }
}
