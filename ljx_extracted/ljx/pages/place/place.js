// pages/place/place.js
Page({
  data: {
    categories: [
      { name: '关注' },
      { name: '发现' },
      { name: '热门' }
    ],
    currentIndex: 0,
    liked: false,
    categoryData: {
      0: [
        { image: '../images/结构-1.png', title: '半隐燕尾榫' },
        { image: '../images/结构-2.png', title: '全隐斗底槽' },
        { image: '../images/结构-3.png', title: '口袋榫' },
        { image: '../images/结构-4.png', title: '圆木哨' },
        { image: '../images/结构-5.png', title: '肩榫接合' },
        { image: '../images/结构-6.png', title: '木方平接' }
      ],
      1: [
        { image: '../images/家具-1.png', title: '椅子' },
        { image: '../images/家具-2.png', title: '桌子' },
        { image: '../images/家具-3.png', title: '柜子' },
        { image: '../images/家具-4.png', title: '床' },
        { image: '../images/家具-5.png', title: '书架' },
        { image: '../images/家具-6.png', title: '案几' }
      ],
      2: [
        { image: '../images/紫檀木.png', title: '紫檀木' },
        { image: '../images/黄花梨.png', title: '黄花梨' },
        { image: '../images/红木.png', title: '红木' },
        { image: '../images/楠木.png', title: '楠木' },
        { image: '../images/鸡翅木.png', title: '鸡翅木' },
        { image: '../images/黄杨木.png', title: '黄杨木' }
      ]
    },
    currentData: []
  },
  onLoad(options) {
    this.setData({
      currentData: this.data.categoryData[0]
    })
  },
  switchCategory(e) {
    const index = e.currentTarget.dataset.index
    this.setData({
      currentIndex: index,
      currentData: this.data.categoryData[index]
    })
  },
  toggleLike() {
    this.setData({
      liked: !this.data.liked
    })
  },
  onReady() {

  },
  onShow() {

  },
  onHide() {

  },
  onUnload() {

  },
  onPullDownRefresh() {

  },
  onReachBottom() {

  },
  onShareAppMessage() {

  }
})