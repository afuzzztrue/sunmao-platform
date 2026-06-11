package com.sunmao.ljx.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 用户反馈实体类
 * 对应数据库表: feedback
 *
 * fbType: 1功能建议 2联系客服 3举报 4bug 5商务
 * status: 0未处理 1已查看 2已回复 3已关闭
 */
@Data
@TableName("feedback")
public class Feedback {

    @TableId(type = IdType.AUTO)
    private Integer feedbackId;

    private Integer userId;

    private Integer fbType;

    private String content;

    private String contact;

    private String device;

    private Integer status;

    private String reply;

    private LocalDateTime replyTime;

    private LocalDateTime createTime;
}
