// pages/register/register.js
const app = getApp();

Page({
  data: {
    account: '',
    password: '',
    confirmPassword: '',
    nickname: '',
    loading: false
  },

  inputAccount(e) {
    this.setData({ account: e.detail.value });
  },

  inputPassword(e) {
    this.setData({ password: e.detail.value });
  },

  inputConfirmPassword(e) {
    this.setData({ confirmPassword: e.detail.value });
  },

  inputNickname(e) {
    this.setData({ nickname: e.detail.value });
  },

  doRegister() {
    const { account, password, confirmPassword, nickname } = this.data;

    // 参数校验
    if (!account || account.trim().length < 4) {
      wx.showToast({ title: '账号至少4位', icon: 'none' });
      return;
    }
    if (!password || password.length < 6) {
      wx.showToast({ title: '密码至少6位', icon: 'none' });
      return;
    }
    if (password !== confirmPassword) {
      wx.showToast({ title: '两次密码不一致', icon: 'none' });
      return;
    }

    this.setData({ loading: true });
    const baseUrl = app.globalData.baseUrl;

    console.log('正在请求注册接口:', baseUrl + '/api/user/register');

    wx.request({
      url: baseUrl + '/api/user/register',
      method: 'POST',
      header: { 'Content-Type': 'application/x-www-form-urlencoded' },
      data: {
        account: account,
        password: password,
        nickname: nickname || account
      },
      timeout: 10000,
      success: res => {
        console.log('注册响应:', res);
        if (res.data.code === 200) {
          wx.showToast({ title: '注册成功，请登录', icon: 'success' });
          setTimeout(() => {
            wx.navigateBack();
          }, 1500);
        } else {
          wx.showToast({ title: res.data.msg || res.data.message || '注册失败', icon: 'none' });
        }
      },
      fail: err => {
        console.error('注册请求失败:', err);
        wx.showModal({
          title: '连接失败',
          content: '无法连接到后端服务器，请检查网络或后端服务是否启动',
          showCancel: false,
          confirmText: '知道了'
        });
      },
      complete: () => {
        this.setData({ loading: false });
      }
    });
  },

  goToLogin() {
    wx.navigateTo({
      url: '/pages/login/login'
    });
  }
});
