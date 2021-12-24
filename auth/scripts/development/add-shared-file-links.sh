#!/bin/bash
set -ueo pipefail
set +x

# shellcheck source=../../../shared/scripts/development-functions.sh
. /mnt/d/msf/shared/scripts/development-functions.sh

log_header "auth: Creating file links for shared files."

link_file "$MSF_DIR"/.gitignore "$AUTH_DIR"/.gitignore
link_file "$MSF_DIR"/.dockerignore "$AUTH_DIR"/.dockerignore

log_header "Making links for Deployment"
link_file "$AUTH_DIR"/scripts/auth.env "$AUTH_DIR"/scripts/deployment/package/auth.env
link_file "$AUTH_DIR"/scripts/deployment/deploy-auth-stack.sh "$AUTH_DIR"/scripts/deployment/package/deploy-auth-stack.sh
link_file "$AUTH_DIR"/docker-compose.yml "$AUTH_DIR"/scripts/deployment/package/docker-compose.yml
link_file "$AUTH_DIR"/scripts/auth-functions.sh "$AUTH_DIR"/scripts/deployment/package/auth-functions.sh
link_file "$SHARED_CONFIG"/resolv.conf "$AUTH_DIR"/scripts/deployment/package/resolv.conf
link_file "$SHARED_CONFIG"/dhclient.conf "$AUTH_DIR"/scripts/deployment/package/dhclient.conf

log_header "Making links for auth-db"
link_file "$MSF_DIR"/.dockerignore "$AUTH_DIR"/auth-db/.dockerignore
link_file "$AUTH_DIR"/scripts/auth.env "$AUTH_DIR"/auth-db/auth.env
link_file "$AUTH_DIR"/scripts/auth-functions.sh "$AUTH_DIR"/auth-db/auth-functions.sh
link_common_functions "$AUTH_DIR"/auth-db

log_header "Making links for auth-sts"
link_file "$MSF_DIR"/.dockerignore "$AUTH_DIR"/auth-sts/.dockerignore
link_file "$AUTH_DIR"/scripts/auth.env "$AUTH_DIR"/auth-sts/auth.env
link_file "$AUTH_DIR"/scripts/auth-functions.sh "$AUTH_DIR"/auth-sts/auth-functions.sh
link_common_functions "$AUTH_DIR"/auth-sts

log_header "Making links for auth-admin"
link_file "$MSF_DIR"/.dockerignore "$AUTH_DIR"/auth-admin/.dockerignore
link_file "$AUTH_DIR"/scripts/auth.env "$AUTH_DIR"/auth-admin/auth.env
link_file "$AUTH_DIR"/scripts/auth-functions.sh "$AUTH_DIR"/auth-admin/auth-functions.sh
link_common_functions "$AUTH_DIR"/auth-admin

log_header "Making links for auth-api"
link_file "$MSF_DIR"/.dockerignore "$AUTH_DIR"/auth-api/.dockerignore
link_file "$AUTH_DIR"/scripts/auth.env "$AUTH_DIR"/auth-api/auth.env
link_file "$AUTH_DIR"/scripts/auth-functions.sh "$AUTH_DIR"/auth-api/auth-functions.sh
link_common_functions "$AUTH_DIR"/auth-api

