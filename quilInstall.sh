#!/bin/bash

# 检查是否以root用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "please change root user to run this script"
    echo "try 'sudo su' to change to root user"
    exit 1
fi

if [ ! -d "/root/.albert_config" ]; then
  mkdir /root/.albert_config
  chmod -R 777 /root/.albert_config
fi
echo "############################################"
echo ""
echo "             *IMPORTANT*                    "
echo ""
echo "SAVE LISTED FILES TO YOUR PC"
echo "  /www/ceremonyclient/node/.config/keys.yml"
echo "  /www/ceremonyclient/node/.config/config.yml"
echo "  /root/wallet1.bak"
echo ""
echo ""
echo "                          -- by SESXueLan"
echo "###########################################"
sleep 3

#################### environment ##########################
install_environment(){
cd /root

ufw disable

apt-get update
apt install cpulimit -y
apt install zip -y
apt install unzip -y
apt install curl build-essential make gcc jq git -y
apt install lz4 -y

if [ ! -d "/www" ]; then
  mkdir -p /www
  chmod -R 777 /www
fi
cd /root
if [ ! -d "/root/.asdf" ]; then
  git clone https://github.com/asdf-vm/asdf.git /root/.asdf --branch v0.14.0
fi

if [ `grep -c "asdf.sh" /root/.bashrc` -ne '0' ];then
  echo "asdf config exists, skip..."
else
  chmod +x .asdf/asdf.sh
  chmod +x .asdf/completions/asdf.bash
  echo  '. $HOME/.asdf/asdf.sh' >> /root/.bashrc
  echo  '. $HOME/.asdf/completions/asdf.bash' >> /root/.bashrc
fi

source /root/.bashrc
source /root/.asdf/asdf.sh
source /root/.asdf/completions/asdf.bash

if [[ `asdf plugin list` =~ "golang" ]]; then
  echo "exists golang plugin, skip..."
else
  asdf plugin add golang https://github.com/asdf-community/asdf-golang.git
fi

if [ ! -d "/root/.asdf/installs/golang/1.20.14" ]; then
  asdf install golang 1.20.14
fi
if [ ! -d "/root/.asdf/installs/golang/1.22.1" ]; then
  asdf install golang 1.22.1
fi

if [[ $(grep ^"net.core.rmem_max=600000000"$ /etc/sysctl.conf) ]]; then
  echo "\net.core.rmem_max=600000000\" found inside /etc/sysctl.conf, skipping..."
else
  echo -e "\n# Change made to increase buffer sizes for better network performance for ceremonyclient\nnet.core.rmem_max=600000000" | tee -a /etc/sysctl.conf > /dev/null
fi

if [[ $(grep ^"net.core.wmem_max=600000000"$ /etc/sysctl.conf) ]]; then
  echo "\net.core.wmem_max=600000000\" found inside /etc/sysctl.conf, skipping..."
else
  echo -e "\n# Change made to increase buffer sizes for better network performance for ceremonyclient\nnet.core.wmem_max=600000000" | tee -a /etc/sysctl.conf > /dev/null
fi
sysctl -p
}
################################################


#################### quil ######################
install_quil(){
cd /www
(
cat <<EOF
#!/bin/bash
# 兼容zsh
export DISABLE_AUTO_TITLE="true"

session="QuilNode"
tmux has-session -t \$session
if [ \$? = 0 ];then
    tmux attach-session -t \$session
    exit
fi

tmux new-session -d -s \$session
tmux send-keys -t \$session:0 'cd /www/ceremonyclient/node/' C-m
tmux send-keys -t \$session:0 '. /www/quil_profile' C-m
tmux send-keys -t \$session:0 '/root/gowork_quil/bin/node ./..' C-m
#tmux new-window -t \$session:1
#tmux send-keys -t \$session:1 'cd /www/ceremonyclient/node/' C-m
# tmux send-keys -t \$session:1 'cpulimit -e node --limit 90 -b' C-m
EOF
) >/root/start.sh
chmod +x /root/start.sh


(
cat <<EOF
grpcurl -plaintext localhost:8337 quilibrium.node.node.pb.NodeService.GetNodeInfo
# grpcurl -plaintext localhost:8337 quilibrium.node.node.pb.NodeService.GetTokenInfo
cd /www/ceremonyclient/client
./qclient token balance
EOF
) >/root/check.sh
chmod +x /root/check.sh

(
cat <<EOF
export GOROOT=/root/.asdf/installs/golang/1.20.14/go
export GOPATH=\$HOME/gowork_quil
export GOBIN=\$GOPATH/bin
export GO111MODULE=on
export PATH=\$GOPATH:\$GOBIN:\$GOROOT/bin:\$PATH
EOF
) >quil_profile
source quil_profile
source /root/.asdf/asdf.sh
source /root/.asdf/completions/asdf.bash
asdf global golang 1.20.14

(
cat <<EOF
source /www/quil_profile
EOF
) >>/root/.bashrc
source /root/.bashrc

(
cat <<EOF
@reboot /root/start.sh
00 00 * * * /usr/sbin/reboot
EOF
) >/var/spool/cron/crontabs/root

crontab -u root /var/spool/cron/crontabs/root
service cron restart

go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest

git clone https://github.com/QuilibriumNetwork/ceremonyclient.git

cd /www/ceremonyclient/node
asdf local golang 1.20.14

GOEXPERIMENT=arenas go run ./... &

while true; do
    if [ -f "/www/ceremonyclient/node/.config/config.yml" ]; then
      sleep 10
      # 结束进程
      process_count=$(ps -ef | grep "exe/node" | grep -v grep | wc -l)
      process_pids=$(ps -ef | grep "exe/node" | grep -v grep | awk '{print $2}' | xargs)

      if [ $process_count -gt 0 ]; then
          echo "killing processes $process_pids"
          kill $process_pids

          child_process_count=$(pgrep -P $process_pids | wc -l)
          child_process_pids=$(pgrep -P $process_pids | xargs)
          if [ $child_process_count -gt 0 ]; then
              echo "killing child processes $child_process_pids"
              kill $child_process_pids
          else
              echo "no child processes running"
          fi
      else
          echo "no processes running"
      fi
      # 修改文件
      sed -i 's|listenGrpcMultiaddr: ""|listenGrpcMultiaddr: "/ip4/0.0.0.0/tcp/8337"|g' /www/ceremonyclient/node/.config/config.yml
      sed -i 's|listenRESTMultiaddr: ""|listenRESTMultiaddr: "/ip4/0.0.0.0/tcp/8338"|g' /www/ceremonyclient/node/.config/config.yml
      break
    else
      echo "config file not exists, waiting..."
      sleep 30
    fi


    sleep 10
done

cd /www/ceremonyclient/node
GOEXPERIMENT=arenas go clean -v -n -a ./...
rm /root/gowork_quil/bin/node
GOEXPERIMENT=arenas go install ./...
cd /www/ceremonyclient/client
GOEXPERIMENT=arenas go build -o qclient main.go


touch /root/.albert_config/quil_installed
}
################################################

install_environment

if [ ! -f "/root/.albert_config/quil_installed" ]; then
  install_quil
fi
