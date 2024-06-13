#!/bin/bash

# 要压缩的文件夹
DIR=".config"

# 远程 Windows 系统的 SSH 配置
WINDOWS_IP="192.168.1.3"
WINDOWS_USER="username"
WINDOWS_DEST_DIR="/c/Users/xiguzai/Downloads"  # WSL 中的 Windows 目录路径

rm -rf /www/ceremonyclient/node/.config/config.yml.bak
# 检查文件夹是否存在
if [ -d "$DIR" ]; then
  # 获取外网 IP 地址
  IP=$(curl -s http://ipecho.net/plain)

  # 检查是否成功获取 IP 地址
  if [ -z "$IP" ]; then
    echo "获取外网 IP 地址失败"
    exit 1
  fi

  # 创建压缩文件名
  ZIP_FILE="${IP}.zip"

  # 压缩文件夹，并覆盖旧的压缩文件
  zip -r "$ZIP_FILE" "$DIR"

  # 检查压缩是否成功
  if [ $? -eq 0 ]; then
    echo "文件夹已压缩：$ZIP_FILE"

    # # 使用 scp 将文件传输到 Windows 系统
    # scp "$ZIP_FILE" "${WINDOWS_USER}@${WINDOWS_IP}:${WINDOWS_DEST_DIR}"

    # # 检查传输是否成功
    # if [ $? -eq 0 ]; then
    #   echo "文件已成功下载到 Windows 系统：${WINDOWS_DEST_DIR}"
    # else
    #   echo "文件下载到 Windows 系统失败"
    fi
  else
    echo "压缩文件夹失败：$DIR"
  fi
else
  echo "文件夹不存在：$DIR"
fi
