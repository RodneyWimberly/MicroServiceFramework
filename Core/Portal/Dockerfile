FROM nginx as base-image
LABEL Author rodneywimberly
LABEL Name portal
LABEL Version 1.0

# Install updates, nginx, and common tools
RUN set -x && \
    apt-get update && \
    apt-get -y --no-install-recommends --no-install-suggests install \
        curl \
        dnsutils \
        unzip \
        jq \
        ca-certificates \
        procps \
        less \
        vim

# Set Environment Vars
ENV CONTAINERPILOT_VER 3.0.0
ENV CONTAINERPILOT /etc/containerpilot/containerpilot.json5
ENV CONSUL_VERSION 1.9.1
ENV CONSUL_TEMPLATE_VERSION=0.25.1
ENV CONSUL_URL https://releases.hashicorp.com
ENV CONSUL_BIND_INTERFACE eth0
ENV CONSUL_CAPATH /consul/config/certs
ENV CONSUL_CACERT /consul/config/certs/em.docker-agent-ca.pem
ENV CONSUL_CLIENT_CERT /consul/config/certs/dc-server-em.docker-0.pem
ENV CONSUL_CLIENT_KEY /consul/config/certs/dc-server-em.docker-0-key.pem
ENV SERVICE_NAME portal
ENV VIRTUAL_HOST portal.service.em.docker

# Install Consl
RUN curl --silent --remote-name ${CONSUL_URL}/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip && \
    curl --silent --remote-name ${CONSUL_URL}/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS && \
    curl --silent --remote-name ${CONSUL_URL}/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS.sig && \
    unzip consul_${CONSUL_VERSION}_linux_amd64.zip && \
    mv consul /usr/bin/ && \
    rm /consul_${CONSUL_VERSION}_linux_amd64.zip && \
    rm /consul_${CONSUL_VERSION}_SHA256SUMS && \
    rm consul_${CONSUL_VERSION}_SHA256SUMS.sig

# Install ContainerPilot
RUN export CONTAINERPILOT_CHECKSUM=6da4a4ab3dd92d8fd009cdb81a4d4002a90c8b7c && \
    curl -Lso /tmp/containerpilot.tar.gz "https://github.com/joyent/containerpilot/releases/download/${CONTAINERPILOT_VER}/containerpilot-${CONTAINERPILOT_VER}.tar.gz" && \
    echo "${CONTAINERPILOT_CHECKSUM}  /tmp/containerpilot.tar.gz" | sha1sum -c && \
    tar zxf /tmp/containerpilot.tar.gz -C /bin && \
    rm /tmp/containerpilot.tar.gz

# Use consul-template to re-write our Nginx virtualhost config
RUN curl -Lo /tmp/consul_template_0.15.0_linux_amd64.zip ${CONSUL_URL}/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip && \
    unzip /tmp/consul_template_0.15.0_linux_amd64.zip && \
    mv consul-template /bin && \
    rm /tmp/consul_template_0.15.0_linux_amd64.zip

# Copy filesystem overlay
COPY root/. /.

EXPOSE 80 443
STOPSIGNAL SIGQUIT

# Nginx doesn't need root privileges so we run it as the consul user from the
# entry point script. The entry point script also uses dumb-init as the top-level
# process to reap any zombie processes created by Consul sub-processes.
COPY root/usr/local/bin/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]