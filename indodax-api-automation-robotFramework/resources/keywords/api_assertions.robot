*** Settings ***
Documentation       Domain-specific assertion keywords for Indodax market data.
...                 Each keyword is a reusable unit that can be composed into
...                 test cases without duplicating logic.
Library             Collections
Library             ../../libraries/IndodaxAPILibrary.py
Resource            ../variables/global_variables.robot

*** Keywords ***
# ═══════════════════════════════════════════════════════════════════════════════
# TICKER
# ═══════════════════════════════════════════════════════════════════════════════

Validate Ticker Response Structure
    [Documentation]    Assert that a ticker JSON has the required top-level 'ticker' key.
    [Arguments]    ${json}    ${pair}
    Response Should Contain Key    ${json}    ticker
    Log Response Summary    ${json}    pair=${pair}    endpoint=ticker

Validate Ticker Fields
    [Documentation]    Assert all mandatory ticker fields exist and are numeric/positive.
    [Arguments]    ${ticker}    ${pair}
    # Required fields
    Response Should Contain Keys    ${ticker}
    ...    high    low    vol_${pair[:3]}    vol_idr    last    buy    sell    server_time
    # Price integrity
    Value Should Be Positive Number    ${ticker['last']}     last price (${pair})
    Value Should Be Positive Number    ${ticker['high']}     high price (${pair})
    Value Should Be Positive Number    ${ticker['low']}      low price (${pair})
    Value Should Be Non Negative Number    ${ticker['buy']}  buy price (${pair})
    Value Should Be Non Negative Number    ${ticker['sell']}  sell price (${pair})
    # OHLC sanity
    High Should Be Greater Than Or Equal To Low
    ...    ${ticker['high']}    ${ticker['low']}    ${pair}
    Last Price Should Be Between High And Low
    ...    ${ticker['last']}    ${ticker['high']}    ${ticker['low']}    ${pair}

Validate Ticker Spread
    [Documentation]    Assert ask >= bid (no crossed spread) for a ticker.
    [Arguments]    ${ticker}    ${pair}
    Ask Should Be Greater Than Or Equal To Bid    ${ticker['sell']}    ${ticker['buy']}    ${pair}

Validate Ticker Volume
    [Documentation]    Assert both base and quote volumes are non-negative.
    [Arguments]    ${ticker}    ${pair}
    ${base_coin}=    Evaluate    "${pair}"[:3]
    ${vol_key}=      Set Variable    vol_${base_coin}
    Value Should Be Non Negative Number    ${ticker['${vol_key}']}    volume base (${pair})
    Value Should Be Non Negative Number    ${ticker['vol_idr']}        volume IDR (${pair})

Full Ticker Validation
    [Documentation]    Composite keyword: structure + fields + spread + volume.
    [Arguments]    ${json}    ${pair}
    Validate Ticker Response Structure    ${json}    ${pair}
    ${ticker}=    Get From Dictionary    ${json}    ticker
    Validate Ticker Fields    ${ticker}    ${pair}
    Validate Ticker Spread    ${ticker}    ${pair}
    Validate Ticker Volume    ${ticker}    ${pair}
    Log    ✅ Full ticker validation passed for pair: ${pair}

# ═══════════════════════════════════════════════════════════════════════════════
# ORDER BOOK (DEPTH)
# ═══════════════════════════════════════════════════════════════════════════════

Validate Order Book Structure
    [Documentation]    Assert order book JSON contains 'buy' and 'sell' arrays.
    [Arguments]    ${json}    ${pair}
    Response Should Contain Keys    ${json}    buy    sell
    Log    ✅ Order book structure valid for ${pair}

Validate Order Book Side
    [Documentation]    Assert each entry in a bid/ask list has [price, volume] format.
    [Arguments]    ${entries}    ${side}    ${pair}
    List Should Not Be Empty    ${entries}    ${side} side (${pair})
    FOR    ${entry}    IN    @{entries}
        Order Book Entry Should Have Valid Structure    ${entry}    ${side}
    END
    Log    ✅ All ${side} entries valid for ${pair}

Validate Order Book Ordering
    [Documentation]    Asks should be ascending price, bids descending price.
    [Arguments]    ${asks}    ${bids}    ${pair}
    # Check best ask >= best bid (top of book)
    ${best_ask}=    Evaluate    float("${asks[0][0]}")
    ${best_bid}=    Evaluate    float("${bids[0][0]}")
    Should Be True    ${best_ask} >= ${best_bid}
    ...    msg=Best ask (${best_ask}) < best bid (${best_bid}) for ${pair}
    Log    ✅ Top-of-book spread valid: ask=${best_ask}, bid=${best_bid}

