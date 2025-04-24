FROM nginx:1.28.0-bookworm@sha256:9334faa48d730571746a7baab46d62896cb685502bc29d270c4495e26fc78afd
ARG DEBIAN_FRONTEND='noninteractive'

# renovate: datasource=github-releases depName=just-containers/s6-overlay versioning=loose
ARG S6_OVERLAY_VERSION=v3.2.0.2
ARG S6_OVERLAY_BASE_URL=https://github.com/just-containers/s6-overlay/releases/download
RUN set -x && \
    apt-get update && apt-get install -y xz-utils && \
    curl --fail ${S6_OVERLAY_BASE_URL}/${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz -SLo- | tar -C / -Jxpf - && \
    curl --fail ${S6_OVERLAY_BASE_URL}/${S6_OVERLAY_VERSION}/s6-overlay-`uname -m| sed 's/armv7l/armhf/g'`.tar.xz -SLo- | tar -C / -Jxpf - && \
    apt-get purge -y --auto-remove xz-utils

COPY --from=fatedier/frps:v0.62.0@sha256:0540c0560ff790cfc6227bb83315c6767bc13e49447bf7fdd59b818057ef25b5 \
    /usr/bin/frps /usr/bin/frps
COPY rootfs/ /
COPY rootfs-s6-rc/ /

RUN set -eux && \
    mv /docker-entrypoint.sh /docker-entrypoint-nginx.sh && \
    apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y unzip zip wget && \
    bash /dl-frpc.sh && rm /dl-frpc.sh && \
    apt-get purge -y --auto-remove unzip zip wget && \
    rm -rf /var/lib/apt/lists/*

STOPSIGNAL SIGTERM
ENTRYPOINT ["/init"]
EXPOSE 80 7000
