@echo off
cd /d "%~dp0"
title Miramee GitHub Pages Publisher
echo ========================================================
echo   Miramee GitHub Pages Publisher
echo ========================================================
echo.
echo The setup window will remain open so that you can see
echo progress messages and any errors.
echo.
call "%~dp0setup-and-publish.bat"
echo.
echo The process has ended. Review the message above.
pause
