package com.sunmao.ljx.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.sunmao.ljx.entity.User;

/**
 * 用户服务接口
 */
public interface UserService extends IService<User> {

    User getByOpenid(String openid);

    User getByPhone(String phone);

    User getByEmail(String email);

    User wxLogin(String openid, String unionid, String nickname, String avatar);

    User register(String phone, String email, String password, String nickname);

    User login(String account, String password);

    void updateStudyHours(Integer userId, Integer hours);

    /**
     * 读取用户偏好 JSON 字符串
     */
    String getPreferences(Integer userId);

    /**
     * 写入用户偏好 JSON 字符串
     */
    void updatePreferences(Integer userId, String preferencesJson);
}
