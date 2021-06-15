*** Settings ***
#Settings
Resource    mStore_Generic_resources.robot

*** Variables ***

*** Keywords ***
Deposit_Message
    [Arguments]     ${UserId}=${SUBSCRIBER_ID}  ${headers}=${OEM_DEPOSIT_HEADERS}   ${url}=${RCS_HOST_URI}  ${object_file}=Deposit_PM_Msg.json  ${MESSAGE_CONTEXT}=${PM_MESSAGE_CONTEXT}
    ...     ${DIRECTION_VALUE}=In   ${X_RCS_MSG_STATUS}=Delivered       ${mStore_request_session}=${MSTORE_SESSION_NAME}

    ${data}=    OperatingSystem.Get Binary File    ${CURDIR}/../testfiles/${object_file}
    ${data} =    Replace Variables    ${data}
    log    ${data}
    ${response}=    RequestsLibrary.Post Request    alias=${mStore_request_session}    uri=${url}${UserId}/objects    data=${data}    headers=${headers}

    ${response_status_code}=    Convert to String    ${response.status_code}
    log    ${response.status_code}
    log    ${response.text}
    log    ${response.headers}
    Should Be Equal    ${response_status_code}    201    msg="deliver pm msg is not success,which has repose ${response.status_code}"
    [Return]    ${response}

