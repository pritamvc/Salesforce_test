/**
* Name: DmsUtils
* Author: Aasim Shaikh
* Date: 19/04/2023
* Purpose: This class contains common methods used in DMS.
* @description DmsUtils class
* @param None.
*/
public class DmsUtils {
    /**
     * Author: Aasim Shaikh
     * @description This method is used to retrieve Opportunity details based on a Lead ID.
     * 
     * This method takes a Lead ID as input and retrieves the associated Opportunity records.
     * The retrieved Opportunity records are returned as a list.
     * 
     * @param leadId The Lead ID for which to retrieve Opportunity details.
     * @return List<Opportunity> The list of Opportunity records associated with the Lead.
     * @date 19/04/2023
     */
    public static List<Opportunity> getOportunityDetails(String leadId) {
        return [SELECT Id, Account.Id, Lead__c, LOS_Id__c, Folder_Index__c, Loan_Application_Number__c,LOS_Sync__c,TrackWizz_Sync__c FROM Opportunity WHERE Lead__c =: leadId];
    }
    
    /**
     * Author: Aasim Shaikh
     * @description This method is used to retrieve a list of documents associated with a Deal object.
     * 
     * This method takes a Deal object as input and retrieves the associated documents,
     * represented as a map where Document_Checklist__c records are keys and lists of ContentVersion records are values.
     * 
     * @param deal The Deal object for which to retrieve the list of documents.
     * @return Map<Document_Checklist__c, List<ContentVersion>> A map of Document_Checklist__c records and associated ContentVersion lists.
     * @date 19/04/2023
     */
    public static Map<Document_Checklist__c, List<ContentVersion>> getDocumentList(Opportunity deal) {  
        List<ContentVersion> documentsList = new List<ContentVersion>();
        List<ContentDistribution> documentsCDList = new List<ContentDistribution>();
        Map<Document_Checklist__c, List<ContentVersion>> documentMap = new Map<Document_Checklist__c, List<ContentVersion>>();
        
        try {
            //Get the related document checklist data
            List<Document_Checklist__c> documentChecklist = [SELECT Id,DMS_Name__c,Applicant__r.Account__c FROM Document_Checklist__c WHERE Deal__c =: deal.Id];
            
            //Get the Ids of document checklist data and add to map 
            Map<Id,Document_Checklist__c> mapDocChecklist = new Map<Id,Document_Checklist__c>();
            for (Document_Checklist__c documentChecklistRecord : documentChecklist) {
                mapDocChecklist.put(documentChecklistRecord.Id,documentChecklistRecord);
            }
            
            //Get ContentDocumentLink of related document checklist
            List<ContentDocumentLink> documentLinkList = [SELECT Id, ContentDocumentId,LinkedEntityId from ContentDocumentLink where LinkedEntityId IN :mapDocChecklist.keyset()];
            
            //Get the ContentDocumentId from the list
            Set<String> contentDocumentIds = new Set<String>();
            for(ContentDocumentLink addMap : documentLinkList) {
                contentDocumentIds.add(addMap.ContentDocumentId);
            }
            
            //Collects the documents with related ContentDocumentId
            documentsList = [SELECT Id,Description,FileType,Download_URL__c,Title,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds];
            documentsCDList = [SELECT Id,ContentDownloadUrl,ContentVersionId FROM ContentDistribution WHERE ContentDocumentId IN :contentDocumentIds];
            
            //Get ContentDocumentId from the list
            Map<Id,ContentVersion> docMap = new Map<Id,ContentVersion>();
            for(ContentVersion cv : documentsList){
                docMap.put(cv.ContentDocumentId,cv);
            }
            
            //Create map with linkedentityid and its related list of ContentVersion
            Map<Id, List<ContentVersion>> contentVersionMap = new Map<Id, List<ContentVersion>>();
            for (ContentDocumentLink documentLink : documentLinkList) {
                if (docMap.containsKey(documentLink.ContentDocumentId)) {
                    if (contentVersionMap.containsKey(documentLink.LinkedEntityId)) {
                        contentVersionMap.get(documentLink.LinkedEntityId).add(docMap.get(documentLink.ContentDocumentId));
                    }
                    else {
                        List<ContentVersion> versionList = new List<ContentVersion>();
                        versionList.add(docMap.get(documentLink.ContentDocumentId));
                        contentVersionMap.put(documentLink.LinkedEntityId, versionList);
                    }
                }
            }
            
            //Iterate the data to create map                 
            for (ContentDocumentLink documentLink : documentLinkList) {
                List<ContentVersion> relatedContentVersion = new List<ContentVersion>();
                Document_Checklist__c relatedDocumentChecklist = new Document_Checklist__c();
                
                //Get document checklist records
                if (mapDocChecklist.containsKey(documentLink.LinkedEntityId) && mapDocChecklist.get(documentLink.LinkedEntityId) != null) {
                    relatedDocumentChecklist = mapDocChecklist.get(documentLink.LinkedEntityId);
                }
                    
                //Get content version records
                if(contentVersionMap.containsKey(documentLink.LinkedEntityId) && contentVersionMap.get(documentLink.LinkedEntityId) != null){
                    for (Id contentVersion : contentVersionMap.keySet()) {
                        if (contentVersion == documentLink.LinkedEntityId) {
                            relatedContentVersion = contentVersionMap.get(contentVersion);
                        }
                    }
                }
                
                if (relatedContentVersion != null && relatedDocumentChecklist != null){
                    documentMap.put(relatedDocumentChecklist, relatedContentVersion); 
                    
                    //Get the Download URL of document
                    for (ContentVersion cv : relatedContentVersion) {
                        for (ContentDistribution cd : documentsCDList) {
                            if (cd.ContentVersionId == cv.Id) {
                                cv.Download_URL__c = cd.ContentDownloadUrl;
                                break;
                            }
                        }
                    }
                }
            }
        } 
        catch(Exception e) {
            System.debug(LOSConstants.DMS_DOCUMENT_EXCEPTION + e.getMessage() + LOSConstants.QUERY_EXCEPTION_LINE + e.getLineNumber());
        }
        return documentMap;
    }
    
