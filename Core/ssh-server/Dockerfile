FROM php:7.3-apache
ARG SSH_PASS=P@55w0rd

LABEL Author microserviceframework
LABEL Name ssh-server

RUN apt-get -y update && \
  apt-get -y --no-install-recommends install --fix-missing openssh-server && \
  rm -rf /var/lib/apt/lists/*

COPY ./*.env /usr/local/scripts/
COPY ./*.sh /usr/local/scripts/
COPY ./consul-service.json /etc/templates/consul-service.json
COPY ./sshd_config /etc/ssh/sshd_config

RUN useradd -m -s /bin/bash -p $(openssl passwd -1 $SSH_PASS) webssh && \
  usermod -g www-data webssh && \
  usermod -a -G www-data,root root && \
  chown -R :www-data /var/www/html && \
  chmod 755 /usr/local/scripts/*.sh

ENTRYPOINT ["/usr/local/scripts/ssh-server-entrypoint.sh"]
