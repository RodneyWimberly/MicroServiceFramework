FROM vault

# Label the image
LABEL Author microserviceframework
LABEL Name vault
LABEL Version 1.0

RUN apk add --no-cache \
    curl \
    jq \
    iputils \
    iproute2 \
    bind-tools \
    gettext \
    gawk \
    bash

RUN mkdir /usr/local/scripts && \
    mkdir /vault/templates && \
    mkdir /vault/certs && \
    chown -R vault:vault /usr/local/scripts && \
    chown -R vault:vault /vault

COPY ./*.hcl /usr/local/policies/
COPY ./*.env /usr/local/scripts/
COPY ./*.sh /usr/local/scripts/
COPY ./*.pem /vault/certs/
COPY ./vault.json /vault/templates/vault.json
COPY ./consul-agent-ca.pem usr/local/share/ca-certificates/consul-agent-ca.pem
RUN chmod 755 /usr/local/scripts/*.sh
RUN test -e /etc/nsswitch.conf || echo 'hosts: dns files' > /etc/nsswitch.conf

EXPOSE 8200

ENTRYPOINT ["/usr/local/scripts/vault-entrypoint.sh"]
CMD [ "server", "-config=/vault/config" ]
