const app = getApp();

Page({
  data: {
    works: [],
    totalLikes: 0,
    totalViews: 0,
    loading: true
  },

  onLoad() { this.loadFromApi(); },
  onShow() { this.loadFromApi(); },

  /**
   * 7/1 修复: 改为调用 GET /api/article/user/{userId}
   * 原因: publish.js 实际发布的是 article 表数据, 不是 user_work 表
   * 原 /api/work/user/{userId} 查询的是 user_work 表, 所以发布后看不到
   *
   * 后端返回 [{articleId, userId, title, coverImage, likeCount, viewCount, createTime}]
   * 这里把 coverImage 相对路径拼成完整 URL
   */
  loadFromApi: function() {
    var that = this;
    var userId = wx.getStorageSync('userId');
    if (!userId) {
      that.setData({ loading: false, works: [] });
      return;
    }
    that.setData({ loading: true });
    wx.request({
      url: app.globalData.baseUrl + '/api/article/user/' + userId,
      method: 'GET',
      header: { 'Authorization': wx.getStorageSync('token') || '' },
      success: function(res) {
        if (res.data.code === 200) {
          var data = (res.data.data || []).map(function(o) {
            var cover = o.coverImage || '';
            // 7/1 修复: 拼接 baseUrl, 与 likes/collects 页面保持一致
            if (cover && cover.indexOf('/uploads/') === 0) {
              cover = app.globalData.baseUrl + cover;
            }
            return {
              id: o.articleId,
              title: o.title,
              image: cover || '../images/家具-1.png',
              likes: o.likeCount || 0,
              comments: o.commentCount || 0,
              views: o.viewCount || 0
            };
          });
          var likes = 0, views = 0;
          data.forEach(function(w) {
            likes += w.likes;
            views += w.views;
          });
          that.setData({ works: data, totalLikes: likes, totalViews: views });
        } else {
          that.setData({ works: [] });
        }
      },
      fail: function() { that.setData({ works: [] }); },
      complete: function() { that.setData({ loading: false }); }
    });
  },

  /**
   * 6/26 修复: 右上角"发布"按钮
   */
  onUpload: function() {
    wx.navigateTo({ url: '/pages/publish/publish' });
  },
  onPublish: function() {
    this.onUpload();
  },

  goBack: function() { wx.navigateBack(); }
});
