/*********************************************************************************************
* @author          Sohail Solapure
* @description     This trigger created to update Lead's Stage/Status according to disposition
* @date            21 Feb 2023  
* @testClass:      EnquiryTriggerHandlerTest
**********************************************************************************************/

trigger TaskTrigger on Task (after insert,after update) {
    List<Task> taskList = new List<Task>();
    List<Task> UpdateReasonTask = new List<Task>();
    List<Task> IVRSendEmail = new List<Task>();
    List<Task> documentIssueCompleteTaskList = new List<Task>();
    
    Set<Id> LeadId = new Set<Id>();
    Boolean senEmailToQueue = false;
    Boolean callCountUpdate = false;
    
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        for(Task t : trigger.new){
            if(trigger.isInsert == true && t.Call_Result__c != null && t.Call_Result__c == 'Call Back' && t.call_back_date_time_New__c  != null){
                callCountUpdate = true;
            }
            if(trigger.isUpdate == true && t.Call_Result__c != null && t.Call_Result__c == 'Call Back' && t.call_back_date_time_New__c  != null && (t.Call_Result__c != trigger.oldmap.get(t.Id).Call_Result__c )){
                callCountUpdate = true;
            }
            if(trigger.isInsert == true && t.Call_Result__c != null){
                senEmailToQueue = true;
            }
            if(trigger.isUpdate == true && t.Call_Result__c != null  && (t.Call_Result__c != trigger.oldmap.get(t.Id).Call_Result__c )){
                senEmailToQueue = true;
            }
            if(trigger.isUpdate == true && (trigger.oldmap.get(t.Id).Status != t.Status) && t.Status == 'Completed' && t.Subject == 'Document Issues' && t.WhoId != null){
                documentIssueCompleteTaskList.add(t);
            }
            
            if(t.Call_Result__c != NULL){
                taskList.add(t);
            } 
            
            if(Trigger.isInsert == true && t.Call_Result__c == CommonConstant.INBOUND_MISSED_CALL_DESPOSITION && t.Call_Type__c == CommonConstant.IVR){
                LeadId.add(t.WhoId);
                IVRSendEmail.add(t);
            }
        }    
        if(taskList.size() > 0){
            TaskTriggerHandler.updateStageStatusFromDisposition(taskList,senEmailToQueue,callCountUpdate);
            // TaskTriggerHandler.createCallbackTask(taskList);
        }
        
         if(!documentIssueCompleteTaskList.IsEmpty() && documentIssueCompleteTaskList.size() > 0){
            TaskTriggerHandler.sendEmailNotificationToLoginDeskUserAfterCompleteDocumentIssue(documentIssueCompleteTaskList);
        }
        
        //Assign Inbound campaign for IVR
        if(LeadId != null){
            List<Lead> updatedLeads = [SELECT Id,Status,KYC_Consent__c,MobilePhone FROM Lead WHERE Id IN : LeadId];
            if(updatedLeads != null)
                LeadCampaignHandler.campaignAssignmentOnMissedCallDesposition(updatedLeads);
        }
        
        //If IVR then send email alert to lead owner
        if(IVRSendEmail != null)
            TaskTriggerHandler.alertLeadOwnerWhenInboundMissedCall(IVRSendEmail);
    } 
    
    //Added to add campaign as Call Back when Call Back Disposition is posted
    /*if(Trigger.isInsert && Trigger.isAfter){
for(Task t:Trigger.New){
if(t.Call_Result__c != null && t.Call_Result__c == 'Call Back')
leadIds.add(t.WhoId);
}
List<Lead> updatedLeads = [SELECT Id,Status FROM Lead WHERE Id In : leadIds AND Status IN ('Fresh', 'Suspect', 'Prospect')];
if(updatedLeads.size() > 0)
LeadCampaignHandler.assignCallBackCampaign(updatedLeads);
}*/
    
    /************************************************************************************************
* 
* @author          Dhanaji Patil
* @description     This trigger is used to calling Ozontel scheduler API.
* @Request         Task object
* @return          No return any value 
* @date            21/03/2023    
* 
**************************************************************************************************/
    
    if(Trigger.isUpdate){
        List<Task> taskListForCallSchedule = new List<Task>();
        List<Task> taskListForUpdate = new List<Task>();
        List<Task> taskListForMissedCalls = new List<Task>();
        List<Id> leadIds = new List<Id>();
        
        for(Task taskObj : Trigger.new) {
            if((string.isBlank(Trigger.OldMap.get(taskObj.id).call_back_date_time_New__c))&& null != taskObj.call_back_date_time_New__c && !string.isEmpty(taskObj.call_back_date_time_New__c)) {
                taskListForCallSchedule.add(taskObj); 
            }
            if((string.isBlank(Trigger.OldMap.get(taskObj.id).Call_Result__c))&& null != taskObj.Call_Result__c && !string.isEmpty(taskObj.Call_Result__c)){
                taskListForUpdate.add(taskObj);
            }
            if(!string.isEmpty(taskObj.agentStatus__c) && taskObj.agentStatus__c.equalsIgnoreCase(CommonConstant.USER_DESCONNECT_AGENT_STATUS) && taskObj.Call_Result__c == null){
                taskListForMissedCalls.add(taskObj);
            }
        }
        /***************** this method used to schedule new call with ozontel****************/
        if(taskListForCallSchedule.size() > 0){
            OzontelCampaignDataSchedule.ozontelCampaignDataSchedule(taskListForCallSchedule);
        }
        
        /****************** this is used for update the task subject and status ***************/
        if(taskListForUpdate.size() > 0){
            TaskTriggerHandler.updateSubjectStatusFromDisposition(taskListForUpdate);
        }
        
        /****************** this is used for update the task subject as missed call ***************/
        if(taskListForMissedCalls.size() > 0){
            TaskTriggerHandler.updateMissedCallSubjectFromDisposition(taskListForMissedCalls);
        }
    }
    /**********Method Used for If Call Back is added to the lead,
then the old Call Back tasks should be marked as Completed.***************/
    if(trigger.isAfter && ( trigger.isInsert || trigger.isUpdate) ){
        TaskTriggerHandler.createCallbackTask(trigger.new);
    }
    
}