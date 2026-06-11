const app = getApp();

Page({
  data: {
    filterIdx: 0,
    list: [],
    dayGroups: [],
    loading: true
  },

  onLoad() { this.loadFromApi(); },
  onShow() { this.loadFromApi(); },

  /**
   * 调用后端 GET /api/footprint/user/{userId}?limit=100
   * 后端返回 [{footprintId, userId, articleId, snapshotTitle, snapshotCover, snapshotAuthor, createTime}]
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
      url: app.globalData.baseUrl + '/api/footprint/user/' + userId + '?limit=100',
      method: 'GET',
      header: { 'Authorization': wx.getStorageSync('token') || '' },
      success: function(res) {
        if (res.data.code === 200) {
          // 把后端字段映射为前端展示字段
          var list = (res.data.data || []).map(function(o) {
            return {
              id: o.articleId,
              day: that._friendlyDay(o.createTime),
              time: that._friendlyTime(o.createTime),
              name: o.snapshotTitle || ('文章 #' + o.articleId),
              price: '',
              image: o.snapshotCover || '../images/结构-1.png',
              author: o.snapshotAuthor || ''
            };
          });
          that.setData({ list: list });
          that.applyGrouping(that.data.filterIdx);
        } else {
          that.setData({ list: [], dayGroups: [] });
        }
      },
      fail: function() { that.setData({ list: [], dayGroups: [] }); },
      complete: function() { that.setData({ loading: false }); }
    });
  },

  /** 把后端时间转为"今天/昨天/3天前/上周" */
  _friendlyDay: function(createTime) {
    if (!createTime) return '更早';
    var d = new Date(createTime.replace(/-/g, '/'));
    if (isNaN(d.getTime())) return '更早';
    var now = new Date();
    var diff = Math.floor((now - d) / 86400000);
    if (diff <= 0) return '今天';
    if (diff === 1) return '昨天';
    if (diff < 3) return '3天前';
    if (diff < 7) return '本周';
    return '上周';
  },

  _friendlyTime: function(createTime) {
    if (!createTime) return '';
    var d = new Date(createTime.replace(/-/g, '/'));
    if (isNaN(d.getTime())) return '';
    var pad = function(n) { return n < 10 ? '0' + n : '' + n; };
    return pad(d.getHours()) + ':' + pad(d.getMinutes());
  },

  applyGrouping: function(idx) {
    var all = this.data.list;
    var filtered = all;
    if (idx === 1) {
      filtered = all.filter(function(o) { return o.day === '今天' || o.day === '昨天'; });
    } else if (idx === 2) {
      filtered = all.filter(function(o) { return o.day === '今天' || o.day === '昨天' || o.day === '3天前'; });
    }
    // idx 0 全部 / idx 3 更早
    var groups = [];
    var seen = {};
    filtered.forEach(function(o) {
      if (!seen[o.day]) { seen[o.day] = true; groups.push({ day: o.day, items: [] }); }
      groups[groups.length - 1].items.push(o);
    });
    this.setData({ dayGroups: groups });
  },

  switchFilter: function(e) {
    var i = parseInt(e.currentTarget.dataset.i, 10);
    this.setData({ filterIdx: i });
    this.applyGrouping(i);
  },

  goProduct: function(e) {
    wx.navigateTo({ url: '/pages/product/product?id=' + e.currentTarget.dataset.id });
  },

  goBack: function() { wx.navigateBack(); }
});
