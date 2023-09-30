/*********************************************************************************************
* @author          Thinqloud Solutions (Chandrakant More)
* @description     This Class called in LeadTriggerHandler(Class),this class used to delete
old Campaign Member once lead stage is updated to next.
* @date            22/02/2023    
* @testClass: 
**********************************************************************************************/
public class CampaignMemberHelper {
    
    /********************************************************************************************************
* @author          Chandrakant More
* @description     OnLeadCreationDeleteOldCampMember this method is used to delete Campaign Member once lead stage updatedto next stage.
* @param           setCampaignMemberId (set<Id>) : This parameter used to get newly created campaign member Ids.
setLeadId (set<Id>) : This parameter used to get associcated Lead Ids.
* @return          void
* @date            22/02/2023   
********************************************************************************************************/
    public static void OnLeadCreationDeleteOldCampMember(Set<Id> setCampaignMemberId,Set<Id> setLeadId){
        try {
            /********************** Get the old campaign members associated with same lead ****************/
            List<CampaignMember> existingOldCampaignMemberlst = new List<CampaignMember>();
            if((!setLeadId.IsEmpty() && setLeadId.size() > 0) && (!setCampaignMemberId.IsEmpty() && setCampaignMemberId.size() > 0)){
                existingOldCampaignMemberlst = [SELECT Id, IsDeleted, CampaignId,
                                                LeadId,Campaign.Name,Campaign.Parent.Name,Lead.Name,Lead.MobilePhone,
                                                CreatedDate,FirstName,LastName,Type,
                                                MobilePhone FROM CampaignMember
                                                where LeadId in:setLeadId And
                                                Id not in:setCampaignMemberId ];
                System.debug('Data to delete:'+existingOldCampaignMemberlst);
            }
            if(!existingOldCampaignMemberlst.IsEmpty() && existingOldCampaignMemberlst.size() >0){
                try{
                    OzontelDeteleLeadDetails.deleteDataFromOzontel(json.serialize(existingOldCampaignMemberlst));
                }catch(System.Exception e){
                    System.debug('Exception:- '+e.getMessage());
                }finally{
                    Delete  existingOldCampaignMemberlst;
                }
            }
        }catch (Exception e) {
            System.debug(CommonConstant.ERROR_CONSTANT + e.getMessage());
        }
    }
    /********************************************************************************************************
* @author          Chandrakant More
* @description     deleteCampaignMembers this method is used to delete Campaign Member once lead stage updated to Sales Processing.
* @param           Leadlist List<Lead> : This parameter used to get list of lead from Lead trigger.
* @return          void
* @date            15/03/2023   
********************************************************************************************************/   
    public static void deleteCampaignMembers(List<Lead> Leadlist){
        // Try-Bloc
        try {
            // List to hold the Lead Ids for which Campaign Members should be deleted
            Set<Id> leadIdsSet = new Set<Id>();
            
            // Check if the Lead stage has been updated to Sales Processing
            if(!Leadlist.IsEmpty() && Leadlist.size() >0){
                for (Lead lead : Leadlist) {
                    leadIdsSet.add(lead.Id);
                }
            }
            
            // Delete Campaign Members for the selected Leads
            List<CampaignMember> campaignMembersToDelete = new List<CampaignMember>();
            if (!leadIdsSet.isEmpty()) {
                campaignMembersToDelete = [SELECT Id,IsDeleted, CampaignId,
                                           LeadId,Campaign.Name,Campaign.Parent.Name,Lead.Name,
                                           CreatedDate,FirstName,LastName,Type,Lead.MobilePhone,
                                           MobilePhone FROM CampaignMember WHERE LeadId IN :leadIdsSet];
            }
            // Delete list of Campaign Member
            if(!campaignMembersToDelete.IsEmpty() && campaignMembersToDelete.size() >0){
                OzontelDeteleLeadDetails.deleteDataFromOzontel(json.serialize(campaignMembersToDelete));
                delete campaignMembersToDelete;
            }
            // Catch-Block to handel exception    
        } catch (Exception e) {
            system.debug(CommonConstant.ERROR_CONSTANT + e.getMessage());
        } 
    }
}