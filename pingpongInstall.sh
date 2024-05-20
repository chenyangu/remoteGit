#!/bin/bash
sudo su
sudo mkdir -p /myProjects/pingpong && sudo chown -R $USER:$USER /myProjects/pingpong && cd /myProjects/pingpong/
wget -4 https://github.com/chenyangu/remoteGit/raw/master/PINGPONG
yes | sudo apt-get update
yes | sudo apt-get install ca-certificates curl
yes | sudo install -m 0755 -d /etc/apt/keyrings
yes | sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
yes | sudo chmod a+r /etc/apt/keyrings/docker.asc
yes | sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
chmod +x ./PINGPONG && ./PINGPONG --key 1f9ebc8b04b80a7b9b46f1e12f71a9828da078bbea7785a359889bf72347ea1a
