/*********************************************************************************************
* @author          Thinqloud Solutions (Chandrakant More)
* @description     This Class called in LeadTrigger(Trigger),this class used to Create Campaign Member once lead created Or updated.
This class called in BulkUploadLeadBatch (Batch Class).
* @date            14/02/2023    
* @testClass: 
**********************************************************************************************/
public class LeadTriggerHandler {
    
    /********************************************************************************************************
* @author          Chandrakant More
* @description     campaignAssignmentOnLead this method is used to create Campaign Member once lead created Or updated based on lead stage.
* @param           leadList (List) : used to pass the list of lead to the method as parameter.
* @return          No-return
* @date            14/02/2023   
********************************************************************************************************/
    Public static void campaignAssignmentOnLead(List<Lead> leadList) {
        try {
            // Metadata for conditions check 
            Campaign_Assignment_Base_On_Lead_Stage__mdt[] campaignAssignmentBaseOnLeadStagemdt = [Select Lead_Stage__c,Consent__c,Campaign_Name__c
                                                                                                  from Campaign_Assignment_Base_On_Lead_Stage__mdt];
            List<String> lstCampaignName = new List<String>();  
            // lstCampaignName.add('Test_Outbound_SF');
            // Map for dynamic condition value 
            Map<String,String> mapLeadStageConsentAndCampaignName = new Map<String,String>();
            for(Campaign_Assignment_Base_On_Lead_Stage__mdt objMetadatavalue : campaignAssignmentBaseOnLeadStagemdt){
                lstCampaignName.add(objMetadatavalue.Campaign_Name__c);
                mapLeadStageConsentAndCampaignName.put(objMetadatavalue.Lead_Stage__c+objMetadatavalue.Consent__c, objMetadatavalue.Campaign_Name__c);
            }
            //  Checking the Existing campaign for the lead assignment based on stage and Consent 
            List<Campaign> existingCampaignList = [Select Id,Name,CreatedDate From Campaign where name IN:lstCampaignName];
            Map<String,Id> CampaignMap = new Map<String,Id>();
            for(Campaign ObjectCampaign : existingCampaignList) {
                CampaignMap.put(ObjectCampaign.Name ,ObjectCampaign.Id);
            }
            //Creation campaign member and assigning to the lead 
            List<CampaignMember> campaignMemberList = new List<CampaignMember>();
            if(!existingCampaignList.IsEmpty() && existingCampaignList.size() >0) {
                For(Lead ObjectLead : leadList) {
                    string leadConditionMatch = ObjectLead.Status+ObjectLead.KYC_Consent__c;
                    if(mapLeadStageConsentAndCampaignName.containsKey(leadConditionMatch)){
                        CampaignMember cm= New CampaignMember(
                            CampaignId=CampaignMap.get(mapLeadStageConsentAndCampaignName.get(leadConditionMatch)),
                            LeadId=ObjectLead.Id,
                            Status=System.Label.Campaign_Member_Status_Sent);
                        campaignMemberList.add(cm);
                    }  /*else if(ObjectLead.Status != null && ObjectLead.Status ==System.Label.Lead_status_Sales_Processing){
if(CampaignMap.containsKey('Test_Outbound_SF')){
CampaignMember cm= New CampaignMember(
CampaignId=CampaignMap.get('Test_Outbound_SF'),
LeadId=ObjectLead.Id,
Status=System.Label.Campaign_Member_Status_Sent);
campaignMemberList.add(cm);
} 

}*/
                }
            }
            List<CampaignMember> newCampaignMemberList = new List<CampaignMember>();
            set<Id> setCampaignMember = new set<Id>();
            Set<Id> setLeadId = new Set<Id>();
            if(!campaignMemberList.IsEmpty() && campaignMemberList.size() > 0){
                insert campaignMemberList ;
                newCampaignMemberList = [select Id,Name,Campaign.Name,LeadId,CampaignId From CampaignMember where Id In : campaignMemberList];
            }
            if(!newCampaignMemberList.IsEmpty() && newCampaignMemberList.size() > 0 ){
                for(CampaignMember objectCampaignMember : newCampaignMemberList) {
                    setCampaignMember.add(objectCampaignMember.Id);
                    setLeadId.add(objectCampaignMember.LeadId);
                } 
                // class to delete old campaign Member associated with same Lead 
                CampaignMemberHelper.OnLeadCreationDeleteOldCampMember(setCampaignMember,setLeadId);
            }
            if(!setCampaignMember.IsEmpty() && setCampaignMember.size() > 0 ){  
                //To call api from trigger(for calling future method)
                if(!System.isFuture() && !System.isBatch()){
                    System.debug('Lead Api called Feom Lead Trigger=================================');
                    BulkOzonetelAPI.pushDataToOzontel(setCampaignMember);
                } 
                // To call api from batch class (avoid calling one future method from another future method)
                else {
                    Database.executeBatch(new BulkLeadUploadBatchavoidDMLAndAPI(newCampaignMemberList),100); 
                }
            }
        } catch(DmlException e) {
            System.debug(CommonConstant.ERROR_CONSTANT + e.getMessage());
        }
    } 
    
