#!/bin/sh

source ./vault-functions.sh

set_vault_admin_token

for x in policies/*.hcl; do
  policy="${x##*/}"
  policy="${policy%.hcl}"
  execute_vault_command policy write "${policy}" - < "${x}"
done

revoke_self
