// pages/login/login.js
const app = getApp();

Page({
  data: {
    account: '',
    password: '',
    loading: false
  },

  inputAccount(e) {
    this.setData({ account: e.detail.value });
  },

  inputPassword(e) {
    this.setData({ password: e.detail.value });
  },

  doLogin() {
    const { account, password } = this.data;

    // 参数校验
    if (!account || account.trim().length === 0) {
      wx.showToast({ title: '请输入账号', icon: 'none' });
      return;
    }
    if (!password || password.length === 0) {
      wx.showToast({ title: '请输入密码', icon: 'none' });
      return;
    }

    // ========== 临时测试模式（后端不通时使用） ==========
    if (account === 'test' && password === '123456') {
      console.log('使用测试模式登录');
      wx.setStorageSync('token', 'jwt_token_1');
      wx.setStorageSync('userId', 1);
      wx.setStorageSync('nickname', '测试用户');
      wx.setStorageSync('phone', '13800138000');
      wx.setStorageSync('avatar', '');
      wx.setStorageSync('userType', 2);
      app.globalData.userInfo = { userId: 1, nickname: '测试用户' };
      wx.showToast({ title: '登录成功（测试模式）', icon: 'success' });
      setTimeout(() => {
        wx.switchTab({ url: '/pages/my/my' });
      }, 1500);
      return;
    }
    // ==================================================

    this.setData({ loading: true });
    const baseUrl = app.globalData.baseUrl;

    console.log('正在请求后端接口:', baseUrl + '/api/user/login');

    wx.request({
      url: baseUrl + '/api/user/login',
      method: 'POST',
      header: { 'Content-Type': 'application/x-www-form-urlencoded' },
      data: {
        account: account,
        password: password
      },
      timeout: 10000,
      success: res => {
        console.log('后端响应:', res);
        if (res.data.code === 200) {
          // 登录成功，保存用户信息
          const userData = res.data.data;
          const userId = userData.userId;
          const nickname = userData.nickname || account;
          const avatar = userData.avatar || '';
          const studyHours = userData.studyHours || 0;

          // 生成token格式用于本地存储
          const token = 'jwt_token_' + userId;

          // 保存到本地存储
          wx.setStorageSync('token', token);
          wx.setStorageSync('userId', userId);
          wx.setStorageSync('nickname', nickname);
          wx.setStorageSync('avatar', avatar);
          wx.setStorageSync('userType', userData.userType || 0);
          app.globalData.userInfo = { userId: userId, nickname: nickname, avatar: avatar, studyHours: studyHours };

          wx.showToast({ title: '登录成功', icon: 'success' });
          setTimeout(() => {
            wx.switchTab({ url: '/pages/my/my' });
          }, 1500);
        } else {
          wx.showToast({ title: res.data.msg || res.data.message || '登录失败', icon: 'none' });
        }
      },
      fail: err => {
        console.error('网络请求失败详情:', err);
        wx.showModal({
          title: '连接失败',
          content: '无法连接到后端服务器\n\n已启用测试模式\n请使用账号：test\n密码：123456',
          showCancel: false,
          confirmText: '知道了'
        });
      },
      complete: () => {
        this.setData({ loading: false });
      }
    });
  },

  goToRegister() {
    wx.navigateTo({
      url: '/pages/register/register'
    });
  }
});
