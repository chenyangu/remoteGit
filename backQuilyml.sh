#!/bin/bash

# 要压缩的文件夹
DIR=".config"

if [ -d "$DIR" ]; then
  # 获取外网 IP 地址
  IP=$(curl -s http://ipecho.net/plain)
  
  # 检查是否成功获取 IP 地址
  if [ -z "$IP" ]; then
    echo "获取外网 IP 地址失败"
    exit 1
  fi
  
  cd /www/ceremonyclient/node
  # 创建压缩文件名
  ZIP_FILE="${IP}www.tar.gz"
  
  # 压缩文件夹，并覆盖旧的压缩文件
  tar -czf "$ZIP_FILE" "$DIR"/*.yml
  
  # 检查压缩是否成功
  if [ $? -eq 0 ]; then
    echo "文件夹已压缩：$ZIP_FILE"
  
    sz "$ZIP_FILE"
  else
    echo "压缩文件夹失败：$DIR"
  fi
  
  cd /root/ceremonyclient/node
  
  # 创建压缩文件名
  ZIP_FILE2="${IP}root.tar.gz"
  
  # 压缩文件夹，并覆盖旧的压缩文件
  tar -czf "$ZIP_FILE2" "$DIR"/*.yml
  
  # 检查压缩是否成功
  if [ $? -eq 0 ]; then
    echo "文件夹已压缩：$ZIP_FILE2"
  
    sz "$ZIP_FILE2"
  else
    echo "压缩文件夹失败：$DIR"
  fi
else
  echo "文件夹不存在：$DIR"
fi
