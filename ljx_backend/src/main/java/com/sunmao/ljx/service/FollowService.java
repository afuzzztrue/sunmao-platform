package com.sunmao.ljx.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.sunmao.ljx.entity.Follow;

/**
 * 关注关系服务接口
 */
public interface FollowService extends IService<Follow> {

    void toggleFollow(Integer userId, Integer followUserId);

    Integer getFollowCount(Integer userId);

    Integer getFollowerCount(Integer userId);
}
