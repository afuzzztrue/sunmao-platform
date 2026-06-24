// custom-tab-bar/index.js
// 抖音风格自定义 tabBar: 5 项, 中间 + 号浮起
// 创建: 2026-06-24

Component({
  data: {
    selected: 0
  },

  lifetimes: {
    attached() {
      this.updateSelected();
    }
  },

  /**
   * 高亮同步改为由每个 tab 页面的 onShow 主动调用
   * this.getTabBar().setData({ selected: N }) 来更新 (官方推荐写法)
   * 这样比 pageLifetimes.show 更可靠, 时机更明确
   */

  methods: {
    /**
     * 根据当前页面路径, 同步高亮对应 tab
     */
    updateSelected() {
      const pages = getCurrentPages();
      if (pages.length === 0) return;
      const current = pages[pages.length - 1].route;
      const map = {
        'pages/index/index': 0,
        'pages/sort/sort':   1,
        'pages/shop/shop':   3,
        'pages/my/my':       4
      };
      const selected = (current in map) ? map[current] : 0;
      this.setData({ selected });
    },

    /**
     * 切换 tab (除中间 + 号外)
     */
    onSwitchTab(e) {
      const url = e.currentTarget.dataset.url;
      wx.switchTab({
        url,
        fail: err => {
          console.error('switchTab 失败:', err);
        }
      });
    },

    /**
     * 点击中央 + 号: 跳转到发布页
     */
    onPublish() {
      wx.navigateTo({
        url: '/pages/publish/publish',
        fail: err => {
          console.error('navigateTo publish 失败:', err);
          wx.showToast({ title: '发布页加载失败', icon: 'none' });
        }
      });
    }
  }
});
