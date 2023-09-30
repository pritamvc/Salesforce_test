public class OwnerAssigmentManualLeadCreated {
    
    public static void ownerAssignmentLead(List<Lead> newLeadList){
        system.debug('newLeadList ==== '+newLeadList);
        system.debug('newLeadList Size ==== '+newLeadList.size());
        
        String userProfileID = UserInfo.getProfileId();
        system.debug('userProfileID ==== '+userProfileID);  
        
        Profile ProfileName = [SELECT Id, Name FROM Profile WHERE Id = : userProfileID LIMIT 1];
        system.debug('ProfileName ==== '+ ProfileName);
        system.debug('ProfileName.Name ==== '+ ProfileName.Name);
        
        Group callCenterQueue = [SELECT Id, DeveloperName,Name from Group WHERE Type = 'Queue' AND Name =: System.Label.Call_Center_Queue ];
        system.debug('callCenterQueue ==== '+ callCenterQueue);
        if(!newLeadList.isEmpty() && newLeadList.size() >0){
            for(Lead objectLead : newLeadList){
                if(ProfileName.Name.contains(System.Label.Profile_Sales_Profile)){ 
                    objectLead.OwnerId = UserInfo.getUserId();
                    objectLead.Status = System.Label.Lead_stage_Sales_Processing;
                    objectLead.Status__c = System.Label.Lead_Status_new; 
                }else if(ProfileName.Name.contains(System.Label.Profile_Call_Center_Team)){ 
                    objectLead.OwnerId = callCenterQueue.Id;
                    objectLead.Status = System.Label.Lead_Stage_Fresh;
                    objectLead.Status__c = System.Label.Lead_Status_new; 
                }
            }
        }
    }
    
}