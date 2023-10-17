@isTest
public class LeadTriggerHandlerTest {
    @isTest
    static void TestLeadTriggerHandler(){
        Test.startTest();
        User UserObj = TestDataFactory.createUserUserProfile(true);
        User UserObjCallCeterProfile = TestDataFactory.createUserCallCenterProfile(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        system.debug('LeadTriggerHandlerTest objSource=== '+json.serializePretty(objSource));
        List<CampaignMember> campaignMemberList = new List<CampaignMember>();
        Campaign campaignObject = TestDataFactory.createCampaign(false);
        campaignObject.Campaign_logic__c = 'Status = Fresh && KYC_Consent__c = true';
        insert campaignObject;
        Campaign campaignObject2 = TestDataFactory.createCampaign(false);
        campaignObject2.Name = 'Call_Back';
        campaignObject2.Priority__c = 80;
        campaignObject2.Campaign_logic__c = 'Status = Fresh && KYC_Consent__c = true';
        insert campaignObject2;
        Campaign campaignObject2child = TestDataFactory.createCampaign(false);
        campaignObject2child.Name = 'Other';
        campaignObject2child.ParentId =campaignObject2.Id ;
        campaignObject2child.Priority__c = 81;
        campaignObject2child.Campaign_logic__c = 'Status = Fresh && KYC_Consent__c = true';
        insert campaignObject2child;
        Campaign campaignObjectChild = TestDataFactory.createCampaign(false);
        campaignObjectChild.Name = 'Inbound Missed Call';
        campaignObjectChild.ParentId=campaignObject.Id;
        campaignObjectChild.Campaign_logic__c = 'KYC_Consent__c = true';
        insert campaignObjectChild;
        Campaign campaignObjectChildPreferedPartner = TestDataFactory.createCampaign(false);
        campaignObjectChildPreferedPartner.Name = 'Preferred Partner';
        campaignObjectChildPreferedPartner.Priority__c=30;
        campaignObjectChildPreferedPartner.ParentId=campaignObject.Id;
        campaignObjectChildPreferedPartner.Campaign_logic__c = '(Source_Name__r.Partner_Name__r.Name = Gradrigh && Source_Name__r.Partner_Name__r.Preferred_Partner__c = true) || (Source_Name__r.Partner_Name__r.Name = Yocketz && Source_Name__r.Partner_Name__r.Preferred_Partner__c = true)';
        insert campaignObjectChildPreferedPartner;
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        List<Lead> leadList = new List<Lead>();
        Lead LeadObj = TestDataFactory.createLead(False);
        LeadObj.Source_Name__c = objSource.Id;
        insert LeadObj;
        leadList.add(LeadObj);
        Lead LeadObjtest = TestDataFactory.createLead(false);
        LeadObjtest.FirstName = 'Rahul';
        LeadObjtest.LastName = 'Kumar';
        LeadObjtest.Email = 'ranulkumarsyst451@gmail.com';
        LeadObjtest.MobilePhone = '9293651452';
        LeadObjtest.Source_Name__c = objSource.Id;
        insert LeadObjtest;
        leadList.add(LeadObjtest);
        system.debug('LeadTriggerHandlerTest LeadObj=== '+json.serializePretty(LeadObj));
        CampaignMember CampaignMemberObject  = TestDataFactory.createCampaignMember2(false);
        CampaignMemberObject.LeadId =LeadObj.Id;
        CampaignMemberObject.CampaignId=campaignObject.id;
        insert CampaignMemberObject;
        campaignMemberList.add(CampaignMemberObject);
        LeadObj.Status = 'Suspect';
        update LeadObj;
        LeadObj.Status = 'Sales Processing';
        update LeadObj;
        LeadObj.Status = 'Applying';
        update LeadObj;
        leadList.add(LeadObj);
        Lead LeadObj2 = TestDataFactory.createLead(false);
        Lead LeadObj3 = TestDataFactory.createLeadForOpp(false);
        LeadObj3.Status ='Fresh';
        LeadObj3.Source_Name__c = objSource.Id;
        insert LeadObj3;
        leadList.add(LeadObj3);
        List<String> strListValues = new List<String>();
        strListValues.add(campaignObjectChildPreferedPartner.Campaign_logic__c);
        String logicalCondition = campaignObjectChildPreferedPartner.Campaign_logic__c;
        Map<String, Object> leadMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(LeadObj));
        LeadTriggerHandler.campaignAssignmentOnLead(leadList); 
        LeadTriggerHandler.assignMobileNumber(leadList); 
        LeadTriggerHandler.duplicateLeadManagement(leadList); 
        System.runAs(UserObj) {
            LeadTriggerHandler.ownerAssignmentLead(leadList);
        }
        System.runAs(UserObjCallCeterProfile) {
            LeadTriggerHandler.ownerAssignmentLead(leadList);
        }
        LeadTriggerHandler.ownerAssignmentLead(leadList);
        LeadCampaignHandler.campaignAssignmentOnLead(leadList);
        LeadCampaignHandler.campaignAssignmentOnMissedCallDesposition(leadList);
       // LeadCampaignHandler.assignCallBackCampaign(leadList);
        LeadCampaignHandler.campaignAssignmentAndOzontelInteraction(campaignMemberList);
        LeadCampaignHandler.collectFieldValue(strListValues,logicalCondition,leadMap,LeadObj);
        Test.stopTest();
    }
    
