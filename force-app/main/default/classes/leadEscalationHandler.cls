/*********************************************************************************************
* @author          Thinqloud Solutions (Vaibhav Hinge)
* @description     This class is used for update datetime fields for no action flows in dispositions
* @date            27/04/2023 (April,2023)    
* @testClass: 
**********************************************************************************************/

public class LeadEscalationHandler {
    
    /********************************************************************************************************
* @author          Vaibhav Hinge
* @description     To set date and time with in the business hours for esclation of lead,in No action disposition
* @param           leadList   
* @date            27/04/2023 (April,2023)
********************************************************************************************************/
    
    Public static void settime(list<lead> leadList){	 
        
		 // Get custom metadata value From Escalate_Setting__mdt
        List<Escalate_Setting__mdt> metadata = [SELECT Escalate_in_Minutes__c,Escalate_in_Minutes_Applying_Active__c,Escalate_in_Minutes_Prospect__c,Escalate_in_Minutes_SP_Inactive__c,Escalate_in_Minutes_SP_New_Active__c,Escalate_in_Minutes_SP_Active__c FROM Escalate_Setting__mdt LIMIT 1];
        
        // Convert Decimal format of custom metadata into Integer format
        Integer esclateTimeMin = (integer)metadata[0].Escalate_in_Minutes__c;
        Integer esclateTimeAppActive = (integer)metadata[0].Escalate_in_Minutes_Applying_Active__c;
        Integer esclateTimeProspActive = (integer)metadata[0].Escalate_in_Minutes_Prospect__c;
        Integer esclateTimeSPInactive = (integer)metadata[0].Escalate_in_Minutes_SP_Inactive__c;
        Integer esclateTimeSPNewActive = (integer)metadata[0].Escalate_in_Minutes_SP_New_Active__c;
        Integer esclateTimeSPActive = (integer)metadata[0].Escalate_in_Minutes_SP_Active__c;
        
        // Get Current time 
        Datetime currentTime = system.now();
        
        // Set target time to call (BusinesshoursService) class and (getesclatetime) method of that class
        Datetime targetDateTime =BusinesshoursService.getesclatetime(currentTime,esclateTimeMin);
        Datetime targetDateTimeAppActive =BusinesshoursService.getesclatetime(currentTime,esclateTimeAppActive);
        Datetime targetDateTimeProspActive =BusinesshoursService.getesclatetime(currentTime,esclateTimeProspActive);
        Datetime targetDateTimeSPInactive =BusinesshoursService.getesclatetime(currentTime,esclateTimeSPInactive);
        Datetime targetDateTimeSPNewActive =BusinesshoursService.getesclatetime(currentTime,esclateTimeSPNewActive);
        Datetime targetDateTimeSPActive =BusinesshoursService.getesclatetime(currentTime,esclateTimeSPActive);
        
        
        //Iterate through the list of lead
        For(lead lead : leadList){
            if(lead.Status==CommonConstant.LEAD_STATUS_FRESH && lead.Status__c== CommonConstant.LEAD_STATUS_NEW ){
                Lead.FreshNewToesclatedateTime__c = targetDateTime;
            }
            else if(lead.Status== CommonConstant.LEAD_STATUS_PROSPECT && lead.Status__c== CommonConstant.LEAD_STATUS_ACTIVE ){
                Lead.ProspectActiveToInactive__c = targetDateTimeProspActive;
            }
            else if(lead.Status== CommonConstant.LEAD_STATUS_SALES_PROCESSING && lead.Status__c== CommonConstant.LEAD_STATUS_NEW  ){
                Lead.SPNewActiveToInactive__c = targetDateTimeSPNewActive;
            }
            else if(lead.Status == CommonConstant.LEAD_STATUS_SALES_PROCESSING && lead.Status__c==CommonConstant.LEAD_STATUS_ACTIVE ){
                Lead.SPActiveToInactive__c = targetDateTimeSPActive;
            }
            else if(lead.Status==CommonConstant.LEAD_STATUS_SALES_PROCESSING && lead.Status__c== CommonConstant.LEAD_STATUS_INACTIVE ){
                Lead.SPInactiveToEscalated__c = targetDateTimeSPInactive ;
            }
            else if(lead.Status == CommonConstant.LEAD_STATUS_APPLYING && lead.Status__c==CommonConstant.LEAD_STATUS_ACTIVE ){
                Lead.ApplyingActiveToInactive__c = targetDateTimeAppActive;
            } 
        }
        
    }
}