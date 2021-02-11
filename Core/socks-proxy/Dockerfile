FROM yarmak/socks5-server

# Label the image
LABEL Author microserviceframework
LABEL Name socks-proxy

# Set proxy user (also required existed PROXY_PASS)
ENV PROXY_USER=user
# Set proxy password for auth, used with PROXY_USER
ENV PROXY_PASSWORD=password
# Set listen address for application
ENV PROXY_ADDRESS=
# Set listen port for application
ENV PROXY_PORT=1080
# If set, enable TLS and use certificate from specified file
ENV PROXY_TLS_CERT=
# Key file for certificate specified in PROXY_TLS_CERT
ENV PROXY_TLS_KEY=
# If set, enable mutual TLS authentication and verify client certificates against CAs specified in CACERT
ENV PROXY_TLS_CACERT=

# Install updates and common tools
# RUN set -x && \
#     apk update && \
#     apk add --no-cache \
#         curl \
#         bind-tools \
#         unzip \
#         jq \
#         gettext

COPY ./core.env /usr/local/scripts/core.env
COPY ./*.sh /usr/local/scripts/
COPY ./consul-service.json /etc/templates/consul-service.json
RUN chmod 755 /usr/local/scripts/*.sh

ENTRYPOINT ["/usr/local/scripts/socks-proxy-entrypoint.sh"]
