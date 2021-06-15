*** Settings ***
#Comment
Resource        ../../resources/mStore_Digits_TMO_resources.robot
Resource		../../resources/Provision.robot
Metadata    	Version        MSTR-P.4.2.14.3
Suite Setup     prepare_suitebed
Suite Teardown  custom_suite_teardown
Test Timeout	2m
Documentation	"Digits LM OEM MT Flow"
#Variables   ${VFILE}

*** Variables ***
${SUBSCRIBER_ID}=	${TO_MSISDN}
${COSID}=			${DIGITS_COS}
${MSG_TYPE}=		MT
${DIRECTION}=		In
${push_recepient_uri}=  ${MSG_TO}
${ASSERTED_SERVICE}=    ${P_ASSERTED_SERVICE_LM}
#${X_IMDN_CORRELATOR}=   ${SUBSCRIBER_ID}_${IMDN_MESSAGE_ID}
#${X_IMDN_CORRELATOR}=	${SUBSCRIBER_ID}_${CONVERSATION_ID}_${IMDN_MESSAGE_ID}
${MESSAGE_CONTEXT}=		${LM_MESSAGE_CONTEXT}
${PNS_TYPE}=            ${LM_PNS_TYPE}
${PNS_SUBTYPE}=         ${LM_PNS_SUBTYPE}
${trl_timer}=           10
${PNS_TRL_DIRECTION_VALUE}=     1

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
#TRL,TMM,Corecheck,cass TTL
#
DeleteSubscriberAlreadyExists
	[Documentation]		"Delete Subscriber If already Exists"
	[Tags]               Provision
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    ${status}    ${delete_response}=		Run Keyword and Ignore Error     DeleteSubscriber_SOAP   ${SUBSCRIBER_ID}
    #Run Keyword and Continue on Failure     ValidateDeleteSubscriberResponse    ${delete_response}
    #Run Keyword and Continue on Failure     ValidateSoapResponseHeaders     response=${delete_response}
    #Run Keyword and Continue on Failure     ValidateSubscriberCassandraUsersTableAfterDelete

AddSubscriber_ValidateResponse
	[Documentation]		"Add new Subscriber and Validate response and cassandra users userfolderkeymap table"
	[Tags]				Provision
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    ${add_response}=    Run Keyword and Continue on Failure     AddSubscrber_SOAP
    Run Keyword and Continue on Failure     ValidateAddSubscriberResponse   response=${add_response}
    Run Keyword and Continue on Failure     ValidateSoapResponseHeaders     response=${add_response}
    ${listOfFolders}=   Run Keyword and Continue on Failure     GetNumberFolderPathfromClassofService
    ${UsersData}=   Run Keyword and Continue on Failure     ValidateSubscriberCassandraUsersTable   imappwd=${IMAP_PWD}  pinpwd=${PIN_PWD}  nut=0  pin_encrypted=0  vvmon=0
    Set Suite Variable      ${listOfFolders}
    Set Suite Variable      ${UsersData}
    Set Suite Variable      ${USERID}   ${UsersData['uuid']}
    Run Keyword and Continue on Failure     CassandraFolderValidation   folders=${listOfFolders}
    Run Keyword and Continue on Failure        ValidateSubscriberCassandraFoldersmapTable      folders=${listOfFolders}     userId=${USERID}


