#!/usr/bin/env sh

dig +short @"$STATIC_IP" > /dev/null || exit 1