    /********************************************************************************************************
* @author          Rohit Pardeshi
* @description     duplicateLeadManagement method use to give error on before insert and before update event 
* @param           List<Lead> newLeadList : used to pass the list of lead to the method as parameter.
* @return          
* @date            07/04/2023   
********************************************************************************************************/
    Public static void duplicateLeadManagement(List<Lead> newLeadList)
    {  
        try { 
            Map<Id, String> duplicateSetId = new Map<Id, String>();
            Set<String> closecovertedset = new Set<String>();
            closecovertedset.add(CommonConstant.LOST_STAGE);
            closecovertedset.add(CommonConstant.CONVERTED_STAGE);
            Map<Id, Lead> leadIdToLeadMap = new Map<Id, Lead>();
            Id leadId;
            String leadStatus;
            Set<Id> dupId = new Set<Id>();
            Id currentLeadId;
            String errorMessage;
            
            Map<String, Lead> phoneVsContextLead = new Map<String, Lead>();
            Map<String, Lead> emailVsContextLead = new Map<String, Lead>();
            Map<String, Lead> firstNameVsContextLead = new Map<String, Lead>();
            
            Map<String, Id> fnameMobileEmailMatch = new Map<String, Id>();
            Map<String, Id> fnameMobileMatch = new Map<String, Id>();
            Map<String, Id> fnameEmailMatch = new Map<String, Id>();
            Map<String, Id> MobileEmailMatch = new Map<String, Id>();
            Map<String, Id> onlyMobileMatch = new Map<String, Id>();
            Map<String, Id> onlyEmailMatch = new Map<String, Id>();
            Map<Id, String> IdandSource = new Map<Id, String>();
            
            Dedupe_Management__c cs = Dedupe_Management__c.getValues(CommonConstant.MANAGE_DEDUPE_DAYS);
            Integer closeddays = Integer.valueOf(cs.Lead_stage_is_closed__c);
            Integer converteddays = Integer.valueOf(cs.Lead_stage_converted__c); 
            
            //DuplicateManagement.LeadWrapper wrapper = DuplicateManagement.getDuplicateLead(newLeadList);
            //system.debug('vsdvdvvsv==' +wrapper.errorMessage);
            
            /***************Collect New Name, Mobile, Email in MAP ***********************************************************/
            For(Lead newLead : newLeadList)
            {
                if(newLead.Id != null){
                    currentLeadId = newLead.Id;
                }
                firstNameVsContextLead.put(newLead.FirstName, newLead);
                phoneVsContextLead.put(newLead.MobilePhone, newLead);
                emailVsContextLead.put(newLead.Email, newLead);  
            }
            
            /***************Get duplicate lead from system based on Email OR Mobile********************************************/
            List<Lead> dupLead = new List<Lead>([SELECT Id, Status, LastModifiedDate, ConvertedOpportunityId ,FirstName, Email, MobilePhone FROM Lead 
                                                 WHERE (MobilePhone IN :phoneVsContextLead.keySet() OR Email IN :emailVsContextLead.keySet()) AND
                                                 Id !=: currentLeadId ORDER BY LastModifiedDate ASC]);
            /***************Collect duplicate lead as per dedupe parameter sequence wise in MAP********************************************/ 
            for(Lead la : dupLead)
            {
                //Lead Stage not equal to Lost & Converted
                if(!closecovertedset.contains(la.Status)){
                    duplicateSetId.put(la.Id, la.Status);
                    leadIdToLeadMap.put(la.Id, la);
                    //Lead stage equal to Lost
                }else if(la.Status == CommonConstant.LOST_STAGE){
                    if(Date.today().addDays(-closeddays) <= la.Lastmodifieddate){
                    //if(System.now().addMinutes(-closeddays) <= la.Lastmodifieddate){
                        duplicateSetId.put(la.Id, la.Status);
                        leadIdToLeadMap.put(la.Id, la);
                    }
                    //Lead stage equal to converted
                }else if(la.Status == CommonConstant.CONVERTED_STAGE){
                    if(Date.today().addDays(-converteddays) <= la.Lastmodifieddate){
                    //if(System.now().addMinutes(-converteddays) <= la.Lastmodifieddate){
                        duplicateSetId.put(la.ConvertedOpportunityId, la.Status);
                        leadIdToLeadMap.put(la.Id, la);
                    }  
                }
            }
            
            List<Lead> exactDuplicate = new List<Lead>([SELECT Id, Status, LastModifiedDate, ConvertedOpportunityId ,FirstName, Email, MobilePhone FROM Lead 
                                                        WHERE Id IN :leadIdToLeadMap.keySet() ORDER BY LastModifiedDate ASC]);
            
            for(Lead duplicateLead : exactDuplicate)
            {
                fnameMobileEmailMatch.put(duplicateLead.FirstName + duplicateLead.MobilePhone + duplicateLead.Email, duplicateLead.Id);
                fnameMobileMatch.put(duplicateLead.FirstName + duplicateLead.MobilePhone, duplicateLead.Id);
                fnameEmailMatch.put(duplicateLead.FirstName + duplicateLead.Email, duplicateLead.Id);
                MobileEmailMatch.put(duplicateLead.MobilePhone + duplicateLead.Email, duplicateLead.Id);
                onlyMobileMatch.put(duplicateLead.MobilePhone, duplicateLead.Id);
                onlyEmailMatch.put(duplicateLead.Email, duplicateLead.Id);
            }
            
            for(Lead leadObj : newLeadList)
            {
                if(fnameMobileEmailMatch.containsKey(leadObj.FirstName + leadObj.MobilePhone + leadObj.Email)){
                    IdandSource.put(fnameMobileEmailMatch.get(leadObj.FirstName + leadObj.MobilePhone + leadObj.Email), leadObj.Source_Category__c);
                    errorMessage = CommonConstant.FNAME_MOBILE_EMAIL_MATCH;
                    leadObj.addError('Lead exists With '+errorMessage+' Id: '+IdandSource.keySet());
                }else if(fnameMobileMatch.containsKey(leadObj.FirstName + leadObj.MobilePhone)){
                    IdandSource.put(fnameMobileMatch.get(leadObj.FirstName + leadObj.MobilePhone), leadObj.Source_Category__c);
                    errorMessage = CommonConstant.FNAME_MOBILE_MATCH;
                    leadObj.addError('Lead exists With '+errorMessage+' Id: '+IdandSource.keySet());
                }else if(fnameEmailMatch.containsKey(leadObj.FirstName + leadObj.Email)){
                    IdandSource.put(fnameEmailMatch.get(leadObj.FirstName + leadObj.Email), leadObj.Source_Category__c);
                    errorMessage = CommonConstant.FNAME_EMAIL_MATCH;
                    leadObj.addError('Lead exists With '+errorMessage+' Id: '+IdandSource.keySet());
                }else if(MobileEmailMatch.containsKey(leadObj.MobilePhone + leadObj.Email)){
                    IdandSource.put(MobileEmailMatch.get(leadObj.MobilePhone + leadObj.Email), leadObj.Source_Category__c);
                    errorMessage = CommonConstant.MOBILE_EMAIL_MATCH;
                    leadObj.addError('Lead exists With '+errorMessage+' Id: '+IdandSource.keySet());
                }else if(onlyMobileMatch.containsKey(leadObj.MobilePhone)){
                    IdandSource.put(onlyMobileMatch.get(leadObj.MobilePhone), leadObj.Source_Category__c);
                    errorMessage = CommonConstant.MOBILE_MATCH;
                    leadObj.addError('Lead exists With '+errorMessage+' Id: '+IdandSource.keySet());
                }else if(onlyEmailMatch.containsKey(leadObj.Email)){
                    IdandSource.put(onlyEmailMatch.get(leadObj.Email), leadObj.Source_Category__c);
                    errorMessage = CommonConstant.EMAIL_MATCH;
                    leadObj.addError('Lead exists With '+errorMessage+' Id: '+IdandSource.keySet());
                }   
            }
        }catch(DmlException e) {
            for(Lead la : newLeadList){
                la.addError(CommonConstant.ERROR_CONSTANT + e.getMessage());
            }
        }   
    }     
    
