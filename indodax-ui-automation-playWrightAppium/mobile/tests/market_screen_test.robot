*** Settings ***
Documentation    Test Suite: Indodax Mobile Market Screen Tests
...              App: Indodax Mobile (Android/iOS)
...              Framework: Robot Framework + Appium
...
...              Test Coverage:
...              - App launch & market screen navigation
...              - Market list display
...              - Search functionality
...              - Market tab filtering
...              - Coin detail navigation
...              - Price data verification
...              - Refresh functionality

Resource         ../keywords/market_keywords.resource

Suite Setup      Open Mobile App
Suite Teardown   Close Mobile App

Test Setup       Run Keywords
...              Wait For App Ready
...              AND    Skip Login If Present
...              AND    Navigate To Market Screen

Test Teardown    Run Keyword If Test Failed    
...              Capture Mobile Screenshot    failure_${TEST_NAME}

Force Tags       mobile    market    indodax


*** Test Cases ***

TC_MOB_001 - Market Screen Opens Successfully
    [Documentation]    Verify Market screen loads after app launch
    [Tags]    smoke    navigation
    User Opens Market Screen
    Market Screen Is Fully Loaded

TC_MOB_002 - Market List Is Displayed With Coins
    [Documentation]    Verify market list shows coin data
    [Tags]    smoke    market-list
    Market Screen Is Fully Loaded
    Market List Shows Coins

TC_MOB_003 - Search Coin Functionality Works
    [Documentation]    Verify searching for BTC finds results
    [Tags]    smoke    search
    Market Screen Is Fully Loaded
    Market Search Is Functional    ${COIN_BTC}

TC_MOB_004 - IDR Market Tab Filter Works
    [Documentation]    Verify IDR tab filters market list
    [Tags]    smoke    filter    tabs
    Market Screen Is Fully Loaded
    Market Tab Filter Is Functional    IDR

TC_MOB_005 - BTC Market Tab Filter Works
    [Documentation]    Verify BTC tab filters market list
    [Tags]    regression    filter    tabs
    Market Screen Is Fully Loaded
    Market Tab Filter Is Functional    BTC

TC_MOB_006 - USDT Market Tab Filter Works
    [Documentation]    Verify USDT tab filters market list
    [Tags]    regression    filter    tabs
    Market Screen Is Fully Loaded
    Market Tab Filter Is Functional    USDT

TC_MOB_007 - Coin Detail Screen Opens From Market List
    [Documentation]    Verify tapping a coin navigates to detail screen
    [Tags]    smoke    navigation    detail
    Market Screen Is Fully Loaded
    Coin Detail Opens Correctly

TC_MOB_008 - Coin Price Is Displayed In Market List
    [Documentation]    Verify price data is shown for coins in list
    [Tags]    smoke    price
    Market Screen Is Fully Loaded
    Market Screen Shows Price Data

TC_MOB_009 - User Can Navigate Back From Coin Detail
    [Documentation]    Verify user can open detail and return to market list
    [Tags]    regression    navigation
    Market Screen Is Fully Loaded
    User Views And Returns From Coin Detail

TC_MOB_010 - Market Screen Can Be Refreshed
    [Documentation]    Verify pull-to-refresh reloads market data
    [Tags]    regression    refresh
    Market Screen Is Fully Loaded
    User Refreshes Market Screen

TC_MOB_011 - Search For USDT Shows Results
    [Documentation]    Verify searching for USDT returns results
    [Tags]    regression    search
    Market Screen Is Fully Loaded
    Market Search Is Functional    ${COIN_USDT}

TC_MOB_012 - Search For ETH Shows Results
    [Documentation]    Verify searching for ETH returns results
    [Tags]    regression    search
    Market Screen Is Fully Loaded
    Market Search Is Functional    ${COIN_ETH}
