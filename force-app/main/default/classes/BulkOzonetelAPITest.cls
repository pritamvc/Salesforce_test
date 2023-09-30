@isTest
public class BulkOzonetelAPITest {
    @isTest
    static void TestBulkOzonetelAPI(){
        Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        List<CampaignMember> campaignMemberList = new List<CampaignMember>();
        List<Task> newTaskList = new List<Task>();
        Set<Id> setCampaignmemberId = new Set<Id>();
        List<String> campaignId = new List<String>();
        User UserObj = TestDataFactory.createUserUserProfile(true);
        User UserObjCallCeterProfile = TestDataFactory.createUserCallCenterProfile(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        Campaign campaignObject = TestDataFactory.createCampaign(false);
        campaignObject.Campaign_logic__c = 'Status = Fresh && KYC_Consent__c = true';
        campaignObject.IsActive = true;
        insert campaignObject;
        campaignId.add(campaignObject.id);
        Campaign campaignObjectChild = TestDataFactory.createCampaign(false);
        campaignObjectChild.Name = 'Inbound Missed Call';
        campaignObjectChild.ParentId=campaignObject.Id;
        campaignObjectChild.IsActive = true;
        campaignObjectChild.Campaign_logic__c = 'KYC_Consent__c = true';
        insert campaignObjectChild;
        campaignId.add(campaignObjectChild.id);
        Campaign campaignObjectChildPreferedPartner = TestDataFactory.createCampaign(false);
        campaignObjectChildPreferedPartner.Name = 'Preferred Partner';
        campaignObjectChildPreferedPartner.Priority__c=30;
        campaignObjectChildPreferedPartner.ParentId=campaignObject.Id;
        campaignObjectChildPreferedPartner.Campaign_logic__c = 'Source_Name__r.Partner_Name__r.Name = Gradrigh';
        insert campaignObjectChildPreferedPartner;
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        List<Lead> leadList = new List<Lead>();
        Lead LeadObj = TestDataFactory.createLead(False);
        LeadObj.Source_Name__c = objSource.Id;
        LeadObj.MobilePhone = '9293666652';
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
        CampaignMember CampaignMemberObject  = TestDataFactory.createCampaignMember2(false);
        CampaignMemberObject.LeadId =LeadObj.Id;
        CampaignMemberObject.CampaignId=campaignObject.id;
        CampaignMemberObject.Is_Ozontel_Sync__c = false;
        insert CampaignMemberObject;
        setCampaignmemberId.add(CampaignMemberObject.Id);
        campaignMemberList.add(CampaignMemberObject);
        CampaignMember CampaignMemberObjectTwo  = TestDataFactory.createCampaignMember2(false);
        CampaignMemberObjectTwo.LeadId =LeadObjtest.Id;
        CampaignMemberObjectTwo.Is_Ozontel_Sync__c = false;
        CampaignMemberObjectTwo.CampaignId=campaignObject.id;
        insert CampaignMemberObjectTwo;
        Task TaskObj = TestDataFactory.createLeadTask(False);
        TaskObj.WhoId = LeadObj.Id;
        insert TaskObj;
        dateTime callbackDateTime = system.now();
        newTaskList.add(TaskObj);
        Ozontel_API_Configuration_Detail__mdt ozontelApiConfigDetails = TestDataFactory.getOzontelAPIConfigurationDetailmdt();
        String finalEndpoint =ozontelApiConfigDetails.ApiEndPoint__c+'apiKey='+ozontelApiConfigDetails.ApiKey__c+'&userName='+ozontelApiConfigDetails.UserName__c+'&campaignName='+campaignObject.Name+'&'+'phoneNumber='+LeadObj.MobilePhone+'&skill='+''+'&agentId='+''+'&status='+'';     
        String methodType = ozontelApiConfigDetails.RequestMethod__c;
        Integer methodTimeout = Integer.valueOf(ozontelApiConfigDetails.RequestTimeout__c);
        setCampaignmemberId.add(CampaignMemberObjectTwo.Id);
        campaignMemberList.add(CampaignMemberObjectTwo);
        BulkOzonetelAPI.pushDataToOzontel(setCampaignmemberId);
        BulkOzonetelAPI.createMapOfCampNameAndCamMemberId(setCampaignmemberId);
        BulkOzonetelAPI.pushDataToOzontelfotBatch(setCampaignmemberId);
        BulkOzonetelAPI.sendBulkData(String.valueOf(campaignObjectChild.Id));
        BulkOzonetelAPI.scheduleTheJobForRepushToOzonetel(campaignMemberList);
        BulkOzonetelAPI.BulkOzonetelAPIFlow(campaignId);
        BulkOzonetelAPI.callOutWithoutFuture(finalEndpoint,methodType,methodTimeout);
        OzontelCampaignDataSchedule.callOut(finalEndpoint,methodType,methodTimeout);
        Test.stopTest();
    } 
    
    @isTest
    static void TestOzontelCampaignDataSchedule(){
        Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        List<Task> newTaskList = new List<Task>();
        List<CampaignMember> campaignMemberList = new List<CampaignMember>();
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Campaign campaignObject = TestDataFactory.createCampaign(false);
        campaignObject.Campaign_logic__c = 'Status = Fresh && KYC_Consent__c = true';
        insert campaignObject;
        Campaign campaignObjectChild = TestDataFactory.createCampaign(false);
        campaignObjectChild.Name = 'Consent Campaign';
        campaignObjectChild.ParentId=campaignObject.Id;
        campaignObjectChild.Campaign_logic__c = 'KYC_Consent__c = true';
        insert campaignObjectChild;
        Account AccountObj = TestDataFactory.createAccount(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        Lead LeadObj = TestDataFactory.createLead(False);
        LeadObj.Source_Name__c = objSource.Id;
        insert LeadObj;
        CampaignMember CampaignMemberObject  = TestDataFactory.createCampaignMember2(false);
        CampaignMemberObject.LeadId =LeadObj.Id;
        CampaignMemberObject.CampaignId=campaignObject.id;
        insert CampaignMemberObject;
        campaignMemberList.add(CampaignMemberObject);
        Task TaskObj = TestDataFactory.createLeadTask(False);
        TaskObj.WhoId = LeadObj.Id;
        insert TaskObj;
        dateTime callbackDateTime = system.now();
        newTaskList.add(TaskObj);
        Map<Id, Task> taskMap = new Map<Id, Task>();
        taskMap.put(TaskObj.Id,TaskObj);
        OzontelCampaignDataSchedule.ozontelCampaignDataSchedule(newTaskList);
        OzontelCampaignDataSchedule.pushScheduledCallDetailsToOzontel(newTaskList);
        OzontelCampaignDataSchedule.convertDateIstToGMT(String.valueof(callbackDateTime));
        OzontelCampaignDataSchedule.generateFinalEndpointForPushToOzontel(campaignMemberList,taskMap,true);
        Test.stopTest();
    }
    @IsTest
    static void testFormatDate() {
        String testDate = '12/31/2023 12:00:00'; 
        Test.startTest();
        Datetime result = OzontelCampaignDataSchedule.formatDate(testDate);
        Test.stopTest();
        System.assertEquals(DateTime.newInstanceGMT(2023, 12, 31, 12, 0, 0), result);
    }
    
    @isTest
    static void TestOzontelCampaignDataSchedule2(){
        // Create a test campaign
        
        
        Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        List<Task> newTaskList = new List<Task>();
        List<CampaignMember> campaignMemberList = new List<CampaignMember>();
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Campaign campaignObject = TestDataFactory.createCampaign(false);
        campaignObject.Campaign_logic__c = 'Status = Fresh && KYC_Consent__c = true';
        insert campaignObject;
        
        Campaign campaignObjectChild = TestDataFactory.createCampaign(false);
        campaignObjectChild.Name = 'Consent Campaign';
        campaignObjectChild.ParentId=campaignObject.Id;
        campaignObjectChild.Campaign_logic__c = 'KYC_Consent__c = true';
        insert campaignObjectChild;
        Account AccountObj = TestDataFactory.createAccount(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        Lead LeadObj = TestDataFactory.createLead(False);
        LeadObj.Source_Name__c = objSource.Id;
        insert LeadObj;
        CampaignMember CampaignMemberObject  = TestDataFactory.createCampaignMember2(false);
        CampaignMemberObject.LeadId =LeadObj.Id;
        CampaignMemberObject.CampaignId=campaignObject.id;
        insert CampaignMemberObject;
        campaignMemberList.add(CampaignMemberObject);
        Task TaskObj = TestDataFactory.createLeadTask1(false);
        TaskObj.WhoId = LeadObj.Id;
        insert TaskObj;
        dateTime callbackDateTime = system.now();
        newTaskList.add(TaskObj);
        Map<Id, Task> taskMap = new Map<Id, Task>();
        taskMap.put(TaskObj.Id,TaskObj);
        Campaign Campaign = new Campaign();
        Campaign.Name = 'Test Campaign';
        Campaign.IsActive = true;
        Campaign.Priority__c = Math.random();
        insert Campaign;
        // Create a test parent campaign
        Campaign parentCampaign = new Campaign();
        parentCampaign.Name = CommonConstant.CALL_BACK_CAMPAIGN;
        parentCampaign.IsActive = true;
        parentCampaign.Priority__c = Math.random();
        insert parentCampaign;

    	// Create a test child campaign
        Campaign childCampaign = new Campaign();
        childCampaign.Name = CommonConstant.OTHER_CAMPAIGN;
        childCampaign.IsActive = true;
        childCampaign.ParentId = parentCampaign.Id;
        childCampaign.Priority__c = Math.random();
        insert childCampaign;
        //OzontelCampaignDataSchedule.ozontelCampaignDataSchedule(newTaskList);
        OzontelCampaignDataSchedule.pushScheduledCallDetailsToOzontel(newTaskList);
        //OzontelCampaignDataSchedule.convertDateIstToGMT(String.valueof(callbackDateTime));
        //OzontelCampaignDataSchedule.generateFinalEndpointForPushToOzontel(campaignMemberList,taskMap,true);
        Test.stopTest();
    }

    
}