@isTest
public class InterestStatementAPITest {
    @isTest private static void InterestStatementTest(){
        Account account = new Account();
        account.Name = 'Test';
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
        newCase.Service_Request_Type__c = 'Statement & Documents';
        newCase.SR_Sub_Type__c = 'Statement of Accounts';
        newCase.IC_From_Date__c = 2022;
        newCase.IC_To_Date__c = 2023;
        insert newCase;
        
        InterestStatementAPI.APIParams params = new InterestStatementAPI.APIParams();
        params.finReference = opportunity.Name;
        params.caseID = newCase.Id;
        params.firstDisbursementDate = opportunity.First_Disbursement_Date__c;
        params.fromYear =  Integer.valueOf(newCase.IC_From_Date__c);
        params.toYear =   Integer.valueOf(newCase.IC_To_Date__c);
        params.type = 'INSTCERTREPORT';
        
        InterestStatementAPI.APIParams[] paramsList = new List<InterestStatementAPI.APIParams>();
        paramsList.add(params);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockTest('access_token'));
        InterestStatementAPI.getInetrestStatement(paramsList);
        Test.stopTest();
    }
    
        @isTest private static void InterestStatementTestForSOA(){
        Account account = new Account();
        account.Name = 'Test';
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
        newCase.Service_Request_Type__c = 'Statement & Documents';
        newCase.SR_Sub_Type__c = 'Statement of Accounts';
        newCase.IC_From_Date__c = 2022;
        newCase.IC_To_Date__c = 2023;
        insert newCase;
        
        InterestStatementAPI.APIParams params = new InterestStatementAPI.APIParams();
        params.finReference = opportunity.Name;
        params.caseID = newCase.Id;
        params.firstDisbursementDate = opportunity.First_Disbursement_Date__c;
        params.fromYear =  Integer.valueOf(newCase.IC_From_Date__c);
        params.toYear =   Integer.valueOf(newCase.IC_To_Date__c);
        params.type = 'SOAREPORT';
        
        InterestStatementAPI.APIParams[] paramsList = new List<InterestStatementAPI.APIParams>();
        paramsList.add(params);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockTest('access_token'));
        InterestStatementAPI.getInetrestStatement(paramsList);
        Test.stopTest();
    }
    
    @isTest private static void InterestStatementTestForProvisionalCert(){
        Account account = new Account();
        account.Name = 'Test';
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
        newCase.Service_Request_Type__c = 'Statement & Documents';
        newCase.SR_Sub_Type__c = 'Provisional Interest Statement';
        newCase.IC_From_Date__c = 2022;
        newCase.IC_To_Date__c = 2023;
        insert newCase;
        
        InterestStatementAPI.APIParams params = new InterestStatementAPI.APIParams();
        params.finReference = opportunity.Name;
        params.caseID = newCase.Id;
        params.firstDisbursementDate = opportunity.First_Disbursement_Date__c;
        params.fromYear =  Integer.valueOf(newCase.IC_From_Date__c);
        params.toYear =   Integer.valueOf(newCase.IC_To_Date__c);
        params.type = 'PROVINSTCERTREPORT';
        
        InterestStatementAPI.APIParams[] paramsList = new List<InterestStatementAPI.APIParams>();
        paramsList.add(params);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockTest('access_token'));
        InterestStatementAPI.getInetrestStatement(paramsList);
        Test.stopTest();
    }
}