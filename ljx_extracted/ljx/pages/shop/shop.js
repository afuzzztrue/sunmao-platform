const app = getApp();
const baseUrl = app.globalData.baseUrl;

var DEMO_FURNITURE = [
  { productId: 201, productName: '明式圈椅', price: '8800.00', coverImage: '../images/家具.jpg' },
  { productId: 202, productName: '四出头官帽椅', price: '12800.00', coverImage: '../images/家具-1.png' },
  { productId: 203, productName: '明式平头案', price: '16800.00', coverImage: '../images/家具-2.png' },
  { productId: 204, productName: '榫卯博古架', price: '9800.00', coverImage: '../images/家具-3.png' }
];

var DEMO_WOOD = [
  { productId: 301, productName: '印度小叶紫檀', price: '2800.00', coverImage: '../images/紫檀木.png' },
  { productId: 302, productName: '海南黄花梨老料', price: '6800.00', coverImage: '../images/黄花梨.png' },
  { productId: 303, productName: '老挝大红酸枝', price: '1800.00', coverImage: '../images/红木.png' },
  { productId: 304, productName: '缅甸金丝楠', price: '3600.00', coverImage: '../images/楠木.png' },
  { productId: 305, productName: '非洲鸡翅木', price: '980.00', coverImage: '../images/鸡翅木.png' }
];

var DEMO_TOOLS = [
  { productId: 401, productName: '榫卯大师五件套', price: '1280.00', coverImage: '../images/tool-set.png' },
  { productId: 402, productName: '日式平刨', price: '680.00', coverImage: '../images/tool-plane.png' },
  { productId: 403, productName: '机械鸠尾榫导板', price: '398.00', coverImage: '../images/tool-jig.png' }
];

var DEMO_COURSES = [
  { productId: 501, productName: '榫卯入门：30天从零到熟练', price: '299.00', coverImage: '../images/入门.png' },
  { productId: 502, productName: '明式家具复制实战', price: '699.00', coverImage: '../images/进阶.png' },
  { productId: 503, productName: '古建筑榫卯结构解析', price: '499.00', coverImage: '../images/高级.png' }
];

var DEMO_ALL = [].concat(DEMO_FURNITURE, DEMO_WOOD, DEMO_TOOLS, DEMO_COURSES);

// 6/29: category ID 对齐 product 表 (1家具 2木料 3工具 4课程, 0=全部)
var DEMO_MAP = {};
DEMO_MAP[0] = DEMO_ALL;
DEMO_MAP[1] = DEMO_FURNITURE;
DEMO_MAP[2] = DEMO_WOOD;
DEMO_MAP[3] = DEMO_TOOLS;
DEMO_MAP[4] = DEMO_COURSES;

function getDemoData(categoryId, keyword) {
  var list = DEMO_MAP[categoryId] || DEMO_ALL;
  if (keyword) {
    var kw = keyword.trim().toLowerCase();
    list = list.filter(function(item) {
      return item.productName.toLowerCase().indexOf(kw) !== -1;
    });
  }
  return list;
}

Page({
  data: {
    // 6/29: category ID 对齐 product 表 (0=全部 1=家具 2=木料 3=工具 4=课程)
    categories: [
      { id: 0, name: '全部' },
      { id: 1, name: '家具' },
      { id: 2, name: '木料' },
      { id: 3, name: '工具' },
      { id: 4, name: '课程' }
    ],
    currentCat: 0,
    productList: [],
    keyword: ''
  },

  onShow: function() {
    // 同步 custom-tab-bar 高亮 (商城是 tabBar.list[3], 中间 list[2] 是 + 号占位)
    if (typeof this.getTabBar === 'function' && this.getTabBar()) {
      this.getTabBar().setData({ selected: 3 });
    }
    this.loadProducts();
  },

  loadProducts: function() {
    var that = this;
    var kw = that.data.keyword;
    var apiUrl = kw ? baseUrl + '/api/product/search' : baseUrl + '/api/product/list';
    var apiData = kw ? { keyword: kw } : { categoryId: that.data.currentCat };
    wx.request({
      url: apiUrl,
      data: apiData,
      success: function(res) {
        if (res.data.code === 200) {
          var apiData = res.data.data;
          if (apiData && apiData.length > 0) {
            that.setData({ productList: apiData });
          } else {
            var demo = getDemoData(that.data.currentCat, that.data.keyword);
            that.setData({ productList: demo });
          }
        } else {
          var demo = getDemoData(that.data.currentCat, that.data.keyword);
          that.setData({ productList: demo });
        }
      },
      fail: function() {
        var demo = getDemoData(that.data.currentCat, that.data.keyword);
        that.setData({ productList: demo });
      }
    });
  },

  onSearchInput: function(e) {
    var kw = e.detail.value;
    this.setData({ keyword: kw });
    this.loadProducts();
  },

  switchCat: function(e) {
    var id = e.currentTarget.dataset.id;
    this.setData({ currentCat: id });
    this.loadProducts();
  },

  goDetail: function(e) {
    var id = e.currentTarget.dataset.id;
    wx.navigateTo({ url: '/pages/product/product?id=' + id });
  },

  clearKeyword: function() {
    this.setData({ keyword: '' });
    this.loadProducts();
  },

  onImgError: function(e) {
    var idx = e.currentTarget.dataset.index;
    var list = this.data.productList;
    if (list[idx]) {
      list[idx].coverImage = '';
      this.setData({ productList: list });
    }
  }
});
