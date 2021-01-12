@echo off
call Stop-EventManager.Logs.cmd
echo ----------------------------------------------------------------------------------------------------
echo Starting Docker Compose project eventmanager-logs
echo ----------------------------------------------------------------------------------------------------
set DOCKER_COMPOSE=docker-compose -p eventmanager-logs --logs-level INFO
%DOCKER_COMPOSE% config
%DOCKER_COMPOSE% build --parallel --force-rm --pull --progress auto
%DOCKER_COMPOSE% up --force-recreate --remove-orphans --detach
call ViewLogs-EventManager.Logs.cmd
