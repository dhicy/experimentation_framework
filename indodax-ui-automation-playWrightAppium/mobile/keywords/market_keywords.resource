*** Settings ***
Documentation    Mobile Market Keywords - Business-level keywords for market tests
...
...              High-level, business-readable keywords for mobile market tests.
...              Layer: Test → Keywords (this) → Screen Object → Base Screen

Resource         ../screens/market_screen.resource
Resource         ../screens/base_screen.resource
Resource         ../resources/variables.resource


*** Keywords ***
# ============================================================
# SETUP / TEARDOWN
# ============================================================
Setup Mobile Test
    [Documentation]    Launch app and navigate to market screen
    Open Mobile App
    Wait For App Ready
    Skip Login If Present
    Navigate To Market Screen

Teardown Mobile Test
    [Documentation]    Capture screenshot on failure, close app
    Run Keyword If Test Failed    Capture Mobile Screenshot    failure_${TEST_NAME}
    Close Mobile App

# ============================================================
# NAVIGATION KEYWORDS
# ============================================================
User Opens Market Screen
    [Documentation]    User navigates to market screen
    Navigate To Market Screen
    Market Screen Should Be Loaded

User Returns To Market Screen
    [Documentation]    User goes back to market screen from detail
    Go Back From Detail Screen
    Market Screen Should Be Loaded

# ============================================================
# VERIFICATION KEYWORDS
# ============================================================
Market Screen Is Fully Loaded
    [Documentation]    Verify market screen is fully loaded with list
    Market Screen Should Be Loaded
    Market List Should Be Visible
    Log    ✓ Market screen is fully loaded

Market List Shows Coins
    [Documentation]    Verify market list displays coins with data
    Market List Should Be Visible
    Market List Should Have Items
    ${count}=    Get Market Item Count
    Should Be True    ${count} > 0    
    ...    msg=Market list should display coins, found ${count}
    Log    ✓ Market list shows ${count} coin(s)

Market Search Is Functional
    [Documentation]    Verify search functionality works correctly
    [Arguments]    ${coin_symbol}=${COIN_BTC}
    Market List Should Be Visible
    Search For Coin    ${coin_symbol}
    Search Results Should Contain Coin    ${coin_symbol}
    Log    ✓ Search found '${coin_symbol}' in results

Market Tab Filter Is Functional
    [Documentation]    Verify tapping market tab filters the list
    [Arguments]    ${tab_name}=IDR
    Market Screen Should Be Loaded
    Tap Market Tab    ${tab_name}
    Market List Should Have Items
    Log    ✓ Market tab '${tab_name}' is functional

Coin Detail Opens Correctly
    [Documentation]    Verify tapping a coin opens detail screen
    Market List Should Have Items
    Tap First Market Item
    Coin Detail Screen Should Be Open
    Coin Detail Should Show Price
    Log    ✓ Coin detail screen opened with price data

Market Screen Shows Price Data
    [Documentation]    Verify market items display price information
    Market List Should Be Visible
    ${price}=    Get First Coin Price
    Should Not Be Empty    ${price}    msg=Coin price should not be empty
    Log    ✓ Price data is displayed: ${price}

# ============================================================
# DATA-DRIVEN KEYWORDS
# ============================================================
Verify Coin Is Searchable In Market
    [Documentation]    Data-driven: verify each coin can be found via search
    [Arguments]    ${coin_symbol}    ${coin_name}
    Navigate To Market Screen
    Market Screen Is Fully Loaded
    Market Search Is Functional    ${coin_symbol}
    Log    ✓ Coin ${coin_symbol} (${coin_name}) is searchable in market

Verify Market Tab Shows Coins
    [Documentation]    Data-driven: verify each tab shows coin list
    [Arguments]    ${tab_name}
    Navigate To Market Screen
    Market Screen Is Fully Loaded
    Market Tab Filter Is Functional    ${tab_name}
    Log    ✓ Tab '${tab_name}' shows coin list

# ============================================================
# COMPOSITE SCENARIOS
# ============================================================
User Views And Returns From Coin Detail
    [Documentation]    User opens a coin detail and returns to market
    Market List Shows Coins
    Tap First Market Item
    Coin Detail Screen Should Be Open
    Coin Detail Should Show Price
    Go Back From Detail Screen
    Market Screen Should Be Loaded
    Log    ✓ User successfully viewed coin detail and returned to market

User Refreshes Market Screen
    [Documentation]    User pull-to-refreshes the market screen
    Market Screen Is Fully Loaded
    Refresh Market Screen
    Market List Shows Coins
    Log    ✓ Market screen refreshed successfully
