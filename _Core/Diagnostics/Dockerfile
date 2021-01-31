FROM mhart/alpine-node
LABEL Author rodneywimberly
LABEL Name hello
LABEL Version 1.0

# This is the release of Consul to pull in.
ENV CONSUL_VERSION=1.9.1
ENV CONSUL_TEMPLATE_VERSION=0.25.1

# This is the location of the releases.
ENV HASHICORP_RELEASES=https://releases.hashicorp.com

# Configure containerpilot
ENV CONTAINERPILOT_VER 3.0.0
ENV CONTAINERPILOT /etc/containerpilot.json5

# Create a consul user and group first so the IDs get set the same way, even as
# the rest of this may change over time.
RUN addgroup consul && \
    adduser -S -G consul consul

# Set up certificates, base tools, and Consul.
# libc6-compat is needed to symlink the shared libraries for ARM builds
RUN set -eux && \
    apk add --no-cache \
        curl \
        unzip \
        bind-tools \
        net-tools \
        iputils \
        ca-certificates \
        curl \
        dumb-init \
        gnupg \
        libcap \
        openssl \
        su-exec \
        iputils \
        jq \
        libc6-compat && \
    mkdir -p /tmp/build && \
    cd /tmp/build && \
    apkArch="$(apk --print-arch)" && \
    case "${apkArch}" in \
        aarch64) consulArch='arm64' ;; \
        armhf) consulArch='armhfv6' ;; \
        x86) consulArch='386' ;; \
        x86_64) consulArch='amd64' ;; \
        *) echo >&2 "error: unsupported architecture: ${apkArch} (see ${HASHICORP_RELEASES}/consul/${CONSUL_VERSION}/)" && exit 1 ;; \
    esac && \
    wget ${HASHICORP_RELEASES}/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_${consulArch}.zip && \
    wget ${HASHICORP_RELEASES}/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS && \
    wget ${HASHICORP_RELEASES}/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS.sig && \
    unzip -d /bin consul_${CONSUL_VERSION}_linux_${consulArch}.zip && \
    cd /tmp && \
    rm -rf /tmp/build && \
    apk del gnupg openssl && \
    rm -rf /root/.gnupg && \
    rm -rf /var/cache/apk/* && \
    consul version

# The /consul/data dir is used by Consul to store state. The agent will be started
# with /consul/config as the configuration directory so you can add additional
# config files in that location.

WORKDIR /
RUN mkdir -p /consul/data && \
    mkdir -p /consul/config && \
    mkdir -p /consul/tmpl

RUN chown -R consul:consul /consul

# set up nsswitch.conf for Go's "netgo" implementation which is used by Consul,
# otherwise DNS supercedes the container's hosts file, which we don't want.
RUN test -e /etc/nsswitch.conf || echo 'hosts: files dns' > /etc/nsswitch.conf

# Expose the consul data directory as a volume since there's mutable state in there.
VOLUME /consul/data

# Server RPC is used for communication between Consul clients and servers for internal
# request forwarding.
EXPOSE 8300

# Serf LAN and WAN (WAN is used only by Consul servers) are used for gossip between
# Consul agents. LAN is within the datacenter and WAN is between just the Consul
# servers in all datacenters.
EXPOSE 8301 8301/udp 8302 8302/udp

# HTTP and DNS (both TCP and UDP) are the primary interfaces that applications
# use to interact with Consul.
EXPOSE 8500 8600 8600/udp

# Expose DNS port
EXPOSE 53/tcp 53/udp

# Use consul-template to re-write our Nginx virtualhost config
RUN curl -Lo /tmp/consul_template_0.15.0_linux_amd64.zip ${HASHICORP_RELEASES}/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip && \
    unzip /tmp/consul_template_0.15.0_linux_amd64.zip && \
    mv consul-template /bin && \
    rm /tmp/consul_template_0.15.0_linux_amd64.zip

# Install ContainerPilot
RUN export CONTAINERPILOT_CHECKSUM=6da4a4ab3dd92d8fd009cdb81a4d4002a90c8b7c && \
    curl -Lso /tmp/containerpilot.tar.gz "https://github.com/joyent/containerpilot/releases/download/${CONTAINERPILOT_VER}/containerpilot-${CONTAINERPILOT_VER}.tar.gz" && \
    echo "${CONTAINERPILOT_CHECKSUM}  /tmp/containerpilot.tar.gz" | sha1sum -c && \
    tar zxf /tmp/containerpilot.tar.gz -C /bin && \
    rm /tmp/containerpilot.tar.gz

# Copy configuration overlay
WORKDIR /

ADD /registry-agent.sh bin/registry-agent.sh
ADD /registry-events.sh bin/registry-events.sh
ADD /docker-entrypoint.sh bin/docker-entrypoint.sh

ADD containerpilot.json5 /etc/containerpilot.json5

RUN chmod 755 bin/registry-agent.sh
RUN chmod 755 bin/registry-events.sh
RUN chmod 755 bin/docker-entrypoint.sh

ENTRYPOINT ["sh"]
