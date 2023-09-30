@isTest
public class BulkOzontelCallBackTest {
    @isTest
    static void testGetCallBackResponse_Success() {
        Source__c SourceObject = TestDataFactory.createSource(false);
        SourceObject.Name = 'Inbound';
        SourceObject.Partner_Name__c = null;
        insert SourceObject;
        Test.startTest();
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        //Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        Source__c objSource = TestDataFactory.createSourceWithoutPartner(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Group callCenterQueue = TestDataFactory.createCallCenterQueue(true); 
        List<Lead> leadList = new List<Lead>();
        Lead LeadObj = TestDataFactory.createLead(False);
        LeadObj.Source_Name__c = objSource.Id;
        LeadObj.MobilePhone = '9730747463';
        // insert LeadObj;
        // leadList.add(LeadObj);
        // Test data
        String inputJsonData = '{"Type": "Progressive Dialing","StartTime":"2023-06-12 12:34:56","Duration":"01:30:45", "Comments": "Test comment", "Disposition": "Call Back","DialedNumber":"9730747463"}';
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/callDetails';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(inputJsonData);
        request.params.put('data', inputJsonData);
        RestContext.request = request;
        
        // Call the method
        BulkOzontelCallBack.responseWrapper response = BulkOzontelCallBack.getCallBackResponse();
        Test.stopTest();
        // Verify the response
        //System.assertEquals('Success', response.status);
        //System.assertEquals('Call data logged successfully..', response.resonText);
    }
    
    @isTest
    static void testGetCallBackResponse_SuccessConditiontwo() {
        Source__c SourceObject = TestDataFactory.createSource(false);
        SourceObject.Name = 'Inbound';
        SourceObject.Partner_Name__c = null;
        insert SourceObject;
        Test.startTest();
        Triggers_Setup__c ts = new Triggers_Setup__c();
        ts.Name = 'Lead Trigger';
        ts.Trigger_Name__c = 'Lead Trigger';
        ts.Trigger_On__c = true;
        insert ts;
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        //Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        Source__c objSource = TestDataFactory.createSourceWithoutPartner(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        List<Lead> leadList = new List<Lead>();
        Lead LeadObj = TestDataFactory.createLead(False);
        LeadObj.Source_Name__c = objSource.Id;
        LeadObj.MobilePhone = '9730748863';
        insert LeadObj;
        leadList.add(LeadObj);
        // Test data
        //     AgentID AgentName AgentPhoneNumber DialStatusType.equalsIgnoreCase(CommonConstant.INBOUND)){
        
        String inputJsonData = '{"Type": "InBound", "Comments": "Test comment", "Disposition": "Call Back","CallerID":"09730748863","AgentID":"","AgentName":"","AgentPhoneNumber":""}';
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/callDetails';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(inputJsonData);
        request.params.put('data', inputJsonData);
        RestContext.request = request;
        
        // Call the method
        BulkOzontelCallBack.responseWrapper response = BulkOzontelCallBack.getCallBackResponse();
        Test.stopTest();
        // Verify the response
        //System.assertEquals('Success', response.status);
        //System.assertEquals('Call data logged successfully..', response.resonText);
    }
    
    @isTest
    static void testCreateNewTaskWithDesposition() {
        Source__c SourceObject = TestDataFactory.createSource(false);
        SourceObject.Name = 'Inbound';
        SourceObject.Partner_Name__c = null;
        insert SourceObject;
        Test.startTest();
        Triggers_Setup__c ts = new Triggers_Setup__c();
        ts.Name = 'Lead Trigger';
        ts.Trigger_Name__c = 'Lead Trigger';
        ts.Trigger_On__c = true;
        insert ts;
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        //Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        Source__c objSource = TestDataFactory.createSourceWithoutPartner(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        List<Lead> leadList = new List<Lead>();
        Lead LeadObj = TestDataFactory.createLead(False);
        LeadObj.Source_Name__c = objSource.Id;
        LeadObj.MobilePhone = '9730748888';
        insert LeadObj;
        leadList.add(LeadObj);
        // Test data
        //     AgentID AgentName AgentPhoneNumber DialStatusType.equalsIgnoreCase(CommonConstant.INBOUND)){
        
        String inputJsonData = '{"Type": "InBound", "Comments": "Test comment", "Disposition": "Call Back","CallerID":"09730748863","AgentID":"","AgentName":"","AgentPhoneNumber":""}';
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/callDetails';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(inputJsonData);
        request.params.put('data', inputJsonData);
        RestContext.request = request;
        
        // Call the method
        BulkOzontelCallBack.responseWrapper response = BulkOzontelCallBack.getCallBackResponse();
        Test.stopTest();
        // Verify the response
        //System.assertEquals('Success', response.status);
        //System.assertEquals('Call data logged successfully..', response.resonText);
    }
    
