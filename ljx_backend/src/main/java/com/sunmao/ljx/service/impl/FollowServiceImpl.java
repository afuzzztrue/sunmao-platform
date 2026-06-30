package com.sunmao.ljx.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.sunmao.ljx.entity.Follow;
import com.sunmao.ljx.entity.User;
import com.sunmao.ljx.mapper.FollowMapper;
import com.sunmao.ljx.mapper.UserMapper;
import com.sunmao.ljx.service.FollowService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.CollectionUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 关注关系服务实现类
 */
@Service
public class FollowServiceImpl extends ServiceImpl<FollowMapper, Follow> implements FollowService {

    @Autowired
    private UserMapper userMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void toggleFollow(Integer userId, Integer followUserId) {
        if (userId == null || followUserId == null || userId.equals(followUserId)) {
            throw new RuntimeException("不能关注自己");
        }
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

    @Override
    public List<Map<String, Object>> getFollowList(Integer userId) {
        List<Integer> followUserIds = baseMapper.selectFollowUserIds(userId);
        return buildUserInfoList(followUserIds);
    }

    @Override
    public List<Map<String, Object>> getFollowerList(Integer userId) {
        List<Integer> followerUserIds = baseMapper.selectFollowerUserIds(userId);
        return buildUserInfoList(followerUserIds);
    }

    @Override
    public boolean isFollowing(Integer userId, Integer followUserId) {
        if (userId == null || followUserId == null) {
            return false;
        }
        return baseMapper.selectByUserAndTarget(userId, followUserId) != null;
    }

    private List<Map<String, Object>> buildUserInfoList(List<Integer> userIds) {
        List<Map<String, Object>> result = new ArrayList<>();
        if (CollectionUtils.isEmpty(userIds)) {
            return result;
        }
        List<User> users = userMapper.selectBatchIds(userIds);
        // 按 userIds 顺序组装结果, 保证关注/粉丝列表的时序一致
        for (Integer userId : userIds) {
            for (User user : users) {
                if (userId.equals(user.getUserId())) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("userId", user.getUserId());
                    map.put("nickname", user.getNickname());
                    map.put("avatar", user.getAvatar());
                    result.add(map);
                    break;
                }
            }
        }
        return result;
    }
}
