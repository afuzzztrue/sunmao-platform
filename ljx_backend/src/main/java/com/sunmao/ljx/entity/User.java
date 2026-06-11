package com.sunmao.ljx.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 用户实体类
 * 对应数据库表: user
 */
@Data
@TableName("user")
public class User {

    @TableId(type = IdType.AUTO)
    private Integer userId;

    private String openid;

    private String unionid;

    private String nickname;

    private String avatar;

    private String phone;

    private String email;

    private String password;

    private Integer gender;

    private String province;

    private String city;

    private Integer studyHours;

    private Integer userType;

    private Integer status;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;

    /**
     * 用户偏好 JSON 字符串
     * 格式: {"notify":true,"darkMode":false,"fontSize":"标准","language":"zh-CN"}
     */
    private String preferences;
}
