/******************************************************************************************************************************
* @author          Thinqloud Solutions (Rahul Shukla)
* @description     This Class called in SendEmailOnDealCreation,this class used to send email with attachment on creation of deal .
* @date            23/08/2023    
* @testClass: 
*******************************************************************************************************************************/

public class SendEmailOnDealCreation {
    
    /********************************************************************************************************************
* @author          Rahul Shukla
* @description     Method to send email with attachments to applicants and co-applicants
* @return          No-return    
* @date            23/08/2023   
***************************************************************************************************************************/
    
    public Static void sendEmailDocChck(List<Id> oppID){
        // Fetch the email template for the email
        EmailTemplate emailTemp = [SELECT Id, Subject, Body, HTMLValue FROM EmailTemplate WHERE  DeveloperName = 'Email_to_Applicant_CoApplicant'];
        // Fetch document checklist records related to the Opportunity
        List<Document_Checklist__c> dochck=[select id,Deal__c from Document_Checklist__c where Document_Type__c='Other Document' and Doc_Sub_Type__c='Application Form' and Deal__c = :oppID];
        // Lists to hold email addresses
        List<String> toAddress = new List<String>();
        List<String> ccAddress = new List<String>();
        // List to store email messages
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        
        // Fetch the Lead Owner's email address
        String leadOwnerEmail;
        String leadOwnerName;
        Lead leadRecord = [SELECT Id, Owner.Email,Owner.Name FROM Lead WHERE Id IN (SELECT Lead__c FROM Opportunity WHERE Id = :oppID[0])];
        
        if (leadRecord != null) {
            leadOwnerEmail = leadRecord.Owner.Email;
            leadOwnerName = leadRecord.Owner.Name;
        }
        
        
        // Fetch org-wide email address for the "From" field
        //List<OrgWideEmailAddress> owea = [select Id from OrgWideEmailAddress WHERE Address='noreply@auxilo.com'];
        
        
        // Fetch applicant and co-applicant information
        List<Co_Applicant__c> applicantname = [SELECT Id, Name,Owner.Name,Account__r.PersonEmail,Email__c,Type__c, Account__r.FirstName, Account__r.LastName FROM Co_Applicant__c WHERE Deal__c = :oppID];  
        //Id contentDocId= [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: dochck[0].id limit 1].ContentDocumentId;
        //Id contectVersionId =[SELECT Id,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId=:contentDocId LIMIT 1].ContentDocumentId;
        // Initialize variables to store applicant information
        id applicantId; 
        string appName;
        for(Co_Applicant__c objCopp: applicantname){
            
            // Check if the Co_Applicant__c record is of type 'Applicant'
            if(objCopp.Type__c== 'Applicant'){
                // Store the applicant's Id and name
                applicantId = objCopp.Id;
                appName = objCopp.Name;
                // Add the applicant's email to the list of recipients
                toAddress.add(objCopp.Account__r.PersonEmail);
            }
            else{
                // Add the co-applicant's email to the list of CC recipients
                ccAddress.add(objCopp.Account__r.PersonEmail);
            }
            
        } 
        
        // Create an email message
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(emailTemp.Subject);
        // Replace placeholders in email body with actual values
        String body = ((String)emailTemp.HtmlValue).replace('{!Co_Applicant__c.Name}', appName);
        //List<Id> idList = new List<Id>(OppID);
        email.setHtmlBody(body);  // Set the HTML body of the email
        email.setTemplateId(emailTemp.Id);  // Set the email template ID for the email
        email.setSaveAsActivity(true); // Save the email as an activity on the record
        email.setwhatid(oppID[0]);
        // Set the recipient addresses for the email
        email.setToAddresses(toAddress);
        email.setccAddresses(ccAddress);
        // Set the "From" address to the Lead Owner's email address
        email.setReplyTo(leadOwnerEmail);
        email.setSenderDisplayName(leadOwnerName); // Optionally set the sender's display name
        
        // Attach content versions to the email if available
        List<Messaging.EmailFileAttachment> emailFileAttList = getContentVers(oppID);
        if(emailFileAttList.size() > 0) {
            email.setFileAttachments(emailFileAttList); 
            //List<Id> convId = new List<Id>();
            //convId.add(contectVersionId);
            //email.setEntityAttachments(emailFileAttList);
        }
        
        // Set the email body as a template and specify the org-wide email address
        email.setTreatBodiesAsTemplate(true);
        //email.setOrgWideEmailAddressId(owea[0].Id);
        // Add the email to the list of email messages to be sent
        emailList.add(email);
        
        try{
            if (!emailList.isEmpty()) {
                Messaging.sendEmail(emailList);
            } 
        }catch (Exception ex) {
            System.debug('An error occurred while Email: ' + ex.getMessage());
        }
        
        
    }
    /********************************************************************************************************************
* @author          Rahul Shukla
* @description     Method to get email attachments from ContentVersion records
* @return          No-return    
* @date            23/08/2023   
***************************************************************************************************************************/
    
    public static List<Messaging.EmailFileAttachment> getContentVers(List<String> oppID) {  
        
        List<Messaging.EmailFileAttachment> emailAttachList = new List<Messaging.EmailFileAttachment>();
        // Fetch document checklist records for ContentDocumentLink
        List<Document_Checklist__c> dochck=[select id,Deal__c from Document_Checklist__c where Document_Type__c='Other Document' and Doc_Sub_Type__c='Application Form' and Deal__c = :OppId limit 1];
        // Fetch ContentDocumentLink records
        List<ContentDocumentLink> cdLs = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: dochck[0].id limit 1];
        List <Id> cdIdList = new List <Id> ();
        
        for (ContentDocumentLink nextCDL : cdLs) {
            cdIdList.add(nextCDL.ContentDocumentId); 
        }
        // Fetch ContentDocument records
        List<ContentDocument> entries = [SELECT Id, Title, FileType FROM ContentDocument WHERE Id IN :cdIdList];
        if(entries.size() > 0) {
            // Fetch latest ContentVersion records
            List<ContentVersion> cvList = [SELECT Id, title, VersionData, FileExtension, ContentDocumentId 
                                           FROM ContentVersion 
                                           WHERE ContentDocumentId IN:entries 
                                           And isLatest = true];
            // Create email attachments from ContentVersion records
            for(ContentVersion cvObj : cvList) {
                emailAttachList.add(setEmailFileAtt(cvObj));   // Add the created email attachment to the list  
            }
            return emailAttachList;
        }
        return emailAttachList;
    }
    /********************************************************************************************************************
* @author          Rahul Shukla
* @description     Method to create an email attachment from ContentVersion
* @return          No-return    
* @date            23/08/2023   
***************************************************************************************************************************/
    
    public static Messaging.EmailFileAttachment setEmailFileAtt(ContentVersion cvObj) {
        Messaging.EmailFileAttachment emlAtt = new Messaging.EmailFileAttachment();
        Blob fileData = cvObj.VersionData; // Get the binary data of the ContentVersion, which represents the content of the attachment
        String filenameapp = cvObj.Title; // Get the title of the ContentVersion as the attachment filename
        emlAtt.setFilename(filenameapp); // Set the attachment filename to be the same as the title of the ContentVersion
        emlAtt.setBody(fileData);// Set the attachment body using the binary data from the ContentVersion
        return emlAtt;
    }
    
}