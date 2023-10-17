/*********************************************************************************************
* @author          Thinqloud Solutions (Rohit Pardeshi)
* @description     This class we are using for duplication Management.
* @date            06/02/2023    
* @testClass: 
**********************************************************************************************/
public class DuplicateManagement {
/********************************************************************************************************
* @author          Rohit Pardeshi
* @description     This method we are using to find duplicate record in case of Bulk Lead opload and Partner API
* @param           List<Lead> newLeadList : List of new list, String sourceName
* @return          set<Id> : By checking duplicate paramaters it will return exact set of duplicate Ids
*                       
* @date            25/03/2017    
********************************************************************************************************/       
    public static set<Id> leadDuplicate(List<Lead> newLeadList, String sourceName)
    {
        Set<Id> userId = New Set<Id>();
        Map<Id, Boolean> userIdAndStatus = New Map<Id, Boolean>();
        Set<Id> duplicateSetId = new Set<Id>();
        Id leadOwnerId;
        Id leadRecordId;
        Set<String> closecovertedset = new Set<String>();
        Map<Id, Id> dupRecordIdvsOwnerd = new Map<Id, Id>();
        closecovertedset.add(CommonConstant.LOST_STAGE);
        closecovertedset.add(CommonConstant.CONVERTED_STAGE);
        Dedupe_Management__c cs = Dedupe_Management__c.getValues('Manage Dedupe Days');
        Integer closeddays = Integer.valueOf(cs.Lead_stage_is_closed__c);
        Integer converteddays = Integer.valueOf(cs.Lead_stage_converted__c);
        LeadWrapper wrapper = getDuplicateLead(newLeadList);
        /***************Get User status ****************************************************************/
        for(Lead getownerId : wrapper.leads){
            userId.add(getownerId.OwnerId);
        }
        
        List<User> userStatus = [SELECT Id , Name, IsActive  FROM User WHERE Id IN : userId];
        
        for(User getuser : userStatus){
            userIdAndStatus.put(getuser.Id, getuser.IsActive);
        }
        
        /***************Get Exception Queue *******************************************************/
        Group queueId = [SELECT Id, Name, Type from Group WHERE Type = 'Queue' AND Name =: System.Label.Exception_Queue];
        
        /***************Action **********************************************************/
        if(wrapper.leads.size() > 0){
            
            for(Lead la : wrapper.leads){
                //Lead Stage not equal to Lost & Converted
                if(!closecovertedset.contains(la.Status)){
                    duplicateSetId.add(la.Id);
                    leadRecordId = la.Id;
                    if(userIdAndStatus.get(la.OwnerId) ==  true){
                        leadOwnerId = la.OwnerId;
                    }else if(userIdAndStatus.get(la.OwnerId) ==  false){
                        leadOwnerId = queueId.Id;                        
                    }else{
                        leadOwnerId = la.OwnerId;
                    }
                    dupRecordIdvsOwnerd.put(la.Id, leadOwnerId);
                    //Lead stage equal to Lost
                }else if(la.Status == CommonConstant.LOST_STAGE){
                    if(Date.today().addDays(-closeddays) <= la.Lastmodifieddate){
                    //if(System.now().addMinutes(-closeddays) <= la.Lastmodifieddate){
                        duplicateSetId.add(la.Id);
                        leadRecordId = la.Id;
                        if(userIdAndStatus.get(la.OwnerId) == true){
                            leadOwnerId = la.OwnerId;
                        }else if(userIdAndStatus.get(la.OwnerId) == false){
                            leadOwnerId = queueId.Id;
                        }else{
                            leadOwnerId = la.OwnerId;  
                        }
                    }
                    dupRecordIdvsOwnerd.put(la.Id, leadOwnerId);
                    //Lead stage equal to converted
                }else if(la.Status == CommonConstant.CONVERTED_STAGE){
                     if(Date.today().addDays(-converteddays) <= la.Lastmodifieddate){
                    //if(System.now().addMinutes(-converteddays) <= la.Lastmodifieddate){
                        duplicateSetId.add(la.Id);
                        //duplicateSetId.add(la.ConvertedOpportunityId);
                        leadRecordId = la.ConvertedOpportunityId;
                        if(userIdAndStatus.get(la.ConvertedOpportunity.OwnerId) ==  true){
                            leadOwnerId = la.ConvertedOpportunity.OwnerId;
                        }else if(userIdAndStatus.get(la.ConvertedOpportunity.OwnerId) ==  false){
                            leadOwnerId = queueId.Id;
                        }else{
                            leadOwnerId = la.ConvertedOpportunity.OwnerId;
                        }
                        dupRecordIdvsOwnerd.put(la.ConvertedOpportunityId, leadOwnerId);
                    }  
                }
            }  
            
            if(leadOwnerId != null){
                try{
                    DuplicateManagement.createTaskRelatedToLead(dupRecordIdvsOwnerd, sourceName);
                    DuplicateManagement.sendNotificationToLeadOwner(dupRecordIdvsOwnerd);
                }catch(Exception e){
                }
            }
        } 
        return duplicateSetId;
    }
    
/********************************************************************************************************
* @author          Rohit Pardeshi
* @description     This Method is use to send Email Notification to Duplicate Lead Owner
* @param           Map<Id, Id> dupRecordIdvsOwnerd
* @return		   NA
* @date            12/04/2023 
********************************************************************************************************/
    public static void sendNotificationToLeadOwner(Map<Id, Id> dupRecordIdvsOwnerd)
    {
        List<String> recipientEmails = new List<String>();
        List<Id> queueUsers = new List<Id>();
        Map<Id, Id> userIdMap = new Map<Id, Id>();
        Map<Id, Id> groupIdMap = new Map<Id, Id>();
        Map<Id, List<String>> recordIdVsEmail = new Map<Id, List<String>>();
        Map<Id, String> UserIdVsEmail = New Map<Id, String>();
        Map<Id, Set<Id>> groupIdVsUsers = New Map<Id, Set<Id>>();
        Map<Id, Lead> leadMap = New Map<Id, Lead>();
        Map<Id, Opportunity> opportunityMap = New Map<Id, Opportunity>();
        Map<Id, List<String>> groupIdVsUsersEmail = New Map<Id, List<String>>();
        Set<Id> leadRecordId = New Set<Id>();
        Set<Id> opportunityRecordId = New Set<Id>();
        string emailBody;
        
        List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
        
        try {
            EmailTemplate invTemplate = [SELECT Id, Name, Subject, HtmlValue, Body FROM EmailTemplate WHERE Name =: System.Label.Lead_is_showing_interest_again];
            List<OrgWideEmailAddress> orgEmailAddress=[select Id from OrgWideEmailAddress WHERE DisplayName =: System.Label.Organization_Wide_Email_Addresses];
            
            //string Name = invTemplate.Name;
            string subject = invTemplate.subject;
            emailBody = invTemplate.HtmlValue;
            
            for (Id recordId : dupRecordIdvsOwnerd.keySet()) {
                Id ownerId = dupRecordIdvsOwnerd.get(recordId);
                // get the object type of the ID value
                String objectType = ownerId.getSObjectType().getDescribe().getName();
                
                if (objectType == 'User') {
                    userIdMap.put(recordId, ownerId);
                } else if (objectType == 'Group') {
                    groupIdMap.put(recordId, ownerId);
                }
                if (String.valueOf(recordId).startsWith('006')) {
                    opportunityRecordId.add(recordId);
                } else {
                    leadRecordId.add(recordId);
                }
            }

            if (opportunityRecordId != null && !opportunityRecordId.isEmpty()){
                List<Opportunity> oppList = [SELECT Id, Name, Applicant_Mobile_Number__c, Applicant_Email__c FROM Opportunity WHERE Id IN: opportunityRecordId];
                
                For(Opportunity oppObj : oppList){
                    opportunityMap.put(oppObj.Id, oppObj);
                }
            }
            
            
            if (!userIdMap.isEmpty()){
                List<User> userList = [SELECT Id, Name, Email,IsActive FROM User WHERE Id IN: userIdMap.values()];
                
                for (User objUser : userList) {
                    Id userId = objUser.Id;
                    String userEmail = objUser.Email;
                    
                    for (Id recordId : userIdMap.keySet()) {
                        if (userIdMap.get(recordId) == userId && objUser.IsActive == true) {
                            if (!recordIdVsEmail.containsKey(recordId)) {
                                recordIdVsEmail.put(recordId, new List<String>());
                            }
                            recordIdVsEmail.get(recordId).add(userEmail);
                        }
                    }
                }
            }
            
            if(!groupIdMap.isEmpty()){
                for (GroupMember member : [SELECT UserOrGroupId, GroupId FROM GroupMember WHERE GroupId IN: groupIdMap.values()]) {
                    if (!groupIdVsUsers.containsKey(member.GroupId)) {
                        groupIdVsUsers.put(member.GroupId, new Set<Id>());
                    }
                    groupIdVsUsers.get(member.GroupId).add(member.UserOrGroupId);
                }
                
                List<Id> userIds = new List<Id>();
                for (Set<Id> userIdSet : groupIdVsUsers.values()) {
                    userIds.addAll(userIdSet);
                }
                
                List<User> groupUserList = [SELECT Id, Name, Email, IsActive FROM User WHERE Id IN: userIds];
                
                for (User objUser : groupUserList) {
                    if (objUser.IsActive == true) {
                        for (Id groupId : groupIdVsUsers.keySet()) {
                            if (groupIdVsUsers.get(groupId).contains(objUser.Id)) {
                                if (!groupIdVsUsersEmail.containsKey(groupId)) {
                                    groupIdVsUsersEmail.put(groupId, new List<String>());
                                }
                                groupIdVsUsersEmail.get(groupId).add(objUser.Email);
                            }
                        }
                    }
                }
                
                for (Id groupId : groupIdMap.keySet()) {
                    Id recordId = groupIdMap.get(groupId); // Get the value associated with the current groupId
                    if (groupIdVsUsersEmail.containsKey(recordId)) {
                        List<String> emailList = groupIdVsUsersEmail.get(recordId);
                        
                        if (!recordIdVsEmail.containsKey(groupId)) {
                            recordIdVsEmail.put(groupId, new List<String>());
                        }
                        recordIdVsEmail.get(groupId).addAll(emailList);
                    }
                }
            }
            
            for (Id recordId : dupRecordIdvsOwnerd.keySet()) {
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                if(orgEmailAddress.size() > 0){
                    message.setOrgWideEmailAddressId(orgEmailAddress[0].Id);  
                }
                message.setSubject(subject);
                message.setTreatBodiesAsTemplate(True); 
                if (recordIdVsEmail.containsKey(recordId)) {
                    List<String> emailAddresses = recordIdVsEmail.get(recordId);
                    message.setToAddresses(emailAddresses);
                }
                message.setSaveAsActivity(true);
                message.setTreatTargetObjectAsRecipient(false);
                
                if (String.valueOf(recordId).startsWith('006')) {
                    message.setWhatId(recordId);
                    emailBody = emailBody.replace('{!Lead.Name}', opportunityMap.get(recordId).Name);
                    emailBody = emailBody.replace('{!Lead.MobilePhone}', opportunityMap.get(recordId).Applicant_Mobile_Number__c);
                    emailBody = emailBody.replace('{!Lead.Email}', opportunityMap.get(recordId).Applicant_Email__c);
                } else {
                    message.setTargetObjectId(recordId);
                }
                message.setHtmlBody(emailBody);
                emailMessageList.add(message);   
            }
            
            if(emailMessageList.size() > 0){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(emailMessageList);
                if(results.size() > 0){
                    if(results.get(0).isSuccess()){
                    }
                }  
            }
        }catch(Exception e) {
            
        }
    }
    
/********************************************************************************************************
* @author          Rohit Pardeshi
* @description     This Method is use to get Duplicate lead record based on Email & Mobile match
* @param           List<Lead> newLeadList : List of new list
* @return          LeadWrapper : Return Wrapper
* @date           27/04/2023 
********************************************************************************************************/
    public static LeadWrapper getDuplicateLead(List<Lead> newLeadList)
    {
        Map<String, Lead> phoneVsContextLead = new Map<String, Lead>();
        Map<String, Lead> emailVsContextLead = new Map<String, Lead>();
        Map<String, Lead> firstNameVsContextLead = new Map<String, Lead>();
        
        Map<String, Id> fnameMobileEmailMatch = new Map<String, Id>();
        Map<String, Id> fnameMobileMatch = new Map<String, Id>();
        Map<String, Id> fnameEmailMatch = new Map<String, Id>();
        Map<String, Id> mobileEmailMatch = new Map<String, Id>();
        Map<String, Id> onlyMobileMatch = new Map<String, Id>();
        Map<String, Id> onlyEmailMatch = new Map<String, Id>();
        List<Lead> duplicateLeadList = new List<Lead>();
        LeadWrapper leadWrapper = null;
        Id currentLeadId;
        String errorMessage;
        
        Map<Id, String> idandSource = new Map<Id, String>();
        
        try{
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
            List<Lead> dupLead = new List<Lead>([SELECT Id, Status, LastModifiedDate, FirstName, Email, MobilePhone FROM Lead 
                                                 WHERE (MobilePhone IN :phoneVsContextLead.keySet() OR Email IN :emailVsContextLead.keySet()) AND
                                                 Id !=: currentLeadId ORDER BY LastModifiedDate ASC]);
            
            /***************Collect duplicate lead as per dedupe parameter sequence wise in MAP********************************************/   
            for(Lead duplicateLead : dupLead)
            {
                fnameMobileEmailMatch.put(duplicateLead.FirstName + duplicateLead.MobilePhone + duplicateLead.Email, duplicateLead.Id);
                fnameMobileMatch.put(duplicateLead.FirstName + duplicateLead.MobilePhone, duplicateLead.Id);
                fnameEmailMatch.put(duplicateLead.FirstName + duplicateLead.Email, duplicateLead.Id);
                mobileEmailMatch.put(duplicateLead.MobilePhone + duplicateLead.Email, duplicateLead.Id);
                onlyMobileMatch.put(duplicateLead.MobilePhone, duplicateLead.Id);
                onlyEmailMatch.put(duplicateLead.Email, duplicateLead.Id);
            }
            
            /***************Check and Get exact match duplicate lead in a MAP********************************************/        
            for(Lead leadObj : newLeadList)
            {
                if(fnameMobileEmailMatch.containsKey(leadObj.FirstName + leadObj.MobilePhone + leadObj.Email)){
                    idandSource.put(fnameMobileEmailMatch.get(leadObj.FirstName + leadObj.MobilePhone + leadObj.Email), leadObj.Source_Category__c);
                    errorMessage = CommonConstant.FNAME_MOBILE_EMAIL_MATCH;
                }else if(fnameMobileMatch.containsKey(leadObj.FirstName + leadObj.MobilePhone)){
                    idandSource.put(fnameMobileMatch.get(leadObj.FirstName + leadObj.MobilePhone), leadObj.Source_Category__c);
                    errorMessage = CommonConstant.FNAME_MOBILE_MATCH;
                }else if(fnameEmailMatch.containsKey(leadObj.FirstName + leadObj.Email)){
                    idandSource.put(fnameEmailMatch.get(leadObj.FirstName + leadObj.Email), leadObj.Source_Category__c);
                    errorMessage = CommonConstant.FNAME_EMAIL_MATCH;
                }else if(mobileEmailMatch.containsKey(leadObj.MobilePhone + leadObj.Email)){
                    idandSource.put(mobileEmailMatch.get(leadObj.MobilePhone + leadObj.Email), leadObj.Source_Category__c);
                    errorMessage = CommonConstant.MOBILE_EMAIL_MATCH;
                }else if(onlyMobileMatch.containsKey(leadObj.MobilePhone)){
                    idandSource.put(onlyMobileMatch.get(leadObj.MobilePhone), leadObj.Source_Category__c);
                    errorMessage = CommonConstant.MOBILE_MATCH;
                }else if(onlyEmailMatch.containsKey(leadObj.Email)){
                    idandSource.put(onlyEmailMatch.get(leadObj.Email), leadObj.Source_Category__c);
                    errorMessage = CommonConstant.EMAIL_MATCH;
                }
            }
            
            duplicateLeadList = [SELECT Id, OwnerId ,Status, ConvertedOpportunityId, ConvertedOpportunity.OwnerId,CreatedDate,
                                 FirstName, Email, MobilePhone,Lastmodifieddate FROM Lead WHERE Id IN :idandSource.keySet()];

            leadWrapper = new LeadWrapper(duplicateLeadList, errorMessage);
            
        }catch(Exception e){
        }
        
        return leadWrapper;
    }
    
/********************************************************************************************************
* @author          Rohit Pardeshi
* @description     LeadWrapper Class
* @param           NA
* @return          NA
* @date            27/04/2023   
********************************************************************************************************/
    public class LeadWrapper {
		/*
        * @author           Rohit Pardeshi
        * @description      leads
        * @Arguments        NA
        * @param            NA
        * @return           List<Lead>
        * @date             27/04/2023     
        */
        public List<Lead> leads {get; set;}
        /*
        * @author           Rohit Pardeshi
        * @description      errorMessage
        * @Arguments        NA
        * @param            NA
        * @return           String
        * @date             27/04/2023     
        */
        public String errorMessage {get; set;}
        /*
        * @author           Rohit Pardeshi
        * @description      LeadWrapper
        * @Arguments        NA
        * @param            List<Lead> duplicateLeadList, String errorMessage
        * @return           NA
        * @date             27/04/2023     
        */
        public LeadWrapper(List<Lead> duplicateLeadList, String errorMessage) {
            leads = duplicateLeadList;
            this.errorMessage = errorMessage;
        }
    } 
    
