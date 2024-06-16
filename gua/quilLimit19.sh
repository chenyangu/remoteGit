#!/bin/bash

# 关键字
keyword="node-1.4.19"

# CPU 使用限制百分比
cpu_limit=80

# 获取所有匹配关键字的进程 ID
pids=$(pgrep -f $keyword)

# 循环处理每个进程
for pid in $pids; do
    echo "Limiting CPU usage for process $pid to $cpu_limit%"
    sudo cpulimit -p $pid -l $cpu_limit -b
done
