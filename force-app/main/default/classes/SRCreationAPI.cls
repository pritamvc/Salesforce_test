@RestResource(urlMapping = '/SRCreationAPI/*')
global with sharing class SRCreationAPI {
    @HttpPost
    global static void creationOfSR(){
        Restresponse res = RestContext.response;
        String caseId = '';
        
        try{
            String requestBody = RestContext.request.requestBody.toString();
            System.debug('Request Body - '+ requestBody);
            
            SrCreationAPIWrapper srCreationAPIWrapper = (SrCreationAPIWrapper)JSON.deserialize(requestBody, SrCreationAPIWrapper.Class);
            system.debug('Wrapper Deserialized'+ srCreationAPIWrapper);
            
            if(srCreationAPIWrapper.LANNumber != null && srCreationAPIWrapper.Customer_Type == 'Existing'){
                List <Opportunity> listOfOpportunity = [SELECT Id,AccountId,LAN__c,(SELECT Id,Account__c,Account__r.Phone, Account__r.Email__c FROM Applicants__r WHERE
                                                                                    (Account__r.Phone = :srCreationAPIWrapper.SuppliedPhone OR Account__r.Email__c = :srCreationAPIWrapper.SuppliedEmail)
                                                                                    LIMIT 1)
                                                        FROM Opportunity WHERE Loan_Application_Number__c =:srCreationAPIWrapper.LANNumber];
                System.debug('Opportunity : ' + listOfOpportunity);
                if(!listOfOpportunity.isEmpty()){
                    Case newCase = new Case();
                    List<Sobject> listofApplicant = listOfOpportunity[0].Applicants__r;
                    if(!listofApplicant.isEmpty()) {
                        newCase.AccountId = listOfOpportunity[0].Applicants__r[0].Account__c;
                        newCase.LAN__c = listOfOpportunity[0].Id;
                        newCase.Subject = srCreationAPIWrapper.Subject;
                        newCase.SuppliedPhone = srCreationAPIWrapper.SuppliedPhone;
                        newCase.SuppliedEmail = srCreationAPIWrapper.SuppliedEmail;
                        newCase.Origin = srCreationAPIWrapper.Origin;
                        newCase.Description = srCreationAPIWrapper.Description;
                        newCase.Request_Type__c = srCreationAPIWrapper.Request_Type;
                        newCase.Service_Request_Type__c = srCreationAPIWrapper.Service_Request_Type;
                        newCase.SR_Sub_Type__c = srCreationAPIWrapper.SR_Sub_Type;
                        newCase.Customer_Type__c = 'Existing';
                        
                        insert newCase;
                        Case caseToSend = [SELECT CaseNumber FROM Case WHERE Id =:newCase.Id];
                        System.debug('Case To be Inserted'+newCase);
                        caseId = '{"CaseId"'+': "'+newCase.Id+'","CaseNumber"'+':"'+caseToSend.CaseNumber+'"}';
                        if(caseToSend != null){
                            res.statusCode = 200;
                            res.responseBody = Blob.valueOf(caseId);    
                        } 
                        
                        
                    }
                    else{
                        res.statusCode = 500;
                        res.responseBody = Blob.valueOf('{"errorMessage": "Mobile or email not registered against LAN","status": "failure"}');
                    }
                }
                else{
                    res.statusCode = 500;
                    res.responseBody = Blob.valueOf('{"errorMessage": "LAN does not exist","status": "failure"}');                            
                } 
                
            }else if(srCreationAPIWrapper.Customer_Type =='New'){
        //        Account nonCustomerAccount = [SELECT Id FROM Account WHERE Name ='Non Customer Account'];
                String nonCustomerAccountId = System.Label.Non_Customer_Account;
                System.debug('Non Customer Account'+nonCustomerAccountId);
                If(nonCustomerAccountId != null){
                    Case newCase = new Case();
                    newCase.AccountId = nonCustomerAccountId;
                    newCase.Subject = srCreationAPIWrapper.Subject;
                    newCase.SuppliedPhone = srCreationAPIWrapper.SuppliedPhone;
                    newCase.SuppliedEmail = srCreationAPIWrapper.SuppliedEmail;
                    newCase.Origin = srCreationAPIWrapper.Origin;
                    newCase.Description = srCreationAPIWrapper.Description;
                    newCase.Request_Type__c = srCreationAPIWrapper.Request_Type;
                    newCase.Service_Request_Type__c = srCreationAPIWrapper.Service_Request_Type;
                    newCase.SR_Sub_Type__c = srCreationAPIWrapper.SR_Sub_Type;
                    newCase.Customer_Type__c = 'New';
                    
                    insert newCase;
                    Case caseToSend = [SELECT CaseNumber FROM Case WHERE Id =:newCase.Id];
                    System.debug('Case To be Inserted'+newCase);
                    caseId = '{"CaseId"'+': "'+newCase.Id+'","CaseNumber"'+':"'+caseToSend.CaseNumber+'"}';
                    if(caseToSend != null){
                        res.statusCode = 200;
                        res.responseBody = Blob.valueOf(caseId);    
                    }     
                }
                
            }
        } catch (Exception e){
            //Returning Error if any exception has occured
            system.debug('Exception Line Number'+e.getLineNumber());
            system.debug('Exception Message'+e.getMessage());
            RestResponse restResponse = RestContext.response;
            res.statusCode = 500;
            if(e.getMessage().contains('out of bounds')){
                res.responseBody = Blob.valueOf('{"errorMessage": "LAN does not exist","status": "failure"}');
            }else{
                res.responseBody = Blob.valueOf(e.getMessage());
            }
        }
    } 
    
    public class SrCreationAPIWrapper {
        
        public String SuppliedPhone;
        public String SuppliedEmail;
        public String LANNumber;
        public String Origin;
        public String Subject;
        public String Description;
        public String Request_Type;
        public String Service_Request_Type;
        public String SR_Sub_Type;
        public String Customer_Type;
    }
    
}