package com.sunmao.ljx.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.sunmao.ljx.entity.Comment;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 评论数据访问层
 */
@Mapper
public interface CommentMapper extends BaseMapper<Comment> {

    @Select("SELECT * FROM comment WHERE target_type = #{targetType} AND target_id = #{targetId} AND parent_id = 0 AND status = 1 ORDER BY create_time DESC")
    List<Comment> selectRootComments(@Param("targetType") Integer targetType, @Param("targetId") Integer targetId);

    @Select("SELECT * FROM comment WHERE parent_id = #{parentId} AND status = 1 ORDER BY create_time")
    List<Comment> selectReplies(@Param("parentId") Integer parentId);
}
