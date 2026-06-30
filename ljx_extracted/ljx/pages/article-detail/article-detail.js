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
    collected: false,
    isLogin: false,
    currentUserId: 0,
    isFollowing: false
  },

  onLoad(options) {
    const id = parseInt(options.id);
    if (!id) {
      wx.showToast({ title: '参数错误', icon: 'none' });
      setTimeout(() => wx.navigateBack(), 1500);
      return;
    }
    const userId = wx.getStorageSync('userId') || 0;
    this.setData({ articleId: id, currentUserId: userId, isLogin: !!userId });
    this.loadArticle({ recordFootprint: true, incrementView: true });
    this.loadUserStatus();
  },

  /**
   * 6/29 新增: 把 /uploads/... 相对路径拼成完整 URL
   * 小程序 <image src> 不会自动拼 baseUrl, 必须手动拼
   */
  _fixUrl(url) {
    if (!url) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/uploads/')) return baseUrl + url;
    return url;
  },

  /**
   * 加载文章详情
   * GET /api/article/detail/{id}
   * 7/1 修复: 增加 options 参数控制是否记录足迹/增加浏览量
   * 避免点赞/收藏刷新时重复增加 viewCount 和足迹
   */
  loadArticle(options = {}) {
    const { recordFootprint = false, incrementView = false } = options;
    wx.request({
      url: baseUrl + '/api/article/detail/' + this.data.articleId,
      success: (res) => {
        if (res.data.code === 200 && res.data.data) {
          const article = res.data.data;
          // 6/29: 拼接图片完整 URL (小程序不自动拼 baseUrl)
          article.coverImage = this._fixUrl(article.coverImage);
          if (article.tags) {
            article.tagsList = article.tags.split(/[,，]/).map(s => s.trim()).filter(s => s);
          } else {
            article.tagsList = [];
          }
          if (article.images) {
            article.imagesList = article.images.split(',').map(s => s.trim()).filter(s => s).map(s => this._fixUrl(s));
          } else {
            article.imagesList = [];
          }
          this.setData({ article, loading: false });
          // 7/1: 只有初次进入详情页才记录足迹和浏览量
          if (recordFootprint) this.recordFootprint(this.data.articleId);
          if (incrementView) this.incrementView(this.data.articleId);
          // 7/1: 加载当前用户对作者的关注状态
          this.loadFollowStatus();
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
   * 7/1 新增: 显式增加浏览量
   * 只有真正查看详情时才调用，避免点赞/收藏刷新导致 viewCount 异常
   */
  incrementView(articleId) {
    wx.request({
      url: baseUrl + '/api/article/view/' + articleId,
      method: 'POST',
      fail: () => { /* 静默忽略 */ }
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
   * 7/1 新增: 加载当前用户是否已关注文章作者
   */
  loadFollowStatus() {
    const userId = wx.getStorageSync('userId');
    const authorId = this.data.article && this.data.article.userId;
    if (!userId || !authorId || userId == authorId) return;
    wx.request({
      url: baseUrl + '/api/follow/status?userId=' + userId + '&followUserId=' + authorId,
      success: (res) => {
        if (res.data.code === 200 && res.data.data) {
          this.setData({ isFollowing: !!res.data.data.following });
        }
      }
    });
  },

  /**
   * 7/1 新增: 关注 / 取消关注文章作者
   */
  onToggleFollow() {
    const userId = wx.getStorageSync('userId');
    const authorId = this.data.article && this.data.article.userId;
    if (!userId) {
      wx.showToast({ title: '请先登录', icon: 'none' });
      return;
    }
    if (!authorId || userId == authorId) {
      wx.showToast({ title: '不能关注自己', icon: 'none' });
      return;
    }
    wx.request({
      url: baseUrl + '/api/follow/toggle',
      method: 'POST',
      header: { 'content-type': 'application/x-www-form-urlencoded' },
      data: { userId: userId, followUserId: authorId },
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
          const liked = !!res.data.data.liked;
          const likeCount = res.data.data.likeCount;
          this.setData({
            liked: liked,
            'article.likeCount': likeCount !== undefined ? likeCount : this.data.article.likeCount
          });
          wx.showToast({ title: liked ? '已赞' : '已取消', icon: 'none' });
          // 7/1 修复: 不再调用 loadArticle，避免重复记录足迹和浏览量
        }
      }
    });
  },

  /**
   * 收藏 / 取消收藏
   * 6/26 升级: 使用后端返回的 collected 同步本地
   * 7/1 修复: 不再调用 loadArticle，避免重复记录足迹和浏览量
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
          const collected = !!res.data.data.collected;
          const collectCount = res.data.data.collectCount;
          this.setData({
            collected: collected,
            'article.collectCount': collectCount !== undefined ? collectCount : this.data.article.collectCount
          });
          wx.showToast({ title: collected ? '已收藏' : '已取消', icon: 'none' });
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
