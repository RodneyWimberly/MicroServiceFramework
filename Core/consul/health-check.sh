#!/usr/bin/env sh

curl -o /dev/null --fail -s http://127.0.0.1:8500/v1/catalog/services || exit 0