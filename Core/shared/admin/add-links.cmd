@echo off
SET MSF_DIR=d:\em
SET CORE_DIR=%MSF_DIR%\core

echo  --- Making links for Core stack
mklink /H %CORE_DIR%\.gitignore d:\em\.gitignore
mklink /H %CORE_DIR%\.dockerignore d:\em\.dockerignore

echo  --- Making links for Consul
mklink /H %CORE_DIR%\consul\consul-agent-ca.pem %CORE_DIR%\shared\certs\consul-agent-ca.pem
mklink /H %CORE_DIR%\consul\docker-client-consul-0.pem %CORE_DIR%\shared\certs\docker-client-consul-0.pem
mklink /H %CORE_DIR%\consul\docker-client-consul-0-key.pem %CORE_DIR%\shared\certs\docker-client-consul-0-key.pem
mklink /H %CORE_DIR%\consul\docker-server-consul-0.pem %CORE_DIR%\shared\certs\docker-server-consul-0.pem
mklink /H %CORE_DIR%\consul\docker-server-consul-0-key.pem %CORE_DIR%\shared\certs\docker-server-consul-0-key.pem
mklink /H %CORE_DIR%\consul\.dockerignore %MSF_DIR%\.dockerignore
mklink /H %CORE_DIR%\consul\core.env %CORE_DIR%\shared\scripts\core.env
mklink /H %CORE_DIR%\consul\common-functions.sh %CORE_DIR%\shared\scripts\common-functions.sh

echo  --- Making links for DNS
mklink /H %CORE_DIR%\dns\.dockerignore %MSF_DIR%\.dockerignore
mklink /H %CORE_DIR%\dns\core.env %CORE_DIR%\shared\scripts\core.env
mklink /H %CORE_DIR%\dns\common-functions.sh %CORE_DIR%\shared\scripts\common-functions.sh

echo  --- Making links for Portal
mklink /H %CORE_DIR%\portal\.dockerignore %MSF_DIR%\.dockerignore
mklink /H %CORE_DIR%\portal\core.env %CORE_DIR%\shared\scripts\core.env
mklink /H %CORE_DIR%\portal\common-functions.sh %CORE_DIR%\shared\scripts\common-functions.sh

echo --- Making links for Vault
mklink /H %CORE_DIR%\vault\consul-agent-ca.pem %CORE_DIR%\shared\certs\consul-agent-ca.pem
mklink /H %CORE_DIR%\vault\docker-client-consul-0.pem %CORE_DIR%\shared\certs\docker-client-consul-0.pem
mklink /H %CORE_DIR%\vault\docker-client-consul-0-key.pem %CORE_DIR%\shared\certs\docker-client-consul-0-key.pem
mklink /H %CORE_DIR%\vault\docker-server-consul-0.pem %CORE_DIR%\shared\certs\docker-server-consul-0.pem
mklink /H %CORE_DIR%\vault\docker-server-consul-0-key.pem %CORE_DIR%\shared\certs\docker-server-consul-0-key.pem
mklink /H %CORE_DIR%\vault\.dockerignore %MSF_DIR%\.dockerignore
mklink /H %CORE_DIR%\vault\core.env %CORE_DIR%\shared\scripts\core.env
mklink /H %CORE_DIR%\vault\common-functions.sh %CORE_DIR%\shared\scripts\common-functions.sh
