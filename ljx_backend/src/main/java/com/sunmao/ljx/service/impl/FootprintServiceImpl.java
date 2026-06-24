package com.sunmao.ljx.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.sunmao.ljx.entity.Footprint;
import com.sunmao.ljx.mapper.FootprintMapper;
import com.sunmao.ljx.service.FootprintService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 浏览足迹服务实现类
 * 6/26 升级: 加 myFootprints + addFootprintV2 方法
 */
@Service
public class FootprintServiceImpl extends ServiceImpl<FootprintMapper, Footprint> implements FootprintService {

    @Autowired
    private FootprintMapper footprintMapper;

    @Override
    public List<Footprint> getUserFootprints(Integer userId, Integer limit) {
        if (limit == null || limit <= 0) limit = 20;
        return footprintMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<Footprint>()
                .eq("user_id", userId)
                .orderByDesc("create_time")
                .last("LIMIT " + limit)
        );
    }

    /**
     * 6/26 新增: 走 5 表 LEFT JOIN
     */
    @Override
    public List<Map<String, Object>> myFootprints(Integer userId, Integer limit) {
        if (limit == null || limit <= 0) limit = 100;
        return footprintMapper.selectMyFootprintsEnriched(userId, limit);
    }

    @Override
    public void addFootprint(Integer userId, Integer articleId) {
        addFootprint(userId, articleId, null, null, null);
    }

    @Override
    public void addFootprint(Integer userId, Integer articleId,
                              String snapshotTitle, String snapshotCover, String snapshotAuthor) {
        Footprint fp = new Footprint();
        fp.setUserId(userId);
        fp.setArticleId(articleId);
        // 6/26 升级: 同时写 articleId 和 targetType/targetId
        fp.setTargetType(1);
        fp.setTargetId(articleId);
        fp.setCreateTime(LocalDateTime.now());
        fp.setSnapshotTitle(snapshotTitle);
        fp.setSnapshotCover(snapshotCover);
        fp.setSnapshotAuthor(snapshotAuthor);
        footprintMapper.insert(fp);
    }

    /**
     * 6/26 新增: 通用版本, 支持任意 type
     */
    @Override
    public void addFootprintV2(Integer userId, Integer targetType, Integer targetId) {
        Footprint fp = new Footprint();
        fp.setUserId(userId);
        fp.setTargetType(targetType);
        fp.setTargetId(targetId);
        fp.setCreateTime(LocalDateTime.now());
        // 兼容: type=1 时同步写 articleId
        if (targetType != null && targetType == 1 && targetId != null) {
            fp.setArticleId(targetId);
        }
        footprintMapper.insert(fp);
    }
}
