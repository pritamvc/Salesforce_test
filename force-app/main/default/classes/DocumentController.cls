public class DocumentController{
   
    @AuraEnabled(cacheable=true)
    public static List<Document_Checklist__c> fetchDocumentChecklist() {
        return [SELECT Id,Name,	Applicant_Name__c,
        Applicant_Type__c,Received_Date__c,Remarks__c,Doc_Sub_Type__c, Document_Type__c,
        Target_Date__c,Status__c,IsDocumentComplete__c from Document_Checklist__c where Applicant_Type__c='Applicant'];
    }
    @AuraEnabled(cacheable=true)
    public static List<Document_Checklist__c> fetchDocumentChecklist2() {
        return [SELECT Id,Name,	Applicant_Name__c,
        Applicant_Type__c,Received_Date__c,Remarks__c,Doc_Sub_Type__c, Document_Type__c,
        Target_Date__c,Status__c,IsDocumentComplete__c from Document_Checklist__c where Applicant_Type__c=:CommonConstant.COAPPLICANT];
    }
    @AuraEnabled(cacheable=true)
    public static List<Document_Checklist__c> fetchDocumentChecklist3() {
        return [SELECT Id,Name,	Applicant_Name__c,
        Applicant_Type__c,Received_Date__c,Remarks__c,Doc_Sub_Type__c, Document_Type__c,
        Target_Date__c,Status__c,IsDocumentComplete__c from Document_Checklist__c where Applicant_Type__c='Guarantor'];
    }

    @AuraEnabled
    public static string getContentVersion(Id docId){
        return [
            SELECT ContentDocumentId, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId =:docId
            order by ContentDocument.CreatedDate desc limit 1
        ].ContentDocumentId;

        //SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = 'a005i00000Fi2jTAAR' order by ContentDocument.CreatedDate desc limit 1

    }

    @AuraEnabled
    public static Document_Checklist__c createDocument(Document_Checklist__c newRecord) {
       insert newRecord;
       return null;
    }
    
}