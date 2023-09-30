/*********************************************************************************************
* @author          Thinqloud Solutions (Chandrakant More)
* @description     This Class called in ApplicantTrigger(Trigger),this class used to update insertion order once applicant created or updated.
* @date            27/03/2023    
* @testClass: 
**********************************************************************************************/
public class ApplicantTriggerHandler {
    /*****************************************************************************************************************
* @author          Chandrakant More
* @description     insertionOrderUpdationOnApplicant this method is used to update insertion order once applicant created or updated.
* @param           newApplicantList (List) : used to pass the list of applicant records to the method as parameter.
* @date            27/03/2023   
*****************************************************************************************************************/
    public static void insertionOrderUpdationOnApplicant(List<Co_Applicant__c> newApplicantList){
        try { 
            Set<Id> leadIdSet = new Set<Id>();
            List<Co_Applicant__c > existingApplicantList = new List<Co_Applicant__c>();
            Map<String,List<Co_Applicant__c>> applicantNonApplicantMap = new Map<String,List<Co_Applicant__c>>();
            List<Co_Applicant__c> listToUpdateInsertionOrder = new List<Co_Applicant__c>();
            
            for(Co_Applicant__c objectApplicant : newApplicantList){
                leadIdSet.add(objectApplicant.Lead__c);
            }
            
            // Get existing applicant for updation insertion order
            existingApplicantList =[SELECT Id,Name,Is_Income_Considered_Financial__c,Lead__c,Type__c,Insertion_Order__c FROM Co_Applicant__c where Lead__c In:leadIdSet AND Type__c != null order by CreatedDate ASC];
            
            //Iteration on existin applicant to put value on map based on financial and non-financial applicant
            string applicantNonApplicant;
            for(Co_Applicant__c objectApplicantExisting : existingApplicantList ){
                if(objectApplicantExisting.Type__c == System.Label.Applicant_Type){
                    applicantNonApplicant = System.Label.Applicant_Type;
                }else if(objectApplicantExisting.Type__c == System.Label.Applicant_Type_Co_Applicant && objectApplicantExisting.Is_Income_Considered_Financial__c == System.Label.Financial_True){
                    applicantNonApplicant = CommonConstant.FINANCIAL_CO_APPLICANT;
                }else{
                    applicantNonApplicant = CommonConstant.NON_FINANCIAL_CO_APPLICANT;
                }
                if(applicantNonApplicantMap.containsKey(applicantNonApplicant)) {
                    List<Co_Applicant__c> tepmLstApplicant = applicantNonApplicantMap.get(applicantNonApplicant);
                    tepmLstApplicant.add(objectApplicantExisting);
                    applicantNonApplicantMap.put(applicantNonApplicant, tepmLstApplicant);
                } else {
                    applicantNonApplicantMap.put(applicantNonApplicant, new List<Co_Applicant__c> {objectApplicantExisting});
                }
            }
            
            // Iteration on map for assigning insertion order
            for(String key : applicantNonApplicantMap.keySet()){
                
                // Checking applicant type is Applicant
                if(key==System.Label.Applicant_Type){
                    List<Co_Applicant__c> lstApplicant = applicantNonApplicantMap.get(key);
                    for(Co_Applicant__c value : lstApplicant){
                        value.Insertion_Order__c = CommonConstant.INT_VALUE_ZERO;
                        listToUpdateInsertionOrder.add(value);
                    }
                }
                
                // Checking applicant type is Financial-Applicant
                else if(key==CommonConstant.FINANCIAL_CO_APPLICANT){
                    Integer i = CommonConstant.INT_VALUE_ZERO;
                    List<Co_Applicant__c> lstApplicant = applicantNonApplicantMap.get(key);
                    for(Co_Applicant__c value : lstApplicant){
                        i++;
                        value.Insertion_Order__c = i;
                        listToUpdateInsertionOrder.add(value);
                    }
                }
                
                // Checking applicant type is Non-financial-Applicant
                else if(key==CommonConstant.NON_FINANCIAL_CO_APPLICANT){
                    Integer i;
                    if(applicantNonApplicantMap.containsKey(CommonConstant.FINANCIAL_CO_APPLICANT)){
                        if(applicantNonApplicantMap.get(CommonConstant.FINANCIAL_CO_APPLICANT).size() ==0 ){
                            i=CommonConstant.INT_VALUE_ZERO;
                        }else{
                            i = applicantNonApplicantMap.get(CommonConstant.FINANCIAL_CO_APPLICANT).size();
                        }}else{
                            i=CommonConstant.INT_VALUE_ZERO;
                        }
                    List<Co_Applicant__c> lstApplicant = applicantNonApplicantMap.get(key);
                    for(Co_Applicant__c value : lstApplicant){
                        i++;
                        value.Insertion_Order__c = i;
                        listToUpdateInsertionOrder.add(value);    
                    }
                }
            }
            
            //Update Insertion order in in system
            if(!listToUpdateInsertionOrder.IsEmpty() && listToUpdateInsertionOrder.size() > 0){
                Update listToUpdateInsertionOrder;
            }
            //aatch-Block
        }catch(Exception e) {
            for(Co_Applicant__c objectApplicant : newApplicantList) {
                objectApplicant.addError(e.getMessage());
            }        
        }
    }
  
