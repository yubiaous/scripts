#!/usr/bin/python
import time
import datetime
import base64
import random
import string
EPOCHTIME=	int(time.time())
LOCALHOST=	"10.10.224.173"
randomchoice="0123456789abcdef"
#############################################################################
#IP'S
#############################################################################
MSTORE_IP=								"10.10.219.158"
MSTORE_CASSANDRA_IP=                   "10.69.15.193"
PNS_SERVER=                             "10.10.224.173"
NMS_SERVER=                             "10.10.224.173"
SWIFT_IP=                               "10.10.227.17"
#############################################################################
#CREDENTIALS
#############################################################################
MSTORE_USERNAME=						"root"
MSTORE_PASSWORD=						"mavenir"
MSTORE_SSH_PORT=						22
MSTORE_SUBSCRIBER_SERVICE_PORT=			80
MSTORE_SESSION_NAME=					"mStoreService"
MSTORE_CASSANDRA_USERNAME=             "root"
MSTORE_CASSANDRA_PASSWORD=             "mavenirtmost"
MSTORE_CASSANDRA_SSH_PORT=             22
MSTORE_CASSANDRA_KEYSPACE=             "rcs_hosted_saurav"

PNS_SERVICE_PORT=						8090
PNS_SERVER_NAME=						"pns.server.mavenir1.com"
NMS_SERVICE_PORT=						6063
NMS_SUBSCRIPTION_DURATION=              7200
NMS_CLIENT_CORRELATOR=                  12345
NMS_SERVER_NAME=						NMS_SERVER
NMS_NOTIFICATION_URL=					'http://'+str(NMS_SERVER)+':'+str(NMS_SERVICE_PORT)+'/nms/subscription/88889'
nms_duration=							3600
nms_client_correlator=					123456789
VMAS_SERVICE_PORT=						8091
SWIFT_USERNAME=                        "root"
SWIFT_PASSWORD=                        "mavenir"
SWIFT_SSH_PORT=                        22
SWIFT_PORT=								8080
SWIFT_SESSION_NAME=						"swift"
#############################################################################
PATH_TO_STORE_LOGS_PCAPS=               "/data/automation/"+str(EPOCHTIME)+"/"

OEM_SERVER_ROOT_PATH=					"wsg.t-mobile.com:443"
WRG_SERVER_ROOT_PATH=					"wrg.t-mobile.com:443"

APPLE_IMAP_PORT=						145
OMTP_IMAP_PORT=							148
GooGLE_IMAP_PORT=						143

REST_USER_PASSWORD=						23456
IMAP_PASSWORD=			REST_USER_PASSWORD
REST_USER_PIN=							70157
EnCrypted_IMAP_Password=				"MjM0NTY="
EnCrypted_PIN=							"NzAxNTc="
Actual_EnCrypted_PIN=                   "4kdZKqHD6cLNwswKupaQTA=="
REST_PROVISION_URI=						"host/nms/v1/vm/provision"
REST_PROVISION_HEADER=					{"Content-Type":"application/xml","User-Agent":"VMAS","Expect":""}
SOAP_PROVISION_URI=						"/SubscriberProvisioningService/MStoreProvisionServlet"
SOAP_PROVISION_HEADER=					{"Content-Type":"text/xml;charset=UTF-8","Expect":""}
SOAP_SUBSCRIBER_ADD_OBJ_FILE=			"AddSubscriber.xml"
REST_SUBSCRIBER_ADD_OBJ_FILE=			"AddNewSubscriber.xml"
SOAP_SUBSCRIBER_DEL_OBJ_FILE=			"DeleteSubscriber.xml"
RESPONSE_HEADER_SERVER_NAME=            "Mavenir Web Application Server"
SUCCESS_STATUS=                         "SUCCESS"
SUCCESS_RESPONSE_CODE=                  200
#############################################################################################
#User Table
###############################################################################################
IMAP_PWD=								""
PIN_PWD=								""

#FeatureSettings
EnableDeltraSync=					True

