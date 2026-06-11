package com.sunmao.ljx.service.impl;

import com.sunmao.ljx.mapper.SearchMapper;
import com.sunmao.ljx.service.SearchService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * 全局搜索服务实现
 */
@Service
public class SearchServiceImpl implements SearchService {

    @Autowired
    private SearchMapper searchMapper;

    @Override
    public List<Map<String, Object>> globalSearch(String keyword, Integer limit) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return Collections.emptyList();
        }
        if (limit == null || limit <= 0) limit = 30;
        return searchMapper.globalSearch(keyword.trim(), limit);
    }
}