    /********************************************************************************************************
* @author         Sohail Solapure
* @description     Add '+91' to mobile number 
* @param           leadList (List) : 
* @return          
* @date            27/04/2023   
********************************************************************************************************/
    public static void assignMobileNumber(List<Lead> updatedLead){
        for(Lead currLead : updatedLead){
            currLead.MobilePhone = '+91'+ currLead.MobilePhone;
        }
    }
    
    /********************************************************************************************************
* @author         Sohail Solapure
* @description    To update the lead percentage from WTA update or manual update
* @param           leadList (List) : 
* @return          
* @date            04/05/2023   
********************************************************************************************************/
    public static void updateLeadPercentage(List<Lead> updatedLeads, Map<Id, Lead> oldLeadsMap){
        Double increasePercentage = 9;
        for(Lead currLead : updatedLeads){ 
            Lead oldLead = oldLeadsMap.get(currLead.Id);
            
            //For Tuition Fees
            if(currLead.Tuition_Fees__c != null && currLead.Tuition_Fees__c != oldLead.Tuition_Fees__c && oldLead.Tuition_Fees__c == null){
                currLead.Lead_form_Weightage__c += increasePercentage;
            }
            else if(currLead.Tuition_Fees__c == null && oldLead.Tuition_Fees__c != null){
                currLead.Lead_form_Weightage__c -= increasePercentage;
            }
        }
    }
    /********************************************************************************************************
* @author          Chandrakant More
* @description     ownerAssignmentLead this method Update lead information based on profile.
* @param           newLeadList List<Lead> : geting list from LeadTrigger.
* @return          No-return
* @date            04/05/2023(DD/MM/YYY)  
********************************************************************************************************/
    public static void ownerAssignmentLead(List<Lead> newLeadList){
        String userProfileID = UserInfo.getProfileId();
        Set<String> presalesProfileSet = new Set<String>();
        Set<String> SalesalesProfileSet = new Set<String>();
        Profile ProfileName = [SELECT Id, Name FROM Profile WHERE Id = : userProfileID LIMIT 1];
        if(!newLeadList.isEmpty() && newLeadList.size() >0){
            Group callCenterQueue = [SELECT Id, DeveloperName,Name from Group WHERE Type = 'Queue' AND Name =: System.Label.Call_Center_Queue];
            string customLablelPreSales = System.Label.Profiles_Pre_Sales_Names;
            string customLablelSales = System.Label.Profiles_Sales_Names;
            presalesProfileSet = Utility.getSetFromString(customLablelPreSales);
            SalesalesProfileSet = Utility.getSetFromString(customLablelSales);
            for(Lead objectLead : newLeadList){
                if(SalesalesProfileSet.contains(ProfileName.Name)){ 
                    objectLead.OwnerId = UserInfo.getUserId();
                    objectLead.Status = System.Label.Lead_stage_Sales_Processing;
                    objectLead.Status__c = System.Label.Lead_Status_new;
                    objectLead.StageStatusChangeTime__c = datetime.now();
                }else if(presalesProfileSet.contains(ProfileName.Name)){ 
                    objectLead.OwnerId = callCenterQueue.Id;
                    objectLead.Status = System.Label.Lead_Status_Fresh;
                    objectLead.Status__c = System.Label.Lead_Status_new; 
                    objectLead.StageStatusChangeTime__c = datetime.now();
                }
            }
        }
    }  
    /********************************************************************************************************
* @author          Avadhut Suryavanshi
* @description     updateLeadRegion this method Update lead Region based on Service branch.
* @param           newLeads List<Lead> : getting lead from LeadTrigger.
* @return          No-return
* @date            01/06/2023(DD/MM/YYY)  
********************************************************************************************************/
    public static void updateLeadRegion(List<Lead> newLeads) {
        
        Map<String, String> branchToRegionMap = new Map<String, String>();
        
        // Query Lead_Branch_Region_Setting__mdt records
        for (Lead_Branch_Region_Setting__mdt mapping : [SELECT Service_Branch__c, Region__c FROM Lead_Branch_Region_Setting__mdt]) {
            branchToRegionMap.put(mapping.Service_Branch__c, mapping.Region__c);
        }
        
        for (Lead lead : newLeads) {
            if (lead.Service_Branch__c != null && branchToRegionMap.containsKey(lead.Service_Branch__c)) {
                lead.Region__c = branchToRegionMap.get(lead.Service_Branch__c);
            }
        }
    }
    
