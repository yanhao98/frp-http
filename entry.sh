#!/bin/bash
set -e

print_title() {
    local title="$1"  # 将传入的参数赋值给 title 变量

    # ANSI 颜色代码
    local red='\033[0;31m'  # 红色
    local no_color='\033[0m'  # 无颜色（用于重置颜色）

    # 打印彩色标题
    echo -e "${red}${title}${no_color}"
}

if [ -z "${FRP_SUBDOMAIN_HOST}" ] || [ "${FRP_SUBDOMAIN_HOST}" = "domain.com" ]; then
    echo "FRP_SUBDOMAIN_HOST is not set"
    exit 1
fi

FRPS_VER=$(frps -v)
SERVER_IP=$(curl -fsSL ip.sb)

print_title "confirm environment variables"
printf "FRP_SUBDOMAIN_HOST: %s\n" "${FRP_SUBDOMAIN_HOST}"
printf "SERVER_IP: %s\n" "${SERVER_IP}"
printf "FRPS_VER: %s\n" "${FRPS_VER}"

sed -i "s/REPLACE_MAIN_DOMAIN/${FRP_SUBDOMAIN_HOST}/g" /usr/share/nginx/html/client.sh
sed -i "s/REPLACE_SERVER_IP/${SERVER_IP}/g" /usr/share/nginx/html/client.sh
sed -i "s/REPLACE_VERSION/${FRPS_VER}/g" /usr/share/nginx/html/client.sh
sed -i "s/REPLACE_MAIN_DOMAIN/${FRP_SUBDOMAIN_HOST}/g" /usr/share/nginx/html/client.vbs
sed -i "s/REPLACE_SERVER_IP/${SERVER_IP}/g" /usr/share/nginx/html/client.vbs
sed -i "s/REPLACE_VERSION/${FRPS_VER}/g" /usr/share/nginx/html/client.vbs

# print_title "the download folder"
# ls -l /usr/share/nginx/html/download

print_title "start nginx"
/docker-entrypoint-nginx.sh nginx -g "daemon on;"

# sleep 0.1
print_title "start frps"
exec /usr/bin/frps \
    --bind-port="7000" \
    --subdomain-host="${FRP_SUBDOMAIN_HOST}" \
    --vhost-http-port="7080" \
    --dashboard-port="7500" \
    --dashboard-user="" \
    --dashboard-pwd=""
