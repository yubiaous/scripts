*** Settings ***
#Comment
Resource        ../../resources/mStore_Digits_TMO_resources.robot
Resource		../../resources/Provision.robot
Metadata    	Version        MSTR-P.4.2.14.3
Suite Setup     prepare_suitebed
Suite Teardown  custom_suite_teardown
Test Timeout	2m
Documentation	"Digits Chat OEM MT Flow"

*** Variables ***
${SUBSCRIBER_ID}=	${TO_MSISDN}
${COSID}=			${DIGITS_COS}
${MSG_TYPE}=		MT
${DIRECTION}=		In
${ASSERTED_SERVICE}=	${P_ASSERTED_SERVICE_CHAT}
${push_recepient_uri}=	${MSG_TO}
${X_IMDN_CORRELATOR}=   ${SUBSCRIBER_ID}_${CONVERSATION_ID}_${IMDN_MESSAGE_ID}
${MESSAGE_CONTEXT}=     ${CHAT_MESSAGE_CONTEXT}
${PNS_TYPE}=            ${CHAT_PNS_TYPE}
${PNS_SUBTYPE}=         ${CHAT_PNS_SUBTYPE}
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
    Run Keyword and Continue on Failure     ValidateSubscriberCassandraUsersTable   imappwd=${IMAP_PWD}  pinpwd=${PIN_PWD}  nut=0  pin_encrypted=0  vvmon=0
    Run Keyword and Continue on Failure     CassandraFolderValidation   folders=${listOfFolders}

CreateSessionForChatDeposit
    [Documentation]     ""
    [Tags]             Chat
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    Set Suite Variable      ${RCS_PARENT_FOLDER_KEY}        ${Generic_Cos_Path_Ids['${RCS_PARENT_PATH}']}

    ${response}=    CreateSessionForChatFT 
    ${resource_url}=   Set Variable    ${response.json()['objectReference']['resourceURL']}
	${session_obj_url}=		Replace String	${resource_url}		http://${LOCAL_FQDN}:80/host		/oemclient
	Set Suite Variable	${SESSION_OBJECT_URL}		${session_obj_url}
    ${resource_url}=    Fetch From Right    ${resource_url}     /
    ${resource_url}=    Split String    ${resource_url}     %3d%3a
    log     ${resource_url}
	${uid}=		Set Variable	${resource_url[1]}
    Set Suite Variable      ${RCS_MESSAGE_FOLDER_KEY}  ${resource_url[0]}=


    ${uid}=     Set Variable    ${resource_url[1]}
    Set Suite Variable      ${UID}      ${uid}

	Run Keyword and Continue on Failure     ValidateCassandraMessagesTable_C44  userId=${USERID}    message_folder_key=${RCS_MESSAGE_FOLDER_KEY}	recent=1    seen=0		uid=${uid}	messagecontext=${CHAT_SESSION_MESSAGE_CONTEXT}
#    Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping



