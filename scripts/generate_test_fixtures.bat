@echo off

:: Use the known Git Bash path
set "GIT_BASH=C:\Program Files\Git\git-bash.exe"

if not exist "%GIT_BASH%" (
    echo Git Bash not found at %GIT_BASH%!
    exit /b 1
)

:: Get the directory containing this batch file
set "SCRIPT_DIR=%~dp0"
:: Get the project root directory (parent of scripts)
set "PROJECT_DIR=%SCRIPT_DIR%.."

:: Change to project directory and execute the shell script using Git Bash
cd "%PROJECT_DIR%"
start /wait "" "%GIT_BASH%" "./scripts/generate_test_fixtures.sh"
exit /b %ERRORLEVEL% 