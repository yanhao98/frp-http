FROM nginx:1
COPY --from=fatedier/frps:v0.53.2 /usr/bin/frps /usr/bin/frps
COPY rootfs/ /

RUN set -x && \
    mv /docker-entrypoint.sh /docker-entrypoint-nginx.sh && \
    apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y unzip zip wget && \
    bash /dl-frpc.sh && rm /dl-frpc.sh && \
    apt-get purge -y --auto-remove unzip zip wget && \
    rm -rf /var/lib/apt/lists/*

# STOPSIGNAL SIGINT
ENTRYPOINT ["/entry.sh"]
EXPOSE 80 7000
