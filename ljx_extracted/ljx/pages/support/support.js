Page({
  data: {},

  onChat: function() {
    wx.navigateTo({ url: '/pages/chat/chat' });
  },

  copyText: function(e) {
    var t = e.currentTarget.dataset.text;
    wx.setClipboardData({
      data: t,
      success: function() {
        wx.showToast({ title: '已复制', icon: 'success' });
      }
    });
  },

  goHelp: function() {
    wx.navigateTo({ url: '/pages/help/help' });
  },

  onComplain: function() { wx.showToast({ title: '投诉通道建设中', icon: 'none' }); },
  onReport: function() { wx.showToast({ title: '举报通道建设中', icon: 'none' }); },
  onSuggestion: function() { wx.showToast({ title: '建议已记录，感谢支持', icon: 'success' }); },

  goBack: function() { wx.navigateBack(); }
});
