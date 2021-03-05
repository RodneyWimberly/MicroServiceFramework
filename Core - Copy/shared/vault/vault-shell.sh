#!/bin/sh

# DESCRIPTION
# Provides an interactive shell to type commands directly into Vault.  The
# session is pre-authenticated with an admin token.

source ./vault-functions.sh
set_vault_addr
set_vault_admin_token
trap 'revoke_self' EXIT

docker-service-exec core_vault "/bin/sh -c 'rm -f entrypoint.sh && echo \"export VAULT_TOKEN="$VAULT_TOKEN" VAULT_ADDR="$VAULT_ADDR"\" >> entrypoint.sh && echo \"/bin/sh\" >> entrypoint.sh && /bin/sh entrypoint.sh'"