Deposit_LM_Message
	[Documentation]		"Deposit LM message"
	[Tags]				LM_OEM_MO	Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    ${response}=    Deposit_Message        DIRECTION_VALUE=${DIRECTION}    headers=${OEM_DEPOSIT_HEADERS}	 object_file=${LM_FT_DEPOSIT_OBJ_FILE}
    Set Suite Variable  ${COMPLETE_OBJ_FILE_SIZE}   ${payload_length}
	${resource_url}=   Set Variable    ${response.json()['objectReference']['resourceURL']}
	${resource_url}=	Fetch From Right	${resource_url}		/
	${resource_url}=	Split String	${resource_url}		%3a
	log		${resource_url} 
	${request}=		GetServicerequest	${PNS_SOCKET_SERVICE}
	Set Test Variable   ${request}
	${headers}		${req_body}		${version}=		GetRequestData	${request}
	Set Suite Variable		${RCS_PARENT_FOLDER_KEY}		${Generic_Cos_Path_Ids['${RCS_PARENT_PATH}']}
	Set Suite Variable      ${RCS_MESSAGE_FOLDER_KEY}	${resource_url[0]}
    Set Suite Variable  ${CREATION_TUID}    ${resource_url[-1]}
    ${CREATION_TUIDS}=  Create Dictionary
    Set To Dictionary   ${CREATION_TUIDS}   1    ${CREATION_TUID}
    Set Suite Variable  ${CREATION_TUIDS}

	${pns_status}	${value}=		Run Keyword and Ignore Error		ValidateFTPNSNotfn	pns_headers=${headers}	pns_body=${req_body}	direction=${DIRECTION}	msgStatus=Recent	push_recipients_uri=${push_recepient_uri}	pns_subtype=LMM	
	Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "PASS"   SendResponse    ${request}  200     OK  ${version}  ELSE    SendResponse    ${request}  400     BadRequest   ${version}
    ${creation_tuid}    ${modification_tuid}=   Run Keyword and Continue on Failure     ValidateCassandra_messages_by_original_folder_timestamp_LargeMessages   recent=1    seen=0
    Run Keyword and Continue on Failure     ValidateCassandra_messages_by_root_folder_timestamp     recent=1    seen=0
    Run Keyword and Continue on Failure     ValidateCassandra_flag_changes_by_root_folder_timestamp     seen=0
    Run Keyword and Continue on Failure     ValidateCassandra_flag_changes_by_original_folder_timestamp     seen=0
    Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping    uid=${CREATION_TUID}
    Run Keyword and Continue on Failure     ValidateCassandraMessageActivity

#    Run Keyword and Continue on Failure     ValidateCassandraMessagesTable  recent=1    seen=0
#	Run Keyword and Continue on Failure		ValidateCassandraIMDNMapping
	Run Keyword and Continue on Failure 	Run Keyword If      "${pns_status}" == "FAIL"   FAIL	PNS notification verification failed \n ${value}



FolderSearchAfterDeposit
	[Documentation]		"Folder search after depositing the message"
	[Tags]              LM_OEM_MO   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	${response}=	FolderSearch		folderkey=${RCS_PARENT_FOLDER_KEY}		headers=${OEM_FOLDER_SEARCH_HEADER}
	Run Keyword and Continue on Failure		ValidateFTFolderSearchResponse	direction=${DIRECTION}	response=${response}	msgStatus=recent



Deliver_LM_Message
	[Documentation]		"Deliver LM message"
	[Tags]              LM_OEM_MO   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    Deposit_Message		X_RCS_MSG_STATUS=Delivered	object_file=${DELIVER_DISPLAY_OBJ_FILE}		MESSAGE_CONTEXT=X-RCS-IMDN	 DIRECTION_VALUE=In		headers=${OEM_DEPOSIT_HEADERS}
    ${request}=     GetServicerequest  ${PNS_SOCKET_SERVICE}
	Set Test Variable   ${request}
    ${headers}      ${req_body}     ${version}=     GetRequestData  ${request}
    ${pns_status}   ${value}=     Run Keyword and Ignore Error	ValidateFTPNSNotfn        pns_headers=${headers}  pns_body=${req_body}	msgStatus=RECENT,DELIVERED		direction=${DIRECTION}	push_recipients_uri=${push_recepient_uri}	pns_subtype=LMMS	
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "PASS"   SendResponse    ${request}  200     OK  ${version}  ELSE    SendResponse    ${request}  400     BadRequest   ${version}
    ${creation_tuid}    ${modification_tuid}=   Run Keyword and Continue on Failure     ValidateCassandra_messages_by_original_folder_timestamp_LargeMessages   recent=1    seen=0  delivered=1   
    Run Keyword and Continue on Failure     ValidateCassandra_messages_by_root_folder_timestamp     recent=1    seen=0      modification_tuid=${modification_tuid}      delivered=1
    Run Keyword and Continue on Failure     ValidateCassandra_flag_changes_by_root_folder_timestamp     seen=0      modification_tuid=${modification_tuid}  delivered=1
    Run Keyword and Continue on Failure     ValidateCassandra_flag_changes_by_original_folder_timestamp     seen=0  modification_tuid=${modification_tuid}  delivered=1
    Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping    uid=${CREATION_TUID}
    Run Keyword and Continue on Failure     ValidateCassandraMessageActivity	cnt=1

