/*********************************************************************************************
* @author          Thinqloud Solutions (Chandrakant More)
* @description     This trigger is used to call CampaignTriggerHandler(Avoid duplicate priority based on parent and chield champaign)
* @date            17/03/2023    
* @testClass: 
**********************************************************************************************/
trigger CampaignTrigger on Campaign (before insert,before Update) {
    List<Campaign> newCampaignInserted = new List<Campaign>(); 
    // trigger before insert
    if(trigger.Isbefore && trigger.IsInsert){
        for(Campaign objectCampaign : trigger.new){
            if(objectCampaign.Priority__c != null && (objectCampaign.ParentId != null || objectCampaign.ParentId == null)){
                newCampaignInserted.add(objectCampaign);
            }
        }
    }
    // trigger before update priority or parent campaign
    if(trigger.Isbefore && trigger.IsUpdate){
        for(Campaign objectCampaign : trigger.new){
            if(((objectCampaign.ParentId != null || objectCampaign.ParentId == null) && ((Trigger.OldMap.get(objectCampaign.Id).Priority__c != objectCampaign.Priority__c))) ||
               ((objectCampaign.Priority__c != null || objectCampaign.Priority__c == null) && (Trigger.OldMap.get(objectCampaign.Id).ParentId != objectCampaign.ParentId) && (objectCampaign.ParentId != null || objectCampaign.ParentId == null) )){
                   {
                       newCampaignInserted.add(objectCampaign);
                   }
               }
        }
    }
    
    // trigger before update logical condition
    if(trigger.Isbefore && trigger.IsUpdate){
        for(Campaign objectCampaign : trigger.new){
            if((objectCampaign.Campaign_logic__c != null || objectCampaign.Campaign_logic__c == null) && ((Trigger.OldMap.get(objectCampaign.Id).Campaign_logic__c != objectCampaign.Campaign_logic__c))){
                {
                    newCampaignInserted.add(objectCampaign);
                }
            }
        }
    }
    
    /*/ call CampaignTriggerHandler class
    if(!newCampaignInserted.IsEmpty() && newCampaignInserted.size() >0){
        CampaignTriggerHandler.avoidDuplicatePriorityOnCampaign(newCampaignInserted);   
    }*/
}