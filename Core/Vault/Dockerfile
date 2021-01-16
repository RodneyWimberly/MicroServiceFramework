FROM alpine:3.10

# This is the release of Consul, Consul-Template, & Vault to pull in.
ARG VAULT_VERSION=1.6.1
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

RUN set -eux && \
    apk add --no-cache \
        curl \
        unzip \
        bind-tools \
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
    #gpg --keyserver pgp.mit.edu --recv-keys 91A6E7F85D05C65630BEF18951852D87348FFC4C && \
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
    #gpg --batch --verify consul_${CONSUL_VERSION}_SHA256SUMS.sig consul_${CONSUL_VERSION}_SHA256SUMS && \
    #grep consul_${CONSUL_VERSION}_linux_${consulArch}.zip consul_${CONSUL_VERSION}_SHA256SUMS | sha256sum -c && \
    unzip -d /bin consul_${CONSUL_VERSION}_linux_${consulArch}.zip && \
    cd /tmp && \
    rm -rf /tmp/build && \
    #gpgconf --kill all && \
    apk del gnupg openssl && \
    rm -rf /root/.gnupg && \
    rm -rf /var/cache/apk/* && \
    # tiny smoke test to ensure the binary we downloaded runs
    consul version

# The /consul/data dir is used by Consul to store state. The agent will be started
# with /consul/config as the configuration directory so you can add additional
# config files in that location.

WORKDIR /
RUN mkdir -p /consul/data && \
    mkdir -p /consul/config && \
    mkdir -p /consul/tmpl

ADD vault.json consul/config/vault.json
ADD em-agent-ca.pem consul/config/certs/em-agent-ca.pem
ADD docker-client-em-0* consul/config/certs/
RUN chown -R consul:consul /consul

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
#RUN export CONTAINERPILOT_CHECKSUM=6da4a4ab3dd92d8fd009cdb81a4d4002a90c8b7c && \
#    curl -Lso /tmp/containerpilot.tar.gz "https://github.com/joyent/containerpilot/releases/download/${CONTAINERPILOT_VER}/containerpilot-${CONTAINERPILOT_VER}.tar.gz" && \
#    echo "${CONTAINERPILOT_CHECKSUM}  /tmp/containerpilot.tar.gz" | sha1sum -c && \
#    tar zxf /tmp/containerpilot.tar.gz -C /bin && \
#    rm /tmp/containerpilot.tar.gz

# Copy configuration overlay
WORKDIR /

ADD /registry-agent.sh bin/registry-agent.sh
ADD /docker-entrypoint.sh bin/docker-entrypoint.sh

ADD /containerpilot.json5 etc/containerpilot.json5

RUN chmod 755 bin/registry-agent.sh
RUN chmod 755 bin/docker-entrypoint.sh

# Create a vault user and group first so the IDs get set the same way,
# even as the rest of this may change over time.
RUN addgroup vault && \
    adduser -S -G vault vault

# Set up certificates, our base tools, and Vault.
RUN set -eux; \
    apk add --no-cache ca-certificates gnupg openssl libcap su-exec dumb-init tzdata && \
    VAULT_GPGKEY=91A6E7F85D05C65630BEF18951852D87348FFC4C; \
    found=''; \
    for server in \
        hkp://p80.pool.sks-keyservers.net:80 \
        hkp://keyserver.ubuntu.com:80 \
        hkp://pgp.mit.edu:80 \
    ; do \
        echo "Fetching GPG key $VAULT_GPGKEY from $server"; \
        gpg --batch --keyserver "$server" --recv-keys "$VAULT_GPGKEY" && found=yes && break; \
    done; \
    test -z "$found" && echo >&2 "error: failed to fetch GPG key $VAULT_GPGKEY" && exit 1; \
    mkdir -p /tmp/build && \
    cd /tmp/build && \
    wget "$HASHICORP_RELEASES"/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_${consulArch}.zip && \
    wget "$HASHICORP_RELEASES"/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_SHA256SUMS && \
    wget "$HASHICORP_RELEASES"/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_SHA256SUMS.sig && \
    gpg --batch --verify vault_${VAULT_VERSION}_SHA256SUMS.sig vault_${VAULT_VERSION}_SHA256SUMS && \
    grep vault_${VAULT_VERSION}_linux_${consulArch}.zip vault_${VAULT_VERSION}_SHA256SUMS | sha256sum -c && \
    unzip -d /bin vault_${VAULT_VERSION}_linux_${consulArch}.zip && \
    cd /tmp && \
    rm -rf /tmp/build && \
    gpgconf --kill dirmngr && \
    gpgconf --kill gpg-agent && \
    apk del gnupg openssl && \
    rm -rf /root/.gnupg

# /vault/logs is made available to use as a location to store audit logs, if
# desired; /vault/file is made available to use as a location with the file
# storage backend, if desired; the server will be started with /vault/config as
# the configuration directory so you can add additional config files in that
# location.
RUN mkdir -p /vault/logs && \
    mkdir -p /vault/file && \
    mkdir -p /vault/config && \
    chown -R vault:vault /vault

# Expose the logs directory as a volume since there's potentially long-running
# state in there
VOLUME /vault/logs

# Expose the file directory as a volume since there's potentially long-running
# state in there
VOLUME /vault/file

# 8200/tcp is the primary interface that applications use to interact with
# Vault.
EXPOSE 8200 8201

# The entry point script uses dumb-init as the top-level process to reap any
# zombie processes created by Vault sub-processes.
#
# For production derivatives of this container, you shoud add the IPC_LOCK
# capability so that Vault can mlock memory.
COPY ./root/bin/docker-entrypoint.sh /bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

# By default you'll get a single-node development server that stores everything
# in RAM and bootstraps itself. Don't use this configuration for production.
CMD [ "server", "-config=/vault/config" ]
