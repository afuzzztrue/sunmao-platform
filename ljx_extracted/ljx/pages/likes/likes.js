// pages/likes/likes.js
// 我的点赞 (6/26 升级: 后端 JOIN 真实数据 + 类型徽章 + 状态同步)
const app = getApp();

Page({
  data: {
    list: [],
    loading: true
  },

  onLoad() { this.loadFromApi(); },
  onShow() { this.loadFromApi(); },

  /**
   * 调用后端 GET /api/like/my/{userId}?limit=100
   * 后端返回 (含 JOIN 真实数据):
   *   [{likeId, targetType, targetId, createTime, title, coverImage}]
   * targetType: 1文章 2帖子 3课程 4作品 5结构
   *
   * 6/26 升级: SQL 改用 LEFT JOIN + COALESCE, 字段名加双引号保留大小写
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
            var t = o.targetType;
            var cover = o.coverImage || '';
            if (cover && cover.indexOf('/uploads/') === 0) {
              cover = app.globalData.baseUrl + cover;
            }
            return {
              id: o.likeId,
              type: t,
              typeName: that._typeLabel(t),
              targetId: o.targetId,
              title: o.title || (that._typeLabel(t) + ' #' + o.targetId),
              coverImage: cover,
              time: o.createTime
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

  /**
   * 点击卡片 → 跳转到对应详情页
   */
  onTapCard: function(e) {
    var type = e.currentTarget.dataset.type;
    var targetId = e.currentTarget.dataset.targetid;
    if (!targetId) {
      wx.showToast({ title: '数据异常', icon: 'none' });
      return;
    }
    // 全部先跳 article-detail 兜底, 后续接各类型独立详情页
    wx.navigateTo({
      url: '/pages/article-detail/article-detail?id=' + targetId,
      fail: function() {
        wx.showToast({ title: '详情页暂未实现', icon: 'none' });
      }
    });
  },

  onUnlike: function(e) {
    var that = this;
    var id = e.currentTarget.dataset.id;
    var targetId = e.currentTarget.dataset.targetid;  // 6/26 新增: 拿真正的目标 ID
    var type = e.currentTarget.dataset.type;
    var userId = wx.getStorageSync('userId');

    if (!userId) {
      wx.showToast({ title: '请先登录', icon: 'none' });
      return;
    }

    wx.showModal({
      title: '提示', content: '取消点赞？', confirmColor: '#C4493D',
      success: function(res) {
        if (!res.confirm) return;

        // 6/26 升级: 真正调后端删除点赞记录, 不是只在前端过滤
        // 当前实现: 只对接了文章类型 (type=1), 走 /api/article/like 的 toggle (有则删)
        if (type === 1) {
          wx.request({
            url: app.globalData.baseUrl + '/api/article/like',
            method: 'POST',
            header: { 'content-type': 'application/x-www-form-urlencoded' },
            data: { articleId: targetId, userId: userId },
            success: function(r) {
              if (r.data.code === 200) {
                var list = that.data.list.filter(function(o) { return o.id !== id; });
                that.setData({ list: list });
                wx.showToast({ title: '已取消', icon: 'success' });
              } else {
                wx.showToast({ title: r.data.msg || '操作失败', icon: 'none' });
              }
            },
            fail: function() {
              wx.showToast({ title: '网络错误', icon: 'none' });
            }
          });
        } else {
          // 帖子/课程/作品/结构 类型的"取消点赞"后端接口下轮再做
          // 暂退化为前端过滤 (与原行为一致)
          var list = that.data.list.filter(function(o) { return o.id !== id; });
          that.setData({ list: list });
          wx.showToast({ title: '已取消', icon: 'success' });
        }
      }
    });
  },

  goBack: function() { wx.navigateBack(); }
});
