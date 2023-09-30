/*
* 
* @author          Aasim shaikh, Dhanaji Patil
* @description     This scheduler is used to calling Create Work Item.
* @Request         null
* @return          No return any value 
* @date            15/03/2023    
* 
*/
global class SchedularForFailedCreateWIApiCalling implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        List<Tracker__c> trackLog = [select id,Lead__c, ApiName__c, Status__c, StatusCode__c  from Tracker__c where Status__c ='Failure'
                                     and ApiName__c =:CommonConstant.WORK_ITEM_API_NAME];
        
        if(trackLog.size() > 0) {
            for(Tracker__c track : trackLog) {
                List<Id> leadId = new List<Id>();
                leadId.add(track.Lead__c);
                System.debug('Scheduled Work Item for failed lead ID: '+ leadId);
                // Call to create Work Item API 
                Database.executeBatch(new BatchForCreateWIApiCalling(leadId), 18);
            }
        }        
    }
}