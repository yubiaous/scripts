*** Settings ***
#Settings
Resource    NEW_mStore_Generic_resources.robot

*** Variables ***

*** Keywords ***
CloseRequest
    [Arguments]    ${request}
    close_socket    ${request}

GetFolderKey_From_UsersFolderKey
    [Arguments]    ${userid}=${SUBSCRIBER_ID}    ${parent_folder_name}=${VAR_PARENTFOLDER_NAME}    ${msg_folder_name}=${VAR_PARENTFOLDERPATH_STORE}
    Switch Connection    cass_db
    Write    select json userid,folderkey from userfolderkeymap where userid='${userid}' and foldername='${parent_folder_name}';
    ${data}=    Read Until    \>
    Write    select json userid,folderkey from userfolderkeymap where userid='${userid}' and foldername='${msg_folder_name}';
    ${data1}=    Read Until    \>
    ${user}=    Convert to String    ${userid}
    ${data}=    Get Lines Containing String    ${data}    ${user}
    ${data1}=    Get Lines Containing String    ${data1}    ${user}
    ${data_json}=    Evaluate    json.loads('''${data}''')    json
    ${data1_json}=    Evaluate    json.loads('''${data1}''')    json
    [Return]    ${data_json['folderkey']}    ${data1_json['folderkey']}    
    

ValidateChatPNSNotfn
		[Arguments]		${pns_headers}   ${pns_body}   ${userId}=${SUBSCRIBER_ID}    ${direction}=Out	${msgStatus}=RECENT    ${sender}=${MSG_FROM}    ${recipients_uri}=${MSG_TO}    ${push_recipients_uri}=${recipients_uri}  ${uid}=1   ${pns_subtype}=${PNS_SUBTYPE}   ${service_root_path}=${OEM_SERVER_ROOT_PATH}    ${oem_path}=${OEM_HOST_URI}    ${parentfolderkey}=${RCS_PARENT_FOLDER_KEY}   ${msgFolderkey}=${RCS_MESSAGE_FOLDER_KEY}	${notification_type}=pns	${folder_path}=${CHAT_PARENT_FOLDER_PATH}/${FROM_MSISDN}/		${PNS_TYPE}=${PNS_TYPE}		${imdn_pns}=deposit		${P_ASSERTED_SERVICE}=${ASSERTED_SERVICE}		${msg_type}=individual	${group_members}=${MSG_TO_GROUP_MEMBERS}	${read_recipients_uri}=${NONE}	${delivered_recipients_uri}=${NONE}		${MULTIFLAG}=FALSE
 
	log	${pns_headers}
	log	${pns_body}
    ${pns_resource_url}=	Set Variable	https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey}%3a${uid}
    ${pns_object_Url}=		Set Variable	https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey}%3a${uid}
    ${pns_parentFolder}=	Set Variable	https://${service_root_path}${oem_path}${userId}/folders/${msgFolderkey}
    ${json_data}=    Set Variable    ${pns_body}
    ${json_data}=    Replace String    ${json_data}    \\    ${EMPTY}
    ${json_out}=    Evaluate    json.loads('''${json_data}''',strict=False)    json
    log    ${json_out}
	Set Suite Variable	${PNS_OBJECT_URL}	${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['objectURL']}
	${OBJECT_URL}=     Replace String		${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['objectURL']}		https://${service_root_path}	${EMPTY}
	Set Suite Variable	${OBJECT_URL}
    ${status_msg}=    Split String    ${msgStatus}    ,
    ${len_msg_status}=    Get Length    ${status_msg}    
  	${len_response_body} =	Get Length	${pns_body}
    Run Keyword and Continue on failure    Run Keyword If   '${notification_type}' == 'pns'		Should Be Equal As Strings    ${pns_headers['host']}    ${PNS_SERVER_NAME}:${PNS_SERVICE_PORT}
	Run Keyword and Continue on failure    Run Keyword If   '${notification_type}' == 'nms'     Should Be Equal As Strings    ${pns_headers['host']}    ${NMS_SERVER_NAME}:${NMS_SERVICE_PORT}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${pns_headers['content-type']}    ${PNS_RESPONSE_CONTENT_TYPE}
    Run Keyword and Continue on failure    Run Keyword If	'${notification_type}' == 'pns'		Should Be Equal As Strings    ${pns_headers['authorization']}    Basic ${PNS_AUTHORIZATION}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${pns_headers['content-length']}    ${len_response_body}
  	Run Keyword and Ignore Error	Run Keyword and Continue on Failure    Should Match Regexp    ${pns_headers['X-mStoreFE-Addr']}    FEname:${FE_NAME}-nodeId:${NODE_ID}-ConnId:[a-zA-Z0-9]+-slot:${SLOT_ID}-instId:[0-9]+-subOid:[0-9]+-time:[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z-localFqdn:${LOCAL_FQDN} 

    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['serviceName']}    ${PNS_SERVICE_NAME}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['TTL']}    ${PNS_TTL}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['recipients'][0]['uri']}    ${push_recipients_uri}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['channel']}       ${PNS_CHANNEL}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['pns-type']}    ${PNS_TYPE}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['pns-subtype']}    ${pns_subtype}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['parentFolder']}    ${pns_parentFolder}
    Run Keyword and Continue on failure    Run Keyword If   ${len_msg_status} == 1	Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['flags']['flag'][0]}    ${status_msg[0]}	ignore_case=True
	Run Keyword and Continue on failure		Run Keyword If   ${len_msg_status} > 1 and '${imdn_pns}' != 'displayed'	Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['flags']['flag'][1]}    ${status_msg[1]}        ignore_case=True
	Run Keyword and Continue on failure		Run Keyword If   ${len_msg_status} > 1 and '${imdn_pns}' == 'displayed'	Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['flags']['flag'][0]}    ${status_msg[0]}        ignore_case=True

    Run Keyword and Continue on failure    Run Keyword If    '${direction}'== 'In' and '${MULTIFLAG}' == 'TRUE'    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['flags']['flag'][1]}    ${status_msg[1]}		ignore_case=True
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['resourceURL']}    ${pns_resource_url}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['correlationId']}    ${CORRELATION_ID}
    #Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['id']}    ${uid}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['store']}    ${folder_path}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['objectURL']}    ${pns_object_Url}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['direction']}    ${direction}
    Run Keyword and Continue on failure    Should Match Regexp    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['message-time']}    [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]{3}-[0-9]{2}:[0-9]{2}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['status']}    ${msgStatus}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['sender']}    ${sender}
	Run Keyword and Continue on failure	   Run Keyword If	'${msg_type}' == 'group'	ValidateGroupRecepients		${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['recipients']}		${group_members}	ELSE    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['recipients'][0]['uri']}    ${recipients_uri}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['imdn-message-id']}    ${IMDN_MESSAGE_ID}

	${delivered_list}=	Set Variable If 	'${imdn_pns}' != 'deposit' and '${direction}' == 'Out'	${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['imdn']['delivered']}
	${read_list}=	Set Variable If		'${imdn_pns}' == 'displayed' and '${direction}' == 'Out'	${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['imdn']['read']}

	Run Keyword and Continue on failure	   Run Keyword If	 '${imdn_pns}' == 'delivered' and '${msg_type}' == 'group'    ValidateImdnDeliveredDisplayed	${delivered_recipients_uri}	${delivered_list}	ELSE IF		'${imdn_pns}' == 'delivered'	Should Be Equal As Strings	${delivered_list[0]}	${recipients_uri}

    Run Keyword and Continue on failure	   Run Keyword If      '${imdn_pns}' == 'displayed' and '${msg_type}' == 'group'    ValidateImdnDeliveredDisplayed    ${delivered_recipients_uri}   ${delivered_list}   ELSE IF    '${imdn_pns}' == 'displayed'	Should Be Equal As Strings    ${delivered_list[0]}    ${recipients_uri}	

    Run Keyword and Continue on failure		Run Keyword If	 '${imdn_pns}' == 'displayed' and '${msg_type}' == 'group'   ValidateImdnDeliveredDisplayed    ${read_recipients_uri}	${read_list}   ELSE IF		 '${imdn_pns}' == 'displayed'	Should Be Equal As Strings    ${read_list[0]}    ${recipients_uri}

    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['content'][0]['content-type']}    ${CHAT_CONTENT_TYPE}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['content'][0]['content-size']}    ${CHAT_CONTENT_LENGTH}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['content'][0]['content']}    ${CHAT_CONTENT_DATA}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['content'][0]['content-transfer-encoding']}    ${CHAT_CONTENT_TRANSFER_ENCODING}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['content'][0]['charset']}    ${CHAT_CHARSET}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['content'][0]['rcs-data']['contribution-id']}    ${CONTRIBUTION_ID}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['content'][0]['rcs-data']['conversation-id']}    ${CONVERSATION_ID}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['content'][0]['rcs-data']['p-asserted-service']}    ${P_ASSERTED_SERVICE}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['content'][0]['rcs-data']['feature-tag']}    ${P_ASSERTED_SERVICE}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['content'][0]['rcs-data']['sip-call-id']}    ${X_SIP_CALLID}

ValidateImdnDeliveredDisplayed    
	[Arguments]		${delivered_recipients_uri}		${delivered_list}

	${length1}=		Get Length		${delivered_recipients_uri}
	${length2}=		Get Length		${delivered_list}
	Lists Should Be Equal		${delivered_recipients_uri}		${delivered_list}	msg="delivered/read recipient list are not equal either in pnssync or foldersync"


ValidateGroupRecepients
	[Arguments]		${pns_recepients_list}		${members}
	${index}=	Set Variable	0
	:FOR	${member}	IN	@{members}
	\	Run Keyword and Continue on Failure		Should Be Equal As Strings		${pns_recepients_list[${index}]['uri']}		${member}
	\	${index}=	Evaluate	${index}+1

ValidateCassandraIMDNMapping
	[Arguments]		${userId}=${USERID}		${cnt}=1	${uid}=1	${folderkey}=${RCS_MESSAGE_FOLDER_KEY}    ${rootfolderkey}=${RCS_PARENT_FOLDER_KEY}    ${creation_tuid}=${uid}	${imdn_msg_id}=${IMDN_MESSAGE_ID}	${cosid}=${COSID}	${foldername}=${FT_PARENT_FOLDER_PATH}/${SUBSCRIBER_ID}/			${SUBSCRIBER_ID}=${SUBSCRIBER_ID}
	${imdncorrelator}=	Set Variable	${SUBSCRIBER_ID}_${imdn_msg_id}
    Switch Connection    cass_db
    Write   select json * from imdnmsgidmapping where userid='${userId}' and creation_tuid=${uid} ALLOW FILTERING;
    ${out}=    Read Until    ${MSTORE_CASSANDRA_KEYSPACE}\>
	Run Keyword and Continue on failure     Should Contain  ${out}  (${cnt} rows)
	Return From Keyword If		${cnt} == 0
    ${user}=    Convert to String    ${userId}
    ${res}=    Get Lines Containing String    ${out}    ${user}
    ${imdn_mapping}=    Evaluate    json.loads('''${res}''')    json
    log    ${imdn_mapping}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${imdn_mapping['creation_tuid']}    ${creation_tuid}
	Run Keyword and Continue on Failure    Should Be Equal As Strings    ${imdn_mapping['folderkey']}    ${folderkey}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${imdn_mapping['rootfolderkey']}	${rootfolderkey}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${imdn_mapping['imdncorrelator']}	${imdncorrelator}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${imdn_mapping['cosid']}	${cosid}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${imdn_mapping['foldername']}	${foldername}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${imdn_mapping['userid']}		${userId}

ValidateCassandraIMDNMappingCHAT
    [Arguments]     ${userId}=${USERID}     ${cnt}=1    ${uid}=1    ${folderkey}=${RCS_MESSAGE_FOLDER_KEY}    ${rootfolderkey}=${RCS_PARENT_FOLDER_KEY}    ${creation_tuid}=${uid}  ${imdn_msg_id}=${IMDN_MESSAGE_ID}   ${cosid}=${COSID}   ${foldername}=${FT_PARENT_FOLDER_PATH}/${SUBSCRIBER_ID}/            ${SUBSCRIBER_ID}=${SUBSCRIBER_ID}
    ${imdncorrelator}=  Set Variable    ${SUBSCRIBER_ID}_${imdn_msg_id}
    Switch Connection    cass_db
    Write   select json * from imdnmsgidmapping where userid='${userId}' and imdncorrelator='${imdncorrelator}' and creation_tuid=${uid} ALLOW FILTERING;
    ${out}=    Read Until    ${MSTORE_CASSANDRA_KEYSPACE}\>
    Run Keyword and Continue on failure     Should Contain  ${out}  (${cnt} rows)
    Return From Keyword If      ${cnt} == 0
    ${user}=    Convert to String    ${userId}
    ${res}=    Get Lines Containing String    ${out}    ${user}
    ${imdn_mapping}=    Evaluate    json.loads('''${res}''')    json
    log    ${imdn_mapping}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${imdn_mapping['creation_tuid']}    ${creation_tuid}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${imdn_mapping['folderkey']}    ${folderkey}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${imdn_mapping['rootfolderkey']}   ${rootfolderkey}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${imdn_mapping['imdncorrelator']}  ${imdncorrelator}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${imdn_mapping['cosid']}   ${cosid}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${imdn_mapping['foldername']}  ${foldername}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${imdn_mapping['userid']}      ${userId}


ValidateCassandraMessagesAfterDelete    
	[Arguments]		${userId}=${SUBSCRIBER_ID}    ${uid}=1	${parent_folder_key}=${RCS_PARENT_FOLDER_KEY}    ${message_folder_key}=${RCS_MESSAGE_FOLDER_KEY}	${messages}=1  ${messages_by_folder_timestamp}=1

    Switch Connection    cass_db
    Write   select json * from messages_by_root_folder_timestamp where userid='${userId}' and rootfolderkey='${parent_folder_key}' and creation_tuid=${creation_tuid};
    ${out}=    Read Until    ${MSTORE_CASSANDRA_KEYSPACE}\>
	Run Keyword and Continue on failure		Should Contain	${out}	(${messages} rows)
    Write   select json * from messages_by_original_folder_timestamp where userid='${userId}' and folderkey='${message_folder_key}' and creation_tuid=${creation_tuid};
    ${out}=    Read Until    ${MSTORE_CASSANDRA_KEYSPACE}\>
	Run Keyword and Continue on failure     Should Contain  ${out}  (${messages_by_folder_timestamp} rows)	

ValidateCassandraMessagesTable
    [Arguments]    ${userId}=${SUBSCRIBER_ID}    ${parent_folder_key}=${RCS_PARENT_FOLDER_KEY}    ${message_folder_key}=${RCS_MESSAGE_FOLDER_KEY}    ${recent}=1    ${flagged}=0    ${delivered}=0    ${answered}=0    ${messagecontext}=${MESSAGE_CONTEXT}    ${seen}=0    ${mstore_version}=vm_2_1    ${uid}=1		${read_imdn_list}=${NONE}		${delivered_imdn_list}=${NONE}	${from_header}=${MSG_FROM}	${to_header}=${msg_to}	${msg_type}=individual		${deleted}=0		${creation_tuid}=${uid}	
    Switch Connection    cass_db
    Write  select json * from messages_by_root_folder_timestamp where userid='${userId}' and rootfolderkey='${parent_folder_key}' and creation_tuid=${creation_tuid};

    ${out}=    Read Until    ${MSTORE_CASSANDRA_KEYSPACE}\>    
    ${user}=    Convert to String    ${userId}
    ${res}=    Get Lines Containing String    ${out}    ${user}
    ${messages}=    Evaluate    json.loads('''${res}''')    json
    log    ${messages}

    Write   select json * from messages_by_original_folder_timestamp where userid='${userId}' and folderkey='${message_folder_key}' and creation_tuid=${creation_tuid};

    ${out}=    Read Until    ${MSTORE_CASSANDRA_KEYSPACE}\>
    ${res}=    Get Lines Containing String    ${out}    ${user}
    ${messages_by_folders}=    Evaluate    json.loads('''${res}''')    json
    log    ${messages_by_folders}

	${members}=	Set Variable	${to_header}
	${to_members}=	Set Variable	${EMPTY}
	:FOR	${member}	IN	${members}
	\	${to_members}=	Set Variable	${to_members},${member}
	
	log		${to_header}
	log		${to_members}
#	Set Suite Variable	${PAYLOAD_CONTENT_SIZE}		${messages['bodyoctets']}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['userid']}    ${userId}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['rootfolderkey']}    ${parent_folder_key}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['recent']}    ${recent}
#    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['flagged']}    ${flagged}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['delivered']}    ${delivered}
#    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['']}    ${answered}
#    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['messagecontext']}    ${messagecontext}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['seen']}    ${seen}
#    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['mstore_version']}    ${mstore_version}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['deleted']}   		${deleted}
	Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['folderkey']}		${message_folder_key}
	Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['imdn_disposition_data']}		${NULL}
	Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['saved']}       ${NULL}
#    Run Keyword and Continue on failure	   Run Keyword If	'${msg_type}' != 'group'	Should Be Equal As Strings    ${messages['toheader']}       ${to_header}	#ELSE	Should Be Equal As Strings		${messages['toheader']}		${to_members}
   Set Suite Variable      ${modification_tuid}   ${messages['modification_tuid']}
    
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['userid']}    ${userId}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['folderkey']}    ${message_folder_key}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['recent']}    ${recent}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['rootfolderkey']}   ${RCS_PARENT_FOLDER_KEY}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['delivered']}    ${delivered}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['seen']}    ${seen}
	Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['deleted']}    ${deleted}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['creation_tuid']}    ${creation_tuid}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['imdn_disposition_data']}    ${NONE}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['modification_tuid']}		${modification_tuid}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['saved']}        ${read_imdn_list}
    #Set Suite Variable      ${modification_tuid}   ${messages['modification_tuid']}

	ValidateCassandraMessagesTableTTLTMO	uid=${creation_tuid}		messages_creation_ts=${messages["creation_tuid"]}    message_folder_key=${message_folder_key}     parent_folderkey=${parent_folder_key}


#    [Return]    ${messages['swiftobjurl']}

ValidateCassandraMessagesTable_C44
    [Arguments]    ${userId}=${SUBSCRIBER_ID}    ${parent_folder_key}=${RCS_PARENT_FOLDER_KEY}    ${message_folder_key}=${RCS_MESSAGE_FOLDER_KEY}    ${recent}=1    ${flagged}=0    ${delivered}=0    ${answered}=0    ${messagecontext}=${MESSAGE_CONTEXT}    ${seen}=0    ${mstore_version}=vm_2_1    ${uid}=1		${read_imdn_list}=${NONE}		${delivered_imdn_list}=${NONE}	${from_header}=${MSG_FROM}	${to_header}=${msg_to}	${msg_type}=individual		${deleted}=0		${creation_tuid}=${uid}	
    Switch Connection    cass_db
    Write  select json * from messages_by_root_folder_timestamp where userid='${userId}' and rootfolderkey='${parent_folder_key}' and creation_tuid=${creation_tuid};

    ${out}=    Read Until    ${MSTORE_CASSANDRA_KEYSPACE}\>    
    ${user}=    Convert to String    ${userId}
    ${res}=    Get Lines Containing String    ${out}    ${user}
    ${messages}=    Evaluate    json.loads('''${res}''')    json
    log    ${messages}
    
	Write   select json * from messages_by_original_folder_timestamp where userid='${userId}' and folderkey='${message_folder_key}' and creation_tuid=${creation_tuid};

    ${out}=    Read Until    ${MSTORE_CASSANDRA_KEYSPACE}\>
    ${res}=    Get Lines Containing String    ${out}    ${user}
    ${messages_by_folders}=    Evaluate    json.loads('''${res}''')    json
    log    ${messages_by_folders}

	${members}=	Set Variable	${to_header}
	${to_members}=	Set Variable	${EMPTY}
	:FOR	${member}	IN	${members}
	\	${to_members}=	Set Variable	${to_members},${member}
	
	log		${to_header}
	log		${to_members}
#	Set Suite Variable	${PAYLOAD_CONTENT_SIZE}		${messages['bodyoctets']}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['userid']}    ${userId}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['rootfolderkey']}    ${parent_folder_key}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['recent']}    ${recent}
#    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['flagged']}    ${flagged}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['delivered']}    ${delivered}
#    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['']}    ${answered}
#    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['messagecontext']}    ${messagecontext}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['seen']}    ${seen}
#    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['mstore_version']}    ${mstore_version}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['deleted']}   		${deleted}
	Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['folderkey']}		${message_folder_key}
	Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['imdn_disposition_data']}		${NULL}
	Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['saved']}       ${NULL}
#    Run Keyword and Continue on failure	   Run Keyword If	'${msg_type}' != 'group'	Should Be Equal As Strings    ${messages['toheader']}       ${to_header}	#ELSE	Should Be Equal As Strings		${messages['toheader']}		${to_members}
   Set Suite Variable      ${modification_tuid}   ${messages['modification_tuid']}
    
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['userid']}    ${userId}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['folderkey']}    ${message_folder_key}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['recent']}    ${recent}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['rootfolderkey']}   ${RCS_PARENT_FOLDER_KEY}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['delivered']}    ${delivered}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['seen']}    ${seen}
	Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['deleted']}    ${deleted}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['creation_tuid']}    ${creation_tuid}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['imdn_disposition_data']}    ${NONE}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['modification_tuid']}		${modification_tuid}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['saved']}        ${read_imdn_list}
    #Set Suite Variable      ${modification_tuid}   ${messages['modification_tuid']}

	ValidateCassandraMessagesTableTTLTMO	uid=${creation_tuid}		messages_creation_ts=${messages["creation_tuid"]}      message_folder_key=${message_folder_key}     parent_folderkey=${parent_folder_key}


  #  [Return]    ${messages['swiftobjurl']}



ValidateCassandraMessagesTableTTLTMO
    [Arguments]    ${messages_creation_ts}    ${message_folder_key}    ${parent_folderkey}     ${userId}=${USERID}       ${uid}=1
    Switch Connection    cass_db
    Write    SELECT JSON userid,TTL(delivered) ,TTL(messagecontext) ,TTL(contenttype) ,TTL(recent),TTL(seen) from messages_by_original_folder_timestamp where userid ='${userId}' and folderkey='${message_folder_key}' and creation_tuid=${uid};

    ${out}=    Read Until    \>
    Write    SELECT JSON userid,TTL(delivered),TTL(folderkey),TTL(imdn_disposition_data),TTL(modification_tuid),TTL(recent),TTL(seen) from messages_by_root_folder_timestamp where userid ='${userId}' and rootfolderkey='${parent_folderkey}' and creation_tuid=${uid};

    ${out1}=    Read Until    \>
    ${user}=    Convert to String    ${userId}
    ${msg_res}=    Get Lines Containing String    ${out}    ${user}
    ${fld_res}=    Get Lines Containing String    ${out1}    ${user}

    ${messages}=    Evaluate    json.loads('''${msg_res}''')    json
    ${messages_by_folder}=    Evaluate    json.loads('''${fld_res}''')    json
    log   ${messages}
    log   ${messages_by_folder}
    Run Keyword and Continue on failure    Should Be Equal    ${messages['ttl(messagecontext)']}		${messages['ttl(messagecontext)']}
    Run Keyword and Continue on failure    Should Be Equal    ${messages['ttl(recent)']}    ${messages['ttl(messagecontext)']}
    Run Keyword and Continue on failure    Should Be Equal    ${messages['ttl(contenttype)']}    ${messages['ttl(messagecontext)']}
	Run Keyword and Continue on failure    Should Be Equal    ${messages['ttl(seen)']}    ${messages['ttl(messagecontext)']}
	

    Run Keyword and Continue on failure    Should Be Equal    ${messages_by_folder['ttl(delivered)']}    ${messages_by_folder['ttl(delivered)']}
    Run Keyword and Continue on failure    Should Be Equal    ${messages_by_folder['ttl(folderkey)']}    ${messages_by_folder['ttl(folderkey)']}
	Run Keyword and Continue on failure    Should Be Equal    ${messages_by_folder['ttl(imdn_disposition_data)']}    ${messages_by_folder['ttl(imdn_disposition_data)']}
	Run Keyword and Continue on failure    Should Be Equal    ${messages_by_folder['ttl(modification_tuid)']}    ${messages_by_folder['ttl(modification_tuid)']}
	Run Keyword and Continue on failure    Should Be Equal    ${messages_by_folder['ttl(recent)']}    ${messages_by_folder['ttl(recent)']}
	Run Keyword and Continue on failure    Should Be Equal    ${messages_by_folder['ttl(seen)']}    ${messages_by_folder['ttl(seen)']}




ValidateCassandraMessagesTableTTL
    [Arguments]    ${messages_creation_ts}		${userId}=${SUBSCRIBER_ID}    ${parent_folderkey}=${RCS_PARENT_FOLDER_KEY}    ${msg_folderkey}=${RCS_MESSAGE_FOLDER_KEY}	${uid}=1
    Switch Connection    cass_db
    Write    SELECT JSON userid,TTL(bodyoctets),TTL(bucketkey),TTL(contenttype),TTL(creation_ts),TTL(messagecontext),TTL(contentencoding) from messages where userid ='${userId}' and folderkey='${msg_folderkey}' and uid=${uid} ALLOW FILTERING;
    ${out}=    Read Until    \>
    Write    SELECT JSON userid,TTL(bodyoctets),TTL(bucketkey),TTL(contenttype),TTL(messagecontext),TTL(contentencoding) from messages_by_folder_timestamp where userid ='${userId}' and folderkey='${parent_folderkey}' and creation_ts='${messages_creation_ts}' and uid=${uid} ALLOW FILTERING;
    ${out1}=    Read Until    \>
    ${user}=    Convert to String    ${userId}
    ${msg_res}=    Get Lines Containing String    ${out}    ${user}
    ${fld_res}=    Get Lines Containing String    ${out1}    ${user}
    
    ${messages}=    Evaluate    json.loads('''${msg_res}''')    json
    ${messages_by_folder}=    Evaluate    json.loads('''${fld_res}''')    json

    Run Keyword and Continue on failure    Should Be Equal    ${messages['ttl(bodyoctets)']}    ${messages['ttl(contenttype)']}
    Run Keyword and Continue on failure    Should Be Equal    ${messages['ttl(contenttype)']}    ${messages['ttl(messagecontext)']}
    Run Keyword and Continue on failure    Should Be Equal    ${messages['ttl(contenttype)']}    ${messages['ttl(contentencoding)']}
    
	Run Keyword and Continue on failure    Should Be Equal    ${messages_by_folder['ttl(deleted)']}    ${messages_by_folder['ttl(contenttype)']}
    Run Keyword and Continue on failure    Should Be Equal    ${messages_by_folder['ttl(delivered)']}    ${messages_by_folder['ttl(messagecontext)']}
    Run Keyword and Continue on failure    Should Be Equal    ${messages_by_folder['ttl(folderkey)']}    ${messages_by_folder['ttl(contentencoding)']}
    Run Keyword and Continue on failure    Should Be Equal    ${messages_by_folder['ttl(imdn_disposition_data)']}    ${messages_by_folder['ttl(imdn_disposition_data)']}
    Run Keyword and Continue on failure    Should Be Equal    ${messages_by_folder['ttl(modification_tuid)']}    ${messages_by_folder['ttl(modification_tuid)']}
    Run Keyword and Continue on failure    Should Be Equal    ${messages_by_folder['ttl(recent)']}    ${messages_by_folder['ttl(recent)']}
    Run Keyword and Continue on failure    Should Be Equal    ${messages_by_folder['ttl(saved)']}    ${messages_by_folder['ttl(saved)']}
    Run Keyword and Continue on failure    Should Be Equal    ${messages_by_folder['ttl(seen)']}    ${messages_by_folder['ttl(seen)']}

FolderSearch
    [Arguments]    ${userId}=${SUBSCRIBER_ID}    ${folderkey}=${RCS_PARENT_FOLDER_KEY}    ${oem_host}=${OEM_HOST_URI}    ${obj_file}=FolderSearch.json    ${headers}=${OEM_FOLDER_SEARCH_HEADER}    ${response_code}=200	${server_root_path}=${OEM_SERVER_ROOT_PATH}		${mStore_request_session}=${MSTORE_SESSION_NAME}

    ${FOLDER_SEARCH_RESOURCE_URL}=    Set Variable    http://${server_root_path}${oem_host}${userId}/folders/${folderkey}
	${data}=	OperatingSystem.Get File	${CURDIR}/../testfiles/${obj_file}	
    ${data}=	Replace Variables	${data}

	${uri}=		Set Variable	${oem_host}${userId}/objects/operations/search

    ${response}=    RequestsLibrary.Post Request    alias=${mStore_request_session}    uri=${uri}    data=${data}    headers=${headers}
    ${response_status_code}=    Convert to String    ${response.status_code}
    log    ${response.status_code}
    log    ${response.text}
    log    ${response.headers}
    Should Be Equal    ${response_status_code}    ${response_code}    msg="folder search is not success,which has repose ${response.status_code}"
    [Return]    ${response}


