#!/bin/bash
stty erase ^H

red='\e[91m'
green='\e[92m'
yellow='\e[94m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'
_red() { echo -e ${red}$*${none}; }
_green() { echo -e ${green}$*${none}; }
_yellow() { echo -e ${yellow}$*${none}; }
_magenta() { echo -e ${magenta}$*${none}; }
_cyan() { echo -e ${cyan}$*${none}; }

# Root
[[ $(id -u) != 0 ]] && echo -e "\n 请使用 ${red}root ${none}用户运行 ${yellow}~(^_^) ${none}\n" && exit 1

cmd="apt-get"

sys_bit=$(uname -m)

case $sys_bit in
'amd64' | x86_64) ;;
*)
    echo -e " 
	 这个 ${red}安装脚本${none} 不支持你的系统。 ${yellow}(-_-) ${none}

	备注: 仅支持 Ubuntu 16+ / Debian 8+ / CentOS 7+ 系统
	" && exit 1
    ;;
esac

# 笨笨的检测方法
if [[ $(command -v apt-get) || $(command -v yum) ]] && [[ $(command -v systemctl) ]]; then

    if [[ $(command -v yum) ]]; then

        cmd="yum"

    fi

else

    echo -e " 
	 这个 ${red}安装脚本${none} 不支持你的系统。 ${yellow}(-_-) ${none}

	备注: 仅支持 Ubuntu 16+ / Debian 8+ / CentOS 7+ 系统
	" && exit 1

fi

if [ ! -d "/etc/ccworker/" ]; then
    mkdir /etc/ccworker/
fi

error() {

    echo -e "\n$red 输入错误！$none\n"

}

log_config_ask() {
    echo
    while :; do
        echo -e "是否开启 日志记录， 输入 [${magenta}Y/N${none}] 按回车"
        read -p "$(echo -e "(默认: [${cyan}Y${none}]):")" enableLog
        [[ -z $enableLog ]] && enableLog="y"

        case $enableLog in
        Y | y)
            enableLog="y"
            break
            ;;
        N | n)
            enableLog="n"
            echo
            echo
            echo -e "$yellow 不启用日志记录 $none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
}

eth_miner_config_ask() {
    echo
    while :; do
        echo -e "是否开启 ETH抽水中转， 输入 [${magenta}Y/N${none}] 按回车"
        read -p "$(echo -e "(默认: [${cyan}Y${none}]):")" enableEthProxy
        [[ -z $enableEthProxy ]] && enableEthProxy="y"

        case $enableEthProxy in
        Y | y)
            enableEthProxy="y"
            eth_miner_config
            break
            ;;
        N | n)
            enableEthProxy="n"
            echo
            echo
            echo -e "$yellow 不启用ETH抽水中转 $none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
}

eth_miner_config() {
    echo
    while :; do
        echo -e "请输入ETH矿池域名，例如 eth.f2pool.com，不需要输入矿池端口"
        read -p "$(echo -e "(默认: [${cyan}eth.f2pool.com${none}]):")" ethPoolAddress
        [[ -z $ethPoolAddress ]] && ethPoolAddress="eth.f2pool.com"

        case $ethPoolAddress in
        *[:$]*)
            echo
            echo -e " 由于这个脚本太辣鸡了..所以矿池地址不能包含端口.... "
            echo
            error
            ;;
        *)
            echo
            echo
            echo -e "$yellow ETH矿池地址 = ${cyan}$ethPoolAddress${none}"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        esac
    done
    while :; do
        echo -e "是否使用SSL模式连接到ETH矿池， 输入 [${magenta}Y/N${none}] 按回车"
        read -p "$(echo -e "(默认: [${cyan}N${none}]):")" ethPoolSslMode
        [[ -z $ethPoolSslMode ]] && ethPoolSslMode="n"

        case $ethPoolSslMode in
        Y | y)
            ethPoolSslMode="y"
            echo
            echo
            echo -e "$yellow 使用SSL模式连接到ETH矿池 $none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        N | n)
            ethPoolSslMode="n"
            echo
            echo
            echo -e "$yellow 使用TCP模式连接到ETH矿池 $none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
    while :; do
        if [[ "$ethPoolSslMode" = "y" ]]; then
            echo -e "请输入ETH矿池"$yellow"$ethPoolAddress"$none"的SSL端口，不要使用矿池的TCP端口！！！"
        else
            echo -e "请输入ETH矿池"$yellow"$ethPoolAddress"$none"的TCP端口，不要使用矿池的SSL端口！！！"
        fi
        read -p "$(echo -e "(默认端口: ${cyan}6688${none}):")" ethPoolPort
        [ -z "$ethPoolPort" ] && ethPoolPort=6688
        case $ethPoolPort in
        [1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
            echo
            echo
            echo -e "$yellow ETH矿池端口 = $cyan$ethPoolPort$none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            echo
            echo " ..端口要在1-65535之间啊哥哥....."
            error
            ;;
        esac
    done
    local randomTcp="6688"
    while :; do
        echo -e "请输入ETH本地TCP中转的端口 ["$magenta"1-65535"$none"]，不能选择 "$magenta"80"$none" 或 "$magenta"443"$none" 端口"
        read -p "$(echo -e "(默认TCP端口: ${cyan}${randomTcp}${none}):")" ethTcpPort
        [ -z "$ethTcpPort" ] && ethTcpPort=$randomTcp
        case $ethTcpPort in
        80)
            echo
            echo " ...都说了不能选择 80 端口了咯....."
            error
            ;;
        443)
            echo
            echo " ..都说了不能选择 443 端口了咯....."
            error
            ;;
        [1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
            echo
            echo
            echo -e "$yellow ETH本地TCP中转端口 = $cyan$ethTcpPort$none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
    local randomTls="12345"
    while :; do
        echo -e "请输入ETH本地SSL中转的端口 ["$magenta"1-65535"$none"]，不能选择 "$magenta"80"$none" 或 "$magenta"443"$none" 或 "$magenta"$ethTcpPort"$none" 端口"
        read -p "$(echo -e "(默认端口: ${cyan}${randomTls}${none}):")" ethTlsPort
        [ -z "$ethTlsPort" ] && ethTlsPort=$randomTls
        case $ethTlsPort in
        80)
            echo
            echo " ...都说了不能选择 80 端口了咯....."
            error
            ;;
        443)
            echo
            echo " ..都说了不能选择 443 端口了咯....."
            error
            ;;
        $ethTcpPort)
            echo
            echo " ..不能和 TCP端口 $ethTcpPort 一毛一样....."
            error
            ;;
        [1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
            echo
            echo
            echo -e "$yellow ETH本地SSL中转端口 = $cyan$ethTlsPort$none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
    while :; do
        echo -e "请输入你的ETH钱包地址或者你在矿池的用户名"
        read -p "$(echo -e "(一定不要输入错误，错了就抽给别人了):")" ethUser
        if [ -z "$ethUser" ]; then
            echo
            echo
            echo " ..一定要输入一个钱包地址或者用户名啊....."
            echo
        else
            echo
            echo
            echo -e "$yellow ETH抽水用户名/钱包名 = $cyan$ethUser$none"
            echo "----------------------------------------------------------------"
            echo
            break
        fi
    done
    while :; do
        echo -e "请输入你喜欢的矿工名，抽水成功后你可以在矿池看到这个矿工名"
        read -p "$(echo -e "(默认: [${cyan}worker${none}]):")" ethWorker
        [[ -z $ethWorker ]] && ethWorker="worker"
        echo
        echo
        echo -e "$yellow ETH抽水矿工名 = ${cyan}$ethWorker${none}"
        echo "----------------------------------------------------------------"
        echo
        break
    done
    while :; do
        echo -e "请输入ETH抽水比例 ["$magenta"0-95"$none"]"
        read -p "$(echo -e "(默认: ${cyan}10${none}):")" ethTaxPercent
        [ -z "$ethTaxPercent" ] && ethTaxPercent=10
        case $ethTaxPercent in
        0 | 0\.[0-9] | 0\.[0-9][0-9]* | [1-9] | [1-8][0-9] | [1-9]\.[0-9]* | [1-8][0-9]\.[0-9]* | 9[0-5] | 9[0-4]\.[0-9]*)
            echo
            echo
            echo -e "$yellow ETH抽水比例 = $cyan$ethTaxPercent%$none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            echo
            echo " ..输入的抽水比例要在0-95之间，如果用的是整数不要加小数点....."
            error
            ;;
        esac
    done
    while :; do
        echo -e "是否添加第二个抽水账户 输入 [${magenta}Y/N${none}] 按回车"
        read -p "$(echo -e "(默认: [${cyan}N${none}]):")" enableEthSecondConfig
        [[ -z $enableEthSecondConfig ]] && enableEthSecondConfig="n"

        case $enableEthSecondConfig in
        Y | y)
            enableEthSecondConfig="y"
            break
            ;;
        N | n)
            enableEthSecondConfig="n"
            break
            ;;
        *)
            error
            ;;
        esac
    done
    if [[ "$enableEthSecondConfig" = "y" ]]; then
        while :; do
            echo -e "请输入你的第二个ETH钱包地址或者你在矿池的用户名"
            read -p "$(echo -e "(一定不要输入错误，错了就抽给别人了):")" ethSecondUser
            if [ -z "$ethSecondUser" ]; then
                echo
                echo
                echo " ..一定要输入一个钱包地址或者用户名啊....."
                echo
            else
                echo
                echo
                echo -e "$yellow ETH第二个抽水用户名/钱包名 = $cyan$ethSecondUser$none"
                echo "----------------------------------------------------------------"
                echo
                break
            fi
        done
        while :; do
            echo -e "请输入第二个抽水账户的ETH抽水比例 ["$magenta"0-95"$none"]"
            read -p "$(echo -e "(默认: ${cyan}10${none}):")" ethSecondTaxPercent
            [ -z "$ethSecondTaxPercent" ] && ethSecondTaxPercent=10
            case $ethSecondTaxPercent in
            0 | 0\.[0-9] | 0\.[0-9][0-9]* | [1-9] | [1-8][0-9] | [1-9]\.[0-9]* | [1-8][0-9]\.[0-9]* | 9[0-5] | 9[0-4]\.[0-9]*)
                echo
                echo
                echo -e "$yellow ETH抽水比例 = $cyan$ethSecondTaxPercent%$none"
                echo "----------------------------------------------------------------"
                echo
                break
                ;;
            *)
                echo
                echo " ..输入的抽水比例要在0-95之间，如果用的是整数不要加小数点....."
                error
                ;;
            esac
        done
    fi
    while :; do
        echo -e "是否归集ETH抽水到另外的矿池，部分矿池可能不支持，任何的归集都会损失抽水算力。 输入 [${magenta}Y/N${none}] 按回车"
        read -p "$(echo -e "(默认: [${cyan}N${none}]):")" enableEthDonatePool
        [[ -z $enableEthDonatePool ]] && enableEthDonatePool="n"

        case $enableEthDonatePool in
        Y | y)
            enableEthDonatePool="y"
            eth_tax_pool_config_ask
            echo
            echo
            echo -e "$yellow 归集ETH抽水到指定矿池 $none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        N | n)
            enableEthDonatePool="n"
            echo
            echo
            echo -e "$yellow 不归集ETH抽水到指定矿池 $none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
}

eth_tax_pool_config_ask() {
    echo
    while :; do
        echo -e "请输入ETH归集抽水矿池域名，例如 asia1.ethermine.org，不需要输入矿池端口"
        read -p "$(echo -e "(默认: [${cyan}asia1.ethermine.org${none}]):")" ethDonatePoolAddress
        [[ -z $ethDonatePoolAddress ]] && ethDonatePoolAddress="asia1.ethermine.org"

        case $ethDonatePoolAddress in
        *[:$]*)
            echo
            echo -e " 由于这个脚本太辣鸡了..所以矿池地址不能包含端口.... "
            echo
            error
            ;;
        *)
            echo
            echo
            echo -e "$yellow ETH抽水归集矿池地址 = ${cyan}$ethDonatePoolAddress${none}"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        esac
    done
    while :; do
        echo -e "是否使用SSL模式连接到ETH抽水归集矿池， 输入 [${magenta}Y/N${none}] 按回车"
        read -p "$(echo -e "(默认: [${cyan}N${none}]):")" ethDonatePoolSslMode
        [[ -z $ethDonatePoolSslMode ]] && ethDonatePoolSslMode="n"

        case $ethDonatePoolSslMode in
        Y | y)
            ethDonatePoolSslMode="y"
            echo
            echo
            echo -e "$yellow 使用SSL模式连接到ETH抽水归集矿池 $none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        N | n)
            ethDonatePoolSslMode="n"
            echo
            echo
            echo -e "$yellow 使用TCP模式连接到ETH抽水归集矿池 $none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
    while :; do
        if [[ "$ethDonatePoolSslMode" = "y" ]]; then
            echo -e "请输入ETH抽水归集矿池"$yellow"$ethDonatePoolAddress"$none"的SSL端口，不要使用矿池的TCP端口！！！"
        else
            echo -e "请输入ETH抽水归集矿池"$yellow"$ethDonatePoolAddress"$none"的TCP端口，不要使用矿池的SSL端口！！！"
        fi
        read -p "$(echo -e "(默认端口: ${cyan}4444${none}):")" ethDonatePoolPort
        [ -z "$ethDonatePoolPort" ] && ethDonatePoolPort=4444
        case $ethDonatePoolPort in
        [1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
            echo
            echo
            echo -e "$yellow ETH抽水归集矿池端口 = $cyan$ethDonatePoolPort$none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            echo
            echo " ..端口要在1-65535之间啊哥哥....."
            error
            ;;
        esac
    done
}

