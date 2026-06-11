package com.sunmao.ljx.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.sunmao.ljx.entity.UserWork;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 用户作品数据访问层
 */
@Mapper
public interface UserWorkMapper extends BaseMapper<UserWork> {

    @Select("SELECT * FROM user_work WHERE user_id = #{userId} AND status = 1 ORDER BY create_time DESC")
    List<UserWork> selectByUserId(@Param("userId") Integer userId);
}
