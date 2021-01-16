FROM mhart/alpine-node
LABEL Author rodneywimberly
LABEL Name world
LABEL Version 1.0

# Install updates and common tools
RUN apk update && \
    apk add curl bind-tools unzip && \
    rm -rf /var/cache/apk/*

# Set EnvironmentVars
ENV CONTAINERPILOT_VER 3.0.0
ENV CONTAINERPILOT /etc/containerpilot.json5

# Install ContainerPilot
RUN export CONTAINERPILOT_CHECKSUM=6da4a4ab3dd92d8fd009cdb81a4d4002a90c8b7c && \
    curl -Lso /tmp/containerpilot.tar.gz "https://github.com/joyent/containerpilot/releases/download/${CONTAINERPILOT_VER}/containerpilot-${CONTAINERPILOT_VER}.tar.gz" && \
    echo "${CONTAINERPILOT_CHECKSUM}  /tmp/containerpilot.tar.gz" | sha1sum -c && \
    tar zxf /tmp/containerpilot.tar.gz -C /bin && \
    rm /tmp/containerpilot.tar.gz

# Copy configuration
COPY root/. /.

# Install our application
COPY index.js /opt/world/

EXPOSE 3002
CMD ["/bin/containerpilot"]
