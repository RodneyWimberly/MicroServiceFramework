FROM serjs/go-socks5-proxy

# Label the image
LABEL Author microserviceframework
LABEL Name socks-proxy

# Install updates and common tools
RUN set -x && \
    apk update && \
    apk add --no-cache \
        curl \
        bind-tools \
        unzip \
        jq \
        gettext

COPY ./core.env /usr/local/scripts/core.env
COPY ./*.sh /usr/local/scripts/
COPY ./consul-service.json /etc/templates/consul-service.json
RUN chmod 755 /usr/local/scripts/*.sh

ENTRYPOINT ["/usr/local/scripts/socks-proxy-entrypoint.sh"]
