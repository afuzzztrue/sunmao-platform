const app = getApp();

var STRUCTURE_DATA = [
  {
    id: 1,
    name: '半隐燕尾榫',
    image: '../images/结构-1.png',
    difficulty: 'beginner',
    difficultyLabel: '入门',
    description: '半隐燕尾榫是燕尾榫的一种变体。其特点是尾部仅在一侧可见，另一侧完全隐藏于木材内部——就像燕子尾巴的剖面隐藏进了木板之中。常用于抽屉面板与侧板的90°直角连接，外观简洁无露痕，兼具牢固与美观，是明式家具抽屉制作的入门必学结构。',
    searchKeyword: '燕尾榫'
  },
  {
    id: 2,
    name: '全隐斗底槽',
    image: '../images/结构-2.png',
    difficulty: 'beginner',
    difficultyLabel: '入门',
    description: '全隐斗底槽是将榫头完全嵌入槽口内部，外部无任何接缝痕迹的直线拼接方式。就像两块木材"咬"在一起后被磨平了表面，仅靠内部摩擦力锁定。常用于桌面拼接、拼板加宽场景，是新手掌握榫卯直线拼接的基础练习。',
    searchKeyword: '斗底槽'
  },
  {
    id: 3,
    name: '口袋榫',
    image: '../images/结构-3.png',
    difficulty: 'beginner',
    difficultyLabel: '入门',
    description: '口袋榫又名"闷榫"，顾名思义是在木材上开出一个"口袋"状的榫眼，将另一块木材的榫头塞入其中。外部只能看到榫眼边缘，榫头完全藏匿。这是最简单的一类榫卯，适合初学者练手，用于简单框架结构的连接，也是传统学徒开蒙第一关。',
    searchKeyword: '口袋榫'
  },
  {
    id: 4,
    name: '圆木哨',
    image: '../images/结构-4.png',
    difficulty: 'scholar',
    difficultyLabel: '学者',
    description: '圆木哨是圆柱形榫接的代表作品，将圆形截面的木料通过内部构造的卡榫机制连接成一体。榫头呈圆柱形，榫眼内壁也需精密旋转铣削，对加工精度要求远超平面榫卯。常见于圈椅扶手、立柱与底座的连接，明代圈椅工艺的精髓所在。',
    searchKeyword: '圆木'
  },
  {
    id: 5,
    name: '粽角榫',
    image: '../images/结构-5.png',
    difficulty: 'scholar',
    difficultyLabel: '学者',
    description: '粽角榫是三维多面体结构的代表，形如粽子的三角锥体。三个方向的榫头在同一个顶点交汇，每个面的角度各不相同——任何一个方向差0.5mm整个结构就锁定不住。这是检验木匠空间几何功力的标准考题，常见于床架、供桌等承重家具的关键节点。',
    searchKeyword: '粽角榫'
  },
  {
    id: 6,
    name: '抱肩榫',
    image: '../images/结构-6.png',
    difficulty: 'scholar',
    difficultyLabel: '学者',
    description: '抱肩榫是桌腿与横枨连接的核心技术。"抱肩"意为榫头如手臂般环绕包裹住另一构件的肩部。榫头分出多个层级——肩部卡住横枨、中部托住牙板、根部插入腿料。一气呵成地将桌面受力传导至四条腿，是上乘家具"踩线不裂"的秘诀。',
    searchKeyword: '抱肩榫'
  },
  {
    id: 7,
    name: '楔钉榫',
    image: '../images/结构-7.png',
    difficulty: 'master',
    difficultyLabel: '大师',
    description: '楔钉榫是榫卯结构中最为精巧的"锁死"结构——榫头插入后，再打入一枚楔形木钉，将整个结构永久锁定。楔子利用木材弹性膨胀原理越打越紧，拆解时需反向取出楔钉。这种"可拆不可解"的智慧是大师级木匠必须掌握的终极技能，用于结构不可拆但需要长期承重的部位。',
    searchKeyword: '楔钉榫'
  },
  {
    id: 8,
    name: '格角榫',
    image: '../images/结构-8.png',
    difficulty: 'master',
    difficultyLabel: '大师',
    description: '格角榫是明式家具框架结构的灵魂。每根构件端头以45°或90°角相互契合，形成网格状的框架系统。一个完整的格角系统需要近二十个相互啮合的榫卯同时精确定位，任何一处误差都会导致整个框架扭曲。官帽椅、画案的边框皆赖此结构得以历百年而不散。',
    searchKeyword: '格角榫'
  },
  {
    id: 9,
    name: '插肩榫',
    image: '../images/结构-9.png',
    difficulty: 'master',
    difficultyLabel: '大师',
    description: '插肩榫是大案、大桌腿足与面框之间最经典的连接方式。"插肩"二字意为榫头从下方斜插插入肩部，如同用肩扛起整个桌面。其形态具有典型的15°~18°倾斜角，靠重力将榫头越压越深——千年太和殿的立柱与阑额连接就使用了类似的原理。',
    searchKeyword: '插肩榫'
  }
];

Page({
  data: {
    tabs: [
      { id: 'beginner', name: '入门' },
      { id: 'scholar', name: '学者' },
      { id: 'master', name: '大师' }
    ],
    currentTabId: 'beginner',
    structureList: [],
    showDetail: false,
    detailItem: null
  },

  onLoad: function(options) {
    this.filterStructures('beginner');
  },

  onShow: function() {
    // 同步 custom-tab-bar 高亮
    if (typeof this.getTabBar === 'function' && this.getTabBar()) {
      this.getTabBar().setData({ selected: 1 });
    }
    this.filterStructures(this.data.currentTabId);
  },

  filterStructures: function(difficulty) {
    var filtered = STRUCTURE_DATA.filter(function(item) {
      return item.difficulty === difficulty;
    });
    this.setData({
      currentTabId: difficulty,
      structureList: filtered
    });
  },

  switchTab: function(e) {
    var tabId = e.currentTarget.dataset.id;
    this.filterStructures(tabId);
  },

  openDetail: function(e) {
    var id = e.currentTarget.dataset.id;
    var item = STRUCTURE_DATA.find(function(s) { return s.id === id; });
    if (item) {
      this.setData({
        showDetail: true,
        detailItem: item
      });
    }
  },

  closeDetail: function() {
    this.setData({
      showDetail: false,
      detailItem: null
    });
  },

  goToShopSearch: function() {
    var keyword = this.data.detailItem ? this.data.detailItem.searchKeyword : '';
    this.setData({ showDetail: false, detailItem: null });
    wx.switchTab({
      url: '/pages/shop/shop',
      success: function() {
        if (keyword) {
          var pages = getCurrentPages();
          var shopPage = pages[pages.length - 1];
          if (shopPage && shopPage.setData) {
            shopPage.setData({ keyword: keyword });
            shopPage.loadProducts();
          }
        }
      }
    });
  },

  onReady: function() {},
  onHide: function() {},
  onUnload: function() {},
  onShareAppMessage: function() {}
});
