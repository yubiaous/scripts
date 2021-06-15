*** Settings ***
#Comment
Resource        ../../resources/mStore_Digits_TMO_resources.robot
Resource		../../resources/Provision.robot
Metadata    	Version        MSTR-P.4.2.14.3
Suite Setup     prepare_suitebed
Suite Teardown  custom_suite_teardown
Test Timeout	2m
Documentation	"Digits LM OEM MO Flow"
#Variables	${VFILE}
*** Variables ***
${SUBSCRIBER_ID}=	${FROM_MSISDN}
${COSID}=			${DIGITS_COS}
${MSG_TYPE}=		MO
${DIRECTION}=		Out
${push_recepient_uri}=  ${MSG_FROM}
${ASSERTED_SERVICE}=    ${P_ASSERTED_SERVICE_LM}
#${X_IMDN_CORRELATOR}=   ${SUBSCRIBER_ID}_${IMDN_MESSAGE_ID}
${MESSAGE_CONTEXT}=		${LM_MESSAGE_CONTEXT}
${TRL_MSG_CONTEXT_ID}=	${TRL_MSG_CONTEXT_IDS['${MESSAGE_CONTEXT}']}
${PNS_TYPE}=            ${LM_PNS_TYPE}
${PNS_SUBTYPE}=         ${LM_PNS_SUBTYPE}
${trl_timer}=           10
${PNS_TRL_DIRECTION_VALUE}=     2
${PAYLOAD_CONTENT_SIZE}=	${LM_DATA_SIZE}
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
	#login_to_swift_server
	CreateSwiftSession
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
	${PNS_SOCKET_SERVICE}=		StartHttpServer		${PNS_SERVER}		${PNS_SERVICE_PORT}
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
	#Should Contain Any 	  ${delete_response.status_code}	200		404
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
    #Run Keyword and Continue on Failure        ValidateSubscriberCassandraDynamicFoldersmapTable    folders=${listOfFolders}    userId=${USERID}    table=dynamicfolder
    #Run Keyword and Continue on Failure        ValidateSubscriberCassandraDynamicFoldersmapTable    folders=${listOfFolders}    userId=${USERID}    table=dynamicfoldercreationmap
    Run Keyword and Continue on Failure     Peg_TMM_file_immediately
    Sleep   10



Deposit_LM_Message
	[Documentation]		"Deposit LM message"
	[Tags]				LM_OEM_MO	Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	log		${X_IMDN_CORRELATOR}		console=true
    ${response}=    Deposit_Message        DIRECTION_VALUE=${DIRECTION}    headers=${OEM_DEPOSIT_HEADERS}	 object_file=${LM_FT_DEPOSIT_OBJ_FILE}
    Set Suite Variable  ${COMPLETE_OBJ_FILE_SIZE}   ${payload_length}
	${resource_url}=   Set Variable    ${response.json()['objectReference']['resourceURL']}
	${resource_url}=	Fetch From Right	${resource_url}		/
	${resource_url}=	Split String	${resource_url}		%3a
	log		${resource_url} 
	${request}=	GetServicerequest		${PNS_SOCKET_SERVICE}
	Set Test Variable   ${request}
	${headers}		${req_body}		${version}=		GetRequestData	${request}
	Set Suite Variable		${RCS_PARENT_FOLDER_KEY}		${Generic_Cos_Path_Ids['${RCS_PARENT_PATH}']}
	#Set Suite Variable		${RCS_MESSAGE_FOLDER_KEY}	${Generic_Cos_Path_Ids['${CHAT_PARENT_FOLDER_PATH}']}
	Set Suite Variable      ${RCS_MESSAGE_FOLDER_KEY}	${resource_url[0]}
	Set Suite Variable  ${CREATION_TUID}    ${resource_url[-1]}
    ${CREATION_TUIDS}=  Create Dictionary
    Set To Dictionary   ${CREATION_TUIDS}   1    ${CREATION_TUID}
    Set Suite Variable  ${CREATION_TUIDS}

	${pns_status}	${value}=		Run Keyword and Ignore Error		ValidateFTPNSNotfn	pns_headers=${headers}	pns_body=${req_body}	direction=${DIRECTION}	msgStatus=SEEN	push_recipients_uri=${push_recepient_uri}   	pns_subtype=LMMO
	Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "PASS"   SendResponse    ${request}  200     OK  ${version}  ELSE    SendResponse    ${request}  400     BadRequest   ${version}
    #Run Keyword and Continue on Failure     ValidateCassandraMessagesTable  recent=0    seen=1
	#Run Keyword and Continue on Failure		ValidateCassandraIMDNMapping
    ${creation_tuid}    ${modification_tuid}=   Run Keyword and Continue on Failure     ValidateCassandra_messages_by_original_folder_timestamp_LargeMessages   recent=0    seen=1
    Run Keyword and Continue on Failure     ValidateCassandra_messages_by_root_folder_timestamp     recent=0    seen=1
    Run Keyword and Continue on Failure     ValidateCassandra_flag_changes_by_root_folder_timestamp     seen=1
    Run Keyword and Continue on Failure     ValidateCassandra_flag_changes_by_original_folder_timestamp     seen=1
    Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping	uid=${CREATION_TUID}
	Run Keyword and Continue on Failure		ValidateCassandraMessageActivity	
	${obj_response}=	GetObjectFromSwift		${SWIFT_OBJECT_URL}
	#Run Keyword and Continue on Failure		ValidateCassandraMessagesTableTTL	userId=${SUBSCRIBER_ID}		parent_folderkey=${RCS_PARENT_FOLDER_KEY}	msg_folderkey=${RCS_MESSAGE_FOLDER_KEY}
	Run Keyword and Continue on Failure 	Run Keyword If      "${pns_status}" == "FAIL"   FAIL	PNS notification verification failed \n ${value}



