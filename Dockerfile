FROM nginx:1
COPY --from=fatedier/frps:v0.53.2 /usr/bin/frps /usr/bin/frps
COPY rootfs/ /

RUN set -xe \
    && mv /docker-entrypoint.sh /docker-entrypoint-nginx.sh \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y unzip zip wget \
    && bash /dl-frpc.sh && rm /dl-frpc.sh \
    && apt-get remove --purge --auto-remove -y unzip zip wget && rm -rf /var/lib/apt/lists/* && apt-get purge -y --auto-remove

# STOPSIGNAL SIGINT
ENTRYPOINT ["/entry.sh"]
EXPOSE 80 7000
