/*********************************************************************************************
* @author          Sohail Solapure
* @description     This EnquiryTriggerHandler class is written for updating stage and status on lead according to Disposition from Ozonetel
* @date            21 Feb 2023  
* @testClass:      EnquiryTriggerHandlerTest
**********************************************************************************************/

public class TaskTriggerHandler {
    /********************************************************************************************************
* @author          Vaibhav Hinge
* @description     This method will update stage and status on lead according to Disposition from Ozonetel
* @param           myTasks (List<Task>) : List of Task where Dispostion is present    
* @date            21 Feb 2023   
********************************************************************************************************/
    public static void updateStageStatusFromDisposition(List<Task> myTasks,Boolean senEmailToQueue,Boolean callCountUpdate) {
        //Fetching the lead ids
        Set<Id> leadIds = new Set<Id>();
        for (Task currentTask : myTasks) {
            leadIds.add(currentTask.WhoId);
        }
        
        //Creating Map of Leads and fetch all required data from lead
        Map<Id, Lead> leadMap = new Map<Id, Lead>([SELECT Id, Status, Status__c, Bad_Call_Count__c, Country_of_Study__c, Admission_Status__c,Call_Back_Count__c, University_Name__c, Institute_Name__c, Course_Id__c, Course_Stream__c, Course_Level__c, Loan_Required_A_B__c, Language_Score_Category__c, Language_Test_Score__c, Analytics_Score_Category__c, Analytics_Test_Score__c, Co_Applicant_Mobile__c, Co_Applicant_Name__c, Co_Applicant_Email__c, Service_Branch__c, OwnerId, Relationship_with_Applicant__c, In_hand_salary__c, Quantitative_Score__c, Verbal_Score__c, Occupation_Type__c,StageStatusChangeTime__c FROM Lead WHERE Id IN :leadIds]);      
        //Iterate through the list of Tasks
        for (Task currentTask : myTasks) {
            Lead leadRecord = leadMap.get(currentTask.WhoId);
            
            //If Lead record is present
            if (leadRecord != null) {
                handleTask(currentTask, leadRecord,senEmailToQueue,callCountUpdate);
                // getStageStatusFromDisposition();
            }
        }
        
        //If Map is not null then update leadMap
        if (!leadMap.isEmpty()) {
            update leadMap.values();   
        }
    }
    
    //Method to handletask used for check disposition and Lead's Stage/Status update
    public static void handleTask(Task currentTask, Lead leadRecord,Boolean senEmailToQueue,Boolean callCountUpdate) {
        //If Disposition is "Call Back"..
        if (currentTask.Call_Result__c.equals(CommonConstant.DISPOSITION_CALL_BACK) && callCountUpdate ==true) {
            updateStageStatusFromDispositionForCallBack(leadRecord, currentTask);
        }
        
        //If Disposition is "Customer Denied the Loan ( not interested)"
        else if(currentTask.Call_Result__c.equals(CommonConstant.DISPOSITION_CUSTOMER_DENIED_THE_LOAN) || currentTask.Call_Result__c.equals(CommonConstant.DISPOSITION_CUSTOMER_DENIED_THE_LOAN_NOT_INTERESTED)){
            updateStageStatusFromDispositionForCustomerDeniedLoanAndNotDoable(leadRecord,CommonConstant.LEAD_STATUS_NOT_INTRESTED,currentTask);
        }
        
        //If Disposition is "Future Prospect "
        else if(currentTask.Call_Result__c.equals(CommonConstant.DISPOSITION_FUTURE_PROSPECT)){
            updateStageStatusFromDispositionForFutureProspect(leadRecord,currentTask);
        }
        
        //If Disposition is "Invalid"
        else if(currentTask.Call_Result__c.equals(CommonConstant.DISPOSITION_INVALID)){
            updateStageStatusFromDispositionForInvalid(leadRecord,currentTask);
        }
        
        //If Disposition is "Not Doable By Auxilo"
        else if(currentTask.Call_Result__c.equals(CommonConstant.DISPOSITION_NOT_DOABLE_BY_AUXILO)){
            updateStageStatusFromDispositionForCustomerDeniedLoanAndNotDoable(leadRecord,CommonConstant.LEAD_STATUS_NOT_DOABLE,currentTask);
        }
        
        //If Disposition is "Passive Transfer to CEM" 
        else if(currentTask.Call_Result__c.equals(CommonConstant.DISPOSITION_PASSIVE_TRANSFER_TO_CEM)){
            updateStageStatusFromDispositionForPassiveTransfer(leadRecord,currentTask,senEmailToQueue);
        }
        
        //If Disposition is "Tri Party Call" => "Tri Party Call" 
        else if(currentTask.Call_Result__c.equals(CommonConstant.DISPOSITION_TRI_PARTY_CALL)){
            updateStageStatusFromDispositionTriPartyCall(leadRecord,currentTask);
        }
        
        //If Disposition is "Willing to Apply"
        else if(currentTask.Call_Result__c.equals(CommonConstant.DISPOSITION_WILLING_TO_APPLY)){
            updateStageStatusFromDispositionForWillingToApply(leadRecord,currentTask,senEmailToQueue);
        }
        
        //If Disposition is "Active Transfer to CEM"
        else if(currentTask.Call_Result__c.equals(CommonConstant.DISPOSITION_ACTIVE_TRANSFER_TO_CEM)){
            updateStageStatusFromDispositionForActiveTransfer(leadRecord,currentTask,senEmailToQueue);
        }
        
        //If Disposition is  "Application formality completed" 
        else if(currentTask.Call_Result__c.equals(CommonConstant.DISPOSITION_APPLICATION_FORMALITIES_COMPLETED)){
            updateStageStatusFromDispositionApplicationFormalityCompleted(leadRecord);
        }
        
        //If Disposition is "Duplicate Lead"
        else if(currentTask.Call_Result__c.equals(CommonConstant.DISPOSITION_DUPLICATE_LEADS)){
            updateStageStatusFromDispositionForDuplicate(leadRecord,currentTask);
        }
        //If Disposition is "Ready to Apply"
        else if(currentTask.Call_Result__c.equals(CommonConstant.DISPOSITION_READY_TO_APPLY)){
            updateStageStatusFromDispositionForReadyToApply(leadRecord);
        }
        //If Disposition is "Call Done"
        else if(currentTask.Call_Result__c.equals(CommonConstant.DISPOSITION_CALL_DONE)){ 
            updateStageStatusFromDispositionForCallDone(leadRecord, currentTask);
        }
        //If Disposition is "Bad Call"
        else if(currentTask.Call_Result__c.equals(CommonConstant.DISPOSITION_BAD_CALL)){ 
            updateStageStatusFromDispositionForBadCall(leadRecord, currentTask);
        }
    }
    
