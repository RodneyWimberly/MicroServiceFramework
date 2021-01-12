consul keygen
consul tls ca create -domain=em.docker
consul tls cert create -server -dc=dc -domain=em.docker
consul tls cert create -client -dc=dc -domain=em.docker
