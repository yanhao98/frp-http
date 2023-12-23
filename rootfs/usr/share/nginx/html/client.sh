#!/bin/bash
set -e

MAIN_DOMAIN="REPLACE_MAIN_DOMAIN"
SERVER_IP="REPLACE_SERVER_IP"
version='REPLACE_VERSION'

# Get options
for i in "$@"; do
    case $i in
    --local=*)
        LOCAL="${i#*=}"
        ;;
    -sd=* | --subdomain=*)
        SUBDOMAIN="${i#*=}"
        ;;
    *)
        # unknown option
        echo "Unknown option: $i"
        ;;
    esac
done

USERNAME=$(whoami)

# Check options
if [[ -z "$LOCAL" ]]; then
    echo "Missing required option: --local."
    exit 1
fi

# Split local
IFS=':' read -r -a LOCAL_ARRAY <<<"$LOCAL"
LOCAL_IP=${LOCAL_ARRAY[0]}
LOCAL_PORT=${LOCAL_ARRAY[1]}

if [[ -z "$SUBDOMAIN" ]]; then
    UUID="$(system_profiler SPHardwareDataType | awk '/UUID/ { print $3; }')"
    UUID=$(echo "$UUID" | tr '[:upper:]' '[:lower:]')
    SUBDOMAIN="${UUID}-${LOCAL_PORT}"
fi

# ############################### Ready to run ###############################
# https://www.ruanyifeng.com/blog/2019/12/mktemp.html
TEMP_DIR=$(mktemp -d) || exit 1
declare -r TEMP_DIR
echo "Working in $TEMP_DIR"
cleanup() {
    echo ""
    echo "Cleaning up..."
    local target="$1"
    rm -vr "$target"
}
trap 'cleanup "$TEMP_DIR"' EXIT


download_frpc() {
    local os=$(echo "$(uname -s)" | sed 's/Darwin/darwin/g') # Darwin => darwin
    local arch=$(echo "$(uname -m)" | sed 's/x86_64/amd64/g') # x86_64 => amd64
    local filename="frpc_${version}_${os}_${arch}.tar.gz"
    local url="${MAIN_DOMAIN}/download/${filename}"
    cd "$TEMP_DIR" || exit 1
    echo "Downloading $filename from $url..."
    curl -s -L "$url" -o "./$filename"
    echo "Unpacking $filename..."
    tar -xzf "./$filename"
}
download_frpc

echo "Running frpc v$(./frpc -v)..."

for i in {1..3}; do echo -ne "\033[1A\033[K"; done

# ##############################################################################
url="https://$SUBDOMAIN.$MAIN_DOMAIN"
spaces_needed=$((69 - ${#url}))
padding=$(printf '%*s' $spaces_needed)

cat <<"EOF" | sed "s|URL|$url$padding|g"
  ___________________________________________________________________________  
 /         _   _                                                             \ 
||        | | (_)                                                            ||
||        | |_ _  __ _  ___ _ __                                             ||
||        | __| |/ _` |/ _ \ '__|                                            ||
||        | |_| | (_| |  __/ |                                               ||
||         \__|_|\__, |\___|_|.                                              ||
||                __/ |                                                      ||
||               |___/                                                       ||
||___________________________________________________________________________||
||                                                                           ||
||   You can access your service through the following address:              ||
||      URL||
||                                                                           ||
||   to stop frpc, please press ^C.                                          ||
||                                                                           ||
||   Enjoy!                                                                  ||
 \___________________________________________________________________________/ 
EOF



./frpc http \
    --server_addr=${SERVER_IP} \
    --server_port=7000 \
    --local_ip="${LOCAL_IP}" \
    --local_port="${LOCAL_PORT}" \
    --sd="${SUBDOMAIN}" \
    --proxy_name="${USERNAME}|${LOCAL}|${SUBDOMAIN}"
