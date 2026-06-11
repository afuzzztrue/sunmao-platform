const app = getApp();
const KEY_HISTORY = 'globalSearchHistory';
const MAX_HISTORY = 10;

Page({
  data: {
    keyword: '',
    history: [],
    hotList: ['明式圈椅', '小叶紫檀', '半隐燕尾榫', '入门30天', '明式家具复制', '抱肩榫', '日式平刨'],
    resultList: [],
    typeMap: { 1: '商品', 2: '作品', 3: '课程', 4: '帖子', 5: '结构' },
    loading: false
  },

  onLoad() { this.loadHistory(); },

  loadHistory: function() {
    try {
      var h = wx.getStorageSync(KEY_HISTORY) || [];
      this.setData({ history: h });
    } catch (e) { this.setData({ history: [] }); }
  },

  saveHistory: function(kw) {
    if (!kw) return;
    var h = (wx.getStorageSync(KEY_HISTORY) || []).filter(function(x) { return x !== kw; });
    h.unshift(kw);
    if (h.length > MAX_HISTORY) h = h.slice(0, MAX_HISTORY);
    wx.setStorageSync(KEY_HISTORY, h);
    this.setData({ history: h });
  },

  onInput: function(e) { this.setData({ keyword: e.detail.value }); },
  onConfirm: function(e) { this.doSearch(e.detail.value); },

  onTapHot: function(e) {
    var kw = e.currentTarget.dataset.kw;
    this.setData({ keyword: kw });
    this.doSearch(kw);
  },

  onTapHistory: function(e) {
    var kw = e.currentTarget.dataset.kw;
    this.setData({ keyword: kw });
    this.doSearch(kw);
  },

  onClearHistory: function() {
    wx.removeStorageSync(KEY_HISTORY);
    this.setData({ history: [] });
  },

  onClearInput: function() {
    this.setData({ keyword: '', resultList: [] });
  },

  /**
   * 调用后端 GET /api/search/global?keyword=&limit=30
   * 后端返回 [{type, id, title, desc, image}]
   *   type 1=商品 2=作品 3=课程 4=帖子 5=结构
   */
  doSearch: function(kw) {
    kw = (kw || this.data.keyword || '').trim();
    if (!kw) return;
    this.setData({ keyword: kw, loading: true });
    var that = this;
    wx.request({
      url: app.globalData.baseUrl + '/api/search/global',
      method: 'GET',
      data: { keyword: kw, limit: 30 },
      header: { 'Authorization': wx.getStorageSync('token') || '' },
      success: function(res) {
        if (res.data.code === 200) {
          that.setData({ resultList: res.data.data || [] });
          that.saveHistory(kw);
        } else {
          that.setData({ resultList: [] });
        }
      },
      fail: function() { that.setData({ resultList: [] }); },
      complete: function() { that.setData({ loading: false }); }
    });
  },

  /**
   * 根据命中类型路由到对应详情页
   * type 1商品 → product  2作品 → works  3课程 → sort
   *     4帖子 → place      5结构 → sort
   */
  onTapResult: function(e) {
    var type = parseInt(e.currentTarget.dataset.type, 10);
    var id = e.currentTarget.dataset.id;
    switch (type) {
      case 1: wx.navigateTo({ url: '/pages/product/product?id=' + id }); break;
      case 2: wx.navigateTo({ url: '/pages/works/works' }); break;
      case 3: wx.switchTab({ url: '/pages/sort/sort' }); break;
      case 4: wx.navigateTo({ url: '/pages/place/place' }); break;
      case 5: wx.switchTab({ url: '/pages/sort/sort' }); break;
      default: wx.showToast({ title: '暂不支持的类别', icon: 'none' });
    }
  },

  goBack: function() { wx.navigateBack(); }
});
