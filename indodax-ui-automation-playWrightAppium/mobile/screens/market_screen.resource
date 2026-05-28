*** Settings ***
Documentation    Market Screen Object - Indodax Mobile Market Screen
...
...              Encapsulates all interactions with the Indodax mobile market screen.
...              Follows Screen Object Model pattern (equivalent to POM for mobile).

Resource         base_screen.resource
Resource         ../resources/locators.resource
Resource         ../resources/variables.resource


*** Keywords ***
# ============================================================
# NAVIGATION TO MARKET SCREEN
# ============================================================
Navigate To Market Screen
    [Documentation]    Tap Market tab in bottom navigation
    Tap Element Safely    ${LOC_NAV_MARKET}
    Market Screen Should Be Loaded

Navigate To Market Screen Android
    [Documentation]    Navigate to market screen on Android
    Tap Element Safely    ${LOC_NAV_MARKET}
    Wait For Loading To Complete
    Market Screen Should Be Loaded

Navigate To Market Screen iOS
    [Documentation]    Navigate to market screen on iOS
    Tap Element Safely    ${IOS_NAV_MARKET}
    Wait For Loading To Complete

Skip Login If Present
    [Documentation]    Skip login screen if shown (tap Skip/Lewati button)
    ${skip_present}=    Run Keyword And Return Status    
    ...    Element Should Be Visible    ${LOC_SKIP_LOGIN}
    Run Keyword If    ${skip_present}    Tap Element Safely    ${LOC_SKIP_LOGIN}
    Wait For Loading To Complete

# ============================================================
# SCREEN VERIFICATION
# ============================================================
Market Screen Should Be Loaded
    [Documentation]    Verify market screen is fully loaded
    Wait For Loading To Complete
    ${title_visible}=    Run Keyword And Return Status    
    ...    Element Should Be Visible    ${LOC_MARKET_SCREEN_TITLE}
    ${list_visible}=    Run Keyword And Return Status    
    ...    Element Should Be Visible    ${LOC_MARKET_RECYCLER_VIEW}
    ${either_visible}=    Evaluate    ${title_visible} or ${list_visible}
    Should Be True    ${either_visible}    
    ...    msg=${MSG_MARKET_LOADED}: Market screen elements not found

Market List Should Be Visible
    [Documentation]    Assert market coin list is displayed
    ${status}=    Run Keyword And Return Status    
    ...    Element Should Be Visible    ${LOC_MARKET_RECYCLER_VIEW}
    Run Keyword If    not ${status}    
    ...    Element Should Be Visible On Screen    ${LOC_MARKET_LIST}    
    ...    message=${MSG_MARKET_LIST_VISIBLE}

Market List Should Have Items
    [Documentation]    Assert market list contains coin items
    Wait For Element Visible    ${LOC_MARKET_RECYCLER_VIEW}
    Element Count Should Be Greater Than    ${LOC_MARKET_ITEMS_ALL}    0
    ...    message=Market list should have coin items

# ============================================================
# SEARCH FUNCTIONALITY
# ============================================================
Search For Coin
    [Documentation]    Type coin symbol in search field
    [Arguments]    ${coin_symbol}
    Wait For Element Visible    ${LOC_MARKET_SEARCH_INPUT}
    Input Text To Field    ${LOC_MARKET_SEARCH_INPUT}    ${coin_symbol}
    Hide Keyboard If Shown
    Sleep    1s

Clear Search Input
    [Documentation]    Clear search field
    Wait For Element Visible    ${LOC_MARKET_SEARCH_INPUT}
    Clear Text    ${LOC_MARKET_SEARCH_INPUT}
    Sleep    0.5s

Search Results Should Contain Coin
    [Documentation]    Verify search results show the searched coin
    [Arguments]    ${coin_symbol}
    ${xpath}=    Set Variable    
    ...    xpath=//android.widget.TextView[contains(@text,'${coin_symbol}')]
    Wait For Element Visible    ${xpath}    timeout=10
    Element Should Be Visible On Screen    ${xpath}    
    ...    message=Search results should contain '${coin_symbol}'

