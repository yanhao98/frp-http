FROM nginx:1.27.1-bookworm@sha256:287ff321f9e3cde74b600cc26197424404157a72043226cbbf07ee8304a2c720
ARG DEBIAN_FRONTEND='noninteractive'

# renovate: datasource=github-releases depName=just-containers/s6-overlay versioning=loose
ARG S6_OVERLAY_VERSION=v3.2.0.0
ARG S6_OVERLAY_BASE_URL=https://github.com/just-containers/s6-overlay/releases/download
RUN set -x && \
    apt-get update && apt-get install -y xz-utils && \
    curl --fail ${S6_OVERLAY_BASE_URL}/${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz -SLo- | tar -C / -Jxpf - && \
    curl --fail ${S6_OVERLAY_BASE_URL}/${S6_OVERLAY_VERSION}/s6-overlay-`uname -m| sed 's/armv7l/armhf/g'`.tar.xz -SLo- | tar -C / -Jxpf - && \
    apt-get purge -y --auto-remove xz-utils

COPY --from=fatedier/frps:v0.60.0@sha256:2af55ac2d6c95784d1348be2a636f66c7fb8d67bd951cbb5951f34635f731445 \
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
