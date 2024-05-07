FROM nginx:1.26.0-bookworm@sha256:9f0d283eccddedf25816104877faf1cb584a8236ec4d7985a4965501d080d84f
ARG DEBIAN_FRONTEND='noninteractive'

# renovate: datasource=github-releases depName=just-containers/s6-overlay versioning=loose
ARG S6_OVERLAY_VERSION=v3.1.6.2
ARG S6_OVERLAY_BASE_URL=https://github.com/just-containers/s6-overlay/releases/download
RUN set -x && \
    apt-get update && apt-get install -y xz-utils && \
    curl --fail ${S6_OVERLAY_BASE_URL}/${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz -SLo- | tar -C / -Jxpf - && \
    curl --fail ${S6_OVERLAY_BASE_URL}/${S6_OVERLAY_VERSION}/s6-overlay-`uname -m| sed 's/armv7l/armhf/g'`.tar.xz -SLo- | tar -C / -Jxpf - && \
    apt-get purge -y --auto-remove xz-utils

COPY --from=fatedier/frps:v0.58.0@sha256:05058b87eb8ae942cf66a3d38575ed464f388fb078b622260d66ea3357eb7b33 \
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
