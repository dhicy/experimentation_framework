*** Settings ***
Documentation    Base Page Object - Common actions for all web pages
...
...              Provides reusable low-level browser interactions.
...              All page objects should import this resource.

Library          Browser
Resource         ../resources/variables.resource
Resource         ../resources/locators.resource


*** Keywords ***
Open Browser Session
    [Documentation]    Initialize browser and open new session
    [Arguments]    ${browser}=${BROWSER}    ${headless}=${HEADLESS}
    New Browser    browser=${browser}    headless=${headless}
    New Context    viewport={'width': ${VIEWPORT_WIDTH}, 'height': ${VIEWPORT_HEIGHT}}
    New Page

Close Browser Session
    [Documentation]    Close current browser session
    Close Browser

Navigate To URL
    [Documentation]    Navigate to given URL and wait for page to load
    [Arguments]    ${url}
    Go To    ${url}
    Wait Until Network Is Idle    timeout=${PAGE_LOAD_TIMEOUT}ms

Wait For Element Visible
    [Documentation]    Wait until element is visible with timeout
    [Arguments]    ${locator}    ${timeout}=${ELEMENT_TIMEOUT}ms
    Wait For Elements State    ${locator}    visible    timeout=${timeout}

Wait For Element Hidden
    [Documentation]    Wait until element is hidden
    [Arguments]    ${locator}    ${timeout}=${ELEMENT_TIMEOUT}ms
    Wait For Elements State    ${locator}    hidden    timeout=${timeout}

Click Element Safely
    [Documentation]    Click element after ensuring it is visible and enabled
    [Arguments]    ${locator}
    Wait For Elements State    ${locator}    visible    timeout=${ELEMENT_TIMEOUT}ms
    Wait For Elements State    ${locator}    enabled    timeout=${SHORT_TIMEOUT}ms
    Click    ${locator}

Get Text Safely
    [Documentation]    Get text from element after ensuring it is visible
    [Arguments]    ${locator}
    Wait For Elements State    ${locator}    visible    timeout=${ELEMENT_TIMEOUT}ms
    ${text}=    Get Text    ${locator}
    RETURN    ${text}

Element Should Contain Text
    [Documentation]    Assert element contains expected text
    [Arguments]    ${locator}    ${expected_text}    ${message}=${EMPTY}
    Wait For Elements State    ${locator}    visible    timeout=${ELEMENT_TIMEOUT}ms
    ${actual_text}=    Get Text    ${locator}
    Should Contain    ${actual_text}    ${expected_text}    msg=${message}

Element Text Should Match Pattern
    [Documentation]    Assert element text matches regex pattern
    [Arguments]    ${locator}    ${pattern}    ${message}=${EMPTY}
    ${text}=    Get Text Safely    ${locator}
    Should Match Regexp    ${text}    ${pattern}    msg=${message}

Element Should Be Visible
    [Documentation]    Assert element is visible on page
    [Arguments]    ${locator}    ${message}=${EMPTY}
    ${status}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${locator}    visible    timeout=${ELEMENT_TIMEOUT}ms
    Should Be True    ${status}    msg=${message}: Element '${locator}' should be visible

Element Count Should Be Greater Than
    [Documentation]    Assert number of elements is greater than minimum
    [Arguments]    ${locator}    ${min_count}    ${message}=${EMPTY}
    ${elements}=    Get Elements    ${locator}
    ${count}=    Get Length    ${elements}
    Should Be True    ${count} > ${min_count}
    ...    msg=${message}: Expected more than ${min_count} elements, found ${count}

Scroll To Element
    [Documentation]    Scroll page until element is in view
    [Arguments]    ${locator}
    Scroll To Element    ${locator}

Take Screenshot With Name
    [Documentation]    Take screenshot with descriptive name
    [Arguments]    ${name}
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    Take Screenshot    filename=${SCREENSHOT_DIR}/${name}_${timestamp}.png

Page Should Contain Element
    [Documentation]    Assert page contains element
    [Arguments]    ${locator}    ${message}=${EMPTY}
    ${count}=    Get Element Count    ${locator}
    Should Be True    ${count} > 0    msg=${message}: Element '${locator}' not found on page

Get Current Page URL
    [Documentation]    Return current page URL
    ${url}=    Get Url
    RETURN    ${url}

Get Current Page Title
    [Documentation]    Return current page title
    ${title}=    Get Title
    RETURN    ${title}

Input Text Safely
    [Documentation]    Clear and type text in input field
    [Arguments]    ${locator}    ${text}
    Wait For Elements State    ${locator}    visible    timeout=${ELEMENT_TIMEOUT}ms
    Clear Text    ${locator}
    Fill Text    ${locator}    ${text}

Wait For Page Load Complete
    [Documentation]    Wait for page to be fully loaded
    Wait Until Network Is Idle    timeout=${PAGE_LOAD_TIMEOUT}ms
