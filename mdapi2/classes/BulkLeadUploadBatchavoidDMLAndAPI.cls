/*********************************************************************************************
* @author          Thinqloud Solutions (Chandrakant More)
* @description     This Batch Class called in LeadTriggerHandler(Class),this class used to call pushDataToOzontelfotBatch method From BulkOzonetelAPI to avoid future method from another future method.
* @date            24/02/2023    
* @testClass: 
**********************************************************************************************/
public class BulkLeadUploadBatchavoidDMLAndAPI implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{
    public List<CampaignMember> campaignMemberToApi ;
    Public set<Id> setCampaignMemberTosenAPI ;
    /********************************************************************************************************
* @author          Chandrakant More
* @description     BulkLeadUploadBatchavoidDMLAndAPI this constructure is used to get Campaign Member list from lead trigger handler.
* @param           campaignMemberToApi (List) : used to pass the list of CampaignMember to the constructure as parameter.
* @date            24/02/2023   
********************************************************************************************************/
    public BulkLeadUploadBatchavoidDMLAndAPI(List<CampaignMember> campaignMemberToApi){
        this.campaignMemberToApi = campaignMemberToApi;
    } 
    /**
* @description :start method to get List of CampaignMenber and procees to Upload.
* 
* @param campaignMemberListBatch The List of campaign Member to be processed by the batch job.
* @return it return iterable Sobject.
*/
    public Iterable<SObject> start(Database.BatchableContext campaignMemberListBatch){
        return campaignMemberToApi;
    }
    /**
* @description :execute method to get List of CampaignMenber and procees to Upload.
* 
* @param reqIds The List of campaign Member to be processed by the batch job.
*/
    public void execute(Database.BatchableContext campaignMemberListBatch, List<CampaignMember> reqIds){
        set<Id> currentCMSetId = new set<Id>();
        if(!reqIds.IsEmpty() && reqIds.size() > 0 ){
            for(CampaignMember objCM : reqIds ){
                currentCMSetId.add(objCM.Id);
            }            
            setCampaignMemberTosenAPI = currentCMSetId;
        }
        if(!setCampaignMemberTosenAPI.IsEmpty() && setCampaignMemberTosenAPI.size() > 0){
            BulkOzonetelAPI.pushDataToOzontelfotBatch(setCampaignMemberTosenAPI);
        }         
    }
    /**
* @description :finish method to Used To do furtner procees on record in Uploaded.
* 
* @param campaignMemberListBatch List Of Lead.
*/
    public void finish(Database.BatchableContext campaignMemberListBatch){
        // Finish method to perform task after completion of batch execution  
    }  
}