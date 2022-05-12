#!/bin/sh

testMode="1"
alias echo_date='echo [$(TZ=UTC-8 date -R +%Y-%m-%d\ %H:%M:%S)]'
# 当前脚本所在目录 绝对路径
DIR=$(cd $(dirname $0); pwd)
# 当前脚本所在目录名 作为模块名
module=${DIR##*/}
resolvPath="/etc/resolv.conf"

if [ $testMode != "1" ];then
  source /koolshare/scripts/ss_base.sh
else
  echo_date "[test]跳过 source /koolshare/scripts/ss_base.sh"
  resolvPath="$DIR/../../debug/resolv.conf"
  echo_date "[test]修改resolv.conf路径"
fi

setupNameserver() {
  echo_date "设置 resolv.conf..."
  cat >$resolvPath <<-EOF
			nameserver 127.0.0.1
		EOF
  echo_date "设置 resolv.conf 完成"
}

set_lock() {
	exec 1000>"$LOCK_FILE"
	flock -x 1000
}

unset_lock() {
	flock -u 1000
	rm -rf "$LOCK_FILE"
}

# 2. 清理上一次配置, 顺序: iptables -> ipset
# 3. 创建好空的 ipset
# 4. 创建好 dnsmasq 的 conf, 核心配置: **【哪些域名】向【哪些DNS服务器】解析, 把结果放到【哪些ipset】 下**
# 5. 配置 iptables 规则, 匹配 步骤2 创建的 ipset 重定向到代理客户端的 IP:PORT, 转发到旁路由用 DNAT, 直接转发到代理进程用 REDIRECT
# 6. 重启 dnsmasq 进程, 应用 步骤4 创建的 conf

# 0. 加锁
# 1. 检查路由器 nameserver 配置, 必须是 127.0.0.1
# 2. 清理相关iptables配置 主要是转发规则
# 3. 清理相关ipset配置
# 4. 清理相关dnsmasq配置 删除相关 conf 文件
# 5. 建立新的 conf 文件, 可以是建好然后 ln 过去
# 6. 重启 dnsmasq
# 7. 解锁
main(){
  echo_date "开始执行..."
  setupNameserver
  
  echo_date "执行完成"
}

main
