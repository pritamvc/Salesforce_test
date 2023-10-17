/**
 * Author: Sohail Solapure
 * @description This class represents a batch job for repushing lead data to Ozonetel.
 * 
 * The class implements the Database.Batchable<String> interface for processing batches of records, Database.Stateful to maintain state between batches, and Database.AllowsCallouts to enable callouts during batch execution.
 */
public class RepushLeadOzonetelScheduler implements Schedulable {
	private String campaignName;
    Map<String,List<Id>> mapCampaignNameAndCampaignMaemberId;
    List<CampaignMember> campaignList;
    
    /**
     * Author: Sohail Solapure
     * @description Constructor for RepushLeadOzonetelBatch class.
     * @param campaignName The name of the campaign.
     * @param mapCampaignNameAndCampaignMaemberId A map containing campaign names as keys and corresponding CampaignMember Ids as values.
     * @param campaignList List of CampaignMember records.
     */
    public RepushLeadOzonetelScheduler (String campaignName,Map<String,List<Id>> mapCampaignNameAndCampaignMaemberId,List<CampaignMember> campaignList) {
        this.campaignName = campaignName; 
        this.mapCampaignNameAndCampaignMaemberId = mapCampaignNameAndCampaignMaemberId;
        this.campaignList = campaignList;
    }
    
    /**
     * Author: Sohail Solapure
     * @description This method is used to process each batch of records in the execution scope.
     * @param sc The batchable context containing the information about the batch job.
     */
    public void execute(SchedulableContext sc){
         RepushLeadOzonetelBatch batch = new RepushLeadOzonetelBatch(campaignName,mapCampaignNameAndCampaignMaemberId,campaignList);
         Database.executeBatch(batch);
         System.abortJob(sc.getTriggerId());
    }
}