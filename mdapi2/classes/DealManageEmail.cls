public class DealManageEmail {
    
    @InvocableMethod
    public Static void sendEmailDocChck(List<Id> OppID){
        //   System.debug('ID OppIDss'+OppIDs);
        //   System.debug('ID OppID'+OppID);
        
        System.debug('ID OppID'+OppID);
        EmailTemplate EmailTemp = [SELECT Id, Subject, Body, HTMLValue FROM EmailTemplate WHERE  DeveloperName = 'Email_to_Applicant_CoApplicant'];
        List<Document_Checklist__c> dochck=[select id,Deal__c from Document_Checklist__c where Document_Type__c='Other Document' and Doc_Sub_Type__c='Application Form' and Deal__c = :OppID];
        System.debug('Email dochck'+dochck);
        List<String> toAddress = new List<String>();
        List<String> ccAddress = new List<String>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<OrgWideEmailAddress> owea = [select Id from OrgWideEmailAddress WHERE Address='noreply@auxilo.com'];
        List<Co_Applicant__c> applicantname = [SELECT Id, Name,Owner.Name,Account__r.PersonEmail,Email__c,Type__c, Account__r.FirstName, Account__r.LastName FROM Co_Applicant__c WHERE Deal__c = :OppID];  
        System.debug('applicantname dochck'+applicantname);
        // Create a set to store unique email addresses
        //Set<String> uniqueEmailAddresses = new Set<String>();
        id applicantId;
        string Name;
        for(Co_Applicant__c objCopp: applicantname){
            
            if(objCopp.Type__c== 'Applicant'){
                System.debug('Email Enter');
                applicantId = objCopp.Id;
                Name = objCopp.Name;
                toAddress.add(objCopp.Account__r.PersonEmail);
            }
            else{
                ccAddress.add(objCopp.Account__r.PersonEmail);
            }
            
        } 
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(EmailTemp.Subject);
        
        //String body = EmailTemp.HTMLValue;
        String body = ((String)EmailTemp.HtmlValue).replace('{!Co_Applicant__c.Name}', Name);
        //String getOwnerName = objCopp.Owner.Name;
        
        email.setHtmlBody(body);
        // email.setPlainTextBody(body);
        email.setTemplateId(EmailTemp.Id);
        //email.setTargetObjectId(applicantId);
        email.setSaveAsActivity(true);
        //email.setTreatTargetObjectAsRecipient(false);
        //system.debug('SetToAddress' +SetToAddress);
        email.setToAddresses(toAddress);
        email.setccAddresses(ccAddress);
        //system.debug('SetToAddress' +SetToAddress);
        List<Messaging.EmailFileAttachment> emailFileAttList = getContentVers(OppID);
        if(emailFileAttList.size() > 0) {
            System.debug('emailList aattenter');
            email.setFileAttachments(emailFileAttList);   
        }
       
        email.setTreatBodiesAsTemplate(true);
        email.setOrgWideEmailAddressId(owea[0].Id);
        emailList.add(email);
        System.debug('emailList'+emailList);
        
        System.debug('emailList'+emailList.size());
        if (!emailList.isEmpty()) {
            Messaging.sendEmail(emailList);
        }
    }
    
    public static List<Messaging.EmailFileAttachment> getContentVers(List<String> OppID) {  
        System.debug('Att start');
        List<Messaging.EmailFileAttachment> emailAttachList = new List<Messaging.EmailFileAttachment>();
        List<Document_Checklist__c> dochck=[select id,Deal__c from Document_Checklist__c where Document_Type__c='Other Document' and Doc_Sub_Type__c='Application Form' and Deal__c = :OppId limit 1];
        System.debug('dochck start'+dochck.size());
        List<ContentDocumentLink> CDLs = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: dochck[0].id limit 1];
        System.debug('CDLs start'+CDLs.size());
        List <Id> CDIdList = new List <Id> ();
        
        for (ContentDocumentLink nextCDL : CDLs) {
            CDIdList.add(nextCDL.ContentDocumentId); 
        }
        System.debug('CDIdList start'+CDIdList.size());
        System.debug('CDIdList'+CDIdList);
        List<ContentDocument> entries = [SELECT Id, Title, FileType FROM ContentDocument WHERE Id IN :CDIdList];
        System.debug('entries start'+entries.size());
        System.debug('entries ++'+entries);
        if(entries.size() > 0) {
            System.debug('entries start'+entries.size());
            List<ContentVersion> cvList = [SELECT Id, title, VersionData, FileExtension, ContentDocumentId 
                                           FROM ContentVersion 
                                           WHERE ContentDocumentId IN:entries 
                                           And isLatest = true];
            System.debug('cvList start'+cvList.size());
            for(ContentVersion cvObj : cvList) {
                emailAttachList.add(setEmailFileAtt(cvObj));     
                System.debug('emailAttachList'+emailAttachList);
            }
            return emailAttachList;
        }
        return emailAttachList;
    }
    
    public static Messaging.EmailFileAttachment setEmailFileAtt(ContentVersion cvObj) {
        Messaging.EmailFileAttachment emlAtt = new Messaging.EmailFileAttachment();
        Blob fileData = cvObj.VersionData;
        emlAtt.setFilename('Document.' + cvObj.FileExtension);
        emlAtt.setBody(fileData);
        System.debug('emailAttachList seting'+emlAtt);
        return emlAtt;
    }
    
}