FROM --platform=$BUILDPLATFORM fatedier/frps:v0.53.2 as origin-frps

FROM nginx:1
COPY --from=origin-frps /usr/bin/frps /usr/bin/frps

COPY ./src/nginx/templates /etc/nginx/templates
COPY ./src/html /usr/share/nginx/html

COPY ./src/dl-frpc.sh /dl-frpc.sh

RUN set -xe \
    && mv /docker-entrypoint.sh /docker-entrypoint-nginx.sh \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y unzip zip wget \
    && bash /dl-frpc.sh && rm /dl-frpc.sh \
    && apt-get remove --purge --auto-remove -y unzip zip wget && rm -rf /var/lib/apt/lists/* && apt-get purge -y --auto-remove

COPY ./src/nginx/templates /etc/nginx/templates
COPY ./src/entry.sh /entry.sh
# STOPSIGNAL SIGINT
ENTRYPOINT ["/entry.sh"]
EXPOSE 80 7000
