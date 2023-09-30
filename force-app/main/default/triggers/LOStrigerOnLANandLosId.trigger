/*
* 
* @author          Dhanaji Patil
* @description     This trigger is used to execute batch(batch calling LOS API).
* @Request         Lead Id
* @return          No return any value 
* @date            02/03/2023    
* 
*/

trigger LOStrigerOnLANandLosId on Opportunity (after update) {
    
    /********** get API details **********************/
    String apiQuery = 'select Id, ApiName__c from LosApiMaster__c where Active__c = true';
    List<LosApiMaster__c> apiMaster = Database.query(apiQuery);
     
    /********************* loop on updated Opportunity to perform operations **********************/
    for(Opportunity opp : Trigger.new) { 
        if(Trigger.isUpdate) {
                if((string.isBlank(Trigger.OldMap.get(opp.id).LOS_Id__c))&& null != Opp.LOS_Id__c && !string.isEmpty(Opp.LOS_Id__c) 
                    && (string.isBlank(Trigger.OldMap.get(opp.id).Loan_Application_Number__c)) && null != Opp.Loan_Application_Number__c && !string.isEmpty(Opp.Loan_Application_Number__c)) {
                        if(null != apiMaster && apiMaster.size()>0) { 
                            for(LosApiMaster__c apiData : apiMaster){
                                if(apiData.ApiName__c != CommonConstant.WORK_ITEM_API_NAME && apiData.ApiName__c != CommonConstant.DATA_TRANSFER_API_NAME ) {
                                    //LosTrigerHandler.LosApiCallingHandler(apiData.ApiName__c,opp);
                                    system.debug('******** Before Calling LOS API :: API Name :: '+apiData.ApiName__c);
                                  //  Database.executeBatch(new BatchForLOSApiCalling(apiData.ApiName__c,opp)); 
                                    system.debug('****** After calling LOS API **************');
                                }
                            }
                         }else{system.debug(' API Master is empty');}               
                }else{system.debug(' LOS id and Application id is null or it was previously updated.');}
        }else{system.debug(' Opportunaty did not updated !!!');}
    }
}