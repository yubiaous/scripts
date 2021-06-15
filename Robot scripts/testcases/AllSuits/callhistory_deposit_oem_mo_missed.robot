*** Settings ***
#Comment
Resource        ../../resources/mStore_Digits_TMO_resources.robot
Resource		../../resources/Provision.robot
Metadata    	Version        MSTR-P.4.2.14.3
Suite Setup     prepare_suitebed
Suite Teardown  custom_suite_teardown
Test Timeout	2m
Documentation	"Digits CallHistory MO Flow"

*** Variables ***
${SUBSCRIBER_ID}=	${FROM_MSISDN}
${COSID}=			${DIGITS_COS}
${MSG_TYPE}=		MO
${DIRECTION}=		Out
${ASSERTED_SERVICE}=	${NONE}
${MESSAGE_CONTEXT}=     ${CALLHISTORY_MESSAGE_CONTEXT}
${PNS_TYPE}=			${CH_PNS_TYPE}
${PNS_SUBTYPE}=			${CH_PNS_SUBTYPE}
${CALL_STATUS}=			Missed
${push_recipients_uri}=		${MSG_FROM}

*** Keywords ***
prepare_testbed
	${CORE_CNT_BT}=		GetCoresCount
	Set Suite Variable	${CORE_CNT_BT}
	ClearTRLs_TMMs
	start_capturing_logs
	start_packet_capture

custom_teardown
	${CORE_CNT_AT}=     GetCoresCount
	stop_capturing_logs
	stop_packet_capture
	Run Keyword and Continue on Failure		Should Be Equal		${CORE_CNT_BT}		${CORE_CNT_AT}		msg="cores are generated during ${TEST_NAME}"

prepare_suitebed
	log to console	${SUITE NAME.rsplit('.')[-1]}
	login_to_mstore
	login_to_mstore_dbm
	login_to_cassandra_db
	CreatemStoreSubscriberSession	mstore_service_port=80
	startPNSserver
	get_mStore_NodeID
	

custom_suite_teardown
	stopPNSserver
	Close All Connections
	Delete All Sessions


startPNSserver
	${PNS_SOCKET_SERVICE}=	StartHttpServer		host=${PNS_SERVER}		port=${PNS_SERVICE_PORT}
	Set Suite variable		${PNS_SOCKET_SERVICE}

stopPNSserver
	StopHttpServer	${PNS_SOCKET_SERVICE}


CassandraFolderValidation
    [Arguments]     ${folders}      ${userId}
    Run Keyword and Continue on Failure    ValidateUserFolderKeymapTable    folders=${folders}          userId=${userId}
    Run Keyword and Continue on Failure    ValidateFolderTable              folders=${folders}          userId=${userId}



ArchivePMMessage_MO
	${response}=	Deposit_Message        DIRECTION_VALUE=${DIRECTION}    headers=${OEM_DEPOSIT_HEADERS}

alidateUserFolderKeymapTable
    [Arguments]    ${folders}=&{EMPTY}    ${userId}=${USERID}
    ${count}=    Get Length    ${folders}
    Switch Connection    cass_db
    Write    SELECT json * FROM userfolderkeymap where userid = '${userId}';
    ${userfolderkeymapdatas}=    Read Until    \>
    Should Contain    ${userfolderkeymapdatas}    (${count} rows)    msg="doesn't contain all the folders in userfolderkeymap for the corresponding cosId"
    ${folder_names}=    Get Dictionary Keys    ${folders}
    :FOR    ${foldername}    IN    @{folder_names}
    \    ${fk_userfolderkeymapdata}=    Get Lines Containing String    ${userfolderkeymapdatas}    \"${foldername}\"
    \   ${fk_userfolderkeymapdata}=     Evaluate    json.loads('''${fk_userfolderkeymapdata}''')    json
    \    log    ${fk_userfolderkeymapdata}
    \    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${folders['${foldername}']}    ${fk_userfolderkeymapdata['folderkey']}
    Set Suite Variable    ${ContainerData}      None
*** TestCases ***
#TRL,TMM,Corecheck,cass TTL
#
DeleteSubscriberAlreadyExists
	[Documentation]		"Delete Subscriber If already Exists"
	[Tags]               Provision
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    ${status}    ${delete_response}=		Run Keyword and Ignore Error     DeleteSubscriber_SOAP   ${SUBSCRIBER_ID}
    Run Keyword and Continue on Failure     ValidateDeleteSubscriberResponse    ${delete_response}
    Run Keyword and Continue on Failure     ValidateSoapResponseHeaders     response=${delete_response}
    Run Keyword and Continue on Failure     ValidateSubscriberCassandraUsersTableAfterDelete




