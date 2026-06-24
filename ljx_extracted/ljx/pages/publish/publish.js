// pages/publish/publish.js
// 发布作品页面 - 前端
// 创建: 2026-06-24
// 后端: 调用 POST /api/article/create, 下一轮实现

const app = getApp();
const baseUrl = app.globalData.baseUrl;
const MAX_IMAGES = 9;

Page({
  data: {
    // 分类 (与后端 category 表的 5 个分类对齐)
    categoryList: [
      { id: 1, name: '结构' },
      { id: 2, name: '家具' },
      { id: 3, name: '木料' },
      { id: 4, name: '历史' },
      { id: 5, name: '教程' }
    ],
    selectedCategory: {},

    // 表单
    coverImage: '',
    title: '',
    content: '',
    tagsInput: '',
    tagsList: [],
    images: [],

    // 状态
    submitting: false
  },

  onLoad() {
    // 读取登录态的 userId (用于发布时传给后端)
    const userId = wx.getStorageSync('userId');
    if (!userId) {
      wx.showToast({ title: '请先登录', icon: 'none' });
    }
  },

  // ========== 表单输入 ==========

  onTitleInput(e) {
    this.setData({ title: e.detail.value });
  },

  onContentInput(e) {
    this.setData({ content: e.detail.value });
  },

  onCategoryChange(e) {
    const idx = e.detail.value;
    this.setData({ selectedCategory: this.data.categoryList[idx] });
  },

  onTagsInput(e) {
    const raw = e.detail.value;
    const tagsList = raw
      .split(/[,，]/)
      .map(s => s.trim())
      .filter(s => s.length > 0)
      .slice(0, 5);
    this.setData({ tagsInput: raw, tagsList });
  },

  // ========== 图片选择 ==========

  onChooseCover() {
    wx.chooseImage({
      count: 1,
      sizeType: ['compressed'],
      sourceType: ['album', 'camera'],
      success: res => {
        this.setData({ coverImage: res.tempFilePaths[0] });
      }
    });
  },

  onRemoveCover() {
    this.setData({ coverImage: '' });
  },

  onChooseImages() {
    const remain = MAX_IMAGES - this.data.images.length;
    wx.chooseImage({
      count: remain,
      sizeType: ['compressed'],
      sourceType: ['album', 'camera'],
      success: res => {
        this.setData({
          images: this.data.images.concat(res.tempFilePaths)
        });
      }
    });
  },

  onRemoveImage(e) {
    const idx = e.currentTarget.dataset.index;
    const images = this.data.images.slice();
    images.splice(idx, 1);
    this.setData({ images });
  },

  // ========== 顶部按钮 ==========

  onCancel() {
    if (this.hasContent()) {
      wx.showModal({
        title: '放弃发布？',
        content: '当前编辑的内容将丢失',
        confirmText: '放弃',
        cancelText: '继续编辑',
        success: res => {
          if (res.confirm) wx.navigateBack();
        }
      });
    } else {
      wx.navigateBack();
    }
  },

  onSaveDraft() {
    // TODO 下一轮: 调后端 POST /api/article/draft
    wx.showToast({ title: '草稿功能开发中', icon: 'none' });
  },

  // ========== 提交 ==========

  hasContent() {
    return this.data.title || this.data.content || this.data.coverImage
        || this.data.images.length > 0 || this.data.tagsList.length > 0;
  },

  onSubmit() {
    // 1. 校验
    const d = this.data;
    if (!d.coverImage) {
      wx.showToast({ title: '请上传封面图', icon: 'none' });
      return;
    }
    if (!d.title.trim()) {
      wx.showToast({ title: '请输入标题', icon: 'none' });
      return;
    }
    if (!d.content.trim()) {
      wx.showToast({ title: '请输入描述', icon: 'none' });
      return;
    }
    if (!d.selectedCategory.id) {
      wx.showToast({ title: '请选择分类', icon: 'none' });
      return;
    }
    if (d.images.length === 0) {
      wx.showToast({ title: '请至少上传 1 张作品图', icon: 'none' });
      return;
    }

    const userId = wx.getStorageSync('userId');
    if (!userId) {
      wx.showToast({ title: '请先登录', icon: 'none' });
      return;
    }

    this.setData({ submitting: true });
    this.doPublish(userId);
  },

  /**
   * 实际发布流程:
   *   1. 收集所有本地图片路径 (封面 + 作品图)
   *   2. wx.uploadFile × N 上传到 /api/upload, 拿 URL 列表
   *   3. POST /api/article/create 提交表单 (body 带 URL 列表)
   *   4. 成功后 Toast + redirectTo 跳到刚发布的详情页
   *
   * 6/25 接入真实后端
   */
  doPublish(userId) {
    const d = this.data;

    // 1. 收集所有图片
    const allTempFiles = [];
    if (d.coverImage) allTempFiles.push(d.coverImage);
    d.images.forEach(p => allTempFiles.push(p));

    if (allTempFiles.length === 0) {
      wx.showToast({ title: '请先选择图片', icon: 'none' });
      this.setData({ submitting: false });
      return;
    }

    // 2. 显示上传进度
    wx.showLoading({
      title: `上传中 0/${allTempFiles.length}`,
      mask: true
    });

    // 3. 顺序上传所有图片
    this.uploadFilesSequentially(allTempFiles, [])
      .then(uploadedUrls => {
        // 3.1 区分封面和作品图
        const coverUrl = uploadedUrls[0] || '';
        const imageUrls = uploadedUrls.slice(1);

        // 3.2 拼 payload
        const payload = {
          userId: userId,
          categoryId: d.selectedCategory.id,
          title: d.title.trim(),
          summary: d.content.trim().substring(0, 80),
          content: d.content.trim(),
          coverImage: coverUrl,
          images: imageUrls.join(','),  // 逗号分隔
          tags: d.tagsList.join(','),
          location: ''
        };

        console.log('发布 payload:', payload);

        // 3.3 调创建接口
        return this.requestCreateArticle(payload);
      })
      .then(articleId => {
        wx.hideLoading();
        wx.showToast({ title: '发布成功', icon: 'success' });

        // 3.4 跳到刚发布的详情页
        setTimeout(() => {
          wx.redirectTo({
            url: '/pages/article-detail/article-detail?id=' + articleId,
            fail: err => {
              console.error('跳转详情页失败', err);
              // 兜底: 跳首页
              wx.switchTab({ url: '/pages/index/index' });
            }
          });
        }, 1500);
      })
      .catch(err => {
        wx.hideLoading();
        console.error('发布失败', err);
        wx.showToast({
          title: err.message || '发布失败',
          icon: 'none',
          duration: 2500
        });
      })
      .finally(() => {
        this.setData({ submitting: false });
      });
  },

  /**
   * 顺序上传多个文件, 返回 URL 列表
   * @param {string[]} tempFiles - 本地临时路径数组
   * @param {string[]} uploadedUrls - 已上传的 URL 数组 (递归用)
   * @returns {Promise<string[]>} 全部 URL 列表
   */
  uploadFilesSequentially(tempFiles, uploadedUrls) {
    if (tempFiles.length === 0) {
      return Promise.resolve(uploadedUrls);
    }

    const [current, ...rest] = tempFiles;
    const total = uploadedUrls.length + tempFiles.length;
    const done = uploadedUrls.length + 1;

    // 更新进度
    wx.showLoading({
      title: `上传中 ${done}/${total}`,
      mask: true
    });

    return new Promise((resolve, reject) => {
      wx.uploadFile({
        url: baseUrl + '/api/upload',
        filePath: current,
        name: 'files',
        success: (res) => {
          try {
            const data = JSON.parse(res.data);
            if (data.code === 200 && data.data && data.data.length > 0) {
              const newUrls = uploadedUrls.concat(data.data);
              // 递归上传剩余文件
              this.uploadFilesSequentially(rest, newUrls)
                .then(resolve)
                .catch(reject);
            } else {
              reject(new Error(data.message || '上传失败'));
            }
          } catch (e) {
            reject(new Error('解析响应失败: ' + e.message));
          }
        },
        fail: (err) => {
          reject(new Error('网络错误: ' + (err.errMsg || '未知')));
        }
      });
    });
  },

  /**
   * 调 POST /api/article/create
   */
  requestCreateArticle(payload) {
    return new Promise((resolve, reject) => {
      wx.request({
        url: baseUrl + '/api/article/create',
        method: 'POST',
        header: { 'content-type': 'application/json' },
        data: payload,
        success: (res) => {
          if (res.data.code === 200 && res.data.data && res.data.data.articleId) {
            resolve(res.data.data.articleId);
          } else {
            reject(new Error(res.data.message || '创建失败'));
          }
        },
        fail: (err) => {
          reject(new Error('网络错误: ' + (err.errMsg || '未知')));
        }
      });
    });
  }
});
