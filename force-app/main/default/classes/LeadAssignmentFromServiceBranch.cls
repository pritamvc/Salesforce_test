/**
 * Author: Sohail Solapure
 * @description This class is used to assign a queue as per the Service Branch.
 * 
 * @date 14 Apr 2023
 * @testClass Include the name of the test class that tests this functionality.
 * @param Describe any relevant parameters or arguments here.
 */
public class LeadAssignmentFromServiceBranch {
    
    //To store the counts of lead assinged in current transaction
    private static Map<Id, Integer> leadCounts = new Map<Id, Integer>();

    //To store the exception queue in map
    private static Group exceptionQueues = new Group();

    //To get User Emails into map
    private static Map<Id,User> usersMap = new Map<Id,User>([SELECT Id,Email,UserRole.Name FROM User WHERE IsActive = true]);

    //To get queues for ASM
    private static Map<String, List<Group>> asmQueuesMap = new Map<String, List<Group>>();

    /**
     * Author: Sohail Solapure
     * @description This method assigns a lead owner to a queue or user based on the Service Branch.
     *
     * @param updatedLeads The list of leads to be processed for assignment.
     * @date 14 Apr 2023
     */
    public static void assignQueue(List<Lead> updatedLeads) {
        Integer counter = 0;
        RoundRobinUserCount__c userCount;

        //To store Ids and map for Lead assignment
        //Set<String> partnerIds = new Set<String>();
        List<String> userWiseQueue = new List<String>();
        Map<String,Lead> userUpdateLead = new Map<String,Lead>();

        Map<Id, RoundRobinUserCount__c> userCountsToUpdate = new Map<Id, RoundRobinUserCount__c>();
        Map<Id,Source__c> sourceObjectMap = new Map<Id,Source__c>([SELECT Id,Name,Partner_Name__c,Preferred_Source__c FROM Source__c WHERE Id IN (SELECT Source_Name__c FROM Lead WHERE Id IN :updatedLeads)]);
        
        /**To store partner accounts in map
        for(Source__c source : sourceObjectMap.values()){
            if(source.Partner_Name__c != null){
                partnerIds.add(source.Partner_Name__c);
            }
        }
        Map<Id,Account> partnerAccountMap = new Map<Id,Account>([SELECT Id,Is_Region_Specific__c,Preferred_Partner__c FROM Account WHERE Id In: partnerIds]);*/
        
        //To fetch exception queues
        exceptionQueues = [SELECT Id,Name FROM Group WHERE Type =: CommonConstant.QUEUE AND Name LIKE :CommonConstant.SALES_QUEUE LIMIT 1];

        //Fetch the ASM Queues in one go
        List<Group> asmQueues = [SELECT Id, Name,(Select Id,UserOrGroupId from GroupMembers WHERE UserOrGroupId IN (SELECT Id FROM User WHERE Profile.Name = 'Sales Manager' AND IsActive=true) LIMIT 1) FROM Group WHERE Type =: CommonConstant.QUEUE AND Name LIKE: CommonConstant.ASM_LIKE];
        for (Group queue : asmQueues) { 
            String branchName = queue.Name.substringBefore(CommonConstant.USER_ROLE_ASM).trim();           
            if (!asmQueuesMap.containsKey(branchName)) {
                asmQueuesMap.put(branchName, new List<Group>());
            }
            asmQueuesMap.get(branchName).add(queue);
        }

        //Iterate the leads
        for(Lead currentLead : updatedLeads){
            String queueName;
            try{
                //If Service branch is "Contact Center + Service branch" (Ex. CC PUNE)
                if(currentLead.Service_Branch__c.startsWith(CommonConstant.CC_BRANCH)){
                    //If Source is tagged
                    if(currentLead.Source_Name__c != null){
                        
                        Source__c sourceName = sourceObjectMap.get(currentLead.Source_Name__c);
                        //String accId = sourceObjectMap.get(currentLead.Source_Name__c).Partner_Name__c;

                        //Account partnerAccount;
                        if(sourceName != null){
                            //partnerAccount = partnerAccountMap.get(accId);
                            if(sourceName.Preferred_Source__c != null){
                            //If partner is not preferred partner then assign to Exception Queue
                                if(sourceName.Preferred_Source__c == 'No'){
                                    currentLead = assignExceptionQueue(currentLead);
                                }

                                //If partner is region specific
                                else{
                                    //Currently commented Sohail 21 Aug will discuss on region
                                    //If region is present then assign to specific Partner's region's queue users
                                    /*if(partnerAccount.Is_Region_Specific__c == true){  
                                        if(currentLead.Region__c != null){
                                            queueName = sourceName+CommonConstant.SPACE+currentLead.Region__c+CommonConstant.SPACE+CommonConstant.QUEUE;
                                            userWiseQueue.add(queueName);
                                            userUpdateLead.put(queueName,currentLead);  
                                        }
                                    }

                                    //If region is not then assign to Partner's queue users
                                    else{ */
                                    String targetSource = '%'+sourceName.Name+'%';
                                    RoundRobinUserCount__c sourceQueue = [SELECT Id,Partner_Names__c,Queue_Name__c FROM RoundRobinUserCount__c WHERE Partner_Names__c LIKE :targetSource LIMIT 1];
                                    if(sourceQueue != null){
                                        queueName = sourceQueue.Queue_Name__c;
                                        //queueName = sourceName+CommanConstant.SPACE+CommanConstant.QUEUE;
                                        userWiseQueue.add(queueName);
                                        userUpdateLead.put(queueName,currentLead);  
                                        
                                    }
                                }  
                            }
                        }     
                    }                          
                }else{
                //If service branch is other than "Contact Center" then assign to respective Branch ASM
                
                userCount = RoundRobinUserCount__c.getInstance(currentLead.Service_Branch__c);
                counter = (Integer)userCount.Current_User_Count__c;
                currentLead = assignASMQueue(currentLead,currentLead.Service_Branch__c,counter,userCount,userCountsToUpdate);
                }   
            }
            catch(Exception e){
                e.getMessage();
            }     
        }

        if(userUpdateLead.size() > 0){
            assignUserRegionWise(userUpdateLead,userWiseQueue);
        }

        //Update the counter
        update userCountsToUpdate.values();
    }

