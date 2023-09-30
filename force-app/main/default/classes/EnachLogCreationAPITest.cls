@isTest
public class EnachLogCreationAPITest {
    @isTest  static void createEnachLog(){
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = account.Id;
        opportunity.name = 'Test Opportunity';
        opportunity.CloseDate = system.today();
        opportunity.StageName = 'Needs Analysis';
        opportunity.Loan_Application_Number__c = '2906202201';
        insert opportunity;
        
        Co_Applicant__c coapplicant = new Co_Applicant__c();
        coapplicant.Name = 'Test';
        coapplicant.Account__c = account.Id;
        coapplicant.Deal__c = opportunity.Id;
        insert coapplicant;
        
        Case newCase = new Case();
        newCase.Subject = 'Test Case';
        newCase.AccountId = account.Id;
        newCase.LAN__c = opportunity.Id;
        newCase.Request_Type__c = 'Service Request';
        newCase.Service_Request_Type__c = 'Change Contact Coordinates';
        newCase.SR_Sub_Type__c = 'Change Registered Mobile Number';
        newCase.New_Mobile_Number__c = '1234567890';
        insert newCase;
        
        
        
        
        String body ='{"CASE_ID":"'+newCase.Id+'","APPLICATION_NO":"2906202201","BNK_AC_ID":18011,"REQ_SRNO":1234,"TRAN_ID":"Trans-186","TXN_STATUS":"Success","TXN_MSG":"NA","TXN_ERR_MSG":"NA","CLNT_TXN_REF":"Completed","TPSL_BANK_CD":"Completed","TPSL_TXN_ID":"Completed","TXN_AMT":"2500000","CLNT_RQST_META":"TEST","TPSL_TXN_TIME":"20","BAL_AMT":"20000","CARD_ID":"12132424","ALIAS_NAME":"Test","BANKTRANSACTIONID":"12321323","MANDATE_REG_NO":"123123123","TOKEN":"0809809809","HASH":"test","UMNR":"1231243123","NPCI_REF_ID":"23423424","REASON":"test","REJECTED_BY":"test","REC_CRT_DT":"16-MAY-22","API_RESPONSE":"msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119","API_REQUEST":"msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119"}';         
        Blob bodyBlod = Blob.valueOf(body);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/EnachLogCreationAPI/*'; //Request URL
        request.httpMethod = 'POST';
        request.requestBody = bodyBlod;
        
        RestContext.request = request;
        RestContext.response = response;
        List<AggregateResult> enachLogAggregateResult = [SELECT count(id) FROM Enach_Log__c];
        EnachLogCreationAPI.creationOfEnachLog();
        System.assertEquals(1,enachLogAggregateResult.size());
        
        body ='{"CASE_ID":""'+newCase.Id+'","APPLICATION_NO":"2906202201","BNK_AC_ID":18011,"REQ_SRNO":1234,"TRAN_ID":"Trans-186","TXN_STATUS":"Success","TXN_MSG":"NA","TXN_ERR_MSG":"NA","CLNT_TXN_REF":"Completed","TPSL_BANK_CD":"Completed","TPSL_TXN_ID":"Completed","TXN_AMT":"2500000","CLNT_RQST_META":"TEST","TPSL_TXN_TIME":"20","BAL_AMT":"20000","CARD_ID":"12132424","ALIAS_NAME":"Test","BANKTRANSACTIONID":"12321323","MANDATE_REG_NO":"123123123","TOKEN":"0809809809","HASH":"test","UMNR":"1231243123","NPCI_REF_ID":"23423424","REASON":"test","REJECTED_BY":"test","REC_CRT_DT":"16-JUN-22","API_RESPONSE":"msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119","API_REQUEST":"msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119"}';
        bodyBlod = Blob.valueOf(body);
        RestRequest request1 = new RestRequest();
        RestResponse response1 = new RestResponse();
        request1.requestURI = '/services/apexrest/EnachLogCreationAPI/*'; //Request URL
        request1.httpMethod = 'POST';
        request1.requestBody = bodyBlod;
        EnachLogCreationAPI.creationOfEnachLog();
        
        body ='{"CASE_ID":""'+newCase.Id+'","APPLICATION_NO":"2906202201","BNK_AC_ID":18011,"REQ_SRNO":1234,"TRAN_ID":"Trans-186","TXN_STATUS":"Success","TXN_MSG":"NA","TXN_ERR_MSG":"NA","CLNT_TXN_REF":"Completed","TPSL_BANK_CD":"Completed","TPSL_TXN_ID":"Completed","TXN_AMT":"2500000","CLNT_RQST_META":"TEST","TPSL_TXN_TIME":"20","BAL_AMT":"20000","CARD_ID":"12132424","ALIAS_NAME":"Test","BANKTRANSACTIONID":"12321323","MANDATE_REG_NO":"123123123","TOKEN":"0809809809","HASH":"test","UMNR":"1231243123","NPCI_REF_ID":"23423424","REASON":"test","REJECTED_BY":"test","REC_CRT_DT":"16-MAY-22","API_RESPONSE":"msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119","API_REQUEST":"msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119"}';
        bodyBlod = Blob.valueOf(body);
        request.requestBody = bodyBlod;
        EnachLogCreationAPI.creationOfEnachLog();
        
        body ='{"CASE_ID":""'+newCase.Id+'","APPLICATION_NO":"2906202201","BNK_AC_ID":18011,"REQ_SRNO":1234,"TRAN_ID":"Trans-186","TXN_STATUS":"Success","TXN_MSG":"NA","TXN_ERR_MSG":"NA","CLNT_TXN_REF":"Completed","TPSL_BANK_CD":"Completed","TPSL_TXN_ID":"Completed","TXN_AMT":"2500000","CLNT_RQST_META":"TEST","TPSL_TXN_TIME":"20","BAL_AMT":"20000","CARD_ID":"12132424","ALIAS_NAME":"Test","BANKTRANSACTIONID":"12321323","MANDATE_REG_NO":"123123123","TOKEN":"0809809809","HASH":"test","UMNR":"1231243123","NPCI_REF_ID":"23423424","REASON":"test","REJECTED_BY":"test","REC_CRT_DT":"16-MAR-22","API_RESPONSE":"msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119","API_REQUEST":"msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119"}';
        bodyBlod = Blob.valueOf(body);
        request.requestBody = bodyBlod;
        EnachLogCreationAPI.creationOfEnachLog();
        
        body ='{"CASE_ID":""'+newCase.Id+'","APPLICATION_NO":"2906202201","BNK_AC_ID":18011,"REQ_SRNO":1234,"TRAN_ID":"Trans-186","TXN_STATUS":"Success","TXN_MSG":"NA","TXN_ERR_MSG":"NA","CLNT_TXN_REF":"Completed","TPSL_BANK_CD":"Completed","TPSL_TXN_ID":"Completed","TXN_AMT":"2500000","CLNT_RQST_META":"TEST","TPSL_TXN_TIME":"20","BAL_AMT":"20000","CARD_ID":"12132424","ALIAS_NAME":"Test","BANKTRANSACTIONID":"12321323","MANDATE_REG_NO":"123123123","TOKEN":"0809809809","HASH":"test","UMNR":"1231243123","NPCI_REF_ID":"23423424","REASON":"test","REJECTED_BY":"test","REC_CRT_DT":"16-FEB-22","API_RESPONSE":"msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119","API_REQUEST":"msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119"}';
        bodyBlod = Blob.valueOf(body);
        request.requestBody = bodyBlod;
        EnachLogCreationAPI.creationOfEnachLog();
        
        body ='{"CASE_ID":""'+newCase.Id+'","APPLICATION_NO":"2906202201","BNK_AC_ID":18011,"REQ_SRNO":1234,"TRAN_ID":"Trans-186","TXN_STATUS":"Success","TXN_MSG":"NA","TXN_ERR_MSG":"NA","CLNT_TXN_REF":"Completed","TPSL_BANK_CD":"Completed","TPSL_TXN_ID":"Completed","TXN_AMT":"2500000","CLNT_RQST_META":"TEST","TPSL_TXN_TIME":"20","BAL_AMT":"20000","CARD_ID":"12132424","ALIAS_NAME":"Test","BANKTRANSACTIONID":"12321323","MANDATE_REG_NO":"123123123","TOKEN":"0809809809","HASH":"test","UMNR":"1231243123","NPCI_REF_ID":"23423424","REASON":"test","REJECTED_BY":"test","REC_CRT_DT":"16-JAN-22","API_RESPONSE":"msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119","API_REQUEST":"msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119"}';
        bodyBlod = Blob.valueOf(body);
        request.requestBody = bodyBlod;
        EnachLogCreationAPI.creationOfEnachLog();
        
        body ='{"CASE_ID":""'+newCase.Id+'","APPLICATION_NO":"2906202201","BNK_AC_ID":18011,"REQ_SRNO":1234,"TRAN_ID":"Trans-186","TXN_STATUS":"Success","TXN_MSG":"NA","TXN_ERR_MSG":"NA","CLNT_TXN_REF":"Completed","TPSL_BANK_CD":"Completed","TPSL_TXN_ID":"Completed","TXN_AMT":"2500000","CLNT_RQST_META":"TEST","TPSL_TXN_TIME":"20","BAL_AMT":"20000","CARD_ID":"12132424","ALIAS_NAME":"Test","BANKTRANSACTIONID":"12321323","MANDATE_REG_NO":"123123123","TOKEN":"0809809809","HASH":"test","UMNR":"1231243123","NPCI_REF_ID":"23423424","REASON":"test","REJECTED_BY":"test","REC_CRT_DT":"16-JUL-22","API_RESPONSE":"msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119","API_REQUEST":"msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119"}';
        bodyBlod = Blob.valueOf(body);
        request.requestBody = bodyBlod;
        EnachLogCreationAPI.creationOfEnachLog();
        
        body ='{"CASE_ID":""'+newCase.Id+'","APPLICATION_NO":"2906202201","BNK_AC_ID":18011,"REQ_SRNO":1234,"TRAN_ID":"Trans-186","TXN_STATUS":"Success","TXN_MSG":"NA","TXN_ERR_MSG":"NA","CLNT_TXN_REF":"Completed","TPSL_BANK_CD":"Completed","TPSL_TXN_ID":"Completed","TXN_AMT":"2500000","CLNT_RQST_META":"TEST","TPSL_TXN_TIME":"20","BAL_AMT":"20000","CARD_ID":"12132424","ALIAS_NAME":"Test","BANKTRANSACTIONID":"12321323","MANDATE_REG_NO":"123123123","TOKEN":"0809809809","HASH":"test","UMNR":"1231243123","NPCI_REF_ID":"23423424","REASON":"test","REJECTED_BY":"test","REC_CRT_DT":"16-AUG-22","API_RESPONSE":"msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119","API_REQUEST":"msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119"}';
        bodyBlod = Blob.valueOf(body);
        request.requestBody = bodyBlod;
        EnachLogCreationAPI.creationOfEnachLog();
        
        body ='{"CASE_ID":""'+newCase.Id+'","APPLICATION_NO":"2906202201","BNK_AC_ID":18011,"REQ_SRNO":1234,"TRAN_ID":"Trans-186","TXN_STATUS":"Success","TXN_MSG":"NA","TXN_ERR_MSG":"NA","CLNT_TXN_REF":"Completed","TPSL_BANK_CD":"Completed","TPSL_TXN_ID":"Completed","TXN_AMT":"2500000","CLNT_RQST_META":"TEST","TPSL_TXN_TIME":"20","BAL_AMT":"20000","CARD_ID":"12132424","ALIAS_NAME":"Test","BANKTRANSACTIONID":"12321323","MANDATE_REG_NO":"123123123","TOKEN":"0809809809","HASH":"test","UMNR":"1231243123","NPCI_REF_ID":"23423424","REASON":"test","REJECTED_BY":"test","REC_CRT_DT":"16-SEP-22","API_RESPONSE":"msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119","API_REQUEST":"msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119"}';
        bodyBlod = Blob.valueOf(body);
        request.requestBody = bodyBlod;
        EnachLogCreationAPI.creationOfEnachLog();
        
        body ='{"CASE_ID":""'+newCase.Id+'","APPLICATION_NO":"2906202201","BNK_AC_ID":18011,"REQ_SRNO":1234,"TRAN_ID":"Trans-186","TXN_STATUS":"Success","TXN_MSG":"NA","TXN_ERR_MSG":"NA","CLNT_TXN_REF":"Completed","TPSL_BANK_CD":"Completed","TPSL_TXN_ID":"Completed","TXN_AMT":"2500000","CLNT_RQST_META":"TEST","TPSL_TXN_TIME":"20","BAL_AMT":"20000","CARD_ID":"12132424","ALIAS_NAME":"Test","BANKTRANSACTIONID":"12321323","MANDATE_REG_NO":"123123123","TOKEN":"0809809809","HASH":"test","UMNR":"1231243123","NPCI_REF_ID":"23423424","REASON":"test","REJECTED_BY":"test","REC_CRT_DT":"16-OCT-22","API_RESPONSE":"msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119","API_REQUEST":"msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119"}';
        bodyBlod = Blob.valueOf(body);
        request.requestBody = bodyBlod;
        EnachLogCreationAPI.creationOfEnachLog();
        
        body ='{"CASE_ID":""'+newCase.Id+'","APPLICATION_NO":"2906202201","BNK_AC_ID":18011,"REQ_SRNO":1234,"TRAN_ID":"Trans-186","TXN_STATUS":"Success","TXN_MSG":"NA","TXN_ERR_MSG":"NA","CLNT_TXN_REF":"Completed","TPSL_BANK_CD":"Completed","TPSL_TXN_ID":"Completed","TXN_AMT":"2500000","CLNT_RQST_META":"TEST","TPSL_TXN_TIME":"20","BAL_AMT":"20000","CARD_ID":"12132424","ALIAS_NAME":"Test","BANKTRANSACTIONID":"12321323","MANDATE_REG_NO":"123123123","TOKEN":"0809809809","HASH":"test","UMNR":"1231243123","NPCI_REF_ID":"23423424","REASON":"test","REJECTED_BY":"test","REC_CRT_DT":"16-NOV-22","API_RESPONSE":"msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119","API_REQUEST":"msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119"}';
        bodyBlod = Blob.valueOf(body);
        request.requestBody = bodyBlod;
        EnachLogCreationAPI.creationOfEnachLog();
        
        body ='{"CASE_ID":""'+newCase.Id+'","APPLICATION_NO":"2906202201","BNK_AC_ID":18011,"REQ_SRNO":1234,"TRAN_ID":"Trans-186","TXN_STATUS":"Success","TXN_MSG":"NA","TXN_ERR_MSG":"NA","CLNT_TXN_REF":"Completed","TPSL_BANK_CD":"Completed","TPSL_TXN_ID":"Completed","TXN_AMT":"2500000","CLNT_RQST_META":"TEST","TPSL_TXN_TIME":"20","BAL_AMT":"20000","CARD_ID":"12132424","ALIAS_NAME":"Test","BANKTRANSACTIONID":"12321323","MANDATE_REG_NO":"123123123","TOKEN":"0809809809","HASH":"test","UMNR":"1231243123","NPCI_REF_ID":"23423424","REASON":"test","REJECTED_BY":"test","REC_CRT_DT":"16-DEC-22","API_RESPONSE":"msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119","API_REQUEST":"msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119"}';
        bodyBlod = Blob.valueOf(body);
        request.requestBody = bodyBlod;
        EnachLogCreationAPI.creationOfEnachLog();
        
        
    }
    
    @isTest  static void createEnachLog1(){
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = account.Id;
        opportunity.name = 'Test Opportunity';
        opportunity.CloseDate = system.today();
        opportunity.StageName = 'Needs Analysis';
        opportunity.Loan_Application_Number__c = '2906202201';
        insert opportunity;
        
        Co_Applicant__c coapplicant = new Co_Applicant__c();
        coapplicant.Name = 'Test';
        coapplicant.Account__c = account.Id;
        coapplicant.Deal__c = opportunity.Id;
        insert coapplicant;
        
        Case newCase = new Case();
        newCase.Subject = 'Test Case';
        newCase.AccountId = account.Id;
        newCase.LAN__c = opportunity.Id;
        newCase.Request_Type__c = 'Service Request';
        newCase.Service_Request_Type__c = 'Change Contact Coordinates';
        newCase.SR_Sub_Type__c = 'Change Registered Mobile Number';
        newCase.New_Mobile_Number__c = '1234567890';
        insert newCase;
        
        String body ='{"CASE_ID":"'+newCase.Id+'","APPLICATION_NO":"2906202201","BNK_AC_ID":18011,"REQ_SRNO":1234,"TRAN_ID":"Trans-186","TXN_STATUS":"Success","TXN_MSG":"NA","TXN_ERR_MSG":"NA","CLNT_TXN_REF":"Completed","TPSL_BANK_CD":"Completed","TPSL_TXN_ID":"Completed","TXN_AMT":"2500000","CLNT_RQST_META":"TEST","TPSL_TXN_TIME":"20","BAL_AMT":"20000","CARD_ID":"12132424","ALIAS_NAME":"Test","BANKTRANSACTIONID":"12321323","MANDATE_REG_NO":"123123123","TOKEN":"0809809809","HASH":"test","UMNR":"1231243123","NPCI_REF_ID":"23423424","REASON":"test","REJECTED_BY":"test","REC_CRT_DT":"16-APR-22","API_RESPONSE":"msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119","API_REQUEST":"msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119"}';         
        Blob bodyBlod = Blob.valueOf(body);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/EnachLogCreationAPI/*'; //Request URL
        request.httpMethod = 'POST';
        request.requestBody = bodyBlod;
        
        RestContext.request = request;
        RestContext.response = response;
        List<AggregateResult> enachLogAggregateResult = [SELECT count(id) FROM Enach_Log__c];
        EnachLogCreationAPI.creationOfEnachLog();
        System.assertEquals(1,enachLogAggregateResult.size());
        
       
        
        
    }
    @isTest  static void createEnachLog2(){
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = account.Id;
        opportunity.name = 'Test Opportunity';
        opportunity.CloseDate = system.today();
        opportunity.StageName = 'Needs Analysis';
        opportunity.Loan_Application_Number__c = '2906202201';
        insert opportunity;
        
        Co_Applicant__c coapplicant = new Co_Applicant__c();
        coapplicant.Name = 'Test';
        coapplicant.Account__c = account.Id;
        coapplicant.Deal__c = opportunity.Id;
        insert coapplicant;
        
        Case newCase = new Case();
        newCase.Subject = 'Test Case';
        newCase.AccountId = account.Id;
        newCase.LAN__c = opportunity.Id;
        newCase.Request_Type__c = 'Service Request';
        newCase.Service_Request_Type__c = 'Change Contact Coordinates';
        newCase.SR_Sub_Type__c = 'Change Registered Mobile Number';
        newCase.New_Mobile_Number__c = '1234567890';
        insert newCase;
        
        String body ='{"CASE_ID":"'+newCase.Id+'","APPLICATION_NO":"2906202201","BNK_AC_ID":18011,"REQ_SRNO":1234,"TRAN_ID":"Trans-186","TXN_STATUS":"Success","TXN_MSG":"NA","TXN_ERR_MSG":"NA","CLNT_TXN_REF":"Completed","TPSL_BANK_CD":"Completed","TPSL_TXN_ID":"Completed","TXN_AMT":"2500000","CLNT_RQST_META":"TEST","TPSL_TXN_TIME":"20","BAL_AMT":"20000","CARD_ID":"12132424","ALIAS_NAME":"Test","BANKTRANSACTIONID":"12321323","MANDATE_REG_NO":"123123123","TOKEN":"0809809809","HASH":"test","UMNR":"1231243123","NPCI_REF_ID":"23423424","REASON":"test","REJECTED_BY":"test","REC_CRT_DT":"16-JUN-22","API_RESPONSE":"msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119","API_REQUEST":"msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119"}';         
        Blob bodyBlod = Blob.valueOf(body);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/EnachLogCreationAPI/*'; //Request URL
        request.httpMethod = 'POST';
        request.requestBody = bodyBlod;
        
        RestContext.request = request;
        RestContext.response = response;
        List<AggregateResult> enachLogAggregateResult = [SELECT count(id) FROM Enach_Log__c];
        EnachLogCreationAPI.creationOfEnachLog();
        System.assertEquals(1,enachLogAggregateResult.size());
        
       
        
        
    }
    @isTest  static void createEnachLog3(){
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = account.Id;
        opportunity.name = 'Test Opportunity';
        opportunity.CloseDate = system.today();
        opportunity.StageName = 'Needs Analysis';
        opportunity.Loan_Application_Number__c = '2906202201';
        insert opportunity;
        
        Co_Applicant__c coapplicant = new Co_Applicant__c();
        coapplicant.Name = 'Test';
        coapplicant.Account__c = account.Id;
        coapplicant.Deal__c = opportunity.Id;
        insert coapplicant;
        
        Case newCase = new Case();
        newCase.Subject = 'Test Case';
        newCase.AccountId = account.Id;
        newCase.LAN__c = opportunity.Id;
        newCase.Request_Type__c = 'Service Request';
        newCase.Service_Request_Type__c = 'Change Contact Coordinates';
        newCase.SR_Sub_Type__c = 'Change Registered Mobile Number';
        newCase.New_Mobile_Number__c = '1234567890';
        insert newCase;
        
        String body ='{"CASE_ID":"'+newCase.Id+'","APPLICATION_NO":"2906202201","BNK_AC_ID":18011,"REQ_SRNO":1234,"TRAN_ID":"Trans-186","TXN_STATUS":"Success","TXN_MSG":"NA","TXN_ERR_MSG":"NA","CLNT_TXN_REF":"Completed","TPSL_BANK_CD":"Completed","TPSL_TXN_ID":"Completed","TXN_AMT":"2500000","CLNT_RQST_META":"TEST","TPSL_TXN_TIME":"20","BAL_AMT":"20000","CARD_ID":"12132424","ALIAS_NAME":"Test","BANKTRANSACTIONID":"12321323","MANDATE_REG_NO":"123123123","TOKEN":"0809809809","HASH":"test","UMNR":"1231243123","NPCI_REF_ID":"23423424","REASON":"test","REJECTED_BY":"test","REC_CRT_DT":"16-JUL-22","API_RESPONSE":"msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119","API_REQUEST":"msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119"}';         
        Blob bodyBlod = Blob.valueOf(body);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/EnachLogCreationAPI/*'; //Request URL
        request.httpMethod = 'POST';
        request.requestBody = bodyBlod;
        
        RestContext.request = request;
        RestContext.response = response;
        List<AggregateResult> enachLogAggregateResult = [SELECT count(id) FROM Enach_Log__c];
        EnachLogCreationAPI.creationOfEnachLog();
        System.assertEquals(1,enachLogAggregateResult.size());
        
       
        
        
    }
    @isTest  static void createEnachLog4(){
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = account.Id;
        opportunity.name = 'Test Opportunity';
        opportunity.CloseDate = system.today();
        opportunity.StageName = 'Needs Analysis';
        opportunity.Loan_Application_Number__c = '2906202201';
        insert opportunity;
        
        Co_Applicant__c coapplicant = new Co_Applicant__c();
        coapplicant.Name = 'Test';
        coapplicant.Account__c = account.Id;
        coapplicant.Deal__c = opportunity.Id;
        insert coapplicant;
        
        Case newCase = new Case();
        newCase.Subject = 'Test Case';
        newCase.AccountId = account.Id;
        newCase.LAN__c = opportunity.Id;
        newCase.Request_Type__c = 'Service Request';
        newCase.Service_Request_Type__c = 'Change Contact Coordinates';
        newCase.SR_Sub_Type__c = 'Change Registered Mobile Number';
        newCase.New_Mobile_Number__c = '1234567890';
        insert newCase;
        
        String body ='{"CASE_ID":"'+newCase.Id+'","APPLICATION_NO":"2906202201","BNK_AC_ID":18011,"REQ_SRNO":1234,"TRAN_ID":"Trans-186","TXN_STATUS":"Success","TXN_MSG":"NA","TXN_ERR_MSG":"NA","CLNT_TXN_REF":"Completed","TPSL_BANK_CD":"Completed","TPSL_TXN_ID":"Completed","TXN_AMT":"2500000","CLNT_RQST_META":"TEST","TPSL_TXN_TIME":"20","BAL_AMT":"20000","CARD_ID":"12132424","ALIAS_NAME":"Test","BANKTRANSACTIONID":"12321323","MANDATE_REG_NO":"123123123","TOKEN":"0809809809","HASH":"test","UMNR":"1231243123","NPCI_REF_ID":"23423424","REASON":"test","REJECTED_BY":"test","REC_CRT_DT":"16-AUG-22","API_RESPONSE":"msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119","API_REQUEST":"msg=0300|success|NA|TRNID134|9530|1811863437|10.00|{itc:~mandateData{UMRNNumber:KKBK7010306220009279~IFSCCode:KKBK0RTGSMI~amount_type:M~frequency:ADHO~account_number:6246841667~expiry_date:01-08-2028~ifsc_code:~amount:10~identifier:~schedule_date:01-06-2022~debitDay:~debitFlag:N~aadharNo:~accountHolderName:JITENDRA+GOVINDBHAI+PATEL~accountType:Saving~dateOfBirth:~mandatePurpose:~utilityNo:~helpdeskNo:~helpdeskEmail:~pan:ACIPP5229L~phoneNumber:9619869763~emailID:jitendra.patel@auxilo.com}}{email:jitendra.patel@auxilo.com}{mob:9619869763}|03-06-2022+15:02:50|NA|||9420885b15ac49e19b677cb82a731295|955623844|caa42918-a90b-4dc5-a055-3d28f411977a|34acd27931f2671342ebf15466707c35388d80f845707a4c5863ebc1451642dd5e2608d5e019043ed70af59f762eb62e06f90dda9256664573cc5af31b55a119"}';         
        Blob bodyBlod = Blob.valueOf(body);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/EnachLogCreationAPI/*'; //Request URL
        request.httpMethod = 'POST';
        request.requestBody = bodyBlod;
        
        RestContext.request = request;
        RestContext.response = response;
        List<AggregateResult> enachLogAggregateResult = [SELECT count(id) FROM Enach_Log__c];
        EnachLogCreationAPI.creationOfEnachLog();
        System.assertEquals(1,enachLogAggregateResult.size());
        
       
        
       
        
        
    }
}