*** Settings ***
#Comment
Resource        ../../resources/mStore_Generic_resources.robot
Resource		../../resources/Provision.robot
Resource        ../../resources/mStore_Digits_TMO_resources.robot
Metadata    	Version        MSTR-P.4.2.14.3
Suite Setup     prepare_suitebed
Suite Teardown  custom_suite_teardown
Test Timeout	2m
Documentation	"Digits PM OEM MO Flow"

*** Variables ***
${SUBSCRIBER_ID}=	${FROM_MSISDN}
${COSID}=			${DIGITS_COS}
${MSG_TYPE}=		MO
${DIRECTION}=		Out
${ASSERTED_SERVICE}=    ${P_ASSERTED_SERVICE_PM}
${X_IMDN_CORRELATOR}=	${SUBSCRIBER_ID}_${CONVERSATION_ID}_${IMDN_MESSAGE_ID}
${MESSAGE_CONTEXT}=     ${PM_MESSAGE_CONTEXT}
${PNS_TYPE}=			${PM_PNS_TYPE}
${PNS_SUBTYPE}=			${PM_PNS_SUBTYPE}
${trl_timer}=			10
${PNS_TRL_DIRECTION_VALUE}=		2

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
	${status}=		Run Keyword and Ignore Error	Variable Should Exist	${request}
	Run Keyword If	'${status[0]}' == 'PASS'	CloseRequest    ${request}

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
    [Arguments]     ${folders}
    Run Keyword and Continue on Failure    ValidateUserFolderKeymapTable    folders=${folders}
    Run Keyword and Continue on Failure    ValidateFolderTable              folders=${folders}

*** TestCases ***
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
	[Documentation]		"Add new Subscriber and Validate response and cassandra users userfolderkeymap table"
	[Tags]				Provision
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    ${add_response}=    Run Keyword and Continue on Failure     AddSubscrber_SOAP
    Run Keyword and Continue on Failure     ValidateAddSubscriberResponse   response=${add_response}
    Run Keyword and Continue on Failure     ValidateSoapResponseHeaders     response=${add_response}
    ${listOfFolders}=   Run Keyword and Continue on Failure     GetNumberFolderPathfromClassofService
    Run Keyword and Continue on Failure     ValidateSubscriberCassandraUsersTable   imappwd=${EMPTY}  pinpwd=${EMPTY}  nut=0  pin_encrypted=0  vvmon=0
    #Run Keyword and Continue on Failure     CassandraFolderValidation   folders=${listOfFolders}

Deposit_PM_Message
	[Documentation]		"Deposit PM message"
	[Tags]				Critical	
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    ${response}=    Deposit_Message        DIRECTION_VALUE=${DIRECTION}    headers=${OEM_DEPOSIT_HEADERS}
	${resource_url}=   Set Variable    ${response.json()['objectReference']['resourceURL']}
	${resource_url}=	Fetch From Right	${resource_url}		/
	${resource_url}=	Split String	${resource_url}		%3a
	log		${resource_url} 
	Set Suite Variable		${RCS_PARENT_FOLDER_KEY}		${Generic_Cos_Path_Ids['${RCS_PARENT_PATH}']}
    ${r_url}=   Replace String  ${resource_url[0]}      %3d     =
    Set Suite Variable      ${RCS_MESSAGE_FOLDER_KEY}   ${r_url}
    log     ${r_url}
    log     ${RCS_MESSAGE_FOLDER_KEY}
    Set Suite Variable  ${CREATION_TUID}    ${resource_url[-1]}
    ${r_url1}=   Replace String  ${resource_url[0]}      %3d     ${EMPTY}
    Set Suite Variable      ${msgFolderkey1}   ${r_url1}
    #Set Suite Variable      ${RCS_MESSAGE_FOLDER_KEY}	${resource_url[0]}
    ${uid}=     Set Variable    ${resource_url[1]}
    Set Suite Variable      ${UID}      ${uid}
    ${request}=     GetServicerequest   ${PNS_SOCKET_SERVICE}
    Set Test Variable   ${request}
    ${headers}      ${req_body}     ${version}=     GetRequestData  ${request}
    ${pns_status}	${value}=		Run Keyword and Ignore Error		ValidateChatPNSNotfn	pns_headers=${headers}	pns_body=${req_body}	direction=${DIRECTION}	msgStatus=SEEN	push_recipients_uri=${MSG_FROM}			uid=${UID}			pns_subtype=ChatO		folder_path=${CHAT_PARENT_FOLDER_PATH}/${SUBSCRIBER_ID}/	
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "PASS"   SendResponse    ${request}  200     OK  ${version}  ELSE    SendResponse    ${request}  400     BadRequest   ${version}
    Run Keyword and Continue on Failure 	Run Keyword If      "${pns_status}" == "FAIL"   FAIL	PNS notification verification failed \n ${value}
    Run Keyword and Continue on Failure     ValidateCassandraMessagesTable_C44  userId=${USERID}    recent=0    seen=1     uid=${UID} 
	Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping		uid=${CREATION_TUID}		foldername=${CHAT_PARENT_FOLDER_PATH}/${SUBSCRIBER_ID}/
	#Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping        uid=${CREATION_TUID} 



