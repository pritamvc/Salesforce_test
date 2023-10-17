trigger CaseTrigger on Case (before insert,before update) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            Map<Id,Case> nullMap = new Map<Id,Case>();
            CaseTriggerHandler.opportunityFilterMethod(trigger.new,nullMap);
        }
        if(trigger.isUpdate){
            List<Case> listOfCase = new List<Case>();
            CaseTriggerHandler.opportunityFilterMethod(trigger.new,trigger.oldMap);
            CaseTriggerHandler.updateMilestoneCompletionTime(trigger.newMap,trigger.oldMap);
        }
    }
    
}