package com.sunmao.ljx.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.sunmao.ljx.entity.CollectRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

/**
 * 收藏记录数据访问层
 */
@Mapper
public interface CollectRecordMapper extends BaseMapper<CollectRecord> {

    @Select("SELECT * FROM collect_record WHERE user_id = #{userId} AND article_id = #{articleId} LIMIT 1")
    CollectRecord selectByUserAndArticle(@Param("userId") Integer userId, @Param("articleId") Integer articleId);
}
