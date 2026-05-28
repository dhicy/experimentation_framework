@echo off
REM ============================================================
REM Run Web Tests - Indodax Automation (Windows)
REM ============================================================

echo ============================================
echo   INDODAX WEB AUTOMATION RUNNER
echo ============================================

if not exist "web\reports\screenshots" mkdir "web\reports\screenshots"

SET BROWSER=chromium
SET HEADLESS=False
SET TAG=
SET TEST_FILE=web\tests\

echo Browser: %BROWSER%
echo Running: %TEST_FILE%
echo.

robot ^
    --outputdir web\reports ^
    --variable BROWSER:%BROWSER% ^
    --variable HEADLESS:%HEADLESS% ^
    --loglevel INFO ^
    %TEST_FILE%

echo.
echo ============================================
echo   Report: web\reports\report.html
echo ============================================
