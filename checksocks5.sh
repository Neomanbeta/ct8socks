#!/bin/bash

# 名为 socks5_proxy 的 pm2 进程名称
PROCESS_NAME="socks5_proxy"

# 设置 PATH，确保 pm2 命令可用
export PATH=/home/$USER/.npm-global/bin:$PATH

# 确保 pm2 命令在远程vps保活脚本中可用
PM2_CMD="/home/$USER/.npm-global/bin/pm2"

# socks5.js 文件路径
WORK_DIR="/home/$USER/domains/${USER,,}.ct8.pl/socks5"
WORK_SCRIPT="socks5.js"
SCRIPT_PATH="$WORK_DIR/$WORK_SCRIPT"

# 检查 pm2 是否在运行
$PM2_CMD status &> /dev/null
if [ $? -ne 0 ]; then
  echo -e "\033[32mPM2 未运行。正在启动 PM2...\033[0m"
  $PM2_CMD resurrect
fi

# 获取 socks5_proxy 进程的状态
PROCESS_STATUS=$($PM2_CMD info $PROCESS_NAME 2>/dev/null | grep status | awk '{print $4}')

# 如果进程未运行或已停止
if [ "$PROCESS_STATUS" != "online" ]; then
  echo -e "\033[32m进程 $PROCESS_NAME 未运行或已停止。正在启动新进程...\033[0m"
  # 确保进入正确的脚本目录
  cd $WORK_DIR || { echo "Failed to cd to $WORK_DIR"; exit 1; }
  $PM2_CMD start $SCRIPT_PATH --name $PROCESS_NAME --cwd $WORK_DIR
else
  echo -e "\033[32m进程 $PROCESS_NAME 已经在运行。\033[0m"
  RUNNING_TIME=$($PM2_CMD info $PROCESS_NAME | grep "uptime" | awk '{print $4 " " $5 " " $6}')
  echo -e "\033[32m进程 $PROCESS_NAME 已经运行了 $RUNNING_TIME。\033[0m"
fi
