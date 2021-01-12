# registry-leader (ContainerPilot & Consul Server Agent / Leader using AutoPilot pattern) Container
FROM consul
LABEL Author rodneywimberly
LABEL Name registry-leader-leader
LABEL Version 1.0

# Setup runtime environment vars
ENV CONSUL_BIND_INTERFACE eth0
ENV CONSUL_CAPATH /consul/config/certs
ENV CONSUL_CACERT /consul/config/certs/em.docker-agent-ca.pem
ENV CONSUL_CLIENT_CERT /consul/config/certs/dc-server-em.docker-0.pem
ENV CONSUL_CLIENT_KEY /consul/config/certs/dc-server-em.docker-0-key.pem
ENV SERVICE_NAME registry-leader
ENV VIRTUAL_HOST registry-leader-node.service.em.docker

# Update environment
RUN apk update

# Ensure consul dirs are created
RUN mkdir -p /consul/data && \
    mkdir -p /consul/config

# COPY configuration
COPY root/consul/. /consul/.

# Consul doesn't need root privileges so we run it as the consul user from the
# entry point script. The entry point script also uses dumb-init as the top-level
# process to reap any zombie processes created by Consul sub-processes.
ENTRYPOINT ["docker-entrypoint.sh"]

# By default you'll get an insecure single-node development server that stores
# everything in RAM, exposes a web UI and HTTP endpoints, and bootstraps itself.
# Don't use this configuration for production.
CMD ["agent", "-data-dir=/consul/data", "-config-dir=/consul/config"]