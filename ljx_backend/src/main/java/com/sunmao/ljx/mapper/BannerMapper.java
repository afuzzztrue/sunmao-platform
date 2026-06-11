package com.sunmao.ljx.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.sunmao.ljx.entity.Banner;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 轮播图数据访问层
 */
@Mapper
public interface BannerMapper extends BaseMapper<Banner> {

    @Select("SELECT * FROM banner WHERE status = 1 ORDER BY sort_order")
    List<Banner> selectActiveList();
}