Deposit_Chat_Message
	[Documentation]		"Deposit Chat message"
	[Tags]				CHAT	Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown

    ${response}=    Deposit_Message        DIRECTION_VALUE=${DIRECTION}    headers=${OEM_DEPOSIT_HEADERS}			#P_ASSERTED_SERVICE=${P_ASSERTED_SERVICE_CHAT}

	${resource_url}=   Set Variable    ${response.json()['objectReference']['resourceURL']}
	${resource_url}=	Fetch From Right	${resource_url}		/
	${resource_url}=	Split String	${resource_url}		%3a
	${uid}=     Set Variable    ${resource_url[1]}
	Set Suite Variable		${chat_deposit_uid}		${uid}
	log		${resource_url} 
    Set Suite Variable      ${RCS_PARENT_FOLDER_KEY}        ${Generic_Cos_Path_Ids['${RCS_PARENT_PATH}']}
    Set Suite Variable      ${RCS_MESSAGE_FOLDER_KEY}  ${resource_url[0]}
    ${r_url}=   Replace String  ${resource_url[0]}      %3d     =
    Set Suite Variable      ${RCS_MESSAGE_FOLDER_KEY}   ${r_url}
    log     ${r_url}
    log     ${RCS_MESSAGE_FOLDER_KEY}
    Set Suite Variable  ${CREATION_TUID}    ${resource_url[-1]}
    ${r_url1}=   Replace String  ${resource_url[0]}      %3d     ${EMPTY}
    Set Suite Variable      ${msgFolderkey1}   ${r_url1}
	${request}=		GetServicerequest	${PNS_SOCKET_SERVICE}
	Set Test Variable   ${request}
	${headers}		${req_body}		${version}=		GetRequestData	${request}
	${pns_status}	${value}=		Run Keyword and Ignore Error		ValidateChatPNSNotfn	pns_headers=${headers}	pns_body=${req_body}	direction=${DIRECTION}	msgStatus=RECENT	push_recipients_uri=${push_recepient_uri}		uid=${uid}			folder_path=${CHAT_PARENT_FOLDER_PATH}/${TO_MSISDN}/	
	Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "PASS"   SendResponse    ${request}  200     OK  ${version}  ELSE    SendResponse    ${request}  400     BadRequest   ${version}

#    Run Keyword and Continue on Failure     ValidateCassandraMessagesTable		userId=${USERID}    message_folder_key=${RCS_MESSAGE_FOLDER_KEY}		recent=1    seen=0	uid=${chat_deposit_uid}	
   ${creation_tuid}    ${modification_tuid}=   Run Keyword and Continue on Failure     ValidateCassandra_messages_by_original_folder_timestamp_CHAT    recent=1    seen=0  delivered=0
     Run Keyword and Continue on Failure     ValidateCassandra_messages_by_root_folder_timestamp     recent=1    seen=0      modification_tuid=${modification_tuid}      delivered=0

    Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping		userId=${USERID}        uid=${chat_deposit_uid}		foldername=${CHAT_PARENT_FOLDER_PATH}/${SUBSCRIBER_ID}/
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "FAIL"   FAIL    PNS notification verification failed \n ${value}





FolderSearchAfterDeposit
	[Documentation]		"Folder search after depositing the message"
	[Tags]              CHAT   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	${response}=	FolderSearch		folderkey=${RCS_PARENT_FOLDER_KEY}		headers=${OEM_FOLDER_SEARCH_HEADER}
	Run Keyword and Continue on Failure		ValidateChatFolderSearchResponse_along_with_Session_Chat	direction=${DIRECTION}	response=${response}		uid=${UID}		msgStatus=recent	session_msgStatus=recent		session_msg_uid=${chat_deposit_uid}	







Deliver_Chat_Message
	[Documentation]		"Deliver Chat message"
	[Tags]              CHAT   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    Deposit_Message		X_RCS_MSG_STATUS=Delivered	object_file=${DELIVER_DISPLAY_OBJ_FILE}		MESSAGE_CONTEXT=X-RCS-IMDN	 DIRECTION_VALUE=In		headers=${OEM_DEPOSIT_HEADERS}
    ${request}=     GetServicerequest  ${PNS_SOCKET_SERVICE}
	Set Test Variable   ${request}
    ${headers}      ${req_body}     ${version}=     GetRequestData  ${request}
    ${pns_status}   ${value}=     Run Keyword and Ignore Error	ValidateChatPNSNotfn        pns_headers=${headers}  pns_body=${req_body}	msgStatus=RECENT,DELIVERED		direction=${DIRECTION}	push_recipients_uri=${push_recepient_uri}	pns_subtype=ChatS		uid=${chat_deposit_uid}			folder_path=${CHAT_PARENT_FOLDER_PATH}/${TO_MSISDN}/ 		
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "PASS"   SendResponse    ${request}  200     OK  ${version}  ELSE    SendResponse    ${request}  400     BadRequest   ${version}
#	Run Keyword and Continue on Failure        ValidateCassandraMessagesTable	delivered=1		recent=1	seen=0	uid=${chat_deposit_uid}			
	${creation_tuid}    ${modification_tuid}=   Run Keyword and Continue on Failure     ValidateCassandra_messages_by_original_folder_timestamp_CHAT    recent=1    seen=0  delivered=1     
    Run Keyword and Continue on Failure     ValidateCassandra_messages_by_root_folder_timestamp     recent=1    seen=0     modification_tuid=${modification_tuid}      delivered=1

 
   Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping	uid=${chat_deposit_uid}			foldername=${CHAT_PARENT_FOLDER_PATH}/${SUBSCRIBER_ID}/	
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "FAIL"   FAIL    PNS notification verification failed \n ${value}