FolderSearchAfterDeposit
	[Documentation]		"Folder search after depositing the message"
	[Tags]              Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	${response}=	FolderSearch		folderkey=${RCS_PARENT_FOLDER_KEY}		headers=${OEM_FOLDER_SEARCH_HEADER}
	Run Keyword and Continue on Failure		ValidateChatFolderSearchResponse	direction=${DIRECTION}	response=${response}	msgStatus=seen 		uid=${UID}





Deliver_PM_Message
	[Documentation]		"Deliver PM message"
	[Tags]                 Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    Deposit_Message		X_RCS_MSG_STATUS=Delivered	object_file=${DELIVER_DISPLAY_OBJ_FILE}		MESSAGE_CONTEXT=X-RCS-IMDN	 DIRECTION_VALUE=In		headers=${OEM_DEPOSIT_HEADERS}
    ${request}=     GetServicerequest  ${PNS_SOCKET_SERVICE}
	Set Test Variable   ${request}
    ${headers}      ${req_body}     ${version}=     GetRequestData  ${request}
    ${pns_status}   ${value}=       Run Keyword and Ignore Error        ValidateChatPNSNotfn    pns_headers=${headers}  pns_body=${req_body}    direction=${DIRECTION}  msgStatus=SEEN,DELIVERED  push_recipients_uri=${MSG_FROM}         uid=${UID}          pns_subtype=ChatS

	Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "PASS"   SendResponse    ${request}  200     OK  ${version}  ELSE    SendResponse    ${request}  400     BadRequest   ${version}
    Run Keyword and Continue on Failure     ValidateCassandraMessagesTable_C44	 userId=${USERID}    recent=0    seen=1      uid=${UID} 		delivered=1
    Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping		uid=${CREATION_TUID}     foldername=${CHAT_PARENT_FOLDER_PATH}/${SUBSCRIBER_ID}/
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "FAIL"   FAIL    PNS notification verification failed \n ${value}


FolderSearchAfterIMDNDelivered
    [Documentation]		"Folder search after seeing the message"
	[Tags]                 Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    ${response}=    FolderSearch	headers=${OEM_FOLDER_SEARCH_HEADER}
    Run Keyword and Continue on Failure     ValidateChatFolderSearchResponse    direction=${DIRECTION} 	    response=${response} 	  	uid=${UID}	  msgStatus=seen	imdn_type=delivered




Display_PM_Message
	[Documentation]		"Display PM message"
	[Tags]                 Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    Deposit_Message			X_RCS_MSG_STATUS=Displayed	object_file=${DELIVER_DISPLAY_OBJ_FILE}		MESSAGE_CONTEXT=X-RCS-IMDN	DIRECTION_VALUE=In		headers=${OEM_DEPOSIT_HEADERS}
    ${request}=     GetServicerequest  ${PNS_SOCKET_SERVICE}
	Set Test Variable   ${request}
    ${headers}      ${req_body}     ${version}=     GetRequestData  ${request}
   	${pns_status}   ${value}=       Run Keyword and Ignore Error        ValidateChatPNSNotfn    pns_headers=${headers}  pns_body=${req_body}    direction=${DIRECTION}  msgStatus=SEEN,DELIVERED   push_recipients_uri=${MSG_FROM}         uid=${UID}          pns_subtype=ChatS

	 Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "PASS"   SendResponse    ${request}  200     OK  ${version}  ELSE    SendResponse    ${request}  400     BadRequest   ${version}
  ${creation_tuid}    ${modification_tuid}=   Run Keyword and Continue on Failure     ValidateCassandra_messages_by_original_folder_timestamp_CHAT    recent=0    seen=1  delivered=1       deliveredimdnlist=${MSG_TO}     readimdnlist=${MSG_TO}
    Run Keyword and Continue on Failure     ValidateCassandra_messages_by_root_folder_timestamp     recent=0    seen=1      modification_tuid=${modification_tuid}      delivered=1
    Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping        uid=${CREATION_TUID}        foldername=${CHAT_PARENT_FOLDER_PATH}/${SUBSCRIBER_ID}/
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "FAIL"   FAIL    PNS notification verification failed \n ${value}




