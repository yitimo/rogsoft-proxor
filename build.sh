#!/bin/sh

set -e

MODULE=Proxor
VERSION=`cat ./version|sed -n 1p`
TITLE=Proxor
DESCRIPTION=Proxor
HOME_URL=Module_proxor.asp

echo "[Proxor]前端打包"

cd ./app
npm run build
cd ..

rm -rf ./proxor/webs
cp -r ./app/build ./proxor/webs

echo "[Proxor]前端打包完成"

sleep 1

echo "[Proxor]开发中..."
exit 1

# TODO: 将 ./proxor 目录打包为 .tar.gz 包
# TODO: 更新 ./config.json.js 和 ./version 文件, 这两个文件供远程请求访问 用来和本地版本对比实现版本更新
# TODO: 更新 ./proxor/version 应该与 ./version 内版本号保持一致
