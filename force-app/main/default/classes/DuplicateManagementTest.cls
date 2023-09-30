@isTest
public class DuplicateManagementTest {

    @isTest
    static void DuplicateManagementTest(){
        
       Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];   
        List<Lead> leadList = new List<Lead>();
        List<Opportunity> oppList = new List<Opportunity>();
        User UserActive = TestDataFactory.createUserActive(true);  
        User UserInActive = TestDataFactory.createUserInactive(true);
        List<Lead> leadListTemp = TestDataFactory.createLeadListForBatch(False);
        Map<Id, Id> dupRecordIdvsOwnerd = new Map<Id, Id>();
        User UserObj = TestDataFactory.createUserUserProfile(true);        
        Group salesProcessingQueue = TestDataFactory.createSalesProcessingQueu(false);   
        //insert salesProcessingQueue;
        Group salesProcessingGroup = TestDataFactory.createSalesProcessingGroup(false);  
        insert salesProcessingGroup;
        //GroupMember groupMember = new GroupMember(UserOrGroupId = UserObj.Id, GroupId = salesProcessingGroup.Id);
       // insert groupMember;
        
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
        LeadObjtest4.OwnerId = UserInActive.Id;
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
        
        For(Lead objectLead : leadListTemp){
            objectLead.Source_Name__c = objSource.Id;
            objectLead.ErrorMessage__c = '';
            leadList.add(objectLead);        
        }  
        insert leadList; 
        Opportunity OppRec1 = TestDataFactory.createOpportunityForScheduler(false);
        oppList.add(OppRec1);
        insert oppList;
        
        // Add the code for sendNotificationToLeadOwner
        Set<Id> duplicateSetId = new Set<Id>();
        for (Lead l : leadList) {
            duplicateSetId.add(l.Id);
        }
        
       dupRecordIdvsOwnerd.put(leadList[0].Id, UserObj.Id);
       dupRecordIdvsOwnerd.put(leadList[1].Id, salesProcessingGroup.Id);
        
        Test.startTest();
        DuplicateManagement.leadDuplicate(leadList,leadList[0].Source_Name__c);
       	DuplicateManagement.getDuplicateLead(leadList);          
        DuplicateManagement.sendNotificationToLeadOwner(dupRecordIdvsOwnerd); 
        DuplicateManagement.createTaskRelatedToLead(dupRecordIdvsOwnerd,leadList[0].Source_Name__c);
        Test.stopTest();         
    }
 
}