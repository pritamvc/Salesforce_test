@isTest
public class PaymentChargesAPITest {
    @isTest
    static void paymentChargesTest(){
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
        opportunity.StageName = 'login';
        opportunity.CloseDate = System.today();
        opportunity.Service_Branch__c = 'MUMBAI';
        opportunity.Loan_Application_Number__c = '2906202201';
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
        newCase.Collateral_Swap_Charges__c = 500;
        newCase.NACH_Swap_charges__c = 500;
        newCase.FC_Statement_Charge__c = 500;
        newCase.Document_Handling_Fees__c = 500;
        newCase.Balance_Due_for_Forclosure__c = 500;
        insert newCase;
        
        String body ='{"caseId":"'+newCase.Id+'"}';         
        Blob bodyBlod = Blob.valueOf(body);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/PaymentChargesAPI/*'; //Request URL
        request.httpMethod = 'POST';
        request.requestBody = bodyBlod;
        
        RestContext.request = request;
        RestContext.response = response;
        PaymentChargesAPI.calculateCharges();
        
        // Added these lines to cover CaseTriggerHandler
        newCase.Sales_Approval_Decision__c = 'Approved';
        update newCase;
        
        newCase.Status = 'In Progress';
        newCase.Sub_Status__c = 'Pending with operations';
        update newCase;
        
        newCase.Status = 'Closed';
        newCase.Sub_Status__c = '';
        newCase.Close_Comment__c = 't';
        update newCase;

    }
    
    @isTest
    static void paymentChargesTest1(){
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
        opportunity.StageName = 'login';
        opportunity.CloseDate = System.today();
        opportunity.Service_Branch__c = 'MUMBAI';
        opportunity.Loan_Application_Number__c = '2906202201';
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
        newCase.SR_Sub_Type__c = 'Amortization schedule';
        newCase.Collateral_Swap_Charges__c = 500;
        newCase.NACH_Swap_charges__c = 500;
        newCase.FC_Statement_Charge__c = 500;
        newCase.Document_Handling_Fees__c = 500;
        newCase.Balance_Due_for_Forclosure__c = 500;
        insert newCase;
        
        String body ='{""}';         
        Blob bodyBlod = Blob.valueOf(body);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/PaymentChargesAPI/*'; //Request URL
        request.httpMethod = 'POST';
        request.requestBody = bodyBlod;
        
        RestContext.request = request;
        RestContext.response = response;
        PaymentChargesAPI.calculateCharges();
        
        
       
        
    }
}