    /**
     * Author: Sohail Solapure
     * @description This method assigns the stage owner to the Login Desk queue or user based on the Service Branch.
     *  
     * @param updatedLeads The list of leads to be processed for assignment.
     * @date 14 Apr 2023
     */
    public static void assignLoginDeskUser(List<Lead> updatedLeads){
        List<String> queueName = new List<String>();
        List<Lead> loginDeskLeads = new List<Lead>();

        for(Lead currentLead : updatedLeads){
            if(currentLead.Service_Branch__c != null){
                if(currentLead.Service_Branch__c.startsWith(CommonConstant.CC_BRANCH)){
                    queueName.add(CommonConstant.CONTACT_CENTER+CommonConstant.SPACE+CommonConstant.LOGIN_DESK);
                    loginDeskLeads.add(currentLead);
                }
                else{
                    queueName.add(currentLead.Service_Branch__c+CommonConstant.SPACE+CommonConstant.LOGIN_DESK);
                    loginDeskLeads.add(currentLead);
                }
                
            }   
            if(loginDeskLeads.size() > 0){
                assignLDUser(loginDeskLeads,queueName);
            }
        }
    }
    
    /**
     * Author: Sohail Solapure
     * @description This method assigns the ASM Queue to a lead owner.
     *
     * @param lead The lead to be assigned to the ASM Queue.
     * @param branch The branch associated with the assignment.
     * @param counter The counter value.
     * @param userCount The user count value.
     * @param userCountsToUpdate The user counts to update.
     * @date 14 Apr 2023
     */
    public static Lead assignASMQueue(Lead currLead,String branch,Integer counter,RoundRobinUserCount__c userCount,Map<Id, RoundRobinUserCount__c> userCountsToUpdate){
        //Map<Id, RoundRobinUserCount__c> userCountsToUpdate = new Map<Id, RoundRobinUserCount__c>();
        List<Group> asmQueue = asmQueuesMap.get(branch);

        if(asmQueue.size() > 0){
            Integer queueIndex = Math.mod(counter, asmQueue.size());
            List<GroupMember> targetASMQueueMembers = asmQueue[queueIndex].GroupMembers;
            if(targetASMQueueMembers != null){
                currLead.OwnerId = targetASMQueueMembers[0].UserOrGroupId;
                currLead.Assigned_Queue__c = asmQueue[queueIndex].Id;
                counter++;
                updateUserCount(userCount,counter,userCountsToUpdate,asmQueue.size());
            } 
        } 
        //update userCountsToUpdate.values();
        return currLead;     
    }

