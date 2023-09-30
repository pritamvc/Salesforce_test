@isTest
public class LeadAssignmentFromServiceBranchTest {
    @isTest
    static void TestLeadAssignmentFromServiceBranch1(){
        Test.startTest();
        TestDataFactory.createRoundRobbinCustomSetting();
        List<Lead> assignSalesuser = new List<Lead>();
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        //Group callCenterQueue = TestDataFactory.createCallCenterQueue(false); 
        Lead lrecrds=TestDataFactory.createLead(false);
        lrecrds.Source_Name__c = objSource.Id;
        lrecrds.Status = 'Fresh';
        lrecrds.Status__c = 'New';
        lrecrds.Service_Branch__c = 'PUNE';
        //lrecrds.OwnerId = callCenterQueue.Id;
        insert lrecrds;
        
        lrecrds.Status = 'Sales Processing';
        update lrecrds;
        assignSalesuser.add(lrecrds);
        
        LeadAssignmentFromServiceBranch.assignQueue(assignSalesuser);
        Test.stopTest();
    }
    
    @isTest
    static void TestLeadAssignmentFromServiceBranch2(){
        Test.startTest();
        List<Lead> assignSalesuser = new List<Lead>();
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        //Group callCenterQueue = TestDataFactory.createCallCenterQueue(false); 
        Group createYockets = TestDataFactory.createYocketsGroup(true); 
        Lead lrecrds=TestDataFactory.createLead(false);
        lrecrds.Source_Name__c = objSource.Id;
        lrecrds.Status = 'Fresh';
        lrecrds.Status__c = 'New';
        lrecrds.Service_Branch__c = 'AHMEDABAD';
        lrecrds.Region__c = 'South';
        //lrecrds.OwnerId = callCenterQueue.Id;
        insert lrecrds;
        
        lrecrds.Status = 'Sales Processing';
        update lrecrds;
        assignSalesuser.add(lrecrds);
        
        LeadAssignmentFromServiceBranch.assignQueue(assignSalesuser);
        Test.stopTest();
    }
    
    @isTest
    static void TestLeadAssignmentFromServiceBranch3(){
        Test.startTest();
        List<Lead> assignSalesuser = new List<Lead>();
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        //Group callCenterQueue = TestDataFactory.createCallCenterQueue(false); 
        Lead lrecrds=TestDataFactory.createLead(false);
        lrecrds.Source_Name__c = objSource.Id;
        lrecrds.Status = 'Applying';
        lrecrds.Status__c = 'Active';
        lrecrds.Service_Branch__c = 'PUNE';
        //lrecrds.OwnerId = callCenterQueue.Id;
        insert lrecrds;
        
        lrecrds.Status__c = 'QC - New';
        update lrecrds;
        assignSalesuser.add(lrecrds);
        
        LeadAssignmentFromServiceBranch.assignQueue(assignSalesuser);
        Test.stopTest();
    }
    
    @isTest
    static void TestLeadAssignmentFromServiceBranch4(){
        Test.startTest();
        List<Lead> assignSalesuser = new List<Lead>();
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(false);
        AccountObj.Is_Region_Specific__c = true;
        insert AccountObj;
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        //Group callCenterQueue = TestDataFactory.createCallCenterQueue(false); 
        Group createYockets = TestDataFactory.createYocketsGroup(true); 
        Lead lrecrds=TestDataFactory.createLead(false);
        lrecrds.Source_Name__c = objSource.Id;
        lrecrds.Status = 'Fresh';
        lrecrds.Status__c = 'New';
        lrecrds.Service_Branch__c = 'AHMEDABAD';
        lrecrds.Region__c = 'South';
        //lrecrds.OwnerId = callCenterQueue.Id;
        insert lrecrds;
        
        lrecrds.Status = 'Sales Processing';
        update lrecrds;
        assignSalesuser.add(lrecrds);
        
        LeadAssignmentFromServiceBranch.assignQueue(assignSalesuser);
        Test.stopTest();
    }
    
    @isTest
    static void TestLeadAssignmentFromServiceBranch5(){
        Test.startTest();
        List<Lead> assignSalesuser = new List<Lead>();
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(false);
        AccountObj.Preferred_Partner__c = false;
        insert AccountObj;
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        
        Source__c SourceObject = TestDataFactory.createSource(false);
        SourceObject.Name = 'Inbound';
        SourceObject.Partner_Name__c = null;
        insert SourceObject;
        
        //Group callCenterQueue = TestDataFactory.createCallCenterQueue(false); 
        Group createYockets = TestDataFactory.createYocketsGroup(true); 
        Lead lrecrds=TestDataFactory.createLead(false);
        lrecrds.Source_Name__c = objSource.Id;
        lrecrds.Status = 'Fresh';
        lrecrds.Status__c = 'New';
        lrecrds.Service_Branch__c = 'AHMEDABAD';
        lrecrds.Region__c = 'South';
        //lrecrds.OwnerId = callCenterQueue.Id;
        insert lrecrds;
        
        lrecrds.Status = 'Applying';
        update lrecrds;
        assignSalesuser.add(lrecrds);
        
        LeadAssignmentFromServiceBranch.assignQueue(assignSalesuser);
        LeadAssignmentFromServiceBranch.sendEmailFromEscalate(assignSalesuser);
        Test.stopTest();
    }
    