    /********************************************************************************************************
* @author          Rohit Pardeshi
* @description     This Method is to create Task on duplicate lead to lead owner
* @param           Map<Id, Id> dupRecordIdvsOwnerd, String sourceName
* @return          NA                      
* @date            27/04/2023 
********************************************************************************************************/
   public static void createTaskRelatedToLead(Map<Id, Id> dupRecordIdvsOwnerd, String sourceName){
    try {
        List<Task> tasksToInsert = new List<Task>();
        
        for (Id recordId : dupRecordIdvsOwnerd.keySet()) {
            Id ownerId = dupRecordIdvsOwnerd.get(recordId);
            
            Task tsk = new Task();
            tsk.Subject = CommonConstant.TASK_SUBJECT;
            tsk.Status = CommonConstant.TASK_STATUS;
            tsk.Priority = CommonConstant.TASK_PRIORITY;
            tsk.Type = 'Task'; //ARS 28-JUN
            if (sourceName != null) {
                tsk.Source_Name__c = sourceName; 
            }
            tsk.OwnerId = ownerId;
            
            if (String.valueOf(recordId).startsWith('006')) {
                // If recordId starts with '00Q', it's an Opportunity Id
                tsk.WhatId = recordId;
            } else {
                // Otherwise, assume it's a Lead Id
                tsk.WhoId = recordId;
            }
            
            tasksToInsert.add(tsk);
        }
        
        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    } catch (Exception e) {
        // Handle the exception here
    }
}

}