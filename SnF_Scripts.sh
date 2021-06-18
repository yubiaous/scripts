#!/bin/bash
#testBedIP=172.24.1.122
#testBedIP=10.10.242.145
#testBedIP=10.69.81.235
#testBedIP=10.69.84.33
testBedIP=10.10.219.158
testBed_Port=8094
#testBed_Port=8084
MSISDN=14256601102
DestUser=142566011021
OrgUser=142566011031
MessageId=958e6172-7672-11e6-8b77-86f30ca893d3
RMS_Cluster=10.10.219.66
AppID=943259
RCS=10.10.219.66

echo "===================================================================================="
echo "===============Select API to be executed ===========================================>"
echo "===================================================================================="                                                                                         
echo "              1.  Store Page Mode Message"
echo "              2.  Update Page Mode Message"
echo "              3.  IM Store Session"
echo "              4.  Store MSRP Data"
echo "              5.  Update IM Session"
echo "              6.  FT Session Store"
echo "              7.  File Data Store  -->Not Working"
echo "              8.  UpdateFTSession  -->Not Working"
echo "              9.  GC Store Participant"
echo "             10.  GC participant session data"
echo "             11.  GC Store MSRP Data"
echo "             12.  Update Group Participant Info"
echo "             13.  store FT session data"
echo "             14.  File Data Storage API"
echo "             15.  Update Group IM Session"
echo "             16.  Update Group FT Session  -->Not Working"
echo "             17.  AT Storage API"
echo "             18.  Update AT Message.json  -->Not Working"
echo "             19.  Store SMSIP Message  -->Not Working"
echo "             20.  Update SMSIP message -->Not Working"
echo "             21.  LM Session Store"
echo "             22.  LM Data Storage API"
echo "             23.  Update LM Session -->Not Working"
echo "             24.  Store SMS Message"
echo "             25.  Update SMS Message"
echo "             26.  MM4 Storage API"
echo "             27.  " 
echo "===================================================================================="
echo "                                   DELETE API"
echo "===================================================================================="
echo "             41.  IM Session Delete"
echo "             42.  FT Session Delete -->Not Working"
echo "             43.  Group IM Session Delete"
echo "             44.  Group FT Session Delete -->Not Working"
echo "             45.  LM Session Delete"
echo "             46.  IM MSRP Data Delete"
echo "             47.  PM Message Delete"
echo "             48.  AT Message Delete"
echo "             49.  SMS IP Message Delete"
echo "             50.  SMS Message Delete"
echo "===================================================================================="
echo "                              Retrieve Stored Object API"
echo "===================================================================================="
echo "             71.  PM Retrieve API"
echo "             72.  IM Session Retrieve API"
echo "             73.  IM MSRP Data Retrieve API"
echo "             74.  IM MSRP Data Retrieve API with Cursor"
echo "             75.  FT Session Retrieve API"
echo "             76.  File Data Retrieve API"
echo "             77.  SMSIP Retrieve API  -->Not Working"
echo "             78.  LM Session Retrieve API"
echo "             79.  LM Data Retrieve API"
echo "             80.  AT Retrieve API"
echo "             81.  SMS Retrieve API  -->Not Working"
echo "             82.  Group Participant Retrieve API"
echo "             83.  Group Participant IM Session Info Retrieve API -->Not Working"
echo "             84.  Group IM MSRP Data Retrieve API  -->Not Working"
echo "             85.  MM4 MMS Retrieve API  -->Not Working"
echo "             86.  Group Participant FT Session Info Retrieve API"
echo "             87.  Group File Data Retrieve API"
echo "             88. forward trigger"
echo "===================================================================================="
echo "                       Forward Notification API/For Fwd Trigger "
echo "===================================================================================="
echo "             101. PM Fwd Notification"
echo "             102. IM Session Fwd Notification"
echo "             103. SMSIP Fwd Notification"
echo "             104. SMS Fwd Notification"
echo "             105. Group IM Session Fwd Notification"
echo "             106. Group FT Session Fwd Notification"
echo "===================================================================================="
echo "                      Forward Trigger (Fwd Trigger) APIs" 
echo "===================================================================================="
echo "             110. Based on TPR"
echo "             111. Based on Alert HLR Notification"
echo "             112. serviceType=PM"
echo "===================================================================================="

echo " "
echo "NUM = '$MSISDN'"
echo "Second_MSISDN= '$second_MSISDN'"
echo "/usr/IMS/current/bin/mlogc -c 127.0.0.1 >  /root/saurav"
echo "tcpdump -w  /root/saurav"
echo "===================================================================================="
echo -n "Enter Your Choice = "

read i

echo " "
echo "Current LogPath : /root/saurav"
echo -n "Enter log/pcap Name : "
read logpathsaurav

nohup tcpdump -i any -s 65535 -w  /root/saurav/$logpathsaurav.pcap &  
tcppid=$!
/usr/IMS/current/bin/mlogc -c 127.0.0.1 > /root/saurav/$logpathsaurav.log &
logpid=$!


if [ $i -eq 1 ]
then
script_name="StorePageModeMessage.json"
echo ======================================================================================
sed -i 's/DestUser/'$DestUser'/g' ./json/$script_name
sed -i 's/OrgUser/'$OrgUser'/g' ./json/$script_name
sed -i 's/MessageId/'$MessageId'/g' ./json/$script_name
sed -i 's/RMS_Cluster/'$RMS_Cluster'/g' ./json/$script_name
echo ======================================================================================
echo Using ./json/$script_name file
echo =============File contents Begin=============
cat ./json/$script_name
echo =============File contents End=============
echo =============Cassandra querry=============
curl -v -X POST --header "Expect: " --header 'Content-Type: application/json' -T ./json/$script_name 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/store/Message?type=pageModeMsg&RmsType=On'
echo ======================================================================================
sed -i 's/'$DestUser'/DestUser/g' ./json/$script_name
sed -i 's/'$OrgUser'/OrgUser/g' ./json/$script_name
sed -i 's/'$MessageId'/MessageId/g' ./json/$script_name
sed -i 's/'$RMS_Cluster'/RMS_Cluster/g' ./json/$script_name
echo ======================================================================================


elif [ $i -eq 2 ]
then
script_name="UpdatePageModeMessage.json"
echo ======================================================================================
sed -i 's/DestUser/'$DestUser'/g' ./json/$script_name
sed -i 's/OrgUser/'$OrgUser'/g' ./json/$script_name
sed -i 's/MessageId/'$MessageId'/g' ./json/$script_name
echo Using ./json/$script_name file
echo =============File contents Begin=============
cat ./json/$script_name
echo =============File contents End=============
echo ======================================================================================
curl -v -X POST --header "Expect: " --header 'Content-Type: application/json' -T ./json/$script_name 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/store/Message?type=updatePageModeMsg&RmsType=On'
echo ======================================================================================
sed -i 's/'$DestUser'/DestUser/g' ./json/$script_name
sed -i 's/'$OrgUser'/OrgUser/g' ./json/$script_name
sed -i 's/'$MessageId'/MessageId/g' ./json/$script_name
echo ======================================================================================


elif [ $i -eq 3 ]
then
script_name="IMStoreSession.json"
echo ======================================================================================
sed -i 's/DestUser/'$DestUser'/g' ./json/$script_name
sed -i 's/OrgUser/'$OrgUser'/g' ./json/$script_name
sed -i 's/MessageId/'$MessageId'/g' ./json/$script_name
sed -i 's/RMS_Cluster/'$RMS_Cluster'/g' ./json/$script_name
echo ======================================================================================
echo Using  ./json/$script_name file
echo =============File contents =============
cat ./json/$script_name
echo ======================================================================================
curl -v -X POST --header "Expect: " --header 'Content-Type:application/json' -T ./json/$script_name  'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/store/IM?type=imSessInfo&RmsType=On'
echo ======================================================================================
sed -i 's/'$DestUser'/DestUser/g' ./json/$script_name
sed -i 's/'$OrgUser'/OrgUser/g' ./json/$script_name
sed -i 's/'$MessageId'/MessageId/g' ./json/$script_name
sed -i 's/'$RMS_Cluster'/RMS_Cluster/g' ./json/$script_name
echo ======================================================================================