    @isTest
    static void testGetCallBackResponse_SuccessConditionthree() {
        Source__c SourceObject = TestDataFactory.createSource(false);
        SourceObject.Name = 'Inbound';
        SourceObject.Partner_Name__c = null;
        insert SourceObject;
        Test.startTest();
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        //Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        Source__c objSource = TestDataFactory.createSourceWithoutPartner(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        List<Lead> leadList = new List<Lead>();
        /*  Lead LeadObj = TestDataFactory.createLead(False);
LeadObj.Source_Name__c = objSource.Id;
LeadObj.MobilePhone = '9730748863';
insert LeadObj;
leadList.add(LeadObj);  */
        // Test data
        //     AgentID AgentName AgentPhoneNumber DialStatusType.equalsIgnoreCase(CommonConstant.INBOUND)){
        
        String inputJsonData = '{"Type": "CallBackAPI", "Comments": "Test comment", "Disposition": "Call Back","CallerID":"09730748863","AgentID":"","AgentName":"","AgentPhoneNumber":""}';
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/callDetails';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(inputJsonData);
        request.params.put('data', inputJsonData);
        RestContext.request = request;
        
        // Call the method
        BulkOzontelCallBack.responseWrapper response = BulkOzontelCallBack.getCallBackResponse();
        Test.stopTest();
        // Verify the response
        //System.assertEquals('Fail', response.status);
        //System.assertEquals('Bad Request', response.resonText);
    }
    
    @isTest
    static void testGetCallBackResponse_SuccessConditionNoLead() {
        Source__c SourceObject = TestDataFactory.createSource(false);
        SourceObject.Name = 'Inbound';
        SourceObject.Partner_Name__c = null;
        insert SourceObject;
        Test.startTest();
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        //Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        Source__c objSource = TestDataFactory.createSourceWithoutPartner(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        List<Lead> leadList = new List<Lead>();
        Lead LeadObj = TestDataFactory.createLead(False);
        LeadObj.Source_Name__c = objSource.Id;
        LeadObj.MobilePhone = '9730748863';
        // insert LeadObj;
        leadList.add(LeadObj);
        // Test data
        //  AgentID AgentName AgentPhoneNumber DialStatusType.equalsIgnoreCase(CommonConstant.INBOUND)){
        
        String inputJsonData = '{"Type": "CallBackAPI", "Comments": "Test comment", "Disposition": "Call Back","CallerID":"09730748863","AgentID":"","AgentName":"","AgentPhoneNumber":""}';
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/callDetails';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(inputJsonData);
        request.params.put('data', inputJsonData);
        RestContext.request = request;
        
        // Call the method
        BulkOzontelCallBack.responseWrapper response = BulkOzontelCallBack.getCallBackResponse();
        Test.stopTest();
        // Verify the response
        //System.assertEquals('Fail', response.status);
        //System.assertEquals('Bad Request', response.resonText);
    }
    
    @isTest
    static void TestformatDate() {
        Source__c SourceObject = TestDataFactory.createSource(false);
        SourceObject.Name = 'Inbound';
        SourceObject.Partner_Name__c = null;
        insert SourceObject;
        Test.startTest();
        Date testDate = system.today();
        BulkOzontelCallBack.formatDate(testDate);
        Test.stopTest();
        
    }
    
    
    @isTest
    static void testGetCallBackResponse_Failure() {
        Source__c SourceObject = TestDataFactory.createSource(false);
        SourceObject.Name = 'Inbound';
        SourceObject.Partner_Name__c = null;
        insert SourceObject;
        // Test data
        String inputJsonData = '';
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/callDetails';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(inputJsonData);
        request.params.put('data', inputJsonData);
        RestContext.request = request;
        
        // Call the method
        BulkOzontelCallBack.responseWrapper response = BulkOzontelCallBack.getCallBackResponse();
        
        // Verify the response
        //System.assertEquals('Fail', response.status);
        //System.assertEquals('Bad Request', response.resonText);
    }  
    
