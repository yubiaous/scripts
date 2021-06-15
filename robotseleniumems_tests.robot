*** Settings ***

Library    SeleniumLibrary    
Resource    ems_keywords.robot




*** Test Cases ***
Verify that mstore server shows the fault management tab to view the alarms, events and event definition
    Open Browser         ${CMS_LOGIN_URL}    Chrome   options=add_argument("--ignore-certificate-errors")
    LogintoEMS            admin    mavenir@123
    Maximize Browser Window
    Select Frame    id:headerFrame
    Click Element    id:hdForm:FaultTab_lbl    
    Current Frame Should Contain    Alarms    
    Current Frame Should Contain    Events    
    Current Frame Should Contain    Event Definitions    
    Close Browser
    

Verify that the performance monitor is shown on the GUI for the CPU, memory and disk statistics monitor
    Open Browser                 ${CMS_LOGIN_URL}    Chrome   options=add_argument("--ignore-certificate-errors")
    LogintoEMS                    admin    mavenir@123
    Maximize Browser Window
    Select Frame                    id:headerFrame
    Click Element                   id:hdForm:j_id49_lbl    
    Current Frame Should Contain    Performance Monitor	    
    Click Element                    id:hdForm:PerformanceMonitor   
    Unselect Frame 
    Select Frame    id:bottomFrame
    Set Selenium Implicit Wait    4
    Click Element    id:j_id4_lbl    
    Close Browser
    
Verify that mstore shall healthCheckUr EMS GUI under the link configuration 
  Open Browser           ${CMS_LOGIN_URL}    Chrome   options=add_argument("--ignore-certificate-errors")
    LogintoEMS           admin    mavenir@123
    Maximize Browser Window
    Set Selenium Speed   2
    Click Mstore
    Select Frame         id:bottomFrame
    Select Frame        id:mstoreTreeFrame
    Wait Until Element Is Visible    id:j_id5:tree:22::j_id18  
    Click Element        id:j_id5:tree:22::j_id18
    Unselect Frame
    
    Select Frame         id:bottomFrame
    Select Frame        id:mstoreTreeActionFrame
    ${healthCheckUrl}     Get Text   xpath://div[@id='healthCheckUrl']//span[@class='value'] 
    ${healthCheckUrllength}     Get Length    ${healthCheckUrl}    

    Close Browser
    


Verify that mstore shall display the hostlist table on the EMS GUI under the link configuration ->DB configuration -> Host list
     Open Browser           ${CMS_LOGIN_URL}    Chrome   options=add_argument("--ignore-certificate-errors")
    LogintoEMS           admin    mavenir@123
    Maximize Browser Window
    Set Selenium Speed   2
    Click Mstore
    Select Frame         id:bottomFrame
    Select Frame         id:mstoreTreeFrame
    Click Element        id:j_id5:tree:11::j_id33  
    Click Element        id:j_id5:tree:11:23::j_id22    
    Unselect Frame
    
    Select Frame         id:bottomFrame
    Select Frame         id:mstoreTreeActionFrame
    Input Text           id:hostlistSearch:j_id5:name    dc1
    Input Text           id:hostlistSearch:j_id12:ipAddress    10.10.227.20  
    Click Button         id:hostlistSearch:search  
    Page Should Not Contain  The hostlist search returned no results.	    	            
    Close Browser