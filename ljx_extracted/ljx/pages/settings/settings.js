const app = getApp();

Page({
  data: {
    userInfo: {},
    isLogin: false,
    notify: true,
    darkMode: false,
    fontSizeLabel: '标准',
    phone: '',
    email: '',
    cacheSize: '12.6MB'
  },

  onLoad() { this.refresh(); this.loadPreferences(); },
  onShow() { this.refresh(); this.loadPreferences(); },

  refresh: function() {
    var userInfo = wx.getStorageSync('userInfo') || {};
    var isLogin = !!wx.getStorageSync('userId');
    this.setData({
      userInfo: userInfo,
      isLogin: isLogin,
      phone: userInfo.phone || '',
      email: userInfo.email || ''
    });
  },

  /**
   * 调用后端 GET /api/user/preferences/{userId}
   * 后端返回 JSON 字符串，前端解析
   */
  loadPreferences: function() {
    var that = this;
    var userId = wx.getStorageSync('userId');
    if (!userId) return;
    wx.request({
      url: app.globalData.baseUrl + '/api/user/preferences/' + userId,
      method: 'GET',
      header: { 'Authorization': wx.getStorageSync('token') || '' },
      success: function(res) {
        if (res.data.code === 200 && res.data.data) {
          try {
            var p = JSON.parse(res.data.data);
            that.setData({
              notify: p.notify !== false,
              darkMode: p.darkMode === true,
              fontSizeLabel: p.fontSize || '标准'
            });
          } catch (e) { /* 后端返回非 JSON 时静默 */ }
        }
      }
    });
  },

  /**
   * 写入后端 PUT /api/user/preferences/{userId}
   * body 为 JSON 字符串
   */
  savePreferences: function() {
    var userId = wx.getStorageSync('userId');
    if (!userId) return;
    var payload = JSON.stringify({
      notify: this.data.notify,
      darkMode: this.data.darkMode,
      fontSize: this.data.fontSizeLabel,
      language: 'zh-CN'
    });
    wx.request({
      url: app.globalData.baseUrl + '/api/user/preferences/' + userId,
      method: 'PUT',
      data: payload,
      header: {
        'Content-Type': 'application/json',
        'Authorization': wx.getStorageSync('token') || ''
      }
    });
  },

  onEditProfile: function() { wx.showToast({ title: '编辑资料（演示）', icon: 'none' }); },
  onToggleNotify: function(e) { this.setData({ notify: e.detail.value }); this.savePreferences(); },
  onToggleDark: function(e) {
    this.setData({ darkMode: e.detail.value });
    this.savePreferences();
    wx.showToast({ title: e.detail.value ? '已开启深色模式（演示）' : '已关闭', icon: 'none' });
  },

  onPickFont: function() {
    var that = this;
    wx.showActionSheet({
      itemList: ['小', '标准', '大', '特大'],
      success: function(res) {
        var labels = ['小', '标准', '大', '特大'];
        that.setData({ fontSizeLabel: labels[res.tapIndex] });
        that.savePreferences();
      }
    });
  },

  onPickLang: function() { wx.showToast({ title: '多语言暂未开放', icon: 'none' }); },
  onChangePwd: function() { wx.showToast({ title: '修改密码（演示）', icon: 'none' }); },
  onBindPhone: function() { wx.showToast({ title: '绑定手机（演示）', icon: 'none' }); },
  onBindEmail: function() { wx.showToast({ title: '绑定邮箱（演示）', icon: 'none' }); },

  onClearCache: function() {
    var that = this;
    wx.showModal({
      title: '清除缓存', content: '确定清除本地缓存吗？',
      success: function(res) {
        if (res.confirm) {
          try { wx.clearStorageSync(); } catch (e) {}
          that.setData({ cacheSize: '0KB' });
          wx.showToast({ title: '已清除', icon: 'success' });
        }
      }
    });
  },

  onPrivacy: function() {
    wx.showModal({ title: '隐私政策', content: '我们严格遵守《个人信息保护法》，仅收集必要信息用于产品功能。', showCancel: false });
  },
  onAgreement: function() {
    wx.showModal({ title: '用户协议', content: '使用本平台即视为同意《榫卯分享平台用户协议》。', showCancel: false });
  },
  onAbout: function() {
    wx.showModal({ title: '关于榫卯', content: '榫卯分享平台 v1.0.0\n让传统工艺走进现代生活。', showCancel: false });
  },

  onLogout: function() {
    var that = this;
    wx.showModal({
      title: '提示', content: '确定要退出登录吗？',
      success: function(res) {
        if (res.confirm) {
          app.clearLoginInfo();
          wx.showToast({ title: '已退出', icon: 'success' });
          setTimeout(function() { wx.navigateBack(); }, 600);
        }
      }
    });
  },

  goBack: function() { wx.navigateBack(); }
});
