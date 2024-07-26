#!/bin/bash

# 介绍信息
echo -e "\e[32m
 ____   ___   ____ _  ______ ____  
 / ___| / _ \ / ___| |/ / ___| ___|  脚本作者TG:@RealNeoMan
 \___ \| | | | |   | ' /\___ \___ \ 
  ___) | |_| | |___| . \ ___) |__) |           不要直连
 |____/ \___/ \____|_|\_\____/____/            没有售后   
\e[0m"

# 获取当前用户名
USER=$(whoami)

# 检查pm2是否已安装并可用
if command -v pm2 > /dev/null 2>&1 && [[ $(which pm2) == "/home/${USER,,}/.npm-global/bin/pm2" ]]; then
  echo "pm2已安装且可用，跳过安装步骤。"
else
  # 安装pm2
  echo "正在安装pm2，请稍候..."
  curl -s https://raw.githubusercontent.com/k0baya/alist_repl/main/serv00/install-pm2.sh | bash

  if [ $? -ne 0 ]; then
    echo "pm2安装失败，请检查网络连接或稍后再试。"
    exit 1
  fi
  echo "pm2安装成功。"

  # 检查pm2路径
  if [[ $(which pm2) != "/home/${USER,,}/.npm-global/bin/pm2" ]]; then
    echo "pm2未正确配置。请断开并重新连接SSH后再运行此脚本。"
    exit 1
  fi
fi

# 检查socks5目录是否存在
SOCKS5_DIR=~/domains/${USER,,}.ct8.pl/socks5
if [ -d "$SOCKS5_DIR" ]; then
  read -p "目录$SOCKS5_DIR已经存在，是否继续安装？(Y/N): " CONTINUE_INSTALL
  CONTINUE_INSTALL=${CONTINUE_INSTALL^^} # 转换为大写
  if [ "$CONTINUE_INSTALL" != "Y" ]; then
    echo "安装已取消。"
    exit 1
  fi
else
  # 创建socks5目录
  echo "正在创建socks5目录..."
  mkdir -p "$SOCKS5_DIR"
fi

cd "$SOCKS5_DIR"

# 检查node-socks5-server是否已安装
if npm list node-socks5-server > /dev/null 2>&1; then
  echo "node-socks5-server已安装，跳过安装步骤。"
else
  # 初始化npm项目
  echo "正在初始化npm项目..."
  npm init -y

  # 安装node-socks5-server
  echo "正在安装node-socks5-server，请稍候..."
  npm install node-socks5-server

  if [ $? -ne 0 ]; then
    echo "node-socks5-server安装失败，请检查网络连接或稍后再试。"
    exit 1
  fi
  echo "node-socks5-server安装成功。"
fi

# 检查socks5.js文件是否存在
SOCKS5_JS="$SOCKS5_DIR/socks5.js"
if [ -f "$SOCKS5_JS" ]; then
  read -p "当前目录下已经有socks5.js文件，是否要覆盖？(Y/N): " OVERWRITE_FILE
  OVERWRITE_FILE=${OVERWRITE_FILE^^} # 转换为大写
  if [ "$OVERWRITE_FILE" != "Y" ]; then
    echo "文件未覆盖，安装已取消。"
    exit 1
  fi
fi

# 提示用户输入socks5端口号
read -p "请输入socks5端口号: " SOCKS5_PORT

# 生成socks5.js文件
cat <<EOF > socks5.js
'use strict';

const socks5 = require('node-socks5-server');

const users = {
  'user': 'password',
};

const userPassAuthFn = (user, password) => {
  if (users[user] === password) return true;
  return false;
};

const server = socks5.createServer({
  userPassAuthFn,
});
server.listen($SOCKS5_PORT);
EOF

# 提示用户输入用户名和密码
read -p "请输入socks5用户名: " SOCKS5_USER

while true; do
  read -p "请输入socks5密码（不能包含@和:）：" SOCKS5_PASS
  echo
  if [[ "$SOCKS5_PASS" == *"@"* || "$SOCKS5_PASS" == *":"* ]]; then
    echo "密码中不能包含@和:符号，请重新输入。"
  else
    break
  fi
done

# 修改socks5.js文件中的用户名和密码
sed -i '' "s/'user': 'password'/'$SOCKS5_USER': '$SOCKS5_PASS'/" socks5.js

# 检查并删除已存在的同名pm2进程
if pm2 list | grep -q socks_proxy; then
  pm2 stop socks_proxy
  pm2 delete socks_proxy
fi

# 启动socks5.js代理
echo "正在启动socks5代理..."
pm2 start socks5.js --name socks_proxy

# 延迟检测以确保代理启动
echo "等待代理启动..."
sleep 5

# 检查pm2中进程的运行状态
PM2_STATUS=$(pm2 show socks_proxy | grep status | awk '{print $4}')
if [ "$PM2_STATUS" == "online" ]; then
  echo "代理服务已启动。正在检查代理运行状态..."
  CURL_OUTPUT=$(curl -s ip.sb --socks5 $SOCKS5_USER:$SOCKS5_PASS@localhost:$SOCKS5_PORT)
  if [[ $CURL_OUTPUT =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "代理创建成功，返回的IP是: $CURL_OUTPUT"
    echo "代理工作正常，脚本结束。"
  else
    echo "代理创建失败，请检查自己输入的内容。"
    pm2 stop socks_proxy
    pm2 delete socks_proxy
    exit 1
  fi
else
  echo "代理服务启动失败，请检查配置。"
  exit 1
fi
