global with sharing class  tempcallback {
    global static HttpRequest createHttpRequest(String apiName, String requestBody ,String password,String fileName) {
        Bank_Statement_Cofiguration__mdt configRecord;
        system.debug('String fileName@@@ HttpRequest createHttpRequest'+fileName);
        try{
             configRecord = [SELECT Label, ApiEndPoint__c, RequestMethod__c, metadata__c, auth_token__c,Content_Type__c
                                                     FROM Bank_Statement_Cofiguration__mdt
                                                     WHERE ApiName__c = :apiName
                                                     LIMIT 1]; // Ensures only one record is returned
        }
        catch (Exception e) {
                // Handle API call error
            }
        
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint('callout:Bank_Statement_Analysis_API'+configRecord.ApiEndPoint__c);
        httpRequest.setMethod(configRecord.RequestMethod__c);
        httpRequest.setTimeout(120000);
        if (apiName =='Upload PDF Binary')
            {   
                httpRequest.setHeader('Content-Type', configRecord.Content_Type__c);
                if(fileName != Null){
                httpRequest.setHeader('filename',fileName);
                }
                else {
                    string newfilename='test.pdf';
                    httpRequest.setHeader('filename',newfilename);
                
                }
                httpRequest.setHeader('metadata','{ "password":"' + password + '" ,"bank":"", "name":"" }');
                
            }
        else{
                httpRequest.setHeader('Content-Type', configRecord.Content_Type__c);
        }
        httpRequest.setHeader('auth-token', configRecord.auth_token__c ); // Add the auth-token header
        httpRequest.setBody(requestBody);
    	system.debug('requestbody'+requestBody);
    	system.debug('httpRequest@@'+httpRequest);
        return httpRequest;
    }
    
    global static String getFileName(String apiName, String docId, Id leadId, Id accId, String initialFileName) {
    String responseString = '';
    String password = '';
    String targetApiName = 'Download Report Data Excel';
    String targetStatus;
    
    // Create a new HTTP request
    HttpRequest httpRequest = createHttpRequest(apiName, docId, password, initialFileName);
    
    // Send the HTTP request
    Http http = new Http();
    HttpResponse httpResponse;
    
    try {
        httpResponse = http.send(httpRequest);
        responseString = httpResponse.getBody();
    } catch (Exception e) {
        // Handle API call error
    }
    
    // Parse the JSON response
    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseString);
    
    // Check the response
    if (httpResponse.getStatusCode() == 200) {
        // Get the document status
        targetStatus = (String) responseMap.get('status');
        
        // Get the "fileDetails" list
        List<Object> fileDetails = (List<Object>) responseMap.get('fileDetails');
        if (fileDetails != null && !fileDetails.isEmpty()) {
            Map<String, Object> fileDetail = (Map<String, Object>) fileDetails[0];
            String newFileName = (String) fileDetail.get('fileName');
            
            System.debug('New File Name: ' + newFileName);
            
            // Modify the file name if it contains "_decrypted"
            String updatedFileName = newFileName;
            if (newFileName.contains('_decrypted')) {
                updatedFileName = newFileName.replace('_decrypted', '');
            }
            
            System.debug('Modified value: ' + updatedFileName);
            return updatedFileName;
        }
    }
    
    return docId + '.xlsx';
}


}