elif [ $i -eq 4 ]
then
script_name="StoreMSRPData.json"
echo ======================================================================================
sed -i 's/DestUser/'$DestUser'/g' ./json/$script_name
sed -i 's/OrgUser/'$OrgUser'/g' ./json/$script_name
sed -i 's/MessageId/'$MessageId'/g' ./json/$script_name
echo ======================================================================================
echo Using  ./json/$script_name file
echo =============File contents =============
cat ./json/$script_name
echo =============File contents End=============  
curl -v -X POST --header "Expect: " --header 'Content-Type: application/json' -T ./json/$script_name 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/store/IM?type=msrpImData&RmsType=On'
echo ======================================================================================
sed -i 's/'$DestUser'/DestUser/g' ./json/$script_name
sed -i 's/'$OrgUser'/OrgUser/g' ./json/$script_name
sed -i 's/'$MessageId'/MessageId/g' ./json/$script_name
echo ======================================================================================


elif [ $i -eq 5 ]
then
script_name="UpdateIMSession.json"
echo ======================================================================================
sed -i 's/DestUser/'$DestUser'/g' ./json/$script_name
sed -i 's/OrgUser/'$OrgUser'/g' ./json/$script_name
sed -i 's/RMS_Cluster/'$RMS_Cluster'/g' ./json/$script_name
echo ======================================================================================
echo Using  ./json/$script_name file
echo =============File contents =============
cat ./json/$script_name
echo =============File contents End=============
curl -v -X POST --header "Expect: " --header 'Content-Type: application/json' -T ./json/$script_name 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/store/IM?type=updateImSessInfo&RmsType=On'
echo ======================================================================================
sed -i 's/'$DestUser'/DestUser/g' ./json/$script_name
sed -i 's/'$OrgUser'/OrgUser/g' ./json/$script_name
sed -i 's/'$RMS_Cluster'/RMS_Cluster/g' ./json/$script_name
echo ======================================================================================


elif [ $i -eq 24 ]
then
script_name="StoreSMSMessage.json"
echo ===================================================
sed -i 's/DestUser/'$DestUser'/g' ./json/$script_name
sed -i 's/OrgUser/'$OrgUser'/g' ./json/$script_name
sed -i 's/MessageId/'$MessageId'/g' ./json/$script_name
sed -i 's/RMS_Cluster/'$RMS_Cluster'/g' ./json/$script_name
echo ======================================================================================
echo Using  ./json/$script_name file
echo =============File contents =============
cat ./json/$script_name
echo =============File contents End=============
echo ======================================================================================
curl -v -X POST --header "Expect: " --header 'Content-Type:application/json' -T ./json/$script_name 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/store/Message?type=smsMsg&RmsType=On'
echo ======================================================================================
sed -i 's/'$DestUser'/DestUser/g' ./json/$script_name
sed -i 's/'$OrgUser'/OrgUser/g' ./json/$script_name
sed -i 's/'$MessageId'/MessageId/g' ./json/$script_name
sed -i 's/'$RMS_Cluster'/RMS_Cluster/g' ./json/$script_name
echo ======================================================================================


elif [ $i -eq 6 ]
then
script_name="FTSessionStore.json"
echo ===================================================
sed -i 's/DestUser/'$DestUser'/g' ./json/$script_name
sed -i 's/OrgUser/'$OrgUser'/g' ./json/$script_name
sed -i 's/RMS_Cluster/'$RMS_Cluster'/g' ./json/$script_name
echo ===================================================
echo Using  ./json/$script_name file
echo =============File contents =============
cat ./json/$script_name
echo =============File contents =============
curl -v -X POST --header "Expect: " --header 'Content-Type: application/json' -T ./json/$script_name 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/store/IM?type=ftSessInfo&RmsType=On'
echo ======================================================================================
sed -i 's/'$DestUser'/DestUser/g' ./json/$script_name
sed -i 's/'$OrgUser'/OrgUser/g' ./json/$script_name
sed -i 's/'$RMS_Cluster'/RMS_Cluster/g' ./json/$script_name
echo ======================================================================================


elif [ $i -eq 7 ]
then
script_name="FileDataStore.json"
echo Using  ./json/$script_name file
echo =============File contents =============
cat ./json/$script_name
echo =============File contents End=============  
curl -v -X POST --header "Expect: " --header 'Content-Type: application/pdf' -T ./json/$script_name 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/store/IM?type=ftData&RmsType=On&fileIdentifier=y786543ae&destUserId='$DestUser'&origUserId='$OrgUser''
echo ======================================================================================


elif [ $i -eq 8 ]
then
script_name="UpdateFTSession.json"
echo Using  ./json/$script_name file
echo =============File contents =============
cat ./json/$script_name
echo =============File contents =============
curl -v -X POST --header "Accept: " --header 'Content-Type: application/json' -T ./json/$script_name  'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/store/IM?type=updateFtSessInfo&RmsType=On'
echo ======================================================================================
echo ======================================================================================



elif [ $i -eq 9  ]
then
script_name="GCStoreParticipant.json"
echo Using  ./json/$script_name file
echo =============File contents =============
cat ./json/$script_name
echo =============Check Table=============
echo gc_participant_info
echo =====================================
curl -v -X POST --header "Expect: " --header 'Content-Type: application/json' -T ./json/$script_name 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/store/GC?type=gcCreateGroupPartInfo&RmsType=On'
echo ======================================================================================
echo ======================================================================================

elif [ $i -eq 10 ]
then
script_name="GCparticipantsessiondata.json"
echo Using  ./json/$script_name file
echo =============File contents =============
cat ./json/$script_name
echo =============File contents =============
curl -v -X POST --header "Accept: " --header 'Content-Type: application/json' -T ./json/$script_name 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/store/GC?type=gcImSessInfo&RmsType=On'
echo ======================================================================================
echo ======================================================================================


elif [ $i -eq 11 ]
then
script_name="GCStoreMSRPData.json"
echo Using  ./json/$script_name file
echo =============File contents =============
cat ./json/$script_name
echo =============File contents =============
curl -v -X POST --header "Accept: " --header 'Content-Type: application/json' -T ./json/$script_name 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/store/GC?type=grpMsrpImData&RmsType=On'
echo ======================================================================================
echo ======================================================================================


elif [ $i -eq 12 ]
then
script_name="updateGCParticipant.json"
echo Using  ./json/$script_name file
echo =============File contents =============
cat ./json/$script_name
echo =============File contents =============
curl -v -X POST --header "Expect: " --header 'Content-Type:application/json' -T ./json/$script_name 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/store/GC?type=updateGroupPartInfo&RmsType=On'
echo ======================================================================================


elif [ $i -eq 13 ]
then
script_name="storeFTsessiondata.json"
echo ======================================================================================
sed -i 's/DestUser/'$DestUser'/g' ./json/$script_name
sed -i 's/OrgUser/'$OrgUser'/g' ./json/$script_name
sed -i 's/MessageId/'$MessageId'/g' ./json/$script_name
echo ======================================================================================
echo Using  ./json/$script_name file
echo =============File contents =============
cat ./json/$script_name
echo =============File contents =============
curl -v -X POST --header "Accept: " --header 'Content-Type:application/json' -T ./json/$script_name 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/store/GC?type=grpFtImSessInfo&RmsType=On'
echo ======================================================================================
sed -i 's/'$DestUser'/DestUser/g' ./json/$script_name
sed -i 's/'$OrgUser'/OrgUser/g' ./json/$script_name
sed -i 's/'$MessageId'/MessageId/g' ./json/$script_name
echo ======================================================================================


elif [ $i -eq 14 ]
then
script_name="FileDataStorageAPI.pdf"
echo ======================================================================================
sed -i 's/DestUser/'$DestUser'/g' ./json/$script_name
sed -i 's/OrgUser/'$OrgUser'/g' ./json/$script_name
sed -i 's/MessageId/'$MessageId'/g' ./json/$script_name
echo ======================================================================================
echo Using  ./json/$script_name file
echo =============File contents =============
cat ./json/$script_name
echo =============File contents =============
curl -v -X POST --header "Accpet: " --header 'Content-Type: application/pdf' --header 'Content-transfer-encoding:base64' -T ./json/$script_name 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/store/GC?type=grpFtData&RmsType=On&conversationId=24tght&destUserId='$DestUser'&fileIdentifier='$MessageId'&origUserId='$OrgUser''
echo ======================================================================================
sed -i 's/'$DestUser'/DestUser/g' ./json/$script_name
sed -i 's/'$OrgUser'/OrgUser/g' ./json/$script_name
sed -i 's/'$MessageId'/MessageId/g' ./json/$script_name
echo ======================================================================================