FolderSearchAfterIMDNDelivered
    [Documentation]		"Folder search after seeing the message"
	[Tags]              CHAT   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    ${response}=    FolderSearch	headers=${OEM_FOLDER_SEARCH_HEADER}
    Run Keyword and Continue on Failure     ValidateChatFolderSearchResponse_along_with_Session_Chat    direction=${DIRECTION}  response=${response}		uid=${UID}	    msgStatus=recent,delivered  session_msgStatus=recent			session_msg_uid=${chat_deposit_uid}





Display_Chat_Message
	[Documentation]		"Display Chat message"
	[Tags]              CHAT   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    Deposit_Message			X_RCS_MSG_STATUS=Displayed	object_file=${DELIVER_DISPLAY_OBJ_FILE}		MESSAGE_CONTEXT=X-RCS-IMDN	DIRECTION_VALUE=In		headers=${OEM_DEPOSIT_HEADERS}
    ${request}=     GetServicerequest  ${PNS_SOCKET_SERVICE}
	Set Test Variable   ${request}
    ${headers}      ${req_body}     ${version}=     GetRequestData  ${request}
    ${pns_status}   ${value}=     Run Keyword and Ignore Error	ValidateChatPNSNotfn        pns_headers=${headers}  pns_body=${req_body}	msgStatus=SEEN,DELIVERED		direction=${DIRECTION}	push_recipients_uri=${push_recepient_uri}	pns_subtype=ChatS		uid=${chat_deposit_uid}			folder_path=${CHAT_PARENT_FOLDER_PATH}/${TO_MSISDN}/	
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "PASS"   SendResponse    ${request}  200     OK  ${version}  ELSE    SendResponse    ${request}  400     BadRequest   ${version}
    #Run Keyword and Continue on Failure        ValidateCassandraMessagesTable       delivered=1		seen=1	recent=0	uid=${chat_deposit_uid}     	
	${creation_tuid}    ${modification_tuid}=   Run Keyword and Continue on Failure     ValidateCassandra_messages_by_original_folder_timestamp_CHAT    recent=0    seen=1  delivered=1      

     Run Keyword and Continue on Failure     ValidateCassandra_messages_by_root_folder_timestamp     recent=0    seen=1      modification_tuid=${modification_tuid}      delivered=1

    Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping	uid=${chat_deposit_uid}			foldername=${CHAT_PARENT_FOLDER_PATH}/${SUBSCRIBER_ID}/	
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "FAIL"   FAIL    PNS notification verification failed \n ${value}





FolderSearchAfterIMDNArchival
	Log to Console	"Folder search after seeing the message"
	[Tags]              CHAT   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	${response}=    FolderSearch	headers=${OEM_FOLDER_SEARCH_HEADER}
    Run Keyword and Continue on Failure     ValidateChatFolderSearchResponse_along_with_Session_Chat    direction=${DIRECTION}  response=${response}		uid=${UID}	    msgStatus=seen,delivered  session_msgStatus=recent		session_msg_uid=${chat_deposit_uid} 




