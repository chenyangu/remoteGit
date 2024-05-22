#!/bin/bash

sudo -i
set -x
cd /www/ceremonyclient/node/.config/
wget -c 45.77.39.118/quil.zip
rm -rf store
unzip -o quil.zip