#X-MSTOREFE-ADDRESS
FE_NAME=                                "mStoreFE"
NODE_ID=                                0
SLOT_ID=                                1
SHELF_ID=                               1
LOCAL_FQDN=                             "10.10.219.141"
VM_SERVICE_PORT=						8091

FROM_MSISDN=                            "9999999990"
TO_MSISDN=                              "8888888880"
TO_MSISDN1=								"7777777777"
TO_MSISDN2=								"6666666666"
TO_MSISDN3=								"5555555555"
TO_MSISDN4=								"4444444444"
TO_MSISDN5=								"3333333333"

DIGITS_COS=                            10
VM_COS=                                240
DIGITS_VMAS_COS=                       1340
DYNAMIC_COS=							999

CALLHISTORY_PARENT_PATH=				"CallHistory"
RCS_PARENT_PATH=                        "RCSMessageStore"
#MSG_FROM=								"sip:"+str(FROM_MSISDN)+"@lab.t-mobile.com"
MSG_FROM=                               "tel:+"+str(FROM_MSISDN)
MSG_TO=                                 "tel:+"+str(TO_MSISDN)
MSG_TO1=                                 "sip:"+str(TO_MSISDN5)+"@lab.t-mobile.com"
MSG_TO_GROUP_MEMBERS=					["sip:"+str(TO_MSISDN1)+"@lab.t-mobile.com","sip:"+str(TO_MSISDN2)+"@lab.t-mobile.com","sip:"+str(TO_MSISDN3)+"@lab.t-mobile.com","sip:"+str(TO_MSISDN4)+"@lab.t-mobile.com","sip:"+str(TO_MSISDN5)+"@lab.t-mobile.com"]
MSG_DEPOSIT_TIME=						datetime.datetime.now().strftime('%Y-%m-%dT%H:%M:%SZ')
CONVERSATION_ID=						"2dbc584e-fc46-4a37-9a56-c2b93246d788"
CONTRIBUTION_ID=						"e0a1029e-a48b-4ca6-b185-299dada439be"

P_ASSERTED_SERVICE=						"urn:urn-7:3gpp-service.ims.icsi.oma.cpm."
P_ASSERTED_SERVICE_PM=					str(P_ASSERTED_SERVICE)+"msg"
P_ASSERTED_SERVICE_LM=					str(P_ASSERTED_SERVICE)+"largemsg"
P_ASSERTED_SERVICE_FT=					str(P_ASSERTED_SERVICE)+"filetransfer"
P_ASSERTED_SERVICE_Chat=				str(P_ASSERTED_SERVICE)+"session"
P_ASSERTED_SERVICE_Group_PM=			str(P_ASSERTED_SERVICE)+"msg.group"
P_ASSERTED_SERVICE_Group_Chat=			str(P_ASSERTED_SERVICE)+"session.group"
P_ASSERTED_SERVICE_Group_LM=          str(P_ASSERTED_SERVICE)+"largemsg.group"
P_ASSERTED_SERVICE_Group_FT=          str(P_ASSERTED_SERVICE)+"filetransfer.group"


