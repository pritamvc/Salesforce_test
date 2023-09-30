@IsTest
public class EmailVerificationTest {
    
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
    public static void testOtpRequest1() {
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('Success');
        
        HTTPRequestMock response = new HTTPRequestMock();
        Test.setMock(HttpCalloutMock.class, response);
        
        String email = 'test@example.com';
        Lead lrecrds=TestDataFactory.createLead(true); 
        // String expectedResponseBody = '{"status":"success"}';
        
        Test.startTest();
        String result = EmailVerification.OtpRequest(email, lrecrds.Id);
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testEmailverify() {
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('Success');
        
        HTTPRequestMock response = new HTTPRequestMock();
        Test.setMock(HttpCalloutMock.class, response);
        
        // Set up mock callout
       // Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        String email = 'test@example.com';
        String otp = '012012';
        String requestId = '123456';
        Lead lrecrds=TestDataFactory.createLead(true); 
        // Call the method to be tested
        Test.startTest();
        String result = EmailVerification.verify(otp,requestId,lrecrds.Id );
        Test.stopTest();
    } 
    
     @IsTest
    static void testCreateErrorLogRecord() {
        // Create test data
       Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
       Lead LeadObj = TestDataFactory.createLead(true);
        
        String testRequest = 'Test Request';
        
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"dataResponse":{"result":{"message":"Otp has been sent to your Email"},"status-code":"101","request_id":"0000000000"},"message":"Request Completed Successfully.","transactionid":"test001","status":"Success","statusCode":101}');
        
        HTTPRequestMock response = new HTTPRequestMock();
        
        // Call the method being tested
        Test.startTest();
        EmailVerification.createErrorLogRecord(LeadObj.Id, testRequest, mockResponse.getBody());
        Test.stopTest();
    }
}