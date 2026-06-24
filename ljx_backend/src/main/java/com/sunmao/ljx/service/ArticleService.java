package com.sunmao.ljx.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.sunmao.ljx.entity.Article;

import java.util.List;

/**
 * 文章服务接口
 */
public interface ArticleService extends IService<Article> {

    List<Article> getHotList(Integer limit);

    List<Article> getListByCategory(Integer categoryId);

    Article getDetail(Integer articleId);

    void incrementViewCount(Integer articleId);

    void toggleLike(Integer articleId, Integer userId);

    void toggleCollect(Integer articleId, Integer userId);

    /**
     * 6/26 新增: 切换点赞并返回新状态 (true=已赞 / false=已取消)
     */
    boolean toggleLikeAndReturn(Integer articleId, Integer userId);

    /**
     * 6/26 新增: 切换收藏并返回新状态 (true=已收 / false=已取消)
     */
    boolean toggleCollectAndReturn(Integer articleId, Integer userId);

    /**
     * 6/26 新增: 查询用户对某篇文章的点赞/收藏状态
     * (用于文章详情页 onLoad 时初始化 liked/collected 本地状态)
     * @return Map, keys: liked, collected (boolean)
     */
    java.util.Map<String, Boolean> getUserStatus(Integer articleId, Integer userId);

    /**
     * 创建文章 (6/25 新增)
     * @param article 文章实体 (userId/categoryId/title/summary/content/coverImage/images/tags/location 必填)
     * @return 新插入的文章 ID
     */
    Integer create(Article article);
}
