// pages/user-profile/user-profile.js
const app = getApp();
const baseUrl = app.globalData.baseUrl;

Page({
  data: {
    userId: 0,
    currentUserId: 0,
    user: {},
    works: [],
    isFollowing: false,
    loading: true
  },

  onLoad(options) {
    const userId = parseInt(options.userId) || 0;
    const currentUserId = wx.getStorageSync('userId') || 0;
    if (!userId) {
      wx.showToast({ title: '参数错误', icon: 'none' });
      setTimeout(() => wx.navigateBack(), 1500);
      return;
    }
    this.setData({ userId, currentUserId });
    this.loadUserInfo();
    this.loadUserWorks();
    if (currentUserId && currentUserId !== userId) {
      this.loadFollowStatus();
    }
  },

  loadUserInfo() {
    wx.request({
      url: baseUrl + '/api/user/info/' + this.data.userId,
      success: (res) => {
        if (res.data.code === 200 && res.data.data) {
          this.setData({ user: res.data.data });
        }
      }
    });
  },

  loadUserWorks() {
    wx.request({
      url: baseUrl + '/api/article/user/' + this.data.userId,
      success: (res) => {
        if (res.data.code === 200 && res.data.data) {
          const works = res.data.data.map(item => {
            if (item.coverImage && !item.coverImage.startsWith('http')) {
              item.coverImage = baseUrl + item.coverImage;
            }
            return item;
          });
          this.setData({ works, loading: false });
        } else {
          this.setData({ loading: false });
        }
      },
      fail: () => {
        this.setData({ loading: false });
      }
    });
  },

  loadFollowStatus() {
    wx.request({
      url: baseUrl + '/api/follow/status?userId=' + this.data.currentUserId + '&followUserId=' + this.data.userId,
      success: (res) => {
        if (res.data.code === 200 && res.data.data) {
          this.setData({ isFollowing: !!res.data.data.following });
        }
      }
    });
  },

  onToggleFollow() {
    if (!this.data.currentUserId) {
      wx.showToast({ title: '请先登录', icon: 'none' });
      return;
    }
    wx.request({
      url: baseUrl + '/api/follow/toggle',
      method: 'POST',
      header: { 'content-type': 'application/x-www-form-urlencoded' },
      data: {
        userId: this.data.currentUserId,
        followUserId: this.data.userId
      },
      success: (res) => {
        if (res.data.code === 200) {
          this.setData({ isFollowing: !this.data.isFollowing });
          wx.showToast({ title: this.data.isFollowing ? '已关注' : '已取消关注', icon: 'none' });
        } else {
          wx.showToast({ title: res.data.message || '操作失败', icon: 'none' });
        }
      },
      fail: () => {
        wx.showToast({ title: '网络错误', icon: 'none' });
      }
    });
  },

  goToArticle(e) {
    const articleId = e.currentTarget.dataset.id;
    if (!articleId) return;
    wx.navigateTo({
      url: '/pages/article-detail/article-detail?id=' + articleId
    });
  }
});
