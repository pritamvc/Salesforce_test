/*********************************************************************************************
* @author          Thinqloud Solutions (Chandrakant More)
* @description     This class is used from BulkUploadLeadsForPartners.js (LWC) class to for mapping field and creation of lead record
* @date            06/02/2023    
* @testClass: 
**********************************************************************************************/
public class BulkUploadLeadsForPartners { 
    /********************************************************************************************************
* @author          Chandrakant More
* @description     getImportLineHeaderFieldMappings this method used to map the csv header field name with lead object field API name
* @return          No-return    
* @date            06/02/2023   
* @param          No Params
********************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Map<String, Import_Lead_Header_Field_Mapping__mdt> getImportLineHeaderFieldMappings(){
        List<Import_Lead_Header_Field_Mapping__mdt> importLineHeaderFieldMappings = Import_Lead_Header_Field_Mapping__mdt.getAll().values();
        Map<String, Import_Lead_Header_Field_Mapping__mdt> headerFieldMappings = new Map<String, Import_Lead_Header_Field_Mapping__mdt>();
        for(Import_Lead_Header_Field_Mapping__mdt mapping : importLineHeaderFieldMappings) {
            headerFieldMappings.put(mapping.Label, mapping);
        }
        return headerFieldMappings;
    }
    
    /********************************************************************************************************
* @author          Chandrakant More
* @description     createBulkLeads this method is used to det the Lead list, selected partner and csv header
* @param           jsonString (String) : List of lead to be inserted From csv file.
* @param           accountId (String) : string of Partner account Id. 
*                  headerFromCSV (String) : string of csv header.
*                  csvFileTittle (String): to get file name from js.
* @return String : string of error message to display on UI.
* @date            06/02/2023   
********************************************************************************************************/
    @AuraEnabled
    public static String createBulkLeads(String jsonString, string accountId,string headerFromCSV,string csvFileTittle) {
        string  messagestring ='';
        try{
            List<Lead> leadList = (List<Lead>) JSON.deserialize(jsonString, List<Lead>.class);            
            Map<string,List<Lead>> mapcheckDuplicateEmailLeadInCSV = new Map<string,List<Lead>>();
            Map<string,List<Lead>> mapcheckDuplicateMobileLeadInCSV = new Map<string,List<Lead>>();
            Map<String, SObject> mapUsernameAndOwnerId = new Map<String, SObject>();
            List<Lead> leadListToInsert = new List<Lead>();
            List<Lead> leadListDuplicateOrErrorFound = new List<Lead>();
            List<Lead> successLeadList = new List<Lead>();
            List<Lead> nonDuplicateLeadsInsideCSV = new List<Lead>();
            List<Lead> existingLeadList = new List<Lead>();
            List<Source__c> sourceLst = new List<Source__c>();
            Set<string> useNameSet = new Set<string>();
            Set<String> existingLeadListMobilePhoneSet = new Set<String> ();
            Set<String> existingLeadListEmailSet = new Set<String> ();
            Set<Id> receivedSetOfId =  new Set<Id>();
            String sourceName;
            
            /****************** Checking csv Contains Duplcate record or Not ***************/
            for(Lead objlead : leadList){
                /***************************** blank check*********************************************/
                if(objlead.Email == null){
                    objlead.ErrorMessage__c = CommonConstant.BLANK_EMAIL;
                    leadListDuplicateOrErrorFound.add(objlead);
                    /*****************************************************************************************/
                }else if(objlead.MobilePhone == null){
                    objlead.ErrorMessage__c = CommonConstant.BLANK_MOBILE_NUMBER;
                    leadListDuplicateOrErrorFound.add(objlead);
                    /*****************************************************************************************/
                }else if(mapcheckDuplicateEmailLeadInCSV.containsKey(objlead.Email.toLowercase())) {
                    if(mapcheckDuplicateEmailLeadInCSV.get(objlead.Email.toLowercase()).size() == 0){
                        nonDuplicateLeadsInsideCSV.add(objlead);
                    }else{
                        objlead.ErrorMessage__c = CommonConstant.DUPLICATE_EMAIL_IN_CSV;
                        leadListDuplicateOrErrorFound.add(objlead);
                    }
                    List<Lead> lstobjlead = mapcheckDuplicateEmailLeadInCSV.get(objlead.Email.toLowercase());
                    objlead.Email = objlead.Email.toLowercase();
                    lstobjlead.add(objlead);
                    mapcheckDuplicateEmailLeadInCSV.put(objlead.Email.toLowercase(), lstobjlead);
                } else if(mapcheckDuplicateMobileLeadInCSV.containsKey(objlead.MobilePhone)) {
                    if(mapcheckDuplicateMobileLeadInCSV.get(objlead.MobilePhone).size() == 0){
                        nonDuplicateLeadsInsideCSV.add(objlead);
                    }else{
                        objlead.ErrorMessage__c = CommonConstant.DUPLICATE_MOBILE_NUMBER_IN_CSV;
                        leadListDuplicateOrErrorFound.add(objlead);
                    }
                    List<Lead> lstobjlead = mapcheckDuplicateMobileLeadInCSV.get(objlead.MobilePhone);
                    lstobjlead.add(objlead);
                    mapcheckDuplicateMobileLeadInCSV.put(objlead.MobilePhone, lstobjlead);
                }else {
                    objlead.Email = objlead.Email.toLowercase();
                    mapcheckDuplicateEmailLeadInCSV.put(objlead.Email, new List<Lead> {objlead});
                    mapcheckDuplicateMobileLeadInCSV.put(objlead.MobilePhone, new List<Lead> {objlead});
                    nonDuplicateLeadsInsideCSV.add(objlead);
                } 
            }
            for(Lead leadRecordObject : nonDuplicateLeadsInsideCSV){
                useNameSet.add(leadRecordObject.csvUserName__c);
            }
            
            mapUsernameAndOwnerId = Utility.assignOwnerAndServiceBranchBasedOnUserName(useNameSet);
            
            sourceLst = [SELECT Id,Partner_Name__c,Source_Category__c,Partner_Name__r.Partner_Code__c 
                         FROM Source__c WHERE Partner_Name__c = :accountId];
            for(Source__c s : sourceLst){
                sourceName = s.Id;
            }
            receivedSetOfId = DuplicateManagement.leadDuplicate(leadList, sourceName);
            existingLeadList = [Select Id ,Email, MobilePhone, CreatedDate From Lead where Id IN : receivedSetOfId];
            For(Lead existingLeadListObject : existingLeadList ){
                existingLeadListMobilePhoneSet.add(existingLeadListObject.MobilePhone);
                existingLeadListEmailSet.add(existingLeadListObject.Email);
            }
            
            for(Lead objectLeadRecord : nonDuplicateLeadsInsideCSV ){
                string mobilePhoneStr = string.valueof(objectLeadRecord.MobilePhone);
                string emailString = string.valueof(objectLeadRecord.Email);
                boolean kyc =boolean.valueof(objectLeadRecord.KYC_Consent__c);
                objectLeadRecord.KYC_Consent__c = kyc;
                if((objectLeadRecord.MobilePhone != null && objectLeadRecord.Email != null) && (existingLeadListMobilePhoneSet.contains(objectLeadRecord.MobilePhone) || existingLeadListEmailSet.contains(objectLeadRecord.Email))){
                    objectLeadRecord.ErrorMessage__c = CommonConstant.DUPLICATE_RECOED;
                    leadListDuplicateOrErrorFound.add(objectLeadRecord);
                }else if((mobilePhoneStr != null && !Pattern.matches('^[0-9]{10}+$', mobilePhoneStr)) && (emailString != null && Pattern.matches('^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$', emailString))){
                    objectLeadRecord.ErrorMessage__c = CommonConstant.INVALID_MOBILE_NUMBER;
                    leadListDuplicateOrErrorFound.add(objectLeadRecord);
                }else if((emailString != null && !Pattern.matches('^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$', emailString)) && (mobilePhoneStr != null && Pattern.matches('^[0-9]{10}+$', mobilePhoneStr))){
                    objectLeadRecord.ErrorMessage__c = CommonConstant.INVALID_EMAIL;
                    leadListDuplicateOrErrorFound.add(objectLeadRecord);
                }else if((mobilePhoneStr != null && !Pattern.matches('^[0-9]{10}+$', mobilePhoneStr)) && (emailString != null && !Pattern.matches('^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$', emailString))){
                    objectLeadRecord.ErrorMessage__c = CommonConstant.INVALID_MOBILE_NUMBER_AND_EMAIL;
                    leadListDuplicateOrErrorFound.add(objectLeadRecord);
                }else if(objectLeadRecord.LastName == null){
                    objectLeadRecord.ErrorMessage__c = CommonConstant.BLANK_LAST_NAME;
                    leadListDuplicateOrErrorFound.add(objectLeadRecord);
                }
                else if(objectLeadRecord.csvUserName__c != null && !mapUsernameAndOwnerId.containsKey(objectLeadRecord.csvUserName__c)){
                    objectLeadRecord.ErrorMessage__c = CommonConstant.INVALID_USER_NAME;
                    leadListDuplicateOrErrorFound.add(objectLeadRecord);
                }else{
                    objectLeadRecord.Bulk_Upload__c = true;
                    leadListToInsert.add(objectLeadRecord);
                }
            }
            
            if(!leadListToInsert.isempty() && leadListToInsert.size() > 0){  
                
                Group callCenterQueue = [SELECT Id, DeveloperName,Name from Group WHERE Type = 'Queue' AND Name =: System.Label.Call_Center_Queue ];
                Group salesProcessingQueue = [SELECT Id, DeveloperName,Name from Group WHERE Type = 'Queue' AND Name =: System.Label.Sales_Processing_Exception_Queue_Queue];
                Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(System.Label.Lead_B2C_Record_Type).getRecordTypeId();
                
                For(Lead objectLeadToInsert : leadListToInsert ){
                    objectLeadToInsert.LeadSource = System.Label.Lead_Source_for_Account_Partner;
                    objectLeadToInsert.Lead_Origin__c = 'Lead Import';
                    If(recordTypeId != null){
                        objectLeadToInsert.RecordTypeId = recordTypeId;
                    }
                    if(!sourceLst.IsEmpty() && sourceLst.size()>0){
                        objectLeadToInsert.Source_Category__c = sourceLst[0].Source_Category__c;
                        objectLeadToInsert.Source_Name__c =  sourceLst[0].Id; 
                    }
                    if(objectLeadToInsert.Status == System.Label.Lead_status_Sales_Processing && mapUsernameAndOwnerId.containsKey(objectLeadToInsert.csvUserName__c)){
                        objectLeadToInsert.OwnerId = mapUsernameAndOwnerId.get(objectLeadToInsert.csvUserName__c).Id;
                        Schema.DescribeSObjectResult describeResult = mapUsernameAndOwnerId.get(objectLeadToInsert.csvUserName__c).Id.getSObjectType().getDescribe();
                        string objectName = describeResult.getName();
                        if(objectName == System.Label.Object_Name_User){
                            objectLeadToInsert.OwnerId = ((User)mapUsernameAndOwnerId.get(objectLeadToInsert.csvUserName__c)).Id;
                            if(((User)mapUsernameAndOwnerId.get(objectLeadToInsert.csvUserName__c)).Service_Branch__c != null){
                                objectLeadToInsert.Service_Branch__c = ((User)mapUsernameAndOwnerId.get(objectLeadToInsert.csvUserName__c)).Service_Branch__c;
                            }
                        } else if(objectName == System.Label.Object_Name_Group){
                            objectLeadToInsert.OwnerId = ((Group)mapUsernameAndOwnerId.get(objectLeadToInsert.csvUserName__c)).Id;
                        }
                    }else if(objectLeadToInsert.Status == System.Label.Lead_status_Sales_Processing && !mapUsernameAndOwnerId.containsKey(objectLeadToInsert.csvUserName__c)){
                        objectLeadToInsert.OwnerId = salesProcessingQueue.id;
                    }else{
                        objectLeadToInsert.OwnerId = callCenterQueue.Id;
                    }
                }
                if(!leadListToInsert.IsEmpty() && leadListToInsert.size() > 100){
                    Database.executeBatch(new BulkUploadLeadBatch(leadListToInsert,leadListDuplicateOrErrorFound,accountId,csvFileTittle,headerFromCSV),200);
                }else if(!leadListToInsert.IsEmpty() && leadListToInsert.size() <= 100){
                    try {
                        List<Database.SaveResult> insertResults = Database.insert(leadListToInsert, false);
                        for (Integer j = 0; j < insertResults.size(); j++) {
                            if(insertResults.get(j).isSuccess()){
                                successLeadList.add(leadListToInsert[j]);
                            }
                            if (!insertResults.get(j).isSuccess()) {
                                lead failRecord = leadListToInsert[j];
                                failRecord.ErrorMessage__c = insertResults.get(j).getErrors()[0].getMessage();
                                leadListDuplicateOrErrorFound.add(failRecord);
                            }
                        }
                    } catch (Exception e) {
                         For(Lead ObjectLeadToInsert : leadListToInsert ){
                            ObjectLeadToInsert.addError(CommonConstant.ERROR_CONSTANT + e.getMessage());
                        }
                    }
                } 
            }
            if(!leadListDuplicateOrErrorFound.isempty() && leadListDuplicateOrErrorFound.size() > 0){   
                setOfErrorLeads(leadListDuplicateOrErrorFound,accountId,csvFileTittle,headerFromCSV);
            }            
            if(!leadListToInsert.IsEmpty() && leadListToInsert.size() > 200){
                messagestring = CommonConstant.BATCH_CALLED_FROM_BULK_UPLOADS_LEADS_MESSAGE;
            }else{
                messagestring = CommonConstant.errorMessage(leadList.size(),leadListDuplicateOrErrorFound.size(),successLeadList.size());
            }
        }catch(Exception e){
            System.debug(CommonConstant.ERROR_CONSTANT + e.getMessage());
        }
        return messagestring;  
    }
    
