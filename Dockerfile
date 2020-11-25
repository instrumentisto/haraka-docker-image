# https://hub.docker.com/_/node
ARG node_ver=15
FROM node:${node_ver}-alpine

ARG haraka_ver=2.8.25
ARG build_rev=0

LABEL org.opencontainers.image.source="\
          https://github.com/instrumentisto/haraka-docker-image"

RUN apk update \
 && apk upgrade \
 && apk add --no-cache \
        ca-certificates \
 && update-ca-certificates \
    \
 # Install tools for building Haraka
 && apk add --no-cache --virtual .build-deps \
        python2 g++ make \
    \
 # Build and install Haraka
 && npm install -g Haraka@${haraka_ver} \
 && haraka -i /etc/haraka/ \
 # See: https://github.com/haraka/Haraka/issues/2746#issuecomment-580387065
 && sed -i -e 's,^max_unrecognized_commands,#max_unrecognized_commands,' \
        /etc/haraka/config/plugins \
    \
 # Cleanup caches and unnecessary stuff
 && apk del .build-deps \
 && rm -rf /var/cache/apk/* \
           /root/.npm/* \
           /tmp/*


EXPOSE 25 587

ENTRYPOINT ["/usr/local/bin/haraka"]

CMD ["-c", "/etc/haraka/"]
