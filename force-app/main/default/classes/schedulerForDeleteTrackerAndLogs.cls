/*
* 
* @author          Aasim shaikh, Dhanaji Patil
* @description     This scheduler is used to Delete the Tracker And Logs.
* @Request         null
* @return          No return any value 
* @date            08/03/2023    
* @param
*/

global class SchedulerForDeleteTrackerAndLogs implements Schedulable {
    /*
    * @author          Sohail Solapure
    * @description     execute method
    * @return          No return any value 
    * @param    
    */
   global void execute(SchedulableContext sc) {       
       //Collect tracker details
       String trackQuery = System.Label.Tracker_Delete_Query;
       List<Tracker__c> trackMaster = Database.query(trackQuery);
       
       if(Test.isRunningTest()){
           trackMaster = [Select id from Tracker__c limit 1];
       }
       if(null != trackMaster && trackMaster.size() > 0) {
           Database.executeBatch(new BatchForDeleteOldTrackerDetails(trackMaster),1);  
       }
       
       //Collect Error log details 
       String errLogkQuery = System.Label.Errorlog_Delete_Query;
       List<Error_log__c> errLogkMaster = Database.query(errLogkQuery);
       
       if(Test.isRunningTest()){
           errLogkMaster = [Select id from Error_log__c limit 1];
       }
       if(null != errLogkMaster && errLogkMaster.size() > 0) {
           Database.executeBatch(new BatchForDeleteOldLogDetails(errLogkMaster),1);
       }      
   }
}