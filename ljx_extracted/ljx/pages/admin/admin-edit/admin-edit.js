const app = getApp();
const baseUrl = app.globalData.baseUrl;

Page({
  data: {
    isEdit: false,
    userId: null,
    form: { account: '', nickname: '', password: '', userType: 0, status: 1 },
    userTypes: ['普通用户', '传承人', '管理员']
  },

  onLoad(options) {
    if (options.userId) {
      this.setData({ isEdit: true, userId: options.userId });
      this.loadUser(options.userId);
    }
  },

  loadUser(userId) {
    var that = this;
    wx.request({
      url: baseUrl + '/api/user/info/' + userId,
      success: function(res) {
        if (res.data.code === 200 && res.data.data) {
          var u = res.data.data;
          that.setData({
            form: {
              account: u.phone || u.email || '',
              nickname: u.nickname || '',
              password: '',
              userType: u.userType || 0,
              status: u.status !== undefined ? u.status : 1
            }
          });
        }
      }
    });
  },

  onAccount(e) { this.setData({ 'form.account': e.detail.value }); },
  onNickname(e) { this.setData({ 'form.nickname': e.detail.value }); },
  onPassword(e) { this.setData({ 'form.password': e.detail.value }); },
  onTypeChange(e) { this.setData({ 'form.userType': parseInt(e.detail.value) }); },
  onStatusChange(e) { this.setData({ 'form.status': e.detail.value ? 1 : 0 }); },

  doSave() {
    var that = this;
    var form = this.data.form;
    var isEdit = this.data.isEdit;
    var userId = this.data.userId;

    if (!form.account && !isEdit) {
      wx.showToast({ title: '请输入账号', icon: 'none' });
      return;
    }

    var url, data;
    if (isEdit) {
      url = baseUrl + '/api/admin/user/update';
      data = { userId: parseInt(userId), nickname: form.nickname, password: form.password || '', userType: form.userType, status: form.status };
    } else {
      url = baseUrl + '/api/admin/user/add';
      data = { account: form.account, password: form.password || '123456', nickname: form.nickname };
    }

    wx.request({
      url: url,
      method: 'POST',
      header: {
        'Content-Type': isEdit ? 'application/json' : 'application/x-www-form-urlencoded',
        'Authorization': wx.getStorageSync('token') || ''
      },
      data: isEdit ? JSON.stringify(data) : data,
      success: function(res) {
        if (res.data.code === 200) {
          wx.showToast({ title: '保存成功', icon: 'success' });
          setTimeout(function() { wx.navigateBack(); }, 1000);
        } else {
          wx.showToast({ title: res.data.message || '保存失败', icon: 'none' });
        }
      }
    });
  }
});
