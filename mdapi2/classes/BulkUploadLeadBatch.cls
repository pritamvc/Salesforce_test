/*
* @Author:  Thinqloud Solutions (Chandrakant More)
* @Name  :  BulkUploadLeadBatch CSV for Partner Account, Record Inserted In Batch
* @Date  :  Feb 21, 2023
* @Purpose : This batch class get called in BulkUploadLeadWithAccPartnerController
****************************************/
global class BulkUploadLeadBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {
    string accountId;
    string csvFileTittle;
    public List<Lead> requestIdList;
    string headerFromCSV;
    public List<Lead> successLineItems = new List<Lead>();
    public List<Lead> failedLineItems = new List<Lead>();
    /**
* @description :BulkUploadLeadBatch Constructor - Initializes the batch job with a specific list of Lead.
* @param requestIdList The ID of the lead to be processed by the batch job.
* @param failedLineItems The list of the lead to be processed by the batch job.
* @param failedLineItems The list of the lead to be processed by the batch job.
* @param csvFileTittle The list of the lead to be processed by the batch job.
*/
    public BulkUploadLeadBatch(List<Lead> requestIdList,List<Lead> failedLineItems,string accountId,string csvFileTittle,string headerFromCSV){
        this.requestIdList = requestIdList;
        this.accountId = accountId;
        this.csvFileTittle =csvFileTittle;
        this.headerFromCSV =headerFromCSV;
        this.failedLineItems =failedLineItems;
    }
    /**
* @description :start method to get List of Lead and procees to Upload.
* 
* @param requestIdList The ID of the lead to be processed by the batch job.
* @return it return iterable Sobject.
*/
    public Iterable<SObject> start(Database.BatchableContext leadlistBatch){
        return requestIdList;
    }
    /**
* @description :execute method to willprocees record In Batch.
* 
* @param reqIds List Of Lead.
*/
    public void execute(Database.BatchableContext leadlistBatch, List<Lead> reqIds){
        try {
            if(!reqIds.IsEmpty() && reqIds.size() > 0 ){
                List<Database.SaveResult> insertResults = Database.insert(reqIds, false);
                for (Integer i = 0; i < insertResults.size(); i++) {
                    if(insertResults.get(i).isSuccess()){
                        successLineItems.add(reqIds[i]);
                    }
                    if (!insertResults.get(i).isSuccess()) {
                        lead failRecord = reqIds[i];
                        failRecord.ErrorMessage__c = insertResults.get(i).getErrors()[0].getMessage();
                        failedLineItems.add(failRecord);
                    }
                }
            }
            
        } catch(Exception e) {
            system.debug(CommonConstant.ERROR_CONSTANT + e.getMessage());
            For(Lead reqIdsRecord : reqIds ){
                reqIdsRecord.addError(CommonConstant.ERROR_CONSTANT + e.getMessage());
            }
        }
    }
    /**
* @description :finish method to Used To do furtner procees on record in Uploaded.
* 
* @param reqIds List Of Lead.
*/
    global void finish(Database.BatchableContext leadlistBatch){
        
        if(!successLineItems.IsEmpty() && successLineItems.size() > 0){
            // LeadTriggerHandler.campaignAssignmentOnLead(successLineItems);
            // LeadTriggerHandler.childCampaignAssignmentOnLead(successLineItems, false);
            LeadCampaignHandler.campaignAssignmentOnLead(successLineItems); //code By Dhanaji
        }
        if(!failedLineItems.isEmpty() && failedLineItems.size() > 0) {
            BulkUploadLeadsForPartners.setOfErrorLeads(failedLineItems,accountId,csvFileTittle,headerFromCSV);
        }
    }
}