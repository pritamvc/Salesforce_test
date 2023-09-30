/*********************************************************************************************
* @author          Sohail Solapure
* @description     This ConvertLeadToOpportunityTest test class is written for ConvertLeadToOpportunity class
* @date            21 Feb 2023  
**********************************************************************************************/
@isTest
public with sharing class ConvertLeadToOpportunityTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test UserRole record
        UserRole testParentRole = new UserRole(Name = 'Test Parent Role');
        insert testParentRole;
        
        UserRole managerRole = new UserRole(
            Name = CommonConstant.DETAENTRY_MANAGER,
            ParentRoleId = testParentRole.Id
        );
        insert managerRole;
        
        // Create test Group record
        Group testGroup = new Group(Name = CommonConstant.DATAENTERYQUEUE);
        insert testGroup;
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        // Create test User records
        User testUser1 = new User(UserRoleId = managerRole.Id, Username = 'testuser1@exampleqq.com', LastName = 'TestUser1', Email = 'testuser1@example.com',
                                  Alias = 'tuser1', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = testProfile.Id, LanguageLocaleKey = 'en_US');
        insert testUser1;
        User testUser2 = new User(ManagerId = testUser1.Id,UserRoleId = testParentRole.Id, Username = 'testuser2@exampleqq.com', LastName = 'TestUser2', Email = 'testuser2@example.com',
                                  Alias = 'tuser2', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = testProfile.Id, LanguageLocaleKey = 'en_US');
        insert testUser2;
        
        // Create test GroupMember records
        GroupMember testGroupMember1 = new GroupMember(GroupId = testGroup.Id, UserOrGroupId = testUser1.Id);
        GroupMember testGroupMember2 = new GroupMember(GroupId = testGroup.Id, UserOrGroupId = testUser2.Id);
        insert new List<GroupMember>{testGroupMember1, testGroupMember2};
            }

    testMethod  public static void testConvertLead4(){
        List<LosApiMap__c> losData = TestDataFactory.createLOSMapData();
        List<String> leadIds = new List<String>();
        Triggers_Setup__c ts = new Triggers_Setup__c();
        ts.Name = 'Lead Trigger';
        ts.Trigger_Name__c = 'Lead Trigger';
        ts.Trigger_On__c = true;
        insert ts;
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Opportunity opp = TestDataFactory.createOpportunityForScheduler(true);
        leadIds.add(opp.Lead__c);
        TestDataFactory.createSuccessTracker(opp);
        TestDataFactory.createFailErrorLog(opp);
        
        Test.startTest();
        List<Opportunity> oppData = SchedulerForDataTransferAPICalling.getOpportunityList(leadIds);
        HTTPRequestMock response = new HTTPRequestMock();
        Test.setMock(HttpCalloutMock.class, response);
        LosUtils.sendMailForFailedLosApi(opp,'Test Error Log');
        Test.stopTest();
    }
    
    testMethod  public static void testConvertLead5(){
        // Create test data
        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity');
        testOpportunity.StageName = System.Label.Opportunity_Stage_Lead_Convert ;
        testOpportunity.CloseDate = System.today();
        insert testOpportunity;
        // Create an instance of the batch class
        BatchForDataTransferAPICalling batch = new BatchForDataTransferAPICalling('API Name', testOpportunity);
        // Start the batch
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();
        // Perform assertions
        System.assertEquals(1, [SELECT Count() FROM AsyncApexJob WHERE JobType = 'BatchApex']);
        
    }
    
    @isTest
    static void testPopulateEmploymentData() {
        // Create test data
        List<Map<String, Object>> payloadList = new List<Map<String, Object>>();
        Map<String, Object> payload1 = new Map<String, Object>();
        payload1.put(LOSConstants.OCCUPATION_TYPE, 'Employee');
        payload1.put('Field1', 'Value1');
        payloadList.add(payload1);
        
        Map<String, Object> payload2 = new Map<String, Object>();
        payload2.put(LOSConstants.OCCUPATION_TYPE, 'Contractor');
        payload2.put('Field2', 'Value2');
        payloadList.add(payload2);
        
        String losMappingId = 'LosMappingIdValue';
        
        // Create test records for LosApiMap__c
        List<LosApiMap__c> mockLosApiMapList = new List<LosApiMap__c>();
        LosApiMap__c losApiMap1 = new LosApiMap__c();
        losApiMap1.LosLable__c = 'Field1';
        mockLosApiMapList.add(losApiMap1);
        
        LosApiMap__c losApiMap2 = new LosApiMap__c();
        losApiMap2.LosLable__c = 'Field2';
        mockLosApiMapList.add(losApiMap2);
        
        // Mock the query result
        Test.startTest();   
        // Call the method to be tested
        LOSHTTPUtils.populateEmploymentData(payloadList, losMappingId);
        Test.stopTest();
    }
    
    @isTest
    static void testPopulateAddressData() {
        // Create test data
        List<Map<String, Object>> payloadList = new List<Map<String, Object>>();
        
        Map<String, Object> payload1 = new Map<String, Object>();
        payload1.put(LOSConstants.CURR_IS_IT_CORRESPOND, true);
        payload1.put('Field1', 'Value1');
        payloadList.add(payload1);
        
        Map<String, Object> payload2 = new Map<String, Object>();
        payload2.put(LOSConstants.ADDRESS_TYPE, 'Permanent');
        payload2.put('Field2', 'Value2');
        payloadList.add(payload2);
        
        // Call the method to be tested
        LOSHTTPUtils.populateAddressData(payloadList);
    }
    
    @isTest
    static void schecularLOS(){
        //Create LOS mapping data
        List<LosApiMap__c> losData = TestDataFactory.createLOSMapData();
        Triggers_Setup__c ts = new Triggers_Setup__c();
        ts.Name = 'Lead Trigger';
        ts.Trigger_Name__c = 'Lead Trigger';
        ts.Trigger_On__c = true;
        insert ts;
        User dealOwner = TestDataFactory.createUserActive(true);
        User uu = [select id from User where LastName = 'TestUser2'];
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Lead LeadObj = TestDataFactory.createLead(false);
        LeadObj.Status__c = 'Escalated';
        LeadObj.Stage_Owner__c = dealOwner.Id;
        LeadObj.OwnerId = uu.Id;
        //LeadObj.OwnerId = 
        insert LeadObj;
        Account AccountObj = TestDataFactory.createPersonAccount(True);
        
        //Applicant Record
        Co_Applicant__c coApplicantObj = TestDataFactory.CreateCoApplicant(false);
        coApplicantObj.Lead__c = LeadObj.Id;
        coApplicantObj.Account__c = AccountObj.Id;
        insert coApplicantObj;
        
        //Asset Record for Co-Applicant
        Asset AssetObj1 = TestDataFactory.createAssetRecord(true);
        AssetObj1.Lead__c = LeadObj.Id;
        AssetObj1.AccountId = coApplicantObj.Account__c;
        update AssetObj1;
        
        Opportunity opp = new Opportunity(Name='TestOpp',AccountId=AccountObj.Id,Lead__c=LeadObj.Id,StageName='Data Entry',CloseDate=System.today());
        insert opp;
        LosApiMaster__c apiMaster = [select id,ApiName__c from LosApiMaster__c where ApiName__c = 'movable' limit 1];
        Test.startTest();
        HTTPRequestMock response = new HTTPRequestMock();
        Test.setMock(HttpCalloutMock.class, response);
        SchedularLOSDealDataSync sc=new SchedularLOSDealDataSync(apiMaster,opp,coApplicantObj);
        sc.execute(null);
        Test.stopTest();
    }
    
    @IsTest
    static void testExecuteWithMovableApiNameAndValidCollateral() {
        List<LosApiMap__c> losData = TestDataFactory.createLOSMapData();
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c ts = new Triggers_Setup__c();
        ts.Name = 'Lead Trigger';
        ts.Trigger_Name__c = 'Lead Trigger';
        ts.Trigger_On__c = true;
        insert ts;
        User dealOwner = TestDataFactory.createUserActive(true);
        User uu = [select id from User where LastName = 'TestUser2'];
        Lead LeadObj = TestDataFactory.createLead(false);
        LeadObj.Status__c = 'Escalated';
        LeadObj.Stage_Owner__c = dealOwner.Id;
        LeadObj.OwnerId = uu.Id;
        //LeadObj.OwnerId = 
        insert LeadObj;
        Account AccountObj = TestDataFactory.createPersonAccount(True);
        // Test the execute method when methodName is Movable API Name and a valid collateral exists
        LosApiMaster__c apiMaster = new LosApiMaster__c();
        apiMaster.ApiName__c = LOSConstants.MOVABLE_API_NAME;
        Opportunity opp = new Opportunity(Name='TestOpp',AccountId=AccountObj.Id,Lead__c=LeadObj.Id,StageName='Data Entry',CloseDate=System.today());
        Co_Applicant__c coApp = new Co_Applicant__c();
        // Create test data and mock necessary objects
        
        // Create a test Asset record that meets the conditions in the query
        Asset testAsset = new Asset();
        // Set the required fields and conditions
        testAsset.Collateral_Type__c = 'FD';
        testAsset.Name='FD';
        testAsset.Asset_Value__c = 1000;
        testAsset.AccountId = AccountObj.Id;
        testAsset.Lead__c = opp.Lead__c;
        testAsset.Security_Offered__c = LOSConstants.SECURITY_YES;
        insert testAsset;
        
        Test.startTest();
        HTTPRequestMock response = new HTTPRequestMock();
        Test.setMock(HttpCalloutMock.class, response);
        
        SchedularLOSDealDataSync scheduler = new SchedularLOSDealDataSync(apiMaster, opp, coApp);
        // Set up the necessary mock objects
        
        Test.stopTest();
        
        // Assert the expected results
        // Verify that Database.executeBatch(callToLos, 1) is called
        // Verify the debug statement for when security is not offered is not logged
    }

    testMethod  public static void testConvertLead() {
        
        //Create LOS mapping data
        List<LosApiMap__c> losData = TestDataFactory.createLOSMapData();
        Triggers_Setup__c ts = new Triggers_Setup__c();
        ts.Name = 'Lead Trigger';
        ts.Trigger_Name__c = 'Lead Trigger';
        ts.Trigger_On__c = true;
        insert ts;
        // Opportunity testOpp=TestDataFactory.createOpportunity(true);
        User dealOwner = TestDataFactory.createUserActive(true);
        User uu = [select id from User where LastName = 'TestUser2'];
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Lead LeadObj = TestDataFactory.createLead(false);
        LeadObj.Status__c = 'Escalated';
        LeadObj.Stage_Owner__c = dealOwner.Id;
        LeadObj.OwnerId = uu.Id;
        //LeadObj.OwnerId = 
        insert LeadObj;
        Account AccountObj = TestDataFactory.createPersonAccount(True);
        Document_Checklist_Master__c DocChkMaster = TestDataFactory.createDocumnetChecklistMaster1(True);
        List<Id> myLeads = new  List<Id>();
        List<Lead> leadList = new   List<Lead>();
        leadList.add(LeadObj);
        
        //Applicant Record
        Co_Applicant__c coApplicantObj = TestDataFactory.CreateCoApplicant(false);
        coApplicantObj.Lead__c = LeadObj.Id;
        insert coApplicantObj;
        
        Source__c SourceObject = TestDataFactory.createSource(false);
        SourceObject.Name = 'Inbound';
        SourceObject.Partner_Name__c = null;
        insert SourceObject;
        
        //Co-Applicant Record
        Co_Applicant__c coApplicantObj1 = TestDataFactory.CreateCoApplicantRecord(false);
        coApplicantObj1.Lead__c = LeadObj.Id;
        insert coApplicantObj1;
        
        //Asset Record for Applicant
        Asset AssetObj = TestDataFactory.createAsset(true);
        AssetObj.Lead__c = LeadObj.Id;
        AssetObj.AccountId = AccountObj.Id;
        update AssetObj;
        
        //Asset Record for Co-Applicant
        Asset AssetObj1 = TestDataFactory.createAsset(true);
        AssetObj1.Lead__c = LeadObj.Id;
        AssetObj1.AccountId = coApplicantObj1.Account__c;
        update AssetObj1;
        
        //Asset Record for Co-Applicant
        Asset AssetObj2 = TestDataFactory.createAsset(true);
        AssetObj2.Lead__c = LeadObj.Id;
        AssetObj2.AccountId = coApplicantObj1.Account__c;
        update AssetObj2;
        
        //Education Details Record for Applicant
        Education_Details__c Educationdetailsobj = TestDataFactory.createEducationDetails(true);
        Educationdetailsobj.Lead__c = LeadObj.Id;
        Educationdetailsobj.Account__c = AccountObj.Id;
        update Educationdetailsobj;
        
        //Employment Details Records for Applicant
        Employment_Details__c Employmentdeatilssobj = TestDataFactory.createEmploymentdeatils(true);
        Employmentdeatilssobj.Lead__c = LeadObj.Id;
        Employmentdeatilssobj.Account__c = AccountObj.Id;
        update Employmentdeatilssobj;
        
        //Employment Details Records for Co-Applicant
        Employment_Details__c Employmentdeatilssobj1 = TestDataFactory.createEmploymentdeatils(true);
        Employmentdeatilssobj1.Lead__c = LeadObj.Id;
        Employmentdeatilssobj1.Account__c = coApplicantObj1.Account__c;
        update Employmentdeatilssobj1;
        
        //Liability Record for Applicant
        Liability__c Liabilitysobj = TestDataFactory.createLiability(true);
        Liabilitysobj.Lead__c = LeadObj.Id;
        Liabilitysobj.Account__c = AccountObj.Id;
        update Liabilitysobj;
        
        //Liability Record for Co-Applicant
        Liability__c Liabilitysobj1 = TestDataFactory.createLiability(true);
        Liabilitysobj1.Lead__c = LeadObj.Id;
        Liabilitysobj1.Account__c = coApplicantObj1.Account__c;
        update Liabilitysobj1;
        
        //Demography Record for Applicant
        Demography__c Demographyobj = TestDataFactory.createDemography(true);
        Demographyobj.Lead__c = LeadObj.Id;
        Demographyobj.Account__c = AccountObj.Id;
        update Demographyobj;
        
        //Demography Record for Co-Applicant
        Demography__c Demographyobj1 = TestDataFactory.createDemography(true);
        Demographyobj1.Lead__c = LeadObj.Id;
        Demographyobj1.Account__c = coApplicantObj1.Account__c;
        update Demographyobj1;
        
        //Reference Record for Applicant
        Reference__c Referenceobj = TestDataFactory.createReference(true);
        Referenceobj.Lead__c = LeadObj.Id;
        Referenceobj.Account__c = AccountObj.Id;
        update Referenceobj;
        
        //Reference Record for Co-Applicant
        Reference__c Referenceobj1 = TestDataFactory.createReference(true);
        Referenceobj1.Lead__c = LeadObj.Id;
        Referenceobj1.Account__c = coApplicantObj1.Account__c;
        update Referenceobj1;
        
        //Bank Detail Record for Applicant
        Bank_Details__c  BankDetailsobj = TestDataFactory.createBankDetails(true);
        BankDetailsobj.Lead__c = LeadObj.Id;
        BankDetailsobj.Account__c = AccountObj.Id;
        update BankDetailsobj;
        
        //Bank Detail Record for Co-Applicant
        Bank_Details__c  BankDetailsobj1 = TestDataFactory.createBankDetails(true);
        BankDetailsobj1.Lead__c = LeadObj.Id;
        BankDetailsobj1.Account__c = coApplicantObj1.Account__c;
        update BankDetailsobj1;
        
        for(Lead objLead : leadList){
            myLeads.add(objLead.Id);
        }
        Test.startTest();
        HTTPRequestMock response = new HTTPRequestMock();
        Test.setMock(HttpCalloutMock.class, response);
        ConvertLeadToOpportunity.convertLead(myLeads);
        Opportunity opp = [SELECT Id,Lead__c FROM Opportunity WHERE Lead__c IN:myLeads limit 1];
        opp.AccountId = AccountObj.Id;
        Update opp ;
        try{
            LosApiMaster__c apiMaster = [SELECT Id,ApiName__c from LosApiMaster__c where ApiName__c=:LOSConstants.MOVABLE_API_NAME limit 1];
            SchedularLOSDealDataSync sc = new SchedularLOSDealDataSync(apiMaster,opp,coApplicantObj1);
            sc.execute(null);
        }catch(Exception e){
            
        }
        List<Tracker__c> trackList = TestDataFactory.createSameTracker(opp);
        List<Tracker__c> trackDupList = SchedulerForDataTransferAPICalling.findDuplicateTracker(trackList);
        List<Tracker__c> trackDelList = SchedulerForDataTransferAPICalling.deleteTracker(trackList);
        
        List<String> leadId = new List<String>();
        leadId.add(opp.Lead__c);
        List<Opportunity> oppList = LosUtils.getOportunityListDetails(leadId);
        
        Map<String, Object> data = LosUtils.generateData(opp);
        LosImplementation.callingDataTransferAPI(opp,'test');
        
        TestDataFactory.createTrackerListOpp(opp);
        try{SchedulerForDataTransferAPICalling sc1 = new SchedulerForDataTransferAPICalling(opp.Id);
            sc1.execute(null);}catch(Exception e){}
        Test.stopTest();
    }
    
    testMethod  public static void testConvertLeadMock(){
        Test.startTest();
        //Create LOS mapping data
        List<LosApiMap__c> losData = TestDataFactory.createLOSMapData();
        User dealOwner = TestDataFactory.createUserActive(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c ts = new Triggers_Setup__c();
        ts.Name = 'Lead Trigger';
        ts.Trigger_Name__c = 'Lead Trigger';
        ts.Trigger_On__c = true;
        insert ts;
        Lead LeadObj = TestDataFactory.createLead(false);
        LeadObj.Status__c = 'Escalated';
        LeadObj.Stage_Owner__c = dealOwner.Id;
        insert LeadObj;
        //Co-Applicant Record
        Co_Applicant__c coApplicantObj1 = TestDataFactory.CreateCoApplicantRecord(false);
        coApplicantObj1.Lead__c = LeadObj.Id;
        insert coApplicantObj1;
        Account AccountObj = TestDataFactory.createPersonAccount(True);
        Document_Checklist_Master__c DocChkMaster = TestDataFactory.createDocumnetChecklistMaster1(True);
        List<Id> myLeads = new  List<Id>();
        List<Lead> leadList = new List<Lead>();
        leadList.add(LeadObj);
        
        Source__c SourceObject = TestDataFactory.createSource(false);
        SourceObject.Name = 'Inbound';
        SourceObject.Partner_Name__c = null;
        insert SourceObject;
        
        
        for(Lead objLead : leadList){
            myLeads.add(objLead.Id);
        }
        HTTPRequestMock response = new HTTPRequestMock('createWorkItemFails');
        Test.setMock(HttpCalloutMock.class, response);
        Test.stopTest();
    }
    
    testMethod  public static void testConvertLead2(){
        Test.startTest();
        Triggers_Setup__c ts = new Triggers_Setup__c();
        ts.Name = 'Lead Trigger';
        ts.Trigger_Name__c = 'Lead Trigger';
        ts.Trigger_On__c = true;
        insert ts;
        //Create LOS mapping data
        List<LosApiMap__c> losData = TestDataFactory.createLOSMapData();
        User dealOwner = TestDataFactory.createUserActive(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        
        Lead LeadObj = TestDataFactory.createLead(false);
        LeadObj.Status__c = 'Escalated';
        LeadObj.Stage_Owner__c = LeadObj.Id;
        insert LeadObj;
        //Co-Applicant Record
        Co_Applicant__c coApplicantObj1 = TestDataFactory.CreateCoApplicantRecord(false);
        coApplicantObj1.Lead__c = LeadObj.Id;
        insert coApplicantObj1;
        Account AccountObj = TestDataFactory.createPersonAccount(True);
        Document_Checklist_Master__c DocChkMaster = TestDataFactory.createDocumnetChecklistMaster1(True);
        Source__c SourceObject = TestDataFactory.createSource(false);
        SourceObject.Name = 'Inbound';
        SourceObject.Partner_Name__c = null;
        insert SourceObject;
        
        
        List<Id> myLeads = new  List<Id>();
        List<Lead> leadList = new   List<Lead>();
        leadList.add(LeadObj);
        
        for(Lead objLead : leadList){
            myLeads.add(objLead.Id);
        }
        HTTPRequestMock response = new HTTPRequestMock('createWorkItemFailure');
        Test.setMock(HttpCalloutMock.class, response);
        Test.stopTest();
    }
    
    
    
    
}