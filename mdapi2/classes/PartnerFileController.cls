@RestResource(urlMapping='/partner/lead/file/*')
global with sharing class PartnerFileController {
    
    @HttpPost
    global static void uploadFile() {
        system.debug('working');
        Map<String, String> res = new Map<String,String>();
        String jsonString = RestContext.request.requestBody.toString();
        // Use Apex JSON class to parse
        System.debug('data '+ jsonString);
        Map<String,Object> jsonData = (Map<String,Object>) JSON.deserializeUntyped(jsonString);
        
        RestResponse restContext = RestContext.response;
        restContext.addHeader('Content-Type', 'application/json');
        try{
            
            String fileBase = (String) jsonData.get('FileBase');
            System.debug('base: '+fileBase);
            String fileName = (String) jsonData.get('FileName');
            String Email = (String) jsonData.get('Email');
            String MobilePhone = (String) jsonData.get('MobilePhone');
            String partnerId = (String) jsonData.get('partnerId');
          
                        Blob blobBody = EncodingUtil.base64Decode(fileBase);
                        ContentVersion contentVersion = createContentVersion(fileName, blobBody);
                        insert contentVersion;
                        Id contentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;
                        System.debug('Document id: '+ contentDocumentId); 
                        
                       /* Account  acc = [select id, Email__c, PersonEmail from Account where PersonEmail =:Email];            
                        ContentDocumentLink contentDocumentLink = createContentDocumentLink(contentDocumentId,acc.Id);
                        insert contentDocumentLink;
                        */
                        res.put('status','SUCCESS');
                        res.put('message','File Uploaded successfully.');
                        restContext.statusCode = 201;
                        restContext.responseBody = Blob.valueOf(JSON.serialize(res));
         
            
            
        }catch(Exception e){
            e.getStackTraceString();
            res.put('status','FALIURE');
            res.put('message', e.getMessage());
            restContext.statusCode = 404;
            restContext.responseBody = Blob.valueOf(JSON.serialize(res));
        }        
        
    }
    
    private static ContentVersion createContentVersion(String name, Blob body) {
        ContentVersion contentVersion = new ContentVersion();
        
        contentVersion.PathOnClient = name;
        contentVersion.Title = name;
        contentVersion.VersionData = body;
        return contentVersion;
    }
    private  static ContentDocumentLink createContentDocumentLink(Id contentDocumentId, Id parentId){
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = contentDocumentId;
        contentDocumentLink.LinkedEntityId = parentId; /// record id
      //  contentDocumentLink.ShareType = 'I'; // Inferred permission
        contentDocumentLink.Visibility = 'AllUsers';
        return contentDocumentLink;
    } 
}