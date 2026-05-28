*** Settings ***
Documentation       Smoke Test Suite — Indodax Public API
...
...                 Fastest subset of tests; intended as a CI gate.
...                 All tests must pass before full regression runs.
...
...                 Coverage (one per endpoint):
...                   ✔ /api/server_time
...                   ✔ /api/pairs
...                   ✔ /api/summaries
...                   ✔ /api/btcidr/ticker
...                   ✔ /api/btcidr/depth
...                   ✔ /api/btcidr/trades
Suite Setup         Create Indodax Session
Suite Teardown      Teardown Indodax Session
Test Tags           smoke    ci
Resource            ../resources/keywords/common_keywords.robot
Resource            ../resources/keywords/api_assertions.robot
Resource            ../resources/variables/global_variables.robot

*** Test Cases ***

Smoke - Server Time Endpoint Is Up
    [Documentation]    Confirms /api/server_time is reachable and returns a timestamp.
    ${json}=    GET Server Time
    Response Should Contain Key    ${json}    server_time
    Log    ✅ SMOKE: server_time OK

Smoke - Pairs Endpoint Is Up
    [Documentation]    Confirms /api/pairs is reachable and returns a list.
    ${pairs}=    GET All Pairs
    List Should Not Be Empty    ${pairs}    pairs list
    Log    ✅ SMOKE: pairs OK — ${pairs.__len__()} pairs

Smoke - Summaries Endpoint Is Up
    [Documentation]    Confirms /api/summaries is reachable and returns a dict.
    ${json}=    GET Summaries
    ${type}=    Evaluate    type($json).__name__
    Should Be Equal    ${type}    dict
    Log    ✅ SMOKE: summaries OK

Smoke - BTC/IDR Ticker Is Up
    [Documentation]    Confirms /api/btcidr/ticker returns valid price data.
    ${json}=    GET Ticker For Pair    ${PAIR_BTC_IDR}
    Validate Ticker Response Structure    ${json}    ${PAIR_BTC_IDR}
    ${ticker}=    Get From Dictionary    ${json}    ticker
    Value Should Be Positive Number    ${ticker['last']}    BTC last price
    Log    ✅ SMOKE: BTC/IDR ticker OK — last=${ticker['last']}

Smoke - BTC/IDR Order Book Is Up
    [Documentation]    Confirms /api/btcidr/depth returns buy and sell arrays.
    ${json}=    GET Order Book For Pair    ${PAIR_BTC_IDR}
    Response Should Contain Keys    ${json}    buy    sell
    Log    ✅ SMOKE: BTC/IDR order book OK

Smoke - BTC/IDR Trades Is Up
    [Documentation]    Confirms /api/btcidr/trades returns a non-empty list.
    ${trades}=    GET Trades For Pair    ${PAIR_BTC_IDR}
    List Should Not Be Empty    ${trades}    trades
    Log    ✅ SMOKE: BTC/IDR trades OK — ${trades.__len__()} records
