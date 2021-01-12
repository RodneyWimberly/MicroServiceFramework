@echo off

echo ----------------------------------------------------------------------------------------------------
echo Docker Compose project eventmanager-logs Logs
echo ----------------------------------------------------------------------------------------------------
set DOCKER_COMPOSE=docker-compose -p eventmanager-logs --logs-level INFO
%DOCKER_COMPOSE% logs --follow