IMDN_MESSAGE_ID=                        "338b8af7-cb27-4ca9-aa94-99f480feceda"
CORRELATION_ID=							IMDN_MESSAGE_ID
MSG_DEPOSITTIME_EPOCH=					int(time.time())
X_IMDN_CORRELATOR=						str(FROM_MSISDN)+"_"+str(IMDN_MESSAGE_ID)
X_SIP_CALLID=							"005056884776-4d72-eb161700-1e2-571fa736-a0e46"
#################################################################################################
#MESSAGE_CONTEXT
PM_MESSAGE_CONTEXT=						"X-RCS-PM"
CHAT_MESSAGE_CONTEXT=					"X-RCS-Chat"
LM_MESSAGE_CONTEXT=						"X-RCS-LM"
FT_MESSAGE_CONTEXT=						"X-RCS-FT"
CHAT_SESSION_MESSAGE_CONTEXT=			"X-RCS-Chat-Session"
FT_SESSION_MESSAGE_CONTEXT=				"X-RCS-FT-Session"
CALLHISTORY_MESSAGE_CONTEXT=            "X-Call-History"
SESSION_MESSAGE_CONTEXT=				"SIO"
#################################################################################################
CHAT_PARENT_FOLDER_PATH=                str(RCS_PARENT_PATH)+"/Chat"
CHAT_CONTENT_TYPE=						"text/plain"
FT_CONTENT_TYPE=                        "multipart/related;boundary=\"MavRmsPhone2cpm\"; type=\"Application/X-CPM-File-Transfer\""
FT_THUMBNAIL_CONTENT_ID=				"7qbyJ@msg.pc.t-mobile.com"
FT_PAYLOAD_CONTENT_ID=					"12067658131@ttn.rcs201.sip.t-mobile.com"
FT_MULTIPART_CONTENT_TYPE=				FT_CONTENT_TYPE+str(";start=\"<")+FT_THUMBNAIL_CONTENT_ID+str(">")
CHAT_CONTENT_DATA=						"This is the new message we are depositing to test $@#^&*!0123456789"
CHAT_CONTENT_LENGTH=					len(CHAT_CONTENT_DATA)
CHAT_CHARSET=							"UTF-8"
CHAT_CONTENT_TRANSFER_ENCODING=			"quoted-printable"

LM_FT_CONTENT_TYPE=						"image/jpeg"
FT_CONTENT_TYPE1=                     "image/jpeg"
LM_DATA_SIZE=       26339


FT_PARENT_FOLDER_PATH=                str(RCS_PARENT_PATH)+"/FT"
FAX_PARENT_FOLDER_PATH=                "Media/Fax"


BOUNDARY_CONTENT=						"multipart/form-data;boundary=\"-boundaryRMS123\";"

CH_DEPOSIT_HEADERS=						{"Content-Type":"application/json","User-Agent":"TAS"}
OEM_DEPOSIT_HEADERS=					{"Content-Type":BOUNDARY_CONTENT,"User-Agent":""}
WRG_DEPOSIT_HEADERS=					{"Content-Type":BOUNDARY_CONTENT,"User-Agent":"WRG"}
RCS_HOST_URI=							"/rmsclient/nms/v1/rms/tel%3a%2b"
OEM_HOST_URI=							"/oemclient/nms/v1/ums/tel%3a%2b"
OEM_FOLDER_SEARCH_HEADER=				{"Content-Type":"application/json;","User-Agent":""}
WRG_FOLDER_SEARCH_HEADER=               {"Content-Type":"application/json;","User-Agent":"WRG"}
OEM_FETCH_HEADERS=						{"User-Agent":""}
WRG_FETCH_HEADERS=                      {"User-Agent":"WRG"}
OEM_BULK_UPDATE_HEADERS=				{"Content-Type": "application/json;","User-Agent":""}
WRG_BULK_UPDATE_HEADERS=				{"Content-Type": "application/json;","User-Agent":"WRG"}
LM_DATA_SIZE=       26339
FT_MULTIPART_DATA_SIZE=16140
#######################################################################################
#PNS sub_Type
#######################################################################################
PM_SUBTYPE_MO=							"ChatO"
PM_PNS_TYPE=							"RCSPage"
CHAT_PNS_TYPE=							"RCSSession"
LM_PNS_TYPE=                            "RCSPage"
FT_PNS_TYPE=                            "RCSSession" 
PM_PNS_SUBTYPE=							"Chat"
CH_PNS_TYPE=							"Call"
CH_PNS_SUBTYPE=							"HistoryS"
CHAT_PNS_SUBTYPE=                       "Chat"
LM_PNS_SUBTYPE=							"LMM"
FT_PNS_SUBTYPE=							"FileTransfer"
PNS_CHANNEL=							"pns_channe"
PNS_TTL=								"600"
BULK_PNS_TYPE=							"Notify"
BULK_PNS_SUBTYPE=						"FullSync"
PNS_SERVICE_NAME=						"SyncApp"
PNS_AUTH_USER=							"Aladdin"
PNS_AUTH_PASSWORD=						"khuljasimsim"
PNS_AUTHORIZATION=						base64.b64encode('Aladdin:khuljasimsim')
VAR_CHARSET=							"utf-8"
VAR_CONTENT_TRANSFER_ENCODING=			"quoted-printable"
PNS_RESPONSE_CONTENT_TYPE=				"application/json"
FAX_CONTENT_TYPE=						"multipart/mixed; boundary=\"====sep==\""
LM_CONTENT_TRANSFER_ENCODING=				"base64"
#######################################################################################
#XMl/JSON
CHAT_SESSION_OBJ_FILE=					"Chat_session_info_message.json"
FT_SESSION_OBJ_FILE=					"FT_Session_info_message.json"
PM_CHAT_DEPOSIT_OBJ_FILE=				"Deposit_PM_Chat_Msg.json"
DELIVER_DISPLAY_OBJ_FILE=				"Deliver_Display_PM_Chat_Msg.json"
PM_CHAT_GROUP_DEPOSIT_OBJ_FILE=			"Deposit_PM_Chat_Group_Msg.json"
LM_FT_GROUP_DEPOSIT_OBJ_FILE=			"Deposit_LM_FT_Group_Msg.json"
LM_FT_DEPOSIT_OBJ_FILE=					"Deposit_LM_FT_Msg.json"
CALLHISTORY_DEPOSIT_OBJ_FILE=			"Call_Log.json"
CALLHISTORY_DEPOSIT_OBJ_FILE1=          "Call_LogMissed.json"