    //Method to handle if disposition is Call Back
    public static void updateStageStatusFromDispositionForCallBack(Lead leadRecord, Task currentTask ) {
        leadRecord.Call_Back_Count__c += 1;
        string dispositionKey = currentTask.Call_Result__c+'#'+leadRecord.Status+'#'+leadRecord.Status__c;
        Map<String,Disposition_Type__mdt> mapDispostionvsObject = getStageStatusFromDisposition();
        if (currentTask.call_back_date_time_New__c != null && ((leadRecord.Status == CommonConstant.LEAD_STATUS_FRESH && (leadRecord.Status__c == CommonConstant.LEAD_STATUS_NEW || leadRecord.Status__c == CommonConstant.LEAD_STATUS_ESCALATED )) || (leadRecord.Status == CommonConstant.LEAD_STATUS_SUSPRCT  && leadRecord.Status__c == CommonConstant.LEAD_STATUS_NOT_CONTACTED))) {            
            leadRecord.Status = CommonConstant.LEAD_STATUS_SUSPRCT ;
            leadRecord.Status__c = CommonConstant.LEAD_STATUS_CONTACTED;
            leadRecord.Call_Back_Count__c=0;
            leadRecord.Call_Result__c = 'Call Back';
            leadRecord.StageStatusChangeTime__c = datetime.now();
        }
        
        //if Stage/Status is Suspect/Contacted with Mandatory Fields: "Call Back Date time" /***
        else if ((currentTask.call_back_date_time_New__c != null || currentTask.Call_Back_Date_time__c != null ) && leadRecord.Status == CommonConstant.LEAD_STATUS_SUSPRCT && leadRecord.Status__c == CommonConstant.LEAD_STATUS_CONTACTED) { 
            if(mapDispostionvsObject.containsKey(dispositionKey) && mapDispostionvsObject.get(dispositionKey) != null && mapDispostionvsObject.get(dispositionKey).Call_Count__c != null){
                
                if(leadRecord.Call_Back_Count__c >= mapDispostionvsObject.get(dispositionKey).Call_Count__c){
                    leadRecord.Status = CommonConstant.LEAD_STATUS_LOST ;
                    leadRecord.Status__c = CommonConstant.LEAD_STATUS_INERT ;
                    leadRecord.Call_Back_Count__c=0;
                    leadRecord.Call_Result__c = 'Call Back';
                    leadRecord.StageStatusChangeTime__c = datetime.now();
                }  
            }
            
        }
        
        //if Stage/Status is Prospect/Active with Mandatory Fields: "Call Back Date time" /**
        else if ((currentTask.call_back_date_time_New__c != null || currentTask.call_back_date_time_New__c != null) && leadRecord.Status == CommonConstant.LEAD_STATUS_PROSPECT && leadRecord.Status__c == CommonConstant.LEAD_STATUS_ACTIVE) {
            if(mapDispostionvsObject.containsKey(dispositionKey) && mapDispostionvsObject.get(dispositionKey) != null && mapDispostionvsObject.get(dispositionKey).Call_Count__c != null){ 
                
                if(leadRecord.Call_Back_Count__c >= mapDispostionvsObject.get(dispositionKey).Call_Count__c){
                    leadRecord.Status = CommonConstant.LEAD_STATUS_LOST;
                    leadRecord.Status__c = CommonConstant.LEAD_STATUS_INERT;
                    leadRecord.Call_Back_Count__c=0;
                    leadRecord.Call_Result__c = 'Call Back';
                    leadRecord.StageStatusChangeTime__c = datetime.now();
                }  
            }
        }
        
        //if Stage/Status is Sales Processing/ Escalated
        else if (leadRecord.Status == CommonConstant.LEAD_STATUS_SALES_PROCESSING && leadRecord.Status__c == CommonConstant.LEAD_STATUS_ESCALATED) {
            leadRecord.Status = CommonConstant.LEAD_STATUS_SALES_PROCESSING;
            leadRecord.Status__c = CommonConstant.LEAD_STATUS_ACTIVE;
            leadRecord.Call_Back_Count__c=0;
            leadRecord.Call_Result__c = 'Call Back';
            leadRecord.StageStatusChangeTime__c = datetime.now();
        }
        
        //If Stage/Status is Sales Processing/Active or Inactive
        else if(leadRecord.Status == CommonConstant.LEAD_STATUS_SALES_PROCESSING && leadRecord.Status__c == CommonConstant.LEAD_STATUS_INACTIVE){
            leadRecord.Status = CommonConstant.LEAD_STATUS_SALES_PROCESSING;
            leadRecord.Status__c = CommonConstant.LEAD_STATUS_ACTIVE;
            leadRecord.Call_Back_Count__c=0;
            leadRecord.Call_Result__c = 'Call Back';
            leadRecord.StageStatusChangeTime__c = datetime.now();
        }
        
        //If Stage/Status is Sales Processing/Call center triparty
        else if((leadRecord.Status == CommonConstant.LEAD_STATUS_SALES_PROCESSING && leadRecord.Status__c == CommonConstant.LEAD_STATUS_CALL_CENTER_TRIPARTY)){
            Id profileId = UserInfo.getProfileId();
            String profileName = [SELECT Name FROM Profile WHERE Id = :profileId].Name;
            if(profileName != CommonConstant.LEAD_STATUS_CALL_CENTER_TEAM_PROFILE){
                leadRecord.Status = CommonConstant.LEAD_STATUS_SALES_PROCESSING;
                leadRecord.Status__c = CommonConstant.LEAD_STATUS_ACTIVE;
                leadRecord.Call_Back_Count__c=0;
                leadRecord.Call_Result__c = 'Call Back';
                leadRecord.StageStatusChangeTime__c = datetime.now();
            }
        }
        
        else if (currentTask.call_back_date_time_New__c != null && leadRecord.Status == CommonConstant.LEAD_STATUS_SALES_PROCESSING && (leadRecord.Status__c == CommonConstant.LEAD_STATUS_NEW || leadRecord.Status__c == CommonConstant.LEAD_STATUS_CALL_CENTER_TRIPARTY || leadRecord.Status__c == CommonConstant.LEAD_STATUS_FUTURE_PROSPECT)) {
            leadRecord.Status = CommonConstant.LEAD_STATUS_SALES_PROCESSING;
            leadRecord.Status__c = CommonConstant.LEAD_STATUS_ACTIVE;
            leadRecord.Call_Back_Count__c=0;
            leadRecord.Call_Result__c = 'Call Back';
            leadRecord.StageStatusChangeTime__c = datetime.now();
        }
        //If Stage/Status is Sales Prospect/Call In-Active/Future Prospect /***
        else if(leadRecord.Status == CommonConstant.LEAD_STATUS_PROSPECT && (leadRecord.Status__c == CommonConstant.LEAD_STATUS_INACTIVE || leadRecord.Status__c == CommonConstant.LEAD_STATUS_FUTURE_PROSPECT)){
            leadRecord.Status = CommonConstant.LEAD_STATUS_PROSPECT;
            leadRecord.Status__c = CommonConstant.LEAD_STATUS_ACTIVE;
            leadRecord.Call_Back_Count__c=0;
            leadRecord.Call_Result__c = 'Call Back';
            leadRecord.StageStatusChangeTime__c = datetime.now();
        }
        //If Stage/Status is Sales Applying/Call In-Active /***
        else if(leadRecord.Status == CommonConstant.LEAD_STATUS_APPLYING && leadRecord.Status__c == CommonConstant.LEAD_STATUS_INACTIVE){
            leadRecord.Status = CommonConstant.LEAD_STATUS_APPLYING;
            leadRecord.Status__c = CommonConstant.LEAD_STATUS_ACTIVE;
            leadRecord.Call_Back_Count__c=0;
            leadRecord.Call_Result__c = 'Call Back';
            leadRecord.StageStatusChangeTime__c = datetime.now();
        }
        
    }
    
    //Method to handle if disposition is "Customer Denied the Loan ( not interested)" AND "Not Doable By Auxilo" 
    public static void updateStageStatusFromDispositionForCustomerDeniedLoanAndNotDoable(Lead leadRecord,String status,task currentTask){
        //If Stage is any with Mandatory Fields: Reason Code 
        if((currentTask.Reason__c != null) && (leadRecord.Status == CommonConstant.LEAD_STATUS_FRESH || leadRecord.Status == CommonConstant.LEAD_STATUS_SUSPRCT || leadRecord.Status == CommonConstant.LEAD_STATUS_PROSPECT || leadRecord.Status == CommonConstant.LEAD_STATUS_SALES_PROCESSING || leadRecord.Status == CommonConstant.LEAD_STATUS_APPLYING)){
            leadRecord.Status = CommonConstant.LEAD_STATUS_LOST;
            if(status.equals(CommonConstant.LEAD_STATUS_NOT_INTRESTED)){   
                leadRecord.Status__c = CommonConstant.LEAD_STATUS_NOT_INTRESTED;
                leadRecord.StageStatusChangeTime__c = datetime.now();
                leadRecord.Call_Result__c = '';
            }
            else if(status.equals(CommonConstant.LEAD_STATUS_NOT_DOABLE)){
                leadRecord.Status__c = CommonConstant.LEAD_STATUS_NOT_DOABLE;
                leadRecord.StageStatusChangeTime__c = datetime.now();
                leadRecord.Call_Result__c = '';
            }
        }
    }
    
    //Method to handle if disposition is Future Prospect
    public static void updateStageStatusFromDispositionForFutureProspect(Lead leadRecord,task currentTask){
        //If Stage/Status is Fresh/New or Escalated || Suspect/Contacted or Not Contacted || Prospect/Active or Inactive with Mandatory Fields: Call Back Date time
        if((currentTask.call_back_date_time_New__c != null)&&((leadRecord.Status == CommonConstant.LEAD_STATUS_FRESH && (leadRecord.Status__c == CommonConstant.LEAD_STATUS_NEW || leadRecord.Status__c == CommonConstant.LEAD_STATUS_ESCALATED))||(leadRecord.Status == CommonConstant.LEAD_STATUS_SUSPRCT  && (leadRecord.Status__c == CommonConstant.LEAD_STATUS_CONTACTED || leadRecord.Status__c == CommonConstant.LEAD_STATUS_NOT_CONTACTED)) || leadRecord.Status == CommonConstant.LEAD_STATUS_PROSPECT && (leadRecord.Status__c == CommonConstant.LEAD_STATUS_ACTIVE || leadRecord.Status__c == CommonConstant.LEAD_STATUS_INACTIVE))){
            leadRecord.Status = CommonConstant.LEAD_STATUS_PROSPECT;
            leadRecord.Status__c = CommonConstant.LEAD_STATUS_FUTURE_PROSPECT;
            leadRecord.StageStatusChangeTime__c = datetime.now();
            leadRecord.Call_Result__c = '';
            leadRecord.Future_Prospect_Date__c = currentTask.call_back_date_time_New__c != '' ? (dateFormating(currentTask.call_back_date_time_New__c)).date():null;
            System.debug('Future date: '+leadRecord.Future_Prospect_Date__c);
        }
        
        //If Stage/Status is Sales Processing/New or Active or Inactive or Call -Center Triparty or Escalated with Mandatory Fields: Call Back Date time
        else if((currentTask.call_back_date_time_New__c != null)&&(leadRecord.Status == CommonConstant.LEAD_STATUS_SALES_PROCESSING &&(leadRecord.Status__c == CommonConstant.LEAD_STATUS_NEW || leadRecord.Status__c == CommonConstant.LEAD_STATUS_ACTIVE || leadRecord.Status__c == CommonConstant.LEAD_STATUS_INACTIVE || leadRecord.Status__c == CommonConstant.LEAD_STATUS_CALL_CENTER_TRIPARTY || leadRecord.Status__c == CommonConstant.LEAD_STATUS_ESCALATED ))){
            leadRecord.Status = CommonConstant.LEAD_STATUS_SALES_PROCESSING;
            leadRecord.Status__c =  CommonConstant.LEAD_STATUS_FUTURE_PROSPECT;
            leadRecord.StageStatusChangeTime__c = datetime.now();
            leadRecord.Call_Result__c = '';
            leadRecord.Future_Prospect_Date__c = currentTask.call_back_date_time_New__c != '' ? (dateFormating(currentTask.call_back_date_time_New__c)).date():null;
        }
        //If Stage/Status is Applying/Active or Inactive or QC-New or QC-WIp or QC-Sales Query
        else if(leadRecord.Status == CommonConstant.LEAD_STATUS_APPLYING && (leadRecord.Status__c == CommonConstant.LEAD_STATUS_ACTIVE || leadRecord.Status__c == CommonConstant.LEAD_STATUS_INACTIVE || leadRecord.Status__c == CommonConstant.LEAD_STATUS_QC_NEW || leadRecord.Status__c == CommonConstant.LEAD_STATUS_QC_WIP || leadRecord.Status__c == CommonConstant.LEAD_STATUS_QC_SALES_QUERY)){
            leadRecord.Status = CommonConstant.LEAD_STATUS_SALES_PROCESSING;
            leadRecord.Status__c =  CommonConstant.LEAD_STATUS_FUTURE_PROSPECT;
            leadRecord.StageStatusChangeTime__c = datetime.now();
            leadRecord.Call_Result__c = '';
            leadRecord.Future_Prospect_Date__c = currentTask.call_back_date_time_New__c != '' ? (dateFormating(currentTask.call_back_date_time_New__c)).date():null;
        }
    }
    
