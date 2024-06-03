@echo off
powershell -ExecutionPolicy Bypass -File .\scripts\check_git_status.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\start_server.ps1
pause