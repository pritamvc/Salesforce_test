@isTest
public class BulkLeadUploadBatchavoidDMLAndAPITest { 
    @isTest
    static void testBulkLeadUploadBatchavoidDMLAndAPI(){
        Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        List<CampaignMember> CampaignMemberList = TestDataFactory.createCampaignMemberList(false);
        Database.executeBatch(new BulkLeadUploadBatchavoidDMLAndAPI(CampaignMemberList),100); 
        Test.stopTest();
    }
    
}