      public static void insertionUpdationOnApplicant(List<Co_Applicant__c> newApplicantList){
        try { 
            Set<Id> leadIdSet = new Set<Id>();
            List<Co_Applicant__c > existingApplicantList = new List<Co_Applicant__c>();
            Map<String,List<Co_Applicant__c>> applicantNonApplicantMap = new Map<String,List<Co_Applicant__c>>();
            List<Co_Applicant__c> listToUpdateInsertionOrder = new List<Co_Applicant__c>();
            
            for(Co_Applicant__c objectApplicant : newApplicantList){
                leadIdSet.add(objectApplicant.Lead__c);
            }
            
            // Get existing applicant for updation insertion order
            existingApplicantList =[SELECT Id,Name,Is_Income_Considered_Financial__c,Lead__c,Type__c,Insertion_Order__c FROM Co_Applicant__c where Lead__c In:leadIdSet AND Type__c != null order by CreatedDate ASC];
            
            //Iteration on existin applicant to put value on map based on financial and non-financial applicant
            string applicantNonApplicant;
            for(Co_Applicant__c objectApplicantExisting : existingApplicantList ){
                if(objectApplicantExisting.Type__c == System.Label.Applicant_Type){
                    applicantNonApplicant = System.Label.Applicant_Type;
                }else if(objectApplicantExisting.Type__c == System.Label.Applicant_Type_Co_Applicant && objectApplicantExisting.Is_Income_Considered_Financial__c == System.Label.Financial_True){
                    applicantNonApplicant = CommonConstant.FINANCIAL_CO_APPLICANT;
                }else{
                    applicantNonApplicant = CommonConstant.NON_FINANCIAL_CO_APPLICANT;
                }
                if(applicantNonApplicantMap.containsKey(applicantNonApplicant)) {
                    List<Co_Applicant__c> tepmLstApplicant = applicantNonApplicantMap.get(applicantNonApplicant);
                    tepmLstApplicant.add(objectApplicantExisting);
                    applicantNonApplicantMap.put(applicantNonApplicant, tepmLstApplicant);
                } else {
                    applicantNonApplicantMap.put(applicantNonApplicant, new List<Co_Applicant__c> {objectApplicantExisting});
                }
            }
            
            // Iteration on map for assigning insertion order
            for(String key : applicantNonApplicantMap.keySet()){
                
                // Checking applicant type is Applicant
                if(key==System.Label.Applicant_Type){
                    List<Co_Applicant__c> lstApplicant = applicantNonApplicantMap.get(key);
                    for(Co_Applicant__c value : lstApplicant){
                        value.Insertion_Order__c = CommonConstant.INT_VALUE_ZERO;
                        listToUpdateInsertionOrder.add(value);
                    }
                }
                
                // Checking applicant type is Financial-Applicant
                else if(key==CommonConstant.FINANCIAL_CO_APPLICANT){
                    Integer i = CommonConstant.INT_VALUE_ZERO;
                    List<Co_Applicant__c> lstApplicant = applicantNonApplicantMap.get(key);
                    for(Co_Applicant__c value : lstApplicant){
                        i++;
                        value.Insertion_Order__c = i;
                        listToUpdateInsertionOrder.add(value);
                    }
                }
                
                // Checking applicant type is Non-financial-Applicant
                else if(key==CommonConstant.NON_FINANCIAL_CO_APPLICANT){
                    Integer i;
                    if(applicantNonApplicantMap.containsKey(CommonConstant.FINANCIAL_CO_APPLICANT)){
                        if(applicantNonApplicantMap.get(CommonConstant.FINANCIAL_CO_APPLICANT).size() ==0 ){
                            i=CommonConstant.INT_VALUE_ZERO;
                        }else{
                            i = applicantNonApplicantMap.get(CommonConstant.FINANCIAL_CO_APPLICANT).size();
                        }}else{
                            i=CommonConstant.INT_VALUE_ZERO;
                        }
                    List<Co_Applicant__c> lstApplicant = applicantNonApplicantMap.get(key);
                    for(Co_Applicant__c value : lstApplicant){
                        i++;
                        value.Insertion_Order__c = i;
                        listToUpdateInsertionOrder.add(value);    
                    }
                }
            }
            
            //Update Insertion order in in system
            if(!listToUpdateInsertionOrder.IsEmpty() && listToUpdateInsertionOrder.size() > 0){
                Update listToUpdateInsertionOrder;
            }
            //aatch-Block
        }catch(Exception e) {
            for(Co_Applicant__c objectApplicant : newApplicantList) {
                objectApplicant.addError(e.getMessage());
            }        
        }
    }
  
    
    /********************************************************************************************************
* @author          Rohit Pardeshi
* @description     updateNamingOrder this method is used to update Naming order once applicant created or updated.
* @param           newApplicantList (List) : used to pass the list of applicant records to the method as parameter.
* @date            30/05/2023   
********************************************************************************************************/
    public static void updateNamingOrder(List<Co_Applicant__c> newApplicantList){
        // try-Block
        
        Set<Id> leadIdSet = new Set<Id>();
        List<Co_Applicant__c > existingApplicantList = new List<Co_Applicant__c>();
        Map<String,List<Co_Applicant__c>> applicantNonApplicantMap = new Map<String,List<Co_Applicant__c>>();
        List<Co_Applicant__c> listToUpdateInsertionOrder = new List<Co_Applicant__c>();
        
        for(Co_Applicant__c objectApplicant : newApplicantList){
            leadIdSet.add(objectApplicant.Lead__c);
        }
        
        // Get existing applicant for updation insertion order
        existingApplicantList =[SELECT Id,Name,Lead__c,Type__c,Naming_Order__c FROM Co_Applicant__c 
                                WHERE Lead__c In:leadIdSet AND Type__c != null AND Type__c != 'Applicant' order by CreatedDate ASC];
        
        //Iteration on existin applicant to put value on map based on financial and non-financial applicant
        string applicantNonApplicant;
        for(Co_Applicant__c objectApplicantExisting : existingApplicantList ){
            if(objectApplicantExisting.Type__c == System.Label.Applicant_Type_Co_Applicant){
                applicantNonApplicant = System.Label.Applicant_Type_Co_Applicant;
            }else if(objectApplicantExisting.Type__c == System.Label.Applicant_Type_Guarantor){
                applicantNonApplicant = System.Label.Applicant_Type_Guarantor;
            }
            if(applicantNonApplicantMap.containsKey(applicantNonApplicant)) {
                List<Co_Applicant__c> tepmLstApplicant = applicantNonApplicantMap.get(applicantNonApplicant);
                tepmLstApplicant.add(objectApplicantExisting);
                applicantNonApplicantMap.put(applicantNonApplicant, tepmLstApplicant);
            } else {
                applicantNonApplicantMap.put(applicantNonApplicant, new List<Co_Applicant__c> {objectApplicantExisting});
            }
        }
        
        
        // Iteration on map for assigning insertion order
        for(String key : applicantNonApplicantMap.keySet()){
            
            if(key==System.Label.Applicant_Type_Co_Applicant){
                Integer i = CommonConstant.INT_VALUE_ZERO; //0
                List<Co_Applicant__c> lstApplicant = applicantNonApplicantMap.get(key);
                for(Co_Applicant__c value : lstApplicant){
                    i++;
                    value.Naming_Order__c = i;
                    listToUpdateInsertionOrder.add(value);
                }
            }else  if(key==System.Label.Applicant_Type_Guarantor){
                Integer i = CommonConstant.INT_VALUE_ZERO; //0
                List<Co_Applicant__c> lstApplicant = applicantNonApplicantMap.get(key);
                for(Co_Applicant__c value : lstApplicant){
                    i++;
                    value.Naming_Order__c = i;
                    listToUpdateInsertionOrder.add(value);
                }
            }
            //Update Insertion order in in system
            if(!listToUpdateInsertionOrder.IsEmpty() && listToUpdateInsertionOrder.size() > 0){
                Update listToUpdateInsertionOrder;
            }  
        } 
    } 
}