FROM consul

# Label the image
LABEL Author rodneywimberly
LABEL Name consul

RUN set -eux && \
    apk update && \
    apk add --no-cache \
        curl \
        bind-tools \
        iputils \
        iproute2 \
        gettext \
        jq

RUN mkdir /usr/local/scripts && \
    mkdir /consul/templates && \
    mkdir /consul/certs && \
    chown -R consul:consul /usr/local/scripts && \
    chown -R consul:consul /consul

COPY ./core.env /usr/local/scripts/core.env
COPY ./*.sh /usr/local/scripts/
COPY ./*.pem /consul/certs/
COPY ./*.json /consul/templates/
COPY ./consul-agent-ca.pem usr/local/share/ca-certificates/consul-agent-ca.pem
RUN chmod 755 /usr/local/scripts/*.sh

ENTRYPOINT ["/usr/local/scripts/consul-entrypoint.sh"]
CMD [ "agent", "-join", "tasks.core_consul" ]
