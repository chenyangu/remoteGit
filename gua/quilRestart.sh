#!/bin/bash

binary="node-2.0.1-$release_os-$release_arch"
# 循环执行，直到手动停止
while true; do
  echo "Starting ./node-2.0.1-linux-amd64..."
  
  # 启动二进制文件，使用 & 使其在后台运行
  ./$binary

  # 等待20分钟
  sleep 1200
  # 查找并杀死所有 node-2.0.1-linux-amd64 进程
  pkill -f "./$binary"

  echo "All node-2.0.1-linux-amd64 processes have been terminated."
done
