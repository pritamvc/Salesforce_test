/**
 * Author: Dhanaji Patil
 * Description: This Batch class is used to delete old tracker details from the object.
 * 
 * This batch job takes a list of tracker details as input and deletes them from the corresponding object.
 * 
 * @param sObject A list of tracker details to be deleted from the object.
 * @return This batch class does not return any value.
 * @date 06/03/2023
 * @description This batch class orchestrates the deletion of old tracker details from the specified object.
 */
public class BatchForDeleteOldTrackerDetails implements Database.Batchable<sObject> {    
    private List<Tracker__c> trackerObject;
    private List<Tracker__c> finalList = new List<Tracker__c>();
    
    /**
    * Author: Sohail Solapure
    * Description: Constructor for the BatchForDeleteOldTrackerDetails class.
    * 
    * This constructor initializes the BatchForDeleteOldTrackerDetails class with the required parameters for
    * deleting old tracker details from the object.
    * 
    * @param trackerRequest A list of Tracker__c records representing the old tracker details to be deleted.
    * @description This constructor initializes the BatchForDeleteOldTrackerDetails class with the provided list of trackers
    */
    public BatchForDeleteOldTrackerDetails(List<Tracker__c> trackerRequest){
        this.trackerObject = trackerRequest;
    }
    
   /**
     * Author: Sohail Solapure
     * Description: The start method of the BatchForDeleteOldTrackerDetails class.
     * 
     * This method is called at the beginning of the batch job and returns the initial set of sObjects
     * representing old tracker details to be deleted.
     * 
     * @param bc The batchable context provided by Salesforce.
     * @return A list of sObjects to be processed by the batch job's execute method.
     * @description This method serves as the starting point for the batch job's execution. 
     */
    public List<sObject> start(Database.BatchableContext bc){
        finalList = trackerObject;
        return finalList;
    }
   
    /**
 * Author: Sohail Solapure
 * Description: The execute method of the BatchForDeleteOldTrackerDetails class.
 * 
 * This method is responsible for processing a batch of old tracker details and deleting them
 * from the corresponding object.
 * 
 * @param bc The batchable context provided by Salesforce.
 * @param trackerList A list of Tracker__c records to be processed by the batch job.
 * @description This method executes the core processing logic of the batch job. .
 */
    public void execute(Database.BatchableContext bc, List<Tracker__c> trackerList) { 
        //Process on each records 
        try {
            if(null != trackerList && trackerList.size() > 0){
                delete trackerList;
            }
        } catch(Exception e) {
            e.getCause();
        }       
    }   
     
    /**
     * Author: Sohail Solapure
     * Description: The finish method of the BatchForDeleteOldTrackerDetails class.
     * 
     * This method is called after all batches are processed, allowing for any finalization logic.
     * 
     * @param bc The batchable context provided by Salesforce.
     * @description This method is executed once all batches of old tracker details have been processed
     */
    public void finish(Database.BatchableContext bc) {
    }
}