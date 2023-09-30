/*********************************************************************************************
* @author          Thinqloud Solutions (Dhanaji Patil)
* @description     This trigger is used to call OpportunityTriggerHandler for upload the lead documents on the LOS
* @date            10/05/2023    
* @testClass: 
**********************************************************************************************/


trigger OpportunityTrigger on Opportunity (after insert,after Update,before insert,before Update) {
    //List<Opportunity> opportunityUpdatedList = new List<Opportunity >();
    ///if(trigger.IsAfter && trigger.IsUpdate){
        //for(Opportunity ObjectLead : trigger.new){
            //if((Trigger.OldMap.get(ObjectLead.Id).LOS_Sync__c != ObjectLead.LOS_Sync__c)
               //&& (ObjectLead.LOS_Sync__c == true)){
                   //opportunityUpdatedList.add(ObjectLead);
               //}
        //}
    //}
    /****************** if list is not empty then calling to the OpportunityTriggerHandler class****************/
    //if(null != opportunityUpdatedList && opportunityUpdatedList.size()>0){
        //OpportunityTriggerHandler.updateDMSDataSync(opportunityUpdatedList);
    //}
    if(Trigger.isBefore && Trigger.isInsert){
    List<Opportunity> updateGroup = new List<Opportunity>();
        Group dataEntryTeam = [SELECT Id,Name FROM Group Where name = 'Data Entry Team' LIMIT 1];
        for(Opportunity opp : trigger.new){
		opp.OwnerId = dataEntryTeam.Id;
		updateGroup.add(opp);	
    }
	if(updateGroup.size()>0){
	Update updateGroup;
	}
}
}