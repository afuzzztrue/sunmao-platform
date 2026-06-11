package com.sunmao.ljx.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.sunmao.ljx.entity.LikeRecord;
import com.sunmao.ljx.entity.Post;
import com.sunmao.ljx.mapper.LikeRecordMapper;
import com.sunmao.ljx.mapper.PostMapper;
import com.sunmao.ljx.service.PostService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 动态帖子服务实现类
 */
@Service
public class PostServiceImpl extends ServiceImpl<PostMapper, Post> implements PostService {

    @Autowired
    private LikeRecordMapper likeRecordMapper;

    @Override
    public List<Post> getPostList(Integer page, Integer size) {
        int offset = (page - 1) * size;
        return baseMapper.selectPageList(offset, size);
    }

    @Override
    public List<Post> getUserPosts(Integer userId) {
        return baseMapper.selectByUserId(userId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void toggleLike(Integer postId, Integer userId) {
        LikeRecord record = likeRecordMapper.selectByUserAndTarget(userId, 2, postId);
        if (record == null) {
            record = new LikeRecord();
            record.setUserId(userId);
            record.setTargetType(2);
            record.setTargetId(postId);
            record.setCreateTime(LocalDateTime.now());
            likeRecordMapper.insert(record);
            baseMapper.updateLikeCount(postId, 1);
        } else {
            likeRecordMapper.deleteById(record.getLikeId());
            baseMapper.updateLikeCount(postId, -1);
        }
    }
}
