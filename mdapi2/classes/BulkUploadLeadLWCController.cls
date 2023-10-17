public class BulkUploadLeadLWCController {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Import_Lead_Header_Field_Mapping__mdt> getImportLineHeaderFieldMappings(){
        
        List<Import_Lead_Header_Field_Mapping__mdt> importLineHeaderFieldMappings = Import_Lead_Header_Field_Mapping__mdt.getAll().values();
        Map<String, Import_Lead_Header_Field_Mapping__mdt> headerFieldMappings = new Map<String, Import_Lead_Header_Field_Mapping__mdt>();
        for(Import_Lead_Header_Field_Mapping__mdt mapping : importLineHeaderFieldMappings) {
            headerFieldMappings.put(mapping.Label, mapping);
        }
        System.debug('headerFieldMappings====> String '+ headerFieldMappings);
        return headerFieldMappings;
    }
    
    @AuraEnabled
    public static String saveLineItems(String jsonString, Boolean createLogs, String source, String sourceFunction, String referenceId, String logCode, string CampaignId) {
        system.debug('jsonString===. '+jsonString);
        List<Lead> newLineItems = (List<Lead>) JSON.deserialize(jsonString, List<Lead>.class);
        system.debug('newLineItems===='+ newLineItems);
        system.debug('newLineItems.size===='+ newLineItems.size());
        /********************** Set of newlineItem  ******************** */  
        Set<String> newLineItemMobilePhoneSet = new Set<String> ();
        Set<String> newLineItemEmailSet = new Set<String> ();
        
        For(Lead newLineItemObject : newLineItems ){
            newLineItemMobilePhoneSet.add(newLineItemObject.MobilePhone);
            newLineItemEmailSet.add(newLineItemObject.Email);
        }
        system.debug('newLineItemMobilePhoneSet===='+ newLineItemMobilePhoneSet);
        system.debug('newLineItemMobilePhoneSet.size===='+ newLineItemMobilePhoneSet.size());
        system.debug('newLineItemEmailSet===='+ newLineItemEmailSet);
        system.debug('newLineItemEmailSet.size===='+ newLineItemEmailSet.size());
        
        /* **************Get Existing Lead In system ************************************* */
        //  Set<String> dupePhoneString = new Set<String>(); //
        //  Set<String> dupeEmailString = new Set<String>(); //
        
        List<Lead> LeadlistToInsert = new List<Lead>();
        List<Lead> LeadlistDuplicate = new List<Lead>();
        
        List<Lead> existingLineItems = [Select Id ,Email, MobilePhone, CreatedDate From Lead where MobilePhone =: newLineItemMobilePhoneSet OR Email =: newLineItemEmailSet ]; // add based On email and Mobile in Or Condition
        system.debug('existingLineItems===='+ existingLineItems);
        system.debug('existingLineItems.size===='+ existingLineItems.size());
        
        /*********************** ***********************************************/
        
        Set<String> existingLineItemsMobilePhoneSet = new Set<String> ();
        Set<String> existingLineItemsEmailSet = new Set<String> ();
        
        For(Lead existingLineItemsObject : existingLineItems ){
            existingLineItemsMobilePhoneSet.add(existingLineItemsObject.MobilePhone);
            existingLineItemsEmailSet.add(existingLineItemsObject.Email);
        }
        system.debug('existingLineItemsMobilePhoneSet===='+ existingLineItemsMobilePhoneSet);
        system.debug('existingLineItemsMobilePhoneSet.size===='+ existingLineItemsMobilePhoneSet.size());
        system.debug('existingLineItemsEmailSet===='+ existingLineItemsEmailSet);
        system.debug('existingLineItemsEmailSet.size===='+ existingLineItemsEmailSet.size());
        
        /******************************** *************************************** */
        
        for(Lead newLineItemsObj : newLineItems ){
            if(existingLineItemsMobilePhoneSet.contains(newLineItemsObj.MobilePhone) || existingLineItemsEmailSet.contains(newLineItemsObj.Email)
               && (newLineItemsObj.MobilePhone != null && newLineItemsObj.Email != null )){
                   LeadlistDuplicate.add(newLineItemsObj);
               }else{
                   if((newLineItemsObj.MobilePhone != null && newLineItemsObj.Email != null )){
                       LeadlistToInsert.add(newLineItemsObj);
                   } 
               }
            
        }
        
        system.debug('LeadlistDuplicate==== New  '+ LeadlistDuplicate);
        system.debug('LeadlistDuplicate.size==== New  '+ LeadlistDuplicate.size());
        system.debug('LeadlistToInsert==== New  '+ LeadlistToInsert);
        system.debug('LeadlistToInsert.size==== New  '+ LeadlistToInsert.size());
        
        /********************************Try -Catch block Inset Lead Record ****************************************/
        try{
            List<CampaignMember> CampaignMemberList = new List<CampaignMember>();
            if(!LeadlistToInsert.isempty() && LeadlistToInsert.size() > 0){
                insert LeadlistToInsert ;
                system.debug('LeadlistToInsert.Id===>'+ LeadlistToInsert[0].Id);
                
                for(Lead ObjLead : LeadlistToInsert){
                    CampaignMember cm= New CampaignMember(
                        CampaignId=CampaignId,
                        LeadId=ObjLead.Id,
                        Status='Sent');
                    CampaignMemberList.add(cm);
                }
            }
            system.debug('CampaignMemberList===='+ CampaignMemberList);
            system.debug('CampaignMemberListSize===='+ CampaignMemberList.size());
            if(!CampaignMemberList.isempty() && CampaignMemberList.size() > 0){
               // insert CampaignMemberList ;
            }  
            
            if(!LeadlistDuplicate.isempty() && LeadlistDuplicate.size() > 0){
                String csvColumnHeader = 'First Name, Last Name, Email, Mobile Number, Lead Source, Gender\n';
                List<String> csvRowValues = new List<String>();
                
                for(Lead csvLeadlistDuplicate : LeadlistDuplicate) {
                    if(csvLeadlistDuplicate != null) {
                        String rowStr = 
                            csvLeadlistDuplicate.FirstName + ',' 
                            + csvLeadlistDuplicate.LastName + ','
                            + csvLeadlistDuplicate.Email + ','
                            + csvLeadlistDuplicate.MobilePhone + ',' 
                            + csvLeadlistDuplicate.LeadSource + ','
                            + csvLeadlistDuplicate.Gender__c.replace('\n', '. ');
                        csvRowValues.add(rowStr);
                    }
                }
                
                system.debug('csvRowValues======> ' +csvRowValues);
                system.debug('csvRowValuesSize======> ' +csvRowValues.size());
                
                if(csvRowValues.size() > 0) {
                    
                    String csvFile = csvColumnHeader + String.join(csvRowValues,'\n');
                    ContentVersion contentVersion = createContentVersion('DuplicateLeads_.csv', Blob.valueOf(csvFile));
                    
                    insert contentVersion;
                    Id contentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;
                    
                    ContentDocumentLink contentDocumentLink = createContentDocumentLink(contentDocumentId,CampaignId);
                    insert contentDocumentLink;
                    
                    SendEmailToLoggedInUser(CampaignId,contentVersion.Id);
                    
                }
                
                /* ******************************************* Email with attachment to current logged In user ************************* */
                
            }
            
        }catch(Exception e){
            System.debug('Error--'+e.getMessage());
        }
        string  messagestring;
        if(newLineItems.size() == LeadlistDuplicate.size()){
            messagestring = 'All Leads are Duplicate, Leads are not inserted In the salesforce system.';
        }
        if(LeadlistToInsert.size() > 0  && LeadlistDuplicate.size() > 0){
            messagestring = 'Out of '+newLineItems.size()+' leads '+ LeadlistToInsert.size()+' are inserted and '+LeadlistDuplicate.size()+ ' are duplicate lead.';
        } 
        
        if(LeadlistToInsert.size() > 0  && LeadlistDuplicate.size() == 0){
            messagestring = 'Out of '+newLineItems.size()+' leads '+ LeadlistToInsert.size()+' leads are inserted.';
        } 
        if((existingLineItems.size() == 0  && LeadlistDuplicate.size() > 0) ||(LeadlistToInsert == null && LeadlistDuplicate == null)){
            messagestring = 'Please ensure that you are inserting lead data only';
        } 
        system.debug('messagestring========>  '+ messagestring);
        return messagestring;
        
    }
    
    Public static void SendEmailToLoggedInUser(String CampaignRecordId,ID ContentDocumentId) {
        list<string> toAddresses = new list<string>();
        List<User> CurrentloggedInUserlst = [Select Id ,Name,Email From User where Id =:UserInfo.getUserId()];
        System.debug('CurrentloggedInUserlst============ ====> '+ CurrentloggedInUserlst);
        /*  if(!CurrentloggedInUserlst.isEmpty() && CurrentloggedInUserlst.size() > 0){
for(User UserObject : CurrentloggedInUserlst){
if(UserObject.Email != null){
toAddresses.add(UserObject.Email);
}
}
} */
        List<Campaign> campaignRecordlst = [Select Id ,Name, TotalLeadsInCSV__c, ActualInsertedLeadInCSV__c, DuplicateLeadsInCSV__c,
                                            CurrentLoggedinUserName__c,  CreatedDate From Campaign where Id =: CampaignRecordId];
        System.debug('campaignRecordlst============ ====> '+ campaignRecordlst);
        System.debug('CampaignId Parent Record ID ====> '+ CampaignRecordId);
        
        // ContentDocumentLink ContentDocumentLinkRecord =[select Id,ContentDocumentId from ContentDocumentLink where Id =:ContentDocumentLinkId];
        // System.debug('ContentDocumentLinkRecord ====> '+ CampaignRecordId);
        
        ContentVersion contentVersionRecord = [select id,VersionData,ContentDocument.Title from ContentVersion
                                               where ID =: ContentDocumentId];
        System.debug('contentVersionRecord ====> '+ contentVersionRecord);
        
        EmailTemplate invTemplate = [SELECT Id, Name, Subject, Body FROM EmailTemplate WHERE Name ='Duplicate CSV send To Logged In user'];
        System.debug('invTemplate ====> '+ invTemplate);
        List<Messaging.SingleEmailMessage > Email_list = new List<Messaging.SingleEmailMessage >();
        if(!CurrentloggedInUserlst.isEmpty() && CurrentloggedInUserlst.size() > 0){
            for(User UserObject : CurrentloggedInUserlst){
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                string Name =invTemplate.Name;
                string subject = invTemplate.subject;
                string emailBody = invTemplate.Body;
                if(UserObject.Email != null){
                    toAddresses.add(UserObject.Email);
                }
                list<Messaging.EmailFileAttachment> efaList = new list<Messaging.EmailFileAttachment>();    
                system.debug('efaList=================='+efaList);
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName('Duplicate Leads.csv');
                efa.setBody(contentVersionRecord.VersionData);
                efaList.add(efa);
                system.debug('efa=============='+efa);
                message.setSubject(subject);
                message.setTreatBodiesAsTemplate(True); 
                // message.setHtmlBody(emailBody);
                message.setToAddresses(toAddresses);
                // message.setTargetObjectId(UserObject.Id);
                // message.setSaveAsActivity(false);
                message.setFileAttachments(efaList);
                message.setPlainTextBody(emailBody);
                
                Email_list.add(message);
            }
            System.debug('toAddresses============ ====> '+ toAddresses);
            System.debug('toAddresses ====> '+ toAddresses.size());
        }
        try {
            if(Email_list.size() > 0){
                Messaging.SendEmailResult[] results =Messaging.sendEmail(Email_list);
                System.debug(results);   
                if(results.size() > 0){
                    if(results.get(0).isSuccess()){
                        System.debug('Success'+results);
                    }
                }  
            }
        }catch(Exception e) {
            system.debug('Email not sent'+e.getMessage());
        }
    }
    
    private static ContentVersion createContentVersion(String name, Blob body) {
        ContentVersion contentVersion = new ContentVersion();
        
        contentVersion.PathOnClient = name;
        contentVersion.Title = name;
        contentVersion.VersionData = body;
        return contentVersion;
    }
    private  static ContentDocumentLink createContentDocumentLink(Id contentDocumentId, Id parentId){
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = contentDocumentId;
        contentDocumentLink.LinkedEntityId = parentId; /// record id
        contentDocumentLink.ShareType = 'I'; // Inferred permission
        contentDocumentLink.Visibility = 'AllUsers';
        return contentDocumentLink;
    }  
}