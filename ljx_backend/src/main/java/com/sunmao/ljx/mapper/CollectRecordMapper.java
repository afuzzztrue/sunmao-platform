package com.sunmao.ljx.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.sunmao.ljx.entity.CollectRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

/**
 * 收藏记录数据访问层
 * 6/26 升级: 新增 selectMyCollectsEnriched 用于"我的 → 我的收藏"页面
 */
@Mapper
public interface CollectRecordMapper extends BaseMapper<CollectRecord> {

    /**
     * 兼容老数据: 只查 articleId 的老记录
     */
    @Select("SELECT * FROM collect_record WHERE user_id = #{userId} AND article_id = #{articleId} LIMIT 1")
    CollectRecord selectByUserAndArticle(@Param("userId") Integer userId,
                                         @Param("articleId") Integer articleId);

    /**
     * 6/26 新增: 通用 - 按 userId + targetType + targetId 查重
     */
    @Select("SELECT * FROM collect_record WHERE user_id = #{userId} AND target_type = #{targetType} AND target_id = #{targetId} LIMIT 1")
    CollectRecord selectByUserAndTarget(@Param("userId") Integer userId,
                                        @Param("targetType") Integer targetType,
                                        @Param("targetId") Integer targetId);

    /**
     * 6/26 新增: 我的收藏 (含真实标题/封面), SQL 在 CollectRecordMapper.xml
     * 兼容老数据: 老 articleId 记录会按 type=1 拼接进去
     */
    List<Map<String, Object>> selectMyCollectsEnriched(@Param("userId") Integer userId,
                                                       @Param("limit") Integer limit);
}
