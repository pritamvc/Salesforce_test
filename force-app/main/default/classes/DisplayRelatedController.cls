public class DisplayRelatedController {
   //Below method will return list of brands [COPYRIGHTS : SalesforceKid (www.salesforcekid.com)]
   
    public static List<Document_Checklist__c> getModel(String oppId)
    {
     List<Document_Checklist__c> docchklist=[select id from Document_Checklist__c where Deal__c=:oppId];
        return docchklist;
    }
    //Below method will return pictures based on Objects [COPYRIGHTS : SalesforceKid (www.salesforcekid.com)]
    @AuraEnabled
    public static List<ContentVersion> getContents(string brandId, string ObjectName) {
        Set<Id> contentIds = new Set<Id>();
        
            //SOQL query to get pictures from Brand object [COPYRIGHTS : SalesforceKid (www.salesforcekid.com)]
            for (ContentDocumentLink cont :[SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink where LinkedEntityId in ( SELECT Id FROM Document_Checklist__c where Id =: brandId) and LinkedEntity.Type=:ObjectName]) {
                contentIds.add(cont.ContentDocumentId);
            }
       
            //SOQL query to get pictures from Model Object [COPYRIGHTS : SalesforceKid (www.salesforcekid.com)]
 
return [SELECT Id,Title FROM ContentVersion WHERE ContentDocumentId IN :contentIds LIMIT 1];
    }
}