    //Method to handle if disposition is "Invalid" 
    public static void updateStageStatusFromDispositionForInvalid(Lead leadRecord,task currentTask){
        if(currentTask.Description == null){
            //currentTask.Description.addError(CommonConstant.LEAD_STATUS_LOST_REASON_ERROR_ON_TASK);
        }
        //If Stage is any with Mandatory Fields:Reason (Free Text/Comment/Description)
        if((currentTask.Description != null)&&(leadRecord.Status == CommonConstant.LEAD_STATUS_FRESH || leadRecord.Status == CommonConstant.LEAD_STATUS_SUSPRCT || leadRecord.Status == CommonConstant.LEAD_STATUS_PROSPECT || leadRecord.Status == CommonConstant.LEAD_STATUS_SALES_PROCESSING || leadRecord.Status == CommonConstant.LEAD_STATUS_APPLYING)){
            leadRecord.Status = CommonConstant.LEAD_STATUS_LOST;
            leadRecord.Status__c = CommonConstant.LEAD_STATUS_INVALID;
            leadRecord.StageStatusChangeTime__c = datetime.now();
            leadRecord.Call_Result__c = '';
        }
    }
    
    //Method to handle if disposition is Passive Trasfer to CEM
    public static void updateStageStatusFromDispositionForPassiveTransfer(Lead leadRecord,task currentTask,Boolean senEmailToQueue){
        if(leadRecord.Service_Branch__c==null){
            // leadRecord.OwnerId = queueId.Id;
            if(senEmailToQueue == true){
                taskCreationForCallCenterEcetionQueue(leadRecord,'Service Branch');
            }
        }
        //If Stage/Status is Fresh/New or escalated || Suspect/Contacted or Not Contacted || Prospect/Active or Inactive or Future Suspect
        if((leadRecord.Service_Branch__c!=null)&&((leadRecord.Status == CommonConstant.LEAD_STATUS_FRESH && (leadRecord.Status__c == CommonConstant.LEAD_STATUS_NEW || leadRecord.Status__c == CommonConstant.LEAD_STATUS_ESCALATED)) || (leadRecord.Status == CommonConstant.LEAD_STATUS_SUSPRCT && (leadRecord.Status__c == CommonConstant.LEAD_STATUS_CONTACTED || leadRecord.Status__c == CommonConstant.LEAD_STATUS_NOT_CONTACTED)) || (leadRecord.Status == CommonConstant.LEAD_STATUS_PROSPECT && (leadRecord.Status__c == CommonConstant.LEAD_STATUS_ACTIVE || leadRecord.Status__c == CommonConstant.LEAD_STATUS_INACTIVE || leadRecord.Status__c == CommonConstant.LEAD_STATUS_FUTURE_PROSPECT)))){
            leadRecord.Status = CommonConstant.LEAD_STATUS_SALES_PROCESSING;
            leadRecord.Status__c = CommonConstant.LEAD_STATUS_NEW ;
            leadRecord.StageStatusChangeTime__c = datetime.now();
            leadRecord.Call_Result__c = '';
        }
    } 
    
    //Method to handle if disposition is Tri Party Call
    public static void updateStageStatusFromDispositionTriPartyCall(Lead leadRecord,Task currentTask){
        
        //If Stage/Status is Sales Processing/Call centre triparty //***
        if(leadRecord.Status == CommonConstant.LEAD_STATUS_SALES_PROCESSING && leadRecord.Status__c ==CommonConstant.LEAD_STATUS_CALL_CENTER_TRIPARTY){
            //To fetch Call center queues
            Group callCenterQueues = [SELECT Id,Name FROM Group WHERE Type =: CommonConstant.QUEUE AND Name LIKE :CommonConstant.CALL_CENTER_QUEUE LIMIT 1];
            system.debug('callCenterQueues' + callCenterQueues);
            
            List<Task> lstTasktoUpdateStageOwner = new List<Task>();
            lstTasktoUpdateStageOwner.add(currentTask);
            assignmentOfStageOwnerToParentlead(lstTasktoUpdateStageOwner);
            leadRecord.Status = CommonConstant.LEAD_STATUS_SALES_PROCESSING;
            leadRecord.Status__c = CommonConstant.LEAD_STATUS_ACTIVE;
            leadRecord.StageStatusChangeTime__c = datetime.now();
            
            // Retrieve the UserIds of users in the callCenterQueues group
            Set<Id> userIds = new Set<Id>();
            for (GroupMember member : [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :callCenterQueues.Id AND UserOrGroupId <> NULL]) {
                if (member.UserOrGroupId.getSObjectType() == User.sObjectType) {
                    userIds.add((Id)member.UserOrGroupId);
                }
            }
            
            // Retrieve the email addresses of users in the callCenterQueues group
            List<String> userEmails = new List<String>();
            if (!userIds.isEmpty()) {
                for (User user : [SELECT Email FROM User WHERE Id IN :userIds]) {
                    userEmails.add(user.Email);
                }
            }
            
            // Retrieve the owner of the lead
            Lead leadOwner = [SELECT Owner.Name, Owner.Email FROM Lead WHERE Id = :leadRecord.Id];
            // Retrieve the email templates
            EmailTemplate LeadTripartyCallDoneForSalesUserTemplate = [SELECT Id,Body,Subject,HtmlValue from EmailTemplate where DeveloperName =: CommonConstant.LEAD_TRIPARTY_CALL_DONE_EMAIL_TO_SALES_USER];           
            
            Messaging.SingleEmailMessage messageTripartyDone = new Messaging.SingleEmailMessage();
            messageTripartyDone.setSubject(LeadTripartyCallDoneForSalesUserTemplate.Subject);
            messageTripartyDone.setTreatBodiesAsTemplate(True); 
            messageTripartyDone.setToAddresses(new List<String>{ leadOwner.Owner.Email });
            messageTripartyDone.setCcAddresses(userEmails);
            messageTripartyDone.setSaveAsActivity(true);
            messageTripartyDone.setTargetObjectId(leadRecord.Id);
            messageTripartyDone.setTreatTargetObjectAsRecipient(false);
            messageTripartyDone.setHtmlBody(LeadTripartyCallDoneForSalesUserTemplate.HtmlValue);
            
            try {
                Messaging.sendEmail(new List<Messaging.Email>{ messageTripartyDone });                
            } catch (Exception e) {                
                System.debug('An error occurred while sending the email: ' + e.getMessage());               
            }  
        }
    }
    
    /* public class LeadWrapper {
@InvocableVariable
public Lead lead;
@InvocableVariable
public List<String> nullFieldLabels;
}*/
    
    //Method to handle if disposition is Willing TO Apply
    public static void updateStageStatusFromDispositionForWillingToApply	(Lead leadRecord,task currentTask,Boolean senEmailToQueue){
        //If Stage/Status is Fresh/New or escalated || Suspect/Contacted or Not Contacted || Prospect/Active or Inactive or Future Suspect
        // To check all Mand field are fill 
        
        
        /*if(leadRecord.Country_of_Study__c != null && leadRecord.Admission_Status__c != null && leadRecord.University_Name__c != null &&leadRecord.Institute_Name__c != null
&& leadRecord.Course_Id__c != null &&  leadRecord.Course_Stream__c != null && leadRecord.Course_Level__c != null &&
leadRecord.Loan_Required_A_B__c > 0 && leadRecord.Co_Applicant_Name__c != null && leadRecord.Co_Applicant_Mobile__c!= null && leadRecord.Co_Applicant_Email__c!= null  && leadRecord.Relationship_with_Applicant__c!= null && 
leadRecord.In_hand_salary__c!= null && leadRecord.Occupation_Type__c != null &&
(leadRecord.Analytics_Score_Category__c != null ? (leadRecord.Quantitative_Score__c != null && leadRecord.Verbal_Score__c != null ) : (leadRecord.Quantitative_Score__c == null && leadRecord.Verbal_Score__c == null ))&&
(leadRecord.Language_Score_Category__c != null ? leadRecord.Language_Test_Score__c != null : leadRecord.Language_Score_Category__c == null)){
if((leadRecord.Status == CommonConstant.LEAD_STATUS_FRESH && (leadRecord.Status__c == CommonConstant.LEAD_STATUS_NEW || leadRecord.Status__c == CommonConstant.LEAD_STATUS_ESCALATED)) || (leadRecord.Status == CommonConstant.LEAD_STATUS_SUSPRCT && (leadRecord.Status__c == CommonConstant.LEAD_STATUS_CONTACTED || leadRecord.Status__c == CommonConstant.LEAD_STATUS_NOT_CONTACTED)) || (leadRecord.Status == CommonConstant.LEAD_STATUS_PROSPECT && (leadRecord.Status__c == CommonConstant.LEAD_STATUS_ACTIVE || leadRecord.Status__c == CommonConstant.LEAD_STATUS_INACTIVE || leadRecord.Status__c == CommonConstant.LEAD_STATUS_FUTURE_PROSPECT))){
leadRecord.Status = CommonConstant.LEAD_STATUS_SALES_PROCESSING;
leadRecord.Status__c = CommonConstant.LEAD_STATUS_NEW;
leadRecord.StageStatusChangeTime__c = datetime.now();
leadRecord.Call_Result__c = '';
}  
}else{
if(senEmailToQueue == true ){
taskCreationForCallCenterEcetionQueue(leadRecord, 'WTA Mandatory fields');
}
}  */
        // Call the getWTAMandField method to get a list of LeadWrapper objects
        // Check if senEmailToQueue is true
        if (senEmailToQueue == true) {
            // Call getWTAMandField to get the LeadWrapper
            List<WillingToApplyMandFields.LeadWrapper> leadWrappers = WillingToApplyMandFields.getWTAMandField(new List<String>{leadRecord.Id});
            
            // Check if leadWrappers is not null and not empty
            if (leadWrappers != null && !leadWrappers.isEmpty()) {
                WillingToApplyMandFields.LeadWrapper wrapper = leadWrappers[0]; // Assuming you are only working with one lead
                // Check if there are null field labels
                if (wrapper.nullFieldLabels != null && !wrapper.nullFieldLabels.isEmpty()) {
                    taskCreationForCallCenterEcetionQueue(leadRecord, 'WTA Mandatory fields');
                }
            }
        }
    }
    
