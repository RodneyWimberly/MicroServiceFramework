FROM mongo

# Label the image
LABEL maintainer="microserviceframework <hello@microserviceframework.com>" \
    org.label-schema.name="Mongo" \
    org.label-schema.description="MicroServices Framework Mongo Docker Image" \
    org.label-schema.vcs-url="https://github.com/RodneyWimberly/MicroServiceFramework" \
    org.label-schema.vendor="microserviceframework" \
    org.label-schema.version="1.0" \
    org.label-schema.schema-version="1.0"

RUN apt-get update && \
    apt-get install -y \
    curl \
    jq \
    iputils-ping \
    iproute2 \
    dnsutils \
    gettext \
    gawk \
    wget \
    bash && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /usr/local/scripts


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

ENTRYPOINT ["/usr/local/scripts/entrypoint.sh"]
EXPOSE 27017