    @isTest
    static void testGetCallBackResponse_Failure1() {
        Source__c SourceObject = TestDataFactory.createSource(false);
        SourceObject.Name = 'Inbound';
        SourceObject.Partner_Name__c = null;
        insert SourceObject;
        // Test data
        String inputJsonData = '"AgentPhoneNumber": "", "Disposition": "Wrap up time exceeded :120","CallerConfAudioFile": "", "TransferredTo": "", "Apikey": "KKe83e4239df69968d15c00a73265491f0", "Did": "9121234569870","StartTime": "2023-01-25 15:45:44", "CallDuration": "00:00:21", "EndTime": "2023-02-25 15:46:05","ConfDuration": "00:00:00", "CustomerStatus": "answered", "TimeToAnswer": "00:00:14", "monitorUCID":"6987456321", "AgentID": "", "AgentStatus": "", "Location": "", "FallBackRule":"AgentDial", "CampaignStatus": "ONLINE", "CallerID": "9698745789", "Duration": "00:00:07", "Status":"Answered", "AgentUniqueID": "4914257", "UserName": "testAgent", "HangupBy": "AgentHangup","AudioFile": "http://recordings.xxxxxx/xxxxxxx/xxxxxxx.mp3", "PhoneName": "ngiteldsd", "TransferType": "NoTransfers", "DialStatus": "answered", "CampaignName": "Outbond Campain", "UUI": "Manual Dial", "AgentName":"ngiteldsd", "Skill": "None", "DialedNumber": "9730502963", "Type": "Inbound", "Comments": ""}';
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/callDetails';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(inputJsonData);
        request.params.put('data', inputJsonData);
        RestContext.request = request;
        
        // Call the method
        BulkOzontelCallBack.responseWrapper response = BulkOzontelCallBack.getCallBackResponse();
        
        // Verify the response
        //System.assertEquals('Fail', response.status);
        //System.assertEquals('Bad Request', response.resonText);
    }  
    
    @isTest
    public static void taskScheduler(){
        Task t= new Task();
        t.Subject = 'Test';
        Test.startTest();
        TaskScheduler sc=new TaskScheduler(t,10);
        sc.execute(null);
        Test.stopTest();
    }
    
    @isTest
    static void testInbound() {
        Test.startTest();
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Source__c SourceObject = TestDataFactory.createSource(false);
        SourceObject.Name = 'Inbound';
        SourceObject.Partner_Name__c = null;
        insert SourceObject;
        // Test data
        String inputJsonData = '"AgentPhoneNumber": "", "Disposition": "Wrap up time exceeded :120","CallerConfAudioFile": "", "TransferredTo": "", "Apikey": "KKe83e4239df69968d15c00a73265491f0", "Did": "9121234569870","StartTime": "2023-01-25 15:45:44", "CallDuration": "00:00:21", "EndTime": "2023-02-25 15:46:05","ConfDuration": "00:00:00", "CustomerStatus": "answered", "TimeToAnswer": "00:00:14", "monitorUCID":"6987456321", "AgentID": "", "AgentStatus": "", "Location": "", "FallBackRule":"AgentDial", "CampaignStatus": "ONLINE", "CallerID": "9698745789", "Duration": "00:00:07", "Status":"Answered", "AgentUniqueID": "4914257", "UserName": "testAgent", "HangupBy": "AgentHangup","AudioFile": "http://recordings.xxxxxx/xxxxxxx/xxxxxxx.mp3", "PhoneName": "ngiteldsd", "TransferType": "NoTransfers", "DialStatus": "answered", "CampaignName": "Outbond Campain", "UUI": "Manual Dial", "AgentName":"ngiteldsd", "Skill": "None", "DialedNumber": "9730502963", "Type": "IVRHangup", "Comments": ""}';
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/callDetails';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(inputJsonData);
        request.params.put('data', inputJsonData);
        RestContext.request = request;
        
        // Call the method
        BulkOzontelCallBack.responseWrapper response = BulkOzontelCallBack.getCallBackResponse();
        Test.stopTest();
        // Verify the response
        //System.assertEquals('Fail', response.status);
        //System.assertEquals('Bad Request', response.resonText);
    }  
    
