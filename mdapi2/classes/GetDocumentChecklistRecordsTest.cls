@isTest
public class GetDocumentChecklistRecordsTest {
    
    static testmethod void testData(){
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true); 
        Source__c src = new Source__c(Name = 'Test',Lead_Gate__c = 'Distribution Partners', Lead_Source__c ='Business Partners', Source_Type__c ='Auxilo',
                                      Sub_Source_Type__c = 'Agencies', Source_Category__c = 'Partner');
        insert src;
        Lead newLead = new Lead();
        newLead.LastName = 'Test';
        newLead.Email = 'abc@gmail.com';
        newLead.MobilePhone = '5454253689';
        newLead.Source_Category__c = 'Partner';
        newLead.Source_Name__c = src.id;
        newLead.Product_Category__c = 'HEL - INDIA';
        insert newLead;
        
        String gsRecordTypeID = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account(FirstName = 'Test', LastName = 'new', recordTypeId = gsRecordTypeID);
        insert acc;
        Account newAcc = new Account(FirstName = 'Test1', LastName = 'new1', recordTypeId = gsRecordTypeID);
        insert newAcc;
        
        Co_Applicant__c coApp = new Co_Applicant__c(Account__c = acc.id, Type__c = CommonConstant.COAPPLICANT);
        insert coApp;
        Co_Applicant__c guarantor = new Co_Applicant__c(Account__c = newAcc.id, Type__c = 'Guarantor');
        insert guarantor;
        
        Document_Checklist__c dc = new Document_Checklist__c(Lead__c = newLead.id, Applicant__c = coApp.id, Applicant_Type__c = CommonConstant.COAPPLICANT,
                                                             Document_Type__c = 'KYC Documents', Doc_Sub_Type__c = 'Aadhar Card');
        insert dc;
        Document_Checklist__c dc1 = new Document_Checklist__c(Lead__c = newLead.id, Applicant__c = guarantor.id, Applicant_Type__c = 'Guarantor',
                                                              Document_Type__c = 'KYC Documents', Doc_Sub_Type__c = 'Aadhar Card',Status__c='Rejected');
        insert dc1;
        List<String> ids = new List<String>();
        ids.add(dc.Id);
        ids.add(dc1.Id);
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
        List<ContentVersion> cvLinkList = [select ContentDocumentId, id from ContentVersion where Id =:contentVersion.Id];
        Account testAccount = new Account(Name = 'Test Account',RecordTypeId=TestDataFactory.getRecordTypeId(true));
        insert testAccount;
        
        // Create a test ContentDocumentLink record
        ContentDocumentLink testContentDocLink = new ContentDocumentLink();
        testContentDocLink.LinkedEntityId = testAccount.Id; 
        testContentDocLink.ContentDocumentId = cvLinkList[0].ContentDocumentId;
        insert testContentDocLink;
        
        test.startTest();
        GetDocumentChecklistRecords.sendDocumentStatusViaEmailNotification(newLead.id);
        GetDocumentChecklistRecords.fetchChecklistRecordsForApplicant(newLead.id);
        //GetDocumentChecklistRecords.getContentDocument(dc.id);
        GetDocumentChecklistRecords.getCoApplicant(newLead.id);
        GetDocumentChecklistRecords.getGuarantor(newLead.id);
        GetDocumentChecklistRecords.updateStatusOnDocChecklist(dc1.id);
        GetDocumentChecklistRecords.fetchChecklistRecordsForApplicantUpdated(newLead.id);
        GetDocumentChecklistRecords.getCoApplicantUpdated(newLead.id);
        GetDocumentChecklistRecords.getGuarantorUpdated(newLead.id);
        GetDocumentChecklistRecords.getSalesProfile();
        GetDocumentChecklistRecords.getProfileLoginDesk();
        
        GetDocumentChecklistRecords.updateDockChecklist(ids);
        String contentDocId = GetDocumentChecklistRecords.getContentDocument(testAccount.Id); 
        test.stopTest();        
    }
}