package com.sunmao.ljx.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.sunmao.ljx.entity.Category;
import com.sunmao.ljx.mapper.CategoryMapper;
import com.sunmao.ljx.service.CategoryService;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 分类服务实现类
 */
@Service
public class CategoryServiceImpl extends ServiceImpl<CategoryMapper, Category> implements CategoryService {

    @Override
    public List<Category> getAllCategories() {
        QueryWrapper<Category> wrapper = new QueryWrapper<>();
        wrapper.eq("status", 1).orderByAsc("sort_order");
        return list(wrapper);
    }

    @Override
    public List<Category> getCategoriesByParentId(Integer parentId) {
        return baseMapper.selectByParentId(parentId);
    }
}
