*** Settings ***
Documentation    Data-Driven Test Suite: Multiple Market Pairs Verification
...
...              Uses DataDriver library to run same test with multiple data sets.
...              Tests that various market pair pages are accessible and functional.

Resource         ../keywords/market_keywords.resource
Library          DataDriver    file=../data/market_pairs.csv    encoding=UTF-8

Suite Setup      Open Browser Session    browser=${BROWSER}    headless=${HEADLESS}
Suite Teardown   Close Browser Session

Test Setup       NONE
Test Teardown    Run Keyword If Test Failed    Capture Market Page Screenshot    ${TEST_NAME}

Force Tags       web    data-driven    market-pairs


*** Test Cases ***

TC_WEB_DD - Verify Market Pair Page Is Accessible
    [Documentation]    Data-driven: Verify each market pair page loads correctly
    [Tags]    data-driven    pairs
    [Template]    Verify Market Pair Page Is Accessible
    ${PAIR}    ${BASE_COIN}    ${QUOTE_COIN}