# ============================================================
# TAB/FILTER INTERACTIONS
# ============================================================
Tap Market Tab
    [Documentation]    Tap market filter tab (IDR/BTC/USDT)
    [Arguments]    ${tab_name}
    ${locator}=    Run Keyword If    '${tab_name}' == 'IDR'     Set Variable    ${LOC_MARKET_TAB_IDR}
    ...    ELSE IF    '${tab_name}' == 'BTC'     Set Variable    ${LOC_MARKET_TAB_BTC}
    ...    ELSE IF    '${tab_name}' == 'USDT'    Set Variable    ${LOC_MARKET_TAB_USDT}
    ...    ELSE       Set Variable    ${LOC_MARKET_TAB_IDR}
    Tap Element Safely    ${locator}
    Wait For Loading To Complete

Tap IDR Tab
    [Documentation]    Select IDR market tab
    Tap Element Safely    ${LOC_MARKET_TAB_IDR}
    Wait For Loading To Complete

Tap BTC Tab
    [Documentation]    Select BTC market tab
    Tap Element Safely    ${LOC_MARKET_TAB_BTC}
    Wait For Loading To Complete

Tap USDT Tab
    [Documentation]    Select USDT market tab
    Tap Element Safely    ${LOC_MARKET_TAB_USDT}
    Wait For Loading To Complete

# ============================================================
# MARKET ITEM INTERACTIONS
# ============================================================
Tap First Market Item
    [Documentation]    Tap the first coin in the market list
    Wait For Element Visible    ${LOC_FIRST_MARKET_ITEM}
    Tap Element Safely    ${LOC_FIRST_MARKET_ITEM}
    Wait For Loading To Complete

Tap Coin By Symbol
    [Documentation]    Tap a specific coin by its symbol
    [Arguments]    ${coin_symbol}
    Search For Coin    ${coin_symbol}
    ${locator}=    Set Variable    
    ...    xpath=//android.widget.TextView[@text='${coin_symbol}']
    Wait For Element Visible    ${locator}
    Tap Element Safely    ${locator}
    Wait For Loading To Complete

Get First Coin Name
    [Documentation]    Get name of first coin in list
    Wait For Element Visible    ${LOC_FIRST_MARKET_ITEM}
    ${name}=    Get Element Text Safely    ${LOC_COIN_NAME}
    RETURN    ${name}

Get First Coin Price
    [Documentation]    Get price of first coin in list
    ${price}=    Get Element Text Safely    ${LOC_MARKET_COIN_PRICE}
    RETURN    ${price}

Get Market Item Count
    [Documentation]    Get number of visible market items
    ${elements}=    Get WebElements    ${LOC_MARKET_ITEMS_ALL}
    ${count}=    Get Length    ${elements}
    RETURN    ${count}

# ============================================================
# COIN DETAIL SCREEN INTERACTIONS
# ============================================================
Coin Detail Screen Should Be Open
    [Documentation]    Verify coin detail screen is displayed
    ${detail_visible}=    Run Keyword And Return Status    
    ...    Element Should Be Visible    ${LOC_DETAIL_CURRENT_PRICE}
    Should Be True    ${detail_visible}    
    ...    msg=${MSG_COIN_DETAIL_OPENS}: Coin detail screen not opened

Coin Detail Should Show Price
    [Documentation]    Assert price is shown on detail screen
    Element Should Be Visible On Screen    ${LOC_DETAIL_CURRENT_PRICE}    
    ...    message=Price should be visible on detail screen

Go Back From Detail Screen
    [Documentation]    Navigate back from coin detail
    ${back_btn}=    Run Keyword And Return Status    
    ...    Element Should Be Visible    ${LOC_DETAIL_BACK_BTN}
    Run Keyword If    ${back_btn}    Tap Element Safely    ${LOC_DETAIL_BACK_BTN}
    ...    ELSE    Press Back Button
    Wait For Loading To Complete

# ============================================================
# REFRESH
# ============================================================
Refresh Market Screen
    [Documentation]    Pull to refresh market list
    Pull To Refresh
    Market List Should Be Visible
