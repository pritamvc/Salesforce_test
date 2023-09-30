public with sharing class BulkUploadCampaignController {
    @AuraEnabled
    public static list<Campaign> csvFileRead(Id contentDocumentId){
        list<Campaign> campaignInsertList = new list<Campaign>();
        if(contentDocumentId != null) {
            
            // Fetch File Data based on the basic of document id 
            ContentVersion contentVersionObj = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:contentDocumentId];
            // split the file data
            list<String> csvRecordsList = contentVersionObj.VersionData.toString().split('\n');
            system.debug('csvRecordsList==== >'+csvRecordsList);
            
            for(Integer i = 1; i < csvRecordsList.size(); i++){
                Campaign campaignObj = new Campaign();
                list<String> csvRowData = csvRecordsList[i].split(',');
                System.debug('csvRowData====> '+csvRowData);
                 System.debug('csvRowData[5]====> '+csvRowData[5]);
                campaignObj.Name = csvRowData[0]; 
                campaignObj.Status = csvRowData[1];
                campaignObj.StartDate = Date.valueOf(csvRowData[2]);
                campaignObj.EndDate = Date.valueOf(csvRowData[3]);
                campaignObj.Type = csvRowData[4]; 
              // Integer BudgetCurrency = Integer.valueof(csvRowData[5]);
              //  String s = ( Decimal.valueOf(BudgetCurrency==null||BudgetCurrency.trim()==''?'0':BudgetCurrency).setScale(2) + 0.001 ).format();
              //  Decimal p = Decimal.valueOf(s.substring(0,s.length()-1));
             // System.debug('BudgetCurrency ====> '+BudgetCurrency);
             String paymentsBehind = csvRowData[5].substring(0).trim();
             //,Total_Amount__c = (decimal.valueof(loanAmount) ? decimal.valueof(loanAmount) : null),
                campaignObj.BudgetedCost = decimal.valueof(paymentsBehind);
               // campaignObj.BudgetedCost = (decimal.valueof(csvRowData[5]) ? decimal.valueof(csvRowData[5]) : null);
                campaignInsertList.add(campaignObj);
            }
            
            try{    
                if(!campaignInsertList.isEmpty()) {
                    insert campaignInsertList;
                }
            }
            catch (Exception ex) {
                throw new AuraHandledException(ex.getMessage());
            } 
        }
        system.debug('campaignInsertList======>  ' +campaignInsertList);
        return campaignInsertList;    
    }
}