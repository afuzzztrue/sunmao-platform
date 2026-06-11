package com.sunmao.ljx.service;

import java.util.List;
import java.util.Map;

/**
 * 全局搜索服务接口
 */
public interface SearchService {

    /**
     * 跨 5 表聚合搜索
     *
     * @param keyword 关键词
     * @param limit   返回上限
     */
    List<Map<String, Object>> globalSearch(String keyword, Integer limit);
}