elif [ $i -eq 15 ]
then
script_name="UpdateGroupIMSession.json"
echo Using  ./json/$script_name file
echo =============File contents =============
cat ./json/$script_name
echo =============File contents =============
curl -v -X POST --header "Accept: " --header 'Content-Type: application/json' -T ./json/$script_name 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/store/IM?type=updateGcImSessInfo&RmsType=On'
echo ======================================================================================


elif [ $i -eq 16 ]
then
script_name="UpdateGroupFTSession.json"
echo ======================================================================================
sed -i 's/DestUser/'$DestUser'/g' ./json/$script_name
sed -i 's/OrgUser/'$OrgUser'/g' ./json/$script_name
sed -i 's/MessageId/'$MessageId'/g' ./json/$script_name
echo ======================================================================================
echo Using  ./json/$script_name file
echo =============Request Begin=============
cat ./json/$script_name
echo =============Request end =============
curl -v -X POST --header "Accept: " --header 'Content-Type: application/json' 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/store/IM?type=updateGrpFtImSessInfo&RmsType=On'
echo ======================================================================================
sed -i 's/'$DestUser'/DestUser/g' ./json/$script_name
sed -i 's/'$OrgUser'/OrgUser/g' ./json/$script_name
sed -i 's/'$MessageId'/MessageId/g' ./json/$script_name
echo ======================================================================================


elif [ $i -eq 17 ]
then
script_name="ATStorageAPI.json"
echo ======================================================================================
sed -i 's/DestUser/'$DestUser'/g' ./json/$script_name
sed -i 's/OrgUser/'$OrgUser'/g' ./json/$script_name
sed -i 's/MessageId/'$MessageId'/g' ./json/$script_name
sed -i 's/RMS_Cluster/'$RMS_Cluster'/g' ./json/$script_name
echo ======================================================================================
echo Using  ./json/$script_name file
echo =============File contents =============
cat ./json/$script_name
echo =============File contents =============
curl -v -X POST --header "Expect: " --header 'Content-Type: application/json' -T ./json/$script_name 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/store/Message?type=atMsg'
echo ======================================================================================
sed -i 's/'$DestUser'/DestUser/g' ./json/$script_name
sed -i 's/'$OrgUser'/OrgUser/g' ./json/$script_name
sed -i 's/'$MessageId'/MessageId/g' ./json/$script_name
sed -i 's/'$RMS_Cluster'/RMS_Cluster/g' ./json/$script_name
echo ======================================================================================


elif [ $i -eq 18 ]
then
script_name="UpdateATStorageAPI.json"
echo ======================================================================================
sed -i 's/DestUser/'$DestUser'/g' ./json/$script_name
sed -i 's/OrgUser/'$OrgUser'/g' ./json/$script_name
sed -i 's/MessageId/'$MessageId'/g' ./json/$script_name
sed -i 's/RMS_Cluster/'$RMS_Cluster'/g' ./json/$script_name
echo ======================================================================================
echo Using  ./json/$script_name file
cat ./json/$script_name
echo =============Request end =============
curl -v -X POST --header "Accpet: " --header 'Content-Type: application/json' 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/store/Message?type=updateAtMsg'
echo ======================================================================================
sed -i 's/'$DestUser'/DestUser/g' ./json/$script_name
sed -i 's/'$OrgUser'/OrgUser/g' ./json/$script_name
sed -i 's/'$MessageId'/MessageId/g' ./json/$script_name
sed -i 's/'$RMS_Cluster'/RMS_Cluster/g' ./json/$script_name
echo ======================================================================================


elif [ $i -eq 19 ]
then
script_name="StoreSMSIPMessage.json"
echo ======================================================================================
sed -i 's/DestUser/'$DestUser'/g' ./json/$script_name
sed -i 's/OrgUser/'$OrgUser'/g' ./json/$script_name
sed -i 's/MessageId/'$MessageId'/g' ./json/$script_name
sed -i 's/RMS_Cluster/'$RMS_Cluster'/g' ./json/$script_name
echo ======================================================================================
echo Using  ./json/$script_name file
cat ./json/$script_name
echo =============Request end =============
curl -v -X POST --header "Accept: " --header 'Content-Type: application/json' 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/store/Message?type=smsipMsg&RmsType=On'
echo ======================================================================================
sed -i 's/'$DestUser'/DestUser/g' ./json/$script_name
sed -i 's/'$OrgUser'/OrgUser/g' ./json/$script_name
sed -i 's/'$MessageId'/MessageId/g' ./json/$script_name
sed -i 's/'$RMS_Cluster'/RMS_Cluster/g' ./json/$script_name
echo ======================================================================================


elif [ $i -eq 20 ]
then
script_name="UpdateSMSIPMessage.json"
echo =============Request Begin=============
echo Using  ./json/$script_name file
cat ./json/$script_name
echo =============Request end =============
curl -v -X POST --header "Accept: " --header 'Content-Type: application/json' 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/store/Message?type=updateSmsipMsg&RmsType=On'
echo ======================================================================================


elif [ $i -eq 21 ]
then
script_name="LMStorageAPI.json"
sed -i 's/DestUser/'$DestUser'/g' ./json/$script_name
sed -i 's/OrgUser/'$OrgUser'/g' ./json/$script_name
sed -i 's/MessageId/'$MessageId'/g' ./json/$script_name
sed -i 's/RMS_Cluster/'$RMS_Cluster'/g' ./json/$script_name
echo ======================================================================================
echo Using  ./json/$script_name file
echo =============File contents =============
cat ./json/$script_name
echo =============File contents =============
curl -v -X POST --header "Accept: " --header 'Content-Type:application/json' -T ./json/$script_name 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/store/IM?type=lmSessInfo&RmsType=On'
echo ======================================================================================
sed -i 's/'$DestUser'/DestUser/g' ./json/$script_name
sed -i 's/'$OrgUser'/OrgUser/g' ./json/$script_name
sed -i 's/'$MessageId'/MessageId/g' ./json/$script_name
sed -i 's/'$RMS_Cluster'/RMS_Cluster/g' ./json/$script_name
echo ======================================================================================


elif [ $i -eq 22 ]
then
script_name="FileDataStorageAPI.pdf"
echo ======================================================================================
cat ./json/$script_name
echo =============File contents =============
curl -v -X POST --header "Accpet: " --header 'Content-Type: application/pdf' --header 'Content-transfer-encoding:base64' -T ./json/$script_name 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/store/IM?type=type=lmData&RmsType=On&fileIdentifier='$MessageId'&destUserId='$DestUser'&origUserId='$OrgUser''
echo ======================================================================================



elif [ $i -eq 23 ]
then
script_name="UpdateLMSession.json"
echo ======================================================================================
sed -i 's/DestUser/'$DestUser'/g' ./json/$script_name
sed -i 's/OrgUser/'$OrgUser'/g' ./json/$script_name
sed -i 's/MessageId/'$MessageId'/g' ./json/$script_name
sed -i 's/RMS_Cluster/'$RMS_Cluster'/g' ./json/$script_name
echo ======================================================================================
echo Using  ./json/$script_name file
cat ./json/$script_name
echo =============File contents =============
curl -v -X POST --header "Accept: " --header 'Content-Type:application/json' 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/store/IM?type=updateLmSessInfo&RmsType=On'
echo ======================================================================================
sed -i 's/'$DestUser'/DestUser/g' ./json/$script_name
sed -i 's/'$OrgUser'/OrgUser/g' ./json/$script_name
sed -i 's/'$MessageId'/MessageId/g' ./json/$script_name
sed -i 's/'$RMS_Cluster'/RMS_Cluster/g' ./json/$script_name
echo ======================================================================================


elif [ $i -eq 25 ]
then
script_name="UpdateSMSMessage.json"
echo ======================================================================================
sed -i 's/DestUser/'$DestUser'/g' ./json/$script_name
sed -i 's/OrgUser/'$OrgUser'/g' ./json/$script_name
sed -i 's/MessageId/'$MessageId'/g' ./json/$script_name
sed -i 's/RMS_Cluster/'$RMS_Cluster'/g' ./json/$script_name
echo ======================================================================================
echo Using  ./json/$script_name file
echo =============File contents =============
cat ./json/$script_name
echo =============File contents =============
curl -v -X POST --header "Accept: " --header 'Content-Type:application/json' -T ./json/$script_name 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/store/Message?type=updateSmsMsg&RmsType=On&qcrType=Replace'
echo ======================================================================================
sed -i 's/'$DestUser'/DestUser/g' ./json/$script_name
sed -i 's/'$OrgUser'/OrgUser/g' ./json/$script_name
sed -i 's/'$MessageId'/MessageId/g' ./json/$script_name
sed -i 's/'$RMS_Cluster'/RMS_Cluster/g' ./json/$script_name
echo ======================================================================================


