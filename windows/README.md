﻿## cc8.0--曹操-自行替换作者钱包，反作者抽水份额。硬改，不影响用户算力。非常稳定

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



## 下载

目录里的文件都要下载

## 运行方式①

打开CaoMinerTaxProxy.exe，记得关闭杀毒软件，不然可能误报
打开后几个配置自己配置，配置完了点击启动
每次启动系统都要重新运行一次

## 运行方式②

自行编辑config.json文件，注意//之后的都删掉，包括//
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
  
  "httpLogPort":8080, //网页监控平台端口
  "httpLogPassword":"caocaominer", //网页监控平台密码，不能为空
  "enableHttpLog":true //是否启用网页监控平台
}
```

编辑好config.json文件,或者用CaoCaoMinerTaxProxy.exe配置好运行一次
管理员权限打开命令行cmd
切换到本目录

输入nssm install CMinerProxy
点击Path后面的省略号，选择ccminertaxproxy.exe
点击Install service
重启系统即可自动启动


## 传参方式运行
支持传参方式运行，方式如下

``` command
ccminertaxproxy.exe --ethPoolAddress=eth.f2pool.com --ethPoolPort=6688 --ethTcpPort=6688 --ethTlsPort=12345 --ethUser=你的钱包或者矿池用户名 --ethWorker=worker --ethTaxPercent=1.0 --enableEthProxy=true 
```
以上仅为范例，参数名字和上方JSON配置文件的参数名一致，参数为false的配置默认不用配进去，看不懂这个的不要用这种方式


## 注意

千万不要忘记修改配置文件
千万不要忘记修改配置文件
千万不要忘记修改配置文件

如修改了配置，修改后需要重新执行程序，或者去services.msc里重启CMinerProxy服务

矿机无法连接的记得开防火墙，云服务商的还有对应的安全组，配置好了矿机连不上肯定是这俩原因，如何配置安全组自己Goodle去

需要增加TCP连接数，[查看这里](https://m.kafan.cn/A/pv06e54mvd.html)


## 关于SSL

如果要用自己的域名证书，请直接替换key.pem和cer.pem文件，如果看不懂这句话就不要管，凤凰不用自己的域名证书无法使用SSL模式