ValidateChatFolderSearchResponse
	[Arguments]		${response}		${direction}=Out	${from_msg}=${MSG_FROM}		${to_msg}=${MSG_TO}		${message_context}=${MESSAGE_CONTEXT}	${msgFolderkey}=${RCS_MESSAGE_FOLDER_KEY}	${uid}=1	${msgStatus}=Recent		${service_root_path}=${OEM_SERVER_ROOT_PATH}    ${oem_path}=${OEM_HOST_URI}		${userId}=${SUBSCRIBER_ID}	${no_of_msgs}=1		${P_ASSERTED_SERVICE}=${ASSERTED_SERVICE}	${msg_type}=individual	${imdn_type}=deposit		${read_recipients_uri}=${NONE}  ${delivered_recipients_uri}=${NONE}			${FROM_MSISDN}=${FROM_MSISDN}	${MSISDN}=${FROM_MSISDN}
	
	${to}=	Run Keyword If	'${msg_type}' == 'individual'	Create List		${to_msg}	ELSE	Copy List	${to_msg}
    #log    ${uid}	
    ${status_msg}=    Split String    ${msgStatus}    ,
    ${len_msg_status}=    Get Length    ${status_msg}
    log		${UID}
    log    ${response.headers}
    ${data}=    set Variable	${response.json()}
    log    ${data}
    ${list_of_objects}=    Get Length    ${data['objectList']['object']}    
	Run Keyword and Continue On Failure		Should Be Equal As Strings	${list_of_objects}	${no_of_msgs}
    :FOR    ${index}    IN RANGE    0    ${list_of_objects}
    \    ${Attributes_pair}=    Get_FolderSearch_AttributesPair    ${data['objectList']['object'][${index}]['attributes']['attribute']}
    \    log    ${Attributes_pair}
	#\    ${uid}=	Evaluate	${index} + 1
	\    ${obj_parentFolder}=	Set Variable	https://${service_root_path}${oem_path}${userId}/folders/${msgFolderkey}
	\    ${obj_resourceURL}=	Set variable	https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey1}%3d%3d%3a${uid}
	\    ${obj_Folderpath}=		Set Variable	/${RCS_PARENT_PATH}/${MSISDN}//${msgFolderkey}%3a${uid}
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['parentFolder']}    ${obj_parentFolder}
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['resourceURL']}    ${obj_resourceURL}
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['path']}    ${obj_Folderpath}
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['correlationId']}    ${CORRELATION_ID}
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['flags']['flag'][0]}    \\${status_msg[0]}    ignore_case=True
    \    Run Keyword and Continue on failure    Run Keyword If    ${len_msg_status} > 1    Should Be Equal    ${data['objectList']['object'][${index}]['flags']['flag'][1]}    \\${status_msg[1]}    ignore_case=True
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['flags']['resourceURL']}    ${obj_resourceURL}/flags
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Charset'][0]}    ${CHAT_CHARSET}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Content-Transfer-Encoding'][0]}    ${CHAT_CONTENT_TRANSFER_ENCODING}
#    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['content-type'][0]}    ${CHAT_CONTENT_TYPE}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Contribution-ID'][0]}    ${CONTRIBUTION_ID}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Conversation-ID'][0]}    ${CONVERSATION_ID}
    \    Run Keyword and Continue on failure    Should Match Regexp    ${Attributes_pair['date'][0]}    [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z    
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Direction'][0]}    ${direction}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['from'][0]}    ${from_msg}
    #\    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['IMDN-Message-ID'][0]}    ${IMDN_MESSAGE_ID}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['message-context'][0]}    ${message_context}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['P-Asserted-Service'][0]}    ${P_ASSERTED_SERVICE}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['textcontent'][0]}    ${CHAT_CONTENT_DATA}
    \    Run Keyword and Continue on failure    Run Keyword If  '${msg_type}' == 'individual'	Should Be Equal    ${Attributes_pair['to'][0]}    ${to_msg}		ELSE	ValidateGroupToMessages		${Attributes_pair['to']}	${to_msg}
	\	Run Keyword and Continue on failure    Run Keyword If    '${imdn_type}' == 'deposit'	Dictionary Should Not Contain Key		${data['objectList']['object'][${index}]}	imdn

    \	${delivered_list}=  Set Variable If     '${imdn_type}' != 'deposit'   ${data['objectList']['object'][${index}]['imdn']['delivered']}
	\   ${read_list}=   Set Variable If     '${imdn_type}' == 'displayed'     ${data['objectList']['object'][${index}]['imdn']['read']}

    \   ${delivered_recipients_uri1}=   Run Keyword If  '${imdn_type}' != 'deposit' and '${msg_type}' == 'group'  Split String    ${delivered_recipients_uri}     ,
    \   ${read_recipients_uri1}=        Run Keyword If  '${imdn_type}' == 'displayed' and '${msg_type}' == 'group'    Split String    ${read_recipients_uri}          ,
    \   log     ${delivered_recipients_uri}
    \   log     ${read_recipients_uri}
    \   log     ${delivered_recipients_uri1}
    \   log     ${read_recipients_uri1}
    \   log     ${delivered_list}
    \   log     ${read_list}

   \	Run Keyword and Continue on failure    Run Keyword If    '${imdn_type}' == 'delivered' and '${msg_type}' == 'group'    ValidateImdnDeliveredDisplayed    ${delivered_recipients_uri}		${delivered_list}   ELSE IF     '${imdn_type}' == 'delivered' and '${msg_type}' != 'group'    Should Be Equal As Strings  ${delivered_list[0]}    ${MSG_TO}

   \	Run Keyword and Continue on failure    Run Keyword If      '${imdn_type}' == 'displayed' and '${msg_type}' == 'group'    ValidateImdnDeliveredDisplayed    ${delivered_recipients_uri}   ${delivered_list}   ELSE IF    '${imdn_type}' == 'displayed' and '${msg_type}' != 'group'  Should Be Equal As Strings    ${delivered_list[0]}    ${MSG_TO}

   \	Run Keyword and Continue on failure     Run Keyword If   '${imdn_type}' == 'displayed' and '${msg_type}' == 'group'   ValidateImdnDeliveredDisplayed    ${read_recipients_uri}   ${read_list}   ELSE IF       '${imdn_type}' == 'displayed' and '${msg_type}' != 'group'   Should Be Equal As Strings    ${read_list[0]}    ${MSG_TO}


ValidateGroupToMessages
	[Arguments]		${response_to_attributes}	${to_members}
	${index}=	Set Variable	0
	:FOR	${member}	IN	@{to_members}
	\	Run Keyword and Continue on Failure		Should Be Equal As Strings		${member}	${response_to_attributes[${index}]}
	\	${index}=	Evaluate	${index} + 1


ValidateChatFolderSearchResponse_along_with_Session_Chat
    [Arguments]     ${response}     ${direction}=${DIRECTION}    ${from}=${MSG_FROM}		${to_msg}=${MSG_TO}		${message_context}=${CHAT_MESSAGE_CONTEXT}    ${msgFolderkey}=${RCS_MESSAGE_FOLDER_KEY}  ${uid}=2    ${msgStatus}=Recent     ${service_root_path}=${OEM_SERVER_ROOT_PATH}    ${oem_path}=${OEM_HOST_URI}     ${userId}=${SUBSCRIBER_ID}   ${no_of_msgs}=2		${session_msg_uid}=1	${session_msg_context}=${CHAT_SESSION_MESSAGE_CONTEXT}	 ${session_msgStatus}=Recent	${session_content_type}=Application/X-CPM-Session	${P_ASSERTED_SERVICE}=${ASSERTED_SERVICE}	${msg_type}=individual	 ${chat_session_asserted_service}=${P_ASSERTED_SERVICE_Chat}	${session_to}=${MSG_TO}		${imdn_type}=deposit        ${read_recipients_uri}=${NONE}  ${delivered_recipients_uri}=${NONE}		 ${multipart}=false	

    ${to}=  Run Keyword If  '${msg_type}' == 'individual'   Create List     ${to_msg}   ELSE    Copy List   ${to_msg}

    ${status_msg}=    Split String    ${msgStatus}    ,
    ${len_msg_status}=    Get Length    ${status_msg}
    log    ${response.headers}
    ${data}=    set Variable    ${response.json()}
    log    ${data}
    ${list_of_objects}=    Get Length    ${data['objectList']['object']}

    ${data}=    Set Variable    ${response.json()}
    log    ${data}
    ${list_of_objects}=    Get Length    ${data['objectList']['object']}

    ${S_resourceURL}=    Set Variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey1}%3d%3d%3a${uid}
    ${S_objectUrl}=    Set Variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey}%3a${session_msg_uid}
    ${S_parentFolder}=    Set Variable    https://${service_root_path}${oem_path}${userId}/folders/${msgFolderkey}
    ${S_Folderpath}=    Set Variable    /${RCS_PARENT_PATH}/${SUBSCRIBER_ID}//${msgFolderkey}%3a${uid}
    ${S_payloadURL}=    Set variable    https://${service_root_path}${oem_path}${userId}/objects/${session_msg_context}/cassandra/${msgFolderkey}%3a${uid}

    ${Attributes_pair}=    Get_FolderSearch_AttributesPair    ${data['objectList']['object'][0]['attributes']['attribute']}
    log    ${Attributes_pair}
    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][0]['parentFolder']}    ${S_parentFolder}
    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][0]['resourceURL']}    ${S_resourceURL}
    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][0]['path']}    ${S_Folderpath}
    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][0]['payloadURL']}    ${S_payloadURL}
    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][0]['flags']['flag'][0]}    \\${session_msgStatus}    ignore_case=True
    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][0]['flags']['resourceURL']}    ${S_resourceURL}/flags
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['content-type'][0]}    ${session_content_type}
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Contribution-ID'][0]}    ${CONTRIBUTION_ID}
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Conversation-ID'][0]}    ${CONVERSATION_ID}
    Run Keyword and Continue on failure    Should Match Regexp    ${Attributes_pair['date'][0]}    [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Direction'][0]}    ${direction}
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['from'][0]}    ${from}
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['message-context'][0]}    ${session_msg_context}
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['P-Asserted-Service'][0]}    ${chat_session_asserted_service}
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['to'][0]}    ${session_to}

    Run Keyword and Continue On Failure     Should Be Equal As Strings  ${list_of_objects}  ${no_of_msgs}
    :FOR    ${index}    IN RANGE    1    ${list_of_objects}
    \    ${Attributes_pair}=    Get_FolderSearch_AttributesPair    ${data['objectList']['object'][${index}]['attributes']['attribute']}
    \    log    ${Attributes_pair}
    \   # ${uid}=    Evaluate    ${index} + 1
    \    ${obj_parentFolder}=   Set Variable    https://${service_root_path}${oem_path}${userId}/folders/${msgFolderkey}
    \    ${obj_resourceURL}=    Set variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey1}%3d%3d%3a${session_msg_uid}
    \    ${obj_Folderpath}=     Set Variable    /${RCS_PARENT_PATH}/${SUBSCRIBER_ID}//${msgFolderkey}%3a${session_msg_uid}
#    \    ${obj_payloadURL}=    Set variable    https://${service_root_path}${oem_path}${userId}/objects/${message_context}${swift_base_url}/${sw_acct_id}/${CONTAINER_INFO['${RCS_PARENT_PATH}']}/[0-9]+%3a${msgFolderkey}%3a${uid}
    #\    Run Keyword and Continue on failure    Should Match Regexp    ${data['objectList']['object'][${index}]['payloadURL']}    ${S_payloadURL}

    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['parentFolder']}    ${obj_parentFolder}
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['resourceURL']}    ${obj_resourceURL}
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['path']}    ${obj_Folderpath}
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['correlationId']}    ${CORRELATION_ID}
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['flags']['flag'][0]}    \\${status_msg[0]}    ignore_case=True
    \    Run Keyword and Continue on failure    Run Keyword If    ${len_msg_status} > 1    Should Be Equal    ${data['objectList']['object'][${index}]['flags']['flag'][1]}    \\${status_msg[1]}    ignore_case=True
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['flags']['resourceURL']}    ${obj_resourceURL}/flags
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Charset'][0]}    ${CHAT_CHARSET}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Content-Transfer-Encoding'][0]}    ${CHAT_CONTENT_TRANSFER_ENCODING}
#    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['content-type'][0]}    ${CHAT_CONTENT_TYPE}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Contribution-ID'][0]}    ${CONTRIBUTION_ID}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Conversation-ID'][0]}    ${CONVERSATION_ID}
    \    Run Keyword and Continue on failure    Should Match Regexp    ${Attributes_pair['date'][0]}    [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Direction'][0]}    ${direction}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['from'][0]}    ${from}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['IMDN-Message-ID'][0]}    ${IMDN_MESSAGE_ID}
 	#  Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['imdn-message-ID'][0]}    ${IMDN_MESSAGE_ID}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['message-context'][0]}    ${message_context}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['P-Asserted-Service'][0]}    ${P_ASSERTED_SERVICE}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['textcontent'][0]}    ${CHAT_CONTENT_DATA}
    \    Run Keyword and Continue on failure    Run Keyword If  '${msg_type}' == 'individual'   Should Be Equal    ${Attributes_pair['to'][0]}    ${to_msg} 	ELSE    ValidateGroupToMessages     ${Attributes_pair['to']}    ${to_msg}
    \   Run Keyword and Continue on failure    Run Keyword If    '${imdn_type}' == 'deposit'    Dictionary Should Not Contain Key       ${data['objectList']['object'][${index}]}   imdn

    \   ${delivered_list}=  Set Variable If     '${imdn_type}' != 'deposit'   ${data['objectList']['object'][${index}]['imdn']['delivered']}
    \   ${read_list}=   Set Variable If     '${imdn_type}' == 'displayed'     ${data['objectList']['object'][${index}]['imdn']['read']}
    \   ${delivered_list}=  Set Variable If     '${imdn_type}' != 'deposit'   ${data['objectList']['object'][${index}]['imdn']['delivered']}
    \   ${read_list}=   Set Variable If     '${imdn_type}' == 'displayed'     ${data['objectList']['object'][${index}]['imdn']['read']}
    \   ${delivered_recipients_uri1}=   Run Keyword If  '${imdn_type}' != 'deposit' and '${msg_type}' == 'group'  Split String    ${delivered_recipients_uri}     ,
    \   ${read_recipients_uri1}=        Run Keyword If  '${imdn_type}' == 'displayed' and '${msg_type}' == 'group'    Split String    ${read_recipients_uri}          ,
    \   log     ${delivered_recipients_uri}
    \   log     ${read_recipients_uri}
    \   log     ${delivered_recipients_uri1}
    \   log     ${read_recipients_uri1}
    \   log     ${delivered_list}
    \   log     ${read_list}
    \   Run Keyword and Continue on failure    Run Keyword If    '${imdn_type}' == 'delivered' and '${msg_type}' == 'group'    ValidateImdnDeliveredDisplayed    ${delivered_recipients_uri1}        ${delivered_list}   ELSE IF     '${imdn_type}' == 'delivered' and '${msg_type}' != 'group'    Should Be Equal As Strings  ${delivered_list[0]}    ${to_msg}

    \   Run Keyword and Continue on failure    Run Keyword If      '${imdn_type}' == 'displayed' and '${msg_type}' == 'group'    ValidateImdnDeliveredDisplayed    ${delivered_recipients_uri1}   ${delivered_list}   ELSE IF    '${imdn_type}' == 'displayed' and '${msg_type}' != 'group'  Should Be Equal As Strings    ${delivered_list[0]}    ${to_msg}

    \   Run Keyword and Continue on failure     Run Keyword If   '${imdn_type}' == 'displayed' and '${msg_type}' == 'group'   ValidateImdnDeliveredDisplayed    ${read_recipients_uri1}   ${read_list}      ELSE IF       '${imdn_type}' == 'displayed' and '${msg_type}' != 'group'   Should Be Equal As Strings    ${read_list[0]}    ${to_msg}
    #\   Run Keyword and Continue on failure     Run Keyword If  '${multipart}' == 'true'    ValidatePayloadMultiPart    ${data['objectList']['object'][${index}]}   ${obj_payloadURL}   ${service_root_path}    ELSE    ValidatePayloadSinglePart   ${data['objectList']['object'][${index}]}   ${S_payloadURL}   ${service_root_path}



#    \   Run Keyword and Continue on failure    Run Keyword If    '${imdn_type}' == 'delivered' and '${msg_type}' == 'group'    ValidateImdnDeliveredDisplayed    ${delivered_recipients_uri}        ${delivered_list}   ELSE IF     '${imdn_type}' == 'delivered' and '${msg_type}' != 'group'    Should Be Equal As Strings  ${delivered_list[0]}    ${to_msg}

 #   \   Run Keyword and Continue on failure    Run Keyword If      '${imdn_type}' == 'displayed' and '${msg_type}' == 'group'    ValidateImdnDeliveredDisplayed    ${delivered_recipients_uri}   ${delivered_list}   ELSE IF    '${imdn_type}' == 'displayed' and '${msg_type}' != 'group'  Should Be Equal As Strings    ${delivered_list[0]}    ${to_msg}

  #  \   Run Keyword and Continue on failure     Run Keyword If   '${imdn_type}' == 'displayed' and '${msg_type}' == 'group'   ValidateImdnDeliveredDisplayed    ${read_recipients_uri}   ${read_list}   ELSE IF       '${imdn_type}' == 'displayed' and '${msg_type}' != 'group'   Should Be Equal As Strings    ${read_list[0]}    ${to_msg}




ValidateChatFolderSearchResponse_along_with_Session_Chat1

    [Arguments]     ${response}     ${direction}=${DIRECTION}    ${from}=${MSG_FROM}        ${to_msg}=${MSG_TO}     ${message_context}=${CHAT_MESSAGE_CONTEXT}    ${msgFolderkey}=${RCS_MESSAGE_FOLDER_KEY}  ${uid}=2    ${msgStatus}=Recent     ${service_root_path}=${OEM_SERVER_ROOT_PATH}    ${oem_path}=${OEM_HOST_URI}     ${userId}=${SUBSCRIBER_ID}   ${no_of_msgs}=2       ${session_msg_uid}=1    ${session_msg_context}=${CHAT_SESSION_MESSAGE_CONTEXT}   ${session_msgStatus}=Recent    ${session_content_type}=Application/X-CPM-Session   ${P_ASSERTED_SERVICE}=${ASSERTED_SERVICE}   ${msg_type}=individual   ${chat_session_asserted_service}=${P_ASSERTED_SERVICE_Chat}    ${session_to}=${MSG_TO}     ${imdn_type}=deposit        ${read_recipients_uri}=${NONE}  ${delivered_recipients_uri}=${NONE}      ${multipart}=false         ${c_uid}=${CREATION_TUIDS}

    ${to}=  Run Keyword If  '${msg_type}' == 'individual'   Create List     ${to_msg}   ELSE    Copy List   ${to_msg}

    ${status_msg}=    Split String    ${msgStatus}    ,
    ${len_msg_status}=    Get Length    ${status_msg}
    log    ${response.headers}
    ${data}=    set Variable    ${response.json()}
    log    ${data}
    ${list_of_objects}=    Get Length    ${data['objectList']['object']}

    ${data}=    Set Variable    ${response.json()}
    log    ${data}
    ${list_of_objects}=    Get Length    ${data['objectList']['object']}

    ${S_resourceURL}=    Set Variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey1}%3d%3d%3a${uid}
    ${S_objectUrl}=    Set Variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey}%3a${session_msg_uid}
    ${S_parentFolder}=    Set Variable    https://${service_root_path}${oem_path}${userId}/folders/${msgFolderkey}
    ${S_Folderpath}=    Set Variable    /${RCS_PARENT_PATH}/${SUBSCRIBER_ID}//${msgFolderkey}%3a${uid}
    ${S_payloadURL}=    Set variable    https://${service_root_path}${oem_path}${userId}/objects/${session_msg_context}/cassandra/${msgFolderkey}%3a${uid}

    ${Attributes_pair}=    Get_FolderSearch_AttributesPair    ${data['objectList']['object'][0]['attributes']['attribute']}
    log    ${Attributes_pair}
    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][0]['parentFolder']}    ${S_parentFolder}
    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][0]['resourceURL']}    ${S_resourceURL}
    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][0]['path']}    ${S_Folderpath}
    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][0]['payloadURL']}    ${S_payloadURL}
    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][0]['flags']['flag'][0]}    \\${session_msgStatus}    ignore_case=True
    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][0]['flags']['resourceURL']}    ${S_resourceURL}/flags
#    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['content-type'][0]}    ${session_content_type}
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Contribution-ID'][0]}    ${CONTRIBUTION_ID}
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Conversation-ID'][0]}    ${CONVERSATION_ID}
    Run Keyword and Continue on failure    Should Match Regexp    ${Attributes_pair['date'][0]}    [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Direction'][0]}    ${direction}
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['from'][0]}    ${from}
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['message-context'][0]}    ${session_msg_context}
     Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['P-Asserted-Service'][0]}    ${chat_session_asserted_service}
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['to'][0]}    ${session_to}

    Run Keyword and Continue On Failure     Should Be Equal As Strings  ${list_of_objects}  ${no_of_msgs}
    :FOR    ${index}    IN RANGE    1    ${list_of_objects}
    \    ${Attributes_pair}=    Get_FolderSearch_AttributesPair    ${data['objectList']['object'][${index}]['attributes']['attribute']}
    \    log    ${Attributes_pair}
    \   # ${uid}=    Evaluate    ${index} + 1
    \    ${uid_index}=      Evaluate    ${index} + 1
    \    ${session_msg_uid}=    Set Variable    ${c_uid['${uid_index}']}
    \    ${obj_parentFolder}=   Set Variable    https://${service_root_path}${oem_path}${userId}/folders/${msgFolderkey}
    \    ${obj_resourceURL}=    Set variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey1}%3d%3d%3a${session_msg_uid}
    \    ${obj_Folderpath}=     Set Variable    /${RCS_PARENT_PATH}/${SUBSCRIBER_ID}//${msgFolderkey}%3a${session_msg_uid}

    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['parentFolder']}    ${obj_parentFolder}
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['resourceURL']}    ${obj_resourceURL}
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['path']}    ${obj_Folderpath}
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['correlationId']}    ${CORRELATION_ID}
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['flags']['flag'][0]}    \\${status_msg[0]}    ignore_case=True
    \    Run Keyword and Continue on failure    Run Keyword If    ${len_msg_status} > 1    Should Be Equal    ${data['objectList']['object'][${index}]['flags']['flag'][1]}    \\${status_msg[1]}    ignore_case=True
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['flags']['resourceURL']}    ${obj_resourceURL}/flags
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Charset'][0]}    ${CHAT_CHARSET}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Content-Transfer-Encoding'][0]}    ${CHAT_CONTENT_TRANSFER_ENCODING}
#    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['content-type'][0]}    ${CHAT_CONTENT_TYPE}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Contribution-ID'][0]}    ${CONTRIBUTION_ID}
     \   log     ${read_recipients_uri1}
    \   log     ${delivered_list}
    \   log     ${read_list}
    \   Run Keyword and Continue on failure    Run Keyword If    '${imdn_type}' == 'delivered' and '${msg_type}' == 'group'    ValidateImdnDeliveredDisplayed    ${delivered_recipients_uri1}        ${delivered_list}   ELSE IF     '${imdn_type}' == 'delivered' and '${msg_type}' != 'group'    Should Be Equal As Strings  ${delivered_list[0]}    ${to_msg}

    \   Run Keyword and Continue on failure    Run Keyword If      '${imdn_type}' == 'displayed' and '${msg_type}' == 'group'    ValidateImdnDeliveredDisplayed    ${delivered_recipients_uri1}   ${delivered_list}   ELSE IF    '${imdn_type}' == 'displayed' and '${msg_type}' != 'group'  Should Be Equal As Strings    ${delivered_list[0]}    ${to_msg}

    \   Run Keyword and Continue on failure     Run Keyword If   '${imdn_type}' == 'displayed' and '${msg_type}' == 'group'   ValidateImdnDeliveredDisplayed    ${read_recipients_uri1}   ${read_list}      ELSE IF       '${imdn_type}' == 'displayed' and '${msg_type} \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Conversation-ID'][0]}    ${CONVERSATION_ID}
    \    Run Keyword and Continue on failure    Should Match Regexp    ${Attributes_pair['date'][0]}    [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Direction'][0]}    ${direction}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['from'][0]}    ${from}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['IMDN-Message-ID'][0]}    ${IMDN_MESSAGE_ID}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['message-context'][0]}    ${message_context}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['P-Asserted-Service'][0]}    ${P_ASSERTED_SERVICE}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['textcontent'][0]}    ${CHAT_CONTENT_DATA}
    \    Run Keyword and Continue on failure    Run Keyword If  '${msg_type}' == 'individual'   Should Be Equal    ${Attributes_pair['to'][0]}    ${to_msg}     ELSE    ValidateGroupToMessages     ${Attributes_pair['to']}    ${to_msg}
    \   Run Keyword and Continue on failure    Run Keyword If    '${imdn_type}' == 'deposit'    Dictionary Should Not Contain Key       ${data['objectList']['object'][${index}]}   imdn

    \   ${delivered_list}=  Set Variable If     '${imdn_type}' != 'deposit'   ${data['objectList']['object'][${index}]['imdn']['delivered']}
    \   ${read_list}=   Set Variable If     '${imdn_type}' == 'displayed'     ${data['objectList']['object'][${index}]['imdn']['read']}
    \   ${delivered_list}=  Set Variable If     '${imdn_type}' != 'deposit'   ${data['objectList']['object'][${index}]['imdn']['delivered']}
    \   ${read_list}=   Set Variable If     '${imdn_type}' == 'displayed'     ${data['objectList']['object'][${index}]['imdn']['read']}
    \   ${delivered_recipients_uri1}=   Run Keyword If  '${imdn_type}' != 'deposit' and '${msg_type}' == 'group'  Split String    ${delivered_recipients_uri}     ,
    \   ${read_recipients_uri1}=        Run Keyword If  '${imdn_type}' == 'displayed' and '${msg_type}' == 'group'    Split String    ${read_recipients_uri}          ,
    \   log     ${delivered_recipients_uri}
    \   log     ${read_recipients_uri}
    \   log     ${delivered_recipients_uri1}
    \   log     ${read_recipients_uri1}
    \   log     ${delivered_list}
    \   log     ${read_list}
    \   Run Keyword and Continue on failure    Run Keyword If    '${imdn_type}' == 'delivered' and '${msg_type}' == 'group'    ValidateImdnDeliveredDisplayed    ${delivered_recipients_uri1}        ${delivered_list}   ELSE IF     '${imdn_type}' == 'delivered' and '${msg_type}' != 'group'    Should Be Equal As Strings  ${delivered_list[0]}    ${to_msg}

    \   Run Keyword and Continue on failure    Run Keyword If      '${imdn_type}' == 'displayed' and '${msg_type}' == 'group'    ValidateImdnDeliveredDisplayed    ${delivered_recipients_uri1}   ${delivered_list}   ELSE IF    '${imdn_type}' == 'displayed' and '${msg_type}' != 'group'  Should Be Equal As Strings    ${delivered_list[0]}    ${to_msg}

    \   Run Keyword and Continue on failure     Run Keyword If   '${imdn_type}' == 'displayed' and '${msg_type}' == 'group'   ValidateImdnDeliveredDisplayed    ${read_recipients_uri1}   ${read_list}      ELSE IF       '${imdn_type}' == 'displayed' and '${msg_type}' != 'group'   Should Be Equal As Strings    ${read_list[0]}    ${to_msg}



ValidateChatFolderSearchResponse_along_with_Session_Chat2

    [Arguments]     ${response}     ${direction}=${DIRECTION}    ${from}=${MSG_FROM}        ${to_msg}=${MSG_TO}     ${message_context}=${CHAT_MESSAGE_CONTEXT}    ${msgFolderkey}=${RCS_MESSAGE_FOLDER_KEY}  ${uid}=2    ${msgStatus}=Recent     ${service_root_path}=${OEM_SERVER_ROOT_PATH}    ${oem_path}=${OEM_HOST_URI}     ${userId}=${SUBSCRIBER_ID}   ${no_of_msgs}=2       ${session_msg_uid}=1    ${session_msg_context}=${CHAT_SESSION_MESSAGE_CONTEXT}   ${session_msgStatus}=Recent    ${session_content_type}=Application/X-CPM-Session   ${P_ASSERTED_SERVICE}=${ASSERTED_SERVICE}   ${msg_type}=individual   ${chat_session_asserted_service}=${P_ASSERTED_SERVICE_Chat}    ${session_to}=${MSG_TO}     ${imdn_type}=deposit        ${read_recipients_uri}=${NONE}  ${delivered_recipients_uri}=${NONE}      ${multipart}=false			${c_uid}=${CREATION_TUIDS}

    ${to}=  Run Keyword If  '${msg_type}' == 'individual'   Create List     ${to_msg}   ELSE    Copy List   ${to_msg}

    ${status_msg}=    Split String    ${msgStatus}    ,
    ${len_msg_status}=    Get Length    ${status_msg}
    log    ${response.headers}
    ${data}=    set Variable    ${response.json()}
    log    ${data}
    ${list_of_objects}=    Get Length    ${data['objectList']['object']}

    ${data}=    Set Variable    ${response.json()}
    log    ${data}
    ${list_of_objects}=    Get Length    ${data['objectList']['object']}

    ${S_resourceURL}=    Set Variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey1}%3d%3d%3a${uid}
    ${S_objectUrl}=    Set Variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey}%3a${session_msg_uid}
    ${S_parentFolder}=    Set Variable    https://${service_root_path}${oem_path}${userId}/folders/${msgFolderkey}
    ${S_Folderpath}=    Set Variable    /${RCS_PARENT_PATH}/${SUBSCRIBER_ID}//${msgFolderkey}%3a${uid}
    ${S_payloadURL}=    Set variable    https://${service_root_path}${oem_path}${userId}/objects/${session_msg_context}/cassandra/${msgFolderkey}%3a${uid}

    ${Attributes_pair}=    Get_FolderSearch_AttributesPair    ${data['objectList']['object'][0]['attributes']['attribute']}
    log    ${Attributes_pair}
    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][0]['parentFolder']}    ${S_parentFolder}
    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][0]['resourceURL']}    ${S_resourceURL}
    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][0]['path']}    ${S_Folderpath}
    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][0]['payloadURL']}    ${S_payloadURL}
    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][0]['flags']['flag'][0]}    \\${session_msgStatus}    ignore_case=True
    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][0]['flags']['resourceURL']}    ${S_resourceURL}/flags
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['content-type'][0]}    ${session_content_type}
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Contribution-ID'][0]}    ${CONTRIBUTION_ID}
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Conversation-ID'][0]}    ${CONVERSATION_ID}
    Run Keyword and Continue on failure    Should Match Regexp    ${Attributes_pair['date'][0]}    [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Direction'][0]}    ${direction}
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['from'][0]}    ${from}
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['message-context'][0]}    ${session_msg_context}
	 Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['P-Asserted-Service'][0]}    ${chat_session_asserted_service}
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['to'][0]}    ${session_to}

    Run Keyword and Continue On Failure     Should Be Equal As Strings  ${list_of_objects}  ${no_of_msgs}
    :FOR    ${index}    IN RANGE    1    ${list_of_objects}
    \    ${Attributes_pair}=    Get_FolderSearch_AttributesPair    ${data['objectList']['object'][${index}]['attributes']['attribute']}
    \    log    ${Attributes_pair}
    \   # ${uid}=    Evaluate    ${index} + 1
	\    ${uid_index}=      Evaluate    ${index} + 1
    \	 ${session_msg_uid}=    Set Variable    ${c_uid['${uid_index}']}
    \    ${obj_parentFolder}=   Set Variable    https://${service_root_path}${oem_path}${userId}/folders/${msgFolderkey}
    \    ${obj_resourceURL}=    Set variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey1}%3d%3d%3a${session_msg_uid}
    \    ${obj_Folderpath}=     Set Variable    /${RCS_PARENT_PATH}/${SUBSCRIBER_ID}//${msgFolderkey}%3a${session_msg_uid}

    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['parentFolder']}    ${obj_parentFolder}
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['resourceURL']}    ${obj_resourceURL}
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['path']}    ${obj_Folderpath}
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['correlationId']}    ${CORRELATION_ID}
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['flags']['flag'][0]}    \\${status_msg[0]}    ignore_case=True
    \    Run Keyword and Continue on failure    Run Keyword If    ${len_msg_status} > 1    Should Be Equal    ${data['objectList']['object'][${index}]['flags']['flag'][1]}    \\${status_msg[1]}    ignore_case=True
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['flags']['resourceURL']}    ${obj_resourceURL}/flags
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Charset'][0]}    ${CHAT_CHARSET}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Content-Transfer-Encoding'][0]}    ${CHAT_CONTENT_TRANSFER_ENCODING}
#    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['content-type'][0]}    ${CHAT_CONTENT_TYPE}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Contribution-ID'][0]}    ${CONTRIBUTION_ID}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Conversation-ID'][0]}    ${CONVERSATION_ID}
    \    Run Keyword and Continue on failure    Should Match Regexp    ${Attributes_pair['date'][0]}    [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Direction'][0]}    ${direction}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['from'][0]}    ${from}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['IMDN-Message-ID'][0]}    ${IMDN_MESSAGE_ID}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['message-context'][0]}    ${message_context}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['P-Asserted-Service'][0]}    ${P_ASSERTED_SERVICE}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['textcontent'][0]}    ${CHAT_CONTENT_DATA}
    \    Run Keyword and Continue on failure    Run Keyword If  '${msg_type}' == 'individual'   Should Be Equal    ${Attributes_pair['to'][0]}    ${to_msg}     ELSE    ValidateGroupToMessages     ${Attributes_pair['to']}    ${to_msg}
    \   Run Keyword and Continue on failure    Run Keyword If    '${imdn_type}' == 'deposit'    Dictionary Should Not Contain Key       ${data['objectList']['object'][${index}]}   imdn

    \   ${delivered_list}=  Set Variable If     '${imdn_type}' != 'deposit'   ${data['objectList']['object'][${index}]['imdn']['delivered']}
    \   ${read_list}=   Set Variable If     '${imdn_type}' == 'displayed'     ${data['objectList']['object'][${index}]['imdn']['read']}
    \   ${delivered_list}=  Set Variable If     '${imdn_type}' != 'deposit'   ${data['objectList']['object'][${index}]['imdn']['delivered']}
    \   ${read_list}=   Set Variable If     '${imdn_type}' == 'displayed'     ${data['objectList']['object'][${index}]['imdn']['read']}
    \   ${delivered_recipients_uri1}=   Run Keyword If  '${imdn_type}' != 'deposit' and '${msg_type}' == 'group'  Split String    ${delivered_recipients_uri}     ,
    \   ${read_recipients_uri1}=        Run Keyword If  '${imdn_type}' == 'displayed' and '${msg_type}' == 'group'    Split String    ${read_recipients_uri}          ,
    \   log     ${delivered_recipients_uri}
    \   log     ${read_recipients_uri}
    \   log     ${delivered_recipients_uri1}
    \   log     ${read_recipients_uri1}
    \   log     ${delivered_list}
    \   log     ${read_list}
    \   Run Keyword and Continue on failure    Run Keyword If    '${imdn_type}' == 'delivered' and '${msg_type}' == 'group'    ValidateImdnDeliveredDisplayed    ${delivered_recipients_uri1}        ${delivered_list}   ELSE IF     '${imdn_type}' == 'delivered' and '${msg_type}' != 'group'    Should Be Equal As Strings  ${delivered_list[0]}    ${to_msg}

    \   Run Keyword and Continue on failure    Run Keyword If      '${imdn_type}' == 'displayed' and '${msg_type}' == 'group'    ValidateImdnDeliveredDisplayed    ${delivered_recipients_uri1}   ${delivered_list}   ELSE IF    '${imdn_type}' == 'displayed' and '${msg_type}' != 'group'  Should Be Equal As Strings    ${delivered_list[0]}    ${to_msg}

    \   Run Keyword and Continue on failure     Run Keyword If   '${imdn_type}' == 'displayed' and '${msg_type}' == 'group'   ValidateImdnDeliveredDisplayed    ${read_recipients_uri1}   ${read_list}      ELSE IF       '${imdn_type}' == 'displayed' and '${msg_type}' != 'group'   Should Be Equal As Strings    ${read_list[0]}    ${to_msg}






Get_FolderSearch_AttributesPair
    [Arguments]    ${data}
    ${attributes}=    Set Variable    ${data}
    ${Attributes_pair}=    Create Dictionary
    :FOR    ${pair}    IN    @{attributes}
    \    log    ${pair['name']}
    \    log    ${pair['value']}
    \    Set To Dictionary    ${Attributes_pair}    ${pair['name']}    ${pair['value']}
    [Return]    ${Attributes_pair}

CreateSessionForChatFT
    [Arguments]     ${UserId}=${SUBSCRIBER_ID}  ${headers}=${OEM_DEPOSIT_HEADERS}   ${url}=${RCS_HOST_URI}  ${object_file}=${CHAT_SESSION_OBJ_FILE}  ${MESSAGE_CONTEXT}=${MESSAGE_CONTEXT}
    ...     ${DIRECTION_VALUE}=${DIRECTION}   ${mStore_request_session}=${MSTORE_SESSION_NAME}		${P_ASSERTED_SERVICE}=${ASSERTED_SERVICE}

    ${data}=    OperatingSystem.Get Binary File    ${CURDIR}/../testfiles/${object_file}
    ${data} =    Replace Variables    ${data}
    log    ${data}
	log		${SUBSCRIBER_ID}
	log		${UserId}
	log		${url}
    ${response}=    RequestsLibrary.Post Request    alias=${mStore_request_session}    uri=${url}${UserId}/objects    data=${data}    headers=${headers}

    ${response_status_code}=    Convert to String    ${response.status_code}
    log    ${response.status_code}
    log    ${response.text}
    log    ${response.headers}
    Should Be Equal    ${response_status_code}    201    msg="deliver pm msg is not success,which has repose ${response.status_code}"
    [Return]    ${response}


Deposit_Message
	[Arguments]		${UserId}=${SUBSCRIBER_ID}	${headers}=${OEM_DEPOSIT_HEADERS}	${url}=${RCS_HOST_URI}	${object_file}=${PM_CHAT_DEPOSIT_OBJ_FILE}		${MESSAGE_CONTEXT}=${MESSAGE_CONTEXT}
	...		${DIRECTION_VALUE}=${DIRECTION}		${X_RCS_MSG_STATUS}=Delivered		${mStore_request_session}=${MSTORE_SESSION_NAME}	${P_ASSERTED_SERVICE}=${ASSERTED_SERVICE}	${MSG_FROM}=${MSG_FROM}		${MSG_TO}=${MSG_TO}	

	${NOTIFICATION_METHOD}=		Set Variable If		'${X_RCS_MSG_STATUS}' == 'Delivered'	delivery	display
	${data}=    OperatingSystem.Get Binary File    ${CURDIR}/../testfiles/${object_file}
    ${data} =    Replace Variables    ${data}
    log    ${data}
	${payload_length}=	Get Length    ${data}
    log		${payload_length}
	set suite variable    ${payload_length}
    ${response}=    RequestsLibrary.Post Request    alias=${mStore_request_session}    uri=${url}${UserId}/objects    data=${data}    headers=${headers}

    ${response_status_code}=    Convert to String    ${response.status_code}
    log    ${response.status_code}
    log    ${response.text}
    log    ${response.headers}
    Should Be Equal    ${response_status_code}    201    msg="deliver pm msg is not success,which has repose ${response.status_code}"
    [Return]    ${response}

#Deposit_CallLog
#	[Arguments]     ${UserId}=${SUBSCRIBER_ID}		${headers}=${OEM_DEPOSIT_HEADERS}	${url}=${HOST_NMS_URI}	${object_file}=${CALLHISTORY_DEPOSIT_OBJ_FILE}	 ${MESSAGE_CONTEXT}=${MESSAGE_CONTEXT}
#	...		${DIRECTION_VALUE}=${DIRECTION}		${mStore_request_session}=${MSTORE_SESSION_NAME}	${MSG_FROM}=${MSG_FROM}     ${MSG_TO}=${MSG_TO}

FetchMessageObject
    [Arguments]    ${ResourceURI}=${OBJECT_URL}    ${service_root_path}=${OEM_SERVER_ROOT_PATH}   ${headers}=${OEM_FETCH_HEADERS}		${mStore_request_session}=${MSTORE_SESSION_NAME} 
    ${uri}=    Replace String    ${ResourceURI}    https://${service_root_path}/    ${EMPTY}
    ${response}=    Get Request    alias=${mStore_request_session}    uri=${uri}    headers=${headers}
    log    ${response.status_code}
    log    ${response.text}
    log    ${response.headers}
    ${response_status_code}=    Convert to String    ${response.status_code}
    Should Be Equal    ${response_status_code}    200
    [Return]    ${response}

ValidateChatFetchResponse
    [Arguments]    ${response}    ${direction}=Out    ${msgFolderkey}=${RCS_MESSAGE_FOLDER_KEY}    ${msgStatus}=RECENT    ${From}=${MSG_FROM}    ${to_msg}=${MSG_TO}	${uid}=1	${service_root_path}=${OEM_SERVER_ROOT_PATH}	${userId}=${SUBSCRIBER_ID}    ${oem_path}=${OEM_HOST_URI}	${msg_context}=${MESSAGE_CONTEXT}	${folder_Path}=${CHAT_PARENT_FOLDER_PATH}		${P_ASSERTED_SERVICE}=${ASSERTED_SERVICE}	${msg_type}=individual		${FROM_MSISDN}=${FROM_MSISDN}
    ${to}=  Run Keyword If  '${msg_type}' == 'individual'   Create List     ${to_msg}   ELSE    Copy List   ${to_msg}
    ${obj_resourceURL}=    Set Variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey1}%3d%3d%3a${uid}
    ${obj_objectUrl}=    Set Variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey}%3a${uid}
    ${obj_parentFolder}=    Set Variable    https://${service_root_path}${oem_path}${userId}/folders/${msgFolderkey}
    ${obj_Folderpath}=    Set Variable    /${folder_Path}/${FROM_MSISDN}//${msgFolderkey}%3a${uid}
    ${status_msg}=    Split String    ${msgStatus}    ,
    ${len_msg_status}=    Get Length    ${status_msg}

    ${data}=    Set Variable    ${response.json()}
    log    ${data}
    ${attributes}=    Set Variable    ${data['object']['attributes']['attribute']}

    ${Attributes_pair}=    Create Dictionary
    :FOR    ${pair}    IN    @{attributes}
    \    log    ${pair['name']}
    \    log    ${pair['value']}
    \    Set To Dictionary    ${Attributes_pair}    ${pair['name']}    ${pair['value']}    
    log    ${Attributes_pair}
    Run Keyword and Continue on failure    Should Be Equal    ${data['object']['parentFolder']}    ${obj_parentFolder}
    Run Keyword and Continue on failure    Should Be Equal    ${data['object']['resourceURL']}    ${obj_resourceURL}
    Run Keyword and Continue on failure    Should Be Equal    ${data['object']['path']}    ${obj_Folderpath}
    Run Keyword and Continue on failure    Should Be Equal    ${data['object']['correlationId']}    ${CORRELATION_ID}
    Run Keyword and Continue on failure    Should Be Equal    ${data['object']['flags']['flag'][0]}    \\${status_msg[0]}    ignore_case=True
    Run Keyword and Continue on failure    Run Keyword If    ${len_msg_status} > 1    Should Be Equal    ${data['object']['flags']['flag'][1]}    \\${status_msg[1]}    ignore_case=True
    Run Keyword and Continue on failure    Should Be Equal    ${data['object']['flags']['resourceURL']}    ${obj_resourceURL}/flags
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Charset'][0]}    ${CHAT_CHARSET}
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Content-Transfer-Encoding'][0]}    ${CHAT_CONTENT_TRANSFER_ENCODING}
#    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['content-type'][0]}    ${CHAT_CONTENT_TYPE}
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Contribution-ID'][0]}    ${CONTRIBUTION_ID}
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Conversation-ID'][0]}    ${CONVERSATION_ID}
    Run Keyword and Continue on failure    Should Match Regexp    ${Attributes_pair['date'][0]}    [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Direction'][0]}    ${direction}
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['from'][0]}    ${From}
#    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['IMDN-Message-ID'][0]}    ${IMDN_MESSAGE_ID}
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['message-context'][0]}    ${msg_context}
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['P-Asserted-Service'][0]}    ${P_ASSERTED_SERVICE}
#    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['textcontent'][0]}    ${CHAT_CONTENT_DATA}
    Run Keyword and Continue on failure    Run Keyword If  '${msg_type}' == 'individual'   Should Be Equal    ${Attributes_pair['to'][0]}    ${to_msg}    ELSE    ValidateGroupToMessages     ${Attributes_pair['to']}    ${to_msg}


