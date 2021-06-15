*** Settings ***
#Settings
Library    SSHLibrary
Library    Collections
Library    String
Library    RequestsLibrary
Library    OperatingSystem
Library    Process
Library    XML
Library    ../testfiles/Socket_PNS_NMS.py

*** Variables ***

*** Keywords ***
login_to_mstore
    [Documentation]    "Login to mstore testbed server"
    [Arguments]    ${mstore_ip}=${MSTORE_IP}    ${mstore_username}=${MSTORE_USERNAME}    ${mstore_password}=${MSTORE_PASSWORD}    ${mstore_ssh_port}=${MSTORE_SSH_PORT}		${mStore_session}=mStore
    Open Connection    ${mstore_ip}    port=${mstore_ssh_port}    timeout=1 minute    alias=${mStore_session}
    Login    ${mstore_username}    ${mstore_password}
    Run Keyword If    "${mstore_username}" != "root"
    ...    Run Keywords
    ...    write    sudo bash
    ...    AND    read until    ${mstore_username}:
    ...    AND    Write    ${mstore_password}
    ...    AND    Read Until    \#

login_to_mstore_dbm
    [Documentation]    "login to mysql db in mstore"
    [Arguments]    ${mstore_ip}=${MSTORE_IP}    ${mstore_username}=${MSTORE_USERNAME}    ${mstore_password}=${MSTORE_PASSWORD}    ${mstore_ssh_port}=${MSTORE_SSH_PORT}		${mStore_dbm_session}=mStore_dbm
    Open Connection    ${mstore_ip}    port=${mstore_ssh_port}    timeout=1 minute    alias=${mStore_dbm_session}
    Login    ${mstore_username}    ${mstore_password}
    Run Keyword If    "${mstore_username}" != "root"
    ...    Run Keywords
    ...    write    sudo bash
    ...    AND    read until    ${mstore_username}:
    ...    AND    Write    ${mstore_password}
    ...    AND    Read Until    \#
    Write    dbm -A --prompt="mysql> "
    Read Until    \>
    

login_to_cassandra_db
    [Documentation]    "login to cassandra"
    [Arguments]    ${cass_srvr_ip}=${MSTORE_CASSANDRA_IP}    ${cass_srvr_username}=${MSTORE_CASSANDRA_USERNAME}    ${cass_srvr_password}=${MSTORE_CASSANDRA_PASSWORD}    ${cass_srvr_sshport}=${MSTORE_CASSANDRA_SSH_PORT}    ${cass_keyspace}=${MSTORE_CASSANDRA_KEYSPACE}
    Open Connection    ${cass_srvr_ip}    port=${cass_srvr_sshport}    timeout=1 minute    alias=cass_db
    Login    ${cass_srvr_username}    ${cass_srvr_password}
    Run Keyword If    "${cass_srvr_username}" != "root"
    ...    Run Keywords
    ...    write    sudo bash
    ...    AND    read until    ${cass_srvr_username}:
    ...    AND    Write    ${cass_srvr_password}
    ...    AND    Read Until    \#
    Write    cqlsh --no-color
    ${status1}	${output}=    Run keyword and Ignore Error    Read Until    \>
    ${status}	${out1}=	Run Keyword If    '''FAIL''' in '''${status1}'''		try_login_cqlsh		ELSE	Set Variable	PASS	None
	Should Be Equal As Strings	${status}	PASS	"Failed to login to Cassandra cqlsh ${out1}"
	Write    use ${cass_keyspace};
	Read Until    \>
	
login_to_swift_server
    [Documentation]    "Login to swift server"
    [Arguments]    ${swift_ip}=${SWIFT_IP}    ${swift_username}=${SWIFT_USERNAME}    ${swift_password}=${SWIFT_PASSWORD}    ${swift_ssh_port}=${SWIFT_SSH_PORT}     ${swift_session}=${SWIFT_SESSION_NAME}
    Open Connection    ${swift_ip}    port=${swift_ssh_port}    timeout=1 minute    alias=${swift_session}
    Login    ${swift_username}    ${swift_password}
    Run Keyword If    "${swift_username}" != "root"
    ...    Run Keywords
    ...    write    sudo bash
    ...    AND    read until    ${swift_username}:
    ...    AND    Write    ${swift_password}
    ...    AND    Read Until    \#