elif [ $i -eq 26 ]
then
script_name="MM4StorageAPI.json"
echo ======================================================================================
sed -i 's/DestUser/'$DestUser'/g' ./json/$script_name
sed -i 's/OrgUser/'$OrgUser'/g' ./json/$script_name
sed -i 's/MessageId/'$MessageId'/g' ./json/$script_name
sed -i 's/RMS_Cluster/'$RMS_Cluster'/g' ./json/$script_name
echo ======================================================================================
echo Using  ./json/$script_name file
echo =============File contents =============
cat ./json/$script_name
echo =============File contents =============
curl -v -X POST --header "Accept: " --header 'Content-Type:application/json' -T ./json/$script_name 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/store/Message?type=mm4Msg'
echo ======================================================================================
sed -i 's/'$DestUser'/DestUser/g' ./json/$script_name
sed -i 's/'$OrgUser'/OrgUser/g' ./json/$script_name
sed -i 's/'$MessageId'/MessageId/g' ./json/$script_name
sed -i 's/'$RMS_Cluster'/RMS_Cluster/g' ./json/$script_name
echo ======================================================================================

elif [ $i -eq 27 ]
then
script_name="CreateGSO.json"
echo Using  ./kumarFiles/$script_name file
echo =============File contents =============
echo =============Adding a Enterprise Fax=============
cat ./kumarFiles/$script_name
echo =============File contents =============
echo Using MSISDN value as defined in the script : $MSISDN

curl -v -X POST --header "Expect: " --header 'Content-Type: application/json;' -T ./kumarFiles/$script_name 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/store/GC?type=gcCreateGroupPartSessInfo&RmsType=On'

elif [ $i -eq 27 ]
then
echo ======================================================================================


elif [ $i -eq 28 ]
then
echo ======================================================================================
echo ======================================================================================

elif [ $i -eq 29 ]
then
echo ======================================================================================



elif [ $i -eq 30 ]
then
echo ======================================================================================
echo ======================================================================================



elif [ $i -eq 31 ]
then
echo ======================================================================================
echo ======================================================================================


elif [ $i -eq 32 ]
then
echo ======================================================================================

elif [ $i -eq 33 ]
then
echo ======================================================================================


elif [ $i -eq 34 ]
then
echo ======================================================================================



elif [ $i -eq 341 ]
then
echo ======================================================================================


elif [ $i -eq 35 ]
then
echo ======================================================================================



elif [ $i -eq 36 ]
then
echo ======================================================================================



elif [ $i -eq 37 ]
then
echo ======================================================================================



elif [ $i -eq 38 ]
then
echo ======================================================================================


elif [ $i -eq  ]
then
echo ======================================================================================



elif [ $i -eq 39 ]
then
echo ======================================================================================


elif [ $i -eq 40 ]
then
echo ======================================================================================


elif [ $i -eq 41 ]
then
echo =============File contents Begin=============
echo ======================================================================================
curl -v -X DELETE  --header "Accept: "  'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/delete/IM?type=imSessInfo&destUserId='$DestUser'&origUserId='$OrgUser'&RmsType=On'
echo ======================================================================================



elif [ $i -eq 42 ]
then
curl -v -X DELETE  --header "Accept: "  'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/delete/IM?type=ftSessInfo&destUserId='$DestUser'&origUserId='$OrgUser'&RmsType=On&fileIdentifier='$MessageId'&swiftUri=%2Fv1%2FAUTH_%5F_TMO%5FAUTO%5F1%%2F175339%5Ffile1'
echo ======================================================================================



elif [ $i -eq 43 ]
then
curl -v -X DELETE  --header "Accept: "  'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/delete/GC?type=gcImSessInfo&participantUri=12987654321&conversationId=convId1&RmsType=On'
echo ======================================================================================


elif [ $i -eq 44 ]
then
curl -v -X DELETE  --header "Accept: "  'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/delete/GC?type=gcFtSessInfo&participantUri=12987654321&RmsType=On&fileIdentifier='$MessageId'&swiftUri=%2Fv1%2FAUTH_%5F_TMO%5FAUTO%5F1%%5Ffile1'
echo ======================================================================================


elif [ $i -eq 45 ]
then
curl -v -X DELETE  --header "Accept: "  'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/delete/IM?type=lmSessInfo&destUserId='$DestUser'&RmsType=On&fileIdentifier=fileId1&swiftUri=%2Fv1%2FAUTH_%5F_TMO%%2FCONT%5F1%2F175339%5Ffile1'
echo ======================================================================================



elif [ $i -eq 46 ]
then
script_name="IMMSRPDataDelete.json"
echo =============Request Begin=============
echo Using  ./json/$script_name file
cat ./json/$script_name
echo =============Request end =============
curl -v -X POST --header "Accept: " --header 'Content-Type: application/json'  -T ./json/$script_name 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/delete/IM?type=msrpImData&destUserId='$DestUser'&origUserId='$OrgUser'&RmsType=On'
echo ======================================================================================
echo ======================================================================================


elif [ $i -eq 47 ]
then
script_name="PMMessageDelete.json"
echo =============Request Begin=============
echo Using  ./json/$script_name file
cat ./json/$script_name
echo =============Request end =============
curl -v -X POST --header "Accept: " --header 'Content-Type: application/json' -T ./json/$script_name  'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/delete/Message?type=pmMsg&destUserId='$DestUser'&RmsType=On'
echo ======================================================================================


elif [ $i -eq 48 ]
then
script_name="ATMessageDelete.json"
echo Using  ./json/$script_name
echo =============File contents =============
cat ./json/$script_name
echo =============File contents =============
curl -v -X POST --header "Accept: " --header 'Content-Type: application/json' -T ./json/$script_name 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/delete/Message?type=atMsg&appId=sysId1'
echo ======================================================================================


elif [ $i -eq 49 ]
then
script_name="SMSIPMessageDelete.json"
echo Using  ./json/$script_name file
echo =============File contents =============
cat ./json/$script_name
echo =============File contents =============
curl -v -X POST --header "Accept: " --header 'Content-Type: application/json' -T ./json/$script_name 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/delete/Message?type=smsipMsg&destUserId='$DestUser'&RmsType=Off'
echo ======================================================================================


elif [ $i -eq 50 ]
then
script_name="SMSMessageDelete.json"
echo Using  ./json/$script_name file
echo =============File contents =============
cat ./json/$script_name
echo =============File contents =============
curl -v -X POST --header "Accept: " --header 'Content-Type: application/json' -T ./json/$script_name 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/delete/Message?type=smsMsg&destUserId='$DestUser''
echo ======================================================================================


elif [ $i -eq 71 ]
then
echo =============Cassandra Querry=============
echo SELECT orig_user_id, subscriber_type, error_code, fwd_in_progress, message_id, tp_data_enc_type, tp_data, create_time, fip_updated_time, trans_data_type, trans_data FROM page_mode_svc_data WHERE dest_user_id = '$DestUser'  limit  4;
echo =====================================
curl -v -X GET 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/retrieve/Message?type=pageModeMsg&destUserId='$DestUser'&maxEntries=3&qcrType=Query'
echo ======================================================================================


elif [ $i -eq 72 ]
then
curl -v -X GET --header "X-CPM-Addr:10.10.219.66" 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/retrieve/IM?type=imSessInfo&destUserId='$DestUser'&maxEntries=3'
echo ======================================================================================



elif [ $i -eq 73 ]
then
curl -v -X GET --header "X-CPM-Addr:10.10.219.66" 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/retrieve/IM?type=msrpImData&destUserId='$DestUser'&origUserId='$OrgUser'&maxEntries=3'
echo ======================================================================================

elif [ $i -eq 74 ]
then
#curl -v -X GET --header "X-CPM-Addr:10.10.219.66" 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/retrieve/IM?type=getMsrpData&destUserId='$DestUser'&origUserId='$OrgUser'&maxEntries=3&fromCursor=cursorId1'
curl -v -X GET --header "X-CPM-Addr:10.10.219.66" 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/retrieve/IM?type=getMsrpData&destUserId='$DestUser'&origUserId='$OrgUser'&maxEntries=3'
echo ======================================================================================


