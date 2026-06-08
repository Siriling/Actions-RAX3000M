#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# 修改openwrt登陆地址,把下面的 192.168.10.1 修改成你想要的就可以了
# sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate
# 修改子网掩码
#sed -i 's/255.255.255.0/255.255.0.0/g' package/base-files/files/bin/config_generate
# 修改主机名字，把 RAX3000M 修改你喜欢的就行（不能纯数字或者使用中文）
sed -i 's/ImmortalWrt/RAX3000M/g' package/base-files/files/bin/config_generate

##-----------------Del duplicate packages------------------
rm -rf feeds/packages/net/open-app-filter
##-----------------Add OpenClash meta core------------------
curl -sL -m 30 --retry 2 https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-arm64.tar.gz -o /tmp/clash.tar.gz
tar zxvf /tmp/clash.tar.gz -C /tmp >/dev/null 2>&1
chmod +x /tmp/clash >/dev/null 2>&1
mkdir -p feeds/luci/applications/luci-app-openclash/root/etc/openclash/core
mv /tmp/clash feeds/luci/applications/luci-app-openclash/root/etc/openclash/core/clash_meta >/dev/null 2>&1
rm -rf /tmp/clash.tar.gz >/dev/null 2>&1
##-----------------Delete DDNS's examples-----------------
sed -i '/myddns_ipv4/,$d' feeds/packages/net/ddns-scripts/files/etc/config/ddns
##-----------------Manually set CPU frequency for MT7981B-----------------
sed -i '/"mediatek"\/\*|\"mvebu"\/\*/{n; s/.*/\tcpu_freq="1.3GHz" ;;/}' package/emortal/autocore/files/generic/cpuinfo

# 添加第三方应用
mkdir kiddin9
pushd kiddin9
git clone --depth=1 https://github.com/kiddin9/kwrt-packages .
popd

mkdir Modem-Support
pushd Modem-Support
git clone --depth=1 https://github.com/Siriling/5G-Modem-Support .
popd

mkdir MyConfig
pushd MyConfig
git clone --depth=1 https://github.com/Siriling/OpenWRT-MyConfig .
popd

# mkdir package/community
pushd package