FolderSearchAfterIMDNArchival
	Log to Console	"Folder search after seeing the message"
	[Tags]                 Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	${response}=    FolderSearch	headers=${OEM_FOLDER_SEARCH_HEADER}
    Run Keyword and Continue on Failure     ValidateChatFolderSearchResponse    direction=${DIRECTION}			response=${response}	msgStatus=seen		uid=${UID}	 imdn_type=displayed



Fetch_PM_Message
	[Tags]                 Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	${response}=	FetchMessageObject	ResourceURI=${OBJECT_URL}	headers=${OEM_FETCH_HEADERS}
	ValidateChatFetchResponse	response=${response}	msgStatus=seen		direction=${DIRECTION}		msg_context=${PM_MESSAGE_CONTEXT}		uid=${UID}





Update_Msg_from_Seen_to_Recent
	[Tags]                 Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	UpdateFlagToMessage		flag=Recent		headers=${OEM_FETCH_HEADERS}
    ${request}=     GetServicerequest  ${PNS_SOCKET_SERVICE}
	Set Test Variable   ${request}
    ${headers}      ${req_body}     ${version}=     GetRequestData  ${request}
    ${pns_status}   ${value}=     Run Keyword and Ignore Error	ValidateChatPNSNotfn     pns_headers=${headers}  pns_body=${req_body}	direction=${DIRECTION}     msgStatus=RECENT,DELIVERED		push_recipients_uri=${MSG_FROM}		folder_path=${CHAT_PARENT_FOLDER_PATH}/${SUBSCRIBER_ID}/			pns_subtype=ChatS		 uid=${UID}
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "PASS"   SendResponse    ${request}  200     OK  ${version}  ELSE    SendResponse    ${request}  400     BadRequest   ${version}
#    Run Keyword and Continue on Failure     ValidateCassandraMessagesTable_C44	recent=1	delivered=1		delivered_imdn_list=${MSG_TO}   read_imdn_list=${MSG_TO}		uid=${UID}
  ${creation_tuid}    ${modification_tuid}=   Run Keyword and Continue on Failure     ValidateCassandra_messages_by_original_folder_timestamp_CHAT    recent=1    seen=0  delivered=1		deliveredimdnlist=${MSG_TO}		readimdnlist=${MSG_TO}
    Run Keyword and Continue on Failure     ValidateCassandra_messages_by_root_folder_timestamp     recent=1    seen=0      modification_tuid=${modification_tuid}      delivered=1

    Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping		uid=${CREATION_TUID}		foldername=${CHAT_PARENT_FOLDER_PATH}/${SUBSCRIBER_ID}/
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "FAIL"   FAIL    PNS notification verification failed \n ${value}



FolderSearchAfterUpdatingtheFlagtoRecent
	Log to Console  "Folder search after depositing the message"
	[Tags]                 Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    ${response}=    FolderSearch	headers=${OEM_FOLDER_SEARCH_HEADER}
    Run Keyword and Continue on Failure     ValidateChatFolderSearchResponse    response=${response}		msgStatus=recent	direction=${DIRECTION}		uid=${UID}		 imdn_type=displayed







