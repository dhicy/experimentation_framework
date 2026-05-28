*** Settings ***
Documentation    Data-Driven Test Suite: Mobile Market - Multiple Coins & Tabs
...
...              Uses DataDriver library for data-driven testing.
...              Tests search and tab functionality across multiple coins.

Resource         ../keywords/market_keywords.resource
Library          DataDriver    file=../data/coins.csv    encoding=UTF-8

Suite Setup      Open Mobile App
Suite Teardown   Close Mobile App

Test Setup       Run Keywords
...              Wait For App Ready
...              AND    Skip Login If Present

Test Teardown    Run Keyword If Test Failed    
...              Capture Mobile Screenshot    failure_${TEST_NAME}

Force Tags       mobile    data-driven


*** Test Cases ***

TC_MOB_DD_SEARCH - Verify Coin Is Searchable In Market
    [Documentation]    Data-driven: verify each coin is findable via search
    [Tags]    data-driven    search
    [Template]    Verify Coin Is Searchable In Market
    ${COIN_SYMBOL}    ${COIN_NAME}
