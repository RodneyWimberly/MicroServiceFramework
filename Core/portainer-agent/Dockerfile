FROM portainer/agent:linux-amd64-2.1.0-alpine


# Label the image
LABEL Author microserviceframework
LABEL Name portainer-agent

ENV AGENT_CLUSTER_ADDR=tasks.core_portainer-agent:9001

# Install updates and common tools
RUN set -x && \
    apk update && \
    apk add --no-cache \
        curl \
        bind-tools \
        jq \
        gettext

COPY ./core.env /usr/local/scripts/core.env
COPY ./*.sh /usr/local/scripts/
COPY ./consul-service.json /etc/templates/consul-service.json
RUN chmod 755 /usr/local/scripts/*.sh

ENTRYPOINT ["/usr/local/scripts/portainer-agent-entrypoint.sh"]
