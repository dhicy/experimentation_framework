*** Settings ***
Documentation    Market Page Object - Indodax Market Page (USDT/IDR)
...              URL: https://indodax.com/market/USDTIDR
...
...              Encapsulates all interactions with the Indodax market page.
...              Follows Page Object Model pattern.

Resource         base_page.resource
Resource         ../resources/locators.resource
Resource         ../resources/variables.resource


*** Keywords ***
# ============================================================
# NAVIGATION
# ============================================================
Open Market Page
    [Documentation]    Open Indodax USDT/IDR market page
    Navigate To URL    ${MARKET_USDT_URL}
    Market Page Should Be Loaded

Open Market Page For Pair
    [Documentation]    Open market page for specific pair
    [Arguments]    ${pair}    # e.g., BTCIDR, ETHIDR
    ${url}=    Set Variable    ${BASE_URL}/market/${pair}
    Navigate To URL    ${url}
    Wait For Page Load Complete

# ============================================================
# PAGE VERIFICATION
# ============================================================
Market Page Should Be Loaded
    [Documentation]    Verify market page is fully loaded with key elements
    Wait For Page Load Complete
    ${url}=    Get Current Page URL
    Should Contain    ${url}    indodax.com/market    
    ...    msg=URL should contain 'indodax.com/market', actual: ${url}

Market Page Title Should Contain USDT
    [Documentation]    Verify page title contains USDT reference
    ${title}=    Get Current Page Title
    Should Contain    ${title}    ${EXPECTED_PAGE_TITLE_CONTAINS}
    ...    msg=Page title should contain '${EXPECTED_PAGE_TITLE_CONTAINS}', actual: ${title}

# ============================================================
# PAIR INFORMATION
# ============================================================
Get Current Pair Name
    [Documentation]    Get the trading pair name displayed on page
    ${name}=    Get Text Safely    ${LOC_MARKET_PAIR_NAME}
    RETURN    ${name}

Get Current Price
    [Documentation]    Get current USDT/IDR price
    ${price}=    Get Text Safely    ${LOC_MARKET_CURRENT_PRICE}
    RETURN    ${price}

Get Price Change
    [Documentation]    Get 24h price change
    ${change}=    Get Text Safely    ${LOC_MARKET_PRICE_CHANGE}
    RETURN    ${change}

Get Volume 24h
    [Documentation]    Get 24h trading volume
    ${volume}=    Get Text Safely    ${LOC_MARKET_VOLUME_24H}
    RETURN    ${volume}

Get High 24h
    [Documentation]    Get 24h highest price
    ${high}=    Get Text Safely    ${LOC_MARKET_HIGH_24H}
    RETURN    ${high}

Get Low 24h
    [Documentation]    Get 24h lowest price
    ${low}=    Get Text Safely    ${LOC_MARKET_LOW_24H}
    RETURN    ${low}

Current Price Should Be Visible
    [Documentation]    Assert current price is displayed
    Element Should Be Visible    ${LOC_MARKET_CURRENT_PRICE}
    ...    message=${MSG_PRICE_VISIBLE}

Price Should Be Numeric
    [Documentation]    Assert price value is a valid number
    ${price}=    Get Current Price
    # Remove formatting (dots, commas, IDR symbols, spaces)
    ${clean_price}=    Evaluate    '${price}'.replace('.', '').replace(',', '').replace('IDR', '').replace('Rp', '').strip()
    Should Match Regexp    ${clean_price}    ^\\d+\\.?\\d*$    
    ...    msg=Price '${price}' (cleaned: '${clean_price}') should be numeric

Price Info Section Should Be Complete
    [Documentation]    Assert all price info elements are visible
    Current Price Should Be Visible
    Element Should Be Visible    ${LOC_MARKET_PRICE_CHANGE}    
    ...    message=Price change should be visible
    Element Should Be Visible    ${LOC_MARKET_VOLUME_24H}    
    ...    message=24h volume should be visible
    Element Should Be Visible    ${LOC_MARKET_HIGH_24H}    
    ...    message=24h high should be visible
    Element Should Be Visible    ${LOC_MARKET_LOW_24H}    
    ...    message=24h low should be visible

