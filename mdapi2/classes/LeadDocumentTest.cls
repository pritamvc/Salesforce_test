@IsTest
public class LeadDocumentTest {
   
    @IsTest
    public static void testUpdateDocumentCheck() {
        // Create test data
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Lead leadRecord=TestDataFactory.createLead(true);
        
        // Call the method to be tested
        Test.startTest();
        Lead updatedLead = LeadDocument.updateDocumentCheck(leadRecord.Id, true);
        Test.stopTest();
        
        // Perform assertions
        System.assertEquals(true, updatedLead.Document_Checked__c, 'Expected the Document_Checked__c field to be true');
    }
    
    @IsTest
    public static void testGetLeadWeightage() {
        // Create test data
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Lead leadRecord=TestDataFactory.createLead(true);
        
        // Call the method to be tested
        Test.startTest();
        Decimal weightage = LeadDocument.getLeadWeightage(leadRecord.Id);
        Test.stopTest();
        
        // Perform assertions
        //System.assertEquals(75, weightage, 'Expected the weightage to be 75');
    }
    
    @IsTest
    public static void testGetFinancialCoApplicants() {
        // Create test data
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Lead leadRecord=TestDataFactory.createLead(true);
        
        Account accountRecord = TestDataFactory.createAccount(true);
        Co_Applicant__c coApplicantRecord = TestDataFactory.CreateCoApplicant(true);
        
        // Call the method to be tested
        Test.startTest();
        Decimal count = LeadDocument.getFinancialCoApplicants(leadRecord.Id);
        Test.stopTest();
        
        // Perform assertions
        //System.assertEquals(1, count, 'Expected the count of financial co-applicants to be 1');
    }
    @IsTest
    static void testMandatoryDocumentValidation() {
        // Create test data
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Lead testLead=TestDataFactory.createLead(true);
     
        Account accrecrds =TestDataFactory.createPersonAccount(true);
        accrecrds.Aadhar_Number__c ='1234567890';
        accrecrds.PAN_Number__c ='12355234';
        accrecrds.Driving_License_Number__c='12355234';
            accrecrds.Passport_Number__c='12355234';
            accrecrds.Voter_ID__c='12355234';
        update accrecrds;
        
         //  Account testAccount = TestOrgDataFactory.createAccount(true);
       
     
        
        List<Co_Applicant__c> coapplist = new list<Co_Applicant__c>();
        Co_Applicant__c coapprecrds = TestDataFactory.CreateCoApplicant(true);
        coapprecrds.Lead__c =testLead.id;
        coapprecrds.Insertion_Order__c =0;
       coapprecrds.Account__c=accrecrds.id;
        update coapprecrds;
        
        
            
         // Create ContentVersion records with ContentDocumentLink for test Account
        ContentVersion cv1 = new ContentVersion(
            Title = 'Aadhar_card_front',
            Document_Sub_Type__c = 'Front',
            Lead__c = testLead.Id,
            Account__c = accrecrds.Id,
            PathOnClient = 'dummyPath1.txt',
            VersionData = Blob.valueOf('Dummy Content')
        );
        ContentVersion cv2 = new ContentVersion(
            Title = 'Aadhar_card_back',
            Document_Sub_Type__c = 'Back',
            Lead__c = testLead.Id,
            Account__c = accrecrds.Id,
            PathOnClient = 'dummyPath2.txt',
            VersionData = Blob.valueOf('Dummy Content')
        );
        insert new List<ContentVersion>{cv1, cv2};
        // Call the method to test
        Test.startTest();
        String result = LeadDocument.mandatoryDocumentValidation(testLead.Id);
        Test.stopTest();

        // Perform assertions
        //System.assertEquals('success', result);
    }
}