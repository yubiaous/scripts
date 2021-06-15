*** Settings ***
#Comment
Resource        ../../resources/mStore_Digits_TMO_resources.robot
Resource		../../resources/Provision.robot
Resource        ../../resources/mStore_Generic_resources.robot
Metadata    	Version        MSTR-P.4.2.14.3
Suite Setup     prepare_suitebed
Suite Teardown  custom_suite_teardown
Test Timeout	2m
Documentation	"Digits PM OEM MT Flow"

*** Variables ***
${SUBSCRIBER_ID}=	${TO_MSISDN}
${COSID}=			${DIGITS_COS}
${MSG_TYPE}=		MT
${DIRECTION}=		In
${ASSERTED_SERVICE}=    ${P_ASSERTED_SERVICE_PM}
${X_IMDN_CORRELATOR}=   ${SUBSCRIBER_ID}_${CONVERSATION_ID}_${IMDN_MESSAGE_ID}
${MESSAGE_CONTEXT}=     ${PM_MESSAGE_CONTEXT}
${PNS_TYPE}=            ${PM_PNS_TYPE}
${PNS_SUBTYPE}=         ${PM_PNS_SUBTYPE}
${trl_timer}=           10
${PNS_TRL_DIRECTION_VALUE}=		1

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
    ${status}=      Run Keyword and Ignore Error    Variable Should Exist   ${request}
    Run Keyword If  '${status[0]}' == 'PASS'    CloseRequest    ${request}

prepare_suitebed
	log to console	${SUITE NAME.rsplit('.')[-1]}
	login_to_mstore
	login_to_mstore_dbm
	login_to_cassandra_db
	CreatemStoreSubscriberSession	mstore_service_port=80
	startPNSserver
	get_mStore_NodeID	
    ${IMDN_MESSAGE_ID}=     GenerateUniqueIMDNMsgId
    Set Suite Variable  ${IMDN_MESSAGE_ID}
    ${X_IMDN_CORRELATOR}=   Set Variable    ${SUBSCRIBER_ID}_${IMDN_MESSAGE_ID}
    Set SUite Variable  ${X_IMDN_CORRELATOR}
    Set Suite Variable  ${CORRELATION_ID}   ${IMDN_MESSAGE_ID}
    ${IMDN_MESSAGE_IDS}=    Create Dictionary   1=${IMDN_MESSAGE_ID}
    Set Suite Variable      ${IMDN_MESSAGE_IDS}



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
    [Arguments]     ${folders}
    Run Keyword and Continue on Failure    ValidateUserFolderKeymapTable    folders=${folders}
    Run Keyword and Continue on Failure    ValidateFolderTable              folders=${folders}



*** TestCases ***
DeleteSubscriberAlreadyExists
	[Documentation]		"Delete Subscriber If already Exists"
    [Tags]              Provision   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    ${status}    ${delete_response}=		Run Keyword and Ignore Error     DeleteSubscriber_SOAP   ${SUBSCRIBER_ID}
    Run Keyword and Continue on Failure     ValidateDeleteSubscriberResponse    ${delete_response}
    Run Keyword and Continue on Failure     ValidateSoapResponseHeaders     response=${delete_response}
    Run Keyword and Continue on Failure     ValidateSubscriberCassandraUsersTableAfterDelete

AddSubscriber_ValidateResponse
	[Documentation]		"Add new Subscriber and Validate response and cassandra users userfolderkeymap table"
    [Tags]              Provision
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    ${add_response}=    Run Keyword and Continue on Failure     AddSubscrber_SOAP
    Run Keyword and Continue on Failure     ValidateAddSubscriberResponse   response=${add_response}
    Run Keyword and Continue on Failure     ValidateSoapResponseHeaders     response=${add_response}
    ${listOfFolders}=   Run Keyword and Continue on Failure     GetNumberFolderPathfromClassofService
    Run Keyword and Continue on Failure     ValidateSubscriberCassandraUsersTable   imappwd=${EMPTY}  pinpwd=${EMPTY}  nut=0  pin_encrypted=0  vvmon=0
    #Run Keyword and Continue on Failure     CassandraFolderValidation   folders=${listOfFolders}

