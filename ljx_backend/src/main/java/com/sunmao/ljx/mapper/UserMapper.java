package com.sunmao.ljx.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.sunmao.ljx.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

/**
 * 用户数据访问层
 */
@Mapper
public interface UserMapper extends BaseMapper<User> {

    @Select("SELECT * FROM user WHERE openid = #{openid} LIMIT 1")
    User selectByOpenid(@Param("openid") String openid);

    @Select("SELECT * FROM user WHERE phone = #{phone} LIMIT 1")
    User selectByPhone(@Param("phone") String phone);

    @Select("SELECT * FROM user WHERE email = #{email} LIMIT 1")
    User selectByEmail(@Param("email") String email);

    /**
     * 读取用户偏好 JSON 字符串（可能为 null）
     */
    @Select("SELECT preferences FROM user WHERE user_id = #{userId}")
    String selectPreferences(@Param("userId") Integer userId);

    /**
     * 写入用户偏好 JSON 字符串
     */
    @Update("UPDATE user SET preferences = #{preferences} WHERE user_id = #{userId}")
    int updatePreferences(@Param("userId") Integer userId,
                           @Param("preferences") String preferences);
}
