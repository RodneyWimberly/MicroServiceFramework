#
# Elasticsearch Dockerfile
#
# https://github.com/dockerfile/elasticsearch
#

# Pull base image.
FROM docker.elastic.co/elasticsearch/elasticsearch-oss:7.10.2
#openjdk:8-jre-slim-buster
# dockerfile/java:oracle-java8

RUN yum update --setopt=tsflags=nodocs -y && \
    yum install --setopt=tsflags=nodocs -y  \
        curl \
        jq \
        iputils \
        iproute \
        bind-utils \
        gettext \
        gawk \
        wget \
        bash &&  \
    yum clean all

# Add Tini
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/local/bin/tini
RUN chmod +x /usr/local/bin/tini

RUN mkdir /usr/local/scripts 

COPY ./*.env /usr/local/scripts/
COPY ./*.sh /usr/local/scripts/
COPY ./consul-service.json /etc/templates/consul-service.json
RUN chmod 755 /usr/local/scripts/*.sh

# Define default command.
ENTRYPOINT ["/usr/local/bin/tini", "--"]
CMD ["/usr/local/scripts/entrypoint.sh", "eswrapper"]

# Expose ports.
#   - 9200: HTTP
#   - 9300: transport
EXPOSE 9200
EXPOSE 9300

HEALTHCHECK \
    --interval=30s \
    --timeout=30s \
    --retries=10 \
    --start-period=30s \
    CMD /usr/local/scripts/health-check.sh

# Label the image
LABEL maintainer="microserviceframework <hello@microserviceframework.com>" \
    org.label-schema.name="Elasticsearch" \
    org.label-schema.description="MicroServices Framework Elasticsearch Docker Image" \
    org.label-schema.vcs-url="https://github.com/RodneyWimberly/MicroServiceFramework" \
    org.label-schema.vendor="microserviceframework" \
    org.label-schema.version="1.0" \
    org.label-schema.schema-version="1.0"