Fetch_Chat_Message
	[Tags]              CHAT   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	${response}=	FetchMessageObject	ResourceURI=${OBJECT_URL}	headers=${OEM_FETCH_HEADERS}
	ValidateChatFetchResponse	response=${response}	msgStatus=seen,delivered		direction=${DIRECTION}	uid=${chat_deposit_uid}     	FROM_MSISDN=${TO_MSISDN}	





Update_Msg_from_Seen_to_Recent
	[Tags]              CHAT   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	UpdateFlagToMessage		ResourceURI=${OBJECT_URL}	flag=Recent		headers=${OEM_FETCH_HEADERS}
    ${request}=     GetServicerequest  ${PNS_SOCKET_SERVICE}
	Set Test Variable   ${request}
    ${headers}      ${req_body}     ${version}=     GetRequestData  ${request}
    ${pns_status}   ${value}=     Run Keyword and Ignore Error	ValidateChatPNSNotfn     pns_headers=${headers}  pns_body=${req_body}	direction=${DIRECTION}     msgStatus=RECENT,DELIVERED	push_recipients_uri=${push_recepient_uri}	pns_subtype=ChatS		uid=${chat_deposit_uid}			folder_path=${CHAT_PARENT_FOLDER_PATH}/${TO_MSISDN}/
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "PASS"   SendResponse    ${request}  200     OK  ${version}  ELSE    SendResponse    ${request}  400     BadRequest   ${version}
#    Run Keyword and Continue on Failure     ValidateCassandraMessagesTable	recent=1	delivered=1		uid=${chat_deposit_uid}			 
	 ${creation_tuid}    ${modification_tuid}=   Run Keyword and Continue on Failure     ValidateCassandra_messages_by_original_folder_timestamp_CHAT    recent=1    seen=0  delivered=1     

     Run Keyword and Continue on Failure     ValidateCassandra_messages_by_root_folder_timestamp     recent=1    seen=0      modification_tuid=${modification_tuid}      delivered=1

    Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping	uid=${chat_deposit_uid}		foldername=${CHAT_PARENT_FOLDER_PATH}/${SUBSCRIBER_ID}/	
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "FAIL"   FAIL	PNS notification verification failed \n ${value}






FolderSearchAfterUpdatingtheFlagtoRecent
	Log to Console  "Folder search after depositing the message"
	[Tags]              CHAT   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    ${response}=    FolderSearch	headers=${OEM_FOLDER_SEARCH_HEADER}
    Run Keyword and Continue on Failure     ValidateChatFolderSearchResponse_along_with_Session_Chat    direction=${DIRECTION}  response=${response} 		uid=${UID}	   msgStatus=recent,delivered  session_msgStatus=recent		session_msg_uid=${chat_deposit_uid}	


Update_Msg_from_Recent_to_Seen
	[Tags]              CHAT   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	UpdateFlagToMessage    flag=Seen	headers=${OEM_FETCH_HEADERS}	ResourceURI=${OBJECT_URL}
    ${request}=     GetServicerequest  ${PNS_SOCKET_SERVICE}
	Set Test Variable   ${request}
    ${headers}      ${req_body}     ${version}=     GetRequestData  ${request}
	${pns_status}   ${value}=     Run Keyword and Ignore Error	ValidateChatPNSNotfn    pns_headers=${headers}  pns_body=${req_body}    msgStatus=SEEN,DELIVERED	direction=${DIRECTION}	push_recipients_uri=${push_recepient_uri}	pns_subtype=ChatS		uid=${chat_deposit_uid}			 folder_path=${CHAT_PARENT_FOLDER_PATH}/${TO_MSISDN}/
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "PASS"   SendResponse    ${request}  200     OK  ${version}  ELSE    SendResponse    ${request}  400     BadRequest   ${version}
#	Run Keyword and Continue on Failure     ValidateCassandraMessagesTable	seen=1  recent=0	delivered=1		uid=${chat_deposit_uid}			
  ${creation_tuid}    ${modification_tuid}=   Run Keyword and Continue on Failure     ValidateCassandra_messages_by_original_folder_timestamp_CHAT    recent=0    seen=1  delivered=1      
     Run Keyword and Continue on Failure     ValidateCassandra_messages_by_root_folder_timestamp     recent=0    seen=1      modification_tuid=${modification_tuid}      delivered=1

    Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping	uid=${chat_deposit_uid}		foldername=${CHAT_PARENT_FOLDER_PATH}/${SUBSCRIBER_ID}/
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "FAIL"   FAIL    PNS notification verification failed \n ${value}



