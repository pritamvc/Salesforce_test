/**
 * Author: Aasim Shaikh
 * Description: This Batch class is used to call the Create Work Item API.
 * 
 * This batch job takes a list of Lead IDs as input and performs API calls to create work items for each lead.
 * It is designed to execute callouts using the AllowsCallouts interface.
 * 
 * @param myLeads A list of Lead IDs for which work items need to be created using the API.
 * @return This batch class does not return any value.
 * @date 09/03/2023
 * @description This batch class orchestrates the API calls to create work items for the provided Lead IDs.
 */
public class BatchToCreateWIForDeal implements Database.Batchable<Id>, Database.AllowsCallouts,Database.Stateful  {
    // List of IDs to process
    private List<Id> ids;
    private Opportunity oppMaster;
    
    /**
     * Author: Sohail Solapure
     * Description: Constructor for the BatchToCreateWIForDeal class.
     * 
     * This constructor initializes the BatchToCreateWIForDeal class with a list of Lead IDs to process.
     * 
     * @param ids A list of Lead IDs for which work items need to be created using the API.
     * @description This constructor sets up the batch class with the list of Lead IDs that will be processed
     */
    public BatchToCreateWIForDeal(List<Id> ids) {
        this.ids = ids;
    }
    
    /**
     * Author: Sohail Solapure
     * Description: The start method of the BatchToCreateWIForDeal class.
     * 
     * This method is called at the beginning of the batch job and returns the initial set of Lead IDs to process.
     * 
     * @param bc The batchable context provided by Salesforce.
     * @return A list of Lead IDs to be processed by the batch job's execute method.
     * @description This method serves as the starting point for the batch job's execution.
     */
    public List<Id> start(Database.BatchableContext bc) {
        return this.ids;
    }
    
    /**
     * Author: Sohail Solapure
     * Description: The execute method of the BatchToCreateWIForDeal class.
     * 
     * This method is responsible for processing a batch of Lead IDs and making API calls to create work items.
     * 
     * @param bc The batchable context provided by Salesforce.
     * @param leadIds A list of Lead IDs to be processed by the batch job.
     * @description This method executes the core processing logic of the batch job. I
     */
    public void execute(Database.BatchableContext bc, List<Id> leadIds) {
        this.oppMaster = LosUtils.getOportunityDetails(ids[0])[0];
        LosImplementation.createWorkItem(oppMaster, LOSConstants.LOCATION_CODE);
    }

    /**
     * Author: Sohail Solapure
     * Description: The finish method of the BatchToCreateWIForDeal class.
     * 
     * This method is called after all batches are processed, allowing for any finalization logic.
     * 
     * @param bc The batchable context provided by Salesforce.
     * @description This method is executed once all batches of Lead IDs have been processed.
     */
    public void finish(Database.BatchableContext bc) { 
        String accountId;
        List<Opportunity> oppList = New List<Opportunity>();
        try {
            this.oppMaster = LosUtils.getOportunityDetails(ids[0])[0];
            oppList.add(this.oppMaster);
            //Added By Rohit 18082023
        	TrackWizzAPICalling.getRelatedRecordsAndCallTrackWizzApi(oppList);
            if(oppMaster != null && oppMaster.LOS_Id__c != null) {
                List<String> apiExcludeList = new List<String>();
                apiExcludeList.add(LOSConstants.WORK_ITEM_API_NAME);
                apiExcludeList.add(LOSConstants.DATA_TRANSFER_API_NAME);
                
                List<LosApiMaster__c> apiMasterForApplicant = [select id, ApiName__c, ApiURL__c, Active__c, ForCoApplicant__c from LosApiMaster__c 
                                                               where Active__c = true and ApiName__c not in:apiExcludeList];
                
                List<Co_Applicant__c> coAppMaster = LosUtils.getCoApplicantDetails(oppMaster.Lead__c);
                
                for(Co_Applicant__c applicant : coAppMaster) {
                    String accType = applicant.Type__c;
                    String accId = applicant.Account__c;
                    accountId = accId;
                    
                    Integer interval = 10; 
                    for(LosApiMaster__c apiConfig : apiMasterForApplicant) {
                        DateTime now  = DateTime.now();
                        interval = interval + 5;
                        DateTime nextRunTime = now.addSeconds(interval);
                        String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
                            nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' +  
                            nextRunTime.month() + ' ? ' + nextRunTime.year();
                        
                        if(accType.equalsIgnoreCase(LOSConstants.APPLICANT)) {
                            SchedularLOSDealDataSync scLos = new SchedularLOSDealDataSync(apiConfig, oppMaster, applicant);
                            System.schedule(LOSConstants.LOS_SCHEDULE_NAME + apiConfig.ApiName__c + LOSConstants.SCHEDULE_LEADID + applicant.Lead__c + LOSConstants.SCHEDULE_ACCOUNTID + applicant.Account__c + ' :' + System.now() + now.millisecond() , cronString, scLos);
                        } 
                        else if(apiConfig.ForCoApplicant__c == true) {
                            SchedularLOSDealDataSync  scLos = new SchedularLOSDealDataSync (apiConfig, oppMaster, applicant);
                            System.schedule(LOSConstants.LOS_SCHEDULE_NAME + apiConfig.ApiName__c + LOSConstants.SCHEDULE_LEADID + applicant.Lead__c + LOSConstants.SCHEDULE_ACCOUNTID + applicant.Account__c + ' :' + System.now() + now.millisecond() , cronString, scLos);
                        }
                    }                    
                }
                
                //To call data transfer API for 
                DateTime scheduledTime = DateTime.now().addMinutes(5);
                String jobName = LOSConstants.DATA_TRANSER_NAME +oppMaster.Name+' '+ scheduledTime.getTime();
                String cronExp = '0 ' + scheduledTime.minute() + ' ' + scheduledTime.hour() + ' ' +scheduledTime.day() + ' ' + scheduledTime.month() + ' ? ' + scheduledTime.year();
                System.schedule(jobName, cronExp, new schedulerForDataTransferAPICalling(oppMaster.Id));                
            } else {
                System.debug(LOSConstants.WORK_ITEM_FAILED);
            }
        } catch(Exception e) {
            System.debug(LOSConstants.ERROR + e.getMessage() +LOSConstants.QUERY_EXCEPTION_LINE + e.getLineNumber());
            LosImplementation.trackException(oppMaster, e.getMessage(), accountId);
        }
    }
}