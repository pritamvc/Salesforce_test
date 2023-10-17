/*********************************************************************************************
* @author          Thinqloud Solutions (Chandrakant More)
* @description     This Class called in CampaignTrigger(Trigger),this class used to avoid duplicate priority based on parent and child campaigns.
* @date            17/03/2023    
* @testClass: 
**********************************************************************************************/
public class CampaignTriggerHandler {
    /********************************************************************************************************
* @author          Chandrakant More
* @description     avoidDuplicatePriorityOnCampaign this method is used to avoid duplicate priority based on parent and child campaigns.
* @param           campaignList (List) : used to pass the list of campaign to the method as parameter.
* @return          No-return
* @date            17/03/2023   
********************************************************************************************************/
    public static void avoidDuplicatePriorityOnCampaign(List<Campaign> campaignList){
        // try-Block
        try {
            //Initialize variables
            Set<Decimal> campaignPrioritySet = new Set<Decimal>();
            Set<String> campaignParentIdSet = new Set<String>();            
            Map<String,Campaign> mapParentAndChildCondition = new  Map<String,Campaign>();             
            List<Campaign> existingCampaignsLst = new List<Campaign>();
            
            if(!campaignList.IsEmpty() && campaignList.size() > 0){
                for (Campaign objCampaign : campaignList) {
                    campaignPrioritySet.add(objCampaign.Priority__c);
                    campaignParentIdSet.add(objCampaign.ParentId);
                }            
                
                // get existing campaigns in the system to check duplicate priority
                existingCampaignsLst = [SELECT Id,Name,ParentId,Parent.Name,Priority__c FROM Campaign WHERE ParentId IN :campaignParentIdSet AND Priority__c IN :campaignPrioritySet];
                
                // Iterate over for loop to get map to sagregate parent campaign and child campaign with conditions
                for(Campaign objectCampaign : existingCampaignsLst){
                    if(objectCampaign.ParentId == null){
                        mapParentAndChildCondition.put(string.valueOf(objectCampaign.Priority__c),objectCampaign);
                    } else {
                        mapParentAndChildCondition.put(objectCampaign.ParentId+string.valueof(objectCampaign.Priority__c),objectCampaign);
                    }
                }
                
                for(Campaign objectCampaign : campaignList){
                    if(null != objectCampaign.Campaign_logic__c && objectCampaign.Campaign_logic__c != ''){
                        String logicalCondition = objectCampaign.Campaign_logic__c;
                        Integer logicalConditionMaxSpaces = spaceChecking(logicalCondition);
                        if(logicalConditionMaxSpaces > 0) {
                            objectCampaign.addError(CommonConstant.ERROR_MSG_FOR_CAMPAIGN_LOGICAL_CONDITION);
                        }
                    }
                }
                
                // loop on campaign records to throw an error if duplicate priority value found on Campaign
                if(!mapParentAndChildCondition.IsEmpty() && mapParentAndChildCondition.size() > 0){
                    for(Campaign objCampaign  : campaignList){
                        if(objCampaign.ParentId == null){
                            if (mapParentAndChildCondition.containsKey(String.valueOf(objCampaign.Priority__c))){
                                if(mapParentAndChildCondition.get(String.valueOf(objCampaign.Priority__c)).Name != null){
                                    objCampaign.addError(CommonConstant.PRIORITY_DUPLICATE_PARENT_ERROR+'"'+mapParentAndChildCondition.get(String.valueOf(objCampaign.Priority__c)).Name+'".');
                                }
                            }
                        }else if(objCampaign.ParentId != null){  
                            if (mapParentAndChildCondition.containsKey(objCampaign.ParentId+string.valueof(objCampaign.Priority__c))){
                                if(mapParentAndChildCondition.get(objCampaign.ParentId+string.valueof(objCampaign.Priority__c)).Name != null){
                                  //  objCampaign.addError(CommonConstant.PRIORITY_DUPLICATE_CHIELD_ERROR+'"'+mapParentAndChildCondition.get(objCampaign.ParentId+string.valueof(objCampaign.Priority__c)).Name+'".');
                                }
                            }
                        }     
                        if(null != objCampaign.Campaign_logic__c && objCampaign.Campaign_logic__c != ''){
                            String logicalCondition = objCampaign.Campaign_logic__c;
                            Integer logicalConditionMaxSpaces = spaceChecking(logicalCondition);
                            if(logicalConditionMaxSpaces > 0) {
                                objCampaign.addError(CommonConstant.ERROR_MSG_FOR_CAMPAIGN_LOGICAL_CONDITION);
                            }
                        }
                        
                    } 
                }
            }
        }catch(Exception e) {
            for(Campaign objectCampaign : campaignList) {
                objectCampaign.addError(e.getMessage());
            }
        }
    } 
    /************* checking space in logical condition ***************************/
    Public static Integer spaceChecking(String text) {
        Integer maxSpaces = 0;
        if(null != text && text != ''){
            String[] substrings = text.split(' ');
            Integer consecutiveSpaces = 0;
            for(Integer i = 0; i < substrings.size(); i++) {
                if(substrings[i] == '') {consecutiveSpaces++;} else {
                    maxSpaces = Math.max(maxSpaces, consecutiveSpaces);consecutiveSpaces = 0;
                }
            }
        }
        return maxSpaces;
    }
}