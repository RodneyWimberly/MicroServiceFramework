#!/bin/bash
set -ueo pipefail
set +x

cd ~ || exit 1
rm -fr ~/msf
mkdir ~/msf