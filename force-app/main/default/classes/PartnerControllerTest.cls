@IsTest
global class PartnerControllerTest {
    @IsTest
    public static void GetStatusOfLeadTest() {
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        List<Lead> testLeads = new List<Lead>();       
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        String leadB2CRecordType = TestDataFactory.getRecordTypeIdLeadB2C();        
        
        List<Partner_Get_API_Response_Field_Mapping__mdt> mappingData = new List<Partner_Get_API_Response_Field_Mapping__mdt>();
        Partner_Get_API_Response_Field_Mapping__mdt mappingRecord = new Partner_Get_API_Response_Field_Mapping__mdt();
        mappingRecord.Field_API_Name__c = 'FirstName';
        mappingData.add(mappingRecord);
        
        Lead lrecrds1 = TestDataFactory.createLeadPartner(false);        
        lrecrds1.Status = 'Fresh';        
        if (objSource != null) {
            lrecrds1.Source_Name__c = objSource.Id;
        }        
        lrecrds1.RecordTypeId = leadB2CRecordType;        
        if (lrecrds1.Source_Name__r != null && lrecrds1.Source_Name__r.Partner_Name__r != null) {
            lrecrds1.Source_Name__r.Partner_Name__r.Partner_Code__c = 'ACCRM0015';
        }        
        testLeads.add(lrecrds1);
        insert testLeads;
        System.debug('lrecrds1.Source_Name__r.Partner_Name__r.Partner_Code__c:' + lrecrds1.Source_Name__r.Partner_Name__r.Partner_Code__c);
        System.debug('testLeads:' + testLeads);
        
        /// Load test data for Lead_status__mdt
        List<Lead_status__mdt> leadStatusData = new List<Lead_status__mdt>();
        Lead_status__mdt statusRecord = new Lead_status__mdt();
        statusRecord.Status__c = lrecrds1.Status;
        statusRecord.PartnerStatus__c = 'Fresh';
        leadStatusData.add(statusRecord);
        
        // Call the method under test
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/partner/lead/';
        request.addParameter('emailId', lrecrds1.Email);
        request.addParameter('mobileNO', lrecrds1.MobilePhone);
        request.addParameter('partnerId', 'ACCRM0015');
        RestContext.request = request;
        
        RestResponse response = new RestResponse();
        RestContext.response = response;
        
        PartnerController.getStatusOfLead();
        
        Test.stopTest();
        
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(response.responseBody.toString());     
    }
    
    @isTest
    public static void GetStatusOfLeadWithoutSourceTest() {
        
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/partner/lead/';
        request.addParameter('emailId', 'test@email.com');
        request.addParameter('mobileNO', '9658235236');
        request.addParameter('partnerId', 'ACCRM0015');
        RestContext.request = request;
        
        RestResponse response = new RestResponse();
        RestContext.response = response;
        
        PartnerController.getStatusOfLead();        
        Test.stopTest();
    }
    @isTest
    public static void GetStatusOfLeadEmail() {
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/partner/lead/';
        request.addParameter('emailId', 'test@email.com');
        request.addParameter('mobileNO', '');
        request.addParameter('partnerId', 'ACCRM0015');
        RestContext.request = request;
        
        RestResponse response = new RestResponse();
        RestContext.response = response;
        
        PartnerController.getStatusOfLead();        
        Test.stopTest();
    }
    @isTest
    public static void GetStatusOfLeadPhone() {
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/partner/lead/';
        request.addParameter('emailId', '');
        request.addParameter('mobileNO', '1234567890');
        request.addParameter('partnerId', 'ACCRM0015');
        RestContext.request = request;
        
        RestResponse response = new RestResponse();
        RestContext.response = response;
        
        PartnerController.getStatusOfLead();        
        Test.stopTest();
    }
    @IsTest
    public static void CreateLeadTest() {
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        List<Lead> testLeads = new List<Lead>();
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        String leadB2CRecordType = TestDataFactory.getRecordTypeIdLeadB2C();
        
        Lead lrecrds1 = TestDataFactory.createLeadPartner(false);        
        lrecrds1.Status = 'Fresh';        
        if (objSource != null) {
            lrecrds1.Source_Name__c = objSource.Id;
        }        
        lrecrds1.RecordTypeId = leadB2CRecordType;        
        if (lrecrds1.Source_Name__r != null && lrecrds1.Source_Name__r.Partner_Name__r != null) {
            lrecrds1.Source_Name__r.Partner_Name__r.Partner_Code__c = 'ACCRM0015';
        }        
        testLeads.add(lrecrds1);
        insert testLeads;        
        
        // Prepare the request body
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('FirstName', 'Johnss');
        requestBody.put('Email', 'testss@example.com');
        requestBody.put('MobilePhone', '1234567770');
        requestBody.put('UserName', 'testUsers');
        requestBody.put('PartnerId', 'ACCRM0015');
        requestBody.put('SourceId', '');
        
        String requestBodyJson = JSON.serialize(requestBody);
        
        // Call the method under test
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/partner/lead/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(requestBodyJson);
        RestContext.request = request;
        
        RestResponse response = new RestResponse();
        RestContext.response = response;
        
        PartnerController.createLead();
        Test.stopTest();
        
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(response.responseBody.toString());       
    }
     @IsTest
    public static void CreateLeadInValidJsonTest() {
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        List<Lead> testLeads = new List<Lead>();
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        String leadB2CRecordType = TestDataFactory.getRecordTypeIdLeadB2C();
        
        Lead lrecrds1 = TestDataFactory.createLeadPartner(false);        
        lrecrds1.Status = 'Fresh';        
        if (objSource != null) {
            lrecrds1.Source_Name__c = objSource.Id;
        }        
        lrecrds1.RecordTypeId = leadB2CRecordType;        
        if (lrecrds1.Source_Name__r != null && lrecrds1.Source_Name__r.Partner_Name__r != null) {
            lrecrds1.Source_Name__r.Partner_Name__r.Partner_Code__c = 'ACCRM0015';
        }        
        testLeads.add(lrecrds1);
        insert testLeads;        
        
        // Prepare the request body
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('FirstName', 'Johnss');
        requestBody.put('Email', 'testss@example.com');
        requestBody.put('MobilePhone', '1234567770');
        requestBody.put('UserName', 'testUsers');
        requestBody.put('PartnerId', 'ACCRM0015');
        requestBody.put('SourceId1', '');
        
        String requestBodyJson = JSON.serialize(requestBody);
        
        // Call the method under test
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/partner/lead/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(requestBodyJson);
        RestContext.request = request;
        
        RestResponse response = new RestResponse();
        RestContext.response = response;
        
        PartnerController.createLead();
        Test.stopTest();
        
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(response.responseBody.toString());       
    }
    
    @IsTest
    public static void CreateLeadWithPatnerIdTest() {
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        List<Lead> testLeads = new List<Lead>();
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        String leadB2CRecordType = TestDataFactory.getRecordTypeIdLeadB2C();
        
        Lead lrecrds1 = TestDataFactory.createLeadPartner(false);        
        lrecrds1.Status = 'Fresh';        
        if (objSource != null) {
            lrecrds1.Source_Name__c = objSource.Id;
        }        
        lrecrds1.RecordTypeId = leadB2CRecordType;        
        if (lrecrds1.Source_Name__r != null && lrecrds1.Source_Name__r.Partner_Name__r != null) {
            lrecrds1.Source_Name__r.Partner_Name__r.Partner_Code__c = 'ACCRM0015';
        }        
        testLeads.add(lrecrds1);
        insert testLeads;
        
        // Prepare the request body
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('FirstName', 'Johnsss');
        requestBody.put('Email', 'testsss@example.com');
        requestBody.put('MobilePhone', '1234547770');
        requestBody.put('UserName', 'testUserss');
        requestBody.put('PartnerId', 'ACCRM0015');
        requestBody.put('SourceId', '12345');
        
        String requestBodyJson = JSON.serialize(requestBody);
        
        // Call the method under test
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/partner/lead/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(requestBodyJson);
        RestContext.request = request;
        
        RestResponse response = new RestResponse();
        RestContext.response = response;
        
        PartnerController.createLead();
        Test.stopTest();
        
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(response.responseBody.toString());
    }
    
    @isTest
    public static void GetLeadMappingTest() {
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        List<Lead> testLeads = new List<Lead>();
        Source__c sourceObj =  new Source__c();
        sourceObj.Name = 'XYZ';
        insert sourceObj;
        Lead lrecrds=TestDataFactory.createLead(true);
        lead leadrecrds = new lead();
        leadrecrds.Source_Name__c = sourceObj.Id;
        leadrecrds.LastName = 'JadhavtEST';
        testLeads.add(leadrecrds);
        // Test data setup
        Lead_Fields__mdt mappingRecord = new Lead_Fields__mdt();
        mappingRecord.DeveloperName = 'Field1';
        mappingRecord.FieldAPIName__c = 'FirstName';
        mappingRecord.Label = 'First Name';
        
        //insert mappingRecord;
        
        // Prepare test data
        Map<String, Object> jsonData = new Map<String, Object>();
        jsonData.put('First Name', lrecrds.FirstName);
        jsonData.put('Last Name', lrecrds.LastName);
        jsonData.put('Email', lrecrds.Email);
        
        // Call the method under test
        Test.startTest();
        Lead lead = PartnerController.getLeadMapping(jsonData);
        Test.stopTest();        
    }
    
    @isTest
    static void CheckForValidJsonTest() {
        // Test data setup
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Lead_Fields__mdt mappingRecord = new Lead_Fields__mdt();
        mappingRecord.DeveloperName = 'Field1';
        mappingRecord.FieldAPIName__c = 'FirstName';
        mappingRecord.Label = 'First Name';
        //insert mappingRecord;
        
        // Prepare test data
        Map<String, Object> jsonData = new Map<String, Object>();
        jsonData.put('First Name', 'John');
        jsonData.put('Last Name', 'Doe');
        jsonData.put('Email', 'john@example.com');
        
        // Call the method under test
        Test.startTest();
        String unManagedFields = PartnerController.checkForValidJson(jsonData); // Assuming checkForValidJson method is within LeadMapping class
        Test.stopTest();        
    }    
    
    @isTest
    static void CheckForValidBodyTest() {
        // Prepare test data
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        List<Lead> testLeads = new List<Lead>();
        Source__c sourceObj =  new Source__c();
        sourceObj.Name = 'XYZ';
        insert sourceObj;
        Lead lrecrds=TestDataFactory.createLead(true);
        lead leadrecrds = new lead();
        leadrecrds.Source_Name__c = sourceObj.Id;
        leadrecrds.LastName = 'JadhavtEST';
        testLeads.add(leadrecrds);
        
        Map<String, String> res = new Map<String, String>();
        String partnerId = 'partner123';
        
        // Test case 1: All fields are valid        
        Boolean isValid = PartnerController.checkForValidBody(lrecrds, res, partnerId);        
        
        // Verify the result
        System.assert(isValid);
        System.assertEquals(0, res.size());
        
        // Test case 2: First Name is blank
        lrecrds.FirstName = '';
        isValid = PartnerController.checkForValidBody(lrecrds, res, partnerId);
        
        
        // Verify the result
        System.assert(!isValid);
        System.assertEquals(2, res.size());
        System.assertEquals(CommonConstant.FIRST_NAME_ERROR, res.get('message'));
        
        // Test case 3: First Name is null
        lrecrds.FirstName = null;
        isValid = PartnerController.checkForValidBody(lrecrds, res, partnerId);
        
        // Verify the result
        System.assert(!isValid);
        System.assertEquals(2, res.size());
        System.assertEquals(CommonConstant.FIRST_NAME_ERROR, res.get('message'));
        
        // Test case 4: Last Name is blank
        lrecrds.FirstName = 'John';
        lrecrds.LastName = '';
        isValid = PartnerController.checkForValidBody(lrecrds, res, partnerId);
        
        
        // Verify the result
        System.assert(!isValid);
        System.assertEquals(2, res.size());
        System.assertEquals(CommonConstant.LAST_NAME_ERROR, res.get('message'));
        
        // Test case 5: Last Name is null
        lrecrds.LastName = null;
        isValid = PartnerController.checkForValidBody(lrecrds, res, partnerId);
        
        // Verify the result
        System.assert(!isValid);
        System.assertEquals(2, res.size());
        System.assertEquals(CommonConstant.LAST_NAME_ERROR, res.get('message'));
        
        // Test case 6: Email is blank
        lrecrds.LastName = 'Doe';
        lrecrds.Email = '';
        isValid = PartnerController.checkForValidBody(lrecrds, res, partnerId);
        
        // Verify the result
        System.assert(!isValid);
        System.assertEquals(2, res.size());
        System.assertEquals(CommonConstant.EMAIL_BLANK, res.get('message'));
        
        // Test case 7: Email is null
        lrecrds.Email = null;
        isValid = PartnerController.checkForValidBody(lrecrds, res, partnerId);
        
        // Verify the result
        System.assert(!isValid);
        System.assertEquals(2, res.size());
        System.assertEquals(CommonConstant.EMAIL_BLANK, res.get('message'));
        
        // Test case 8: Email is invalid
        lrecrds.Email = 'invalid-email';
        isValid = PartnerController.checkForValidBody(lrecrds, res, partnerId);
        
        // Verify the result
        System.assert(!isValid);
        System.assertEquals(2, res.size());
        // Test case 9: MobilePhone is blank
        lrecrds.Email = 'john@example.com';
        lrecrds.MobilePhone = '';
        isValid = PartnerController.checkForValidBody(lrecrds, res, partnerId);
        
        // Verify the result
        System.assert(!isValid);
        System.assertEquals(2, res.size());
        System.assertEquals(CommonConstant.MOBILE_BLANK, res.get('message'));
        
        // Test case 10: MobilePhone is null
        lrecrds.MobilePhone = null;
        isValid = PartnerController.checkForValidBody(lrecrds, res, partnerId);
        
        // Verify the result
        System.assert(!isValid);
        System.assertEquals(2, res.size());
        System.assertEquals(CommonConstant.MOBILE_BLANK, res.get('message'));
        
        // Test case 11: MobilePhone is invalid
        lrecrds.MobilePhone = 'invalid-phone';
        isValid = PartnerController.checkForValidBody(lrecrds, res, partnerId);
        
        // Verify the result
        System.assert(!isValid);
        System.assertEquals(2, res.size());
        System.assertEquals(CommonConstant.MOBILE_ERROR, res.get('message'));
    }
    
    @IsTest
    public static void CreateLeadUnmanagedFieldsTest() {
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Dedupe_Management__c customSettingDedupeManagement = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        List<Lead> testLeads = new List<Lead>();
        Account accountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id, Name, Partner_Name__c FROM Source__c WHERE Partner_Name__c = :accountObj.Id];
        String leadB2CRecordType = TestDataFactory.getRecordTypeIdLeadB2C();
        
        Lead lrecrds1 = TestDataFactory.createLeadPartner(false);              
        lrecrds1.Status = 'Fresh';        
        if (objSource != null) {
            lrecrds1.Source_Name__c = objSource.Id;
        }        
        lrecrds1.RecordTypeId = leadB2CRecordType;        
        if (lrecrds1.Source_Name__r != null && lrecrds1.Source_Name__r.Partner_Name__r != null) {
            lrecrds1.Source_Name__r.Partner_Name__r.Partner_Code__c = 'ACCRM0015';
        }        
        testLeads.add(lrecrds1);
        insert testLeads;
        
        // Prepare the request body
        Map<String, Object> requestBodyNotEmpty = new Map<String, Object>();
        requestBodyNotEmpty.put('FirstName', 'Johnss');
        requestBodyNotEmpty.put('Email', 'testss@example.com');
        requestBodyNotEmpty.put('MobilePhone', '1234567770');
        requestBodyNotEmpty.put('UserName', 'testUsers');
        requestBodyNotEmpty.put('PartnerId', 'ACCRM0015');
        requestBodyNotEmpty.put('SourceId', objSource.Id);   
        
        Map<String, Object> requestBodyEmpty = new Map<String, Object>();
        requestBodyEmpty.put('FirstName', '');
        requestBodyEmpty.put('Email', '');
        requestBodyEmpty.put('MobilePhone', '');
        requestBodyEmpty.put('UserName', '');
        requestBodyEmpty.put('PartnerId', '');
        requestBodyEmpty.put('SourceId', '');
        
        Map<String, Object> requestBodyMobEmialNotEmpty = new Map<String, Object>();
        requestBodyMobEmialNotEmpty.put('FirstName', '');
        requestBodyMobEmialNotEmpty.put('Email', 'testsss@example.com');
        requestBodyMobEmialNotEmpty.put('MobilePhone', '1234565470');
        requestBodyMobEmialNotEmpty.put('UserName', '');
        requestBodyMobEmialNotEmpty.put('PartnerId', '');
        requestBodyMobEmialNotEmpty.put('SourceId', '');
        
        String requestBodyJsonNotEmpty = JSON.serialize(requestBodyNotEmpty);
        String requestBodyJsonEmpty = JSON.serialize(requestBodyEmpty);
        String requestBodyJsonMobEmialNotEmpty = JSON.serialize(requestBodyMobEmialNotEmpty);
        
        // Call the method under test - Not Empty Request Body
        Test.startTest();
        RestRequest requestNotEmpty = new RestRequest();
        requestNotEmpty.requestUri = '/services/apexrest/partner/lead/';
        requestNotEmpty.httpMethod = 'POST';
        requestNotEmpty.requestBody = Blob.valueOf(requestBodyJsonNotEmpty);
        RestContext.request = requestNotEmpty;
        
        RestResponse responseNotEmpty = new RestResponse();
        RestContext.response = responseNotEmpty;
        
        PartnerController.createLead();    
        
        Map<String, Object> resultNotEmpty = (Map<String, Object>) JSON.deserializeUntyped(responseNotEmpty.responseBody.toString());
        
        // Call the method under test - Empty Request Body
        
        RestRequest requestEmpty = new RestRequest();
        requestEmpty.requestUri = '/services/apexrest/partner/lead/';
        requestEmpty.httpMethod = 'POST';
        requestEmpty.requestBody = Blob.valueOf(requestBodyJsonEmpty);
        RestContext.request = requestEmpty;
        
        RestResponse responseEmpty = new RestResponse();
        RestContext.response = responseEmpty;
        
        PartnerController.createLead();   
        
        Map<String, Object> resultEmpty = (Map<String, Object>) JSON.deserializeUntyped(responseEmpty.responseBody.toString());     
        Test.stopTest();
    }
   
    @IsTest
    public static void CreateLeadTest2() {
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        List<Lead> testLeads = new List<Lead>();
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        String leadB2CRecordType = TestDataFactory.getRecordTypeIdLeadB2C();
        
        Lead lrecrds1 = TestDataFactory.createLeadPartner(false);        
        lrecrds1.Status = 'Fresh';        
        if (objSource != null) {
            lrecrds1.Source_Name__c = objSource.Id;
        }        
        lrecrds1.RecordTypeId = leadB2CRecordType;        
        if (lrecrds1.Source_Name__r != null && lrecrds1.Source_Name__r.Partner_Name__r != null) {
            lrecrds1.Source_Name__r.Partner_Name__r.Partner_Code__c = 'ACCRM0015';
        }        
        testLeads.add(lrecrds1);
        insert testLeads;        
        
        // Prepare the request body
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('FirstName', 'Johnss');
        requestBody.put('LastName', 'Test');
        requestBody.put('Email', 'testss@example.com');
        requestBody.put('MobilePhone', '1234567770');
        requestBody.put('UserName', 'testUsers');
        requestBody.put('PartnerId', 'ACCRM0015');
        requestBody.put('SourceId', '');
        
        String requestBodyJson = JSON.serialize(requestBody);
        
        // Call the method under test
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/partner/lead/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(requestBodyJson);
        RestContext.request = request;
        
        RestResponse response = new RestResponse();
        RestContext.response = response;
        
        PartnerController.createLead();
        Test.stopTest();
        
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(response.responseBody.toString());       
    }
    
    @IsTest
    public static void CreateLeadTest3() {
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        List<Lead> testLeads = new List<Lead>();
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        String leadB2CRecordType = TestDataFactory.getRecordTypeIdLeadB2C();
        User userRec = TestDataFactory.createUser(true);
        Lead lrecrds1 = TestDataFactory.createLeadPartner(false);        
        lrecrds1.Status = 'Fresh';        
        if (objSource != null) {
            lrecrds1.Source_Name__c = objSource.Id;
        }        
        lrecrds1.RecordTypeId = leadB2CRecordType;        
        if (lrecrds1.Source_Name__r != null && lrecrds1.Source_Name__r.Partner_Name__r != null) {
            lrecrds1.Source_Name__r.Partner_Name__r.Partner_Code__c = 'ACCRM0015';
        }        
        testLeads.add(lrecrds1);
        insert testLeads;
       
        // Prepare the request body
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('FirstName', 'Johnss');
        requestBody.put('LastName', 'Test');
        requestBody.put('Email', 'testss@example.com');
        requestBody.put('MobilePhone', '1234567770');
        requestBody.put('UserName', 'johndoeauxilo@example.com');
        requestBody.put('PartnerId', 'ACCRM0015');
        requestBody.put('SourceId', '');
        
        String requestBodyJson = JSON.serialize(requestBody);
         
        
        // Call the method under test
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/partner/lead/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(requestBodyJson);
        RestContext.request = request;
        
        RestResponse response = new RestResponse();
        RestContext.response = response;
        
        PartnerController.createLead();
        Test.stopTest();
        
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(response.responseBody.toString());       
    }
    @IsTest
    public static void CreateLeadNoSUser() {
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        List<Lead> testLeads = new List<Lead>();
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        String leadB2CRecordType = TestDataFactory.getRecordTypeIdLeadB2C();
        User userRec = TestDataFactory.createUser(true);
        Lead lrecrds1 = TestDataFactory.createLeadPartner(false);        
        lrecrds1.Status = 'Fresh';        
        if (objSource != null) {
            lrecrds1.Source_Name__c = objSource.Id;
        }        
        lrecrds1.RecordTypeId = leadB2CRecordType;        
        if (lrecrds1.Source_Name__r != null && lrecrds1.Source_Name__r.Partner_Name__r != null) {
            lrecrds1.Source_Name__r.Partner_Name__r.Partner_Code__c = 'ACCRM0015';
        }        
        testLeads.add(lrecrds1);
        insert testLeads;
       
        // Prepare the request body
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('FirstName', 'Johnss');
        requestBody.put('LastName', 'Test');
        requestBody.put('Email', 'testss@example.com');
        requestBody.put('MobilePhone', '8745754589');
       // requestBody.put('UserName', 'johndoeauxilo@example.com');
        requestBody.put('PartnerId', 'ACCRM0015');
        requestBody.put('SourceId', '');
        
        String requestBodyJson = JSON.serialize(requestBody);
         
        
        // Call the method under test
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/partner/lead/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(requestBodyJson);
        RestContext.request = request;
        
        RestResponse response = new RestResponse();
        RestContext.response = response;
        
        PartnerController.createLead();
        Test.stopTest();
        
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(response.responseBody.toString());       
    }
     @IsTest
    public static void CreateLeadSales() {
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        List<Lead> testLeads = new List<Lead>();
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        String leadB2CRecordType = TestDataFactory.getRecordTypeIdLeadB2C();
        User userRec = TestDataFactory.createUser(true);
        userRec.Service_Branch__c = 'PUNE';
        Lead lrecrds1 = TestDataFactory.createLeadPartner(false);        
        lrecrds1.Status = 'Fresh';        
        if (objSource != null) {
            lrecrds1.Source_Name__c = objSource.Id;
        }        
        lrecrds1.RecordTypeId = leadB2CRecordType;        
        if (lrecrds1.Source_Name__r != null && lrecrds1.Source_Name__r.Partner_Name__r != null) {
            lrecrds1.Source_Name__r.Partner_Name__r.Partner_Code__c = 'ACCRM0015';
        }        
        testLeads.add(lrecrds1);
        insert testLeads;
       
        // Prepare the request body
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('FirstName', 'Johnss');
        requestBody.put('LastName', 'Test');
        requestBody.put('Email', 'testss@example.com');
        requestBody.put('MobilePhone', '1234567770');
        requestBody.put('UserName', 'johndoeauxilo@example.com');
        requestBody.put('PartnerId', 'ACCRM0015');
        requestBody.put('SourceId', '');
        
        String requestBodyJson = JSON.serialize(requestBody);
         
        
        // Call the method under test
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/partner/lead/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(requestBodyJson);
        RestContext.request = request;
        
        RestResponse response = new RestResponse();
        RestContext.response = response;
        
        PartnerController.createLead();
        Test.stopTest();
        
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(response.responseBody.toString());       
    }
    
    @IsTest
    public static void CreateLeadTest4() {
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        List<Lead> testLeads = new List<Lead>();
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        String leadB2CRecordType = TestDataFactory.getRecordTypeIdLeadB2C();
        User userRec = TestDataFactory.createUser(true);
        Lead lrecrds1 = TestDataFactory.createLeadPartner(false);        
        lrecrds1.Status = 'Fresh';        
        if (objSource != null) {
            lrecrds1.Source_Name__c = objSource.Id;
        }        
        lrecrds1.RecordTypeId = leadB2CRecordType;        
        if (lrecrds1.Source_Name__r != null && lrecrds1.Source_Name__r.Partner_Name__r != null) {
            lrecrds1.Source_Name__r.Partner_Name__r.Partner_Code__c = 'ACCRM0015';
        }        
        testLeads.add(lrecrds1);
        insert testLeads;
       
        // Prepare the request body
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('FirstName', 'Johnss');
        requestBody.put('LastName', 'Test');
        requestBody.put('Email', 'testss@example.com');
        requestBody.put('MobilePhone', '1234567770');
        requestBody.put('PartnerId', 'ACCRM0015');
        requestBody.put('SourceId', '');
        
        String requestBodyJson = JSON.serialize(requestBody);
         
        
        // Call the method under test
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/partner/lead/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(requestBodyJson);
        RestContext.request = request;
        
        RestResponse response = new RestResponse();
        RestContext.response = response;
        
        PartnerController.createLead();
        Test.stopTest();
        
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(response.responseBody.toString());       
    }
}