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
   * 调用后端 GET /api/work/user/{userId}
   * 后端返回 [{workId, userId, title, description, images, likeCount, commentCount, status, createTime}]
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
      url: app.globalData.baseUrl + '/api/work/user/' + userId,
      method: 'GET',
      header: { 'Authorization': wx.getStorageSync('token') || '' },
      success: function(res) {
        if (res.data.code === 200) {
          var data = (res.data.data || []).map(function(o) {
            // 后端 images 是 JSON 字符串，取第一张
            var firstImage = '';
            if (o.images) {
              try {
                var arr = JSON.parse(o.images);
                firstImage = (arr && arr.length) ? arr[0] : '';
              } catch (e) { firstImage = ''; }
            }
            return {
              id: o.workId,
              title: o.title,
              image: firstImage || '../images/家具-1.png',
              likes: o.likeCount || 0,
              comments: o.commentCount || 0,
              views: 0  // 后端 user_work 表没有 viewCount 字段
            };
          });
          var likes = 0;
          data.forEach(function(w) { likes += w.likes; });
          that.setData({ works: data, totalLikes: likes, totalViews: 0 });
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
   * 之前模板 bindtap="onUpload" 但方法叫 onPublish, 导致无反应
   * 6/26 改名统一为 onUpload, 跳到首页加号同款发布页
   */
  onUpload: function() {
    wx.navigateTo({ url: '/pages/publish/publish' });
  },
  onPublish: function() {  // 兼容老方法名
    this.onUpload();
  },

  goBack: function() { wx.navigateBack(); }
});
