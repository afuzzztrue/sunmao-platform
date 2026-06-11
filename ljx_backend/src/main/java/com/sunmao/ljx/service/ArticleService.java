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
}
