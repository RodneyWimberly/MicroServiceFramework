sudo ip link add dummy0 type dummy
sudo ip link set dev dummy0 up
ip link show type dummy

sudo ip addr add 169.254.1.1/32 dev dummy0
sudo ip link set dev dummy0 up
ip addr show dev dummy0

apk add systemd-networkd
sudo systemctl restart systemd-networkd

{
  "client_addr": "169.254.1.1",
  "bind_addr": "HOST_IP_ADDRESS"
}

server=/consul/169.254.1.1#8600
listen-address=127.0.0.1
listen-address=169.254.1.1

dns 169.254.1.1 \
              -e CONSUL_HTTP_ADDR=169.254.1.1:8500 \
              -e CONSUL_RPC_ADDR=169.254.1.1:8400 ...

              # /etc/environment
CONSUL_HTTP_ADDR=169.254.1.1:8500
CONSUL_RPC_ADDR=169.254.1.1:8400

https://medium.com/zendesk-engineering/making-docker-and-consul-get-along-5fceda1d52b9
