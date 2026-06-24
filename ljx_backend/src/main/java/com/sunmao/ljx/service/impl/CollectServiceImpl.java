package com.sunmao.ljx.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.sunmao.ljx.entity.CollectRecord;
import com.sunmao.ljx.mapper.CollectRecordMapper;
import com.sunmao.ljx.service.CollectService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

/**
 * 收藏服务实现类
 * 6/26 新增
 */
@Service
public class CollectServiceImpl extends ServiceImpl<CollectRecordMapper, CollectRecord> implements CollectService {

    @Autowired
    private CollectRecordMapper collectRecordMapper;

    @Override
    public List<Map<String, Object>> myCollects(Integer userId, Integer limit) {
        if (limit == null || limit <= 0) limit = 50;
        return collectRecordMapper.selectMyCollectsEnriched(userId, limit);
    }
}
