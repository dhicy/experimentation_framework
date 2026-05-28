*** Settings ***
Documentation    Locators for Indodax Market Web Page
...              URL: https://indodax.com/market/USDTIDR
...              
...              Locator Strategy:
...              - Prefer data-testid > aria-label > CSS > XPath
...              - All locators centralized here for easy maintenance


*** Variables ***
# ============================================================
# HEADER / NAVIGATION
# ============================================================
${LOC_HEADER_LOGO}                  css=.header-logo, a.navbar-brand img
${LOC_HEADER_NAV_MARKET}            css=a[href*="/market"], nav a:text("Market")
${LOC_HEADER_NAV_TRADE}             css=a[href*="/trade"]
${LOC_HEADER_LOGIN_BTN}             css=a[href*="/login"], button:text("Login"), a:text("Login")
${LOC_HEADER_REGISTER_BTN}          css=a[href*="/register"], button:text("Daftar"), a:text("Daftar")

# ============================================================
# MARKET PAGE - PAIR INFO
# ============================================================
${LOC_MARKET_PAIR_NAME}             css=.market-pair-name, .pair-name, h1.coin-pair
${LOC_MARKET_PAIR_FULL_NAME}        css=.coin-full-name, .market-name, .asset-name
${LOC_MARKET_CURRENT_PRICE}         css=.last-price, .current-price, [class*="lastPrice"], .price-value
${LOC_MARKET_PRICE_CHANGE}          css=.price-change, .change-24h, [class*="priceChange"]
${LOC_MARKET_PRICE_CHANGE_PCT}      css=.price-change-pct, .change-percent, [class*="changePercent"]
${LOC_MARKET_VOLUME_24H}            css=.volume-24h, [class*="volume"], .market-volume
${LOC_MARKET_HIGH_24H}              css=.high-24h, [class*="highPrice"], .price-high
${LOC_MARKET_LOW_24H}               css=.low-24h, [class*="lowPrice"], .price-low

# ============================================================
# MARKET PAGE - TRADING CHART
# ============================================================
${LOC_CHART_CONTAINER}              css=#trading-view, .tradingview-widget-container, canvas.chart-canvas, .chart-container
${LOC_CHART_TIMEFRAME_1M}           css=button[data-value="1"], .timeframe-btn:text("1m"), .chart-btn:text("1M")
${LOC_CHART_TIMEFRAME_5M}           css=button[data-value="5"], .timeframe-btn:text("5m")
${LOC_CHART_TIMEFRAME_15M}          css=button[data-value="15"], .timeframe-btn:text("15m")
${LOC_CHART_TIMEFRAME_1H}           css=button[data-value="60"], .timeframe-btn:text("1h")
${LOC_CHART_TIMEFRAME_1D}           css=button[data-value="1D"], .timeframe-btn:text("1D")
${LOC_CHART_TYPE_CANDLESTICK}       css=.chart-type-candle, button[title*="Candlestick"]

# ============================================================
# MARKET PAGE - ORDER BOOK
# ============================================================
${LOC_ORDERBOOK_CONTAINER}          css=.order-book, #order-book, [class*="orderBook"], .orderbook-container
${LOC_ORDERBOOK_ASKS_SECTION}       css=.asks, .sell-orders, [class*="asks"], .order-book-asks
${LOC_ORDERBOOK_BIDS_SECTION}       css=.bids, .buy-orders, [class*="bids"], .order-book-bids
${LOC_ORDERBOOK_ASK_ROWS}           css=.asks .order-row, .asks tbody tr, .ask-row
${LOC_ORDERBOOK_BID_ROWS}           css=.bids .order-row, .bids tbody tr, .bid-row
${LOC_ORDERBOOK_ASK_PRICE}          css=.asks .price, .ask-price, .asks td.price
${LOC_ORDERBOOK_BID_PRICE}          css=.bids .price, .bid-price, .bids td.price
${LOC_ORDERBOOK_SPREAD}             css=.spread, .order-book-spread, [class*="spread"]
${LOC_ORDERBOOK_TAB}                css=.tab-orderbook, button:text("Order Book"), [data-tab="orderbook"]

# ============================================================
# MARKET PAGE - TRADE FORM (BUY/SELL)
# ============================================================
${LOC_TRADE_BUY_TAB}                css=.buy-tab, button.buy, [data-tab="buy"], .tab-buy
${LOC_TRADE_SELL_TAB}               css=.sell-tab, button.sell, [data-tab="sell"], .tab-sell
${LOC_TRADE_PRICE_INPUT}            css=input[name="price"], #price-input, .price-input input
${LOC_TRADE_AMOUNT_INPUT}           css=input[name="amount"], #amount-input, .amount-input input
${LOC_TRADE_TOTAL_INPUT}            css=input[name="total"], #total-input, .total-input input
${LOC_TRADE_BUY_SUBMIT}             css=button.btn-buy, button:text("Beli"), .buy-submit
${LOC_TRADE_SELL_SUBMIT}            css=button.btn-sell, button:text("Jual"), .sell-submit

# ============================================================
# MARKET PAGE - TRADE HISTORY
# ============================================================
${LOC_TRADE_HISTORY_CONTAINER}      css=.trade-history, #trade-history, [class*="tradeHistory"]
${LOC_TRADE_HISTORY_ROWS}           css=.trade-history tr, .trade-history .row, .history-row
${LOC_TRADE_HISTORY_TAB}            css=.tab-history, button:text("Trade History"), [data-tab="history"]
${LOC_TRADE_HISTORY_FIRST_ROW}      css=.trade-history tbody tr:first-child, .history-item:first-child
${LOC_TRADE_HISTORY_TIME}           css=.trade-history .time, .history-time
${LOC_TRADE_HISTORY_PRICE}          css=.trade-history .price, .history-price
${LOC_TRADE_HISTORY_VOLUME}         css=.trade-history .volume, .history-volume

# ============================================================
# MARKET PAGE - MARKET LIST / PAIRS
# ============================================================
${LOC_MARKET_LIST_CONTAINER}        css=.market-list, #market-list, [class*="marketList"]
${LOC_MARKET_SEARCH_INPUT}          css=input[placeholder*="Search"], input[placeholder*="Cari"], .market-search input
${LOC_MARKET_PAIR_ROWS}             css=.market-list tr, .market-item, .pair-row
${LOC_MARKET_TAB_IDR}               css=.tab-idr, button:text("IDR"), [data-tab="IDR"]
${LOC_MARKET_TAB_BTC}               css=.tab-btc, button:text("BTC"), [data-tab="BTC"]
${LOC_MARKET_TAB_USDT}              css=.tab-usdt, button:text("USDT"), [data-tab="USDT"]

# ============================================================
# PAGE TITLE & META
# ============================================================
${EXPECTED_PAGE_TITLE_CONTAINS}     USDT
${EXPECTED_URL_CONTAINS}            indodax.com/market/USDTIDR
${EXPECTED_PAIR}                    USDT/IDR