try_login_cqlsh
	Switch Connection	cass_db
	:FOR	${index} 	IN RANGE	0	10
	\	Write    cqlsh --no-color
    \	${status}	${out}=		Run keyword and Ignore Error	Read Until    \>
	\	EXIT FOR LOOP IF	'''PASS''' in '''${status}'''
	[Return]	${status}	${out}
    

login_to_simulator_server
    [Documentation]    "login to simulator server"
    [Arguments]    ${simulator_srvr_ip}=${SIMULATOR_SRVR_IP}    ${simulator_srvr_username}=${SIMULATOR_SRVR_USERNAME}    ${simulator_srvr_password}=${SIMULATOR_SRVR_PASSWORD}    ${simulator_ssh_port}=${SIMULATOR_SRVR_SSH_PORT}
    Open Connection    ${simulator_srvr_ip}    port=${simulator_ssh_port}    timeout=1 minute    alias=simulator_srvr
    Login    ${simulator_srvr_username}    ${simulator_srvr_password}
    Run Keyword If    "${simulator_srvr_username}" != "root"
    ...    Run Keywords
    ...    write    sudo bash
    ...    AND    read until    ${simulator_srvr_username}:
    ...    AND    Write    ${simulator_srvr_password}
    ...    AND    Read Until    \#



start_capturing_logs
    [Arguments]    ${testcase_name}=${TEST_NAME}    ${suite_name}=${SUITE NAME.rsplit('.')[-1]}    ${path}=${PATH_TO_STORE_LOGS_PCAPS}	${mStore_session}=mStore
    ${suite_name}=    Replace String    ${suite_name}    ${SPACE}    _
    Switch Connection    ${mStore_session}
    Execute Command    killall -10 mlogc &> /dev/null
    Write    mkdir -p ${path}/"${suite_name}"/"${testcase_name}"
    Read Until    \#
    Write    /usr/IMS/current/bin/mlogc -c 127.0.0.1> ${path}/"${suite_name}"/"${testcase_name}"/"${testcase_name}".log &
    Read Until    \#

