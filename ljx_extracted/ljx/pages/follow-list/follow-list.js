// pages/follow-list/follow-list.js
const app = getApp();
const baseUrl = app.globalData.baseUrl;

Page({
  data: {
    type: 'follow',
    userId: 0,
    list: [],
    loading: true
  },

  onLoad(options) {
    const type = options.type === 'fans' ? 'fans' : 'follow';
    const userId = parseInt(options.userId) || 0;
    this.setData({ type, userId });
    wx.setNavigationBarTitle({ title: type === 'fans' ? '粉丝' : '关注' });
    this.loadList();
  },

  loadList() {
    if (!this.data.userId) {
      this.setData({ loading: false, list: [] });
      return;
    }
    const url = this.data.type === 'fans'
      ? baseUrl + '/api/follow/fans/' + this.data.userId
      : baseUrl + '/api/follow/list/' + this.data.userId;

    wx.request({
      url: url,
      success: (res) => {
        if (res.data.code === 200 && res.data.data) {
          this.setData({ list: res.data.data });
        }
      },
      fail: () => {
        wx.showToast({ title: '加载失败', icon: 'none' });
      },
      complete: () => {
        this.setData({ loading: false });
      }
    });
  },

  goToUserProfile(e) {
    const userId = e.currentTarget.dataset.userid;
    if (!userId) return;
    wx.navigateTo({
      url: '/pages/user-profile/user-profile?userId=' + userId
    });
  }
});
