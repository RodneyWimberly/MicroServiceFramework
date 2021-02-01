FROM nginx

# Label the image
LABEL Author rodneywimberly
LABEL Name portal

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
        vim \
        gettext

# Set Environment Vars
ENV CONSUL_VERSION 1.9.1
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
    mkdir /etc/templates

COPY ./core.env /usr/local/scripts/core.env
COPY ./*.sh /usr/local/scripts/
COPY ./nginx.conf /etc/templates/nginx.conf
COPY ./index.html /etc/templates/index.html
COPY ./.vimrc /.vimrc
COPY ./stylesheet.css /usr/share/nginx/html/stylesheet.css
#COPY ./.crt usr/local/share/ca-certificates/.crt
RUN chmod 755 /usr/local/scripts/*.sh

ENTRYPOINT ["/usr/local/scripts/portal-entrypoint.sh"]
CMD [ "-g", "'daemon off;'" ]
