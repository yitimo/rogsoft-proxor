#!/bin/sh
# TODO: 真机这里需要放开 待研究包含了啥
# source /koolshare/scripts/base.sh
alias echo_date='echo [$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)]: '
# 当前脚本所在目录 绝对路径
DIR=$(cd $(dirname $0); pwd)
# 当前脚本所在目录名 作为模块名
module=${DIR##*/}

# 安装代理插件
# 复制各种 shell 脚本到软件目录下
# 复制UI到软件目录下, 这里只提供几个控制按钮和展示状态按钮即可, 更漂亮的UI放到nas上

install(){
	# TODO: 安装过程
	echo "module=$module DIR=$DIR"
}

install
