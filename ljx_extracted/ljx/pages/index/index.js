// index.js - 榫卯首页 v2.0 抖音风
// 改造日期: 2026-06-24
// 改造范围: 仅渲染逻辑, 后端 API 完全不动

const app = getApp();
const baseUrl = app.globalData.baseUrl;

Page({
  data: {
    // 顶部横滑 tab 配置
    // 6/26 升级: 加 cid 字段 (对应后端 article.category_id), 让切换 tab 时真调后端
    // 1=结构 2=家具 3=木料 4=历史 5=教程
    topTabs: [
      { key: 'recommend', label: '推荐', cid: null },
      { key: 'follow',    label: '关注', cid: null },
      { key: 'structure', label: '结构', cid: 1 },
      { key: 'furniture', label: '家具', cid: 2 },
      { key: 'wood',      label: '木料', cid: 3 },
      { key: 'tool',      label: '工具', cid: 5 },
      { key: 'tutorial',  label: '教程', cid: 5 }
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

  /**
   * 同步 custom-tab-bar 高亮 (官方推荐写法)
   * 解决: custom-tab-bar 共享单例, 切 tab 后 selected 不会自动更新
   */
  onShow: function () {
    if (typeof this.getTabBar === 'function' && this.getTabBar()) {
      this.getTabBar().setData({ selected: 0 });
    }
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
    console.log('[index] loadArticleList called');
    wx.request({
      url: baseUrl + '/api/article/hot',
      data: { limit: 10 },
      success: res => {
        console.log('[index] /api/article/hot response:', res.data.code, (res.data.data || []).length, 'articles');
        if (res.data.code === 200) {
          // 6/29: 拼接 coverImage 完整 URL
          const list = (res.data.data || []).map(a => {
            if (a.coverImage && a.coverImage.startsWith('/uploads/')) {
              a.coverImage = baseUrl + a.coverImage;
            }
            return a;
          });
          this.setData({
            articleList: list,
            loading: false
          }, () => {
            this.splitArticleList();
          });
        }
      },
      fail: err => {
        console.error('[index] 获取文章列表失败', err);
        this.setData({ loading: false });
      }
    });
  },

  /**
   * 6/29: 拼接图片完整 URL
   */
  _fixUrl(url) {
    if (!url) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/uploads/')) return baseUrl + url;
    return url;
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
    console.log('[index] onSwitchTab:', key, 'current:', this.data.currentTab);
    if (key === this.data.currentTab) return;
    this.setData({ currentTab: key });

    const tab = this.data.topTabs.find(t => t.key === key);
    if (!tab) {
      console.warn('[index] tab not found for key:', key);
      return;
    }
    console.log('[index] tab found:', JSON.stringify(tab));

    // 推荐 / 关注 → 调热门文章接口
    if (!tab.cid) {
      console.log('[index] -> loadArticleList (recommend/follow)');
      this.loadArticleList();
      return;
    }
    // 分类 tab → 调分类接口
    console.log('[index] -> loadArticlesByCategory cid=' + tab.cid);
    this.loadArticlesByCategory(tab.cid);
  },

  /**
   * 6/26 新增: 按分类加载文章
   * GET /api/article/category/{categoryId}
   */
  loadArticlesByCategory(cid) {
    wx.showLoading({ title: '加载中...' });
    wx.request({
      url: baseUrl + '/api/article/category/' + cid,
      method: 'GET',
      success: (res) => {
        console.log('[index] /api/article/category/' + cid + ' response:', res.data.code, (res.data.data || []).length, 'articles');
        if (res.data.code === 200) {
          // 6/29: 拼接 coverImage 完整 URL
          const list = (res.data.data || []).map(a => {
            if (a.coverImage && a.coverImage.startsWith('/uploads/')) {
              a.coverImage = baseUrl + a.coverImage;
            }
            if (a.tags) {
              a.tagsList = a.tags.split(/[,，]/).map(s => s.trim()).filter(s => s);
            } else {
              a.tagsList = [];
            }
            return a;
          });
          this.setData({
            articleList: list,
            loading: false
          }, () => {
            this.splitArticleList();
          });
        } else {
          this.setData({ articleList: [] });
        }
      },
      fail: () => this.setData({ articleList: [] }),
      complete: () => wx.hideLoading()
    });
  },

  /**
   * 6/26 新增: 归一化文章数据 (tags 字符串转数组)
   */
  _normalizeArticle(a) {
    if (a.tags) {
      a.tagsList = a.tags.split(/[,，]/).map(s => s.trim()).filter(s => s);
    } else {
      a.tagsList = [];
    }
    return a;
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
    // 6/25: 跳详情页 (article-detail 已建好)
    wx.navigateTo({
      url: '/pages/article-detail/article-detail?id=' + articleId,
      fail: err => {
        console.error('跳转详情页失败', err);
        wx.showToast({ title: '详情页加载失败', icon: 'none' });
      }
    });
  },

  // ========== 生命周期 (保留) ==========

  // 6/29: 删掉了这里重复的空 onShow, 它会覆盖上面第 51 行的 onShow (tab bar 同步)

  onHide() {},

  onReady() {},

  onPullDownRefresh() {
    this.setData({ loading: true });
    this.loadBannerList();
    this.loadArticleList();
    wx.stopPullDownRefresh();
  }
});
