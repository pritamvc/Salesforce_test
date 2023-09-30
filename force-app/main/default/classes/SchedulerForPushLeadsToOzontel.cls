/*********************************************************************************************
* @author          Dhanaji Patil
* @description     This scheduler Class used for to calling the bulk push to ozontel batch for pushing data in ozontel with 1 min delay.
* @date            02/05/2023    
* @testClass: 
* @param
**********************************************************************************************/

global class SchedulerForPushLeadsToOzontel implements Schedulable {
    private List<CampaignMember> listCampaignMemberFromAPI ;
    private set<Id> setCampaignMemberTosenAPI ;
   /*
    * @author          Sohail Solapure
    * @description     constructor
    * @return          No return any value 
    * @param    
    */
    public SchedulerForPushLeadsToOzontel(List<CampaignMember> listCampaignMemberFromAPI) {
        this.listCampaignMemberFromAPI = listCampaignMemberFromAPI;
    }
    
    /*
    * @author          Sohail Solapure
    * @description     execute method
    * @return          No return any value 
    * @param    
    */
    global void execute(SchedulableContext sc) {
        try {  
            Database.executeBatch(new BulkLeadUploadBatchavoidDMLAndAPI(listCampaignMemberFromAPI),100);
            System.abortJob(sc.getTriggerId());
        } catch(Exception e) {
            e.getStackTraceString();
        }
    }
}