*** Settings ***
#COmment
Library         SSHLibrary
Library         Collections
Library         RequestsLibrary
Library         String
Library         OperatingSystem
Library         XML
Library         DateTime

#Settings
Resource    NEW_mStore_Generic_resources.robot

*** Variables ***


*** Keywords ***
AddSubscrber_SOAP
    [Arguments]    ${userid}=${SUBSCRIBER_ID}    ${cosid}=${COSID}    ${headers}=${SOAP_PROVISION_HEADER}    ${Obj_File}=${SOAP_SUBSCRIBER_ADD_OBJ_FILE}    ${provision_uri}=${SOAP_PROVISION_URI}		${mStore_request_session}=${MSTORE_SESSION_NAME}
    ${USER_TO_PROVISION}=    Set Variable    ${userid}
    ${COSID_TO_PROVISION}=    Set Variable    ${cosid}
    ${data}=    OperatingSystem.Get File    ${CURDIR}/../testfiles/${Obj_File}
    ${data} =    Replace Variables    ${data}
    log    ${data}
    ${response}=    Post Request    alias=${mStore_request_session}    uri=${provision_uri}    headers=${headers}    data=${data}
    log    ${response.status_code}
    log    ${response.text}
    log    ${response.headers}
    [Return]    ${response}

AddSubscriber
    [Arguments]    ${userid}=${SUBSCRIBER_ID}    ${cosid}=${COSID}    ${imap_password}=${REST_USER_PASSWORD}    ${sub_uri}=${REST_PROVISION_URI}    ${response_code}=201    ${headers}=${REST_PROVISION_HEADER}    ${Obj_File}=${REST_SUBSCRIBER_ADD_OBJ_FILE}		${mStore_request_session}=${MSTORE_SESSION_NAME}
    ${USER_TO_PROVISION}=    Set Variable    ${userid}
    ${COSID_TO_PROVISION}=    Set Variable    ${cosid}
    ${data}=    OperatingSystem.Get File    ${CURDIR}/../testfiles/${Obj_File}
    ${data} =    Replace Variables    ${data}
    log    ${data}
    ${response}=    Post Request    alias=${mStore_request_session}    uri=${sub_uri}    headers=${headers}    data=${data}
    log    ${response.status_code}
    log    ${response.text}
    log    ${response.headers}
    ${response_code}=    Convert to Integer    ${response_code}
    Run Keyword and Continue on Failure    Run Keyword and Continue on Failure    Should Be Equal    ${response.status_code}    ${response_code}
    [Return]    ${response}

DeleteSubscriber_SOAP
    [Arguments]    ${userid}=${SUBSCRIBER_ID}    ${headers}=${SOAP_PROVISION_HEADER}    ${Obj_File}=${SOAP_SUBSCRIBER_DEL_OBJ_FILE}    ${provision_uri}=${SOAP_PROVISION_URI}	${mStore_request_session}=${MSTORE_SESSION_NAME}
    ${USER_TO_DELETE}=    Set Variable    ${userid}
    ${data}=    OperatingSystem.Get File    ${CURDIR}/../testfiles/${Obj_File}
    ${data} =    Replace Variables    ${data}
    log    ${data}
    ${response}=    Post Request    alias=${mStore_request_session}    uri=${provision_uri}    data=${data}    headers=${headers}
    log    ${response.status_code}
    log    ${response.text}
    log    ${response.headers}
    [Return]    ${response}

DeleteSubscriber
    [Arguments]    ${userid}=${SUBSCRIBER_ID}    ${headers}=${REST_PROVISION_HEADER}    ${sub_uri}=${REST_PROVISION_URI}    ${response_code}=200	${mStore_request_session}=${MSTORE_SESSION_NAME}
    ${params}=    Create Dictionary    backupService=None
    ${response}=    Delete Request    alias=${mStore_request_session}    uri=${sub_uri}/${userid}    headers=${headers}    params=${params}
    log    ${response.status_code}
    log    ${response.text}
    log    ${response.headers}
    ${response_code}=    Convert to Integer    ${response_code}
    Should Be Equal    ${response.status_code}    ${response_code}
    [Return]    ${response}

RetrieveSubscriberInfo_SOAP
    [Arguments]    ${userId}=${SUBSCRIBER_ID}    ${headers}=${SOAP_PROVISION_HEADER}    ${Obj_File}=${SOAP_SUBSCRIBER_RET_OBJ_FILE}    ${provision_uri}=${SOAP_PROVISION_URI}	${mStore_request_session}=${MSTORE_SESSION_NAME}
    ${USER_TO_RETRIEVE}=    Set Variable    ${userid}
    ${data}=    OperatingSystem.Get File    ${CURDIR}/../testfiles/${Obj_File}
    ${data} =    Replace Variables    ${data}
    log    ${data}
    ${response}=    Post Request    alias=${mStore_request_session}    uri=${provision_uri}    data=${data}
    log    ${response.status_code}
    log    ${response.text}
    log    ${response.headers}
    [Return]    ${response}

RetrieveSubscriberInfo
    [Arguments]    ${userid}=${SUBSCRIBER_ID}    ${headers}=${REST_PROVISION_HEADER}    ${sub_uri}=${REST_PROVISION_URI}    ${response_code}=200	${mStore_request_session}=${MSTORE_SESSION_NAME}
    ${response}=    Get Request    alias=${mStore_request_session}    uri=${sub_uri}/${SUBSCRIBER_ID}/profile    headers=${headers}
    log    ${response.status_code}
    log    ${response.text}
    log    ${response.headers}
    ${response_code}=    Convert to Integer    ${response_code}
    Should Be Equal    ${response.status_code}    ${response_code}
    [Return]    ${response}
    
ModifySubscriber_SOAP
    [Arguments]    ${old_userId}=${SUBSCRIBER_ID}    ${new_userId}=${NEW_SUBSCRIBER_ID}    ${CosId}=${COSID}    ${headers}=${SOAP_PROVISION_HEADER}    ${Obj_File}=${SOAP_SUBSCRIBER_MOD_OBJ_FILE}    ${provision_uri}=${SOAP_PROVISION_URI}    ${mStore_request_session}=${MSTORE_SESSION_NAME}
    ${ACTUAL_OLD_MSISDN}=    Set Variable    ${old_userId}
    ${NEW_SUBSCRIBER_ID_TO_CHANGE}=    Set Variable    ${new_userId}
    ${COSID_TO_CHANGE}=    Set Variable    ${CosId}
    ${data}=    OperatingSystem.Get File    ${CURDIR}/../testfiles/${Obj_File}
    ${data}=    Replace Variables    ${data}
    log    ${data}
    ${response}=    Post Request    alias=${mStore_request_session}    uri=${provision_uri}    data=${data}    headers=${headers}
    log    ${response.status_code}
    log    ${response.text}
    log    ${response.headers}
    [Return]    ${response}