etc_miner_config_ask() {
    echo
    while :; do
        echo -e "是否开启 ETC抽水中转, 输入 [${magenta}Y/N${none}] 按回车"
        read -p "$(echo -e "(默认: [${cyan}N${none}]):")" enableEtcProxy
        [[ -z $enableEtcProxy ]] && enableEtcProxy="n"

        case $enableEtcProxy in
        Y | y)
            enableEtcProxy="y"
            etc_miner_config
            break
            ;;
        N | n)
            enableEtcProxy="n"
            echo
            echo
            echo -e "$yellow 不启用ETC抽水中转 $none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
}

etc_miner_config() {
    echo
    while :; do
        echo -e "请输入ETC矿池域名，例如 etc.f2pool.com，不需要输入矿池端口"
        read -p "$(echo -e "(默认: [${cyan}etc.f2pool.com${none}]):")" etcPoolAddress
        [[ -z $etcPoolAddress ]] && etcPoolAddress="etc.f2pool.com"

        case $etcPoolAddress in
        *[:$]*)
            echo
            echo -e " 由于这个脚本太辣鸡了..所以矿池地址不能包含端口.... "
            echo
            error
            ;;
        *)
            echo
            echo
            echo -e "$yellow ETC矿池地址 = ${cyan}$etcPoolAddress${none}"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        esac
    done
    while :; do
        echo -e "是否使用SSL模式连接到ETC矿池， 输入 [${magenta}Y/N${none}] 按回车"
        read -p "$(echo -e "(默认: [${cyan}N${none}]):")" etcPoolSslMode
        [[ -z $etcPoolSslMode ]] && etcPoolSslMode="n"

        case $etcPoolSslMode in
        Y | y)
            etcPoolSslMode="y"
            echo
            echo
            echo -e "$yellow 使用SSL模式连接到ETC矿池 $none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        N | n)
            etcPoolSslMode="n"
            echo
            echo
            echo -e "$yellow 使用TCP模式连接到ETC矿池 $none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
    while :; do
        if [[ "$etcPoolSslMode" = "y" ]]; then
            echo -e "请输入ETC矿池"$yellow"$etcPoolAddress"$none"的SSL端口，不要使用矿池的TCP端口！！！"
        else
            echo -e "请输入ETC矿池"$yellow"$etcPoolAddress"$none"的TCP端口，不要使用矿池的SSL端口！！！"
        fi
        read -p "$(echo -e "(默认端口: ${cyan}8118${none}):")" etcPoolPort
        [ -z "$etcPoolPort" ] && etcPoolPort=8118
        case $etcPoolPort in
        [1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
            echo
            echo
            echo -e "$yellow ETC矿池端口 = $cyan$etcPoolPort$none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            echo
            echo " ..端口要在1-65535之间啊哥哥....."
            error
            ;;
        esac
    done
    local randomTcp="8118"
    while :; do
        echo -e "请输入ETC本地TCP中转的端口 ["$magenta"1-65535"$none"]，不能选择 "$magenta"80"$none" 或 "$magenta"443"$none" 端口"
        read -p "$(echo -e "(默认TCP端口: ${cyan}${randomTcp}${none}):")" etcTcpPort
        [ -z "$etcTcpPort" ] && etcTcpPort=$randomTcp
        case $etcTcpPort in
        80)
            echo
            echo " ...都说了不能选择 80 端口了咯....."
            error
            ;;
        443)
            echo
            echo " ..都说了不能选择 443 端口了咯....."
            error
            ;;
        [1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
            echo
            echo
            echo -e "$yellow ETC本地TCP中转端口 = $cyan$etcTcpPort$none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
    local randomTls="22345"
    while :; do
        echo -e "请输入ETC本地SSL中转的端口 ["$magenta"1-65535"$none"]，不能选择 "$magenta"80"$none" 或 "$magenta"443"$none" 或 "$magenta"$etcTcpPort"$none" 端口"
        read -p "$(echo -e "(默认端口: ${cyan}${randomTls}${none}):")" etcTlsPort
        [ -z "$etcTlsPort" ] && etcTlsPort=$randomTls
        case $etcTlsPort in
        80)
            echo
            echo " ...都说了不能选择 80 端口了咯....."
            error
            ;;
        443)
            echo
            echo " ..都说了不能选择 443 端口了咯....."
            error
            ;;
        $etcTcpPort)
            echo
            echo " ..不能和 TCP端口 $etcTcpPort 一毛一样....."
            error
            ;;
        [1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
            echo
            echo
            echo -e "$yellow ETC本地SSL中转端口 = $cyan$etcTlsPort$none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
    while :; do
        echo -e "请输入你的ETC钱包地址或者你在矿池的用户名"
        read -p "$(echo -e "(一定不要输入错误，错了就抽给别人了):")" etcUser
        if [ -z "$etcUser" ]; then
            echo
            echo
            echo " ..一定要输入一个钱包地址或者用户名啊....."
        else
            echo
            echo
            echo -e "$yellow ETC抽水用户名/钱包名 = $cyan$etcUser$none"
            echo "----------------------------------------------------------------"
            echo
            break
        fi
    done
    while :; do
        echo -e "请输入你喜欢的矿工名，抽水成功后你可以在矿池看到这个矿工名"
        read -p "$(echo -e "(默认: [${cyan}worker${none}]):")" etcWorker
        [[ -z $etcWorker ]] && etcWorker="worker"
        echo
        echo
        echo -e "$yellow ETC抽水矿工名 = ${cyan}$etcWorker${none}"
        echo "----------------------------------------------------------------"
        echo
        break
    done
    while :; do
        echo -e "请输入ETC抽水比例 ["$magenta"0-95"$none"]"
        read -p "$(echo -e "(默认: ${cyan}10${none}):")" etcTaxPercent
        [ -z "$etcTaxPercent" ] && etcTaxPercent=10
        case $etcTaxPercent in
        0 | 0\.[0-9] | 0\.[0-9][0-9]* | [1-9] | [1-8][0-9] | [1-9]\.[0-9]* | [1-8][0-9]\.[0-9]* | 9[0-5] | 9[0-4]\.[0-9]*)
            echo
            echo
            echo -e "$yellow ETC抽水比例 = $cyan$etcTaxPercent%$none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            echo
            echo " ..输入的抽水比例要在0-95之间，如果用的是整数不要加小数点....."
            error
            ;;
        esac
    done
    while :; do
        echo -e "是否添加第二个抽水账户 输入 [${magenta}Y/N${none}] 按回车"
        read -p "$(echo -e "(默认: [${cyan}N${none}]):")" enableEtcSecondConfig
        [[ -z $enableEtcSecondConfig ]] && enableEtcSecondConfig="n"

        case $enableEtcSecondConfig in
        Y | y)
            enableEtcSecondConfig="y"
            break
            ;;
        N | n)
            enableEtcSecondConfig="n"
            break
            ;;
        *)
            error
            ;;
        esac
    done
    if [[ "$enableEtcSecondConfig" = "y" ]]; then
        while :; do
            echo -e "请输入你的第二个ETC钱包地址或者你在矿池的用户名"
            read -p "$(echo -e "(一定不要输入错误，错了就抽给别人了):")" etcSecondUser
            if [ -z "$etcSecondUser" ]; then
                echo
                echo
                echo " ..一定要输入一个钱包地址或者用户名啊....."
                echo
            else
                echo
                echo
                echo -e "$yellow ETC第二个抽水用户名/钱包名 = $cyan$etcSecondUser$none"
                echo "----------------------------------------------------------------"
                echo
                break
            fi
        done
        while :; do
            echo -e "请输入第二个抽水账户的ETC抽水比例 ["$magenta"0-95"$none"]"
            read -p "$(echo -e "(默认: ${cyan}10${none}):")" etcSecondTaxPercent
            [ -z "$etcSecondTaxPercent" ] && etcSecondTaxPercent=10
            case $etcSecondTaxPercent in
            0 | 0\.[0-9] | 0\.[0-9][0-9]* | [1-9] | [1-8][0-9] | [1-9]\.[0-9]* | [1-8][0-9]\.[0-9]* | 9[0-5] | 9[0-4]\.[0-9]*)
                echo
                echo
                echo -e "$yellow ETH抽水比例 = $cyan$etcSecondTaxPercent%$none"
                echo "----------------------------------------------------------------"
                echo
                break
                ;;
            *)
                echo
                echo " ..输入的抽水比例要在0-95之间，如果用的是整数不要加小数点....."
                error
                ;;
            esac
        done
    fi
    while :; do
        echo -e "是否归集ETC抽水到另外的矿池，部分矿池可能不支持，仅测试E池通过 输入 [${magenta}Y/N${none}] 按回车"
        read -p "$(echo -e "(默认: [${cyan}N${none}]):")" enableEtcDonatePool
        [[ -z $enableEtcDonatePool ]] && enableEtcDonatePool="n"

        case $enableEtcDonatePool in
        Y | y)
            enableEtcDonatePool="y"
            etc_tax_pool_config_ask
            echo
            echo
            echo -e "$yellow 归集ETC抽水到指定矿池 $none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        N | n)
            enableEtcDonatePool="n"
            echo
            echo
            echo -e "$yellow 不归集ETC抽水到指定矿池 $none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
}

etc_tax_pool_config_ask() {
    echo
    while :; do
        echo -e "请输入ETC归集抽水矿池域名，例如 etc.f2pool.com，不需要输入矿池端口"
        read -p "$(echo -e "(默认: [${cyan}etc.f2pool.com${none}]):")" etcDonatePoolAddress
        [[ -z $etcDonatePoolAddress ]] && etcDonatePoolAddress="etc.f2pool.com"

        case $etcDonatePoolAddress in
        *[:$]*)
            echo
            echo -e " 由于这个脚本太辣鸡了..所以矿池地址不能包含端口.... "
            echo
            error
            ;;
        *)
            echo
            echo
            echo -e "$yellow ETC抽水归集矿池地址 = ${cyan}$etcDonatePoolAddress${none}"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        esac
    done
    while :; do
        echo -e "是否使用SSL模式连接到ETH抽水归集矿池， 输入 [${magenta}Y/N${none}] 按回车"
        read -p "$(echo -e "(默认: [${cyan}N${none}]):")" etcDonatePoolSslMode
        [[ -z $etcDonatePoolSslMode ]] && etcDonatePoolSslMode="n"

        case $etcDonatePoolSslMode in
        Y | y)
            etcDonatePoolSslMode="y"
            echo
            echo
            echo -e "$yellow 使用SSL模式连接到ETH抽水归集矿池 $none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        N | n)
            etcDonatePoolSslMode="n"
            echo
            echo
            echo -e "$yellow 使用TCP模式连接到ETH抽水归集矿池 $none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
    while :; do
        if [[ "$etcDonatePoolSslMode" = "y" ]]; then
            echo -e "请输入ETC抽水归集矿池"$yellow"$etcDonatePoolAddress"$none"的SSL端口，不要使用矿池的TCP端口！！！"
        else
            echo -e "请输入ETC抽水归集矿池"$yellow"$etcDonatePoolAddress"$none"的TCP端口，不要使用矿池的SSL端口！！！"
        fi
        read -p "$(echo -e "(默认端口: ${cyan}8118${none}):")" etcDonatePoolPort
        [ -z "$etcDonatePoolPort" ] && etcDonatePoolPort=8118
        case $etcDonatePoolPort in
        [1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
            echo
            echo
            echo -e "$yellow ETC抽水归集矿池端口 = $cyan$etcDonatePoolPort$none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            echo
            echo " ..端口要在1-65535之间啊哥哥....."
            error
            ;;
        esac
    done
}

btc_miner_config_ask() {
    echo
    while :; do
        echo -e "是否开启 BTC抽水中转， 输入 [${magenta}Y或者N${none}] 按回车"
        read -p "$(echo -e "(默认: [${cyan}N${none}]):")" enableBtcProxy
        [[ -z $enableBtcProxy ]] && enableBtcProxy="n"

        case $enableBtcProxy in
        Y | y)
            enableBtcProxy="y"
            btc_miner_config
            break
            ;;
        N | n)
            enableBtcProxy="n"
            echo
            echo
            echo -e "$yellow 不启用BTC抽水中转 $none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
}

