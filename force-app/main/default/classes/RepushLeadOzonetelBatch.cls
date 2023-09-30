/**
 * Author: Sohail Solapure
 * @description This class represents a batch job for repushing lead data to Ozonetel.
 * 
 * The class implements the Database.Batchable<String> interface for processing batches of records, Database.Stateful to maintain state between batches, and Database.AllowsCallouts to enable callouts during batch execution.
 */
public class RepushLeadOzonetelBatch implements Database.Batchable<String>,Database.Stateful,Database.AllowsCallouts  {
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
    public RepushLeadOzonetelBatch(String campaignName,Map<String,List<Id>> mapCampaignNameAndCampaignMaemberId,List<CampaignMember> campaignList){
        this.campaignName = campaignName; 
        this.mapCampaignNameAndCampaignMaemberId = mapCampaignNameAndCampaignMaemberId;
        this.campaignList = campaignList;
    }
    
    /**
     * Author: Sohail Solapure
     * @description This method is used as the start point for the batch execution.
     * @param bc The batchable context containing the information about the batch job.
     * @return An Iterable of query locators that define the scope of records to process.
     */
    public Iterable<String> start(Database.BatchableContext bc) {
        List<String> lstCampaignName = new List<String>();
        lstCampaignName.add(campaignName);
        return lstCampaignName;
    }
    
    /**
     * Author: Sohail Solapure
     * @description This method is used to process each batch of records in the execution scope.
     * @param bc The batchable context containing the information about the batch job.
     * @param scope A list of string values representing the scope of records to process.
     */
    public void execute(Database.BatchableContext bc,List<String> scope){
        OzontelDeteleLeadDetails.deleteBulkLeadDataFromOzontel(campaignName,'','','',''); 
        update campaignList;
    }
    
    /**
     * Author: Sohail Solapure
     * @description This method is used to process each batch of records in the execution scope.
     * @param bc The batchable context containing the information about the batch job.
     */
    public void finish(Database.BatchableContext bc){
        
        if(campaignList.size() < 10){ 
            BulkOzonetelAPI.makeDataAndCallingToOzontel(campaignName,mapCampaignNameAndCampaignMaemberId);
        }else{
            BulkOzonetelAPI.scheduleTheJobForRepushToOzonetel(campaignList);
        }
    }
}