public with sharing class BulkUploadLeadController {
    @AuraEnabled
    public static list<Lead> csvFileRead(Id contentDocumentId, Id campaignId){
        //public static list<Lead> csvFileRead(Id contentDocumentId){
        system.debug('campaignId from js ==============>   '+campaignId);
        list<Lead> LeadInsertList = new list<Lead>();
        if(contentDocumentId != null) {
            
            // Fetch File Data based on the basic of document id 
            ContentVersion contentVersionObj = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:contentDocumentId];
            // split the file data
            list<String> csvRecordsList = contentVersionObj.VersionData.toString().split('\n');
            
            for(Integer i = 1; i < csvRecordsList.size(); i++){
                Lead leadObj = new Lead();
                list<String> csvRowData = csvRecordsList[i].split(',');
                System.debug('csvRowData====> '+csvRowData);
                leadObj.FirstName = csvRowData[0]; // accName
                leadObj.LastName = csvRowData[1];
                leadObj.Email = csvRowData[2];
                leadObj.MobilePhone = csvRowData[3];
                leadObj.LeadSource = csvRowData[4];
                leadObj.Date_of_Birth__c = Date.valueof(csvRowData[5]);
                leadObj.Gender__c = csvRowData[6];
               // String recordId = csvRowData[7].substring(0).trim();
               // Id newId = Id.valueOf(recordId);
                leadObj.Campaign__c = campaignId;
                LeadInsertList.add(leadObj);
            }
            
            try{    
                if(!LeadInsertList.isEmpty()) {
                    insert LeadInsertList;
                }
            }
            catch (Exception ex) {
                throw new AuraHandledException(ex.getMessage());
            } 
        }
        system.debug('LeadInsertList===>'+ LeadInsertList);
        Set<String> CurrentLeadId = new  Set<String>();
        for(Lead objLead :LeadInsertList){
            CurrentLeadId.add(objLead.Id);
        }
       //  system.debug('CurrentLeadId===>'+ CurrentLeadId);
        List<Lead> CurrentLeadDataTable = [Select Id,FirstName, LastName, Email, MobilePhone, LeadSource, Date_of_Birth__c, Gender__c,CampaignNameFormula__c
                                           From Lead Where Id In :CurrentLeadId order by CreatedDate DESC];
       // system.debug('CurrentLeadDataTable===>'+ CurrentLeadDataTable);
       // system.debug('CurrentLeadDataTableSize===>'+ CurrentLeadDataTable.size());
        return CurrentLeadDataTable;    
    }
}