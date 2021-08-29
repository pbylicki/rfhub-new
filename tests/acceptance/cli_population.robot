*** Settings ***
Resource    resources/keywords.resource
Resource    resources/variables.resource

*** Test Cases ***
Cli Should Populate App With Keywords From Provided Paths Only
    [Documentation]    Cli Should Populate App With Keywords From Provided Paths Only
    [Tags]    rfhub2-153
    Run Cli Package Without Installed Keywords
    Output Should Contain
    ...    LibWithInit library with 4 keywords loaded.
    ...    Test Libdoc File library with 1 keywords loaded.
    ...    LibWithEmptyInit1 library with 2 keywords loaded.
    ...    test_resource library with 2 keywords loaded.
    ...    SingleClassLib library with 3 keywords loaded.
    ...    LibWithEmptyInit2 library with 2 keywords loaded.
    ...    test_robot library with 4 keywords loaded.
    ...    test_res_lib_dir library with 2 keywords loaded.
    ...    Successfully loaded 8 collections with 20 keywords.
    Api Should Have 8 Collections And 20 Keywords

Cli Should Populate App With Installed Keywords
    [Documentation]    Cli Should Populate App With Installed Keywords
    Run Cli Package With Options    --load-mode=insert
    Output Should Contain
    ...    Collections library with 43 keywords loaded.
    ...    XML library with 37 keywords loaded.
    ...    Easter library with 1 keywords loaded.
    ...    Process library with 15 keywords loaded.
    ...    String library with 32 keywords loaded.
    ...    DateTime library with 8 keywords loaded.
    ...    OperatingSystem library with 56 keywords loaded.
    ...    Screenshot library with 3 keywords loaded.
    ...    BuiltIn library with 105 keywords loaded.
    ...    Telnet library with 20 keywords loaded.
    ...    Successfully loaded 10 collections with 320 keywords.
    Api Should Have 10 Collections And 100 Keywords

Cli Should Preserve All Keywords When Paths And Append Set
    [Documentation]    Cli Should Preserve All Keywords When Paths And Append Set
    ...                This test is dependant on one above:
    ...                'Cli Should Populate App With Installed Keywords'
    Run Cli Package With Options    --load-mode=append --no-installed-keywords
    Output Should Contain
    ...    Successfully loaded 0 collections with 0 keywords.
    Api Should Have 10 Collections And 100 Keywords

Cli Should Delete All Keywords When Paths And No Installed Keywords Set
    [Documentation]    Cli Should Delete All Keywords When Paths And No Installed Keywords Set
    Run Cli Package With Options    --load-mode=insert --no-installed-keywords
    Output Should Contain
    ...    Successfully loaded 0 collections with 0 keywords.
    Api Should Have 0 Collections And 0 Keywords

Cli Should Return Unauthorised When Wrong User Given
    [Documentation]    Cli Should Return Unauthorised When Wrong User Given
    Run Cli Package With Options    -u wrong_user
    Output Should Contain    Unauthorized to perform this action

Cli Should Return Unauthorised When Wrong Password Given
    [Documentation]    Cli Should Return Unauthorised When Wrong Password Given
    Run Cli Package With Options    -p wrong_pass
    Output Should Contain    Unauthorized to perform this action

Cli Should Return Connection Error When Wrong Url Given
    [Documentation]    Cli Should Return Connection Error When Wrong Url Given
    Run Cli Package With Options    -a 123.456.789.123:666
    Should Contain    ${output}    No connection adapters were found

Cli Should Update Existing Collections, Delete Obsolete And Add New
    [Documentation]     Cli Should Update Existing Collections, 
    ...    Delete Obsolete And Add New.
    [Tags]    rfhub2-64
    [Setup]    Run Keywords
    ...    Run Cli Package Without Installed Keywords
    ...    Backup And Switch Initial With Updated Fixtures
    Run Cli Package With Options
    ...    --load-mode=update --no-installed-keywords ${INITIAL_FIXTURES}
    Output Should Contain
    ...    SingleClassLib library with 4 keywords loaded.
    ...    test_resource library with 2 keywords loaded.
    ...    Test Libdoc File library with 1 keywords loaded.
    ...    Test Libdoc File Copy library with 1 keywords loaded.

