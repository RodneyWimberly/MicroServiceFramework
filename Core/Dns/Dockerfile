FROM storytel/dnsmasq

LABEL maintainer="MicroServices Framework <hello@microserviceframework.com>" \
    org.label-schema.name="Dns" \
    org.label-schema.description="MicroServices Framework DNS Docker Image" \
    org.label-schema.vcs-url="https://github.com/RodneyWimberly/MicroServiceFramework" \
    org.label-schema.vendor="microserviceframework" \
    org.label-schema.version="1.0" \
    org.label-schema.schema-version="1.0"

# Add required pacakges
RUN set -eux && \
    apk update && \
    apk upgrade && \
    apk add --no-cache \
        curl \
        unzip \
        bind-tools \
        iputils \
        iproute2 \
        gettext \
        jq

# Set Environment Vars
ENV CONSUL_VERSION 1.9.2
ENV CONSUL_TEMPLATE_VERSION=0.25.1
ENV CONSUL_URL https://releases.hashicorp.com

# Install Consl
RUN curl --remote-name ${CONSUL_URL}/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip && \
    curl --remote-name ${CONSUL_URL}/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS && \
    curl --remote-name ${CONSUL_URL}/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS.sig && \
    unzip consul_${CONSUL_VERSION}_linux_amd64.zip && \
    mv consul /usr/bin/ && \
    rm /consul_${CONSUL_VERSION}_linux_amd64.zip && \
    rm /consul_${CONSUL_VERSION}_SHA256SUMS && \
    rm consul_${CONSUL_VERSION}_SHA256SUMS.sig && \
    # tiny smoke test to ensure the binary we downloaded runs
    consul version

# Use consul-template to re-write our Nginx virtualhost config
RUN curl -Lo /tmp/consul_template_0.15.0_linux_amd64.zip ${CONSUL_URL}/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip && \
    unzip /tmp/consul_template_0.15.0_linux_amd64.zip && \
    mv consul-template /bin && \
    rm /tmp/consul_template_0.15.0_linux_amd64.zip

# Install ContainerPilot
ENV CONTAINERPILOT_VER 3.0.0
ENV CONTAINERPILOT /etc/containerpilot.json5

RUN export CONTAINERPILOT_CHECKSUM=6da4a4ab3dd92d8fd009cdb81a4d4002a90c8b7c \
    && curl -Lso /tmp/containerpilot.tar.gz \
    "https://github.com/joyent/containerpilot/releases/download/${CONTAINERPILOT_VER}/containerpilot-${CONTAINERPILOT_VER}.tar.gz" \
    && echo "${CONTAINERPILOT_CHECKSUM}  /tmp/containerpilot.tar.gz" | sha1sum -c \
    && tar zxf /tmp/containerpilot.tar.gz -C /bin \
    && rm /tmp/containerpilot.tar.gz

COPY ./*.env /usr/local/scripts/
COPY ./*.sh /usr/local/scripts/
COPY ./0.base.conf /etc/dnsmasq/0.base.conf
COPY ./1.consul.conf /etc/templates/1.consul.conf
COPY ./consul-service.json /etc/templates/consul-service.json
COPY ./containerpilot.json5 /etc/templates/containerpilot.json5
RUN chmod 755 /usr/local/scripts/*.sh

ENTRYPOINT ["/usr/local/scripts/entrypoint.sh"]

HEALTHCHECK \
    --interval=30s \
    --timeout=30s \
    --retries=10 \
    --start-period=30s \
    CMD /usr/local/scripts/health-check.sh