    /*
    @isTest
    static void DuplicateManagementTest(){
        
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];   
        List<Lead> leadList = new List<Lead>();
        User UserActive = TestDataFactory.createUserActive(true);  
        User UserInActive = TestDataFactory.createUserInactive(true);
        Group salesProcessingQueue = TestDataFactory.createSalesProcessingQueu(false);        
        Group salesProcessingGroup = TestDataFactory.createSalesProcessingGroup(false);  
        insert salesProcessingGroup;
        Lead LeadObjtest = TestDataFactory.createLeadDup1(false);        
        LeadObjtest.Source_Name__c = objSource.Id;   
        LeadObjtest.Status = 'Fresh';
        LeadObjtest.Status__c = 'New';
        LeadObjtest.OwnerId = UserInActive.Id;
        leadList.add(LeadObjtest);
        
        Lead LeadObjtest2 = TestDataFactory.createLeadDup2(false);       
        LeadObjtest2.Source_Name__c = objSource.Id;   
        LeadObjtest2.Status = 'Fresh';
        LeadObjtest2.Status__c = 'New';
        LeadObjtest2.OwnerId = UserInActive.Id;        
        leadList.add(LeadObjtest2);         
        
        Lead LeadObjtest3 = TestDataFactory.createLeadDup1(false);        
        LeadObjtest3.Source_Name__c = objSource.Id;   
        LeadObjtest3.Status = 'Lost';
        LeadObjtest3.Status__c = 'Not Interested';
        LeadObjtest3.OwnerId = UserInActive.Id;
        leadList.add(LeadObjtest3);
        
        Lead LeadObjtest4 = TestDataFactory.createLeadDup1(false);        
        LeadObjtest4.Source_Name__c = objSource.Id;   
        LeadObjtest4.Status = 'Lost';
        LeadObjtest4.Status__c = 'Not Interested';
        LeadObjtest4.OwnerId = UserActive.Id;
        leadList.add(LeadObjtest4);
        
        Lead LeadObjtest8 = TestDataFactory.createLeadDup1(false);        
        LeadObjtest8.Source_Name__c = objSource.Id;   
        LeadObjtest8.Status = 'Converted';
        LeadObjtest8.IsConverted = true;
        LeadObjtest8.Status__c = 'Push to LOS';
        LeadObjtest8.OwnerId = UserActive.Id;
        LeadObjtest8.ConvertedAccountId = AccountObj.Id;
        leadList.add(LeadObjtest8);
        
        Lead LeadObjtest9 = TestDataFactory.createLeadDup1(false);        
        LeadObjtest9.Source_Name__c = objSource.Id;   
        LeadObjtest9.Status = 'Converted';
        LeadObjtest9.IsConverted = true;
        LeadObjtest9.Status__c = 'Push to LOS';
        LeadObjtest9.OwnerId = UserInActive.Id;
        LeadObjtest9.ConvertedAccountId = AccountObj.Id;
        leadList.add(LeadObjtest9);
        
        insert leadList;  
        
        
        Test.startTest();
        DuplicateManagement.getDuplicateLead(leadList);
        
        // Add the code for sendNotificationToLeadOwner
        Set<Id> duplicateSetId = new Set<Id>();
        for (Lead l : leadList) {
            duplicateSetId.add(l.Id);
        }
        //DuplicateManagement.sendNotificationToLeadOwner(salesProcessingGroup.Id, duplicateSetId);
        DuplicateManagement.leadDuplicate(leadList,leadList[0].Source_Name__c);
        DuplicateManagement.getDuplicateLead(leadList);      
        Test.stopTest();      
    }*/
    