Cli Update Load Mode Should Leave Application With New Set Of Collections
    [Documentation]     Cli Update Load Mode Should Leave Application 
    ...    With New Set Of Collections. This test bases on 
    ...    'Cli Should Update Existing Collections, Delete Obsolete And Add New' 
    ...    to speed up execution
    [Tags]    rfhub2-64    update
    Api Should Have 7 Collections And 16 Keywords
    
Running Cli Update Load Mode Second Time Should Leave Collections Untouched
    [Documentation]    Running Cli Update Load Mode Second Time 
    ...    Should Leave Collections Untouched. This test bases on 
    ...    'Cli Should Update Existing Collections, Delete Obsolete And Add New' 
    ...    to speed up execution
    [Tags]    rfhub2-64    update
    Run Cli Package With Options
    ...    --load-mode=update --no-installed-keywords ${INITIAL_FIXTURES}
    Output Should Contain    Successfully loaded 0 collections with 0 keywords.
    [Teardown]    Run Keywords    Restore Initial Fixtures    AND
    ...    Run Cli Package With Options
    ...    --load-mode=insert --no-installed-keywords

Cli Merge Load Mode Should Update Existing Libraries And Do Not Remove Not Provided Paths
    [Documentation]     Cli Merge Load Mode Should Leave Application
    ...    With Matched Collections Updated Without Not Matched Collection Removal
    [Tags]    rfhub2-64    merge
    [Setup]    Run Keywords
    ...    Run Cli Package Without Installed Keywords
    ...    Backup And Switch Initial With Merged Fixtures
    Run Cli Package With Options
    ...    --load-mode=merge --no-installed-keywords ${INITIAL_FIXTURES}
    Api Should Have 9 Collections And 22 Keywords

Cli Merge Load Mode Should Update Existing Resources And Do Not Remove Not Provided Paths
    [Documentation]     Cli Merge Load Mode Should Leave Application
    ...    With Matched Collections Updated Without Not Matched Collection Removal
    ...    This test bases on
    ...    'Cli Merge Load Mode Should Update Existing Libraries And Do Not Remove Not Provided Paths'
    ...    to speed up execution
    [Tags]    rfhub2-64    merge
    [Setup]    Switch Merged With Merged_2 Fixtures
    Run Cli Package With Options
    ...    --load-mode=merge --no-installed-keywords ${INITIAL_FIXTURES}
    Api Should Have 9 Collections And 21 Keywords

Running Cli Merge Load Mode Second Time Should Leave Collections Untouched
    [Documentation]    Running Cli Update Load Mode Second Time
    ...    Should Leave Collections Untouched. This test bases on
    ...    'Cli Merge Load Mode Should Update Existing Resources And Do Not Remove Not Provided Paths'
    ...    to speed up execution
    [Tags]    rfhub2-64    merge
    Run Cli Package With Options
    ...    --load-mode=merge --no-installed-keywords ${INITIAL_FIXTURES}
    Output Should Contain    Successfully loaded 0 collections with 0 keywords.
    [Teardown]    Run Keywords    Restore Initial Fixtures    AND
    ...    Run Cli Package With Options
    ...    --load-mode=insert --no-installed-keywords

Running Cli With Library Names Instead Of Paths Should Populate App
    [Documentation]    Tests loading installed library using given name, 
    ...    instead of full path.
    [Tags]    rfhub2-342    installed_libs
    Run Cli Package With Options
    ...    --load-mode=insert --no-installed-keywords RequestsLibrary
    Output Should Contain    Successfully loaded 1 collections with 26 keywords.
    Api Should Have 1 Collections And 26 Keywords

Running Cli With Non Existing Library Names Should Load Only Found Libraries
    [Documentation]    Tests loading installed library using given name, 
    ...    instead of full path.
    [Tags]    rfhub2-342    installed_libs
    Run Cli Package With Options
    ...    --load-mode=insert --no-installed-keywords NonExistingLibrary
    Output Should Contain    Successfully loaded 0 collections with 0 keywords.
    Api Should Have 0 Collections And 0 Keywords

