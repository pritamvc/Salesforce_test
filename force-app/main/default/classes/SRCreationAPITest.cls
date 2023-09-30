@isTest
public class SRCreationAPITest {
    @isTest
    static void testSRCreationTest(){
        Account account = new Account();
        account.Name = 'Test Account';
        account.Phone = '9004731726';
        insert account;
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = account.Id;
        opportunity.name = 'Test Opportunity';
        opportunity.CloseDate = system.today();
        opportunity.StageName = 'Needs Analysis';
        opportunity.Loan_Application_Number__c = '2906202201';
        insert opportunity;
        Co_Applicant__c applicants = new Co_Applicant__c ();
        applicants.Name = 'Test Applicant';
        applicants.Account__c = account.Id;
        applicants.Deal__c = opportunity.Id;
        applicants.Mobile_Number__c ='9004731726'; 
        insert applicants;
        
        String body = '{ "Subject" : "TEST CASE", "SuppliedPhone" : "9004731726", "SuppliedEmail" : "vijay.p@cloudroute.in", "LANNumber" : "2906202201", "Origin" : "Email", "Description" : "Test Description", "Request_Type" : "Service Request", "Service_Request_Type" : "Loan Repayment Related", "SR_Sub_Type" : "Increase EMI Amount (NACH Limit)","Customer_Type":"Existing" }';
        Blob bodyBlod = Blob.valueOf(body);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/SRCreationAPI/*'; //Request URL
        request.httpMethod = 'POST';
        request.requestBody = bodyBlod;
        
        RestContext.request = request;
        RestContext.response = response;
        List<AggregateResult> caseAggregateResult = [SELECT count(id) FROM Case];
        SRCreationAPI.creationOfSR();
        System.assertEquals(1,caseAggregateResult.size());
    }
    
    @isTest
    static void testSRCreationTest1(){
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = account.Id;
        opportunity.name = 'Test Opportunity';
        opportunity.CloseDate = system.today();
        opportunity.StageName = 'Needs Analysis';
        insert opportunity;
        Co_Applicant__c applicants = new Co_Applicant__c ();
        applicants.Name = 'Test Applicant';
        applicants.Account__c = account.Id;
        applicants.Deal__c = opportunity.Id;
        applicants.Mobile_Number__c ='9004731726'; 
        insert applicants;
        
        String body = '{ "Subject" : "TEST CASE", "SuppliedPhone" : "9004731726", "SuppliedEmail" : "vijay.p@cloudroute.in", "Origin" : "Email", "Description" : "Test Description", "Request_Type" : "Service Request", "Service_Request_Type" : "Loan Repayment Related", "SR_Sub_Type" : "Increase EMI Amount (NACH Limit)","Customer_Type":"New" }';
        Blob bodyBlod = Blob.valueOf(body);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/SRCreationAPI/*'; //Request URL
        request.httpMethod = 'POST';
        request.requestBody = bodyBlod;
        
        RestContext.request = request;
        RestContext.response = response;
        SRCreationAPI.creationOfSR();
        
        
    }
    @isTest
    static void testSRCreationTest2(){
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = account.Id;
        opportunity.name = 'Test Opportunity';
        opportunity.CloseDate = system.today();
        opportunity.StageName = 'Needs Analysis';
        opportunity.Loan_Application_Number__c = '2906202201';
        insert opportunity;
        Co_Applicant__c applicants = new Co_Applicant__c ();
        applicants.Name = 'Test Applicant';
        applicants.Account__c = account.Id;
        applicants.Deal__c = opportunity.Id;
        applicants.Mobile_Number__c ='9004731726'; 
        insert applicants;
        
        String body = '{ "Subject" : "TEST CASE", "SuppliedPhone" : "9004731726", "SuppliedEmail" : "vijay.p@cloudroute.in", "LANNumber" : "2906202201", "Origin" : "Email", "Description" : "Test Description", "Request_Type" : "Service Request", "Service_Request_Type" : "Loan Repayment Related", "SR_Sub_Type" : "Increase EMI Amount (NACH Limit) }';
        Blob bodyBlod = Blob.valueOf(body);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/SRCreationAPI/*'; //Request URL
        request.httpMethod = 'POST';
        request.requestBody = bodyBlod;
        
        RestContext.request = request;
        RestContext.response = response;
        SRCreationAPI.creationOfSR();
    }
    
}