*** Settings ***
Documentation    Locators for Indodax Mobile App - Market Screen
...              Platform: Android (UiAutomator2)
...
...              Locator Strategy:
...              - Prefer accessibility_id > resource-id > xpath
...              - resource-id format: id.co.bitcoin:id/element_id
...              - All locators centralized for maintainability


*** Variables ***
# ============================================================
# APP PACKAGE INFO
# ============================================================
${APP_PACKAGE}                  id.co.bitcoin
${APP_ACTIVITY}                 id.co.bitcoin.SplashActivity

# ============================================================
# SPLASH / LOADING SCREEN
# ============================================================
${LOC_SPLASH_LOGO}              accessibility_id=Indodax Logo
${LOC_LOADING_INDICATOR}        xpath=//android.widget.ProgressBar

# ============================================================
# BOTTOM NAVIGATION
# ============================================================
${LOC_NAV_HOME}                 accessibility_id=Home
${LOC_NAV_MARKET}               accessibility_id=Market
${LOC_NAV_TRADE}                accessibility_id=Trade
${LOC_NAV_WALLET}               accessibility_id=Wallet
${LOC_NAV_PROFILE}              accessibility_id=Profile

# ============================================================
# MARKET SCREEN - MAIN
# ============================================================
${LOC_MARKET_SCREEN_TITLE}      xpath=//android.widget.TextView[@text='Market']
${LOC_MARKET_CONTAINER}         id=${APP_PACKAGE}:id/market_container
${LOC_MARKET_SEARCH_BAR}        id=${APP_PACKAGE}:id/search_market
${LOC_MARKET_SEARCH_INPUT}      xpath=//android.widget.EditText[contains(@resource-id, 'search')]
${LOC_MARKET_SEARCH_HINT}       xpath=//android.widget.EditText[@hint='Cari koin...']

# ============================================================
# MARKET SCREEN - TABS/FILTERS
# ============================================================
${LOC_MARKET_TAB_FAVORITES}     xpath=//android.widget.TextView[@text='Favorit']
${LOC_MARKET_TAB_IDR}           xpath=//android.widget.TextView[@text='IDR']
${LOC_MARKET_TAB_BTC}           xpath=//android.widget.TextView[@text='BTC']
${LOC_MARKET_TAB_USDT}          xpath=//android.widget.TextView[@text='USDT']

# ============================================================
# MARKET SCREEN - LIST ITEMS
# ============================================================
${LOC_MARKET_LIST}              id=${APP_PACKAGE}:id/market_list
${LOC_MARKET_RECYCLER_VIEW}     xpath=//androidx.recyclerview.widget.RecyclerView
${LOC_MARKET_ITEM}              xpath=//android.widget.LinearLayout[contains(@resource-id,'market_item')]
${LOC_MARKET_COIN_NAME}         xpath=//android.widget.TextView[contains(@resource-id,'coin_name')]
${LOC_MARKET_COIN_SYMBOL}       xpath=//android.widget.TextView[contains(@resource-id,'coin_symbol')]
${LOC_MARKET_COIN_PRICE}        xpath=//android.widget.TextView[contains(@resource-id,'coin_price')]
${LOC_MARKET_COIN_CHANGE}       xpath=//android.widget.TextView[contains(@resource-id,'price_change')]
${LOC_MARKET_COIN_VOLUME}       xpath=//android.widget.TextView[contains(@resource-id,'volume')]

