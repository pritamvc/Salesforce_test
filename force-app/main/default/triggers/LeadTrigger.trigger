/*********************************************************************************************
* @author          Thinqloud Solutions (Chandrakant More)
* @description     This trigger is used to call LeadTriggerHandler(Create Campaign Member once lead created Or Updated)
* @date            14/02/2023    
* @testClass: 
**********************************************************************************************/
trigger LeadTrigger on Lead (before insert,before update,after insert,after Update) {
    List<Lead> newLeadInserted = new List<Lead>();
    List<Lead> beforeLeadInsert = new List<Lead>();
    List<Lead> beforeLeadupdate = new List<Lead>();
    List<Lead> leadUpdateBasedOnProfile = new List<Lead>();
    List<Lead> deleteCampaignMemberList = new List<Lead>();
    List<Lead> afterUpdate = new List<Lead>();
    Set<Id> leadIds = new Set<Id>();
    
    Triggers_Setup__c cs = Triggers_Setup__c.getValues('Lead Trigger');
    system.debug('cs' +cs);
    
    if(cs.Trigger_On__c == true){
        
        if(trigger.IsAfter && trigger.IsInsert){
            for(Lead ObjectLead : trigger.new){
                if((ObjectLead.Status == System.Label.Lead_Status_Fresh || ObjectLead.Status == System.Label.Lead_Status_Suspect ||
                    ObjectLead.Status == System.Label.Lead_Status_Prospect) /*&&
ObjectLead.Call_Result__c == CommonConstant.INBOUND_MISSED_CALL_DESPOSITION*/){
    newLeadInserted.add(ObjectLead);
}
                
                if(ObjectLead.Course_Start_Date__c != null || ObjectLead.Course_Duration_Months__c != null){
                    //afterUpdate.add(ObjectLead);
                    leadIds.add(ObjectLead.Id);
                }
            }
        }
             List<ID> LeadIDs = new List<Id>();
        if(trigger.IsAfter && trigger.IsUpdate){
            List<Lead> leadUpdate = new List<Lead>();
            List<Lead> myUpdatedLeads = new List<Lead>();
         
            //List<Lead> callCenterTriLeads = new List<Lead>();
            for(Lead ObjectLead : trigger.new){
              
                if(((Trigger.OldMap.get(ObjectLead.Id).Status != ObjectLead.Status)
                    && ((ObjectLead.Status == System.Label.Lead_Status_Fresh || 
                         ObjectLead.Status == System.Label.Lead_Status_Suspect ||
                         ObjectLead.Status == System.Label.Lead_Status_Prospect) && ObjectLead.DoNotCall == false) || 
                    (Trigger.OldMap.get(ObjectLead.Id).Status__c != ObjectLead.Status__c) && 
                    ObjectLead.Status == System.Label.Lead_stage_Sales_Processing) &&
                   ObjectLead.Call_Result__c == CommonConstant.INBOUND_MISSED_CALL_DESPOSITION){
                       newLeadInserted.add(ObjectLead);
                   }
                if((ObjectLead.Status != Trigger.oldMap.get(ObjectLead.Id).Status) && (ObjectLead.Status == System.Label.Lead_stage_Sales_Processing || ObjectLead.Status == System.Label.Lead_Stage_Applying || ObjectLead.Status == System.Label.Lead_stage_Lost || ObjectLead.Status == System.Label.Lead_Stage_Converted)) {
                    deleteCampaignMemberList.add(ObjectLead);
                }
                
                if((ObjectLead.Course_Start_Date__c != Trigger.oldMap.get(ObjectLead.Id).Course_Start_Date__c) || (ObjectLead.Course_Duration_Months__c !=Trigger.oldMap.get(ObjectLead.Id).Course_Duration_Months__c)){
                    //afterUpdate.add(ObjectLead);
                    leadIds.add(ObjectLead.Id);
                }
                //if((ObjectLead.Status__c != Trigger.oldMap.get(ObjectLead.Id).Status__c) && ObjectLead.Status__c == System.Label.Lead_Status_Call_centre_triparty){
                //callCenterTriLeads.add(ObjectLead);
                //}
                //Sohail: To check if DNC is enabled then stage move to lostDNC
                if(ObjectLead.DoNotCall != trigger.oldMap.get(ObjectLead.Id).DoNotCall && ObjectLead.DoNotCall == true){
                    leadUpdate.add(ObjectLead);
                }
            }
            if(leadUpdate !=null && leadUpdate.size() > 0){
                myUpdatedLeads = [SELECT Id,Status,Status__c FROM Lead WHERE id In:leadUpdate];
                CampaignMemberHelper.deleteCampaignMembers(myUpdatedLeads);
                for(Lead l:myUpdatedLeads){
                    l.Status = System.Label.Lead_stage_Lost;
                    l.Status__c = System.Label.Lead_Status_DNC;
                    l.StageStatusChangeTime__c = System.today();
                }
            }
            Database.update(myUpdatedLeads);
            //if(callCenterTriLeads.size() > 0){
            //LeadCampaignHandler.assignCallCenterTripaty(callCenterTriLeads);
            //}
            //
            
        }
        
        if (!leadIds.isEmpty()) {
            //if (!afterUpdate.IsEmpty() && afterUpdate.size() >0) {
            List<Lead> leadsToUpdate = [SELECT Id, Course_Start_Date__c,Course_End_Date__c, Course_Duration_Months__c FROM Lead WHERE Id IN :leadIds];
            LeadTriggerHandler.updateCourseEndDate(leadsToUpdate);
        }
        
        
        // By Chandrakant More
        if(!System.isFuture() && !System.isBatch()){
            if(!newLeadInserted.IsEmpty() && newLeadInserted.size() > 0) {
                //This method is used to Create Campaign Member once lead created Or updated. **/
                // LeadTriggerHandler.campaignAssignmentOnLead(newLeadInserted); // commented by aasim.
                //LeadTriggerHandler.childCampaignAssignmentOnLead(newLeadInserted, false); 
                LeadCampaignHandler.campaignAssignmentOnLead(newLeadInserted);        
            }
        }
        
        // To delete old campaign member once lead stage is updated to Sales Processing **/
        if(!deleteCampaignMemberList.IsEmpty() && deleteCampaignMemberList.size() >0){
            CampaignMemberHelper.deleteCampaignMembers(deleteCampaignMemberList);
        }
        
        if(trigger.Isbefore && trigger.IsInsert){
            for(Lead ObjectLead : trigger.new){
                if(ObjectLead.MobilePhone != null){
                    beforeLeadInsert.add(ObjectLead);
                }
                if(ObjectLead.Tuition_Fees__c != null){
                    Double increasePercentage = 9;
                    ObjectLead.Lead_form_Weightage__c = increasePercentage;
                }
                if(ObjectLead.Bulk_Upload__c == false){
                    leadUpdateBasedOnProfile.add(ObjectLead);
                }
                
            }
        }
        
        if(!beforeLeadInsert.IsEmpty() && beforeLeadInsert.size() >0){
            LeadTriggerHandler.duplicateLeadManagement(beforeLeadInsert);
        }
        
        // By Chandrakant More
        if(!System.isFuture() && !System.isBatch()){ 
            if(!leadUpdateBasedOnProfile.IsEmpty() && leadUpdateBasedOnProfile.size() > 0) {
                //This method is used Update lead information such as stage, statu and owner based on profile. 
                LeadTriggerHandler.ownerAssignmentLead(leadUpdateBasedOnProfile); 
            }
        }
        List<Lead> updatedLeadList = new List<Lead>();       
        if(Trigger.isUpdate){
            for(Lead ObjectLead : trigger.new){
                if(ObjectLead.Country_of_Study__c !=trigger.oldMap.get(ObjectLead.Id).Country_of_Study__c || ObjectLead.Course_Stream__c !=trigger.oldMap.get(ObjectLead.Id).Course_Stream__c
                   || ObjectLead.Loan_Required_A_B__c !=trigger.oldMap.get(ObjectLead.Id).Loan_Required_A_B__c || ObjectLead.Admission_Status__c !=trigger.oldMap.get(ObjectLead.Id).Admission_Status__c
                   || ObjectLead.KYC_Consent__c !=trigger.oldMap.get(ObjectLead.Id).KYC_Consent__c || ObjectLead.Gender__c !=trigger.oldMap.get(ObjectLead.Id).Gender__c
                   || ObjectLead.Source_Name__c !=trigger.oldMap.get(ObjectLead.Id).Source_Name__c ){
                       updatedLeadList.add(ObjectLead);
                   }
            }
            if(null != updatedLeadList && updatedLeadList.size() >0){
                //LeadCampaignHandler.campaignAssignmentOnLead(updatedLeadList);
            }
        }
        
        
        if(trigger.Isbefore && trigger.Isupdate ){
            List<Lead> leadUpdate = new List<Lead>();
            // SalesProcessingStageDisposition.checkLeadStage(Trigger.new, Trigger.oldMap);
            for(Lead ObjectLead : trigger.new){
                if(ObjectLead.MobilePhone !=trigger.oldMap.get(ObjectLead.Id).MobilePhone || ObjectLead.Email !=trigger.oldMap.get(ObjectLead.Id).Email || 
                   ObjectLead.FirstName !=trigger.oldMap.get(ObjectLead.Id).FirstName){
                       beforeLeadupdate.add(ObjectLead);
                   }
                
                
            }
            
             
        }
        
        if(!beforeLeadupdate.IsEmpty() && beforeLeadupdate.size() >0){
            LeadTriggerHandler.duplicateLeadManagement(beforeLeadupdate);
        }
        
        //For Lead Assignment
        if(Trigger.isBefore && Trigger.isUpdate){
            Set<String> allowedStages = new Set<String>{'Fresh', 'Suspect', 'Prospect'};
                List<Lead> leadsToUpdate = new List<Lead>();
            List<Lead> assignSalesuser = new List<Lead>();
            List<Lead> assignLoginDeskUser= new List<Lead>();
            Group callCenterQueue = [SELECT Id FROM Group WHERE Type =: System.Label.Group_Type AND Name =: System.Label.Call_Center_Queue LIMIT 1];
            for(Lead l:Trigger.New){
                Lead oldLead = Trigger.oldMap.get(l.Id);
                if(l.Status != oldLead.Status && l.Status == System.Label.Lead_stage_Sales_Processing && l.Status__c == 'New' && l.Service_Branch__c != null && l.OwnerId == callCenterQueue.Id){
                    assignSalesuser.add(l);
                }
                if(l.Status__c != oldLead.Status__c && l.Status == System.Label.Lead_Stage_Applying && l.Status__c == System.Label.Lead_Status_QC_New && l.Service_Branch__c != null){
                    assignLoginDeskUser.add(l);
                }
                // if (allowedStages.contains(l.Status)) {
                leadsToUpdate.add(l);
                // }
            }
            if(assignSalesuser.size() > 0){
                LeadAssignmentFromServiceBranch.assignQueue(assignSalesuser);
                
            }
            if(assignLoginDeskUser.size() > 0){
                LeadAssignmentFromServiceBranch.assignLoginDeskUser(assignLoginDeskUser);
            }
            if(leadsToUpdate.size() > 0){
                LeadTriggerHandler.updateLeadPercentage(leadsToUpdate,Trigger.oldMap);
            }
        }
        
        //For Email alert after lead assignment
        if(Trigger.isAfter && Trigger.isUpdate){
            List<Lead> sendAlertList = new List<Lead>();
            for(Lead l:Trigger.New){
                if(l.Status == System.Label.Lead_stage_Sales_Processing){
                    Lead oldLead = Trigger.oldMap.get(l.Id);
                    if (l.Status != null && l.Status != oldLead.Status) {
                        sendAlertList.add(l);
                    }
                }
                if(l.Status == System.Label.Lead_Stage_Applying){
                    Lead oldLead = Trigger.oldMap.get(l.Id);
                    if (l.Status__c != null && l.Status__c != oldLead.Status__c && l.Status__c == System.Label.Lead_Status_QC_New) {
                        sendAlertList.add(l);
                    }
                }
            }
            if(sendAlertList.size() > 0){
                LeadAssignmentFromServiceBranch.sendEmailAlert(sendAlertList);
            }
        }
        
        //For Mobile number
        if(Trigger.isBefore && Trigger.isInsert){
            //LeadTriggerHandler.assignMobileNumber(Trigger.New);
        }
        
        // Custom Validation On Analytical Score,Language score And University/Instititute/Course
        if(Trigger.isbefore && (Trigger.isInsert || Trigger.isUpdate)){
            CustomValidationHandler.customValidationMethod(Trigger.New);
        }
        // Lead Esclated with business hours
        if(Trigger.isbefore && (Trigger.isInsert || Trigger.isUpdate)){
           List<Lead> lstLead = new List<Lead>();
        For(lead lead : Trigger.New){
            if((lead.Status==CommonConstant.LEAD_STATUS_FRESH && lead.Status__c== CommonConstant.LEAD_STATUS_NEW) ||
                (lead.Status== CommonConstant.LEAD_STATUS_PROSPECT && lead.Status__c== CommonConstant.LEAD_STATUS_ACTIVE ) ||
                (lead.Status== CommonConstant.LEAD_STATUS_SALES_PROCESSING && lead.Status__c== CommonConstant.LEAD_STATUS_NEW ) ||
                (lead.Status == CommonConstant.LEAD_STATUS_SALES_PROCESSING && lead.Status__c==CommonConstant.LEAD_STATUS_ACTIVE ) || 
                (lead.Status==CommonConstant.LEAD_STATUS_SALES_PROCESSING && lead.Status__c== CommonConstant.LEAD_STATUS_INACTIVE ) ||
                (lead.Status == CommonConstant.LEAD_STATUS_APPLYING && lead.Status__c==CommonConstant.LEAD_STATUS_ACTIVE )){
                
                lstLead.add(lead);    
            }                
            
        }
        if(lstLead.size() > 0){
            leadEscalationHandler.settime(lstLead);
        }
        }  
        // Update Lead Region based on Service Branch
        if(Trigger.isbefore && (Trigger.isInsert || Trigger.isUpdate)){
            if(Trigger.isInsert){
            LeadTriggerHandler.updateLeadRegion(Trigger.new);
        }
        if(Trigger.isUpdate){
            List<Lead> lstLead = new List<Lead>();
             for(Lead ObjectLead:Trigger.New){
                if(Trigger.OldMap.get(ObjectLead.Id).Service_Branch__c != ObjectLead.Service_Branch__c){
                    lstLead.add(ObjectLead); 
                }
            }   
            if(lstLead.size() > 0){
                LeadTriggerHandler.updateLeadRegion(Trigger.new);
            }
        }
        }
        // When lead lost then complete all task
        if(Trigger.isAfter && Trigger.isUpdate){
            // LeadTriggerHandler.updateLeadRegion(Trigger.new);
            set<Id> leadId = New Set<Id>();
            Boolean callCenter = true ;
            for(Lead l:Trigger.New){
                Lead oldLead = Trigger.oldMap.get(l.Id);
                if(l.Status == System.Label.Lead_stage_Lost){
                    if(oldLead.Status == System.Label.Lead_Status_Fresh || oldLead.Status == System.Label.Lead_Status_Suspect || oldLead.Status == System.Label.Lead_Status_Prospect){
                        callCenter = false;
                    } 
                    leadId.add(l.Id);
                } 
            }
            LeadTriggerHandler.updateTaskStatusComplete(leadId,callCenter);
        }
        
    }
}