    //Method to handle if disposition is Active Trasfer to CEM
    public static void updateStageStatusFromDispositionForActiveTransfer(Lead leadRecord,Task currentTask,Boolean senEmailToQueue){
        //If Stage/Status is Fresh/New or escalated || Suspect/Contacted or Not Contacted || Prospect/Active or Inactive or Future Suspect
        //Mandatory field "Lead owner Name" & "Reason for Transfer" (Free text/Description)
        
        if(leadRecord.OwnerId != null){
            if(currentTask.Description != null){
                if((leadRecord.Status == CommonConstant.LEAD_STATUS_FRESH && (leadRecord.Status__c == CommonConstant.LEAD_STATUS_NEW || leadRecord.Status__c == CommonConstant.LEAD_STATUS_ESCALATED)) || (leadRecord.Status == CommonConstant.LEAD_STATUS_SUSPRCT && (leadRecord.Status__c == CommonConstant.LEAD_STATUS_CONTACTED || leadRecord.Status__c == CommonConstant.LEAD_STATUS_NOT_CONTACTED)) || (leadRecord.Status == CommonConstant.LEAD_STATUS_PROSPECT && (leadRecord.Status__c == CommonConstant.LEAD_STATUS_ACTIVE || leadRecord.Status__c == CommonConstant.LEAD_STATUS_INACTIVE || leadRecord.Status__c == CommonConstant.LEAD_STATUS_FUTURE_PROSPECT))){
                    leadRecord.Status = CommonConstant.LEAD_STATUS_SALES_PROCESSING;
                    leadRecord.Status__c = CommonConstant.LEAD_STATUS_NEW ;
                    leadRecord.StageStatusChangeTime__c = datetime.now();
                    leadRecord.Call_Result__c = '';
                }  
            }else{
                if(senEmailToQueue == true){
                    taskCreationForCallCenterEcetionQueue(leadRecord,'Task Description');
                }
            }   
        }else{
            if(senEmailToQueue == true){
                taskCreationForCallCenterEcetionQueue(leadRecord,'Lead Owner');
            }
        }
    }
    
    //Method to handle if disposition is Application formality completed
    public static void updateStageStatusFromDispositionApplicationFormalityCompleted(Lead leadRecord){
        //If Stage/Status is Applying/Active or Inactive
        if(leadRecord.Status == CommonConstant.LEAD_STATUS_APPLYING && (leadRecord.Status__c == CommonConstant.LEAD_STATUS_ACTIVE || leadRecord.Status__c == CommonConstant.LEAD_STATUS_INACTIVE)){
            leadRecord.Status = CommonConstant.LEAD_STATUS_APPLYING;
            leadRecord.Status__c = CommonConstant.LEAD_STATUS_QC_NEW;
            leadRecord.StageStatusChangeTime__c = datetime.now();
            leadRecord.Call_Result__c = '';
        }
    }
    
    //Method to handle if disposition is Duplicate Lead" 
    public static void updateStageStatusFromDispositionForDuplicate(Lead leadRecord,task currentTask){
        
        //If Stage is any
        if(leadRecord.Status == CommonConstant.LEAD_STATUS_FRESH || leadRecord.Status == CommonConstant.LEAD_STATUS_SUSPRCT || leadRecord.Status == CommonConstant.LEAD_STATUS_PROSPECT || leadRecord.Status == CommonConstant.LEAD_STATUS_SALES_PROCESSING || leadRecord.Status == CommonConstant.LEAD_STATUS_APPLYING){
            leadRecord.Status = CommonConstant.LEAD_STATUS_LOST; 
            leadRecord.Status__c = CommonConstant.LEAD_STATUS_DUPLICATE_LEADS;
            leadRecord.StageStatusChangeTime__c = datetime.now();
            leadRecord.Call_Result__c = '';
        }
    }
    //Method to handle if disposition is Ready to Apply
    public static void updateStageStatusFromDispositionForReadyToApply(Lead leadRecord){
        //If Stage/Status is Sales Processing/New or Active or Inactive
        if(leadRecord.Status == CommonConstant.LEAD_STATUS_SALES_PROCESSING && (leadRecord.Status__c == CommonConstant.LEAD_STATUS_NEW || leadRecord.Status__c == CommonConstant.LEAD_STATUS_ACTIVE || leadRecord.Status__c == CommonConstant.LEAD_STATUS_INACTIVE || leadRecord.Status__c == CommonConstant.LEAD_STATUS_ESCALATED  || leadRecord.Status__c == CommonConstant.LEAD_STATUS_CALL_CENTER_TRIPARTY)){
            leadRecord.Status = CommonConstant.LEAD_STATUS_APPLYING; 
            leadRecord.Status__c = CommonConstant.LEAD_STATUS_ACTIVE;
            leadRecord.StageStatusChangeTime__c = datetime.now();
            leadRecord.Call_Result__c = '';
        }
    } 
    
    public static void updateStageStatusFromDispositionForCallDone(Lead leadRecord, Task currentTask) {
        //If Stage/Status is Prospect/Inactive
        if(leadRecord.Status == CommonConstant.LEAD_STATUS_PROSPECT && leadRecord.Status__c == CommonConstant.LEAD_STATUS_INACTIVE) {
            leadRecord.Status = CommonConstant.LEAD_STATUS_PROSPECT;
            leadRecord.Status__c = CommonConstant.LEAD_STATUS_ACTIVE;
            leadRecord.StageStatusChangeTime__c = datetime.now();
            leadRecord.Call_Result__c = '';
        }
        //If Stage/Status is Prospect/Future Prospect with Mandatory Fields: "Call Back Date time"
        else if(currentTask.Call_Back_Date_time__c != null && (leadRecord.Status == CommonConstant.LEAD_STATUS_PROSPECT && leadRecord.Status__c == CommonConstant.LEAD_STATUS_FUTURE_PROSPECT)) {
            leadRecord.Status = CommonConstant.LEAD_STATUS_PROSPECT;
            leadRecord.Status__c = CommonConstant.LEAD_STATUS_ACTIVE;
            leadRecord.StageStatusChangeTime__c = datetime.now();
            leadRecord.Call_Result__c = '';
        }
        //If Stage/Status is Sales Processing/Inactive 
        else if(leadRecord.Status == CommonConstant.LEAD_STATUS_SALES_PROCESSING && leadRecord.Status__c == CommonConstant.LEAD_STATUS_INACTIVE) {
            leadRecord.Status = CommonConstant.LEAD_STATUS_SALES_PROCESSING;
            leadRecord.Status__c = CommonConstant.LEAD_STATUS_ACTIVE;
            leadRecord.StageStatusChangeTime__c = datetime.now();
            leadRecord.Bad_Call_Count__c = 0;
            leadRecord.Call_Result__c = '';
        }
    }
    
