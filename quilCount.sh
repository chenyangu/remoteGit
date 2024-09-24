#!/bin/bash

# 启用错误输出和调试信息
set -e
trap 'echo "Error occurred at line $LINENO"' ERR

# 文件路径，用于存储余额记录
LOG_FILE="balance_log.txt"
SUMMARY_FILE="balance_summary.txt"

# 获取当前的 Unclaimed balance (只提取数字部分)
get_balance() {
#    echo "Running get_balance at line $LINENO"
    ./node-1.4.21.1-darwin-arm64 --node-info | grep "Unclaimed balance" | awk '{print $3}'
}

# 记录当前时间和余额，同时输出到命令行
record_balance() {
    echo "Running record_balance at line $LINENO"
    BALANCE=$(get_balance)
    echo "B   $BALANCE"    
    if [[ ! $BALANCE =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        echo "Invalid balance: $BALANCE"
        exit 1
    fi
    
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    echo "$TIMESTAMP Unclaimed balance: $BALANCE"
    echo "$TIMESTAMP $BALANCE" >> "$LOG_FILE"
}

# 计算差异并更新汇总，同时输出到命令行
update_summary() {
    echo "Running update_summary at line $LINENO"
    # 读取前一次和当前的 balance 数值，确保提取的是数值
    PREV_BALANCE=$(tail -2 "$LOG_FILE" | head -1 | awk '{print $NF}')
    CURRENT_BALANCE=$(tail -1 "$LOG_FILE" | awk '{print $NF}')
    echo "prev: $PREV_BALANCE"
    echo "current: $CURRENT_BALANCE"
    # 检查数值格式是否正确
    if [[ ! $PREV_BALANCE =~ ^[0-9]+(\.[0-9]+)?$ || ! $CURRENT_BALANCE =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        echo "Invalid balance values - PREV_BALANCE: $PREV_BALANCE, CURRENT_BALANCE: $CURRENT_BALANCE"
        exit 1
    fi

    # 差值计算并格式化输出
    if [[ -n "$PREV_BALANCE" && -n "$CURRENT_BALANCE" ]]; then
        DIFF=$(echo "$CURRENT_BALANCE - $PREV_BALANCE" | bc -l)
        TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

        # 计算每分钟、每小时、每天的预计增长
        GROWTH_PER_MINUTE=$(echo "$DIFF / 3" | bc -l)   # 每 3 分钟的增长，除以 3 得到每分钟增长
        GROWTH_PER_HOUR=$(echo "$GROWTH_PER_MINUTE * 60" | bc -l)  # 每小时增长
        GROWTH_PER_DAY=$(echo "$GROWTH_PER_HOUR * 24" | bc -l)     # 每天增长

        # 输出差异和预计的增长到命令行
        echo "$TIMESTAMP Difference: $DIFF"
        echo "每分钟大概个数: $GROWTH_PER_MINUTE"
        echo "每小时大概个数: $GROWTH_PER_HOUR"
        echo "每天大概个数: $GROWTH_PER_DAY"

        # 更新每分钟、每小时、每天的增量到文件
        echo "$TIMESTAMP Difference: $DIFF" >> "$SUMMARY_FILE"
        echo "$TIMESTAMP Estimated per minute: $GROWTH_PER_MINUTE, per hour: $GROWTH_PER_HOUR, per day: $GROWTH_PER_DAY" >> "$SUMMARY_FILE"
    fi
}

# 主逻辑
while true; do
    echo "Starting main loop at line $LINENO"
    record_balance   # 记录当前时间和余额，并输出
    update_summary   # 更新汇总和差异，并输出
    sleep 180        # 每 3 分钟执行一次
done

