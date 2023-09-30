@IsTest
public class PennyDropAPIManualCallingTest {
    @IsTest
    public static void TestPennyDropAPIManualCalling() {
        List<Id> newDealIdsList = new  List<Id>();
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Opportunity objectOpportunityRecord = TestDataFactory.createOpportunity1(true);
        newDealIdsList.add(objectOpportunityRecord.Id);
        system.Test.startTest();
        PennyDropAPIManualCalling.callToPennyDropAPI(newDealIdsList);
        system.Test.stopTest();
    }
}