# 系统相关应用
#Poweroff
git clone --depth=1 https://github.com/esirplayground/luci-app-poweroff .
# mkdir luci-app-poweroff
# cp -rf ../kiddin9/luci-app-poweroff/* luci-app-poweroff
#Diskman
rm -rf ../package/feeds/luci/luci-app-diskman
rm -rf ../feeds/luci/applications/luci-app-diskman
mkdir luci-app-diskman
cp -rf ../kiddin9/luci-app-diskman/* luci-app-diskman
#Fileassistant
mkdir luci-app-fileassistant
cp -rf ../kiddin9/luci-app-fileassistant/* luci-app-fileassistant
#Guest-wifi
mkdir luci-app-guest-wifi
cp -rf ../kiddin9/luci-app-guest-wifi/* luci-app-guest-wifi
#Onliner
mkdir luci-app-onliner
cp -rf ../kiddin9/luci-app-onliner/* luci-app-onliner
#Eqos
# mkdir luci-app-eqos
# cp -rf ../kiddin9/luci-app-eqos/* luci-app-eqos
#Wolplus
mkdir luci-app-wolplus
cp -rf ../kiddin9/luci-app-wolplus/* luci-app-wolplus
#WiFischedule
mkdir luci-app-wifischedule
cp -rf ../kiddin9/luci-app-wifischedule/* luci-app-wifischedule
#RAMfree
mkdir luci-app-ramfree
cp -rf ../kiddin9/luci-app-ramfree/* luci-app-ramfree
#ttyd（终端）
# mkdir luci-app-ttyd
# cp -rf ../kiddin9/luci-app-ttyd/* luci-app-ttyd
#NetData（系统监控）
mkdir luci-app-netdata
cp -rf ../kiddin9/luci-app-netdata/* luci-app-netdata
#rtbwmon（实施流量）
mkdir luci-app-rtbwmon
cp -rf ../kiddin9/luci-app-rtbwmon/* luci-app-rtbwmon

# 存储相关应用
mkdir autoshare-samba
mkdir luci-app-samba4
cp -rf ../kiddin9/autoshare-samba/* autoshare-samba
cp -rf ../kiddin9/luci-app-samba4/* luci-app-samba4

# 科学上网和代理应用
#OpenClash
# svn export https://github.com/vernesong/OpenClash/trunk/luci-app-openclash
# svn export https://github.com/Siriling/OpenWRT-MyConfig/trunk/configs/istoreos/general/applications/luci-app-openclash temp/luci-app-openclash
# cp -rf temp/luci-app-openclash/* luci-app-openclash
mkdir luci-app-openclash
cp -rf ../kiddin9/luci-app-openclash/* luci-app-openclash
cp -rf ../MyConfig/configs/istoreos/general/applications/luci-app-openclash/* luci-app-openclash
#加入OpenClash核心
chmod -R a+x $GITHUB_WORKSPACE/scripts/preset-clash-core.sh
$GITHUB_WORKSPACE/scripts/preset-clash-core.sh arm64
#加入OpenClash Dev核心
# curl -sL -m 30 --retry 2 https://raw.githubusercontent.com/vernesong/OpenClash/core/master/dev/clash-linux-arm64.tar.gz -o /tmp/clash.tar.gz
# tar zxvf /tmp/clash.tar.gz -C /tmp >/dev/null 2>&1
# chmod +x /tmp/clash >/dev/null 2>&1
# mkdir -p feeds/luci/applications/luci-app-openclash/root/etc/openclash/core
# mv /tmp/clash feeds/luci/applications/luci-app-openclash/root/etc/openclash/core/clash >/dev/null 2>&1
# rm -rf /tmp/clash.tar.gz >/dev/null 2>&1

# 去广告
#ADGuardHome（kiddin9）
mkdir luci-app-adguardhome
cp -rf ../kiddin9/luci-app-adguardhome/* luci-app-adguardhome
cp -rf ../MyConfig/configs/istoreos/general/applications/luci-app-adguardhome/* luci-app-adguardhome
sed -i 's/拦截DNS服务器/拦截DNS服务器（默认用户名和密码均为root）/' luci-app-adguardhome/po/zh_Hans/adguardhome.po
#sed -i 's/+PACKAGE_$(PKG_NAME)_INCLUDE_binary:adguardhome//' luci-app-adguardhome/Makefile
#ADGuardHome（kenzok8）
# cp -rf temp/luci-app-adguardhome/* luci-app-adguardhome
# sed -i 's/默认账号和密码均为：admin/默认用户名和密码均为root/' luci-app-adguardhome/po/zh-cn/AdGuardHome.po
# sed -i 's/网页管理账号和密码:admin ,端口:/端口/' luci-app-adguardhome/po/zh-cn/AdGuardHome.po
#dnsfilter
# svn export https://github.com/kenzok8/small-package/trunk/luci-app-dnsfilter
#ikoolproxy
# svn export https://github.com/kenzok8/small-package/trunk/luci-app-ikoolproxy

#内网穿透
#Zerotier
# mkdir luci-app-zerotier
# cp -rf ../kiddin9/luci-app-zerotier/* luci-app-zerotier

# 其他
#Socat
mkdir luci-app-socat
cp -rf ../kiddin9/luci-app-socat/* luci-app-socat
#Unblockneteasemusic
# mkdir UnblockNeteaseMusic
# mkdir luci-app-unblockneteasemusic
# cp -rf ../kiddin9/UnblockNeteaseMusic/* UnblockNeteaseMusic
# cp -rf ../kiddin9/luci-app-unblockneteasemusic/* luci-app-unblockneteasemusic
#OpenAppFilter
# svn export https://github.com/destan19/OpenAppFilter/trunk OpenAppFilter

#主题
# mkdir luci-theme-argon
mkdir luci-app-argon-config
# cp -rf ../kiddin9/luci-theme-argon/* luci-theme-argon
cp -rf ../kiddin9/luci-app-argon-config/* luci-app-argon-config

# iStore应用
mkdir taskd
mkdir luci-lib-taskd
mkdir luci-lib-xterm
mkdir luci-app-store
mkdir quickstart
mkdir luci-app-quickstart
cp -rf ../kiddin9/taskd/* taskd
cp -rf ../kiddin9/luci-lib-taskd/* luci-lib-taskd
cp -rf ../kiddin9/luci-lib-xterm/* luci-lib-xterm
cp -rf ../kiddin9/luci-app-store/* luci-app-store
cp -rf ../kiddin9/quickstart/* quickstart
cp -rf ../kiddin9/luci-app-quickstart/* luci-app-quickstart

# 5G通信模组拨号工具
mkdir quectel_QMI_WWAN
mkdir fibocom_QMI_WWAN
mkdir meig_QMI_WWAN
mkdir tw_QMI_WWAN
mkdir quectel_cm_5G
# mkdir quectel_MHI
# mkdir luci-app-hypermodem
cp -rf ../Modem-Support/quectel_QMI_WWAN/* quectel_QMI_WWAN
cp -rf ../Modem-Support/fibocom_QMI_WWAN/* fibocom_QMI_WWAN
cp -rf ../Modem-Support/meig_QMI_WWAN/* meig_QMI_WWAN
cp -rf ../../Modem-Support/tw_QMI_WWAN/* tw_QMI_WWAN
cp -rf ../Modem-Support/quectel_cm_5G/* quectel_cm_5G
# cp -rf ../Modem-Support/quectel_MHI/* quectel_MHI
# cp -rf ../Modem-Support/luci-app-hypermodem/* luci-app-hypermodem

# 5G模组短信插件
mkdir sms-tool
mkdir luci-app-sms-tool
cp -rf ../Modem-Support/sms-tool/* sms-tool
cp -rf ../Modem-Support/luci-app-sms-tool/* luci-app-sms-tool
cp -rf ../MyConfig/configs/istoreos/general/applications/luci-app-sms-tool/* luci-app-sms-tool

# 5G模组IPv6
mkdir ndisc
cp -rf ../Modem-Support/ndisc/* ndisc

# 5G模组管理插件+AT工具
mkdir luci-app-modem
cp -rf ../Modem-Support/luci-app-modem/* luci-app-modem
sed -i "/kmod-pcie_mhi/d" luci-app-modem/Makefile
popd

# 设置GCC版本
# cp -rf MyConfig/configs/hanwckf/toolchain/* toolchain

#解决elfutils编译错误
# rm -rf package/libs/elfutils
# cp -rf MyConfig/configs/hanwckf/package/libs package

# 更新uhttpd版本（防止在GCC版本为13.3.0时报错）
# rm -rf package/network/services/uhttpd
# cp -rf MyConfig/configs/hanwckf/package/network package