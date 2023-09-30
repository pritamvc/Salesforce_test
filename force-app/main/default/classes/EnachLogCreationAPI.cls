@RestResource(urlMapping = '/EnachLogCreationAPI/*')
global with sharing class EnachLogCreationAPI {
    @HttpPost
    global static void creationOfEnachLog(){
        Restresponse res = RestContext.response;
        String enachLogBody = '';
        
        try{
            String requestBody = RestContext.request.requestBody.toString();
            System.debug('Request Body - '+ requestBody);
            
            EnachLogCreationAPIWrapper enachLogWrapper = (EnachLogCreationAPIWrapper)JSON.deserialize(requestBody, EnachLogCreationAPIWrapper.Class);
            system.debug('Wrapper Deserialized'+ enachLogWrapper);
            
            if(enachLogWrapper.APPLICATION_NO != null){
                List <Opportunity> listOfOpportunity = [SELECT Id,Loan_Application_Number__c
                                                        FROM Opportunity WHERE Loan_Application_Number__c =:enachLogWrapper.APPLICATION_NO];
                System.debug('Opportunity : ' + listOfOpportunity);
                List<Case> listOfCase = [SELECT Id FROM Case WHERE Id =:enachLogWrapper.CASE_ID];
                if(!listOfOpportunity.isEmpty() && !listOfCase.isEmpty()){
                    Enach_Log__c enachLogs = new Enach_Log__c();
                    enachLogs.Case_Id__c = enachLogWrapper.CASE_ID;
                    enachLogs.APPLICATION_NO__c = listOfOpportunity[0].Loan_Application_Number__c;
                    enachLogs.BNK_AC_ID__c = String.valueOf(enachLogWrapper.BNK_AC_ID);
                    enachLogs.REQ_SRNO__c = String.valueOf(enachLogWrapper.REQ_SRNO);
                    enachLogs.TRAN_ID__c = enachLogWrapper.TRAN_ID;
                    enachLogs.TXN_STATUS__c = enachLogWrapper.TXN_STATUS;
                    enachLogs.TXN_MSG__c = enachLogWrapper.TXN_MSG;
                    enachLogs.TXN_ERR_MSG__c = enachLogWrapper.TXN_ERR_MSG;
                    enachLogs.CLNT_TXN_REF__c = enachLogWrapper.CLNT_TXN_REF;
                    enachLogs.TPSL_BANK_CD__c = enachLogWrapper.TPSL_BANK_CD;
                    enachLogs.TPSL_TXN_ID__c = enachLogWrapper.TPSL_TXN_ID;
                    enachLogs.TXN_AMT__c = enachLogWrapper.TXN_AMT;
                    enachLogs.CLNT_RQST_META__c = enachLogWrapper.CLNT_RQST_META;
                    enachLogs.TPSL_TXN_TIME__c = enachLogWrapper.TPSL_TXN_TIME;
                    enachLogs.BAL_AMT__c = enachLogWrapper.BAL_AMT;
                    enachLogs.CARD_ID__c = enachLogWrapper.CARD_ID;
                    enachLogs.ALIAS_NAME__c = enachLogWrapper.ALIAS_NAME;
                    enachLogs.BANKTRANSACTIONID__c = enachLogWrapper.BANKTRANSACTIONID;
                    enachLogs.MANDATE_REG_NO__c = enachLogWrapper.MANDATE_REG_NO;
                    enachLogs.TOKEN__c = enachLogWrapper.TOKEN;
                    enachLogs.HASH__c = enachLogWrapper.HASH;
                    enachLogs.UMNR__c = enachLogWrapper.UMNR;
                    enachLogs.NPCI_REF_ID__c = enachLogWrapper.NPCI_REF_ID;
                    enachLogs.REASON__c = enachLogWrapper.REASON;
                    enachLogs.REJECTED_BY__c = enachLogWrapper.REJECTED_BY;
                    if(enachLogWrapper.REC_CRT_DT != null){
                    String [] enachdate = enachLogWrapper.REC_CRT_DT.split('-');
                    System.debug('Date Spilt '+enachdate);    
                    String enachdateMonth = enachdate[1];
                    String finalDate ='20'+ enachdate[2]+'-' ;  
                        switch on enachdateMonth{
                            when 'JAN'{
                                finalDate+= '01';
                            }
                            when 'FEB'{
                                finalDate+= '02';
                            }
                            when 'MAR'{
                                finalDate+= '03';
                            }
                            when 'APR'{
                                finalDate+= '04';
                            }
                            when 'MAY'{
                                finalDate+= '05';
                            }
                            when 'JUN'{
                                finalDate+= '06';
                            }
                            when 'JUL'{
                                finalDate+= '07';
                            }
                            when 'AUG'{
                                finalDate+= '08';
                            }
                            when 'SEP'{
                                finalDate+= '09';
                            }
                            when 'OCT'{
                                finalDate+= '10';
                            }
                            when 'NOV'{
                                finalDate+= '11';
                            }
                            when 'DEC'{
                                finalDate+= '12';
                            }
                        }
                    finalDate += '-'+ enachdate[0];   
                    enachLogs.REC_CRT_DT__c = Date.valueOf(finalDate);
                    }
                    enachLogs.API_RESPONSE__c = enachLogWrapper.API_RESPONSE;
                    enachLogs.API_REQUEST__c = enachLogWrapper.API_REQUEST;
                    enachlogs.Deal__c = listOfOpportunity[0].Id;
                    insert enachLogs;
                    
                    System.debug('Enach Log To be Inserted'+enachLogs);
                    Enach_Log__c enachLog = [SELECT Id,TRAN_ID__c FROM Enach_Log__c WHERE Id =:enachLogs.Id];
                    enachLogBody = '{"dataResponse": "Record was Successfully inserted","message":"Request Completed Successfully","transactionid":"'+enachLog.TRAN_ID__c+'","status":"Success","statusCode":101}';
                    if(enachLog != null){
                        res.statusCode = 200;
                        res.responseBody = Blob.valueOf(enachLogBody);
                        
                    } 
                }else{
                    res.statusCode = 500;
                    res.responseBody = Blob.valueOf('{"errorMessage": "Case does not exist","status": "failure"}');
                }
            }      
        } 
        catch (Exception e){
            //Returning Error if any exception has occured
            system.debug('Exception Line Number'+e.getLineNumber());
            system.debug('Exception Message'+e.getMessage());
            RestResponse restResponse = RestContext.response;
            res.statusCode = 400;
            if(e.getMessage().contains('out of bounds')){
                res.responseBody = Blob.valueOf('{"errorMessage": "LAN does not exist","status": "failure"}');
            }else{
                res.responseBody = Blob.valueOf(e.getMessage());
            }
        }
    }
    
    
    public class EnachLogCreationAPIWrapper{
        public String CASE_ID;	//500Bi000001CBGrIAO
        public String APPLICATION_NO;	//100219000454
        public Integer BNK_AC_ID;	//18011
        public Integer REQ_SRNO;	//1234
        public String TRAN_ID;	//Trans-186
        public String TXN_STATUS;	//Success
        public String TXN_MSG;	//NA
        public String TXN_ERR_MSG;	//NA
        public String CLNT_TXN_REF;	//Completed
        public String TPSL_BANK_CD;	//Completed
        public String TPSL_TXN_ID;	//Completed
        public String TXN_AMT;	//2500000
        public String CLNT_RQST_META;	//TEST
        public String TPSL_TXN_TIME;	//20
        public String BAL_AMT;	//20000
        public String CARD_ID;	//12132424
        public String ALIAS_NAME;	//Test
        public String BANKTRANSACTIONID;	//12321323
        public String MANDATE_REG_NO;	//123123123
        public String TOKEN;	//0809809809
        public String HASH;	//test
        public String UMNR;	//1231243123
        public String NPCI_REF_ID;	//23423424
        public String REASON;	//test
        public String REJECTED_BY;	//test
        public String REC_CRT_DT;	//16-APR-22
        public String API_RESPONSE;	//msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119
        public String API_REQUEST;	//msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119
        
    }
    

}