Running Cli Without Include Or Exclude Options Should Load All Keywords
    [Documentation]    Test loading Keywords without including or excluding
                ...    any tags should load all keywords
    [Tags]    include-exclude
    [Template]    Run Cli With Options ${options} And Expect Api To Have ${n} Collections And ${m} Keywords
    [Setup]    Run Keywords
    ...        Backup And Switch Initial With Include_Exclude Fixtures
    --load-mode=insert --no-installed-keywords ${INITIAL_FIXTURES}                              3    11
    --load-mode=insert --no-installed-keywords --include "" ${INITIAL_FIXTURES}                 3    11
    --load-mode=insert --no-installed-keywords --exclude "" ${INITIAL_FIXTURES}                 3    11
    --load-mode=insert --no-installed-keywords --include "" --exclude "" ${INITIAL_FIXTURES}    3    11
    [Teardown]    Restore Initial Fixtures

Running Cli And Including Tags Should Load Only Keywords Matching Include Pattern
    [Documentation]    Test loading Keywords and including tags
    [Tags]    include-exclude
    [Template]    Run Cli With Options ${options} And Expect Api To Have ${n} Collections And ${m} Keywords
    [Setup]    Run Keywords
    ...        Backup And Switch Initial With Include_Exclude Fixtures
    --load-mode=insert --no-installed-keywords --include 👻 ${INITIAL_FIXTURES}              3    2
    --load-mode=insert --no-installed-keywords --include 👻AND❤️ ${INITIAL_FIXTURES}        3    1
    --load-mode=insert --no-installed-keywords --include 👻OR❤️ ${INITIAL_FIXTURES}         3    5
    --load-mode=insert --no-installed-keywords --include 👻OR❤️NOT🚀 ${INITIAL_FIXTURES}    3    3
    --load-mode=insert --no-installed-keywords --include *⛅️*✈️* ${INITIAL_FIXTURES}        3    1
    --load-mode=insert --no-installed-keywords --include s[a-z]rt_a? ${INITIAL_FIXTURES}     3    1
    [Teardown]    Restore Initial Fixtures

Running Cli And Excluding Tags Should Load Only Keywords Not Matching Exclude Pattern
    [Documentation]    Test loading Keywords and excluding tags
    [Tags]    include-exclude
    [Template]    Run Cli With Options ${options} And Expect Api To Have ${n} Collections And ${m} Keywords
    [Setup]    Run Keywords
    ...        Backup And Switch Initial With Include_Exclude Fixtures
    --load-mode=insert --no-installed-keywords --exclude 👻 ${INITIAL_FIXTURES}              3    9
    --load-mode=insert --no-installed-keywords --exclude 👻AND❤️ ${INITIAL_FIXTURES}        3    10
    --load-mode=insert --no-installed-keywords --exclude 👻OR❤️ ${INITIAL_FIXTURES}         3    6
    --load-mode=insert --no-installed-keywords --exclude 👻OR❤️NOT🚀 ${INITIAL_FIXTURES}    3    8
    --load-mode=insert --no-installed-keywords --exclude *⛅️*✈️* ${INITIAL_FIXTURES}        3    10
    --load-mode=insert --no-installed-keywords --exclude *⛅️?✈️? ${INITIAL_FIXTURES}        3    11
    --load-mode=insert --no-installed-keywords --exclude s[a-z]rt_a? ${INITIAL_FIXTURES}     3    10
    [Teardown]    Restore Initial Fixtures

Running Cli And Including + Excluding Tags Should Load Proper Keywords
    [Documentation]    Test loading Keywords and including + excluding tags
    [Tags]    include-exclude
    [Template]    Run Cli With Options ${options} And Expect Api To Have ${n} Collections And ${m} Keywords
    [Setup]    Run Keywords
    ...        Backup And Switch Initial With Include_Exclude Fixtures
    --load-mode=insert --no-installed-keywords --include ❤️ --exclude 👻 ${INITIAL_FIXTURES}              3    3
    --load-mode=insert --no-installed-keywords --include ❤️OR👻 --exclude ❤️AND👻 ${INITIAL_FIXTURES}    3    4
    [Teardown]    Restore Initial Fixtures

