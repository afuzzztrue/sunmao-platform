package com.sunmao.ljx.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.sunmao.ljx.entity.LikeRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

/**
 * 点赞记录数据访问层
 */
@Mapper
public interface LikeRecordMapper extends BaseMapper<LikeRecord> {

    @Select("SELECT * FROM like_record WHERE user_id = #{userId} AND target_type = #{targetType} AND target_id = #{targetId} LIMIT 1")
    LikeRecord selectByUserAndTarget(@Param("userId") Integer userId,
                                      @Param("targetType") Integer targetType,
                                      @Param("targetId") Integer targetId);

    /**
     * 查询用户的所有点赞记录（用于"我的 → 我的点赞"）
     * 返回原始 like_record 行，前端根据 targetType 路由跳转
     */
    @Select("SELECT like_id     AS likeId, " +
            "       target_type AS targetType, " +
            "       target_id   AS targetId, " +
            "       create_time AS createTime " +
            "FROM like_record " +
            "WHERE user_id = #{userId} " +
            "ORDER BY create_time DESC " +
            "LIMIT #{limit}")
    List<Map<String, Object>> selectMyLikes(@Param("userId") Integer userId,
                                              @Param("limit") Integer limit);

    /**
     * 我的点赞 (含真实标题/封面, SQL 在 LikeRecordMapper.xml)
     * 返回字段: likeId, targetType, targetId, createTime, title, coverImage
     */
    List<Map<String, Object>> selectMyLikesEnriched(@Param("userId") Integer userId,
                                                     @Param("limit") Integer limit);
}
