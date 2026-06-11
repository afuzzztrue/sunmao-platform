package com.sunmao.ljx.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.sunmao.ljx.entity.LikeRecord;
import com.sunmao.ljx.mapper.LikeRecordMapper;
import com.sunmao.ljx.service.LikeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

/**
 * 点赞服务实现类
 */
@Service
public class LikeServiceImpl extends ServiceImpl<LikeRecordMapper, LikeRecord> implements LikeService {

    @Autowired
    private LikeRecordMapper likeRecordMapper;

    @Override
    public List<Map<String, Object>> myLikes(Integer userId, Integer limit) {
        if (limit == null || limit <= 0) limit = 50;
        return likeRecordMapper.selectMyLikes(userId, limit);
    }
}
