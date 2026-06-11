const app = getApp();

Page({
  data: {
    faqs: [
      { q: '什么是榫卯？', a: '榫卯是中式木作的核心工艺，通过凹凸咬合将木材连接成结构，无需胶钉。明式家具的榫卯多达上百种。', open: false },
      { q: '如何购买课程？', a: '进入「商城 → 课程」分类，选择感兴趣的课程下单支付。已购买的课程会自动加入「我的 → 已下载的课程」。', open: false },
      { q: '课程支持离线下载吗？', a: '支持。课程详情页有「下载」按钮，下载后可在「我的 → 已下载的课程」中离线观看。', open: false },
      { q: '订单可以取消吗？', a: '待支付订单可在「我的订单」中直接取消。已支付订单如需取消请联系客服。', open: false },
      { q: '如何联系传承人？', a: '在 AI 文化导师中可与系统 AI 交流榫卯知识。预约真人传承人请通过「客服中心」咨询。', open: false },
      { q: '账号忘记密码怎么办？', a: '在登录页点击「忘记密码」（如有）走找回流程，或直接联系客服重置。', open: false }
    ],
    fbText: '',
    fbContact: ''
  },

  toggleFaq: function(e) {
    var i = parseInt(e.currentTarget.dataset.i, 10);
    var faqs = this.data.faqs.map(function(f, idx) {
      if (idx === i) f.open = !f.open;
      return f;
    });
    this.setData({ faqs: faqs });
  },

  onFbInput: function(e) { this.setData({ fbText: e.detail.value }); },
  onFbContact: function(e) { this.setData({ fbContact: e.detail.value }); },

  /**
   * 调用后端 POST /api/feedback/submit
   * 入参: { userId, fbType=1(功能建议), content, contact }
   */
  onSubmit: function() {
    var that = this;
    var text = this.data.fbText.trim();
    if (!text) { wx.showToast({ title: '请填写反馈内容', icon: 'none' }); return; }
    wx.showLoading({ title: '提交中...', mask: true });
    wx.request({
      url: app.globalData.baseUrl + '/api/feedback/submit',
      method: 'POST',
      header: {
        'Content-Type': 'application/json',
        'Authorization': wx.getStorageSync('token') || ''
      },
      data: {
        userId: wx.getStorageSync('userId') || null,
        fbType: 1,   // 1=功能建议
        content: text,
        contact: that.data.fbContact
      },
      success: function(res) {
        if (res.data.code === 200) {
          that.setData({ fbText: '', fbContact: '' });
          wx.showToast({ title: '感谢你的反馈', icon: 'success' });
        } else {
          wx.showToast({ title: res.data.message || '提交失败', icon: 'none' });
        }
      },
      fail: function() {
        wx.showToast({ title: '网络异常，请重试', icon: 'none' });
      },
      complete: function() { wx.hideLoading(); }
    });
  },

  goBack: function() { wx.navigateBack(); }
});
