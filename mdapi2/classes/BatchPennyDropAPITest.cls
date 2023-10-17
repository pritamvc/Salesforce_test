@isTest
private class BatchPennyDropAPITest {
    @isTest
    static void testBatchPennyDropAPI() {
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true); 
        Lead LeadObj = TestDataFactory.createLead(true);
        Account AccountObj = TestDataFactory.createPersonAccount(True);
        Opportunity opp=TestDataFactory.createOpportunity(true);
       	Id leadId=LeadObj.Id;
       	Bank_Details__c  BankDetailsobj = TestDataFactory.createBankDetails(false);
        BankDetailsobj.Lead__c = LeadObj.Id;
        BankDetailsobj.Account__c = AccountObj.Id; 
        BankDetailsobj.Account_Number__c='35939548644';
        BankDetailsobj.IFSC_Code__c='SBIN00128';
        BankDetailsobj.Deal__c=opp.id;
        insert BankDetailsobj;
        string concent='Y';       
        Test.startTest();
        HTTPRequestMock response = new HTTPRequestMock('SUCCESS');
        Test.setMock(HttpCalloutMock.class, response);
        BatchPennyDropAPI batch = new BatchPennyDropAPI(leadId);
        DocumentVerification.PannyDrop(BankDetailsobj.Lead__c,BankDetailsobj.Account__c, concent, BankDetailsobj.IFSC_Code__c, BankDetailsobj.Account_Number__c,BankDetailsobj.Deal__c);
        Database.executeBatch(batch);
        Test.stopTest();       
}
    @isTest
    static void testBatchPennyDropAPINew() {
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true); 
        Lead LeadObj = TestDataFactory.createLead(true);
        Account AccountObj = TestDataFactory.createPersonAccount(True);
        Opportunity opp=TestDataFactory.createOpportunity(true);
       	Id leadId=LeadObj.Id;
       	Bank_Details__c  BankDetailsobj = TestDataFactory.createBankDetails(false);
        BankDetailsobj.Lead__c = LeadObj.Id;
        BankDetailsobj.Account__c = AccountObj.Id; 
        BankDetailsobj.Account_Number__c='35939548644';
        BankDetailsobj.IFSC_Code__c='SBIN00128';
        BankDetailsobj.Deal__c=opp.id;
        insert BankDetailsobj;
        string concent='Y';       
        Test.startTest();
        HTTPRequestMock response = new HTTPRequestMock('SUCCESS');
        Test.setMock(HttpCalloutMock.class, response);
        BatchPennyDropAPI batch = new BatchPennyDropAPI(opp.id);
        DocumentVerification.PannyDrop(BankDetailsobj.Lead__c,BankDetailsobj.Account__c, concent, BankDetailsobj.IFSC_Code__c, BankDetailsobj.Account_Number__c,BankDetailsobj.Deal__c);
        Database.executeBatch(batch);
        Test.stopTest();       
}

}