FROM alpine
ARG SSH_PASS=P@55w0rd

LABEL maintainer="MicroServices Framework <hello@microserviceframework.com>" \
  org.label-schema.name="SSH-Server" \
  org.label-schema.description="MicroServices Framework SSH Server Docker Image" \
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
  openssh \ 
  openssl \
  bash \
  shadow \
  openrc

COPY ./*.env /usr/local/scripts/
COPY ./*.sh /usr/local/scripts/
COPY ./consul-service.json /etc/templates/consul-service.json
COPY ./sshd_config /etc/ssh/sshd_config

RUN addgroup  www-data && \
  echo -e "${SSH_PASS}\n${SSH_PASS}" | adduser -s /bin/bash -G www-data webssh && \
  usermod -a -G www-data,root root && \
  chmod 755 /usr/local/scripts/*.sh && \
  rc-update add sshd default && \
  mkdir -p /run/openrc/ && \
  touch /run/openrc/softlevel


EXPOSE 22
ENTRYPOINT ["/usr/local/scripts/entrypoint.sh"]

HEALTHCHECK \
  --interval=30s \
  --timeout=30s \
  --retries=10 \
  --start-period=30s \
  CMD /usr/local/scripts/health-check.sh