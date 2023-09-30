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
public class BatchForDeleteOldLogDetails implements Database.Batchable<sObject> {
    private List<Error_log__c> errLogObject;
    private List<Error_log__c> finalList = new List<Error_log__c>();
    
    /**
     * Author: Sohail Solapure
     * Description: Constructor for the BatchForDeleteOldLogDetails class.
     * 
     * This constructor initializes the BatchForDeleteOldLogDetails class with the required parameters for
     * deleting old error log details from the object.
     * 
     * @param errLogRequest A list of Error_log__c records representing the old error log details to be deleted.
     * @description This constructor initializes the BatchForDeleteOldLogDetails class with the provided list of errorlogs           
     */
    public BatchForDeleteOldLogDetails(List<Error_log__c> errLogRequest){
        this.errLogObject = errLogRequest;
    }
    
   /**
     * Author: Sohail Solapure
     * Description: The start method of the BatchForDeleteOldLogDetails class.
     * 
     * This method is called at the beginning of the batch job and returns the initial set of sObjects
     * representing old error log details to be deleted.
     * 
     * @param bc The batchable context provided by Salesforce.
     * @return A list of sObjects to be processed by the batch job's execute method.
     * @description This method serves as the starting point for the batch job's execution.
     */
    public List<sObject> start(Database.BatchableContext bc){
         finalList = errLogObject;
         return finalList;
    }
   
    /**
     * Author: Sohail Solapure
     * Description: The execute method of the BatchForDeleteOldLogDetails class.
     * 
     * This method is responsible for processing a batch of old error log details and deleting them
     * from the corresponding object.
     * 
     * @param bc The batchable context provided by Salesforce.
     * @param errLogList A list of Error_log__c records to be processed by the batch job.
     * @description This method executes the core processing logic of the batch job. 
     */
    public void execute(Database.BatchableContext bc, List<Error_log__c> errLogList) {
        //Process on each records 
        try {
            if(null != errLogList && errLogList.size() > 0){
                delete errLogList;
            }
        } catch(Exception e) {
            e.getCause();
        }      
    }   
     
    /**
     * Author: Sohail Solapure
     * Description: The finish method of the BatchForDeleteOldLogDetails class.
     * 
     * This method is called after all batches are processed, allowing for any finalization logic.
     * 
     * @param bc The batchable context provided by Salesforce.
     * @description This method is executed once all batches of old error log details have been processed.
     *              It provides an opportunity to perform any necessary finalization or cleanup tasks before
     *              the batch job completes. Any cleanup, notification, or summary actions related to the
     *              batch job can be implemented here.
     */
    public void finish(Database.BatchableContext bc) {
    }  
}