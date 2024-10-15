#!/bin/bash

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    release_os="linux"
    if [[ $(uname -m) == "aarch64"* ]]; then
        release_arch="arm64"
    else
        release_arch="amd64"
    fi
else
    release_os="darwin"
    release_arch="arm64"
fi

fetch() {
    files=$(curl https://releases.quilibrium.com/release | grep $release_os-$release_arch)
    new_release=false

    for file in $files; do
        version=$(echo "$file" | cut -d '-' -f 2)
        if ! test -f "./$file"; then
            curl "https://releases.quilibrium.com/$file" > "$file"
            new_release=true
        fi
    done
}

fetchClient() {
    files=$(curl https://releases.quilibrium.com/qclient-release | grep $release_os-$release_arch)
    new_release=false

    for file in $files; do
        version=$(echo "$file" | cut -d '-' -f 2)
        if ! test -f "./$file"; then
            curl "https://releases.quilibrium.com/$file" > "$file"
            new_release=true
        fi
    done
}

fetch
fetchClient

chmod +x node-2.0*
chmod +x qclient-2.0*