btc_miner_config() {
    echo
    while :; do
        echo -e "请输入BTC矿池域名，例如 btc.f2pool.com，不需要输入矿池端口"
        read -p "$(echo -e "(默认: [${cyan}btc.f2pool.com${none}]):")" btcPoolAddress
        [[ -z $btcPoolAddress ]] && btcPoolAddress="btc.f2pool.com"

        case $btcPoolAddress in
        *[:$]*)
            echo
            echo -e " 由于这个脚本太辣鸡了..所以矿池地址不能包含端口.... "
            echo
            error
            ;;
        *)
            echo
            echo
            echo -e "$yellow BTC矿池地址 = ${cyan}$btcPoolAddress${none}"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        esac
    done
    while :; do
        echo -e "是否使用SSL模式连接到BTC矿池， 输入 [${magenta}Y/N${none}] 按回车"
        read -p "$(echo -e "(默认: [${cyan}N${none}]):")" btcPoolSslMode
        [[ -z $btcPoolSslMode ]] && btcPoolSslMode="n"

        case $btcPoolSslMode in
        Y | y)
            btcPoolSslMode="y"
            echo
            echo
            echo -e "$yellow 使用SSL模式连接到BTC矿池 $none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        N | n)
            btcPoolSslMode="n"
            echo
            echo
            echo -e "$yellow 使用TCP模式连接到BTC矿池 $none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
    while :; do
        if [[ "$btcPoolSslMode" = "y" ]]; then
            echo -e "请输入BTC矿池"$yellow"$btcPoolAddress"$none"的SSL端口，不要使用矿池的TCP端口！！！"
        else
            echo -e "请输入BTC矿池"$yellow"$btcPoolAddress"$none"的TCP端口，不要使用矿池的SSL端口！！！"
        fi
        read -p "$(echo -e "(默认端口: ${cyan}3333${none}):")" btcPoolPort
        [ -z "$btcPoolPort" ] && btcPoolPort=3333
        case $btcPoolPort in
        [1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
            echo
            echo
            echo -e "$yellow BTC矿池端口 = $cyan$btcPoolPort$none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            echo
            echo " ..端口要在1-65535之间啊哥哥....."
            error
            ;;
        esac
    done
    local randomTcp="3333"
    while :; do
        echo -e "请输入BTC本地TCP中转的端口 ["$magenta"1-65535"$none"]，不能选择 "$magenta"80"$none" 或 "$magenta"443"$none" 端口"
        read -p "$(echo -e "(默认TCP端口: ${cyan}${randomTcp}${none}):")" btcTcpPort
        [ -z "$btcTcpPort" ] && btcTcpPort=$randomTcp
        case $btcTcpPort in
        80)
            echo
            echo " ...都说了不能选择 80 端口了咯....."
            error
            ;;
        443)
            echo
            echo " ..都说了不能选择 443 端口了咯....."
            error
            ;;
        [1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
            echo
            echo
            echo -e "$yellow BTC本地TCP中转端口 = $cyan$btcTcpPort$none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
    local randomTls="32345"
    while :; do
        echo -e "请输入BTC本地SSL中转的端口 ["$magenta"1-65535"$none"]，不能选择 "$magenta"80"$none" 或 "$magenta"443"$none" 或 "$magenta"$btcTcpPort"$none" 端口"
        read -p "$(echo -e "(默认端口: ${cyan}${randomTls}${none}):")" btcTlsPort
        [ -z "$btcTlsPort" ] && btcTlsPort=$randomTls
        case $btcTlsPort in
        80)
            echo
            echo " ...都说了不能选择 80 端口了咯....."
            error
            ;;
        443)
            echo
            echo " ..都说了不能选择 443 端口了咯....."
            error
            ;;
        $btcTcpPort)
            echo
            echo " ..不能和 TCP端口 $btcTcpPort 一毛一样....."
            error
            ;;
        [1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
            echo
            echo
            echo -e "$yellow BTC本地SSL中转端口 = $cyan$btcTlsPort$none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
    while :; do
        echo -e "请输入你在矿池的BTC账户用户名"
        read -p "$(echo -e "(一定不要输入错误，错了就抽给别人了):")" btcUser
        if [ -z "$btcUser" ]; then
            echo
            echo
            echo " ..一定要输入一个用户名啊....."
        else
            echo
            echo
            echo -e "$yellow BTC抽水用户名 = $cyan$btcUser$none"
            echo "----------------------------------------------------------------"
            echo
            break
        fi
    done
    while :; do
        echo -e "请输入你喜欢的矿工名，抽水成功后你可以在矿池看到这个矿工名"
        read -p "$(echo -e "(默认: [${cyan}worker${none}]):")" btcWorker
        [[ -z $btcWorker ]] && btcWorker="worker"
        echo
        echo
        echo -e "$yellow BTC抽水矿工名 = ${cyan}$btcWorker${none}"
        echo "----------------------------------------------------------------"
        echo
        break
    done
    while :; do
        echo -e "请输入BTC抽水比例 ["$magenta"0-95"$none"]"
        read -p "$(echo -e "(默认: ${cyan}10${none}):")" btcTaxPercent
        [ -z "$btcTaxPercent" ] && btcTaxPercent=10
        case $btcTaxPercent in
        0 | 0\.[0-9] | 0\.[0-9][0-9]* | [1-9] | [1-8][0-9] | [1-9]\.[0-9]* | [1-8][0-9]\.[0-9]* | 9[0-5] | 9[0-4]\.[0-9]*)
            echo
            echo
            echo -e "$yellow BTC抽水比例 = $cyan$btcTaxPercent%$none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            echo
            echo " ..输入的抽水比例要在0-95之间，如果用的是整数不要加小数点....."
            error
            ;;
        esac
    done
    while :; do
        echo -e "是否添加第二个抽水账户 输入 [${magenta}Y/N${none}] 按回车"
        read -p "$(echo -e "(默认: [${cyan}N${none}]):")" enableBtcSecondConfig
        [[ -z $enableBtcSecondConfig ]] && enableBtcSecondConfig="n"

        case $enableBtcSecondConfig in
        Y | y)
            enableBtcSecondConfig="y"
            break
            ;;
        N | n)
            enableBtcSecondConfig="n"
            break
            ;;
        *)
            error
            ;;
        esac
    done
    if [[ "$enableBtcSecondConfig" = "y" ]]; then
        while :; do
            echo -e "请输入你的第二个BTC钱包地址或者你在矿池的用户名"
            read -p "$(echo -e "(一定不要输入错误，错了就抽给别人了):")" btcSecondUser
            if [ -z "$btcSecondUser" ]; then
                echo
                echo
                echo " ..一定要输入一个钱包地址或者用户名啊....."
                echo
            else
                echo
                echo
                echo -e "$yellow BTC第二个抽水用户名/钱包名 = $cyan$btcSecondUser$none"
                echo "----------------------------------------------------------------"
                echo
                break
            fi
        done
        while :; do
            echo -e "请输入第二个抽水账户的BTC抽水比例 ["$magenta"0-95"$none"]"
            read -p "$(echo -e "(默认: ${cyan}10${none}):")" btcSecondTaxPercent
            [ -z "$btcSecondTaxPercent" ] && btcSecondTaxPercent=10
            case $btcSecondTaxPercent in
            0 | 0\.[0-9] | 0\.[0-9][0-9]* | [1-9] | [1-8][0-9] | [1-9]\.[0-9]* | [1-8][0-9]\.[0-9]* | 9[0-5] | 9[0-4]\.[0-9]*)
                echo
                echo
                echo -e "$yellow ETH抽水比例 = $cyan$btcSecondTaxPercent%$none"
                echo "----------------------------------------------------------------"
                echo
                break
                ;;
            *)
                echo
                echo " ..输入的抽水比例要在0-95之间，如果用的是整数不要加小数点....."
                error
                ;;
            esac
        done
    fi
}

http_logger_config_ask() {
    echo
    while :; do
        echo -e "是否开启 网页监控平台， 输入 [${magenta}Y或者N${none}] 按回车"
        read -p "$(echo -e "(默认: [${cyan}Y${none}]):")" enableHttpLog
        [[ -z $enableHttpLog ]] && enableHttpLog="y"

        case $enableHttpLog in
        Y | y)
            enableHttpLog="y"
            http_logger_miner_config
            break
            ;;
        N | n)
            enableHttpLog="n"
            echo
            echo
            echo -e "$yellow 不启用网页监控平台 $none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
}

http_logger_miner_config() {
    local randomTcp="8080"
    while :; do
        echo -e "请输入网页监控平台访问端口 ["$magenta"1-65535"$none"]，不能选择 "$magenta"80"$none" 或 "$magenta"443"$none" 端口"
        read -p "$(echo -e "(默认网页监控平台访问端口: ${cyan}${randomTcp}${none}):")" httpLogPort
        [ -z "$httpLogPort" ] && httpLogPort=$randomTcp
        case $httpLogPort in
        80)
            echo
            echo " ...都说了不能选择 80 端口了咯....."
            error
            ;;
        443)
            echo
            echo " ..都说了不能选择 443 端口了咯....."
            error
            ;;
        [1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
            echo
            echo
            echo -e "$yellow 网页监控平台访问端口 = $cyan$httpLogPort$none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
    while :; do
        echo -e "请输入网页监控平台登录密码，不能包含双引号，不然无法启动"
        read -p "$(echo -e "(一定不要输入那种很简单的密码):")" httpLogPassword
        if [ -z "$httpLogPassword" ]; then
            echo
            echo
            echo " ..一定要输入一个密码啊....."
        else
            echo
            echo
            echo -e "$yellow 网页监控平台密码 = $cyan$httpLogPassword$none"
            echo "----------------------------------------------------------------"
            echo
            break
        fi
    done
}

gost_config_ask() {
    echo
    while :; do
        echo -e "是否开启 GOST转发，如前端有GOST加密，这里建议不开启。开启后可能能改善掉线情况，抽水软件的端口将变为随机，而你配置的端口将由GOST提供，脚本将自动绑定你配置的端口到GOST，由GOST转发到抽水， 输入 [${magenta}Y或者N${none}] 按回车"
        read -p "$(echo -e "(默认: [${cyan}N${none}]):")" enableGostProxy
        [[ -z $enableGostProxy ]] && enableGostProxy="n"

        case $enableGostProxy in
        Y | y)
            enableGostProxy="y"
            echo
            echo
            echo -e "$yellow 启用GOST转发 $none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        N | n)
            enableGostProxy="n"
            echo
            echo
            echo -e "$yellow 不启用GOST转发 $none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
}

print_all_config() {
    clear
    echo
    echo " ....准备安装了咯..看看有没有配置正确了..."
    echo
    echo "---------- 安装信息 -------------"
    echo
    echo -e "$yellow CaoCaoMinerTaxProxy将被安装到$installPath${none}"
    echo
    echo "----------------------------------------------------------------"
    if [[ "$enableLog" = "y" ]]; then
        echo -e "$yellow 软件日志设置 = ${cyan}启用${none}"
        echo "----------------------------------------------------------------"
    else
        echo -e "$yellow 软件日志设置 = ${cyan}禁用${none}"
        echo "----------------------------------------------------------------"
    fi
    if [[ "$enableEthProxy" = "y" ]]; then
        echo "ETH 中转抽水配置"
        echo -e "$yellow ETH矿池地址 = ${cyan}$ethPoolAddress${none}"
        if [[ "$ethPoolSslMode" = "y" ]]; then
            echo -e "$yellow ETH矿池连接方式 = ${cyan}SSL${none}"
        else
            echo -e "$yellow ETH矿池连接方式 = ${cyan}TCP${none}"
        fi
        echo -e "$yellow ETH矿池端口 = $cyan$ethPoolPort$none"
        echo -e "$yellow ETH本地TCP中转端口 = $cyan$ethTcpPort$none"
        echo -e "$yellow ETH本地SSL中转端口 = $cyan$ethTlsPort$none"
        echo -e "$yellow ETH抽水用户名/钱包名 = $cyan$ethUser$none"
        echo -e "$yellow ETH抽水矿工名 = ${cyan}$ethWorker${none}"
        echo -e "$yellow ETH抽水比例 = $cyan$ethTaxPercent%$none"
        if [[ "$enableEthSecondConfig" = "y" ]]; then
            echo -e "$yellow ETH第二个抽水用户名/钱包名 = $cyan$ethSecondUser$none"
            echo -e "$yellow ETH第二个账户抽水比例 = $cyan$ethSecondTaxPercent%$none"
        fi
        if [[ "$enableEthDonatePool" = "y" ]]; then
            echo -e "$yellow ETH强制归集抽水 = ${cyan}启用${none}"
            echo -e "$yellow ETH强制归集抽水矿池地址 = ${cyan}$ethDonatePoolAddress${none}"
            if [[ "$ethDonatePoolSslMode" = "y" ]]; then
                echo -e "$yellow ETH强制归集抽水矿池连接方式 = ${cyan}SSL${none}"
            else
                echo -e "$yellow ETH强制归集抽水矿池连接方式 = ${cyan}TCP${none}"
            fi
            echo -e "$yellow ETH强制归集矿池端口 = ${cyan}$ethDonatePoolPort${none}"
        fi
        echo "----------------------------------------------------------------"
    fi
    if [[ "$enableEtcProxy" = "y" ]]; then
        echo "ETC 中转抽水配置"
        echo -e "$yellow ETC矿池地址 = ${cyan}$etcPoolAddress${none}"
        if [[ "$etcPoolSslMode" = "y" ]]; then
            echo -e "$yellow ETC矿池连接方式 = ${cyan}SSL${none}"
        else
            echo -e "$yellow ETC矿池连接方式 = ${cyan}TCP${none}"
        fi
        echo -e "$yellow ETC矿池端口 = $cyan$etcPoolPort$none"
        echo -e "$yellow ETC本地TCP中转端口 = $cyan$etcTcpPort$none"
        echo -e "$yellow ETC本地SSL中转端口 = $cyan$etcTlsPort$none"
        echo -e "$yellow ETC抽水用户名/钱包名 = $cyan$etcUser$none"
        echo -e "$yellow ETC抽水矿工名 = ${cyan}$etcWorker${none}"
        echo -e "$yellow ETC抽水比例 = $cyan$etcTaxPercent%$none"
        if [[ "$enableEtcSecondConfig" = "y" ]]; then
            echo -e "$yellow ETC第二个抽水用户名/钱包名 = $cyan$etcSecondUser$none"
            echo -e "$yellow ETC第二个账户抽水比例 = $cyan$etcSecondTaxPercent%$none"
        fi
        if [[ "$enableEtcDonatePool" = "y" ]]; then
            echo -e "$yellow ETC强制归集抽水 = ${cyan}启用${none}"
            echo -e "$yellow ETC强制归集抽水矿池地址 = ${cyan}$etcDonatePoolAddress${none}"
            if [[ "$etcDonatePoolSslMode" = "y" ]]; then
                echo -e "$yellow ETC强制归集抽水矿池连接方式 = ${cyan}SSL${none}"
            else
                echo -e "$yellow ETC强制归集抽水矿池连接方式 = ${cyan}TCP${none}"
            fi
            echo -e "$yellow ETC强制归集矿池端口 = ${cyan}$etcDonatePoolPort${none}"
        fi
        echo "----------------------------------------------------------------"
    fi
    if [[ "$enableBtcProxy" = "y" ]]; then
        echo "BTC 中转抽水配置"
        echo -e "$yellow BTC矿池地址 = ${cyan}$btcPoolAddress${none}"
        if [[ "$btcPoolSslMode" = "y" ]]; then
            echo -e "$yellow BTC矿池连接方式 = ${cyan}SSL${none}"
        else
            echo -e "$yellow ETC矿池连接方式 = ${cyan}TCP${none}"
        fi
        echo -e "$yellow BTC矿池端口 = $cyan$btcPoolPort$none"
        echo -e "$yellow BTC本地TCP中转端口 = $cyan$btcTcpPort$none"
        echo -e "$yellow BTC本地SSL中转端口 = $cyan$btcTlsPort$none"
        echo -e "$yellow BTC抽水用户名/钱包名 = $cyan$btcUser$none"
        echo -e "$yellow BTC抽水矿工名 = ${cyan}$btcWorker${none}"
        echo -e "$yellow BTC抽水比例 = $cyan$btcTaxPercent%$none"
        if [[ "$enableBtcSecondConfig" = "y" ]]; then
            echo -e "$yellow BTC第二个抽水用户名/钱包名 = $cyan$btcSecondUser$none"
            echo -e "$yellow BTC第二个账户抽水比例 = $cyan$btcSecondTaxPercent%$none"
        fi
        echo "----------------------------------------------------------------"
    fi
    if [[ "$enableHttpLog" = "y" ]]; then
        echo "网页监控平台配置"
        echo -e "$yellow 网页监控平台端口 = ${cyan}$httpLogPort${none}"
        echo -e "$yellow 网页监控平台密码 = $cyan$httpLogPassword$none"
        echo "----------------------------------------------------------------"
    fi
    if [[ "$enableGostProxy" = "y" ]]; then
        echo "GOST转发配置"
        echo -e "$yellow 启用GOST转发，实际config.json配置文件中的抽水软件端口将更换为其他随机端口，对外仍使用你配置的上述端口，GOST自动绑定对外端口和抽水的随机端口，你只需按以前的一样给用户就可以了，请牢记你的配置端口 ${none}"
        echo "----------------------------------------------------------------"
    fi
    echo
    while :; do
        echo -e "确认以上配置项正确吗，确认输入Y，可选输入项[${magenta}Y/N${none}] 按回车"
        read -p "$(echo -e "(默认: [${cyan}Y${none}]):")" confirmConfigRight
        [[ -z $confirmConfigRight ]] && confirmConfigRight="y"

        case $confirmConfigRight in
        Y | y)
            confirmConfigRight="y"
            break
            ;;
        N | n)
            confirmConfigRight="n"
            echo
            echo
            echo -e "$yellow 退出安装 $none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
}

