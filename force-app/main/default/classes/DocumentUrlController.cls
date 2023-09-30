public class DocumentUrlController {

    // Method to get the public URL to view a Document on the web
    public static String getDocumentViewUrl(String contentDocumentId) {
        String documentViewUrl = '';
        
        // Query the ContentVersion object to get the FileExtension
        List<ContentVersion> contentVersions = [SELECT Id, FileExtension
                                                FROM ContentVersion
                                                WHERE ContentDocumentId = :contentDocumentId
                                                LIMIT 1];

        if (!contentVersions.isEmpty()) {
            String fileExtension = contentVersions[0].FileExtension;
            
            // Construct the URL to view the Document in Salesforce
            documentViewUrl = '/' + contentDocumentId + '/e';
        }
        
        return documentViewUrl;
    }
}