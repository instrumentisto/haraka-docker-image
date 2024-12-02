# https://hub.docker.com/_/node
ARG node_ver=22
FROM node:${node_ver}-alpine3.20

ARG haraka_ver=3.0.5
ARG build_rev=0


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
 # TODO: Remove once `node` image ships at least 10.9.1 `npm` version.
 # Install latest `npm` version to include npm/npm-install-checks#120:
 # https://github.com/npm/npm-install-checks/pull/120
 && npm --maxsockets=1 install -g npm@latest \
 && npm --version \
    \
 # Build and install Haraka
 && npm --maxsockets=1 install -g Haraka@${haraka_ver} \
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
