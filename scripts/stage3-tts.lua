-- 接通
session:answer()

-- 导入http模块用以调用百度HTTP接口
http = require("socket.http")

-- 导入同目录下的配置文件，包含本机MAC和申请的百度Token
require "stage3-tts-conf"

-- 调用接口获得结果
r,c,h,body=http.request("http://tsn.baidu.com/text2audio?lan=zh&ctp=1&aue=6&cuid=".. MAC .. "&tok=" .. baidu_tocken .. "&tex=来自远方的问候")

-- 判断是否调用成功，如果成功写入到本地文件中
is_call_baidu_api_success = false
audio_path = "/usr/local/freeswitch/storage/" .. session:getVariable("uuid") .. ".wav" -- uuid是每通电话唯一的标识
for i,v in pairs(h) do
    if i == "content-type" and v == "audio/wav" then
        is_call_baidu_api_success = true
        f = io.open(audio_path, "wb")
        f:write(r)
        f:close()
    end
end

-- 如果调用成功，播放写入本地的音频文件
if is_call_baidu_api_success then
    session:consoleLog("INFO", "播放音频：" .. audio_path)
    session:streamFile(audio_path)
else
    session:consoleLog("INFO", "调用百度接口失败")
end

-- 挂机
session:hangup()