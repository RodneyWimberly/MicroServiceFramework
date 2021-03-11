FROM alpine:3.12

LABEL maintainer="MicroServices Framework <hello@microserviceframework.com>" \
    org.label-schema.name="Portal" \
    org.label-schema.description="MicroServices Framework Portal Docker Image" \
    org.label-schema.vcs-url="https://github.com/RodneyWimberly/MicroServiceFramework" \
    org.label-schema.vendor="microserviceframework" \
    org.label-schema.version="1.0" \
    org.label-schema.schema-version="1.0"

# Install updates, nginx, and common tools
RUN set -x && \
    apk update && \
    apk add --no-cache \
        curl \
        bind-tools \
        unzip \
        jq \
        ca-certificates \
        procps \
        less \
        vim \
        nginx \
        gettext && \
        mkdir /run/nginx

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

RUN mkdir /usr/local/scripts && \
    mkdir /etc/templates && \
    chown -R nginx:nginx /etc/nginx && \
    chown -R nginx:nginx /usr/local/scripts && \
    chown -R nginx:nginx /etc/templates && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /run/nginx

COPY ./*.env /usr/local/scripts/
COPY ./*.sh /usr/local/scripts/
COPY ./*.conf /etc/templates/
COPY ./consul-service.json /etc/templates/consul-service.json
COPY ./index.html /etc/templates/index.html
COPY ./.vimrc /.vimrc
COPY ./stylesheet.css /usr/share/nginx/html/stylesheet.css
#COPY ./.crt usr/local/share/ca-certificates/.crt
RUN chmod 755 /usr/local/scripts/*.sh

ENTRYPOINT ["/usr/local/scripts/entrypoint.sh"]

HEALTHCHECK \
    --interval=30s \
    --timeout=30s \
    --retries=10 \
    --start-period=30s \
    CMD /usr/local/scripts/health-check.sh
