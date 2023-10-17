/*
* 
* @author          Aasim Shaikh
* @description     This Batch is call Failed LOS Api.
* @Request         List<Id> myLeads
* @return          No return any value 
* @date            30/03/2023    
*  
*/
global class BatchForFailedLOSApiCalling implements Database.Batchable<Id>, Database.AllowsCallouts {
    private List<Id> ids;
    private Opportunity oppMaster;
    
    public BatchForFailedLOSApiCalling(List<Id> ids) {
        this.ids = ids;
    }  
    
    global List<Id> start(Database.BatchableContext bc) {
        return this.ids;
    }
    
    global void execute(Database.BatchableContext bc, List<Id> leadIds) {
        try {
            /******************************* get the failed status tracker details ***********************************/
            String applicantLeadId = ids[0];
            String status = CommonConstant.STATUS_SUCCESS;
            String query = 'Select ApiName__c, Lead__c, Account__c, Status__c, StatusCode__c  from Tracker__c where Status__c != :status and Lead__c=:applicantLeadId limit 10';
            
            List<Tracker__c> trackerList =  Database.query(query);
            
            System.debug(' Tracker Failed Records is :: '+ trackerList.size());
            
            if(null != trackerList && trackerList.size() > 0) {
                this.oppMaster = LosUtils.getOportunityDetails(applicantLeadId)[0]; 
                Set<String> apiNames = new Set<String>();
                for(Tracker__c trackerObj : trackerList) {
                    apiNames.add(trackerObj.ApiName__c);
                }
                List<LosApiMaster__c> apiMaster = [select id, ApiName__c, ApiURL__c, Active__c, ForCoApplicant__c from LosApiMaster__c 
                                                           where Active__c =: true and ApiName__c in:apiNames];
                
                List<Co_Applicant__c> coAppMaster = LosUtils.getCoApplicantDetails(oppMaster.Lead__c);
                
                for(Co_Applicant__c applicant : coAppMaster) {
                    String accType = applicant.Type__c;
                    String accId = applicant.Account__c;
                    
                    Integer interval = 10 ;
                   
                    for(LosApiMaster__c apiConfig : apiMaster) {
                        DateTime now  = DateTime.now(); 
                        interval = interval + 5;
                        DateTime nextRunTime = now.addSeconds(interval);
                        String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
                            nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' +  
                            nextRunTime.month() + ' ? ' + nextRunTime.year();
                        
                        if(accType.equalsIgnoreCase(CommonConstant.APPLICANT)) {
                            SchedularForLosApiCalling scLos = new SchedularForLosApiCalling(apiConfig.ApiName__c, oppMaster, applicant);
                            System.debug('SchedularForLosApiCalling obj**** ' + apiConfig.ApiName__c +' '+ oppMaster.LOS_Id__c + ' '+ applicant.Lead__c + ' '+ applicant.Account__c + ' '+ applicant.Type__c);
                            System.schedule('Los api scheduled for '+  applicant.Type__c + '.Lead Id- '+ applicant.Lead__c + '.AccountId: '+ applicant.Account__c  + ' - ' + apiConfig.ApiName__c +' at: '+ cronString + System.now() + now.millisecond() , cronString, scLos);
                        } else if(apiConfig.ForCoApplicant__c == true) {
                            SchedularForLosApiCalling scLos = new SchedularForLosApiCalling(apiConfig.ApiName__c, oppMaster, applicant);
                            System.debug('SchedularForLosApiCalling obj**** ' + apiConfig.ApiName__c +' '+ oppMaster.LOS_Id__c + ' '+ applicant.Lead__c + ' '+ applicant.Account__c + ' '+ applicant.Type__c);
                            System.schedule('Los api scheduled for '+  applicant.Type__c + '.Lead Id- '+ applicant.Lead__c + '.AccountId: '+ applicant.Account__c  + ' - ' + apiConfig.ApiName__c +' at: '+ cronString + System.now() + now.millisecond() , cronString, scLos);
                        }
                    } 
                }
                // Deleting old records
               delete trackerList;
               System.debug('Tracker record deleted');
            }else{System.debug(CommonConstant.ERROR_TRACKER_OBJECT_IS_VALUE_EMPTY);} 
        }catch(Exception e){
            System.debug('Exception in LosManualCalling :: '+ e.getMessage() + ' at line no.- ' + e.getLineNumber());
            LosImplementation.trackException(oppMaster, e.getMessage());
        }   
        
    }
    
    global void finish(Database.BatchableContext bc) {        
    }
    
}