Update_Msg_from_Recent_to_Seen
	[Tags]                 Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	UpdateFlagToMessage    flag=Seen	headers=${OEM_FETCH_HEADERS}
    ${request}=     GetServicerequest  ${PNS_SOCKET_SERVICE}
	Set Test Variable   ${request}
    ${headers}      ${req_body}     ${version}=     GetRequestData  ${request}
	${pns_status}   ${value}=     Run Keyword and Ignore Error	ValidateChatPNSNotfn    pns_headers=${headers}  pns_body=${req_body}    msgStatus=SEEN,DELIVERED		direction=${DIRECTION}	push_recipients_uri=${MSG_FROM}		folder_path=${CHAT_PARENT_FOLDER_PATH}/${SUBSCRIBER_ID}/		pns_subtype=ChatS		uid=${UID}
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "PASS"   SendResponse    ${request}  200     OK  ${version}  ELSE    SendResponse    ${request}  400     BadRequest   ${version}
	${creation_tuid}    ${modification_tuid}=   Run Keyword and Continue on Failure     ValidateCassandra_messages_by_original_folder_timestamp_CHAT    recent=0    seen=1  delivered=1       deliveredimdnlist=${MSG_TO}     readimdnlist=${MSG_TO}
    Run Keyword and Continue on Failure     ValidateCassandra_messages_by_root_folder_timestamp     recent=0    seen=1     modification_tuid=${modification_tuid}      delivered=1

     Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping		uid=${CREATION_TUID}		foldername=${CHAT_PARENT_FOLDER_PATH}/${SUBSCRIBER_ID}/
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "FAIL"   FAIL    PNS notification verification failed \n ${value}

   




FolderSearchAfterUpdatingtheFlagtoSeen
	Log to Console  "Folder search after seeing the message"
	[Tags]                 Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	${response}=    FolderSearch	headers=${OEM_FOLDER_SEARCH_HEADER}
	Run Keyword and Continue on Failure     ValidateChatFolderSearchResponse    response=${response}    direction=${DIRECTION}		uid=${UID}		msgStatus=seen	 imdn_type=displayed


Delete_PM_Msg
	[Tags]                 Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	${response}=	DeleteMsgObject	response_code=204	headers=${OEM_FETCH_HEADERS}
	Sleep   1
	${request}=     GetServicerequest  ${PNS_SOCKET_SERVICE}
	Set Test Variable   ${request}
    ${headers}      ${req_body}     ${version}=     GetRequestData  ${request}
	${pns_status}   ${value}=     Run Keyword and Ignore Error	ValidateChatDeletePNSNotfn     pns_headers=${headers}  pns_body=${req_body}		msgStatus=DELETED		direction=${DIRECTION}	pns_subtype=ChatD	push_recipients_uri=${MSG_FROM}		uid=${UID}			store=${CHAT_PARENT_FOLDER_PATH}/${FROM_MSISDN}/ 
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "PASS"   SendResponse    ${request}  200     OK  ${version}  ELSE    SendResponse    ${request}  400     BadRequest   ${version}
	#Run Keyword If	${EnableDeltraSync} == True		Run Keyword and Continue on Failure		ValidateCassandraMessagesAfterDelete	messages=0	messages_by_folder_timestamp=1
    #Run Keyword If  ${EnableDeltraSync} == False     Run Keyword and Continue on Failure     ValidateCassandraMessagesAfterDelete    messages=0  messages_by_folder_timestamp=0

    ${creation_tuid}    ${modification_tuid}=   Run Keyword and Continue on Failure     ValidateCassandra_messages_by_original_folder_timestamp_CHAT    recent=0    seen=0  delivered=0     deleted=1		deliveredimdnlist=${MSG_TO}     readimdnlist=${MSG_TO}
    Run Keyword and Continue on Failure     ValidateCassandra_messages_by_root_folder_timestamp     recent=0    seen=0     modification_tuid=${modification_tuid}      delivered=0      deleted=1

	#Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping	cnt=0		uid=${CREATION_TUID}
    Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping        uid=${CREATION_TUID}        foldername=${CHAT_PARENT_FOLDER_PATH}/${SUBSCRIBER_ID}/
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "FAIL"   FAIL    PNS notification verification failed \n ${value}


	
Redelete_PM_Msg
	[Tags]                 Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	${response}=    DeleteMsgObject	response_code=204	headers=${OEM_FETCH_HEADERS}


FolderSearchAfterDeletingtheMsg
	[Tags]                 Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	${response_code}=	Set Variable If		${EnableDeltraSync} == True		200		204
	${response}=    FolderSearch	response_code=${response_code}   headers=${OEM_FOLDER_SEARCH_HEADER}
	Run Keyword If		${EnableDeltraSync} == True		Run Keyword and Continue on Failure     ValidateChatFolderSearchResponse    response=${response}   		uid=${UId}		 msgStatus=Deleted	direction=${DIRECTION}	 imdn_type=displayed


