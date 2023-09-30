@isTest
public class AttachPDFToLeadTest {

    @isTest
    static void testAttachPDF() {
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        // Create a test Lead
       // Lead testLead = new Lead(FirstName = 'Test', LastName = 'Lead');
        //insert testLead;
         Lead lrecrds=TestDataFactory.createLead(true);

        // Create a ContentVersion record
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Test.pdf',
            VersionData = Blob.valueOf('Sample PDF Content'),
            PathOnClient = 'Test.pdf'
        );
        insert testContentVersion;

        // Create a Document_Checklist__c record associated with the test Lead
        Document_Checklist__c testDocChecklist = new Document_Checklist__c(
            Document_Type__c = 'Other Document',
            Doc_Sub_Type__c = 'Application Form',
            Lead__c = lrecrds.Id
        );
        insert testDocChecklist;

        // Instantiate AttachPDFToLead class with test Lead
        AttachPDFToLead pdfAttacher = new AttachPDFToLead(new ApexPages.StandardController(lrecrds));
        
        // Test attachPDF method
        System.assertEquals(0, [SELECT count() FROM ContentDocumentLink WHERE LinkedEntityId = :testDocChecklist.Id]);
        //System.assertEquals(0, [SELECT count() FROM ContentVersion WHERE Id = :testContentVersion.Id]);

        pdfAttacher.attachPDF();

        System.assertEquals(1, [SELECT count() FROM ContentDocumentLink WHERE LinkedEntityId = :testDocChecklist.Id]);
        System.assertEquals(1, [SELECT count() FROM ContentVersion WHERE Id = :testContentVersion.Id]);

        // Clean up
        //delete testContentVersion;
        delete testDocChecklist;
        delete lrecrds;
    }
}