package com.sunmao.ljx.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.sunmao.ljx.entity.LikeRecord;

import java.util.List;
import java.util.Map;

/**
 * 点赞服务接口
 * 集中管理点赞相关业务（取消点赞/我的点赞列表）
 */
public interface LikeService extends IService<LikeRecord> {

    /**
     * 查询用户的所有点赞
     */
    List<Map<String, Object>> myLikes(Integer userId, Integer limit);
}
