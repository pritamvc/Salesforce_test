/**
 * @author          Aasim Shaikh
 * @description     This Batch class is used to call the Failed LOS Api 
 * @param           myLeads A list of lead IDs for which the Failed LOS Api needs to be called.
 * @return          This batch class does not return any value.
 * @date            30/03/2023
 */
public class BatchFailedLOSDealDataSync implements Database.Batchable<Id>,Database.AllowsCallouts,Database.stateful {
    private List<Id> ids;
    private Opportunity oppMaster;
    
    /**
     * Constructor for the BatchFailedLOSDealDataSync class.
     * Initializes the batch class with a list of lead IDs to process.
     * 
     * @param ids A list of lead IDs for which the Failed LOS Api needs to be called.
     * @description This constructor initializes the BatchFailedLOSDealDataSync class with a provided list of lead IDs,allowing the batch job to process Failed LOS Api calls for the specified leads
     *              .
     */
    public BatchFailedLOSDealDataSync(List<Id> ids) {
        this.ids = ids;
    }  
    
    /**
     * The start method of the BatchFailedLOSDealDataSync class.
     * This method is called at the beginning of the batch job and returns the initial set of IDs to process.
     * @param bc The batchable context provided by Salesforce.
     * @return A list of lead IDs to be processed by the batch job.
     * @description This method is responsible for providing the initial set of lead IDs that will be processed  by the batch job. It is called at the start of the batch job execution.
     *             
     */
    public List<Id> start(Database.BatchableContext bc) {
        return this.ids;
    }
    
    /**
     * The execute method of the BatchFailedLOSDealDataSync class.
     * This method is responsible for processing a batch of lead IDs.
     * 
     * @param bc The batchable context provided by Salesforce.
     * @param leadIds A list of lead IDs to be processed by the batch job.
     * @description This method is the core of the batch processing logic.
     *              
     */
    public void execute(Database.BatchableContext bc, List<Id> leadIds) {
        String accountId;
        try {
           //Get the failed status tracker details
            String applicantLeadId = ids[0];
            String status = LOSConstants.STATUS_SUCCESS;
           
            List<Tracker__c> trackerList = [Select ApiName__c, Lead__c,Deal__c, Account__c, Status__c, StatusCode__c  from Tracker__c where 
                                            Status__c != :status and Lead__c=:applicantLeadId limit 10];
            
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
                    accountId = accId; 
                    
                    Integer interval = 10 ;
                   
                    for(LosApiMaster__c apiConfig : apiMaster) {
                        DateTime now  = DateTime.now(); 
                        interval = interval + 5;
                        DateTime nextRunTime = now.addSeconds(interval);
                        String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
                            nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' +  
                            nextRunTime.month() + ' ? ' + nextRunTime.year();
                         
                        if(accType.equalsIgnoreCase(LOSConstants.APPLICANT)) {
                            SchedularLOSDealDataSync scLos = new SchedularLOSDealDataSync(apiConfig, oppMaster, applicant);
                            System.schedule(LOSConstants.LOS_SCHEDULE_NAME + apiConfig.ApiName__c + LOSConstants.SCHEDULE_LEADID + applicant.Lead__c + LOSConstants.SCHEDULE_ACCOUNTID + applicant.Account__c + ' :' + System.now() + now.millisecond() , cronString, scLos);
                        } else if(apiConfig.ForCoApplicant__c == true) {
                            SchedularLOSDealDataSync scLos = new SchedularLOSDealDataSync(apiConfig, oppMaster, applicant);
                            System.schedule(LOSConstants.LOS_SCHEDULE_NAME + apiConfig.ApiName__c + LOSConstants.SCHEDULE_LEADID + applicant.Lead__c + LOSConstants.SCHEDULE_ACCOUNTID + applicant.Account__c + ' :' + System.now() + now.millisecond()  , cronString, scLos);
                        } 
                    } 
                }
                // Deleting old records
               delete trackerList;
            }
        }catch(Exception e){
            System.debug(LOSConstants.LOS_FAILED_EXCEPTION + e.getMessage() + LOSConstants.QUERY_EXCEPTION_LINE + e.getLineNumber());
            LosImplementation.trackException(oppMaster, e.getMessage(), accountId);
        }   
        
    }
    
    /**
     * The finish method of the BatchFailedLOSDealDataSync class.
     * This method is called after all batches are processed, allowing for any finalization logic.
     * 
     * @param bc The batchable context provided by Salesforce.
     * @description This method is executed once all batches of lead IDs have been processed. 
     *           
     */
    public void finish(Database.BatchableContext bc) { 
        //To call data transfer API for 
        DateTime scheduledTime = DateTime.now().addMinutes(5);
        String jobName = LOSConstants.DATA_TRANSER_FOR_FAILED +' '+ scheduledTime.getTime();
        String cronExp = '0 ' + scheduledTime.minute() + ' ' + scheduledTime.hour() + ' ' +scheduledTime.day() + ' ' + scheduledTime.month() + ' ? ' + scheduledTime.year();
        
        if(oppMaster != null){
            System.schedule(jobName, cronExp, new schedulerForDataTransferAPICalling(oppMaster.Id));
        }
        else{
            String applicantLeadId = ids[0];
            this.oppMaster = LosUtils.getOportunityDetails(applicantLeadId)[0]; 
            System.schedule(jobName, cronExp, new schedulerForDataTransferAPICalling(oppMaster.Id));
        }    
    }
    
}