    //Method to handle if disposition is Bad Call
    public static void updateStageStatusFromDispositionForBadCall(Lead leadRecord,Task currentTask){
        leadRecord.Bad_Call_Count__c += 1;
        string dispositionKey = currentTask.Call_Result__c+'#'+leadRecord.Status+'#'+leadRecord.Status__c;
        Map<String,Disposition_Type__mdt> mapDispostionvsObject = getStageStatusFromDisposition();
        
        /* ***************************************************************************** */
        //Increament the count for Bad call
        if(currentTask.Reason__c != null && (currentTask.Reason__c == CommonConstant.LEAD_REASON_INVALID_NUMBER || currentTask.Reason__c == CommonConstant.LEAD_REASON_WRONG_NUMBER)){  
            leadRecord.Status = CommonConstant.LEAD_STATUS_LOST;
            leadRecord.Status__c = CommonConstant.LEAD_STATUS_INVALID;
            leadRecord.Bad_Call_Count__c =0;
            leadRecord.StageStatusChangeTime__c = datetime.now();
            leadRecord.Call_Result__c = '';
        }
        //Increament the count for Bad call
        else if(currentTask.Reason__c != null && (leadRecord.Status == CommonConstant.LEAD_STATUS_FRESH && (leadRecord.Status__c == CommonConstant.LEAD_STATUS_NEW || leadRecord.Status__c == CommonConstant.LEAD_STATUS_ESCALATED))){  
            leadRecord.Status = CommonConstant.LEAD_STATUS_SUSPRCT;
            leadRecord.Status__c = CommonConstant.LEAD_STATUS_NOT_CONTACTED;
            leadRecord.Bad_Call_Count__c =0;
            leadRecord.StageStatusChangeTime__c = datetime.now();
            leadRecord.Call_Result__c = '';
        }
        else if(leadRecord.Status == CommonConstant.LEAD_STATUS_SUSPRCT && (leadRecord.Status__c == CommonConstant.LEAD_STATUS_CONTACTED || leadRecord.Status__c == CommonConstant.LEAD_STATUS_NOT_CONTACTED)){
            if(mapDispostionvsObject.containsKey(dispositionKey) && mapDispostionvsObject.get(dispositionKey) != null && mapDispostionvsObject.get(dispositionKey).Call_Count__c != null){
                
                if(leadRecord.Bad_Call_Count__c >= mapDispostionvsObject.get(dispositionKey).Call_Count__c){
                    leadRecord.Status = CommonConstant.LEAD_STATUS_LOST;
                    leadRecord.Status__c = CommonConstant.LEAD_STATUS_INERT;
                    leadRecord.Bad_Call_Count__c =0;
                    leadRecord.StageStatusChangeTime__c = datetime.now();
                    leadRecord.Call_Result__c = '';
                }  
            }
        }else if(leadRecord.Status == CommonConstant.LEAD_STATUS_PROSPECT && (leadRecord.Status__c == CommonConstant.LEAD_STATUS_ACTIVE || leadRecord.Status__c == CommonConstant.LEAD_STATUS_INACTIVE || leadRecord.Status__c == CommonConstant.LEAD_STATUS_FUTURE_PROSPECT)){
            if(mapDispostionvsObject.containsKey(dispositionKey) && mapDispostionvsObject.get(dispositionKey) != null && mapDispostionvsObject.get(dispositionKey).Call_Count__c != null){
                
                if(leadRecord.Bad_Call_Count__c >= mapDispostionvsObject.get(dispositionKey).Call_Count__c){
                    leadRecord.Status = CommonConstant.LEAD_STATUS_LOST;
                    leadRecord.Status__c = CommonConstant.LEAD_STATUS_INERT;
                    leadRecord.Bad_Call_Count__c =0;
                    leadRecord.StageStatusChangeTime__c = datetime.now();
                    leadRecord.Call_Result__c = '';
                }  
            }
        }else if(leadRecord.Status == CommonConstant.LEAD_STATUS_SALES_PROCESSING){
            if(leadRecord.Status__c == CommonConstant.LEAD_STATUS_INACTIVE || leadRecord.Status__c == CommonConstant.LEAD_STATUS_ESCALATED || leadRecord.Status__c == CommonConstant.LEAD_STATUS_FUTURE_PROSPECT){
                // leadRecord.Bad_Call_Count__c += 1;
                leadRecord.StageStatusChangeTime__c = datetime.now();
                leadRecord.Call_Result__c = '';
            }
            if(leadRecord.Status__c == CommonConstant.LEAD_STATUS_NEW || leadRecord.Status__c == CommonConstant.LEAD_STATUS_ACTIVE){
                if(mapDispostionvsObject.containsKey(dispositionKey) && mapDispostionvsObject.get(dispositionKey) != null && mapDispostionvsObject.get(dispositionKey).Call_Count__c != null){
                    //To fetch Call center queues
                    Group callCenterQueues = [SELECT Id,Name FROM Group WHERE Type =: CommonConstant.QUEUE AND Name LIKE :CommonConstant.CALL_CENTER_QUEUE LIMIT 1];
                    system.debug('callCenterQueues' + callCenterQueues);
                    
                    if(leadRecord.Bad_Call_Count__c >= mapDispostionvsObject.get(dispositionKey).Call_Count__c){
                        leadRecord.Status__c = CommonConstant.LEAD_STATUS_CALL_CENTER_TRIPARTY;
                        leadRecord.Bad_Call_Count__c =0;
                        leadRecord.StageStatusChangeTime__c = datetime.now();
                        leadRecord.Call_Result__c = '';
                        //leadRecord.OwnerId = callCenterQueues.Id;
                        
                        // Retrieve the UserIds of users in the callCenterQueues group
                        Set<Id> userIds = new Set<Id>();
                        for (GroupMember member : [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :callCenterQueues.Id AND UserOrGroupId <> NULL]) {
                            if (member.UserOrGroupId.getSObjectType() == User.sObjectType) {
                                userIds.add((Id)member.UserOrGroupId);
                            }
                        }
                        
                        // Retrieve the email addresses of users in the callCenterQueues group
                        List<String> userEmails = new List<String>();
                        if (!userIds.isEmpty()) {
                            for (User user : [SELECT Email FROM User WHERE Id IN :userIds]) {
                                userEmails.add(user.Email);
                            }
                        }
                        
                        createTaskCallCenterTriPartyCallDone(leadRecord,callCenterQueues);
                        // Retrieve the owner of the lead
                        Lead leadOwner = [SELECT Owner.Name, Owner.Email FROM Lead WHERE Id = :leadRecord.Id];
                        
                        // Retrieve the email templates
                        EmailTemplate LeadCallCenterEmailTemplate = [SELECT Id,Body,Subject,HtmlValue from EmailTemplate where DeveloperName =: CommonConstant.LEAD_TASK_ASSIGN_TO_CC_QUEUE_EMAIL];                            
                        
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        message.setSubject(LeadCallCenterEmailTemplate.Subject);
                        message.setTreatBodiesAsTemplate(True); 
                        message.setToAddresses(userEmails);
                        message.setCcAddresses(new List<String>{ leadOwner.Owner.Email });
                        message.setSaveAsActivity(true);
                        message.setTargetObjectId(leadRecord.Id);
                        message.setTreatTargetObjectAsRecipient(false);
                        message.setHtmlBody(LeadCallCenterEmailTemplate.HtmlValue);                        
                        
                        try {
                            Messaging.sendEmail(new List<Messaging.Email>{ message });                
                        } catch (Exception e) {                
                            System.debug('An error occurred while sending the email: ' + e.getMessage());               
                        }                          
                        
                        // leadRecord.OwnerId = callCenterQueues.Id;
                    } 
                }
            }
            else if(leadRecord.Status__c == CommonConstant.LEAD_STATUS_CALL_CENTER_TRIPARTY){
                if(mapDispostionvsObject.containsKey(dispositionKey) && mapDispostionvsObject.get(dispositionKey) != null && mapDispostionvsObject.get(dispositionKey).Call_Count__c != null){
                    
                    if(leadRecord.Bad_Call_Count__c >= mapDispostionvsObject.get(dispositionKey).Call_Count__c){
                        leadRecord.Status = CommonConstant.LEAD_STATUS_LOST;
                        leadRecord.Status__c = CommonConstant.LEAD_STATUS_INERT;
                        leadRecord.Bad_Call_Count__c =0;
                        leadRecord.StageStatusChangeTime__c = datetime.now();
                        leadRecord.Call_Result__c = '';
                    }
                }
            }
            
        }else if(leadRecord.Status == CommonConstant.LEAD_STATUS_APPLYING || leadRecord.Status == CommonConstant.LEAD_STATUS_LOST || leadRecord.Status == CommonConstant.LEAD_STATUS_CONVERTED){
            if((leadRecord.Status == CommonConstant.LEAD_STATUS_APPLYING && (leadRecord.Status__c == CommonConstant.LEAD_STATUS_QC_NEW || leadRecord.Status__c == CommonConstant.LEAD_STATUS_QC_WIP || leadRecord.Status__c == CommonConstant.LEAD_STATUS_QC_SALES_QUERY || leadRecord.Status__c == CommonConstant.LEAD_STATUS_ACTIVE)) ||
               (leadRecord.Status == CommonConstant.LEAD_STATUS_LOST && (leadRecord.Status__c == CommonConstant.LEAD_STATUS_NOT_INTRESTED || leadRecord.Status__c == CommonConstant.LEAD_STATUS_INVALID || leadRecord.Status__c == CommonConstant.LEAD_STATUS_DUPLICATE_LEADS || leadRecord.Status__c == CommonConstant.LEAD_STATUS_NOT_DOABLE)) ||
               (leadRecord.Status == CommonConstant.LEAD_STATUS_CONVERTED && leadRecord.Status__c == CommonConstant.LEAD_STATUS_PUST_TO_LOS)){
                   if(mapDispostionvsObject.containsKey(dispositionKey) && mapDispostionvsObject.get(dispositionKey) != null && mapDispostionvsObject.get(dispositionKey).Call_Count__c != null){
                       
                       if(leadRecord.Bad_Call_Count__c >= mapDispostionvsObject.get(dispositionKey).Call_Count__c){
                           leadRecord.Status = CommonConstant.LEAD_STATUS_SALES_PROCESSING;
                           leadRecord.Status__c = CommonConstant.LEAD_STATUS_CALL_CENTER_TRIPARTY;
                           leadRecord.Bad_Call_Count__c =0;
                           leadRecord.StageStatusChangeTime__c = datetime.now();
                           leadRecord.Call_Result__c = '';
                           
                       }
                   }
               }
            if(leadRecord.Status == CommonConstant.LEAD_STATUS_APPLYING && leadRecord.Status__c == CommonConstant.LEAD_STATUS_INACTIVE){
                leadRecord.Status = CommonConstant.LEAD_STATUS_APPLYING;
                leadRecord.Status__c = CommonConstant.LEAD_STATUS_ACTIVE;
                leadRecord.Bad_Call_Count__c =0;
                leadRecord.StageStatusChangeTime__c = datetime.now();
                leadRecord.Call_Result__c = '';
            }
            if(leadRecord.Status == CommonConstant.LEAD_STATUS_APPLYING && leadRecord.Status__c == CommonConstant.LEAD_STATUS_FUTURE_PROSPECT){
                if(mapDispostionvsObject.containsKey(dispositionKey) && mapDispostionvsObject.get(dispositionKey) != null && mapDispostionvsObject.get(dispositionKey).Call_Count__c != null){
                    
                    if(leadRecord.Bad_Call_Count__c >= mapDispostionvsObject.get(dispositionKey).Call_Count__c){
                        leadRecord.Status = CommonConstant.LEAD_STATUS_APPLYING;
                        leadRecord.Status__c = CommonConstant.LEAD_STATUS_ACTIVE;
                        leadRecord.Bad_Call_Count__c =0;
                        leadRecord.StageStatusChangeTime__c = datetime.now();
                        leadRecord.Call_Result__c = '';
                    }
                }
            }  
        }
        
    }
    
    // Method to updateSubjectStatusFromDisposition used for update task
    public static void updateSubjectStatusFromDisposition(List<Task> despositionTask) {
        Map<String,Lead> leadMap = createMapOfMobileNumberVsLead(despositionTask);   
        Map<String,User> userMap = createMapOfAgentIdVsUser(despositionTask);
        List<Task> taskList = new List<Task>();
        
        for(Task taskObj : despositionTask) {
            Task taskSObject = new Task(Id = taskObj.Id);
            setStatusAndLostReson(taskObj,taskSObject,leadMap);
            if(null != taskObj.call_back_date_time_New__c && taskObj.call_back_date_time_New__c != ''){
                taskSObject.Status = CommonConstant.OPEN;
                taskSObject.Call_Back_Date_time__c=(dateFormating(taskObj.call_back_date_time_New__c));
                taskSObject.ActivityDate =(dateFormating(taskObj.call_back_date_time_New__c)).date();
            }else if(taskObj.Call_Result__c == 'Willing To Apply'){
                taskSObject.Status = CommonConstant.OPEN;
            }else{
                taskSObject.Status = CommonConstant.COMPLETED;
            }
            
            //taskSObject.Sales_Comment__c = CommonConstant.COMPLETED;
            if(taskSObject.Call_Result__c == 'Call Back'){
                taskSObject.Type = 'CC_Callback';
            } else{
                taskSObject.Type = 'Disposition'; 
            }
            if(taskObj.Call_Result__c !=null && taskObj.call_back_date_time_New__c !=null){
                taskSObject.Subject = taskObj.Call_Result__c + '-' + taskObj.call_back_date_time_New__c;//ARS 30-JUN
            }            
            
            /********** checking lead id if not available then task map to lead *****************************/
            allocateTaskToLead(taskObj,taskSObject,leadMap);
            
            /************** Asign User to the task ***********************/
            if(null != taskObj.agentId__c && taskObj.agentId__c != ''){
                assignUserToTheLeadTask(taskObj,taskSObject,userMap);
            }
            taskList.add(taskSObject);  
        }
        update taskList;
    }
    
