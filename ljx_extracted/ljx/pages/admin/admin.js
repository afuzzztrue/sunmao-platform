const app = getApp();
const baseUrl = app.globalData.baseUrl;

Page({
  data: {
    userList: [],
    keyword: '',
    page: 1
  },

  onShow() {
    this.loadUsers();
  },

  loadUsers() {
    wx.request({
      url: baseUrl + '/api/admin/user/list',
      data: { page: this.data.page, size: 20 },
      header: { 'Authorization': wx.getStorageSync('token') || '' },
      success: res => {
        if (res.data.code === 200 && res.data.data) {
          this.setData({ userList: res.data.data.list || [] });
        }
      },
      fail: () => {
        wx.showToast({ title: '加载失败', icon: 'none' });
      }
    });
  },

  onSearchInput(e) {
    this.setData({ keyword: e.detail.value });
  },

  doSearch() {
    var kw = this.data.keyword.trim();
    if (!kw) { this.loadUsers(); return; }
    wx.request({
      url: baseUrl + '/api/admin/user/search',
      data: { keyword: kw },
      header: { 'Authorization': wx.getStorageSync('token') || '' },
      success: res => {
        if (res.data.code === 200) {
          this.setData({ userList: res.data.data || [] });
        }
      }
    });
  },

  goAdd() {
    wx.navigateTo({ url: '/pages/admin/admin-edit/admin-edit' });
  },

  goEdit(e) {
    var user = e.currentTarget.dataset.user;
    wx.navigateTo({ url: '/pages/admin/admin-edit/admin-edit?userId=' + user.userId });
  },

  doDelete(e) {
    var that = this;
    var userId = e.currentTarget.dataset.id;
    wx.showModal({
      title: '确认',
      content: '确定要删除该用户吗？',
      success: function(res) {
        if (res.confirm) {
          wx.request({
            url: baseUrl + '/api/admin/user/delete',
            method: 'POST',
            data: { userId: userId },
            header: { 'Content-Type': 'application/x-www-form-urlencoded', 'Authorization': wx.getStorageSync('token') || '' },
            success: function(res) {
              if (res.data.code === 200) {
                wx.showToast({ title: '已删除', icon: 'success' });
                that.loadUsers();
              } else {
                wx.showToast({ title: res.data.message || '操作失败', icon: 'none' });
              }
            }
          });
        }
      }
    });
  }
});
