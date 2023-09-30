/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-24-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@IsTest
public class DealAssignmentFromBranchAndRegionTest {
   @TestSetup
    static void setupTestData() {
        // Create test UserRole record
        UserRole testParentRoleID = new UserRole(
            Name = 'Test Parent Role' );
        insert testParentRoleID;
        UserRole managerRole = new UserRole(
            Name = CommonConstant.CREDIT_MANAGER ,
            ParentRoleId = [SELECT Id FROM UserRole WHERE Name = 'Test Parent Role' LIMIT 1].Id // Set the appropriate ParentRoleId value
             );
            insert managerRole;
    }
   @IsTest
    public static void testAssignQueue() {
        // Test data setup
        Group testGroup = TestDataFactory.createDealCreditUserGroup(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Account accountRecrds = TestDataFactory.createAccount(true);
        User dealOwner = TestDataFactory.createUserActive(true);
        Opportunity oppRecrds = new Opportunity(
            Name = 'Mangesh',
            Region__c = 'North',
            Service_Branch__c = 'DELHI',
            AccountId = accountRecrds.Id,
            CloseDate = System.today(),
            StageName = 'Credit Assessment',
            LOS_Id__c = 'LOS-00000000009028478-PROCESS',
            LOS_Sync__c = true,
            Folder_Index__c = 1234,
            Stage_Owner__c = dealOwner.Id
        );

       List<UserRole> managerRoles = [SELECT Id FROM UserRole WHERE Name = :CommonConstant.CREDIT_MANAGER  LIMIT 1];
           
        // Assign the test opportunity
        Test.startTest();
         List<Opportunity> opportunityList = new List<Opportunity>{ oppRecrds };
         DealAssignmentFromBranchAndRegion.assignQueueUpdated(opportunityList);
         DealAssignmentFromBranchAndRegion.assignApproverQueue(opportunityList);
        Test.stopTest();

    }
    @IsTest
    public static void testAssignQueue2() {
        // Test data setup
        Group testGroup = TestDataFactory.createDealCreditUserGroup(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Account accountRecrds = TestDataFactory.createAccount(true);
        Opportunity oppRecrds = new Opportunity(
            Name = 'Mangesh',
            Region__c = 'North',
            Service_Branch__c = 'CC DELHI',
            AccountId = accountRecrds.Id,
            CloseDate = System.today(),
            StageName = 'Credit Assessment',
            LOS_Id__c = 'LOS-00000000009028478-PROCESS',
            LOS_Sync__c = true,
            Folder_Index__c = 1234
        );
        User dealOwner = TestDataFactory.createUserActive(true);
        List<UserRole> managerRoles = [SELECT Id FROM UserRole WHERE Name = :CommonConstant.CREDIT_MANAGER  LIMIT 1];
           
        // Assign the test opportunity
        Test.startTest();
         List<Opportunity> opportunityList = new List<Opportunity>{ oppRecrds };
         DealAssignmentFromBranchAndRegion.assignQueueUpdated(opportunityList);
         DealAssignmentFromBranchAndRegion.assignApproverQueue(opportunityList);
        Test.stopTest();
    }

       @IsTest
    public static void testSendEmailDealStageOwner1() {
        // Create test data
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Test.startTest();
        EmailTemplate testEmailTemplate =[select id,Subject,DeveloperName,TemplateType from EmailTemplate limit 1];
        Account accountRecrds =TestDataFactory.createAccount(true);  
        Opportunity oppRecrds = new Opportunity(Stage_Owner__c=userinfo.getUserId(),Credit_User__c=userinfo.getUserId(),Name='Mangesh',AccountId=accountRecrds.Id,CloseDate=System.today(),StageName='Credit Assessment',LOS_Id__c='LOS-00000000009028478-PROCESS',LOS_Sync__c=true,Folder_Index__c=1234);
        insert oppRecrds;
        List<Id> dealList = new List<Id>{ oppRecrds.Id };
        Boolean refereBack = false;
        Boolean reAppeal = false;
        DealAssignmentFromBranchAndRegion.sendEmailDealStageOwner(dealList,refereBack,reAppeal);
        Test.stopTest();
    }
      @IsTest
    public static void testSendEmailDealStageOwner5() {
        // Create test data
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Test.startTest();
        EmailTemplate testEmailTemplate =[select id,Subject,DeveloperName,TemplateType from EmailTemplate limit 1];
        Account accountRecrds =TestDataFactory.createAccount(true);  
        Opportunity oppRecrds = new Opportunity(Credit_User__c=userinfo.getUserId(),Name='Mangesh',AccountId=accountRecrds.Id,CloseDate=System.today(),StageName='Credit Assessment',LOS_Id__c='LOS-00000000009028478-PROCESS',LOS_Sync__c=true,Folder_Index__c=1234);
        insert oppRecrds;
        List<Id> dealList = new List<Id>{ oppRecrds.Id };
        Boolean refereBack = false;
        Boolean reAppeal = true;
        DealAssignmentFromBranchAndRegion.sendEmailDealStageOwner(dealList,refereBack,reAppeal);
        Test.stopTest();
    }
       @IsTest
    public static void testSendEmailDealStageOwner2() {
        // Create test data
       Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Test.startTest();
        EmailTemplate testEmailTemplate =[select id,Subject,DeveloperName,TemplateType from EmailTemplate limit 1];
        Account accountRecrds =TestDataFactory.createAccount(true);  
        Opportunity oppRecrds = new Opportunity(Stage_Owner__c=userinfo.getUserId(),Name='Mangesh',AccountId=accountRecrds.Id,CloseDate=System.today(),StageName='Credit Assessment',LOS_Id__c='LOS-00000000009028478-PROCESS',LOS_Sync__c=true,Folder_Index__c=1234);
        insert oppRecrds;
        List<Id> dealList = new List<Id>{ oppRecrds.Id };
        Boolean refereBack = true;
        Boolean reAppeal = false;
        DealAssignmentFromBranchAndRegion.sendEmailDealStageOwner(dealList,refereBack,reAppeal);
        Test.stopTest();
    }
       @IsTest
    public static void testSendEmailDealStageOwner4() {
        // Create test data
       Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Test.startTest();
        EmailTemplate testEmailTemplate =[select id,Subject,DeveloperName,TemplateType from EmailTemplate limit 1];
       // Lead lrecrds=TestDataFactory.createLead1(true);
        Account accountRecrds =TestDataFactory.createAccount(true);  
        Opportunity oppRecrds = new Opportunity(Stage_Owner__c=userinfo.getUserId(),Name='Mangesh',AccountId=accountRecrds.Id,CloseDate=System.today(),StageName='Credit Assessment',Status__c='Approver',LOS_Id__c='LOS-00000000009028478-PROCESS',LOS_Sync__c=true,Folder_Index__c=1234);
        insert oppRecrds;
        oppRecrds.Status__c = 'WIP';
        oppRecrds.Description='test';
        update oppRecrds;
        List<Id> dealList = new List<Id>{ oppRecrds.Id };
        Boolean refereBack = true;
        Boolean reAppeal = false;
        DealAssignmentFromBranchAndRegion.sendEmailDealStageOwner(dealList,refereBack,reAppeal);
        Test.stopTest();
    }
     @IsTest
    public static void testSendEmailDealStageOwner3() {
        // Create test data
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Test.startTest();
        EmailTemplate testEmailTemplate =[select id,Subject,DeveloperName,TemplateType from EmailTemplate limit 1];
        Account accountRecrds =TestDataFactory.createAccount(true);  
        Opportunity oppRecrds = new Opportunity(Stage_Owner__c=userinfo.getUserId(),Name='Mangesh',AccountId=accountRecrds.Id,CloseDate=System.today(),StageName='Credit Assessment',LOS_Id__c='LOS-00000000009028478-PROCESS',LOS_Sync__c=true,Folder_Index__c=1234);
        insert oppRecrds;
        List<Id> dealList = new List<Id>{ oppRecrds.Id };
        Boolean refereBack = false;
        Boolean reAppeal = true;
        DealAssignmentFromBranchAndRegion.sendEmailDealStageOwner(dealList,refereBack,reAppeal);
        Test.stopTest();
    }
           @IsTest
    public static void testDealAssignmentFromBranchAndRegion() {
        // Create test data
       Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        EmailTemplate testEmailTemplate =[select id,Subject,DeveloperName,TemplateType from EmailTemplate limit 1];
        Account accountRecrds =TestDataFactory.createAccount(true);  
        Opportunity oppRecrds = new Opportunity(Stage_Owner__c=userinfo.getUserId(),Name='Mangesh',AccountId=accountRecrds.Id,CloseDate=System.today(),StageName='Credit Assessment',Status__c = 'New',LOS_Id__c='LOS-00000000009028478-PROCESS',LOS_Sync__c=true,Folder_Index__c=1234);
        insert oppRecrds;
        Test.startTest();
        oppRecrds.Status__c = 'Approver';
        update oppRecrds;
        List<Id> dealList = new List<Id>{ oppRecrds.Id };
        DealAssignmentFromBranchAndRegion.sendEmailDealApproveQueue(dealList);
        Test.stopTest();
    }
   
}