    // Method Used for to update the Missed Call Subject From Disposition 
    public static void updateMissedCallSubjectFromDisposition(List<Task> despositionTask) {
        Set<Id> LeadIdsSet = new Set<Id>();
        List<Task> taskList = new List<Task>();
        //List<Task> taskEmail = new List<Task>();
        for(Task taskObj : despositionTask) {
            Task taskSObject = new Task(Id = taskObj.Id);
            try{
                if(null == taskObj.Call_Result__c && null != taskObj.agentStatus__c && !string.isEmpty(taskObj.agentStatus__c) && taskObj.agentStatus__c.equalsIgnoreCase(CommonConstant.USER_DESCONNECT_AGENT_STATUS)){
                    taskSObject.Subject = CommonConstant.INBOUND_MISSED_CALL_DESPOSITION + '-' + taskObj.call_back_date_time_New__c; //ARS 30-JUN
                    taskSObject.Call_Result__c = CommonConstant.INBOUND_MISSED_CALL_DESPOSITION;
                    taskSObject.Status = CommonConstant.COMPLETED;
                    // taskSObject.Sales_Comment__c = CommonConstant.COMPLETED;
                    taskSObject.WhoId = taskObj.WhoId;
                    taskSObject.Caller_Id__c = taskObj.Caller_Id__c;
                    taskSObject.callStartTime__c = taskObj.callStartTime__c;
                    taskSObject.Type = 'Disposition';
                    taskList.add(taskSObject);
                    //taskEmail.add(taskSObject);
                    LeadIdsSet.add(taskObj.WhoId);
                }
            }catch(System.Exception e){
                e.getMessage();
            }   
        }
        if(taskList.size() > 0)
            alertLeadOwnerWhenInboundMissedCall(taskList);
        update taskList;
        //if(missedCallEmailSent == false){
        //alertLeadOwnerWhenInbboundMissedCall(taskList);
        //missedCallEmailSent = true;
        //}
        if(LeadIdsSet.size() >0){
            Boolean isCalledFromTask = true;
            List<Lead> leadList = [Select Id,Status,KYC_Consent__c,MobilePhone From Lead where Id In:LeadIdsSet]; 
            if(null != leadList && leadList.size()>0){
                LeadCampaignHandler.campaignAssignmentOnMissedCallDesposition(leadList);
            }
        } 
    }
    
    /************************** Formating date time *********************************/
    public static DateTime dateFormating(String convertDatetime){
        DateTime finalConvertedDateTime;
        try{
            if(null != convertDatetime) {
                List<String> dateTimeSplit = convertDatetime.split(' ');
                if(null != dateTimeSplit && dateTimeSplit.size()>0){
                    List<String> dateSplit = dateTimeSplit[0].split('/');
                    String strDate = dateSplit[2]+'-'+dateSplit[0]+'-'+dateSplit[1]+' '+dateTimeSplit[1];
                    finalConvertedDateTime = Datetime.valueOf(strDate);
                }
            }
        }catch(Exception e){
            e.getCause();
        } 
        return finalConvertedDateTime;
    }
    
    /******************* if sub desposition is present then maping it to lost reson ***************************/
    public static void setStatusAndLostReson(Task taskObj,Task taskSObject,Map<String,Lead> leadMap){
        try{
            string[] splitted = taskObj.Call_Result__c.split('__');
            taskSObject.Call_Result__c = splitted[0];
            taskSObject.Subject = splitted[0];
            
            Schema.DescribeFieldResult fieldDescribe = Task.Reason__c.getDescribe();
            
            /************************* Get the picklist values for the field *********************/
            List<Schema.PicklistEntry> picklistValues = fieldDescribe.getPicklistValues();
            
            /************************* checking the picklist values ****************************/
            Boolean fieldFlag = false;
            for (Schema.PicklistEntry picklistEntry : picklistValues) {
                if (picklistEntry.getValue().equals(splitted[1])) {
                    taskSObject.Reason__c = splitted[1];
                    taskSObject.Subject = splitted[0]+' - '+splitted[1];
                    fieldFlag =true;
                    break;
                }
            }
            if(!fieldFlag){
                try{
                    String mobileNo = '';
                    Long longNumber = Long.valueOf(taskObj.Caller_Id__c);
                    integer count = 1;
                    while (longNumber != 0) {
                        longNumber = longNumber / 10;
                        count = count+1;
                    }
                    /********** checking mobile number digit if extra then remove 0 *****************************/
                    if(count == 11){mobileNo = taskObj.Caller_Id__c.removeStart('0');}else{mobileNo =taskObj.Caller_Id__c;}
                    
                    Lead leadDetails = leadMap.get(mobileNo);
                    if(null != leadDetails) {
                        leadDetails.Service_Branch__c = splitted[1];
                    }else {
                        mobileNo = '+91'+mobileNo; 
                        leadDetails = leadMap.get(mobileNo);
                        if(null != leadDetails) {
                            leadDetails.Service_Branch__c = splitted[1];
                        }
                    }
                    update leadDetails;
                }catch(System.Exception e){
                    e.getMessage();
                } 
            }
            
        }catch(System.Exception e){
            e.getMessage();
        } 
    }
    
    /******************* assign User To The Lead Task ***************************/
    public static void assignUserToTheLeadTask(Task taskObj,Task taskSObject,Map<String,User> userMap){
        try{
            if(null != taskObj.agentId__c && taskObj.agentId__c != ''){
                User userDetails = userMap.get(taskObj.agentId__c);
                if(null != userDetails) {
                    taskSObject.OwnerId = userDetails.id;
                }
            }
        }catch(System.Exception e){
            e.getMessage();
        } 
    }
    
    /********** checking lead id if not available then task map to lead *****************************/
    public static void allocateTaskToLead(Task taskObj,Task taskSObject,Map<String,Lead> leadMap){
        try{
            if(null == taskObj.WhoId){
                String mobileNo = '';
                Long longNumber = Long.valueOf(taskObj.Caller_Id__c);
                integer count = 1;
                while (longNumber != 0) {
                    longNumber = longNumber / 10;
                    count = count+1;
                }
                /********** checking mobile number digit if extra then remove 0 *****************************/
                if(count == 11){mobileNo = taskObj.Caller_Id__c.removeStart('0');}else{mobileNo =taskObj.Caller_Id__c;}
                
                Lead leadDetails = leadMap.get(mobileNo);
                if(null != leadDetails) {
                    taskSObject.WhoId =  leadDetails.id;
                }
            }
        }catch(System.Exception e){
            e.getMessage();
        } 
    }
    
    /************************ Mobile number vs lead details map ****************/
    public static Map<String,Lead> createMapOfMobileNumberVsLead(List<Task> taskList){
        
        Map<String,Lead> mapOfMobileNoAndLead = new Map<String,Lead>();
        List<String> mobileNo = collectCallerNumber(taskList);
        if(null != mobileNo && mobileNo.size()>0) {
            List<Lead> leadDetailsList = new List<Lead>();
            leadDetailsList = [select id, FirstName, LastName, MobilePhone from lead where MobilePhone  = :mobileNo order by CreatedDate desc ];
            if(!leadDetailsList.IsEmpty() && leadDetailsList.size() > 0){
                for(Lead leadObj : leadDetailsList) {
                    if(mapOfMobileNoAndLead.containsKey(leadObj.MobilePhone)) {
                        continue;
                    } else {
                        mapOfMobileNoAndLead.put(leadObj.MobilePhone, leadObj);
                    }
                }        
            }
        }
        List<String> mobileNoNewList = new List<String>();
        for(String mobile : mobileNo){
            Long longNumber = Long.valueOf(mobile);
            integer count = 0;
            while (longNumber != 0) {
                longNumber = longNumber / 10;
                count = count+1;
            }
            if(count == 10){mobile = '+91'+mobile;}
            else if(count == 12){mobile = '+'+mobile;}
            mobileNoNewList.add(mobile);
        }
        if(null != mobileNoNewList && mobileNoNewList.size()>0) {
            List<Lead> leadDetailsList = new List<Lead>();
            leadDetailsList = [select id, FirstName, LastName, MobilePhone from lead where MobilePhone  = :mobileNoNewList order by CreatedDate desc ];
            if(!leadDetailsList.IsEmpty() && leadDetailsList.size() > 0){
                for(Lead leadObj : leadDetailsList) {
                    if(mapOfMobileNoAndLead.containsKey(leadObj.MobilePhone)) {
                        continue;
                    } else {
                        mapOfMobileNoAndLead.put(leadObj.MobilePhone, leadObj);
                    }
                }        
            }
        }
        return mapOfMobileNoAndLead;
    }
    
    /************************ Collect Caller number from task ****************/
    public static List<String> collectCallerNumber(List<Task> taskList){
        List<String> mobileNoList = new List<String>();
        if(null != taskList && taskList.size()>0) {
            for(Task taskObj :taskList) {
                try{
                    Long longNumber = Long.valueOf(taskObj.Caller_Id__c);
                    integer count = 1;
                    while (longNumber != 0) {
                        longNumber = longNumber / 10;
                        count = count+1;
                    }
                    /********** checking mobile number digit if extra then remove 0 *****************************/
                    if(count == 11){mobileNoList.add(taskObj.Caller_Id__c.removeStart('0'));}else{mobileNoList.add(taskObj.Caller_Id__c);}
                }catch(System.Exception e){
                    e.getMessage();
                } 
            }
        }
        return mobileNoList;
    }
    
    /************************ Agent Id vs User details map ****************/
    public static Map<String,User> createMapOfAgentIdVsUser(List<Task> taskList){
        
        Map<String,User> mapOfAgentIdAndUser = new Map<String,User>();
        List<String> agentIds = new List<String>();
        for(Task taskObj :taskList){
            agentIds.add(taskObj.agentId__c);
        }
        if(null != agentIds && agentIds.size()>0) {
            List<User> userDetailsList = new List<User>();
            userDetailsList = [select id, name, Email, Username from User where username = :agentIds order by CreatedDate desc ];
            if(!userDetailsList.IsEmpty() && userDetailsList.size() > 0){
                for(User userObj : userDetailsList) {
                    if(mapOfAgentIdAndUser.containsKey(userObj.Username)) {
                        continue;
                    } else {
                        mapOfAgentIdAndUser.put(userObj.Username, userObj);
                    }
                }        
            }
        }
        return mapOfAgentIdAndUser;
    }
    /********************************************************************************************************
* @author          Swati Yadav
* @description     getStageStatusFromDisposition method used to get dynamic count and stage and status for stage movement once disposition created.
* @param           No-Parameter  
* @date            28-Mar-2023   
* @return -Type    Map<String,Disposition_Type__mdt> : map of string and Disposition Type mdt Record Task where Dispostion is present 
********************************************************************************************************/
    public static Map<String,Disposition_Type__mdt> getStageStatusFromDisposition(){        
        list<Disposition_Type__mdt> lstdispositionStageStatus = new list<Disposition_Type__mdt>();
        lstdispositionStageStatus =[SELECT id,Disposition__c,Existing_Stage__c,Existing_Status__c,New_Stage__c,New_Status__c,Call_Count__c FROM Disposition_Type__mdt];
        
        Map<String,Disposition_Type__mdt> mapDispostionvsObject = new  Map<String,Disposition_Type__mdt>();       
        for(Disposition_Type__mdt objDispositionType: lstdispositionStageStatus){               
            mapDispostionvsObject.put(objDispositionType.Disposition__c+'#'+objDispositionType.Existing_Stage__c+'#'+objDispositionType.Existing_Status__c,objDispositionType);
        }        
        return mapDispostionvsObject;
    }
    
