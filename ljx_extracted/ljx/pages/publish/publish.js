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
   *   1. 上传所有图片到后端, 拿到 URL 列表
   *   2. 调 POST /api/article/create 提交表单
   *   3. 成功后 toast + 返回首页
   *
   * 当前 (前端先做): 第 2 步直接调, 图片用本地路径作为占位
   *   下一轮补 wx.uploadFile 上传逻辑 + 后端 create 接口
   */
  doPublish(userId) {
    const d = this.data;
    const payload = {
      userId: userId,
      categoryId: d.selectedCategory.id,
      title: d.title.trim(),
      summary: d.content.trim().substring(0, 80),
      content: d.content.trim(),
      coverImage: d.coverImage,
      images: d.images,           // TODO: 下一轮上传后改成 URL 数组
      tags: d.tagsList.join(','),
      location: ''
    };

    // TODO 下一轮: POST /api/article/create (当前接口未实现)
    console.log('发布 payload:', payload);

    wx.showToast({ title: '后端接口待实现 (下一轮)', icon: 'none' });
    this.setData({ submitting: false });

    // 下一轮: 成功后返回首页
    // setTimeout(() => wx.switchTab({ url: '/pages/index/index' }), 1500);
  }
});
