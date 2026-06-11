package com.sunmao.ljx.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

/**
 * 全局搜索 Mapper（5 表 UNION ALL 聚合查询）
 */
@Mapper
public interface SearchMapper {

    /**
     * 跨 5 张表（article / user_work / course / post / 结构类 article）的 LIKE 搜索
     *
     * @param kw    搜索关键词
     * @param limit 返回上限
     * @return 命中列表，每条: {type, id, title, desc, image}
     *         type 1=文章 2=作品 3=课程 4=帖子 5=结构
     */
    List<Map<String, Object>> globalSearch(@Param("kw") String kw,
                                            @Param("limit") Integer limit);
}
