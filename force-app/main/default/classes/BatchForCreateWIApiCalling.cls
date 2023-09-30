/*
* 
* @author          Aasim Shaikh
* @description     This Batch is call create work item api.
* @Request         List<Id> myLeads
* @return          No return any value 
* @date            09/03/2023    
*  
*/
global class BatchForCreateWIApiCalling implements Database.Batchable<Id>, Database.AllowsCallouts {
    // List of IDs to process
    private List<Id> ids;
    private Opportunity oppMaster;
    
    // Constructor to set the list of IDs
    public BatchForCreateWIApiCalling(List<Id> ids) {
        this.ids = ids;
        this.oppMaster = LosUtils.getOportunityDetails(ids[0])[0];
    }
    
    global List<Id> start(Database.BatchableContext bc) {
        return this.ids;
    }
    
    global void execute(Database.BatchableContext bc, List<Id> leadIds) {
        // Call to createWI        
       
        System.debug('oppMaster ' + oppMaster);
        LosImplementation.createWorkItem(oppMaster, '004');
    }
    
    global void finish(Database.BatchableContext bc) { 
        try {
            System.debug('finish:  ' + oppMaster);
            this.oppMaster = LosUtils.getOportunityDetails(ids[0])[0];
            if(oppMaster != null && oppMaster.LOS_Id__c != null) {
                List<String> apiExcludeList = new List<String>();
                apiExcludeList.add(CommonConstant.WORK_ITEM_API_NAME);
                apiExcludeList.add(CommonConstant.DATA_TRANSFER_API_NAME);
                
                List<LosApiMaster__c> apiMasterForApplicant = [select id, ApiName__c, ApiURL__c, Active__c, ForCoApplicant__c from LosApiMaster__c 
                                                               where Active__c = true and ApiName__c not in:apiExcludeList];
               
                List<Co_Applicant__c> coAppMaster = LosUtils.getCoApplicantDetails(oppMaster.Lead__c);
                SysTem.debug('coAppMaster::::::::::::::' + coAppMaster.size());
                for(Co_Applicant__c applicant : coAppMaster) {
                    String accType = applicant.Type__c;
                    String accId = applicant.Account__c;
                    
                    Integer interval = 10; 
                    for(LosApiMaster__c apiConfig : apiMasterForApplicant) {
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
                
            } else {
                SchedularForFailedCreateWIApiCalling m = new SchedularForFailedCreateWIApiCalling();
                DateTime now  = DateTime.now();                
                DateTime nextRunTime = now.addMinutes(CommonConstant.FIVE_MIN_INTERVAL);
                String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
                    nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + 
                    nextRunTime.month() + ' ? ' + nextRunTime.year();                               
                System.debug('cron: ' + cronString);
                String jobID = System.schedule('LOS scheduler For Create WI API Calling at ' + cronString, cronString, m);
                system.debug('In BatchForCreateWIApiCalling finish method:: Opportunity is empty/ create work item api failed.');            
            }  
        } catch(Exception e) {
            System.debug('Exception in BatchForCreateWIApiCalling execute ::::: ' + e.getMessage() +'. At line no.- ' + e.getLineNumber());
            LosImplementation.trackException(oppMaster, e.getMessage());
        }
    }
    
}