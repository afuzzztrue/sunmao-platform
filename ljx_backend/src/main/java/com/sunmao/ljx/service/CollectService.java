package com.sunmao.ljx.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.sunmao.ljx.entity.CollectRecord;

import java.util.List;
import java.util.Map;

/**
 * 收藏服务接口
 * 6/26 新增: 用于"我的 → 我的收藏"页面
 */
public interface CollectService extends IService<CollectRecord> {

    /**
     * 查询用户的所有收藏 (含真实标题/封面)
     */
    List<Map<String, Object>> myCollects(Integer userId, Integer limit);
}