    /********************************************************************************************************
* @author          Rohit Pardeshi
* @description     Update Course End Date
* @param           newLeads List<Lead> : getting lead from LeadTrigger.
* @return          No-return
* @date            19/06/2023(DD/MM/YYY)  
********************************************************************************************************/
    public static void updateCourseEndDate(List<Lead> newLeads) {
        List<Lead> updateLead = new List<Lead>();
        for (Lead objlead : newLeads) {
            try {
                if (objlead.Course_Start_Date__c != null && objlead.Course_Duration_Months__c != null) {
                    Integer courseDurationMonths = Integer.valueOf(objlead.Course_Duration_Months__c);
                    Date courseStartDate = objlead.Course_Start_Date__c;
                    Date courseEndDate = courseStartDate.addMonths(courseDurationMonths);
                    objlead.Course_End_Date__c = courseEndDate;
                    updateLead.add(objlead);
                }
            } catch (Exception e) {
                System.debug('An error occurred while updating Course End Date for Lead ID: ' + objlead.Id);
                System.debug(e.getMessage());
            }
        }
        
        // Update the leads with the new course end dates
        if (!updateLead.isEmpty()) {
            update updateLead;
        }
    }
    /********************************************************************************************************
* @author          Vaibhav Hinge
* @description     Lead move to lost stage then complete all related task
* @param           newLeads List<Lead> : getting lead from LeadTrigger.
* @return          No-return
* @date            07/07/2023(DD/MM/YYY)  
********************************************************************************************************/ 
    public static void updateTaskStatusComplete(Set<Id> leadId,Boolean callCenter) {
        List<Task> updateTask = new List<Task>();
        
        List<Task> getAllOpenTask = [SELECT Id,Status FROM Task WHERE WhoId =:leadId AND Status != 'Completed'];
        for (Task task : getAllOpenTask) {
            task.Status = 'Completed';
            task.Description ='This task is automatically completed since lead is lost.';
            if(callCenter){
                task.Sales_Comment__c = 'This task is automatically completed since lead is lost.';
            }
            updateTask.add(task);
        }
        if(updateTask.size()>0){
            update updateTask;
        }   
    }
    
  
}