public class DealLeadLoanRequirements {

        /*
        *
        *Name  :  LeadLoanRequirements
        *Author:  Sohail Solapure
        *Date  :  20/0/2023
        *Purpose : Loan Application form-Loan section get data, insert and update data.
        *
        */

        /********************************************************************************************************************************************
        * @author           Sohail Solapure
        * @description      Getting data from Lead on Loan requirement section
        * @Arguments        leadGetId 
        * @param            leadGetId used for pass Lead Id
        * @return           Wrapper
        * @date             20/06/2023     
        ********************************************************************************************************************************************/  
        @AuraEnabled
        public static WrapperClassApplicationForm getWrapperClassApplicationForm(String leadGetId) {            
        
            Opportunity getLeadLoanRecord;
            try{
                getLeadLoanRecord = [Select Id, Language_Test_Score__c,Tuition_Fees__c, Living_Hostel_Food_Expenses__c,Traveling_Expenses__c,Other_Costs__c,Own_Source__c,
                Scholarship__c,Others_Fund__c,Total_Costs__c,Total_Funds__c,Repayment_Option__c,Loan_Tenure_Months__c,
                Loan_Required_A_B__c From Opportunity Where Id =: leadGetId];             
            }
            catch (Exception e) {
                
            }             
            
            //Wrapper Class
            WrapperClassApplicationForm wc = new WrapperClassApplicationForm();
        
            if(getLeadLoanRecord != null){
                wc.leadLoanRecords = getLeadLoanRecord; 
            }                        
            return wc;   
        }          
      
        /********************************************************************************************************************************************
        * @author           Sohail Solapure
        * @description      For saving or updating the Loan details on Lead.
        * @Arguments        leadGetId
        * @param            leadGetId used for pass Lead Id
        * @return           updateParentLeadLoanRequirment Lead Id
        * @date             20/06/2023     
        ********************************************************************************************************************************************/
        @AuraEnabled
        public static String saveUpdateLoanOnLead(String wrapperClassInstance) {
          
            WrapperClassApplicationForm wrapperClassApplicationFormInstance = (WrapperClassApplicationForm)json.deserialize(wrapperClassInstance,WrapperClassApplicationForm.Class);      
            //For Loan update on lEad
            Opportunity updateParentLeadLoanRequirment = (Opportunity)json.deserialize(wrapperClassApplicationFormInstance.loanSectionLeadRec,Opportunity.Class);
            if(updateParentLeadLoanRequirment != null){                   
                update updateParentLeadLoanRequirment;
            } 
            return updateParentLeadLoanRequirment.Id;
        }
        
         /********************************************************************************************************************************************
        * @author           Sohail Solapure
        * @description      Wrapper class
        * @Arguments        NA
        * @param            NA
        * @return           NA
        * @date             20/06/2023     
        ********************************************************************************************************************************************/  
        public class WrapperClassApplicationForm{
        /********************************************************************************************************************************************
        * @author           Sohail Solapure
        * @description      leadLoanRecords
        * @Arguments        NA
        * @param            NA
        * @return           NA
        * @date             20/06/2023     
        ********************************************************************************************************************************************/  
            @AuraEnabled
            public Opportunity leadLoanRecords{get;set;} 
        /********************************************************************************************************************************************
        * @author           Sohail Solapure
        * @description      loanSectionLeadRec
        * @Arguments        NA
        * @param            NA
        * @return           NA
        * @date             20/06/2023     
        ********************************************************************************************************************************************/  
            @AuraEnabled
            public String loanSectionLeadRec{get;set;}          
        }      
    }