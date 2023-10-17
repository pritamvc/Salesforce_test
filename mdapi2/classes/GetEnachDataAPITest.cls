@isTest
public class GetEnachDataAPITest {
    @isTest
    public static void getEnachDataTestMethodForTry(){
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account account = new Account();
        account.RecordTypeId = recordTypeId;
        account.FirstName='Test FName';
        account.LastName='Test LName';
        account.PersonEmail = 'test123@gmail.com';
        account.Phone = '1234567890';
        insert account;
        
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'Test Opportunity';
        opportunity.AccountId = account.Id;
        opportunity.StageName = 'Loan Closed';
        opportunity.CloseDate = System.today();
        opportunity.Service_Branch__c = 'MUMBAI';
        opportunity.Loan_Application_Number__c = '100219000454';
        opportunity.Loan_Segment__c = 'Education loan';
        opportunity.Product_Category__c = 'Working Executive';
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
        
        insert newCase;
        
        String body = '{ "APPLICATION_NO": "100219000454", "EMAIL_ID": "test123@gmail.com", "MOBILE_NO": "1234567890" }';        
        Blob bodyBlod = Blob.valueOf(body);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/GetEnachDataAPI/*'; //Request URL
        request.httpMethod = 'POST';
        request.requestBody = bodyBlod;
        
        RestContext.request = request;
        RestContext.response = response;
        GetEnachDataAPI.getEnachData();
    }
    @isTest
    public static void getEnachDataTestMethodForException(){
        
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account account = new Account();
        account.RecordTypeId = recordTypeId;
        account.FirstName='Test FName';
        account.LastName='Test LName';
        account.PersonEmail = 'test123@gmail.com';
        account.Phone = '1234567890';
        insert account;
        
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'Test Opportunity';
        opportunity.AccountId = account.Id;
        opportunity.StageName = 'Loan Closed';
        opportunity.CloseDate = System.today();
        opportunity.Service_Branch__c = 'MUMBAI';
        opportunity.Loan_Application_Number__c = '100219000454';
        opportunity.Loan_Segment__c = 'Education loan';
        opportunity.Product_Category__c = 'Working Executive';
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
        
        insert newCase;
        
        String body = '';        
        Blob bodyBlod = Blob.valueOf(body);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/GetEnachDataAPI/*'; //Request URL
        request.httpMethod = 'POST';
        request.requestBody = bodyBlod;
        
        RestContext.request = request;
        RestContext.response = response;
        GetEnachDataAPI.getEnachData();
        
    }
}