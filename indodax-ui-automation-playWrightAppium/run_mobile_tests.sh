#!/bin/bash
# ============================================================
# Run Mobile Tests - Indodax Automation
# ============================================================

echo "============================================"
echo "  INDODAX MOBILE AUTOMATION RUNNER"
echo "============================================"

# Create reports directory
mkdir -p mobile/reports/screenshots

# Default values
TAG=""
TEST_FILE="mobile/tests/"
PLATFORM="Android"
DEVICE="emulator-5554"

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --tag|-t) TAG="--include $2"; shift ;;
        --file|-f) TEST_FILE="$2"; shift ;;
        --platform|-p) PLATFORM="$2"; shift ;;
        --device|-d) DEVICE="$2"; shift ;;
        --smoke) TAG="--include smoke" ;;
        --regression) TAG="--include regression" ;;
        --data-driven) TAG="--include data-driven" ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

echo "Platform: $PLATFORM"
echo "Device: $DEVICE"
echo "Tags: $TAG"
echo "Test File: $TEST_FILE"
echo ""
echo "⚠️  Make sure Appium server is running: appium"
echo ""

# Run tests
robot \
    --outputdir mobile/reports \
    --variable PLATFORM:$PLATFORM \
    --variable ANDROID_DEVICE:$DEVICE \
    --loglevel INFO \
    $TAG \
    $TEST_FILE

EXIT_CODE=$?

echo ""
echo "============================================"
echo "  TEST EXECUTION COMPLETED"
echo "  Report: mobile/reports/report.html"
echo "  Log:    mobile/reports/log.html"
echo "============================================"

exit $EXIT_CODE
