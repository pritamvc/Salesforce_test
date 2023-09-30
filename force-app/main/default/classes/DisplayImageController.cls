public with sharing Class DisplayImageController {
 
    @AuraEnabled(cacheable=true)
    public static String getResourceURL(String resourceName) {
            List<StaticResource> resourceList = [
                SELECT Name, NamespacePrefix, SystemModStamp 
                FROM StaticResource 
                WHERE Name = :resourceName
        ];
                             
        if (resourceList.size() == 1) {
           String namespace = resourceList[0].NamespacePrefix;
           return '/resource/' 
              + resourceList[0].SystemModStamp.getTime() + '/' 
              + (namespace != null && namespace != '' ? namespace + '__' : '') 
              + resourceName; 
        } else return '';
    }
    
    @AuraEnabled   
    public static List<ContentVersion> getContents(string oppId, string ObjectName) {
        Set<Id> contentIds = new Set<Id>();
           //List<Document_Checklist__c> docchklist=[select id from Document_Checklist__c where Deal__c=:oppId];
        //return docchklist;

            for (ContentDocumentLink cont :[SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink where LinkedEntityId in ( SELECT Id FROM Document_Checklist__c where Id =: oppId) and LinkedEntity.Type=:ObjectName]) {
                contentIds.add(cont.ContentDocumentId);
                system.debug('contentIds' +contentIds);
            }
       
 
return [SELECT Id,Title FROM ContentVersion WHERE ContentDocumentId IN :contentIds LIMIT 1];
    }
}