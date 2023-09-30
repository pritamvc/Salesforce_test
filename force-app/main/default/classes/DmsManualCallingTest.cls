@isTest
public class DmsManualCallingTest {
    testMethod  public static void testDMS(){
         Test.startTest();
        //TestDataFactory.createLOSMapData();
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);

        //TestDataFactory.createInboundSource(true);
        Opportunity opp = TestDataFactory.createOpportunity1(true);
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(opp);
        
        Account AccountObj = TestDataFactory.createPersonAccount(True);
        
        //Applicant Record
        Co_Applicant__c coApplicantObj = TestDataFactory.CreateCoApplicant(false);
        coApplicantObj.Deal__c = opp.Id;
        coApplicantObj.Account__c = AccountObj.Id;
        insert coApplicantObj;
        
        TestDataFactory.createDocuments(opp.Id,1);

       
        HTTPRequestMock response = new HTTPRequestMock();
		Test.setMock(HttpCalloutMock.class, response);
        OpportunityTriggerHandler.updateDMSDataSync(oppList);
        Test.stopTest();
    }

    testMethod  public static void testDMS1(){
        Test.startTest();
        //TestDataFactory.createLOSMapData();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);

        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Opportunity opp = TestDataFactory.createOpportunityForScheduler(true);
        List<Id> oppId = new List<Id>();
        oppId.add(opp.Lead__c);
        TestDataFactory.createDocuments(opp.Id,1);
        TestDataFactory.createDMSTracker(opp);

        
        HTTPRequestMock response = new HTTPRequestMock('DMSFail');
		Test.setMock(HttpCalloutMock.class, response);
        DmsManualCalling.callToLOS(oppId);
        Test.stopTest();
    }

    testMethod  public static void testDMS2(){
        Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);

        //TestDataFactory.createLOSMapData();
        //TestDataFactory.createInboundSource(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        List<Id> oppId = new List<Id>();
        Opportunity opp = TestDataFactory.createOpportunityForFails(true);
        Account AccountObj = TestDataFactory.createPersonAccount(True);
        
        //Applicant Record
        Co_Applicant__c coApplicantObj = TestDataFactory.CreateCoApplicant(false);
        coApplicantObj.Deal__c = opp.Id;
        coApplicantObj.Account__c = AccountObj.Id;
        insert coApplicantObj;
        
        TestDataFactory.createFailDocuments(opp,1);
        oppId.add(opp.Lead__c);
        
        HTTPRequestMock response = new HTTPRequestMock();
		Test.setMock(HttpCalloutMock.class, response);
        try{
        DmsManualCalling.callToLOS(oppId);
        }catch(DmlException e){
            System.debug('Exception:'+e.getMessage());
        }
        Test.stopTest();
    }
}