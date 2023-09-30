/**
* @description:Document verification is a process used to authenticate the authenticity and 
* accuracy of various documents, often in digital transactions or identity verification scenarios.
*It involves cross-referencing provided documents with trusted sources to ensure legitimacy and 
 *prevent fraud. */
public with sharing class DocumentVerification {
    @AuraEnabled 
    public static String PanProfile(String pan,String aadhaarLastFour,String dob,String name,String address,String getContactDetails,String PANStatus,String consent) {
         String token = LOSToken.getAccessToken();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint('callout:LOS_API'+'/karza/panProfile');
        request.setMethod(CommonConstant.REQUEST_METHOD);
        request.setHeader('Authorization', token);
        request.setHeader('Content-Type', 'application/json');
        Map<String,Object> requestMap = new Map<String,Object>();
        requestMap.put('pan',pan);
        requestMap.put('aadhaarLastFour',aadhaarLastFour);
        requestMap.put('dob',dob);
        requestMap.put('name',name);
        requestMap.put('address',address);
        requestMap.put('getContactDetails',getContactDetails);
        requestMap.put('PANStatus',PANStatus);
        requestMap.put('consent',consent);
        request.setBody(JSON.serialize(requestMap));
                                            
        HttpResponse response = http.send(request);
        // try {
        //     if(response.getStatusCode() == 200){
        //         //system.debug('Success: ' + response.getBody());
               
        //     }else{
        //         //system.debug('Error: ' + response.getStatusCode() +' '+ response.getStatus());
               
        //     }
        // } catch (Exception e) {
        //     //system.debug('Error: ' + e.getMessage());
        // }
        return response.getBody();
    }
    
    /*
    @AuraEnabled
    public static String PassportVerification(String consent,String fileNo,String dob,String passportNo, String doi, String name) {
          String token = LOSToken.getAccessToken();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:LOS_API'+'/v3/passport-verification');
        request.setMethod(CommonConstant.REQUEST_METHOD);
        request.setHeader('Authorization', token);
        request.setHeader('Content-Type', 'application/json');
        
        Map<String,Object> requestMap = new Map<String,Object>();
        requestMap.put('consent',consent);
        requestMap.put('fileNo',fileNo);
        requestMap.put('dob',dob);
        requestMap.put('passportNo',passportNo);
        requestMap.put('doi',doi);
        requestMap.put('name',name);
        request.setBody(JSON.serialize(requestMap));
        HttpResponse response = http.send(request);
        try {
            if(response.getStatusCode() == 200){
                //system.debug('Success: ' + response.getBody());
               
            }else{
                //system.debug('Error: ' + response.getStatusCode() +' '+ response.getStatus());
               
            }
        } catch (Exception e) {
            //system.debug('Error: ' + e.getMessage());
        }
        return response.getBody();
    }
   */
    
    @AuraEnabled
    public static String AadharVerification(String aadhaarNo,String consent) {
        //String token = LOSToken.getAccessToken();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setTimeout(60000);
        //request.setEndpoint('callout:LOS_API'+'karza/aadharVerificationOtp');
        request.setEndpoint('https://testapi.karza.in/v3/aadhaar-xml/otp');
        request.setMethod(CommonConstant.REQUEST_METHOD);
       // request.setHeader('Authorization', token);
        request.setHeader('Content-Type', 'application/json');
        
        Map<String,Object> requestMap = new Map<String,Object>();
        requestMap.put('aadhaarNo',aadhaarNo);
        requestMap.put('consent',consent);
        request.setBody(JSON.serialize(requestMap));
        HttpResponse response = http.send(request);
        /*try {
            if(response.getStatusCode() == 200){
                //system.debug('Success: ' + response.getBody());
               
            }else{
                //system.debug('Error: ' + response.getStatusCode() +' '+ response.getStatus());
               
            }
        } catch (Exception e) {
            //system.debug('Error: ' + e.getMessage());
        }*/
        return response.getBody();
        
    }
    @AuraEnabled
    public static String DownloadAadhar(String otp,String aadhaarNo,String requestId,String consent) {
         // String token = LOSToken.getAccessToken();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setTimeout(60000);
        //request.setEndpoint('callout:LOS_API'+'karza/downloadAadharXml');
        request.setEndpoint(' https://testapi.karza.in/v3/aadhaar-xml/file');
        request.setMethod(CommonConstant.REQUEST_METHOD);
      //  request.setHeader('Authorization', token);
        request.setHeader('Content-Type', 'application/json');
        
        Map<String,Object> requestMap = new Map<String,Object>();
        requestMap.put('otp',otp);
        requestMap.put('aadhaarNo',aadhaarNo);
        requestMap.put('requestId',requestId);
        requestMap.put('consent',consent);
        request.setBody(JSON.serialize(requestMap));
        HttpResponse response = http.send(request);
       /* try {
            if(response.getStatusCode() == 200){
                //system.debug('Success: ' + response.getBody());
               
            }else{
                //system.debug('Error: ' + response.getStatusCode() +' '+ response.getStatus());
               
            }
        } catch (Exception e) {
            //system.debug('Error: ' + e.getMessage());
        }*/
        
        return response.getBody();
    }
    
    
    @AuraEnabled
    public static String PannyDrop(Id leadId, Id accId,String consent,String ifsc,String accountNumber,Id dealId) {
        
        //system.debug('calling apex class ba');
        //system.debug('LeadId==> ' +leadId);
        //system.debug('accId==> ' +accId);
        //system.debug('consent==>'+ consent);
        //system.debug('ifsc==>' + ifsc);
        //system.debug('accountNumber==> ' + accountNumber);
        String  PennyDrop = Label.PennyDrop;
        KARZA_API_Detail__mdt apiConfig = [select ApiEndPoint__c from KARZA_API_Detail__mdt where QualifiedApiName =:PennyDrop];
        //system.debug('apiConfig' +apiConfig.ApiEndPoint__c);
        String token = LOSToken.getAccessToken();
        //system.debug('Tocken'+token);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
       	request.setEndpoint('callout:LOS_API'+apiConfig.ApiEndPoint__c);
        request.setMethod(CommonConstant.REQUEST_METHOD);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', token);
        //request.setHeader('x-karza-key', '3CXmVz52L0erntMn'); 
        
        Map<String,Object> requestMap = new Map<String,Object>();
        requestMap.put('consent',consent);
        requestMap.put('ifsc',ifsc);
        requestMap.put('accountNumber',accountNumber);
        request.setBody(JSON.serialize(requestMap));
        HttpResponse response = http.send(request);
        
        
        try {
            string apiEndpoint=apiConfig.ApiEndPoint__c;
            Map<String, Object> parsedResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            String  status= (String)parsedResponse.get('status');
            Map<String, Object> dataResponse = (Map<String, Object>)parsedResponse.get('dataResponse');
            Map<String, Object> result = (Map<String, Object>)dataResponse.get('result');
            Boolean bankTxnStatus = (Boolean)result.get('bankTxnStatus');
            //system.debug('result  '+result+'bankTxnStatus'+bankTxnStatus);
            Integer count=1;
           
            String statusCodestr = (string)dataResponse.get('status-code');
            Integer statusCode = Integer.valueOf(statusCodestr);
            if(response.getStatusCode() == 200){
                //system.debug('Success: ' + response.getBody());
                storeErrorLogs( leadId,accId,dealId,apiEndpoint, request.getBody(),response.getBody(),status,statusCode,bankTxnStatus);
               
            }else{
                //system.debug('Error: ' + response.getStatusCode() +' '+ response.getStatus());
                storeErrorLogs( leadId,accId,dealId,apiEndpoint, request.getBody(),response.getBody(),status,statusCode,bankTxnStatus);
				//sendMailForFailedPennyDropApi(dealId,apiEndpoint,leadId);  
            }
            if (bankTxnStatus!=true) {
                sendMailForFailedPennyDropApi(dealId,apiEndpoint,leadId);
                //system.debug('dealId  '+dealId+'  apiEndpoint  '+apiEndpoint +'  leadId'+leadId);
            }    
            
            
            /*if(statusCode!=101){
                sendMailForFailedPennyDropApi(dealId,apiEndpoint,leadId);
            }*/
        } catch (Exception e) {
            ////system.debug('Error: ' + e.getMessage());
            //system.debug('Outer Exception: ' + e.getMessage() + '. At line no. ' + e.getLineNumber());
        }
       	return response.getBody();
    }
   
    /*
    public static void MaskedAadhar(Blob file) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:LOS_API'+'v3/aadhaar-xml/otp');
        request.setMethod(CommonConstant.REQUEST_METHOD);
        request.setHeader('Content-Type', 'application/json');
       
        Map<String,Object> requestMap = new Map<String,Object>();
        requestMap.put('file',file);
        request.setBody(JSON.serialize(requestMap));
        try {
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 200){
                //system.debug('Success: ' + response.getBody());
               
            }else{
                //system.debug('Error: ' + response.getStatusCode() +' '+ response.getStatus());
               
            }
        } catch (Exception e) {
            //system.debug('Error: ' + e.getMessage());
        }
        
        
    }
     */
    @AuraEnabled(cacheable=true)
     public static Decimal getLeadFormWeightage(Id leadId) {
    Lead lead = [SELECT Lead_form_Weightage__c FROM Lead WHERE Id = :leadId];
    return lead.Lead_form_Weightage__c;
    }
  /*  
    @AuraEnabled
     public static void UpdateLeadFormWeightage(Id recordId,Decimal ProgressValue) {
     Lead Updatelead = new lead(Id=recordId);
     if (Updatelead != null) {
        Updatelead.Lead_form_Weightage__c += ProgressValue;
        update Updatelead;
     } else {
        // Handle the case when the lead record is not found
        //system.debug('Lead record not found with Id: ' + recordId);
    }
}
    */
      @AuraEnabled
    public static List<String> getLeadFileNames(Id leadId) {
      /*  Set<Id> dclId = new Set<Id>();

       List<Document_Checklist__c> listId = [Select id,  Lead__c from Document_Checklist__c where Lead__c =:leadId];//Added by dhanashri to test
        //system.debug('dclId' +dclId);

        for(Document_Checklist__c obj : listId){
            dclId.add(obj.Id);
        }*/
        List<String> fileNames = new List<String>();
        
        // Retrieve the list of ContentDocumentLink records associated with the Lead
        List<ContentDocumentLink> documentLinks = [SELECT ContentDocument.Title
                                                    FROM ContentDocumentLink
                                                    WHERE LinkedEntityId =: leadId];

        // Extract the file names from the ContentDocumentLink records
        for (ContentDocumentLink link : documentLinks) {
            fileNames.add(link.ContentDocument.Title);
        }
        //system.debug('fileNames' +fileNames);
        return fileNames;
    }
     @AuraEnabled
    public static List<String> getAccountFileNames(Id accountId) {
        List<String> fileNames = new List<String>();
        
        // Retrieve the list of ContentDocumentLink records associated with the Account
        List<ContentDocumentLink> documentLinks = [SELECT ContentDocument.Title
                                                    FROM ContentDocumentLink
                                                    WHERE LinkedEntityId = :accountId];
        
        // Extract the file names from the ContentDocumentLink records
        for (ContentDocumentLink link : documentLinks) {
            fileNames.add(link.ContentDocument.Title);
        }
        return fileNames;
    }
    @AuraEnabled
     public static Decimal getLeadTotalPercentage(Id leadId) {
        Lead myLead = [SELECT Lead_form_Weightage__c FROM Lead WHERE Id = :leadId];
        if (myLead != null) {
            return myLead.Lead_form_Weightage__c;
        }
        return null;
    }
   @AuraEnabled
    public static Decimal updateLeadTotalPercentage(Id leadId, Decimal percentage ,Boolean checked) {
    Decimal perc = 0;
    Lead myLead = [SELECT Lead_form_Weightage__c FROM Lead WHERE Id = :leadId];
    if (myLead != null) {
        myLead.Lead_form_Weightage__c = myLead.Lead_form_Weightage__c + percentage;
        perc = myLead.Lead_form_Weightage__c;
        update myLead;
    } 
    return perc ;
}
//error logs
public static void storeErrorLogs(Id leadId, Id accId,Id dealId , String apiEndpoint, String request, String responseBody, String status, Integer statusCode,Boolean BankTxnStatus) {
        // Create new error log record for requested response
        String updatedStatus;
        if(BankTxnStatus==true){
            updatedStatus=status;
        }
        else{
            updatedStatus='Fail';
        }
        Error_log__c errorLogObj = new Error_log__c();
        errorLogObj.Lead__c = leadId;
        errorLogObj.Account__c = accId;
    	errorLogObj.Deal__c = dealId;
        errorLogObj.ApiName__c = apiEndpoint;
        errorLogObj.Request__c = request;
        errorLogObj.Response__c = responseBody;
        errorLogObj.Status__c = updatedStatus;
        errorLogObj.StatusCode__c = statusCode;
        
        try {
            insert errorLogObj;
            
        } catch (DmlException e) {
            
        }
    }
    public static void sendMailForFailedPennyDropApi(Id oppId, String apiName,Id leadId) {
        try{ 
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            string failStatus='Fail';
            Error_log__c errorLog = [SELECT Id from Error_log__c WHERE ApiName__c =: apiName AND Deal__c =: oppId AND 	Status__c=:failStatus ORDER BY CreatedDate DESC LIMIT 1];
            EmailTemplate et =[Select Id,Subject,HtmlValue, DeveloperName From EmailTemplate where DeveloperName =: Label.Penny_Drop_Api_Failed_Email];
            //system.debug('Email template '+et);
            List<OrgWideEmailAddress> orgEmailAddress=[select Id from OrgWideEmailAddress WHERE DisplayName =: system.Label.Organization_Wide_Email_Addresses];
            
            if(orgEmailAddress.size() > 0){
                mail.setOrgWideEmailAddressId(orgEmailAddress[0].Id);
                //system.debug('mail'+mail);
            }
           String errorURL = '';
            if(errorLog != null){
                errorURL = system.URL.getSalesforceBaseURL().toExternalForm() + '/'+ errorLog.Id;
            }
            
            List<String> toAddresses = new List<String>();
            List<String> ccAddresses = new List<String>();
            String pennyDropEmailAddress = label.LOS_Failed_Email_Address;
            ccAddresses = pennyDropEmailAddress.split(',');
            toAddresses.add(UserInfo.getUserEmail()); 
            String emailBody = ((String)et.HtmlValue).replace(LOSConstants.ERROR_LOG_LINKS,errorURL);
            String newSubject = et.Subject;
            mail.setSubject(newSubject);
            mail.setHtmlBody(emailBody);
            mail.setToAddresses(toAddresses);
            mail.setccAddresses(ccAddresses);
            mail.setTreatBodiesAsTemplate(True); 
            mail.setTargetObjectId(leadId);
            mail.setWhatId(oppId);
            mail.setTreatTargetObjectAsRecipient(false);
            mail.setSaveAsActivity(false);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } 
        catch(Exception e) {
            //system.debug(LOSConstants.EMAIL_EXCEPTION + e.getMessage() + LOSConstants.QUERY_EXCEPTION_LINE + e.getLineNumber());
        }     
    }
    
  
}