// index.js
const app = getApp();
const baseUrl = app.globalData.baseUrl;
console.log(app,899)

Page({
  data: {
    dataList: [],
    bannerList: [],
    hotList: [],
    articleList: []
  },

  onLoad: function() {
    console.log('index加载页面的时候触发-onLoad');
    this.loadBannerList();
    this.loadHotList();
    this.loadArticleList();
  },

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

  loadHotList() {
    wx.request({
      url: baseUrl + '/api/article/hot',
      data: { limit: 4 },
      success: res => {
        if (res.data.code === 200) {
          const hotList = res.data.data.map(item => item.coverImage);
          this.setData({ hotList });
        }
      },
      fail: err => {
        console.error('获取热门内容失败', err);
      }
    });
  },

  loadArticleList() {
    wx.request({
      url: baseUrl + '/api/article/hot',
      data: { limit: 10 },
      success: res => {
        if (res.data.code === 200) {
          this.setData({ articleList: res.data.data });
        }
      },
      fail: err => {
        console.error('获取文章列表失败', err);
      }
    });
  },

  onShow() {
    console.log('index进入页面-onshow');
  },

  onHide() {
    console.log('index离开页面-onHide');
  },

  onReady() {
    console.log('index页面渲染完成-onReady');
  },

  onPullDownRefresh() {
    console.log('index下拉刷新页面，获取最新数据-onPullDownRefresh');
    this.loadBannerList();
    this.loadHotList();
    this.loadArticleList();
    wx.stopPullDownRefresh();
  }
});
