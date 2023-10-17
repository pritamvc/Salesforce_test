public class FilesController {
      @AuraEnabled 
    public static List<ContentDocumentLink> fetchFiles(String linkedRecId){
        
		List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId,ContentDocument.title FROM ContentDocumentLink WHERE LinkedEntityId =: linkedRecId];
        return cdlList;
    }

}