    @isTest
    static void TestcreateBulkLeadsBatchCallFromBulkUpload(){        
        
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];   
        
        List<Lead> leadList = new List<Lead>();
        List<Lead> leadListTemp = TestDataFactory.createLeadListForBatch(False);
        For(Lead objectLead : leadListTemp){
            objectLead.Source_Name__c = objSource.Id;
            objectLead.ErrorMessage__c = '';
            leadList.add(objectLead);        
        }       
        
        insert leadList;             
        Group salesProcessingQueue = TestDataFactory.createSalesProcessingQueu(false);
        
        String jsonString = JSON.serialize(leadList);
        Test.startTest();
        BulkUploadLeadsForPartners.createBulkLeads(jsonString, AccountObj.Id,'SampleCSVFile.csv',TestDataFactory.fieldsString);
        Database.executeBatch(new BulkUploadLeadBatch(leadList,leadList,AccountObj.Id,'SampleCSVFile.csv',TestDataFactory.fieldsString),200); 
        LeadCampaignHandler.campaignAssignmentOnLead(leadList);   
        Test.stopTest();
    }
    
    @isTest
    static void TestOzontelDeteleLeadDetails(){
        Test.startTest();
        User UserObj = TestDataFactory.createUserUserProfile(true);
        User UserObjCallCeterProfile = TestDataFactory.createUserCallCenterProfile(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        system.debug('LeadTriggerHandlerTest objSource=== '+json.serializePretty(objSource));
        List<CampaignMember> campaignMemberList = new List<CampaignMember>();
        Campaign campaignObject = TestDataFactory.createCampaign(false);
        campaignObject.Campaign_logic__c = 'Status = Fresh && KYC_Consent__c = true';
        insert campaignObject;
        Campaign campaignObjectChild = TestDataFactory.createCampaign(false);
        campaignObjectChild.Name = 'Inbound Missed Call';
        campaignObjectChild.ParentId=campaignObject.Id;
        campaignObjectChild.Campaign_logic__c = 'KYC_Consent__c = true';
        insert campaignObjectChild;
        Campaign campaignObjectChildPreferedPartner = TestDataFactory.createCampaign(false);
        campaignObjectChildPreferedPartner.Name = 'Preferred Partner';
        campaignObjectChildPreferedPartner.Priority__c=30;
        campaignObjectChildPreferedPartner.ParentId=campaignObject.Id;
        campaignObjectChildPreferedPartner.Campaign_logic__c = '(Source_Name__r.Partner_Name__r.Name = Gradrigh && Source_Name__r.Partner_Name__r.Preferred_Partner__c = true) || (Source_Name__r.Partner_Name__r.Name = Yocketz && Source_Name__r.Partner_Name__r.Preferred_Partner__c = true)';
        insert campaignObjectChildPreferedPartner;
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        List<Lead> leadList = new List<Lead>();
        Lead LeadObj = TestDataFactory.createLead(False);
        LeadObj.Source_Name__c = objSource.Id;
        insert LeadObj;
        leadList.add(LeadObj);
        Lead LeadObjtest = TestDataFactory.createLead(false);
        LeadObjtest.FirstName = 'Rahul';
        LeadObjtest.LastName = 'Kumar';
        LeadObjtest.Email = 'ranulkumarsyst451@gmail.com';
        LeadObjtest.MobilePhone = '9293651452';
        LeadObjtest.Source_Name__c = objSource.Id;
        insert LeadObjtest;
        leadList.add(LeadObjtest);
        system.debug('LeadTriggerHandlerTest LeadObj=== '+json.serializePretty(LeadObj));
        CampaignMember CampaignMemberObject  = TestDataFactory.createCampaignMember2(false);
        CampaignMemberObject.LeadId =LeadObj.Id;
        CampaignMemberObject.CampaignId=campaignObject.id;
        insert CampaignMemberObject;
        LeadObj.Status = 'Suspect';
        update LeadObj;
        LeadObj.Status = 'Sales Processing';
        update LeadObj;
        LeadObj.Status = 'Applying';
        update LeadObj;
        leadList.add(LeadObj);
        Lead LeadObj2 = TestDataFactory.createLead(false);
        Lead LeadObj3 = TestDataFactory.createLeadForOpp(false);
        LeadObj3.Status ='Fresh';
        LeadObj3.Source_Name__c = objSource.Id;
        insert LeadObj3;
        leadList.add(LeadObj3);
        LeadTriggerHandler.campaignAssignmentOnLead(leadList); 
        LeadTriggerHandler.assignMobileNumber(leadList); 
        LeadTriggerHandler.duplicateLeadManagement(leadList); 
        System.runAs(UserObj) {
            LeadTriggerHandler.ownerAssignmentLead(leadList);
        }
        System.runAs(UserObjCallCeterProfile) {
            LeadTriggerHandler.ownerAssignmentLead(leadList);
        }
        LeadTriggerHandler.ownerAssignmentLead(leadList);
        LeadCampaignHandler.campaignAssignmentOnLead(leadList);
        LeadCampaignHandler.campaignAssignmentOnMissedCallDesposition(leadList);
        Test.stopTest();
    }
    @isTest 
	static void testUpdateCourseEndDate() {
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        List<Lead> leadList = new List<Lead>();
        Lead LeadObj = TestDataFactory.createLead(False);
        system.debug(LeadObj);
        LeadObj.Source_Name__c = objSource.Id;
        // Create a test Lead
        Lead LeadObjtest = TestDataFactory.createLead(false);
        LeadObjtest.FirstName = 'shubham';
        LeadObjtest.LastName = 'Patil';
        LeadObjtest.Email = 'patilshubham451@gmail.com';
        LeadObjtest.MobilePhone = '9293851452';
        LeadObjtest.Source_Name__c = objSource.Id;
        LeadObjtest.Course_Start_Date__c=Date.today();
        LeadObjtest.Course_Duration_Months__c='24';
        insert LeadObjtest;

        // Retrieve the newly created Lead
        Lead insertedLead = [SELECT Id, Course_Start_Date__c, Course_Duration_Months__c FROM Lead WHERE Id = : LeadObjtest.Id];
        // Update the course end date
        LeadTriggerHandler.updateCourseEndDate(new List<Lead>{insertedLead});

        // Verify that the Course_End_Date__c has been updated correctly
        Lead updatedLead = [SELECT Course_End_Date__c FROM Lead WHERE Id = :insertedLead.Id];
    
    }
    
}