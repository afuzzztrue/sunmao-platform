// pages/footprint/footprint.js
// 我的足迹 (6/26 升级: 调真实后端 + 按日期分组 + 支持点击跳详情)
const app = getApp();

Page({
  data: {
    list: [],
    dayGroups: [],
    loading: true
  },

  onLoad() { this.loadFromApi(); },
  onShow() { this.loadFromApi(); },

  /**
   * 调用后端 GET /api/footprint/my/{userId}?limit=100
   * 返回: [{footprintId, targetType, targetId, createTime, title, coverImage}]
   * 6/26 升级: 后端 FootprintService 需要做类似 likes 的 LEFT JOIN 拿到 title/cover
   */
  loadFromApi: function() {
    var that = this;
    var userId = wx.getStorageSync('userId');
    if (!userId) {
      that.setData({ loading: false, list: [], dayGroups: [] });
      return;
    }
    that.setData({ loading: true });
    wx.request({
      url: app.globalData.baseUrl + '/api/footprint/my/' + userId + '?limit=100',
      method: 'GET',
      header: { 'Authorization': wx.getStorageSync('token') || '' },
      success: function(res) {
        if (res.data.code === 200) {
          var data = (res.data.data || []).map(function(o) {
            var t = o.targetType;
            // 6/29: 拼接 coverImage 完整 URL
            var cover = o.coverImage || '';
            if (cover && cover.indexOf('/uploads/') === 0) {
              cover = app.globalData.baseUrl + cover;
            }
            return {
              id: o.footprintId,
              targetType: t,
              typeName: that._typeLabel(t),
              targetId: o.targetId,
              title: o.title || (that._typeLabel(t) + ' #' + o.targetId),
              coverImage: cover,
              time: that._formatTime(o.createTime)
            };
          });
          that.setData({ list: data, dayGroups: that._groupByDay(data) });
        } else {
          that.setData({ list: [], dayGroups: [] });
        }
      },
      fail: function() { that.setData({ list: [], dayGroups: [] }); },
      complete: function() { that.setData({ loading: false }); }
    });
  },

  _typeLabel: function(t) {
    var map = { 1: '文章', 2: '帖子', 3: '课程', 4: '作品', 5: '结构' };
    return map[t] || '未知';
  },

  _formatTime: function(s) {
    if (!s) return '';
    // 格式: 2026-06-24T16:45:00 → 06-24 16:45
    return String(s).replace('T', ' ').substring(5, 16);
  },

  /**
   * 按日期分组 (今天/昨天/具体日期)
   */
  _groupByDay: function(list) {
    var groups = {};
    list.forEach(function(o) {
      var day = (o.time || '').substring(0, 5);  // MM-DD
      if (!groups[day]) groups[day] = [];
      groups[day].push(o);
    });
    return Object.keys(groups).map(function(d) {
      return { day: d, items: groups[d] };
    });
  },

  /**
   * 点击卡片 → 跳转到详情页
   * 目前各类型都先跳 article-detail 兜底
   */
  onTapCard: function(e) {
    var type = e.currentTarget.dataset.type;
    var targetId = e.currentTarget.dataset.id;
    if (!targetId) {
      wx.showToast({ title: '数据异常', icon: 'none' });
      return;
    }
    wx.navigateTo({
      url: '/pages/article-detail/article-detail?id=' + targetId,
      fail: function() {
        wx.showToast({ title: '详情页暂未实现', icon: 'none' });
      }
    });
  },

  goBack: function() { wx.navigateBack(); }
});