elif [ $i -eq 75 ]
then
curl -v -X GET --header "X-CPM-Addr:10.10.219.66" 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/retrieve/IM?type=ftSessInfo&destUserId='$DestUser'&maxEntries=3'
echo ======================================================================================

elif [ $i -eq 76 ]
then
#curl -v -X GET --header "X-CPM-Addr:10.10.219.66" 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/retrieve/IM?type= ftData&destUserId='$DestUser'&origUserId='$OrgUser'&fileIdentifier='$MessageId'&swiftUri=%2Fv1%2FAUTH_%5F_TMO%5FAUTO%5F1%2FCONT%2FCONT%5F1%2F175339%5Ffile1'
curl -v -X GET --header "X-CPM-Addr:10.10.219.66" 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/retrieve/IM?type=ftData&destUserId='$DestUser'&origUserId='$OrgUser'&fileIdentifier='$MessageId'&swiftUri=%2Fv1%2FAUTH_%5F_TMO%5FAUTO%5F1%2FCONT%2FCONT%5F1%2F175339%5Ffile1'
echo ======================================================================================


elif [ $i -eq 77 ]
then
curl -v -X GET --header "X-CPM-Addr:10.10.219.66" 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/retrieve/Message?type=smsipMsg&destUserId='$DestUser'&maxEntries=3'
echo ======================================================================================


elif [ $i -eq 78 ]
then
curl -v -X GET --header "X-CPM-Addr:10.10.219.66" 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/retrieve/Message?type=lmSessInfo&destUserId='$DestUser'&maxEntries=3'
echo ======================================================================================


elif [ $i -eq 79 ]
then
curl -v -X GET --header "X-CPM-Addr:10.10.219.66" 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/retrieve/Message?type=lmData&destUserId='$DestUser'&origUserId='$OrgUser'&fileIdentifier='$MessageId'&swiftUri=/v1/AUTH_RMS_1123_1/CONT_1/958e6172-7672-11e6-8b77-86f30ca893d3_1558469122000'
echo ======================================================================================


elif [ $i -eq 80 ]
then
curl -v -X GET --header "X-CPM-Addr:10.10.219.66" 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/retrieve/Message?type=atMsg&appId=943259&maxEntries=3&destUserId='$DestUser''
echo ======================================================================================


elif [ $i -eq 81 ]
then
curl -v -X GET --header "X-CPM-Addr:10.10.219.66" 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/retrieve/Message?type=smsMsg&appId=943259&maxEntries=3'
echo ======================================================================================


elif [ $i -eq 82 ]
then
echo =============Check Table=============
echo gc_participant_info
echo =====================================
curl -v -X GET --header "X-CPM-Addr:10.10.219.66" 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/retrieve/GC?type=getPartListInfo&conversationId='URI'&RmsType=On'
echo ======================================================================================


elif [ $i -eq 83 ]
then
curl -v -X GET --header "X-CPM-Addr:10.10.219.66" 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/retrieve/GC?type=gcGetPartSessInfo&destUserId='$DestUser'&RmsType=On&maxEntries=3'
echo ======================================================================================


elif [ $i -eq 84 ]
then
curl -v -X GET --header "X-CPM-Addr:10.10.219.66" 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/retrieve/GC?type=getGrpmsrpData&destUserId='$DestUser'&conversationId=convId1&RmsType=On&maxEntries=3'
echo ======================================================================================


elif [ $i -eq 85 ]
then
curl -v -X GET --header "X-CPM-Addr:10.10.219.66" 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/retrieve/Message?type=mm4Msg&appId='$AppID'&maxEntries=3'
echo ======================================================================================


elif [ $i -eq 86 ]
then
curl -v -X GET --header "X-CPM-Addr:10.10.219.66" 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/retrieve/GC?type=gcFtGetPartSessInfo&destUserId='$DestUser'&RmsType=On&maxEntries=3'
echo ======================================================================================


elif [ $i -eq 87 ]
then
echo curl -v -X GET --header "X-CPM-Addr:10.10.219.66" 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/retrieve/IM?type=grpFtData&destUserId='$DestUser'&fileIdentifier='$MessageId'&conversationId=txartunvi&swiftUri=%2Fv1%2FAUTH_%5F_TMO%5FAUTO%5F1%2FCONT%2FCONT%5F1%2F175339%5Ffile1'

curl -v -X GET --header "X-CPM-Addr:10.10.219.66" 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/retrieve/IM?type=grpFtData&destUserId='$DestUser'&fileIdentifier='$MessageId'&conversationId=txartunvi&swiftUri=%2Fv1%2FAUTH_%5F_TMO%5FAUTO%5F1%2FCONT%2FCONT%5F1%2F175339%5Ffile1'
echo ======================================================================================



elif [ $i -eq 88 ]
then

curl -v -X GET --header "X-CPM-Addr:10.10.219.66" 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/forward/service?type=fwdTrigger&serviceType=pm&destUserId='$DestUser'&triggerChannel=AlertNotification&RmsType=On'
echo ======================================================================================


elif [ $i -eq 101 ]
then
script_name="PMFwdNotification.json"
echo ======================================================================================
sed -i 's/DestUser/'$DestUser'/g' ./json/$script_name
sed -i 's/OrgUser/'$OrgUser'/g' ./json/$script_name
sed -i 's/MessageId/'$MessageId'/g' ./json/$script_name
sed -i 's/RMS_Cluster/'$RMS_Cluster'/g' ./json/$script_name
echo ======================================================================================
echo Using  ./json/$script_name file
cat ./json/$script_name
echo =============File contents =============
curl -v -X POST --header "Accept: " --header 'Content-Type:application/json' -T ./json/$script_name 'http://'10.10.219.66':'8081'/mStoreRoot/V1/SF/forward/Message?type=pageModeMsg'
echo ======================================================================================
sed -i 's/'$DestUser'/DestUser/g' ./json/$script_name
sed -i 's/'$OrgUser'/OrgUser/g' ./json/$script_name
sed -i 's/'$MessageId'/MessageId/g' ./json/$script_name
sed -i 's/'$RMS_Cluster'/RMS_Cluster/g' ./json/$script_name
echo ======================================================================================


elif [ $i -eq 102 ]
then
script_name="IMSessionFwdNotification.json"
echo ======================================================================================
sed -i 's/DestUser/'$DestUser'/g' ./json/$script_name
sed -i 's/OrgUser/'$OrgUser'/g' ./json/$script_name
sed -i 's/MessageId/'$MessageId'/g' ./json/$script_name
sed -i 's/RMS_Cluster/'$RMS_Cluster'/g' ./json/$script_name
echo ======================================================================================
echo Using  ./json/$script_name file
cat ./json/$script_name
echo =============File contents =============
curl -v -X POST --header "Accept: " --header 'Content-Type:application/json' -T ./json/$script_name 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/forward/IM?type=imSessInfo'
echo ======================================================================================
sed -i 's/'$DestUser'/DestUser/g' ./json/$script_name
sed -i 's/'$OrgUser'/OrgUser/g' ./json/$script_name
sed -i 's/'$MessageId'/MessageId/g' ./json/$script_name
sed -i 's/'$RMS_Cluster'/RMS_Cluster/g' ./json/$script_name
echo ======================================================================================


elif [ $i -eq 103 ]
then
script_name="SMSIPFwdNotification.json"
echo ======================================================================================
sed -i 's/DestUser/'$DestUser'/g' ./json/$script_name
sed -i 's/OrgUser/'$OrgUser'/g' ./json/$script_name
sed -i 's/MessageId/'$MessageId'/g' ./json/$script_name
sed -i 's/RMS_Cluster/'$RMS_Cluster'/g' ./json/$script_name
echo ======================================================================================
echo Using  ./json/$script_name file
cat ./json/$script_name
echo =============File contents =============
curl -v -X POST --header "Accept: " --header 'Content-Type:application/json' -T ./json/$script_name 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/forward/Message?type=smsipMsg'
echo ======================================================================================
sed -i 's/'$DestUser'/DestUser/g' ./json/$script_name
sed -i 's/'$OrgUser'/OrgUser/g' ./json/$script_name
sed -i 's/'$MessageId'/MessageId/g' ./json/$script_name
sed -i 's/'$RMS_Cluster'/RMS_Cluster/g' ./json/$script_name
echo ======================================================================================