# ============================================================
# ORDER BOOK
# ============================================================
Order Book Should Be Visible
    [Documentation]    Assert order book section is displayed
    Element Should Be Visible    ${LOC_ORDERBOOK_CONTAINER}    
    ...    message=${MSG_ORDERBOOK_VISIBLE}

Ask Orders Should Be Present
    [Documentation]    Assert sell orders (asks) are present in order book
    Wait For Element Visible    ${LOC_ORDERBOOK_ASKS_SECTION}
    Element Count Should Be Greater Than    ${LOC_ORDERBOOK_ASK_ROWS}    0
    ...    message=Ask orders should be present in order book

Bid Orders Should Be Present
    [Documentation]    Assert buy orders (bids) are present in order book
    Wait For Element Visible    ${LOC_ORDERBOOK_BIDS_SECTION}
    Element Count Should Be Greater Than    ${LOC_ORDERBOOK_BID_ROWS}    0
    ...    message=Bid orders should be present in order book

Order Book Should Have Both Asks And Bids
    [Documentation]    Assert both sides of the order book are populated
    Order Book Should Be Visible
    Ask Orders Should Be Present
    Bid Orders Should Be Present

Get First Ask Price
    [Documentation]    Get the best ask (lowest sell) price
    ${price}=    Get Text Safely    ${LOC_ORDERBOOK_ASK_PRICE}
    RETURN    ${price}

Get First Bid Price
    [Documentation]    Get the best bid (highest buy) price
    ${price}=    Get Text Safely    ${LOC_ORDERBOOK_BID_PRICE}
    RETURN    ${price}

# ============================================================
# TRADING CHART
# ============================================================
Trading Chart Should Be Visible
    [Documentation]    Assert trading chart is displayed on page
    Element Should Be Visible    ${LOC_CHART_CONTAINER}    
    ...    message=${MSG_CHART_VISIBLE}

# ============================================================
# TRADE HISTORY
# ============================================================
Trade History Should Be Visible
    [Documentation]    Assert trade history section is visible
    Element Should Be Visible    ${LOC_TRADE_HISTORY_CONTAINER}    
    ...    message=${MSG_HISTORY_VISIBLE}

Trade History Should Have Entries
    [Documentation]    Assert trade history contains records
    Wait For Element Visible    ${LOC_TRADE_HISTORY_CONTAINER}
    Element Count Should Be Greater Than    ${LOC_TRADE_HISTORY_ROWS}    0
    ...    message=Trade history should contain entries

Get Trade History Row Count
    [Documentation]    Get number of rows in trade history
    ${elements}=    Get Elements    ${LOC_TRADE_HISTORY_ROWS}
    ${count}=    Get Length    ${elements}
    RETURN    ${count}

# ============================================================
# MARKET LIST
# ============================================================
Search Coin In Market List
    [Documentation]    Search for a coin in market list
    [Arguments]    ${coin_symbol}
    Wait For Element Visible    ${LOC_MARKET_SEARCH_INPUT}
    Input Text Safely    ${LOC_MARKET_SEARCH_INPUT}    ${coin_symbol}
    Sleep    1s    # Wait for search results to filter

Click Market Tab IDR
    [Documentation]    Click IDR market tab
    Click Element Safely    ${LOC_MARKET_TAB_IDR}

Click Market Tab BTC
    [Documentation]    Click BTC market tab  
    Click Element Safely    ${LOC_MARKET_TAB_BTC}

Click Market Tab USDT
    [Documentation]    Click USDT market tab
    Click Element Safely    ${LOC_MARKET_TAB_USDT}

Market List Should Have Pairs
    [Documentation]    Assert market list contains trading pairs
    Wait For Element Visible    ${LOC_MARKET_LIST_CONTAINER}
    Element Count Should Be Greater Than    ${LOC_MARKET_PAIR_ROWS}    0
    ...    message=Market list should contain trading pairs

# ============================================================
# PAGE SCREENSHOTS
# ============================================================
Capture Market Page Screenshot
    [Documentation]    Take screenshot of market page
    [Arguments]    ${name}=market_page
    Take Screenshot With Name    ${name}
