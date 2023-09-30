/**
 * Author: Aasim Shaikh
 * Description: This Batch class is used to call the Dms API.
 * 
 * This batch job takes a list of Opportunity records as input and calls the Dms API for each Opportunity.
 * It is designed to execute callouts using the AllowsCallouts interface.
 * 
 * @param sobject A list of Opportunity records to be processed by the batch job.
 * @return This batch class does not return any value.
 * @date 14/04/2023
 * @description This batch class orchestrates the call to the Dms API for each provided Opportunity. 
 */
public class BatchForDmsApiCalling implements Database.Batchable<sobject>, Database.AllowsCallouts {
    private List<Opportunity> oppObj;
    Map<Document_Checklist__c, List<ContentVersion>> documentsList;
    
    /**
     * Author: Sohail Solapure
     * Description: Constructor for the BatchForDmsApiCalling class.
     * 
     * This constructor initializes the BatchForDmsApiCalling class with the required parameters for
     * calling the Dms API.
     * 
     * @param oppList A list of Opportunity records containing deal details to be processed by the batch job.
     * @param docList A map of Document_Checklist__c records to their corresponding lists of ContentVersion records.
     * @description This constructor initializes the BatchForDmsApiCalling class with the provided lists of Opportunity
     */
    public BatchForDmsApiCalling(List<Opportunity> oppList, Map<Document_Checklist__c, List<ContentVersion>> docList) {      
        this.oppObj = oppList;
        this.documentsList = docList;
    }
    
    /**
     * Author: Sohail Solapure
     * Description: The start method of the BatchForDmsApiCalling class.
     * 
     * This method is called at the beginning of the batch job and returns the initial set of Opportunity records
     * to be used for calling the Dms API.
     * 
     * @param bc The batchable context provided by Salesforce.
     * @return A list of Opportunity records to be processed by the batch job's execute method.
     * @description This method serves as the starting point for the batch job's execution. 
     */
    public List<Opportunity> start(Database.BatchableContext bc) {        
        return this.oppObj;
    }
    
    /**
     * Author: Sohail Solapure
     * Description: The execute method of the BatchForDmsApiCalling class.
     * 
     * This method is responsible for processing a batch of Opportunity records and making calls to the Dms API.
     * 
     * @param bc The batchable context provided by Salesforce.
     * @param oppObj A list of Opportunity records to be processed by the batch job.
     * @description This method executes the core processing logic of the batch job. 
     */
    public void execute(Database.BatchableContext bc, List<Opportunity> oppObj) {
        Opportunity deal = this.oppObj[0];
        
        if(deal != null && deal.Folder_Index__c != null && documentsList.size() > 0) {            
            
            Integer interval = 10; 
            for(Document_Checklist__c documentChecklistRecord : documentsList.keySet()) {
                List<ContentVersion> docList = documentsList.get(documentChecklistRecord);
                for(ContentVersion doc : docList){
                    DateTime now  = DateTime.now();
                    interval = interval + 5;
                    DateTime nextRunTime = now.addSeconds(interval);
                    String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
                        nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' +  
                        nextRunTime.month() + ' ? ' + nextRunTime.year();
                        
                    Map<String,Object> requestBody = new Map<String,Object>();
                    requestBody.put(LOSConstants.DMS_FOLDER_INDEX, deal.Folder_Index__c);
                    requestBody.put(LOSConstants.DOCUMENT_NAME, documentChecklistRecord.DMS_Name__c);
                    requestBody.put(LOSConstants.COMMENT, doc.Title != null ? doc.Title.contains('.') ? doc.Title.substring(0, doc.Title.lastIndexOf('.')) :doc.Title : '');
                    requestBody.put(LOSConstants.CREATED_BY, doc.FileType);
                    requestBody.put(LOSConstants.FILE_NAME, doc.Download_URL__c);
                    
                   SchedularForDmsApiCalling scLos = new SchedularForDmsApiCalling(requestBody, doc, deal, documentChecklistRecord);
                   System.schedule(LOSConstants.DMS_SCHEDULE_NAME + documentChecklistRecord.DMS_Name__c + System.now() + now.millisecond() , cronString, scLos); 
                }
            }
        }
    }
    
    /**
     * Author: Sohail Solapure
     * Description: The finish method of the BatchForDmsApiCalling class.
     * 
     * This method is called after all batches are processed, allowing for any finalization logic.
     * 
     * @param bc The batchable context provided by Salesforce.
     * @description This method is executed once all batches of Opportunity records have been processed.
     */
    public void finish(Database.BatchableContext bc) { 
    }  
}