#######################################################################################
Product=								"mstore"

#VM Related Variables
VM_INBOX_FOLDER_NAME="VV-Mail/Inbox"
VM_GREETING_FOLDER_NAME="VV-Mail/Greetings"
VM_REQUEST_URI="/host/nms/v1/vm/tel%3a%2b"
VM_MESSAGE_CONTEXT="voice-message"
VM_MESSAGE_FROM="tel:+"+str(FROM_MSISDN)
VM_MESSAGE_TO="tel:+"+str(TO_MSISDN)
VM_MESSAGE_ID="61433105412CPN61414689689D2016-02-16T05:37:34ZN19T0.amr@vha.com"
VM_PRIORITY=4
VM_SENSITIVITY="Personal"
VM_RETURN_NUMBER="tel:+"+str(FROM_MSISDN)
VM_SOURCE_NODE="VMAS"
VM_MIME_VERSION=1.0
VM_MESSAGE_VERSION=1.0
NORMAL_VM_RECORD_LENGTH=12
VM_BODY_PART_CONETENT_TYPE='multipart/mixed; boundary="----=_Part_174_8587667.1393372971162"'
VM_DEPOSIT_DATE=str(datetime.datetime.today().strftime('%FT%TZ'))
VM_Multipart_Content_Type="multipart/form-data;boundary=====outer123==;"
#VM_Multipart_Content_Type="multipart/form-data;boundary=-====outer123==;"
VM_DEPOSIT_HEADERS={"User-Agent":"VMAS","Content-Type":VM_Multipart_Content_Type}
RESTORE_OBJ_HEADERS={"User-Agent":"CCPS","Content-Type":"application/json"}
NORMAL_VM_DEPOSIT_SINGLE_RECEPIENT_OBJ_FILE="VMDepositBodyExpc.xml"
GREETING_RESTORE_OBJ_FILE="restore_api.json"
FAX_BODY_PART_CONETENT_TYPE='multipart/mixed; boundary="----=_Part_2670_675099.1391810466866"'
FAX_MESSAGE_CONTEXT="fax-message"
FAX_CONTENT_PAGES=10
FAX_SUBJECT=								'mStore Fax'
SENDER_EMAIL_ADDR=							'SENDER@mavenir.com'
RECIPIENT_EMAIL_ADDR=						'RECIPIENT@mavenir.com'
VM_DOMAIN_NAME="domain.com"
VM_RESTORE_OBJ_FILE="restore_VM_api.json"
HOST_NMS_URI="/host/nms/v1/ums/tel:+"
##################################################################################################
#
##################################################################################################
RCS_PARENT_FOLDER_KEY=						'fb830d1d-a4a5-4f58-a3ad-740be2fd2fc6'
RCSMessageStore_Chat=						'97d38f52-bed0-4046-8784-bb110e3b0ea3'
RCSMessageStore_FT=							'4b6ff8a1-df89-4c59-9ebf-4d73f95540d4'
CallHistory=								'c65f2cff-67eb-4ca1-a5e0-68f2066b20af'
FAX_MESSAGE_ID=								'338b8af7-cb27-4ca9-aa94-99f480feceda'
FAX_PARENT_FOLDER_KEY=						str(FAX_MESSAGE_ID)
##################################################################################################
MSG_CONTEXT_PM=								'X-RCS-PM'
VM_GREETING_MESSAGE_CONTEXT=				'x-voice-grtng'
##################################################################################################
VM_GREETING_SUBJECT="Append Greeting through IMAP Client"
VM_GREETING_PRIORITY=2
VM_GREETING_MESSAGE_ID="AANLkTikC5oN2rO5VTj8HN7U03b2H3HUqt89KYdemGlcJ@mavenir.com"
VM_GREETING_MIME_VERSION="1.0"
VM_GREETING_MESSAGE_VERSION="1.0"
VM_GREETING_MIME_CONTENT_TYPE='Multipart/mixed; boundary="_Part_694_2885415978"'
VM_GREETING_DURATION=12
CNS_GREETING_TYPE="normal-greeting"

