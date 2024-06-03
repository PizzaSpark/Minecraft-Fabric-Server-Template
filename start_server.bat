@echo off
setlocal

:: Load configuration
for /f "tokens=1,2 delims==" %%a in (config.txt) do (
    if "%%a"=="version" set "VERSION=%%b"
    if "%%a"=="allocated_ram" set "ALLOCATED_RAM=%%b"
    if "%%a"=="check_for_updates" set "CHECK_FOR_UPDATES=%%b"
)

:: Function to download the latest PaperMC jar
call :download_latest_paper

:: Start the server
call :run_server
goto :EOF

:download_latest_paper
if /I "%CHECK_FOR_UPDATES%"=="true" (
    :: Create a directory for the server if it doesn't exist
    if not exist "papermc_server" mkdir papermc_server
    cd papermc_server

    :: Download the specified PaperMC build
    echo Checking and downloading PaperMC build version %VERSION%...
    powershell -Command "(New-Object Net.WebClient).DownloadFile('https://papermc.io/api/v2/projects/paper/versions/%VERSION%', 'version_builds.json')"
    for /f "tokens=* delims=" %%a in ('powershell -Command "(Get-Content version_builds.json | ConvertFrom-Json).builds[-1]"') do set LATEST_BUILD=%%a

    if exist "paper.jar" (
        :: Check if the downloaded build matches the local build
        for /f "tokens=*" %%a in ('powershell -Command "(New-Object -TypeName System.IO.FileInfo -ArgumentList 'paper.jar').VersionInfo.FileVersion"') do set LOCAL_BUILD=%%a
    ) else (
        set LOCAL_BUILD=0
    )

    if not "%LOCAL_BUILD%"=="%LATEST_BUILD%" (
        powershell -Command "(New-Object Net.WebClient).DownloadFile('https://papermc.io/api/v2/projects/paper/versions/%VERSION%/builds/%LATEST_BUILD%/downloads/paper-%VERSION%-%LATEST_BUILD%.jar', 'paper.jar')"
        echo Download complete: paper-%VERSION%-%LATEST_BUILD%.jar
    ) else (
        echo PaperMC build version %VERSION% is up to date.
    )

    :: Clean up
    del version_builds.json
    cd..
)
goto :EOF

:run_server
cd papermc_server

:: Run the server with specified memory allocation
java -Xmx%ALLOCATED_RAM%G -Xms%ALLOCATED_RAM%G -jar paper.jar --nogui

cd..
goto :EOF

endlocal
pause
