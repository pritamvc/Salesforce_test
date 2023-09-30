/**
* @description :The BatchPennyDropAPI class is an Apex batchable class in Salesforce that processes 
* Bank_Details__c records associated with a specific lead or deal. It invokes an external service 
* DocumentVerification.PannyDrop to update account name and status based on the response.
* @Author:Harshvardhan Pol
* 
*/
public class BatchPennyDropAPI implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    // Member variable to store the lead ID for processing
    private String leadId;
    /** 
/**
 * @description :BatchPennyDropAPI Constructor - Initializes the batch job with a specific lead ID.
 * 
 * @param leadId The ID of the lead to be processed by the batch job.
 */
    public BatchPennyDropAPI(String leadId) {
        this.leadId = leadId;
    }
    /**
 * @description :Provides the query locator to select relevant Bank_Details__c records.
 *
 * @param bankCheckList The batchable context for the batch job.
 * @return A query locator for selecting records.
 */
    public Database.QueryLocator start(Database.BatchableContext bankCheckList) {
        String query = 'SELECT Id, Lead__c, Account__c,Deal__c, Account_Name__c, Status__c, Account_Number__c, IFSC_Code__c, Account_Holder_Name__c, Lead__r.Name FROM Bank_Details__c WHERE (Lead__c =:leadId or Deal__c=:leadId) and Account_Name__c=null ';
        
        try {
            //System.debug('Run qury ');
            return Database.getQueryLocator(query);
        } catch (Exception ex) {
            // Handle the error and log the message
            ////System.debug('Error in start method: ' + ex.getMessage());
            return null; // Return null if there's an error
        }
    }
    /**
 * @description :Processes each batch of Bank_Details__c records and updates them.
 *
 * @param bankCheckList The batchable context for the batch job.
 * @param scope The list of Bank_Details__c records to be processed in this batch.
 */
    public void execute(Database.BatchableContext bankCheckList, List<sObject> scope) {
        List<BankUpdateWrapper> bankToUpdate = new List<BankUpdateWrapper>();
        
        for (sObject record : scope) {
            try {
                Bank_Details__c bankDetail = (Bank_Details__c)record;

                string concent='Y';
                String pennyDropResponse = DocumentVerification.PannyDrop(bankDetail.Lead__c, bankDetail.Account__c, concent, bankDetail.IFSC_Code__c, bankDetail.Account_Number__c,bankDetail.Deal__c);
                Map<String, Object> parsedResponse = (Map<String, Object>)JSON.deserializeUntyped(pennyDropResponse);
                Map<String, Object> dataResponse = (Map<String, Object>)parsedResponse.get('dataResponse');
                Map<String, Object> result = (Map<String, Object>)dataResponse.get('result');
                
                if (result != null) {
                    String accountName = (String)result.get('accountName');
                    String bankResponse = (String)result.get('bankResponse');
                    bankToUpdate.add(new BankUpdateWrapper(bankDetail, accountName, bankResponse));
                } else {
                    bankToUpdate.add(new BankUpdateWrapper(bankDetail, null, null));
                }
                
                
            } catch (Exception ex) {
                for (sObject errorRecord : scope) {
                    errorRecord.addError(ex.getMessage());
                }
                
            }
        }
        
        // Update records in bulk
        List<Bank_Details__c> recordsToUpdate = new List<Bank_Details__c>();
        for (BankUpdateWrapper wrapper : bankToUpdate) {
            wrapper.updateFields();
            recordsToUpdate.add(wrapper.bankDetail);
        }
        
        if (!recordsToUpdate.isEmpty()) {
            try {
                update recordsToUpdate;
            } catch (Exception ex) {
                for (Integer i = 0; i < ex.getNumDml(); i++) {
                    recordsToUpdate[ex.getDmlIndex(i)].addError('Update failed: ' + ex.getDmlMessage(i));
                }
            }
        }
    }
/**
 * @description :This method is called after all batches have been processed.
 *
 * @param bankCheckList The batchable context for the batch job.
 */
    public void finish(Database.BatchableContext bankCheckList) {
        String objectLabel = Id.valueOf(leadId).getSObjectType().getDescribe().getLabel();
        if(objectLabel == 'Deal'){
            List<Bank_Details__c> bankDetailList = [SELECT Id, Lead__c, Account__c,Deal__c, Account_Name__c FROM Bank_Details__c WHERE  Deal__c=: leadId AND Account_Name__c=null];
            if(bankDetailList.size() == 0){
                Opportunity objectOpportunity = new Opportunity();
                objectOpportunity.Id =leadId ;
                objectOpportunity.Penny_Drop_Sync__c = true;
                update objectOpportunity;
            }
        }
    }
    
    /** *
    *@description BankUpdateWrapper Wrapper class to hold bank details and update information
    */
    @testvisible
    public class BankUpdateWrapper {
        Bank_Details__c bankDetail;
        String accountName;
        String bankResponse;
        @TestVisible
        BankUpdateWrapper(Bank_Details__c bankDetail, String accountName, String bankResponse) {
            this.bankDetail = bankDetail;
            this.accountName = accountName;
            this.bankResponse = bankResponse;
        }
        @TestVisible
        void updateFields() {
            if (accountName != null && bankResponse != null) {
                bankDetail.Account_Name__c = accountName;
                bankDetail.Status__c = bankResponse;
            }
        }
    }
}