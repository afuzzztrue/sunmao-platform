package com.sunmao.ljx.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.sunmao.ljx.entity.UserWork;
import com.sunmao.ljx.mapper.UserWorkMapper;
import com.sunmao.ljx.service.UserWorkService;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 用户作品服务实现类
 */
@Service
public class UserWorkServiceImpl extends ServiceImpl<UserWorkMapper, UserWork> implements UserWorkService {

    @Override
    public List<UserWork> getUserWorks(Integer userId) {
        return baseMapper.selectByUserId(userId);
    }
}
