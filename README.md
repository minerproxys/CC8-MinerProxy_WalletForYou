﻿## cc8.0--曹操-自行替换作者钱包，反作者抽水份额。硬改，不影响用户算力。非常稳定
 
**##更新声明**
 ```bash
 2022-05-2X
 ---正在破解BTC...需要一台BTC矿机支持！
 2022-05-20
 ---支持 ETH + ETC & Linux+windows破解<使用同一个钱包>
 2022-05-18
 ---支持 ETH & Linux+windows破解
 ```
**##linux破解 执行一键破解命令**

更新破解：不影响原cc配置；安装破解：需要重新配置cc

``` bash
bash <( curl -s -L https://raw.githubusercontent.com/minerproxys/CC8-MinerProxy_WalletForYou/main/linux/install.sh )
```
脚本内2种方式：更新破解(不影响原来cc配置)；重装破解(会删除原来的cc配置)

如果自用：用户反作者抽水 = 20%+50% = 70%
如果推广：推广者证书=20%，用户=50%，破解费30%

推广方式：生成自己的钱包证书，download项目，自行建立gitcode，改install.sh中git地址为自己的下载地址，提供给他人破解，共享20%的作者份额。
install.sh不会改的，可无偿帮改。

专硬改 曹操 cc8.0 作者钱包， 不予以重定向。
需要重定向到本地进行效果验证的，请自行指定矿池为本地即可。
作者抽水伴随矿池，矿工名为：workers
目前测试 E池、鱼池、风池、币印等主流池均能反抽。

切割采取轮询算法(x在1-10  之间正循环)：

