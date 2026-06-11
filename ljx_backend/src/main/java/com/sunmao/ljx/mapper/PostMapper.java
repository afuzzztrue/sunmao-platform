package com.sunmao.ljx.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.sunmao.ljx.entity.Post;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

/**
 * 动态帖子数据访问层
 */
@Mapper
public interface PostMapper extends BaseMapper<Post> {

    @Select("SELECT * FROM post WHERE status = 1 ORDER BY create_time DESC LIMIT #{offset}, #{limit}")
    List<Post> selectPageList(@Param("offset") Integer offset, @Param("limit") Integer limit);

    @Select("SELECT * FROM post WHERE user_id = #{userId} AND status = 1 ORDER BY create_time DESC")
    List<Post> selectByUserId(@Param("userId") Integer userId);

    @Update("UPDATE post SET like_count = like_count + #{delta} WHERE post_id = #{postId}")
    int updateLikeCount(@Param("postId") Integer postId, @Param("delta") Integer delta);

    @Update("UPDATE post SET comment_count = comment_count + #{delta} WHERE post_id = #{postId}")
    int updateCommentCount(@Param("postId") Integer postId, @Param("delta") Integer delta);
}
