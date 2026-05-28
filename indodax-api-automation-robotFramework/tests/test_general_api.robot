*** Settings ***
Documentation       General Public API Test Suite
...
...                 Covers:
...                   - /api/server_time       → server time sync check
...                   - /api/pairs             → trading pair catalogue
...                   - /api/summaries         → market-wide snapshot
...
...                 Tests include schema, value integrity, and performance.
Suite Setup         Create Indodax Session
Suite Teardown      Teardown Indodax Session
Test Tags           api    public    general
Resource            ../resources/keywords/common_keywords.robot
Resource            ../resources/keywords/api_assertions.robot
Resource            ../resources/variables/global_variables.robot

*** Test Cases ***

# ═══════════════════════════════════════════════════════
# SERVER TIME
# ═══════════════════════════════════════════════════════

Server Time - Endpoint Returns HTTP 200
    [Documentation]    /api/server_time must return HTTP 200.
    [Tags]    server-time    smoke
    ${json}=    GET Server Time
    Response Should Contain Key    ${json}    server_time

Server Time - Response Contains server_time Key
    [Documentation]    Response body must contain 'server_time' field.
    [Tags]    server-time    contract
    ${json}=    GET Server Time
    Response Should Contain Key    ${json}    server_time

Server Time - Timestamp Is A Recent Unix Timestamp
    [Documentation]    server_time should be a Unix epoch within 5 minutes of now.
    [Tags]    server-time    integrity
    ${json}=    GET Server Time
    Validate Server Time Response    ${json}

Server Time - Response Time Is Within SLA
    [Documentation]    Server time endpoint must respond in under 3 seconds.
    [Tags]    server-time    performance
    ${url}=    Set Variable    ${SERVER_TIME_URL}
    ${response}=    GET Public Endpoint    ${url}
    Status Code Should Be    ${response}    ${HTTP_200}
    Response Time Should Be Acceptable    ${response}    max_seconds=3

# ═══════════════════════════════════════════════════════
# PAIRS LIST
# ═══════════════════════════════════════════════════════

Pairs - Endpoint Returns HTTP 200
    [Documentation]    /api/pairs must return HTTP 200.
    [Tags]    pairs    smoke
    ${json}=    GET All Pairs
    ${type}=    Evaluate    type($json).__name__
    Should Be Equal    ${type}    list

Pairs - Response Is A Non-Empty List
    [Documentation]    The pairs list must not be empty.
    [Tags]    pairs    contract
    ${pairs}=    GET All Pairs
    List Should Not Be Empty    ${pairs}    pairs list

Pairs - Each Pair Has Required Fields
    [Documentation]    Spot-check up to 5 pairs for mandatory metadata fields.
    [Tags]    pairs    contract    schema
    ${pairs}=    GET All Pairs
    Validate Pairs List Response    ${pairs}

Pairs - Total Count Exceeds Reasonable Minimum
    [Documentation]    Indodax supports many pairs; must have > 10.
    [Tags]    pairs    integrity
    ${pairs}=    GET All Pairs
    ${count}=    Get Length    ${pairs}
    Should Be True    ${count} > 10
    ...    msg=Expected > 10 pairs, got ${count}
    Log    📊 Total pairs: ${count}

Pairs - BTC/IDR Is Present In List
    [Documentation]    BTC/IDR (btcidr) must exist in the pairs catalogue.
    [Tags]    pairs    integrity    regression
    ${pairs}=    GET All Pairs
    ${ids}=    Evaluate    [p.get('id','') for p in $pairs]
    Should Contain    ${ids}    ${PAIR_BTC_IDR}
    ...    msg=Pair '${PAIR_BTC_IDR}' not found in pairs list

Pairs - ETH/IDR Is Present In List
    [Documentation]    ETH/IDR must exist in the pairs catalogue.
    [Tags]    pairs    integrity    regression
    ${pairs}=    GET All Pairs
    ${ids}=    Evaluate    [p.get('id','') for p in $pairs]
    Should Contain    ${ids}    ${PAIR_ETH_IDR}
    ...    msg=Pair '${PAIR_ETH_IDR}' not found in pairs list

Pairs - All Pair IDs Match Naming Convention
    [Documentation]    Every pair id must be lowercase alphanumeric (e.g. btcidr).
    [Tags]    pairs    integrity    naming
    ${pairs}=    GET All Pairs
    ${total}=    Get Length    ${pairs}
    ${check_count}=    Evaluate    min(20, ${total})
    FOR    ${i}    IN RANGE    0    ${check_count}
        ${pair}=    Get From List    ${pairs}    ${i}
        Pair Name Should Match Convention    ${pair['id']}
    END
    Log    ✅ ${check_count} pair IDs all match lowercase-alphanumeric convention.

Pairs - Base Currency Is IDR For All Spot Pairs
    [Documentation]    Indodax is an IDR exchange; base_currency should be 'idr'.
    [Tags]    pairs    integrity    business-rule
    ${pairs}=    GET All Pairs
    ${total}=    Get Length    ${pairs}
    ${check_count}=    Evaluate    min(20, ${total})
    FOR    ${i}    IN RANGE    0    ${check_count}
        ${pair}=    Get From List    ${pairs}    ${i}
        ${base}=    Get From Dictionary    ${pair}    base_currency
        Should Be Equal As Strings    ${base}    idr
        ...    msg=Pair '${pair['id']}' base_currency = '${base}', expected 'idr'
    END
    Log    ✅ ${check_count} pairs confirmed with base_currency = 'idr'.

Pairs - Response Time Is Within SLA
    [Documentation]    Pairs endpoint must respond within 5 seconds.
    [Tags]    pairs    performance
    ${url}=    Set Variable    ${PAIRS_URL}
    ${response}=    GET Public Endpoint    ${url}
    Status Code Should Be    ${response}    ${HTTP_200}
    Response Time Should Be Acceptable    ${response}    max_seconds=5

# ═══════════════════════════════════════════════════════
# SUMMARIES
# ═══════════════════════════════════════════════════════

Summaries - Endpoint Returns HTTP 200
    [Documentation]    /api/summaries must return HTTP 200.
    [Tags]    summaries    smoke
    ${json}=    GET Summaries
    ${type}=    Evaluate    type($json).__name__
    Should Be Equal    ${type}    dict

Summaries - Response Is Non-Empty Dict
    [Documentation]    Summaries response must be a non-empty dictionary.
    [Tags]    summaries    contract
    ${json}=    GET Summaries
    Validate Summaries Response    ${json}

Summaries - BTC/IDR Key Exists In Summaries
    [Documentation]    The summary for btc_idr pair must be present.
    [Tags]    summaries    integrity    regression
    ${json}=    GET Summaries
    ${keys}=    Get Dictionary Keys    ${json}
    # Summaries uses underscore format: btc_idr
    Should Contain    ${keys}    btc_idr
    ...    msg=Expected 'btc_idr' key in summaries. Available: ${keys[:5]}

Summaries - Response Time Is Within SLA
    [Documentation]    Summaries endpoint must respond within 5 seconds.
    [Tags]    summaries    performance
    ${url}=    Set Variable    ${SUMMARIES_URL}
    ${response}=    GET Public Endpoint    ${url}
    Status Code Should Be    ${response}    ${HTTP_200}
    Response Time Should Be Acceptable    ${response}    max_seconds=5
