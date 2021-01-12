@echo off
echo ----------------------------------------------------------------------------------------------------
echo Stopping Docker Compose project eventmanager-logs
echo ----------------------------------------------------------------------------------------------------
set DOCKER_COMPOSE=docker-compose -p eventmanager-logs --logs-level INFO
%DOCKER_COMPOSE% kill
%DOCKER_COMPOSE% down --rmi local --remove-orphans
