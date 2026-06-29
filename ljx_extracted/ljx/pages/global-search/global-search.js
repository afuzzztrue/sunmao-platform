// pages/global-search/global-search.js
// 全局搜索页 (6/29 新建)
// 调后端 GET /api/search/global?keyword=xxx&limit=30
// 跨 5 表: 文章/作品/课程/帖子/结构

const app = getApp();

Page({
  data: {
    keyword: '',
    results: [],
    loading: false,
    searched: false,
    hotKeywords: ['明式家具', '燕尾榫', '紫檀', '官帽椅', '明式圈椅', '榫卯']
  },

  onLoad(options) {
    if (options.keyword) {
      this.setData({ keyword: decodeURIComponent(options.keyword) });
      this.doSearch();
    }
  },

  onInput(e) {
    this.setData({ keyword: e.detail.value });
  },

  onSearch() {
    this.doSearch();
  },

  onTapHotKeyword(e) {
    const kw = e.currentTarget.dataset.kw;
    this.setData({ keyword: kw });
    this.doSearch();
  },

  doSearch() {
    const kw = (this.data.keyword || '').trim();
    if (!kw) {
      wx.showToast({ title: '请输入搜索词', icon: 'none' });
      return;
    }
    this.setData({ loading: true, searched: true });
    wx.request({
      url: app.globalData.baseUrl + '/api/search/global',
      method: 'GET',
      data: { keyword: kw, limit: 30 },
      success: (res) => {
        if (res.data.code === 200) {
          const list = (res.data.data || []).map(o => {
            var img = o.image || '';
            if (img && img.indexOf('/uploads/') === 0) {
              img = app.globalData.baseUrl + img;
            }
            return {
              type: o.type,
              typeId: o.id,
              title: o.title || '',
              desc: o.desc || '',
              image: img,
              typeName: this._typeLabel(o.type)
            };
          });
          this.setData({ results: list });
        } else {
          this.setData({ results: [] });
        }
      },
      fail: () => {
        wx.showToast({ title: '搜索失败', icon: 'none' });
        this.setData({ results: [] });
      },
      complete: () => this.setData({ loading: false })
    });
  },

  _typeLabel(t) {
    const map = { 1: '文章', 2: '作品', 3: '课程', 4: '帖子', 5: '结构' };
    return map[t] || '未知';
  },

  onTapResult(e) {
    const id = e.currentTarget.dataset.id;
    wx.navigateTo({
      url: '/pages/article-detail/article-detail?id=' + id,
      fail: () => wx.showToast({ title: '详情页暂未实现', icon: 'none' })
    });
  },

  goBack() {
    wx.navigateBack();
  }
});
