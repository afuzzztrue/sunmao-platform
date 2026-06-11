package com.sunmao.ljx.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.sunmao.ljx.entity.Post;

import java.util.List;

/**
 * 动态帖子服务接口
 */
public interface PostService extends IService<Post> {

    List<Post> getPostList(Integer page, Integer size);

    List<Post> getUserPosts(Integer userId);

    void toggleLike(Integer postId, Integer userId);
}
