#!/usr/bin/env sh

curl -o /dev/null --fail -s http://localhost:8200/v1/sys/health || exit 1