#	Run Keyword and Continue on Failure        ValidateCassandraMessagesTable	delivered=1		recent=1	seen=0	
#    Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "FAIL"   FAIL	PNS notification verification failed \n ${value}





FolderSearchAfterIMDNDelivered
    [Documentation]		"Folder search after seeing the message"
	[Tags]              LM_OEM_MO   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    ${response}=    FolderSearch	headers=${OEM_FOLDER_SEARCH_HEADER}
    Run Keyword and Continue on Failure     ValidateFTFolderSearchResponse    direction=${DIRECTION}    response=${response}    msgStatus=recent,delivered




Display_LM_Message
	[Documentation]		"Display LM message"
	[Tags]              LM_OEM_MO   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    Deposit_Message			X_RCS_MSG_STATUS=Displayed	object_file=${DELIVER_DISPLAY_OBJ_FILE}		MESSAGE_CONTEXT=X-RCS-IMDN	DIRECTION_VALUE=In		headers=${OEM_DEPOSIT_HEADERS}
    ${request}=     GetServicerequest  ${PNS_SOCKET_SERVICE}
	Set Test Variable   ${request}
    ${headers}      ${req_body}     ${version}=     GetRequestData  ${request}
    ${pns_status}   ${value}=     Run Keyword and Ignore Error	ValidateFTPNSNotfn        pns_headers=${headers}  pns_body=${req_body}	msgStatus=SEEN,DELIVERED		direction=${DIRECTION}	push_recipients_uri=${push_recepient_uri}	pns_subtype=LMMS	
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "PASS"   SendResponse    ${request}  200     OK  ${version}  ELSE    SendResponse    ${request}  400     BadRequest   ${version}
    ${creation_tuid}    ${modification_tuid}=   Run Keyword and Continue on Failure     ValidateCassandra_messages_by_original_folder_timestamp_LargeMessages   recent=0    seen=1  delivered=1
    Run Keyword and Continue on Failure     ValidateCassandra_messages_by_root_folder_timestamp     recent=0    seen=1      modification_tuid=${modification_tuid}      delivered=1
    Run Keyword and Continue on Failure     ValidateCassandra_flag_changes_by_root_folder_timestamp     seen=1      modification_tuid=${modification_tuid}  delivered=1
    Run Keyword and Continue on Failure     ValidateCassandra_flag_changes_by_original_folder_timestamp     seen=1  modification_tuid=${modification_tuid}  delivered=1
    Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping    uid=${CREATION_TUID}
    Run Keyword and Continue on Failure     ValidateCassandraMessageActivity	cnt=2
    #Run Keyword and Continue on Failure        ValidateCassandraMessagesTable       delivered=1		seen=1	recent=0		
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "FAIL"   FAIL	PNS notification verification failed \n ${value}



FolderSearchAfterIMDNArchival
	Log to Console	"Folder search after seeing the message"
	[Tags]              LM_OEM_MO   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	${response}=    FolderSearch	headers=${OEM_FOLDER_SEARCH_HEADER}
    Run Keyword and Continue on Failure     ValidateFTFolderSearchResponse    direction=${DIRECTION}	response=${response}	msgStatus=seen,delivered



Fetch_LM_Message
	[Tags]              LM_OEM_MO   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	${response}=	FetchMessageObject	ResourceURI=${OBJECT_URL}	headers=${OEM_FETCH_HEADERS}
	ValidateFTFetchResponse	response=${response}	msgStatus=seen,delivered		direction=${DIRECTION}		msg_context=${LM_MESSAGE_CONTEXT}	imdn_type=deposit



Get_LM_FullPayload
    [Tags]              LM_OEM_MO   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown

    ${response}=    Get Request    alias=${MSTORE_SESSION_NAME}    uri=${FT_PAYLOADURL}
    log    ${response.status_code}    #console=True
    log    ${response.text}    #console=True
    log    ${response.headers}    #console=True
    Should Be Equal As Strings      ${response.status_code}     200



