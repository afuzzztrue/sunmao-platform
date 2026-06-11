package com.sunmao.ljx.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.sunmao.ljx.entity.Footprint;
import com.sunmao.ljx.mapper.FootprintMapper;
import com.sunmao.ljx.service.FootprintService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 浏览足迹服务实现类
 */
@Service
public class FootprintServiceImpl extends ServiceImpl<FootprintMapper, Footprint> implements FootprintService {

    @Override
    public List<Footprint> getUserFootprints(Integer userId, Integer limit) {
        return baseMapper.selectRecentByUserId(userId, limit);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void addFootprint(Integer userId, Integer articleId) {
        Footprint footprint = new Footprint();
        footprint.setUserId(userId);
        footprint.setArticleId(articleId);
        footprint.setCreateTime(LocalDateTime.now());
        save(footprint);
    }

    /**
     * 带快照的足迹写入（推荐使用）
     * 文章被删除后足迹记录仍能展示历史浏览
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void addFootprint(Integer userId, Integer articleId,
                              String snapshotTitle, String snapshotCover, String snapshotAuthor) {
        Footprint footprint = new Footprint();
        footprint.setUserId(userId);
        footprint.setArticleId(articleId);
        footprint.setSnapshotTitle(snapshotTitle);
        footprint.setSnapshotCover(snapshotCover);
        footprint.setSnapshotAuthor(snapshotAuthor);
        footprint.setCreateTime(LocalDateTime.now());
        save(footprint);
    }
}
