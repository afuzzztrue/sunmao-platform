package com.sunmao.ljx.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.sunmao.ljx.entity.Feedback;

/**
 * 用户反馈服务接口
 */
public interface FeedbackService extends IService<Feedback> {

    /**
     * 提交反馈（用户端调用）
     * 默认 fbType=1（功能建议），status=0（未处理）
     */
    void submit(Feedback feedback);

    /**
     * 反馈列表（管理后台用），按时间倒序
     */
    IPage<Feedback> pageQuery(Integer page, Integer size, Integer status, Integer fbType);
}
