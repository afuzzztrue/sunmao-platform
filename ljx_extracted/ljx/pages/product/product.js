const app = getApp();
const baseUrl = app.globalData.baseUrl;

Page({
  data: {
    product: {},
    productId: null
  },

  onLoad(options) {
    if (options.id) {
      this.setData({ productId: options.id });
      this.loadDetail(options.id);
    }
  },

  loadDetail(id) {
    wx.request({
      url: baseUrl + '/api/product/detail/' + id,
      success: res => {
        if (res.data.code === 200) {
          this.setData({ product: res.data.data || {} });
        }
      }
    });
  },

  doBuy() {
    var that = this;
    var userId = wx.getStorageSync('userId');
    if (!userId) {
      wx.showToast({ title: '请先登录', icon: 'none' });
      return;
    }
    wx.request({
      url: baseUrl + '/api/product/order/create',
      method: 'POST',
      header: { 'Content-Type': 'application/x-www-form-urlencoded' },
      data: { productId: this.data.productId, userId: userId, quantity: 1 },
      success: function(res) {
        if (res.data.code === 200) {
          wx.showToast({ title: '下单成功！', icon: 'success' });
          // 标记「我的订单」待打开，让 my 页面 onShow 时自动跳转
          app.globalData.pendingTab = 'orders';
          setTimeout(function() {
            wx.switchTab({ url: '/pages/my/my' });
          }, 1000);
        } else {
          wx.showToast({ title: '下单失败', icon: 'none' });
        }
      },
      fail: function() {
        wx.showToast({ title: '网络异常，请稍后再试', icon: 'none' });
      }
    });
  }
});
