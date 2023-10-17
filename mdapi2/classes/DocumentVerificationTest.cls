@IsTest
public class DocumentVerificationTest {

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse response;
        
        public MockHttpResponseGenerator(HttpResponse response) {
            this.response = response;
        }
        
        public HttpResponse respond(HttpRequest request) {
            return response;
        }
    }
    
    @IsTest
    public static void testPanProfile() {
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true); 
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('Success');
        
        HTTPRequestMock response = new HTTPRequestMock();
        Test.setMock(HttpCalloutMock.class, response);
        
        String pan = 'ABCDE1234F';
        String aadhaarLastFour = '5678';
        String dob = '1996-01-12';
        String name = 'Vaibhav';
        String address = '123 Main City';
        String getContactDetails = 'true';
        String PANStatus = 'Active';
        String consent = 'true';
        
        // Call the method to test
        Test.startTest();
        String result = DocumentVerification.PanProfile(pan, aadhaarLastFour, dob, name, address, getContactDetails, PANStatus, consent);
        Test.stopTest();
      
    }
    
   
    
    @isTest
    static void testAadharVerification() {
        
        // Set up mock response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('Success');
        

         // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        
        // Call the method to be tested
        Test.startTest();
        String result = DocumentVerification.AadharVerification('123456963852','true');
        Test.stopTest();
        
        // Perform assertions
        System.assertEquals('Success', result, 'Expected success response');
    }
    
     @isTest
    static void testDownloadAadhar() {
        
        // Set up mock response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('Success');
        

         // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        
        // Call the method to be tested
        Test.startTest();
        String result = DocumentVerification.DownloadAadhar('012012','123456963852','123456','true');
        Test.stopTest();
        
        // Perform assertions
        System.assertEquals('Success', result, 'Expected success response');
    }
    
   @IsTest
    static void testGetLeadFormWeightage() {
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);   
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        // Create test data
        List<Lead> leadList = new List<Lead>();
        Lead leadRecord = TestDataFactory.createLead(false);
        leadRecord.Lead_form_Weightage__c = 5;
        leadList.add(leadRecord);
        insert leadList;
        
        // Call the method under test
        Decimal weightage = DocumentVerification.getLeadFormWeightage(leadRecord.Id);
        
        // Verify the result
        //System.assertEquals(5, weightage);
}
     @IsTest
    static void testupdateLeadTotalPercentage() {
       Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
       Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);   
        // Create test data
        List<Lead> leadList = new List<Lead>();
        Lead leadRecord = TestDataFactory.createLead(false);
        leadRecord.Lead_form_Weightage__c = 5;
       // leadList.add(leadRecord);
        insert leadRecord;
        // Call the method under test
         Decimal weightage = DocumentVerification.updateLeadTotalPercentage(leadRecord.Id,10,true);
        
        //System.assertEquals(15, weightage);
}
    
     @IsTest
    static void testGetLeadTotalPercentage() {
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);   
        // Create test data
        List<Lead> leadList = new List<Lead>();
        Lead leadRecord = TestDataFactory.createLead(true);
        leadRecord.Lead_form_Weightage__c = 5;
        leadList.add(leadRecord);
        //insert leadList;
        
        // Call the method under test
        Decimal weightage = DocumentVerification.getLeadTotalPercentage(leadRecord.Id);
        
        // Verify the result
        //System.assertEquals(5, weightage);
}
    @IsTest
    static void testGetLeadFileNames() {
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);   
        Lead leadRec= TestDataFactory.createLead(true);
     // Call the method to be tested
        Test.startTest();
        List<String> result = DocumentVerification.getLeadFileNames(leadRec.Id);
        Test.stopTest();
        
    }
    @IsTest
    static void testGetAccountFileNames() {
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);   
        Account accountRec= TestDataFactory.createAccount1(true);
     // Call the method to be tested
        Test.startTest();
        List<String> result = DocumentVerification.getAccountFileNames(accountRec.Id);
        Test.stopTest();
        
    }
    @isTest
    static void testPennyDropAPI() {
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
        DocumentVerification.PannyDrop(BankDetailsobj.Lead__c,BankDetailsobj.Account__c, concent, BankDetailsobj.IFSC_Code__c, BankDetailsobj.Account_Number__c,BankDetailsobj.Deal__c);
        Test.stopTest();       
}
    
       @IsTest
    public static void testSendEmailpnnydrop() {
        // Create test data
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
       //RoundRobinUserCount__c rrRecrds = TestDataFactory.createRoundRobbinCustomSetting();
        Test.startTest();
        EmailTemplate testEmailTemplate =[select id,Subject,DeveloperName,HtmlValue,TemplateType from EmailTemplate where DeveloperName='Penny_Drop_Failed_Email' limit 1];
      //  Lead lrecrds=TestDataFactory.createLead1(true);
        Account accountRecrds =TestDataFactory.createAccount(true);  
        Opportunity oppRecrds = new Opportunity(Stage_Owner__c=userinfo.getUserId(),Credit_User__c=userinfo.getUserId(),Name='Mangesh',AccountId=accountRecrds.Id,CloseDate=System.today(),StageName='Credit Assessment',LOS_Id__c='LOS-00000000009028478-PROCESS',LOS_Sync__c=true,Folder_Index__c=1234);
        insert oppRecrds;
        Id dealId = oppRecrds.Id;
        Id leadId  = oppRecrds.Id;
        string apiName='PennyDrop';
        DocumentVerification.sendMailForFailedPennyDropApi(dealId, apiName,leadId);
        Test.stopTest();
    } 

    
    

   
}