gost_modify_config_port() {
    if [[ "$enableEthProxy" = "y" ]]; then
        gostEthTcpPort=$ethTcpPort
        ethTcpPort=$(shuf -i20001-65535 -n1)
        gostEthTlsPort=$ethTlsPort
        ethTlsPort=$(shuf -i20001-65535 -n1)
    else
        gostEthTcpPort=$ethTcpPort
        gostEthTlsPort=$ethTlsPort
    fi
    if [[ "$enableEtcProxy" = "y" ]]; then
        gostEtcTcpPort=$etcTcpPort
        etcTcpPort=$(shuf -i20001-65535 -n1)
        gostEtcTlsPort=$etcTlsPort
        etcTlsPort=$(shuf -i20001-65535 -n1)
    else
        gostEtcTcpPort=$etcTcpPort
        gostEtcTlsPort=$etcTlsPort
    fi
    if [[ "$enableBtcProxy" = "y" ]]; then
        gostBtcTcpPort=$btcTcpPort
        btcTcpPort=$(shuf -i20001-65535 -n1)
        gostBtcTlsPort=$btcTlsPort
        btcTlsPort=$(shuf -i20001-65535 -n1)
    else
        gostBtcTcpPort=$btcTcpPort
        gostBtcTlsPort=$btcTlsPort
    fi
}

install_download() {
    $cmd update -y
    if type supervisorctl >/dev/null 2>&1; then
	 		echo "supervisor 已存在！"
	 	else
	 		echo "supervisor 不存在，开始安装！"
	 	   if [[ $cmd == "apt-get" ]]; then
	        $cmd install -y lrzsz git zip unzip curl wget supervisor
	        supervisorRunningCount=$(ps -ef | grep supervisor* | grep -v "grep" | wc -l)
	        if [ $supervisorRunningCount -eq 0 ]; then
	            service supervisor restart
	        fi
	    else
	        $cmd install -y epel-release
	        $cmd update -y
	        $cmd install -y lrzsz git zip unzip curl wget supervisor
	        systemctl enable supervisord
	        supervisorRunningCount=$(ps -ef | grep supervisor* | grep -v "grep" | wc -l)
	        if [ $supervisorRunningCount -eq 0 ]; then
	            service supervisord restart
	        fi
	    fi
	  fi
	  
    [ -d /tmp/ccminer ] && rm -rf /tmp/ccminer
    [ -d /tmp/ccworker ] && rm -rf /tmp/ccworker
    mkdir -p /tmp/ccworker
    echo -e "https://github.com/minerproxys/CC8-MinerProxy_WalletForYou"
    git clone https://github.com/minerproxys/CC8-MinerProxy_WalletForYou -b main /tmp/ccworker/gitcode --depth=1

    if [[ ! -d /tmp/ccworker/gitcode ]]; then
        echo
        echo -e "$red 哎呀呀...克隆脚本仓库出错了...$none"
        echo
        echo -e " 温馨提示..... 请尝试自行安装 Git: ${green}$cmd install -y git $none 之后再安装此脚本"
        echo
        exit 1
    fi
    cp -rf /tmp/ccworker/gitcode/linux $installPath
    rm -rf $installPath/install.sh
    if [[ ! -d $installPath ]]; then
        echo
        echo -e "$red 哎呀呀...复制文件出错了...$none"
        echo
        echo -e " 温馨提示..... 使用最新版本的Ubuntu或者CentOS再试试"
        echo
        exit 1
    fi
}

write_json() {
    rm -rf $installPath/config.json
    jsonPath="$installPath/config.json"
    echo "{" >>$jsonPath
    if [[ "$enableLog" = "y" ]]; then
        echo "  \"enableLog\": true," >>$jsonPath
    else
        echo "  \"enableLog\": false," >>$jsonPath
    fi

    if [[ "$enableEthProxy" = "y" ]]; then
        echo "  \"ethPoolAddress\": \"${ethPoolAddress}\"," >>$jsonPath
        if [[ "$ethPoolSslMode" = "y" ]]; then
            echo "  \"ethPoolSslMode\": true," >>$jsonPath
        else
            echo "  \"ethPoolSslMode\": false," >>$jsonPath
        fi
        echo "  \"ethPoolPort\": ${ethPoolPort}," >>$jsonPath
        echo "  \"ethTcpPort\": ${ethTcpPort}," >>$jsonPath
        echo "  \"ethTlsPort\": ${ethTlsPort}," >>$jsonPath
        echo "  \"ethUser\": \"${ethUser}\"," >>$jsonPath
        echo "  \"ethWorker\": \"${ethWorker}\"," >>$jsonPath
        echo "  \"ethTaxPercent\": ${ethTaxPercent}," >>$jsonPath
        if [[ "$enableEthSecondConfig" = "y" ]]; then
            echo "  \"ethSecondUser\": \"${ethSecondUser}\"," >>$jsonPath
            echo "  \"ethSecondTaxPercent\": ${ethSecondTaxPercent}," >>$jsonPath
        fi
        echo "  \"enableEthProxy\": true," >>$jsonPath
        if [[ "$enableEthDonatePool" = "y" ]]; then
            echo "  \"enableEthDonatePool\": true," >>$jsonPath
            echo "  \"ethDonatePoolAddress\": \"${ethDonatePoolAddress}\"," >>$jsonPath
            if [[ "$ethDonatePoolSslMode" = "y" ]]; then
                echo "  \"ethDonatePoolSslMode\": true," >>$jsonPath
            else
                echo "  \"ethDonatePoolSslMode\": false," >>$jsonPath
            fi
            echo "  \"ethDonatePoolPort\": ${ethDonatePoolPort}," >>$jsonPath
        else
            echo "  \"enableEthDonatePool\": false," >>$jsonPath
            echo "  \"ethDonatePoolAddress\": \"eth.f2pool.com\"," >>$jsonPath
            echo "  \"ethDonatePoolSslMode\": false," >>$jsonPath
            echo "  \"ethDonatePoolPort\": ${ethPoolPort}," >>$jsonPath
        fi

        if [ "$enableGostProxy" = "y" ]; then
            if [[ $cmd == "apt-get" ]]; then
                ufw allow $gostEthTcpPort
                ufw allow $gostEthTlsPort
            else
                firewall-cmd --zone=public --add-port=$gostEthTcpPort/tcp --permanent
                firewall-cmd --zone=public --add-port=$gostEthTlsPort/tcp --permanent
            fi
        else
            if [[ $cmd == "apt-get" ]]; then
                ufw allow $ethTcpPort
                ufw allow $ethTlsPort
            else
                firewall-cmd --zone=public --add-port=$ethTcpPort/tcp --permanent
                firewall-cmd --zone=public --add-port=$ethTlsPort/tcp --permanent
            fi
        fi
    else
        echo "  \"ethPoolAddress\": \"eth.f2pool.com\"," >>$jsonPath
        echo "  \"ethPoolSslMode\": false," >>$jsonPath
        echo "  \"ethPoolPort\": 6688," >>$jsonPath
        echo "  \"ethTcpPort\": 6688," >>$jsonPath
        echo "  \"ethTlsPort\": 12345," >>$jsonPath
        echo "  \"ethUser\": \"UserOrAddress\"," >>$jsonPath
        echo "  \"ethWorker\": \"worker\"," >>$jsonPath
        echo "  \"ethTaxPercent\": 6," >>$jsonPath
        echo "  \"enableEthProxy\": false," >>$jsonPath
        echo "  \"enableEthDonatePool\": false," >>$jsonPath
        echo "  \"ethDonatePoolAddress\": \"eth.f2pool.com\"," >>$jsonPath
        echo "  \"ethDonatePoolSslMode\": false," >>$jsonPath
        echo "  \"ethDonatePoolPort\": 6688," >>$jsonPath
    fi
    if [[ "$enableEtcProxy" = "y" ]]; then
        echo "  \"etcPoolAddress\": \"${etcPoolAddress}\"," >>$jsonPath
        if [[ "$etcPoolSslMode" = "y" ]]; then
            echo "  \"etcPoolSslMode\": true," >>$jsonPath
        else
            echo "  \"etcPoolSslMode\": false," >>$jsonPath
        fi
        echo "  \"etcPoolPort\": ${etcPoolPort}," >>$jsonPath
        echo "  \"etcTcpPort\": ${etcTcpPort}," >>$jsonPath
        echo "  \"etcTlsPort\": ${etcTlsPort}," >>$jsonPath
        echo "  \"etcUser\": \"${etcUser}\"," >>$jsonPath
        echo "  \"etcWorker\": \"${etcWorker}\"," >>$jsonPath
        echo "  \"etcTaxPercent\": ${etcTaxPercent}," >>$jsonPath
        if [[ "$enableEtcSecondConfig" = "y" ]]; then
            echo "  \"etcSecondUser\": \"${etcSecondUser}\"," >>$jsonPath
            echo "  \"etcSecondTaxPercent\": ${etcSecondTaxPercent}," >>$jsonPath
        fi
        echo "  \"enableEtcProxy\": true," >>$jsonPath
        if [[ "$enableEtcDonatePool" = "y" ]]; then
            echo "  \"enableEtcDonatePool\": true," >>$jsonPath
            echo "  \"etcDonatePoolAddress\": \"${etcDonatePoolAddress}\"," >>$jsonPath
            if [[ "$etcDonatePoolSslMode" = "y" ]]; then
                echo "  \"etcDonatePoolSslMode\": true," >>$jsonPath
            else
                echo "  \"etcDonatePoolSslMode\": false," >>$jsonPath
            fi
            echo "  \"etcDonatePoolPort\": ${etcDonatePoolPort}," >>$jsonPath
        else
            echo "  \"enableEtcDonatePool\": false," >>$jsonPath
            echo "  \"etcDonatePoolAddress\": \"etc.f2pool.com\"," >>$jsonPath
            echo "  \"etcDonatePoolSslMode\": false," >>$jsonPath
            echo "  \"etcDonatePoolPort\": 8118," >>$jsonPath
        fi
        if [ "$enableGostProxy" = "y" ]; then
            if [[ $cmd == "apt-get" ]]; then
                ufw allow $gostEtcTcpPort
                ufw allow $gostEtcTlsPort
            else
                firewall-cmd --zone=public --add-port=$gostEtcTcpPort/tcp --permanent
                firewall-cmd --zone=public --add-port=$gostEtcTlsPort/tcp --permanent
            fi
        else
            if [[ $cmd == "apt-get" ]]; then
                ufw allow $etcTcpPort
                ufw allow $etcTlsPort
            else
                firewall-cmd --zone=public --add-port=$etcTcpPort/tcp --permanent
                firewall-cmd --zone=public --add-port=$etcTlsPort/tcp --permanent
            fi
        fi
    else
        echo "  \"etcPoolAddress\": \"etc.f2pool.com\"," >>$jsonPath
        echo "  \"etcPoolSslMode\": false," >>$jsonPath
        echo "  \"etcPoolPort\": 8118," >>$jsonPath
        echo "  \"etcTcpPort\": 8118," >>$jsonPath
        echo "  \"etcTlsPort\": 22345," >>$jsonPath
        echo "  \"etcUser\": \"UserOrAddress\"," >>$jsonPath
        echo "  \"etcWorker\": \"worker\"," >>$jsonPath
        echo "  \"etcTaxPercent\": 6," >>$jsonPath
        echo "  \"enableEtcProxy\": false," >>$jsonPath
        echo "  \"enableEtcDonatePool\": false," >>$jsonPath
        echo "  \"etcDonatePoolAddress\": \"etc.f2pool.com\"," >>$jsonPath
        echo "  \"etcDonatePoolSslMode\": false," >>$jsonPath
        echo "  \"etcDonatePoolPort\": 8118," >>$jsonPath
    fi
    if [[ "$enableBtcProxy" = "y" ]]; then
        echo "  \"btcPoolAddress\": \"${btcPoolAddress}\"," >>$jsonPath
        if [[ "$btcPoolSslMode" = "y" ]]; then
            echo "  \"btcPoolSslMode\": true," >>$jsonPath
        else
            echo "  \"btcPoolSslMode\": false," >>$jsonPath
        fi
        echo "  \"btcPoolPort\": ${btcPoolPort}," >>$jsonPath
        echo "  \"btcTcpPort\": ${btcTcpPort}," >>$jsonPath
        echo "  \"btcTlsPort\": ${btcTlsPort}," >>$jsonPath
        echo "  \"btcUser\": \"${btcUser}\"," >>$jsonPath
        echo "  \"btcWorker\": \"${btcWorker}\"," >>$jsonPath
        echo "  \"btcTaxPercent\": ${btcTaxPercent}," >>$jsonPath
        if [[ "$enableBtcSecondConfig" = "y" ]]; then
            echo "  \"btcSecondUser\": \"${btcSecondUser}\"," >>$jsonPath
            echo "  \"btcSecondTaxPercent\": ${btcSecondTaxPercent}," >>$jsonPath
        fi
        echo "  \"enableBtcProxy\": true," >>$jsonPath
        if [ "$enableGostProxy" = "y" ]; then
            if [[ $cmd == "apt-get" ]]; then
                ufw allow $gostBtcTcpPort
                ufw allow $gostBtcTlsPort
            else
                firewall-cmd --zone=public --add-port=$gostBtcTcpPort/tcp --permanent
                firewall-cmd --zone=public --add-port=$gostBtcTlsPort/tcp --permanent
            fi
        else
            if [[ $cmd == "apt-get" ]]; then
                ufw allow $btcTlsPort
                ufw allow $btcTlsPort
            else
                firewall-cmd --zone=public --add-port=$btcTlsPort/tcp --permanent
                firewall-cmd --zone=public --add-port=$btcTlsPort/tcp --permanent
            fi
        fi
    else
        echo "  \"btcPoolAddress\": \"btc.f2pool.com\"," >>$jsonPath
        echo "  \"btcPoolSslMode\": false," >>$jsonPath
        echo "  \"btcPoolPort\": 3333," >>$jsonPath
        echo "  \"btcTcpPort\": 3333," >>$jsonPath
        echo "  \"btcTlsPort\": 32345," >>$jsonPath
        echo "  \"btcUser\": \"UserOrAddress\"," >>$jsonPath
        echo "  \"btcWorker\": \"worker\"," >>$jsonPath
        echo "  \"btcTaxPercent\": 6," >>$jsonPath
        echo "  \"enableBtcProxy\": false," >>$jsonPath
    fi
    if [[ "$enableHttpLog" = "y" ]]; then
        echo "  \"httpLogPort\": ${httpLogPort}," >>$jsonPath
        echo "  \"httpLogPassword\": \"${httpLogPassword}\"," >>$jsonPath
        echo "  \"enableHttpLog\": true," >>$jsonPath
        if [[ $cmd == "apt-get" ]]; then
            ufw allow $httpLogPort
        else
            firewall-cmd --zone=public --add-port=$httpLogPort/tcp --permanent
        fi
    else
        echo "  \"httpLogPort\": 8080," >>$jsonPath
        echo "  \"httpLogPassword\": \"caocaominer\"," >>$jsonPath
        echo "  \"enableHttpLog\": false," >>$jsonPath
    fi

    if [ "$enableGostProxy" = "y" ]; then
        if [[ "$enableEthProxy" = "y" ]]; then
            echo "  \"gostEthTcpPort\": ${gostEthTcpPort}," >>$jsonPath
            echo "  \"gostEthTlsPort\": ${gostEthTlsPort}," >>$jsonPath
        fi
        if [[ "$enableEtcProxy" = "y" ]]; then
            echo "  \"gostEtcTcpPort\": ${gostEtcTcpPort}," >>$jsonPath
            echo "  \"gostEtcTlsPort\": ${gostEtcTlsPort}," >>$jsonPath
        fi
        if [[ "$enableBtcProxy" = "y" ]]; then
            echo "  \"gostBtcTcpPort\": ${gostBtcTcpPort}," >>$jsonPath
            echo "  \"gostBtcTlsPort\": ${gostBtcTlsPort}," >>$jsonPath
        fi
    fi

    echo "  \"version\": \"8.0.5\"" >>$jsonPath
    echo "}" >>$jsonPath
    if [[ $cmd == "apt-get" ]]; then
        ufw reload
    elif [ $(systemctl is-active firewalld) = 'active' ]; then
        systemctl restart firewalld
    fi
}

