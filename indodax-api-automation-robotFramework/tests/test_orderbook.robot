*** Settings ***
Documentation       Order Book (Depth) API Test Suite
...
...                 Covers: /api/{pair}/depth
...                 Tests include:
...                   - Data-driven happy path for multiple pairs
...                   - buy/sell array structure validation
...                   - Entry format: [price, volume]
...                   - Top-of-book spread (best ask >= best bid)
...                   - Minimum depth requirements
...                   - Response time SLA
...                   - Invalid pair handling
Suite Setup         Create Indodax Session
Suite Teardown      Teardown Indodax Session
Test Tags           api    public    orderbook
Resource            ../resources/keywords/common_keywords.robot
Resource            ../resources/keywords/api_assertions.robot
Resource            ../resources/variables/global_variables.robot

*** Test Cases ***

# ─── Data-Driven: Happy Path ──────────────────────────────────────────────────
Order Book - Happy Path For ${pair}
    [Documentation]    Fetch order book for each pair and run full validation.
    [Template]    Verify Order Book For Pair
    [Tags]    happy-path    data-driven
    btcidr
    ethidr
    usdtidr
    bnbidr

# ─── Contract Tests ───────────────────────────────────────────────────────────
Order Book - BTC/IDR Contains Buy And Sell Keys
    [Documentation]    Response must have top-level 'buy' and 'sell' arrays.
    [Tags]    contract    schema
    ${json}=    GET Order Book For Pair    ${PAIR_BTC_IDR}
    Response Should Contain Keys    ${json}    buy    sell

Order Book - BTC/IDR Buy And Sell Are Lists
    [Documentation]    Both 'buy' and 'sell' fields must be JSON arrays.
    [Tags]    contract    schema
    ${json}=    GET Order Book For Pair    ${PAIR_BTC_IDR}
    ${asks}=    Get From Dictionary    ${json}    sell
    ${bids}=    Get From Dictionary    ${json}    buy
    ${ask_type}=    Evaluate    type($asks).__name__
    ${bid_type}=    Evaluate    type($bids).__name__
    Should Be Equal    ${ask_type}    list    msg=sell field should be a list
    Should Be Equal    ${bid_type}    list    msg=buy field should be a list

# ─── Entry Format Integrity ───────────────────────────────────────────────────
Order Book - BTC/IDR Each Entry Is Price Volume Pair
    [Documentation]    Every entry in asks/bids must be [price_str, volume_str] with numeric values.
    [Tags]    integrity    format
    ${json}=    GET Order Book For Pair    ${PAIR_BTC_IDR}
    ${asks}=    Get From Dictionary    ${json}    sell
    ${bids}=    Get From Dictionary    ${json}    buy
    Validate Order Book Side    ${asks}    asks    ${PAIR_BTC_IDR}
    Validate Order Book Side    ${bids}    bids    ${PAIR_BTC_IDR}

Order Book - BTC/IDR Has Minimum Depth
    [Documentation]    Order book must have at least 1 level on each side.
    [Tags]    integrity    depth
    ${json}=    GET Order Book For Pair    ${PAIR_BTC_IDR}
    ${asks}=    Get From Dictionary    ${json}    sell
    ${bids}=    Get From Dictionary    ${json}    buy
    List Length Should Be At Least    ${asks}    1    asks (${PAIR_BTC_IDR})
    List Length Should Be At Least    ${bids}    1    bids (${PAIR_BTC_IDR})

# ─── Spread Integrity ─────────────────────────────────────────────────────────
Order Book - BTC/IDR Best Ask Is Greater Than Or Equal To Best Bid
    [Documentation]    Top-of-book: best ask must be >= best bid (no crossed spread).
    [Tags]    integrity    spread
    ${json}=    GET Order Book For Pair    ${PAIR_BTC_IDR}
    ${asks}=    Get From Dictionary    ${json}    sell
    ${bids}=    Get From Dictionary    ${json}    buy
    Validate Order Book Ordering    ${asks}    ${bids}    ${PAIR_BTC_IDR}

Order Book - BTC/IDR All Ask Prices Are Positive
    [Documentation]    Every ask price must be > 0.
    [Tags]    integrity    price
    ${json}=    GET Order Book For Pair    ${PAIR_BTC_IDR}
    ${asks}=    Get From Dictionary    ${json}    sell
    FOR    ${entry}    IN    @{asks}
        Value Should Be Positive Number    ${entry[0]}    ask price
    END

Order Book - BTC/IDR All Bid Prices Are Positive
    [Documentation]    Every bid price must be > 0.
    [Tags]    integrity    price
    ${json}=    GET Order Book For Pair    ${PAIR_BTC_IDR}
    ${bids}=    Get From Dictionary    ${json}    buy
    FOR    ${entry}    IN    @{bids}
        Value Should Be Positive Number    ${entry[0]}    bid price
    END

# ─── Performance ─────────────────────────────────────────────────────────────
Order Book - Response Time Is Within SLA
    [Documentation]    Order book response must arrive within 5 seconds.
    [Tags]    performance    sla
    ${url}=    Set Variable    ${PUBLIC_API_BASE}/${PAIR_BTC_IDR}/depth
    ${response}=    GET Public Endpoint    ${url}
    Status Code Should Be    ${response}    ${HTTP_200}
    Response Time Should Be Acceptable    ${response}    max_seconds=5

# ─── Negative Cases ───────────────────────────────────────────────────────────
Order Book - Invalid Pair Returns Non 200
    [Documentation]    An invalid pair symbol should not return HTTP 200.
    [Tags]    negative    error-handling
    ${url}=    Set Variable    ${PUBLIC_API_BASE}/${INVALID_PAIR}/depth
    ${response}=    GET Public Endpoint    ${url}
    Should Not Be Equal As Integers    ${response.status_code}    200
    ...    msg=Invalid pair '${INVALID_PAIR}' should not return HTTP 200
    Log    ✅ Invalid pair rejected with status: ${response.status_code}

*** Keywords ***
Verify Order Book For Pair
    [Documentation]    Template keyword: GET order book + full validation.
    [Arguments]    ${pair}
    Log To Console    \n▶ Testing order book for pair: ${pair}
    ${json}=    GET Order Book For Pair    ${pair}
    Full Order Book Validation    ${json}    ${pair}