ChangeCosId
    [Arguments]    ${CosId}=${NEW_COS_ID}    ${headers}=${REST_PROVISION_HEADER}    ${sub_uri}=${REST_PROVISION_URI}    ${response_code}=200    ${Obj_File}=${REST_SUBSCRIBER_MOD_COS_OBJ_FILE}		${mStore_request_session}=${MSTORE_SESSION_NAME}
    ${COSID_TO_CHANGE}=    Set Variable    ${CosId}
    ${data}=    OperatingSystem.Get File    ${CURDIR}/../testfiles/${Obj_File}
    ${data}=    Replace Variables    ${data}
    log    ${data}
    &{files}=    Create Dictionary    file=${data}
    ${response}=    Put Request    alias=${mStore_request_session}    uri=${sub_uri}/${SUBSCRIBER_ID}/attributes    headers=${headers}    data=${data}
    log    ${response.status_code}
    log    ${response.text}
    log    ${response.headers}
    ${response_code}=    Convert to Integer    ${response_code}
    Should Be Equal    ${response.status_code}    ${response_code}
    [Return]    ${response}
    
ChangeMSISDN
    [Arguments]    ${old_userId}=${SUBSCRIBER_ID}    ${new_userId}=${NEW_SUBSCRIBER_ID}    ${headers}=${REST_PROVISION_HEADER}    ${sub_uri}=${REST_PROVISION_URI}    ${response_code}=200    ${Obj_File}=${REST_SUBSCRIBER_MOD_MSISDN_OBJ_FILE}	${mStore_request_session}=${MSTORE_SESSION_NAME}
    ${ACTUAL_OLD_MSISDN}=    Set Variable    ${old_userId}
    ${NEW_SUBSCRIBER_ID_TO_CHANGE}=    Set Variable    ${new_userId}
    ${data}=    OperatingSystem.Get File    ${CURDIR}/../testfiles/${Obj_File}
    ${data}=    Replace Variables    ${data}
    log    ${data}
    ${response}=    Put Request    alias=${mStore_request_session}    uri=${sub_uri}    headers=${headers}    data=${data}    
    log    ${response.status_code}
    log    ${response.text}
    log    ${response.headers} 
    ${response_code}=    Convert to Integer    ${response_code}
    Should Be Equal    ${response.status_code}    ${response_code}
    [Return]    ${response}

BlockSubscriber
    [Arguments]    ${user_id}=${SUBSCRIBER_ID}    ${headers}=${REST_PROVISION_HEADER}    ${sub_uri}=${REST_PROVISION_URI}    ${response_code}=200	${mStore_request_session}=${MSTORE_SESSION_NAME}
    ${response}=    Put Request    alias=${mStore_request_session}    uri=${sub_uri}/${user_id}/flags/%5cSubBlocked    headers=${headers}
    log    ${response.status_code}
    log    ${response.text}
    log    ${response.headers}
    ${response_code}=    Convert to Integer    ${response_code}
    Should Be Equal    ${response.status_code}    ${response_code}
    [Return]    ${response}

UnBlockSubscriber
    [Arguments]    ${user_id}=${SUBSCRIBER_ID}    ${headers}=${REST_PROVISION_HEADER}    ${sub_uri}=${REST_PROVISION_URI}    ${response_code}=200		${mStore_request_session}=${MSTORE_SESSION_NAME}
    ${response}=    Put Request    alias=${mStore_request_session}    uri=${sub_uri}/${user_id}/flags/%5cSubUnblocked    headers=${headers}
    log    ${response.status_code}
    log    ${response.text}
    log    ${response.headers}
    ${response_code}=    Convert to Integer    ${response_code}
    Should Be Equal    ${response.status_code}    ${response_code}
    [Return]    ${response}

ValidateAddSubscriberResponse
    [Arguments]    ${response}    ${response_code}=${SUCCESS_RESPONSE_CODE}    ${status}=${SUCCESS_STATUS}
    ${response_code}=    Convert to Integer    ${response_code}
    Should Be Equal    ${response.status_code}    ${response_code}
    ${data}=    ParseXML    ${response.text}
    ${body}=    Get Element    ${data}    Body
    ${statusText}=    Get Element Text    ${data}    Body
    ${child1}=    Get Element    ${body}    AddSubscriberResponse
    ${child2}=    Get Element    ${child1}    AddStatus
    ${child3}    Get Element    ${child2}    Status
    Should Be Equal    ${child3.text}    ${status}


ValidateDeleteSubscriberResponse
    [Arguments]    ${response}    ${response_code}=${SUCCESS_RESPONSE_CODE}    ${status}=${SUCCESS_STATUS}
    ${response_code}=    Convert to Integer    ${response_code}
    Should Be Equal    ${response.status_code}    ${response_code}
    ${data}=    ParseXML    ${response.text}
    ${body}=    Get Element    ${data}    Body
    ${statusText}=    Get Element Text    ${data}    Body
    ${child1}=    Get Element    ${body}    DeleteSubscriberResponse
    ${child3}    Get Element    ${child1}    Status
    Should Be Equal    ${child3.text}    ${status}


ValidateModifySubscriberInfo
    [Arguments]    ${response}    ${response_code}=${SUCCESS_RESPONSE_CODE}    ${status}=${SUCCESS_STATUS}
    ${response_code}=    Convert to Integer    ${response_code}
    Should Be Equal    ${response.status_code}    ${response_code}
    ${data}=    ParseXML    ${response.text}
    ${body}=    Get Element    ${data}    Body
    ${statusText}=    Get Element Text    ${data}    Body
    ${child1}=    Get Element    ${body}    ModifySubscriberResponse
    ${child2}=    Get Element    ${child1}    ModifyStatus
    ${child3}    Get Element    ${child2}    Status
    Should Be Equal    ${child3.text}    ${status}

ValidateSubscriberCassandraUsersTable
    [Arguments]    ${userId}=${SUBSCRIBER_ID}    ${Cos_Id}=${COSID}    ${imappwd}=${EnCrypted_IMAP_Password}    ${pinpwd}=${EnCrypted_PIN}    ${nut}=1    ${pin_encrypted}=1    ${vvmon}=1    ${omavvmon}=0
    Switch Connection    cass_db
    Write    SELECT JSON * FROM users WHERE userid='${userId}';
    ${users_out}=    Read Until    \>
    Should Contain    ${users_out}    (1 rows)    msg="No entry in Users table for the userId ${userId}"
    ${lines}=    Split to Lines    ${users_out}
    ${type}    Evaluate    type(${lines})
    log    ${lines[3]}
    ${json_out}=    Evaluate    json.loads('''${lines[3]}''')    json
    ${SWIFTACCOUNTID}=    Set Variable    ${json_out['swiftaccountid']}
    Set Suite Variable    ${SWIFTACCOUNTID}