FolderSearchAfterDeposit
	[Documentation]		"Folder search after depositing the message"
	[Tags]              LM_OEM_MO   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	${response}=	FolderSearch		folderkey=${RCS_PARENT_FOLDER_KEY}		headers=${OEM_FOLDER_SEARCH_HEADER}
	Run Keyword and Continue on Failure		ValidateFTFolderSearchResponse	direction=${DIRECTION}	response=${response}	msgStatus=seen


Deliver_LM_Message
	[Documentation]		"Deliver LM message"
	[Tags]              LM_OEM_MO   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    Deposit_Message		X_RCS_MSG_STATUS=Delivered	object_file=${DELIVER_DISPLAY_OBJ_FILE}		MESSAGE_CONTEXT=X-RCS-IMDN	 DIRECTION_VALUE=In		headers=${OEM_DEPOSIT_HEADERS}
    ${request}=     GetServicerequest  ${PNS_SOCKET_SERVICE}
	Set Test Variable   ${request}
    ${headers}      ${req_body}     ${version}=     GetRequestData  ${request}
    ${pns_status}   ${value}=     Run Keyword and Ignore Error	ValidateFTPNSNotfn        pns_headers=${headers}  pns_body=${req_body}	msgStatus=DELIVERED		direction=${DIRECTION}	push_recipients_uri=${push_recepient_uri}	pns_subtype=LMMS		imdn_pns=delivered
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "PASS"   SendResponse    ${request}  200     OK  ${version}  ELSE    SendResponse    ${request}  400     BadRequest   ${version}
#	Run Keyword and Continue on Failure        ValidateCassandraMessagesTable	delivered=0		recent=0	seen=1		delivered_imdn_list=${MSG_TO}	
#    Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping
    ${creation_tuid}    ${modification_tuid}=   Run Keyword and Continue on Failure     ValidateCassandra_messages_by_original_folder_timestamp_LargeMessages   recent=0    seen=1	delivered=0		deliveredimdnlist=${MSG_TO}
    Run Keyword and Continue on Failure     ValidateCassandra_messages_by_root_folder_timestamp     recent=0    seen=1		modification_tuid=${modification_tuid}		delivered=0
    Run Keyword and Continue on Failure     ValidateCassandra_flag_changes_by_root_folder_timestamp     seen=1		modification_tuid=${modification_tuid}	delivered=0
    Run Keyword and Continue on Failure     ValidateCassandra_flag_changes_by_original_folder_timestamp     seen=1	modification_tuid=${modification_tuid}	delivered=0
    Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping    uid=${CREATION_TUID}
    Run Keyword and Continue on Failure     ValidateCassandraMessageActivity	cnt=1

    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "FAIL"   FAIL	PNS notification verification failed ${value}



FolderSearchAfterIMDNDelivered
    [Documentation]		"Folder search after seeing the message"
	[Tags]              LM_OEM_MO   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    ${response}=    FolderSearch	headers=${OEM_FOLDER_SEARCH_HEADER}
    Run Keyword and Continue on Failure     ValidateFTFolderSearchResponse    direction=${DIRECTION}    response=${response}    msgStatus=seen	 imdn_type=delivered



