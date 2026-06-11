const app = getApp();
const baseUrl = app.globalData.baseUrl;

// 订单状态定义
// 0:待支付 1:已支付(待发货) 2:已发货(待收货) 3:已完成(待评价) 4:已取消(售后)
var STATUS_MAP = { 0: '待支付', 1: '已支付', 2: '已发货', 3: '已完成', 4: '已取消' };

// 售后期天数：与后端 ProductController.AFTER_SALES_DAYS 保持一致
var AFTER_SALES_DAYS = 7;

/**
 * 判断订单是否可被删除
 * 规则：status=4（已取消）直接可删；status=3（已完成）需超过售后期；其他状态均不可删
 */
function canDeleteOrder(order) {
  if (!order) return false;
  var status = order.status;
  if (status === 4) return true;
  if (status === 3) {
    if (!order.createTime) return false;
    var create = new Date(String(order.createTime).replace(/-/g, '/')).getTime();
    if (isNaN(create)) return false;
    var days = (Date.now() - create) / (1000 * 60 * 60 * 24);
    return days > AFTER_SALES_DAYS;
  }
  return false;
}

/**
 * 给订单列表加上 _canDelete 标记（用于 wxml 条件渲染）
 */
function enrichOrders(list) {
  return (list || []).map(function(o) {
    o._canDelete = canDeleteOrder(o);
    return o;
  });
}

// 二级 tab 列表：id=0 为全部；其余 id 与 status 一一对应（id - 1 = status）
var ORDER_TABS = [
  { id: 0, name: '全部' },
  { id: 1, name: '待支付' },
  { id: 2, name: '待发货' },
  { id: 3, name: '待收货/使用' },
  { id: 4, name: '评价' },
  { id: 5, name: '售后' }
];

function filterOrdersByTab(list, tabId) {
  if (!tabId) return list; // 全部
  var targetStatus = tabId - 1;
  return list.filter(function(o) { return o.status === targetStatus; });
}