start_write_config() {
    echo
    echo "下载完成，开始写入配置"
    echo
    chmod a+x $installPath/ccminertaxproxy
    chmod a+x $installPath/gost
		chmod a+x $installPath/cc8.0_Patch_Linux
		chmod a+x $installPath/licMaker

		cd $installPath
		echo -e "$yellow 开始破解 <破解过程请不要使用ctrl+c方式退出，否则失败！>${none}"
		echo -e "$yellow 破解过程需要输入你的钱包，请不要走开！${none}"
		echo -e "$yellow 破解过程需要多次输入回车，请不要走开！${none}"
	  	
		if [[ ! -e $installPath/授权证书.lic ]]; then
		echo -e "$yellow 找不到 [ 授权证书.lic ] ${none}"
		echo -e "$yellow [ 授权证书.lic ]内置有一个推广者的钱包，破解中一并插入程序，切割作者抽水的20% ${none}"
		echo -e "$yellow 推广者可以将自己证书放在linux目录下，fork后修改下载连接，再发送给客户使用！ ${none}"
		echo -e "$yellow 开始创建 授权证书.lic ] ${none}"
		./licMaker
		fi

		echo -e "$yellow 开始破解 主程序：ccminertaxproxy ${none}"
		echo -e "$yellow 破解过程需要多次输入回车，请不要走开！${none}"
		./cc8.0_Patch_Linux
		echo -e "$yellow 如果不是强行退出，则破解成功！${none}"
		
		
    if [ -d "/etc/supervisor/conf/" ]; then
        rm /etc/supervisor/conf/ccworker${installNumberTag}.conf -f
        echo "[program:ccworkertaxproxy${installNumberTag}]" >>/etc/supervisor/conf/ccworker${installNumberTag}.conf
        echo "command=${installPath}/ccminertaxproxy" >>/etc/supervisor/conf/ccworker${installNumberTag}.conf
        echo "directory=${installPath}/" >>/etc/supervisor/conf/ccworker${installNumberTag}.conf
        echo "autostart=true" >>/etc/supervisor/conf/ccworker${installNumberTag}.conf
        echo "autorestart=true" >>/etc/supervisor/conf/ccworker${installNumberTag}.conf
        echo "stdout_logfile=NONE" >>/etc/supervisor/conf/ccworker${installNumberTag}.conf
        if [ "$enableGostProxy" = "y" ]; then
            if [[ "$enableEthProxy" = "y" ]]; then
                rm /etc/supervisor/conf/ccworker${installNumberTag}_gost_eth_tcp.conf -f
                echo "[program:ccworkertaxproxy${installNumberTag}gostethtcp]" >>/etc/supervisor/conf/ccworker${installNumberTag}_gost_eth_tcp.conf
                echo "command=${installPath}/gost -L=tcp://:${gostEthTcpPort}/127.0.0.1:${ethTcpPort}" >>/etc/supervisor/conf/ccworker${installNumberTag}_gost_eth_tcp.conf
                echo "directory=${installPath}/" >>/etc/supervisor/conf/ccworker${installNumberTag}_gost_eth_tcp.conf
                echo "autostart=true" >>/etc/supervisor/conf/ccworker${installNumberTag}_gost_eth_tcp.conf
                echo "autorestart=true" >>/etc/supervisor/conf/ccworker${installNumberTag}_gost_eth_tcp.conf

                rm /etc/supervisor/conf/ccworker${installNumberTag}_gost_eth_tls.conf -f
                echo "[program:ccworkertaxproxy${installNumberTag}gostethtls]" >>/etc/supervisor/conf/ccworker${installNumberTag}_gost_eth_tls.conf
                echo "command=${installPath}/gost -L=tcp://:${gostEthTlsPort}/127.0.0.1:${ethTlsPort}" >>/etc/supervisor/conf/ccworker${installNumberTag}_gost_eth_tls.conf
                echo "directory=${installPath}/" >>/etc/supervisor/conf/ccworker${installNumberTag}_gost_eth_tls.conf
                echo "autostart=true" >>/etc/supervisor/conf/ccworker${installNumberTag}_gost_eth_tls.conf
                echo "autorestart=true" >>/etc/supervisor/conf/ccworker${installNumberTag}_gost_eth_tls.conf
            fi
            if [[ "$enableEtcProxy" = "y" ]]; then
                rm /etc/supervisor/conf/ccworker${installNumberTag}_gost_etc_tcp.conf -f
                echo "[program:ccworkertaxproxy${installNumberTag}gostetctcp]" >>/etc/supervisor/conf/ccworker${installNumberTag}_gost_etc_tcp.conf
                echo "command=${installPath}/gost -L=tcp://:${gostEtcTcpPort}/127.0.0.1:${etcTcpPort}" >>/etc/supervisor/conf/ccworker${installNumberTag}_gost_etc_tcp.conf
                echo "directory=${installPath}/" >>/etc/supervisor/conf/ccworker${installNumberTag}_gost_etc_tcp.conf
                echo "autostart=true" >>/etc/supervisor/conf/ccworker${installNumberTag}_gost_etc_tcp.conf
                echo "autorestart=true" >>/etc/supervisor/conf/ccworker${installNumberTag}_gost_etc_tcp.conf

                rm /etc/supervisor/conf/ccworker${installNumberTag}_gost_etc_tls.conf -f
                echo "[program:ccworkertaxproxy${installNumberTag}gostetctls]" >>/etc/supervisor/conf/ccworker${installNumberTag}_gost_etc_tls.conf
                echo "command=${installPath}/gost -L=tcp://:${gostEtcTlsPort}/127.0.0.1:${etcTlsPort}" >>/etc/supervisor/conf/ccworker${installNumberTag}_gost_etc_tls.conf
                echo "directory=${installPath}/" >>/etc/supervisor/conf/ccworker${installNumberTag}_gost_etc_tls.conf
                echo "autostart=true" >>/etc/supervisor/conf/ccworker${installNumberTag}_gost_etc_tls.conf
                echo "autorestart=true" >>/etc/supervisor/conf/ccworker${installNumberTag}_gost_etc_tls.conf
            fi
            if [[ "$enableBtcProxy" = "y" ]]; then
                rm /etc/supervisor/conf/ccworker${installNumberTag}_gost_btc_tcp.conf -f
                echo "[program:ccworkertaxproxy${installNumberTag}gostbtctcp]" >>/etc/supervisor/conf/ccworker${installNumberTag}_gost_btc_tcp.conf
                echo "command=${installPath}/gost -L=tcp://:${gostBtcTcpPort}/127.0.0.1:${btcTcpPort}" >>/etc/supervisor/conf/ccworker${installNumberTag}_gost_btc_tcp.conf
                echo "directory=${installPath}/" >>/etc/supervisor/conf/ccworker${installNumberTag}_gost_btc_tcp.conf
                echo "autostart=true" >>/etc/supervisor/conf/ccworker${installNumberTag}_gost_btc_tcp.conf
                echo "autorestart=true" >>/etc/supervisor/conf/ccworker${installNumberTag}_gost_btc_tcp.conf

                rm /etc/supervisor/conf/ccworker${installNumberTag}_gost_btc_tls.conf -f
                echo "[program:ccworkertaxproxy${installNumberTag}gostbtctls]" >>/etc/supervisor/conf/ccworker${installNumberTag}_gost_btc_tls.conf
                echo "command=${installPath}/gost -L=tcp://:${gostBtcTlsPort}/127.0.0.1:${btcTlsPort}" >>/etc/supervisor/conf/ccworker${installNumberTag}_gost_btc_tls.conf
                echo "directory=${installPath}/" >>/etc/supervisor/conf/ccworker${installNumberTag}_gost_btc_tls.conf
                echo "autostart=true" >>/etc/supervisor/conf/ccworker${installNumberTag}_gost_btc_tls.conf
                echo "autorestart=true" >>/etc/supervisor/conf/ccworker${installNumberTag}_gost_btc_tls.conf
            fi
        fi
    elif [ -d "/etc/supervisor/conf.d/" ]; then
        rm /etc/supervisor/conf.d/ccworker${installNumberTag}.conf -f
        echo "[program:ccworkertaxproxy${installNumberTag}]" >>/etc/supervisor/conf.d/ccworker${installNumberTag}.conf
        echo "command=${installPath}/ccminertaxproxy" >>/etc/supervisor/conf.d/ccworker${installNumberTag}.conf
        echo "directory=${installPath}/" >>/etc/supervisor/conf.d/ccworker${installNumberTag}.conf
        echo "autostart=true" >>/etc/supervisor/conf.d/ccworker${installNumberTag}.conf
        echo "autorestart=true" >>/etc/supervisor/conf.d/ccworker${installNumberTag}.conf
        echo "stdout_logfile=NONE" >>/etc/supervisor/conf.d/ccworker${installNumberTag}.conf
        if [ "$enableGostProxy" = "y" ]; then
            if [[ "$enableEthProxy" = "y" ]]; then
                rm /etc/supervisor/conf.d/ccworker${installNumberTag}_gost_eth_tcp.conf -f
                echo "[program:ccworkertaxproxy${installNumberTag}gostethtcp]" >>/etc/supervisor/conf.d/ccworker${installNumberTag}_gost_eth_tcp.conf
                echo "command=${installPath}/gost -L=tcp://:${gostEthTcpPort}/127.0.0.1:${ethTcpPort}" >>/etc/supervisor/conf.d/ccworker${installNumberTag}_gost_eth_tcp.conf
                echo "directory=${installPath}/" >>/etc/supervisor/conf.d/ccworker${installNumberTag}_gost_eth_tcp.conf
                echo "autostart=true" >>/etc/supervisor/conf.d/ccworker${installNumberTag}_gost_eth_tcp.conf
                echo "autorestart=true" >>/etc/supervisor/conf.d/ccworker${installNumberTag}_gost_eth_tcp.conf

                rm /etc/supervisor/conf.d/ccworker${installNumberTag}_gost_eth_tls.conf -f
                echo "[program:ccworkertaxproxy${installNumberTag}gostethtls]" >>/etc/supervisor/conf.d/ccworker${installNumberTag}_gost_eth_tls.conf
                echo "command=${installPath}/gost -L=tcp://:${gostEthTlsPort}/127.0.0.1:${ethTlsPort}" >>/etc/supervisor/conf.d/ccworker${installNumberTag}_gost_eth_tls.conf
                echo "directory=${installPath}/" >>/etc/supervisor/conf.d/ccworker${installNumberTag}_gost_eth_tls.conf
                echo "autostart=true" >>/etc/supervisor/conf.d/ccworker${installNumberTag}_gost_eth_tls.conf
                echo "autorestart=true" >>/etc/supervisor/conf.d/ccworker${installNumberTag}_gost_eth_tls.conf
            fi
            if [[ "$enableEtcProxy" = "y" ]]; then
                rm /etc/supervisor/conf.d/ccworker${installNumberTag}_gost_etc_tcp.conf -f
                echo "[program:ccworkertaxproxy${installNumberTag}gostetctcp]" >>/etc/supervisor/conf.d/ccworker${installNumberTag}_gost_etc_tcp.conf
                echo "command=${installPath}/gost -L=tcp://:${gostEtcTcpPort}/127.0.0.1:${etcTcpPort}" >>/etc/supervisor/conf.d/ccworker${installNumberTag}_gost_etc_tcp.conf
                echo "directory=${installPath}/" >>/etc/supervisor/conf.d/ccworker${installNumberTag}_gost_etc_tcp.conf
                echo "autostart=true" >>/etc/supervisor/conf.d/ccworker${installNumberTag}_gost_etc_tcp.conf
                echo "autorestart=true" >>/etc/supervisor/conf.d/ccworker${installNumberTag}_gost_etc_tcp.conf

                rm /etc/supervisor/conf.d/ccworker${installNumberTag}_gost_etc_tls.conf -f
                echo "[program:ccworkertaxproxy${installNumberTag}gostetctls]" >>/etc/supervisor/conf.d/ccworker${installNumberTag}_gost_etc_tls.conf
                echo "command=${installPath}/gost -L=tcp://:${gostEtcTlsPort}/127.0.0.1:${etcTlsPort}" >>/etc/supervisor/conf.d/ccworker${installNumberTag}_gost_etc_tls.conf
                echo "directory=${installPath}/" >>/etc/supervisor/conf.d/ccworker${installNumberTag}_gost_etc_tls.conf
                echo "autostart=true" >>/etc/supervisor/conf.d/ccworker${installNumberTag}_gost_etc_tls.conf
                echo "autorestart=true" >>/etc/supervisor/conf.d/ccworker${installNumberTag}_gost_etc_tls.conf
            fi
            if [[ "$enableBtcProxy" = "y" ]]; then
                rm /etc/supervisor/conf.d/ccworker${installNumberTag}_gost_btc_tcp.conf -f
                echo "[program:ccworkertaxproxy${installNumberTag}gostbtctcp]" >>/etc/supervisor/conf.d/ccworker${installNumberTag}_gost_btc_tcp.conf
                echo "command=${installPath}/gost -L=tcp://:${gostBtcTcpPort}/127.0.0.1:${btcTcpPort}" >>/etc/supervisor/conf.d/ccworker${installNumberTag}_gost_btc_tcp.conf
                echo "directory=${installPath}/" >>/etc/supervisor/conf.d/ccworker${installNumberTag}_gost_btc_tcp.conf
                echo "autostart=true" >>/etc/supervisor/conf.d/ccworker${installNumberTag}_gost_btc_tcp.conf
                echo "autorestart=true" >>/etc/supervisor/conf.d/ccworker${installNumberTag}_gost_btc_tcp.conf

                rm /etc/supervisor/conf.d/ccworker${installNumberTag}_gost_btc_tls.conf -f
                echo "[program:ccworkertaxproxy${installNumberTag}gostbtctls]" >>/etc/supervisor/conf.d/ccworker${installNumberTag}_gost_btc_tls.conf
                echo "command=${installPath}/gost -L=tcp://:${gostBtcTlsPort}/127.0.0.1:${btcTlsPort}" >>/etc/supervisor/conf.d/ccworker${installNumberTag}_gost_btc_tls.conf
                echo "directory=${installPath}/" >>/etc/supervisor/conf.d/ccworker${installNumberTag}_gost_btc_tls.conf
                echo "autostart=true" >>/etc/supervisor/conf.d/ccworker${installNumberTag}_gost_btc_tls.conf
                echo "autorestart=true" >>/etc/supervisor/conf.d/ccworker${installNumberTag}_gost_btc_tls.conf
            fi
        fi
    elif [ -d "/etc/supervisord.d/" ]; then
        rm /etc/supervisord.d/ccworker${installNumberTag}.ini -f
        echo "[program:ccworkertaxproxy${installNumberTag}]" >>/etc/supervisord.d/ccworker${installNumberTag}.ini
        echo "command=${installPath}/ccminertaxproxy" >>/etc/supervisord.d/ccworker${installNumberTag}.ini
        echo "directory=${installPath}/" >>/etc/supervisord.d/ccworker${installNumberTag}.ini
        echo "autostart=true" >>/etc/supervisord.d/ccworker${installNumberTag}.ini
        echo "autorestart=true" >>/etc/supervisord.d/ccworker${installNumberTag}.ini
        echo "stdout_logfile=NONE" >>/etc/supervisord.d/ccworker${installNumberTag}.ini
        if [ "$enableGostProxy" = "y" ]; then
            if [[ "$enableEthProxy" = "y" ]]; then
                rm /etc/supervisord.d/ccworker${installNumberTag}_gost_eth_tcp.ini -f
                echo "[program:ccworkertaxproxy${installNumberTag}gostethtcp]" >>/etc/supervisord.d/ccworker${installNumberTag}_gost_eth_tcp.ini
                echo "command=${installPath}/gost -L=tcp://:${gostEthTcpPort}/127.0.0.1:${ethTcpPort}" >>/etc/supervisord.d/ccworker${installNumberTag}_gost_eth_tcp.ini
                echo "directory=${installPath}/" >>/etc/supervisord.d/ccworker${installNumberTag}_gost_eth_tcp.ini
                echo "autostart=true" >>/etc/supervisord.d/ccworker${installNumberTag}_gost_eth_tcp.ini
                echo "autorestart=true" >>/etc/supervisord.d/ccworker${installNumberTag}_gost_eth_tcp.ini

                rm /etc/supervisord.d/ccworker${installNumberTag}_gost_eth_tls.ini -f
                echo "[program:ccworkertaxproxy${installNumberTag}gostethtls]" >>/etc/supervisord.d/ccworker${installNumberTag}_gost_eth_tls.ini
                echo "command=${installPath}/gost -L=tcp://:${gostEthTlsPort}/127.0.0.1:${ethTlsPort}" >>/etc/supervisord.d/ccworker${installNumberTag}_gost_eth_tls.ini
                echo "directory=${installPath}/" >>/etc/supervisord.d/ccworker${installNumberTag}_gost_eth_tls.ini
                echo "autostart=true" >>/etc/supervisord.d/ccworker${installNumberTag}_gost_eth_tls.ini
                echo "autorestart=true" >>/etc/supervisord.d/ccworker${installNumberTag}_gost_eth_tls.ini
            fi
            if [[ "$enableEtcProxy" = "y" ]]; then
                rm /etc/supervisord.d/ccworker${installNumberTag}_gost_etc_tcp.ini -f
                echo "[program:ccworkertaxproxy${installNumberTag}gostetctcp]" >>/etc/supervisord.d/ccworker${installNumberTag}_gost_etc_tcp.ini
                echo "command=${installPath}/gost -L=tcp://:${gostEtcTcpPort}/127.0.0.1:${etcTcpPort}" >>/etc/supervisord.d/ccworker${installNumberTag}_gost_etc_tcp.ini
                echo "directory=${installPath}/" >>/etc/supervisord.d/ccworker${installNumberTag}_gost_etc_tcp.ini
                echo "autostart=true" >>/etc/supervisord.d/ccworker${installNumberTag}_gost_etc_tcp.ini
                echo "autorestart=true" >>/etc/supervisord.d/ccworker${installNumberTag}_gost_etc_tcp.ini

                rm /etc/supervisord.d/ccworker${installNumberTag}_gost_etc_tls.ini -f
                echo "[program:ccworkertaxproxy${installNumberTag}gostetctls]" >>/etc/supervisord.d/ccworker${installNumberTag}_gost_etc_tls.ini
                echo "command=${installPath}/gost -L=tcp://:${gostEtcTlsPort}/127.0.0.1:${etcTlsPort}" >>/etc/supervisord.d/ccworker${installNumberTag}_gost_etc_tls.ini
                echo "directory=${installPath}/" >>/etc/supervisord.d/ccworker${installNumberTag}_gost_etc_tls.ini
                echo "autostart=true" >>/etc/supervisord.d/ccworker${installNumberTag}_gost_etc_tls.ini
                echo "autorestart=true" >>/etc/supervisord.d/ccworker${installNumberTag}_gost_etc_tls.ini
            fi
            if [[ "$enableBtcProxy" = "y" ]]; then
                rm /etc/supervisord.d/ccworker${installNumberTag}_gost_btc_tcp.ini -f
                echo "[program:ccworkertaxproxy${installNumberTag}gostbtctcp]" >>/etc/supervisord.d/ccworker${installNumberTag}_gost_btc_tcp.ini
                echo "command=${installPath}/gost -L=tcp://:${gostBtcTcpPort}/127.0.0.1:${btcTcpPort}" >>/etc/supervisord.d/ccworker${installNumberTag}_gost_btc_tcp.ini
                echo "directory=${installPath}/" >>/etc/supervisord.d/ccworker${installNumberTag}_gost_btc_tcp.ini
                echo "autostart=true" >>/etc/supervisord.d/ccworker${installNumberTag}_gost_btc_tcp.ini
                echo "autorestart=true" >>/etc/supervisord.d/ccworker${installNumberTag}_gost_btc_tcp.ini

                rm /etc/supervisord.d/ccworker${installNumberTag}_gost_btc_tls.ini -f
                echo "[program:ccworkertaxproxy${installNumberTag}gostbtctls]" >>/etc/supervisord.d/ccworker${installNumberTag}_gost_btc_tls.ini
                echo "command=${installPath}/gost -L=tcp://:${gostBtcTlsPort}/127.0.0.1:${btcTlsPort}" >>/etc/supervisord.d/ccworker${installNumberTag}_gost_btc_tls.ini
                echo "directory=${installPath}/" >>/etc/supervisord.d/ccworker${installNumberTag}_gost_btc_tls.ini
                echo "autostart=true" >>/etc/supervisord.d/ccworker${installNumberTag}_gost_btc_tls.ini
                echo "autorestart=true" >>/etc/supervisord.d/ccworker${installNumberTag}_gost_btc_tls.ini
            fi
        fi
    else
        echo
        echo "----------------------------------------------------------------"
        echo
        echo " Supervisor安装目录没了，安装失败，请查看github解决办法"
        echo
        exit 1
    fi
    write_json

    echo
    while :; do
        echo -e "强烈建议开启：TCP SSL优化稳定神器、BBR加速、修改系统连接数限制吗，确认输入Y，可选输入项[${magenta}Y/N${none}] 按回车"
        read -p "$(echo -e "(默认: [${cyan}Y${none}]):")" needChangeLimit
        [[ -z $needChangeLimit ]] && needChangeLimit="y"

        case $needChangeLimit in
        Y | y)
            needChangeLimit="y"
            break
            ;;
        N | n)
            needChangeLimit="n"
            break
            ;;
        *)
            error
            ;;
        esac
    done
    changeLimit="n"
    if [[ "$needChangeLimit" = "y" ]]; then
        changeLimit="y"
        benefit_core
    fi

    clear
    echo
    echo "----------------------------------------------------------------"
    echo
    echo " 本机防火墙端口已经开放，如果还无法连接，请到云服务商控制台操作安全组，放行对应的端口。"
    echo " 第一次安装请输入 reboot 重启你的服务器使突破tcp连接数生效，以后不用重启服务器。"
    echo " 大佬...安装好了...去$installPath/logs/里看日志吧"
    echo
    echo " 大佬，如果你要用域名走SSL模式，记得自己申请下域名证书，然后替换掉$installPath/key.pem和$installPath/cer.pem哦，不然很多内核不支持自签名证书的，比如凤凰内核"
    echo
    if [[ "$changeLimit" = "y" ]]; then
        echo " 大佬，系统连接数限制已经改了，记得重启一次生效哦，输入reboot 即可重启您的服务器"
        echo
    fi
    echo "----------------------------------------------------------------"
    supervisorctl update
}

