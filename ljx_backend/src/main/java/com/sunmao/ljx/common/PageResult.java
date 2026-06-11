package com.sunmao.ljx.common;

import lombok.Data;

import java.util.List;

/**
 * 分页响应结果封装
 */
@Data
public class PageResult<T> {

    private Long total;
    private List<T> list;
    private Long current;
    private Long size;
    private Long pages;

    public PageResult(Long total, List<T> list, Long current, Long size) {
        this.total = total;
        this.list = list;
        this.current = current;
        this.size = size;
        this.pages = (total + size - 1) / size;
    }
}
