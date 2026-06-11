// app.js
App({
  onLaunch() {
    // 展示本地存储能力
    const logs = wx.getStorageSync('logs') || []
    logs.unshift(Date.now())
    wx.setStorageSync('logs', logs)

    // 从本地存储读取登录凭证
    const token = wx.getStorageSync('token')
    const userId = wx.getStorageSync('userId')

    if (token && userId) {
      // 验证Token有效性
      this.checkTokenValidity(token)
    }
  },

  /**
   * 验证Token有效性
   */
  checkTokenValidity: function(token) {
    // 实际项目应请求后端验证
    if (!token || !token.startsWith('jwt_token_')) {
      this.clearLoginInfo()
    }
  },

  /**
   * 保存登录信息到本地
   */
  saveLoginInfo: function(loginInfo) {
    wx.setStorageSync('userId', loginInfo.userId)
    wx.setStorageSync('token', loginInfo.token)
    wx.setStorageSync('nickname', loginInfo.nickname || '')
    wx.setStorageSync('phone', loginInfo.phone || '')
    wx.setStorageSync('avatar', loginInfo.avatar || '')
    console.log('登录信息已保存 - 用户:', loginInfo.nickname)
  },

  /**
   * 清除登录信息
   */
  clearLoginInfo: function() {
    wx.removeStorageSync('userId')
    wx.removeStorageSync('token')
    wx.removeStorageSync('nickname')
    wx.removeStorageSync('phone')
    wx.removeStorageSync('avatar')
    wx.removeStorageSync('userInfo')
    this.globalData.userInfo = null
  },

  /**
   * 检查用户是否已登录
   */
  isLoggedIn: function() {
    return !!wx.getStorageSync('token') && !!wx.getStorageSync('userId')
  },

  /**
   * 封装网络请求（带Token自动注入）
   */
  request: function(url, method = 'GET', data = {}) {
    return new Promise((resolve, reject) => {
      const token = wx.getStorageSync('token')
      wx.request({
        url: this.globalData.baseUrl + url,
        method: method,
        data: data,
        header: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': token || ''
        },
        success: (res) => {
          if (res.data.code === 200) {
            resolve(res.data)
          } else if (res.data.code === 401) {
            wx.showToast({ title: '登录已过期，请重新登录', icon: 'none' })
            this.clearLoginInfo()
            setTimeout(() => { wx.reLaunch({ url: '/pages/login/login' }) }, 1500)
            reject(res.data)
          } else {
            wx.showToast({ title: res.data.msg || res.data.message || '请求失败', icon: 'none' })
            reject(res.data)
          }
        },
        fail: (err) => {
          wx.showToast({ title: '网络请求失败', icon: 'none' })
          reject(err)
        }
      })
    })
  },

  globalData: {
    userInfo: null,
    baseUrl: 'http://localhost:8081'
  }
})