Deposit_PM_Message
    [Tags]                 Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	${response}=	Deposit_Message		DIRECTION_VALUE=${DIRECTION}
	${resource_url}=   Set Variable    ${response.json()['objectReference']['resourceURL']}
    ${resource_url}=    Fetch From Right    ${resource_url}     /
    ${resource_url}=    Split String    ${resource_url}     %3a
    ${r_url}=   Replace String  ${resource_url[0]}      %3d     =
    log     ${resource_url}
	Sleep	1
	${request}=		GetServicerequest	${PNS_SOCKET_SERVICE}
	Set Test Variable   ${request}
	${headers}		${req_body}		${version}=		GetRequestData	${request}
	Set Suite Variable		${RCS_PARENT_FOLDER_KEY}		${Generic_Cos_Path_Ids['${RCS_PARENT_PATH}']}
    Set Suite Variable      ${RCS_MESSAGE_FOLDER_KEY}  ${r_url}

    Set Suite Variable  ${CREATION_TUID}    ${resource_url[-1]}
    ${r_url1}=   Replace String  ${resource_url[0]}      %3d     ${EMPTY}
    Set Suite Variable      ${msgFolderkey1}   ${r_url1}
    ${uid}=     Set Variable    ${resource_url[1]}
    Set Suite Variable      ${UID}      ${uid}

	${pns_status}	${value}=		Run Keyword and Ignore Error		ValidateChatPNSNotfn	pns_headers=${headers}	pns_body=${req_body}	direction=${DIRECTION}		msgStatus=RECENT	push_recipients_uri=${MSG_TO}		 uid=${UID} 		folder_path=${CHAT_PARENT_FOLDER_PATH}/${SUBSCRIBER_ID}/	
	Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "PASS"   SendResponse    ${request}  200     OK  ${version}  ELSE    SendResponse    ${request}  400     BadRequest   ${version}
    #Run Keyword and Continue on Failure     ValidateCassandraMessagesTable  recent=1    seen=0			 uid=${UID}
	Run Keyword and Continue on Failure     ValidateCassandraMessagesTable_C44  userId=${USERID}    recent=1    seen=0     uid=${UID}

    Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping   			uid=${UID} 		foldername=${CHAT_PARENT_FOLDER_PATH}/${SUBSCRIBER_ID}/
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "FAIL"   FAIL    PNS notification verification failed \n ${value}



FolderSearchAfterDeposit
    [Tags]                 Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	Log to Console	"Folder search after depositing the message"
	${response}=	FolderSearch		folderkey=${RCS_PARENT_FOLDER_KEY}
	Run Keyword and Continue on Failure		ValidateChatFolderSearchResponse	direction=${DIRECTION}		response=${response}		uid=${UID}		msgStatus=recent		FROM_MSISDN=${TO_MSISDN}




Deliver_PM_Message
    [Tags]                 Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	Log To Console          "Deliver PM message"
    Deposit_Message		X_RCS_MSG_STATUS=Delivered	object_file=${DELIVER_DISPLAY_OBJ_FILE}		MESSAGE_CONTEXT=X-RCS-IMDN	 DIRECTION_VALUE=Out
    ${request}=     GetServicerequest  ${PNS_SOCKET_SERVICE}
	Set Test Variable   ${request}
    ${headers}      ${req_body}     ${version}=     GetRequestData  ${request}
    ${pns_status}   ${value}=     Run Keyword and Ignore Error	ValidateChatPNSNotfn        pns_headers=${headers} 	 	pns_body=${req_body}		msgStatus=RECENT,DELIVERED		direction=${DIRECTION}	push_recipients_uri=${MSG_TO}		 uid=${UID}		pns_subtype=ChatS		folder_path=${CHAT_PARENT_FOLDER_PATH}/${SUBSCRIBER_ID}/
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "PASS"   SendResponse    ${request}  200     OK  ${version}  ELSE    SendResponse    ${request}  400     BadRequest   ${version}
#	Run Keyword and Continue on Failure        ValidateCassandraMessagesTable_C44	delivered=1		recent=1	seen=0		uid=${UID}	
    Run Keyword and Continue on Failure     ValidateCassandraMessagesTable_C44   userId=${USERID}    recent=1    seen=0      uid=${UID}         delivered=1 
    Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping    	uid=${UID}		foldername=${CHAT_PARENT_FOLDER_PATH}/${SUBSCRIBER_ID}/
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "FAIL"   FAIL    PNS notification verification failed \n ${value}



FolderSearchAfterIMDNDelivered
    [Tags]                 Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    Log to Console  "Folder search after seeing the message"
    ${response}=    FolderSearch
    Run Keyword and Continue on Failure     ValidateChatFolderSearchResponse    direction=${DIRECTION}    response=${response}   		msgStatus=recent,delivered		uid=${UID}		FROM_MSISDN=${TO_MSISDN}





