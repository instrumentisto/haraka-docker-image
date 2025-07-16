# https://hub.docker.com/_/node
ARG node_ver=24
FROM node:${node_ver}-alpine3.22

ARG haraka_ver=3.1.1
ARG build_rev=2


COPY rootfs /

RUN apk update \
 && apk upgrade \
 && apk add --no-cache \
        ca-certificates \
 && update-ca-certificates \
    \
 # Install tools for building Haraka
 && apk add --no-cache --virtual .build-deps \
        python3 g++ make \
    \
 # Build and install Haraka
 && npm install -g Haraka@${haraka_ver} \
 && haraka -i /etc/haraka/ \
 # See: https://github.com/haraka/Haraka/issues/2746#issuecomment-580387065
 && sed -i -e 's,^max_unrecognized_commands,#max_unrecognized_commands,' \
        /etc/haraka/config/plugins \
    \
 # Setup entrypoint
 && chmod +x /usr/local/bin/docker-entrypoint.sh \
    \
 # Cleanup caches and unnecessary stuff
 && apk del .build-deps \
 && rm -rf /var/cache/apk/* \
           /root/.npm/* \
           /tmp/*

ENV HARAKA_HOME=/etc/haraka


EXPOSE 25 587

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["-c", "/etc/haraka"]
