@echo off
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File package.ps1
pause