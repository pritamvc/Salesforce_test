@isTest
public class BulkUploadLeadsForPartnersTest {
    @isTest
    static void TestcreateBulkLeads(){
        List<Lead> leadList = TestDataFactory.createLeadList(False);
        Account AccountObj = TestDataFactory.createAccount(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);  
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Group salesProcessingQueue = TestDataFactory.createSalesProcessingQueu(false);
        String jsonString = JSON.serialize(leadList);
        Test.startTest();
        BulkUploadLeadsForPartners.getImportLineHeaderFieldMappings();
        BulkUploadLeadsForPartners.createBulkLeads(jsonString, AccountObj.Id,'SampleCSVFile.csv',TestDataFactory.fieldsString);
        Utility.dynamicBulkUploadLeadsCSVTemplate();
        //Utility.setVisibilityOfComponentBasedOnRole();
        Test.stopTest();
    } 
    
    
    @isTest
    static void TestcreateBulkLeadsBatchCall(){
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
        
        // insert  leadList;
        Group salesProcessingQueue = TestDataFactory.createSalesProcessingQueu(false);
        String jsonString = JSON.serialize(leadList);
        Test.startTest();
        BulkUploadLeadsForPartners.createBulkLeads(jsonString, AccountObj.Id,'SampleCSVFile.csv',TestDataFactory.fieldsString);
        Database.executeBatch(new BulkUploadLeadBatch(leadList,leadList,AccountObj.Id,'SampleCSVFile.csv',TestDataFactory.fieldsString),200);  
        Test.stopTest();
    }
    
    @isTest
    static void TestBatchForAssignCampaignToLead(){
        Test.startTest();
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true); 
        Campaign campaignObject = TestDataFactory.createCampaign(false);
        campaignObject.Campaign_logic__c = 'Status = Fresh && KYC_Consent__c = true';
        insert campaignObject;
        Campaign campaignObjectChild = TestDataFactory.createCampaign(false);
        campaignObjectChild.Name = 'Consent Campaign';
        campaignObjectChild.ParentId=campaignObject.Id;
        campaignObjectChild.Campaign_logic__c = 'KYC_Consent__c = true';
        insert campaignObjectChild;
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        List<Lead> leadList = new List<Lead>();
        List<Lead> leadListTemp = TestDataFactory.createLeadListForBatchForAssignCampaignToLead(False);
        For(Lead objectLead : leadListTemp){
            objectLead.Source_Name__c = objSource.Id;
            objectLead.ErrorMessage__c = '';
            objectLead.State = 'Fresh';
            objectLead.KYC_Consent__c = true;
            leadList.add(objectLead);
        }
        
        insert  leadList;
        Test.stopTest();
    }     
    
    @isTest
    static void TestSchedulerForPushLeadsToOzontel(){
        Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);  
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Campaign campaignObject = TestDataFactory.createCampaign(false);
        campaignObject.Campaign_logic__c = 'Status = Fresh && KYC_Consent__c = true';
        insert campaignObject;
        Campaign campaignObjectChild = TestDataFactory.createCampaign(false);
        campaignObjectChild.Name = 'Consent Campaign';
        campaignObjectChild.ParentId=campaignObject.Id;
        campaignObjectChild.Campaign_logic__c = 'KYC_Consent__c = true';
        insert campaignObjectChild;
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        List<Lead> leadList = new List<Lead>();
        List<Lead> leadListTemp = TestDataFactory.createLeadListForBatchForAssignCampaignToLead(False);
        For(Lead objectLead : leadListTemp){
            objectLead.Source_Name__c = objSource.Id;
            objectLead.ErrorMessage__c = '';
            objectLead.State = 'Fresh';
            objectLead.KYC_Consent__c = true;
            leadList.add(objectLead);
        }
        insert  leadList;
        Test.stopTest();
    } 
}