Display_LM_Message
	[Documentation]		"Display LM message"
	[Tags]              LM_OEM_MO   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    Deposit_Message			X_RCS_MSG_STATUS=Displayed	object_file=${DELIVER_DISPLAY_OBJ_FILE}		MESSAGE_CONTEXT=X-RCS-IMDN	DIRECTION_VALUE=In		headers=${OEM_DEPOSIT_HEADERS}
    ${request}=     GetServicerequest  ${PNS_SOCKET_SERVICE}
	Set Test Variable   ${request}
    ${headers}      ${req_body}     ${version}=     GetRequestData  ${request}
    ${pns_status}   ${value}=     Run Keyword and Ignore Error	ValidateFTPNSNotfn        pns_headers=${headers}  pns_body=${req_body}	msgStatus=SEEN		direction=${DIRECTION}	push_recipients_uri=${push_recepient_uri}	pns_subtype=LMMS		imdn_pns=displayed
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "PASS"   SendResponse    ${request}  200     OK  ${version}  ELSE    SendResponse    ${request}  400     BadRequest   ${version}
#    Run Keyword and Continue on Failure        ValidateCassandraMessagesTable       delivered=0		seen=1	recent=0	delivered_imdn_list=${MSG_TO}	read_imdn_list=${MSG_TO}	
    ${creation_tuid}    ${modification_tuid}=   Run Keyword and Continue on Failure     ValidateCassandra_messages_by_original_folder_timestamp_LargeMessages   recent=0    seen=1  delivered=0     deliveredimdnlist=${MSG_TO}		readimdnlist=${MSG_TO}
    Run Keyword and Continue on Failure     ValidateCassandra_messages_by_root_folder_timestamp     recent=0    seen=1      modification_tuid=${modification_tuid}      delivered=0
    Run Keyword and Continue on Failure     ValidateCassandra_flag_changes_by_root_folder_timestamp     seen=1      modification_tuid=${modification_tuid}  delivered=0
    Run Keyword and Continue on Failure     ValidateCassandra_flag_changes_by_original_folder_timestamp     seen=1  modification_tuid=${modification_tuid}  delivered=0
    Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping    uid=${CREATION_TUID}
    Run Keyword and Continue on Failure     ValidateCassandraMessageActivity	cnt=2
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "FAIL"   FAIL	PNS notification verification failed \n ${value}


FolderSearchAfterIMDNArchival
	Log to Console	"Folder search after seeing the message"
	[Tags]              LM_OEM_MO   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	${response}=    FolderSearch	headers=${OEM_FOLDER_SEARCH_HEADER}
    Run Keyword and Continue on Failure     ValidateFTFolderSearchResponse    direction=${DIRECTION}	response=${response}	msgStatus=seen	 imdn_type=displayed



Fetch_LM_Message
	[Tags]              LM_OEM_MO   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	${response}=	FetchMessageObject	ResourceURI=${OBJECT_URL}	headers=${OEM_FETCH_HEADERS}
	ValidateFTFetchResponse	response=${response}	msgStatus=seen		direction=${DIRECTION}		msg_context=${LM_MESSAGE_CONTEXT}



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
    ${pns_status}   ${value}=     Run Keyword and Ignore Error	ValidateFTPNSNotfn     pns_headers=${headers}  pns_body=${req_body}	direction=${DIRECTION}     msgStatus=RECENT	push_recipients_uri=${push_recepient_uri}	pns_subtype=LMMS		
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "PASS"   SendResponse    ${request}  200     OK  ${version}  ELSE    SendResponse    ${request}  400     BadRequest   ${version}
#    Run Keyword and Continue on Failure     ValidateCassandraMessagesTable	recent=1	delivered=0		delivered_imdn_list=${MSG_TO}   read_imdn_list=${MSG_TO}
    ${creation_tuid}    ${modification_tuid}=   Run Keyword and Continue on Failure     ValidateCassandra_messages_by_original_folder_timestamp_LargeMessages   recent=1    seen=0  delivered=0     deliveredimdnlist=${MSG_TO}		readimdnlist=${MSG_TO}
    Run Keyword and Continue on Failure     ValidateCassandra_messages_by_root_folder_timestamp     recent=1    seen=0      modification_tuid=${modification_tuid}      delivered=0
    Run Keyword and Continue on Failure     ValidateCassandra_flag_changes_by_root_folder_timestamp     seen=0      modification_tuid=${modification_tuid}  delivered=0
    Run Keyword and Continue on Failure     ValidateCassandra_flag_changes_by_original_folder_timestamp     seen=0  modification_tuid=${modification_tuid}  delivered=0
    Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping    uid=${CREATION_TUID}
    Run Keyword and Continue on Failure     ValidateCassandraMessageActivity	cnt=2

    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "FAIL"   FAIL	PNS notification verification failed \n ${value}



