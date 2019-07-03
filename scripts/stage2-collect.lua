-- 接通
session:answer()

-- 控制台打印日志
session:consoleLog("INFO", "开始播报识别")

-- 播放音频并开启识别
session:execute("play_and_detect_speech", "/usr/local/freeswitch/storage/stage1-test.wavdetect:unimrcp:baidu-cloud {start-input-timers=false,No-Input-Timeout=3000,Speech-Complete-Timeout=1200}http://192.168.0.1/grammars/not-exit.gram")
local result = session:getVariable('detect_speech_result')
if result == nil then
    session:consoleLog("INFO", "引擎异常")
elseif result == "Completion-Cause: 001" then
    session:consoleLog("INFO", "未识别")
elseif result == "Completion-Cause: 002" then
    session:consoleLog("INFO", "未输入")
else
    session:consoleLog("INFO", "识别结果是：\n".. result)
end

session:consoleLog("INFO", "结束播报识别")

-- 挂机
session:hangup()