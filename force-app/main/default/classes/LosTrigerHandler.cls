/*
* 
* @author          Dhanaji Patil
* @description     This Class is used to execute batch for calling LOS API.
* @Request         apiName and Opportunity object
* @return          No return any value 
* @date            09/03/2023    
* 
*/

global with sharing class LosTrigerHandler { 
    
    /******************************* calling to fresh LOS API ***********************************/
     global static void LosApiCallingHandler(String apiName, Opportunity opp){
         
         
         if(null != apiName && String.isEmpty(apiName)) {
            system.debug('******** Before Calling LOS API :: API Name :: '+apiName);
            // Database.executeBatch(new BatchForLOSApiCalling(apiName,opp)); 
            system.debug('****** After calling LOS API **************');
         }
		
     }
}