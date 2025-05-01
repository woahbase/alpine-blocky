# syntax=docker/dockerfile:1
#
ARG IMAGEBASE=frommakefile
#
FROM ${IMAGEBASE}
#
ARG SRCARCH
ARG VERSION
#
ENV \
    BLOCKY_CONFIG_FILE=/config/config.yml
#
RUN set -ex \
    && apk add -Uu --no-cache \
        # bind-tools \
        ca-certificates \
        curl \
        gcompat \
        libcap \
        tzdata \
        yq \
    && echo "Using version: $SRCARCH / $VERSION" \
    && curl \
        -o /tmp/blocky_${VERSION}_${SRCARCH}.tar.gz \
        -SL https://github.com/0xERR0R/blocky/releases/download/v${VERSION}/blocky_v${VERSION}_${SRCARCH}.tar.gz \
    && tar -xzf /tmp/blocky_${VERSION}_${SRCARCH}.tar.gz -C /usr/local/bin \
    && /usr/sbin/setcap CAP_NET_BIND_SERVICE=+eip $(which blocky) \
    && apk del --purge \
        curl \
        libcap \
    && rm -rf /var/cache/apk/* /tmp/*
#
COPY root/ /
#
VOLUME /config/
#
HEALTHCHECK \
    --interval=2m \
    --retries=5 \
    --start-period=5m \
    --timeout=10s \
    CMD \
    blocky healthcheck || exit 1
    # dig @127.0.0.1 -p 53 healthcheck.blocky +tcp || exit 1
#
EXPOSE 4000 53/tcp 53/udp 853 443
#
ENTRYPOINT ["/init"]
