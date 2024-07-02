#!/bin/bash

ACCOUNTNAME=$1
WORKERNAME=$2

# 指定要检查的文件夹路径
DIR="/root/zkAleo"

# 检查文件夹是否存在
if [ -d "$DIR" ]; then
    echo "文件夹 $DIR 已经存在。"
else
    echo "文件夹 $DIR 不存在，正在创建..."
    mkdir -p "$DIR"
    if [ $? -eq 0 ]; then
        echo "文件夹 $DIR 创建成功。"
    else
        echo "文件夹 $DIR 创建失败。"
    fi
fi

cd $DIR

LOCAL_FILE = "$DIR/aleo-pool-prover"
# 检查本地文件是否存在
if [ -f "$LOCAL_FILE" ]; then
    echo "本地文件 $LOCAL_FILE 已存在。"

    # 获取本地文件的MD5哈希值
    LOCAL_HASH=$(md5sum "$LOCAL_FILE" | awk '{ print $1 }')

    # 获取服务器文件的MD5哈希值
    SERVER_HASH=$(wget -qO- "$URL" | md5sum | awk '{ print $1 }')

    if [ "$LOCAL_HASH" == "$SERVER_HASH" ]; then
        echo "本地文件与服务器文件一致，不需要下载。"
    else
        echo "本地文件与服务器文件不一致，重新下载。"
        wget -c https://github.com/zkrush/aleo-pool-client/releases/download/v1.5-testnet-beta/aleo-pool-prover
    fi
else
    echo "本地文件 $LOCAL_FILE 不存在，正在下载..."
    wget -O "$LOCAL_FILE" "$URL"
fi

echo "下载完成"
chmod +x aleo-pool-prover
cat <<EOF > /etc/systemd/system/aleo-pool-prover.service

[Unit]
Description=Aleo F2Pool Prover Service
After=network.target

[Service]
ExecStart=$DIR/aleo-pool-prover --pool wss://aleo.zkrush.com:3333 --account $ACCOUNTNAME --worker-name $WORKERNAME
WorkingDirectory=$DIR
StandardOutput=append:$DIR/prover.log
StandardError=append:$DIR/prover.log
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

echo "安装完成，准备启动"
sudo systemctl daemon-reload
sudo systemctl start aleo-pool-prover
sudo systemctl enable aleo-pool-prover

echo "启动完成"