    /**
     * Author: Aasim Shaikh
     * @description This method is used to retrieve a list of documents associated with a Deal object for a failed DMS API call.
     * 
     * This method takes a Deal object as input and retrieves the associated documents,
     * represented as a map where Document_Checklist__c records are keys and lists of ContentVersion records are values.
     * This method is specifically tailored for scenarios where a DMS API call has failed and documents need to be retrieved again.
     * 
     * @param deal The Deal object for which to retrieve the list of documents.
     * @return Map<Document_Checklist__c, List<ContentVersion>> A map of Document_Checklist__c records and associated ContentVersion lists.
     * @date 19/04/2023
     */
    public static Map<Document_Checklist__c, List<ContentVersion>> getDocumentListForFailedDmsApi(Opportunity deal) {  
        List<ContentVersion> documentsList = new List<ContentVersion>();
        List<ContentDistribution> documentsCDList = new List<ContentDistribution>();
        Map<Document_Checklist__c, List<ContentVersion>> documentMap = new Map<Document_Checklist__c, List<ContentVersion>>();
        try {
            List<Tracker__c> trackerLog = [SELECT Id, ApiName__c, Record_Id__c, Record_Type__c, Lead__c, Status__c, StatusCode__c FROM Tracker__c 
                                       WHERE Deal__c =: deal.Id AND Status__c =: LOSConstants.DMS_FAIL AND StatusCode__c =: LOSConstants.DMS_FAILURE_CODE AND Record_Type__c =: LOSConstants.DOCUMENT_ID];
            
            //Iterate only if we get data for failed tracker list
            if(trackerLog != null){
                
                //Collect all document checklist ids
                Set<String> documentChecklistIds = new Set<String>();
                for(Tracker__c addMap : trackerLog) {
                    documentChecklistIds.add(addMap.Record_Id__c);
                }
            
                //Get Document Checklist data and ContentDocumentLink of related deal
                Map<Id,Document_Checklist__c> documentChecklist = new Map<Id,Document_Checklist__c>([SELECT Id,DMS_Name__c,Applicant__r.Account__c FROM Document_Checklist__c WHERE Id IN :documentChecklistIds]);            
                List<ContentDocumentLink> documentLinkList = [SELECT Id, ContentDocumentId,LinkedEntityId from ContentDocumentLink where LinkedEntityId IN :documentChecklistIds];
                
                //Separate the ContentDocumentId from the ContentDocumentLink
                Set<String> contentDocumentIds = new Set<String>();
                for(ContentDocumentLink addMap : documentLinkList) {
                    contentDocumentIds.add(addMap.ContentDocumentId);
                }
            
                //Collects all documents with related ids and add to map
                documentsList = [select Id,Description,FileType,Download_URL__c,Title,ContentDocumentId FROM ContentVersion where ContentDocumentId in :contentDocumentIds];
                documentsCDList = [select Id,ContentDownloadUrl,ContentVersionId from ContentDistribution WHERE ContentDocumentId in :contentDocumentIds];
                
                Map<Id,ContentVersion> docMap = new Map<Id,ContentVersion>();
                for(ContentVersion cv : documentsList){
                    docMap.put(cv.ContentDocumentId,cv);
                }
                
                //Create map with linkedentityid and its related list of ContentVersion
                Map<Id, List<ContentVersion>> contentVersionMap = new Map<Id, List<ContentVersion>>();
                for (ContentDocumentLink documentLink : documentLinkList) {                    
                    if (docMap.containsKey(documentLink.ContentDocumentId)) {
                        if (contentVersionMap.containsKey(documentLink.LinkedEntityId)){ 
                            contentVersionMap.get(documentLink.LinkedEntityId).add(docMap.get(documentLink.ContentDocumentId));
                        }
                        else {
                            List<ContentVersion> versionList = new List<ContentVersion>();
                            versionList.add(docMap.get(documentLink.ContentDocumentId));
                            contentVersionMap.put(documentLink.LinkedEntityId, versionList);
                        }
                    }
                }
                
                //Iterate the data to create map                   
                for (ContentDocumentLink documentLink : documentLinkList) {
                    List<ContentVersion> relatedContentVersion = new List<ContentVersion>();
                    Document_Checklist__c relatedDocumentChecklist = new Document_Checklist__c();
                    
                    //Get document checklist records
                    if (documentChecklist.containsKey(documentLink.LinkedEntityId) && documentChecklist.get(documentLink.LinkedEntityId) != null) {
                        relatedDocumentChecklist = documentChecklist.get(documentLink.LinkedEntityId);
                    }
                    
                    //Get content version records
                    if(contentVersionMap.containsKey(documentLink.LinkedEntityId) && contentVersionMap.get(documentLink.LinkedEntityId) != null){
                        for (Id contentVersion : contentVersionMap.keySet()) {
                            if (contentVersion == documentLink.LinkedEntityId) {
                                relatedContentVersion = contentVersionMap.get(contentVersion);
                            }
                        }
                    }
                    
                    if (relatedContentVersion != null && relatedDocumentChecklist != null){
                        documentMap.put(relatedDocumentChecklist, relatedContentVersion); 
                        
                        //Get the Download URL of document
                        for (ContentVersion cv : relatedContentVersion) {
                            for (ContentDistribution cd : documentsCDList) {
                                if (cd.ContentVersionId == cv.Id) {
                                    cv.Download_URL__c = cd.ContentDownloadUrl;
                                    break;
                                }
                            }
                        }
                    }
                }
                delete trackerLog; 
            }
            else{
                List<Id> leadID = new List<Id>();
                leadID.add(deal.Lead__c);
                DmsManualCalling.callToLOSWhenSync(leadID);
            }
        } 
        catch(Exception e) {
            System.debug(LOSConstants.DMS_DOCUMENT_EXCEPTION + e.getMessage() + LOSConstants.QUERY_EXCEPTION_LINE + e.getLineNumber());
        } 
        return documentMap;
    }
    