    /**
     * Author: Sohail Solapure
     * @description This method assigns users as per round robin for a specified queue.
     * 
     * @param updatedLeads The map of updated leads to be processed for assignment.
     * @param queueName The name of the queue to which users will be assigned.
     * @date 14 Apr 2023
     */
    public static void assignUserRegionWise(Map<String,Lead> updatedLeads,List<String> queueName){
        Integer counter = 0;
        RoundRobinUserCount__c userCount;
        Map<Id, RoundRobinUserCount__c> userCountsToUpdate = new Map<Id, RoundRobinUserCount__c>();
        Map<Id,Group> queueMap = new Map<Id,Group>([SELECT Name,(SELECT UserOrGroupId FROM GroupMembers) FROM Group WHERE Type =: CommonConstant.QUEUE AND Name LIKE :queueName]);

        Map<String, Group> updatedQueueMap = new Map<String, Group>();
        for (Id groupId : queueMap.keySet()) {
            Group currGroup = queueMap.get(groupId);
            updatedQueueMap.put(currGroup.Name, currGroup);
        }

        Group targetQueue = new Group();
        
        for (String key : updatedLeads.keySet()){
            Lead currLead = updatedLeads.get(key);
            try{
                userCount = RoundRobinUserCount__c.getInstance(key);
                counter = (Integer)userCount.Current_User_Count__c;
                targetQueue = updatedQueueMap.get(key);

                if(targetQueue != null){
                    List<GroupMember> members = targetQueue.GroupMembers;
                    if(!members.isEmpty()){
                        Integer memberIndex = Math.mod(counter, members.size());
                        currLead.OwnerId = members[memberIndex].UserOrGroupId;
                        counter++;
                        updateUserCount(userCount, counter, userCountsToUpdate, members.size());
                    }  
                }
            }
            catch(Exception e){
                e.getMessage();
            }   
        }
        update userCountsToUpdate.values();
    }

    /**
     * Author: Sohail Solapure
     * @description This method assigns users as per round robin for the Login Desk queue.
     *
     * @param updatedLeads The list of updated leads to be processed for assignment.
     * @param queueName The name of the queue (Login Desk) to which users will be assigned.
     * @date 14 Apr 2023
     */
    public static void assignLDUser(List<Lead> updatedLeads,List<String> queueName){
        Integer counter = 0;
        RoundRobinUserCount__c userCount;
        Map<Id, RoundRobinUserCount__c> userCountsToUpdate = new Map<Id, RoundRobinUserCount__c>();
        Map<Id,Group> queueMap = new Map<Id,Group>([SELECT Name,(SELECT UserOrGroupId FROM GroupMembers) FROM Group WHERE Type =: CommonConstant.QUEUE AND Name LIKE :queueName]);
        Map<String, Group> updatedQueueMap = new Map<String, Group>();
        for (Id groupId : queueMap.keySet()) {
            Group currGroup = queueMap.get(groupId);
            updatedQueueMap.put(currGroup.Name, currGroup);
        }

        Group targetQueue = new Group();
        for(Lead currLead : updatedLeads){
            try{
                string serviceBranch;
                if (currLead.Service_Branch__c.startsWith(CommonConstant.CC_BRANCH)) {   
                   serviceBranch = CommonConstant.CONTACT_CENTER; 
                  }else{
                   serviceBranch =currLead.Service_Branch__c; 
                }
                userCount = RoundRobinUserCount__c.getInstance(serviceBranch+CommonConstant.LD);
                counter = (Integer)userCount.Current_User_Count__c;
                targetQueue = updatedQueueMap.get(serviceBranch+CommonConstant.SPACE+CommonConstant.LOGIN_DESK);
                if(targetQueue != null){
                    List<GroupMember> members = targetQueue.GroupMembers;
                    if(!members.isEmpty()){
                        Integer memberIndex = Math.mod(counter, members.size());
                        currLead.Stage_Owner__c = members[memberIndex].UserOrGroupId;
                        counter++;
                        updateUserCount(userCount, counter, userCountsToUpdate, members.size());
                    }  
                }
            }
            catch(Exception e){
                e.getMessage();
            }   
        }
        update userCountsToUpdate.values();
    }

