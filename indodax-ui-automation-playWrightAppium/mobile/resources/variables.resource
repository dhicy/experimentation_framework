*** Settings ***
Documentation    Global variables for Mobile Automation


*** Variables ***
# ============================================================
# APPIUM SERVER
# ============================================================
${APPIUM_HOST}                  127.0.0.1
${APPIUM_PORT}                  4723
${APPIUM_URL}                   http://${APPIUM_HOST}:${APPIUM_PORT}/wd/hub

# ============================================================
# PLATFORM SELECTION
# ============================================================
${PLATFORM}                     Android    # Android | iOS

# ============================================================
# ANDROID CAPABILITIES
# ============================================================
${ANDROID_PLATFORM}             Android
${ANDROID_VERSION}              13.0
${ANDROID_DEVICE}               emulator-5554
${ANDROID_AUTOMATION}           UiAutomator2
${ANDROID_PACKAGE}              id.co.bitcoin
${ANDROID_ACTIVITY}             id.co.bitcoin.SplashActivity
${ANDROID_NO_RESET}             ${TRUE}

# ============================================================
# iOS CAPABILITIES
# ============================================================
${IOS_PLATFORM}                 iOS
${IOS_VERSION}                  17.0
${IOS_DEVICE}                   iPhone 15
${IOS_AUTOMATION}               XCUITest
${IOS_BUNDLE_ID}                id.co.bitcoin
${IOS_NO_RESET}                 ${TRUE}

# ============================================================
# TIMEOUTS
# ============================================================
${APP_LAUNCH_TIMEOUT}           15
${IMPLICIT_WAIT}                10
${EXPLICIT_WAIT}                20
${SWIPE_WAIT}                   2

# ============================================================
# SCREENSHOT
# ============================================================
${MOBILE_SCREENSHOT_DIR}        mobile/reports/screenshots
${TAKE_SCREENSHOT_ON_FAIL}      ${TRUE}

# ============================================================
# TEST DATA
# ============================================================
${COIN_USDT}                    USDT
${COIN_BTC}                     BTC
${COIN_ETH}                     ETH
${COIN_BNB}                     BNB
${COIN_SOL}                     SOL

# ============================================================
# ASSERTION MESSAGES
# ============================================================
${MSG_MARKET_LOADED}            Market screen should be loaded
${MSG_MARKET_LIST_VISIBLE}      Market list should be visible
${MSG_SEARCH_WORKS}             Search functionality should work
${MSG_COIN_DETAIL_OPENS}        Coin detail screen should open
