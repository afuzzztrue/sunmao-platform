// index.js - 榫卯首页 v2.0 抖音风
// 改造日期: 2026-06-24
// 改造范围: 仅渲染逻辑, 后端 API 完全不动

const app = getApp();
const baseUrl = app.globalData.baseUrl;

Page({
  data: {
    // 顶部横滑 tab 配置
    topTabs: [
      { key: 'recommend', label: '推荐', badge: false },
      { key: 'follow',    label: '关注', badge: false },
      { key: 'structure', label: '结构', badge: false },
      { key: 'furniture', label: '家具', badge: false },
      { key: 'wood',      label: '木料', badge: false },
      { key: 'tool',      label: '工具', badge: false },
      { key: 'tutorial',  label: '教程', badge: false }
    ],
    currentTab: 'recommend',

    // 搜索浮层
    showSearch: false,
    hotKeywords: ['明式家具', '燕尾榫', '紫檀', '官帽椅', '明式圈椅'],

    // 轮播图
    bannerList: [],

    // 文章列表 (用于瀑布流)
    articleList: [],

    // 瀑布流左/右列
    leftList: [],
    rightList: [],

    // 加载状态
    loading: true
  },

  onLoad: function () {
    this.loadBannerList();
    this.loadArticleList();
  },

  // ========== 原有 API 调用 (完全不动) ==========

  loadBannerList() {
    wx.request({
      url: baseUrl + '/api/banner/list',
      success: res => {
        if (res.data.code === 200) {
          const bannerList = res.data.data.map(item => item.imageUrl);
          this.setData({ bannerList });
        }
      },
      fail: err => {
        console.error('获取轮播图失败', err);
      }
    });
  },

  loadArticleList() {
    wx.request({
      url: baseUrl + '/api/article/hot',
      data: { limit: 10 },
      success: res => {
        if (res.data.code === 200) {
          this.setData({
            articleList: res.data.data,
            loading: false
          }, () => {
            this.splitArticleList();
          });
        }
      },
      fail: err => {
        console.error('获取文章列表失败', err);
        this.setData({ loading: false });
      }
    });
  },

  // ========== 双列瀑布流拆分 ==========

  splitArticleList() {
    const left = [];
    const right = [];
    this.data.articleList.forEach((item, index) => {
      if (index % 2 === 0) {
        left.push(item);
      } else {
        right.push(item);
      }
    });
    this.setData({ leftList: left, rightList: right });
  },

  // ========== 顶部 tab 交互 ==========

  onSwitchTab(e) {
    const key = e.currentTarget.dataset.key;
    this.setData({ currentTab: key });
    // TODO: 按 tab key 调用 /api/article/category/{id} 或 /api/article/follow
  },

  // ========== 搜索浮层 ==========

  onTapSearch() {
    this.setData({ showSearch: true });
  },

  onCloseSearch() {
    this.setData({ showSearch: false });
  },

  onSearchConfirm(e) {
    const keyword = e.detail.value;
    if (!keyword || !keyword.trim()) {
      wx.showToast({ title: '请输入搜索词', icon: 'none' });
      return;
    }
    wx.navigateTo({
      url: '/pages/global-search/global-search?keyword=' + encodeURIComponent(keyword)
    });
    this.setData({ showSearch: false });
  },

  // ========== 侧边菜单 (占位) ==========

  onTapMenu() {
    wx.showActionSheet({
      itemList: ['技艺教程', '传承人', '故事', '作品', '取消'],
      success: res => {
        if (res.tapIndex < 4) {
          wx.showToast({
            title: '功能开发中',
            icon: 'none'
          });
        }
      }
    });
  },

  // ========== 瀑布流卡片点击 ==========

  onTapCard(e) {
    const articleId = e.currentTarget.dataset.id;
    // TODO 下一轮: 新建 pages/article-detail 页面后, 改为:
    //   wx.navigateTo({ url: '/pages/article-detail/article-detail?id=' + articleId });
    wx.showToast({
      title: '详情页开发中 #' + articleId,
      icon: 'none'
    });
  },

  // ========== 生命周期 (保留) ==========

  onShow() {},

  onHide() {},

  onReady() {},

  onPullDownRefresh() {
    this.setData({ loading: true });
    this.loadBannerList();
    this.loadArticleList();
    wx.stopPullDownRefresh();
  }
});