UpdateFlagToMessageRECENT
	[Arguments]    ${flag}=Seen   ${ResourceURI}=${OBJECT_URL}   ${headers}=${OEM_FETCH_HEADERS}     ${mStore_request_session}=${MSTORE_SESSION_NAME}
	${uri}=     Set Variable    ${ResourceURI}
    ${response}=    Delete Request    alias=${mStore_request_session}    uri=${uri}/flags/%5C${flag}   headers=${headers}
    log    ${response.status_code}
    log    ${response.text}
    log    ${response.headers}
    ${response_status_code}=    Convert to String    ${response.status_code}
    Should Be Equal    ${response_status_code}    201
    [Return]    ${response}

UpdateFlagToMessage
    [Arguments]    ${flag}=Recent    ${ResourceURI}=${OBJECT_URL}  	${headers}=${OEM_FETCH_HEADERS}		${mStore_request_session}=${MSTORE_SESSION_NAME}
    #${uri}=    Replace String    ${ResourceURI}    https://${service_root_path}/    ${EMPTY}
    ${uri}=		Set Variable	${ResourceURI}
    ${response}=    Put Request    alias=${mStore_request_session}    uri=${uri}/flags/%5C${flag}	headers=${headers}
    log    ${response.status_code}
    log    ${response.text}
    log    ${response.headers}
    ${response_status_code}=    Convert to String    ${response.status_code}
    Should Be Equal    ${response_status_code}    201
    [Return]    ${response}

DeleteMsgObject
    [Arguments]    ${ResourceURI}=${OBJECT_URL}    ${response_code}=204   	${headers}=${OEM_FETCH_HEADERS}		${mStore_request_session}=${MSTORE_SESSION_NAME}	${scheme}=https
    #${uri}=    Replace String    ${ResourceURI}    ${scheme}://${service_root_path}/    ${EMPTY}
    ${uri}=     Set Variable    ${ResourceURI}
    ${response}=    Delete Request    alias=${mStore_request_session}    uri=${uri}	headers=${headers}
    ${status_code}=    Convert to String    ${response.status_code}
    log    ${response.status_code}
    log    ${response.text}
    log    ${response.headers}
    Should Be Equal    ${response_code}    ${status_code}
    [Return]    ${response}


ValidateChatDeletePNSNotfn
	[Arguments]     ${pns_headers}   ${pns_body}   ${userId}=${SUBSCRIBER_ID}    ${direction}=Out   ${msgStatus}=RECENT    ${sender}=${MSG_FROM}    ${recipients_uri}=${MSG_TO}    ${push_recipients_uri}=${recipients_uri}  ${uid}=1   ${pns_subtype}=Chat   ${service_root_path}=${OEM_SERVER_ROOT_PATH}    ${oem_path}=${OEM_HOST_URI}    ${parentfolderkey}=${RCS_PARENT_FOLDER_KEY}   ${msgFolderkey}=${RCS_MESSAGE_FOLDER_KEY}	${notification_type}=pns		${PNS_TYPE}=${PNS_TYPE}		${msg_type}=individual		${group_members}=${MSG_TO_GROUP_MEMBERS}		${store}=${CHAT_PARENT_FOLDER_PATH}/${TO_MSISDN}/

    log		${pns_headers}
    log		${pns_body}
    ${pns_resource_url}=    Set Variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey}%3a${uid}
    ${pns_object_Url}=    Set Variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey}%3a${uid}
    ${pns_parentFolder}=    Set Variable    https://${service_root_path}${oem_path}${userId}/folders/${msgFolderkey}
    ${json_data}=    Set Variable    ${pns_body}
    ${json_data}=    Replace String    ${json_data}    \\    ${EMPTY}
    ${json_out}=    Evaluate    json.loads('''${json_data}''',strict=False)    json
    log    ${json_out}
	${len_response_body} =  Get Length  ${pns_body}
    Run Keyword and Continue on failure    Run Keyword If	'${notification_type}' == 'pns'		Should Be Equal As Strings    ${pns_headers['host']}    ${PNS_SERVER_NAME}:${PNS_SERVICE_PORT}
    Run Keyword and Continue on failure    Run Keyword If   '${notification_type}' == 'nms'     Should Be Equal As Strings    ${pns_headers['host']}    ${NMS_SERVER_NAME}:${NMS_SERVICE_PORT}  
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${pns_headers['content-type']}    ${PNS_RESPONSE_CONTENT_TYPE}
    Run Keyword and Continue on failure    Run Keyword If   '${notification_type}' == 'pns'     Should Be Equal As Strings    ${pns_headers['authorization']}    Basic ${PNS_AUTHORIZATION}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${pns_headers['content-length']}    ${len_response_body}
    Run Keyword and Ignore Error    Run Keyword and Continue on Failure    Should Match Regexp    ${pns_headers['X-mStoreFE-Addr']}    FEname:${FE_NAME}-nodeId:${NODE_ID}-ConnId:[a-zA-Z0-9]+-slot:${SLOT_ID}-instId:[0-9]+-subOid:[0-9]+-time:[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z-localFqdn:${LOCAL_FQDN}

    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['serviceName']}    ${PNS_SERVICE_NAME}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['TTL']}    ${PNS_TTL}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['recipients'][0]['uri']}    ${push_recipients_uri}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['channel']}       ${PNS_CHANNEL}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['pns-type']}    ${PNS_TYPE}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['pns-subtype']}    ${pns_subtype}

    Run Keyword and Continue on failure    Should Be Equal    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['resourceURL']}    ${pns_resource_url}
    #Run Keyword and Continue on failure    Should Be Equal    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['correlationId']}    ${CORRELATION_ID}
#    Run Keyword and Continue on failure    Should Match Regexp    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['id']}    ${uid}
    Run Keyword and Continue on failure    Should Be Equal    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['store']}    ${store}
    Run Keyword and Continue on failure    Should Be Equal    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['objectURL']}    ${pns_object_Url}
    Run Keyword and Continue on failure    Should Be Equal    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['direction']}    ${direction}
    Run Keyword and Continue on failure    Should Match Regexp    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['message-time']}    [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]{3}-[0-9]{2}:[0-9]{2}
    Run Keyword and Continue on failure    Should Be Equal    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['status']}    ${msgStatus}
    Run Keyword and Continue on failure    Should Be Equal    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['sender']}    ${sender}
    Run Keyword and Continue on failure    Run Keyword If   '${msg_type}' == 'group'    ValidateGroupRecepients     ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['recipients']}    ${group_members}    ELSE    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['recipients'][0]['uri']}    ${recipients_uri}
   Run Keyword and Continue on failure    Should Be Equal    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['imdn-message-id']}    ${IMDN_MESSAGE_ID}

NMSNotificationSubscription
    [Arguments]    ${userid}=${SUBSCRIBER_ID}	${nms_server}=${NMS_SERVER}		${nms_Service_port}=${NMS_SERVICE_PORT}   ${header}=application/json   ${uri}=${OEM_HOST_URI}${userid}/subscriptions    ${response_code}=201		${mStore_request_session}=${MSTORE_SESSION_NAME}
    Run    cp ${CURDIR}/../testfiles/NMSNotificationSubscription.json /tmp/NMSNotificationSubscription.json
    Run    sed -i 's/NMS_SERVER_IP:NMS_SERVICE_PORT/${nms_server}:${nms_Service_port}/' /tmp/NMSNotificationSubscription.json
    Run    sed -i 's/DURATION/${nms_duration}/' /tmp/NMSNotificationSubscription.json
    Run    sed -i 's/CLIENTCORRELATOR/${nms_client_correlator}/' /tmp/NMSNotificationSubscription.json
    ${data}=    OperatingSystem.Get File    ${CURDIR}/../testfiles/NMSNotificationSubscription.json
	log		${data}
	${data}=	Replace variables	${data}
	log		${data}
    &{files}=    Create Dictionary    file=${data}
    ${headers}=    Create Dictionary    Content-Type=${header}    Accept=${EMPTY}
    ${response}=    RequestsLibrary.Post Request    alias=${mStore_request_session}    uri=${uri}    data=${data}    headers=${headers}
    log    ${response.status_code}
    log    ${response.text}
    log    ${response.headers}
    ${response_code}=    Convert to Integer    ${response_code}
    Should Be Equal    ${response.status_code}    ${response_code}
    [Return]    ${response}

ValidateNMSSubscriptionResponse
    [Arguments]    ${response}    ${userid}=${SUBSCRIBER_ID}    ${nms_server}=${NMS_SERVER}    ${nms_Service_port}=${NMS_SERVICE_PORT}    ${nms_duration}=${NMS_SUBSCRIPTION_DURATION}    ${nms_client_correlator}=${NMS_CLIENT_CORRELATOR}    ${oem_client_uri}=${OEM_HOST_URI}    ${server_root_path}=${WRG_SERVER_ROOT_PATH}

    ${response_text}=    Set Variable    ${response.text}
    ${response_text}=    Evaluate    json.loads('''${response_text}''')    json

    ${SubscriptionId}=    Replace String    ${response_text['nmsSubscription']['resourceURL']}    http://${server_root_path}${oem_client_uri}${userid}/subscriptions/    ${EMPTY}
    ${restartToken}=    Convert to String    ${response_text['nmsSubscription']['restartToken']}
	Set Suite Variable		 ${NMS_RESTART_TOKEN}	${restartToken}
    
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${response_text['nmsSubscription']['callbackReference']['notifyURL']}    http://${nms_server}:${nms_Service_port}/nms/subscription/88889
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${response_text['nmsSubscription']['duration']}    ${nms_duration}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${response_text['nmsSubscription']['clientCorrelator']}    ${nms_client_correlator}
    Run Keyword and Continue on Failure    Should Match Regexp    ${restartToken}    [0-9]+
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${response_text['nmsSubscription']['index']}    0
    Run Keyword and Continue on Failure    Should Match Regexp    ${response_text['nmsSubscription']['resourceURL']}    http://${server_root_path}${oem_client_uri}${userid}/subscriptions/[A-Za-z0-9\-]+

    [Return]    ${SubscriptionId}