Running Cli With Merge Load Mode And Including + Excluding Tags Should Load Proper Keywords
    [Documentation]    Test loading Keywords and including + excluding tags
    [Tags]    include-exclude    merge
    [Setup]    Run Keywords
    ...        Backup And Switch Initial With Include_Exclude Fixtures
    Run Cli Package With Options
    ...    --load-mode=insert --no-installed-keywords --exclude 👻 ${INITIAL_FIXTURES}
    # 1/3 in ResourceLibrary1, 5/5 in ResourceLibrary2, 3/3 in PyLibrary
    Api Should Have 3 Collections And 9 Keywords
    Run Cli Package With Options
    ...    --load-mode=merge --no-installed-keywords --include 👻 ${INITIAL_FIXTURES}
    # 2/3 in ResourceLibrary1, 0/5 in ResourceLibrary2, 3/3 (untouched) in PyLibrary
    Api Should Have 3 Collections And 5 Keywords
    [Teardown]    Restore Initial Fixtures

Running Cli With Append Load Mode And Including + Excluding Tags Should Load Proper Keywords
    [Documentation]    Test loading Keywords and including + excluding tags
    [Tags]    include-exclude    append
    [Setup]    Run Keywords
    ...        Backup And Switch Initial With Include_Exclude Fixtures
    Run Cli Package With Options
    ...    --load-mode=insert --no-installed-keywords --exclude 👻 ${INITIAL_FIXTURES}
    # 1/3 in ResourceLibrary1, 5/5 in ResourceLibrary2, 3/3 in PyLibrary
    Api Should Have 3 Collections And 9 Keywords
    Run Cli Package With Options
    ...    --load-mode=append --no-installed-keywords --include ❤️ ${INITIAL_FIXTURES}
    # 1/3❤️ + 1/3 in ResourceLibrary1, 1/5❤️ + 5/5 in ResourceLibrary2, 3/3❤️ + 2/3 in PyLibrary
    Api Should Have 6 Collections And 13 Keywords
    [Teardown]    Restore Initial Fixtures

Running Cli With Update Load Mode And Including + Excluding Tags Should Load Proper Keywords
    [Documentation]    Test loading Keywords and including + excluding tags
    [Tags]    include-exclude    update
    [Setup]    Run Keywords
    ...        Backup And Switch Initial With Include_Exclude Fixtures
    Run Cli Package With Options
    ...    --load-mode=insert --no-installed-keywords --exclude 👻 ${INITIAL_FIXTURES}
    # 1/3 in ResourceLibrary1, 5/5 in ResourceLibrary2, 3/3 in PyLibrary
    Api Should Have 3 Collections And 9 Keywords
    OperatingSystem.Remove Files    ${INITIAL_FIXTURES}${/}PyLibrary${/}__init__.py
    Run Cli Package With Options
    ...    --load-mode=update --no-installed-keywords --include 👻OR🚂 ${INITIAL_FIXTURES}
    # 2/3 in ResourceLibrary1, 0/5 in ResourceLibrary2, 0/3 in PyLibrary (deleted)
    Api Should Have 2 Collections And 2 Keywords
    [Teardown]    Restore Initial Fixtures

Running Cli In Statistics Mode Should Populate App With Execution Data
    [Documentation]    Running Cli In Statistics Mode 
    ...    Should Populate App With Execution Data
    [Tags]    rfhub2-67    statistics
    Run Cli Package With Options    --load-mode=insert --mode=statistics ${SUBDIR_PATH}
    Output Should Contain    Successfully loaded 1 files with 3 statistics.

Running Cli In Statistics Mode Should Populate App With New Execution Data
    [Documentation]    Running Cli In Statistics Mode 
    ...    Should Populate App With New Execution Data
    [Tags]    rfhub2-67    statistics
    Run Cli Package With Options    --load-mode=insert --mode=statistics ${STATISTICS_PATH}
    Output Should Contain    Successfully loaded 1 files with 87 statistics
    Output Should Contain    Records already exist for file from ${SUBDIR_PATH}${/}output.xml
    [Teardown]    Delete All Statistics

*** Keywords ***
Api Should Have ${n} Collections And ${m} Keywords
    collections Endpoint Should Have ${n} Items
    keywords Endpoint Should Have ${m} Items

Run Cli With Options ${options} And Expect Api To Have ${n} Collections And ${m} Keywords
    [Documentation]    Run pkg from CLI and expect a certain amount of collections
    ...    and keywords
    Run Cli Package With Options    ${options}
    Api Should Have ${n} Collections And ${m} Keywords
