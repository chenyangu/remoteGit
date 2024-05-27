#!/bin/bash


# 检查是否以root用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "please change root user to run this script"
    echo "try 'sudo su' to change to root user"
    exit 1
fi

tmux kill-server

(
cat <<EOF
#!/bin/bash
sleep 20

while true; do
  count=\$(ps -ef |grep cpulimit|grep -v grep |wc -l)
  if [ \$count -gt 0 ]; then
    echo "limited! skip!"
  else
    echo "no limit! should limit cpu usage"
    sleep 5
    cpulimit --pid \`ps -ef |grep "node" |grep "\-linux\-"|awk '{print \$2}'\` --limit 300 -b
  fi
  sleep 600
done

EOF
) >/root/limitcpu.sh
chmod +x /root/limitcpu.sh

reboot
