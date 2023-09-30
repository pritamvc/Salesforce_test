/******************************************************************************************************************************
* @author          Thinqloud Solutions (Rahul Shukla)
* @description     This Class called in SendEmailOnDealCreationTest,this class used to send email with attachment on creation of deal.
* @date            23/08/2023       
*******************************************************************************************************************************/
@isTest
public class SendEmailOnDealCreationTest {

    @isTest
    static void testSendEmailDocChck() {
        // Create test data
         Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
		Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);     
        Account testAccount =TestDataFactory.createPersonAccount(true);
        Lead lrecrds=TestDataFactory.createLead(true);
        Opportunity testOpp=TestDataFactory.createOpportunity(false);
        testOpp.Lead__c = lrecrds.Id;
        insert testOpp;
        //Opportunity testOpp = new Opportunity(Name = 'Test Opportunity', StageName = 'Closed Won', CloseDate = Date.today(), AccountId = testAccount.Id);
        //insert testOpp;
        
        Co_Applicant__c testApplicant = new Co_Applicant__c(Name = 'Test Applicant', Deal__c = testOpp.Id, Type__c = 'Applicant', Account__c = testAccount.Id, Email__c = testAccount.PersonEmail);
        insert testApplicant;
        
        Co_Applicant__c testCoApplicant1 = new Co_Applicant__c(Name = 'Test Co-Applicant', Deal__c = testOpp.Id, Type__c = CommonConstant.COAPPLICANT, Account__c = testAccount.Id, Email__c = testAccount.PersonEmail);
        insert testCoApplicant1;
        // Create test Document Checklist records
         List<ContentVersion> contentVersionsToInsert = new List<ContentVersion>();
        Set<Id> docIds = new Set<Id>();
        Document_Checklist__c testDocChecklist = new Document_Checklist__c(Applicant_Type__c = 'Applicant',Applicant_Name__c = 'Test',Document_DMS_Name__c = 'TestDoc',Document_Type__c = 'Other Document', Doc_Sub_Type__c = 'Application Form', Deal__c = testOpp.Id);
        insert testDocChecklist;
        List<ContentDocumentLink> contentDocumentLinkToInsert = new List<ContentDocumentLink>();
        integer size=1;
        for (Integer i = 1; i <= size; i++) {
            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S'; 
            cv.PathOnClient = 'test.pdf'; 
            cv.Title = 'test.txt'; 
            cv.VersionData = Blob.valueOf('Content of file ' + i); 
            contentVersionsToInsert.add(cv);
        }
        insert contentVersionsToInsert;
        for(ContentVersion cv : contentVersionsToInsert){
            docIds.add(cv.Id);
        }
        
        List<ContentVersion> contentVersions = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN  :docIds];
        for(ContentVersion cv : contentVersions){
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cv.ContentDocumentId;
            cdl.LinkedEntityId = testDocChecklist.Id; 
            //cdl.ShareType = 'V'; 
            cdl.Visibility = 'AllUsers'; 
            contentDocumentLinkToInsert.add(cdl);
        }
        // Insert the ContentVersion records
        insert contentDocumentLinkToInsert;
        Test.startTest();
        List<Id> oppIds = new List<Id>{testOpp.Id};
        SendEmailOnDealCreation.sendEmailDocChck(oppIds);
       
        // Call the method to be tested
        List<Messaging.EmailFileAttachment> result = SendEmailOnDealCreation.getContentVers(new List<String>{testOpp.Id});

        // Perform assertions
        System.assertEquals(1, result.size()); // Ensure one attachment is returned

        Messaging.EmailFileAttachment attachment = result[0];
        System.assertEquals('test.txt', attachment.fileName); // Ensure attachment file name matches

        Test.stopTest();
        
        
    }
}