    /**
     * Author: Aasim Shaikh
     * @description This method is used to track DMS API requests and responses.
     * 
     * This method takes various parameters related to a DMS API request and response,
     * such as an Opportunity object, API name, request details, response body,
     * and a Document_Checklist__c object. It tracks these details for auditing and monitoring purposes.
     * 
     * @param opp The Opportunity object associated with the DMS API interaction.
     * @param apiName The name of the API being called.
     * @param request The request details sent to the DMS API.
     * @param responseBody The response received from the DMS API.
     * @param docChecklist The Document_Checklist__c object associated with the DMS interaction.
     * @date 19/04/2023
     */
    public static void trackDmsApiRequest(Opportunity opp, String apiName, String request, String responseBody,Document_Checklist__c docChecklist) {
         Map<String, Object> responseBodyMap = LosUtils.jsonStringToMapConvert(responseBody);
       
        List<Tracker__c> trackerLog = [select Id, ApiName__c, Record_Id__c, Record_Type__c, Lead__c, Status__c, StatusCode__c from Tracker__c 
                                       where Deal__c =: opp.Id and ApiName__c =: apiName/* and Record_Id__c =: cv.ContentDocumentId*/];
        
        String status = responseBodyMap.get(LOSConstants.STATUS).toString();
        Integer statusCode = Integer.valueOf(responseBodyMap.get(LOSConstants.STATUS_CODE));
        
        if(trackerLog.size() > 0) {
            // Update only if existing record is sucess. If failure skip process altogether,
            if(trackerLog[0].Status__c == LOSConstants.DMS_SUCCESS && trackerLog[0].StatusCode__c == LOSConstants.DMS_SUCCESS_CODE) {
                trackerLog[0].Request__c = request;
                trackerLog[0].Response__c = responseBody;
                trackerLog[0].Status__c = status;
                trackerLog[0].StatusCode__c = statusCode;
                trackerLog[0].Account__c = docChecklist.Applicant__r.Account__c;
                update trackerLog[0];
            } 
        } else {
            Tracker__c trackDetailsobj = new Tracker__c();
            trackDetailsobj.Lead__c =  opp.Lead__c;
            trackDetailsobj.Deal__c = opp.Id;
            trackDetailsobj.ApiName__c = apiName;
            trackDetailsobj.Request__c = request;
            trackDetailsobj.Response__c = responseBody;
            trackDetailsobj.Status__c = status;
            trackDetailsobj.StatusCode__c = statusCode;     
            trackDetailsobj.Record_Id__c = docChecklist.Id;
            trackDetailsobj.Account__c = docChecklist.Applicant__r.Account__c;
            trackDetailsobj.Record_Type__c = LOSConstants.DOCUMENT_ID;
            insert trackDetailsobj;
        }
    }
    