Display_PM_Message
    [Tags]                 Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	Log To Console          "Display PM message"
    Deposit_Message			X_RCS_MSG_STATUS=Displayed	object_file=${DELIVER_DISPLAY_OBJ_FILE}		MESSAGE_CONTEXT=X-RCS-IMDN	DIRECTION_VALUE=Out
    ${request}=     GetServicerequest  ${PNS_SOCKET_SERVICE}
	Set Test Variable   ${request}
    ${headers}      ${req_body}     ${version}=     GetRequestData  ${request}
    ${pns_status}   ${value}=     Run Keyword and Ignore Error	ValidateChatPNSNotfn        pns_headers=${headers}  pns_body=${req_body}	msgStatus=SEEN,DELIVERED		direction=${DIRECTION}	push_recipients_uri=${MSG_TO}		uid=${UID}			pns_subtype=ChatS		folder_path=${CHAT_PARENT_FOLDER_PATH}/${SUBSCRIBER_ID}/	
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "PASS"   SendResponse    ${request}  200     OK  ${version}  ELSE    SendResponse    ${request}  400     BadRequest   ${version}
#    Run Keyword and Continue on Failure        ValidateCassandraMessagesTable       delivered=1		seen=1	recent=0	
    ${creation_tuid}    ${modification_tuid}=   Run Keyword and Continue on Failure     ValidateCassandra_messages_by_original_folder_timestamp_CHAT    recent=0    seen=1  delivered=1  
    Run Keyword and Continue on Failure     ValidateCassandra_messages_by_root_folder_timestamp     recent=0    seen=1      modification_tuid=${modification_tuid}      delivered=1
	Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping   		uid=${UID} 		foldername=${CHAT_PARENT_FOLDER_PATH}/${SUBSCRIBER_ID}/
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "FAIL"   FAIL    PNS notification verification failed \n ${value}




	
FolderSearchAfterIMDNArchival
    [Tags]                 Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	Log to Console	"Folder search after seeing the message"
	${response}=    FolderSearch
    Run Keyword and Continue on Failure     ValidateChatFolderSearchResponse    direction=${DIRECTION}	response=${response}	msgStatus=seen	uid=${UID}      FROM_MSISDN=${TO_MSISDN}





Fetch_PM_Message
    [Tags]                 Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	${response}=	FetchMessageObject	ResourceURI=${OBJECT_URL}	
	ValidateChatFetchResponse	response=${response}	msgStatus=seen,delivered		direction=${DIRECTION}		uid=${UID}	 FROM_MSISDN=${TO_MSISDN}





Update_Msg_from_Seen_to_Recent
    [Tags]                 Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	UpdateFlagToMessage		flag=Recent
    ${request}=     GetServicerequest  ${PNS_SOCKET_SERVICE}
	Set Test Variable   ${request}
    ${headers}      ${req_body}     ${version}=     GetRequestData  ${request}
    ${pns_status}   ${value}=     Run Keyword and Ignore Error	ValidateChatPNSNotfn     pns_headers=${headers}  pns_body=${req_body}	direction=${DIRECTION}     msgStatus=RECENT,DELIVERED	push_recipients_uri=${MSG_TO}	pns_subtype=ChatS	folder_path=${CHAT_PARENT_FOLDER_PATH}/${SUBSCRIBER_ID}/		uid=${UID}
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "PASS"   SendResponse    ${request}  200     OK  ${version}  ELSE    SendResponse    ${request}  400     BadRequest   ${version}
#    Run Keyword and Continue on Failure     ValidateCassandraMessagesTable	recent=1	delivered=1		 uid=${UID}
    ${creation_tuid}    ${modification_tuid}=   Run Keyword and Continue on Failure     ValidateCassandra_messages_by_original_folder_timestamp_CHAT    recent=1    seen=0  delivered=1      
    Run Keyword and Continue on Failure     ValidateCassandra_messages_by_root_folder_timestamp     recent=1    seen=0      modification_tuid=${modification_tuid}      delivered=1
    Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping   		uid=${UID} 			foldername=${CHAT_PARENT_FOLDER_PATH}/${SUBSCRIBER_ID}/
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "FAIL"   FAIL    PNS notification verification failed \n ${value}




FolderSearchAfterUpdatingtheFlagtoRecent
    [Tags]                 Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	Log to Console  "Folder search after depositing the message"
    ${response}=    FolderSearch
    Run Keyword and Continue on Failure     ValidateChatFolderSearchResponse    response=${response}		msgStatus=recent,delivered	direction=${DIRECTION}		uid=${UID}      FROM_MSISDN=${TO_MSISDN}