AddSubscriber_ValidateResponse
    [Documentation]     "Add new Subscriber and Validate response and cassandra users userfolderkeymap table"
    [Tags]              Provision
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    ${add_response}=    Run Keyword and Continue on Failure     AddSubscrber_SOAP
    Run Keyword and Continue on Failure     ValidateAddSubscriberResponse   response=${add_response}
    Run Keyword and Continue on Failure     ValidateSoapResponseHeaders     response=${add_response}
    ${listOfFolders}=   Run Keyword and Continue on Failure     GetNumberFolderPathfromClassofService
    Run Keyword and Continue on Failure     ValidateSubscriberCassandraUsersTable   imappwd=${IMAPPWD}  pinpwd=${PINPWD}  nut=0  pin_encrypted=0  vvmon=0
    Run Keyword and Continue on Failure     CassandraFolderValidation   folders=${listOfFolders}        userId=${USERID}
    Run Keyword and Continue on Failure     Peg_TMM_file_immediately
    Sleep   10



Deposit_CallHistory
	[Documentation]		"Deposit Call History"
	[Tags]				PM_OEM_MO	Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    ${response}=    Deposit_Message       headers=${CH_DEPOSIT_HEADERS}	  object_file=${CALLHISTORY_DEPOSIT_OBJ_FILE1}	url=${HOST_NMS_URI}
	${resource_url}=   Set Variable    ${response.json()['objectReference']['resourceURL']}
	${resource_url}=	Fetch From Right	${resource_url}		/
	${resource_url}=	Split String	${resource_url}		%3a
	log		${resource_url} 
	${request}=		GetServicerequest	${PNS_SOCKET_SERVICE}
	${headers}		${req_body}		${version}=		GetRequestData	${request}
	log		${req_body}
	Set Suite Variable		${CALLHISTORY_PARENT_FOLDER_KEY}		${CallHistory}
	Set Suite Variable      ${CALLHISTORY_MESSAGE_FOLDER_KEY}	${resource_url[0]}
    Set Suite Variable      ${CALLHISTORY_UID}   ${resource_url[1]}
	Set Suite Variable		${UID}		${resource_url[1]}
	${pns_status}	${value}=		Run Keyword and Ignore Error	ValidateCallHistoryPNSNotfn		uid=${CALLHISTORY_UID}		pns_headers=${headers}	pns_body=${req_body}	msgStatus=${MSGSTATUS1} 	pns_subtype=History	
	Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "PASS"   SendResponse    ${request}  200     OK  ${version}  ELSE    SendResponse    ${request}  400     BadRequest   ${version}
    Run Keyword and Continue on Failure     ValidateCassandraForCallHistory		userId=${USERID}		answered=0
	Run Keyword and Continue on Failure 	Run Keyword If      "${pns_status}" == "FAIL"   FAIL	PNS notification verification failed \n ${value}
	CloseRequest    ${request}






FolderSearchAfterDeposit
	[Documentation]		"Folder search after depositing the message"
	[Tags]              PM_OEM_MO   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	${response}=	FolderSearch		folderkey=${CALLHISTORY_PARENT_FOLDER_KEY}		headers=${OEM_FOLDER_SEARCH_HEADER}	
	ValidateCallHistoryFolderSearchResponse		response=${response}	msgStatus=\$${MSGSTATUS1}		uid=${CALLHISTORY_UID}



Fetch_CallLog
	[Tags]              PM_OEM_MO   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	${response}=	FetchMessageObject	ResourceURI=${OBJECT_URL}	headers=${OEM_FETCH_HEADERS}
	ValidateCallHistoryFetchResponse	uid=${UID}		response=${response}	msgStatus=\$${MSGSTATUS1}


Update_Msg_from_Seen_to_Recent
	[Tags]              PM_OEM_MO   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	UpdateFlagToMessage		flag=Recent		headers=${OEM_FETCH_HEADERS}
    ${request}=     GetServicerequest  ${PNS_SOCKET_SERVICE}
    ${headers}      ${req_body}     ${version}=     GetRequestData  ${request}
    ${pns_status}   ${value}=       Run Keyword and Ignore Error        ValidateUpdateCallHistoryPNSNotfn 	pns_headers=${headers}  pns_body=${req_body}	msgStatus=recent,missed		uid=${UID}		pns_subtype=HistoryS
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "PASS"   SendResponse    ${request}  200     OK  ${version}  ELSE    SendResponse    ${request}  400     BadRequest   ${version}
    Run Keyword and Continue on Failure     ValidateCassandraForCallHistory     answered=0	recent=1		uid=0
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "FAIL"   FAIL    PNS notification verification failed \n ${value}	
    CloseRequest    ${request}


