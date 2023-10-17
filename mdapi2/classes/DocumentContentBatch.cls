public class DocumentContentBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    private Id leadId;

    public DocumentContentBatch(Id leadId) {
        this.leadId = leadId;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([
            SELECT Id FROM Document_Checklist__c WHERE Lead__c = :leadId AND Doc_Sub_Type__c = 'Bank Statement'
        ]);
    }

    public void execute(Database.BatchableContext context, List<Document_Checklist__c> scope) {
        List<Id> docChecklistIds = new List<Id>();
        for (Document_Checklist__c checklist : scope) {
            docChecklistIds.add(checklist.Id);
        }

        Map<Id, Document_Checklist__c> mapDocChecklist = new Map<Id, Document_Checklist__c>([
            SELECT Id FROM Document_Checklist__c WHERE Id IN :docChecklistIds
        ]);

        List<ContentDocumentLink> documentLinkList = [
            SELECT Id, ContentDocumentId, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :mapDocChecklist.keySet()
        ];

        Set<Id> contentDocumentIds = new Set<Id>();
        for (ContentDocumentLink link : documentLinkList) {
            contentDocumentIds.add(link.ContentDocumentId);
        }

        List<ContentVersion> contentVersions = [
            SELECT Id, Description, FileType, Download_URL__c, Title, ContentDocumentId, VersionData 
            FROM ContentVersion 
            WHERE ContentDocumentId IN :contentDocumentIds
        ];

        for (ContentVersion contentVersion : contentVersions) {
            Blob documentContent = contentVersion.VersionData;
            String base64Content = EncodingUtil.base64Encode(documentContent);
            system.debug('Base64'+base64Content);
            // Process or store the base64 encoded content as needed
            System.debug('LeadId after base64 processing: ' + leadId);
            string password='New';
            Id accId='001Bi000008YsSoIAK';
            string apiName='Upload PDF Binary';
            string fileName='bankstatement.pdf';
            BankStatementAnalyzer.uploadBinaryPDF(leadId,accId,apiName,base64Content,password,fileName);
        }
    }

    public void finish(Database.BatchableContext context) {
        // Finalization logic if needed
    }
}