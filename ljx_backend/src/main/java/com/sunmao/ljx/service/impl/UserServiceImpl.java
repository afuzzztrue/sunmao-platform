package com.sunmao.ljx.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.sunmao.ljx.common.BusinessException;
import com.sunmao.ljx.entity.User;
import com.sunmao.ljx.mapper.UserMapper;
import com.sunmao.ljx.service.UserService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.DigestUtils;
import org.springframework.util.StringUtils;

import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;

/**
 * 用户服务实现类
 */
@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {

    @Override
    public User getByOpenid(String openid) {
        return baseMapper.selectByOpenid(openid);
    }

    @Override
    public User getByPhone(String phone) {
        return baseMapper.selectByPhone(phone);
    }

    @Override
    public User getByEmail(String email) {
        return baseMapper.selectByEmail(email);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public User wxLogin(String openid, String unionid, String nickname, String avatar) {
        User user = getByOpenid(openid);
        if (user == null) {
            user = new User();
            user.setOpenid(openid);
            user.setUnionid(unionid);
            user.setNickname(nickname);
            user.setAvatar(avatar);
            user.setStudyHours(0);
            user.setUserType(0);
            user.setStatus(1);
            user.setCreateTime(LocalDateTime.now());
            user.setUpdateTime(LocalDateTime.now());
            save(user);
        } else {
            user.setNickname(nickname);
            user.setAvatar(avatar);
            user.setUpdateTime(LocalDateTime.now());
            updateById(user);
        }
        return user;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public User register(String phone, String email, String password, String nickname) {
        if (StringUtils.hasText(phone) && getByPhone(phone) != null) {
            throw new BusinessException("手机号已注册");
        }
        if (StringUtils.hasText(email) && getByEmail(email) != null) {
            throw new BusinessException("邮箱已注册");
        }

        User user = new User();
        user.setPhone(phone);
        user.setEmail(email);
        user.setPassword(encryptPassword(password));
        user.setNickname(nickname);
        user.setStudyHours(0);
        user.setUserType(0);
        user.setStatus(1);
        user.setCreateTime(LocalDateTime.now());
        user.setUpdateTime(LocalDateTime.now());
        save(user);
        return user;
    }

    @Override
    public User login(String account, String password) {
        User user = null;
        if (account.contains("@")) {
            user = getByEmail(account);
        } else {
            user = getByPhone(account);
        }
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        if (!encryptPassword(password).equals(user.getPassword())) {
            throw new BusinessException("密码错误");
        }
        if (user.getStatus() == 0) {
            throw new BusinessException("账号已被禁用");
        }
        return user;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateStudyHours(Integer userId, Integer hours) {
        User user = getById(userId);
        if (user != null) {
            user.setStudyHours(user.getStudyHours() + hours);
            user.setUpdateTime(LocalDateTime.now());
            updateById(user);
        }
    }

    @Override
    public String getPreferences(Integer userId) {
        return baseMapper.selectPreferences(userId);
    }

    @Override
    public void updatePreferences(Integer userId, String preferencesJson) {
        baseMapper.updatePreferences(userId, preferencesJson);
    }

    private String encryptPassword(String password) {
        return DigestUtils.md5DigestAsHex(password.getBytes(StandardCharsets.UTF_8));
    }
}