Full Order Book Validation
    [Documentation]    Composite: structure + entry format + spread check.
    [Arguments]    ${json}    ${pair}
    Validate Order Book Structure    ${json}    ${pair}
    ${asks}=    Get From Dictionary    ${json}    sell
    ${bids}=    Get From Dictionary    ${json}    buy
    Validate Order Book Side    ${asks}    asks    ${pair}
    Validate Order Book Side    ${bids}    bids    ${pair}
    Validate Order Book Ordering    ${asks}    ${bids}    ${pair}
    Log    ✅ Full order book validation passed for: ${pair}

# ═══════════════════════════════════════════════════════════════════════════════
# TRADE HISTORY
# ═══════════════════════════════════════════════════════════════════════════════

Validate Trade Entry
    [Documentation]    Assert a single trade object has all required fields.
    [Arguments]    ${trade}    ${pair}
    Response Should Contain Keys    ${trade}
    ...    date    price    amount    tid    type
    Value Should Be Positive Number    ${trade['price']}     trade price (${pair})
    Value Should Be Positive Number    ${trade['amount']}    trade amount (${pair})
    # type must be 'buy' or 'sell'
    Should Be True    "${trade['type']}" in ["buy", "sell"]
    ...    msg=Trade type '${trade['type']}' is not 'buy' or 'sell' for ${pair}

Validate Trades Response
    [Documentation]    Composite: list non-empty + validate first N trades.
    [Arguments]    ${trades}    ${pair}    ${sample_count}=5
    List Should Not Be Empty    ${trades}    trades (${pair})
    ${total}=    Get Length    ${trades}
    ${check_count}=    Evaluate    min(${sample_count}, ${total})
    FOR    ${i}    IN RANGE    0    ${check_count}
        Validate Trade Entry    ${trades[${i}]}    ${pair}
    END
    Log    ✅ Validated ${check_count}/${total} trade entries for ${pair}

# ═══════════════════════════════════════════════════════════════════════════════
# PAIRS LIST
# ═══════════════════════════════════════════════════════════════════════════════

Validate Pair Object Fields
    [Documentation]    Assert a single pair dict has required metadata fields.
    [Arguments]    ${pair_obj}
    Response Should Contain Keys    ${pair_obj}
    ...    id    symbol    base_currency    traded_currency
    ...    traded_currency_unit    description    ticker_id
    Value Should Not Be Empty String    ${pair_obj['id']}               pair id
    Value Should Not Be Empty String    ${pair_obj['base_currency']}    base currency
    Value Should Not Be Empty String    ${pair_obj['traded_currency']}  traded currency
    Pair Name Should Match Convention    ${pair_obj['id']}

Validate Pairs List Response
    [Documentation]    Assert the /api/pairs endpoint returns a non-empty list of valid pairs.
    [Arguments]    ${pairs}
    List Should Not Be Empty    ${pairs}    pairs list
    Log Pairs Count    ${pairs}
    ${total}=    Get Length    ${pairs}
    ${check_count}=    Evaluate    min(5, ${total})
    FOR    ${i}    IN RANGE    0    ${check_count}
        Validate Pair Object Fields    ${pairs[${i}]}
    END
    Log    ✅ Pairs list validation passed (${check_count}/${total} spot-checked)

# ═══════════════════════════════════════════════════════════════════════════════
# SERVER TIME
# ═══════════════════════════════════════════════════════════════════════════════

Validate Server Time Response
    [Documentation]    Assert server_time field exists and is a recent Unix timestamp.
    [Arguments]    ${json}
    Response Should Contain Key    ${json}    server_time
    Timestamp Should Be Recent    ${json['server_time']}    max_age_seconds=300
    Log    ✅ Server time is valid and recent: ${json['server_time']}

# ═══════════════════════════════════════════════════════════════════════════════
# SUMMARIES
# ═══════════════════════════════════════════════════════════════════════════════

Validate Summaries Response
    [Documentation]    Assert the summaries endpoint returns a non-empty dict with ticker data.
    [Arguments]    ${json}
    ${type}=    Evaluate    type($json).__name__
    Should Be Equal    ${type}    dict
    ...    msg=Summaries response should be a dict, got: ${type}
    ${keys}=    Get Dictionary Keys    ${json}
    List Should Not Be Empty    ${keys}    summaries keys
    Log    ✅ Summaries response has ${len(${keys})} pairs.
