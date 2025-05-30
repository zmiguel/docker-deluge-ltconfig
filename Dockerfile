FROM alpine:edge
LABEL maintainer="ZMiguel Valdiviesso <zmiguel.alves@gmail.com>"

ARG LIBTORRENT_VERSION=2.0.11
ARG DELUGE_VERSION=2.2.0

ENV USER=deluge \
    UID=1000 \
    GID=1000

ADD scripts/*.sh docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh && build.sh

EXPOSE 8112/tcp 6881/tcp 6881/udp 55975/tcp 55975/udp 58846/tcp 58846/udp
VOLUME ["/config", "/data"]
ENTRYPOINT ["docker-entrypoint.sh"]
