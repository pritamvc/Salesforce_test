public class BankDetailsBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    // Member variable to store the lead ID for processing
    private String leadId;
    // * Constructor - Initializes the batch job with a specific lead ID.
    public BankDetailsBatch(String leadId) {
        this.leadId = leadId;
    }
    //* start - Provides the query locator to select relevant Bank_Details__c records.
    public Database.QueryLocator start(Database.BatchableContext bankCheckList) {
        String query = 'SELECT Id, Lead__c, Account__c, Account_Name__c, Status__c, Account_Number__c, IFSC_Code__c, Account_Holder_Name__c, Lead__r.Name FROM Bank_Details__c WHERE Lead__c = :leadId and Account_Name__c=null ';
        
        try {
            return Database.getQueryLocator(query);
        } catch (Exception ex) {
            // Handle the error and log the message
            //system.debug('Error in start method: ' + ex.getMessage());
            return null; // Return null if there's an error
        }
    }
    // * execute - Processes each batch of Bank_Details__c records and updates them.
    public void execute(Database.BatchableContext bankCheckList, List<sObject> scope) {
        List<BankUpdateWrapper> bankToUpdate = new List<BankUpdateWrapper>();

        for (sObject record : scope) {
            try {
                Bank_Details__c bankDetail = (Bank_Details__c)record;
                Opportunity opportunity ;
                try{
                opportunity= [SELECT Id FROM Opportunity WHERE Lead__c =:bankDetail.Lead__c LIMIT 1];
                }
                catch (Exception ex){
                    opportunity.id='none';
                }
                if(opportunity.id!=null){
                    //pass
                }
                else{
                     opportunity.id='none';
                }
                String pennyDropResponse = DocumentVerification.PannyDrop(bankDetail.Lead__c, bankDetail.Account__c, 'Y', bankDetail.IFSC_Code__c, bankDetail.Account_Number__c,opportunity.Id);
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
                // Log the error and continue processing
                //system.debug('Error processing record: ' + ex.getMessage());
                System.debug(LoggingLevel.WARN, 'Error updating records: '+ex.getMessage());
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
                // Handle update error
                //system.debug('Error updating records: ' + ex.getMessage());
                System.debug(LoggingLevel.WARN, 'Error updating records: '+ex.getMessage());
            }
        }
    }

    public void finish(Database.BatchableContext bankCheckList) {
        // Finish logic if needed
        System.debug(LoggingLevel.WARN, 'In Finish');
    }
    
    // Wrapper class to hold bank details and update information
    private class BankUpdateWrapper {
        Bank_Details__c bankDetail;
        String accountName;
        String bankResponse;
        
        BankUpdateWrapper(Bank_Details__c bankDetail, String accountName, String bankResponse) {
            this.bankDetail = bankDetail;
            this.accountName = accountName;
            this.bankResponse = bankResponse;
        }
        
        void updateFields() {
            if (accountName != null && bankResponse != null) {
                bankDetail.Account_Name__c = accountName;
                bankDetail.Status__c = bankResponse;
            }
        }
    }
}