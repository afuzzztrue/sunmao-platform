package com.sunmao.ljx.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.sunmao.ljx.entity.Footprint;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 浏览足迹数据访问层
 */
@Mapper
public interface FootprintMapper extends BaseMapper<Footprint> {

    @Select("SELECT * FROM footprint WHERE user_id = #{userId} ORDER BY create_time DESC LIMIT #{limit}")
    List<Footprint> selectRecentByUserId(@Param("userId") Integer userId, @Param("limit") Integer limit);
}
