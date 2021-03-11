FROM graylog/graylog:4.0

# Label the image
LABEL maintainer="microserviceframework <hello@microserviceframework.com>" \
    org.label-schema.name="Graylog" \
    org.label-schema.description="MicroServices Framework Graylog Docker image" \
    org.label-schema.vcs-url="https://github.com/RodneyWimberly/MicroServiceFramework" \
    org.label-schema.vendor="microserviceframework" \
    org.label-schema.version="1.0" \
    org.label-schema.schema-version="1.0"

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
    chown -R graylog:graylog /usr/local/scripts

COPY ./*.env /usr/local/scripts/
COPY ./*.sh /usr/local/scripts/
COPY ./consul-service.json /etc/templates/consul-service.json
RUN chmod 755 /usr/local/scripts/*.sh

HEALTHCHECK \
    --interval=30s \
    --timeout=30s \
    --retries=10 \
    --start-period=30s \
    CMD /usr/local/scripts/health-check.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/scripts/entrypoint.sh"]