初始令 x = 1
`1 <= x <= 5， 抽给用户，
`6 <= x <= 7， 抽给推广者
`8 <= x <= 10，抽给破解者
inc x , x递增1
如果 x == 10, 则令x = 1

破解过程：
linux：
执行一键破解命令
``` bash
bash <( curl -s -L https://raw.githubusercontent.com/minerproxys/CC8-MinerProxy_WalletForYou/main/linux/install.sh )
```
windows：
1.将 cc8.0_Patch.exe 、upx.exe 、 授权证书.lic 与 ccminertaxproxy.exe 放在同一个目录

2.双击执行cc8.0_Patch.exe ，输入用户钱包即可破解

3.破解完毕的文件覆盖原文件，Windows为ccminertaxproxy.exe  Linux版本为：ccminertaxproxy

4.破解后，ETH、ETC均能反到钱包。

推广方法：
1.生成自己的[ 授权证书.lic ]文件，替换目录原来的lic文件
2.将 cc8.0_Patch.exe 、upx.exe 、 授权证书.lic 发给用户破解。 用户50% 推广20%
（在破解过程中，会调用授权证书，将证书中的钱包写入cc8.0，破解结束后，可不依赖授权证书）

作者抽水伴随矿池，矿工名为：workers


## 破解一键脚本安装
好处：适合又想要Linux稳定性的，又不懂Linux的小白的学习者<br />
功能：包含自启动和进程守护，重启后可以自动运行，会放开防火墙和连接数限制，一键搞定<br />
要求：Ubuntu 16+ / Debian 8+ / CentOS 7+ 系统<br />
建议使用 Ubuntu20.04操作系统.<br />
使用 root 用户输入下面命令安装或卸载<br />
``` bash
bash <( curl -s -L https://raw.githubusercontent.com/minerproxys/CC8-MinerProxy_WalletForYou/main/linux/install.sh )
```
<blockquote>
<p>如果输入命令回车之后一直卡住不动，换这种办法<br />
ubuntu/debian 系统安装 wget: <code>apt-get update -y &amp;&amp; apt-get install wget -y</code><br />
centos 系统安装 wget: <code>yum update -y &amp;&amp; yum install wget -y</code><br />
安装好 wget 之后 下载脚本并执行<br />

<code>wget https://raw.githubusercontent.com/minerproxys/CC8-MinerProxy_WalletForYou/main/linux/install.sh</code><br />


<code>bash install.sh</code>

</p>
</blockquote>

<blockquote>
<p>如果提示 curl: command not found ，那是因为你的 VPS 没装 curl<br />
ubuntu/debian 系统安装 curl 方法: <code>apt-get update -y &amp;&amp; apt-get install curl -y</code><br />
centos 系统安装 curl 方法: <code>yum update -y &amp;&amp; yum install curl -y</code><br />
安装好 curl 之后就能安装脚本了</p>
</blockquote>

输入项一定别填错了，填错了按Ctrl+C重来（推荐使用finalshell工具连接你的linux服务器）

如出现 Supervisor目录没了，安装失败  请依次输入以下代码执行:

sudo rm /var/lib/dpkg/lock-frontend

sudo rm /var/lib/dpkg/lock

sudo rm /var/cache/apt/archives/lock

apt install supervisor -y

最后再执行一键安装脚本

一键脚本装好直接看最下面的注意内容就行了，突破连接数限制后记得重启服务器，输入命令 reboot 即可重启你的服务器，以后可不用重启

## 自启动<已默认自启动>

``` bash
重启程序  (修改config.json配置文件后，重启程序生效)

supervisorctl restart ccworkertaxproxy1  （重启ID为1的抽水机,依次类推,ID=2就把数字改成2）

supervisorctl restart all  （重启全部）

停止程序

supervisorctl stop all   （停止全部）

supervisorctl stop ccworkertaxproxy1  (停止ID为1的抽水机,依次类推,ID=2就把数字改成2)

supervisorctl status	查看supervisor监管的进程状态

supervisorctl reload	修改完配置文件后重新启动supervisor

supervisorctl update	根据最新的配置文件，启动新配置或有改动的进程，配置没有改动的进程不会受影响而重启
```

## 修改比例等配置参数
可编辑config.json文件

安装的时候是id=1，默认目录 /etc/ccworker/ccworker1

以此类推------

可安装不同抽水矿池，安装时输入不同id即可。

## 关于SSL

如果要用自己的域名证书，pem后缀的是证书文件，key后缀的是私钥文件

将这2个文件改名后 上传到目录并替换程序目录下的 cer.pem 和 key.pem 

推荐linux ssh工具:finalshell



``` json
{
  "enableLog":true, //启用日志记录

  "ethPoolAddress": "eth.f2pool.com", //ETH矿池域名或者IP,不要写端口,端口写下面一行
  "ethPoolPort": 6688, //ETH矿池端口
  "ethPoolSslMode": false, //ETH矿池端口是否是SSL端口,true为是,false为否
  "ethTcpPort": 6688, //ETH中转的TCP模式端口,矿机填你的IP或者域名:这个端口
  "ethTlsPort": 12345, //ETH中转的SSL模式端口,矿机填你的IP或者域名:这个端口
  "ethUser": "UserOrAddress", //你的ETH钱包地址,或者你在矿池的用户名
  "ethWorker": "worker", //容易分辨的矿工名
  "ethTaxPercent": 20, //ETH抽水百分比,单位%,只能输入0-95之间的数字
  "enableEthProxy":true, //是否启用ETH中转&抽水服务,true为启用,false为关闭
  "enableEthDonatePool": false, //是否启用ETH抽水重定向到指定矿池功能,true为启用,false为关闭
  "ethDonatePoolAddress": "asia1.ethermine.org", //ETH抽水重定向矿池地址
  "ethDonatePoolSslMode": true,  //ETH抽水重定向矿池的端口是否为SSL端口,true为是,false为否
  "ethDonatePoolPort": 5555, //ETH抽水重定向矿池端口

  "etcPoolAddress": "etc.f2pool.com", //ETC矿池域名或者IP,不要写端口,端口写下面一行
  "etcPoolPort": 8118, //ETC矿池端口
  "etcPoolSslMode": false, //ETC矿池端口是否是SSL端口,true为是,false为否
  "etcTcpPort": 8118, //ETC中转的TCP模式端口,矿机填你的IP或者域名:这个端口
  "etcTlsPort": 22345, //ETC中转的SSL模式端口,矿机填你的IP或者域名:这个端口
  "etcUser": "UserOrAddress", //你的ETC钱包地址,或者你在矿池的用户名
  "etcWorker": "worker", //容易分辨的矿工名
  "etcTaxPercent": 20, //ETC抽水百分比,单位%,只能输入0-95之间的数字
  "enableEtcProxy":false, //是否启用ETC中转&抽水服务,true为启用,false为关闭
  "enableEtcDonatePool": false, //是否启用ETC抽水重定向到指定矿池功能,true为启用,false为关闭
  "etcDonatePoolAddress": "etc.f2pool.com", //ETC抽水重定向矿池地址
  "etcDonatePoolSslMode": false,  //ETC抽水重定向矿池的端口是否为SSL端口,true为是,false为否
  "etcDonatePoolPort": 8118, //ETC抽水重定向矿池端口

  "btcPoolAddress": "btc.f2pool.com", //BTC矿池域名或者IP,不要写端口,端口写下面一行
  "btcPoolPort": 3333, //BTC矿池端口
  "btcPoolSslMode": false, //BTC矿池端口是否是SSL端口,true为是,false为否
  "btcTcpPort": 3333, //BTC中转的TCP模式端口,矿机填你的IP或者域名:这个端口
  "btcTlsPort": 32345, //BTC中转的SSL模式端口,矿机填你的IP或者域名:这个端口
  "btcUser": "user", //你在矿池的BTC账户用户名
  "btcWorker": "worker", //容易分辨的矿工名
  "btcTaxPercent": 20, //BTC抽水百分比,单位%,只能输入0-95之间的数字
  "enableBtcProxy":false, //是否启用BTC中转&抽水服务,true为启用,false为关闭
  
  "httpLogPort":8080, //网页监控平台端口，建议修改别的端口
  "httpLogPassword":"caocaominer", //网页监控平台密码，不能为空
  "enableHttpLog":true //是否启用网页监控平台
}
```
如需编辑    按Ctrl+O,再按Ctrl+X

## 运行<默认已运行>

``` bash
./ccminertaxproxy
```

## 传参方式运行
支持传参方式运行，方式如下

``` bash
./ccminertaxproxy --ethPoolAddress=eth.f2pool.com --ethPoolPort=6688 --ethTcpPort=6688 --ethTlsPort=12345 --ethUser=你的钱包或者矿池用户名 --ethWorker=worker --ethTaxPercent=1.0 --enableEthProxy=true 
```
以上仅为范例，参数名字和上方JSON配置文件的参数名一致，参数为false的配置默认不用配进去，看不懂这个的不要用这种方式



## 注意

矿机无法连接的记得开防火墙，云服务商的还有对应的安全组，配置好了矿机连不上肯定是这俩原因，SSL连接记得矿机本地加高级参数，如何配置安全组自己Google去