OPENSTACK_SWIFT_BASE_URL="/v1"
##################################################################################################
#Call
##################################################################################################
CALLHISTORY_PARTICIPATING_DEVICE=		"urn:uuid:42E78839-75E3-46C1-B72E-61535EDFDE82"
CALL_DURATION=							"15"
CALL_STATUS=							"Answered"
CALL_STATUS1=                           "Missed"
CALL_TYPE=								"Audio"
MSGSTATUS = 							"answered"
MSGSTATUS1 =							"missed"
##################################################################################################
#For Cos 1340 
VM_NEW_MSG_TTL=	14
VM_SAVED_MSG_TTL=	21
DELETED_MSG_TTL=	13
BACKUP_TTL=		11
##################################################################################################
#KPI
##################################################################################################
KPI_DEPOSIT_PM_REQ=							"PM_Deposit"
PNS_REQUEST_SEND_KPI=						"MSTR_SND_PN_OUT_REQ_ODP_WITH_CONTENT"
PNS_RESPONSE_RVD_KPI=						"MSTR_RCVD_PN_RES_SUCC_ODP"
NMS_REST_POST_REQ=							"HTTP_POST_CREATE_REQ_RCVD"
NMS_REST_POST_RSP=							"HTTP_POST_CREATE_RSP_SENT"
MSTR_OBJ_SRCH=								"MSTORE_OBJ_SEARCH_QUERY"
MSTR_OBJ_SRCH_REQ=                          "MSTORE_OBJ_SEARCH_QUERY"
MSTR_OBJ_SRCH_RSP=							"MSTR_SND_OBJ_SEARCH_RSP_SUCC"
KPI_NODE_ID=								"sauravVariableFile"
fileds_to_validate=							{"NodeID":"Mavenir","CardID":0,"FCI":8,"Peer":MSTORE_IP,"Service":"HTTPFT"}
TRL_PATH=                               	"/data/redun/cdr/trl"
TMM_PATH=                               	"/data/redun/tmm"
##################################################################################################
#TRL
##################################################################################################
HTTP_INTERFACE_TYPE=						"1"
TRL_NODE_ID=								"0-9:mStoreFE"
store_RCS=									3
HTTPTRLCOUNT=                               201
TRL_MSG_CONTEXT_ID=                    {"X-RCS-CHAT":5,"X-RCS-FT":6,"X-RCS-CHAT-SESSION":7,"X-RCS-FT-SESSION":8,"X-RCS-CHAT-GSO":9,"X-RCS-FT-GSO":10,"FAXMESSAGE":11,"X-IVR-GREETING":12,"X-CALL-HISTORY":13,"X-RCS-PM":14,"X-RCS-LM":15}

