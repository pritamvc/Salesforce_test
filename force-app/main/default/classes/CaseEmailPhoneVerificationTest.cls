@isTest
public class CaseEmailPhoneVerificationTest {
    @isTest 
    public static void casePhoneVerification(){
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account account = new Account();
        account.FirstName = 'Test';
        account.LastName  = 'CR';
        account.PersonEmail = 'test123@gmail.com';
        account.PersonMobilePhone = '1234567890';
        account.RecordTypeId = recordTypeId;
        insert account;
        
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'Test Opportunity';
        opportunity.AccountId = account.Id;
        opportunity.StageName = 'Loan Closed';
        opportunity.CloseDate = System.today();
        opportunity.Service_Branch__c = 'MUMBAI';
        opportunity.First_Disbursement_Date__c = system.today();
        insert opportunity;
        
        Co_Applicant__c coapplicant = new Co_Applicant__c();
        coapplicant.Name = 'Test';
        coapplicant.Account__c = account.Id;
        coapplicant.Deal__c = opportunity.Id;
        insert coapplicant;
        
        Case newCase = new Case();
        newCase.Subject = 'Test Case';
        newCase.AccountId = account.Id;
        newCase.LAN__c = opportunity.Id;
        newCase.Request_Type__c = 'Service Request';
        newCase.Service_Request_Type__c = 'Change Contact Coordinates';
        newCase.SR_Sub_Type__c = 'Change Registered Mobile Number';
        newCase.New_Mobile_Number__c = '1234567890';
        insert newCase;
        
        CaseEmailPhoneVerification.Params apiParams = new CaseEmailPhoneVerification.Params();
        apiParams.caseObj = newCase;
        apiParams.email_phone = '1234567890';
        apiParams.type = 'Phone';
        
        CaseEmailPhoneVerification.Params [] apiParamsList = new List<CaseEmailPhoneVerification.Params>();
        apiParamsList.add(apiParams);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockTest('CaseEmailPhoneVerificationTest'));
        CaseEmailPhoneVerification.verification(apiParamsList);
        Test.stopTest();
    }
    
    @isTest
    public static void caseEmailVerification(){
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
         Account account = new Account();
        account.FirstName = 'Test';
        account.LastName  = 'CR';
        account.PersonEmail = 'test123@gmail.com';
        account.PersonMobilePhone = '1234567890';
        account.RecordTypeId = recordTypeId;
        insert account;
        
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'Test Opportunity';
        opportunity.AccountId = account.Id;
        opportunity.StageName = 'Loan Closed';
        opportunity.CloseDate = System.today();
        opportunity.Service_Branch__c = 'MUMBAI';
        opportunity.First_Disbursement_Date__c = system.today();
        insert opportunity;

		Co_Applicant__c coapplicant = new Co_Applicant__c();
        coapplicant.Name = 'Test';
        coapplicant.Account__c = account.Id;
        coapplicant.Deal__c = opportunity.Id;
        insert coapplicant;
        
        Case newCase = new Case();
        newCase.Subject = 'Test Case';
        newCase.AccountId = account.Id;
        newCase.LAN__c = opportunity.Id;
        newCase.Request_Type__c = 'Service Request';
        newCase.Service_Request_Type__c = 'Change Contact Coordinates';
        newCase.SR_Sub_Type__c = 'Change Registered Mobile Number';
        newCase.New_Mobile_Number__c = '1234567890';
        newCase.New_Email__c = 'newemail@gmail.com';
        insert newCase;
        
        CaseEmailPhoneVerification.Params apiParams = new CaseEmailPhoneVerification.Params();
        apiParams.caseObj = newCase;
        apiParams.email_phone = 'newemail@gmail.com';
        apiParams.type = 'Email';
        
        CaseEmailPhoneVerification.Params [] apiParamsList = new List<CaseEmailPhoneVerification.Params>();
        apiParamsList.add(apiParams);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockTest('CaseEmailPhoneVerificationTest'));
        CaseEmailPhoneVerification.verification(apiParamsList);
        Test.stopTest();
    }
}