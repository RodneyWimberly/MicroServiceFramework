#!/usr/bin/dumb-init /bin/sh
set +e
echo "Creating dnsmasq.conf configuration template"
echo '# Enable forward lookup of the em domain:' >> /etc/dnsmasq/em.conf
echo 'server=/em/127.0.0.1#8600' >> /etc/dnsmasq/em.conf
echo ' ' >> /etc/dnsmasq/em.conf
echo '# Uncomment and modify as appropriate to enable reverse DNS lookups for' >> /etc/dnsmasq/em.conf
echo '# common netblocks found in RFC 1918, 5735, and 6598:' >> /etc/dnsmasq/em.conf
echo '#rev-server=0.0.0.0/8,127.0.0.1#8600' >> /etc/dnsmasq/em.conf
echo '#rev-server=10.0.0.0/8,127.0.0.1#8600' >> /etc/dnsmasq/em.conf
echo '#rev-server=100.64.0.0/10,127.0.0.1#8600' >> /etc/dnsmasq/em.conf
echo '#rev-server=127.0.0.1/8,127.0.0.1#8600' >> /etc/dnsmasq/em.conf
echo '#rev-server=169.254.0.0/16,127.0.0.1#8600' >> /etc/dnsmasq/em.conf
echo '#rev-server=172.16.0.0/12,127.0.0.1#8600' >> /etc/dnsmasq/em.conf
echo '#rev-server=192.168.0.0/16,127.0.0.1#8600' >> /etc/dnsmasq/em.conf
echo '#rev-server=224.0.0.0/4,127.0.0.1#8600' >> /etc/dnsmasq/em.conf
echo '#rev-server=240.0.0.0/4,127.0.0.1#8600' >> /etc/dnsmasq/em.conf
#echo '{{range service "registry-leader"}}server=/em/{{.Address}}' >> /tmp/dnsmasq.tpl
#echo '{{end}}' >> /tmp/dnsmasq.tpl

#echo "Starting service registry agent"
#registry-agent.sh
#--template-file-reload /tmp/dnsmasq.tpl dnsmasq.tpl /etc/dnsmasq/em.conf "consul lock -name=service/dns -shell=false restart killall dnsmasq"

echo "Starting dnsmasq service"
exec dnsmasq "$@"
