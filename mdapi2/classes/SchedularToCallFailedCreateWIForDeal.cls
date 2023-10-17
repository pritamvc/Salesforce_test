/**
 * Author: Aasim Shaikh, Dhanaji Patil
 * @description This scheduler is used to call the Create Work Item API for failed deals.
 * @Request null
 * @date 15/03/2023
 */
public class SchedularToCallFailedCreateWIForDeal implements Schedulable {
    private Opportunity oppMaster;
    /**
     * Author: Sohail Solapure
     * @description Constructor for initializing the scheduler with an Opportunity.
     * @param opp The Opportunity object to be processed.
     */
    public SchedularToCallFailedCreateWIForDeal(Opportunity opp) {
        this.oppMaster = opp;
    }
    
    /**
     * Author: Sohail Solapure
     * @description Executes the scheduled job. This method will be called by the scheduler.
     * @param sc The context of the scheduler.
     */
    public void execute(SchedulableContext sc) {
        List<Id> ids = new List<Id>();
        ids.add(oppMaster.Lead__c);
        Database.executeBatch(new BatchToCreateWIForDeal(ids));       
        
        Id jobId = sc.getTriggerId();
        System.abortJob(jobId);
    }
}