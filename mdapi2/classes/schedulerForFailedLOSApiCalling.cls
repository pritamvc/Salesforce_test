/*
* 
* @author          Aasim Shaikh, Dhanaji Patil
* @description     This scheduler is used to re-push the failed LOS API details again.
* @Request         no request
* @return          No return any value 
* @date            03/03/2023    
* 
* Not used currently
*/ 

global class SchedulerForFailedLOSApiCalling implements Schedulable {
    
    public String leadId;
     
    global schedulerForFailedLOSApiCalling(String leadId){
        this.leadId = leadId;
    }
    
    global void execute(SchedulableContext sc) {
        system.debug('schedulerForFailedLOSApiCalling Batch Started time id :: '+System.today());
        
        try {
            /******************************* get the failed status tracker details ***********************************/
            String status = LOSConstants.STATUS_SUCCESS;
            String query = 'Select ApiName__c, Lead__c, Account__c, Status__c, StatusCode__c  from Tracker__c where Status__c != :status and Lead__c=:leadId limit 10';
            
            List<Tracker__c> trackerList =  Database.query(query);
            
            System.debug(' Tracker Failed Records is :: '+trackerList);
            
            if(null != trackerList && trackerList.size() > 0) {
                Opportunity oppMaster = LosUtils.getOportunityDetails(leadId)[0]; 
                for(Tracker__c trackerObj : trackerList) {        
                    if(null != trackerObj.Lead__c && null != trackerObj.ApiName__c) {
                        
                        /******************************* calling to LOS API ***********************************/
                            
                        Co_Applicant__c applicantDetail = [select id, Account__c, Type__c, Lead__c from Co_Applicant__c where 
                                                           Lead__c =:trackerObj.Lead__c and Account__c =:trackerObj.Account__c];                      
                        DateTime now  = DateTime.now();
                        Integer interval = 10 ;
                        DateTime nextRunTime = now.addSeconds(interval); 
                        String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
                            nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + 
                            nextRunTime.month() + ' ? ' + nextRunTime.year();                               
                         
                     
                        
                    }else{System.debug(LOSConstants.ERROR_TRACKER_OBJECT_IS_VALUE_EMPTY);}
                }
            }else{System.debug(LOSConstants.ERROR_TRACKER_OBJECT_IS_VALUE_EMPTY);} 
        } catch(Exception e) {
            System.debug('Exception in schedulerForFailedLOSApiCalling execute ::::: ' + e.getMessage() +'. At line no.- ' + e.getLineNumber());
        }
        
        system.debug('schedulerForFailedLOSApiCalling Batch Ended time id :: '+System.today());
    }
}