*** Settings ***
Documentation    Global variables for Web Automation


*** Variables ***
# ============================================================
# URLS
# ============================================================
${BASE_URL}                     https://indodax.com
${MARKET_USDT_URL}              https://indodax.com/market/USDTIDR
${MARKET_BTC_URL}               https://indodax.com/market/BTCIDR
${MARKET_ETH_URL}               https://indodax.com/market/ETHIDR

# ============================================================
# BROWSER SETTINGS
# ============================================================
${BROWSER}                      chromium
${HEADLESS}                     ${FALSE}
${VIEWPORT_WIDTH}               1920
${VIEWPORT_HEIGHT}              1080
${SLOW_MO}                      0

# ============================================================
# TIMEOUTS
# ============================================================
${PAGE_LOAD_TIMEOUT}            30000
${ELEMENT_TIMEOUT}              15000
${SHORT_TIMEOUT}                5000
${LONG_TIMEOUT}                 45000

# ============================================================
# SCREENSHOT
# ============================================================
${SCREENSHOT_DIR}               web/reports/screenshots
${TAKE_SCREENSHOT_ON_FAIL}      ${TRUE}

# ============================================================
# TEST DATA
# ============================================================
${PAIR_USDT_IDR}                USDT/IDR
${PAIR_BTC_IDR}                 BTC/IDR
${PAIR_ETH_IDR}                 ETH/IDR
${COIN_USDT}                    USDT
${COIN_BTC}                     BTC

# ============================================================
# ASSERTION MESSAGES
# ============================================================
${MSG_PAGE_LOADED}              Market page should be loaded successfully
${MSG_PRICE_VISIBLE}            Current price should be visible
${MSG_ORDERBOOK_VISIBLE}        Order book should be visible
${MSG_CHART_VISIBLE}            Trading chart should be visible
${MSG_HISTORY_VISIBLE}          Trade history should be visible
