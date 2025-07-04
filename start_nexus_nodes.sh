#!/bin/bash

# 检查是否提供了 node-id
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <node-id1> <node-id2> ... <node-idN>"
    exit 1
fi

# 创建日志目录
LOG_DIR="./nexus_logs"
mkdir -p "$LOG_DIR"

# 启动每个节点并记录日志
for node_id in "$@"; do
    log_file="$LOG_DIR/nexus_node_${node_id}.log"
    echo "Starting node $node_id (logs: $log_file)"
    nohup ./nexus-network start --node-id "$node_id" > "$log_file" 2>&1 &
    tail -f "$log_file" &
done

# 提示信息
echo "All nodes started. Press Ctrl+C to stop."
echo "To view logs, check files in $LOG_DIR/"

# 等待 Ctrl+C 退出
trap 'kill $(jobs -p)' EXIT
wait
