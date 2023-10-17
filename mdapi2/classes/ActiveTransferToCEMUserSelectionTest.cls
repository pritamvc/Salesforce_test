@isTest
public class ActiveTransferToCEMUserSelectionTest {
    
    @isTest
    static void testActiveTransferToCEMUserSelection(){
        Test.startTest();
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);  
        User UserObj = TestDataFactory.createUser(True);
        Lead LeadObj = TestDataFactory.createLead(True);
        LeadObj.Service_Branch__c = 'AHMEDABAD';
        update LeadObj;
        String LeadIdStr = LeadObj.Id;
        ActiveTransferToCEMUserSelection.getActiveTransferToCEMUserSelection();
        ActiveTransferToCEMUserSelection.getServiceBarnchFromLead(LeadIdStr);//getUserList
        ActiveTransferToCEMUserSelection.getUserList(LeadObj.Service_Branch__c);
        ActiveTransferToCEMUserSelection.updateLeadRecord(LeadObj.Id,LeadObj.Service_Branch__c,UserObj.Id);
        Test.stopTest();
    }
    
}