FolderSearchAfterUpdatingtheFlagtoRecent
	Log to Console  "Folder search after depositing the message"
	[Tags]              LM_OEM_MO   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    ${response}=    FolderSearch	headers=${OEM_FOLDER_SEARCH_HEADER}
    Run Keyword and Continue on Failure     ValidateFTFolderSearchResponse    response=${response}		msgStatus=recent	direction=${DIRECTION}	 imdn_type=displayed



Update_Msg_from_Recent_to_Seen
	[Tags]              LM_OEM_MO   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	UpdateFlagToMessage    flag=Seen	headers=${OEM_FETCH_HEADERS}
    ${request}=     GetServicerequest  ${PNS_SOCKET_SERVICE}
	Set Test Variable   ${request}
    ${headers}      ${req_body}     ${version}=     GetRequestData  ${request}
	${pns_status}   ${value}=     Run Keyword and Ignore Error	ValidateFTPNSNotfn    pns_headers=${headers}  pns_body=${req_body}    msgStatus=SEEN	direction=${DIRECTION}	push_recipients_uri=${push_recepient_uri}	pns_subtype=LMMS	
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "PASS"   SendResponse    ${request}  200     OK  ${version}  ELSE    SendResponse    ${request}  400     BadRequest   ${version}
	#Run Keyword and Continue on Failure     ValidateCassandraMessagesTable	seen=1  recent=0	delivered=0		delivered_imdn_list=${MSG_TO}   read_imdn_list=${MSG_TO}
    #Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping
    ${creation_tuid}    ${modification_tuid}=   Run Keyword and Continue on Failure     ValidateCassandra_messages_by_original_folder_timestamp_LargeMessages   recent=0    seen=1  delivered=0     deliveredimdnlist=${MSG_TO}     readimdnlist=${MSG_TO}
    Run Keyword and Continue on Failure     ValidateCassandra_messages_by_root_folder_timestamp     recent=0    seen=1      modification_tuid=${modification_tuid}      delivered=0
    Run Keyword and Continue on Failure     ValidateCassandra_flag_changes_by_root_folder_timestamp     seen=1      modification_tuid=${modification_tuid}  delivered=0
    Run Keyword and Continue on Failure     ValidateCassandra_flag_changes_by_original_folder_timestamp     seen=1  modification_tuid=${modification_tuid}  delivered=0
    Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping    uid=${CREATION_TUID}
    Run Keyword and Continue on Failure     ValidateCassandraMessageActivity	cnt=2

    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "FAIL"   FAIL	PNS notification verification failed \n ${value}



FolderSearchAfterUpdatingtheFlagtoSeen
	Log to Console  "Folder search after seeing the message"
	[Tags]              LM_OEM_MO   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	${response}=    FolderSearch	headers=${OEM_FOLDER_SEARCH_HEADER}
	Run Keyword and Continue on Failure     ValidateFTFolderSearchResponse    response=${response}    direction=${DIRECTION}	msgStatus=seen	 imdn_type=displayed



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

	#Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping	cnt=0

    ${creation_tuid}    ${modification_tuid}=   Run Keyword and Continue on Failure     ValidateCassandra_messages_by_original_folder_timestamp_LargeMessages   recent=0    seen=0  delivered=0     deliveredimdnlist=${MSG_TO}     readimdnlist=${MSG_TO}	deleted=1
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
	Run Keyword If		${EnableDeltraSync} == True		Run Keyword and Continue on Failure     ValidateFTFolderSearchResponse    response=${response}    msgStatus=Deleted	direction=${DIRECTION}	 imdn_type=displayed





DeleteSubscriber
    [Documentation]     "Delete Subscriber If already Exists"
    [Tags]               Provision
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    ${status}    ${delete_response}=        Run Keyword and Ignore Error     DeleteSubscriber_SOAP   ${SUBSCRIBER_ID}
    Run Keyword and Continue on Failure     ValidateDeleteSubscriberResponse    ${delete_response}
    Run Keyword and Continue on Failure     ValidateSoapResponseHeaders     response=${delete_response}
    Run Keyword and Continue on Failure     ValidateSubscriberCassandraUsersTableAfterDeletingSubscriber


