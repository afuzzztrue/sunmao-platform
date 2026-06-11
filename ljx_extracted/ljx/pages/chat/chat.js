const app = getApp();
const baseUrl = app.globalData.baseUrl;

Page({
  data: {
    messages: [],
    inputValue: '',
    loading: false,
    scrollToView: ''
  },

  onLoad() {
    this.setData({
      messages: [{
        role: 'ai',
        content: '您好！我是您的榘卯文化AI导师，基于DeepSeek大模型。您可以问我关于榘卯结构（如燕尾榘、棕角榘、抱肩榘等）、木工技艺、传统建筑、各种木材（紫檀、黄花梨、红木等）或非遗文化的任何问题！

例如：
- 什么是燕尾榘？怎么制作？
- 紫檀木有什么特点？
- 明式家具的历史和特色是什么？'
      }]
    });
  },

  onInput(e) { this.setData({ inputValue: e.detail.value }); },

  sendMsg() {
    var that = this;
    var content = this.data.inputValue.trim();
    if (!content || this.data.loading) return;

    var messages = this.data.messages.concat([{ role: 'user', content: content }]);
    this.setData({ messages: messages, inputValue: '', loading: true, scrollToView: 'msg-' + (messages.length - 1) });

    wx.request({
      url: baseUrl + '/api/chat/query',
      method: 'POST',
      header: { 'Content-Type': 'application/x-www-form-urlencoded', 'Authorization': wx.getStorageSync('token') || '' },
      data: { content: content },
      success: function(res) {
        if (res.data.code === 200 && res.data.data) {
          var reply = res.data.data.reply || '抱歉，未获取到回复。';
          var newMsgs = that.data.messages.concat([{ role: 'ai', content: reply }]);
          that.setData({ messages: newMsgs, loading: false, scrollToView: 'msg-' + (newMsgs.length - 1) });
        } else {
          that.setData({ loading: false });
          wx.showToast({ title: 'AI请求失败', icon: 'none' });
        }
      },
      fail: function() {
        that.setData({ loading: false });
        wx.showToast({ title: '网络错误', icon: 'none' });
      }
    });
  }
});
