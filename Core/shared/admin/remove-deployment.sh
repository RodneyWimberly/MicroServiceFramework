#!/bin/bash


# Setup environment
# Ignore non existent vars
# set -u
set -o nounset
# Terminate on command error
# set -e
set -o errexit
# Apply -e to pipe commands
set -o pipefail
# Output commands
# set -x
# set -oxtrace

cd ~ || exit 1
rm -fr ~/msf
mkdir ~/msf