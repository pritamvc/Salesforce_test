@isTest
public class ApplicantTriggerHandlerTest {
    @isTest
    static void testApplicantTriggerHandler(){
        Test.startTest();
        List<Co_Applicant__c> newApplicantList = new List<Co_Applicant__c>();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);  
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Lead LeadObj = TestDataFactory.createLead(True);
        Co_Applicant__c coApplicantObj = TestDataFactory.CreateCoApplicant(False);
        coApplicantObj.Lead__c =LeadObj.Id;
        Insert coApplicantObj ;
        newApplicantList.add(coApplicantObj);
        Co_Applicant__c coApplicantObj2 = TestDataFactory.CreateCoApplicant(true);
        coApplicantObj2.Lead__c =LeadObj.Id;
        //coApplicantObj2.Type__c =CommonConstant.COAPPLICANT;
        Update coApplicantObj2 ;
        newApplicantList.add(coApplicantObj2);
        Co_Applicant__c coApplicantObj3 = TestDataFactory.CreateCoApplicant(true);
        coApplicantObj3.Lead__c =LeadObj.Id;
        coApplicantObj3.Type__c =CommonConstant.COAPPLICANT;
        coApplicantObj3.Is_Income_Considered_Financial__c ='Yes';
        Update coApplicantObj3 ;
        newApplicantList.add(coApplicantObj3);
        Co_Applicant__c coApplicantObj4 = TestDataFactory.CreateCoApplicant(true);
        coApplicantObj4.Lead__c =LeadObj.Id;
        coApplicantObj4.Type__c ='Guarantor';
        coApplicantObj4.Is_Income_Considered_Financial__c ='Yes';
        Update coApplicantObj4;
        newApplicantList.add(coApplicantObj4);
        ApplicantTriggerHandler.insertionOrderUpdationOnApplicant(newApplicantList);
        ApplicantTriggerHandler.updateNamingOrder(newApplicantList);
        delete coApplicantObj3;
        Test.stopTest();
        
    }
}