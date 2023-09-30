/*********************************************************************************************
* @author          Thinqloud Solutions (Chandrakant More)
* @description     This trigger is used to call ApplicantTriggerHandler(Update Insertion Order On Applicant Insertion and Updation)
* @date            27/03/2023    
* @testClass: 
**********************************************************************************************/
trigger ApplicantTrigger on Co_Applicant__c (Before Insert,Before update,after insert,  after Update,after delete) {
    List<Co_Applicant__c> newApplicantInserted = new List<Co_Applicant__c>();
    // trigger before insert
    // 
     if(trigger.IsBefore && trigger.IsInsert){
           for(Co_Applicant__c objectApplicant : trigger.new){
              newApplicantInserted.add(objectApplicant);
        }
     }
    
    if(trigger.Isafter && trigger.IsInsert){
        for(Co_Applicant__c objectApplicant : trigger.new){
            if(objectApplicant.Type__c != null && objectApplicant.Lead__c !=null  ){
                newApplicantInserted.add(objectApplicant);
            }
        }
    }
    
    
    // trigger after update
    if(trigger.IsAfter && trigger.IsUpdate){
        for(Co_Applicant__c objectApplicant : trigger.new){
            if(((objectApplicant.Type__c != null) && (Trigger.OldMap.get(objectApplicant.Id).Type__c != objectApplicant.Type__c) &&  (objectApplicant.Lead__c !=null)) ||
               ((objectApplicant.Lead__c != null) && (Trigger.OldMap.get(objectApplicant.Id).Lead__c != objectApplicant.Lead__c) &&  (objectApplicant.Type__c !=null)) ||
               ((objectApplicant.Is_Income_Considered_Financial__c != null) && (Trigger.OldMap.get(objectApplicant.Id).Is_Income_Considered_Financial__c != objectApplicant.Is_Income_Considered_Financial__c) &&  (objectApplicant.Type__c !=null && objectApplicant.Lead__c !=null)) ){
                   newApplicantInserted.add(objectApplicant);
               }
        }
    }
    // trigger after delete
    if(trigger.Isafter && trigger.Isdelete){
        for(Co_Applicant__c objectApplicant : trigger.old){
            if(objectApplicant.Type__c != null && objectApplicant.Lead__c !=null  ){
                newApplicantInserted.add(objectApplicant);
            }
        }
    }
    // call ApplicantTriggerHandler class
    if(!newApplicantInserted.IsEmpty() && newApplicantInserted.size() >0){
        ApplicantTriggerHandler.insertionOrderUpdationOnApplicant(newApplicantInserted);
        ApplicantTriggerHandler.updateNamingOrder(newApplicantInserted);
    }
}