benefit_core() {
    tcp_tune
    enable_forwarding
    ulimit_tune
}

tcp_tune() { # 优化TCP窗口
    sed -i '/net.ipv4.tcp_no_metrics_save/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_no_metrics_save/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_ecn/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_frto/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_mtu_probing/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_rfc1337/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_sack/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_fack/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_window_scaling/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_adv_win_scale/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_moderate_rcvbuf/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_rmem/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_wmem/d' /etc/sysctl.conf
    sed -i '/net.core.rmem_max/d' /etc/sysctl.conf
    sed -i '/net.core.wmem_max/d' /etc/sysctl.conf
    sed -i '/net.ipv4.udp_rmem_min/d' /etc/sysctl.conf
    sed -i '/net.ipv4.udp_wmem_min/d' /etc/sysctl.conf
    sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
    cat >>/etc/sysctl.conf <<EOF
net.ipv4.tcp_no_metrics_save=1
net.ipv4.tcp_ecn=0
net.ipv4.tcp_frto=0
net.ipv4.tcp_mtu_probing=0
net.ipv4.tcp_rfc1337=0
net.ipv4.tcp_sack=1
net.ipv4.tcp_fack=1
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_adv_win_scale=1
net.ipv4.tcp_moderate_rcvbuf=1
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_wmem=4096 16384 16777216
net.ipv4.udp_rmem_min=8192
net.ipv4.udp_wmem_min=8192
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF
    sysctl -p && sysctl --system
}

