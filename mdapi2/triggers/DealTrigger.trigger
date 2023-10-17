/*********************************************************************************************
* @author          Thinqloud Solutions (Dhanaji Patil)
* @description     This trigger is used to call OpportunityTriggerHandler for upload the lead documents on the LOS
* @date            10/05/2023    
* @testClass: 
**********************************************************************************************/


trigger DealTrigger on Opportunity (after insert,after Update,before insert,before Update) {

      /********************************************************************************************************
    * @author          Vaibhav Hinge
    * @description     This are used For deal Assignment.
    * @return          No-return
    * @date            28 JUNE 2023   
    ********************************************************************************************************/
    
    
    //For deal Assignment
    if(Trigger.isBefore && Trigger.isUpdate){
        List<Opportunity> assignUnderwriterStageOwnerQueueId = new List<Opportunity>();
        List<Opportunity> assignCManagerStageOwnerQueueId = new List<Opportunity>();
        for(Opportunity Opp :Trigger.New){
        Opportunity oldOpp = Trigger.oldMap.get(Opp.Id);
        if(oldOpp.StageName==CommonConstant.DATAENTERY && Opp.StageName==CommonConstant.CREDIT_ASSESSMENT && (Opp.Status__c==CommonConstant.CA_NEW || Opp.Status__c==CommonConstant.WIP)&& Opp.Service_Branch__c != null ){
            assignUnderwriterStageOwnerQueueId.add(Opp);   
         }
         if((oldOpp.Status__c==CommonConstant.CA_NEW || oldOpp.Status__c==CommonConstant.WIP) && Opp.StageName==CommonConstant.CREDIT_ASSESSMENT &&
            Opp.Status__c== CommonConstant.APPROVER && Opp.Service_Branch__c != null){  
            assignCManagerStageOwnerQueueId.add(Opp);   
         }   
      }
        if(assignUnderwriterStageOwnerQueueId.size()>0){
          DealAssignmentFromBranchAndRegion.assignQueueUpdated(assignUnderwriterStageOwnerQueueId);
        }    
        if(assignCManagerStageOwnerQueueId.size()>0){
           DealAssignmentFromBranchAndRegion.assignApproverQueue(assignCManagerStageOwnerQueueId);
        }
    }
    //For Email alert after Deal assignment
    if(Trigger.isAfter && Trigger.isUpdate){
        List<Opportunity> sendEmailAlertList = new List<Opportunity>();
        List<Id> oppIds = new List<Id>();
        List<Id> refereBackIds = new List<Id>();
        List<Id> approverQueue = new List<Id>();
        Boolean refereBack = false;
        Boolean reAppeal = false;
        for(Opportunity deals :Trigger.New){
            if( deals.StageName == CommonConstant.CREDIT_ASSESSMENT ){
                Opportunity oldDeal = Trigger.oldMap.get(deals.Id);
                if((oldDeal.Status__c==CommonConstant.CA_NEW || oldDeal.Status__c==CommonConstant.WIP) && deals.Status__c== CommonConstant.APPROVER) {
                       approverQueue.add(deals.Id);
                   }
                
                else if(oldDeal.Status__c== CommonConstant.APPROVER && deals.Status__c==CommonConstant.WIP && deals.Description != null ){
                    oppIds.add(deals.Id);
                    refereBack = true;
				}
                else if(oldDeal.StageName== CommonConstant.LOSTDEAL && (oldDeal.Status__c==CommonConstant.REJECTET_CA || oldDeal.Status__c==CommonConstant.REJECTET_CM )){
                       oppIds.add(deals.Id);
                       reAppeal = true;
				}
                else if (deals.Stage_Owner__c != oldDeal.Stage_Owner__c) {
                    oppIds.add(deals.Id);
                }
            }
		}
        if(oppIds.size() > 0){
            DealAssignmentFromBranchAndRegion.sendEmailDealStageOwner(oppIds,refereBack,reAppeal);
        }
        if(approverQueue.size() > 0){
            DealAssignmentFromBranchAndRegion.sendEmailDealApproveQueue(approverQueue);
        }
	}

    //Added by Avadhut - 20-Jul-23
    // if (Trigger.isAfter && Trigger.isInsert) {
    //     OpportunityTriggerHandler.updateTasksForOpportunity(Trigger.new);
    // }
  }