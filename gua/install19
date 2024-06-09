#!/bin/bash

if ! [ -x "$(command -v sudo)" ]; then
  echo "需要root权限执行脚本..." >&2
  exit 1
fi

cd /root 

echo "更新系统并安装工具..."
apt -q update
apt-get install git wget tar curl zip -y

if ! [ "$(sudo swapon -s)" ]; then
  echo "创建swap..."
  sudo mkdir /swap && sudo fallocate -l 24G /swap/swapfile && sudo chmod 600 /swap/swapfile || { echo "Failed to create swap space! Exiting..."; exit 1; }
  sudo mkswap /swap/swapfile && sudo swapon /swap/swapfile || { echo "Failed to set up swap space! Exiting..."; exit 1; }
  sudo bash -c 'echo "/swap/swapfile swap swap defaults 0 0" >> /etc/fstab' || { echo "Failed to update /etc/fstab! Exiting..."; exit 1; }
fi

echo "配置网络参数..."
if [[ $(grep ^"net.core.rmem_max=600000000"$ /etc/sysctl.conf) ]]; then
  echo "\net.core.rmem_max=600000000\" found inside /etc/sysctl.conf, skipping..."
else
  echo -e "\n# Change made to increase buffer sizes for better network performance for ceremonyclient\nnet.core.rmem_max=600000000" | sudo tee -a /etc/sysctl.conf > /dev/null
fi
if [[ $(grep ^"net.core.wmem_max=600000000"$ /etc/sysctl.conf) ]]; then
  echo "\net.core.wmem_max=600000000\" found inside /etc/sysctl.conf, skipping..."
else
  echo -e "\n# Change made to increase buffer sizes for better network performance for ceremonyclient\nnet.core.wmem_max=600000000" | sudo tee -a /etc/sysctl.conf > /dev/null
fi
sudo sysctl -p

cat <<EOF > /root/qlog.sh
journalctl -fu ceremonyclient.service
EOF
chmod +x /root/qlog.sh

# 检查当前安装的 Go 版本
if go version | grep -q "go1.20.1[1-4]"; then
  echo "Go已经安装..."
else
  echo "安装Go..."
  
  # 检查系统架构
  ARCH=$(uname -m)
  if [[ "$ARCH" == "x86_64" ]]; then
    GO_URL="http://49.13.194.189:8008/go1.20.14.linux-amd64.tar.gz"
  elif [[ "$ARCH" == "aarch64" ]]; then
    GO_URL="http://49.13.194.189:8008/go1.20.14.linux-arm64.tar.gz"
  else
    echo "不支持的架构: $ARCH"
    exit 1
  fi

  # 下载 Go 安装包
  if wget -4 $GO_URL; then
    echo "下载Go安装包成功..."
  else
    echo "下载Go安装包失败..."
    exit 1
  fi
  
  # 提取包文件名
  FILE_NAME=$(basename $GO_URL)
  
  # 解压 Go 安装包
  if sudo tar -C /usr/local -xzf $FILE_NAME; then
    echo "解压Go安装包成功..."
  else
    echo "解压Go安装包失败..."
    exit 1
  fi

  # 删除 Go 安装包
  sudo rm $FILE_NAME
fi

echo "配置 Go 环境变量..."
sed -i '/export GOROOT=\/usr\/local\/go/d' ~/.bashrc
sed -i '/export GOPATH=\/root\/go/d' ~/.bashrc
sed -i '/export PATH=\$PATH:\/usr\/local\/go\/bin/d' ~/.bashrc

if grep -q 'export GOROOT=/usr/local/go' ~/.bashrc; then
    echo "GOROOT already set in ~/.bashrc."
else
    echo 'export GOROOT=/usr/local/go' >> ~/.bashrc
    echo "GOROOT set in ~/.bashrc."
fi

if grep -q "export GOPATH=$HOME/go" ~/.bashrc; then
    echo "GOPATH already set in ~/.bashrc."
else
    echo "export GOPATH=$HOME/go" >> ~/.bashrc
    echo "GOPATH set in ~/.bashrc."
fi

if grep -q 'export PATH=$GOPATH/bin:$GOROOT/bin:$PATH' ~/.bashrc; then
    echo "PATH already set in ~/.bashrc."
else
    echo 'export PATH=$GOPATH/bin:$GOROOT/bin:$PATH' >> ~/.bashrc
    echo "PATH set in ~/.bashrc."
fi

source ~/.bashrc
sleep 1  # Add a 1-second delay

# 临时设置 Go 环境变量 - 多余，但它修复了 GO 命令未找到错误
export PATH=$PATH:/usr/local/go/bin 
export GOPATH=~/go

echo "下载节点代码..."
cd /root && git clone https://source.quilibrium.com/quilibrium/ceremonyclient.git

# Navigate to the ceremonyclient directory and update the repository
cd /root/ceremonyclient && git fetch origin && git checkout release && git pull

# Extract version from Go file
version=$(cat /root/ceremonyclient/node/config/version.go | grep -A 1 "func GetVersion() \[\]byte {" | grep -Eo '0x[0-9a-fA-F]+' | xargs printf "%d.%d.%d")

# Determine binary path based on OS type and architecture
case "$OSTYPE" in
    linux-gnu*)
        if [[ $(uname -m) == x86* ]]; then
            binary="node-$version-linux-amd64"
        else
            binary="node-$version-linux-arm64"
        fi
        ;;
    darwin*)
        binary="node-$version-darwin-arm64"
        ;;
    *)
        echo "unsupported OS for releases, please build from source"
        exit 1
        ;;
esac

echo "Create/update the systemd service file for ceremonyclient"
cat <<EOF > /lib/systemd/system/ceremonyclient.service
[Unit]
Description=Ceremony Client Go App Service

[Service]
Type=simple
Restart=always
RestartSec=5s
WorkingDirectory=/root/ceremonyclient/node
Environment=GOEXPERIMENT=arenas
ExecStart=/root/ceremonyclient/node/$binary

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable ceremonyclient.service
echo "安装完成，正在重启....."
reboot
