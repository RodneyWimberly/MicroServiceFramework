cat > /etc/docker/daemon.json <<EOL
{
    "experimental": true,
    "debug": true,
    "log-level": "info",
    "insecure-registries": ["127.0.0.1"],
    "hosts": ["unix:///var/run/docker.sock", "tcp://0.0.0.0:2375"],
    "tls": false,
    "tlscacert": "",
    "tlscert": "",
    "tlskey": "",
    "dns": [ "127.0.0.1", "169.254.1.1", "8.8.8.8"]
}
EOL
apk add screen git gettext curl jq
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
echo "192.168.0.8 worker1" >> /etc/hosts
echo "192.168.0.7 manager1" >> /etc/hosts
# sudo ip link add dummy0 type dummy
# sudo ip link set dev dummy0 up
# sudo ip addr add 169.254.1.1/32 dev dummy0
# sudo ip link set dev dummy0 up
echo "caption always \"%{= kc}Screen session %S on %H %-20=%{= .m}%D %d.%m.%Y %0c\"" > ~/.screenrc
screen -q -t stack-deployment -S stack-deployment
