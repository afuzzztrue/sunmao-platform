package com.sunmao.ljx.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.sunmao.ljx.entity.Feedback;
import com.sunmao.ljx.mapper.FeedbackMapper;
import com.sunmao.ljx.service.FeedbackService;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

/**
 * 用户反馈服务实现类
 */
@Service
public class FeedbackServiceImpl extends ServiceImpl<FeedbackMapper, Feedback> implements FeedbackService {

    @Override
    public void submit(Feedback feedback) {
        if (feedback.getFbType() == null) feedback.setFbType(1);
        if (feedback.getStatus() == null) feedback.setStatus(0);
        if (feedback.getContent() == null || feedback.getContent().trim().isEmpty()) {
            throw new com.sunmao.ljx.common.BusinessException("反馈内容不能为空");
        }
        feedback.setCreateTime(LocalDateTime.now());
        save(feedback);
    }

    @Override
    public IPage<Feedback> pageQuery(Integer page, Integer size, Integer status, Integer fbType) {
        QueryWrapper<Feedback> qw = new QueryWrapper<>();
        if (status != null) qw.eq("status", status);
        if (fbType != null)  qw.eq("fb_type", fbType);
        qw.orderByDesc("create_time");
        return page(new Page<>(page, size), qw);
    }
}
