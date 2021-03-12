FROM consul

LABEL maintainer="MicroServices Framework <hello@microserviceframework.com>" \
    org.label-schema.name="Consul" \
    org.label-schema.description="MicroServices Framework Consul Docker Image" \
    org.label-schema.vcs-url="https://github.com/RodneyWimberly/MicroServiceFramework" \
    org.label-schema.vendor="microserviceframework" \
    org.label-schema.version="1.0" \
    org.label-schema.schema-version="1.0"

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
    chown -R consul:consul /consul
+
COPY ./*.env /usr/local/scripts/
COPY ./*.sh /usr/local/scripts/
COPY ./*.pem /consul/certs/
COPY ./*.json /consul/templates/
COPY ./consul-agent-ca.pem usr/local/share/ca-certificates/consul-agent-ca.pem
RUN chmod 755 /usr/local/scripts/*.sh


ENTRYPOINT ["/usr/local/scripts/entrypoint.sh"]
CMD agent -retry-join consul.service.consul

# HEALTHCHECK \
#     --interval=30s \
#     --timeout=30s \
#     --retries=10 \
#     --start-period=2m \
#     CMD echo "test" || exit 0

HEALTHCHECK NONE