backup_TRL_TMM_File
    [Arguments]    ${testcase_name}=${TEST_NAME}    ${suite_name}=${SUITE NAME.rsplit('.')[-1]}    ${path}=${PATH_TO_STORE_LOGS_PCAPS}    ${trl_path}=${TRL_PATH}    ${tmm_path}=${TMM_PATH}    ${tag}=FCS	${mStore_session}=mStore
    ${suite_name}=    Replace String    ${suite_name}    ${SPACE}    _
    Switch Connection    ${mStore_session}
    Execute Command    mkdir -p ${path}/"${suite_name}"/"${testcase_name}"
    Execute Command    mkdir -p ${path}/"${suite_name}"/"${testcase_name}"
    ${current_tmm_path}=    Execute Command    echo ${tmm_path}/`date +%Y-%m/%d`
    ${current_trl_path}=    Execute Command    echo ${trl_path}/`date +%Y_%m/%d/%H`
    Write    cp -p ${current_tmm_path}/*${tag}* ${path}/"${suite_name}"/"${testcase_name}"/
    Read Until    \#
    Write    cp -p ${current_trl_path}/* ${path}/"${suite_name}"/"${testcase_name}"/
    Read Until    \#

backup_TRL_Files
    [Arguments]    ${testcase_name}=${TEST_NAME}    ${suite_name}=${SUITE NAME.rsplit('.')[-1]}    ${path}=${PATH_TO_STORE_LOGS_PCAPS}    ${trl_path}=${TRL_PATH}	${mStore_session}=mStore
    ${suite_name}=    Replace String    ${suite_name}    ${SPACE}    _
    Switch Connection    ${mStore_session}
    Execute Command    mkdir -p ${path}/"${suite_name}"/"${testcase_name}"
    ${current_trl_path}=    Execute Command    echo ${trl_path}/`date +%Y_%m/%d/%H`
    Write    cp -p ${current_trl_path}/* ${path}/"${suite_name}"/"${testcase_name}"/
    Read Until    \#

backup_TMM_Files
    [Arguments]    ${testcase_name}=${TEST_NAME}    ${suite_name}=${SUITE NAME.rsplit('.')[-1]}    ${path}=${PATH_TO_STORE_LOGS_PCAPS}    ${tmm_path}=${TMM_PATH}    ${tag}=PROVISION	${mStore_session}=mStore
    ${suite_name}=    Replace String    ${suite_name}    ${SPACE}    _    
    Switch Connection    ${mStore_session}
    Execute Command    mkdir -p ${path}/"${suite_name}"/"${testcase_name}"
    ${current_tmm_path}=    Execute Command    echo ${tmm_path}/`date +%Y-%m/%d`
    Write    cp -p ${current_tmm_path}/*${tag}* ${path}/"${suite_name}"/"${testcase_name}"/
    Read Until    \#

stop_capturing_logs
	[Arguments]		${mStore_session}=mStore
    Switch Connection    ${mStore_session}
    Execute Command    killall -10 mlogc &> /dev/null

start_packet_capture
    [Arguments]    ${testcase_name}=${TEST_NAME}    ${suite_name}=${SUITE NAME.rsplit('.')[-1]}    ${path}=${PATH_TO_STORE_LOGS_PCAPS}		${mStore_session}=mStore
    ${suite_name}=    Replace String    ${suite_name}    ${SPACE}    _
    Switch Connection    ${mStore_session}
    Execute Command    pkill -f tcpdump
    Write    mkdir -p ${path}/"${suite_name}"/"${testcase_name}"
    Read Until    \#
    Write    tcpdump -i any -s 0 -w ${path}/"${suite_name}"/"${testcase_name}"/"${testcase_name}".pcap &
    Read Until    \#

stop_packet_capture
	[Arguments]     ${mStore_session}=mStore
    Switch Connection    ${mStore_session}
    Execute Command    pkill -f tcpdump
	Write	date
	Read Until	\#


healthCheckofMstore
    [Arguments]    ${mstore_service_port}=${MSTORE_SERVICE_PORT}    ${mstore_regdata_port}=${MSTORE_REGDATA_SERVICE_PORT}    ${cass_Service_port}=${MSTORE_CASSANDRA_SERVICE_PORT}		${mStore_session}=mStore
    Switch Connection    ${mStore_session}
    Write    readShm
    ${State}=    Read Until    \#
    Write    netstat -alpn |grep -w ${mstore_service_port}
    ${msp}=    Read Until    \#
    Write    netstat -alpn |grep -w ${mstore_regdata_port}
    ${mrp}=    Read Until    \#
    Write    netstat -alpn |grep -w ${cass_Service_port}
    ${mcp}=    Read Until    \#

    ${State}=    Get Lines Containing String    ${State}    STATE_INS
    Run Keyword And Continue On Failure    Should Contain    ${State}    STATE_INS_ACTIVE
    
    ${msp}=    Get Lines Containing String    ${msp}    LISTEN
    Run Keyword And Continue On Failure    Should Not Be Empty    ${msp}
    ${mrp}=    Get Lines Containing String    ${mrp}    LISTEN
    Run Keyword And Continue On Failure    Should Not Be Empty    ${mrp}
    ${mcp}=    Get Lines Containing String    ${mcp}    ESTABLISHED
    Run Keyword And Continue On Failure    Should Not Be Empty    ${mcp}


StartHttpServer
    [Arguments]    ${host}    ${port}
    ${socket_server}=    open_socket    ${host}    ${port}
    [Return]    ${socket_server}

GetServicerequest
    [Arguments]    ${service}
    ${request}=    get_one_request    ${service}
    [Return]    ${request}

GetRequestData
    [Arguments]    ${request}
    ${data}=    read_request_body    ${request}
    [Return]    ${data}


SendResponse
    [Arguments]    ${request}    ${response_code}    ${message}    ${version}
    sendresponse_code    ${request}    ${response_code}    ${message}    ${version}


StopHttpServer
    [Arguments]    ${service}
    close_socket    ${service}
    

GetCoresCount
	[Arguments]		${mStore_session}=mStore
    Switch Connection   ${mStore_session} 
    ${core_cnt}=    Execute Command    ls -altr /data/storage/corefiles/core.* |wc -l
    Write    ls -altr /data/storage/corefiles/core.* 
    ${core}=    Read Until    \#
    [Return]    ${core_cnt}

CreatemStoreSubscriberSession
    [Arguments]    ${mStore_ip}=${MSTORE_IP}    ${mstore_service_port}=${MSTORE_SUBSCRIBER_SERVICE_PORT}    ${mStore_request_session}=${MSTORE_SESSION_NAME}
    Create Session    alias=${mStore_request_session}    url=http://${mStore_ip}:${mstore_service_port}

CreateSwiftSession    
    Create Session    alias=${SWIFT_SESSION_NAME}    url=http://${SWIFT_IP}:${SWIFT_PORT}

ClearTRLs_TMMs
    [Arguments]    ${trl_path}=${TRL_PATH}    ${tmm_path}=${TMM_PATH}	${mStore_session}=mStore
    Switch Connection    ${mStore_session}
    ${current_trl_path}=    Execute Command    echo ${trl_path}/`date +%Y_%m/%d/%H`
    ${current_tmm_path}=    Execute Command    echo ${tmm_path}/`date +%Y-%m/%d`
    log    ${current_trl_path}
    log    ${current_tmm_path}
    Should Not Be Empty    ${current_trl_path}    msg="TRL path is empty"
    Should Not Be Empty    ${current_tmm_path}    msg="TMM path is empty"
    Write    rm -rf ${current_trl_path}/*
    Read Until    \#
    Write    rm -rf ${current_tmm_path}/*
    Read Until    \#


get_mStore_NodeID
	[Arguments]		${mStore_dbm_session}=mStore_dbm
    Switch Connection    ${mStore_dbm_session}
    Write    select * from platform;
    Read Until    \>
    Write    select name from platform;
    ${name1}=    Read Until    \>
    ${name2}=    Get Line    ${name1}    3
    ${name}=    Strip String    ${name2}    characters=|${SPACE}
    Set Suite Variable    ${MSTORE_NODE_NAME}    ${name}
    [Return]    ${name}

Peg_TMM_file_immediately
	[Arguments]		${mStore_session}=mStore
    Switch Connection    ${mStore_session}
    Write    cd /usr/IMS/current/bin/; ./msgSender 0 52 49941 1
    ${output}=    Read Until    \#
    Should Contain    ${output}    messages has been sent out    msg="Error: Failed to Peg"

Clear_NMS_Subscription_tables
    Switch Connection    cass_db
    Write    truncate nms_subscriptions_mapping;
    Read Until    \>
    Write    truncate nms_subscriptions;
    Read Until    \>

ValidateKPIReport
    [Arguments]    ${kpi_data}    ${Field}    ${count}
    ${kpi_data}=    Run    echo "${kpi_data}" |grep -v '= 0'
    ${data}=    Get Lines Containing String    ${kpi_data}    ${Field}
    log    ${data}
    Should Not Be Empty    ${data}    msg="Generated kpi report doen't contain Field ${Field}"
    ${dec_data}=    Split String    ${data}
    Should Be Equal As Strings    ${dec_data[3]}    ${count}
   
GetObjectFromSwift
	[Arguments]		${swiftobjurl}	${response_code}=200
	${response}=    Get Request    alias=${SWIFT_SESSION_NAME}    uri=${swiftobjurl}
	log		${response.status_code}
	log		${response.text}
	log		${response.headers}
	#log     ${response.json()}
	Run Keyword and continue on Failure		Should Be Equal As Strings	${response.status_code}		${response_code}
	[Return]	${response}

Generate_random_numbers
	[Arguments]		${length}=10
    ${start_range}=     Evaluate    10**(${length}-1)
    ${end_range}=       Evaluate    (10**${length})-1
    ${random_num}=    Evaluate    random.randint(${start_range},${end_range})     random
	[Return]	${random_num}


GetDecodedTMMReport
    [Arguments]    ${service_type}="MSTORE_PROVISIONING"    ${tmm_path}=${TMM_PATH}    ${no_of_lines}=1     ${mStore_session}=mStore    ${expected_counters}=1
    ${current_tmm_path}=    Execute Command    echo ${tmm_path}/`date +%Y-%m/%d`
    Switch Connection    ${mStore_session}
    ${hdr_file}=    Execute Command    ls -lrt /data/redun/tmm/*.hdr |grep ${service_type}_TEMPLATE |awk '{print $NF}'
    Should Not Be Empty     ${hdr_file} msg="No header file for group ${service_type}"
    ${hdr_fields}=  Execute Command     cat ${hdr_file}
    log     ${hdr_fields}
    @{kpi_keys}=    Split String    ${hdr_fields}   ,
    log     ${kpi_keys}
    ${files}=       Execute Command    ls -lrt ${current_tmm_path}/*.csv
    log     ${files}
    ${kpi_file}=    Execute Command    ls -lrt ${current_tmm_path}/*.csv |grep ${service_type} |tail -n 1 |awk '{print $NF}'
    Should Not Be Empty    ${kpi_file}    msg="KPI file not generated for ${service_type}"
    ${kpi_data}=    Execute Command    cat ${kpi_file}
    log    ${kpi_data}
    ${kpi_data}=    Execute Command    cat ${kpi_file} |grep ,${expected_counters}, |tail -n ${no_of_lines}
    log    ${kpi_data}
	${kpi_values}=	Split String	${kpi_data}	,
    #${kpi_data}=   Split to Lines  ${kpi_data}
    #@{kpi_values}=  Run Keyword if   '${no_of_lines}' == '1'    Split String    ${kpi_data} ,   ELSE    Split to Lines  ${kpi_data}
    log     ${kpi_values}
	${zip_kpi_key_values}=	Evaluate	dict(zip(${kpi_keys},${kpi_values}))
	log		${zip_kpi_key_values}
    Should Not Be Empty    ${kpi_data}    msg="Counters are not generated for ${service_type}"
    Execute Command    cat ${kpi_file} |grep ,${expected_counters}, |tail -n ${no_of_lines} >/tmp/${service_type}.csv
    ${kpi_report}=    Execute Command    python /usr/IMS/current/tmm_def/tmmdecoder.py ${hdr_file} /tmp/${service_type}.csv
    log    ${kpi_report}
    Should Not Be Empty    ${kpi_report}    msg="Counters are not generated for ${service_type}"
    [Return]   ${zip_kpi_key_values} 

ValidateTMMReport
	[Arguments]         ${kpi_data}     ${peer}=${PNS_SERVER_NAME}      ${msgContext}=${MESSAGE_CONTEXT}   ${TenantId}=${EMPTY}       &{fileds_to_validate}

    Run Keyword and Continue on Failure     Should Match Regexp    ${kpi_data["STARTTIME"]}    \\d{12}
    Run Keyword and Continue on Failure     Should Match Regexp    ${kpi_data["STOPTIME"]}    \\d{12}
    Run Keyword and Continue on Failure     Should Be Equal As Strings  ${kpi_data["NodeID"]}      ${KPI_NODE_ID}
    Run Keyword and Continue on Failure     Should Be Equal As Strings  ${kpi_data["CardID"]}      ${CARD_ID}
    Run Keyword and Continue on Failure     Should Be Equal As Strings  ${kpi_data["Peer"]}      ${peer}
#    Run Keyword and Continue on Failure     Should Be Equal As Strings  ${kpi_data["MessageType"]}      ${msgContext}
#    Run Keyword and Continue on Failure     Should Be Equal As Strings  ${kpi_data["Tenant"]}	${TenantId}
	Remove From Dictionary  ${kpi_data}	STARTTIME	STOPTIME	NodeID	CardID	Peer	Tenant	FCI		HTTP_POST_AVG_LATENCY	HTTP_POST_MAX_LATENCY	HTTP_POST_MIN_LATENCY	
	${keys}=	Get Dictionary Keys		${fileds_to_validate}
	:FOR	${key}	IN	@{keys}
	\	Run Keyword and Continue on Failure     Should Be Equal As Strings	${kpi_data["${key}"]}	${fileds_to_validate["${key}"]}		msg="counter mismatch for ${key} field Expected ${fileds_to_validate['${key}']} Recieved ${kpi_data['${key}']}"
	\	Remove From Dictionary	${kpi_data}		${key}
	
	log		${kpi_data}
	${keys}=	Get Dictionary Keys		${kpi_data}
	:FOR    ${key}  IN  @{keys}
    \   Run Keyword and Continue on Failure     Should Be Equal As Strings  ${kpi_data["${key}"]}		0	msg="counter mismatch for ${key} field Expected 0 Recieved ${kpi_data['${key}']}"



