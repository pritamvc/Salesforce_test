/********************************************************************************************************
* @author          Dhanaji Patil
* @description     BatchForAssignCampaignToLead this Batch class is used for assign campaign to the lead
* @param           Lead (List), Map of chield campaign, map of parent campaign : All pass to the constructure as parameter.
* @return          No-return
* @date            03/05/2023   
* @param
********************************************************************************************************/

public class BatchForAssignCampaignToLead implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{
    
    private List<CampaignMember> campaignMemberList = new  List<CampaignMember>();
    private Map<String,String> mapOfParentCampIdAndLogicCondition = new Map<String,String>();
    private Map<String,List<Campaign>> mapOfParentCampIdAndChildCampList = new Map<String,List<Campaign>>();
    private List<Lead> leadList = new List<Lead>();
    private List<Lead> leadListFromtrigger = new List<Lead>();
    private Map<String,String> mapOfParentCampNameAndLogicCondition = new Map<String,String>();
    /**
     * Author: Sohail Solapure
     * Description: Constructor for the BatchForAssignCampaignToLead class.
     * 
     * This constructor initializes the BatchForAssignCampaignToLead class with the required parameters for assigning
     * campaigns to leads based on specified conditions.
     * 
     * @param mapOfParentCampIdAndLogicCondition A map of parent campaign IDs and their associated logic conditions.
     * @param mapOfParentCampIdAndChildCampList A map of parent campaign IDs and lists of child campaigns.
     * @param leadList A list of leads to which campaigns will be assigned.
     * @param leadListFromtrigger A list of leads retrieved from a trigger context.
     * @param mapOfParentCampNameAndLogicCondition A map of parent campaign names and their associated logic conditions.
     * @description This constructor initializes the BatchForAssignCampaignToLead class with the specified parameters.
     *    
     */
    public BatchForAssignCampaignToLead(Map<String,String> mapOfParentCampIdAndLogicCondition,Map<String,List<Campaign>> mapOfParentCampIdAndChildCampList,List<Lead> leadList, List<Lead> leadListFromtrigger,Map<String,String> mapOfParentCampNameAndLogicCondition){
        this.mapOfParentCampIdAndLogicCondition = mapOfParentCampIdAndLogicCondition;
        this.mapOfParentCampIdAndChildCampList = mapOfParentCampIdAndChildCampList;
        this.leadList = leadList;
        this.leadListFromtrigger = leadListFromtrigger;
    } 

    /**
     * Author: Sohail Solapure
     * Description: The start method of the BatchForAssignCampaignToLead class.
     * 
     * This method is called at the beginning of the batch job and returns the initial set of SObjects
     * to be processed.
     * 
     * @param bc The batchable context provided by Salesforce.
     * @return An iterable collection of SObjects to be processed by the batch job's execute method.
     * @description This method serves as the starting point for the batch job's execution. 
     */
    public Iterable<SObject> start(Database.BatchableContext bc){
        return leadList;
    }

    /**
     * Author: Sohail Solapure
     * Description: The execute method of the BatchForAssignCampaignToLead class.
     * 
     * This method is responsible for processing a batch of leads and assigning campaigns to them
     * based on the specified conditions.
     * 
     * @param bc The batchable context provided by Salesforce.
     * @param leadList A list of leads to be processed by the batch job.
     * @description This method executes the core processing logic of the batch job.
     */
    public void execute(Database.BatchableContext bc, List<Lead> leadList){
        if(!mapOfParentCampIdAndLogicCondition.IsEmpty() && mapOfParentCampIdAndLogicCondition.size() >0) {
            if(null != leadList && leadList.size()>0){
                For(Lead leadObject : leadList) {
                    try{
                        campaignMemberList = LeadCampaignHandler.assignCampaignMemberTolead(leadObject, campaignMemberList, mapOfParentCampIdAndLogicCondition, mapOfParentCampIdAndChildCampList, leadListFromtrigger, mapOfParentCampNameAndLogicCondition);
                    } catch(DmlException e) {
                        e.getCause();
                    }
                }
            } 
        }
    }

    /**
     * Author: Sohail Solapure
     * Description: The start method of the BatchForAssignCampaignToLead class.
     * 
     * This method is called at the beginning of the batch job and returns the initial set of SObjects
     * to be processed.
     * 
     * @param bc The batchable context provided by Salesforce.
     * @description This method serves as the finish point for the batch job's execution. 
     */
    public void finish(Database.BatchableContext bc){
        if(campaignMemberList.size() > 0) {
            LeadCampaignHandler.campaignAssignmentAndOzontelInteraction(campaignMemberList);
        }
    } 
}