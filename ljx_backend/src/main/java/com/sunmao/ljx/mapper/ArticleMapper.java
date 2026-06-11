package com.sunmao.ljx.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.sunmao.ljx.entity.Article;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

/**
 * 文章数据访问层
 */
@Mapper
public interface ArticleMapper extends BaseMapper<Article> {

    @Select("SELECT * FROM article WHERE is_hot = 1 AND status = 1 ORDER BY sort_order, create_time DESC LIMIT #{limit}")
    List<Article> selectHotList(@Param("limit") Integer limit);

    @Select("SELECT * FROM article WHERE category_id = #{categoryId} AND status = 1 ORDER BY create_time DESC")
    List<Article> selectByCategoryId(@Param("categoryId") Integer categoryId);

    @Update("UPDATE article SET view_count = view_count + 1 WHERE article_id = #{articleId}")
    int incrementViewCount(@Param("articleId") Integer articleId);

    @Update("UPDATE article SET like_count = like_count + #{delta} WHERE article_id = #{articleId}")
    int updateLikeCount(@Param("articleId") Integer articleId, @Param("delta") Integer delta);

    @Update("UPDATE article SET collect_count = collect_count + #{delta} WHERE article_id = #{articleId}")
    int updateCollectCount(@Param("articleId") Integer articleId, @Param("delta") Integer delta);

    @Update("UPDATE article SET comment_count = comment_count + #{delta} WHERE article_id = #{articleId}")
    int updateCommentCount(@Param("articleId") Integer articleId, @Param("delta") Integer delta);
}