    /********************************************************************************************************
* @author          Chandrakant More.
* @description     SendEmailToLoggedInUser this method is used to send the duplicate lead or error lead if contaise in CSV file.
* @param           contentDocumentId (Id) : get the document Id which will get shared with logged in User.
* @return          No-return.
* @date            06/02/2023   
********************************************************************************************************/
    Public static void sendEmailToLoggedInUser(ID contentDocumentId,string csvFileTittle) {
        list<string> toAddresses = new list<string>();
        ContentVersion contentVersionRecord = [select id,VersionData,ContentDocument.Title from ContentVersion
                                               where ID =: contentDocumentId];        
        EmailTemplate invTemplate = [SELECT Id, Name, Subject, Body FROM EmailTemplate WHERE Name =: System.Label.Bulk_Lead_Upload_Email_Template_Error_File_Text];
        List<OrgWideEmailAddress> orgEmailAddress=[select Id from OrgWideEmailAddress WHERE DisplayName =: System.Label.Organization_Wide_Email_Addresses];
        List<Messaging.SingleEmailMessage > email_list = new List<Messaging.SingleEmailMessage >();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        string subject = invTemplate.subject;
        string emailBody = invTemplate.Body;
        if(orgEmailAddress.size() > 0){
            message.setOrgWideEmailAddressId(orgEmailAddress[0].Id); 
        }
        toAddresses.add(UserInfo.getUserEmail());
        if(UserInfo.getUserName() != null) {
            emailBody = emailBody.replace('{!Account.CurrentLoggedinUserName__c}',UserInfo.getFirstName() +' '+ UserInfo.getLastName());
        }
        list<Messaging.EmailFileAttachment> efaList = new list<Messaging.EmailFileAttachment>();    
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(csvFileTittle+CommonConstant.ERROR_FILE_FORMATE_AND_NAME);
        efa.setBody(contentVersionRecord.VersionData);
        efaList.add(efa);
        message.setSubject(subject);
        message.setTreatBodiesAsTemplate(True); 
        message.setToAddresses(toAddresses);
        message.setTargetObjectId(UserInfo.getUserId());
        message.setSaveAsActivity(false);
        message.setFileAttachments(efaList);
        message.setPlainTextBody(emailBody);
        email_list.add(message);
        try {
            if(email_list.size() > 0){
                Messaging.SendEmailResult[] results =Messaging.sendEmail(email_list);
                if(results.size() > 0){
                    if(results.get(0).isSuccess()){
                    }
                }  
            }
        }catch(Exception e) {
            system.debug(CommonConstant.ERROR_CONSTANT + e.getMessage());
        }
    }
    
     /********************************************************************************************************
* @author          Chandrakant More.
* @description     SendEmailToLoggedInUser this method is used to send the duplicate lead or error lead if contaise in CSV file.
* @param           lstErrorLeads (Id) : get list of Lead to procced the lead  for error file.
* @param           accountId (string) : getaccountId.
* @param           csvFileTittle (string) : To get File Name.
* @param           headerFromCSV (string) : To get header for csv file.
********************************************************************************************************/
    Public static void setOfErrorLeads(List<Lead> lstErrorLeads,string accountId,string csvFileTittle,string headerFromCSV){
        Utility.createCSVfile(lstErrorLeads,accountId,csvFileTittle,headerFromCSV);
    }
    
}