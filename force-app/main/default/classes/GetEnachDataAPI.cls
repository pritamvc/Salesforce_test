@RestResource(urlMapping = '/GetEnachDataAPI/*')
global with sharing class GetEnachDataAPI {
    @HttpPost
    global static void getEnachData(){
        Restresponse res = RestContext.response;
        try{
            String requestBody = RestContext.request.requestBody.toString();
            System.debug('Request Body - '+ requestBody);
            
            Map<String,String> requestWrap = (Map<String,String>)JSON.deserialize(requestBody, Map<String,String>.Class);
            system.debug('Wrapper Deserialized'+ requestWrap); 
            
            
            if(!requestWrap.isEmpty() && requestWrap.containsKey('APPLICATION_NO')){
                Case caseRec = [SELECT Id,AccountId,Name_of_Account_Holder__c,Mandate_Type__c,Loan_Application_No__c,Transaction_Id__c,Auxilo_Bank_Code__c,
                                Amount__c,Sponsor_Bank_Code__c,Utility_Code__c,Until_Cancelled__c,IC_From_Date__c,IC_To_Date__c ,Account.PersonEmail,Account.Phone,
                                LAN__r.Loan_Application_Number__c,IFSC__c,MICR_Code__c,Bank_Name__c,Branch_Name__c,Bank_A_C_No__c,NPCI_Bank_DC_CODE__c,NPCI_Bank_NETB_Code__c,
                                Frequency__c,Debit_Type__c,Mandate_Status__c,Max_Limit__c,NPCI_Debit_Card_Code__c,NPCI_Net_Banking_Code__c,Months_to_be_extended__c FROM Case WHERE LAN__r.Loan_Application_Number__c = :requestWrap.get('APPLICATION_NO') AND (Account.PersonEmail = :requestWrap.get('EMAIL_ID') OR Account.Phone = :requestWrap.get('MOBILE_NO')) LIMIT 1
                                  ];
                System.debug('Case Record -->'+caseRec);
                if(caseRec != null){
                    GetEnachDataWrapper.cls_dataResponse dataResponse = new GetEnachDataWrapper.cls_dataResponse();
                    System.debug('Case :'+caseRec);
              //      dataResponse.CUST_ID =caseRec.Id;
                    dataResponse.IFSC = caseRec.IFSC__c;
                /*    dataResponse.BNK_AC_ID = '';
                    dataResponse.NACH_STATUS ='';
                    dataResponse.INSTALL_PERCENT = '100';*/
                    dataResponse.TRAN_ID = caseRec.Transaction_Id__c;
              //      dataResponse.NACH_STATUS_DATE = '';
                    dataResponse.AUX_BNK_CODE = caseRec.Auxilo_Bank_Code__c; 
                    dataResponse.MOBILE_NO1 = caseRec.Account.Phone;
            /*        dataResponse.COLL_END_AT = '';
                    dataResponse.STRT_MTH = ''; */
                    dataResponse.ACC_NUM = caseRec.Bank_A_C_No__c;
                    dataResponse.MICR = caseRec.MICR_Code__c;
            /*        dataResponse.END_MTH = '';
                    dataresponse.REC_CRT_DT = ''; */
                    dataResponse.COLL_FRQ = String.ValueOf(caseRec.Months_to_be_extended__c);
                    dataResponse.COLL_MAX_AMT = String.ValueOf(caseRec.Max_Limit__c);
                    dataResponse.ACCOUNT_HOLDER_NAME = caseRec.Name_of_Account_Holder__c;
                    dataResponse.WI_NAME = caseRec.Id;
                    dataResponse.NPCI_BNK_DC_CODE = caseRec.NPCI_Bank_DC_CODE__c;
              //      dataResponse.ACC_TYPE = '';  
                    dataResponse.APPLICATION_NO = caseRec.LAN__r.Loan_Application_Number__c ;
                    dataResponse.BRANCH_NAME = caseRec.Branch_Name__c;
                    dataResponse.EMAIL_ID1 = caseRec.Account.PersonEmail;
                    dataResponse.NPCI_BNK_NETB_CODE = caseRec.NPCI_Bank_NETB_Code__c;  
                    dataResponse.BANK_NAME = caseRec.Bank_Name__c;
            //        dataResponse.COLL_TYPE = '';
                    
                    if(dataResponse != null){
                        res.statusCode = 200;
                        res.responseBody = Blob.valueOf(JSON.serialize(dataResponse));
                    }
                }else{
                    res.statusCode = 500;
                    res.responseBody = Blob.valueOf(JSON.serialize('{"errorMessage": "Case does not exist","status": "failure"}'));
                }
                
            }
            
        } catch(Exception e){
            //Returning Error if any exception has occured
            system.debug('Exception Line Number'+e.getLineNumber());
            system.debug('Exception Message'+e.getMessage());
            RestResponse restResponse = RestContext.response;
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(e.getMessage()));
            
        } 
        
    }
}