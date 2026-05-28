*** Settings ***
Documentation    Test Suite: Indodax Market Web Page Tests
...              URL: https://indodax.com/market/USDTIDR
...              Framework: Robot Framework + Playwright
...
...              Test Coverage:
...              - Page load & URL verification
...              - Header elements
...              - Price information display
...              - Order book (asks & bids)
...              - Trading chart
...              - Trade history
...              - Page completeness check

Resource         ../keywords/market_keywords.resource

Suite Setup      Open Browser Session    browser=${BROWSER}    headless=${HEADLESS}
Suite Teardown   Close Browser Session

Test Setup       Open Market Page
Test Teardown    Run Keyword If Test Failed    Capture Market Page Screenshot    ${TEST_NAME}

Force Tags       web    market    indodax


*** Test Cases ***

TC_WEB_001 - Market Page Loads Successfully
    [Documentation]    Verify USDT/IDR market page opens and loads without error
    [Tags]    smoke    page-load
    User Opens USDT IDR Market Page
    Market Page Is Fully Loaded
    Verify Market Page URL Is Correct

TC_WEB_002 - Market Page Header Is Present
    [Documentation]    Verify page header and navigation elements are displayed
    [Tags]    smoke    ui
    Market Page Should Be Loaded
    Element Should Be Visible    ${LOC_HEADER_LOGO}
    ...    message=Indodax logo should be visible in header

TC_WEB_003 - Current Price USDT IDR Is Displayed
    [Documentation]    Verify current USDT/IDR price is shown and is a valid number
    [Tags]    smoke    price
    Market Page Is Fully Loaded
    Current Price Should Be Visible
    Price Should Be Numeric
    Verify Current Price Is Greater Than Zero

TC_WEB_004 - 24H Price Statistics Are Displayed
    [Documentation]    Verify 24h high, low, volume, and change are displayed
    [Tags]    smoke    price
    Market Page Is Fully Loaded
    Market Price Information Is Displayed
    Verify 24h Price Data Is Valid

TC_WEB_005 - Order Book Shows Ask And Bid Orders
    [Documentation]    Verify order book displays both sell (ask) and buy (bid) orders
    [Tags]    smoke    orderbook
    Market Page Is Fully Loaded
    Order Book Is Showing Data
    Verify Order Book Has Valid Prices

TC_WEB_006 - Trading Chart Is Rendered
    [Documentation]    Verify trading chart widget is visible on page
    [Tags]    smoke    chart
    Market Page Is Fully Loaded
    Trading Chart Is Displayed

TC_WEB_007 - Trade History Shows Transactions
    [Documentation]    Verify trade history section contains recent transactions
    [Tags]    regression    history
    Market Page Is Fully Loaded
    Trade History Has Records

TC_WEB_008 - All Market Page Sections Are Present
    [Documentation]    Comprehensive test: verify all major sections exist on market page
    [Tags]    regression    full-check
    All Market Page Sections Are Present

TC_WEB_009 - Market Page URL Is Correct
    [Documentation]    Verify the URL matches the USDTIDR market page
    [Tags]    smoke    url
    User Opens USDT IDR Market Page
    Verify Market Page URL Is Correct
    ${url}=    Get Current Page URL
    Should Contain    ${url}    USDTIDR
    Log    ✓ URL verified: ${url}
