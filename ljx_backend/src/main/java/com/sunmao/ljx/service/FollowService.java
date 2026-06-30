package com.sunmao.ljx.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.sunmao.ljx.entity.Follow;

import java.util.List;
import java.util.Map;

/**
 * 关注关系服务接口
 */
public interface FollowService extends IService<Follow> {

    void toggleFollow(Integer userId, Integer followUserId);

    Integer getFollowCount(Integer userId);

    Integer getFollowerCount(Integer userId);

    List<Map<String, Object>> getFollowList(Integer userId);

    List<Map<String, Object>> getFollowerList(Integer userId);

    boolean isFollowing(Integer userId, Integer followUserId);
}
