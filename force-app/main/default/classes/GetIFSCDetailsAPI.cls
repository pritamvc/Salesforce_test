global class GetIFSCDetailsAPI {
    global static String statuscode;
    @InvocableMethod(label='GetIFSCDetailsAPI' description='method description')
    global static List<String> getIFSCDetails(APIParams[] params){
        GetIFSCDetailsAPIRequestWrapper requestWrapper = new GetIFSCDetailsAPIRequestWrapper();
        GetIFSCDetailsAPIWrapper ifscDetailsWrapper = new GetIFSCDetailsAPIWrapper();
        try{
            String accessToken = getToken();
            
            if(test.isRunningTest()){
               Test.setMock(HttpCalloutMock.class, new HttpCalloutMockTest('GetIFSCDetailsAPI'));
                }
            String requestbody;
            if(accessToken != null){
                requestWrapper.IFSC = params[0].IFSC;
                requestbody = JSON.serialize(requestWrapper);
                System.debug('Get IFSC Details --> ' + requestbody);
                String resp = getIFSCDetailsCall(requestbody,accessToken);
                System.debug('RESP'+resp);
                
                if(resp != null){
                    ifscDetailsWrapper = (GetIFSCDetailsAPIWrapper)Json.deserialize(resp, GetIFSCDetailsAPIWrapper.class);
                    System.debug('Main Class -->'+ifscDetailsWrapper);
                    System.debug('Inner Class -->'+ifscDetailsWrapper.dataResponse);
                    System.debug('Inner Class Zero Index -->'+ifscDetailsWrapper.dataResponse[0]);
                    GetIFSCDetailsAPIWrapper.cls_dataResponse dataResponseClass = ifscDetailsWrapper.dataResponse[0];
                    
                    if((ifscDetailsWrapper.status == 'Success' || ifscDetailsWrapper.statusCode == 101)){
                        Case caseRecord = [SELECT Id FROM Case WHERE Id = :params[0].caseID];
                        caseRecord.Bank_Name__c = dataResponseClass.BANKNAME;
                        caseRecord.Record_Status__c = dataResponseClass.RECORDSTATUS;
                        caseRecord.Branch_Name__c = dataResponseClass.BRANCHDESC;
                        caseRecord.Auxilo_Partner_Bank__c = dataResponseClass.AUX_PRTNR_BNK;
                        caseRecord.ADDOFBRANCH__c = dataResponseClass.ADDOFBRANCH;
                        caseRecord.MICR_Code__c = dataResponseClass.MICR;
                        caseRecord.Bank_Code__c = dataResponseClass.BANKCODE;
                        caseRecord.CITY__c = dataResponseClass.CITY;
                        caseRecord.Branch_Code__c = dataResponseClass.BRANCHCODE;
                        caseRecord.NPCI_Bank_DC_CODE__c = dataResponseClass.NPCI_BNK_DC_CODE;
                        caseRecord.PC_City_Name__c = dataResponseClass.PCCITYNAME;
                        caseRecord.Auxilo_Bank_Name__c = dataResponseClass.AUX_BNK_NAME;
                        caseRecord.NPCI_Bank_NETB_Code__c = dataResponseClass.NPCI_BNK_NETB_CODE;
                        caseRecord.Auxilo_Bank_Code__c = dataResponseClass.AUX_BNK_CODE;
                        caseRecord.Transaction_Id__c = ifscDetailsWrapper.transactionid;
                        
                        update caseRecord;
                    }
                }
            }
        }catch(Exception e){
            System.debug('Error On Line ' + e.getLineNumber() + ' :: Exception :: '+e.getMessage());
        }
        if(ifscDetailsWrapper.status != 'Success'){
            statuscode = ifscDetailsWrapper.message;
            return new List<String>{statuscode};
                }
        statuscode = 'Success';
        return new List<String>{statuscode};
            }
    
    global static String getToken(){
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setTimeout(20000);
        request.setEndpoint(Label.TokenAPIEndpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(Label.TokenRequestBody);
        HttpResponse response = http.send(request);
        System.debug('getToken Response -->' + response.getbody());
        if(response.getStatusCode() == 200){
            Map<String,String> responseMap = (Map<String,String>) JSON.deserialize(response.getbody(),Map<String,String>.class);
            System.debug('ACCESS TOKEN = ' + responseMap.get('access_token'));
            return responseMap.get('access_token');
            
        }
        return null;
        
    }
    
    global static String getIFSCDetailsCall(String requestbody,String accessToken){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setTimeout(11000);
        request.setEndpoint(Label.BaseUrlAPI + '/los_lms/api/v1/getIFSCdetails');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setBody(requestbody);
        HttpResponse response = http.send(request);
        System.debug('makeGetIFSCDetailsCall Response -->' + response.getbody());
        if(response.getStatusCode() == 200){
            return response.getbody();
        }
        return null; 
    }
    
    global class APIParams {
        @InvocableVariable
        global String IFSC;
        
        @InvocableVariable
        global String caseID;
    }
    
    global class GetIFSCDetailsAPIRequestWrapper {
        String IFSC;
    }
    
}