Update_Msg_from_Recent_to_Seen
    [Tags]                 Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	UpdateFlagToMessage    flag=Seen
	Sleep   1
    ${request}=     GetServicerequest  ${PNS_SOCKET_SERVICE}
	Set Test Variable   ${request}
    ${headers}      ${req_body}     ${version}=     GetRequestData  ${request}
	${pns_status}   ${value}=     Run Keyword and Ignore Error	ValidateChatPNSNotfn    pns_headers=${headers}  pns_body=${req_body}    msgStatus=SEEN,DELIVERED	direction=${DIRECTION}	push_recipients_uri=${MSG_TO}	pns_subtype=ChatS	folder_path=${CHAT_PARENT_FOLDER_PATH}/${SUBSCRIBER_ID}/		 uid=${UID}
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "PASS"   SendResponse    ${request}  200     OK  ${version}  ELSE    SendResponse    ${request}  400     BadRequest   ${version}
#	Run Keyword and Continue on Failure     ValidateCassandraMessagesTable	seen=1  recent=0	delivered=1		creation_tuid=${UID}
    #Run Keyword and Continue on Failure     ValidateCassandraMessagesTable_C44  recent=0    delivered=1      uid=${UID}
    ${creation_tuid}    ${modification_tuid}=   Run Keyword and Continue on Failure     ValidateCassandra_messages_by_original_folder_timestamp_CHAT    recent=0    seen=1  delivered=1       
    Run Keyword and Continue on Failure     ValidateCassandra_messages_by_root_folder_timestamp     recent=0    seen=1     modification_tuid=${modification_tuid}      delivered=1
    Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping   	uid=${UID}		foldername=${CHAT_PARENT_FOLDER_PATH}/${SUBSCRIBER_ID}/
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "FAIL"   FAIL    PNS notification verification failed \n ${value}


FolderSearchAfterUpdatingtheFlagtoSeen
    [Tags]                 Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	Log to Console  "Folder search after seeing the message"
	${response}=    FolderSearch
	Run Keyword and Continue on Failure     ValidateChatFolderSearchResponse    response=${response}    direction=${DIRECTION}	msgStatus=seen,delivered		uid=${UID}      FROM_MSISDN=${TO_MSISDN}


Delete_PM_Msg
    [Tags]                 Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	${response}=	DeleteMsgObject	response_code=204
	Sleep   1
	${request}=     GetServicerequest  ${PNS_SOCKET_SERVICE}
	Set Test Variable   ${request}
    ${headers}      ${req_body}     ${version}=     GetRequestData  ${request}
	${pns_status}   ${value}=     Run Keyword and Ignore Error	ValidateChatDeletePNSNotfn     pns_headers=${headers}  pns_body=${req_body}		msgStatus=DELETED		direction=${DIRECTION}	pns_subtype=ChatD	push_recipients_uri=${MSG_TO}		uid=${UID} 
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "PASS"   SendResponse    ${request}  200     OK  ${version}  ELSE    SendResponse    ${request}  400     BadRequest   ${version}
#    Run Keyword If  ${EnableDeltraSync} == True     Run Keyword and Continue on Failure     ValidateCassandraMessagesAfterDelete    messages=0  messages_by_folder_timestamp=1
 #   Run Keyword If  ${EnableDeltraSync} == False     Run Keyword and Continue on Failure     ValidateCassandraMessagesAfterDelete    messages=0  messages_by_folder_timestamp=0
    ${creation_tuid}    ${modification_tuid}=   Run Keyword and Continue on Failure     ValidateCassandra_messages_by_original_folder_timestamp_CHAT    recent=0    seen=0  delivered=0		deleted=1
        Run Keyword and Continue on Failure     ValidateCassandra_messages_by_root_folder_timestamp     recent=0    seen=0     modification_tuid=${modification_tuid}      delivered=0		deleted=1
    Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping        uid=${CREATION_TUID}        foldername=${CHAT_PARENT_FOLDER_PATH}/${SUBSCRIBER_ID}/

    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "FAIL"   FAIL    PNS notification verification failed \n ${value}





	
Redelete_PM_Msg
    [Tags]                 Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	${response}=    DeleteMsgObject	response_code=204




FolderSearchAfterDeletingtheMsg
    [Tags]                 Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    ${response_code}=   Set Variable If     ${EnableDeltraSync} == True     200     204
    ${response}=    FolderSearch    response_code=${response_code}   headers=${OEM_FOLDER_SEARCH_HEADER}
    Run Keyword If      ${EnableDeltraSync} == True     Run Keyword and Continue on Failure     ValidateChatFolderSearchResponse    response=${response}    msgStatus=Deleted   direction=${DIRECTION}		uid=${UID}      FROM_MSISDN=${TO_MSISDN}



