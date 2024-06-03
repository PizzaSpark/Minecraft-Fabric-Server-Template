@echo off
call .\scripts\check_git_status.bat
powershell -ExecutionPolicy Bypass -File .\scripts\start_server.ps1
pause