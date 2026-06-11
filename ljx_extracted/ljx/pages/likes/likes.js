const app = getApp();

Page({
  data: {
    filterIdx: 0,
    list: [],
    loading: true
  },

  onLoad() { this.loadFromApi(); },
  onShow() { this.loadFromApi(); },

  /**
   * 调用后端 GET /api/like/my/{userId}?limit=100
   * 后端返回 [{likeId, targetType, targetId, createTime}]
   * targetType: 1文章 2帖子 3课程 4作品 5结构
   *
   * 风险声明：本期前端仅展示原始 type/id，未跨 5 表 join 拿 title/cover，
   * 展示效果会比较简陋。如需美化卡片，需在 LikeService 内部 5 个 if 分支
   * join 各自的目标表（迭代 #2 补）。
   */
  loadFromApi: function() {
    var that = this;
    var userId = wx.getStorageSync('userId');
    if (!userId) {
      that.setData({ loading: false, list: [] });
      return;
    }
    that.setData({ loading: true });
    wx.request({
      url: app.globalData.baseUrl + '/api/like/my/' + userId + '?limit=100',
      method: 'GET',
      header: { 'Authorization': wx.getStorageSync('token') || '' },
      success: function(res) {
        if (res.data.code === 200) {
          var data = (res.data.data || []).map(function(o) {
            return {
              id: o.likeId,
              type: o.targetType,
              targetId: o.targetId,
              title: that._typeLabel(o.targetType) + ' #' + o.targetId,
              author: '',
              likes: 0,
              time: o.createTime,
              image: ''
            };
          });
          that.setData({ list: data });
        } else {
          that.setData({ list: [] });
        }
      },
      fail: function() { that.setData({ list: [] }); },
      complete: function() { that.setData({ loading: false }); }
    });
  },

  _typeLabel: function(t) {
    var map = { 1: '文章', 2: '帖子', 3: '课程', 4: '作品', 5: '结构' };
    return map[t] || '未知';
  },

  onUnlike: function(e) {
    var that = this;
    var id = e.currentTarget.dataset.id;
    wx.showModal({
      title: '提示', content: '取消点赞？', confirmColor: '#C4493D',
      success: function(res) {
        if (!res.confirm) return;
        // 本期只在前端过滤（实际取消点赞需调 /api/article/like 或 /api/post/like）
        var list = that.data.list.filter(function(o) { return o.id !== id; });
        that.setData({ list: list });
        wx.showToast({ title: '已取消', icon: 'success' });
      }
    });
  },

  goBack: function() { wx.navigateBack(); }
});
