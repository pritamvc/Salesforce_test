@isTest
public class CampaignTriggerHandlerTest {
    @isTest
    static void TestCampaignTriggerHandler(){
        
        try {
            Test.startTest();
            List<Campaign> campaignList = new List<Campaign>();
            String parameterMethod = 'testString';
            Campaign campaignObjectParentMain = TestDataFactory.createCampaignParent(false);
            campaignObjectParentMain.Priority__c=51;
            campaignObjectParentMain.Campaign_logic__c='Status = Prospect && KYC_Consent__c = true || Status = Prospect && KYC_Consent__c = false';
            insert campaignObjectParentMain;
            campaignObjectParentMain.Priority__c=55;
            Update campaignObjectParentMain;
            campaignList.add(campaignObjectParentMain);
            Campaign campaignObjectParent = TestDataFactory.createCampaignParent(true);
            campaignList.add(campaignObjectParent);
            Campaign campaignObjectChild = TestDataFactory.createCampaign(false);
            campaignObjectChild.ParentId=campaignObjectParent.Id;
            insert campaignObjectChild;
            campaignList.add(campaignObjectChild);
            campaignObjectParentMain.Priority__c =52;
            // Update campaignObjectParentMain;
            campaignObjectChild.ParentId = campaignObjectParentMain.Id;
            // Update campaignObjectChild;
            campaignObjectChild.ParentId = campaignObjectParent.Id;
            //   Update campaignObjectChild;
            CampaignTriggerHandler.spaceChecking(parameterMethod);
            CampaignTriggerHandler.avoidDuplicatePriorityOnCampaign(campaignList);
            
            Test.stopTest();
        } catch (Exception e) {
            // Handle the exception or perform any necessary actions
            System.debug('An exception occurred: ' + e.getMessage());
            // You can also throw a custom exception or assert specific conditions
            System.assert(false, 'An exception occurred: ' + e.getMessage());
        }
    }
}