elif [ $i -eq 104 ]
then
script_name="SMSIPFwdNotification.json"
echo ======================================================================================
sed -i 's/DestUser/'$DestUser'/g' ./json/$script_name
sed -i 's/OrgUser/'$OrgUser'/g' ./json/$script_name
sed -i 's/MessageId/'$MessageId'/g' ./json/$script_name
sed -i 's/RMS_Cluster/'$RMS_Cluster'/g' ./json/$script_name
echo ======================================================================================
echo Using  ./json/$script_name file
cat ./json/$script_name
echo =============File contents =============
curl -v -X POST --header "Accept: " --header 'Content-Type:application/json' -T ./json/$script_name 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/forward/Message?type=smsMsg'
echo ======================================================================================
sed -i 's/'$DestUser'/DestUser/g' ./json/$script_name
sed -i 's/'$OrgUser'/OrgUser/g' ./json/$script_name
sed -i 's/'$MessageId'/MessageId/g' ./json/$script_name
sed -i 's/'$RMS_Cluster'/RMS_Cluster/g' ./json/$script_name
echo ======================================================================================


elif [ $i -eq 105 ]
then
script_name="GroupIMSessionFwdNotification.json"
echo ======================================================================================
sed -i 's/DestUser/'$DestUser'/g' ./json/$script_name
sed -i 's/OrgUser/'$OrgUser'/g' ./json/$script_name
sed -i 's/MessageId/'$MessageId'/g' ./json/$script_name
sed -i 's/RMS_Cluster/'$RMS_Cluster'/g' ./json/$script_name
echo ======================================================================================
echo Using  ./json/$script_name file
cat ./json/$script_name
echo =============File contents =============
curl -v -X POST --header "Accept: " --header 'Content-Type:application/json' -T ./json/$script_name 'http://'10.10.219.66':'7889'/mStoreRoot/V1/SF/forward/GC?type=gcImSessInfo'
echo ======================================================================================
sed -i 's/'$DestUser'/DestUser/g' ./json/$script_name
sed -i 's/'$OrgUser'/OrgUser/g' ./json/$script_name
sed -i 's/'$MessageId'/MessageId/g' ./json/$script_name
sed -i 's/'$RMS_Cluster'/RMS_Cluster/g' ./json/$script_name
echo ======================================================================================


elif [ $i -eq 106 ]
then
script_name="GroupFTSessionFwdNotification.json"
echo ======================================================================================
sed -i 's/DestUser/'$DestUser'/g' ./json/$script_name
sed -i 's/OrgUser/'$OrgUser'/g' ./json/$script_name
sed -i 's/MessageId/'$MessageId'/g' ./json/$script_name
sed -i 's/RMS_Cluster/'$RMS_Cluster'/g' ./json/$script_name
echo ======================================================================================
echo Using  ./json/$script_name file
cat ./json/$script_name
echo =============File contents =============
curl -v -X POST --header "Accept: " --header 'Content-Type:application/json' -T ./json/$script_name 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/forward/GC?type=grpFtImSessInfo'
echo ======================================================================================
sed -i 's/'$DestUser'/DestUser/g' ./json/$script_name
sed -i 's/'$OrgUser'/OrgUser/g' ./json/$script_name
sed -i 's/'$MessageId'/MessageId/g' ./json/$script_name
sed -i 's/'$RMS_Cluster'/RMS_Cluster/g' ./json/$script_name
echo ======================================================================================


elif [ $i -eq 107 ]
then
script_name="LongSMSReassemblyFwdNotification.json"
echo ======================================================================================
sed -i 's/DestUser/'$DestUser'/g' ./json/$script_name
sed -i 's/OrgUser/'$OrgUser'/g' ./json/$script_name
sed -i 's/MessageId/'$MessageId'/g' ./json/$script_name
sed -i 's/RMS_Cluster/'$RMS_Cluster'/g' ./json/$script_name
echo ======================================================================================
echo Using  ./json/$script_name file
cat ./json/$script_name
echo =============File contents =============
curl -v -X POST --header "Accept: " --header 'Content-Type:application/json' -T ./json/$script_name 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/forward/SmsReassembly?type=smsReassembly'
echo ======================================================================================
sed -i 's/'$DestUser'/DestUser/g' ./json/$script_name
sed -i 's/'$OrgUser'/OrgUser/g' ./json/$script_name
sed -i 's/'$MessageId'/MessageId/g' ./json/$script_name
sed -i 's/'$RMS_Cluster'/RMS_Cluster/g' ./json/$script_name
echo ======================================================================================


elif [ $i -eq 110 ]
then
curl -v -X GET 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/forward/service?type=fwdTrigger&serviceType=p2p_ft&serviceType=p2p_im&serviceType=pm&serviceType=smsip&serviceType=grp_im&serviceType=grp_ft&destUserId='$DestUser'&triggerChannel=TPR'

echo ======================================================================================


elif [ $i -eq 111 ]
then
curl -v -X GET 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/forward/service?type=fwdTrigger&serviceType=p2p_ft&serviceType=p2p_im&serviceType=pm&serviceType=smsip&serviceType=grp_im&serviceType=grp_ft&serviceType=sms&destUserId='$DestUser'&triggerChannel=AlertNotification&RmsType=On'
echo ======================================================================================

elif [ $i -eq 112 ]
then

curl -v -X GET --header "X-CPM-Addr:10.10.219.66" 'http://'$testBedIP':'$testBed_Port'/mStoreRoot/V1/SF/forward/service?type=fwdTrigger&serviceType=pm&destUserId='$DestUser'&triggerChannel=AlertNotification&RmsType=On'
echo ======================================================================================

elif [ $i -eq 202 ]
then
echo -n "Enter Uid :"
read Uid
echo -n "Enter Uid2 :"
read Uid2
script_name="moveToDeleted.json"
sed -i 's/MSISDN/'$MSISDN'/g' ./xmlfiles/$script_name
sed -i '7 s/UID/'$Uid'/g' ./xmlfiles/$script_name
sed -i '8 s/UID/'$Uid2'/g' ./xmlfiles/$script_name
echo =============File contents =============
cat ./xmlfiles/$script_name
echo =============File contents =============
echo Use Web Rest Client POST 'http://'$testBedIP':'$testBed_Port'/oemclient/nms/v1/ums/tel%3A%2B'$MSISDN'/folders/operations/moveToFolder'
curl -v -X POST --header "Accept: " --header 'Content-Type: application/json' -T ./xmlfiles/$script_name  -A ' ' 'http://'$testBedIP':'$testBed_Port'/oemclient/nms/v1/ums/tel%3A%2B'$MSISDN'/folders/operations/moveToFolder'
echo ======================================================================================
sed -i 's/'$MSISDN'/MSISDN/g' ./xmlfiles/$script_name
sed -i '7 s/UID/'$Uid'/g' ./xmlfiles/$script_name
sed -i '8 s/UID/'$Uid2'/g' ./xmlfiles/$script_name
echo ======================================================================================

elif [ $i -eq 203 ]
then
script_name="VoicemailDpst_Purge.xml"
echo Using ./xmlfiles/$script_name file
echo =============File contents Begin=============
sed -i 's/MSISDN_file/'$MSISDN'/g' ./xmlfiles/$script_name
cat ./xmlfiles/$script_name
echo =============File contents End=============
echo ======================================================================================
echo Use Web Rest Client POST 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/tel%3A%2B'$MSISDN'/objects/'
curl -v -X POST --header "Expect: " --header 'Content-Type: boundary="====outer123=="' -T ./xmlfiles/$script_name 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/tel%3A%2B'$MSISDN'/objects'
echo ======================================================================================
sed -i 's/'$MSISDN'/MSISDN_file/g' ./xmlfiles/$script_name
echo ======================================================================================

elif [ $i -eq 204 ]
then
script_name="fax_deposit_Purge.xml"
echo Using  ./xmlfiles/$script_name file
echo =============File contents =============
sed -i 's/MSISDN_file/'$MSISDN'/g' ./xmlfiles/$script_name
cat ./xmlfiles/$script_name
echo =============File contents End=============
echo ======================================================================================
echo Use Web Rest Client POST 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/tel%3A%2B'$MSISDN'/objects'
curl -v -X POST --header "Expect: " --header 'Content-Type: multipart/form-data;boundary="====outer123==";' -T ./xmlfiles/$script_name 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/tel%3A%2B'$MSISDN'/objects'
echo ======================================================================================
sed -i 's/'$MSISDN'/MSISDN_file/g' ./xmlfiles/$script_name
echo ======================================================================================


