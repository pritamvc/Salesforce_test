/*********************************************************************************************
* @author          Thinqloud Solutions (Chandrakant More)
* @description     this is trigger on Source Object
* @date            20/02/2023    
* @testClass: 
**********************************************************************************************/
trigger SourceTrigger on Source__c (before insert,before Update,after insert,after Update) {
    List<Source__c> newSourceList = new List<Source__c>();
    List<Source__c> lstExistingSource = new List<Source__c>();
    lstExistingSource = [Select Id, Source_Id__c from Source__c  where Source_Id__c  != null order by Source_Id__c DESC limit 1];
    Integer sourceIdNumber = 0;
    if(lstExistingSource.size() > 0 && lstExistingSource[0].Source_Id__c !=  null){
        sourceIdNumber = Integer.valueof(lstExistingSource[0].Source_Id__c) + 1;
    }else{
        sourceIdNumber = 1;
    }
    if(Trigger.IsBefore && Trigger.IsInsert){
        for(Source__c objSource : Trigger.new){           
            objSource.Source_Id__c = sourceIdNumber;
            sourceIdNumber++;
            if(objSource.Partner_Name__c != null){
                newSourceList.add(objSource);
            }
        }
    }
    if(Trigger.IsBefore && Trigger.IsUpdate){
        for(Source__c objSource : Trigger.new){
            if((Trigger.oldMap.get(objSource.Id).Partner_Name__c != objSource.Partner_Name__c) && objSource.Partner_Name__c != null){
                newSourceList.add(objSource);
            }
        }
    }
    if(!newSourceList.isEmpty() && newSourceList.size() >0 ){
        SourceTriggerHandler.singleSourceOnAccount(newSourceList);
    }
    
    
    List<Source__c> sourceListForUpdatePartnerCode = new List<Source__c>();
    if(trigger.isAfter && (trigger.isUpdate)){
    //if(trigger.isUpdate){
        for(Source__c objSource : Trigger.new){
            if(((string.isBlank(Trigger.OldMap.get(objSource.id).Sub_Source_Type__c)) || (Trigger.oldMap.get(objSource.Id).Sub_Source_Type__c != objSource.Sub_Source_Type__c)) && objSource.Sub_Source_Type__c != null){
                sourceListForUpdatePartnerCode.add(objSource);
            }
        }
    }
    
    if(!sourceListForUpdatePartnerCode.isEmpty() && sourceListForUpdatePartnerCode.size() >0 ){
        SourceTriggerHandler.updateSourceAccountDetailsAsPerConfigration(sourceListForUpdatePartnerCode);
    }

}