Update_Msg_from_Seen_to_Recent
	[Tags]              LM_OEM_MO   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	UpdateFlagToMessage		flag=Recent		headers=${OEM_FETCH_HEADERS}
    ${request}=     GetServicerequest  ${PNS_SOCKET_SERVICE}
	Set Test Variable   ${request}
    ${headers}      ${req_body}     ${version}=     GetRequestData  ${request}
    ${pns_status}   ${value}=     Run Keyword and Ignore Error	ValidateFTPNSNotfn     pns_headers=${headers}  pns_body=${req_body}	direction=${DIRECTION}     msgStatus=RECENT,Delivered		push_recipients_uri=${push_recepient_uri}		pns_subtype=LMMS
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "PASS"   SendResponse    ${request}  200     OK  ${version}  ELSE    SendResponse    ${request}  400     BadRequest   ${version}
    ${creation_tuid}    ${modification_tuid}=   Run Keyword and Continue on Failure     ValidateCassandra_messages_by_original_folder_timestamp_LargeMessages   recent=1    seen=0  delivered=1
    Run Keyword and Continue on Failure     ValidateCassandra_messages_by_root_folder_timestamp     recent=1    seen=0      modification_tuid=${modification_tuid}      delivered=1
    Run Keyword and Continue on Failure     ValidateCassandra_flag_changes_by_root_folder_timestamp     seen=0      modification_tuid=${modification_tuid}  delivered=1
    Run Keyword and Continue on Failure     ValidateCassandra_flag_changes_by_original_folder_timestamp     seen=0  modification_tuid=${modification_tuid}  delivered=1
    Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping    uid=${CREATION_TUID}
    Run Keyword and Continue on Failure     ValidateCassandraMessageActivity	cnt=2

    #Run Keyword and Continue on Failure     ValidateCassandraMessagesTable	recent=1	delivered=1	
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "FAIL"   FAIL	PNS notification verification failed \n ${value}



FolderSearchAfterUpdatingtheFlagtoRecent
	Log to Console  "Folder search after depositing the message"
	[Tags]              LM_OEM_MO   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    ${response}=    FolderSearch	headers=${OEM_FOLDER_SEARCH_HEADER}
    Run Keyword and Continue on Failure     ValidateFTFolderSearchResponse    response=${response}		msgStatus=recent,delivered	direction=${DIRECTION}



Update_Msg_from_Recent_to_Seen
	[Tags]              LM_OEM_MO   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	UpdateFlagToMessage    flag=Seen	headers=${OEM_FETCH_HEADERS}
    ${request}=     GetServicerequest  ${PNS_SOCKET_SERVICE}
	Set Test Variable   ${request}
    ${headers}      ${req_body}     ${version}=     GetRequestData  ${request}
	${pns_status}   ${value}=     Run Keyword and Ignore Error	ValidateFTPNSNotfn    pns_headers=${headers}  pns_body=${req_body}    msgStatus=SEEN,Delivered	direction=${DIRECTION}	push_recipients_uri=${push_recepient_uri}	pns_subtype=LMMS
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "PASS"   SendResponse    ${request}  200     OK  ${version}  ELSE    SendResponse    ${request}  400     BadRequest   ${version}
    ${creation_tuid}    ${modification_tuid}=   Run Keyword and Continue on Failure     ValidateCassandra_messages_by_original_folder_timestamp_LargeMessages   recent=0    seen=1  delivered=1
    Run Keyword and Continue on Failure     ValidateCassandra_messages_by_root_folder_timestamp     recent=0    seen=1      modification_tuid=${modification_tuid}      delivered=1
    Run Keyword and Continue on Failure     ValidateCassandra_flag_changes_by_root_folder_timestamp     seen=1      modification_tuid=${modification_tuid}  delivered=1
    Run Keyword and Continue on Failure     ValidateCassandra_flag_changes_by_original_folder_timestamp     seen=1  modification_tuid=${modification_tuid}  delivered=1
    Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping    uid=${CREATION_TUID}
    Run Keyword and Continue on Failure     ValidateCassandraMessageActivity	cnt=2
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "FAIL"   FAIL	PNS notification verification failed \n ${value}