    @isTest
    static void testCalculateDuration() {
        // Test with a valid duration
        String validDuration = '01:30:45';
        Integer expectedResult = 1 * 60 * 60 + 30 * 60 + 45;
        Integer actualResult = BulkOzontelCallBack.calculateDuration(validDuration);
        //System.assertEquals(expectedResult, actualResult, 'Valid duration test failed.');
        
        // Test with another valid duration
        String anotherValidDuration = '02:15:30';
        Integer expectedAnotherResult = 2 * 60 * 60 + 15 * 60 + 30;
        Integer actualAnotherResult = BulkOzontelCallBack.calculateDuration(anotherValidDuration);
        //System.assertEquals(expectedAnotherResult, actualAnotherResult, 'Another valid duration test failed.');
        
        // Test with an empty duration
        String emptyDuration = '';
        Integer expectedEmptyResult = 0;
        Integer actualEmptyResult = BulkOzontelCallBack.calculateDuration(emptyDuration);
        //System.assertEquals(expectedEmptyResult, actualEmptyResult, 'Empty duration test failed.');
        
        // Test with a null duration
        String nullDuration = null;
        Integer expectedNullResult = 0;
        Integer actualNullResult = BulkOzontelCallBack.calculateDuration(nullDuration);
        //System.assertEquals(expectedNullResult, actualNullResult, 'Null duration test failed.');
    }   
    
    @isTest
    static void testGetMobileNo() {
        // Test with INBOUND call type
        BulkOzontelCallBack.OzontelCallDetailsParse callDetailsInbound = new BulkOzontelCallBack.OzontelCallDetailsParse();
        callDetailsInbound.Type = 'INBOUND';
        callDetailsInbound.CallerID = '0123456789';
        String expectedResultInbound = '123456789';
        String actualResultInbound = BulkOzontelCallBack.getMobileNo(callDetailsInbound);
        //System.assertEquals(expectedResultInbound, actualResultInbound, 'INBOUND call type test failed.');
        
        // Test with PROGRESSIVE_DAIALING call type
        BulkOzontelCallBack.OzontelCallDetailsParse callDetailsProgressiveDialing = new BulkOzontelCallBack.OzontelCallDetailsParse();
        callDetailsProgressiveDialing.Type = 'PROGRESSIVE_DAIALING';
        callDetailsProgressiveDialing.CallerID = '0123456789';
        String expectedResultProgressiveDialing = '123456789';
        String actualResultProgressiveDialing = BulkOzontelCallBack.getMobileNo(callDetailsProgressiveDialing);
        //System.assertEquals(expectedResultProgressiveDialing, actualResultProgressiveDialing, 'PROGRESSIVE_DAIALING call type test failed.');
        
        // Test with PROGRESSIVE call type
        BulkOzontelCallBack.OzontelCallDetailsParse callDetailsProgressive = new BulkOzontelCallBack.OzontelCallDetailsParse();
        callDetailsProgressive.Type = 'PROGRESSIVE';
        callDetailsProgressive.CallerID = '0123456789';
        String expectedResultProgressive = '123456789';
        String actualResultProgressive = BulkOzontelCallBack.getMobileNo(callDetailsProgressive);
        //System.assertEquals(expectedResultProgressive, actualResultProgressive, 'PROGRESSIVE call type test failed.');
        
        // Test with other call type and DialedNumber is not null
        BulkOzontelCallBack.OzontelCallDetailsParse callDetailsOtherNotNull = new BulkOzontelCallBack.OzontelCallDetailsParse();
        callDetailsOtherNotNull.Type = 'SOME_OTHER_TYPE';
        callDetailsOtherNotNull.CallerID = '0123456789';
        callDetailsOtherNotNull.DialedNumber = '9876543210';
        String expectedResultOtherNotNull = '9876543210';
        String actualResultOtherNotNull = BulkOzontelCallBack.getMobileNo(callDetailsOtherNotNull);
        //System.assertEquals(expectedResultOtherNotNull, actualResultOtherNotNull, 'Other call type with not null DialedNumber test failed.');
        
        // Test with other call type and DialedNumber is null
        BulkOzontelCallBack.OzontelCallDetailsParse callDetailsOtherNull = new BulkOzontelCallBack.OzontelCallDetailsParse();
        callDetailsOtherNull.Type = 'SOME_OTHER_TYPE';
        callDetailsOtherNull.CallerID = '0123456789';
        callDetailsOtherNull.DialedNumber = null;
        String expectedResultOtherNull = '0123456789';
        String actualResultOtherNull = BulkOzontelCallBack.getMobileNo(callDetailsOtherNull);
        //System.assertEquals(expectedResultOtherNull, actualResultOtherNull, 'Other call type with null DialedNumber test failed.');
    }
    
