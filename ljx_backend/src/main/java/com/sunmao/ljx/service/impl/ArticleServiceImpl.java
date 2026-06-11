package com.sunmao.ljx.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.sunmao.ljx.entity.Article;
import com.sunmao.ljx.entity.CollectRecord;
import com.sunmao.ljx.entity.LikeRecord;
import com.sunmao.ljx.mapper.ArticleMapper;
import com.sunmao.ljx.mapper.CollectRecordMapper;
import com.sunmao.ljx.mapper.LikeRecordMapper;
import com.sunmao.ljx.service.ArticleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 文章服务实现类
 */
@Service
public class ArticleServiceImpl extends ServiceImpl<ArticleMapper, Article> implements ArticleService {

    @Autowired
    private LikeRecordMapper likeRecordMapper;

    @Autowired
    private CollectRecordMapper collectRecordMapper;

    @Override
    public List<Article> getHotList(Integer limit) {
        return baseMapper.selectHotList(limit);
    }

    @Override
    public List<Article> getListByCategory(Integer categoryId) {
        return baseMapper.selectByCategoryId(categoryId);
    }

    @Override
    public Article getDetail(Integer articleId) {
        Article article = getById(articleId);
        if (article != null) {
            incrementViewCount(articleId);
        }
        return article;
    }

    @Override
    public void incrementViewCount(Integer articleId) {
        baseMapper.incrementViewCount(articleId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void toggleLike(Integer articleId, Integer userId) {
        LikeRecord record = likeRecordMapper.selectByUserAndTarget(userId, 1, articleId);
        if (record == null) {
            record = new LikeRecord();
            record.setUserId(userId);
            record.setTargetType(1);
            record.setTargetId(articleId);
            record.setCreateTime(LocalDateTime.now());
            likeRecordMapper.insert(record);
            baseMapper.updateLikeCount(articleId, 1);
        } else {
            likeRecordMapper.deleteById(record.getLikeId());
            baseMapper.updateLikeCount(articleId, -1);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void toggleCollect(Integer articleId, Integer userId) {
        CollectRecord record = collectRecordMapper.selectByUserAndArticle(userId, articleId);
        if (record == null) {
            record = new CollectRecord();
            record.setUserId(userId);
            record.setArticleId(articleId);
            record.setCreateTime(LocalDateTime.now());
            collectRecordMapper.insert(record);
            baseMapper.updateCollectCount(articleId, 1);
        } else {
            collectRecordMapper.deleteById(record.getCollectId());
            baseMapper.updateCollectCount(articleId, -1);
        }
    }
}
