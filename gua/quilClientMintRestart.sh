#!/bin/bash

# 无限循环，每隔10分钟重启一次程序
while true; do
    # 后台启动 ./mint 并将输出重定向到日志文件
    ./qclient-2.0.2.3-linux-amd64 token mint all &> mint.log &

    # 获取进程ID
    mint_pid=$!

    # 等待10分钟 (600秒)
    sleep 600

    # 杀掉当前运行的 mint 进程
    kill $mint_pid

    # 确保进程已终止
    wait $mint_pid 2>/dev/null
done
