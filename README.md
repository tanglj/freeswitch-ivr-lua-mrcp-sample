# freeswitch-ivr-lua-mrcp-sample

>FreeSWITCH IVR环境的搭建

## 测试环境

CentOS7.6 1核4G40G

## 一、安装FreeSWITCH

### 安装与启动

- FreeSWITCH官网CentOS7安装方法：
<https://freeswitch.org/confluence/display/FREESWITCH/CentOS+7+and+RHEL+7>

```bash
yum install -y http://files.freeswitch.org/freeswitch-release-1-6.noarch.rpm epel-release
yum install -y freeswitch-config-vanilla freeswitch-lang-* freeswitch-sounds-*
```

- 安装需要的模块

```bash
yum install -y freeswitch-lua freeswitch-asrtts-unimrcp
yum install -y lua-socket
```

- 启动FreeSWITCH

```bash
freeswitch -nonat -nc
```

- 进入FreeSWITCH控制台

```bash
fs_cli
```

### 配置

- 建立软连接

```bash
mkdir -p /usr/local/freeswitch/storage
ln -s /etc/freeswitch/ /usr/local/freeswitch/conf
ln -s /usr/share/freeswitch/scripts/ /usr/local/freeswitch/scripts
```

- 修改FreeSWITCH基本配置

编辑`/usr/local/freeswitch/conf/vars.xml`，`default_password`改为默认值1234以外的值

如果是公网环境，`internal_sip_port`和`internal_tls_port`改成5060/5061以外的可用端口，避免受到攻击

如果是公网环境，修改`/usr/local/freeswitch/conf/sip_profiles/internal.xml`的配置，`ext-rtp-ip`和`ext-sip-ip`配置为服务器公网IP

- 修改FreeSWITCH启动加载模块配置

编辑`/usr/local/freeswitch/conf/autoload_configs/modules.conf.xml`

取消 `<load module="mod_lua"/>`的注释

添加`<load module="mod_unimrcp"/>`

- 修改Lua模块配置

编辑`/usr/local/freeswitch/conf/autoload_configs/lua.conf.xml`

修改或添加

`<param name="module-directory" value="/usr/lib64/lua/5.1/?.so"/>`

`<param name="script-directory" value="/usr/share/lua/5.1/?.lua"/>`

`<param name="script-directory" value="$${script_dir}/?.lua"/>`

- 重启FreeSWITCH

Shell执行`freeswitch -stop`或在FreeSWITCH控制台执行`shutdown`，再启动

## 二、实现呼叫

### 注册分机

- 安装软电话

选择安装Adore SIP Client(iOS)、CSipSimple(Android)、MicroSIP(Windows)

最好使用手机，避免收音问题

- 注册分机

在软电话中配置账号。

服务器，FreeSWITCH的IP:之前配置的端口

账号，1001-1020中任意一个

密码，填写之前配置的密码

- 查看注册状态

软电话注册成功会有提示

同时在FreeSWITCH控制台中，执行`sofia status profile internal reg`，若能看到相关信息表明注册成功

### 使用echo测试分机

在FreeSWITCH控制台中，执行`originate user/1001 &echo`，其中1001是注册的分机号

执行成功注册的软电话会振铃，接通后可以听到自己说话的声音

## 三、配置简单的Lua流程

### 拨号计划(dialplan)

### Lua脚本

## 四、调用百度云MRCP语音识别服务

<https://ai.baidu.com/docs#/TTS-API/top>

### 获取认证信息

### 部署百度云MRCP Server

### 调用识别资源

## 五、配置简单的语音IVR流程

### 基本的流程设计

### HTTP语音合成调用

### 交互流程