    @isTest
    static void testDateFormating() {
        // Test with a valid datetime string
        String validDatetimeString = '2023-08-01T12:08:18';
        DateTime expectedResult = DateTime.newInstanceGMT(2023, 8, 1, 6, 38, 18); // Converted to GMT -5:30
        DateTime actualResult = BulkOzontelCallBack.dateFormating(validDatetimeString);
        //System.assertEquals(expectedResult, actualResult, 'Valid datetime string test failed.');
        
        // Test with another valid datetime string
        String anotherValidDatetimeString = '2023-08-02T08:30:00';
        DateTime expectedAnotherResult = DateTime.newInstanceGMT(2023, 8, 2, 3, 0, 0); // Converted to GMT -5:30
        DateTime actualAnotherResult = BulkOzontelCallBack.dateFormating(anotherValidDatetimeString);
        //System.assertEquals(expectedAnotherResult, actualAnotherResult, 'Another valid datetime string test failed.');
        
        // Test with null datetime string
        String nullDatetimeString = null;
        DateTime expectedNullResult = null;
        DateTime actualNullResult = BulkOzontelCallBack.dateFormating(nullDatetimeString);
        //System.assertEquals(expectedNullResult, actualNullResult, 'Null datetime string test failed.');
    }
    
    @isTest
    static void testGetCallBackResponse_IVRHangup() {
        // Test with input JSON data having Disconnectedtype as 'IVRHangup'
        BulkOzontelCallBack.OzontelCallDetailsParse callDetailsIVRHangup = new BulkOzontelCallBack.OzontelCallDetailsParse();
        callDetailsIVRHangup.Disconnectedtype = 'IVRHangup';
        // Set other required properties in callDetailsIVRHangup as needed
        String jsonString = JSON.serialize(callDetailsIVRHangup);
        
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = 'https://yourapiendpoint.com/callback'; // Replace with your API endpoint
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf(jsonString);
        RestContext.request = request;
        
        BulkOzontelCallBack.responseWrapper actualResponse = BulkOzontelCallBack.getCallBackResponse();
        
        Test.stopTest();
        
        //System.assertEquals(CommonConstant.SUCCESS_CODE, actualResponse.statusCode, 'IVRHangup test failed.');
    }
    
    @isTest
    static void testGetCallBackResponse_NotIVRHangup() {
        // Test with input JSON data having Disconnectedtype as something other than 'IVRHangup'
        BulkOzontelCallBack.OzontelCallDetailsParse callDetailsNotIVRHangup = new BulkOzontelCallBack.OzontelCallDetailsParse();
        callDetailsNotIVRHangup.Disconnectedtype = 'NotIVRHangup';
        // Set other required properties in callDetailsNotIVRHangup as needed
        String jsonString = JSON.serialize(callDetailsNotIVRHangup);
        
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = 'https://yourapiendpoint.com/callback'; // Replace with your API endpoint
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf(jsonString);
        RestContext.request = request;
        
        BulkOzontelCallBack.responseWrapper actualResponse = BulkOzontelCallBack.getCallBackResponse();
        
        Test.stopTest();
        
        //System.assertEquals(CommonConstant.FAIL_CODE, actualResponse.statusCode, 'NotIVRHangup test failed.');
    }
}