    /********************************************************************************************************
* @author          Chandrakant More
* @description     This method used to create task and assign to call center exception queue if data is missing on lead.
* @param           myTasks (List<Task>) : List of Task where Dispostion is present    
* @date            19 April 2023   
********************************************************************************************************/
    public static void taskCreationForCallCenterEcetionQueue(Lead objectLead,String missingField) {
        
        Group queueId = [SELECT Id, Name, Type from Group WHERE Type = 'Queue' AND Name =: System.Label.Exception_Queue];
        List<Task> taskList = new List<Task>();
        Task objectTask = new Task();
        objectTask.Subject = missingField +' must be updated.';
        objectTask.Status = CommonConstant.TASK_STATUS;
        objectTask.Priority = CommonConstant.TASK_PRIORITY_HIGH;
        objectTask.OwnerId = queueId.Id;
        objectTask.WhoId =objectLead.Id;
        objectTask.Type = 'Disposition';
        taskList.add(objectTask);
        if(!taskList.IsEmpty() && taskList.size() >0){
            try {
                insert taskList;
                sendEmailNotificationToCallCenterExceptionQueue(taskList,missingField);
            }catch(Exception e) {
                objectLead.addError(CommonConstant.ERROR_CONSTANT + e.getMessage());
            }
        }
    }
    
    /********************************************************************************************************
* @author          Chandrakant More
* @description     This method used to create task and assign to call center exception queue if data is missing on lead.
* @param           myTasks (List<Task>) : List of Task where Dispostion is present    
* @date            19 April 2023   
********************************************************************************************************/
    public static void sendEmailNotificationToCallCenterExceptionQueue(List<Task> taskList,String missingField) {
        
        List<String> recipientEmails = new List<String>();
        List<String> queueIdSet = new List<String>();
        List<Id> queueUsers = new List<Id>();
        for(Task objTask : taskList){
            if(objTask.OwnerId != null){
                queueIdSet.add(objTask.OwnerId);
            }
        }
        Group queueId = [SELECT Id, Name, Type from Group WHERE Type = 'Queue' AND Id =: queueIdSet]; 
        EmailTemplate invTemplate = [SELECT Id, Name, Subject, HtmlValue, Body FROM EmailTemplate WHERE Name =: System.Label.Send_Notification_To_Call_Center_Exception_Queue];
        List<OrgWideEmailAddress> orgEmailAddress=[select Id from OrgWideEmailAddress WHERE DisplayName =: System.Label.Organization_Wide_Email_Addresses];
        List<Messaging.SingleEmailMessage > Email_list = new List<Messaging.SingleEmailMessage>();
        
        string Name = invTemplate.Name;
        string subject = missingField+' '+invTemplate.subject;
        string emailBody = invTemplate.HtmlValue;
        
        for (GroupMember member : [SELECT UserOrGroupId FROM GroupMember WHERE GroupId =: queueId.Id]) {
            queueUsers.add(member.UserOrGroupId);
        }
        
        For(User objUser : [SELECT Email, IsActive FROM User WHERE Id =: queueUsers]){
            if(objUser.IsActive == true){
                recipientEmails.add(objUser.Email);   
            }    
        }
        emailBody = emailBody.replace('{!Lead.OwnerFirstName}', 'Team'); 
        emailBody = emailBody.replace('requiredfield', missingField); 
        for(Task objTask : taskList){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            if(orgEmailAddress.size() > 0){
                message.setOrgWideEmailAddressId(orgEmailAddress[0].Id); 
            }
            message.setSubject(subject);
            message.setTreatBodiesAsTemplate(True); 
            message.setToAddresses(recipientEmails);
            message.setSaveAsActivity(true);
            message.setTargetObjectId(objTask.WhoId);
            message.setTreatTargetObjectAsRecipient(false);
            message.setHtmlBody(emailBody);
            
            Email_list.add(message);   
            
            try {
                if(Email_list.size() > 0){
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(Email_list);
                    if(results.size() > 0){
                        if(results.get(0).isSuccess()){
                        }
                    }  
                }
            }catch(Exception e) {
                for(Task ObjectTask : taskList){
                    ObjectTask.addError(CommonConstant.ERROR_CONSTANT + e.getMessage());
                }
            }
        }
    }
    
    /********************************************************************************************************
* @author          Chandrakant More
* @description     assignmentOfStageOwnerToParentlead method used to used to assign stage owner to parent lead based on agent.
* @param           myTasks (List<Task>) : List of Task where Dispostion is present    
* @date            19 April 2023   
********************************************************************************************************/
    public static void assignmentOfStageOwnerToParentlead(List<Task> newTaskList){
        
        set<String> leadIdSet = new set<String>();
        set<String> userNameIdSet = new set<String>();
        for(Task objectTask : newTaskList){
            leadIdSet.add(objectTask.WhoId);
            userNameIdSet.add(objectTask.agentId__c);
        }
        
        
        List<Lead> parentLeadList = new List<Lead>();
        List<User> stageOwnerUserList = new List<User>();
        
        parentLeadList =[select Id, Name,Status,Status__c from Lead where Id In : leadIdSet];
        stageOwnerUserList =[SELECT Id,Name, Email,Username, MobilePhone FROM User where Username In : userNameIdSet];
        
        Map<String,String> mapUserNameAndOwnerId = new Map<String,String>();
        
        for(User objectUser : stageOwnerUserList){
            mapUserNameAndOwnerId.put(objectUser.Username,objectUser.Id);
        }
        
        Map<String, Lead> mapUpdateLeadStageOwner = new Map<String, Lead>();
        for(Lead objectead :parentLeadList) {
            mapUpdateLeadStageOwner.put(objectead.Id,objectead);
        }
        
        List<Lead> leadListToUpdateStageOwner = new List<Lead>();
        for(Task objectTask : newTaskList){
            if (mapUpdateLeadStageOwner.containsKey(objectTask.WhoId) && mapUserNameAndOwnerId.containsKey(objectTask.agentId__c) ) {
                mapUpdateLeadStageOwner.get(objectTask.WhoId).Stage_Owner__c =  mapUserNameAndOwnerId.get(objectTask.agentId__c) ;
                mapUpdateLeadStageOwner.get(objectTask.WhoId).Status = CommonConstant.LEAD_STATUS_SALES_PROCESSING;
                mapUpdateLeadStageOwner.get(objectTask.WhoId).Status__c = CommonConstant.LEAD_STATUS_ACTIVE;
                leadListToUpdateStageOwner.add(mapUpdateLeadStageOwner.get(objectTask.WhoId));
            }
            
        }
        if(!leadListToUpdateStageOwner.IsEmpty() && leadListToUpdateStageOwner.size() >0){
            Update leadListToUpdateStageOwner;
        }
    }
    
    /********************************************************************************************************
* @author          Vaibhav Hinge
* @description     If Call Back is added to the lead, then the old Call Back tasks should be marked as Completed..
* @param               
* @date            09 June 2023   
********************************************************************************************************/
    private static Boolean isExecuting = false;
    public static void createCallbackTask(List<Task> newTasks) {
        List<Task> callbackTasks = new List<Task>();
        List<Id> callbackTasksId = new List<Id>();
        Set<Id> leadIds = new Set<Id>();
        // Collect all the new callback tasks associated with leads
        for (Task task : newTasks) {
            if (task.Call_Result__c == CommonConstant.DISPOSITION_CALL_BACK && task.WhoId != null && String.valueOf(task.WhoId).startsWith('00Q') && task.Status != 'Completed' ) {
                callbackTasks.add(task);
                leadIds.add(task.WhoId);
                callbackTasksId.add(task.Id);
            }
        }
        
        if (!callbackTasks.isEmpty()) {
            // Complete all previous callback tasks for the lead
            if (!isExecuting) {
                isExecuting = true;
                completePreviousCallbackTasks(leadIds, callbackTasksId);
                isExecuting = false;
            }
        }
    }
    @future
    public static void completePreviousCallbackTasks(Set<Id> leadIds, List<Id> callbackTasks) {
        List<Task> previousTasks = [SELECT Id, Status,Call_Back_Date_time__c,call_back_date_time_New__c,Description FROM Task WHERE WhoId IN :leadIds AND Call_Result__c = :CommonConstant.DISPOSITION_CALL_BACK AND Id NOT IN :callbackTasks];
        List<Task> currentTasks = [SELECT Id, Status,Call_Back_Date_time__c,Description  FROM Task WHERE WhoId IN :leadIds AND Call_Result__c = :CommonConstant.DISPOSITION_CALL_BACK AND Id IN :callbackTasks ORDER BY CreatedDate DESC LIMIT 1 ];
        String userProfileID = UserInfo.getProfileId();         
        Profile ProfileName = [SELECT Id, Name FROM Profile WHERE Id = : userProfileID LIMIT 1];
        Datetime callbackdatetime;
        string comments = 'This callback activity has been automatically closed because a new callback activity has been created.';
        if (!currentTasks.isEmpty()) {
            if(currentTasks[0].Call_Back_Date_time__c == null){
                callbackdatetime = Datetime.now().addDays(1);
            }else{
                callbackdatetime=currentTasks[0].Call_Back_Date_time__c;
            }  
        }  
        if (!previousTasks.isEmpty()) {
            List<Task> tasksToUpdate = new List<Task>();
            for (Task task : previousTasks) {
                task.Status = 'Completed';
                task.Call_Back_Date_time__c=callbackdatetime;
                task.call_back_date_time_New__c=callbackdatetime.format('yyyy-MM-dd HH:mm:ss');
                task.Description=comments;  
                if(ProfileName.Name == 'Sales Profile'){
                    task.Sales_Comment__c = comments;
                }
                tasksToUpdate.add(task);
            }
            if(tasksToUpdate.size()>0){
                update tasksToUpdate;
            } 
        }
    }
    