elif [ $i -eq 205 ]
then
#echo -n "Enter second MSISDN = " 
#read secondMSISDN
script_name="TUI_VoicemailDpst_MultiRcpt.json"
echo Using  ./xmlfiles/$script_name file
sed -i '35 s/MSISDN_file/'$MSISDN'/g' ./xmlfiles/$script_name
sed -i '36 s/MSISDN_second/'$secondMSISDN'/g' ./xmlfiles/$script_name
echo =============File contents =============

cat ./xmlfiles/$script_name
echo =============File contents =============
echo Use Web Rest Client PUT 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/multircpt/objects/operations/bulkCreation'
curl -v -X POST --header "Expect: " --header 'Content-Type: multipart/form-data;boundary="====outer123==";' -T ./xmlfiles/$script_name 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/multircpt/objects/operations/bulkCreation'
echo ======================================================================================
sed -i '35 s/'$MSISDN'/MSISDN_file/g' ./xmlfiles/$script_name
sed -i '36 s/'$secondMSISDN'/MSISDN_second/g' ./xmlfiles/$script_name
echo ======================================================================================

elif [ $i -eq 206 ]
then
echo =============Request Begin=============
echo GET /uccAs/nms/v1/vm/backupProfile/'$MSISDN'/profile HTTP/1.1
echo =============Request end =============
echo Use Web Rest Client GET 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/backupProfile/'$MSISDN'/profile '
curl -v -X GET 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/backupProfile/'$MSISDN'/profile'
echo ======================================================================================
echo ======================================================================================

elif [ $i -eq 207 ]
then
echo -n "Enter BackupUserId :"
read BackupID
script_name="User_restore.xml"
sed -i 's/MSISDN_file/'$MSISDN'/g' ./xmlfiles/$script_name
sed -i ' s/BackID/'$BackupID'/g' ./xmlfiles/$script_name
echo =============File contents =============
cat ./xmlfiles/$script_name
echo =============File contents =============
echo Use Web Rest Client POST 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/restoreProfile'
#curl -v -X POST --header "Accept: " --header 'Content-Type: application/xml' -T ./xmlfiles/$script_name  -A ' ' 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/restoreProfile'
curl -v -X POST --header "Expect: " --header 'Content-Type: application/xml' -T dynamicUserAdd_restore.xml  'http://10.10.218.153:80/uccAs/nms/v1/vm/restoreProfile'
echo ======================================================================================
sed -i 's/'$MSISDN'/MSISDN_file/g' ./xmlfiles/$script_name
sed -i 's/'$BackupID'/BackID/g' ./xmlfiles/$script_name
echo ======================================================================================

elif [ $i -eq 211 ]
then
script_name="MC_VM_DEPOSIT.xml"
echo Using ./xmlfiles/$script_name file
echo =============File contents Begin=============
sed -i 's/MSISDN_file/'$MSISDN'/g' ./xmlfiles/$script_name
cat ./xmlfiles/$script_name
echo =============File contents End=============
echo ======================================================================================
echo Use Web Rest Client POST 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/tel%3A%2B'$MSISDN'/objects/'
curl -v -X POST --header "Expect: " --header 'Content-Type: multipart/form-data;boundary="====outer123==";' -T ./xmlfiles/$script_name -A "MC" 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/tel%3A%2B'$MSISDN'/objects'
echo ======================================================================================
sed -i 's/'$MSISDN'/MSISDN_file/g' ./xmlfiles/$script_name
echo ======================================================================================


elif [ $i -eq 212 ]
then
script_name="MC_Forward_voice_mail_deposit.xml"
echo Using ./xmlfiles/$script_name file
echo =============File contents Begin=============
sed -i 's/MSISDN_file/'$MSISDN'/g' ./xmlfiles/$script_name
cat ./xmlfiles/$script_name
echo =============File contents End=============
echo ======================================================================================
echo Use Web Rest Client POST 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/tel%3A%2B'$MSISDN'/objects/'
curl -v -X POST --header "Expect: " --header 'Content-Type: multipart/form-data;boundary="====outer123==";' -T ./xmlfiles/$script_name -A "MC" 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/tel%3A%2B'$MSISDN'/objects'
echo ======================================================================================
sed -i 's/'$MSISDN'/MSISDN_file/g' ./xmlfiles/$script_name
echo ======================================================================================


elif [ $i -eq 214 ]
then
script_name="MC_Reply_voice_mail_deposit.xml"
echo Using ./xmlfiles/$script_name file
echo =============File contents Begin=============
sed -i 's/MSISDN_file/'$MSISDN'/g' ./xmlfiles/$script_name
cat ./xmlfiles/$script_name
echo =============File contents End=============
echo ======================================================================================
echo Use Web Rest Client POST 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/tel%3A%2B'$MSISDN'/objects/'
curl -v -X POST --header "Expect: " --header 'Content-Type: multipart/form-data;boundary="====outer123==";' -T ./xmlfiles/$script_name -A "MC" 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/tel%3A%2B'$MSISDN'/objects'
echo ======================================================================================
sed -i 's/'$MSISDN'/MSISDN_file/g' ./xmlfiles/$script_name
echo ======================================================================================


elif [ $i -eq 215 ]
then
script_name="MC_DSN_voice_mail_deposit.xml"
echo Using ./xmlfiles/$script_name file
echo =============File contents Begin=============
sed -i 's/MSISDN_file/'$MSISDN'/g' ./xmlfiles/$script_name
cat ./xmlfiles/$script_name
echo =============File contents End=============
echo ======================================================================================
echo Use Web Rest Client POST 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/tel%3A%2B'$MSISDN'/objects/'
curl -v -X POST --header "Expect: " --header 'Content-Type: multipart/form-data;boundary="====outer123==";' -T ./xmlfiles/$script_name -A "MC" 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/tel%3A%2B'$MSISDN'/objects'
echo ======================================================================================
sed -i 's/'$MSISDN'/MSISDN_file/g' ./xmlfiles/$script_name
echo ======================================================================================


elif [ $i -eq 216 ] 
then
script_name="MC_MDN_voice_mail_deposit.xml"
echo Using ./xmlfiles/$script_name file
echo =============File contents Begin=============
sed -i 's/MSISDN_file/'$MSISDN'/g' ./xmlfiles/$script_name
cat ./xmlfiles/$script_name
echo =============File contents End=============
echo ======================================================================================
echo Use Web Rest Client POST 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/tel%3A%2B'$MSISDN'/objects/'
curl -v -X POST --header "Expect: " --header 'Content-Type: multipart/form-data;boundary="====outer123==";' -T ./xmlfiles/$script_name -A "MC" 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/tel%3A%2B'$MSISDN'/objects'
echo ======================================================================================
sed -i 's/'$MSISDN'/MSISDN_file/g' ./xmlfiles/$script_name
echo ======================================================================================


elif [ $i -eq 217 ]
then
script_name="MC_FAX_DEPOSIT_deposit.xml"
echo Using ./xmlfiles/$script_name file
echo =============File contents Begin=============
sed -i 's/MSISDN_file/'$MSISDN'/g' ./xmlfiles/$script_name
cat ./xmlfiles/$script_name
echo =============File contents End=============
echo ======================================================================================
echo Use Web Rest Client POST 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/tel%3A%2B'$MSISDN'/objects/'
curl -v -X POST --header "Expect: " --header 'Content-Type: multipart/form-data;boundary="====outer123==";' -T ./xmlfiles/$script_name -A "MC" 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/tel%3A%2B'$MSISDN'/objects'
echo ======================================================================================
sed -i 's/'$MSISDN'/MSISDN_file/g' ./xmlfiles/$script_name
echo ======================================================================================

elif [ $i -eq 218 ]
then
script_name="MC_Forward_FAX_DEPOSIT_deposit.xml"
echo Using ./xmlfiles/$script_name file
echo =============File contents Begin=============
sed -i 's/MSISDN_file/'$MSISDN'/g' ./xmlfiles/$script_name
cat ./xmlfiles/$script_name
echo =============File contents End=============
echo ======================================================================================
echo Use Web Rest Client POST 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/tel%3A%2B'$MSISDN'/objects/'
curl -v -X POST --header "Expect: " --header 'Content-Type: multipart/form-data;boundary="====outer123==";' -T ./xmlfiles/$script_name -A "MC" 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/tel%3A%2B'$MSISDN'/objects'
echo ======================================================================================
sed -i 's/'$MSISDN'/MSISDN_file/g' ./xmlfiles/$script_name
echo ======================================================================================

