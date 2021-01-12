@echo off
cls
call Stop-EventManager.Logs.cmd
echo ----------------------------------------------------------------------------------------------------
echo Removing Docker eventmanager-logs Images
echo ----------------------------------------------------------------------------------------------------
docker image prune --all --force