#!/bin/bash
# ============================================================
# Run Web Tests - Indodax Automation
# ============================================================

echo "============================================"
echo "  INDODAX WEB AUTOMATION RUNNER"
echo "============================================"

# Create reports directory
mkdir -p web/reports/screenshots

# Default values
TAG=""
TEST_FILE="web/tests/"
BROWSER="chromium"
HEADLESS="False"

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --tag|-t) TAG="--include $2"; shift ;;
        --file|-f) TEST_FILE="$2"; shift ;;
        --browser|-b) BROWSER="$2"; shift ;;
        --headless) HEADLESS="True" ;;
        --smoke) TAG="--include smoke" ;;
        --regression) TAG="--include regression" ;;
        --data-driven) TAG="--include data-driven" ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

echo "Browser: $BROWSER"
echo "Headless: $HEADLESS"
echo "Tags: $TAG"
echo "Test File: $TEST_FILE"
echo ""

# Run tests
robot \
    --outputdir web/reports \
    --variable BROWSER:$BROWSER \
    --variable HEADLESS:$HEADLESS \
    --loglevel INFO \
    $TAG \
    $TEST_FILE

EXIT_CODE=$?

echo ""
echo "============================================"
echo "  TEST EXECUTION COMPLETED"
echo "  Report: web/reports/report.html"
echo "  Log:    web/reports/log.html"
echo "============================================"

exit $EXIT_CODE