Page({
  data: {
    categories: ORDER_TABS,
    currentCat: 0,
    orderList: [],
    fullOrderList: [],
    statusMap: STATUS_MAP,
    highlightOrderId: null,
    emptyMap: {
      0: '暂无订单',
      1: '没有待支付的订单',
      2: '没有待发货的订单',
      3: '没有待收货的订单',
      4: '没有待评价的订单',
      5: '没有售后记录'
    }
  },

  onShow() {
    var that = this;
    var userId = wx.getStorageSync('userId');
    if (!userId) {
      wx.showToast({ title: '请先登录', icon: 'none' });
      return;
    }

    // 处理从 order-search 跳回的高亮定位请求
    var pendingHighlightId = app.globalData.highlightOrderId;
    var pendingStatus = app.globalData.highlightOrderStatus;
    if (pendingHighlightId) {
      app.globalData.highlightOrderId = null;
      app.globalData.highlightOrderStatus = null;
    }

    wx.request({
      url: baseUrl + '/api/product/order/my',
      data: { userId: userId },
      success: function(res) {
        if (res.data.code === 200) {
          var all = enrichOrders(res.data.data || []);
          // 如果有高亮请求，先切到对应 tab，再过滤
          var targetTab = (pendingHighlightId && pendingStatus !== null && pendingStatus !== undefined)
            ? (pendingStatus + 1)
            : that.data.currentCat;
          that.setData({
            fullOrderList: all,
            currentCat: targetTab,
            orderList: filterOrdersByTab(all, targetTab)
          });
          // 滚动到指定订单并短暂高亮
          if (pendingHighlightId) {
            that.scrollAndHighlight(pendingHighlightId);
          }
        }
      },
      fail: function() {
        // 网络失败时也清空，避免展示陈旧数据
        that.setData({ orderList: [], fullOrderList: [] });
      }
    });
  },

  /**
   * 滚动到指定订单并触发高亮动画
   * 依赖每个 .order-card 都有 id="order-{{orderId}}"
   */
  scrollAndHighlight: function(orderId) {
    var that = this;
    // 1) 立刻滚动到目标（兼容 selector 找不到时静默失败）
    wx.pageScrollTo({
      selector: '#order-' + orderId,
      duration: 250
    });
    // 2) 触发 highlight class
    that.setData({ highlightOrderId: orderId });
    // 3) 2.5s 后清除高亮（动画时长结束）
    setTimeout(function() {
      that.setData({ highlightOrderId: null });
    }, 2600);
  },

  switchCat: function(e) {
    var id = parseInt(e.currentTarget.dataset.id, 10);
    if (id === this.data.currentCat) return;
    this.setData({
      currentCat: id,
      highlightOrderId: null,
      orderList: filterOrdersByTab(this.data.fullOrderList, id)
    });
  },

  goToOrderSearch: function() {
    wx.navigateTo({ url: '/pages/order-search/order-search' });
  },

  /**
   * 去支付：当前后端未接入支付通道，先弹 toast 占位
   * 同时也刷新订单列表以便后续接入真实支付时无缝切换
   */
  goPay: function(e) {
    var orderId = e.currentTarget.dataset.id;
    var name = e.currentTarget.dataset.name;
    var price = e.currentTarget.dataset.price;
    if (!orderId) return;
    wx.showModal({
      title: '确认支付',
      content: '商品：' + (name || '') + '\n金额：¥' + (price || '0') + '\n\n（支付通道未接入，此处仅作演示）',
      confirmText: '确认支付',
      confirmColor: '#7D9A6A',
      success: function(res) {
        if (!res.confirm) return;
        wx.showToast({ title: '支付通道暂未接入', icon: 'none' });
      }
    });
  },

  cancelOrder: function(e) {
    var that = this;
    var orderId = e.currentTarget.dataset.id;
    var userId = wx.getStorageSync('userId');
    if (!userId) {
      wx.showToast({ title: '请先登录', icon: 'none' });
      return;
    }
    wx.showModal({
      title: '提示',
      content: '确定要取消该订单吗？',
      confirmColor: '#C4493D',
      success: function(res) {
        if (!res.confirm) return;
        wx.showLoading({ title: '处理中...', mask: true });
        wx.request({
          url: baseUrl + '/api/product/order/cancel',
          method: 'POST',
          header: { 'Content-Type': 'application/x-www-form-urlencoded' },
          data: { orderId: orderId, userId: userId },
          success: function(r) {
            wx.hideLoading();
            if (r.data && r.data.code === 200) {
              wx.showToast({ title: '取消订单成功', icon: 'success' });
              that.onShow();
            } else {
              wx.showToast({ title: (r.data && r.data.message) || '取消失败', icon: 'none' });
            }
          },
          fail: function() {
            wx.hideLoading();
            wx.showToast({ title: '网络异常，请稍后再试', icon: 'none' });
          }
        });
      }
    });
  },

  deleteOrder: function(e) {
    var that = this;
    var orderId = e.currentTarget.dataset.id;
    var userId = wx.getStorageSync('userId');
    if (!userId) {
      wx.showToast({ title: '请先登录', icon: 'none' });
      return;
    }
    wx.showModal({
      title: '提示',
      content: '确定要删除该订单吗？删除后无法恢复。',
      confirmColor: '#9B8E85',
      success: function(res) {
        if (!res.confirm) return;
        wx.showLoading({ title: '处理中...', mask: true });
        wx.request({
          url: baseUrl + '/api/product/order/delete',
          method: 'POST',
          header: { 'Content-Type': 'application/x-www-form-urlencoded' },
          data: { orderId: orderId, userId: userId },
          success: function(r) {
            wx.hideLoading();
            if (r.data && r.data.code === 200) {
              wx.showToast({ title: '删除订单成功', icon: 'success' });
              that.onShow();
            } else {
              wx.showToast({ title: (r.data && r.data.message) || '删除失败', icon: 'none' });
            }
          },
          fail: function() {
            wx.hideLoading();
            wx.showToast({ title: '网络异常，请稍后再试', icon: 'none' });
          }
        });
      }
    });
  }
});
