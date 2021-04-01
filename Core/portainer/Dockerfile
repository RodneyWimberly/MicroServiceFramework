FROM portainer/portainer-ce:alpine

LABEL maintainer="MicroServices Framework <hello@microserviceframework.com>" \
    org.label-schema.name="Portainer" \
    org.label-schema.description="MicroServices Framework Portainer Docker Image" \
    org.label-schema.vcs-url="https://github.com/RodneyWimberly/MicroServiceFramework" \
    org.label-schema.vendor="microserviceframework" \
    org.label-schema.version="1.0" \
    org.label-schema.schema-version="1.0"

# Install updates and common tools
RUN set -x && \
    apk update && \
    apk upgrade && \
    apk add --no-cache \
        curl \
        bind-tools \
        unzip \
        jq \
        gettext \
        dhclient \
        openrc


COPY ./*.env /usr/local/scripts/
COPY ./*.sh /usr/local/scripts/
COPY ./consul-service.json /etc/templates/consul-service.json
RUN chmod 755 /usr/local/scripts/*.sh

ENTRYPOINT ["/usr/local/scripts/entrypoint.sh"]

HEALTHCHECK \
    --interval=30s \
    --timeout=30s \
    --retries=10 \
    --start-period=30s \
    CMD /usr/local/scripts/health-check.sh
