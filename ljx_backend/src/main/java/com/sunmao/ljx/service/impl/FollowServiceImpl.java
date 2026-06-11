package com.sunmao.ljx.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.sunmao.ljx.entity.Follow;
import com.sunmao.ljx.mapper.FollowMapper;
import com.sunmao.ljx.service.FollowService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

/**
 * 关注关系服务实现类
 */
@Service
public class FollowServiceImpl extends ServiceImpl<FollowMapper, Follow> implements FollowService {

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void toggleFollow(Integer userId, Integer followUserId) {
        Follow follow = baseMapper.selectByUserAndTarget(userId, followUserId);
        if (follow == null) {
            follow = new Follow();
            follow.setUserId(userId);
            follow.setFollowUserId(followUserId);
            follow.setCreateTime(LocalDateTime.now());
            save(follow);
        } else {
            removeById(follow.getFollowId());
        }
    }

    @Override
    public Integer getFollowCount(Integer userId) {
        return baseMapper.selectFollowCount(userId);
    }

    @Override
    public Integer getFollowerCount(Integer userId) {
        return baseMapper.selectFollowerCount(userId);
    }
}
