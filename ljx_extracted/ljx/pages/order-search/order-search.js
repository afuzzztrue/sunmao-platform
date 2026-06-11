// pages/order-search/order-search.js
const app = getApp();
const baseUrl = app.globalData.baseUrl;

Page({
  data: {
    keyword: '',
    resultList: [],
    allOrders: [],
    loading: false,
    statusMap: { 0: '待支付', 1: '已支付', 2: '已发货', 3: '已完成', 4: '已取消' }
  },

  onLoad() {
    this.loadAll();
  },

  onShow() {
    // 从 order 页面回退时如果订单数据已变，可重新拉取
    if (this.data.allOrders && this.data.allOrders.length) {
      this.applyFilter();
    }
  },

  loadAll: function() {
    var that = this;
    var userId = wx.getStorageSync('userId');
    if (!userId) {
      wx.showToast({ title: '请先登录', icon: 'none' });
      return;
    }
    that.setData({ loading: true });
    wx.request({
      url: baseUrl + '/api/product/order/my',
      data: { userId: userId },
      success: function(res) {
        that.setData({ loading: false });
        if (res.data && res.data.code === 200) {
          var all = res.data.data || [];
          that.setData({ allOrders: all });
          that.applyFilter();
        } else {
          that.setData({ allOrders: [], resultList: [] });
        }
      },
      fail: function() {
        that.setData({ loading: false, allOrders: [], resultList: [] });
        wx.showToast({ title: '网络异常', icon: 'none' });
      }
    });
  },

  /**
   * 根据 keyword 在 allOrders 中做大小写不敏感的模糊匹配
   * 匹配字段：productName
   */
  filterOrders: function(list, kw) {
    if (!list) return [];
    if (!kw || !kw.trim()) return list;
    var k = kw.trim().toLowerCase();
    return list.filter(function(o) {
      var name = (o && o.productName) ? String(o.productName).toLowerCase() : '';
      return name.indexOf(k) !== -1;
    });
  },

  applyFilter: function() {
    this.setData({
      resultList: this.filterOrders(this.data.allOrders, this.data.keyword)
    });
  },

  onSearchInput: function(e) {
    var kw = e.detail.value;
    this.setData({ keyword: kw });
    this.applyFilter();
  },

  onSearchConfirm: function(e) {
    var kw = (e.detail && e.detail.value) || this.data.keyword;
    this.setData({ keyword: kw });
    this.applyFilter();
  },

  clearKeyword: function() {
    this.setData({ keyword: '' });
    this.applyFilter();
  },

  onCancel: function() {
    wx.navigateBack();
  },

  /**
   * 点击搜索结果中的订单：回到 order 页面，并定位到该订单
   * 通过 app.globalData.highlightOrderId / highlightOrderStatus 传参
   * order 页面 onShow 中会读取这些字段做：切 tab + 滚动 + 高亮动画
   */
  goToOrder: function(e) {
    var orderId = e.currentTarget.dataset.id;
    if (orderId === undefined || orderId === null) return;
    var order = (this.data.allOrders || []).find(function(o) {
      return o.orderId === orderId;
    });
    if (!order) {
      wx.showToast({ title: '订单信息已失效', icon: 'none' });
      return;
    }
    app.globalData.highlightOrderId = orderId;
    app.globalData.highlightOrderStatus = (order.status === null || order.status === undefined) ? 0 : order.status;
    wx.navigateBack({ delta: 1 });
  }
});
