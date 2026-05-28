*** Settings ***
Documentation    Base Screen - Common mobile interactions for all screens
...
...              Provides reusable low-level mobile actions.
...              All screen objects should import this resource.

Library          AppiumLibrary
Resource         ../resources/variables.resource
Resource         ../resources/locators.resource


*** Keywords ***
# ============================================================
# SESSION MANAGEMENT
# ============================================================
Open Android App
    [Documentation]    Launch Indodax on Android device
    ${desired_caps}=    Create Dictionary
    ...    platformName=${ANDROID_PLATFORM}
    ...    platformVersion=${ANDROID_VERSION}
    ...    deviceName=${ANDROID_DEVICE}
    ...    automationName=${ANDROID_AUTOMATION}
    ...    appPackage=${ANDROID_PACKAGE}
    ...    appActivity=${ANDROID_ACTIVITY}
    ...    noReset=${ANDROID_NO_RESET}
    ...    newCommandTimeout=60
    Open Application    ${APPIUM_URL}    &{desired_caps}
    Set Appium Timeout    ${IMPLICIT_WAIT}

Open iOS App
    [Documentation]    Launch Indodax on iOS device
    ${desired_caps}=    Create Dictionary
    ...    platformName=${IOS_PLATFORM}
    ...    platformVersion=${IOS_VERSION}
    ...    deviceName=${IOS_DEVICE}
    ...    automationName=${IOS_AUTOMATION}
    ...    bundleId=${IOS_BUNDLE_ID}
    ...    noReset=${IOS_NO_RESET}
    ...    newCommandTimeout=60
    Open Application    ${APPIUM_URL}    &{desired_caps}
    Set Appium Timeout    ${IMPLICIT_WAIT}

Open Mobile App
    [Documentation]    Open app based on PLATFORM variable
    Run Keyword If    '${PLATFORM}' == 'Android'    Open Android App
    Run Keyword If    '${PLATFORM}' == 'iOS'        Open iOS App

Close Mobile App
    [Documentation]    Close current app session
    Close Application

# ============================================================
# WAITING
# ============================================================
Wait For Element Visible
    [Documentation]    Wait until element is visible
    [Arguments]    ${locator}    ${timeout}=${EXPLICIT_WAIT}
    Wait Until Element Is Visible    ${locator}    timeout=${timeout}

Wait For Element Not Visible
    [Documentation]    Wait until element disappears
    [Arguments]    ${locator}    ${timeout}=${EXPLICIT_WAIT}
    Wait Until Element Is Not Visible    ${locator}    timeout=${timeout}

Wait For App Ready
    [Documentation]    Wait for app to be fully loaded after launch
    Sleep    ${APP_LAUNCH_TIMEOUT}s
    # Wait for loading indicators to disappear
    Run Keyword And Ignore Error    
    ...    Wait Until Element Is Not Visible    ${LOC_LOADING_INDICATOR}    timeout=30

Wait For Loading To Complete
    [Documentation]    Wait until loading indicator disappears
    Sleep    1s
    Run Keyword And Ignore Error    
    ...    Wait Until Element Is Not Visible    ${LOC_PROGRESS_BAR}    timeout=${EXPLICIT_WAIT}

# ============================================================
# ELEMENT INTERACTIONS
# ============================================================
Tap Element Safely
    [Documentation]    Tap element after ensuring it is visible
    [Arguments]    ${locator}
    Wait Until Element Is Visible    ${locator}    timeout=${EXPLICIT_WAIT}
    Click Element    ${locator}

Input Text To Field
    [Documentation]    Clear field and input text
    [Arguments]    ${locator}    ${text}
    Wait Until Element Is Visible    ${locator}    timeout=${EXPLICIT_WAIT}
    Clear Text    ${locator}
    Input Text    ${locator}    ${text}

Get Element Text Safely
    [Documentation]    Get text from element
    [Arguments]    ${locator}
    Wait Until Element Is Visible    ${locator}    timeout=${EXPLICIT_WAIT}
    ${text}=    Get Text    ${locator}
    RETURN    ${text}

# ============================================================
# SWIPE / SCROLL
# ============================================================
Swipe Up On Screen
    [Documentation]    Swipe up to scroll down
    ${height}=    Get Window Height
    ${width}=    Get Window Width
    ${start_x}=    Evaluate    ${width} / 2
    ${start_y}=    Evaluate    ${height} * 0.7
    ${end_y}=    Evaluate    ${height} * 0.3
    Swipe    ${start_x}    ${start_y}    ${start_x}    ${end_y}    800

Swipe Down On Screen
    [Documentation]    Swipe down to scroll up (pull to refresh)
    ${height}=    Get Window Height
    ${width}=    Get Window Width
    ${start_x}=    Evaluate    ${width} / 2
    ${start_y}=    Evaluate    ${height} * 0.3
    ${end_y}=    Evaluate    ${height} * 0.7
    Swipe    ${start_x}    ${start_y}    ${start_x}    ${end_y}    800

Scroll To Element
    [Documentation]    Scroll until element is visible
    [Arguments]    ${locator}
    Scroll Element Into View    ${locator}

Pull To Refresh
    [Documentation]    Pull down to refresh the current screen
    Swipe Down On Screen
    Wait For Loading To Complete

# ============================================================
# ASSERTIONS
# ============================================================
Element Should Be Visible On Screen
    [Documentation]    Assert element is visible
    [Arguments]    ${locator}    ${message}=${EMPTY}
    ${status}=    Run Keyword And Return Status    
    ...    Element Should Be Visible    ${locator}
    Should Be True    ${status}    msg=${message}: Element '${locator}' not visible

Element Count Should Be Greater Than
    [Documentation]    Assert element count exceeds minimum
    [Arguments]    ${locator}    ${min_count}    ${message}=${EMPTY}
    ${elements}=    Get WebElements    ${locator}
    ${count}=    Get Length    ${elements}
    Should Be True    ${count} > ${min_count}
    ...    msg=${message}: Expected > ${min_count} elements, found ${count}

# ============================================================
# SCREENSHOT
# ============================================================
Capture Mobile Screenshot
    [Documentation]    Take screenshot with descriptive name
    [Arguments]    ${name}=mobile_screenshot
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    Capture Page Screenshot    filename=${MOBILE_SCREENSHOT_DIR}/${name}_${timestamp}.png

# ============================================================
# NAVIGATION
# ============================================================
Press Back Button
    [Documentation]    Press device back button
    Press Keycode    4    # Android back key

Hide Keyboard If Shown
    [Documentation]    Hide keyboard if visible
    Run Keyword And Ignore Error    Hide Keyboard