    /**
     * Author: Sohail Solapure
     * @description This method is used to update the user count in the round-robin mechanism.
     *
     * @param userCount The RoundRobinUserCount__c object representing the user count to update.
     * @param counter The current counter value.
     * @param userCountsToUpdate A map of user IDs to RoundRobinUserCount__c objects to update.
     * @param maxCount The maximum count value to determine the reset point.
     * @date 14 Apr 2023
     */
    public static void updateUserCount(RoundRobinUserCount__c userCount,Integer counter,Map<Id, RoundRobinUserCount__c> userCountsToUpdate,Integer maxCount){
        if(counter == maxCount){
            userCount.Current_User_Count__c = 0;
        }
        else {
            userCount.Current_User_Count__c = counter;
        }
        userCountsToUpdate.put(userCount.Id, userCount);
    }

   /**
     * Author: Sohail Solapure
     * @description This method is used to assign the owner of a lead to the exception queue.
     *
     * @param currLead The lead for which the owner will be assigned to the exception queue.
     * @return Lead The lead with updated owner assignment.
     * @date 14 Apr 2023
     */
    public static Lead assignExceptionQueue(Lead currLead){
        if(exceptionQueues != null){
            currLead.OwnerId = exceptionQueues.Id;
        }
        return currLead;
    }

   /**
    * Author: Sohail Solapure
    * @description This method is used to send an email alert.
    *
    * @param updatedLeads The list of leads for which email alerts will be triggered.
    * @date 14 Apr 2023
    */
    public static void sendEmailAlert(List<Lead> updatedLeads){
        EmailTemplate leadEmailTemplate = [SELECT Id,Body,Subject from EmailTemplate where DeveloperName =: CommonConstant.LEAD_ASSIGNMENT];
        OrgWideEmailAddress orgEmailAdd = [SELECT Id, Address, DisplayName from OrgWideEmailAddress limit 1];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Set<Id> assignedQueueIds = new Set<Id>();
        List<User> userList = new List<User>();
        
        for(Lead currLead : updatedLeads){
            assignedQueueIds.add(currLead.OwnerId);
        }
        Map<Id,Group> assignedQueueMap = new Map<Id,Group>([SELECT Id, Name,(SELECT UserOrGroupId FROM GroupMembers) FROM Group WHERE Type =: CommonConstant.QUEUE AND Id =:assignedQueueIds]);

        for(Lead currLead : updatedLeads){
            mail.setTemplateId(leadEmailTemplate.Id);
            mail.setSaveAsActivity(true);
            mail.setTargetObjectId(currLead.Id);
            mail.setTreatTargetObjectAsRecipient(false);
            mail.setOrgWideEmailAddressId(orgEmailAdd.Id);

            if(currLead.Status == CommonConstant.SALES_PROCESSING){
                Group assignedQueue = assignedQueueMap.get(currLead.OwnerId);
                if(assignedQueue != null){
                    List<String> userIds = new List<String>();
                    for(GroupMember gm : assignedQueue.GroupMembers){
                        userIds.add(gm.UserOrGroupId);
                    }
                    for (String userId : userIds) {
                        Id idValue = (Id)userId;
                        if (usersMap.containsKey(idValue)) {
                            userList.add(usersMap.get(idValue));
                        }
                    }
                    List<String> emailAddresses = new List<String>();
                    
                    for(User u : userList){
                        //if(u.UserRole.Name == 'ASM'){
                            emailAddresses.add(u.Email); 
                        //}
                    }

                    mail.setToAddresses(emailAddresses); 
                }
                else{
                    mail.setToAddresses(new list<string>{currLead.OwnerId}); 
                }
            }
            else if(currLead.Status == CommonConstant.APPLYING){
                if(currLead.Stage_Owner__c != null){
                    mail.setToAddresses(new list<string>{currLead.Stage_Owner__c}); 
                }
            }
            try{
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }catch(Exception e){
                e.getMessage();
            }
        }
    }

