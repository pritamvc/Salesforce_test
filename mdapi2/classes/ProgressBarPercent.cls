global with sharing class ProgressBarPercent {
	   @AuraEnabled
      public static Decimal updateLeadLoanPercentage(Id leadId, Decimal percentage) {
        System.debug('leadid=='+leadId);
        System.debug('percentage=='+percentage);
        Decimal perc = 0;
        Lead myLead = [SELECT Loan_percent__c FROM Lead WHERE Id = :leadId];
     if (myLead != null) {
        System.debug('beforre weight'+myLead.Loan_percent__c);
        myLead.Loan_percent__c = percentage;
        System.debug('updataed weight'+myLead.Loan_percent__c);
        perc = myLead.Loan_percent__c;
        update myLead;
        return perc ;
     } else {
        return perc ;
     }
}
    	 @AuraEnabled
     public static Decimal getLeadLoanPercentage(Id leadId) {
        Lead myLead = [SELECT Loan_percent__c FROM Lead WHERE Id = :leadId];
        if (myLead != null) {
            System.debug('lead percentsge'+myLead.Loan_percent__c);
            return myLead.Loan_percent__c;
        }
        return null;
    }
    	   @AuraEnabled
           public static Decimal updateCoursePercentage(Id leadId, Decimal percentage) {
             System.debug('leadid=='+leadId);
             System.debug('percentage=='+percentage);
             Decimal perc = 0;
             Lead myLead = [SELECT Course_Percent__c FROM Lead WHERE Id = :leadId];
          if (myLead != null) {
             System.debug('beforre weight'+myLead.Course_Percent__c);
             myLead.Course_Percent__c = percentage;
             System.debug('updataed weight'+myLead.Course_Percent__c);
             perc = myLead.Course_Percent__c;
             update myLead;
            return perc ;
         } else {
                 return perc ;  
         }
      }
     @AuraEnabled
     public static Decimal getLeadCoursePercentage(Id leadId) {
        Lead myLead = [SELECT Course_Percent__c FROM Lead WHERE Id = :leadId];
        if (myLead != null) {
            System.debug('lead percentsge'+myLead.Course_Percent__c);
            return myLead.Course_Percent__c;
        }
        return null;
    }
    @AuraEnabled
    public static void updateTermsAndConditionsCheck(String leadId, Boolean isChecked) {
        Lead leadRecord = [SELECT Id FROM Lead WHERE Id = :leadId];
        leadRecord.Terms_and_Conditions_Check__c = isChecked;
        update leadRecord;
    }
    @AuraEnabled
    public static Boolean getTermsAndConditionsCheck(String leadId) {
        Lead leadRecord = [SELECT Terms_and_Conditions_Check__c FROM Lead WHERE Id = :leadId];
        return leadRecord.Terms_and_Conditions_Check__c;
    }
}