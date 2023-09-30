@istest
public class LeadReferenceControllerTest {
    
    @isTest
    Public static void testLeadReferenceController() {
        
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true); 
        Lead lrecrds=TestDataFactory.createLead(true);
        Area__c arrecrds=TestDataFactory.createArea(true);
        List<Reference__c> refList = new List<Reference__c>();
        Reference__c refrecrds=TestDataFactory.createReference(true);
        Reference__c refrecrds1=TestDataFactory.createReference(true);
        refList.add(refrecrds);
        refList.add(refrecrds1);
        Test.startTest();
        LeadReferenceController.getPincodeRecord(arrecrds.id);
        LeadReferenceController.createReferenceRecord(refList,lrecrds.id);
        LeadReferenceController.updateReferenceCheck(lrecrds.Id,true);
        LeadReferenceController.getPicklistValues();
        Test.stopTest();
    }
    
}