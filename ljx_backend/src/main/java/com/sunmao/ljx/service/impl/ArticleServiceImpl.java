package com.sunmao.ljx.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.sunmao.ljx.common.BusinessException;
import com.sunmao.ljx.entity.Article;
import com.sunmao.ljx.entity.CollectRecord;
import com.sunmao.ljx.entity.LikeRecord;
import com.sunmao.ljx.entity.User;
import com.sunmao.ljx.mapper.ArticleMapper;
import com.sunmao.ljx.mapper.CollectRecordMapper;
import com.sunmao.ljx.mapper.LikeRecordMapper;
import com.sunmao.ljx.mapper.UserMapper;
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

    @Autowired
    private UserMapper userMapper;

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
        // 7/1 修复: getDetail 不再自动增加浏览量
        // 浏览量增长改为前端详情页 onLoad 时显式调用 /api/article/view/{articleId}
        // 避免点赞/收藏刷新时重复增加 viewCount
        return getById(articleId);
    }

    @Override
    public List<Article> getUserArticles(Integer userId) {
        return baseMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<Article>()
                .eq("user_id", userId)
                .eq("status", 1)
                .orderByDesc("create_time")
        );
    }

    /**
     * 6/26 新增: 查询用户对某篇文章的点赞/收藏状态
     */
    @Override
    public java.util.Map<String, Boolean> getUserStatus(Integer articleId, Integer userId) {
        java.util.Map<String, Boolean> status = new java.util.HashMap<>();
        if (userId == null || articleId == null) {
            status.put("liked", false);
            status.put("collected", false);
            return status;
        }
        // 1) 点赞
        LikeRecord like = likeRecordMapper.selectByUserAndTarget(userId, 1, articleId);
        status.put("liked", like != null);
        // 2) 收藏 (兼容老 articleId 记录)
        CollectRecord collect = collectRecordMapper.selectByUserAndTarget(userId, 1, articleId);
        if (collect == null) {
            collect = collectRecordMapper.selectByUserAndArticle(userId, articleId);
        }
        status.put("collected", collect != null);
        return status;
    }

    @Override
    public void incrementViewCount(Integer articleId) {
        baseMapper.incrementViewCount(articleId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void toggleLike(Integer articleId, Integer userId) {
        toggleLikeAndReturn(articleId, userId);
    }

    /**
     * 6/26 新增: 切换点赞并返回新状态
     * @return true=已赞 / false=已取消
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean toggleLikeAndReturn(Integer articleId, Integer userId) {
        LikeRecord record = likeRecordMapper.selectByUserAndTarget(userId, 1, articleId);
        if (record == null) {
            record = new LikeRecord();
            record.setUserId(userId);
            record.setTargetType(1);
            record.setTargetId(articleId);
            record.setCreateTime(LocalDateTime.now());
            likeRecordMapper.insert(record);
            baseMapper.updateLikeCount(articleId, 1);
            return true;   // 现在已赞
        } else {
            likeRecordMapper.deleteById(record.getLikeId());
            baseMapper.updateLikeCount(articleId, -1);
            return false;  // 现在未赞
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void toggleCollect(Integer articleId, Integer userId) {
        toggleCollectAndReturn(articleId, userId);
    }

    /**
     * 6/26 新增: 切换收藏并返回新状态
     * @return true=已收 / false=已取消
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean toggleCollectAndReturn(Integer articleId, Integer userId) {
        // 6/26 升级: 同时支持老 articleId 记录和新 targetType/targetId 记录
        // 1) 先按新方式 (user + type=1 + id) 查
        CollectRecord record = collectRecordMapper.selectByUserAndTarget(userId, 1, articleId);
        // 2) 查不到再按老方式 (user + articleId) 查
        if (record == null) {
            record = collectRecordMapper.selectByUserAndArticle(userId, articleId);
        }
        if (record == null) {
            // 新增: 同时写 articleId 和 targetType/targetId
            record = new CollectRecord();
            record.setUserId(userId);
            record.setArticleId(articleId);
            record.setTargetType(1);
            record.setTargetId(articleId);
            record.setCreateTime(LocalDateTime.now());
            collectRecordMapper.insert(record);
            baseMapper.updateCollectCount(articleId, 1);
            return true;   // 现在已收
        } else {
            // 兼容: 删之前先把 targetType/targetId 也补上 (老记录无值)
            if (record.getTargetType() == null) {
                record.setTargetType(1);
            }
            if (record.getTargetId() == null) {
                record.setTargetId(record.getArticleId());
            }
            collectRecordMapper.deleteById(record.getCollectId());
            baseMapper.updateCollectCount(articleId, -1);
            return false;  // 现在未收
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Integer create(Article article) {
        // 1. 校验必填
        if (article.getUserId() == null) {
            throw new BusinessException("userId 不能为空");
        }
        if (article.getCategoryId() == null) {
            throw new BusinessException("categoryId 不能为空");
        }
        if (article.getTitle() == null || article.getTitle().trim().isEmpty()) {
            throw new BusinessException("title 不能为空");
        }
        if (article.getContent() == null || article.getContent().trim().isEmpty()) {
            throw new BusinessException("content 不能为空");
        }

        // 2. 校验 userId 真实存在
        User user = userMapper.selectById(article.getUserId());
        if (user == null) {
            throw new BusinessException("用户不存在: userId=" + article.getUserId());
        }

        // 3. 设置默认值
        LocalDateTime now = LocalDateTime.now();
        article.setCreateTime(now);
        article.setUpdateTime(now);
        if (article.getViewCount() == null)     article.setViewCount(0);
        if (article.getLikeCount() == null)     article.setLikeCount(0);
        if (article.getCommentCount() == null)  article.setCommentCount(0);
        if (article.getCollectCount() == null)  article.setCollectCount(0);
        if (article.getIsHot() == null)         article.setIsHot(0);
        if (article.getIsBanner() == null)      article.setIsBanner(0);
        if (article.getStatus() == null)        article.setStatus(1);

        // 4. 插入并返回 articleId
        baseMapper.insert(article);
        return article.getArticleId();
    }
}