    @isTest
    static void TestLeadAssignmentFromServiceBranch6(){
        Test.startTest();
        //Create user for MUMBAI ASM
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Manager']; 
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser22@example.com',
            Username = 'testuser22@example.com',
            ProfileId = p.Id,
            Alias = 'tuser',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        Group testQueue = new Group(
            Name = 'MUMBAI ASM1',
            Type = 'Queue'
        );
        insert testQueue;

         GroupMember testGroupMember = new GroupMember(
            GroupId = testQueue.Id,
            UserOrGroupId = testUser.Id
        );
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert testGroupMember;
        }

        List<Lead> assignSalesuser = new List<Lead>();
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(false);
        AccountObj.Preferred_Partner__c = false;
        insert AccountObj;
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        
        Source__c SourceObject = TestDataFactory.createSource(false);
        SourceObject.Name = 'Inbound';
        SourceObject.Partner_Name__c = null;
        insert SourceObject;
        
        //Group callCenterQueue = TestDataFactory.createCallCenterQueue(false); 
        Lead lrecrds=TestDataFactory.createLead(false);
        lrecrds.Source_Name__c = objSource.Id;
        lrecrds.Status = 'Fresh';
        lrecrds.Status__c = 'New';
        lrecrds.Service_Branch__c = 'MUMBAI';
        lrecrds.Region__c = 'South';
        //lrecrds.OwnerId = callCenterQueue.Id;
        insert lrecrds;
        
        lrecrds.Status = 'Sales Processing';
        update lrecrds;
        assignSalesuser.add(lrecrds);
        
