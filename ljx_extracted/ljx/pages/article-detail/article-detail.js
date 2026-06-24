// pages/article-detail/article-detail.js
// 文章详情页 - 6/25 新增, 6/26 升级点赞/收藏状态同步
// 入口: 首页 onTapCard (传 id) / publish 成功后跳 (传 id)

const app = getApp();
const baseUrl = app.globalData.baseUrl;

Page({
  data: {
    articleId: 0,
    article: null,
    loading: true,
    liked: false,
    collected: false
  },

  onLoad(options) {
    const id = parseInt(options.id);
    if (!id) {
      wx.showToast({ title: '参数错误', icon: 'none' });
      setTimeout(() => wx.navigateBack(), 1500);
      return;
    }
    this.setData({ articleId: id });
    this.loadArticle();
    this.loadUserStatus();  // 6/26 新增: 加载当前用户对该文章的点赞/收藏状态
    this.recordFootprint(id);  // 6/26 新增: 记录浏览足迹
  },

  /**
   * 加载文章详情
   * GET /api/article/detail/{id}
   */
  loadArticle() {
    wx.request({
      url: baseUrl + '/api/article/detail/' + this.data.articleId,
      success: (res) => {
        if (res.data.code === 200 && res.data.data) {
          // 解析 tags 字符串为数组 (逗号分隔)
          const article = res.data.data;
          if (article.tags) {
            article.tagsList = article.tags.split(/[,，]/).map(s => s.trim()).filter(s => s);
          } else {
            article.tagsList = [];
          }
          // 解析 images 字符串为数组
          if (article.images) {
            article.imagesList = article.images.split(',').map(s => s.trim()).filter(s => s);
          } else {
            article.imagesList = [];
          }
          this.setData({ article, loading: false });
        } else {
          wx.showToast({ title: '文章不存在', icon: 'none' });
          setTimeout(() => wx.navigateBack(), 1500);
        }
      },
      fail: (err) => {
        console.error('加载文章失败', err);
        wx.showToast({ title: '网络错误', icon: 'none' });
        this.setData({ loading: false });
      }
    });
  },

  /**
   * 6/26 新增: 记录浏览足迹 (用于"我的足迹"页面)
   * 静默调用, 失败也不打扰用户
   */
  recordFootprint(articleId) {
    const userId = wx.getStorageSync('userId');
    if (!userId) return;
    wx.request({
      url: baseUrl + '/api/footprint/add',
      method: 'POST',
      header: { 'content-type': 'application/x-www-form-urlencoded' },
      data: {
        userId: userId,
        articleId: articleId,
        snapshotTitle: this.data.article ? this.data.article.title : '',
        snapshotCover: this.data.article ? this.data.article.coverImage : '',
        snapshotAuthor: '榫卯'
      },
      fail: () => { /* 静默忽略 */ }
    });
  },

  /**
   * 6/26 新增: 加载当前用户对文章的点赞/收藏状态
   * GET /api/article/status?articleId=1&userId=12
   * 解决"已点赞状态下再点导致本地+1 后端-1"的不一致
   */
  loadUserStatus() {
    const userId = wx.getStorageSync('userId');
    if (!userId) return;  // 未登录, liked/collected 保持默认 false
    wx.request({
      url: baseUrl + '/api/article/status',
      method: 'GET',
      data: { articleId: this.data.articleId, userId: userId },
      success: (res) => {
        if (res.data.code === 200 && res.data.data) {
          this.setData({
            liked: !!res.data.data.liked,
            collected: !!res.data.data.collected
          });
        }
      }
    });
  },

  /**
   * 点赞 / 取消点赞
   * 6/26 升级: 使用后端返回的 liked 同步本地, 不再"盲反转"
   */
  onTapLike() {
    const userId = wx.getStorageSync('userId');
    if (!userId) {
      wx.showToast({ title: '请先登录', icon: 'none' });
      return;
    }
    wx.request({
      url: baseUrl + '/api/article/like',
      method: 'POST',
      header: { 'content-type': 'application/x-www-form-urlencoded' },
      data: { articleId: this.data.articleId, userId: userId },
      success: (res) => {
        if (res.data.code === 200 && res.data.data) {
          // 用后端返回值同步本地
          this.setData({ liked: !!res.data.data.liked });
          wx.showToast({ title: res.data.data.liked ? '已赞' : '已取消', icon: 'none' });
          // 刷新文章数据以更新 likeCount
          this.loadArticle();
        }
      }
    });
  },

  /**
   * 收藏 / 取消收藏
   * 6/26 升级: 使用后端返回的 collected 同步本地
   */
  onTapCollect() {
    const userId = wx.getStorageSync('userId');
    if (!userId) {
      wx.showToast({ title: '请先登录', icon: 'none' });
      return;
    }
    wx.request({
      url: baseUrl + '/api/article/collect',
      method: 'POST',
      header: { 'content-type': 'application/x-www-form-urlencoded' },
      data: { articleId: this.data.articleId, userId: userId },
      success: (res) => {
        if (res.data.code === 200 && res.data.data) {
          this.setData({ collected: !!res.data.data.collected });
          wx.showToast({ title: res.data.data.collected ? '已收藏' : '已取消', icon: 'none' });
          this.loadArticle();
        }
      }
    });
  },

  /**
   * 评论 (TODO 下一轮)
   */
  onTapComment() {
    wx.showToast({ title: '评论功能开发中', icon: 'none' });
  },

  /**
   * 分享
   */
  onShareAppMessage() {
    return {
      title: this.data.article ? this.data.article.title : '榫卯非遗',
      path: '/pages/article-detail/article-detail?id=' + this.data.articleId
    };
  }
});
