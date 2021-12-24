FROM mcr.microsoft.com/dotnet/aspnet:5.0-buster-slim

# Label the image
LABEL maintainer="microserviceframework <hello@microserviceframework.com>" \
    org.label-schema.name="Auth-Api" \
    org.label-schema.description="MicroServices Framework Auth Admin Docker Image" \
    org.label-schema.vcs-url="https://github.com/RodneyWimberly/MicroServiceFramework" \
    org.label-schema.vendor="microserviceframework" \
    org.label-schema.version="1.0" \
    org.label-schema.schema-version="1.0"\
    Name="auth-api" \
    Version="1.0"

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
COPY ./appsettings.json /app/appsettings.json
RUN chmod 755 /usr/local/scripts/*.sh

HEALTHCHECK \
    --interval=30s \
    --timeout=30s \
    --retries=10 \
    --start-period=30s \
    CMD /usr/local/scripts/health-check.sh

WORKDIR /app
COPY ./bld/. .

CMD [ "dotnet", "MicroServicesFramework.Auth.Admin.Api.dll" ]
EXPOSE 50002