    /********************************************************************************************************
* @author          Sohail Solapure
* @description     If Inbound Missed Call is added then alert lead owner
* @param           List<Task>  
* @date            13 June 2023   
********************************************************************************************************/
    public static void alertLeadOwnerWhenInboundMissedCall(List<Task> updatedTasks){
        //Get the email template for Inbound Missed call
        EmailTemplate inboundTemplate = [SELECT Id,Body,Subject,HtmlValue from EmailTemplate where DeveloperName =: System.Label.Inbound_Missed_Email_Template];
        OrgWideEmailAddress orgEmailAdd = [SELECT Id, Address, DisplayName from OrgWideEmailAddress limit 1];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        String sub = inboundTemplate.Subject;
        Set<Id> leadIds = new Set<Id>();
        Lead leadDeatils;
        
        //Assign the details of template to mail object
        mail.setTemplateId(inboundTemplate.Id);
        mail.setSaveAsActivity(true);
        mail.setOrgWideEmailAddressId(orgEmailAdd.Id);
        mail.setSubject(sub);
        
        //Get the lead ids from task
        for(Task currTask : updatedTasks){
            if(currTask.WhoId != null)
                leadIds.add(currTask.WhoId);
        }
        
        //Create map of leads
        Map<Id,Lead> leadDataMap = new Map<Id,Lead>([SELECT Id,Owner.Name,OwnerId FROM Lead WHERE Id In : leadIds]);
        
        //Get the information about call center exception queue if lead is not present with dialed number
        Group callCenterQueue = [SELECT Id,Name,(SELECT UserOrGroupId FROM GroupMembers) FROM Group WHERE Type =: System.Label.Group_Type AND Name =: System.Label.Exception_Queue LIMIT 1];
        
        //Get the information about call center exception queue if lead is not present with dialed number
        Group callCenter = [SELECT Id,Name,(SELECT UserOrGroupId FROM GroupMembers) FROM Group WHERE Type =: System.Label.Group_Type AND Name =: System.Label.Call_Center_Queue LIMIT 1];
        
        //Get the user ids from members
        List<String> toAddresses = new List<String>();
        Set<Id> userIds = new Set<Id>();
        for (GroupMember member : callCenterQueue.GroupMembers) 
            userIds.add(member.UserOrGroupId);
        
        for (GroupMember member : callCenter.GroupMembers) 
            userIds.add(member.UserOrGroupId);
        
        //Create map of users
        Map<Id, User> usersMap;
        if (!userIds.isEmpty()) 
            usersMap = new Map<Id, User>([SELECT Id, Email FROM User WHERE Id IN :userIds]);
        
        //Get the list of task
        List<Task> taskList = [SELECT Id,callStartTime__c,Caller_Id__c,WhoId from Task WHERE Id IN: updatedTasks];
        //Iterate the list to send email
        for(Task currTask : taskList){
            //Create url of task 
            String taskLink = System.URL.getSalesforceBaseURL().toExternalForm() + '/'+currTask.Id;
            
            //If task is created via IVR
            if(taskLink.contains('-sites'))
                taskLink = taskLink.replace('-site','');
            
            //If task is created via IVR
            if(taskLink.contains('salesforces'))
                taskLink = taskLink.replace('salesforces','salesforce');
            
            leadDeatils = leadDataMap.get(currTask.WhoId);
            //If lead present then notify to lead owner
            if(leadDeatils != null){
                String ownerName;
                if(leadDeatils.OwnerId == callCenter.Id){
                    ownerName = callCenter.Name;
                    for (GroupMember member : callCenterQueue.GroupMembers) {
                        User user = usersMap.get(member.UserOrGroupId);
                        toAddresses.add(user.Email);
                    }
                    
                    mail.setToAddresses(toAddresses);
                }
                else{
                    ownerName = leadDeatils.Owner.Name;
                    mail.setToAddresses(new list<string>{leadDeatils.OwnerId}); 
                }
                //= leadDeatils.Owner.Name;
                
                String emailBody = ((String)inboundTemplate.HtmlValue)
                    .replace(CommonConstant.TASK_LEAD_OWNER,ownerName)
                    .replace(CommonConstant.TASK_DATE_TIME,currTask.callStartTime__c != null ? currTask.callStartTime__c.format('MM/dd/yyyy hh:mm a') : '')
                    .replace(CommonConstant.TASK_CALLER_NUMBER,currTask.Caller_Id__c != null ? currTask.Caller_Id__c : '')
                    .replace(CommonConstant.TASK_LINK,taskLink);
                mail.setTargetObjectId(leadDeatils.Id);
                mail.setTreatTargetObjectAsRecipient(false);
                //mail.setToAddresses(new list<string>{leadDeatils.OwnerId,'sohail.solapure@thinqloud.com','gokul.bhujbal@thinqloud.com','aditya.hande@extrapreneursindia.com'}); 
                mail.setHtmlBody(emailBody);
                mail.setTreatBodiesAsTemplate(true); 
            }
            //Else notify exeception's queue members
            else{
                String ownerName = callCenterQueue.Name;
                for (GroupMember member : callCenterQueue.GroupMembers) {
                    User user = usersMap.get(member.UserOrGroupId);
                    toAddresses.add(user.Email);
                }
                
                
                String emailBody = ((String)inboundTemplate.HtmlValue)
                    .replace(CommonConstant.TASK_LEAD_OWNER,ownerName)
                    .replace(CommonConstant.TASK_DATE_TIME,currTask.callStartTime__c != null ? currTask.callStartTime__c.format('MM/dd/yyyy hh:mm a') : '')
                    .replace(CommonConstant.TASK_CALLER_NUMBER,currTask.Caller_Id__c != null ? currTask.Caller_Id__c : '')
                    .replace(CommonConstant.TASK_LINK,taskLink);
                
                mail.setToAddresses(toAddresses); 
                mail.setHtmlBody(emailBody);
                mail.setTreatBodiesAsTemplate(true); 
            }
            
            try{
                Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }catch(Exception e){
                System.debug(CommonConstant.ERROR_CONSTANT+e.getMessage());
            }
        }
    }
    public static void createTaskCallCenterTriPartyCallDone(Lead leadRecord,Group callCenterQueues){
        
        Task newCallCenterTriPartyTask = new Task();
        newCallCenterTriPartyTask.WhoId = leadRecord.Id;
        newCallCenterTriPartyTask.OwnerId = callCenterQueues.Id; 
        newCallCenterTriPartyTask.Call_Result__c = 'Tri Party Call';
        newCallCenterTriPartyTask.Subject = newCallCenterTriPartyTask.Call_Result__c;
        newCallCenterTriPartyTask.Description = 'Tri Party Call';
        newCallCenterTriPartyTask.ActivityDate = Date.today() + 2;
        insert newCallCenterTriPartyTask;
    }
    
    public static void sendEmailNotificationToLoginDeskUserAfterCompleteDocumentIssue(List<Task> completedTaskOnject) {
        Set<Id> parentLeadsId = new Set<Id>();
        List<Lead> updateLeads = New List<Lead>();
        List<Lead> leadList = new List<Lead>();
        Map<Id,Lead> mapIdVsLead = new  Map<Id,Lead>();
        for(Task objtask : completedTaskOnject ){
            parentLeadsId.add(objtask.WhoId);
        }
        leadList = [select id,Name, Stage_Owner__r.Email,Stage_Owner__r.Name ,Stage_Owner__c,  Owner.Email  from Lead where Id In : parentLeadsId];
        for(Lead objLead : leadList ){
            objLead.Status__c = system.label.Lead_Status_QC_WIP;
            mapIdVsLead.put(objLead.Id,objLead);
            updateLeads.add(objLead);
        }
        
        if(updateLeads.size() > 0){
            update updateLeads;
        }
        
        EmailTemplate RejectedAcceptedEmailTemp = [SELECT Id, Subject, Body, HTMLValue FROM EmailTemplate WHERE Name =: label.Document_issue_resolved_Email_Template_Name];
        List<OrgWideEmailAddress> owea = [select Id from OrgWideEmailAddress WHERE Address='noreply@auxilo.com'];
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<String> SetToAddress = new List<String>();
        List<Task> taskList = new List<Task>();
        String leadRecordLink ;
        for(Task objtask : completedTaskOnject ){
            leadRecordLink = URL.getSalesforceBaseUrl().toExternalForm() + '/' + mapIdVsLead.get(objtask.WhoId).Id;
            String Subject = RejectedAcceptedEmailTemp.Subject;
            Subject = Subject.replace('Document issue resolved',Subject+' of the lead - '+ mapIdVsLead.get(objtask.WhoId).Name);
            String body = RejectedAcceptedEmailTemp.HTMLValue;
            String getLeadName = mapIdVsLead.get(objtask.WhoId).Stage_Owner__r.Name;
            if(mapIdVsLead.get(objtask.WhoId).Stage_Owner__r.Email != null){
                SetToAddress.add(mapIdVsLead.get(objtask.WhoId).Stage_Owner__r.Email);
            }
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject(Subject);
            if(getLeadName != null) {
                body = body.replace('{!Document_Checklist__c.Lead_Name__c}',getLeadName);
            }
            if(leadRecordLink != null){
                body = body.replace('{!Document_Checklist__c.Lead__c}',leadRecordLink);
            }
            email.setHtmlBody(body);
            email.setTemplateId(RejectedAcceptedEmailTemp.Id);
            email.setTargetObjectId(mapIdVsLead.get(objtask.WhoId).Id);
            email.setSaveAsActivity(true);
            email.setTreatTargetObjectAsRecipient(false);
            email.setToAddresses(SetToAddress);
            email.setTreatBodiesAsTemplate(true);
            email.setOrgWideEmailAddressId(owea[0].Id);
            emailList.add(email);
        }
        if (!emailList.isEmpty()) {
            Messaging.sendEmail(emailList);
        } 
    }
}