#    Run Keyword and Continue on Failure    Should Match Regexp    ${json_out['changepasswordtime']}    \\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}.\\d{3}Z
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${json_out['cosid']}    ${Cos_Id}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${json_out['identifiertype']}    0
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${json_out['imapfailedlogincount']}    0
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${json_out['imappassword']}    ${imappwd}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${json_out['ispinencrypted']}    ${pin_encrypted}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${json_out['issubblocked']}    ${NULL}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${json_out['loginlevel']}    0
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${json_out['mailboxquota']}    ${MailBoxQuota}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${json_out['nut']}    ${nut}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${json_out['omavvmon']}    ${omavvmon}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${json_out['passwordhistory']}    ICwgLCAs
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${json_out['pin']}    ${pinpwd}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${json_out['substatus']}    1
    #Run Keyword and Continue on Failure    Should Be Equal As Strings    ${json_out['version']}    ${NULL}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${json_out['vvmon']}    ${vvmon}
    Run Keyword and Continue on Failure    Should Match Regexp    ${json_out['uuid']}    [0-9a-f\-]+
    ${SWIFTACCOUNTID}=    Set Variable    ${json_out['swiftaccountid']}
    Set Suite Variable    ${SWIFTACCOUNTID}
    ${USERID}=    Set Variable    ${json_out['uuid']}
    Set Suite Variable    ${USERID}
    [Return]    ${json_out}


ValidateSubscriberCassandraUsersTableAfterDelete
    [Arguments]    ${userId}=${SUBSCRIBER_ID}
    Switch Connection    cass_db
    Write    SELECT JSON * FROM users WHERE userid='${userId}';
    ${users_out}=    Read Until    \>
    Should Contain    ${users_out}    (0 rows)    msg="${userId} not deleted Successfully"
    Write    SELECT JSON * FROM userfolderkeymap WHERE userid='${userId}';
    ${users_out}=    Read Until    \>
    Should Contain    ${users_out}    (0 rows)    msg="${userId} not deleted Successfully"
    Write    SELECT JSON * FROM folder WHERE userid='${userId}';
    ${users_out}=    Read Until    \>
    Should Contain    ${users_out}    (0 rows)    msg="${userId} not deleted Successfully"
    Write    SELECT JSON * FROM messages WHERE userid='${userId}';
    ${users_out}=    Read Until    \>
    Should Contain    ${users_out}    (0 rows)    msg="${userId} not deleted Successfully"
    Write    SELECT JSON * FROM nms_subscriptions_mapping WHERE userid='${userId}';
    ${users_out}=    Read Until    \>
    Should Contain    ${users_out}    (0 rows)    msg="${userId} not deleted Successfully"

ValidateFolderTableForBlockedUser
    [Arguments]    ${userId}=${SUBSCRIBER_ID}    ${value}=1
    Switch Connection    cass_db
    Write    SELECT JSON * FROM folder where userid='${userId}' and folderkey='27a29814-dd8f-43ee-b768-19af98bf1d07';
    ${users_out}=    Read Until    \>
    log    ${users_out}
    ${lines}=    Split to Lines    ${users_out}
    ${type}    Evaluate    type(${lines})
    log    ${lines[3]}
    ${json_out}=    Evaluate    json.loads('''${lines[3]}''')    json
    Should Be Equal As Strings    ${json_out['subblocked']}    ${value}

