trigger DocumentChecklistTrigger on Document_Checklist__c (after update) {
    List<Document_Checklist__c> listDocumentChecklist = new List<Document_Checklist__c>();
    if(trigger.isAfter && trigger.isUpdate){
        For(Document_Checklist__c documentChecklistObj : Trigger.new){
            if((Trigger.oldMap.get(documentChecklistObj.Id).Status__c != documentChecklistObj.Status__c) &&
               (documentChecklistObj.Status__c == 'Accepted' ||documentChecklistObj.Status__c == 'Rejected') && (documentChecklistObj.Lead__c != null)){
                   listDocumentChecklist.add(documentChecklistObj);
               }
        }
    }
    if(!listDocumentChecklist.IsEmpty() && listDocumentChecklist.size() > 0){
        system.debug('listDocumentChecklist.size() ' + listDocumentChecklist.size());
       //  DocumentChecklistHandler.handleAcceptedOrRejected(listDocumentChecklist);
    }
    
}