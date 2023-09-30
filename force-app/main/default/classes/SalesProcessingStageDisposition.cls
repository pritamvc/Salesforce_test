/*

trigger LeadTrigger on Lead (before update) {
if(trigger.Isbefore && trigger.Isupdate){
      SalesProcessingStageDisposition.checkLeadStage(Trigger.new, Trigger.oldMap);
}
  }
*/
    /********************************************************************************************************
     * @author          Vaibhav Hinge
     * @description     This Class used for user role "Call Center Agents (WTA)" Change stage From Prospect to
                        Sales-Processing and status is new then required field make mandatory  
     * @param               
     * @date            14 Mar 2023   
     ********************************************************************************************************/

public class SalesProcessingStageDisposition {
    public static void checkLeadStage(List<Lead> newLeads, Map<Id, Lead> oldLeads) {
        // Get the current user's role
        String userRole = [SELECT UserRole.Name FROM User WHERE Id = :UserInfo.getUserId()].UserRole.Name;
        // For loop through the list of new leads
        for (Lead newLead : newLeads) {
            // Get the old lead record
            Lead oldLead = oldLeads.get(newLead.Id);
            // Check if the lead stage has changed
            if (oldLead.Status != newLead.Status) {
                // When lead stage change from Prospect to sales-Processing only perform validation 
                if(oldLead.Status=='Prospect'){
                     if(newLead.Status == 'Sales Processing' && newLead.Status__c=='New' ){
                // Perform actions based on the user's role
                if (userRole == 'Call Center Agents (WTA)') {
                    if(newLead.Country_of_Study__c == null || newLead.Admission_Status__c == null || newLead.University_Name__c == null || newLead.Institute_Name__c == null || newLead.Course_Id__c == null || newLead.Course_Stream__c == null || newLead.Course_Level__c == null ){
                       newLead.addError('Please check Mandatory Fields in Admission and cource details section');
                        return;
                    } 
                    // check Analytics_Score_Category data
                     if(newLead.Analytics_Score_Category__c != null){
                        if(newLead.Analytics_Test_Score__c == null){
                           newLead.Analytics_Test_Score__c.addError('Analytics Test Score is Mandatory Fields');
                            return;
                        }   
                    }
                    if(newLead.Language_Score_Category__c != null){
                        if(newLead.Language_Test_Score__c == null){
                         newLead.Language_Test_Score__c.addError('Language Test Score is Mandatory Fields'); 
                            return;
                        } 
                    }
                   
                 /*   if(newLead.Country_of_Study__c == null){
                       newLead.Country_of_Study__c.addError('Country of Study is Mandatory Fields');
                    }
                    if(newLead.Admission_Status__c == null){
                       newLead.Admission_Status__c.addError('Admission Status is Mandatory Fields');
                    }
                    if(newLead.University_Name__c == null){
                       newLead.University_Name__c.addError('Country of Study is Mandatory Fields');
                    }
                    if(newLead.Institute_Name__c == null){
                       newLead.Institute_Name__c.addError('Institute Name is Mandatory Fields');
                    }
                    if(newLead.Course_Id__c == null){
                       newLead.Course_Id__c.addError('Course Id is Mandatory Fields');
                    }
                    if(newLead.Course_Stream__c == null){
                       newLead.Course_Stream__c.addError('Course Stream is Mandatory Fields');
                    }
                    if(newLead.Course_Level__c == null){
                       newLead.Course_Level__c.addError('Course Level is Mandatory Fields');
                    }
                   if(newLead.Analytics_Score_Category__c != null){
                        if(newLead.Analytics_Test_Score__c == null){
                           newLead.Analytics_Test_Score__c.addError('Analytics Test Score is Mandatory Fields');
                        }   
                    }
                    if(newLead.Language_Score_Category__c != null){
                        if(newLead.Language_Test_Score__c == null){
                         newLead.Language_Test_Score__c.addError('Language Test Score is Mandatory Fields');    
                        } 
                    }
                 */
                    
                    if(newLead.Loan_Required_A_B__c <= 0){
                        newLead.addError('Please mention required loan amount');
                        return;
                   }
                     if(newLead.Co_Applicant_Name__c== null || newLead.Co_Applicant_Mobile__c== null || newLead.Co_Applicant_Email__c== null){
                         newLead.addError('Please mention financial Co-Applicant details');
                    }
                 }
               }
             }
          }
       }
    }
}