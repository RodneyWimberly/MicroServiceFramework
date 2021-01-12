@echo off
echo ----------------------------------------------------------------------------------------------------
echo Docker Compose project eventmanager-logs Events
echo ----------------------------------------------------------------------------------------------------
set DOCKER_COMPOSE=docker-compose -p eventmanager-logs --logs-level INFO
%DOCKER_COMPOSE% events
