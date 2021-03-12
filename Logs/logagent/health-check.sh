#!/usr/bin/env sh

ps -ef | grep -v grep | grep -e logagent || exit 1