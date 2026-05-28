*** Settings ***
Documentation       Ticker API Test Suite
...
...                 Covers: /api/{pair}/ticker
...                 Tests include:
...                   - Data-driven happy path across multiple pairs
...                   - Field presence and value integrity
...                   - OHLC sanity (high >= low, last within range)
...                   - Spread validation (ask >= bid)
...                   - Volume non-negative
...                   - Response time SLA
...                   - Invalid pair handling
...
...                 Data source: resources/testdata/ticker_pairs.csv
Suite Setup         Create Indodax Session
Suite Teardown      Teardown Indodax Session
Test Tags           api    public    ticker
Resource            ../resources/keywords/common_keywords.robot
Resource            ../resources/keywords/api_assertions.robot
Resource            ../resources/variables/global_variables.robot

*** Test Cases ***

# ─── Data-Driven: Happy Path ──────────────────────────────────────────────────
Ticker - Happy Path For ${pair} (${description})
    [Documentation]    Fetch ticker for each pair defined in CSV; run full validation.
    [Template]    Verify Ticker For Pair
    [Tags]    happy-path    data-driven
    # pair         description
    btcidr         Bitcoin IDR pair
    ethidr         Ethereum IDR pair
    usdtidr        USDT IDR pair
    bnbidr         BNB IDR pair
    solidr         Solana IDR pair
    xrpidr         XRP IDR pair
    dogidr         Dogecoin IDR pair
    ltcidr         Litecoin IDR pair

# ─── Contract Tests ───────────────────────────────────────────────────────────
Ticker - BTC/IDR Response Contains Required Fields
    [Documentation]    Assert the ticker JSON schema contains all required keys.
    [Tags]    contract    schema
    ${json}=    GET Ticker For Pair    ${PAIR_BTC_IDR}
    Validate Ticker Response Structure    ${json}    ${PAIR_BTC_IDR}
    ${ticker}=    Get From Dictionary    ${json}    ticker
    Response Should Contain Keys    ${ticker}
    ...    high    low    vol_btc    vol_idr    last    buy    sell    server_time

Ticker - Server Time In Ticker Response Is Recent
    [Documentation]    server_time inside the ticker response must be a recent Unix timestamp.
    [Tags]    contract    timestamp
    ${json}=    GET Ticker For Pair    ${PAIR_BTC_IDR}
    ${ticker}=    Get From Dictionary    ${json}    ticker
    Timestamp Should Be Recent    ${ticker['server_time']}    max_age_seconds=300

# ─── Value Integrity ──────────────────────────────────────────────────────────
Ticker - BTC/IDR Price Fields Are Positive
    [Documentation]    last, high, low must be positive numbers.
    [Tags]    integrity    price
    ${json}=    GET Ticker For Pair    ${PAIR_BTC_IDR}
    ${ticker}=    Get From Dictionary    ${json}    ticker
    Value Should Be Positive Number    ${ticker['last']}    last price
    Value Should Be Positive Number    ${ticker['high']}    high price
    Value Should Be Positive Number    ${ticker['low']}     low price

Ticker - BTC/IDR High Is Greater Than Or Equal To Low
    [Documentation]    High must always be >= low. A violation means data corruption.
    [Tags]    integrity    ohlc
    ${json}=    GET Ticker For Pair    ${PAIR_BTC_IDR}
    ${ticker}=    Get From Dictionary    ${json}    ticker
    High Should Be Greater Than Or Equal To Low
    ...    ${ticker['high']}    ${ticker['low']}    ${PAIR_BTC_IDR}

Ticker - BTC/IDR Last Price Is Within High Low Range
    [Documentation]    Last price must fall within [low, high] range.
    [Tags]    integrity    ohlc
    ${json}=    GET Ticker For Pair    ${PAIR_BTC_IDR}
    ${ticker}=    Get From Dictionary    ${json}    ticker
    Last Price Should Be Between High And Low
    ...    ${ticker['last']}    ${ticker['high']}    ${ticker['low']}    ${PAIR_BTC_IDR}

Ticker - BTC/IDR Ask Is Greater Than Or Equal To Bid
    [Documentation]    sell (ask) >= buy (bid) — no crossed spread allowed.
    [Tags]    integrity    spread
    ${json}=    GET Ticker For Pair    ${PAIR_BTC_IDR}
    ${ticker}=    Get From Dictionary    ${json}    ticker
    Ask Should Be Greater Than Or Equal To Bid
    ...    ${ticker['sell']}    ${ticker['buy']}    ${PAIR_BTC_IDR}

Ticker - BTC/IDR Volume Is Non Negative
    [Documentation]    Trading volume for both base coin and IDR must be >= 0.
    [Tags]    integrity    volume
    ${json}=    GET Ticker For Pair    ${PAIR_BTC_IDR}
    ${ticker}=    Get From Dictionary    ${json}    ticker
    Value Should Be Non Negative Number    ${ticker['vol_btc']}    vol_btc
    Value Should Be Non Negative Number    ${ticker['vol_idr']}    vol_idr

# ─── Performance ─────────────────────────────────────────────────────────────
Ticker - Response Time Is Within SLA
    [Documentation]    Full ticker response must complete within 5 seconds.
    [Tags]    performance    sla
    ${url}=    Set Variable    ${TICKER_API_BASE}/${PAIR_BTC_IDR}/ticker
    ${response}=    GET Public Endpoint    ${url}
    Status Code Should Be    ${response}    ${HTTP_200}
    Response Time Should Be Acceptable    ${response}    max_seconds=5

# ─── Negative / Edge Cases ────────────────────────────────────────────────────
Ticker - Invalid Pair Returns 4xx
    [Documentation]    Requesting a non-existent pair must NOT return HTTP 200.
    ...                Acceptable: 400, 404, or any 4xx/5xx.
    [Tags]    negative    error-handling
    ${url}=    Set Variable    ${TICKER_API_BASE}/${INVALID_PAIR}/ticker
    ${response}=    GET Public Endpoint    ${url}
    Should Not Be Equal As Integers    ${response.status_code}    200
    ...    msg=Invalid pair '${INVALID_PAIR}' should not return HTTP 200
    Log    ✅ Invalid pair correctly rejected with status: ${response.status_code}

*** Keywords ***
Verify Ticker For Pair
    [Documentation]    Template keyword: GET ticker + run full validation suite.
    [Arguments]    ${pair}    ${description}
    Log To Console    \n▶ Testing ticker for pair: ${pair} (${description})
    ${json}=    GET Ticker For Pair    ${pair}
    Full Ticker Validation    ${json}    ${pair}
