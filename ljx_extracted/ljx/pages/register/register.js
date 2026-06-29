// pages/register/register.js
// 注册页 6/29 新建
// 5 栏: 手机号 / 邮箱 / 昵称 / 密码 / 确认密码, 实时校验

const app = getApp();

// 手机号正则: 1开头的11位数字
const PHONE_RE = /^1[3-9]\d{9}$/;
// 邮箱正则
const EMAIL_RE = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
// 昵称: 2-20 字符
const NICKNAME_RE = /^.{2,20}$/;
// 密码: 6-20 位
const PASSWORD_RE = /^.{6,20}$/;

Page({
  data: {
    phone: '',
    email: '',
    nickname: '',
    password: '',
    confirmPassword: '',
    // 校验状态
    phoneError: '',
    emailError: '',
    nicknameError: '',
    passwordError: '',
    confirmPasswordError: '',
    // 是否通过校验
    phoneValid: false,
    emailValid: false,
    nicknameValid: false,
    passwordValid: false,
    confirmPasswordValid: false,
    canSubmit: false,
    submitting: false
  },

  // ========== 实时校验 ==========

  onPhoneInput(e) {
    const val = e.detail.value;
    this.setData({ phone: val });
    if (!val) {
      this.setData({ phoneError: '', phoneValid: false });
    } else if (!PHONE_RE.test(val)) {
      this.setData({ phoneError: '请输入正确的手机号', phoneValid: false });
    } else {
      this.setData({ phoneError: '', phoneValid: true });
    }
    this._updateSubmit();
  },

  onEmailInput(e) {
    const val = e.detail.value;
    this.setData({ email: val });
    if (!val) {
      this.setData({ emailError: '', emailValid: false });
    } else if (!EMAIL_RE.test(val)) {
      this.setData({ emailError: '请输入正确的邮箱地址', emailValid: false });
    } else {
      this.setData({ emailError: '', emailValid: true });
    }
    this._updateSubmit();
  },

  onNicknameInput(e) {
    const val = e.detail.value;
    this.setData({ nickname: val });
    if (!val) {
      this.setData({ nicknameError: '', nicknameValid: false });
    } else if (!NICKNAME_RE.test(val)) {
      this.setData({ nicknameError: '昵称需要 2-20 个字符', nicknameValid: false });
    } else {
      this.setData({ nicknameError: '', nicknameValid: true });
    }
    this._updateSubmit();
  },

  onPasswordInput(e) {
    const val = e.detail.value;
    this.setData({ password: val });
    if (!val) {
      this.setData({ passwordError: '', passwordValid: false });
    } else if (!PASSWORD_RE.test(val)) {
      this.setData({ passwordError: '密码需要 6-20 位', passwordValid: false });
    } else {
      this.setData({ passwordError: '', passwordValid: true });
    }
    // 同时校验确认密码
    if (this.data.confirmPassword) {
      this._checkConfirmPassword();
    }
    this._updateSubmit();
  },

  onConfirmPasswordInput(e) {
    const val = e.detail.value;
    this.setData({ confirmPassword: val });
    this._checkConfirmPassword();
    this._updateSubmit();
  },

  _checkConfirmPassword() {
    const val = this.data.confirmPassword;
    if (!val) {
      this.setData({ confirmPasswordError: '', confirmPasswordValid: false });
    } else if (val !== this.data.password) {
      this.setData({ confirmPasswordError: '两次输入的密码不一致', confirmPasswordValid: false });
    } else {
      this.setData({ confirmPasswordError: '', confirmPasswordValid: true });
    }
  },

  _updateSubmit() {
    const d = this.data;
    const can = d.phoneValid && d.emailValid && d.nicknameValid
              && d.passwordValid && d.confirmPasswordValid;
    this.setData({ canSubmit: can });
  },

  // ========== 提交注册 ==========

  onSubmit() {
    if (!this.data.canSubmit || this.data.submitting) return;
    this.setData({ submitting: true });
    wx.request({
      url: app.globalData.baseUrl + '/api/user/register',
      method: 'POST',
      header: { 'content-type': 'application/x-www-form-urlencoded' },
      data: {
        phone: this.data.phone,
        email: this.data.email,
        nickname: this.data.nickname,
        password: this.data.password
      },
      success: (res) => {
        if (res.data.code === 200) {
          wx.showToast({ title: '注册成功', icon: 'success' });
          setTimeout(() => {
            wx.redirectTo({ url: '/pages/login/login' });
          }, 1500);
        } else {
          wx.showToast({ title: res.data.message || '注册失败', icon: 'none' });
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

  goToLogin() {
    wx.redirectTo({ url: '/pages/login/login' });
  }
});
