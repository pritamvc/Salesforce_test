public class BatchBankStatement implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    private Id leadId;

    public BatchBankStatement(Id leadId) {
        this.leadId = leadId;
    }

    // Start method: Returns the initial set of records to process
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([
            SELECT Id,Applicant__r.Bank_Statement_Password__c,Applicant__r.Account__c
            FROM Document_Checklist__c
            WHERE Lead__c = :leadId AND Doc_Sub_Type__c = 'Bank Statement'
        ]);
    }

    // Execute method: Processes each batch of records
    public void execute(Database.BatchableContext context, List<Document_Checklist__c> scope) {
        List<Id> docChecklistIds = new List<Id>();
        List<string> docummentpassword=new list<string>();
        List<Id> applicantId = new List<Id>();
        Map<Id, String> docChecklistIdToPasswordMap = new Map<Id, String>();
        
        for (Document_Checklist__c checklist : scope) {
            docChecklistIds.add(checklist.Id);
            docummentpassword.add(checklist.Applicant__r.Bank_Statement_Password__c);
            applicantId.add(checklist.Applicant__r.Account__c);
            docChecklistIdToPasswordMap.put(checklist.Id, checklist.Applicant__r.Bank_Statement_Password__c);
        }
        //DocumentChecklist
        system.debug('docummentpassword'+docChecklistIdToPasswordMap);
        system.debug('Applicant id'+applicantId);
           Map<Id, Document_Checklist__c> mapDocChecklist = new Map<Id, Document_Checklist__c>([
            SELECT Id
            FROM Document_Checklist__c
            WHERE Id IN :docChecklistIdToPasswordMap.keySet()
        ]);
        // Query ContentDocumentLink records linked to Document_Checklist__c records
        List<ContentDocumentLink> documentLinkList = [
            SELECT Id, ContentDocumentId, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :mapDocChecklist.keySet()
        ];

        Set<Id> contentDocumentIds = new Set<Id>();
        for (ContentDocumentLink link : documentLinkList) {
            contentDocumentIds.add(link.ContentDocumentId);
        }

        // Query ContentVersion records using ContentDocumentIds
        List<ContentVersion> contentVersions = [
            SELECT Id, Description, FileType, Download_URL__c, Title, ContentDocumentId, VersionData 
            FROM ContentVersion 
            WHERE ContentDocumentId IN :contentDocumentIds
        ];
        Map<Id, String> contentVersionlistIdToPasswordMap = new Map<Id, String>();
        Map<Id, String> contentVersionlistIdToApplicantIdMap = new Map<Id, String>();
        // Make sure both lists have the same number of items, and iterate to create the map
            for (Integer i = 0; i < contentVersions.size() && i < docummentpassword.size(); i++) {
                contentVersionlistIdToPasswordMap.put(contentVersions[i].Id, docummentpassword[i]);
            }
            for (Integer i = 0; i < contentVersions.size() && i < applicantId.size(); i++) {
                contentVersionlistIdToApplicantIdMap.put(contentVersions[i].Id, applicantId[i]);
            }

            /*for (Id contentVersionId : contentVersionlistIdToPasswordMap.keySet()) {
                String password = contentVersionlistIdToPasswordMap.get(contentVersionId);
                System.debug('Content Version ID: ' + contentVersionId + ', Password: ' + password);
            }
            
            for (Id contentVersionId : contentVersionlistIdToApplicantIdMap.keySet()) {
                String password = contentVersionlistIdToApplicantIdMap.get(contentVersionId);
                System.debug('Content Version ID: ' + contentVersionId + ', applicantId: ' + password);
            }*/
            
        // Process each ContentVersion record
        for (ContentVersion contentVersion : contentVersions) {
            Blob documentContent = contentVersion.VersionData;
            String fileName=contentVersion.Title+'.pdf';
            String base64Content = EncodingUtil.base64Encode(documentContent);
            // Perform processing on base64 encoded content
            System.debug('fileName' + fileName);
            // Perform actions with the processed data
            System.debug('LeadId after base64 processing: ' + leadId);
            String password = (String)contentVersionlistIdToPasswordMap.get(contentVersion.Id);
            Id accId=(Id)contentVersionlistIdToApplicantIdMap.get(contentVersion.Id);
            String apiName = 'Upload PDF Binary';
            system.debug('password=='+password+'accId'+accId);
            BankStatementAnalyzer.uploadBinaryPDF(leadId, accId, apiName, base64Content, password, fileName);
        }
    }

    // Finish method: Perform finalization logic if needed
    public void finish(Database.BatchableContext context) {
        // Finalization logic if needed
    }
}