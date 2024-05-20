#!/bin/bash

wget -4 https://github.com/chenyangu/remoteGit/raw/master/PINGPONG
yes | sudo apt-get update
yes | sudo apt-get install ca-certificates curl
yes | sudo install -m 0755 -d /etc/apt/keyrings
yes | sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
yes | sudo chmod a+r /etc/apt/keyrings/docker.asc
yes | sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
chmod +x ./PINGPONG
