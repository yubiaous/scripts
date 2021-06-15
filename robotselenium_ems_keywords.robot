*** Settings ***
Library    SeleniumLibrary    


*** Keywords ***


LogintoEMS
    [Arguments]    ${username}     ${password}
    Input Text       id:login:username        ${username}    
    Input Password   id:login:password        ${password}    
    Click Button     id:login:loginBtn  

Click Mstore
     Select Frame                    id:headerFrame
     Click Element                   id:hdForm:j_id54_lbl    
     Click Element        id:hdForm:mstore
     Unselect Frame
 
    

*** Variables ***

${CMS_LOGIN_URL}  https://10.10.216.75:5001/login.seam
