FROM mcr.microsoft.com/mssql/server

# Label the image
LABEL maintainer="microserviceframework <hello@microserviceframework.com>" \
    org.label-schema.name="Auth-Db" \
    org.label-schema.description="MicroServices Framework Auth DB Docker Image" \
    org.label-schema.vcs-url="https://github.com/RodneyWimberly/MicroServiceFramework" \
    org.label-schema.vendor="microserviceframework" \
    org.label-schema.version="1.0" \
    org.label-schema.schema-version="1.0" \
    Name="auth-db" \
    Version="1.0"

USER root
RUN apt update && \
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
    apt-get clean && \
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

CMD ["/usr/local/scripts/entrypoint.sh"]
EXPOSE 1433