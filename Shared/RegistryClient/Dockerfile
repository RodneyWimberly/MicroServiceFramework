# RegistryClient (AspNetCore runtime, ContainerPilot & Consul Client Agent using AutoPilot pattern) Container.
# 
# Intended to be base for all AspNetCore services to auto provide service registration, health checks, 
# de-registration, participate in both the gossip and consensus protocols, and provide centralized configuration
# based on Docker, Linux, and AspNetCore services
FROM mcr.microsoft.com/dotnet/aspnet:5.0-buster-slim AS aspnet-core-base
MAINTAINER rodney.wimberly@gmail.com

# Setup Runtime Environment Vars
ENV CONSUL_VERSION 1.9.0
ENV CONSUL_URL https://releases.hashicorp.com/consul
ENV CONSUL_BIND_INTERFACE eth0
ENV CONSUL_CLIENT_INTERFACE eth0
ENV CONSUL_CACERT /etc/consul.d/em.docker-agent-ca.pem
ENV CONSUL_CLIENT_CERT /etc/consul.d/dc-client-em.docker-0.pem
ENV CONSUL_CLIENT_KEY /etc/consul.d/dc-client-em.docker-0-key.pem
ENV CONTAINERPILOT_VER 3.0.0
ENV CONTAINERPILOT /etc/containerpilot.json5


# Update environment
RUN apk update && \
    apk --no-cache add curl ca-certificates

# Install Consul
RUN curl --silent --remote-name ${CONSUL_URL}/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip && \
    curl --silent --remote-name ${CONSUL_URL}/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS && \
    curl --silent --remote-name ${CONSUL_URL}/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS.sig && \
    unzip consul_${CONSUL_VERSION}_linux_amd64.zip && \
    mv consul /bin/ && \
    consul --version
COPY root/etc/consul.d/. /etc/consul.d/.

# Install ContainerPilot
RUN export CONTAINERPILOT_CHECKSUM=6da4a4ab3dd92d8fd009cdb81a4d4002a90c8b7c && \
    curl -Lso /tmp/containerpilot.tar.gz "https://github.com/joyent/containerpilot/releases/download/${CONTAINERPILOT_VER}/containerpilot-${CONTAINERPILOT_VER}.tar.gz" && \
    echo "${CONTAINERPILOT_CHECKSUM}  /tmp/containerpilot.tar.gz" | sha1sum -c && \
    tar zxf /tmp/containerpilot.tar.gz -C /bin && \
    rm /tmp/containerpilot.tar.gz
COPY containerpilot.json5 /etc/containerpilot.json5
ENV CONTAINERPILOT=/etc/containerpilot.json5

# Setup EntryPoint
WORKDIR /
EXPOSE 80
CMD ["/bin/containerpilot"]