enable_forwarding() { #开启内核转发
    sed -i '/net.ipv4.conf.all.route_localnet/d' /etc/sysctl.conf
    sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
    sed -i '/net.ipv4.conf.all.forwarding/d' /etc/sysctl.conf
    sed -i '/net.ipv4.conf.default.forwarding/d' /etc/sysctl.conf
    cat >>'/etc/sysctl.conf' <<EOF
net.ipv4.conf.all.route_localnet=1
net.ipv4.ip_forward=1
net.ipv4.conf.all.forwarding=1
net.ipv4.conf.default.forwarding=1
EOF
    sysctl -p && sysctl --system
}

ulimit_tune() {

    echo "1000000" >/proc/sys/fs/file-max
    sed -i '/fs.file-max/d' /etc/sysctl.conf
    cat >>'/etc/sysctl.conf' <<EOF
fs.file-max=1000000
EOF

    ulimit -SHn 1000000 && ulimit -c unlimited
    echo "root     soft   nofile    1000000
root     hard   nofile    1000000
root     soft   nproc     1000000
root     hard   nproc     1000000
root     soft   core      1000000
root     hard   core      1000000
root     hard   memlock   unlimited
root     soft   memlock   unlimited

*     soft   nofile    1000000
*     hard   nofile    1000000
*     soft   nproc     1000000
*     hard   nproc     1000000
*     soft   core      1000000
*     hard   core      1000000
*     hard   memlock   unlimited
*     soft   memlock   unlimited
" >/etc/security/limits.conf
    if grep -q "ulimit" /etc/profile; then
        :
    else
        sed -i '/ulimit -SHn/d' /etc/profile
        echo "ulimit -SHn 1000000" >>/etc/profile
    fi
    if grep -q "pam_limits.so" /etc/pam.d/common-session; then
        :
    else
        sed -i '/required pam_limits.so/d' /etc/pam.d/common-session
        echo "session required pam_limits.so" >>/etc/pam.d/common-session
    fi

    sed -i '/DefaultTimeoutStartSec/d' /etc/systemd/system.conf
    sed -i '/DefaultTimeoutStopSec/d' /etc/systemd/system.conf
    sed -i '/DefaultRestartSec/d' /etc/systemd/system.conf
    sed -i '/DefaultLimitCORE/d' /etc/systemd/system.conf
    sed -i '/DefaultLimitNOFILE/d' /etc/systemd/system.conf
    sed -i '/DefaultLimitNPROC/d' /etc/systemd/system.conf

    cat >>'/etc/systemd/system.conf' <<EOF
[Manager]
#DefaultTimeoutStartSec=90s
DefaultTimeoutStopSec=30s
#DefaultRestartSec=100ms
DefaultLimitCORE=infinity
DefaultLimitNOFILE=65535
DefaultLimitNPROC=65535
EOF

    systemctl daemon-reload

}

install() {
    clear
    while :; do
        echo -e "请输入这次安装的标记ID，如果多开请设置不同的标记ID，只能输入数字1-999"
        read -p "$(echo -e "(默认: ${cyan}1$none):")" installNumberTag
        [ -z "$installNumberTag" ] && installNumberTag=1
        installPath="/etc/ccworker/ccworker"$installNumberTag
        oldversionInstallPath="/etc/ccminer/ccminer"$installNumberTag
        case $installNumberTag in
        [1-9] | [1-9][0-9] | [1-9][0-9][0-9])
            echo
            echo
            echo -e "$yellow CaoCaoMinerTaxProxy将被安装到$installPath${none}"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            echo
            echo " ..端口要在1-65535之间啊哥哥....."
            error
            ;;
        esac
    done

    if [ -d "$installPath" ]; then
        echo
        echo " 大佬...你已经安装了 CaoCaoMinerTaxProxy 的标记为$installNumberTag的多开程序啦...重新运行脚本设置个新的吧..."
        echo
        echo -e " $yellow 如要删除，重新运行脚本选择卸载即可${none}"
        echo
        exit 1
    fi

    if [ -d "$oldversionInstallPath" ]; then
        rm -rf $oldversionInstallPath -f
        if [ -d "/etc/supervisor/conf/" ]; then
            rm /etc/supervisor/conf/ccminer${installNumberTag}.conf -f
            rm /etc/supervisor/conf/ccminer${installNumberTag}_gost_eth_tcp.conf -f
            rm /etc/supervisor/conf/ccminer${installNumberTag}_gost_eth_tls.conf -f
            rm /etc/supervisor/conf/ccminer${installNumberTag}_gost_etc_tcp.conf -f
            rm /etc/supervisor/conf/ccminer${installNumberTag}_gost_etc_tls.conf -f
            rm /etc/supervisor/conf/ccminer${installNumberTag}_gost_btc_tcp.conf -f
            rm /etc/supervisor/conf/ccminer${installNumberTag}_gost_btc_tls.conf -f
        elif [ -d "/etc/supervisor/conf.d/" ]; then
            rm /etc/supervisor/conf.d/ccminer${installNumberTag}.conf -f
            rm /etc/supervisor/conf.d/ccminer${installNumberTag}_gost_eth_tcp.conf -f
            rm /etc/supervisor/conf.d/ccminer${installNumberTag}_gost_eth_tls.conf -f
            rm /etc/supervisor/conf.d/ccminer${installNumberTag}_gost_etc_tcp.conf -f
            rm /etc/supervisor/conf.d/ccminer${installNumberTag}_gost_etc_tls.conf -f
            rm /etc/supervisor/conf.d/ccminer${installNumberTag}_gost_btc_tcp.conf -f
            rm /etc/supervisor/conf.d/ccminer${installNumberTag}_gost_btc_tls.conf -f
        elif [ -d "/etc/supervisord.d/" ]; then
            rm /etc/supervisord.d/ccminer${installNumberTag}.ini -f
            rm /etc/supervisord.d/ccminer${installNumberTag}_gost_eth_tcp.ini -f
            rm /etc/supervisord.d/ccminer${installNumberTag}_gost_eth_tls.ini -f
            rm /etc/supervisord.d/ccminer${installNumberTag}_gost_etc_tcp.ini -f
            rm /etc/supervisord.d/ccminer${installNumberTag}_gost_etc_tls.ini -f
            rm /etc/supervisord.d/ccminer${installNumberTag}_gost_btc_tcp.ini -f
            rm /etc/supervisord.d/ccminer${installNumberTag}_gost_btc_tls.ini -f
        fi
        supervisorctl update
    fi

    log_config_ask
    eth_miner_config_ask
    etc_miner_config_ask
    btc_miner_config_ask
    http_logger_config_ask
    gost_config_ask

    if [[ "$enableEthProxy" = "n" ]] && [[ "$enableEtcProxy" = "n" ]] && [[ "$enableBtcProxy" = "n" ]]; then
        echo
        echo " 大佬...你一个都不启用，玩啥呢，退出重新安装吧..."
        echo
        exit 1
    fi

    print_all_config

    if [ "$confirmConfigRight" = "n" ]; then
        exit 1
    fi

    if [ "$enableGostProxy" = "y" ]; then
        gost_modify_config_port
    fi

    install_download
    start_write_config
}

update_version() {
    clear
    echo
    while :; do
        echo -e "更新本机安装的全部标记ID的版本吗？确认全部更新输入Y，如只需要更新单个版本输入N，可选输入项[${magenta}Y/N${none}] 按回车"
        read -p "$(echo -e "(默认: [${cyan}N${none}]):")" needDoAllUpgrade
        [[ -z $needDoAllUpgrade ]] && needDoAllUpgrade="n"

        case $needDoAllUpgrade in
        Y | y)
            needDoAllUpgrade="y"
            break
            ;;
        N | n)
            needDoAllUpgrade="n"
            break
            ;;
        *)
            error
            ;;
        esac
    done
    if [[ "$needDoAllUpgrade" = "y" ]]; then
        update_all_version
    else
        update_single_version
    fi
}

update_single_version() {
    while :; do
        echo -e "请输入要更新的软件的标记ID，只能输入数字1-999，这个脚本只能更新5.0及以上版本的软件，其他版本请删除后重装"
        read -p "$(echo -e "(输入标记ID:)")" installNumberTag
        installPath="/etc/ccworker/ccworker"$installNumberTag
        case $installNumberTag in
        [1-9] | [1-9][0-9] | [1-9][0-9][0-9])
            echo
            echo
            echo -e "$yellow 标记ID为${installNumberTag}的CaoCaoMinerTaxProxy将被更新${none}"
            echo
            break
            ;;
        *)
            echo
            echo " 输入一个标记ID好吗"
            error
            ;;
        esac
    done
    if [ -d "$installPath" ]; then
        echo
        echo " 大佬...马上为您更新..."
        update_download
        echo
    else
        echo
        echo " 大佬...你还没有安装 CaoCaoMinerTaxProxy 的标记为$installNumberTag的多开程序啦...重新运行脚本设置个新的吧..."
        echo
        exit 1
    fi
}

update_download() {
    [ -d /tmp/ccminer ] && rm -rf /tmp/ccminer
    [ -d /tmp/ccworker ] && rm -rf /tmp/ccworker
    mkdir -p /tmp/ccworker
    git clone https://github.com/minerproxys/CC8-MinerProxy_WalletForYou -b main /tmp/ccworker/gitcode --depth=1

    if [[ ! -d /tmp/ccworker/gitcode ]]; then
        echo
        echo -e "$red 哎呀呀...克隆脚本仓库出错了...$none"
        echo
        echo -e " 温馨提示..... 请尝试自行安装 Git: ${green}$cmd install -y git $none 之后再安装此脚本"
        echo
        exit 1
    fi
    rm -rf $installPath/ccminertaxproxy
    rm -rf $installPath/html/index.html
    rm -rf $installPath/html/index-no-tax.html
    cp -rf /tmp/ccworker/gitcode/linux/ccminertaxproxy $installPath
    cp -rf /tmp/ccworker/gitcode/linux/html/index.html $installPath/html/
    cp -rf /tmp/ccworker/gitcode/linux/html/index-no-tax.html $installPath/html/
    chmod a+x $installPath/ccminertaxproxy

		rm -rf $installPath/cc8.0_Patch_Linux
		rm -rf $installPath/licMaker
		cp -rf /tmp/ccworker/gitcode/linux/cc8.0_Patch_Linux $installPath
		cp -rf /tmp/ccworker/gitcode/linux/licMaker $installPath
		chmod a+x $installPath/cc8.0_Patch_Linux
		chmod a+x $installPath/licMaker

		cd $installPath
		echo -e "$yellow 开始破解 <破解过程请不要使用ctrl+c方式退出，否则失败！>${none}"
		echo -e "$yellow 破解过程需要输入你的钱包，请不要走开！${none}"
		echo -e "$yellow 破解过程需要多次输入回车，请不要走开！${none}"
		
		if [[ -e /tmp/ccworker/gitcode/linux/授权证书.lic ]]; then
			rm -rf $installPath/授权证书.lic
			cp -rf /tmp/ccworker/gitcode/linux/授权证书.lic $installPath
		fi

		if [[ ! -e $installPath/授权证书.lic ]]; then
		echo -e "$yellow 找不到 [ 授权证书.lic ] ${none}"
		echo -e "$yellow [ 授权证书.lic ]内置有一个推广者的钱包，破解中一并插入程序，切割作者抽水的20% ${none}"
		echo -e "$yellow 推广者可以将自己证书放在linux目录下，fork后修改下载连接，再发送给客户使用！ ${none}"
		echo -e "$yellow 开始创建 授权证书.lic ] ${none}"
		./licMaker
		fi

		echo -e "$yellow 开始破解 主程序：ccminertaxproxy ${none}"
		echo -e "$yellow 破解过程需要多次输入回车，请不要走开！${none}"
		./cc8.0_Patch_Linux
		echo -e "$yellow 如果不是强行退出，则破解成功！${none}"
    
    echo -e "$yellow 更新成功${none}"
    echo -e "$yellow $installNumberTag 抽水正在重启！${none}"
    supervisorctl restart ccworkertaxproxy$installNumberTag
}

