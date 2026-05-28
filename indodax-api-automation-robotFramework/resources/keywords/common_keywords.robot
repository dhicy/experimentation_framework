*** Settings ***
Documentation       Base request keywords used across all test suites.
...                 Wraps RequestsLibrary with logging, retries, and assertion helpers.
Library             RequestsLibrary
Library             Collections
Library             String
Library             OperatingSystem
Library             ../../libraries/IndodaxAPILibrary.py
Resource            ../variables/global_variables.robot

*** Keywords ***
Create Indodax Session
    [Documentation]    Create a persistent HTTP session toward the Indodax base URL.
    ...                Must be called in Suite Setup before any request keyword.
    Create Session    indodax    ${BASE_URL}    verify=True    timeout=${REQUEST_TIMEOUT}
    Log    🔗 Session created → ${BASE_URL}

Teardown Indodax Session
    [Documentation]    Delete the shared HTTP session. Call in Suite Teardown.
    Delete All Sessions
    Log    🔒 Session closed.

# ─── Core Request Primitives ──────────────────────────────────────────────────

GET Public Endpoint
    [Documentation]    Perform a GET against *url* (absolute).
    ...                Returns the full response object.
    [Arguments]    ${url}    ${params}=${NONE}
    ${response}=    GET On Session    indodax    ${url}    params=${params}
    ...             expected_status=any
    Log    → GET ${url} params=${params} status=${response.status_code}
    RETURN    ${response}

# ─── Response Assertion Primitives ───────────────────────────────────────────

Status Code Should Be
    [Documentation]    Assert HTTP status code equals *expected*.
    [Arguments]    ${response}    ${expected}=${HTTP_200}
    Should Be Equal As Integers    ${response.status_code}    ${expected}
    ...    msg=Expected HTTP ${expected}, got ${response.status_code}. Body: ${response.text[:300]}
    Log    ✅ Status code = ${response.status_code}

Response Should Be Valid JSON
    [Documentation]    Assert response body is parseable JSON and return the dict/list.
    [Arguments]    ${response}
    ${json}=    Evaluate    __import__('json').loads($response.text)    modules=json
    Log    ✅ Response is valid JSON.
    RETURN    ${json}

Response Time Should Be Acceptable
    [Documentation]    Assert response elapsed time <= *max_seconds*.
    [Arguments]    ${response}    ${max_seconds}=5
    ${elapsed}=    Evaluate    $response.elapsed.total_seconds()
    Should Be True    ${elapsed} <= ${max_seconds}
    ...    msg=Response too slow: ${elapsed}s > ${max_seconds}s threshold
    Log    ⏱ Response time = ${elapsed}s (limit ${max_seconds}s)

# ─── High-level Composed Helpers ─────────────────────────────────────────────

GET And Validate Public API
    [Documentation]    GET *url*, assert HTTP 200, parse JSON, check response time.
    ...                Returns parsed JSON body.
    [Arguments]    ${url}    ${params}=${NONE}    ${max_seconds}=5
    ${response}=    GET Public Endpoint    ${url}    params=${params}
    Status Code Should Be    ${response}    ${HTTP_200}
    Response Time Should Be Acceptable    ${response}    ${max_seconds}
    ${json}=    Response Should Be Valid JSON    ${response}
    RETURN    ${json}

GET Ticker For Pair
    [Documentation]    Fetch the ticker for *pair* and return parsed JSON.
    [Arguments]    ${pair}
    ${url}=    Set Variable    ${TICKER_API_BASE}/${pair}/ticker
    ${json}=    GET And Validate Public API    ${url}
    RETURN    ${json}

GET Order Book For Pair
    [Documentation]    Fetch order book (depth) for *pair* and return parsed JSON.
    [Arguments]    ${pair}
    ${url}=    Set Variable    ${PUBLIC_API_BASE}/${pair}/depth
    ${json}=    GET And Validate Public API    ${url}
    RETURN    ${json}

GET Trades For Pair
    [Documentation]    Fetch recent trades for *pair* and return parsed JSON.
    [Arguments]    ${pair}
    ${url}=    Set Variable    ${PUBLIC_API_BASE}/${pair}/trades
    ${json}=    GET And Validate Public API    ${url}
    RETURN    ${json}

GET OHLC For Pair
    [Documentation]    Fetch OHLC chart data for *pair* and return parsed JSON.
    [Arguments]    ${pair}    ${tf}=day
    ${url}=    Set Variable    ${PUBLIC_API_BASE}/${pair}/chart_data
    ${json}=    GET And Validate Public API    ${url}
    RETURN    ${json}

GET Server Time
    [Documentation]    Fetch server time and return parsed JSON.
    ${json}=    GET And Validate Public API    ${SERVER_TIME_URL}
    RETURN    ${json}

GET All Pairs
    [Documentation]    Fetch the list of all trading pairs and return parsed JSON.
    ${json}=    GET And Validate Public API    ${PAIRS_URL}
    RETURN    ${json}

GET Summaries
    [Documentation]    Fetch market summaries and return parsed JSON.
    ${json}=    GET And Validate Public API    ${SUMMARIES_URL}
    RETURN    ${json}
