package com.sunmao.ljx.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.sunmao.ljx.entity.UserWork;

import java.util.List;

/**
 * 用户作品服务接口
 */
public interface UserWorkService extends IService<UserWork> {

    List<UserWork> getUserWorks(Integer userId);
}