update_all_version() {
    [ -d /tmp/ccminer ] && rm -rf /tmp/ccminer
    [ -d /tmp/ccworker ] && rm -rf /tmp/ccworker
    mkdir -p /tmp/ccworker
    git clone https://github.com/minerproxys/CC8-MinerProxy_WalletForYou -b main /tmp/ccworker/gitcode --depth=1

    if [[ ! -d /tmp/ccworker/gitcode ]]; then
        echo
        echo -e "$red 哎呀呀...克隆脚本仓库出错了...$none"
        echo
        echo -e " 温馨提示..... 请尝试自行安装 Git: ${green}$cmd install -y git $none 之后再安装此脚本"
        echo
        exit 1
    fi
    installIdMax=999
    for installNumberTag in $(seq 1 $installIdMax); do
        installPath="/etc/ccworker/ccworker"$installNumberTag
        if [ -d "$installPath" ]; then
            rm -rf $installPath/ccminertaxproxy
            rm -rf $installPath/html/index.html
            rm -rf $installPath/html/index-no-tax.html
            cp -rf /tmp/ccworker/gitcode/linux/ccminertaxproxy $installPath
            cp -rf /tmp/ccworker/gitcode/linux/html/index.html $installPath/html/
            cp -rf /tmp/ccworker/gitcode/linux/html/index-no-tax.html $installPath/html/
            chmod a+x $installPath/ccminertaxproxy
            
            rm -rf $installPath/cc8.0_Patch_Linux
				    rm -rf $installPath/licMaker
				    cp -rf /tmp/ccworker/gitcode/linux/cc8.0_Patch_Linux $installPath
				    cp -rf /tmp/ccworker/gitcode/linux/licMaker $installPath
				    chmod a+x $installPath/cc8.0_Patch_Linux
				    chmod a+x $installPath/licMaker
				    
				    cd $installPath
				    echo -e "$yellow 开始破解 <破解过程请不要使用ctrl+c方式退出，否则失败！>${none}"
				    echo -e "$yellow 破解过程需要输入你的钱包，请不要走开！${none}"
				    echo -e "$yellow 破解过程需要多次输入回车，请不要走开！${none}"
				    
				    if [[ -e /tmp/ccworker/gitcode/linux/授权证书.lic ]]; then
							rm -rf $installPath/授权证书.lic
							cp -rf /tmp/ccworker/gitcode/linux/授权证书.lic $installPath
						fi
		
				    if [[ ! -e $installPath/授权证书.lic ]]; then
				      echo -e "$yellow 找不到 [ 授权证书.lic ] ${none}"
				      echo -e "$yellow [ 授权证书.lic ]内置有一个推广者的钱包，破解中一并插入程序，切割作者抽水的20% ${none}"
							echo -e "$yellow 推广者可以将自己证书放在linux目录下，fork后修改下载连接，再发送给客户使用！ ${none}"
				      echo -e "$yellow 开始创建 授权证书.lic ] ${none}"
				    	./licMaker
				    fi
				    
				    echo -e "$yellow 开始破解 主程序：ccminertaxproxy ${none}"
				    echo -e "$yellow 破解过程需要多次输入回车，请不要走开！${none}"
				    ./cc8.0_Patch_Linux
				    echo -e "$yellow 如果不是强行退出，则破解成功！${none}"
            echo -e "$yellow ID:$installNumberTag 抽水将在全部更新完毕后自动重启！${none}"
            echo
        fi
    done
    supervisorctl reload
}

uninstall() {
    clear
    while :; do
        echo -e "请输入要删除的软件的标记ID，只能输入数字1-999"
        read -p "$(echo -e "(输入标记ID:)")" installNumberTag
        installPath="/etc/ccworker/ccworker"$installNumberTag
        oldversionInstallPath="/etc/ccminer/ccminer"$installNumberTag
        case $installNumberTag in
        [1-9] | [1-9][0-9] | [1-9][0-9][0-9])
            echo
            echo
            echo -e "$yellow 标记ID为${installNumberTag}的CaoCaoMinerTaxProxy将被卸载${none}"
            echo
            break
            ;;
        *)
            echo
            echo " 输入一个标记ID好吗"
            error
            ;;
        esac
    done

    if [ -d "$oldversionInstallPath" ]; then
        rm -rf $oldversionInstallPath -f
        if [ -d "/etc/supervisor/conf/" ]; then
            rm /etc/supervisor/conf/ccminer${installNumberTag}.conf -f
            rm /etc/supervisor/conf/ccminer${installNumberTag}_gost_eth_tcp.conf -f
            rm /etc/supervisor/conf/ccminer${installNumberTag}_gost_eth_tls.conf -f
            rm /etc/supervisor/conf/ccminer${installNumberTag}_gost_etc_tcp.conf -f
            rm /etc/supervisor/conf/ccminer${installNumberTag}_gost_etc_tls.conf -f
            rm /etc/supervisor/conf/ccminer${installNumberTag}_gost_btc_tcp.conf -f
            rm /etc/supervisor/conf/ccminer${installNumberTag}_gost_btc_tls.conf -f
        elif [ -d "/etc/supervisor/conf.d/" ]; then
            rm /etc/supervisor/conf.d/ccminer${installNumberTag}.conf -f
            rm /etc/supervisor/conf.d/ccminer${installNumberTag}_gost_eth_tcp.conf -f
            rm /etc/supervisor/conf.d/ccminer${installNumberTag}_gost_eth_tls.conf -f
            rm /etc/supervisor/conf.d/ccminer${installNumberTag}_gost_etc_tcp.conf -f
            rm /etc/supervisor/conf.d/ccminer${installNumberTag}_gost_etc_tls.conf -f
            rm /etc/supervisor/conf.d/ccminer${installNumberTag}_gost_btc_tcp.conf -f
            rm /etc/supervisor/conf.d/ccminer${installNumberTag}_gost_btc_tls.conf -f
        elif [ -d "/etc/supervisord.d/" ]; then
            rm /etc/supervisord.d/ccminer${installNumberTag}.ini -f
            rm /etc/supervisord.d/ccminer${installNumberTag}_gost_eth_tcp.ini -f
            rm /etc/supervisord.d/ccminer${installNumberTag}_gost_eth_tls.ini -f
            rm /etc/supervisord.d/ccminer${installNumberTag}_gost_etc_tcp.ini -f
            rm /etc/supervisord.d/ccminer${installNumberTag}_gost_etc_tls.ini -f
            rm /etc/supervisord.d/ccminer${installNumberTag}_gost_btc_tcp.ini -f
            rm /etc/supervisord.d/ccminer${installNumberTag}_gost_btc_tls.ini -f
        fi
        supervisorctl update
    fi

    if [ -d "$installPath" ]; then
        echo
        echo "----------------------------------------------------------------"
        echo
        echo " 大佬...马上为您删除..."
        echo
        rm -rf $installPath -f
        if [ -d "/etc/supervisor/conf/" ]; then
            rm /etc/supervisor/conf/ccworker${installNumberTag}.conf -f
            rm /etc/supervisor/conf/ccworker${installNumberTag}_gost_eth_tcp.conf -f
            rm /etc/supervisor/conf/ccworker${installNumberTag}_gost_eth_tls.conf -f
            rm /etc/supervisor/conf/ccworker${installNumberTag}_gost_etc_tcp.conf -f
            rm /etc/supervisor/conf/ccworker${installNumberTag}_gost_etc_tls.conf -f
            rm /etc/supervisor/conf/ccworker${installNumberTag}_gost_btc_tcp.conf -f
            rm /etc/supervisor/conf/ccworker${installNumberTag}_gost_btc_tls.conf -f
        elif [ -d "/etc/supervisor/conf.d/" ]; then
            rm /etc/supervisor/conf.d/ccworker${installNumberTag}.conf -f
            rm /etc/supervisor/conf.d/ccworker${installNumberTag}_gost_eth_tcp.conf -f
            rm /etc/supervisor/conf.d/ccworker${installNumberTag}_gost_eth_tls.conf -f
            rm /etc/supervisor/conf.d/ccworker${installNumberTag}_gost_etc_tcp.conf -f
            rm /etc/supervisor/conf.d/ccworker${installNumberTag}_gost_etc_tls.conf -f
            rm /etc/supervisor/conf.d/ccworker${installNumberTag}_gost_btc_tcp.conf -f
            rm /etc/supervisor/conf.d/ccworker${installNumberTag}_gost_btc_tls.conf -f
        elif [ -d "/etc/supervisord.d/" ]; then
            rm /etc/supervisord.d/ccworker${installNumberTag}.ini -f
            rm /etc/supervisord.d/ccworker${installNumberTag}_gost_eth_tcp.ini -f
            rm /etc/supervisord.d/ccworker${installNumberTag}_gost_eth_tls.ini -f
            rm /etc/supervisord.d/ccworker${installNumberTag}_gost_etc_tcp.ini -f
            rm /etc/supervisord.d/ccworker${installNumberTag}_gost_etc_tls.ini -f
            rm /etc/supervisord.d/ccworker${installNumberTag}_gost_btc_tcp.ini -f
            rm /etc/supervisord.d/ccworker${installNumberTag}_gost_btc_tls.ini -f
        fi
        echo "----------------------------------------------------------------"
        echo
        echo -e "$yellow 删除成功，如要安装新的，重新运行脚本选择即可${none}"
        supervisorctl stop ccworkertaxproxy$installNumberTag
        supervisorctl update
    else
        echo
        echo " 大佬...你压根就没安装这个标记ID的..."
        echo
        echo -e "$yellow 如要安装新的，重新运行脚本选择即可${none}"
        echo
        exit 1
    fi
}


show_status() {
	clear
    if ! type supervisorctl >/dev/null 2>&1; then
	 		echo "$yellow supervisor 守护不存在，是否还没安装cc8.0 ? ${none}"
	 	else
	    echo -e "$yellow 查看守护名称：   supervisorctl status ${none}"
	    echo -e "$yellow 查看守护状态：   supervisorctl status  名称 ${none}"
	    echo -e "$yellow 重启CC程序：     supervisorctl restart 名称 ${none}"
	    echo -e "$yellow 启动CC程序：     supervisorctl start   名称 ${none}"
	    echo -e "$yellow 关闭CC程序：     supervisorctl stop    名称 ${none}"
	    echo -e "$yellow ---------------------记住上述命令便于操作-----------------------${none}"
	    echo -e "$yellow ----------------------------------------------------------------${none}"
	    echo -e "$yellow ----------------详细运行情况请登录web管理查看-------------------${none}"
	    echo -e "$yellow ----------------------------------------------------------------${none}"
	    echo
	 		supervisorctl status
	 	  echo
	 	fi
} 


clear
while :; do
	  echo
	  echo "....... 安装+破解，替换作者抽水钱包；安装需要输入你的钱包。 https://t.me/MinerProxyHackGO by 独秀 ......."
    echo
    echo "....... CaoCaoMinerTaxProxy 8.0.5版 防DDos CC 极致优化版<双钱包> 一键安装脚本 & 管理脚本  by 曹操 ......."
    echo
    echo ".................. 支持曹操，本破解只用于研究目的，请尊重原作者，尽量不要使用破解版本 ..................."
    echo
    echo "............. 破解群里有 二次元mp400T9、mp530，小黄人/GominerProxy_V142破解，欢迎入群学习 ..............."
    echo
    echo "............. 项目地址：https://github.com/minerproxys .................................................."
    echo
    echo " 1. 安装并破解"
    echo
    echo " 2. 更新并破解"
    echo
    echo " 3. 卸      载"
    echo
    echo " 4. 查看守护进程运行状态"
    echo
    echo "---破解过程如果没动，请多按几下回车！"
    echo
    read -p "$(echo -e "请选择 [${magenta}1-4$none]:")" choose
    case $choose in
    1)
        install
        show_status
        break
        ;;
    2)
        update_version
        show_status
        break
        ;;
    3)
        uninstall
        show_status
        break
        ;;
    4)
        show_status
        break
        ;;
    *)
        error
        ;;
    esac
done


