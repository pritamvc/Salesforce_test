@isTest
public class LeadLoanRequirementsTest {
	
    @isTest
    Public static void testLeadLoanRequirementsTest() {
        
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Lead lrecrds=TestDataFactory.createLead(true);
        LeadLoanRequirements.getWrapperClassApplicationForm(lrecrds.Id);
        //string wrapperjson='{"loanSectionLeadRec":""}';
        //LeadLoanRequirements.saveUpdateLoanOnLead(wrapperjson);
      
    }
    
    @isTest
    public static void testDealLoanRequirementsTest() {
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Opportunity lrecrds = TestDataFactory.createOpportunity2(true);
        DealLeadLoanRequirements.getWrapperClassApplicationForm(lrecrds.Id);      
    }
    
    @isTest
    static void testSaveUpdateLoanOnLead() {
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        // Create test data
        Lead lrecrds=TestDataFactory.createLead(true);

        // Create the wrapper class instance
        LeadLoanRequirements.wrapperClassApplicationForm wrapperInstance = new LeadLoanRequirements.wrapperClassApplicationForm();
        wrapperInstance.loanSectionLeadRec = JSON.serialize(lrecrds);

        // Call the method being tested
        Test.startTest();
        String leadId = LeadLoanRequirements.saveUpdateLoanOnLead(JSON.serialize(wrapperInstance));
        Test.stopTest();

        // Retrieve the updated Lead record
        Lead updatedLead = [SELECT Id, Lead_form_Weightage__c FROM Lead WHERE Id = :leadId];

        // Assert the results
        System.assertEquals(lrecrds.Id, leadId);
        // Assert any other necessary conditions based on the expected behavior of the code

        // Clean up test data
        delete updatedLead;
    }
    
    @isTest
    static void testSaveUpdateLoanOnDeal() {
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Opportunity lrecrds = TestDataFactory.createOpportunity2(true);
        
        DealLeadLoanRequirements.wrapperClassApplicationForm wrapperInstance = new DealLeadLoanRequirements.wrapperClassApplicationForm();
        wrapperInstance.loanSectionLeadRec = JSON.serialize(lrecrds);

        // Call the method being tested
        Test.startTest();
        String leadId = DealLeadLoanRequirements.saveUpdateLoanOnLead(JSON.serialize(wrapperInstance));
        Test.stopTest();
    }
}