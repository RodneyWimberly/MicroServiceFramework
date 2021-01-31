@echo off
SET CORE_DIR=d:\em\core

echo  ---> Making links for Consul
mklink /H %CORE_DIR%\consul\consul-agent-ca.pem %CORE_DIR%\shared\certs\consul-agent-ca.pem
mklink /H %CORE_DIR%\consul\docker-client-consul-0.pem %CORE_DIR%\shared\certs\docker-client-consul-0.pem
mklink /H %CORE_DIR%\consul\docker-client-consul-0-key.pem %CORE_DIR%\shared\certs\docker-client-consul-0-key.pem
mklink /H %CORE_DIR%\consul\docker-server-consul-0.pem %CORE_DIR%\shared\certs\docker-server-consul-0.pem
mklink /H %CORE_DIR%\consul\docker-server-consul-0-key.pem %CORE_DIR%\shared\certs\docker-server-consul-0-key.pem
mklink /H %CORE_DIR%\consul\.dockerignore d:\em\.dockerignore
mklink /H %CORE_DIR%\consul\core.env %CORE_DIR%\shared\config\core.env
mklink /H %CORE_DIR%\consul\common-functions.sh %CORE_DIR%\shared\scripts\common-functions.sh

echo  ---> Making links for DNS
mklink /H %CORE_DIR%\dns\.dockerignore d:\em\.dockerignore
mklink /H %CORE_DIR%\dns\core.env %CORE_DIR%\shared\config\core.env
mklink /H %CORE_DIR%\dns\common-functions.sh %CORE_DIR%\shared\scripts\common-functions.sh

echo ---> Making links for Vault
mklink /H %CORE_DIR%\vault\consul-agent-ca.pem %CORE_DIR%\shared\certs\consul-agent-ca.pem
mklink /H %CORE_DIR%\vault\docker-client-consul-0.pem %CORE_DIR%\shared\certs\docker-client-consul-0.pem
mklink /H %CORE_DIR%\vault\docker-client-consul-0-key.pem %CORE_DIR%\shared\certs\docker-client-consul-0-key.pem
mklink /H %CORE_DIR%\vault\docker-server-consul-0.pem %CORE_DIR%\shared\certs\docker-server-consul-0.pem
mklink /H %CORE_DIR%\vault\docker-server-consul-0-key.pem %CORE_DIR%\shared\certs\docker-server-consul-0-key.pem
mklink /H %CORE_DIR%\vault\.dockerignore d:\em\.dockerignore
mklink /H %CORE_DIR%\vault\core.env %CORE_DIR%\shared\config\core.env
mklink /H %CORE_DIR%\vault\common-functions.sh %CORE_DIR%\shared\scripts\common-functions.sh