FolderSearchAfterUpdatingtheFlagtoSeen
	Log to Console  "Folder search after seeing the message"
	[Tags]              LM_OEM_MO   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	${response}=    FolderSearch	headers=${OEM_FOLDER_SEARCH_HEADER}
	Run Keyword and Continue on Failure     ValidateFTFolderSearchResponse    response=${response}    direction=${DIRECTION}	msgStatus=seen,delivered



Delete_LM_Msg
	[Tags]              LM_OEM_MO   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	${response}=	DeleteMsgObject	response_code=204	headers=${OEM_FETCH_HEADERS}
	Sleep   1
	${request}=     GetServicerequest  ${PNS_SOCKET_SERVICE}
	Set Test Variable   ${request}
    ${headers}      ${req_body}     ${version}=     GetRequestData  ${request}
	${pns_status}   ${value}=     Run Keyword and Ignore Error	ValidateFTDeletePNSNotfn     pns_headers=${headers}  pns_body=${req_body}		msgStatus=DELETED		direction=${DIRECTION}	pns_subtype=LMMD	push_recipients_uri=${push_recepient_uri} 
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "PASS"   SendResponse    ${request}  200     OK  ${version}  ELSE    SendResponse    ${request}  400     BadRequest   ${version}
	#Run Keyword If	${EnableDeltraSync} == True		Run Keyword and Continue on Failure		ValidateCassandraMessagesAfterDelete	messages=0	messages_by_folder_timestamp=1
    #Run Keyword If  ${EnableDeltraSync} == False     Run Keyword and Continue on Failure     ValidateCassandraMessagesAfterDelete    messages=0  messages_by_folder_timestamp=0
    ${creation_tuid}    ${modification_tuid}=   Run Keyword and Continue on Failure     ValidateCassandra_messages_by_original_folder_timestamp_LargeMessages   recent=0    seen=0  delivered=0		deleted=1
    Run Keyword and Continue on Failure     ValidateCassandra_messages_by_root_folder_timestamp     recent=0    seen=0      modification_tuid=${modification_tuid}      delivered=0		deleted=1
    Run Keyword and Continue on Failure     ValidateCassandra_flag_changes_by_root_folder_timestamp     seen=0      modification_tuid=${modification_tuid}  delivered=0		deleted=1
    Run Keyword and Continue on Failure     ValidateCassandra_flag_changes_by_original_folder_timestamp     seen=0  modification_tuid=${modification_tuid}  delivered=0		deleted=1
    Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping    uid=${CREATION_TUID}
    Run Keyword and Continue on Failure     ValidateCassandraMessageActivity	cnt=2
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "FAIL"   FAIL	PNS notification verification failed \n ${value}



Redelete_LM_Msg
	[Tags]              LM_OEM_MO   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	${response}=    DeleteMsgObject	response_code=204	headers=${OEM_FETCH_HEADERS}



FolderSearchAfterDeletingtheMsg
	[Tags]              LM_OEM_MO   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	${response_code}=	Set Variable If		${EnableDeltraSync} == True		200		204
	${response}=    FolderSearch	response_code=${response_code}   headers=${OEM_FOLDER_SEARCH_HEADER}
	Run Keyword If		${EnableDeltraSync} == True		Run Keyword and Continue on Failure     ValidateFTFolderSearchResponse    response=${response}    msgStatus=Deleted	direction=${DIRECTION}



DeleteSubscriber
    [Documentation]     "Delete Subscriber If already Exists"
    [Tags]               Provision
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    ${status}    ${delete_response}=        Run Keyword and Ignore Error     DeleteSubscriber_SOAP   ${SUBSCRIBER_ID}
    Run Keyword and Continue on Failure     ValidateDeleteSubscriberResponse    ${delete_response}
    Run Keyword and Continue on Failure     ValidateSoapResponseHeaders     response=${delete_response}
    Run Keyword and Continue on Failure     ValidateSubscriberCassandraUsersTableAfterDeletingSubscriber

