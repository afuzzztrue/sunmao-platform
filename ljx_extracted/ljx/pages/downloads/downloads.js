const app = getApp();

Page({
  data: {
    list: [],
    loading: true,
    manageMode: false,
    selectedCount: 0
  },

  onLoad() { this.loadFromApi(); },
  onShow() { this.loadFromApi(); },

  /**
   * 调用后端 GET /api/course/downloads/{userId}?limit=100
   * 后端返回 [{downloadId, courseId, downloadTime, title, coverImage, duration, difficulty, teacherId, teacherName}]
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
      url: app.globalData.baseUrl + '/api/course/downloads/' + userId + '?limit=100',
      method: 'GET',
      header: { 'Authorization': wx.getStorageSync('token') || '' },
      success: function(res) {
        if (res.data.code === 200) {
          var data = (res.data.data || []).map(function(o) {
            return {
              downloadId: o.downloadId,
              id: o.courseId,
              title: o.title || ('课程 #' + o.courseId),
              author: o.teacherName || '',
              chapters: 0,        // 后端 course 表无 chapters 字段
              image: o.coverImage || '../images/技艺教程.png',
              progress: 0,        // 进度需要额外接口，本期默认 0
              difficulty: o.difficulty,
              duration: o.duration,
              selected: false
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

  onContinue: function(e) {
    var id = e.currentTarget.dataset.id;
    wx.navigateTo({ url: '/pages/sort/sort?courseId=' + id });
  },

  toggleManage: function() {
    this.setData({ manageMode: !this.data.manageMode, selectedCount: 0 });
    var list = this.data.list.map(function(o) { o.selected = false; return o; });
    this.setData({ list: list });
  },

  onSelect: function(e) {
    if (!this.data.manageMode) return;
    var id = e.currentTarget.dataset.id;
    var list = this.data.list.map(function(o) {
      if (o.id === id) o.selected = !o.selected;
      return o;
    });
    var selectedCount = list.filter(function(o) { return o.selected; }).length;
    this.setData({ list: list, selectedCount: selectedCount });
  },

  onDelete: function() {
    var that = this;
    var selected = that.data.list.filter(function(o) { return o.selected; });
    if (selected.length === 0) {
      wx.showToast({ title: '请先选择', icon: 'none' });
      return;
    }
    wx.showModal({
      title: '提示', content: '确定删除选中的 ' + selected.length + ' 项？', confirmColor: '#C4493D',
      success: function(res) {
        if (!res.confirm) return;
        // 本期只在前端过滤（不调后端删除接口，留待后续迭代补 DELETE 接口）
        var ids = {};
        selected.forEach(function(o) { ids[o.id] = true; });
        var list = that.data.list.filter(function(o) { return !ids[o.id]; });
        that.setData({ list: list, selectedCount: 0, manageMode: false });
        wx.showToast({ title: '已删除', icon: 'success' });
      }
    });
  },

  goBack: function() { wx.navigateBack(); }
});
