/*********************************************************************************************
* @author          Thinqloud Solutions (Chandrakant More)
* @description     This class is used for selection of user(Lead Owner) based on service Branch in Active Transfer To CEM
* @date            03/05/2023 (May,2023)    
* @testClass: 
**********************************************************************************************/
public class ActiveTransferToCEMUserSelection {
    
    /********************************************************************************************************
* @author          Chandrakant More
* @description     getActiveTransferToCEMUserSelection this method is used to pass the Service Branch name as picklist to the component.
* @return          List<Active_Transfer_To_CEM_User_Selection__mdt> list or all metadata record.    
* @date            03/05/2023 (May,2023)
********************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Active_Transfer_To_CEM_User_Selection__mdt> getActiveTransferToCEMUserSelection() {
        return [SELECT Service_Branch_Name__c FROM Active_Transfer_To_CEM_User_Selection__mdt];
    }
    
    /********************************************************************************************************
* @author          Chandrakant More
* @description     getServiceBarnchFromLead this method is used get the existing service branch from current lead on load of component.
* @return String of Service Barnch name.    
* @date            03/05/2023 (May,2023)
* @param           leadId (String) : get LeadId.
********************************************************************************************************/
    @AuraEnabled
    public static String getServiceBarnchFromLead(String leadId) {
        Lead objectLead = [SELECT Id,Name,Service_Branch__c from Lead where Id =:leadId] ;
        return objectLead.Service_Branch__c ;
    }
    
    /********************************************************************************************************
* @author          Chandrakant More
* @description     getUserList this method is used to get the all associated user to the service branch and pass to component as picklist.
* @return          List<User> list of user associated to the service branch.    
* @date            03/05/2023 (May,2023)
* @param           selectedBranch (String) : get Sevice Barnch.
********************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<User> getUserList(String selectedBranch) {
        Active_Transfer_To_CEM_User_Selection__mdt instanceActiveTransferToCEM = new  Active_Transfer_To_CEM_User_Selection__mdt();
        List<String> allAssociatedBranchSet = new List<String>();
        List<String> setQueueIds = new List<String>();
        List<String> setUserIds = new List<String>();
        List<Group> listAssociatedBranchQueue = new  List<Group>();
        List<GroupMember> lstGroupMember = new List<GroupMember>();
        List<User> lstUser = new List<User>();
        
        instanceActiveTransferToCEM = [SELECT Id, Service_Branch_Name__c,Service_Branch_Associated_Queues__c FROM Active_Transfer_To_CEM_User_Selection__mdt
                                       where Service_Branch_Name__c =: selectedBranch ];
        
        if(instanceActiveTransferToCEM != null){
            allAssociatedBranchSet = instanceActiveTransferToCEM.Service_Branch_Associated_Queues__c.split(',');
        }
        
        listAssociatedBranchQueue = [SELECT Id, DeveloperName,Name from Group WHERE Type = 'Queue' AND Name =: allAssociatedBranchSet];
        for(Group objectGroup : listAssociatedBranchQueue){
            setQueueIds.add(objectGroup.Id);
        }
        
        lstGroupMember = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId =: setQueueIds];
        for(GroupMember objectGroupMember : lstGroupMember){
            setUserIds.add(objectGroupMember.UserOrGroupId);
        }
        
        String userRoleName = 'ASM ' + selectedBranch.toLowerCase().capitalize();
        lstUser = [SELECT Name,userrole.name from User where Id In: setUserIds and userrole.Name !=: userRoleName];
        return lstUser ;
    }
    
    /********************************************************************************************************
* @author          Chandrakant More
* @description     updateLeadRecord this method is used to update the lead based on service branch and selected user.
* @return          No-returntype    
* @date            03/05/2023 (May,2023)
* @param           leadId (String) : get Sevice Barnch.
* @param           userName (String) : get User Name.
* @param           selectedBranch (String) : get Sevice Barnch.
********************************************************************************************************/
    @AuraEnabled
    public static String updateLeadRecord(String leadId,String serviceBranchName,String userName) {
        string errorMessage ;
        try {
            List<Lead> leadsToUpdate = new List<Lead>();
            Lead objectLead = new Lead();
            objectLead.Id = leadId;
            objectLead.Service_Branch__c = serviceBranchName;
            objectLead.OwnerId = userName;
            objectLead.Status = System.Label.Lead_status_Sales_Processing;
            objectLead.Status__c = System.Label.Lead_Status_new; 
            objectLead.StageStatusChangeTime__c = datetime.now();
            leadsToUpdate.add(objectLead);
            if (leadsToUpdate.size() > 0) {
                update leadsToUpdate; 
            }   
        }
        catch (Exception ex) {
            errorMessage =ex.getMessage() ;
        }
        return errorMessage ;
    }
}