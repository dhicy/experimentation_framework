*** Settings ***
Documentation       Trade History API Test Suite
...
...                 Covers: /api/{pair}/trades
...                 Tests include:
...                   - Data-driven happy path for multiple pairs
...                   - Trade object schema (date, price, amount, tid, type)
...                   - Trade type must be 'buy' or 'sell'
...                   - Numeric field validation (price, amount > 0)
...                   - Chronological ordering check
...                   - Response time SLA
Suite Setup         Create Indodax Session
Suite Teardown      Teardown Indodax Session
Test Tags           api    public    trades
Resource            ../resources/keywords/common_keywords.robot
Resource            ../resources/keywords/api_assertions.robot
Resource            ../resources/variables/global_variables.robot

*** Test Cases ***

# ─── Data-Driven: Happy Path ──────────────────────────────────────────────────
Trades - Happy Path For ${pair}
    [Documentation]    Fetch recent trades for each pair and run full validation.
    [Template]    Verify Trades For Pair
    [Tags]    happy-path    data-driven
    btcidr
    ethidr
    usdtidr

# ─── Contract Tests ───────────────────────────────────────────────────────────
Trades - BTC/IDR Response Is A List
    [Documentation]    The trades response must be a JSON array, not a dict.
    [Tags]    contract    schema
    ${json}=    GET Trades For Pair    ${PAIR_BTC_IDR}
    ${type}=    Evaluate    type($json).__name__
    Should Be Equal    ${type}    list    msg=Trades response should be a list, got: ${type}

Trades - BTC/IDR Each Trade Has Required Fields
    [Documentation]    Spot-check first trade for all required field keys.
    [Tags]    contract    schema
    ${trades}=    GET Trades For Pair    ${PAIR_BTC_IDR}
    List Should Not Be Empty    ${trades}    trades list
    ${first}=    Get From List    ${trades}    0
    Response Should Contain Keys    ${first}
    ...    date    price    amount    tid    type

# ─── Value Integrity ──────────────────────────────────────────────────────────
Trades - BTC/IDR Price Is Positive
    [Documentation]    Trade price must be a positive number in every record.
    [Tags]    integrity    price
    ${trades}=    GET Trades For Pair    ${PAIR_BTC_IDR}
    ${total}=    Get Length    ${trades}
    ${check_count}=    Evaluate    min(10, ${total})
    FOR    ${i}    IN RANGE    0    ${check_count}
        ${trade}=    Get From List    ${trades}    ${i}
        Value Should Be Positive Number    ${trade['price']}    trade[${i}] price
    END

Trades - BTC/IDR Amount Is Positive
    [Documentation]    Trade amount (volume) must be > 0 in every record.
    [Tags]    integrity    volume
    ${trades}=    GET Trades For Pair    ${PAIR_BTC_IDR}
    ${total}=    Get Length    ${trades}
    ${check_count}=    Evaluate    min(10, ${total})
    FOR    ${i}    IN RANGE    0    ${check_count}
        ${trade}=    Get From List    ${trades}    ${i}
        Value Should Be Positive Number    ${trade['amount']}    trade[${i}] amount
    END

Trades - BTC/IDR Type Is Buy Or Sell
    [Documentation]    Trade type must be exactly 'buy' or 'sell'. No other values allowed.
    [Tags]    integrity    enum
    ${trades}=    GET Trades For Pair    ${PAIR_BTC_IDR}
    ${total}=    Get Length    ${trades}
    ${check_count}=    Evaluate    min(20, ${total})
    FOR    ${i}    IN RANGE    0    ${check_count}
        ${trade}=    Get From List    ${trades}    ${i}
        Should Be True    "${trade['type']}" in ["buy", "sell"]
        ...    msg=trade[${i}] type='${trade['type']}' — must be 'buy' or 'sell'
    END
    Log    ✅ All ${check_count} sampled trade types are valid.

Trades - BTC/IDR TID Is Unique
    [Documentation]    Transaction IDs (tid) in a response must be unique (no duplicate records).
    [Tags]    integrity    uniqueness
    ${trades}=    GET Trades For Pair    ${PAIR_BTC_IDR}
    ${tids}=    Evaluate    [t['tid'] for t in $trades]
    ${unique_count}=    Evaluate    len(set($tids))
    ${total}=    Get Length    ${trades}
    Should Be Equal As Integers    ${unique_count}    ${total}
    ...    msg=Found duplicate TIDs: ${total} trades but only ${unique_count} unique TIDs
    Log    ✅ All ${total} TIDs are unique.

Trades - BTC/IDR Timestamps Are In Descending Order
    [Documentation]    Trades should be returned newest-first (descending date/timestamp).
    [Tags]    integrity    ordering
    ${trades}=    GET Trades For Pair    ${PAIR_BTC_IDR}
    ${total}=    Get Length    ${trades}
    IF    ${total} >= 2
        ${check_count}=    Evaluate    min(10, ${total})
        FOR    ${i}    IN RANGE    0    ${check_count} - 1
            ${current}=    Get From List    ${trades}    ${i}
            ${next}=       Get From List    ${trades}    ${i+1}
            ${curr_ts}=    Evaluate    int("${current['date']}")
            ${next_ts}=    Evaluate    int("${next['date']}")
            Should Be True    ${curr_ts} >= ${next_ts}
            ...    msg=Trades are not in descending order at index ${i}: ${curr_ts} < ${next_ts}
        END
        Log    ✅ Trade timestamps are in descending order.
    ELSE
        Log    ⚠ Not enough trades to check ordering (got ${total})
    END

# ─── Performance ─────────────────────────────────────────────────────────────
Trades - Response Time Is Within SLA
    [Documentation]    Trade history response must complete within 5 seconds.
    [Tags]    performance    sla
    ${url}=    Set Variable    ${PUBLIC_API_BASE}/${PAIR_BTC_IDR}/trades
    ${response}=    GET Public Endpoint    ${url}
    Status Code Should Be    ${response}    ${HTTP_200}
    Response Time Should Be Acceptable    ${response}    max_seconds=5

# ─── Negative Cases ───────────────────────────────────────────────────────────
Trades - Invalid Pair Returns Non 200
    [Documentation]    Invalid pair should not return HTTP 200.
    [Tags]    negative    error-handling
    ${url}=    Set Variable    ${PUBLIC_API_BASE}/${INVALID_PAIR}/trades
    ${response}=    GET Public Endpoint    ${url}
    Should Not Be Equal As Integers    ${response.status_code}    200
    ...    msg=Invalid pair '${INVALID_PAIR}' should not return HTTP 200
    Log    ✅ Invalid pair rejected: ${response.status_code}

*** Keywords ***
Verify Trades For Pair
    [Documentation]    Template keyword: GET trades + full validation.
    [Arguments]    ${pair}
    Log To Console    \n▶ Testing trades for pair: ${pair}
    ${trades}=    GET Trades For Pair    ${pair}
    Validate Trades Response    ${trades}    ${pair}