# Market items by position (fallback locators)
${LOC_FIRST_MARKET_ITEM}        xpath=(//androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup)[1]
${LOC_MARKET_ITEMS_ALL}         xpath=//androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup

# ============================================================
# COIN DETAIL SCREEN
# ============================================================
${LOC_DETAIL_SCREEN}            id=${APP_PACKAGE}:id/detail_container
${LOC_DETAIL_COIN_NAME}         xpath=//android.widget.TextView[contains(@resource-id,'detail_coin_name')]
${LOC_DETAIL_COIN_SYMBOL}       xpath=//android.widget.TextView[contains(@resource-id,'detail_symbol')]
${LOC_DETAIL_CURRENT_PRICE}     xpath=//android.widget.TextView[contains(@resource-id,'detail_price')]
${LOC_DETAIL_PRICE_CHANGE}      xpath=//android.widget.TextView[contains(@resource-id,'detail_change')]
${LOC_DETAIL_VOLUME}            xpath=//android.widget.TextView[contains(@resource-id,'detail_volume')]
${LOC_DETAIL_HIGH_24H}          xpath=//android.widget.TextView[contains(@resource-id,'high_24h')]
${LOC_DETAIL_LOW_24H}           xpath=//android.widget.TextView[contains(@resource-id,'low_24h')]
${LOC_DETAIL_CHART}             xpath=//android.view.View[contains(@resource-id,'chart')]
${LOC_DETAIL_BUY_BTN}           xpath=//android.widget.Button[@text='Beli' or @text='Buy']
${LOC_DETAIL_SELL_BTN}          xpath=//android.widget.Button[@text='Jual' or @text='Sell']
${LOC_DETAIL_BACK_BTN}          xpath=//android.widget.ImageButton[@content-desc='Navigate up']

# ============================================================
# SORT OPTIONS
# ============================================================
${LOC_SORT_BUTTON}              xpath=//android.widget.ImageView[contains(@content-desc,'sort')]
${LOC_SORT_BY_PRICE}            xpath=//android.widget.TextView[@text='Harga']
${LOC_SORT_BY_CHANGE}           xpath=//android.widget.TextView[@text='Perubahan']
${LOC_SORT_BY_VOLUME}           xpath=//android.widget.TextView[@text='Volume']
${LOC_SORT_ASCENDING}           xpath=//android.widget.TextView[@text='Naik']
${LOC_SORT_DESCENDING}          xpath=//android.widget.TextView[@text='Turun']

# ============================================================
# LOGIN SCREEN (if needed)
# ============================================================
${LOC_LOGIN_EMAIL}              id=${APP_PACKAGE}:id/email_input
${LOC_LOGIN_PASSWORD}           id=${APP_PACKAGE}:id/password_input
${LOC_LOGIN_SUBMIT}             id=${APP_PACKAGE}:id/login_button
${LOC_LOGIN_TITLE}              xpath=//android.widget.TextView[@text='Masuk']
${LOC_SKIP_LOGIN}               xpath=//android.widget.TextView[@text='Lewati' or @text='Skip']

# ============================================================
# COMMON ELEMENTS
# ============================================================
${LOC_TOAST_MSG}                xpath=//android.widget.Toast
${LOC_DIALOG_OK}                xpath=//android.widget.Button[@text='OK']
${LOC_DIALOG_CANCEL}            xpath=//android.widget.Button[@text='Batal']
${LOC_PROGRESS_BAR}             xpath=//android.widget.ProgressBar
${LOC_SWIPE_REFRESH}            xpath=//androidx.swiperefreshlayout.widget.SwipeRefreshLayout

# ============================================================
# iOS LOCATORS (XCUITest)
# ============================================================
${IOS_NAV_MARKET}               xpath=//XCUIElementTypeButton[@name='Market']
${IOS_MARKET_TITLE}             xpath=//XCUIElementTypeNavigationBar[@name='Market']
${IOS_SEARCH_BAR}               xpath=//XCUIElementTypeSearchField
${IOS_MARKET_TABLE}             xpath=//XCUIElementTypeTableView
${IOS_MARKET_CELL}              xpath=//XCUIElementTypeTableView/XCUIElementTypeCell
${IOS_COIN_NAME}                xpath=//XCUIElementTypeStaticText[contains(@name,'coin')]
${IOS_COIN_PRICE}               xpath=//XCUIElementTypeStaticText[contains(@name,'price')]
${IOS_TAB_IDR}                  xpath=//XCUIElementTypeButton[@name='IDR']
${IOS_TAB_BTC}                  xpath=//XCUIElementTypeButton[@name='BTC']
${IOS_BACK_BTN}                 xpath=//XCUIElementTypeButton[@name='Back']
