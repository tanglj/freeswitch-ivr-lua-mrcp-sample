-- 接通
session:answer()

-- 导入http模块用以调用百度HTTP接口
http = require("socket.http")
-- 导入xmlSimple模块用以解析识别结果XML，获取用户输入
xml = require("xmlSimple")

-- 导入同目录下的配置文件，包含本机MAC和申请的百度Token
require "stage3-tts-conf"

-- 全局变量
exit = 0 -- 退出编码，0继续交互/1用户退出/2ASR异常退出/3TTS异常退出
input_text = "" -- 用户输入的文本
speak_string = "" -- 系统播报的文本
speak_count = 0 -- 全局计数，用于标识调用合成的次序
audio_path = "" -- TTS合成的音频路径

-- 调用百度TTS接口的函数，返回成功与否
function get_baidu_tts_wav()
	r,c,h,body=http.request("http://tsn.baidu.com/text2audio?lan=zh&ctp=1&aue=6&cuid=".. MAC .. "&tex=" .. speak_string .. "&tok=" .. baidu_tocken)
	local is_call_baidu_api_success = false
	speak_count = speak_count + 1
	audio_path = "/usr/local/freeswitch/storage/" .. session:getVariable("uuid") .. "-" .. tostring(speak_count) .. ".wav"
	for i,v in pairs(h) do
		if i == "content-type" and v == "audio/wav" then
			is_call_baidu_api_success = true
			f = io.open(audio_path, "wb")
			f:write(r)
			f:close()
		end
	end
	session:consoleLog("INFO", "get_baidu_tts_wav()|is_call_baidu_api_success=" .. tostring(is_call_baidu_api_success))
	return is_call_baidu_api_success
end

-- 播报识别函数
function prompt_and_collect()
	if input_text ~= "" then
		speak_string = "识别结果是：" .. input_text .. "，请继续输入"
	else
		speak_string = "你好，请问有什么可以帮您的？"
	end
	if get_baidu_tts_wav() then
		session:execute("play_and_detect_speech", audio_path .. "detect:unimrcp:baidu-cloud {start-input-timers=false,No-Input-Timeout=3000,Speech-Complete-Timeout=1200}http://192.168.0.1/grammars/not-exist.gram")
		local result = session:getVariable('detect_speech_result')
		if result == nil then
			session:consoleLog("INFO", "----------No result!----------\n")
			exit = 2
		elseif result == "Completion-Cause: 001" then
			session:consoleLog("INFO", "----------No result! " .. result .."\n")
			input_text = "未识别"
		elseif result == "Completion-Cause: 002" then
			session:consoleLog("INFO", "----------No result! " .. result .."\n")
			input_text = "未输入"
		else
			session:consoleLog("INFO", "----------result=----------\n".. result .."\n")
			parsedXml = xml:newParser():ParseXmlText(result)
			input_text = parsedXml.result.interpretation.input:value()
			session:consoleLog("INFO", "识别文本，input_text=[" .. input_text .. "]\n")
			if input_text == "退出" then
				exit = 1
			end
		end
	else
		exit = 3
	end
end

-- 流程循环
while session:ready() do
	if exit == 0 then
		prompt_and_collect()
	elseif exit == 1 then
		session:consoleLog("INFO", "用户输入“退出”")
		speak_string = "识别结果是“退出”，再见。"
		if get_baidu_tts_wav() then
			session:streamFile(audio_path)
		end
		break
	elseif exit == 2 then
		session:consoleLog("ERR", "识别调用错误，退出")
		speak_string = "系统错误，再见。"
		if get_baidu_tts_wav() then
			session:streamFile(audio_path)
		end
		break
	else
		session:consoleLog("ERR", "合成调用错误，退出")
		break
	end
end

-- 挂机
session:hangup()