elif [ $i -eq 219 ]
then
script_name="MC_Reply_FAX_DEPOSIT_deposit.xml"
echo Using ./xmlfiles/$script_name file
echo =============File contents Begin=============
sed -i 's/MSISDN_file/'$MSISDN'/g' ./xmlfiles/$script_name
cat ./xmlfiles/$script_name
echo =============File contents End=============
echo ======================================================================================
echo Use Web Rest Client POST 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/tel%3A%2B'$MSISDN'/objects/'
curl -v -X POST --header "Expect: " --header 'Content-Type: multipart/form-data;boundary="====outer123==";' -T ./xmlfiles/$script_name -A "MC" 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/tel%3A%2B'$MSISDN'/objects'
echo ======================================================================================
sed -i 's/'$MSISDN'/MSISDN_file/g' ./xmlfiles/$script_name
echo ======================================================================================

elif [ $i -eq 220 ]
then
script_name="MC_DSN_FAX_DEPOSIT_deposit.xml"
echo Using ./xmlfiles/$script_name file
echo =============File contents Begin=============
sed -i 's/MSISDN_file/'$MSISDN'/g' ./xmlfiles/$script_name
cat ./xmlfiles/$script_name
echo =============File contents End=============
echo ======================================================================================
echo Use Web Rest Client POST 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/tel%3A%2B'$MSISDN'/objects/'
curl -v -X POST --header "Expect: " --header 'Content-Type: multipart/form-data;boundary="====outer123==";' -T ./xmlfiles/$script_name -A "MC" 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/tel%3A%2B'$MSISDN'/objects'
echo ======================================================================================
sed -i 's/'$MSISDN'/MSISDN_file/g' ./xmlfiles/$script_name
echo ======================================================================================

elif [ $i -eq 221 ]
then
script_name="MC_MDN_FAX_DEPOSIT_deposit.xml"
echo Using ./xmlfiles/$script_name file
echo =============File contents Begin=============
sed -i 's/MSISDN_file/'$MSISDN'/g' ./xmlfiles/$script_name
cat ./xmlfiles/$script_name
echo =============File contents End=============
echo ======================================================================================
echo Use Web Rest Client POST 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/tel%3A%2B'$MSISDN'/objects/'
curl -v -X POST --header "Expect: " --header 'Content-Type: multipart/form-data;boundary="====outer123==";' -T ./xmlfiles/$script_name -A "MC" 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/tel%3A%2B'$MSISDN'/objects'
echo ======================================================================================
sed -i 's/'$MSISDN'/MSISDN_file/g' ./xmlfiles/$script_name
echo ======================================================================================

elif [ $i -eq 222  ]
then
script_name="MC_VG_deposit.xml"
echo Using ./xmlfiles/$script_name file
echo =============File contents Begin=============
sed -i 's/MSISDN_file/'$MSISDN'/g' ./xmlfiles/$script_name
cat ./xmlfiles/$script_name
echo =============File contents End=============
echo ======================================================================================
echo Use Web Rest Client POST 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/tel%3A%2B'$MSISDN'/objects/'
curl -v -X POST --header "Expect: " --header 'Content-Type: multipart/form-data;boundary="====outer123==";' -T ./xmlfiles/$script_name -A "MC" 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/tel%3A%2B'$MSISDN'/objects'
echo ======================================================================================
sed -i 's/'$MSISDN'/MSISDN_file/g' ./xmlfiles/$script_name
echo ======================================================================================

elif [ $i -eq 223 ]
then
script_name="MC_folder_update.xml"
echo -n "Enter FolderKey: "
read FolderKey
echo -n "Enter UID: "
read uid
echo -n "Enter UIDValidity: "
read Validity
echo Using ./xmlfiles/$script_name file
echo =============File contents Begin=============
sed -i 's/MSISDN_file/'$MSISDN'/g' ./xmlfiles/$script_name
sed -i '7 s/UID_FILE/'$uid'/g' ./xmlfiles/$script_name
sed -i '11 s/UID_valid_file/'$Validity'/g' ./xmlfiles/$script_name
cat ./xmlfiles/$script_name
echo =============File contents End=============
echo ======================================================================================
echo Use Web Rest Client PUT 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/tel%3A%2B'$MSISDN'/folders/'$FolderKey'/updateFolderAttributes'
curl -v -X PUT --header "Expect: " --header 'Content-Type: application/xml' -T ./xmlfiles/$script_name -A "MC" 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/tel%3A%2B'$MSISDN'/folders/'$FolderKey'/updateFolderAttributes'
echo ======================================================================================
sed -i 's/'$MSISDN'/MSISDN_file/g' ./xmlfiles/$script_name
sed -i '7 s/'$uid'/UID_FILE/g' ./xmlfiles/$script_name
sed -i '11 s/'$Validity'/UID_valid_file/g' ./xmlfiles/$script_name
echo ======================================================================================

elif [ $i -eq 224 ]
then
echo =============Request Begin=============

echo =============Request end =============
echo Use Web Rest Client GET 'http://'$testBedIP':'$testBed_Port'/oemclient/nms/v1/vms/tel%3A%2B'$MSISDN'/folders/c1a7c823-fdd1-4857-8d44-b315444d2a83?attrFilter=Quota'
curl -v -X GET --header "Accept: " --header 'Content-Type: application/xml' -A ' ' 'http://'$testBedIP':'$testBed_Port'/uccAs/nms/v1/vm/tel%3A%2B'$MSISDN'/folders/27a29814-dd8f-43ee-b768-19af98bf1d07?attrFilter=Getquota'
echo ======================================================================================
echo ======================================================================================


elif [ $i -eq 225 ]
then
echo =============Request Begin=============

echo =============Request end =============
echo Use Web Rest Client GET 'http://'$testBedIP':'$testBed_Port'/oemclient/nms/v1/vms/tel%3A%2B'$MSISDN'/folders/c1a7c823-fdd1-4857-8d44-b315444d2a83?attrFilter=Quota'
curl -v -X GET --header "Accept: " --header 'Content-Type: application/xml' -A ' ' 'http://'$testBedIP':'$testBed_Port'/host/nms/v1/vm/tel%3A%2B'$MSISDN'/folders/c1a7c823-fdd1-4857-8d44-b315444d2a83?attrFilter=Getquota'
echo ======================================================================================
echo ======================================================================================

elif [ $i -eq 226 ]
then
echo =============Request Begin=============

echo =============Request end =============
echo Use Web Rest Client GET 'http://'$testBedIP':'$testBed_Port'/oemclient/nms/v1/vms/tel%3A%2B'$MSISDN'/folders/c1a7c823-fdd1-4857-8d44-b315444d2a83%3FattrFilter%3DQuota'
curl -v -X GET --header "Accept: " --header 'Content-Type: application/xml' -A ' ' 'http://'$testBedIP':'$testBed_Port'/oemclient/nms/v1/ums/tel%3A%2B'$MSISDN'/folders/c1a7c823-fdd1-4857-8d44-b315444d2a83?attrFilter=Quota'
echo ======================================================================================
echo ======================================================================================

elif [ $i -eq 227 ]
then
echo =============Request Begin=============

echo =============Request end =============
echo Use Web Rest Client GET 'http://'$testBedIP':'$testBed_Port'/oemclient/nms/v1/vms/tel%3A%2B'$MSISDN'/folders/c1a7c823-fdd1-4857-8d44-b315444d2a83?attrFilter=Quota'
curl -v -X GET --header "Accept: " --header 'Content-Type: application/xml' -A ' ' 'http://'$testBedIP':'$testBed_Port'/oemclient/nms/v1/ums/tel%3A%2B'$MSISDN'/folders/27a29814-dd8f-43ee-b768-19af98bf1d07?attrFilter=Getquota'
echo ======================================================================================
echo ======================================================================================

else
echo "Invalid choice " $i

exit

fi


echo " "
echo "/root/saurav/$logpathsaurav.pcap"
echo "/root/saurav/$logpathsaurav.log"
echo " "
ls -alrt /data/storage/corefiles
echo " "
sleep 1 
kill -INT $logpid
sleep 5 
kill -INT $tcppid
echo " "
echo "   Push Notification to PNS server "
grep -i "payload<" /root/saurav/$logpathsaurav.log
echo " "
echo " NMS Notification to VMAS "
grep -i "Before Sending notification to VMAS" /root/saurav/$logpathsaurav.log
echo " "
