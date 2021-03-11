#!/usr/bin/env sh

ps -ef | grep -v grep | grep -e agent || exit 1