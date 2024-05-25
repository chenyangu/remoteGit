#!/bin/bash

echo "Stop the existing ceremonyclient service"
service ceremonyclient stop

sed -i 's|listenGrpcMultiaddr: ""|listenGrpcMultiaddr: "/ip4/0.0.0.0/tcp/8337"|g' /root/ceremonyclient/node/.config/config.yml && sed -i 's|listenRESTMultiaddr: ""|listenRESTMultiaddr: "/ip4/0.0.0.0/tcp/8338"|g' /root/ceremonyclient/node/.config/config.yml

# Navigate to the ceremonyclient directory and update the repository
cd /root/ceremonyclient && git fetch origin && git checkout release

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
CPUQuota=600%
Type=simple
Restart=always
RestartSec=5s
WorkingDirectory=/root/ceremonyclient/node
Environment=GOEXPERIMENT=arenas
ExecStart=/root/ceremonyclient/node/$binary

[Install]
WantedBy=multi-user.target
EOF

echo "Reload the systemd manager configuration"
# systemctl daemon-reload

echo "Start the ceremonyclient service"
service ceremonyclient start
echo "Ceremony Client has been updated and restarted successfully."
journalctl -fu ceremonyclient.service