    /**
     * Author: Aasim Shaikh
     * @description This method is used to track failed DMS API requests and responses.
     * 
     * This method takes various parameters related to a failed DMS API request and response,
     * such as an Opportunity object, API name, request details, response body,
     * and a Document_Checklist__c object. It tracks these details specifically for failed API calls,
     * which can be useful for debugging and analysis.
     * 
     * @param opp The Opportunity object associated with the failed DMS API interaction.
     * @param apiName The name of the API that was called.
     * @param request The request details sent to the DMS API.
     * @param responseBody The response received from the DMS API.
     * @param docChecklist The Document_Checklist__c object associated with the DMS interaction.
     * @date 19/04/2023
     */
    public static void trackFailedDmsApiRequest(Opportunity opp, String apiName, String request, String responseBody, Document_Checklist__c docChecklist) {
        Map<String, Object> responseBodyMap = LosUtils.jsonStringToMapConvert(responseBody);
        
        Error_log__c errorLogObj = new Error_log__c();
        errorLogObj.Lead__c = opp.Lead__c;
        errorLogObj.Deal__c = opp.Id;
        errorLogObj.ApiName__c = apiName;
        errorLogObj.Request__c = request;
        errorLogObj.Response__c = responseBody;
        errorLogObj.Record_Id__c = docChecklist.Id;
        errorLogObj.Record_Type__c = LOSConstants.DOCUMENT_ID;
        errorLogObj.Status__c = responseBodyMap.get(LOSConstants.STATUS).toString();
        errorLogObj.StatusCode__c = Integer.valueOf(responseBodyMap.get(LOSConstants.STATUS_CODE));
        errorLogObj.Account__c = docChecklist.Applicant__r.Account__c;
        insert errorLogObj;
    } 
    
