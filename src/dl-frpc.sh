#!/bin/bash
#
# Description: 只保留frpc
#
set -e

cd /usr/share/nginx/html

FRPS_VER=$(frps -v)

declare -a URLS
URLS[0]="https://github.com/fatedier/frp/releases/download/v${FRPS_VER}/frp_${FRPS_VER}_darwin_arm64.tar.gz"
URLS[1]="https://github.com/fatedier/frp/releases/download/v${FRPS_VER}/frp_${FRPS_VER}_darwin_amd64.tar.gz"
URLS[2]="https://github.com/fatedier/frp/releases/download/v${FRPS_VER}/frp_${FRPS_VER}_windows_amd64.zip"
URLS[3]="https://github.com/fatedier/frp/releases/download/v${FRPS_VER}/frp_${FRPS_VER}_windows_arm64.zip"

mkdir ./temp
cd ./temp

declare -a FILENAMES
declare -a OUTPUTS_FILENAMES
for i in "${!URLS[@]}"; do
    echo "----------------------------------------"
    FILENAMES[i]=$(basename "${URLS[$i]}") # >>> frp_0.0.0_darwin_arm64.tar.gz
    OUTPUTS_FILENAMES[i]=${FILENAMES[$i]//frp/frpc} # >>> frpc_0.0.0_darwin_arm64.tar.gz
    echo "Downloading ${FILENAMES[$i]} ..."
    wget --quiet "${URLS[$i]}"

    echo "Packing frpc ..."
    if [[ "${FILENAMES[$i]}" =~ \.zip$ ]]; then
        unzip -q "./${FILENAMES[$i]}"
        zip -q -j "./${OUTPUTS_FILENAMES[$i]}" "./${FILENAMES[$i]//.zip/}/frpc.exe"
        rm -rf "./${FILENAMES[$i]//.zip/}"
    else
        # [tar命令详解](https://www.cnblogs.com/duanweishi/p/16899404.html)
        tar -xzf "./${FILENAMES[$i]}"
        tar -czf "./${OUTPUTS_FILENAMES[$i]}" -C "./${FILENAMES[$i]//.tar.gz/}" frpc
        rm -rf "./${FILENAMES[$i]//.tar.gz/}"
    fi
    rm -rf "./${FILENAMES[$i]}"

done

cd ..

mv ./temp ./download

echo "Done."
