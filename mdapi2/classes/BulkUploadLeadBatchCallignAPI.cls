/*
*
*Name  :  Upload CSV for Partner Account, Record Inserted In Batch
*Author:  Thinqloud Solutions (Chandrakant More)
*Date  :  Feb 21, 2023
*Purpose : This batch class get called in BulkUploadLeadBatch (Batch)
*
*/
public class BulkUploadLeadBatchCallignAPI implements Database.Batchable<sObject>,Database.Stateful  {
    public List<Lead> requestIdListBathtwo;
    public List<Lead> InsertedLeadSet ;
    public BulkUploadLeadBatchCallignAPI(List<Lead> requestIdListBathtwo ){
        this.requestIdListBathtwo = requestIdListBathtwo;
    } 
    public Iterable<SObject> start(Database.BatchableContext BC){
        return requestIdListBathtwo;
    }
    public void execute(Database.BatchableContext BC, List<Lead> reqIds){
        if(!reqIds.IsEmpty() && reqIds.size() > 0 ){
            InsertedLeadSet = reqIds;
        }
    }
    public void finish(Database.BatchableContext BC){
        if(!InsertedLeadSet.IsEmpty() && InsertedLeadSet.size() > 0){
            // Database.executeBatch(new BulkUploadLeadBatch(InsertedLeadSet),200);
            // LeadTriggerHandler.campaignAssignmentOnLead(InsertedLeadSet);
            //LeadTriggerHandler.childCampaignAssignmentOnLead(InsertedLeadSet, false);
        }
    }   
}