trigger AccountTrigger on Account (before insert , before update, after insert, after Update) {
    List<Account> newAccount = new List<Account>();
    
    if(trigger.IsBefore && trigger.IsInsert){
        for(Account acc : trigger.new){
            if(acc.PAN_Number__c != NULL || acc.Date_of_Birth__c != NULL  || acc.Aadhar_Number__c != NULL || acc.Passport_Number__c != NULL || 
               acc.Driving_License_Number__c != NULL || acc.Voter_ID__c != NULL){
                   newAccount.add(acc);
               }
        }   
    } 
    
    if(trigger.IsBefore && trigger.Isupdate){
        for(Account acc : trigger.new){
            if(acc.PAN_Number__c != trigger.oldMap.get(acc.Id).PAN_Number__c || acc.Aadhar_Number__c != trigger.oldMap.get(acc.Id).Aadhar_Number__c || 
               acc.Passport_Number__c != trigger.oldMap.get(acc.Id).Passport_Number__c || acc.Driving_License_Number__c != trigger.oldMap.get(acc.Id).Driving_License_Number__c 
               || acc.Voter_ID__c != trigger.oldMap.get(acc.Id).Voter_ID__c || acc.Date_of_Birth__c != trigger.oldMap.get(acc.Id).Date_of_Birth__c){
                   newAccount.add(acc);
               }
        }
    }
    
    if(!newAccount.IsEmpty() && newAccount.size() >0){
        AccountTriggerHandler.accountDedupe(newAccount);
    }
}