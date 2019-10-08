*** Test Cases ***
Test 1
    Keyword 1 Not Imported From Robot File

*** Keywords ***
Keyword 1 Not Imported From Robot File
    [Documentation]   This keyword should not be imported from file with .robot extension
    Log    This keyword was not imported from file with .robot

Keyword With Exotic Characters
    [Documentation]    I'm keyword with exotic characters "𝕂", "𐀀", "😓", "🂲"
    Log    I'm keyword with exotic characters "𝕂", "𐀀", "😓", "🂲"
