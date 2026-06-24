// pages/my/my.js
const app = getApp();

Page({
  data: {
    userInfo: null,
    isLogin: false,
    userType: 0,
    followCount: 0,
    followerCount: 0,
    logoutFlash: false
  },

  onShow() {
    // 同步 custom-tab-bar 高亮
    if (typeof this.getTabBar === 'function' && this.getTabBar()) {
      this.getTabBar().setData({ selected: 4 });
    }
    this.checkLoginStatus();
    // 处理从 product.js 下单成功后的跳转：自动打开「我的订单」页
    if (app.globalData.pendingTab === 'orders') {
      app.globalData.pendingTab = '';
      if (this.data.isLogin) {
        wx.navigateTo({ url: '/pages/order/order' });
      }
    }
  },

  checkLoginStatus() {
    const token = wx.getStorageSync('token');
    const userId = wx.getStorageSync('userId');
    const nickname = wx.getStorageSync('nickname');
    const userType = wx.getStorageSync('userType');

    if (token && userId) {
      this.setData({
        isLogin: true,
        userType: userType || 0,
        userInfo: {
          userId: userId,
          nickname: nickname || '用户' + userId
        }
      });
      this.loadFollowCount(userId);
    } else {
      this.setData({
        isLogin: false,
        userType: 0,
        userInfo: null,
        followCount: 0,
        followerCount: 0
      });
    }
  },

  loadFollowCount(userId) {
    const baseUrl = app.globalData.baseUrl;
    wx.request({
      url: baseUrl + '/api/follow/count/' + userId,
      success: res => {
        if (res.data.code === 200) {
          this.setData({
            followCount: res.data.data.followCount,
            followerCount: res.data.data.followerCount
          });
        }
      }
    });
  },

  goToLogin() {
    if (!this.data.isLogin) {
      wx.navigateTo({
        url: '/pages/login/login'
      });
    }
  },

  /**
   * 副标题点击统一入口：catchtap 阻止冒泡，由本方法完全接管
   * - 已登录：滚动到「退出登录」按钮 + 触发短暂脉冲高亮
   * - 未登录：跳转到登录页
   */
  handleSubtitleTap: function() {
    if (this.data.isLogin) {
      var that = this;
      wx.pageScrollTo({
        selector: '#logout-btn',
        duration: 400
      });
      that.setData({ logoutFlash: true });
      setTimeout(function() {
        that.setData({ logoutFlash: false });
      }, 1600);
    } else {
      wx.navigateTo({ url: '/pages/login/login' });
    }
  },

  goToFootprint: function() { wx.navigateTo({ url: '/pages/footprint/footprint' }); },
  goToWorks: function() { wx.navigateTo({ url: '/pages/works/works' }); },
  goToDownloads: function() { wx.navigateTo({ url: '/pages/downloads/downloads' }); },
  goToLikes: function() { wx.navigateTo({ url: '/pages/likes/likes' }); },
  goToCollects: function() { wx.navigateTo({ url: '/pages/collects/collects' }); },
  goToHelp: function() { wx.navigateTo({ url: '/pages/help/help' }); },
  goToSupport: function() { wx.navigateTo({ url: '/pages/support/support' }); },
  goToSettings: function() { wx.navigateTo({ url: '/pages/settings/settings' }); },
  goToGlobalSearch: function() { wx.navigateTo({ url: '/pages/global-search/global-search' }); },

  logout() {
    wx.showModal({
      title: '提示',
      content: '确定要退出登录吗？',
      success: (res) => {
        if (res.confirm) {
          app.clearLoginInfo();
          this.setData({
            userInfo: null,
            isLogin: false,
            followCount: 0,
            followerCount: 0
          });
          wx.showToast({ title: '已退出登录', icon: 'success' });
        }
      }
    });
  },

  goToChat() {
    wx.navigateTo({ url: '/pages/chat/chat' });
  },

  goToAdmin() {
    wx.navigateTo({ url: '/pages/admin/admin' });
  },

  goToOrders() {
    wx.navigateTo({ url: '/pages/order/order' });
  },

  onLoad(options) {},
  onReady() {},
  onHide() {},
  onUnload() {},
  onPullDownRefresh() {},
  onReachBottom() {},
  onShareAppMessage() {}
});
