*** Settings ***
Documentation    File with .robot extension with two test keywords

*** Keywords ***
Keyword 1 Imported From Robot File
    [Documentation]   This keyword was imported from file
    ...    with .robot extension
    Log    This keyword was imported from file with .resource extension, available since RFWK 3.1

Keyword 2 Imported From Robot File
    [Documentation]   This keyword was imported from file
    ...    with .robot extension
    [Arguments]    ${arg_1}    ${arg_2}
    Log    This keyword was imported from file with .resource extension, available since RFWK 3.1

Keyword With Args With Single Quotation Mark
    [Documentation]    Keyword With Args With Single Quotation Mark
    [Arguments]    ${ok_argument}    ${not_ok_argument}=Kill.${app.replace('-', '_')}

Keyword With Args With Double Quotation Mark
    [Documentation]    Keyword With Args With Double Quotation Mark
    [Arguments]    ${ok_argument}    ${not_ok_argument}=Kill.${app.replace("-", "_")}