ValidateNMSSubscriptionTables
    [Arguments]    ${nms_SubscriptionId}    ${userid}=${USERID}    ${nms_server}=${NMS_SERVER}    ${nms_Service_port}=${NMS_SERVICE_PORT}    ${nms_duration}=${NMS_SUBSCRIPTION_DURATION}    ${nms_client_correlator}=${NMS_CLIENT_CORRELATOR}
    ${notifyurl}=    Set Variable    http://${nms_server}:${nms_Service_port}/nms/subscription/88889
    Switch Connection    cass_db
    Write    SELECT json * FROM nms_subscriptions_mapping where userid = '${userId}' AND subscriptionid=${nms_SubscriptionId} ALLOW FILTERING ; 
    ${nms_subscription_mapping_data}=    Read Until    \>
    Should Contain    ${nms_subscription_mapping_data}    1 rows
    ${nms_subscription_mapping_data}=    Get Lines Containing String    ${nms_subscription_mapping_data}    notifyurl
    ${nms_subscription_mapping_data}=    Evaluate    json.loads('''${nms_subscription_mapping_data}''')    json
    log    ${nms_subscription_mapping_data}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${nms_subscription_mapping_data['notifyurl']}    ${notifyurl}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${nms_subscription_mapping_data['subscriptionid']}    ${nms_SubscriptionId}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${nms_subscription_mapping_data['clientcorrelator']}    ${nms_client_correlator}

    Write    SELECT json ttl(clientcorrelator),ttl(notifyurl) from nms_subscriptions_mapping where userid = '${userId}' AND subscriptionid=${nms_SubscriptionId};
    ${ttl_nms_subscriptions_mapping}=    Read Until    \>
    ${ttl_nms_subscriptions_mapping}=    Get Lines Containing String    ${ttl_nms_subscriptions_mapping}    \{"
    ${ttl_nms_subscriptions_mapping}=    Evaluate    json.loads('''${ttl_nms_subscriptions_mapping}''')    json
    Run Keyword and Continue on Failure		Should Be Equal    ${ttl_nms_subscriptions_mapping['ttl(clientcorrelator)']}    ${ttl_nms_subscriptions_mapping['ttl(notifyurl)']}
    Evaluate    ${ttl_nms_subscriptions_mapping['ttl(clientcorrelator)']} < ${nms_duration}


BulkUpdate
    [Arguments]    ${objfile}=BulkUpdate.json    ${ListresourceURls}=${LIST_OF_RESOURCEURLS}    ${flag}=Recent  ${headers}=${OEM_BULK_UPDATE_HEADERS}    ${response_code}=200	${userId}=${SUBSCRIBER_ID} 		${mStore_request_session}=${MSTORE_SESSION_NAME}
    ${Objecturl}=    Set Variable    ${EMPTY}
    :FOR    ${url}    IN    @{ListresourceURls}
    \    ${Objecturl}=    Set Variable    ${Objecturl}{ "resourceURL" : "${url}" },
    ${Objecturl}=    Set Variable    ${Objecturl[:-1]}
    #${Objecturl}=    Replace String    ${Objecturl}    /    \\/
    log    ${Objecturl}
    ${FLAG_TO_UPDATE}=    Set Variable If    "${flag}" == "Recent"    RemoveFlag    "${flag}"=="Seen"    AddFlag
	${LIST_OF_OBJECTURLS}=	Set Variable	${Objecturl}
	${uri}=		Set Variable	${OEM_HOST_URI}${userId}/objects/operations/bulkUpdate
	${data}=    OperatingSystem.Get Binary File		${CURDIR}/../testfiles/${objfile}
	${data}=	Replace Variables	${data}
    log    ${data}
    ${response}=    RequestsLibrary.Post Request    alias=${mStore_request_session}    uri=${uri}    data=${data}    headers=${headers}    
    log    ${response.status_code}
    log    ${response.text}
    log    ${response.headers}
    ${response_code}=    Convert to Integer    ${response_code}
    Should Be Equal    ${response.status_code}    ${response_code}
    [Return]    ${response}

BulkDelete    
    [Arguments]    ${objfile}=BulkDelete.json    ${ListresourceURls}=${LIST_OF_RESOURCEURLS}    ${headers}=${OEM_BULK_UPDATE_HEADERS}    ${response_code}=200		${userId}=${SUBSCRIBER_ID}		${mStore_request_session}=${MSTORE_SESSION_NAME}
    ${Objecturl}=    Set Variable    ${EMPTY}
    :FOR    ${url}    IN    @{ListresourceURls}
    \    ${Objecturl}=    Set Variable    ${Objecturl} { "resourceURL": "${url}" },
    ${Objecturl}=    Set Variable    ${Objecturl[:-1]}
    log    ${Objecturl}
	${LIST_OF_OBJECTURLS}=  Set Variable    ${Objecturl}
    ${uri}=     Set Variable    ${OEM_HOST_URI}${userId}/objects/operations/bulkDelete
    ${data}=    OperatingSystem.Get Binary File     ${CURDIR}/../testfiles/${objfile}
    ${data}=    Replace Variables   ${data}
    log    ${data}
    ${response}=    RequestsLibrary.Delete Request    alias=${mStore_request_session}    uri=${uri}    data=${data}    headers=${headers}
    log    ${response.status_code}
    log    ${response.text}
    log    ${response.headers}
    ${response_code}=    Convert to Integer    ${response_code}
    Should Be Equal    ${response.status_code}    ${response_code}
    [Return]    ${response}


ValidateBulkPNSNotification
    [Arguments]    ${pns_headers}    ${pns_body}    ${recipients_uri}=${SUBSCRIBER_ID}    ${folderSyncPath}=${CHAT_PARENT_FOLDER_PATH}    ${oem_path}=${OEM_HOST_URI}    ${service_root_path}=${OEM_SERVER_ROOT_PATH}    ${userId}=${SUBSCRIBER_ID}		${notification_type}=pns		${msgFolderkey}=${RCS_MESSAGE_FOLDER_KEY}
    log    ${pns_body}
    ${data}=    Evaluate    json.loads('''${pns_body}''')    json
    log    ${data}
   # ${msgFolderkey}=	Set Variable   ${Generic_Cos_Path_Ids['${folderSyncPath}']}

    ${folderURL}=    Set variable    https://${service_root_path}${oem_path}${userId}/folders/${msgFolderkey}
	${len_response_body} =  Get Length  ${pns_body}
    Run Keyword and Continue on failure    Run Keyword If   '${notification_type}' == 'pns'     Should Be Equal As Strings    ${pns_headers['host']}    ${PNS_SERVER_NAME}:${PNS_SERVICE_PORT}
    Run Keyword and Continue on failure    Run Keyword If   '${notification_type}' == 'nms'     Should Be Equal As Strings    ${pns_headers['host']}    ${NMS_SERVER_NAME}:${NMS_SERVICE_PORT}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${pns_headers['content-type']}    ${PNS_RESPONSE_CONTENT_TYPE}
    Run Keyword and Continue on failure    Run Keyword If   '${notification_type}' == 'pns'     Should Be Equal As Strings    ${pns_headers['authorization']}    Basic ${PNS_AUTHORIZATION}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${pns_headers['content-length']}    ${len_response_body}
#    Run Keyword and Ignore Error    Run Keyword and Continue on Failure    Should Match Regexp    ${headers['X-mStoreFE-Addr']}    FEname:${FE_NAME}-nodeId:${NODE_ID}-ConnId:[a-zA-Z0-9]+-slot:${SLOT_ID}-instId:[0-9]+-subOid:[0-9]+-time:[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z-localFqdn:${LOCAL_FQDN}

    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${data['push-message']['recipients'][0]['uri']}    tel:+${recipients_uri}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${data['push-message']['channel']}    ${PNS_CHANNEL}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${data['push-message']['serviceName']}    ${PNS_SERVICE_NAME}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${data['push-message']['pns-type']}    ${BULK_PNS_TYPE}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${data['push-message']['pns-subtype']}    ${BULK_PNS_SUBTYPE}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${data['push-message']['nmsEventList']['nmsEvent'][0]['notifyObject']['message']['folderURL']}    ${folderURL}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${data['push-message']['nmsEventList']['nmsEvent'][0]['notifyObject']['message']['folderSyncPath']}    ${folderSyncPath}/${userId}

ValidateBulkResponse
    [Arguments]    ${response}    ${code}=200    ${reason}=OK    ${list_of_obj_urls}=${LIST_OF_RESOURCEURLS}
    ${response_text}=    Set Variable    ${response.text}
    ${data}=    Evaluate    json.loads('''${response_text}''')    json
    log    ${data}
    ${length}=    Get Length    ${list_of_obj_urls}
    :FOR    ${index}    IN RANGE    0    ${length}
    \    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${data['bulkResponseList']['response'][${index}]['code']}    ${code}
    \    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${data['bulkResponseList']['response'][${index}]['reason']}    ${reason}
    \    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${data['bulkResponseList']['response'][${index}]['success']['resourceURL']}    ${list_of_obj_urls[${index}]}

ValidateBulkFailureResponse
    [Arguments]    ${response}    ${code}=404    ${reason}=Not found    ${list_of_obj_urls}=${LIST_OF_RESOURCEURLS}
    ${response_text}=    Set Variable    ${response.text}
    ${data}=    Evaluate    json.loads('''${response_text}''')    json
    log    ${data}
    ${length}=    Get Length    ${list_of_obj_urls}
    :FOR    ${index}    IN RANGE    0    ${length}
    \    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${data['bulkResponseList']['response'][${index}]['code']}    ${code}
    \    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${data['bulkResponseList']['response'][${index}]['reason']}    ${reason}
    \    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${data['bulkResponseList']['response'][${index}]['failure']['serviceException']['variables'][0]}    ${list_of_obj_urls[${index}]}


GetArchivalHTTPTRLdecodedData
    [Arguments]    ${nodeId}=${MSTORE_NODE_NAME}    ${trl_path}=${TRL_PATH}    ${no_of_trl}=1    ${interface_type}=${HTTP_INTERFACE_TYPE}	${HTTP_Method}=0	${Operation_type}=3		${mStore_session}=mStore
    Switch Connection    ${mStore_session}
    ${current_trl_path}=    Execute Command    echo ${trl_path}/`date +%Y_%m/%d/%H`
    log    ${current_trl_path}
    Should Not Be Empty    ${current_trl_path}    msg="TRL path is empty"
    ${all_files}=    Execute Command    ls -lrt ${current_trl_path}/* |grep ${nodeId}_TRL.*gz
    log    ${all_files}
    ${complete_data}=    Execute Command    zcat ${current_trl_path}/*
    log    ${complete_data}
    ${full_data}=    Execute Command    zcat ${current_trl_path}/* |grep ,V1,${HTTP_Method},${Operation_type}, |tail -n ${no_of_trl}
    log    ${full_data}
    Should Not Be Empty    ${full_data}    msg="TRL data is not generated"
    Run    echo "${full_data}" > /tmp/http_trl_test.csv
    ${c_time}=    Get Time    epoch
    ${decoded_file}=    Set Variable    /tmp/trl_decodeddata_${c_time}.txt
    ${result}=    Run    ${CURDIR}/../testfiles/trlDecoder.sh /tmp/http_trl_test.csv ${CURDIR}/../testfiles/mStore_HTTP_TRL_Fields.txt
    log    ${result}
    Run    echo "${result}" > ${decoded_file}
    [Return]    ${full_data}    ${decoded_file}

GetPNSHTTPTRLdecodedData
    [Arguments]    ${nodeId}=${MSTORE_NODE_NAME}    ${trl_path}=${TRL_PATH}    ${no_of_trl}=1    ${interface_type}=${HTTP_INTERFACE_TYPE}   ${HTTP_Method}=0    ${Operation_type}=16     ${mStore_session}=mStore
    Switch Connection    ${mStore_session}
    ${current_trl_path}=    Execute Command    echo ${trl_path}/`date +%Y_%m/%d/%H`
    log    ${current_trl_path}
    Should Not Be Empty    ${current_trl_path}    msg="TRL path is empty"
    ${all_files}=    Execute Command    ls -lrt ${current_trl_path}/* |grep ${nodeId}_TRL.*gz
    log    ${all_files}
	${complete_data}=    Execute Command    zcat ${current_trl_path}/*
    log    ${complete_data}
    ${full_data}=    Execute Command    zcat ${current_trl_path}/* |grep ,${HTTP_Method},${Operation_type}, |tail -n ${no_of_trl}
    log    ${full_data}
    Should Not Be Empty    ${full_data}    msg="PNS TRL data is not generated"
	Run    echo "${full_data}" > /tmp/http_trl_test.csv
    ${c_time}=    Get Time    epoch
    ${decoded_file}=    Set Variable    /tmp/trl_decodeddata_${c_time}.txt
    ${result}=    Run    ${CURDIR}/../testfiles/trlDecoder.sh /tmp/http_trl_test.csv ${CURDIR}/../testfiles/mStore_HTTP_TRL_Fields.txt
    log    ${result}
    Run    echo "${result}" > ${decoded_file}
    [Return]    ${full_data}    ${decoded_file}


ValidateFTPNSNotfn
    [Arguments]     ${pns_headers}   ${pns_body}   ${userId}=${SUBSCRIBER_ID}    ${direction}=Out   ${msgStatus}=RECENT    ${sender}=${MSG_FROM}    ${recipients_uri}=${MSG_TO}    ${push_recipients_uri}=${recipients_uri}  ${uid}=${CREATION_TUID}   ${pns_subtype}=${PNS_SUBTYPE}   ${service_root_path}=${OEM_SERVER_ROOT_PATH}    ${oem_path}=${OEM_HOST_URI}    ${parentfolderkey}=${RCS_PARENT_FOLDER_KEY}   ${msgFolderkey}=${RCS_MESSAGE_FOLDER_KEY}   ${notification_type}=pns    ${folder_path}=${FT_PARENT_FOLDER_PATH}/${userId}/        ${PNS_TYPE}=${PNS_TYPE}      ${imdn_pns}=deposit     ${P_ASSERTED_SERVICE}=${ASSERTED_SERVICE}       ${msg_type}=individual  ${group_members}=${MSG_TO_GROUP_MEMBERS}    ${read_recipients_uri}=${NONE}  ${delivered_recipients_uri}=${NONE}		${multipart}=false
    log		${pns_headers}
    log		${pns_body}
    ${pns_resource_url}=    Set Variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey}%3a${uid}
    ${pns_object_Url1}=    Set Variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey}%3a${uid}
    ${pns_parentFolder}=    Set Variable    https://${service_root_path}${oem_path}${userId}/folders/${msgFolderkey}
	${pns_object_Icon_Url}=		Set Variable	https://${service_root_path}${oem_path}${userId}/objects/${FT_MESSAGE_CONTEXT}/v1/${SWIFTACCOUNTID}/${CONTAINER_INFO['${FT_PARENT_FOLDER_PATH}']}/\\d+%3a${msgFolderkey}%3a${uid}/payloadParts/part2
    ${json_data}=    Set Variable    ${pns_body}
    ${json_data}=    Replace String    ${json_data}    \\    ${EMPTY}
    ${json_out}=    Evaluate    json.loads('''${json_data}''',strict=False)    json
    log    ${json_out}
	Set Suite Variable  ${PNS_OBJECT_URL}   ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['objectURL']}
    ${OBJECT_URL}=     Replace String		${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['objectURL']}		https://${service_root_path}	${EMPTY}
    Set Suite Variable  ${OBJECT_URL}
    ${status_msg}=    Split String    ${msgStatus}    ,
    ${len_msg_status}=    Get Length    ${status_msg}
    ${len_response_body} =  Get Length  ${pns_body}
    Run Keyword and Continue on failure    Run Keyword If   '${notification_type}' == 'pns'     Should Be Equal As Strings    ${pns_headers['host']}    ${PNS_SERVER_NAME}:${PNS_SERVICE_PORT}
    Run Keyword and Continue on failure    Run Keyword If   '${notification_type}' == 'nms'     Should Be Equal As Strings    ${pns_headers['host']}    ${NMS_SERVER_NAME}:${NMS_SERVICE_PORT}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${pns_headers['content-type']}    ${PNS_RESPONSE_CONTENT_TYPE}
    Run Keyword and Continue on failure    Run Keyword If   '${notification_type}' == 'pns'     Should Be Equal As Strings    ${pns_headers['authorization']}    Basic ${PNS_AUTHORIZATION}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${pns_headers['content-length']}    ${len_response_body}
    Run Keyword and Ignore Error    Run Keyword and Continue on Failure    Should Match Regexp    ${headers['X-mStoreFE-Addr']}    FEname:${FE_NAME}-nodeId:${NODE_ID}-ConnId:[a-zA-Z0-9]+-slot:${SLOT_ID}-instId:[0-9]+-subOid:[0-9]+-time:[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z-localFqdn:${LOCAL_FQDN}

    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['serviceName']}    ${PNS_SERVICE_NAME}		msg="pns serviceName mismatch"
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['TTL']}    ${PNS_TTL}		msg="pns TTL mismatch"
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['recipients'][0]['uri']}    ${push_recipients_uri}		msg="pns recipient uri mismatch"
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['channel']}       ${PNS_CHANNEL}	msg="pns channel mismatch"
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['pns-type']}    ${PNS_TYPE}		msg="pns_type mismatch"
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['pns-subtype']}    ${pns_subtype}	msg="pns subtype mismatch"
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['parentFolder']}    ${pns_parentFolder}		msg="pns parentFolder mismatch"
    ${flag_length}=    Get Length      ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['flags']['flag']}

    Run Keyword and Continue on failure    Run Keyword If	${len_msg_status} == 1	Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['flags']['flag'][0]}    ${status_msg[0]}    ignore_case=True	msg="pns flag mismatch"
	Run Keyword and Continue on failure    Run Keyword If	${len_msg_status} > 1 and '${imdn_pns}' != 'displayed'	Should Be Equal As Strings	  ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['flags']['flag'][0]}    ${status_msg[1]}    ignore_case=True    msg="pns flag mismatch"
	Run Keyword and Continue on failure    Run Keyword If   ${len_msg_status} > 1 and '${imdn_pns}' == 'displayed'    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['flags']['flag'][0]}    ${status_msg[0]}    ignore_case=True    msg="pns flag mismatch"

    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['resourceURL']}    ${pns_resource_URL}	msg="pns resourceURL mismatch"
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['correlationId']}    ${CORRELATION_ID}	msg="pns correlationId mismatch"
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['store']}    ${folder_path}	msg="pns message store mismatch"
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['objectURL']}    ${pns_object_Url1}	 msg="pns objecturl mismatch"
	Run Keyword and Continue on failure    Run Keyword If	'${multipart}' == 'true'	Should Match Regexp   ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['objectIconURL']}    ${pns_object_Icon_Url}		msg="pns objectIconUrl mismatch"
	${iconUrl}=		Run Keyword If   '${multipart}' == 'true'	Replace String	${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['objectIconURL']}		https://${service_root_path}   ${EMPTY}	
	Run Keyword If   '${multipart}' == 'true'	Set SUite Variable	${FT_OBJECTICON_PART}	${iconUrl}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['direction']}    ${direction}	msg="pns direction mismatch"
    Run Keyword and Continue on failure    Should Match Regexp    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['message-time']}    [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}.000-[0-9]{2}:[0-9]{2}		msg="pns message-time mismatch"
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['status']}    ${msgStatus}   ignore_case=True	msg="pns message status mismatch"
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['sender']}    ${sender}	msg="pns sender mismatch"
    Run Keyword and Continue on failure    Run Keyword If   '${msg_type}' == 'group'    ValidateGroupRecepients     ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['recipients']}        ${group_members}    ELSE    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['recipients'][0]['uri']}    ${recipients_uri}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['imdn-message-id']}    ${IMDN_MESSAGE_ID}	msg="pns imdn message id mismatch"
    ${delivered_list}=  Set Variable If     '${imdn_pns}' != 'deposit' and '${direction}' == 'Out'	${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['imdn']['delivered']}
    ${read_list}=   Set Variable If     '${imdn_pns}' == 'displayed' and '${direction}' == 'Out'    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['imdn']['read']}
	${delivered_recipients_uri1}=	Run Keyword If	'${imdn_pns}' != 'deposit' and '${msg_type}' == 'group'		Split String	${delivered_recipients_uri}		,
	${read_recipients_uri1}=		Run Keyword If	'${imdn_pns}' == 'displayed' and '${msg_type}' == 'group'		Split String	${read_recipients_uri}			,
	log		${delivered_recipients_uri}
	log		${read_recipients_uri}
    log     ${delivered_recipients_uri1}
    log     ${read_recipients_uri1}
	log		${delivered_list}
	log		${read_list}
    Run Keyword and Continue on failure    Run Keyword If    '${imdn_pns}' == 'delivered' and '${msg_type}' == 'group'    ValidateImdnDeliveredDisplayed    ${delivered_recipients_uri1}		${delivered_list}   ELSE IF     '${imdn_pns}' == 'delivered'    Should Be Equal As Strings  ${delivered_list[0]}    ${recipients_uri}

    Run Keyword and Continue on failure    Run Keyword If      '${imdn_pns}' == 'displayed' and '${msg_type}' == 'group'    ValidateImdnDeliveredDisplayed    ${delivered_recipients_uri1}   ${delivered_list}   ELSE IF    '${imdn_pns}' == 'displayed' and '${direction}' == 'Out'	Should Be Equal As Strings    ${delivered_list[0]}    ${recipients_uri}

    Run Keyword and Continue on failure     Run Keyword If   '${imdn_pns}' == 'displayed' and '${msg_type}' == 'group'   ValidateImdnDeliveredDisplayed    ${read_recipients_uri1}   ${read_list}   ELSE IF       '${imdn_pns}' == 'displayed' and '${direction}' == 'Out'	Should Be Equal As Strings    ${read_list[0]}    ${recipients_uri}

    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['content'][0]['rcs-data']['contribution-id']}    ${CONTRIBUTION_ID}		msg="pns contribution-id mismatch"
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['content'][0]['rcs-data']['conversation-id']}    ${CONVERSATION_ID}	msg="pns conversation-id mismatch"
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['content'][0]['rcs-data']['p-asserted-service']}    ${P_ASSERTED_SERVICE}	msg="pns p-asserted-service mismatch"
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['content'][0]['rcs-data']['feature-tag']}    ${P_ASSERTED_SERVICE}	msg="pns feature-tag mismatch"
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['content'][0]['rcs-data']['sip-call-id']}    ${X_SIP_CALLID}		msg="pns sipCallId mismatch"



ValidateFTFolderSearchResponse
    [Arguments]     ${response}     ${direction}=Out    ${from_msg}=${MSG_FROM}     ${to_msg}=${MSG_TO}     ${message_context}=${MESSAGE_CONTEXT}   ${msgFolderkey}=${RCS_MESSAGE_FOLDER_KEY}   ${uid}=${CREATION_TUID}    ${msgStatus}=Recent     ${service_root_path}=${OEM_SERVER_ROOT_PATH}    ${oem_path}=${OEM_HOST_URI}     ${userId}=${SUBSCRIBER_ID}  ${no_of_msgs}=1     ${P_ASSERTED_SERVICE}=${ASSERTED_SERVICE}   ${msg_type}=individual	  ${sw_acct_id}=${SWIFTACCOUNTID}	${swift_base_url}=${OPENSTACK_SWIFT_BASE_URL}	${imdn_type}=deposit        ${read_recipients_uri}=${NONE}  ${delivered_recipients_uri}=${NONE}		${multipart}=false	${c_uid}=${CREATION_TUIDS} 		${msgFolderkey2}=${RCS_MESSAGE_FOLDER_KEY2}		${UserPath}=${FROM_MSISDN}

    ${to}=  Run Keyword If  '${msg_type}' == 'individual'   Create List     ${to_msg}   ELSE    Copy List   ${to_msg}

    ${status_msg}=    Split String    ${msgStatus}    ,
    ${len_msg_status}=    Get Length    ${status_msg}
    log    ${response.headers}
    ${data}=    set Variable    ${response.json()}
    log    ${data}
    ${list_of_objects}=    Get Length    ${data['objectList']['object']}
    Run Keyword and Continue On Failure     Should Be Equal As Strings  ${list_of_objects}  ${no_of_msgs}
    :FOR    ${index}    IN RANGE    0    ${list_of_objects}
    \    ${Attributes_pair}=    Get_FolderSearch_AttributesPair    ${data['objectList']['object'][${index}]['attributes']['attribute']}
    \    log    ${Attributes_pair}
    \    ${uid_index}=      Evaluate    ${index} + 1
    \    ${uid}=    Set Variable    ${c_uid['${uid_index}']}
    \    ${imdnMsgId}=  Set Variable    ${IMDN_MESSAGE_IDS['${uid_index}']}
    \    ${CorlnId}=    Set Variable    ${imdnMsgId}
    \    ${obj_parentFolder}=   Set Variable    https://${service_root_path}${oem_path}${userId}/folders/${msgFolderkey}
    \    ${obj_resourceURL}=    Set variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey2}%3a${uid}
    \    ${obj_Folderpath}=     Set Variable    /${RCS_PARENT_PATH}/${UserPath}//${msgFolderkey}%3a${uid}
	\	 ${obj_payloadURL}=    Set variable    https://${service_root_path}${oem_path}${userId}/objects/${message_context}${swift_base_url}/${sw_acct_id}/${CONTAINER_INFO['${RCS_PARENT_PATH}']}/[0-9]+%3a${msgFolderkey}%3a${uid}

    \	 Run Keyword and Continue on failure    Should Match Regexp    ${data['objectList']['object'][${index}]['payloadURL']}    ${obj_payloadURL}		msg="payloadURL mismatch foldersync response"
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['parentFolder']}    ${obj_parentFolder}		msg="parentFolder mismatch foldersync response"
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['resourceURL']}    ${obj_resourceURL}	msg="resourceURL mismatch foldersync response"
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['path']}    ${obj_Folderpath}	msg="path mismatch foldersync response"
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['correlationId']}    ${CorlnId}	msg="correlationId mismatch foldersync response"
	\	 ${flag_length}=	Get Length		${data['objectList']['object'][${index}]['flags']['flag']}
	\	 Run Keyword and Continue on failure	Should Be Equal As Strings	${len_msg_status}	${flag_length}	msg="Expectes flag status ${msgStatus} Recieved ${data['objectList']['object'][${index}]['flags']['flag']}"
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['flags']['flag'][0]}    \\${status_msg[0]}    ignore_case=True	msg="flag mismatch foldersync response"
    \    Run Keyword and Continue on failure    Run Keyword If    ${len_msg_status} > 1    Should Be Equal    ${data['objectList']['object'][${index}]['flags']['flag'][1]}    \\${status_msg[1]}    ignore_case=True	msg="flag mismatch foldersync response"
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['flags']['resourceURL']}    ${obj_resourceURL}/flags	msg="flag resourceURL mismatch foldersync response"
    \    Run Keyword and Continue on failure    Run Keyword If  '${multipart}' == 'true'	Should Be Equal    ${Attributes_pair['content-type'][0]}   ${FT_CONTENT_TYPE}	msg="attribute content-type mismatch foldersync response"
#;start="${FT_THUMBNAIL_CONTENT_ID}"		ELSE	Should Be Equal    ${Attributes_pair['content-type'][0]}   ${FT_CONTENT_TYPE}	msg="attribute content-type mismatch foldersync response"
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Contribution-ID'][0]}    ${CONTRIBUTION_ID}	msg="attribute Contribution-ID mismatch foldersync response"
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Conversation-ID'][0]}    ${CONVERSATION_ID}	msg="attributr Conversation-ID mismatch foldersync response"
    \    Run Keyword and Continue on failure    Should Match Regexp    ${Attributes_pair['date'][0]}    [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z		msg="attribute date mismatch foldersync response"
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Direction'][0]}    ${direction}	msg="attribute direction mismatch foldersync response"
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['from'][0]}    ${from_msg}		msg="attribute from mismatch foldersync response"
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['IMDN-Message-ID'][0]}    ${imdnMsgId}	msg="attribute IMDN-Message-ID mismatch foldersync response"
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['message-context'][0]}    ${message_context}		msg="attribute message-context mismatch foldersync response"
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['P-Asserted-Service'][0]}    ${P_ASSERTED_SERVICE}		msg="attribute P-Asserted-Service mismatch foldersync response"
    \    Run Keyword and Continue on failure    Run Keyword If  '${msg_type}' == 'individual'   Should Be Equal    ${Attributes_pair['to'][0]}    ${to_msg} 	ELSE    ValidateGroupToMessages     ${Attributes_pair['to']}    ${to_msg}
    \   Run Keyword and Continue on failure    Run Keyword If    '${imdn_type}' == 'deposit'    Dictionary Should Not Contain Key       ${data['objectList']['object'][${index}]}   imdn

    \   ${delivered_list}=  Set Variable If     '${imdn_type}' != 'deposit'   ${data['objectList']['object'][${index}]['imdn']['delivered']}
    \   ${read_list}=   Set Variable If     '${imdn_type}' == 'displayed'     ${data['objectList']['object'][${index}]['imdn']['read']}
	\   ${delivered_recipients_uri1}=   Run Keyword If  '${imdn_type}' != 'deposit' and '${msg_type}' == 'group'  Split String    ${delivered_recipients_uri}     ,
    \	${read_recipients_uri1}=        Run Keyword If  '${imdn_type}' == 'displayed' and '${msg_type}' == 'group'    Split String    ${read_recipients_uri}          ,
    \	log     ${delivered_recipients_uri}
    \	log     ${read_recipients_uri}
    \	log     ${delivered_recipients_uri1}
    \	log     ${read_recipients_uri1}
    \	log     ${delivered_list}
    \	log     ${read_list}


    \   Run Keyword and Continue on failure    Run Keyword If    '${imdn_type}' == 'delivered' and '${msg_type}' == 'group'    ValidateImdnDeliveredDisplayed    ${delivered_recipients_uri1}        ${delivered_list}   ELSE IF     '${imdn_type}' == 'delivered' and '${msg_type}' != 'group'    Should Be Equal As Strings  ${delivered_list[0]}    ${to_msg}

    \   Run Keyword and Continue on failure    Run Keyword If      '${imdn_type}' == 'displayed' and '${msg_type}' == 'group'    ValidateImdnDeliveredDisplayed    ${delivered_recipients_uri1}   ${delivered_list}   ELSE IF    '${imdn_type}' == 'displayed' and '${msg_type}' != 'group'  Should Be Equal As Strings    ${delivered_list[0]}    ${to_msg}

    \   Run Keyword and Continue on failure     Run Keyword If   '${imdn_type}' == 'displayed' and '${msg_type}' == 'group'   ValidateImdnDeliveredDisplayed    ${read_recipients_uri1}   ${read_list}   	ELSE IF       '${imdn_type}' == 'displayed' and '${msg_type}' != 'group'   Should Be Equal As Strings    ${read_list[0]}    ${to_msg}
	\	Run Keyword and Continue on failure		Run Keyword If	'${multipart}' == 'true'	ValidatePayloadMultiPart	${data['objectList']['object'][${index}]}	${obj_payloadURL}	${service_root_path}	ELSE	ValidatePayloadSinglePart	${data['objectList']['object'][${index}]}	${obj_payloadURL}	${service_root_path}

ValidatePayloadMultiPart
	[Arguments]		${data}		${payloadurl}	${service_root_path}
	${href1}=	Set Variable	${payloadurl}/payloadParts/part1
    ${href2}=   Set Variable    ${payloadurl}/payloadParts/part3

    Run Keyword and Continue on Failure     Should Be Equal As Strings  ${data['payloadPart'][0]['contentType']}    Application/X-CPM-File-Transfer
    Run Keyword and Continue on Failure     Should Be Equal As Strings  ${data['payloadPart'][0]['contentEncoding']}    binary
    Run Keyword and Continue on Failure     Should Match Regexp  ${data['payloadPart'][0]['href']}      ${href1}

    Run Keyword and Continue on Failure     Should Be Equal As Strings  ${data['payloadPart'][1]['contentType']}    ${FT_CONTENT_TYPE1}
    Run Keyword and Continue on Failure     Should Be Equal As Strings  ${data['payloadPart'][1]['contentId']}      ${FT_THUMBNAIL_CONTENT_ID}
    Run Keyword and Continue on Failure     Should Be Equal As Strings  ${data['payloadPart'][1]['contentEncoding']}    ${LM_CONTENT_TRANSFER_ENCODING}
    Run Keyword and Continue on Failure     Should Match Regexp  ${data['payloadPart'][1]['content']}      \\w+

	Run Keyword and Continue on Failure		Should Be Equal As Strings	${data['payloadPart'][2]['contentType']}	${FT_CONTENT_TYPE1}
	Run Keyword and Continue on Failure     Should Be Equal As Strings	${data['payloadPart'][2]['contentId']}		${FT_PAYLOAD_CONTENT_ID}
    Run Keyword and Continue on Failure     Should Be Equal As Strings  ${data['payloadPart'][2]['contentEncoding']}	${LM_CONTENT_TRANSFER_ENCODING}
    Run Keyword and Continue on Failure     Should Match Regexp  ${data['payloadPart'][2]['href']}		${href2}
	${FT_SESSION_PART}=		Replace String   ${data['payloadPart'][0]['href']}    https://${service_root_path}    /
    ${FT_PAYLOAD_PART}=   Replace String   ${data['payloadPart'][2]['href']}    https://${service_root_path}    /
	Set Suite Variable  ${FT_PAYLOAD_PART} 
	Set Suite Variable	${FT_SESSION_PART}

ValidatePayloadSinglePart	
    [Arguments]     ${data}		${payloadurl}	${service_root_path}
    ${href}=    Set Variable    ${payloadurl}/payloadParts/part1
    Run Keyword and Continue on Failure     Should Be Equal As Strings  ${data['payloadPart'][0]['contentType']}    ${LM_FT_CONTENT_TYPE}
    Run Keyword and Continue on Failure     Should Be Equal As Strings  ${data['payloadPart'][0]['contentId']}      <${FT_PAYLOAD_CONTENT_ID}>
    Run Keyword and Continue on Failure     Should Be Equal As Strings  ${data['payloadPart'][0]['contentEncoding']}    ${LM_CONTENT_TRANSFER_ENCODING}
    Run Keyword and Continue on Failure     Should Match Regexp  ${data['payloadPart'][0]['href']}		${href}
    ${FT_PAYLOAD_PART}=   Replace String   ${data['payloadPart'][0]['href']}    https://${service_root_path}    /
    Set Suite Variable  ${FT_PAYLOAD_PART} 


ValidateFTFolderSearchResponse_along_with_Session_FT
    [Arguments]     ${response}     ${direction}=Out    ${from_msg}=${MSG_FROM}     ${to_msg}=${MSG_TO}     ${message_context}=${MESSAGE_CONTEXT}   ${msgFolderkey}=${RCS_MESSAGE_FOLDER_KEY}   ${uid}=1    ${msgStatus}=Recent     ${service_root_path}=${OEM_SERVER_ROOT_PATH}    ${oem_path}=${OEM_HOST_URI}     ${userId}=${SUBSCRIBER_ID}  ${no_of_msgs}=2     ${P_ASSERTED_SERVICE}=${ASSERTED_SERVICE}   ${msg_type}=individual    ${sw_acct_id}=${SWIFTACCOUNTID}   ${swift_base_url}=${OPENSTACK_SWIFT_BASE_URL}   ${imdn_type}=deposit        ${read_recipients_uri}=${NONE}  ${delivered_recipients_uri}=${NONE}		${session_msg_uid}=${SESSION_MSG_CTUID}    ${session_msg_context}=${FT_SESSION_MESSAGE_CONTEXT}   ${session_msgStatus}=Recent    ${session_content_type}=Application/X-CPM-Session		${ft_session_asserted_service}=${P_ASSERTED_SERVICE_FT}    ${session_to}=${MSG_TO}	${multipart}=false	${c_uid}=${CREATION_TUIDS}		${msgFolderkey2}=${RCS_MESSAGE_FOLDER_KEY2}		${UserPath}=${FROM_MSISDN}	

    ${to}=  Run Keyword If  '${msg_type}' == 'individual'   Create List     ${to_msg}   ELSE    Copy List   ${to_msg}

    ${status_msg}=    Split String    ${msgStatus}    ,
    ${len_msg_status}=    Get Length    ${status_msg}
    log    ${response.headers}
    ${data}=    set Variable    ${response.json()}
    log    ${data}
    ${list_of_objects}=    Get Length    ${data['objectList']['object']}

    Run Keyword and Continue On Failure     Should Be Equal As Strings  ${list_of_objects}  ${no_of_msgs}
    ${S_resourceURL}=    Set Variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey2}%3a${session_msg_uid}
    ${S_objectUrl}=    Set Variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey}%3a${session_msg_uid}
    ${S_parentFolder}=    Set Variable    https://${service_root_path}${oem_path}${userId}/folders/${msgFolderkey}
    ${S_Folderpath}=    Set Variable    /${RCS_PARENT_PATH}/${UserPath}//${msgFolderkey}%3a${session_msg_uid}
    ${S_payloadURL}=    Set variable    https://${service_root_path}${oem_path}${userId}/objects/${session_msg_context}/cassandra/${msgFolderkey}%3a${session_msg_uid}

    ${Attributes_pair}=    Get_FolderSearch_AttributesPair    ${data['objectList']['object'][0]['attributes']['attribute']}
    log    ${Attributes_pair}
    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][0]['parentFolder']}    ${S_parentFolder}
    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][0]['resourceURL']}    ${S_resourceURL}
    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][0]['path']}    ${S_Folderpath}
    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][0]['payloadURL']}    ${S_payloadURL}
    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][0]['flags']['flag'][0]}    \\${session_msgStatus}    ignore_case=True
    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][0]['flags']['resourceURL']}    ${S_resourceURL}/flags
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['content-type'][0]}    ${session_content_type}
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Contribution-ID'][0]}    ${CONTRIBUTION_ID}
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Conversation-ID'][0]}    ${CONVERSATION_ID}
    Run Keyword and Continue on failure    Should Match Regexp    ${Attributes_pair['date'][0]}    [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Direction'][0]}    ${direction}
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['from'][0]}    ${from_msg}
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['message-context'][0]}    ${session_msg_context}
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['P-Asserted-Service'][0]}    ${ft_session_asserted_service}
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['to'][0]}    ${session_to}

    :FOR    ${index}    IN RANGE    1    ${list_of_objects}
    \    ${Attributes_pair}=    Get_FolderSearch_AttributesPair    ${data['objectList']['object'][${index}]['attributes']['attribute']}
    \    log    ${Attributes_pair}
#    \    ${uid_index}=      Evaluate    ${index} + 1
    \    ${uid}=    Set Variable    ${c_uid['${index}']}
	\	 ${imdnMsgId}=	Set Variable	${IMDN_MESSAGE_IDS['${index}']}
	\	 ${CorlnId}=	Set Variable	${imdnMsgId}
    \    ${obj_parentFolder}=   Set Variable    https://${service_root_path}${oem_path}${userId}/folders/${msgFolderkey}
    \    ${obj_resourceURL}=    Set variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey2}%3a${uid}
    \    ${obj_Folderpath}=     Set Variable    /${RCS_PARENT_PATH}/${UserPath}//${msgFolderkey}%3a${uid}
    \    ${obj_payloadURL}=    Set variable    https://${service_root_path}${oem_path}${userId}/objects/${message_context}${swift_base_url}/${sw_acct_id}/${CONTAINER_INFO['${RCS_PARENT_PATH}']}/[0-9]+%3a${msgFolderkey}%3a${uid}
    \    Run Keyword and Continue on failure    Should Match Regexp    ${data['objectList']['object'][${index}]['payloadURL']}    ${obj_payloadURL}
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['parentFolder']}    ${obj_parentFolder}
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['resourceURL']}    ${obj_resourceURL}
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['path']}    ${obj_Folderpath}
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['correlationId']}    ${CorlnId}
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['flags']['flag'][0]}    \\${status_msg[0]}    ignore_case=True
    \    Run Keyword and Continue on failure    Run Keyword If    ${len_msg_status} > 1    Should Be Equal    ${data['objectList']['object'][${index}]['flags']['flag'][1]}    \\${status_msg[1]}    ignore_case=True
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['flags']['resourceURL']}    ${obj_resourceURL}/flags
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['content-type'][0]}        ${FT_CONTENT_TYPE}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Contribution-ID'][0]}    ${CONTRIBUTION_ID}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Conversation-ID'][0]}    ${CONVERSATION_ID}
    \    Run Keyword and Continue on failure    Should Match Regexp    ${Attributes_pair['date'][0]}    [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Direction'][0]}    ${direction}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['from'][0]}    ${from_msg}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['IMDN-Message-ID'][0]}    ${imdnMsgId}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['message-context'][0]}    ${message_context}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['P-Asserted-Service'][0]}    ${P_ASSERTED_SERVICE}
    \    Run Keyword and Continue on failure    Run Keyword If  '${msg_type}' == 'individual'   Should Be Equal    ${Attributes_pair['to'][0]}    ${to_msg}     ELSE    ValidateGroupToMessages     ${Attributes_pair['to']}    ${to_msg}
    \   Run Keyword and Continue on failure    Run Keyword If    '${imdn_type}' == 'deposit'    Dictionary Should Not Contain Key       ${data['objectList']['object'][${index}]}   imdn

    \   ${delivered_list}=  Set Variable If     '${imdn_type}' != 'deposit'   ${data['objectList']['object'][${index}]['imdn']['delivered']}
    \   ${read_list}=   Set Variable If     '${imdn_type}' == 'displayed'     ${data['objectList']['object'][${index}]['imdn']['read']}
    \   ${delivered_list}=  Set Variable If     '${imdn_type}' != 'deposit'   ${data['objectList']['object'][${index}]['imdn']['delivered']}
    \   ${read_list}=   Set Variable If     '${imdn_type}' == 'displayed'     ${data['objectList']['object'][${index}]['imdn']['read']}
    \   ${delivered_recipients_uri1}=   Run Keyword If  '${imdn_type}' != 'deposit' and '${msg_type}' == 'group'  Split String    ${delivered_recipients_uri}     ,
    \   ${read_recipients_uri1}=        Run Keyword If  '${imdn_type}' == 'displayed' and '${msg_type}' == 'group'    Split String    ${read_recipients_uri}          ,
    \   log     ${delivered_recipients_uri}
    \   log     ${read_recipients_uri}
    \   log     ${delivered_recipients_uri1}
    \   log     ${read_recipients_uri1}
    \   log     ${delivered_list}
    \   log     ${read_list}

    \   Run Keyword and Continue on failure    Run Keyword If    '${imdn_type}' == 'delivered' and '${msg_type}' == 'group'    ValidateImdnDeliveredDisplayed    ${delivered_recipients_uri1}        ${delivered_list}   ELSE IF     '${imdn_type}' == 'delivered' and '${msg_type}' != 'group'    Should Be Equal As Strings  ${delivered_list[0]}    ${to_msg}

    \   Run Keyword and Continue on failure    Run Keyword If      '${imdn_type}' == 'displayed' and '${msg_type}' == 'group'    ValidateImdnDeliveredDisplayed    ${delivered_recipients_uri1}   ${delivered_list}   ELSE IF    '${imdn_type}' == 'displayed' and '${msg_type}' != 'group'  Should Be Equal As Strings    ${delivered_list[0]}    ${to_msg}

    \   Run Keyword and Continue on failure     Run Keyword If   '${imdn_type}' == 'displayed' and '${msg_type}' == 'group'   ValidateImdnDeliveredDisplayed    ${read_recipients_uri1}   ${read_list}   ELSE IF       '${imdn_type}' == 'displayed' and '${msg_type}' != 'group'   Should Be Equal As Strings    ${read_list[0]}    ${to_msg}
    \   Run Keyword and Continue on failure     Run Keyword If  '${multipart}' == 'true'    ValidatePayloadMultiPart    ${data['objectList']['object'][${index}]}   ${obj_payloadURL}   ${service_root_path}    ELSE    ValidatePayloadSinglePart   ${data['objectList']['object'][${index}]}   ${obj_payloadURL}   ${service_root_path}


ValidateFTFetchResponse
    [Arguments]    ${response}    ${direction}=Out    ${msgFolderkey}=${RCS_MESSAGE_FOLDER_KEY}    ${msgStatus}=RECENT    ${From}=${MSG_FROM}    ${to_msg}=${MSG_TO}    ${uid}=${CREATION_TUID}    ${service_root_path}=${OEM_SERVER_ROOT_PATH}    ${userId}=${SUBSCRIBER_ID}    ${oem_path}=${OEM_HOST_URI}   ${msg_context}=${MESSAGE_CONTEXT}   ${folder_Path}=${FT_PARENT_FOLDER_PATH}/${userid}/     ${P_ASSERTED_SERVICE}=${ASSERTED_SERVICE}   ${msg_type}=individual	${sw_acct_id}=${SWIFTACCOUNTID}   ${swift_base_url}=${OPENSTACK_SWIFT_BASE_URL}		${imdn_type}=displayed		${multipart}=false	${read_recipients_uri}=${NONE}  ${delivered_recipients_uri}=${NONE}		${msgFolderkey2}=${RCS_MESSAGE_FOLDER_KEY2}
    ${to}=  Run Keyword If  '${msg_type}' == 'individual'   Create List     ${to_msg}   ELSE    Copy List   ${to_msg}
    ${obj_resourceURL}=    Set Variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey2}%3a${uid}
    ${obj_objectUrl}=    Set Variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey}%3a${uid}
    ${obj_parentFolder}=    Set Variable    https://${service_root_path}${oem_path}${userId}/folders/${msgFolderkey}
    ${obj_Folderpath}=    Set Variable    /${folder_Path}/${msgFolderkey}%3a${uid}
    ${obj_payloadURL}=    Set variable    https://${service_root_path}${oem_path}${userId}/objects/${message_context}${swift_base_url}/${sw_acct_id}/${CONTAINER_INFO['${RCS_PARENT_PATH}']}/[0-9]+%3a${msgFolderkey}%3a${uid}

    ${status_msg}=    Split String    ${msgStatus}    ,
    ${len_msg_status}=    Get Length    ${status_msg}

    ${data}=    Set Variable    ${response.json()}
    log    ${data}
    ${attributes}=    Set Variable    ${data['object']['attributes']['attribute']}

    ${Attributes_pair}=    Create Dictionary
    :FOR    ${pair}    IN    @{attributes}
    \    log    ${pair['name']}
    \    log    ${pair['value']}
    \    Set To Dictionary    ${Attributes_pair}    ${pair['name']}    ${pair['value']}
    log    ${Attributes_pair}
    Run Keyword and Continue on failure    Should Match Regexp    ${data['object']['payloadURL']}    ${obj_payloadURL}
    Run Keyword and Continue on failure    Should Be Equal    ${data['object']['parentFolder']}    ${obj_parentFolder}
    Run Keyword and Continue on failure    Should Be Equal    ${data['object']['resourceURL']}    ${obj_resourceURL}
    Run Keyword and Continue on failure    Should Be Equal    ${data['object']['path']}    ${obj_Folderpath}
    Run Keyword and Continue on failure    Should Be Equal    ${data['object']['correlationId']}    ${CORRELATION_ID}
    Run Keyword and Continue on failure    Should Be Equal    ${data['object']['flags']['flag'][0]}    \\${status_msg[0]}    ignore_case=True
    Run Keyword and Continue on failure    Run Keyword If    ${len_msg_status} > 1    Should Be Equal    ${data['object']['flags']['flag'][1]}    \\${status_msg[1]}    ignore_case=True
    Run Keyword and Continue on failure    Should Be Equal    ${data['object']['flags']['resourceURL']}    ${obj_resourceURL}/flags
    Run Keyword and Continue on failure    Run Keyword If  '${multipart}' == 'true'    Should Be Equal    ${Attributes_pair['content-type'][0]}   ${FT_CONTENT_TYPE}
#;start="${FT_THUMBNAIL_CONTENT_ID}"      ELSE    Should Be Equal    ${Attributes_pair['content-type'][0]}   ${FT_CONTENT_TYPE}

    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Contribution-ID'][0]}    ${CONTRIBUTION_ID}
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Conversation-ID'][0]}    ${CONVERSATION_ID}
    Run Keyword and Continue on failure    Should Match Regexp    ${Attributes_pair['date'][0]}    [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Direction'][0]}    ${direction}
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['from'][0]}    ${From}
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['IMDN-Message-ID'][0]}    ${IMDN_MESSAGE_ID}
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['message-context'][0]}    ${msg_context}
    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['P-Asserted-Service'][0]}    ${P_ASSERTED_SERVICE}
    Run Keyword and Continue on failure    Run Keyword If  '${msg_type}' == 'individual'   Should Be Equal    ${Attributes_pair['to'][0]}    ${to_msg}    ELSE    ValidateGroupToMessages     ${Attributes_pair['to']}    ${to_msg}
    Run Keyword and Continue on failure    Run Keyword If  '${msg_type}' == 'individual'   Should Be Equal    ${Attributes_pair['to'][0]}    ${to_msg}     ELSE    ValidateGroupToMessages     ${Attributes_pair['to']}    ${to_msg}
    Run Keyword and Continue on failure    Run Keyword If    '${imdn_type}' == 'deposit'    Dictionary Should Not Contain Key       ${data['object']}   imdn

    ${delivered_list}=  Set Variable If     '${imdn_type}' != 'deposit'   ${data['object']['imdn']['delivered']}
    ${read_list}=   Set Variable If     '${imdn_type}' == 'displayed'     ${data['object']['imdn']['read']}
    ${delivered_recipients_uri1}=   Run Keyword If  '${imdn_type}' != 'deposit' and '${msg_type}' == 'group'  Split String    ${delivered_recipients_uri}     ,
    ${read_recipients_uri1}=        Run Keyword If  '${imdn_type}' == 'displayed' and '${msg_type}' == 'group'    Split String    ${read_recipients_uri}          ,
    log     ${delivered_recipients_uri}
    log     ${read_recipients_uri}
    log     ${delivered_recipients_uri1}
    log     ${read_recipients_uri1}
    log     ${delivered_list}
    log     ${read_list}

    Run Keyword and Continue on failure    Run Keyword If    '${imdn_type}' == 'delivered' and '${msg_type}' == 'group'    ValidateImdnDeliveredDisplayed    ${delivered_recipients_uri1}        ${delivered_list}   ELSE IF     '${imdn_type}' == 'delivered' and '${msg_type}' != 'group'    Should Be Equal As Strings  ${delivered_list[0]}    ${to_msg}

    Run Keyword and Continue on failure    Run Keyword If      '${imdn_type}' == 'displayed' and '${msg_type}' == 'group'    ValidateImdnDeliveredDisplayed    ${delivered_recipients_uri1}   ${delivered_list}   ELSE IF    '${imdn_type}' == 'displayed' and '${msg_type}' != 'group'  Should Be Equal As Strings    ${delivered_list[0]}    ${to_msg}

    Run Keyword and Continue on failure     Run Keyword If   '${imdn_type}' == 'displayed' and '${msg_type}' == 'group'   ValidateImdnDeliveredDisplayed    ${read_recipients_uri1}   ${read_list}   ELSE IF       '${imdn_type}' == 'displayed' and '${msg_type}' != 'group'   Should Be Equal As Strings    ${read_list[0]}    ${to_msg}
    Run Keyword and Continue on failure     Run Keyword If  '${multipart}' == 'true'    ValidatePayloadMultiPart    ${data['object']}   ${obj_payloadURL}   ${service_root_path}	ELSE    ValidatePayloadSinglePart   ${data['object']}   ${obj_payloadURL}	${service_root_path}

	${FT_PAYLOADURL}=	Replace String	 ${data['object']['payloadURL']}	https://${service_root_path}	/
	Set Suite Variable	${FT_PAYLOADURL}


ValidateFTDeletePNSNotfn
    [Arguments]     ${pns_headers}   ${pns_body}   ${userId}=${SUBSCRIBER_ID}    ${direction}=Out   ${msgStatus}=RECENT    ${sender}=${MSG_FROM}    ${recipients_uri}=${MSG_TO}    ${push_recipients_uri}=${recipients_uri}  ${uid}=${CREATION_TUID}   ${pns_subtype}=${PNS_SUBTYPE}   ${service_root_path}=${OEM_SERVER_ROOT_PATH}    ${oem_path}=${OEM_HOST_URI}    ${parentfolderkey}=${RCS_PARENT_FOLDER_KEY}   ${msgFolderkey}=${RCS_MESSAGE_FOLDER_KEY}    ${notification_type}=pns        ${PNS_TYPE}=${PNS_TYPE}  ${msg_type}=individual      ${group_members}=${MSG_TO_GROUP_MEMBERS}		${FT_PARENT_FOLDER_PATH}=${FT_PARENT_FOLDER_PATH}/${FROM_MSISDN}/

    log     ${pns_headers}
    log     ${pns_body}
    ${pns_resource_url}=    Set Variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey}%3a${uid}
    ${pns_object_Url}=    Set Variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey}%3a${uid}
    ${pns_parentFolder}=    Set Variable    https://${service_root_path}${oem_path}${userId}/folders/${msgFolderkey}
    ${json_data}=    Set Variable    ${pns_body}
    ${json_data}=    Replace String    ${json_data}    \\    ${EMPTY}
    ${json_out}=    Evaluate    json.loads('''${json_data}''',strict=False)    json
    log    ${json_out}
    ${len_response_body} =  Get Length  ${pns_body}
    Run Keyword and Continue on failure    Run Keyword If   '${notification_type}' == 'pns'     Should Be Equal As Strings    ${pns_headers['host']}    ${PNS_SERVER_NAME}:${PNS_SERVICE_PORT}
    Run Keyword and Continue on failure    Run Keyword If   '${notification_type}' == 'nms'     Should Be Equal As Strings    ${pns_headers['host']}    ${NMS_SERVER_NAME}:${NMS_SERVICE_PORT}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${pns_headers['content-type']}    ${PNS_RESPONSE_CONTENT_TYPE}
    Run Keyword and Continue on failure    Run Keyword If   '${notification_type}' == 'pns'     Should Be Equal As Strings    ${pns_headers['authorization']}    Basic ${PNS_AUTHORIZATION}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${pns_headers['content-length']}    ${len_response_body}
    Run Keyword and Ignore Error    Run Keyword and Continue on Failure    Should Match Regexp    ${headers['X-mStoreFE-Addr']}    FEname:${FE_NAME}-nodeId:${NODE_ID}-ConnId:[a-zA-Z0-9]+-slot:${SLOT_ID}-instId:[0-9]+-subOid:[0-9]+-time:[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z-localFqdn:${LOCAL_FQDN}

    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['serviceName']}    ${PNS_SERVICE_NAME}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['TTL']}    ${PNS_TTL}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['recipients'][0]['uri']}    ${push_recipients_uri}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['channel']}       ${PNS_CHANNEL}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['pns-type']}    ${PNS_TYPE}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['pns-subtype']}    ${pns_subtype}

    Run Keyword and Continue on failure    Should Be Equal    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['resourceURL']}    ${pns_resource_url}
    Run Keyword and Continue on failure    Should Be Equal    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['correlationId']}    ${CORRELATION_ID}
#    Run Keyword and Continue on failure    Should Match Regexp    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['id']}    ${uid}
    Run Keyword and Continue on failure    Should Be Equal    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['store']}    ${FT_PARENT_FOLDER_PATH}
    Run Keyword and Continue on failure    Should Be Equal    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['objectURL']}    ${pns_object_Url}
    Run Keyword and Continue on failure    Should Be Equal    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['direction']}    ${direction}
    Run Keyword and Continue on failure    Should Match Regexp    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['message-time']}    [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}.000-[0-9]{2}:[0-9]{2}
    Run Keyword and Continue on failure    Should Be Equal    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['status']}    ${msgStatus}
    Run Keyword and Continue on failure    Should Be Equal    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['sender']}    ${sender}
    Run Keyword and Continue on failure    Run Keyword If   '${msg_type}' == 'group'    ValidateGroupRecepients     ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['recipients']}    ${group_members}    ELSE    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['recipients'][0]['uri']}    ${recipients_uri}
    Run Keyword and Continue on failure    Should Be Equal    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['imdn-message-id']}    ${IMDN_MESSAGE_ID}


ValidateCallHistoryPNSNotfn
    [Arguments]     ${pns_headers}   ${pns_body}   ${userId}=${SUBSCRIBER_ID}    ${direction}=${DIRECTION}   ${msgStatus}=answered    ${sender}=${MSG_FROM}    ${recipients_uri}=${MSG_TO}    ${push_recipients_uri}=${push_recipients_uri}  ${uid}=1   ${pns_subtype}=${PNS_SUBTYPE}   ${service_root_path}=${OEM_SERVER_ROOT_PATH}    ${oem_path}=${OEM_HOST_URI}    ${parentfolderkey}=${CALLHISTORY_PARENT_FOLDER_KEY}   ${msgFolderkey}=${CALLHISTORY_MESSAGE_FOLDER_KEY}  ${notification_type}=pns    ${folder_path}=${CALLHISTORY_PARENT_PATH}        ${PNS_TYPE}=${PNS_TYPE}    ${call_duration}=${CALL_DURATION}	${call_type}=Audio
    log 	${pns_headers}
    log 	${pns_body}
    ${pns_resource_url}=    Set Variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey}%3a${uid}
    ${pns_object_Url}=    Set Variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey}%3a${uid}
    ${pns_parentFolder}=    Set Variable    https://${service_root_path}${oem_path}${userId}/folders/${msgFolderkey}
    ${json_data}=    Set Variable    ${pns_body}
    ${json_data}=    Replace String    ${json_data}    \\    ${EMPTY}
    ${json_out}=    Evaluate    json.loads('''${json_data}''',strict=False)    json
    log    ${json_out}
	Set Suite Variable  ${PNS_OBJECT_URL}   ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['objectURL']}
    ${OBJECT_URL}=     Replace String       ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['objectURL']}     https://${service_root_path}    /
    Set Suite Variable  ${OBJECT_URL}
    #${status_msg}=    Split String    ${msgStatus}    ,
    #${len_msg_status}=    Get Length    ${status_msg}
    ${len_response_body} =  Get Length  ${pns_body}
    Run Keyword and Continue on failure    Run Keyword If   '${notification_type}' == 'pns'     Should Be Equal As Strings    ${pns_headers['host']}    ${PNS_SERVER_NAME}:${PNS_SERVICE_PORT}
    Run Keyword and Continue on failure    Run Keyword If   '${notification_type}' == 'nms'     Should Be Equal As Strings    ${pns_headers['host']}    ${NMS_SERVER_NAME}:${NMS_SERVICE_PORT}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${pns_headers['content-type']}    ${PNS_RESPONSE_CONTENT_TYPE}
    Run Keyword and Continue on failure    Run Keyword If   '${notification_type}' == 'pns'     Should Be Equal As Strings    ${pns_headers['authorization']}    Basic ${PNS_AUTHORIZATION} 
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${pns_headers['content-length']}    ${len_response_body}
    Run Keyword and Ignore Error    Run Keyword and Continue on Failure    Should Match Regexp    ${headers['X-mStoreFE-Addr']}    FEname:${FE_NAME}-nodeId:${NODE_ID}-ConnId:[a-zA-Z0-9]+-slot:${SLOT_ID}-instId:[0-9]+-subOid:[0-9]+-time:[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z-localFqdn:${LOCAL_FQDN} 

    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['serviceName']}    ${PNS_SERVICE_NAME}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['TTL']}    ${PNS_TTL}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['recipients'][0]['uri']}    ${push_recipients_uri}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['channel']}       ${PNS_CHANNEL}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['pns-type']}    ${PNS_TYPE}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['pns-subtype']}    ${pns_subtype}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['parentFolder']}    ${pns_parentFolder}
#    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['flags']['flag'][0]}    ${status_msg[0]}    ignore_case=True
    Run Keyword and Continue on failure    Run Keyword If    '${msgStatus}' == 'answered'	Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['flags']['flag'][0]}    ${msgStatus}    ignore_case=True		ELSE	Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['flags']['flag'][0]}    \$${msgStatus}		ignore_case=True

    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['resourceURL']}    ${pns_resource_URL}
#    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['id']}    ${uid}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['store']}    ${folder_path}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['objectURL']}    ${pns_object_Url}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['direction']}    ${direction}
    Run Keyword and Continue on failure    Should Match Regexp    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['message-time']}    [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]{3}-[0-9]{2}:[0-9]{2}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['status']}    ${msgStatus}   ignore_case=True
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['sender']}    ${sender}
    Run Keyword and Continue on failure    Run Keyword If   '${msg_type}' == 'group'    ValidateGroupRecepients     ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['recipients']}        ${group_members}    ELSE    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['recipients'][0]['uri']}    ${recipients_uri}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['call-duration']}	${call_duration} 
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['call-timestamp']}      	${MSG_DEPOSIT_TIME}             
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['participating-device']}    	${CALLHISTORY_PARTICIPATING_DEVICE}              
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['call-type']}    ${call_type}


ValidateCassandraForCallHistory_BULK
	[Arguments]    ${userId}=${USERID}    ${parent_folder_key}=${CALLHISTORY_PARENT_FOLDER_KEY}    ${message_folder_key}=${CALLHISTORY_MESSAGE_FOLDER_KEY}    ${recent}=0    ${flagged}=0 ${delivered}=0    ${answered}=0    ${messagecontext}=${MESSAGE_CONTEXT}    ${seen}=0    ${mstore_version}=vm_2_1    ${uid}=None    ${from_header}=${MSG_FROM}  ${to_header}=${msg_to}  ${msg_type}=individual  ${read_imdn_list}=${NONE}       ${delivered_imdn_list}=${NONE}      ${saved}=None
    Switch Connection    cass_db
    Write   select json * from messages_by_root_folder_timestamp where userid='${userId}' and folderkey='${message_folder_key}' ALLOW FILTERING;
    ${out}=    Read Until    ${MSTORE_CASSANDRA_KEYSPACE}\>
    ${user}=    Convert to String    ${userId}
    ${res}=    Get Lines Containing String    ${out}    ${user}
    ${messages}=    Evaluate    json.loads('''${res}''')    json
    log    ${messages}
	Write   select json * from messages_by_original_folder_timestamp where userid='${userId}' and folderkey='${message_folder_key}' ALLOW FILTERING;
    ${out}=    Read Until    ${MSTORE_CASSANDRA_KEYSPACE}\>
    ${res}=    Get Lines Containing String    ${out}    ${user}
    ${messages_by_folders}=    Evaluate    json.loads('''${res}''')    json
    log    ${messages_by_folders}

    ${members}= Set Variable    ${to_header}
    ${to_members}=  Set Variable    ${EMPTY}
    :FOR    ${member}   IN  ${members}
    \   ${to_members}=  Set Variable    ${to_members},${member}

    log     ${to_header}
    log     ${to_members}

    log     ${to_header}
    log     ${to_members}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['userid']}          ${userId}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['rootfolderkey']}   ${message_folder_key}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['recent']}          ${recent}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['deleted']}         ${flagged}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['delivered']}       ${delivered}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['folderkey']}       ${message_folder_key}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['imdn_disposition_data']}    None
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['seen']}            ${seen}
    Run Keyword and Continue on failure    Should Match Regexp           ${messages['modification_tuid']}    \\d+
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['saved']}           ${saved}


    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['userid']}       ${userId}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['folderkey']}    ${message_folder_key}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['recent']}       ${recent}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['flagged']}      ${flagged}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['delivered']}    ${delivered}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['answered']}     ${answered}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['messagecontext']}    ${messagecontext}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['seen']}         ${seen}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['mstore_version']}    ${mstore_version}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['uid']}          ${uid}
	Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['readimdnlist']}        ${read_imdn_list}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['deliveredimdnlist']}   ${delivered_imdn_list}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['fromheader']}           ${from_header}
    Run Keyword and Continue on failure    Run Keyword If   '${msg_type}' != 'group'    Should Be Equal As Strings    ${messages_by_folders['toheader']}       ${to_header}


    [Return]    ${messages_by_folders['swiftobjurl']}
	
ValidateCassandraForCallHistory
    [Arguments]    ${userId}=${USERID}    ${parent_folder_key}=${CALLHISTORY_PARENT_FOLDER_KEY}    ${message_folder_key}=${CALLHISTORY_MESSAGE_FOLDER_KEY}    ${recent}=0    ${flagged}=0    ${delivered}=0    ${answered}=0    ${messagecontext}=${MESSAGE_CONTEXT}    ${seen}=0    ${mstore_version}=vm_2_1    ${uid}=None    ${from_header}=${MSG_FROM}  ${to_header}=${msg_to}  ${msg_type}=individual	${read_imdn_list}=${NONE}       ${delivered_imdn_list}=${NONE}		${saved}=None	
    Switch Connection    cass_db
    Write   select json * from messages_by_root_folder_timestamp where userid='${userId}' and folderkey='${message_folder_key}' ALLOW FILTERING;
    ${out}=    Read Until    ${MSTORE_CASSANDRA_KEYSPACE}\>
    ${user}=    Convert to String    ${userId}
    ${res}=    Get Lines Containing String    ${out}    ${user}
    ${messages}=    Evaluate    json.loads('''${res}''')    json
    log    ${messages}
	
	#${creation_ts}=     Run     date -d "${messages['creation_tuid']}" '+%F %T.%3N'

    #Write   select json * from messages_by_original_folder_timestamp where userid='${userId}' and folderkey='${message_folder_key}' and creation_ts='${messages['creation_tuid']}' ALLOW FILTERING;
    Write   select json * from messages_by_original_folder_timestamp where userid='${userId}' and folderkey='${message_folder_key}' ALLOW FILTERING;
    ${out}=    Read Until    ${MSTORE_CASSANDRA_KEYSPACE}\>
    ${res}=    Get Lines Containing String    ${out}    ${user}
    ${messages_by_folders}=    Evaluate    json.loads('''${res}''')    json
    log    ${messages_by_folders}

    ${members}=	Set Variable    ${to_header}
    ${to_members}=  Set Variable    ${EMPTY}
    :FOR    ${member}   IN  ${members}
    \   ${to_members}=  Set Variable    ${to_members},${member}

    log     ${to_header}
    log     ${to_members}

    log     ${to_header}
    log     ${to_members}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['userid']}			${userId}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['rootfolderkey']}	${message_folder_key}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['recent']}    		${recent}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['deleted']}    		${flagged}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['delivered']}    	${delivered}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['folderkey']}    	${message_folder_key}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['imdn_disposition_data']}    None
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['seen']}    		${seen}
    Run Keyword and Continue on failure    Should Match Regexp			 ${messages['modification_tuid']}    \\d+
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['saved']}    		${saved}


    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['userid']}		${userId}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['folderkey']}    ${message_folder_key}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['recent']}    	${recent}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['flagged']}    	${flagged}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['delivered']}    ${delivered}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['answered']}    	${answered}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['messagecontext']}    ${messagecontext}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['seen']}    		${seen}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['mstore_version']}    ${mstore_version}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['uid']}    		${uid}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['readimdnlist']}        ${read_imdn_list}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['deliveredimdnlist']}   ${delivered_imdn_list}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['fromheader']}       	${from_header}
    Run Keyword and Continue on failure    Run Keyword If   '${msg_type}' != 'group'    Should Be Equal As Strings    ${messages_by_folders['toheader']}       ${to_header}

	
    [Return]    ${messages_by_folders['swiftobjurl']}


ValidateCallHistoryFolderSearchResponse
    [Arguments]     ${response}     ${direction}=${DIRECTION}    ${from_msg}=${MSG_FROM}     ${to_msg}=${MSG_TO}     ${message_context}=${MESSAGE_CONTEXT}   ${msgFolderkey}=${CALLHISTORY_MESSAGE_FOLDER_KEY}   ${uid}=${CALLHISTORY_UID}    ${msgStatus}=${CALL_STATUS}     ${service_root_path}=${OEM_SERVER_ROOT_PATH}    ${oem_path}=${OEM_HOST_URI}     ${userId}=${SUBSCRIBER_ID}  ${no_of_msgs}=1     ${msg_type}=individual 

    ${to}=  Run Keyword If  '${msg_type}' == 'individual'   Create List     ${to_msg}   ELSE    Copy List   ${to_msg}

    ${status_msg}=    Split String    ${msgStatus}    ,
    ${len_msg_status}=    Get Length    ${status_msg}
    log    ${response.headers}   
    ${data}=    set Variable    ${response.json()}
    log    ${data}
    ${list_of_objects}=    Get Length    ${data['objectList']['object']}
    Run Keyword and Continue On Failure     Should Be Equal As Strings  ${list_of_objects}  ${no_of_msgs}
    :FOR    ${index}    IN RANGE    0    ${list_of_objects}
    \    ${Attributes_pair}=    Get_FolderSearch_AttributesPair    ${data['objectList']['object'][${index}]['attributes']['attribute']}
    \    log    ${Attributes_pair}
  #  \    ${uid}=    Evaluate    ${index} + 1
    \    ${obj_parentFolder}=   Set Variable    https://${service_root_path}${oem_path}${userId}/folders/${msgFolderkey}
    \    ${obj_resourceURL}=    Set variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey}%3a${uid}
    \    ${obj_Folderpath}=     Set Variable    /${CALLHISTORY_PARENT_PATH}/${msgFolderkey}%3a${uid}
    \    Run Keyword and Continue on failure    Should Be Equal As Strings    ${data['objectList']['object'][${index}]['parentFolder']}    ${obj_parentFolder}
    \    Run Keyword and Continue on failure    Should Be Equal As Strings    ${data['objectList']['object'][${index}]['resourceURL']}    ${obj_resourceURL}
    \    Run Keyword and Continue on failure    Should Be Equal As Strings    ${data['objectList']['object'][${index}]['path']}    ${obj_Folderpath}
    \    Run Keyword and Continue on failure    Should Be Equal As Strings    ${data['objectList']['object'][${index}]['flags']['flag'][0]}    ${status_msg[0]}    ignore_case=True
    \    Run Keyword and Continue on failure    Run Keyword If    ${len_msg_status} > 1    Should Be Equal As Strings    ${data['objectList']['object'][${index}]['flags']['flag'][1]}    ${status_msg[1]}    ignore_case=True
    \    Run Keyword and Continue on failure    Should Be Equal As Strings    ${data['objectList']['object'][${index}]['flags']['resourceURL']}    ${obj_resourceURL}/flags
    \    Run Keyword and Continue on failure    Should Be Equal As Strings    ${Attributes_pair['call-duration'][0]}    ${CALL_DURATION}
    \    Run Keyword and Continue on failure    Should Be Equal As Strings    ${Attributes_pair['call-timestamp'][0]}    ${MSG_DEPOSIT_TIME}
    \    Run Keyword and Continue on failure    Should Be Equal As Strings    ${Attributes_pair['call-type'][0]}    ${CALL_TYPE}
    \    Run Keyword and Continue on failure    Should Be Equal As Strings    ${Attributes_pair['date'][0]}    ${MSG_DEPOSIT_TIME}
    \    Run Keyword and Continue on failure    Should Be Equal As Strings    ${Attributes_pair['Direction'][0]}    ${direction}
    \    Run Keyword and Continue on failure    Should Be Equal As Strings    ${Attributes_pair['from'][0]}    ${from_msg}
    \    Run Keyword and Continue on failure    Should Be Equal As Strings    ${Attributes_pair['message-context'][0]}    ${message_context}
    \    Run Keyword and Continue on failure    Should Be Equal As Strings    ${Attributes_pair['participating-device'][0]}    ${CALLHISTORY_PARTICIPATING_DEVICE}
    \    Run Keyword and Continue on failure    Should Be Equal As Strings    ${Attributes_pair['to'][0]}    ${to_msg}


ValidateCallHistoryFetchResponse
    [Arguments]     ${response}     ${direction}=${DIRECTION}    ${from_msg}=${MSG_FROM}     ${to_msg}=${MSG_TO}     ${message_context}=${MESSAGE_CONTEXT}   ${msgFolderkey}=${CALLHISTORY_MESSAGE_FOLDER_KEY}   ${uid}=1    ${msgStatus}=${CALL_STATUS}     ${service_root_path}=${OEM_SERVER_ROOT_PATH}    ${oem_path}=${OEM_HOST_URI}     ${userId}=${SUBSCRIBER_ID}   ${msg_type}=individual	${folder_Path}=${CALLHISTORY_PARENT_PATH}

    ${to}=  Run Keyword If  '${msg_type}' == 'individual'   Create List     ${to_msg}   ELSE    Copy List   ${to_msg}
    ${obj_resourceURL}=    Set Variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey}%3a${uid}
    ${obj_objectUrl}=    Set Variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey}%3a${uid}
    ${obj_parentFolder}=    Set Variable    https://${service_root_path}${oem_path}${userId}/folders/${msgFolderkey}
    ${obj_Folderpath}=    Set Variable    /${folder_Path}/${msgFolderkey}%3a${uid}
    ${status_msg}=    Split String    ${msgStatus}    ,
    ${len_msg_status}=    Get Length    ${status_msg}

    ${data}=    Set Variable    ${response.json()}
    log    ${data}
    ${attributes}=    Set Variable    ${data['object']['attributes']['attribute']}

    ${Attributes_pair}=    Create Dictionary
    :FOR    ${pair}    IN    @{attributes}
    \    log    ${pair['name']}
    \    log    ${pair['value']}
    \    Set To Dictionary    ${Attributes_pair}    ${pair['name']}    ${pair['value']}
    log    ${Attributes_pair}
    Run Keyword and Continue on failure    Should Be Equal    ${data['object']['parentFolder']}    ${obj_parentFolder}
    Run Keyword and Continue on failure    Should Be Equal    ${data['object']['resourceURL']}    ${obj_resourceURL}
    Run Keyword and Continue on failure    Should Be Equal    ${data['object']['path']}    ${obj_Folderpath}
    Run Keyword and Continue on failure    Should Be Equal    ${data['object']['flags']['flag'][0]}    ${status_msg[0]}    ignore_case=True
    Run Keyword and Continue on failure    Run Keyword If    ${len_msg_status} > 1    Should Be Equal    ${data['object']['flags']['flag'][1]}    ${status_msg[1]}    ignore_case=True
    Run Keyword and Continue on failure    Should Be Equal    ${data['object']['flags']['resourceURL']}    ${obj_resourceURL}/flags

    Run Keyword and Continue on failure    Should Be Equal As Strings    ${Attributes_pair['call-duration'][0]}    ${CALL_DURATION}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${Attributes_pair['call-timestamp'][0]}    ${MSG_DEPOSIT_TIME}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${Attributes_pair['call-type'][0]}    ${CALL_TYPE}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${Attributes_pair['date'][0]}    ${MSG_DEPOSIT_TIME}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${Attributes_pair['Direction'][0]}    ${direction}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${Attributes_pair['from'][0]}    ${from_msg}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${Attributes_pair['message-context'][0]}    ${message_context}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${Attributes_pair['participating-device'][0]}    ${CALLHISTORY_PARTICIPATING_DEVICE}
    Run Keyword and Continue on failure    Run Keyword If  '${msg_type}' == 'individual'   Should Be Equal As Strings    ${Attributes_pair['to'][0]}    ${to_msg}    ELSE    ValidateGroupToMessages     ${Attributes_pair['to']}    ${to_msg}


ValidateCallHistoryDeletePNSNotfn
    [Arguments]     ${pns_headers}   ${pns_body}   ${userId}=${SUBSCRIBER_ID}    ${direction}=${DIRECTION}   ${msgStatus}=${CALL_STATUS}    ${sender}=${MSG_FROM}    ${recipients_uri}=${MSG_TO}    ${push_recipients_uri}=${push_recipients_uri}  ${uid}=1   ${pns_subtype}=${PNS_SUBTYPE}   ${service_root_path}=${OEM_SERVER_ROOT_PATH}    ${oem_path}=${OEM_HOST_URI}    ${parentfolderkey}=${CALLHISTORY_PARENT_FOLDER_KEY}   ${msgFolderkey}=${CALLHISTORY_MESSAGE_FOLDER_KEY}  ${notification_type}=pns    ${folder_path}=${CALLHISTORY_PARENT_PATH}        ${PNS_TYPE}=${PNS_TYPE}    ${call_duration}=${CALL_DURATION} ${call_type}=Audio
    log     ${pns_headers}
    log     ${pns_body}
    ${pns_resource_url}=    Set Variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey}%3a${uid}
    ${pns_object_Url}=    Set Variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey}%3a${uid}
    ${pns_parentFolder}=    Set Variable    https://${service_root_path}${oem_path}${userId}/folders/${msgFolderkey}
    ${json_data}=    Set Variable    ${pns_body}
    ${json_data}=    Replace String    ${json_data}    \\    ${EMPTY}
    ${json_out}=    Evaluate    json.loads('''${json_data}''',strict=False)    json
    log    ${json_out}
    ${OBJECT_URL}=     Replace String       ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['objectURL']}     https://${service_root_path}    /
    Set Suite Variable  ${OBJECT_URL}
    ${status_msg}=    Split String    ${msgStatus}    ,
    ${len_msg_status}=    Get Length    ${status_msg}
    ${len_response_body} =  Get Length  ${pns_body}
    Run Keyword and Continue on failure    Run Keyword If   '${notification_type}' == 'pns'     Should Be Equal As Strings    ${pns_headers['host']}    ${PNS_SERVER_NAME}:${PNS_SERVICE_PORT}
    Run Keyword and Continue on failure    Run Keyword If   '${notification_type}' == 'nms'     Should Be Equal As Strings    ${pns_headers['host']}    ${NMS_SERVER_NAME}:${NMS_SERVICE_PORT}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${pns_headers['content-type']}    ${PNS_RESPONSE_CONTENT_TYPE}
    Run Keyword and Continue on failure    Run Keyword If   '${notification_type}' == 'pns'     Should Be Equal As Strings    ${pns_headers['authorization']}    Basic ${PNS_AUTHORIZATION}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${pns_headers['content-length']}    ${len_response_body}
#    Run Keyword and Ignore Error    Run Keyword and Continue on Failure    Should Match Regexp    ${headers['X-mStoreFE-Addr']}    FEname:${FE_NAME}-nodeId:${NODE_ID}-ConnId:[a-zA-Z0-9]+-slot:${SLOT_ID}-instId:[0-9]+-subOid:[0-9]+-time:[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z-localFqdn:${LOCAL_FQDN}

    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['serviceName']}    ${PNS_SERVICE_NAME}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['TTL']}    ${PNS_TTL}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['recipients'][0]['uri']}    ${push_recipients_uri}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['channel']}       ${PNS_CHANNEL}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['pns-type']}    ${PNS_TYPE}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['pns-subtype']}    ${pns_subtype}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['resourceURL']}    ${pns_resource_URL}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['id']}    ${uid}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['store']}    ${folder_path}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['objectURL']}    ${pns_object_Url}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['direction']}    ${direction}
    Run Keyword and Continue on failure    Should Match Regexp    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['message-time']}    [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}-[0-9]{2}:[0-9]{2}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['sender']}    ${sender}
    Run Keyword and Continue on failure    Run Keyword If   '${msg_type}' == 'group'    ValidateGroupRecepients     ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['recipients']}        ${group_members}    ELSE    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['recipients'][0]['uri']}    ${recipients_uri}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['call-type']}    ${call_type}

ValidateUpdateCallHistoryPNSNotfn
    [Arguments]     ${pns_headers}   ${pns_body}   ${userId}=${SUBSCRIBER_ID}    ${direction}=${DIRECTION}   ${msgStatus}=${CALL_STATUS}    ${sender}=${MSG_FROM}    ${recipients_uri}=${MSG_TO}    ${push_recipients_uri}=${push_recipients_uri}  ${uid}=1   ${pns_subtype}=${PNS_SUBTYPE}   ${service_root_path}=${OEM_SERVER_ROOT_PATH}    ${oem_path}=${OEM_HOST_URI}    ${parentfolderkey}=${CALLHISTORY_PARENT_FOLDER_KEY}   ${msgFolderkey}=${CALLHISTORY_MESSAGE_FOLDER_KEY}  ${notification_type}=pns    ${folder_path}=${CALLHISTORY_PARENT_PATH}        ${PNS_TYPE}=${PNS_TYPE}    ${call_duration}=${CALL_DURATION} ${call_type}=Audio
    log     ${pns_headers}
    log     ${pns_body}
    ${pns_resource_url}=    Set Variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey}%3a${uid}
    ${pns_object_Url}=    Set Variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey}%3a${uid}
    ${pns_parentFolder}=    Set Variable    https://${service_root_path}${oem_path}${userId}/folders/${msgFolderkey}
    ${json_data}=    Set Variable    ${pns_body}
    ${json_data}=    Replace String    ${json_data}    \\    ${EMPTY}
    ${json_out}=    Evaluate    json.loads('''${json_data}''',strict=False)    json
    log    ${json_out}
    #${OBJECT_URL}=     Replace String       ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['objectURL']}     https://${service_root_path}    /
    #Set Suite Variable  ${OBJECT_URL}
    ${status_msg}=    Split String    ${msgStatus}    ,
    ${len_msg_status}=    Get Length    ${status_msg}
    ${len_response_body} =  Get Length  ${pns_body}
    Run Keyword and Continue on failure    Run Keyword If   '${notification_type}' == 'pns'     Should Be Equal As Strings    ${pns_headers['host']}    ${PNS_SERVER_NAME}:${PNS_SERVICE_PORT}
    Run Keyword and Continue on failure    Run Keyword If   '${notification_type}' == 'nms'     Should Be Equal As Strings    ${pns_headers['host']}    ${NMS_SERVER_NAME}:${NMS_SERVICE_PORT}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${pns_headers['content-type']}    ${PNS_RESPONSE_CONTENT_TYPE}
    Run Keyword and Continue on failure    Run Keyword If   '${notification_type}' == 'pns'     Should Be Equal As Strings    ${pns_headers['authorization']}    Basic ${PNS_AUTHORIZATION}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${pns_headers['content-length']}    ${len_response_body}
#    Run Keyword and Ignore Error    Run Keyword and Continue on Failure    Should Match Regexp    ${headers['X-mStoreFE-Addr']}    FEname:${FE_NAME}-nodeId:${NODE_ID}-ConnId:[a-zA-Z0-9]+-slot:${SLOT_ID}-instId:[0-9]+-subOid:[0-9]+-time:[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z-localFqdn:${LOCAL_FQDN}

    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['serviceName']}    ${PNS_SERVICE_NAME}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['TTL']}    ${PNS_TTL}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['recipients'][0]['uri']}    ${push_recipients_uri}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['channel']}       ${PNS_CHANNEL}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['pns-type']}    ${PNS_TYPE}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['pns-subtype']}    ${pns_subtype}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['parentFolder']}    ${pns_parentFolder}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['flags']['flag'][0]}    ${status_msg[0]}    ignore_case=True
    Run Keyword and Continue on failure    Run Keyword If    ${len_msg_status} > 1    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['flags']['flag'][1]}    ${status_msg[1]}     ignore_case=True

    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['resourceURL']}    ${pns_resource_URL}
#    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['id']}    ${uid}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['store']}    ${folder_path}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['objectURL']}    ${pns_object_Url}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['direction']}    ${direction}
    Run Keyword and Continue on failure    Should Match Regexp    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['message-time']}    [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]{3}-[0-9]{2}:[0-9]{2}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['status']}    ${msgStatus}   ignore_case=True
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['sender']}    ${sender}
    Run Keyword and Continue on failure    Run Keyword If   '${msg_type}' == 'group'    ValidateGroupRecepients     ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['recipients']}        ${group_members}    ELSE    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['recipients'][0]['uri']}    ${recipients_uri} 
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['call-type']}    ${call_type}


ValidateFaxPNSNotfn
    [Arguments]     ${pns_headers}   ${pns_body}   ${userId}=${SUBSCRIBER_ID}    ${direction}=${DIRECTION}   ${msgStatus}=RECENT    ${sender}=${MSG_FROM}    ${recipients_uri}=${MSG_TO}    ${push_recipients_uri}=${push_recepient_uri}  ${uid}=1   ${pns_subtype}=${PNS_SUBTYPE}   ${service_root_path}=${OEM_SERVER_ROOT_PATH}    ${oem_path}=${OEM_HOST_URI}    ${parentfolderkey}=${FAX_PARENT_FOLDER_KEY}   ${msgFolderkey}=${FAX_MESSAGE_FOLDER_KEY}   ${notification_type}=pns    ${folder_path}=${FAX_PARENT_FOLDER_PATH}        ${PNS_TYPE}=${PNS_TYPE}   ${msg_type}=individual  ${group_members}=${MSG_TO_GROUP_MEMBERS}

    log     ${pns_headers}
    log     ${pns_body}
    ${pns_resource_url}=    Set Variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey}%3a${uid}
    ${pns_object_Url}=    Set Variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey}%3a${uid}
    ${pns_parentFolder}=    Set Variable    https://${service_root_path}${oem_path}${userId}/folders/${msgFolderkey}
    ${json_data}=    Set Variable    ${pns_body}
    ${json_data}=    Replace String    ${json_data}    \\    ${EMPTY}
    ${json_out}=    Evaluate    json.loads('''${json_data}''',strict=False)    json
    log    ${json_out}
	Set Suite Variable  ${PNS_OBJECT_URL}   ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['objectURL']}
    ${OBJECT_URL}=     Replace String       ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['objectURL']}     https://${service_root_path}    /
    Set Suite Variable  ${OBJECT_URL}
    ${status_msg}=    Split String    ${msgStatus}    ,
    ${len_msg_status}=    Get Length    ${status_msg}
    ${len_response_body} =  Get Length  ${pns_body}
    Run Keyword and Continue on failure    Run Keyword If   '${notification_type}' == 'pns'     Should Be Equal As Strings    ${pns_headers['host']}    ${PNS_SERVER_NAME}:${PNS_SERVICE_PORT}
    Run Keyword and Continue on failure    Run Keyword If   '${notification_type}' == 'nms'     Should Be Equal As Strings    ${pns_headers['host']}    ${NMS_SERVER_NAME}:${NMS_SERVICE_PORT}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${pns_headers['content-type']}    ${PNS_RESPONSE_CONTENT_TYPE}
    Run Keyword and Continue on failure    Run Keyword If   '${notification_type}' == 'pns'     Should Be Equal As Strings    ${pns_headers['authorization']}    Basic ${PNS_AUTHORIZATION}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${pns_headers['content-length']}    ${len_response_body}
    Run Keyword and Ignore Error    Run Keyword and Continue on Failure    Should Match Regexp    ${headers['X-mStoreFE-Addr']}    FEname:${FE_NAME}-nodeId:${NODE_ID}-ConnId:[a-zA-Z0-9]+-slot:${SLOT_ID}-instId:[0-9]+-subOid:[0-9]+-time:[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z-localFqdn:${LOCAL_FQDN}

    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['serviceName']}    ${PNS_SERVICE_NAME}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['TTL']}    ${PNS_TTL}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['recipients'][0]['uri']}    ${push_recipients_uri}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['channel']}       ${PNS_CHANNEL}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['pns-type']}    ${PNS_TYPE}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['pns-subtype']}    ${pns_subtype}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['parentFolder']}    ${pns_parentFolder}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['flags']['flag'][0]}    ${status_msg[0]}    ignore_case=True 
    Run Keyword and Continue on failure    Run Keyword If    ${len_msg_status} > 1    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['flags']['flag'][1]}    ${status_msg[1]}     ignore_case=True
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['resourceURL']}    ${pns_resource_URL}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['correlationId']}    ${CORRELATION_ID}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['id']}    ${uid}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['store']}    ${folder_path}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['objectURL']}    ${pns_object_Url}
#    Run Keyword and Continue on failure    Run Keyword If   '${multipart}' == 'true'    Should Match Regexp   ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['objectIconURL']}    ${pns_object_Icon_Url}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['direction']}    ${direction}
    Run Keyword and Continue on failure    Should Match Regexp    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['message-time']}    [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}-[0-9]{2}:[0-9]{2}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['status']}    ${msgStatus}   ignore_case=True
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['sender']}    ${sender}
    Run Keyword and Continue on failure    Run Keyword If   '${msg_type}' == 'group'    ValidateGroupRecepients     ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['recipients']}        ${group_members}    ELSE    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['recipients'][0]['uri']}    ${recipients_uri}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['changedObject']['message']['message-id']}    ${IMDN_MESSAGE_ID}


ValidateCassandraForFaxMessages
    [Arguments]    ${userId}=${USERID}    ${parent_folder_key}=${FAX_PARENT_FOLDER_KEY}    ${message_folder_key}=${FAX_MESSAGE_FOLDER_KEY}    ${recent}=1    ${flagged}=0    ${delivered}=0    ${answered}=0    ${messagecontext}=${MESSAGE_CONTEXT}    ${seen}=0    ${mstore_version}=vm_2_1    ${uid}=1    ${from_header}=${MSG_FROM}  ${to_header}=${msg_to}  ${msg_type}=individual
    Switch Connection    cass_db
    Write   select json * from messages where userid='${userId}' and uid=${uid} and folderkey='${message_folder_key}';
    ${out}=    Read Until    ${MSTORE_CASSANDRA_KEYSPACE}\>
    ${user}=    Convert to String    ${userId}
    ${res}=    Get Lines Containing String    ${out}    ${user}
    ${messages}=    Evaluate    json.loads('''${res}''')    json
    log    ${messages}
    Write   select json * from messages_by_folder_timestamp where userid='${userId}' and folderkey='${parent_folder_key}' and creation_ts='${messages["creation_ts"]}' and uid=${uid} ALLOW FILTERING;
    ${out}=    Read Until    ${MSTORE_CASSANDRA_KEYSPACE}\>
    ${res}=    Get Lines Containing String    ${out}    ${user}
    ${messages_by_folders}=    Evaluate    json.loads('''${res}''')    json
    log    ${messages_by_folders}

    ${members}=  Set Variable    ${to_header}
    ${to_members}=  Set Variable    ${EMPTY}
    :FOR    ${member}   IN  ${members}
    \   ${to_members}=  Set Variable    ${to_members},${member}

    log     ${to_header}
    log     ${to_members}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['userid']}    ${userId}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['folderkey']}    ${message_folder_key}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['recent']}    ${recent}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['flagged']}    ${flagged}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['delivered']}    ${delivered}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['answered']}    ${answered}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['messagecontext']}    ${messagecontext}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['seen']}    ${seen}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['mstore_version']}    ${mstore_version}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['uid']}    ${uid}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages['fromheader']}       ${from_header}
    Run Keyword and Continue on failure    Run Keyword If   '${msg_type}' != 'group'    Should Be Equal As Strings    ${messages['toheader']}       ${to_header}    #ELSE   Should Be Equal As Strings      ${messages['toheader']}     ${to_members}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['userid']}    ${userId}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['folderkey']}    ${parent_folder_key}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['recent']}    ${recent}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['flagged']}    ${flagged}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['delivered']}    ${delivered}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['answered']}    ${answered}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['messagecontext']}    ${messagecontext}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['seen']}    ${seen}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['mstore_version']}    ${mstore_version}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['uid']}    ${uid}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${messages_by_folders['fromheader']}       ${from_header}
    Run Keyword and Continue on failure    Run Keyword If   '${msg_type}' != 'group'    Should Be Equal As Strings    ${messages_by_folders['toheader']}       ${to_header}
    [Return]    ${messages['swiftobjurl']}


ValidateFAXFolderSearchResponse
    [Arguments]     ${response}     ${direction}=${DIRECTION}    ${from_msg}=${MSG_FROM}     ${to_msg}=${MSG_TO}     ${message_context}=${MESSAGE_CONTEXT}   ${msgFolderkey}=${FAX_MESSAGE_FOLDER_KEY}   ${uid}=1    ${msgStatus}=Recent     ${service_root_path}=${OEM_SERVER_ROOT_PATH}    ${oem_path}=${OEM_HOST_URI}     ${userId}=${SUBSCRIBER_ID}  ${no_of_msgs}=1     ${msg_type}=individual    ${sw_acct_id}=${SWIFTACCOUNTID}   ${swift_base_url}=${OPENSTACK_SWIFT_BASE_URL}   ${multipart}=false

    ${to}=  Run Keyword If  '${msg_type}' == 'individual'   Create List     ${to_msg}   ELSE    Copy List   ${to_msg}

    ${status_msg}=    Split String    ${msgStatus}    ,
    ${len_msg_status}=    Get Length    ${status_msg}
    log    ${response.headers}
    ${data}=    set Variable    ${response.json()}
    log    ${data}
    ${list_of_objects}=    Get Length    ${data['objectList']['object']}
    Run Keyword and Continue On Failure     Should Be Equal As Strings  ${list_of_objects}  ${no_of_msgs}
    :FOR    ${index}    IN RANGE    0    ${list_of_objects}
    \    ${Attributes_pair}=    Get_FolderSearch_AttributesPair    ${data['objectList']['object'][${index}]['attributes']['attribute']}
    \    log    ${Attributes_pair}
    \    ${uid}=    Evaluate    ${index} + 1
    \    ${obj_parentFolder}=   Set Variable    https://${service_root_path}${oem_path}${userId}/folders/${msgFolderkey}
    \    ${obj_resourceURL}=    Set variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey}%3a${uid}
    \    ${obj_Folderpath}=     Set Variable    /${FAX_PARENT_FOLDER_PATH}/${msgFolderkey}%3a${uid}
    \    ${obj_payloadURL}=    Set variable    https://${service_root_path}${oem_path}${userId}/objects/${message_context}${swift_base_url}/${sw_acct_id}/${CONTAINER_INFO['${FAX_PARENT_FOLDER_PATH}']}/[0-9]+%3a${msgFolderkey}%3a${uid}

    \    Run Keyword and Continue on failure    Should Match Regexp    ${data['objectList']['object'][${index}]['payloadURL']}    ${obj_payloadURL}
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['parentFolder']}    ${obj_parentFolder}
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['resourceURL']}    ${obj_resourceURL}
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['path']}    ${obj_Folderpath}
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['correlationId']}    ${CORRELATION_ID}
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['flags']['flag'][0]}    \\${status_msg[0]}    ignore_case=True
    \    Run Keyword and Continue on failure    Run Keyword If    ${len_msg_status} > 1    Should Be Equal    ${data['objectList']['object'][${index}]['flags']['flag'][1]}    \\${status_msg[1]}    ignore_case=True
    \    Run Keyword and Continue on failure    Should Be Equal    ${data['objectList']['object'][${index}]['flags']['resourceURL']}    ${obj_resourceURL}/flags
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['content-type'][0]}   ${FAX_CONTENT_TYPE}
    \    Run Keyword and Continue on failure    Should Match Regexp    ${Attributes_pair['date'][0]}    [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Direction'][0]}    ${direction}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['from'][0]}    ${from_msg}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Message-Id'][0]}    ${FAX_MESSAGE_ID}
    \    Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['message-context'][0]}    ${message_context}
    \    Run Keyword and Continue on failure    Run Keyword If  '${msg_type}' == 'individual'   Should Be Equal    ${Attributes_pair['to'][0]}    ${to_msg}     ELSE    ValidateGroupToMessages     ${Attributes_pair['to']}    ${to_msg}
    \	${href}=    Set Variable    ${obj_payloadURL}/payloadParts/part1
	\   Run Keyword and Continue on Failure     Should Be Equal As Strings  ${data['objectList']['object'][${index}]['payloadPart'][0]['contentType']}    application/pdf
    \	Run Keyword and Continue on Failure     Should Be Equal As Strings  ${data['objectList']['object'][${index}]['payloadPart'][0]['contentDisposition']}     attachment; filename="test123.pdf"
    \	Run Keyword and Continue on Failure     Should Be Equal As Strings  ${data['objectList']['object'][${index}]['payloadPart'][0]['contentEncoding']}   base64
    \	Run Keyword and Continue on Failure     Should Match Regexp  ${data['objectList']['object'][${index}]['payloadPart'][0]['href']}      ${href}
    \	${FAX_PAYLOAD_PART}=   Replace String   ${data['objectList']['object'][${index}]['payloadPart'][0]['href']}    https://${service_root_path}    /
    \	Set Suite Variable  ${FAX_PAYLOAD_PART}


ValidateFAXFetchResponse
    [Arguments]     ${response}     ${direction}=${DIRECTION}    ${from_msg}=${MSG_FROM}     ${to_msg}=${MSG_TO}     ${message_context}=${MESSAGE_CONTEXT}   ${msgFolderkey}=${FAX_MESSAGE_FOLDER_KEY}   ${uid}=1    ${msgStatus}=Recent     ${service_root_path}=${OEM_SERVER_ROOT_PATH}    ${oem_path}=${OEM_HOST_URI}     ${userId}=${SUBSCRIBER_ID}  ${no_of_msgs}=1     ${msg_type}=individual    ${sw_acct_id}=${SWIFTACCOUNTID}   ${swift_base_url}=${OPENSTACK_SWIFT_BASE_URL}   ${multipart}=false		${folder_Path}=${FAX_PARENT_FOLDER_PATH}

    ${to}=  Run Keyword If  '${msg_type}' == 'individual'   Create List     ${to_msg}   ELSE    Copy List   ${to_msg}
    ${obj_resourceURL}=    Set Variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey}%3a${uid}
    ${obj_objectUrl}=    Set Variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey}%3a${uid}
    ${obj_parentFolder}=    Set Variable    https://${service_root_path}${oem_path}${userId}/folders/${msgFolderkey}
    ${obj_Folderpath}=    Set Variable    /${folder_Path}/${msgFolderkey}%3a${uid}
    ${obj_payloadURL}=    Set variable    https://${service_root_path}${oem_path}${userId}/objects/${message_context}${swift_base_url}/${sw_acct_id}/${CONTAINER_INFO['${folder_Path}']}/[0-9]+%3a${msgFolderkey}%3a${uid}

    ${status_msg}=    Split String    ${msgStatus}    ,
    ${len_msg_status}=    Get Length    ${status_msg}

    ${data}=    Set Variable    ${response.json()}
    log    ${data}
    ${attributes}=    Set Variable    ${data['object']['attributes']['attribute']}

    ${Attributes_pair}=    Create Dictionary
    :FOR    ${pair}    IN    @{attributes}
    \    log    ${pair['name']}
    \    log    ${pair['value']}
    \    Set To Dictionary    ${Attributes_pair}    ${pair['name']}    ${pair['value']}
    log    ${Attributes_pair}
    Run Keyword and Continue on failure    Should Match Regexp    ${data['object']['payloadURL']}    ${obj_payloadURL}
    Run Keyword and Continue on failure    Should Be Equal    ${data['object']['parentFolder']}    ${obj_parentFolder}
    Run Keyword and Continue on failure    Should Be Equal    ${data['object']['resourceURL']}    ${obj_resourceURL}
    Run Keyword and Continue on failure    Should Be Equal    ${data['object']['path']}    ${obj_Folderpath}
    Run Keyword and Continue on failure    Should Be Equal    ${data['object']['correlationId']}    ${CORRELATION_ID}
    Run Keyword and Continue on failure    Should Be Equal    ${data['object']['flags']['flag'][0]}    \\${status_msg[0]}    ignore_case=True
    Run Keyword and Continue on failure    Run Keyword If    ${len_msg_status} > 1    Should Be Equal    ${data['object']['flags']['flag'][1]}    \\${status_msg[1]}    ignore_case=True
    Run Keyword and Continue on failure    Should Be Equal    ${data['object']['flags']['resourceURL']}    ${obj_resourceURL}/flags

	Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['content-type'][0]}   ${FAX_CONTENT_TYPE}
	Run Keyword and Continue on failure    Should Match Regexp    ${Attributes_pair['date'][0]}    [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z
	Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Direction'][0]}    ${direction}
	Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['from'][0]}    ${from_msg}
	Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['Message-Id'][0]}    ${FAX_MESSAGE_ID}
	Run Keyword and Continue on failure    Should Be Equal    ${Attributes_pair['message-context'][0]}    ${message_context}
	Run Keyword and Continue on failure    Run Keyword If  '${msg_type}' == 'individual'   Should Be Equal    ${Attributes_pair['to'][0]}    ${to_msg}     ELSE		ValidateGroupToMessages     ${Attributes_pair['to']}    ${to_msg}
	${href}=    Set Variable    ${obj_payloadURL}/payloadParts/part1
	Run Keyword and Continue on Failure     Should Be Equal As Strings  ${data['object']['payloadPart'][0]['contentType']}    application/pdf
	Run Keyword and Continue on Failure     Should Be Equal As Strings  ${data['object']['payloadPart'][0]['contentDisposition']}     attachment; filename="test123.pdf"
	Run Keyword and Continue on Failure     Should Be Equal As Strings  ${data['object']['payloadPart'][0]['contentEncoding']}   base64
	Run Keyword and Continue on Failure     Should Match Regexp  ${data['object']['payloadPart'][0]['href']}      ${href}
	${FAX_PAYLOAD_PART}=   Replace String   ${data['object']['payloadPart'][0]['href']}    https://${service_root_path}    /
	${FAX_PAYLOAD_URL}=		 Replace String		${data['object']['payloadURL']}		https://${service_root_path}    /
	Set Suite Variable  ${FAX_PAYLOAD_PART}
	Set Suite Variable	${FAX_PAYLOAD_URL}

ValidateFAXDeletePNSNotfn
    [Arguments]     ${pns_headers}   ${pns_body}   ${userId}=${SUBSCRIBER_ID}    ${direction}=${DIRECTION}   ${msgStatus}=RECENT    ${sender}=${MSG_FROM}    ${recipients_uri}=${MSG_TO}    ${push_recipients_uri}=${push_recepient_uri}  ${uid}=1   ${pns_subtype}=${PNS_SUBTYPE}   ${service_root_path}=${OEM_SERVER_ROOT_PATH}    ${oem_path}=${OEM_HOST_URI}    ${parentfolderkey}=${FAX_PARENT_FOLDER_KEY}   ${msgFolderkey}=${FAX_MESSAGE_FOLDER_KEY}    ${notification_type}=pns        ${PNS_TYPE}=${PNS_TYPE}    ${msg_type}=individual      ${group_members}=${MSG_TO_GROUP_MEMBERS}

    log     ${pns_headers}
    log     ${pns_body}
    ${pns_resource_url}=    Set Variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey}%3a${uid}
    ${pns_object_Url}=    Set Variable    https://${service_root_path}${oem_path}${userId}/objects/${msgFolderkey}%3a${uid}
    ${pns_parentFolder}=    Set Variable    https://${service_root_path}${oem_path}${userId}/folders/${msgFolderkey}
    ${json_data}=    Set Variable    ${pns_body}
    ${json_data}=    Replace String    ${json_data}    \\    ${EMPTY}
    ${json_out}=    Evaluate    json.loads('''${json_data}''',strict=False)    json
    log    ${json_out}
    ${len_response_body} =  Get Length  ${pns_body}
    Run Keyword and Continue on failure    Run Keyword If   '${notification_type}' == 'pns'     Should Be Equal As Strings    ${pns_headers['host']}    ${PNS_SERVER_NAME}:${PNS_SERVICE_PORT}
    Run Keyword and Continue on failure    Run Keyword If   '${notification_type}' == 'nms'     Should Be Equal As Strings    ${pns_headers['host']}    ${NMS_SERVER_NAME}:${NMS_SERVICE_PORT}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${pns_headers['content-type']}    ${PNS_RESPONSE_CONTENT_TYPE}
    Run Keyword and Continue on failure    Run Keyword If   '${notification_type}' == 'pns'     Should Be Equal As Strings    ${pns_headers['authorization']}    Basic ${PNS_AUTHORIZATION}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${pns_headers['content-length']}    ${len_response_body}
    Run Keyword and Ignore Error    Run Keyword and Continue on Failure    Should Match Regexp    ${headers['X-mStoreFE-Addr']}    FEname:${FE_NAME}-nodeId:${NODE_ID}-ConnId:[a-zA-Z0-9]+-slot:${SLOT_ID}-instId:[0-9]+-subOid:[0-9]+-time:[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z-localFqdn:${LOCAL_FQDN}

    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['serviceName']}    ${PNS_SERVICE_NAME}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['TTL']}    ${PNS_TTL}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['recipients'][0]['uri']}    ${push_recipients_uri}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['channel']}       ${PNS_CHANNEL}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['pns-type']}    ${PNS_TYPE}
    Run Keyword and Continue on failure    Should Be Equal As Strings    ${json_out['push-message']['pns-subtype']}    ${pns_subtype}

    Run Keyword and Continue on failure    Should Be Equal    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['resourceURL']}    ${pns_resource_url}
    Run Keyword and Continue on failure    Should Be Equal    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['correlationId']}    ${CORRELATION_ID}
    Run Keyword and Continue on failure    Should Match Regexp    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['id']}    ${uid}
    Run Keyword and Continue on failure    Should Be Equal    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['store']}    ${FAX_PARENT_FOLDER_PATH}
    Run Keyword and Continue on failure    Should Be Equal    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['objectURL']}    ${pns_object_Url}
    Run Keyword and Continue on failure    Should Be Equal    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['direction']}    ${direction}
    Run Keyword and Continue on failure    Should Match Regexp    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['message-time']}    [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}-[0-9]{2}:[0-9]{2}
    Run Keyword and Continue on failure    Should Be Equal    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['status']}    ${msgStatus}
    Run Keyword and Continue on failure    Should Be Equal    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['sender']}    ${sender}
    Run Keyword and Continue on failure    Run Keyword If   '${msg_type}' == 'group'    ValidateGroupRecepients     ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['recipients']}    ${group_members}    ELSE    Should Be Equal As Strings    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['recipients'][0]['uri']}    ${recipients_uri}
    Run Keyword and Continue on failure    Should Be Equal    ${json_out['push-message']['nmsEventList']['nmsEvent'][0]['deletedObject']['message']['message-id']}    ${IMDN_MESSAGE_ID}


validatePNSKPIReport1
    [Arguments]    ${kpi_data}    ${Field}    ${count}
    ${kpi_data}=    Run    echo "${kpi_data}" |grep -v '= 0'
    ${data}=    Get Lines Containing String    ${kpi_data}    ${Field}
    log    ${data}
    Should Not Be Empty    ${data}    msg="Generated kpi report doen't contain Field ${Field}"
    ${dec_data}=    Split String    ${data}
    Should Be Equal As Strings    ${dec_data[3]}    ${count}


ValidatePNSKPIReport
    [Arguments]			${kpi_data}		${peer}=${PNS_SERVER_NAME}		${msgContext}=${MESSAGE_CONTEXT}		&{fileds_to_validate}
	log		${fileds_to_validate}
    ${fileds_to_validate}=    Evaluate    {str(k):str(v) for k,v in ${fileds_to_validate}.items()}
	log		${fileds_to_validate}
	
    ${length_of_kpi}=    Get Length    ${kpi_data}
    Run Keyword and Continue on Failure		Should Be Equal As Strings    ${length_of_kpi}    43			msg="saurav u r here"
    Run Keyword and Continue on Failure     Should Match Regexp    ${kpi_data[0]}    \\d{12}
    Run Keyword and Continue on Failure     Should Match Regexp    ${kpi_data[1]}    \\d{12}
	Run Keyword and Continue on Failure		Should Be Equal As Strings	${kpi_data[2]}		${KPI_NODE_ID}
    Run Keyword and Continue on Failure     Should Be Equal As Strings  ${kpi_data[3]}		${CARD_ID}
    Run Keyword and Continue on Failure     Should Be Equal As Strings  ${kpi_data[4]}		${peer}
    Run Keyword and Continue on Failure     Should Be Equal As Strings  ${kpi_data[5]}		${msgContext}
    Log     ${EMPTY}     console=true
	:FOR    ${i}    IN RANGE    8    ${length_of_kpi}
    \    ${key}=    Evaluate    ${i}+1
	\	 ${key}=	Convert to String	${key}
    \    ${kpi_filed_status}=    Run Keyword and return Status    Dictionary Should Contain Key    ${fileds_to_validate}    ${key}
    \    Run Keyword If    ${kpi_filed_status} == True    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${kpi_data[${i}]}    ${fileds_to_validate['${key}']}  msg="sauravurhere"	
    \    Run Keyword If    ${kpi_filed_status} == True      Log     "MSTORE_PUSH_NOTIFICATION"	#console=true
    \    Run Keyword If    ${kpi_filed_status} == False    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${kpi_data[${i}]}    0	msg="Expected 0 Recieved"

ValidateMsgDepositKPIReport
    [Arguments]    ${kpi_hdrs}  ${kpi_data}     &{fileds_to_validate}
    log     ${fileds_to_validate}
    ${fileds_to_validate}=    Evaluate    {str(k):str(v) for k,v in ${fileds_to_validate}.items()}
    log     ${fileds_to_validate}

    ${length_of_kpi}=    Get Length    ${kpi_data}
    Run Keyword and Continue on Failure     Should Be Equal As Strings    ${length_of_kpi}    95
    Run Keyword and Continue on Failure     Should Match Regexp    ${kpi_data[0]}    \\d{12}
    Run Keyword and Continue on Failure     Should Match Regexp    ${kpi_data[1]}    \\d{12}
    Run Keyword and Continue on Failure     Should Be Equal As Strings  ${kpi_data[2]}  ${KPI_NODE_ID}
    Run Keyword and Continue on Failure     Should Be Equal As Strings  ${kpi_data[3]}    ${CARD_ID}
    Run Keyword and Continue on Failure     Should Be Equal As Strings  ${kpi_data[4]}    ${LOCALHOST}
    Run Keyword and Continue on Failure     Should Be Equal As Strings  ${kpi_data[5]}    ${COSID}
    Run Keyword and Continue on Failure     Should Be Equal As Strings  ${kpi_data[6]}    RMS
    Run Keyword and Continue on Failure     Should Be Equal As Strings  ${kpi_data[7]}    ${DIRECTION}
    Log     ${EMPTY}     console=true
    :FOR    ${i}    IN RANGE    8    ${length_of_kpi}
    \    log    ${kpi_hdrs[${i}]}
    \    log    ${kpi_data[${i}]}
    \    ${key}=    Evaluate    ${i}+1
    \    ${key}=    Convert to String   ${key}
    \    ${kpi_filed_status}=    Run Keyword and return Status    Dictionary Should Contain Key    ${fileds_to_validate}    ${key}
    \    Run Keyword If    ${kpi_filed_status} == True    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${kpi_data[${i}]}    ${fileds_to_validate['${key}']}     msg="Expected ${fileds_to_validate['${key}']} Recieved ${kpi_data[${i}]} for ${kpi_hdrs[${i}]} field"
    \    Run Keyword If    ${kpi_filed_status} == True      Log     "MSTORE_MSG_DEPOSIT_RET , ${key}: ${kpi_hdrs[${i}]} , Expected: ${fileds_to_validate['${key}']} , Recieved: ${kpi_data[${i}]}"		#console=true
    \    Run Keyword If    ${kpi_filed_status} == False    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${kpi_data[${i}]}    0  msg="Expected 0 Recieved ${kpi_data[${i}]} for ${kpi_hdrs[${i}]} field"


ValidateNMSRestKPIReport
    [Arguments]    ${kpi_hdrs}  ${kpi_data}     &{fileds_to_validate}
    log     ${fileds_to_validate}
    ${fileds_to_validate}=    Evaluate    {str(k):str(v) for k,v in ${fileds_to_validate}.items()}
    log     ${fileds_to_validate}
	${ignore_list}=		Create List		62	63	64
    ${length_of_kpi}=    Get Length    ${kpi_data}
    Run Keyword and Continue on Failure     Should Be Equal As Strings    ${length_of_kpi}    101
    Run Keyword and Continue on Failure     Should Match Regexp    ${kpi_data[0]}    \\d{12}
    Run Keyword and Continue on Failure     Should Match Regexp    ${kpi_data[1]}    \\d{12}
    Run Keyword and Continue on Failure     Should Be Equal As Strings  ${kpi_data[2]}  ${KPI_NODE_ID}
    Run Keyword and Continue on Failure     Should Be Equal As Strings  ${kpi_data[3]}    ${CARD_ID}
    Run Keyword and Continue on Failure     Should Be Equal As Strings  ${kpi_data[4]}    ums:${LOCALHOST}
    Log     ${EMPTY}     console=true
    :FOR    ${i}    IN RANGE    5    ${length_of_kpi}
    \    log    ${kpi_hdrs[${i}]}
    \    log    ${kpi_data[${i}]}
    \    ${key}=    Evaluate    ${i}+1
    \    ${key}=    Convert to String   ${key}
    \    ${ignore_status}=    Run Keyword and return Status	List Should Contain Value   ${ignore_list}  ${key}
	\	 Continue For Loop If	${ignore_status} == True
    \    ${kpi_filed_status}=    Run Keyword and return Status    Dictionary Should Contain Key    ${fileds_to_validate}    ${key}
    \    Run Keyword If    ${kpi_filed_status} == True    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${kpi_data[${i}]}    ${fileds_to_validate['${key}']}     msg="Expected ${fileds_to_validate['${key}']} Recieved ${kpi_data[${i}]} for ${kpi_hdrs[${i}]} field"
    \    Run Keyword If    ${kpi_filed_status} == True      Log     "NMS_REST , ${key}: ${kpi_hdrs[${i}]} , Expected: ${fileds_to_validate['${key}']} , Recieved: ${kpi_data[${i}]}" 	#console=true
    \    Run Keyword If    ${kpi_filed_status} == False    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${kpi_data[${i}]}    0  msg="Expected 0 Recieved ${kpi_data[${i}]} for ${kpi_hdrs[${i}]} field"


ValidateMsgReadDeliverKPIReport
    [Arguments]    ${kpi_hdrs}  ${kpi_data}     &{fileds_to_validate}
    log     ${fileds_to_validate}
    ${fileds_to_validate}=    Evaluate    {str(k):str(v) for k,v in ${fileds_to_validate}.items()}
    log     ${fileds_to_validate}

    ${length_of_kpi}=    Get Length    ${kpi_data}
    Run Keyword and Continue on Failure     Should Be Equal As Strings    ${length_of_kpi}    47
    Run Keyword and Continue on Failure     Should Match Regexp    ${kpi_data[0]}    \\d{12}
    Run Keyword and Continue on Failure     Should Match Regexp    ${kpi_data[1]}    \\d{12}
    Run Keyword and Continue on Failure     Should Be Equal As Strings  ${kpi_data[2]}  ${KPI_NODE_ID}
    Run Keyword and Continue on Failure     Should Be Equal As Strings  ${kpi_data[3]}    ${CARD_ID}
    Run Keyword and Continue on Failure     Should Be Equal As Strings  ${kpi_data[4]}    ${LOCALHOST}
    Run Keyword and Continue on Failure     Should Be Equal As Strings  ${kpi_data[5]}    ${COSID}
    Run Keyword and Continue on Failure     Should Be Equal As Strings  ${kpi_data[6]}    RMS
	Log		${EMPTY}		console=true
    :FOR    ${i}    IN RANGE    7    ${length_of_kpi}
    \    log    ${kpi_hdrs[${i}]}
    \    log    ${kpi_data[${i}]}
    \    ${key}=    Evaluate    ${i}+1
    \    ${key}=    Convert to String   ${key}
    \    ${kpi_filed_status}=    Run Keyword and return Status    Dictionary Should Contain Key    ${fileds_to_validate}    ${key}
    \    Run Keyword If    ${kpi_filed_status} == True    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${kpi_data[${i}]}    ${fileds_to_validate['${key}']}     msg="Expected ${fileds_to_validate['${key}']} Recieved ${kpi_data[${i}]} for ${kpi_hdrs[${i}]} field"
	\	 Run Keyword If    ${kpi_filed_status} == True		Log		"MSTORE_MSG_READ_DELIVER , ${key}: ${kpi_hdrs[${i}]} , Expected: ${fileds_to_validate['${key}']} , Recieved: ${kpi_data[${i}]}"		#console=true
    \    Run Keyword If    ${kpi_filed_status} == False    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${kpi_data[${i}]}    0  msg="Expected 0 Recieved ${kpi_data[${i}]} for ${kpi_hdrs[${i}]} field"

ValidateArchiveTRLdata
	[Arguments]		${trl_data}	 ${no_of_fields}=${HTTPTRLCOUNT}	${store_type}=3		${messageFolderKey}=${RCS_MESSAGE_FOLDER_KEY}	${api_version}=V1	${http_method}=0	${operation_type}=1		${source_node}=RESTCLIENT	${response_code}=201	${mime_content_type}=${CHAT_CONTENT_TYPE}	${content_encoding}=${CHAT_CONTENT_TRANSFER_ENCODING}	${uid}=${CREATION_TUID}		${no_of_msgs}=1		${MSG_CONTEXT_ID}=${TRL_MSG_CONTEXT_ID}	${content_size}=${PAYLOAD_CONTENT_SIZE}		${imdn_status}=${EMPTY}		${content_type}=${BOUNDARY_CONTENT}		${msg_type}=individual		${imdn_trl_correlator}=${X_IMDN_CORRELATOR}		${Sender}=${MSG_FROM}	${Receiver}=${MSG_TO}
	${trl_fields_count}=	Get Length	 ${trl_data}
	Run Keyword and Continue on Failure		Should Be Equal As Strings	 ${trl_fields_count}	${no_of_fields}	  msg="trl field count mismatch Expected: ${no_of_fields} , Recieved: ${trl_fields_count}"
	Run Keyword and Continue on Failure     Should Be Equal As Strings	 ${trl_data[0]}		${TRL_NODE_ID}		  msg="Node Id Field mismatch Expected: ${TRL_NODE_ID} , Recieved: ${trl_data[0]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[1]}     ${PRODUCT}			  msg="Product Field mismatch Expected: ${PRODUCT}, Recieved: ${trl_data[1]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[2]}     1                     msg="InterfaceType(0->IMAP,1->HTTP) Field mismatch Expected:1, Recieved:${trl_data[2]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[3]}     ${store_type}		  msg="StoreType mismatch Expected:${store_type}, Recieved:${trl_data[3]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[4]}     ${SUBSCRIBER_ID}	  msg="UserMailBoxIdentity mismatch Expected:${SUBSCRIBER_ID}, Recieved:${trl_data[4]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[5]}     ${messageFolderKey}	  msg="FolderKey mimatch Expected:${messageFolderKey},Recieved:${trl_data[5]}"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[6]}     \\d+                  msg="callID mimatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[7]}     0                     msg="CE card Index mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[8]}     \\d+				  msg="DB Transcation id mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[9]}     0	                  msg="Interface on which request is recieved HTTP->0,HTTPS->1 mismtch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[10]}    0                     msg="API Type OMA_NMS_REST->0,GSMA_REST->1,PNS_REST->2,HTTP_REST->3 mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[11]}	${api_version}		  msg="API Version mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[12]}	${http_method}		  msg="HTTP method mismatch POST->0,GET->1,PUT->2,DELETE->3 mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[13]}	${operation_type}	  msg="Operation Type mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[14]}	${source_node}		  msg="Source node mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[15]}	\\d{16}\\+0000		  msg="Request Time Stamp mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[16]}	\\d{16}\\+0000		  msg="Response Time Stamp mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[17]}	${response_code}	  msg="Protocol cause code mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[21]}    \\d+				  msg="HTTP POST messageDepositiRequestTimestamp mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[22]}    ${messageFolderKey}:${uid}	msg="HTTP POST ObjectId mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[23]}	${no_of_msgs}		  msg="HTTP POST number of messages in mailbox mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[24]}     \\d+				  msg="HTTP POST messageDepositiResponseTimestamp mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[25]}     0                    msg="HTTP POST Internal CauseCode mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[74]}     ${Sender}		  msg="Generic Message Header Info Caller Address Mismatch i.e, MSG FROM"
    Run Keyword and Continue on Failure     Run Keyword If	'${msg_type}' == 'individual'	 Should Be Equal As Strings   ${trl_data[75]}     ${Receiver}		msg="Generic Message Header Info Called Address Mismatch i.e, MSG_TO"
	Run Keyword and Continue on Failure     Run Keyword If  '${msg_type}' == 'group'	ValidateGroupMemebersTRL	${trl_data[75]} 	${MSG_TO_GROUP_MEMBERS}	 #msg="Generic Message Header Info Called Address Mismatch i.e, MSG_TO"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[76]}     ${MSG_DEPOSIT_TIME}  msg="Generic Message Header Info Message Deposit Time mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[77]}	 ${EMPTY}			  msg="Generic Message Header Info Subject Mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[78]}     ${MSG_CONTEXT_ID}	  msg="Generic Message Header Info Message Context Mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[79]}	 ${EMPTY}			  msg="Generic Message Header Info Mime Version mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[80]}     ${content_type}	  msg="Generic Message Header Info top level Mime Content type of the object mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[81]}     ${COSID}			  msg="Generic Message Header Info Subscriber CosId mismatch"
    Run Keyword and Continue on Failure     Run Keyword If	'${imdn_status}' == '${EMPTY}'	 Should Be Equal As Strings   ${trl_data[82]}     ${mime_content_type}	msg="Generic Message Mime Header Info attachment content type mismatch"
    Run Keyword and Continue on Failure     Run Keyword If  '${imdn_status}' == '${EMPTY}'   Should Be Equal As Strings   ${trl_data[83]}     ${content_encoding}	msg="Generic Message Mime Header Info Content Transfer Encoding mismatch"
    Run Keyword and Continue on Failure     Run Keyword If  '${imdn_status}' == '${EMPTY}'   Should Be Equal As Strings   ${trl_data[84]}     0		msg="Generic Message Mime Header Info Content duration mismatch"
    Run Keyword and Continue on Failure     Run Keyword If  '${imdn_status}' == '${EMPTY}'   Should Be Equal As Strings   ${trl_data[85]}     ${EMPTY}	msg="Generic Message Mime Header Info Content disposition mismatch"
    Run Keyword and Continue on Failure     Run Keyword If  '${imdn_status}' == '${EMPTY}'   Should Be Equal As Strings   ${trl_data[86]}     ${content_size}	msg="Generic Message Mime Header Info Content size mismatch"
#    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[94]}     ${MSTORE_CASSANDRA_IP}		msg="Metadata server Address mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[95]}     ${SWIFT_IP}:${SWIFT_PORT}	msg="Storage Object server Address mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[96]}     \\d+						msg="DB Transcation Id mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[97]}     \\d+						msg="Correlation ID mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[171]}     ${imdn_trl_correlator}		msg="IMDN Correlator mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[172]}     ${imdn_status}			msg="X-RCS-Msg Status mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[175]}     \\w+						msg="Connection Id mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[176]}     \\w+						msg="DB Statistics mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[178]}     ${CONVERSATION_ID}		msg="Converstaion ID mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[179]}     ${CONTRIBUTION_ID}		msg="Contribution ID mismatch"

ValidateGroupMemebersTRL
	[Arguments]		${trl}		${members}
	${cnt}=		Get Length	${members}
	:FOR	${i}	IN RANGE	${cnt}
	\		${to_member}=	Set Variable	${members[${i}]};
	\		log		${to_member}
	Run Keyword and Continue on Failure		Should Be Equal As Strings   ${trl}		${to_member}	msg="Generic Message Header Info Called Address Mismatch i.e, MSG_TO"

ValidatePNSTRLdata
	[Arguments]     ${trl_data}  ${no_of_fields}=${HTTPTRLCOUNT}	${store_type}=${EMPTY}	${operation_type}=16	${response_code}=200	${notfn_ip}=${PNS_SERVER_NAME}	 ${notfn_port}=${PNS_SERVICE_PORT}	 ${notfn_channel}=1		${api_type}=2	${api_version}=V1		${http_method}=0	${source_node}=RESTCLIENT	${trl_object_url}=${PNS_OBJECT_URL}
	...	${notfn_cause_code}=4925	${notfn_content_flag}=Y		${direction_id}=${PNS_TRL_DIRECTION_VALUE}	${messageFolderKey}=${RCS_MESSAGE_FOLDER_KEY}	${uid}=${CREATION_TUID}		${subscription_id}=${SPACE}		${pns_type}=${PNS_TYPE}		${sync_type}=${NONE}	${pns_subtype}=${PNS_SUB_TYPE}	${pns_oject_icon_url}=${SPACE}

    ${trl_fields_count}=    Get Length   ${trl_data}
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_fields_count}    ${no_of_fields}   msg="trl field count mismatch Expected: ${no_of_fields} , Recieved: ${trl_fields_count}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[0]}     ${TRL_NODE_ID}        msg="Node Id Field mismatch Expected: ${TRL_NODE_ID} , Recieved: ${trl_data[0]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[1]}     ${PRODUCT}            msg="Product Field mismatch Expected: ${PRODUCT}, Recieved: ${trl_data[1]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[2]}     1                     msg="InterfaceType(0->IMAP,1->HTTP) Field mismatch Expected:1, Recieved:${trl_data[2]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[3]}     ${store_type}         msg="StoreType mismatch Expected:${store_type}, Recieved:${trl_data[3]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[4]}     ${SUBSCRIBER_ID}      msg="UserMailBoxIdentity mismatch Expected:${SUBSCRIBER_ID}, Recieved:${trl_data[4]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[5]}     ${SPACE}   			  msg="FolderKey mimatch Expected:${EMPTY},Recieved:${trl_data[5]}"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[6]}     \\d+                  msg="callID mimatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[7]}     0                     msg="CE card Index mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[8]}     \\d+                  msg="DB Transcation id mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[9]}     0                     msg="Interface on which request is recieved HTTP->0,HTTPS->1 mismtch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[10]}    ${api_type}           msg="API Type OMA_NMS_REST->0,GSMA_REST->1,PNS_REST->2,HTTP_REST->3 mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[11]}    ${api_version}        msg="API Version mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[12]}    ${http_method}        msg="HTTP method mismatch POST->0,GET->1,PUT->2,DELETE->3 mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[13]}    ${operation_type}     msg="Operation Type mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[14]}    ${source_node}        msg="Source node mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[15]}    \\d{16}\\+0000        msg="Request Time Stamp mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[16]}    \\d{16}\\+0000        msg="Response Time Stamp mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[17]}    ${response_code}      msg="Protocol cause code mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[106]}    ${notfn_ip}:${notfn_port}	msg="PNS/NMS notification Address mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[107]}    ${notfn_channel}		msg="Notification Channel mismatch PNS->1,WRG->2 mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[108]}    ${notfn_cause_code}	msg="Internal Causecode for PNS notification mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[109]}    ${notfn_content_flag}		msg="Notification content flag mismatch i.e,Content is part of notification or not"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[110]}    ${direction_id}		msg="Direction of the message mismatch None->0,In->1,Out->2"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[111]}    ${pns_type}		msg="PNS message type mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[112]}    ${pns_subtype}		msg="PNS sub message type mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[113]}    tel:+${SUBSCRIBER_ID}	msg="Target Address mismatch i.e, To whom the notification is sent "
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[114]}    ${subscription_id}		msg="Subscription ID mismatch"
    Run Keyword and Continue on Failure     Run Keyword If	'${sync_type}' != 'bulk'	Should Be Equal As Strings   ${trl_data[115]}    ${IMDN_MESSAGE_ID}		msg="RCS message IMDN message ID mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[116]}    ${PNS_CHANNEL}		msg="PNS Channel mismatch"
    Run Keyword and Continue on Failure     Run Keyword If  '${sync_type}' != 'bulk'    Should Be Equal As Strings   ${trl_data[118]}    ${trl_object_url}	msg="Object url mismatch"
    Run Keyword and Continue on Failure     Run Keyword If  '${sync_type}' != 'bulk'    Should Be Equal As Strings   ${trl_data[119]}	 ${pns_oject_icon_url}		msg="Object ICON url mismatch"
    Run Keyword and Continue on Failure     Run Keyword If  '${sync_type}' != 'bulk'    Should Be Equal As Strings   ${trl_data[120]}    ${messageFolderKey}:${uid}		msg="Object ID mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[173]}    \\d{16}\\+0000		msg="PNS request Timestamp mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[174]}    \\d{16}\\+0000		msg="PNS response Timestamp mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[175]}    \\w+				msg="Connection ID mismatch"


ValidateFolderSearchTRLdata
    [Arguments]     ${trl_data}  ${no_of_fields}=${HTTPTRLCOUNT}    ${store_type}=${EMPTY}     ${messageFolderKey}=${RCS_PARENT_FOLDER_KEY}   ${api_version}=V1   ${http_method}=0    ${operation_type}=3     ${source_node}=RESTCLIENT   ${response_code}=200   ${no_of_msgs}=1	${no_of_rec_req}=100	${search_scope}=Y	${search_criteria}=N	${logical_operator}=3 
    ${trl_fields_count}=    Get Length   ${trl_data}
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_fields_count}    ${no_of_fields}   msg="trl field count mismatch Expected: ${no_of_fields} , Recieved: ${trl_fields_count}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[0]}     ${TRL_NODE_ID}        msg="Node Id Field mismatch Expected: ${TRL_NODE_ID} , Recieved: ${trl_data[0]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[1]}     ${PRODUCT}            msg="Product Field mismatch Expected: ${PRODUCT}, Recieved: ${trl_data[1]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[2]}     1                     msg="InterfaceType(0->IMAP,1->HTTP) Field mismatch Expected:1, Recieved:${trl_data[2]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[3]}     0				      msg="StoreType mismatch Expected:${store_type}, Recieved:${trl_data[3]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[4]}     ${SUBSCRIBER_ID}      msg="UserMailBoxIdentity mismatch Expected:${SUBSCRIBER_ID}, Recieved:${trl_data[4]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[5]}     ${messageFolderKey}   msg="FolderKey mimatch Expected:${messageFolderKey},Recieved:${trl_data[5]}"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[6]}     \\d+                  msg="callID mimatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[7]}     0                     msg="CE card Index mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[8]}     \\d+                  msg="DB Transcation id mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[9]}     0                     msg="Interface on which request is recieved HTTP->0,HTTPS->1 mismtch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[10]}    0                     msg="API Type OMA_NMS_REST->0,GSMA_REST->1,PNS_REST->2,HTTP_REST->3 mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[11]}    ${api_version}        msg="API Version mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[12]}    ${http_method}        msg="HTTP method mismatch POST->0,GET->1,PUT->2,DELETE->3 mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[13]}    ${operation_type}     msg="Operation Type mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[14]}    ${source_node}        msg="Source node mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[15]}    \\d{16}\\+0000        msg="Request Time Stamp mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[16]}    \\d{16}\\+0000        msg="Response Time Stamp mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[17]}    ${response_code}      msg="Protocol cause code mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[30]}    \\d{16}\\+0000
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[31]}	${no_of_rec_req}
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[32]}	${search_scope}
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[33]}	${search_criteria}
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[34]}	${logical_operator}
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[35]}	${no_of_msgs}
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[36]}    \\d{16}\\+0000
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[37]}	0
#    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[94]}     ${MSTORE_CASSANDRA_IP}     msg="Metadata server Address mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[95]}     ${SWIFT_IP}:${SWIFT_PORT}  msg="Storage Object server Address mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[96]}     \\d+                       msg="DB Transcation Id mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[97]}     \\d+                       msg="Correlation ID mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[175]}     \\w+                      msg="Connection Id mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[176]}     \\w+                      msg="DB Statistics mismatch"

ValidateFetchTRLdata
    [Arguments]     ${trl_data}  ${no_of_fields}=202    ${store_type}=${EMPTY}     ${messageFolderKey}=${RCS_MESSAGE_FOLDER_KEY}   ${api_version}=V1   ${http_method}=1    ${operation_type}=2     ${source_node}=RESTCLIENT   ${response_code}=200		${fetch_obj_url}=${OBJECT_URL}
	${fetch_obj_url}=	Replace String	${fetch_obj_url}	%3a		:
	${fetch_obj_url}=   Replace String  ${fetch_obj_url}   %2b     +
	log		${fetch_obj_url}	
    ${trl_fields_count}=    Get Length   ${trl_data}

    ${trl_fields_count}=    Get Length   ${trl_data}
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_fields_count}    ${no_of_fields}   msg="trl field count mismatch Expected: ${no_of_fields} , Recieved: ${trl_fields_count}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[0]}     ${TRL_NODE_ID}        msg="Node Id Field mismatch Expected: ${TRL_NODE_ID} , Recieved: ${trl_data[0]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[1]}     ${PRODUCT}            msg="Product Field mismatch Expected: ${PRODUCT}, Recieved: ${trl_data[1]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[2]}     1                     msg="InterfaceType(0->IMAP,1->HTTP) Field mismatch Expected:1, Recieved:${trl_data[2]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[3]}     ${store_type}         msg="StoreType mismatch Expected:${store_type}, Recieved:${trl_data[3]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[4]}     ${SUBSCRIBER_ID}      msg="UserMailBoxIdentity mismatch Expected:${SUBSCRIBER_ID}, Recieved:${trl_data[4]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[5]}     ${messageFolderKey}   msg="FolderKey mimatch Expected:${messageFolderKey},Recieved:${trl_data[5]}"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[6]}     \\d+                  msg="callID mimatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[7]}     0                     msg="CE card Index mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[8]}     \\d+                  msg="DB Transcation id mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[9]}     0                     msg="Interface on which request is recieved HTTP->0,HTTPS->1 mismtch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[10]}    0                     msg="API Type OMA_NMS_REST->0,GSMA_REST->1,PNS_REST->2,HTTP_REST->3 mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[11]}    ${api_version}        msg="API Version mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[12]}    ${http_method}        msg="HTTP method mismatch POST->0,GET->1,PUT->2,DELETE->3 mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[13]}    ${operation_type}     msg="Operation Type mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[14]}    ${source_node}        msg="Source node mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[15]}    \\d{16}\\+0000        msg="Request Time Stamp mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[16]}    \\d{16}\\+0000        msg="Response Time Stamp mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[17]}    ${response_code}      msg="Protocol cause code mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[26]}    \\d{16}\\+0000		  msg="MsgRetReqTs mismtach"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[27]}    ${fetch_obj_url}	  msg="Content Location mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[28]}    \\d{16}\\+0000		  msg="MsgRetResTs mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[29]}    0                     msg="Retreieve Internal causecode mismatch"
#    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[94]}     ${MSTORE_CASSANDRA_IP}     msg="Metadata server Address mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[95]}     ${SWIFT_IP}:${SWIFT_PORT}  msg="Storage Object server Address mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[96]}     \\d+                       msg="DB Transcation Id mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[97]}     \\d+                       msg="Correlation ID mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[175]}     \\w+                      msg="Connection Id mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[176]}     \\w+                      msg="DB Statistics mismatch"



ValidateUpdateMsgTRLdata
    [Arguments]     ${trl_data}  ${no_of_fields}=${HTTPTRLCOUNT}    ${store_type}=${EMPTY}     ${messageFolderKey}=${RCS_MESSAGE_FOLDER_KEY}   ${api_version}=V1   ${http_method}=2    ${operation_type}=5     ${source_node}=RESTCLIENT   ${response_code}=201		${uid}=${CREATION_TUID}	${flag_id}=1
    ${trl_fields_count}=    Get Length   ${trl_data}
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_fields_count}    ${no_of_fields}   msg="trl field count mismatch Expected: ${no_of_fields} , Recieved: ${trl_fields_count}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[0]}     ${TRL_NODE_ID}        msg="Node Id Field mismatch Expected: ${TRL_NODE_ID} , Recieved: ${trl_data[0]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[1]}     ${PRODUCT}            msg="Product Field mismatch Expected: ${PRODUCT}, Recieved: ${trl_data[1]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[2]}     1                     msg="InterfaceType(0->IMAP,1->HTTP) Field mismatch Expected:1, Recieved:${trl_data[2]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[3]}     ${store_type}         msg="StoreType mismatch Expected:${store_type}, Recieved:${trl_data[3]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[4]}     ${SUBSCRIBER_ID}      msg="UserMailBoxIdentity mismatch Expected:${SUBSCRIBER_ID}, Recieved:${trl_data[4]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[5]}     ${messageFolderKey}   msg="FolderKey mimatch Expected:${messageFolderKey},Recieved:${trl_data[5]}"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[6]}     \\d+                  msg="callID mimatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[7]}     0                     msg="CE card Index mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[8]}     \\d+                  msg="DB Transcation id mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[9]}     0                     msg="Interface on which request is recieved HTTP->0,HTTPS->1 mismtch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[10]}    0                     msg="API Type OMA_NMS_REST->0,GSMA_REST->1,PNS_REST->2,HTTP_REST->3 mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[11]}    ${api_version}        msg="API Version mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[12]}    ${http_method}        msg="HTTP method mismatch POST->0,GET->1,PUT->2,DELETE->3 mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[13]}    ${operation_type}     msg="Operation Type mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[14]}    ${source_node}        msg="Source node mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[15]}    \\d{16}\\+0000        msg="Request Time Stamp mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[16]}    \\d{16}\\+0000        msg="Response Time Stamp mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[17]}    ${response_code}      msg="Protocol cause code mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[47]}    ${flag_id}			 msg="Request Flag mismatch Seen->0,Deleted->1,Saved->2"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[48]}    \\d{16}\\+0000		 msg="Update Message Request Timestamp mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[49]}    ${messageFolderKey}:${uid}	msg="ObjectId recieved in updated request mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[50]}     0						msg="Saved message TTL mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[51]}    \\d{16}\\+0000			msg="Update Message Response Timestamp mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[52]}    0                     msg="Update Internal causecode mismatch"
#    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[94]}     ${MSTORE_CASSANDRA_IP}     msg="Metadata server Address mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[95]}     ${SWIFT_IP}:${SWIFT_PORT}  msg="Storage Object server Address mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[96]}     \\d+                       msg="DB Transcation Id mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[97]}     \\d+                       msg="Correlation ID mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[175]}     \\w+                      msg="Connection Id mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[176]}     \\w+                      msg="DB Statistics mismatch"

ValidateDeleteMsgTRLdata
    [Arguments]     ${trl_data}  ${no_of_fields}=${HTTPTRLCOUNT}    ${store_type}=${EMPTY}    ${messageFolderKey}=${RCS_MESSAGE_FOLDER_KEY}   ${api_version}=V1   ${http_method}=3    ${operation_type}=7     ${source_node}=RESTCLIENT   ${response_code}=204    ${uid}=${CREATION_TUID}    ${flag_id}=1
    ${trl_fields_count}=    Get Length   ${trl_data}
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_fields_count}    ${no_of_fields}   msg="trl field count mismatch Expected: ${no_of_fields} , Recieved: ${trl_fields_count}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[0]}     ${TRL_NODE_ID}        msg="Node Id Field mismatch Expected: ${TRL_NODE_ID} , Recieved: ${trl_data[0]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[1]}     ${PRODUCT}            msg="Product Field mismatch Expected: ${PRODUCT}, Recieved: ${trl_data[1]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[2]}     1                     msg="InterfaceType(0->IMAP,1->HTTP) Field mismatch Expected:1, Recieved:${trl_data[2]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[3]}     ${store_type}         msg="StoreType mismatch Expected:${store_type}, Recieved:${trl_data[3]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[4]}     ${SUBSCRIBER_ID}      msg="UserMailBoxIdentity mismatch Expected:${SUBSCRIBER_ID}, Recieved:${trl_data[4]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[5]}     ${messageFolderKey}   msg="FolderKey mimatch Expected:${messageFolderKey},Recieved:${trl_data[5]}"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[6]}     \\d+                  msg="callID mimatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[7]}     0                     msg="CE card Index mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[8]}     \\d+                  msg="DB Transcation id mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[9]}     0                     msg="Interface on which request is recieved HTTP->0,HTTPS->1 mismtch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[10]}    0                     msg="API Type OMA_NMS_REST->0,GSMA_REST->1,PNS_REST->2,HTTP_REST->3 mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[11]}    ${api_version}        msg="API Version mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[12]}    ${http_method}        msg="HTTP method mismatch POST->0,GET->1,PUT->2,DELETE->3 mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[13]}    ${operation_type}     msg="Operation Type mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[14]}    ${source_node}        msg="Source node mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[15]}    \\d{16}\\+0000        msg="Request Time Stamp mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[16]}    \\d{16}\\+0000        msg="Response Time Stamp mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[17]}    ${response_code}      msg="Protocol cause code mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[55]}    \\d{16}\\+0000				 msg="Delete Message Request Timestamp mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[56]}    ${messageFolderKey}:${uid}		msg="ObjectId recieved in delete request mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[57]}    ${EMPTY}                     msg="Reserved"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[58]}    \\d{16}\\+0000			msg="Delete Message Response Timestamp mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[59]}    0                     msg="Delete Internal causecode mismatch"
#    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[94]}     ${MSTORE_CASSANDRA_IP}     msg="Metadata server Address mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[95]}     ${SWIFT_IP}:${SWIFT_PORT}  msg="Storage Object server Address mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[96]}     \\d+                       msg="DB Transcation Id mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[97]}     \\d+                       msg="Correlation ID mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[175]}     \\w+                      msg="Connection Id mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[176]}     \\w+                      msg="DB Statistics mismatch"


ValidateBulkUpdateTRLdata
    [Arguments]     ${trl_data}  ${no_of_fields}=${HTTPTRLCOUNT}    ${store_type}=${EMPTY}     ${messageFolderKey}=${RCS_MESSAGE_FOLDER_KEY}   ${api_version}=V1   ${http_method}=0    ${operation_type}=20     ${source_node}=RESTCLIENT   ${response_code}=200    ${no_of_msgs}=5		${update_operation}=2	${flag}=Seen
    ${trl_fields_count}=    Get Length   ${trl_data}
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_fields_count}    ${no_of_fields}   msg="trl field count mismatch Expected: ${no_of_fields} , Recieved: ${trl_fields_count}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[0]}     ${TRL_NODE_ID}        msg="Node Id Field mismatch Expected: ${TRL_NODE_ID} , Recieved: ${trl_data[0]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[1]}     ${PRODUCT}            msg="Product Field mismatch Expected: ${PRODUCT}, Recieved: ${trl_data[1]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[2]}     1                     msg="InterfaceType(0->IMAP,1->HTTP) Field mismatch Expected:1, Recieved:${trl_data[2]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[3]}     ${store_type}         msg="StoreType mismatch Expected:${store_type}, Recieved:${trl_data[3]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[4]}     ${SUBSCRIBER_ID}      msg="UserMailBoxIdentity mismatch Expected:${SUBSCRIBER_ID}, Recieved:${trl_data[4]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[5]}     ${EMPTY}              msg="FolderKey mimatch Expected:${EMPTY},Recieved:${trl_data[5]}"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[6]}     \\d+                  msg="callID mimatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[7]}     0                     msg="CE card Index mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[8]}     \\d+                  msg="DB Transcation id mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[9]}     0                     msg="Interface on which request is recieved HTTP->0,HTTPS->1 mismtch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[10]}    0                     msg="API Type OMA_NMS_REST->0,GSMA_REST->1,PNS_REST->2,HTTP_REST->3 mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[11]}    ${api_version}        msg="API Version mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[12]}    ${http_method}        msg="HTTP method mismatch POST->0,GET->1,PUT->2,DELETE->3 mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[13]}    ${operation_type}     msg="Operation Type mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[14]}    ${source_node}        msg="Source node mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[15]}    \\d{16}\\+0000        msg="Request Time Stamp mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[16]}    \\d{16}\\+0000        msg="Response Time Stamp mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[17]}    ${response_code}      msg="Protocol cause code mismatch"
#    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[94]}     ${MSTORE_CASSANDRA_IP}     msg="Metadata server Address mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[95]}     ${SWIFT_IP}:${SWIFT_PORT}  msg="Storage Object server Address mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[96]}     \\d+                       msg="DB Transcation Id mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[97]}     \\d+                       msg="Correlation ID mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[156]}    \\d{16}\\+0000			msg="Bulk Update Request Timestamp mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[157]}    \\d{16}\\+0000			msg="Bulk Update Response Timestamp mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[158]}    ${no_of_msgs}			msg="Number of objects to update mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[159]}    ${no_of_msgs}			msg="Number of objects Successfully updated mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[160]}    ${update_operation}	msg="Update operation mismatch AddFlag->1, RemoveFlag->2"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[161]}    ${flag}				msg="flag mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[162]}    0                     msg="Bulk Update Internal causecode mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[175]}     \\w+                      msg="Connection Id mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[176]}     \\w+                      msg="DB Statistics mismatch"

ValidateBulkDeleteTRLdata
    [Arguments]     ${trl_data}  ${no_of_fields}=${HTTPTRLCOUNT}    ${store_type}=${EMPTY}      ${api_version}=V1   ${http_method}=3    ${operation_type}=17     ${source_node}=RESTCLIENT   ${response_code}=200    ${no_of_msgs}=5 
    ${trl_fields_count}=    Get Length   ${trl_data}
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_fields_count}    ${no_of_fields}   msg="trl field count mismatch Expected: ${no_of_fields} , Recieved: ${trl_fields_count}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[0]}     ${TRL_NODE_ID}        msg="Node Id Field mismatch Expected: ${TRL_NODE_ID} , Recieved: ${trl_data[0]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[1]}     ${PRODUCT}            msg="Product Field mismatch Expected: ${PRODUCT}, Recieved: ${trl_data[1]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[2]}     1                     msg="InterfaceType(0->IMAP,1->HTTP) Field mismatch Expected:1, Recieved:${trl_data[2]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[3]}     ${store_type}         msg="StoreType mismatch Expected:${store_type}, Recieved:${trl_data[3]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[4]}     ${SUBSCRIBER_ID}      msg="UserMailBoxIdentity mismatch Expected:${SUBSCRIBER_ID}, Recieved:${trl_data[4]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[5]}     ${EMPTY}              msg="FolderKey mimatch Expected:${EMPTY},Recieved:${trl_data[5]}"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[6]}     \\d+                  msg="callID mimatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[7]}     0                     msg="CE card Index mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[8]}     \\d+                  msg="DB Transcation id mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[9]}     0                     msg="Interface on which request is recieved HTTP->0,HTTPS->1 mismtch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[10]}    0                     msg="API Type OMA_NMS_REST->0,GSMA_REST->1,PNS_REST->2,HTTP_REST->3 mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[11]}    ${api_version}        msg="API Version mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[12]}    ${http_method}        msg="HTTP method mismatch POST->0,GET->1,PUT->2,DELETE->3 mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[13]}    ${operation_type}     msg="Operation Type mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[14]}    ${source_node}        msg="Source node mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[15]}    \\d{16}\\+0000        msg="Request Time Stamp mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[16]}    \\d{16}\\+0000        msg="Response Time Stamp mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[17]}    ${response_code}      msg="Protocol cause code mismatch"
#    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[94]}     ${MSTORE_CASSANDRA_IP}     msg="Metadata server Address mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[95]}     ${SWIFT_IP}:${SWIFT_PORT}  msg="Storage Object server Address mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[96]}     \\d+                       msg="DB Transcation Id mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[97]}     \\d+                       msg="Correlation ID mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[147]}    \\d{16}\\+0000				msg="Bulk Delete Request Timestamp mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[148]}    \\d{16}\\+0000				msg="Bulk Delete Response Timestamp mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[149]}    ${no_of_msgs}				msg="Number of objects to delete mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[150]}    ${no_of_msgs}				msg="Number of objects successfully delted mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[151]}    0                     msg="Bulk Delete Internal causecode mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[175]}     \\w+                      msg="Connection Id mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[176]}     \\w+                      msg="DB Statistics mismatch"


ValidateNMSSubscriptionTRLdata
    [Arguments]		${trl_data}		${no_of_fields}=${HTTPTRLCOUNT}		${store_type}=${store_RCS}		${api_version}=V1		${http_method}=0		${operation_type}=19		${source_node}=RESTCLIENT		${response_code}=201		${subscription_event}=0			${subscription_id}=${SubscriptionId} 
    ${trl_fields_count}=    Get Length   ${trl_data}
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_fields_count}    ${no_of_fields}   msg="trl field count mismatch Expected: ${no_of_fields} , Recieved: ${trl_fields_count}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[0]}     ${TRL_NODE_ID}        msg="Node Id Field mismatch Expected: ${TRL_NODE_ID} , Recieved: ${trl_data[0]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[1]}     ${PRODUCT}            msg="Product Field mismatch Expected: ${PRODUCT}, Recieved: ${trl_data[1]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[2]}     1                     msg="InterfaceType(0->IMAP,1->HTTP) Field mismatch Expected:1, Recieved:${trl_data[2]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[3]}     ${store_type}         msg="StoreType mismatch Expected:${store_type}, Recieved:${trl_data[3]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[4]}     ${SUBSCRIBER_ID}      msg="UserMailBoxIdentity mismatch Expected:${SUBSCRIBER_ID}, Recieved:${trl_data[4]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[5]}     ${EMPTY}              msg="FolderKey mimatch Expected:${EMPTY},Recieved:${trl_data[5]}"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[6]}     \\d+                  msg="callID mimatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[7]}     0                     msg="CE card Index mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[8]}     \\d+                  msg="DB Transcation id mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[9]}     0                     msg="Interface on which request is recieved HTTP->0,HTTPS->1 mismtch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[10]}    0                     msg="API Type OMA_NMS_REST->0,GSMA_REST->1,PNS_REST->2,HTTP_REST->3 mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[11]}    ${api_version}        msg="API Version mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[12]}    ${http_method}        msg="HTTP method mismatch POST->0,GET->1,PUT->2,DELETE->3 mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[13]}    ${operation_type}     msg="Operation Type mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[14]}    ${source_node}        msg="Source node mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[15]}    \\d{16}\\+0000        msg="Request Time Stamp mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[16]}    \\d{16}\\+0000        msg="Response Time Stamp mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[17]}    ${response_code}      msg="Protocol cause code mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[96]}     \\d+                       msg="DB Transcation Id mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[97]}     \\d+                       msg="Correlation ID mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[139]}    ${subscription_event}      msg="subscription event mismatch Create->0,Update->1,Get->2,Delete->3"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[140]}    ${NMS_NOTIFICATION_URL}		msg=""
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[141]}    ${NMS_SUBSCRIPTION_DURATION}    msg=""
	Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[142]}	 ${NMS_RESTART_TOKEN}
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[143]}    ${subscription_id}    msg="NMS Subscription ID mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[144]}    \\d{16}\\+0000        msg="NMS Subscription Request Time Stamp mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[145]}    \\d{16}\\+0000        msg="NMS Subscription Response Time Stamp mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[146]}    0    msg="NMS Subscription Internal CauseCode mismatch"


ValidateCassandra_messages_by_original_folder_timestamp_LargeMessages
    [Arguments]    ${userId}=${USERID}    ${folderkey}=${RCS_MESSAGE_FOLDER_KEY}    ${rootfolderkey}=${RCS_PARENT_FOLDER_KEY}    ${creation_tuid}=${CREATION_TUID}
    ...    ${recent}=1    ${seen}=0    ${delivered}=0    ${deleted}=0       ${bodyoctets}=${LM_DATA_SIZE}       ${modification_tuid}=${CREATION_TUID}   ${direction_value}=0
    ...    ${contentencoding}=${EMPTY}      ${contenttype}=${FT_CONTENT_TYPE}    ${contributionid}=${CONTRIBUTION_ID}    ${conversationid}=${CONVERSATION_ID}   ${content_size}=${COMPLETE_OBJ_FILE_SIZE}
    ...    ${messagecontext}=${MESSAGE_CONTEXT}    ${deliveredimdnlist}=None    ${readimdnlist}=None  ${msg_from}=${MSG_FROM}   ${msg_to}=${MSG_TO}     ${imdn_msg_id}=${IMDN_MESSAGE_ID}	${msg_type}=individual
    Switch Connection    cass_db
    Write   SELECT json * from messages_by_original_folder_timestamp where userid='${userId}' AND folderkey='${folderkey}' AND creation_tuid=${creation_tuid};
    ${data}=    Read Until    ${MSTORE_CASSANDRA_KEYSPACE}>
    ${json_data}=    Get Lines Containing String    ${data}    ${folderkey}
    ${mboft_data}=    Evaluate    json.loads('''${json_data}''')    json
    log    ${mboft_data}

    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['folderkey']}    ${folderkey}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['bodyoctets']}    ${bodyoctets}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['contentencoding']}    ${contentencoding}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['contenttype']}    ${contenttype}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['fromheader']}        ${msg_from}
    Run Keyword and Continue on Failure    Run Keyword If	'${msg_type}' != 'group'	Should Be Equal As Strings    ${mboft_data['toheader']}          ${msg_to}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['imdnmessageid']}     ${imdn_msg_id}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['rfc2822size']}           ${content_size}
    Run Keyword and Continue on Failure    Should Match Regexp    ${mboft_data['swiftobjurl']}		/v1/${SWIFTACCOUNTID}/${CONTAINER_INFO['${FT_PARENT_FOLDER_PATH}']}/\\d+:${folderkey}:${creation_tuid}
	Set SUite Variable	${SWIFT_OBJECT_URL}		${mboft_data['swiftobjurl']}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['contributionid']}    ${contributionid}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['conversationid']}    ${conversationid}
#    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['message']}    ${message}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['messagecontext']}    ${messagecontext}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['rootfolderkey']}    ${rootfolderkey}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['recent']}    ${recent}		msg="recent flag mismatch in cassandra "
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['delivered']}    ${delivered}		msg="delivered flag mismatch in cassandra "
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['seen']}    ${seen}		msg="seen flag mismatch in cassandra"
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['readimdnlist']}    ${readimdnlist}	msg="read list mismatch in cassandara"
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['deliveredimdnlist']}    ${deliveredimdnlist}		msg="delivered list mismatch in cassandra"
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['creation_tuid']}    ${creation_tuid}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['deleted']}    ${deleted}		msg="deleted flag mismatch n cassandra"
    [Return]    ${mboft_data['creation_tuid']}    ${mboft_data['modification_tuid']}




ValidateCassandra_messages_by_original_folder_timestamp_CHAT
    [Arguments]    ${userId}=${USERID}    ${folderkey}=${RCS_MESSAGE_FOLDER_KEY}    ${rootfolderkey}=${RCS_PARENT_FOLDER_KEY}    ${creation_tuid}=${CREATION_TUID}
    ...    ${recent}=1    ${seen}=0    ${delivered}=0    ${deleted}=0             ${modification_tuid}=${CREATION_TUID}   ${direction_value}=0
    ...    ${contentencoding}=${EMPTY}      ${contenttype}=${CHAT_CONTENT_TYPE}    ${contributionid}=${CONTRIBUTION_ID}    ${conversationid}=${CONVERSATION_ID}
    ...    ${messagecontext}=${MESSAGE_CONTEXT}    ${deliveredimdnlist}=None    ${readimdnlist}=None  ${msg_from}=${MSG_FROM}   ${msg_to}=${MSG_TO}     ${imdn_msg_id}=${IMDN_MESSAGE_ID}   ${msg_type}=individual
    Switch Connection    cass_db
    Write   SELECT json * from messages_by_original_folder_timestamp where userid='${userId}' AND folderkey='${folderkey}' AND creation_tuid=${creation_tuid};
    ${data}=    Read Until    ${MSTORE_CASSANDRA_KEYSPACE}>
    ${json_data}=    Get Lines Containing String    ${data}    ${folderkey}
    ${mboft_data}=    Evaluate    json.loads('''${json_data}''')    json
    log    ${mboft_data}

    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['folderkey']}    ${folderkey}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['contenttype']}    ${contenttype}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['fromheader']}        ${msg_from}
    Run Keyword and Continue on Failure    Run Keyword If   '${msg_type}' != 'group'    Should Be Equal As Strings    ${mboft_data['toheader']}          ${msg_to}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['imdnmessageid']}     ${imdn_msg_id}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['contributionid']}    ${contributionid}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['conversationid']}    ${conversationid}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['messagecontext']}    ${messagecontext}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['rootfolderkey']}    ${rootfolderkey}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['recent']}    ${recent}       msg="recent flag mismatch in cassandra "
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['delivered']}    ${delivered}     msg="delivered flag mismatch in cassandra "
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['seen']}    ${seen}       msg="seen flag mismatch in cassandra"
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['readimdnlist']}    ${readimdnlist}   msg="read list mismatch in cassandara"
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['deliveredimdnlist']}    ${deliveredimdnlist}     msg="delivered list mismatch in cassandra"
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['delivered']}    ${delivered}     msg="delivered flag mismatch in cassandra "
   Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['creation_tuid']}    ${creation_tuid}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mboft_data['deleted']}    ${deleted}     msg="deleted flag mismatch n cassandra"
    [Return]    ${mboft_data['creation_tuid']}    ${mboft_data['modification_tuid']}






ValidateCassandra_messages_by_root_folder_timestamp
    [Arguments]    ${userId}=${USERID}    ${folderkey}=${RCS_MESSAGE_FOLDER_KEY}    ${rootfolderkey}=${RCS_PARENT_FOLDER_KEY}    ${creation_tuid}=${CREATION_TUID}   ${modification_tuid}=${CREATION_TUID}      ${recent}=1    ${seen}=0    ${delivered}=0    ${deleted}=0
    Switch Connection    cass_db
    Write    SELECT json * from messages_by_root_folder_timestamp where userid='${userId}' and rootfolderkey='${rootfolderkey}' and creation_tuid=${creation_tuid};
    ${data}=    Read Until    \>
    ${json_data}=    Get Lines Containing String    ${data}    ${folderkey}
    ${mbrft_data}=    Evaluate    json.loads('''${json_data}''')    json
    log    ${mbrft_data}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mbrft_data['folderkey']}    ${folderkey}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mbrft_data['rootfolderkey']}    ${rootfolderkey}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mbrft_data['deleted']}    ${deleted}		msg="deleted flag mismatch n cassandra"
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mbrft_data['delivered']}    ${delivered}		msg="delivered flag mismatch in cassandra "
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mbrft_data['recent']}    ${recent}		msg="recent flag mismatch in cassandra "
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mbrft_data['seen']}    ${seen}			 msg="seen flag mismatch in cassandra"
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mbrft_data['creation_tuid']}    ${creation_tuid}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${mbrft_data['modification_tuid']}    ${modification_tuid}


ValidateCassandra_flag_changes_by_root_folder_timestamp
    [Arguments]    ${userId}=${USERID}    ${folderkey}=${RCS_MESSAGE_FOLDER_KEY}    ${rootfolderkey}=${RCS_PARENT_FOLDER_KEY}    ${creation_tuid}=${CREATION_TUID}   ${modification_tuid}=${CREATION_TUID}  ${seen}=0    ${delivered}=0    ${deleted}=0
    Switch Connection    cass_db
    Write    SELECT json * from flag_changes_by_root_folder_timestamp where userid='${userId}' AND rootfolderkey='${rootfolderkey}' AND modification_tuid=${modification_tuid};
    ${data}=    Read Until    \>
    ${json_data}=    Get Lines Containing String    ${data}    ${folderkey}
    ${fcbrft_data}=    Evaluate    json.loads('''${json_data}''')    json
    log    ${fcbrft_data}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${fcbrft_data['folderkey']}    ${folderkey}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${fcbrft_data['rootfolderkey']}    ${rootfolderkey}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${fcbrft_data['deleted']}    ${deleted}		msg="deleted flag mismatch n cassandra"
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${fcbrft_data['delivered']}    ${delivered}		msg="delivered flag mismatch in cassandra "
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${fcbrft_data['seen']}    ${seen}	msg="seen flag mismatch in cassandra"
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${fcbrft_data['creation_tuid']}    ${creation_tuid}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${fcbrft_data['modification_tuid']}    ${modification_tuid}


ValidateCassandra_flag_changes_by_original_folder_timestamp
    [Arguments]    ${userId}=${USERID}    ${folderkey}=${RCS_MESSAGE_FOLDER_KEY}    ${rootfolderkey}=${RCS_PARENT_FOLDER_KEY}    ${creation_tuid}=${CREATION_TUID}   ${modification_tuid}=${CREATION_TUID}  ${seen}=0    ${delivered}=0    ${deleted}=0
    Switch Connection    cass_db
    Write    SELECT json * from flag_changes_by_original_folder_timestamp where userid='${userId}' AND folderkey='${folderkey}' AND modification_tuid=${modification_tuid};
    ${data}=    Read Until    \>
    ${json_data}=    Get Lines Containing String    ${data}    ${folderkey}
    ${fcboft_data}=    Evaluate    json.loads('''${json_data}''')    json
    log    ${fcboft_data}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${fcboft_data['folderkey']}    ${folderkey}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${fcboft_data['deleted']}    ${deleted}		msg="deleted flag mismatch n cassandra"
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${fcboft_data['delivered']}    ${delivered}		msg="delivered flag mismatch in cassandra "
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${fcboft_data['seen']}    ${seen}		msg="seen flag mismatch in cassandra"
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${fcboft_data['creation_tuid']}    ${creation_tuid}
    Run Keyword and Continue on Failure    Should Be Equal As Strings    ${fcboft_data['modification_tuid']}    ${modification_tuid}


ValidateCassandraMessageActivity
    [Arguments]     ${imdn_msg_id}=${IMDN_MESSAGE_ID}		${cnt}=0
    Switch Connection    cass_db
    Write   select json * from message_activity where imdnmessageid='${imdnmessageid}';
    ${out}=    Read Until    ${MSTORE_CASSANDRA_KEYSPACE}\>
    log    ${out}
    Should Contain  ${out}  (${cnt} rows)	
	Return From Keyword If      ${cnt} == 0
	${json_data}=    Get Lines Containing String    ${out}	${imdnmessageid}
	${json_data}=	Split to Lines	${json_data}
	${type}    Evaluate    type(${json_data})	
	${list_len}=	Get Length	${json_data}
	${json_data0}=	Run Keyword If	${list_len} == 1	Evaluate    json.loads('''${json_data[0]}''')    json
    ${json_data1}=   Run Keyword If  ${list_len} == 2    Evaluate    json.loads('''${json_data[0]}''')    json
    ${json_data2}=   Run Keyword If  ${list_len} == 2    Evaluate    json.loads('''${json_data[1]}''')    json

	log		${json_data}
	Run Keyword If	${cnt} == 1		ValidateessageActivityForDelivered		${json_data0}
    Run Keyword If  ${cnt} == 2     ValidateessageActivityForDelivered		${json_data1}
    Run Keyword If  ${cnt} == 2     ValidateessageActivityForDisplayed		${json_data2}

ValidateessageActivityForDelivered
	[Arguments]		${json_data}	${imdnmessageid}=${IMDN_MESSAGE_ID}
	Run Keyword and Continue on Failure    Should Be Equal As Strings		${json_data['imdnmessageid']}	${imdnmessageid}
    Run Keyword and Continue on Failure    Should Be Equal As Strings       ${json_data['flagtype']}   		0
    Run Keyword and Continue on Failure    Should Be Equal As Strings       ${json_data['ttltracker']}   	True
	${deliveredlist}=	Get Dictionary Keys		${json_data['useractivityinfo']}
	log		${deliveredlist}


ValidateessageActivityForDisplayed
    [Arguments]     ${json_data}    ${imdnmessageid}=${IMDN_MESSAGE_ID}
    Run Keyword and Continue on Failure    Should Be Equal As Strings       ${json_data['imdnmessageid']}   ${imdnmessageid}
    Run Keyword and Continue on Failure    Should Be Equal As Strings       ${json_data['flagtype']}        1
    Run Keyword and Continue on Failure    Should Be Equal As Strings       ${json_data['ttltracker']}      True
    ${displayedlist}=   Get Dictionary Keys     ${json_data['useractivityinfo']}
    log     ${displayedlist}

GetArchivalHTTPTRLdecodedDataVara
    [Arguments]    ${nodeId}=${MSTORE_NODE_NAME}    ${trl_path}=${TRL_PATH}    ${no_of_trl}=1    ${interface_type}=${HTTP_INTERFACE_TYPE}   ${mStore_session}=mStore
    Switch Connection    ${mStore_session}
    ${current_trl_path}=    Execute Command    echo ${trl_path}/`date +%Y_%m/%d/%H`
    log    ${current_trl_path}
    Should Not Be Empty    ${current_trl_path}    msg="TRL path is empty"
    ${all_files}=    Execute Command    ls -lrt ${current_trl_path}/* |grep ${nodeId}_TRL.*gz
    log    ${all_files}
    #${latest_trl_file}=    Execute Command    ls -lrt ${current_trl_path}/* |grep ${nodeId}_TRL.*gz |awk '{print $NF}' |tail -n ${no_of_trl}
    #log    ${latest_trl_file}
    #Should Not Be Empty    ${latest_trl_file}    msg="TRL file not generated for ${TEST NAME} in ${current_trl_path} path "
    ${complete_data}=    Execute Command    zcat ${current_trl_path}/*
    log    ${complete_data}
    ${full_data}=    Execute Command    zcat ${current_trl_path}/* |grep ,mstore,${interface_type}, |tail -n ${no_of_trl}
    log    ${full_data}
    Should Not Be Empty    ${full_data}    msg="TRL data is not generated"
    #Set Test Variable    ${CURRENT_TEST_TRL_FILE}    ${latest_trl_file}
    Run    echo "${full_data}" > /tmp/http_trl_test.csv
    ${c_time}=    Get Time    epoch
    ${decoded_file}=    Set Variable    /tmp/trl_decodeddata_${c_time}.txt
    ${result}=    Run    ${CURDIR}/../testfiles/trlDecoder.sh /tmp/http_trl_test.csv ${CURDIR}/../testfiles/mStore_HTTP_TRL_Fields.txt
    log    ${result}
    Run    echo "${result}" > ${decoded_file}
    [Return]    ${full_data}    ${decoded_file}


ValidateFetchTRLdata_C44
    [Arguments]     ${trl_data}  ${no_of_fields}=202    ${store_type}=${EMPTY}     ${messageFolderKey}=${RCS_MESSAGE_FOLDER_KEY}   ${api_version}=V1   ${http_method}=1    ${operation_type}=2     ${source_node}=RESTCLIENT   ${response_code}=200     ${fetch_obj_url}=${OBJECT_URL}		${Int_CauseCode}=0
    ${fetch_obj_url}=   Replace String  ${fetch_obj_url}    %3a     :
    ${fetch_obj_url}=   Replace String  ${fetch_obj_url}   %2b     +
    log     ${fetch_obj_url}
    ${trl_fields_count}=    Get Length   ${trl_data}

    ${trl_fields_count}=    Get Length   ${trl_data}
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_fields_count}    ${no_of_fields}   msg="trl field count mismatch Expected: ${no_of_fields} , Recieved: ${trl_fields_count}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[0]}     ${TRL_NODE_ID}        msg="Node Id Field mismatch Expected: ${TRL_NODE_ID} , Recieved: ${trl_data[0]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[1]}     ${PRODUCT}            msg="Product Field mismatch Expected: ${PRODUCT}, Recieved: ${trl_data[1]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[2]}     1                     msg="InterfaceType(0->IMAP,1->HTTP) Field mismatch Expected:1, Recieved:${trl_data[2]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[3]}     0         msg="StoreType mismatch Expected:${store_type}, Recieved:${trl_data[3]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[4]}     ${SUBSCRIBER_ID}      msg="UserMailBoxIdentity mismatch Expected:${SUBSCRIBER_ID}, Recieved:${trl_data[4]}"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[5]}     ${messageFolderKey}   msg="FolderKey mimatch Expected:${messageFolderKey},Recieved:${trl_data[5]}"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[6]}     \\d+                  msg="callID mimatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[7]}     0                     msg="CE card Index mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[8]}     \\d+                  msg="DB Transcation id mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[9]}     0                     msg="Interface on which request is recieved HTTP->0,HTTPS->1 mismtch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[10]}    0                     msg="API Type OMA_NMS_REST->0,GSMA_REST->1,PNS_REST->2,HTTP_REST->3 mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[11]}    ${api_version}        msg="API Version mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[12]}    ${http_method}        msg="HTTP method mismatch POST->0,GET->1,PUT->2,DELETE->3 mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[13]}    ${operation_type}     msg="Operation Type mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[14]}    ${source_node}        msg="Source node mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[15]}    \\d{16}\\+0000        msg="Request Time Stamp mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[16]}    \\d{16}\\+0000        msg="Response Time Stamp mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[17]}    ${response_code}      msg="Protocol cause code mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[26]}    \\d{16}\\+0000        msg="MsgRetReqTs mismtach"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[27]}    ${fetch_obj_url}      msg="Content Location mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[28]}    \\d{16}\\+0000        msg="MsgRetResTs mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[29]}     ${Int_CauseCode}        msg="Retreieve Internal causecode mismatch"
   # Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[94]}     ${MSTORE_CASSANDRA_IP}     msg="Metadata server Address mismatch"
    Run Keyword and Continue on Failure     Should Be Equal As Strings   ${trl_data[95]}     ${SWIFT_IP}:${SWIFT_PORT}  msg="Storage Object server Address mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[96]}     \\d+                       msg="DB Transcation Id mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[97]}     \\d+                       msg="Correlation ID mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[175]}     \\w+                      msg="Connection Id mismatch"
    Run Keyword and Continue on Failure     Should Match Regexp          ${trl_data[176]}     \\w+                      msg="DB Statistics mismatch"

