public with sharing class getContentVersionClass {
public String versionId { get; set; }

    public void storeId(String docId) {
        ContentVersion contentVersion = [SELECT Id, IsLatest, Title, ContentDocumentId 
                                         FROM ContentVersion 
                                         WHERE ContentDocumentId = :docId AND IsLatest = true 
                                         LIMIT 1];
        versionId = contentVersion.Id;
        System.debug('versionId' +versionId);
    }
}