    /**
     * Author: Sohail Solapure
     * @description This method is used to send an email alert after escalation.
     *
     * @param updatedLeads The list of leads for which email alerts will be triggered after escalation.
     * @date 14 Apr 2023
     */
    @InvocableMethod(label='Send Escalate Email')
    public static void sendEmailFromEscalate(List<Lead> updatedLeads){
        EmailTemplate leadEmailTemplate = [SELECT Id,Body,Subject from EmailTemplate where DeveloperName =: CommonConstant.LEAD_ESCALATION];
        OrgWideEmailAddress orgEmailAdd = [SELECT Id, Address, DisplayName from OrgWideEmailAddress limit 1];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       
        mail.setTemplateId(leadEmailTemplate.Id);
        mail.setSaveAsActivity(true);
        mail.setTreatTargetObjectAsRecipient(false);
        mail.setOrgWideEmailAddressId(orgEmailAdd.Id);

        Group callCenterExceptionQueue = [SELECT Id, Name,(SELECT UserOrGroupId FROM GroupMembers) FROM Group WHERE Type =: CommonConstant.QUEUE AND Name LIKE :CommonConstant.CC_QUEUE];
        Group salesProcessingExceptionQueue = [SELECT Id, Name,(SELECT UserOrGroupId FROM GroupMembers) FROM Group WHERE Type =: CommonConstant.QUEUE AND Name LIKE :CommonConstant.SALES_QUEUE];
        Group applyingExceptionQueue = [SELECT Id, Name,(SELECT UserOrGroupId FROM GroupMembers) FROM Group WHERE Type =: CommonConstant.QUEUE AND Name LIKE :CommonConstant.APPLYING_QUEUE];
  
        for(Lead currLead : updatedLeads){
            List<String> userIds = new List<String>();
            List<User> userList = new List<User>();

            if(currLead.Status == System.Label.Lead_status_Sales_Processing){
                if(salesProcessingExceptionQueue != null){
                    for(GroupMember gm : salesProcessingExceptionQueue.GroupMembers){
                        userIds.add(gm.UserOrGroupId);
                    }
                    for (String userId : userIds) {
                        Id idValue = (Id)userId;
                        if (usersMap.containsKey(idValue)) {
                            userList.add(usersMap.get(idValue));
                        }
                    }
                    List<String> emailAddresses = new List<String>();

                    for(User u : userList){
                        emailAddresses.add(u.Email); 
                    }

                    mail.setToAddresses(emailAddresses); 
                }
            }

            else if(currLead.Status == System.Label.Lead_Stage_Applying){
                if(applyingExceptionQueue != null){
                    for(GroupMember gm : applyingExceptionQueue.GroupMembers){
                        userIds.add(gm.UserOrGroupId);
                    }
                    for (String userId : userIds) {
                        Id idValue = (Id)userId;
                        if (usersMap.containsKey(idValue)) {
                            userList.add(usersMap.get(idValue));
                        }
                    }
                    List<String> emailAddresses = new List<String>();

                    for(User u : userList){
                        emailAddresses.add(u.Email); 
                    }

                    mail.setToAddresses(emailAddresses); 
                }
            }

            else{
                if(callCenterExceptionQueue != null){
                    for(GroupMember gm : callCenterExceptionQueue.GroupMembers){
                        userIds.add(gm.UserOrGroupId);
                    }
                    for (String userId : userIds) {
                        Id idValue = (Id)userId;
                        if (usersMap.containsKey(idValue)) {
                            userList.add(usersMap.get(idValue));
                        }
                    }
                    List<String> emailAddresses = new List<String>();

                    for(User u : userList){
                        emailAddresses.add(u.Email); 
                    }
        
                    mail.setToAddresses(emailAddresses); 
                }
            }
            mail.setTargetObjectId(currLead.Id);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}