FolderSearchAfterUpdatingtheFlagtoRecent
	Log to Console  "Folder search after depositing the message"
	[Tags]              PM_OEM_MO   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    #Run Keyword and Continue on Failure     ValidateChatFolderSearchResponse    response=${response}		msgStatus=recent	direction=${DIRECTION}	 imdn_type=displayed
    ${response}=    FolderSearch        folderkey=${CALLHISTORY_PARENT_FOLDER_KEY}      headers=${OEM_FOLDER_SEARCH_HEADER}	
    ValidateCallHistoryFolderSearchResponse     response=${response}	msgStatus=\\recent,\$${MSGSTATUS1}




Update_Msg_from_Recent_to_Seen
	[Tags]              PM_OEM_MO   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	UpdateFlagToMessage    flag=Seen	headers=${OEM_FETCH_HEADERS}
    ${request}=     GetServicerequest  ${PNS_SOCKET_SERVICE}
    ${headers}      ${req_body}     ${version}=     GetRequestData  ${request}
#    ${pns_status}   ${value}=       Run Keyword and Ignore Error        ValidateUpdateCallHistoryPNSNotfn 	pns_headers=${headers}  pns_body=${req_body}	msgStatus=	seen,missed			uid=${UID}			folder_path=CallHistory
   ${pns_status}   ${value}=       Run Keyword and Ignore Error        ValidateUpdateCallHistoryPNSNotfn   pns_headers=${headers}  pns_body=${req_body}    msgStatus=seen,missed        uid=${UID}      pns_subtype=HistoryS

    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "PASS"   SendResponse    ${request}  200     OK  ${version}  ELSE    SendResponse    ${request}  400     BadRequest   ${version}
    Run Keyword and Continue on Failure     ValidateCassandraForCallHistory     answered=0	seen=1	recent=0		uid=0
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "FAIL"   FAIL    PNS notification verification failed \n ${value}
	CloseRequest    ${request}


FolderSearchAfterUpdatingtheFlagtoSeen
	Log to Console  "Folder search after seeing the message"
	[Tags]              PM_OEM_MO   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    ${response}=    FolderSearch        folderkey=${CALLHISTORY_PARENT_FOLDER_KEY}      headers=${OEM_FOLDER_SEARCH_HEADER}
    ValidateCallHistoryFolderSearchResponse     response=${response}	msgStatus=\\seen,\$${MSGSTATUS1}








Delete_CallLog
    [Tags]              PM_OEM_MO   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    ${response}=    DeleteMsgObject 	response_code=204   headers=${OEM_FETCH_HEADERS}
    Sleep   1
    ${request}=     GetServicerequest  ${PNS_SOCKET_SERVICE}
    ${headers}      ${req_body}     ${version}=     GetRequestData  ${request}
    ${pns_status}   ${value}=       Run Keyword and Ignore Error        ValidateCallHistoryDeletePNSNotfn   pns_headers=${headers}  pns_body=${req_body}    pns_subtype=HistoryD    uid=${CALLHISTORY_UID}
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "PASS"   SendResponse    ${request}  200     OK  ${version}  ELSE    SendResponse    ${request}  400     BadRequest   ${version}
    Run Keyword and Continue on Failure     ValidateCassandraMessagesAfterDelete    userId=${USERID}    messages=1  messages_by_folder_timestamp=1  parent_folder_key=${CALLHISTORY_PARENT_FOLDER_KEY}  message_folder_key=c65f2cff-67eb-4ca1-a5e0-68f2066b20af
    Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping        userId=${USERID}    cnt=0       uid=${CALLHISTORY_UID}      folderkey=c65f2cff-67eb-4ca1-a5e0-68f2066b20af
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "FAIL"   FAIL    PNS notification verification failed \n ${value}
    CloseRequest    ${request}












	
Redelete_CallLog
	[Tags]              PM_OEM_MO   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	${response}=    DeleteMsgObject	response_code=204	headers=${OEM_FETCH_HEADERS}




FolderSearchAfterDeletingtheMsg
	[Tags]              PM_OEM_MO   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	${response_code}=	Set Variable If		${EnableDeltraSync} == True		200		204
    ${response}=    FolderSearch        folderkey=${CALLHISTORY_PARENT_FOLDER_KEY}      headers=${OEM_FOLDER_SEARCH_HEADER}		response_code=${response_code}
    Run Keyword If      ${EnableDeltraSync} == True     Run Keyword and Continue on Failure		ValidateCallHistoryFolderSearchResponse     response=${response}	msgStatus=\\deleted