        LeadAssignmentFromServiceBranch.assignQueue(assignSalesuser);
        //LeadAssignmentFromServiceBranch.sendEmailFromEscalate(assignSalesuser);
        Test.stopTest();
    }
    
    @isTest
    static void TestLeadAssignmentFromServiceBranch7(){
        Test.startTest();
        List<Lead> assignSalesuser = new List<Lead>();
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(false);
        AccountObj.Preferred_Partner__c = false;
        insert AccountObj;
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        
        Source__c SourceObject = TestDataFactory.createSource(false);
        SourceObject.Name = 'Inbound';
        SourceObject.Partner_Name__c = null;
        insert SourceObject;
        
        //Group callCenterQueue = TestDataFactory.createCallCenterQueue(false); 
        Lead lrecrds=TestDataFactory.createLead(false);
        lrecrds.Source_Name__c = objSource.Id;
        lrecrds.Status = 'Fresh';
        lrecrds.Status__c = 'New';
        lrecrds.Service_Branch__c = 'MUMBAI';
        lrecrds.Region__c = 'South';
        //lrecrds.OwnerId = callCenterQueue.Id;
        insert lrecrds;
        
        lrecrds.Status = 'Suspect';
        update lrecrds;
        assignSalesuser.add(lrecrds);
        
        LeadAssignmentFromServiceBranch.assignQueue(assignSalesuser);
        LeadAssignmentFromServiceBranch.sendEmailFromEscalate(assignSalesuser);
        Test.stopTest();
    }
    
    @isTest
    static void TestLeadAssignmentFromServiceBranch8(){
        Test.startTest();
        TestDataFactory.createRoundRobbinCustomSetting();
        List<Lead> assignSalesuser = new List<Lead>();
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(false);
        AccountObj.Name = 'Test';
        insert AccountObj;
        Group testQueue = new Group(Name='Test West Queue',Type='Queue');
        insert testQueue;
        QueueSobject queueSobject = new QueueSobject(
            QueueId = testQueue.Id,
            SObjectType = 'Lead'
        );
        System.runAs(new User(Id = UserInfo.getUserId())) {
           insert queueSobject;
        }
        User queueUser = new User(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@example.com',
            Alias = 'jdoe',
            Username = 'jdoeqq@example.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id, // Replace 'Standard User' with your desired profile name
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert queueUser;

        // Step 3: Associate the User with the Queue using GroupMember
        GroupMember groupMember = new GroupMember(
            GroupId = testQueue.Id,
            UserOrGroupId = queueUser.Id
        );
        System.runAs(new User(Id = UserInfo.getUserId())) {
           insert groupMember;
        }
        
        
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        //Group callCenterQueue = TestDataFactory.createCallCenterQueue(false); 
        Lead lrecrds=TestDataFactory.createLead(false);
        lrecrds.Source_Name__c = objSource.Id;
        lrecrds.Status = 'Fresh';
        lrecrds.Status__c = 'New';
        lrecrds.Service_Branch__c = 'CC PUNE';
        lrecrds.Region__c = 'West';
        //lrecrds.OwnerId = callCenterQueue.Id;
        insert lrecrds;
        
        lrecrds.Status = 'Sales Processing';
        update lrecrds;
        assignSalesuser.add(lrecrds);
        
        LeadAssignmentFromServiceBranch.assignQueue(assignSalesuser);
        LeadAssignmentFromServiceBranch.assignLoginDeskUser(assignSalesuser);
        
        Test.stopTest();
    }
    
    @isTest
    public static void testExceptionQueue(){
        Test.startTest();
        Group callCenterQueue = new Group(Name='Call Center',Type='Queue');
        insert callCenterQueue;
        QueueSobject queueSobject = new QueueSobject(
            QueueId = callCenterQueue.Id,
            SObjectType = 'Lead'
        );
        System.runAs(new User(Id = UserInfo.getUserId())) {
           insert queueSobject;
        }
        
        List<Lead> assignSalesuser = new List<Lead>();
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        
        Account AccountObj = TestDataFactory.createPartnerAccount2(false);
        AccountObj.Name = 'Test';
        AccountObj.Preferred_Partner__c = false;
        insert AccountObj;
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        Lead lrecrds=TestDataFactory.createLead(false);
        lrecrds.Source_Name__c = objSource.Id;
        lrecrds.Status = 'Fresh';
        lrecrds.Status__c = 'New';
        lrecrds.Service_Branch__c = 'CC PUNE';
        //lrecrds.OwnerId = callCenterQueue.Id;
        lrecrds.Source_Category__c = 'Partner';
        lrecrds.Source_Name__c = objSource.Id;
        lrecrds.Bulk_Upload__c = true;
        insert lrecrds;
        lrecrds.OwnerId = callCenterQueue.Id; 
        update lrecrds;
        lrecrds.Status = 'Sales Processing';
        lrecrds.Status__c = 'New';
        List<Lead> testException = new List<Lead>();
        testException.add(lrecrds);
        LeadAssignmentFromServiceBranch.assignQueue(testException);
        //update lrecrds;
        //assignSalesuser.add(lrecrds);
        Test.stopTest();
    }

    @isTest
    static void testAssignUserRegionWise() {
        // Create test data
        Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
		Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        List<String> queueNames = new List<String>{'Queue1', 'Queue2'};
        List<Group> queues = new List<Group>();
        for (String queueName : queueNames) {
            Group queue = new Group(Name = queueName, Type = CommonConstant.QUEUE);
            queues.add(queue);
        }
        insert queues;

        List<User> users = new List<User>();
        for (Integer i = 0; i < 5; i++) {
            User u = new User(Username = 'uuser' + i + '@example.com', Email = 'user' + i + '@example.com',FirstName = 'Test',LastName = 'Test'+i,
                              Alias = 'test'+i,ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id, TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US');
            users.add(u);
        }
        insert users;

        List<GroupMember> groupMembers = new List<GroupMember>();
        for (Group queue : queues) {
            for (User user : users) {
                GroupMember member = new GroupMember(UserOrGroupId = user.Id, GroupId = queue.Id);
                groupMembers.add(member);
            }
        }
        System.runAs(new User(Id = UserInfo.getUserId())) {
           insert groupMembers;
        }
        

        Map<String, Lead> updatedLeads = new Map<String, Lead>();
        for (Integer i = 0; i < 10; i++) {
            Lead lead = new Lead(
                FirstName = 'Lead' + i,
                LastName = 'Test',
                Status = 'Fresh',
                Company = 'Test Company',
                Email='testtest'+i+'@gmail.com',
				MobilePhone='963214253'+i,Source_Category__c='Partner',Source_Name__c=objSource.Id,Product_Category__c='HEL - INDIA'
            );
            // Assuming you have the appropriate key-value relationship for updatedLeads
            updatedLeads.put('Queue' + Math.mod(i, queueNames.size()), lead);
        }
        insert updatedLeads.values();

        // Call the method to be tested
        
        LeadAssignmentFromServiceBranch.assignUserRegionWise(updatedLeads, queueNames);
        Test.stopTest();
    }
}