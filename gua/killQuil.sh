#!/bin/bash

# 循环运行直到手动停止
while true; do
  echo "Killing all node-2.0.1-linux-amd64 processes..."
  
  # 查找并杀死所有 node-2.0.1-linux-amd64 进程
  pkill -f "./node-2.0.1-linux-amd64"

  echo "All node-2.0.1-linux-amd64 processes have been terminated."
  
  # 等待20分钟
  sleep 1200
done
