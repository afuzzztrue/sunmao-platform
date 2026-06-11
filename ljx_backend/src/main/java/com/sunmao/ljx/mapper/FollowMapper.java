package com.sunmao.ljx.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.sunmao.ljx.entity.Follow;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

/**
 * 关注关系数据访问层
 */
@Mapper
public interface FollowMapper extends BaseMapper<Follow> {

    @Select("SELECT * FROM follow WHERE user_id = #{userId} AND follow_user_id = #{followUserId} LIMIT 1")
    Follow selectByUserAndTarget(@Param("userId") Integer userId, @Param("followUserId") Integer followUserId);

    @Select("SELECT COUNT(*) FROM follow WHERE user_id = #{userId}")
    Integer selectFollowCount(@Param("userId") Integer userId);

    @Select("SELECT COUNT(*) FROM follow WHERE follow_user_id = #{userId}")
    Integer selectFollowerCount(@Param("userId") Integer userId);
}