    /**
     * Author: Sohail Solapure
     * @description This method is used to update the document index in a ContentVersion record.
     * 
     * This method takes a ContentVersion object and a document index as input and updates the
     * document index in the ContentVersion record. The purpose is to keep track of the order or
     * sequence of documents.
     * 
     * @param cv The ContentVersion object to update the document index for.
     * @param documentIndex The document index to be updated in the ContentVersion record.
     * @date 30/05/2023
     */
    public static void updateDocumentIndex(ContentVersion cv,String documentIndex){
        cv.Document_Index__c = documentIndex;
        update cv;
    }
    
    /**
     * Author: Sohail Solapure
     * @description This method is used to send an email notification when a DMS API call fails.
     * 
     * This method takes an Opportunity object and the name of the API as input and sends an email
     * notification to relevant stakeholders when a DMS API call associated with the Opportunity fails.
     * The email can serve as an alert for action or investigation.
     * 
     * @param opp The Opportunity object associated with the failed DMS API call.
     * @param apiName The name of the API that failed.
     * @date 04/04/2023
     */
    public static void sendMailForFailedDMSApi(Opportunity opp, String apiName) {
        try{ 
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            Error_log__c errorLog = [SELECT Id from Error_log__c WHERE ApiName__c =: apiName AND Deal__c =: opp.Id ORDER BY CreatedDate LIMIT 1];
            EmailTemplate et =[Select Id,Subject,HtmlValue, DeveloperName From EmailTemplate where DeveloperName =: Label.DMS_API_Fail_Email];
            List<OrgWideEmailAddress> orgEmailAddress=[select Id from OrgWideEmailAddress WHERE DisplayName =: System.Label.Organization_Wide_Email_Addresses];
            
            if(orgEmailAddress.size() > 0){
                mail.setOrgWideEmailAddressId(orgEmailAddress[0].Id); 
            }
            String errorURL = '';
            if(errorLog != null){
                errorURL = System.URL.getSalesforceBaseURL().toExternalForm() + '/'+ errorLog.Id;
            }
            
            List<String> toAddresses = new List<String>();
            List<String> ccAddresses = new List<String>();
            String losFailedEmailAddress = label.DMS_Failed_Email_Address;
            ccAddresses = losFailedEmailAddress.split(',');
            toAddresses.add(UserInfo.getUserEmail()); 
            String emailBody = ((String)et.HtmlValue).replace(LOSConstants.API_NAME, apiName).replace(LOSConstants.ERROR_LOG_LINK,errorURL);
            String newSubject = et.Subject.replace(LOSConstants.API_NAME, apiName);
            mail.setSubject(newSubject);
            mail.setHtmlBody(emailBody);
            mail.setToAddresses(toAddresses);
            mail.setccAddresses(ccAddresses);
            mail.setTreatBodiesAsTemplate(True); 
            mail.setTargetObjectId(opp.Lead__c);
            mail.setWhatId(opp.Id);
            mail.setTreatTargetObjectAsRecipient(false);
            mail.setSaveAsActivity(false);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } 
        catch(Exception e) {
            System.debug(LOSConstants.EMAIL_EXCEPTION + e.getMessage() + LOSConstants.QUERY_EXCEPTION_LINE + e.getLineNumber());
        }     
    }
}