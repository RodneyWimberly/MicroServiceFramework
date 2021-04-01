FROM vault

LABEL maintainer="MicroServices Framework <hello@microserviceframework.com>" \
    org.label-schema.name="Vault" \
    org.label-schema.description="MicroServices Framework Vault Docker Image" \
    org.label-schema.vcs-url="https://github.com/RodneyWimberly/MicroServiceFramework" \
    org.label-schema.vendor="microserviceframework" \
    org.label-schema.version="1.0" \
    org.label-schema.schema-version="1.0"

RUN set -x && \
    apk update && \
    apk upgrade && \
    apk add --no-cache \
    curl \
    jq \
    iputils \
    iproute2 \
    bind-tools \
    gettext \
    gawk \
    bash \
    openrc \
    dhclient

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


EXPOSE 8200

ENTRYPOINT ["/usr/local/scripts/entrypoint.sh"]
CMD [ "server", "-config=/vault/config" ]

HEALTHCHECK \
    --interval=30s \
    --timeout=30s \
    --retries=10 \
    --start-period=30s \
    CMD /usr/local/scripts/health-check.sh