FolderSearchAfterUpdatingtheFlagtoSeen
	Log to Console  "Folder search after seeing the message"
	[Tags]              CHAT   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	${response}=    FolderSearch	headers=${OEM_FOLDER_SEARCH_HEADER}
    Run Keyword and Continue on Failure     ValidateChatFolderSearchResponse_along_with_Session_Chat    direction=${DIRECTION}  response=${response}  		uid=${UID}	  msgStatus=seen,delivered  session_msgStatus=recent			 session_msg_uid=${chat_deposit_uid}	


DeleteChatMessage
	[Tags]              CHAT   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	${response}=	DeleteMsgObject	response_code=204	headers=${OEM_FETCH_HEADERS}
	Sleep   1
	${request}=     GetServicerequest  ${PNS_SOCKET_SERVICE}
	Set Test Variable   ${request}
    ${headers}      ${req_body}     ${version}=     GetRequestData  ${request}
	${pns_status}   ${value}=     Run Keyword and Ignore Error	ValidateChatDeletePNSNotfn     pns_headers=${headers}  pns_body=${req_body}		msgStatus=DELETED		direction=${DIRECTION}	pns_subtype=ChatD	push_recipients_uri=${push_recepient_uri}		uid=${chat_deposit_uid} 	
    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "PASS"   SendResponse    ${request}  200     OK  ${version}  ELSE    SendResponse    ${request}  400     BadRequest   ${version}
 
   ${creation_tuid}    ${modification_tuid}=   Run Keyword and Continue on Failure     ValidateCassandra_messages_by_original_folder_timestamp_CHAT    recent=0    seen=0  delivered=0     deleted=1      
     Run Keyword and Continue on Failure     ValidateCassandra_messages_by_root_folder_timestamp     recent=0    seen=0     modification_tuid=${modification_tuid}      delivered=0      deleted=1
      Run Keyword and Continue on Failure     ValidateCassandraIMDNMapping        uid=${CREATION_TUID}        foldername=${CHAT_PARENT_FOLDER_PATH}/${SUBSCRIBER_ID}/

    Run Keyword and Continue on Failure     Run Keyword If      "${pns_status}" == "FAIL"   FAIL    PNS notification verification failed \n ${value}




	
Redelete_Chat_Msg
	[Tags]              CHAT   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
	${response}=    DeleteMsgObject		response_code=204	headers=${OEM_FETCH_HEADERS}



FolderSearchAfterDeletingtheMsg
    [Tags]              CHAT   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    ${no_of_msgs}=  Set Variable If     ${EnableDeltraSync} == True     2   1
    ${response}=    FolderSearch    response_code=200   headers=${OEM_FOLDER_SEARCH_HEADER}
    Run Keyword If      ${EnableDeltraSync} == True     Run Keyword and Continue on Failure     ValidateChatFolderSearchResponse_along_with_Session_Chat    response=${response}        uid=${UID}     msgStatus=Deleted    direction=${DIRECTION}  session_msgStatus=recent    no_of_msgs=${no_of_msgs}        session_msg_uid=${chat_deposit_uid}




DeleteChatSession
    [Tags]              CHAT   Critical
    [Setup]         prepare_testbed
    [Teardown]      custom_teardown
    ${response}=    DeleteMsgObject     response_code=204   headers=${OEM_FETCH_HEADERS}    ResourceURI=${SESSION_OBJECT_URL}


