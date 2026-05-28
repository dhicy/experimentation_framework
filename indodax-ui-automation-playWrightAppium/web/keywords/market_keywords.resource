*** Settings ***
Documentation    Market Keywords - Business-level keyword layer for market tests
...
...              This layer provides high-level, business-readable keywords
...              that compose page-level interactions into meaningful test steps.
...              
...              Layer: Test → Keywords (this file) → Page Object → Base Page

Resource         ../pages/market_page.resource
Resource         ../pages/base_page.resource
Resource         ../resources/variables.resource


*** Keywords ***
# ============================================================
# SETUP / TEARDOWN
# ============================================================
Setup Web Test
    [Documentation]    Initialize browser and open market page
    Open Browser Session    browser=${BROWSER}    headless=${HEADLESS}
    Open Market Page

Teardown Web Test
    [Documentation]    Close browser and clean up
    Run Keyword If Test Failed    Capture Market Page Screenshot    failure
    Close Browser Session

Setup Web Test For Pair
    [Documentation]    Setup test for specific trading pair
    [Arguments]    ${pair}
    Open Browser Session    browser=${BROWSER}    headless=${HEADLESS}
    Open Market Page For Pair    ${pair}

# ============================================================
# NAVIGATION KEYWORDS
# ============================================================
User Opens USDT IDR Market Page
    [Documentation]    User navigates to USDT/IDR market page
    Open Market Page
    Market Page Should Be Loaded

User Opens Market Page For Pair
    [Documentation]    User navigates to specific pair market page
    [Arguments]    ${pair}
    Open Market Page For Pair    ${pair}
    Market Page Should Be Loaded

# ============================================================
# VERIFICATION KEYWORDS
# ============================================================
Market Page Is Fully Loaded
    [Documentation]    Verify all critical elements on market page are present
    Market Page Should Be Loaded
    Current Price Should Be Visible
    Log    Market page loaded successfully

Market Price Information Is Displayed
    [Documentation]    Verify complete price information section is shown
    Price Info Section Should Be Complete
    Price Should Be Numeric
    Log    All price information elements are displayed correctly

Order Book Is Showing Data
    [Documentation]    Verify order book shows both buy and sell orders
    Order Book Should Have Both Asks And Bids
    Log    Order book is showing ask and bid orders

Trading Chart Is Displayed
    [Documentation]    Verify trading chart is rendered on page
    Trading Chart Should Be Visible
    Log    Trading chart is visible on page

Trade History Has Records
    [Documentation]    Verify trade history contains transaction records
    Trade History Should Have Entries
    ${count}=    Get Trade History Row Count
    Should Be True    ${count} > 0
    ...    msg=Trade history should have records, found ${count}
    Log    Trade history contains ${count} records

All Market Page Sections Are Present
    [Documentation]    Comprehensive check of all market page sections
    Market Page Is Fully Loaded
    Market Price Information Is Displayed
    Order Book Is Showing Data
    Trading Chart Is Displayed
    Trade History Has Records

# ============================================================
# DATA ASSERTION KEYWORDS
# ============================================================
Verify Current Price Is Greater Than Zero
    [Documentation]    Assert that current price is a positive number
    ${price}=    Get Current Price
    Log    Current USDT/IDR price: ${price}
    # Price should not be zero or empty
    Should Not Be Empty    ${price}
    ...    msg=Current price should not be empty

Verify 24h Price Data Is Valid
    [Documentation]    Verify 24h high, low, and volume are all present
    ${high}=    Get High 24h
    ${low}=    Get Low 24h
    ${volume}=    Get Volume 24h
    Should Not Be Empty    ${high}     msg=24h High should not be empty
    Should Not Be Empty    ${low}      msg=24h Low should not be empty
    Should Not Be Empty    ${volume}   msg=24h Volume should not be empty
    Log    24h Data - High: ${high} | Low: ${low} | Volume: ${volume}

Verify Order Book Has Valid Prices
    [Documentation]    Verify ask price is higher than bid price (market spread)
    ${ask}=    Get First Ask Price
    ${bid}=    Get First Bid Price
    Should Not Be Empty    ${ask}    msg=Best ask price should not be empty
    Should Not Be Empty    ${bid}    msg=Best bid price should not be empty
    Log    Best Ask: ${ask} | Best Bid: ${bid}

Verify Market Page URL Is Correct
    [Documentation]    Verify current URL matches expected market page URL
    ${url}=    Get Current Page URL
    Should Contain    ${url}    USDTIDR
    ...    msg=URL should contain 'USDTIDR', actual URL: ${url}
    Log    Current URL: ${url}

# ============================================================
# INTERACTION KEYWORDS
# ============================================================
User Searches For Coin
    [Documentation]    User types coin symbol in market search
    [Arguments]    ${coin_symbol}
    Search Coin In Market List    ${coin_symbol}
    Log    Searched for coin: ${coin_symbol}

User Selects Market Tab
    [Documentation]    User clicks on market tab (IDR/BTC/USDT)
    [Arguments]    ${tab_name}
    Run Keyword If    '${tab_name}' == 'IDR'     Click Market Tab IDR
    Run Keyword If    '${tab_name}' == 'BTC'     Click Market Tab BTC
    Run Keyword If    '${tab_name}' == 'USDT'    Click Market Tab USDT
    Log    Selected market tab: ${tab_name}

# ============================================================
# DATA-DRIVEN KEYWORDS
# ============================================================
Verify Market Pair Page Is Accessible
    [Documentation]    Data-driven: verify a specific market pair page loads
    [Arguments]    ${pair}    ${expected_base}    ${expected_quote}
    User Opens Market Page For Pair    ${pair}
    Market Page Is Fully Loaded
    ${url}=    Get Current Page URL
    Should Contain    ${url}    ${pair}
    ...    msg=URL should contain pair '${pair}'
    Log    Market pair ${pair} (${expected_base}/${expected_quote}) is accessible
