FROM sematext/logagent

# Label the image
LABEL maintainer="microserviceframework <hello@microserviceframework.com>" \
    org.label-schema.name="LogAgent" \
    org.label-schema.description="MicroServices Framework LogAgent Docker Image" \
    org.label-schema.vcs-url="https://github.com/RodneyWimberly/MicroServiceFramework" \
    org.label-schema.vendor="microserviceframework" \
    org.label-schema.version="1.0" \
    org.label-schema.schema-version="1.0"

RUN yes | apk add --no-cache \
    curl \
    jq \
    iputils \
    iproute2 \
    bind-tools \
    gettext \
    gawk \
    bash \
    npm && \
  yes | npm update && \
  yes | npm upgrade && \
  yes | npm i -g --unsafe-perm graygelf && \
  yes | npm i --unsafe-perm graygelf && \
  mkdir /usr/local/scripts && \
  chown -R node:node /usr/local/scripts

COPY ./logagent.conf /etc/sematext/logagent.conf
ENV LA_CONFIG /etc/sematext/logagent.conf   
 
COPY ./*.env /usr/local/scripts/
COPY ./*.sh /usr/local/scripts/
RUN chmod 755 /usr/local/scripts/*.sh

HEALTHCHECK \
    --interval=30s \
    --timeout=30s \
    --retries=10 \
    --start-period=30s \
    CMD /usr/local/scripts/health-check.sh

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/scripts/entrypoint.sh"]
