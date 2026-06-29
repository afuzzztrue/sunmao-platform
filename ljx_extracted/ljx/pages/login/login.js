// pages/login/login.js
// 登录页 6/29 新建
// 手机号或邮箱 + 密码, 实时校验

const app = getApp();

const PHONE_RE = /^1[3-9]\d{9}$/;
const EMAIL_RE = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
const PASSWORD_RE = /^.{6,20}$/;

Page({
  data: {
    account: '',
    password: '',
    accountError: '',
    passwordError: '',
    accountValid: false,
    passwordValid: false,
    canSubmit: false,
    submitting: false,
    // 记录账号类型: phone / email
    accountType: ''
  },

  onAccountInput(e) {
    const val = e.detail.value;
    let type = '';
    let error = '';
    let valid = false;

    if (!val) {
      error = '';
      valid = false;
    } else if (val.indexOf('@') !== -1) {
      // 邮箱模式
      type = 'email';
      if (!EMAIL_RE.test(val)) {
        error = '请输入正确的邮箱地址';
        valid = false;
      } else {
        error = '';
        valid = true;
      }
    } else {
      // 手机号模式
      type = 'phone';
      if (!PHONE_RE.test(val)) {
        error = '请输入正确的手机号';
        valid = false;
      } else {
        error = '';
        valid = true;
      }
    }

    this.setData({
      account: val,
      accountType: type,
      accountError: error,
      accountValid: valid
    });
    this._updateSubmit();
  },

  onPasswordInput(e) {
    const val = e.detail.value;
    let error = '';
    let valid = false;
    if (!val) {
      error = '';
      valid = false;
    } else if (!PASSWORD_RE.test(val)) {
      error = '密码需要 6-20 位';
      valid = false;
    } else {
      error = '';
      valid = true;
    }
    this.setData({ password: val, passwordError: error, passwordValid: valid });
    this._updateSubmit();
  },

  _updateSubmit() {
    const can = this.data.accountValid && this.data.passwordValid;
    this.setData({ canSubmit: can });
  },

  onSubmit() {
    if (!this.data.canSubmit || this.data.submitting) return;
    this.setData({ submitting: true });
    wx.request({
      url: app.globalData.baseUrl + '/api/user/login',
      method: 'POST',
      header: { 'content-type': 'application/x-www-form-urlencoded' },
      data: {
        account: this.data.account,
        password: this.data.password
      },
      success: (res) => {
        if (res.data.code === 200) {
          const data = res.data.data;
          // 保存登录信息到本地
          wx.setStorageSync('userId', data.userId);
          wx.setStorageSync('nickname', data.nickname);
          wx.setStorageSync('avatar', data.avatar || '');
          wx.setStorageSync('userType', data.userType);
          wx.setStorageSync('phone', data.phone || '');
          wx.setStorageSync('email', data.email || '');
          // 后端未返回 token, 生成模拟 token 与 app.js checkTokenValidity 兼容
          wx.setStorageSync('token', 'jwt_token_' + data.userId);
          wx.showToast({ title: '登录成功', icon: 'success' });
          setTimeout(() => {
            wx.switchTab({ url: '/pages/index/index' });
          }, 1500);
        } else {
          wx.showToast({ title: res.data.message || '登录失败', icon: 'none' });
        }
      },
      fail: () => {
        wx.showToast({ title: '网络错误', icon: 'none' });
      },
      complete: () => {
        this.setData({ submitting: false });
      }
    });
  },

  goToRegister() {
    wx.redirectTo({ url: '/pages/register/register' });
  }
});