getMailboxattributes
	[Arguments]    ${CosId}=${COSID}	${mStore_dbm_session}=mStore_dbm
    Switch Connection    ${mStore_dbm_session}
    Write    select profileXml from ClassOfService where profileXml like '%<COSId>${CosId}</COSId>%' \\G;
    ${profileXml}=    Read Until    mysql\>
    #${profileXml}=    Run Keyword If    '${LOCAL_DB_TYPE}' == 'mysql'    Read Until    mysql\>  ELSE    Read Until  MariaDB [mnode_cm_data]>
    ${profileXml}=    Fetch From Right    ${profileXml}    profileXml:
    ${profileXml}=    Fetch From Left    ${profileXml}    1 row in set
    ${profileXml}=    Fetch From Left    ${profileXml}      [0;10;1m
    log    ${profileXml}
    ${parsed_xml}=    ParseXML    ${profileXml.strip()}
    log    ${parsed_xml}
	${mailboxUnlockTime}=    Get Element Text    ${parsed_xml}    RepositoryData/ServiceData/COSProfile/mailboxAttributes/mailboxUnlockTime
	${imapUnlockTime}=    Get Element Text    ${parsed_xml}    RepositoryData/ServiceData/COSProfile/mailboxAttributes/imapUnlockTime
    ${imapMaxFailedLoginAttempt}=    Get Element Text    ${parsed_xml}    RepositoryData/ServiceData/COSProfile/mailboxAttributes/imapMaxFailedLoginAttempt
    ${maxGreetingLength}=    Get Element Text    ${parsed_xml}    RepositoryData/ServiceData/COSProfile/mailboxAttributes/maxGreetingLength
    ${minPinLength}=    Get Element Text    ${parsed_xml}    RepositoryData/ServiceData/COSProfile/mailboxAttributes/minPinLength
    ${maxPinLength}=    Get Element Text    ${parsed_xml}    RepositoryData/ServiceData/COSProfile/mailboxAttributes/maxPinLength
    ${changePswdTTL}=    Get Element Text    ${parsed_xml}    RepositoryData/ServiceData/COSProfile/mailboxAttributes/changePswdTTL
    ${maxVoiceSigGrtngLenInSec}=    Get Element Text    ${parsed_xml}    RepositoryData/ServiceData/COSProfile/mailboxAttributes/maxVoiceSigGrtngLenInSec
	&{mailboxAttributes}=    Create Dictionary		mailboxUnlockTime=${mailboxUnlockTime}	imapUnlockTime=${imapUnlockTime}	imapMaxFailedLoginAttempt=${imapMaxFailedLoginAttempt}	maxGreetingLength=${maxGreetingLength}	minPinLength=${minPinLength}	maxPinLength=${maxPinLength}	changePswdTTL=${changePswdTTL}	maxVoiceSigGrtngLenInSec=${maxVoiceSigGrtngLenInSec}
	Set Suite Variable	${mailboxAttributes}
	[Return]		${mailboxAttributes}

GetNumberFolderPathfromClassofService
    [Arguments]    ${CosId}=${COSID}	${mStore_dbm_session}=mStore_dbm
    Switch Connection    ${mStore_dbm_session}
    Write    select profileXml from ClassOfService where profileXml like '%<COSId>${CosId}</COSId>%' \\G;
	${profileXml}=    Read Until    mysql\>
    #${profileXml}=    Run Keyword If	'${LOCAL_DB_TYPE}' == 'mysql'    Read Until    mysql\>	ELSE	Read Until	MariaDB [mnode_cm_data]>
    ${profileXml}=    Fetch From Right    ${profileXml}    profileXml:
    ${profileXml}=    Fetch From Left	  ${profileXml}		</cos>
	${profileXml}=		Set Variable	${profileXml}</cos>
    #${profileXml}=    Fetch From Left    ${profileXml}    1 row in set
	#${profileXml}=    Fetch From Left    ${profileXml}		[0;10;1m
    log    ${profileXml}
    ${parsed_xml}=    ParseXML    ${profileXml.strip()}
    log    ${parsed_xml}
    ${mailbox}=    Get Elements    ${parsed_xml}    RepositoryData/ServiceData/COSProfile/mailbox
    log    ${mailbox}
    ${defaultMailboxQuota}=    Get Element Text    ${parsed_xml}    RepositoryData/ServiceData/COSProfile/defaultMailboxQuota
    log    ${defaultMailboxQuota}
    Set Suite Variable    ${MailBoxQuota}    ${defaultMailboxQuota}
    &{Generic_Cos_Path_Ids}=    Create Dictionary
    &{ProfileXmlData}=    Create Dictionary
    Set Suite Variable    ${Generic_Cos_Path_Ids}
    Set Suite Variable    ${ProfileXmlData}
    :FOR    ${mailbox_ele}    IN    @{mailbox}
    \    ${folder}=    Get Element    ${mailbox_ele}    folder
    \    ${quota}=    Get Element Text    ${mailbox_ele}    quota/pctOfTotalStorage
    \    log    ${quota}
    \    log    ${folder}
    \    ${type}=    Get Elements    ${folder}    type
    \    log    ${type}
    \    GetAllTypesofCosProfiles    ${folder}    ${type}    ${quota}
    Log    ${Generic_Cos_Path_Ids}
    Set Suite Variable    ${Generic_Cos_Path_Ids}
    Set Suite Variable    ${ProfileXmlData}
    log    ${ProfileXmlData}
    [Return]    ${Generic_Cos_Path_Ids}


GetAllTypesofCosProfiles
    [Arguments]    ${folder}    ${type}    ${quota}
    :FOR    ${e_type}    IN    @{type}
    \    ${path}=    Get Element Text    ${e_type}    path
    \    ${id}=    Get Element Text    ${e_type}    id
    \    ${status}=    Run Keyword and Return Status    Dictionary Should Not Contain Key    ${Generic_Cos_Path_Ids}    ${path}
    \    log    ${status}
    \    &{val}=    Create Dictionary    folder_key=${id}    quota=${quota}
    \    Run Keyword If    "${status}"=="True"    Set To Dictionary    ${Generic_Cos_Path_Ids}    ${path}    ${id}
    \    Run Keyword If    "${status}"=="True"    Set To Dictionary    ${ProfileXmlData}    ${path}    ${val}

ValidateSubscriberCassandraFoldersmapTable
    [Arguments]    ${folders}=&{EMPTY}    ${userId}=${SUBSCRIBER_ID}
    ${count}=    Get Length    ${folders}
    Switch Connection    cass_db
    Write    SELECT foldername,folderkey,swiftcontainerid FROM userfolderkeymap where userid = '${userId}';
    ${userfolderkeymapdatas}=    Read Until    \>
    Should Contain    ${userfolderkeymapdatas}    (${count} rows)    msg="doesn't contain all the folders in userkeyfolermap for the corresponding cosId"
    &{ContainerData}=    Create Dictionary
    ${folder_path}=    Get Dictionary Keys    ${folders}
    :FOR    ${path}    IN    @{folder_path}
    \    ${fk_userfolderkeymapdata}=    Get Lines Containing String    ${userfolderkeymapdatas}    ${path}
    \    ${fk_userfolderkeymapdata}=    GetActualData    ${fk_userfolderkeymapdata}    ${path}
    \    ${userfolderkeymap_data}=    Split String    ${fk_userfolderkeymapdata}    |
    \    log    ${userfolderkeymap_data}
    \    ${userfolderkeymap_foldername}=    Set Variable    ${userfolderkeymap_data[0].strip()}
    \    ${userfolderkeymap_folderkey}=    Set Variable    ${userfolderkeymap_data[1].strip()}
    \    ${userfolderkeymap_swiftcontainerid}=    Set Variable    ${userfolderkeymap_data[2].strip()}
    \    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${folders['${path}']}    ${userfolderkeymap_folderkey}
    \    Write    SELECT foldername,folderkey,swiftcontainerid FROM folder where userid = '${userId}' and folderkey='${userfolderkeymap_folderkey}';
    \    ${folder_data}=    Read Until    \>
    \    ${folder_data}=    Get Lines Containing String    ${folder_data}    ${path}    
    \    ${folder_data}=    Split String    ${folder_data}    |
    \    log    ${folder_data}
    \    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${folder_data[2].strip()}    ${userfolderkeymap_swiftcontainerid}
    \    ${k_status}    ${list_of_folder}=    Run Keyword and Ignore Error    Get From Dictionary    ${ContainerData}    ${userfolderkeymap_swiftcontainerid}
    \    log    ${k_status}
    \    Run Keyword If    '${k_status}' == 'PASS'    Append to List    ${list_of_folder}    ${path}
    \    ${list_of_folder1}=    Run Keyword If    '${k_status}' == 'FAIL'    Create List    ${path}
    \    log    ${list_of_folder}
    \    log    ${list_of_folder1}
    \    Run Keyword If    '${k_status}' == 'PASS'    Set To Dictionary    ${ContainerData}    ${userfolderkeymap_swiftcontainerid}=${list_of_folder}    
    \    Run Keyword If    '${k_status}' == 'FAIL'    Set To Dictionary    ${ContainerData}    ${userfolderkeymap_swiftcontainerid}=${list_of_folder1}
    \    log    ${ContainerData}
    Set Suite Variable    ${ContainerData}
    log    ${ContainerData}
    
GetActualData
    [Arguments]    ${line}    ${path}
    ${lines}=    Split to Lines    ${line}
    :FOR    ${li}    IN    @{lines}
    \    ${str}=    Split String    ${li}    |
    \    ${value}=    Set Variable    ${li}
    \    Exit For loop If    '${str[0].strip()}' == '${path}'
    [Return]    ${value}

ValidateUserFolderKeymapTable
    [Arguments]    ${folders}=&{EMPTY}    ${userId}=${USERID}
    ${count}=    Get Length    ${folders}
    Switch Connection    cass_db
    Write    SELECT json * FROM userfolderkeymap where userid = '${userId}';
    ${userfolderkeymapdatas}=    Read Until    \>
    Should Contain    ${userfolderkeymapdatas}    (${count} rows)    msg="doesn't contain all the folders in userfolderkeymap for the corresponding cosId"
    &{ContainerData}=    Create Dictionary
	Set Suite Variable    ${ContainerData}
    ${folder_names}=    Get Dictionary Keys    ${folders}
    :FOR    ${foldername}    IN    @{folder_names}
    \    ${fk_userfolderkeymapdata}=    Get Lines Containing String    ${userfolderkeymapdatas}    \"${foldername}\"
	\	${fk_userfolderkeymapdata}=		Evaluate	json.loads('''${fk_userfolderkeymapdata}''')	json
	\    log    ${fk_userfolderkeymapdata}
	\    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${folders['${foldername}']}    ${fk_userfolderkeymapdata['folderkey']}
	\    Run Keyword If    '${fk_userfolderkeymapdata["swiftcontainerid"]}' != '${NONE}'	SetContainerInfo	${fk_userfolderkeymapdata['swiftcontainerid']}    ${foldername}


SetContainerInfo
	[Arguments]		${containerId}	${foldername}
    ${k_status}    ${list_of_folder}=    Run Keyword and Ignore Error    Get From Dictionary    ${ContainerData}    ${containerId}
    Run Keyword If    '${k_status}' == 'PASS'    Append to List    ${list_of_folder}    ${foldername}
    ${list_of_folder1}=    Run Keyword If    '${k_status}' == 'FAIL'    Create List    ${foldername}
    Run Keyword If    '${k_status}' == 'PASS'    Set To Dictionary    ${ContainerData}    ${containerId}=${list_of_folder}
    Run Keyword If    '${k_status}' == 'FAIL'    Set To Dictionary    ${ContainerData}    ${containerId}=${list_of_folder1}
    log    ${ContainerData}
    Set Suite Variable    ${ContainerData}
    log    ${ContainerData}


ValidateFolderTable
    [Arguments]    ${folders}=&{EMPTY}    ${userId}=${USERID}
    ${count}=    Get Length    ${folders}
    Switch Connection    cass_db
    Write    SELECT json * FROM folder where userid = '${userId}';
    ${folderdatas}=    Read Until    \>
    Should Contain    ${folderdatas}    (${count} rows)    msg="doesn't contain all the folders in folder for the corresponding cosId"

	${CONTAINER_INFO}=	Create Dictionary
    ${folder_names}=    Get Dictionary Keys    ${folders}
    :FOR    ${foldername}    IN    @{folder_names}
	\   ${fk_folderdata}=	Get Lines Containing String    ${folderdatas}    \"${foldername}\"
	\	${fk_folderdata}=	Evaluate    json.loads('''${fk_folderdata}''')	json
	\	log		${fk_folderdata}
	\	Run Keyword and Continue on Failure   Should Be Equal As Strings   ${fk_folderdata['folderkey']}   ${folders['${foldername}']}
	\   Run Keyword and Continue on Failure   Should Be Equal As Strings   ${fk_folderdata['initialized']}	0
	\	Run Keyword and Continue on Failure   Should Be Equal As Strings   ${fk_folderdata['inuse']}        ${NONE}
	\	Run Keyword and Continue on Failure   Should Be Equal As Strings   ${fk_folderdata['isactive']}     ${NONE}
	\	Run Keyword and Continue on Failure   Should Be Equal As Strings   ${fk_folderdata['locked']}       0
	\	Run Keyword and Continue on Failure   Should Be Equal As Strings   ${fk_folderdata['mailboxunlocktime']}   ${NONE} 
	#\	Run Keyword and Continue on Failure   Should Be Equal As Strings   ${fk_folderdata['messagecontext']}	${NONE}
	\	Run Keyword and Continue on Failure   Should Be Equal As Strings   ${fk_folderdata['new']}                1
	\	Run Keyword and Continue on Failure   Should Be Equal As Strings   ${fk_folderdata['parentkey']}		${EMPTY}
	\	Run Keyword and Continue on Failure   Should Be Equal As Strings   ${fk_folderdata['pwdsuppressed']}      0
	\	Run Keyword and Continue on Failure   Should Be Equal As Strings   ${fk_folderdata['subblocked']}		${NONE}
	#\	Run Keyword and Continue on Failure   Should Be Equal As Strings   ${fk_folderdata['swiftcontainerid']}
	\	${uidval}=		convert to string		${fk_folderdata['uidval']}
	#\	Run Keyword and Continue on Failure   Should Match Regexp   ${fk_folderdata['uidval']}           [0-9a-f ]+
	\	Run Keyword and Continue on Failure		Should Match Regexp		${uidval}		\\d+
	\	Set To Dictionary	${CONTAINER_INFO}	${foldername}	${fk_folderdata['swiftcontainerid']}
	Set Suite Variable		${CONTAINER_INFO}
	Set Suite Variable    ${SUBSCRIBER_UID_VAL}		${fk_folderdata['uidval']}

	
ValidateQuotaonSwift
    [Arguments]    ${folders}=&{ProfileXmlData}    ${containers}=&{ContainerData}    ${response_code}=204    ${userId}=${SUBSCRIBER_ID}
    ${swiftContainers}=    Get Dictionary Keys    ${containers}
    log    ${swiftContainers}
    ${sum_of_quota_allocated}=    Set Variable    0
    ${sum_of_quota_calculated}=    Set Variable    0
    :FOR    ${container}    IN    @{swiftContainers}
    \    ${folders}=    Set Variable    ${ContainerData['${container}']}
    \    ${response}=    Get Request    alias=${SWIFT_SESSION_NAME}    uri=/v1/${SWIFTACCOUNTID}/${container}
    \    log    ${response.headers}
    \    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${response.status_code}    ${response_code}
    #\    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${response.headers['x-container-meta-owner-msisdn']}    ${userid}
    \    ${quota_received}=    Set Variable    ${response.headers['x-container-meta-quota-bytes']}
    \    CheckQuotaMultipier    ${container}    ${folders}    ${quota_received}    

CheckQuotaMultipier
    [Arguments]    ${container}    ${folders}    ${quota_received_from_swift}
    :FOR    ${each_folder}    IN    @{folders}
    \    ${vm_status}=    Run Keyword and Return Status    List Should Contain Value    ${VM_FOLDERS}    ${each_folder}
    \    ${rcs_status}=    Run Keyword and Return Status    List Should Contain Value    ${RCS_FOLDERS}    ${each_folder}
    \    ${pct_quota_allocated_folder}=    Set Variable    ${ProfileXmlData['${each_folder}']['quota']}
	\	 ${calculated_quota}=    Evaluate    100 * ${quota_received_from_swift}/${MailBoxQuota}
	\	 ${pct_quota_allocated_folder_mul}=	Run Keyword and Continue on Failure    Run Keyword If    '${vm_status}' == 'True'    Evaluate	${pct_quota_allocated_folder} * ${VM_SWIFT_QUOTA_MULTIPLIER}		ELSE	Evaluate	${pct_quota_allocated_folder} * ${RCS_SWIFT_QUOTA_MULTIPLIER}
    \    Run Keyword and Continue on Failure    Run Keyword If    '${rcs_status}' == 'False' and '${vm_status}' == 'False'    log    "${each_folder} is not part of both VM and RCS folder"
    \	${pct_quota_allocated_folder_add_1}=	Evaluate	${pct_quota_allocated_folder_mul} + 1
	\	${pct_quota_allocated_folder_sub_1}=    Evaluate    ${pct_quota_allocated_folder_mul} - 1
    \	Run Keyword and Continue on Failure		Should Be True	${pct_quota_allocated_folder_add_1} >= ${calculated_quota} >= ${pct_quota_allocated_folder_sub_1}	msg="Quota Validation failed for ${each_folder} expected ${pct_quota_allocated_folder_mul} received ${calculated_quota}"
    #\   log    ${each_folder} | ${Generic_Cos_Path_Ids['${each_folder}']} | ${MailBoxQuota} | ${quota_received_from_swift} | ${pct_quota_allocated_folder} | ${pct_quota_allocated_folder_mul} | ${calculated_quota}     console=true
    

ValidateSubscriberErrorResponse
    [Arguments]    ${response}    ${response_code}    ${status}
    ${response_code}=    Convert to Integer    ${response_code}
    Should Be Equal    ${response.status_code}    ${response_code}
    ${data}=    ParseXML    ${response.text}
    ${body}=    Get Element    ${data}    Body
    ${fault}=    Get Element    ${body}    Fault
    ${detail}=    Get Element    ${fault}    detail
    ${srvce_errs}=    Get Element    ${detail}    ServiceErrors
    ${srvce_err}=    Get Element    ${srvce_errs}    ServiceError
    ${val_err}=    Get Element    ${srvce_err}    ValidationError
    ${code}=    Get Element    ${val_err}    Code
    ${reason}=    Get Element    ${val_err}    Reason
    log    ${code.text}
    log    ${reason.text}
    Should Be Equal    ${reason.text}    ${status}

ValidateRecievedSubscriberInfo
    [Arguments]    ${response}    ${response_code}=${SUCCESS_RESPONSE_CODE}    ${userId}=${SUBSCRIBER_ID}    ${cosId}=${COSID}
    ${response_code}=    Convert to Integer    ${response_code}
    ${cosId}=    Convert to Integer    ${cosId}
    Should Be Equal    ${response.status_code}    ${response_code}
    ${data}=    ParseXML    ${response.text}
    ${body}=    Get Element    ${data}    Body
    ${subc_resp}=    Get Element    ${body}    GetSubscriberResponse
    ${subc_detail}=    Get Element    ${subc_resp}    SubscriberDetails
    ${subscriber_id}=    Get Element    ${subc_detail}    Identifier
    ${subcmstrdata}=    Get Element    ${subc_detail}    SubscriberMSTRData
    ${cosidr}=    Get Element    ${subcmstrdata}    COSID
    log    ${cosidr.text}
    log    ${subscriber_id.text}
    ${resp_cosid}=    Convert to Integer    ${cosidr.text}
    ${resp_UserId}=    Convert to Integer    ${subscriber_id.text}
    Should Be Equal    ${resp_cosid}    ${cosId}
    Should Be Equal    ${resp_UserId}    ${userId}

ValidateRetrievedSubscriberInfo
    [Arguments]    ${response_xml}
    ${attributeList}=    Get Elements    ${response_xml}    attributeList
    log    ${attributeList}
    ${child_ele}=    Get Child Elements    ${response_xml}    attributeList
    log    ${child_ele}
    ${RetrievedInfo}=    Create Dictionary
    :FOR    ${ele}    IN    @{child_ele}
    \    ${name}=    Get Element Text    ${ele}    name
    \    log    ${name}
    \    ${value}=    Get Element Text    ${ele}    value
    \    log    ${value}
    \    Set to Dictionary    ${RetrievedInfo}    ${name}    ${value}
    log    ${RetrievedInfo}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${RetrievedInfo['cos-id']}    ${COSID}
    Run Keyword and Continue on Failure    Should Match Regexp    ${RetrievedInfo['date']}    [0-9A-Z\-:]+
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${RetrievedInfo['deletedmsgaction']}    Automatic
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${RetrievedInfo['imappassword']}    ${REST_USER_PASSWORD}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${RetrievedInfo['nut']}    true
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${RetrievedInfo['omavvmon']}    false
    Run Keyword and Continue on Failure    Should Match Regexp    ${RetrievedInfo['passworddate']}    \\d+
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${RetrievedInfo['pin']}    ${REST_USER_PIN}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${RetrievedInfo['subscriberstatus']}    Active
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${RetrievedInfo['vvmon']}    true

DeleteAlltheSubscribers
    Switch Connection    cass_db
    Write    SELECT userid FROM users ;    
    ${out}=    Read Until    \>
    ${cnt}=    get line count    ${out}
    :FOR    ${index}    IN RANGE    3    ${cnt}-3
    \    ${val}=    Get Line    ${out}    ${index}
    \    DeleteSubscriber    ${val.strip()}    


GetKpiReport
    [Arguments]    ${service_type}="MSTORE_PROVISIONING"   	${count}=1	 ${tmm_path}=${TMM_PATH}    ${no_of_lines}=1		${mStore_session}=mStore
    ${current_tmm_path}=    Execute Command    echo ${tmm_path}/`date +%Y-%m/%d`
    Switch Connection    ${mStore_session}
    ${hdr_file}=    Execute Command    ls -lrt /data/redun/tmm/*.hdr |grep ${service_type} |awk '{print $NF}'
	${files}=		Execute Command    ls -lrt ${current_tmm_path}/*.csv
	log		${files}
    ${kpi_file}=    Execute Command    ls -lrt ${current_tmm_path}/*.csv |grep ${service_type}|tail -n 1 |awk '{print $NF}'
    Should Not Be Empty    ${kpi_file}    msg="KPI file not generated for ${service_type}"
    ${kpi_data}=    Execute Command    cat ${kpi_file}
    log    ${kpi_data}
    ${kpi_data}=    Execute Command    cat ${kpi_file} |grep ,${count}, |tail -n ${no_of_lines}
    log    ${kpi_data}
    Should Not Be Empty    ${kpi_data}    msg="Counters are not generated for ${service_type}"
    Execute Command    cat ${kpi_file} |grep ,${count}, |tail -n ${no_of_lines} >/tmp/${service_type}.csv
    ${kpi_report}=    Execute Command    python /usr/IMS/current/tmm_def/tmmdecoder.py ${hdr_file} /tmp/${service_type}.csv
    log    ${kpi_report}
    Should Not Be Empty    ${kpi_report}    msg="saurav Check here"
    [Return]    ${kpi_report}
    
ValidateProvisioningKPIReport
    [Arguments]    ${kpi_data}    ${Field}    ${count}    ${v_Cos_id}=${COSID}
    log    ${v_Cos_id}
    ${data}=    Get Lines Containing String    ${kpi_data}    ${Field}
    log    ${data}
    Should Not Be Empty    ${data}    msg="Generated kpi report doen't contain Field ${Field}"
    ${dec_data}=    Split String    ${data}
    Should Be Equal As Strings    ${dec_data[3]}    ${count}
    ${StartTime}=    Get Lines Containing String    ${kpi_data}    STARTTIME
    ${StartTime}=    Split String    ${StartTime}    =
    ${StopTime}=    Get Lines Containing String    ${kpi_data}    STOPTIME
    ${StopTime}=    Split String    ${StopTime}    =
    ${NodeId}=    Get Lines Containing String    ${kpi_data}    NodeID
    ${NodeId}=    Split String    ${NodeId}    =
    ${CardId}=    Get Lines Containing String    ${kpi_data}    CardID
    ${CardId}=    Split String    ${CardId}    =
    ${Peer}=    Get Lines Containing String    ${kpi_data}    Peer
    ${Peer}=    Split String    ${Peer}    =
    ${CosId}=    Get Lines Containing String    ${kpi_data}    CosId
    ${CosId}=    Split String    ${CosId}    =
    log    ${v_Cos_id}
    Run Keyword and Continue on Failure    Should Match Regexp    ${StartTime[-1].strip()}    \\d{12}    msg="Failed to validate STARTTIME in Provision KPI"
    Run Keyword and Continue on Failure    Should Match Regexp    ${StopTime[-1].strip()}    \\d{12}    msg="Failed to validate STOPTTIME in Provision KPI"
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${NodeId[-1].strip()}    Mavenir    msg="Failed to validate NodeId in Provision KPI"
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${CardId[-1].strip()}    0    msg="Failed to validate CardId in Provision KPI"
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${Peer[-1].strip()}    ${LOCALHOST}    msg="Failed to Validate Peer in Provision KPI"
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${CosId[-1].strip()}    ${v_Cos_id}    msg="Failed to validate CosId in Provision KPI"

GetProvisionTRLdecodedData
    [Arguments]    ${nodeId}=${MSTORE_NODE_NAME}    ${trl_path}=${TRL_PATH}    ${no_of_trl}=1    ${interface_type}=${PROVISION_INTERFACE_TYPE}		${mStore_session}=mstore
    Switch Connection     ${mStore_session}
    ${current_trl_path}=    Execute Command    echo ${trl_path}/`date +%Y_%m/%d/%H`
    log    ${current_trl_path}
    Should Not Be Empty    ${current_trl_path}    msg="TRL path is empty"
    ${all_files}=    Execute Command    ls -lrt ${current_trl_path}/* |grep ${nodeId}_TRL.*gz
    log    ${all_files}
    ${latest_trl_file}=    Execute Command    ls -lrt ${current_trl_path}/* |grep ${nodeId}_TRL.*gz |awk '{print $NF}' |tail -n ${no_of_trl}
    log    ${latest_trl_file}
    Should Not Be Empty    ${latest_trl_file}    msg="TRL file not generated for ${TEST NAME} in ${current_trl_path} path "
    ${complete_data}=    Execute Command    zcat ${latest_trl_file}
    log    ${complete_data}
    ${full_data}=    Execute Command    zcat ${latest_trl_file}|grep ,mstore,${interface_type}, |tail -n ${no_of_trl} 
    log    ${full_data}
    Should Not Be Empty    ${full_data}    msg="No data exist in file ${latest_trl_file}"
    Set Test Variable    ${CURRENT_TEST_TRL_FILE}    ${latest_trl_file}
    Run    echo "${full_data}" > /tmp/provision_trl_test.csv
    ${c_time}=    Get Time    epoch
    ${decoded_file}=    Set Variable    /tmp/trl_decodeddata_${c_time}.txt
    ${result}=    Run    ${CURDIR}/../testfiles/trlDecoder.sh /tmp/provision_trl_test.csv ${CURDIR}/../testfiles/mStore_Provision_TRL_Fields.txt
    log    ${result}
    Run    echo "${result}" > ${decoded_file}
    [Return]    ${full_data}    ${decoded_file}


ValidateProvisionTRL
    [Arguments]    ${trl_data}    ${decoded_file_data}    ${static_fields_to_validate}    ${regex_fields_to_validate}
    Should Not Be Empty    ${trl_data}    msg="Given trl doesn't contain Provision Interface"
    ${trl_fields}=    Split String    ${trl_data}    ,
    log    ${trl_fields}
    ${length_of_trl}=    Get Length    ${trl_fields}
    Should Be Equal    ${length_of_trl}    ${PROVISION_TRL_LENGTH}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${trl_fields[0]}    ${SHELF_ID}-${SLOT_ID}:${FE_NAME}    msg="Failed to Validate ${PROVISION_TRL_FIELDS[1]}"
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${trl_fields[1]}    ${PRODUCT}    msg="Failed to Validate ${PROVISION_TRL_FIELDS[2]}"
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${trl_fields[2]}    ${PROVISION_INTERFACE_TYPE}    msg="Failed to Validate ${PROVISION_TRL_FIELDS[3]}"
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${trl_fields[3]}    0    msg="Failed to Validate ${PROVISION_TRL_FIELDS[4]}"
    Run Keyword and Continue on Failure    Should Match Regexp    ${trl_fields[4]}    \\d+    msg="Failed to Validate ${PROVISION_TRL_FIELDS[5]}"
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${trl_fields[5]}    0    msg="Failed to Validate ${PROVISION_TRL_FIELDS[6]}"
    Run Keyword and Continue on Failure    Should Match Regexp    ${trl_fields[6]}    \\d{11}    msg="Failed to Validate ${PROVISION_TRL_FIELDS[7]}"
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${trl_fields[7]}    0    msg="Failed to Validate ${PROVISION_TRL_FIELDS[8]}"
    Run Keyword and Continue on Failure    Should Match Regexp    ${trl_fields[49]}    \\d{11}    msg="Failed to Validate ${PROVISION_TRL_FIELDS[50]}"
    Run Keyword and Continue on Failure    Should Match Regexp    ${trl_fields[50]}    \\d+    msg="Failed to Validate ${PROVISION_TRL_FIELDS[51]}"

    :FOR    ${i}    IN RANGE    8    ${PROVISION_TRL_LENGTH}
    \    ${key}=    Evaluate    ${i}+1
    \    ${value}=    Set Variable    ${PROVISION_TRL_FIELDS[${key}]}
    \    log    ${trl_fields[${i}]}
    \    ${key}=    Convert To String    ${key}
    \    ${static_status}=    Run Keyword and return Status    Dictionary Should Contain Key    ${static_fields_to_validate}    ${key}
    \    ${regex_status}=    Run Keyword and return Status    Dictionary Should Contain Key    ${regex_fields_to_validate}    ${key}
    \    Run Keyword If    ${static_status} == True    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${trl_fields[${i}]}    ${static_fields_to_validate['${key}']}    msg="TRL validation Failed for ${key} ${value} field"
    \    Run Keyword If    ${regex_status} == True    Run Keyword and Continue on Failure    Should Match Regexp    ${trl_fields[${i}]}    ${regex_fields_to_validate['${key}']}    msg="TRL validation Failed for ${key} ${value} field"
    \    Run Keyword If    '${regex_status}' == 'False' and '${static_status}' == 'False'    Run Keyword and Continue on Failure    Should Be Empty    ${trl_fields[${i}]}    msg="TRL validation Failed for ${key} ${value} field"

    
ValidateRestResponseHeaders
    [Arguments]    ${response}    ${reason_phrase}=${EMPTY}
    ${content_length}=    Get Length    ${response.text}
    Run Keyword and Continue on Failure    Should Match Regexp    ${response.headers['date']}    [a-zA-Z0-9 :,]+
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${response.headers['content-length']}    ${content_length}
    Run Keyword and Continue on Failure    Run Keyword If    '${reason_phrase}' != '${EMPTY}'    Should Be Equal As Strings    ${response.headers['reason-phrase']}    ${reason_phrase}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${response.headers['server']}    ${RESPONSE_HEADER_SERVER_NAME}
    Run Keyword and Continue on Failure    Should Match Regexp    ${response.headers['x-mstorefe-addr']}    FEname:${FE_NAME}-nodeId:${NODE_ID}-ConnId:[a-zA-Z0-9]+-slot:${SLOT_ID}-instId:[0-9]+-subOid:[0-9]+-time:[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z-localFqdn:${LOCAL_FQDN}
    

ValidateSoapResponseHeaders
    [Arguments]    ${response}    ${content_type}=text/xml
    log		${response.headers}
    ${content_length}=    Get Length    ${response.text}
    Run Keyword and Continue on Failure    Should Match Regexp    ${response.headers['date']}    [a-zA-Z0-9 :,]+
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${response.headers['content-length']}    ${content_length}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${response.headers['content-type']}    ${content_type}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${response.headers['server']}    ${RESPONSE_HEADER_SERVER_NAME}
    #Run Keyword and Continue on Failure    Should Match Regexp    ${response.headers['x-mstorefe-addr']}    FEname:${FE_NAME}-nodeId:${NODE_ID}-ConnId:[a-zA-Z0-9]+-slot:${SLOT_ID}-instId:[0-9]+-subOid:[0-9]+-time:[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z-localFqdn:${LOCAL_FQDN}


ValidateResponseHeader
    [Arguments]    ${response}    ${content_type}=${STORE_RESPONSE_CONTENT_TYPE}
    Run Keyword and Continue on Failure    Should Match Regexp    ${response.headers['date']}    [a-zA-Z0-9 :,]+
    Run Keyword and Continue on Failure    Should Match Regexp    ${response.headers['content-length']}    \\d+
    Run Keyword and Continue on Failure    Should Be Equal    ${response.headers['content-type']}    ${content_type}
    Run Keyword and Continue on Failure    Should Be Equal    ${response.headers['location']}    ${response.text['objectReference']['resourceURL']}
    Run Keyword and Continue on Failure    Should Be Equal    ${response.headers['server']}    ${RESPONSE_HEADER_SERVER_NAME}
    Run Keyword and Continue on Failure    Should Match Regexp    ${response.headers['x-mstorefe-addr']}    FEname:${FE_NAME}-nodeId:${NODE_ID}-ConnId:[a-zA-Z0-9]+-slot:${SLOT_ID}-instId:[0-9]+-subOid:[0-9]+-time:[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z-localFqdn:${LOCAL_FQDN}




ValidateSubscriberCassandraDynamicFoldersmapTable
    [Arguments]    ${folders}=&{EMPTY}    ${userId}=${USERID}    ${table}=dynamicfolder
    ${count}=    Get Length    ${folders}
    Switch Connection    cass_db
    Write    SELECT foldername,folderkey FROM ${table} where userid = '${userId}';
    ${dynamicfolder_data}=    Read Until    \>
    Should Contain    ${dynamicfolder_data}    ${count} rows    msg="doesn't contain all the folders in dynamicfolder for the corresponding cosId"
    ${folder_path}=    Get Dictionary Keys    ${folders}
    :FOR    ${path}    IN    @{folder_path}
    \    ${dynamicfolder_data}=    Get Lines Containing String    ${dynamicfolder_data}    ${path}
    \    ${dynamicfolder_data}=    Split String    ${dynamicfolder_data}    |
    \    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${folders['${path}']}    ${dynamicfolder_data[1].strip()}



ValidateSubscriberCassandraUsersTableAfterDeletingSubscriber
    [Arguments]    ${subId}=${SUBSCRIBER_ID}	${userId}=${USERID}		${imdnmessageid}=${IMDN_MESSAGE_ID}
    Switch Connection    cass_db
    Write    SELECT JSON * FROM users WHERE userid='${subId}';
    ${users_out}=    Read Until    \>
    Run Keyword and Continue on Failure		Should Contain    ${users_out}    (0 rows)    msg="${userId} not deleted Successfully"
    Write    SELECT JSON * FROM userfolderkeymap WHERE userid='${userId}';
    ${users_out}=    Read Until    \>
	Run Keyword and Continue on Failure    Should Contain    ${users_out}    (0 rows)    msg="${userId} not deleted Successfully"
    Write    SELECT JSON * FROM folder WHERE userid='${userId}';
    ${users_out}=    Read Until    \>
	Run Keyword and Continue on Failure    Should Contain    ${users_out}    (0 rows)    msg="${userId} not deleted Successfully"
    Write    SELECT JSON * FROM messages_by_original_folder_timestamp WHERE userid='${userId}';
    ${users_out}=    Read Until    \>
    Run Keyword and Continue on Failure		Should Contain    ${users_out}    (0 rows)    msg="${userId} not deleted Successfully"
    Write    SELECT JSON * FROM nms_subscriptions_mapping WHERE userid='${userId}';
    ${users_out}=    Read Until    \>
    Run Keyword and Continue on Failure		Should Contain    ${users_out}    (0 rows)    msg="${userId} not deleted Successfully"
    Write    SELECT JSON * FROM messages_by_original_folder_timestamp WHERE userid='${userId}';
    ${users_out}=    Read Until    \>
    Run Keyword and Continue on Failure		Should Contain    ${users_out}    (0 rows)    msg="${userId} not deleted Successfully"
    Write    SELECT JSON * FROM messages_by_root_folder_timestamp WHERE userid='${userId}';
    ${users_out}=    Read Until    \>
    Run Keyword and Continue on Failure		Should Contain    ${users_out}    (0 rows)    msg="${userId} not deleted Successfully"
    Write    SELECT JSON * FROM flag_changes_by_original_folder_timestamp WHERE userid='${userId}';
    ${users_out}=    Read Until    \>
    Run Keyword and Continue on Failure		Should Contain    ${users_out}    (0 rows)    msg="${userId} not deleted Successfully"
    Write    SELECT JSON * FROM flag_changes_by_root_folder_timestamp WHERE userid='${userId}';
    ${users_out}=    Read Until    \>
    Run Keyword and Continue on Failure		Should Contain    ${users_out}    (0 rows)    msg="${userId} not deleted Successfully"
    Write    SELECT JSON * FROM message_activity WHERE imdnmessageid='${imdnmessageid}';
    ${users_out}=    Read Until    \>
    Run Keyword and Continue on Failure		Should Contain    ${users_out}    (0 rows)    msg="${userId} not deleted Successfully"
    Write    SELECT JSON * FROM imdnmsgidmapping WHERE userid='${userId}';
    ${users_out}=    Read Until    \>
    Run Keyword and Continue on Failure		Should Contain    ${users_out}    (0 rows)    msg="${userId} not deleted Successfully"


GenerateUniqueIMDNMsgId
	${str1}=	Generate Random String	8	[NUMBERS]abcdef
    ${str2}=    Generate Random String  4   [NUMBERS]abcdef
    ${str3}=    Generate Random String  4   [NUMBERS]abcdef
    ${str4}=    Generate Random String  4   [NUMBERS]abcdef
    ${str5}=    Generate Random String  12   [NUMBERS]abcdef
	${imdnMsId}=	Set Variable	${str1}-${str2}-${str3}-${str4}-${str5}
	log		${imdnMsId}
	[Return]	${imdnMsId}

	#[Arguments]		${length}=10	${randomchoice}=0123456789abcdef
	#${randomString}=	Evaluate	 ''.join(random.choice(${randomchoice}) for i in range(8))		random
	#log		${randomString}
	#[Return]	${randomString}
