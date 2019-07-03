-- 接通
session:answer()

-- 控制台打印日志
session:consoleLog("INFO", "开始播放音频")

-- 播放音频 “欢迎你来到新世界”
session:streamFile("/usr/local/freeswitch/storage/stage1-test.wav")

session:consoleLog("INFO", "结束播放音频")

-- 挂机
session:hangup()