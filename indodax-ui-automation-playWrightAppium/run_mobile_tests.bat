@echo off
REM ============================================================
REM Run Mobile Tests - Indodax Automation (Windows)
REM ============================================================

echo ============================================
echo   INDODAX MOBILE AUTOMATION RUNNER
echo ============================================

if not exist "mobile\reports\screenshots" mkdir "mobile\reports\screenshots"

SET PLATFORM=Android
SET DEVICE=emulator-5554
SET TAG=
SET TEST_FILE=mobile\tests\

echo Platform: %PLATFORM%
echo Device: %DEVICE%
echo.
echo Make sure Appium is running: appium
echo.

robot ^
    --outputdir mobile\reports ^
    --variable PLATFORM:%PLATFORM% ^
    --variable ANDROID_DEVICE:%DEVICE% ^
    --loglevel INFO ^
    %TEST_FILE%

echo.
echo ============================================
echo   Report: mobile\reports\report.html
echo ============================================
