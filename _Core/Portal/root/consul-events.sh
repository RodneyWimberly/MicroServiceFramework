#!/bin/sh

# Render Nginx configuration template using values from Consul,
# but do not reload because Nginx has't started yet
onStart() {
    consul-template \
        -once \
        -consul localhost:8500 \
        -template "/consul/tmp/index.html:/usr/share/nginx/html/index.html"
    consul-template \
        -once \
        -consul localhost:8500 \
        -template "/consul/tmp/nginx.conf:/etc/nginx/conf.d/default.conf"
}

# Render Nginx configuration template using values from Consul,
# then gracefully reload Nginx
onChange() {
    consul-template \
        -once \
        -consul localhost:8500 \
        -template "/consul/tmp/index.html:/usr/share/nginx/html/index.html"
    consul-template \
        -once \
        -consul localhost:8500 \
        -template "/consul/tmp/nginx.conf:/etc/nginx/conf.d/default.conf:consul lock -name service/portal -shell=false reload nginx -s reload"
}

until
    cmd=$1
    if [ -z "$cmd" ]; then
        onChange
    fi
    shift 1
    $cmd "$@"
    [ "$?" -ne 127 ]
do
    onChange
    exit
done
