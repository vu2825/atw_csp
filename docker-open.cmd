@echo off
setlocal

cd /d "%~dp0"

echo [1/3] Rebuilding and starting containers...
docker compose up --build -d
if errorlevel 1 goto :error

echo [2/3] Opening browser...
start "" "http://localhost:8080/"

echo [3/3] Showing app logs...
docker compose logs -f app
goto :eof

:error
echo Docker compose failed.
exit /b 1
