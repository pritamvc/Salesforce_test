@isTest
public class GetIFSCDetailsAPITest {
    @isTest
    public static void getIFSCDetailsTestMethod1(){
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
        newCase.IFSC__c = 'IBKL0497LDC';
        
        insert newCase;
        
        GetIFSCDetailsAPI.APIParams apiParams = new GetIFSCDetailsAPI.APIParams();
        apiParams.caseID = newCase.Id;
        apiParams.IFSC = newCase.IFSC__c;
        
        GetIFSCDetailsAPI.APIParams[] paramsList = new List<GetIFSCDetailsAPI.APIParams>();
        paramsList.add(apiParams);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockTest('access_token'));
        GetIFSCDetailsAPI.getIFSCDetails(paramsList);
        Test.stopTest();
    }
    	@isTest
        public static void getIFSCDetailsTestMethod2(){
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
        newCase.IFSC__c = 'IBKL0497LDC';
        
        insert newCase;
        
        GetIFSCDetailsAPI.APIParams apiParams = new GetIFSCDetailsAPI.APIParams();
        apiParams.caseID = newCase.Id;
        apiParams.IFSC = newCase.IFSC__c;
        
        GetIFSCDetailsAPI.APIParams[] paramsList = new List<GetIFSCDetailsAPI.APIParams>();
        paramsList.add(apiParams);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockTest('GetIFSCDetailsAPI'));
        GetIFSCDetailsAPI.getIFSCDetails(paramsList);
        Test.stopTest();
    }

}