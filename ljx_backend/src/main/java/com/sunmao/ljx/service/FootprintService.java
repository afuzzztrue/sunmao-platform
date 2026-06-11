package com.sunmao.ljx.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.sunmao.ljx.entity.Footprint;

import java.util.List;

/**
 * 浏览足迹服务接口
 */
public interface FootprintService extends IService<Footprint> {

    List<Footprint> getUserFootprints(Integer userId, Integer limit);

    void addFootprint(Integer userId, Integer articleId);

    /**
     * 带快照字段的足迹写入（推荐使用）
     * @param snapshotTitle  文章标题快照
     * @param snapshotCover  文章封面 URL 快照
     * @param snapshotAuthor 作者名称快照
     */
    void addFootprint(Integer userId, Integer articleId,
                      String snapshotTitle, String snapshotCover, String snapshotAuthor);
}
