public class GetPublicUrl {
    
    // Method to get DistributionPublicUrls for Document Checklist records
     @AuraEnabled
    public static List<String> getDistributionPublicUrls(Id leadId, Id applicantId) {
        List<String> publicUrls = new List<String>();
        List<String> DocType= new List<String>();
        
        // Query Document Checklist records based on Lead and Applicant IDs
        List<Document_Checklist__c> checklistRecords = [SELECT Id, Status__c, Applicant__c, Doc_Sub_Type__c 
                                                         FROM Document_Checklist__c 
                                                         WHERE Status__c = 'Uploaded' AND 
                                                               Lead__c = :leadId AND 
                                                               Applicant__c = :applicantId];
        
        // Print the IDs from the first query
        for (Document_Checklist__c checklistRecord : checklistRecords) {
            //System.debug('Document_Checklist__c ID: ' + checklistRecord.Doc_Sub_Type__c);
             DocType.add(checklistRecord.Doc_Sub_Type__c);
        }
        
        if (!checklistRecords.isEmpty()) {
            // Create a set to store ContentDocumentIds
            Set<Id> contentDocumentIds = new Set<Id>();
            
            for (Document_Checklist__c checklistRecord : checklistRecords) {
                contentDocumentIds.add(checklistRecord.Id);
            }
            
            // Query ContentDocumentLinks based on Document Checklist record Ids
            List<ContentDocumentLink> docLinks = [SELECT Id, ContentDocument.Title, ContentDocumentId 
                                                  FROM ContentDocumentLink 
                                                  WHERE LinkedEntityId IN :contentDocumentIds];
            
            // Print the ContentDocumentIds from the second query
            for (ContentDocumentLink docLink : docLinks) {
                //System.debug('ContentDocumentLink ID: ' + docLink.Id);
                //System.debug('ContentDocumentId: ' + docLink.ContentDocumentId);
            }
            
            if (!docLinks.isEmpty()) {
                // Create a map to store ContentDocumentIds and corresponding DistributionPublicUrls
                Map<Id, String> docIdToUrlMap = new Map<Id, String>();
                
                for (ContentDocumentLink docLink : docLinks) {
                    docIdToUrlMap.put(docLink.ContentDocumentId, null); // Initialize URLs to null
                }
                
                // Query DistributionPublicUrls based on ContentDocumentIds
                List<ContentDistribution> dists = [SELECT ContentDocumentId, DistributionPublicUrl 
                                                   FROM ContentDistribution 
                                                   WHERE ContentDocumentId IN :docIdToUrlMap.keySet()];
                
                // Print the DistributionPublicUrls from the third query
                for (ContentDistribution dist : dists) {
                    //System.debug('DistributionPublicUrl: ' + dist.DistributionPublicUrl);
                    docIdToUrlMap.put(dist.ContentDocumentId, dist.DistributionPublicUrl);
                    publicUrls.add(dist.DistributionPublicUrl);
                }
                
                // Populate the publicUrls list
                //for (Document_Checklist__c checklistRecord : checklistRecords) {
                  //  publicUrls.add(docIdToUrlMap.get(checklistRecord.Id));//
                //}
                Map<String, String> DocTypeAndUrl = new Map<String, String>();
				for (Integer i = 0; i < checklistRecords.size() && i < dists.size(); i++) {
   				 	DocTypeAndUrl.put(DocType[i], publicUrls[i]);
				}
				// Loop through the map and print its contents
                for (String key : DocTypeAndUrl.keySet()) {
                    String value = DocTypeAndUrl.get(key);
                    System.debug('Key: ' + key + ', Value: ' + value);
                }
            }
        }
        
        return publicUrls;
    }
     @AuraEnabled
    public static List<Document_Checklist__c> picklistValue(Id leadId,Id applicantId){
        List<String> DocType= new List<String>();
        List<Document_Checklist__c> checklistRecords = [SELECT Id, Status__c, Applicant__c, Doc_Sub_Type__c 
                                                         FROM Document_Checklist__c 
                                                         WHERE Status__c = 'Uploaded' AND 
                                                               Deal__c= :leadId AND 
                                                               Applicant__c = :applicantId];
        
        // Print the IDs from the first query
        for (Document_Checklist__c checklistRecord : checklistRecords) {
            //System.debug('Document_Checklist__c ID: ' + checklistRecord.Doc_Sub_Type__c);
             DocType.add(checklistRecord.Doc_Sub_Type__c);
        }
        return checklistRecords;
    }
    @AuraEnabled
    // Method to get DistributionPublicUrl for a Document Checklist record
    public static String getDistributionPublicUrl(Id Docid) {
        system.debug(' this is doc id Docid'+Docid);
        /*public static String getDistributionPublicUrl(id leadId, id applicantId,id Docid ) {
        // Query to get the Document Checklist record based on Lead and Applicant IDs
        /*Document_Checklist__c checklistRecord = [SELECT Id, Status__c, Applicant__c, Doc_Sub_Type__c 
                                                  FROM Document_Checklist__c 
                                                  WHERE Status__c = 'Uploaded' AND 
                                                        Deal__c = :leadId AND 
                                                        Applicant__c = :applicantId AND
                                                 		Doc_Sub_Type__c=:DocSubType
                                                  LIMIT 1];*/
        
        if ( Docid != null) {
            // Query to get ContentDocumentLink based on the Document Checklist record's Id
            ContentDocumentLink docLink = [SELECT Id, ContentDocument.Title, ContentDocumentId 
                                           FROM ContentDocumentLink 
                                           WHERE LinkedEntityId = : Docid
                                           LIMIT 1];
            
            if (docLink != null) {
                // Query to get DistributionPublicUrl based on ContentDocumentId
                ContentDistribution dist = [SELECT DistributionPublicUrl 
                                             FROM ContentDistribution 
                                             WHERE ContentDocumentId = :docLink.ContentDocumentId 
                                             LIMIT 1];
                
                if (dist != null) {
                    return dist.DistributionPublicUrl;
                }
            }
        }
        
        return null; // Return null if any of the queries did not return valid results
    }
    @AuraEnabled
    public static List<Co_Applicant__c> applicantname(Id Deal ){
        List<Co_Applicant__c> coApplicants = [SELECT Id, Name FROM Co_Applicant__c WHERE Deal__c =:Deal];
        return coApplicants;
    }
}