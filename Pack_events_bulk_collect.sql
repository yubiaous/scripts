create or replace 
package body pack_sp_events
is

/**************************************************************************************************************************
create_cash_transaction_event WILL POPULATE CASH_TRANSACTION  TABLE 
***************************************************************************************************************************/
 
 PROCEDURE  create_cash_transaction_event(
            CA_TAB_CASH_TRXN     IN    TY_TAB_CASH_TRXN,      
            RA_RETURN_CODE       OUT NUMBER,
            ra_return_message    OUT varchar2) 
      is
vl_error_log_id      sp_error_log.error_log_id%type;
VL_LOG_STATUS_MESSAGE 		      SP_ERROR_LOG.OVERALL_STATUS_MESSAGE%TYPE;
vl_error_rec_count              number := 0;

BEGIN                                                   
 VG_PROGRAM_NAME := 'PACK_SP_EVENTS.CREATE_CASH_TRANSACTION_EVENT';
--Call Utility API to log program call
pack_sp_error_utility.pc_start_logging(  ca_program_name => vg_program_name,
                                        ca_log_start_date => systimestamp,
                                        RA_ERROR_LOG_ID => VL_ERROR_LOG_ID );
DBMS_OUTPUT.PUT_LINE(VG_PROGRAM_NAME);                            
vg_step_no   := 'PDSC01';
vg_step_desc := 'VALIDATE INPUT COLLECTION';
 

IF CA_TAB_CASH_TRXN.COUNT = 0 THEN
VL_LOG_STATUS_MESSAGE := 'Input COLLECTION IS EMPTY.';
RAISE transaction_exception;
ELSE
vg_step_no   := 'PCD002';
VG_STEP_DESC := 'INSERTING RECORDS INTO cash_transaction ';
BEGIN
FORALL rec in ca_tab_cash_trxn.FIRST..ca_tab_cash_trxn.LAST  
 
INSERT  INTO cash_transaction(
                  RETAIL_ACCOUNT_NUMBER ,
                  ORDER_NO,
                  ORDER_ITEM_NO,
                  OBJECT_REF_CODE,
                  OBJECT_REF_SID,
                  CATALOGUE_CODE,
                  ITEM_DESCRIPTION   ,
                  AMOUNT   ,
                  QTY ,
                  CREDIT_TYPE_CODE  ,
                  CARD_SCHEME_CODE,
                  DD_OR_DC,
                  MIV_CODE,
                  MIV_SUB_CODE  ,
                  VALUE_OFFER,
                  BROKEN_VALUE_DEAL_IND  
         )
         VALUES
         (
                ca_tab_cash_trxn(rec).RETAIL_ACCOUNT_NUMBER       ,                             
                ca_tab_cash_trxn(rec).ORDER_NO                    ,
                ca_tab_cash_trxn(rec).ORDER_ITEM_NO          	,
                ca_tab_cash_trxn(rec).OBJECT_REF_CODE           ,
                ca_tab_cash_trxn(rec).OBJECT_REF_SID             ,
                ca_tab_cash_trxn(rec).CATALOGUE_CODE             ,
                ca_tab_cash_trxn(rec).ITEM_DESCRIPTION           ,
                ca_tab_cash_trxn(rec).AMOUNT                     ,
                ca_tab_cash_trxn(rec).QTY                      	,
                ca_tab_cash_trxn(rec).CREDIT_TYPE_CODE           ,
                ca_tab_cash_trxn(rec).CARD_SCHEME_CODE           , 
                ca_tab_cash_trxn(rec).DD_OR_DC         	        ,
                ca_tab_cash_trxn(rec).MIV_CODE             	    ,
                ca_tab_cash_trxn(rec).MIV_SUB_CODE               ,
                ca_tab_cash_trxn(rec).VALUE_OFFER             	,
                ca_tab_cash_trxn(rec).BROKEN_VALUE_DEAL_IND          
                
                  );
  EXCEPTION
  When OTHERS THEN
  ROLLBACK;
  END;
  VL_LOG_STATUS_MESSAGE := 'All the records inserted successfully into cash _transaction table ';
 COMMIT; 
 END IF;
 
--Assign output variables to indicate successful update

						ra_return_code := 1;
						ra_return_message := vl_log_status_message;		
						
--Call Utility API to log program call end
pack_sp_error_utility.pc_end_logging ( ca_error_log_id => vl_error_log_id,
                                      ca_overall_execution_status => vg_exec_success, ca_overall_status_message =>
                                      vl_log_status_message, ca_log_end_date => systimestamp,
                                      ca_last_exec_step_status => vg_detail_success_status, ca_step_exec_error_descr
                                      => null, ca_last_exec_step_number => vg_step_no, ca_step_description =>
                                      vg_step_desc, ca_error_code => null);
exception
when transaction_exception then
--Assign output variables to indicate error
ra_return_code := 0;
ra_return_message := VL_LOG_STATUS_MESSAGE;
rollback;
		--Call Utility API to log program call end
pack_sp_error_utility.pc_end_logging (  ca_error_log_id => vl_error_log_id,
ca_overall_execution_status => vg_exec_fail, ca_overall_status_message =>
vg_prog_error_status_message, ca_log_end_date =>systimestamp,
ca_last_exec_step_status => vg_detail_error_status, ca_step_exec_error_descr
=> vl_log_status_message, ca_last_exec_step_number => vg_step_no,
ca_step_description => vg_step_desc, ca_error_code => null);  
when others then		
--Assign output variables to indicate error
ra_return_code := 0;
ra_return_message := vl_log_status_message;
rollback;
		--Call Utility API to log program call end
pack_sp_error_utility.pc_end_logging (  ca_error_log_id => vl_error_log_id,
ca_overall_execution_status => vg_exec_fail, ca_overall_status_message =>
vg_error_status_message, ca_log_end_date =>systimestamp,
ca_last_exec_step_status => vg_detail_error_status, ca_step_exec_error_descr
=> vl_log_status_message, ca_last_exec_step_number => vg_step_no,
ca_step_description => vg_step_desc, ca_error_code => null);  
                                      
 
                                     
 end create_cash_transaction_event;
 
END  pack_sp_events;