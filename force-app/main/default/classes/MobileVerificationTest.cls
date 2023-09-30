@IsTest
public class MobileVerificationTest {
    
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
    public static void testMobileOtpRequest1() {
         Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('Success');
        
        HTTPRequestMock response = new HTTPRequestMock();
        Test.setMock(HttpCalloutMock.class, response);
        
        String email = 'test@example.com';
        // String expectedResponseBody = '{"status":"success"}';
        String mobile = '2342353543';
        String consent ='true';
        Lead lrecrds=TestDataFactory.createLead(true); 
        
        Test.startTest();
        String result = MobileVerification.OtpRequest(mobile,consent,lrecrds.Id);
        Test.stopTest();
        
        
    }
    
    @IsTest
    public static void testMobileOtpverify() {
         Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('Success');
        
        HTTPRequestMock response = new HTTPRequestMock();
        Test.setMock(HttpCalloutMock.class, response);
        
        String email = 'test@example.com';
        // String expectedResponseBody = '{"status":"success"}';
        String mobile = '2342353543';
        String consent ='true';
        String otp = '012012';
        String requestId = '123456';
        Lead lrecrds=TestDataFactory.createLead(true);
        
        Test.startTest();
        String result = MobileVerification.OtpVerify(otp,requestId,lrecrds.Id);
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
         mockResponse.setBody('{"dataResponse":{"result":{"message":"Otp has been sent to your mobile number"},"status-code":"101","request_id":"0000000000"},"message":"Request Completed Successfully.","transactionid":"mobileAuthOtp812","status":"Success","statusCode":101}');
        
        
        HTTPRequestMock response = new HTTPRequestMock();
        
        // Call the method being tested
        Test.startTest();
        MobileVerification.createErrorLogRecord(LeadObj.Id, testRequest, mockResponse.getBody());
        Test.stopTest();
    }   
}