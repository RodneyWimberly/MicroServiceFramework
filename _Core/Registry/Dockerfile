# registry-leader (ContainerPilot & Consul Server Agent / Leader using AutoPilot pattern) Container
FROM consul
LABEL Author rodneywimberly
LABEL Name registry-leader-leader
LABEL Version 1.0

# Update environment
RUN apk update

WORKDIR /
RUN mkdir -p /consul/data && \
    mkdir -p /consul/config/certs && \
    mkdir -p /consul/tmpl

# COPY configuration

RUN chown -R consul:consul /consul

# Consul doesn't need root privileges so we run it as the consul user from the
# entry point script. The entry point script also uses dumb-init as the top-level
# process to reap any zombie processes created by Consul sub-processes.
ENTRYPOINT ["docker-entrypoint.sh"]

# By default you'll get an insecure single-node development server that stores
# everything in RAM, exposes a web UI and HTTP endpoints, and bootstraps itself.
# Don't use this configuration for production.
CMD ["agent", "-data-dir=/consul/data", "-config-dir=/consul/config"]
