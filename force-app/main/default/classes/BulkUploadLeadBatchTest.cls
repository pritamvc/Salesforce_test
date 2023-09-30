@isTest
public class BulkUploadLeadBatchTest {
    @isTest
    static void TestcreateBulkLeads(){
        Test.startTest();
        List<Lead> leadList = new List<Lead>();
        // leadList = TestDataFactory.createLeadList(False);
        Account AccountObj = TestDataFactory.createAccount(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Lead LeadObj = TestDataFactory.createLead4(False);
        LeadObj.Source_Name__c = objSource.Id;
        LeadObj.ErrorMessage__c = '';
       // insert LeadObj ;
        leadList.add(LeadObj);
        Lead LeadObj2 = TestDataFactory.createLead4(False);
        LeadObj2.Source_Name__c = objSource.Id;
        LeadObj2.ErrorMessage__c = '';
       // insert LeadObj ;
        leadList.add(LeadObj2);
        Group salesProcessingQueue = TestDataFactory.createSalesProcessingQueu(false);
        String jsonString = JSON.serialize(leadList);
        Database.executeBatch(new BulkUploadLeadBatch(leadList,leadList,AccountObj.Id,'SampleCSVFile.csv',TestDataFactory.fieldsString),200);   
        Utility.dynamicBulkUploadLeadsCSVTemplate();
       // Utility.setVisibilityOfComponentBasedOnRole();
        Test.stopTest();
    }
    
}