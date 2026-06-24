package com.sunmao.ljx.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.sunmao.ljx.entity.Footprint;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

/**
 * 足迹数据访问层
 * 6/26 新增: selectMyFootprintsEnriched 用于"我的足迹"页面
 */
@Mapper
public interface FootprintMapper extends BaseMapper<Footprint> {

    /**
     * 6/26 新增: 我的足迹 (含真实标题/封面), SQL 在 FootprintMapper.xml
     * 5 表 LEFT JOIN, 字段名加双引号保留大小写
     */
    List<Map<String, Object>> selectMyFootprintsEnriched(@Param("userId") Integer userId,
                                                          @Param("limit") Integer limit);
}
