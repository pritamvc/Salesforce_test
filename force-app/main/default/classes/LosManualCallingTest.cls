@isTest
public class LosManualCallingTest {
    testMethod  public static void testManual() {
        Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        List<LosApiMap__c> losData = TestDataFactory.createLOSMapData();
        Opportunity opp = TestDataFactory.createOpportunity1(true);
        List<Id> oppId = new List<Id>();
        oppId.add(opp.Lead__c);

        //Applicant Record
        Co_Applicant__c coApplicantObj = TestDataFactory.CreateCoApplicant(false);
        coApplicantObj.Lead__c = opp.Lead__c;
        insert coApplicantObj;

        //Asset Record for Applicant
        Asset AssetObj = TestDataFactory.createAsset(true);
        AssetObj.Lead__c = opp.Lead__c;
        AssetObj.AccountId = opp.AccountId;
        update AssetObj;

        //Co-Applicant Record
        Co_Applicant__c coApplicantObj1 = TestDataFactory.CreateCoApplicantRecord(false);
        coApplicantObj1.Lead__c = opp.Lead__c;
        insert coApplicantObj1;

        //Asset Record for Co-Applicant
        Asset AssetObj1 = TestDataFactory.createAssetRecord(true);
        AssetObj1.Lead__c = opp.Lead__c;
        AssetObj1.AccountId = opp.AccountId;
        update AssetObj1;

        TestDataFactory.createTracker(opp.Id, opp.Lead__c);
        LosManualCalling.callToLOS(oppId);
        Test.stopTest();
    }

    testMethod  public static void testManual1() {
        Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        TestDataFactory.createLOSMapData();
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Opportunity opp = TestDataFactory.createOpportunityForScheduler(true);
        TestDataFactory.createTracker(opp.Id,opp.Lead__c);
        List<Id> oppId = new List<Id>();
        oppId.add(opp.Lead__c);
        LosManualCalling.callToLOS(oppId);
        Test.stopTest();
    }
}