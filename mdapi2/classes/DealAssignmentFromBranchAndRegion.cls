/*********************************************************************************************
* @author          Vaibhav Hinge
* @description     This class is to assign the queue id as per Service branch
* @date            23 JUNE 2023  
* @testClass:      DealAssignmentFromBranchAndRegiontest
**********************************************************************************************/
public class DealAssignmentFromBranchAndRegion {
    
/********************************************************************************************************
* @author         Vaibhav Hinge
* @description    This method used for Credit underwritter will Deal_stage_owner_Id__c in this 
					field to store queue id as per Service Branch
* @param          assignQueueUpdated(List<Opportunity>) : List of deals 
* @date           23 JUNE 2023   
********************************************************************************************************/    
    public static void assignQueueUpdated(List<Opportunity> oppList) {
        List<Opportunity> oppUpdateList = new List<Opportunity>();
        set<String> serviceBranchNameSet = new set<String>();
        set<String> userIdMemberIdSet = new set<String>();
        Map<string, string> mapOpportunityIdVsServiceBranch = new Map<string, string>();
        Map<string, string> mapQueueNameVsGroupId = new Map<string, string>();
        Map<string, User> mapUserIdVsUserObject = new Map<string,User>();
        Set<String> userIdsInGroupSet = new Set<String>();
        // for loop to store a serviceBranchs and deal ids
        for (Opportunity objOpportunity : oppList) {
            string serviceBranchs;
            if (objOpportunity.Service_Branch__c != null){
                if (objOpportunity.Service_Branch__c.startsWith(CommonConstant.CC_BRANCH)) {   
                    serviceBranchs = objOpportunity.Service_Branch__c.substring(3) ; 
                }else{
                    serviceBranchs = objOpportunity.Service_Branch__c ; 
                }
                serviceBranchNameSet.add(serviceBranchs +CommonConstant.USER_ROLE_CM);
                mapOpportunityIdVsServiceBranch.put(objOpportunity.Id, serviceBranchs + CommonConstant.USER_ROLE_CM);
            }
        }
        
        try {
            //Check service branch not empty
            if (!serviceBranchNameSet.isEmpty()) {
                List<Group> cmQueues = [SELECT Id, Name FROM Group WHERE Type = :CommonConstant.QUEUES AND Name = :serviceBranchNameSet];
                for (Group objGroup : cmQueues) {
                    userIdsInGroupSet.add(objGroup.Id);
                    mapQueueNameVsGroupId.put(objGroup.Name, objGroup.Id);
                } 
            }
            // Create a map to store group names as keys and a list of members as values
            Map<String, List<String>> groupNameVsMembers = new Map<String, List<String>>();
            // Set to store unique GroupIds
            Set<Id> groupIds = new Set<Id>();
            // Retrieve the list of GroupMember records
            List<GroupMember> listOfGroupMembers = [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN :userIdsInGroupSet];
            for (GroupMember objGroupMember : listOfGroupMembers) {
                userIdMemberIdSet.add(objGroupMember.UserOrGroupId);
                groupIds.add(objGroupMember.GroupId);
            }  
            // Map to store GroupIds and their corresponding Group names
            Map<Id, String> groupIdVsGroupName = new Map<Id, String>();
            
            if(!groupIds.isEmpty()){
                // Retrieve the group names based on the GroupIds from the Group object
                List<Group> groupList = [SELECT Id, Name FROM Group WHERE Id IN :groupIds];
                for (Group groupRec : groupList) {
                    groupIdVsGroupName.put(groupRec.Id, groupRec.Name);
                }  
            }
            // Loop through the GroupMember records to populate the map
            for (GroupMember objGroupMember : listOfGroupMembers) {
                String groupId = objGroupMember.GroupId;
                String memberId = objGroupMember.UserOrGroupId;
                
                // Get the group name from the map using the GroupId
                String groupName = groupIdVsGroupName.get(groupId);
                
                // Check if the group name is already in the map
                if (!groupNameVsMembers.containsKey(groupName)) {
                    groupNameVsMembers.put(groupName, new List<String>()); // Initialize the list if the group name is not present in the map
                }
                
                // Add the member to the list of members for the corresponding group name
                groupNameVsMembers.get(groupName).add(memberId);
            }
            // to fetch user id,name and roles
            List<User> usersList = [SELECT Id, Name, UserRole.Name FROM User WHERE Id IN :userIdMemberIdSet AND IsActive = TRUE];
            for (User objectUser : usersList) {
                mapUserIdVsUserObject.put(objectUser.Id, objectUser);
            }
            
            for (Opportunity objectOpportunity : oppList) {
                if (mapOpportunityIdVsServiceBranch.containsKey(objectOpportunity.Id)) {
                    if (mapQueueNameVsGroupId.containsKey(mapOpportunityIdVsServiceBranch.get(objectOpportunity.Id))) {
                        objectOpportunity.Deal_stage_owner_Id__c = mapQueueNameVsGroupId.get(mapOpportunityIdVsServiceBranch.get(objectOpportunity.Id));
                        // set service branch CC BRANCH and BRANCH both are same
                        string serviceBranch;
                        if (objectOpportunity.Service_Branch__c.startsWith(CommonConstant.CC_BRANCH)) {   
                            serviceBranch = objectOpportunity.Service_Branch__c.substring(3) ; 
                        }else{
                            serviceBranch =objectOpportunity.Service_Branch__c ; 
                        }
                        String userCMRole = CommonConstant.CM_ROLE + serviceBranch;
                        List<String> groupUsers = groupNameVsMembers.get(serviceBranch + CommonConstant.USER_ROLE_CM);
                        Boolean isUserAssigned = false;
                        for (String userids : groupUsers) {
                            User user = mapUserIdVsUserObject.get(userids);
                            if (user != null && user.UserRole != null && user.UserRole.Name != null) {
                                // First, check CM + service branch present then assign
                                if (user.UserRole.Name == userCMRole) {
                                    objectOpportunity.Stage_Owner__c = user.Id;
                                    objectOpportunity.Credit_Manager__c = user.Name;
                                    oppUpdateList.add(objectOpportunity);
                                    isUserAssigned = true;
                                    break;
                                }
                            }
                        }
                        
                        if (!isUserAssigned) {
                            for (String userids : groupUsers) {
                                User user = mapUserIdVsUserObject.get(userids);
                                if (user != null && user.UserRole != null && user.UserRole.Name != null) {
                                    // If CM + service branch not found, assign RCM user
                                    if (user.UserRole.Name.startsWith('RCM')) {
                                        objectOpportunity.Stage_Owner__c = user.Id;
                                        objectOpportunity.Credit_Manager__c = user.Name;
                                        oppUpdateList.add(objectOpportunity);
                                        isUserAssigned = true;
                                        break;
                                    }
                                }
                            }
                        }
                    } 
                }
            } 
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
    }
    /********************************************************************************************************
* @author          Vaibhav Hinge
* @description     This method used for Credit underwritter will Deal_stage_owner_Id__c in this 
field to store queue id as per Service Branch
* @param 		   oppList The list of Opportunities to assign the Credit Assessment Approver queue to.  
* @date            28 JUNE 2023   
********************************************************************************************************/   
    public static void assignApproverQueue(List<Opportunity> oppList) {
        //Get Credit Assessment Approver Queue 
        Group creditAssessmentApproverQueue = [SELECT Id, Name FROM Group WHERE Name = :System.Label.Credit_Assessment_Approver_Group AND Type =:System.Label.Public_Group LIMIT 1];
        // Set to hold Opportunity IDs
        Set<Id> oppIds = New Set<Id>();
        //Iterate the Opportunity
        for(Opportunity opp : oppList){
            try{
                // Assign the Credit Assessment Approver queue ID to the Opportunity
                opp.Deal_stage_owner_Id__c = creditAssessmentApproverQueue.Id;
                opp.Queue_Name__c = creditAssessmentApproverQueue.Name;
                // Reset the Stage Owner field
                if(opp.Stage_Owner__c != null){
                    opp.Credit_User__c = opp.Stage_Owner__c;
                    opp.Stage_Owner__c =null;
                }
                oppIds.add(opp.Id);
            }  
            catch(Exception e){
                System.debug(CommonConstant.ERROR_CONSTANT + e.getMessage());
            } 
        }
    }
    /********************************************************************************************************
* @author          Vaibhav Hinge
* @description     This method will used to send email alert after deal assigned.
* @param           dealList
* @param		   referBack Boolean variable
* @param		   reAppeal  Boolean variable
* @date            26 JUNE 2023   
********************************************************************************************************/
    public static void sendEmailDealStageOwner(List<Id> dealList, Boolean referBack,Boolean reAppeal){
        // Retrieve the email templates and org-wide email address
        EmailTemplate dealEmailTemplate = [SELECT Id,Body,Subject,HtmlValue from EmailTemplate where DeveloperName =: CommonConstant.DEAL_ASSIGNMENT_TEMPLATE];
        EmailTemplate dealReAppEmailTemplate = [SELECT Id,Body,Subject,HtmlValue from EmailTemplate where DeveloperName =: CommonConstant.DEAL_RE_APPEAL_TEMPLATE];
        OrgWideEmailAddress orgEmailAdd = [SELECT Id, Address, DisplayName from OrgWideEmailAddress limit 1];
        
        
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<Opportunity> oppList = [SELECT Id,StageName,Stage_Owner__c,Description,Stage_Owner__r.Email,Stage_Owner__r.Name,Credit_User__c,Credit_User__r.Name,Credit_User__r.Email FROM Opportunity WHERE ID =:dealList];     
        for(Opportunity currDeal : oppList){ 
            
            if(currDeal.Stage_Owner__c !=null){
                mail.setTargetObjectId(currDeal.Stage_Owner__c);
            }
            else if(currDeal.Credit_User__c !=null){
                mail.setTargetObjectId(currDeal.Credit_User__c);
            }
            mail.setSaveAsActivity(true);
            mail.setTreatTargetObjectAsRecipient(false);
            mail.setOrgWideEmailAddressId(orgEmailAdd.Id);
            mail.setWhatId(currDeal.Id);
            
            String emailBody;
            
            // display a reason for refer back disposition
            if(referBack){
                mail.setTemplateId(dealEmailTemplate.Id);
                mail.setSubject(dealEmailTemplate.Subject);
                emailBody = dealEmailTemplate.HtmlValue;
                String referBackEmailReason = CommonConstant.REFEREBACK +currDeal.Description;
                emailBody = emailBody.replace('{!Opportunity.Description}',referBackEmailReason );
                if(currDeal.Credit_User__r.Name !=null){
                    emailBody = emailBody.replace('{!Opportunity.Stage_Owner__c}', currDeal.Credit_User__r.Name);
                }
                
                
            }else if(reAppeal){
                // Email for re-appeal
                mail.setTemplateId(dealReAppEmailTemplate.Id);
                mail.setSubject(dealReAppEmailTemplate.Subject);
                emailBody = dealReAppEmailTemplate.HtmlValue;
                if(currDeal.Credit_User__r.Name != null){
                    emailBody = emailBody.replace('{!Opportunity.Stage_Owner__c}', currDeal.Credit_User__r.Name);
                }
                else if(currDeal.Stage_Owner__r.Name != null){
                    emailBody = emailBody.replace('{!Opportunity.Stage_Owner__c}', currDeal.Stage_Owner__r.Name);
                }
                
                
            }else{
                // Default email
                mail.setTemplateId(dealEmailTemplate.Id);
                mail.setSubject(dealEmailTemplate.Subject);
                emailBody = dealEmailTemplate.HtmlValue;
                emailBody = emailBody.replace('{!Opportunity.Description}','');
                emailBody = emailBody.replace('{!Opportunity.Stage_Owner__c}', currDeal.Stage_Owner__r.Name);
            }
            
            
            // create a deal link
            String recordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + currDeal.Id;
            
            // create a deal link with hyperlink
            String recordLink = '<a href="' + recordURL + '">' + recordURL + '</a>';
            emailBody = emailBody.replace('{!Opportunity.Link}', recordLink);
            mail.setHtmlBody(emailBody);
            if(currDeal.Stage_Owner__c != null){
                mail.setToAddresses(new List<String>{currDeal.Stage_Owner__r.Email});
            }
            try{
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }catch(Exception e){
                System.debug(CommonConstant.ERROR_CONSTANT+e.getMessage());
            }
        }
    }
    /********************************************************************************************************
* @author          Vaibhav Hinge
* @description     This method will used to send email alert after deal moved to approve.
* @param           dealList ids
* @date            28 JUNE 2023   
********************************************************************************************************/
    
    public static void sendEmailDealApproveQueue(List<Id> dealList){
        //Get 'Credit Assessment Approver queue' data
        Group creditAssessmentApproverQueue = [SELECT Id, Name FROM Group WHERE Name = :System.Label.Credit_Assessment_Approver_Group AND Type =:System.Label.Public_Group LIMIT 1];
        //Fetch queue group member having role Credit Manager
        // List<User> groupMember = [SELECT Id,Name,Email FROM User WHERE UserRoleId = :managerRoleId AND Id IN (SELECT UserOrGroupId FROM GroupMember WHERE GroupId =: creditAssessmentApproverQueue.Id)]; 
        List<User> groupMember = [SELECT Id,Name,Email FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE GroupId =: creditAssessmentApproverQueue.Id)]; 
        List<String> emailList = new List<String>();
        //Iterate the user for collecting Email id's of Credit Manager from queue
        for(User user : groupMember) {
            emailList.add(user.Email);
        }
        //Fetch email template 
        EmailTemplate dealApprovalEmailTemplate = [SELECT Id,Body,Subject,HtmlValue from EmailTemplate where DeveloperName =: CommonConstant.DEAL_APPROVAL_TEMPLATE];
        OrgWideEmailAddress orgEmailAdd = [SELECT Id, Address, DisplayName from OrgWideEmailAddress limit 1];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();      
        List<Opportunity> oppList = [SELECT Id,Name,StageName,Stage_Owner__c,Description,Stage_Owner__r.Email,Stage_Owner__r.Name,Deal_stage_owner_Id__c FROM Opportunity WHERE ID =:dealList];     
        
        //Iterate the Opportunity
        for(Opportunity currDeal : oppList){ 
            mail.setTemplateId(dealApprovalEmailTemplate.Id);
            mail.setSaveAsActivity(true);
            mail.setTargetObjectId(userInfo.getUserId());
            mail.setTreatTargetObjectAsRecipient(false);
            mail.setOrgWideEmailAddressId(orgEmailAdd.Id);
            mail.setWhatId(currDeal.Id);
            mail.setSubject(dealApprovalEmailTemplate.Subject);
            
            String emailBody = dealApprovalEmailTemplate.HtmlValue;
            emailBody = emailBody.replace('{!Opportunity.Deal_Name_Formula__c}', currDeal.Name );
            // create a deal link
            String recordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + currDeal.Id;
            // create a deal link with hyperlink
            String recordLink = '<a href="' + recordURL + '">' + recordURL + '</a>';
            emailBody = emailBody.replace('{!Opportunity.Link}', recordLink);
            
            mail.setHtmlBody(emailBody);
            if(emailList.size()>0){
                mail.setToAddresses(emailList);
                try{
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }catch(Exception e){
                    System.debug(CommonConstant.ERROR_CONSTANT+e.getMessage());
                }
            }
        }
    }
}