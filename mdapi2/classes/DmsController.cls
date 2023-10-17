global with sharing class DmsController {
    /*
    global static Map<String,Object> getToken(){
        
        Map<String, Object> responseMap = new Map<String, Object>();
        try{
            String endpoint = CommonConstant.dms_endpoint+'/api/oauth2/token';           
            
            Map<String, String> payload = new Map<String, String>();
            payload.put('client_id', CommonConstant.client_id);
            payload.put('client_secret', CommonConstant.client_secret);
            payload.put('authenticated_userid', CommonConstant.authenticated_userid);
            payload.put('grant_type', CommonConstant.grant_type);
            payload.put('provision_key', CommonConstant.provision_key);
            
            System.debug(JSON.serialize(payload));
            Http http = new Http();
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);            
            request.setMethod('POST'); 
            request.setHeader('Content-Type', 'application/json');
            request.setBody(JSON.serialize(payload));
            request.setTimeout(120000);            
            HttpResponse response = http.send(request);
            
            responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());            
            System.debug(response.getBody());
            
            
        }catch(Exception e){
            e.getStackTraceString();
            System.debug(e.getMessage());
        }
        return responseMap;
    }
    
    
    global static String addDocument(String leadAccId){
        String returnResponse = null;
        
        try{
            
            List<ContentDocumentLink> leadDocLink = [Select Id ,ContentDocumentId  from ContentDocumentLink where LinkedEntityId =:leadAccId];
            
            for(ContentDocumentLink contentLink : leadDocLink){
                
                Http http = new Http();
                
                String endpoint = 'https://auxapiuat.auxilo.com/newgen/adddoc/addDocument';
                String payload = addDocPayload(contentLink.ContentDocumentId);
                System.debug('payload for each id'+ payload);
                
                String requestMethod = 'POST';
                String contentType ='multipart/form-data;boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW';
                Integer timeout = 120000;
                
                HttpResponse httpResponse = postCall(endpoint, payload, requestMethod, contentType, timeout);
                returnResponse = httpResponse.getBody();
                System.debug('add document response' + returnResponse);
                break;
            }
            
        }catch(Exception e){
            e.getStackTraceString();
            System.debug(e.getMessage());
        }
        return returnResponse;
    }
    
    private static String addDocPayload(String contentDocumentId){
        String payload = null;
        try{
            String folderIndex = '5486'; // from create WI 
            String documentName= null;
            String Comment= 'add_comment';
            String filePath= null;   
            System.debug('contentDocumentId '+contentDocumentId);
            //  ContentVersion docInfo = [select id ,Title,VersionData, VersionDataUrl from ContentVersion where ContentDocumentId =:contentDocumentId ] ;
            
            documentName = 'Book1.xlsx';
            
            
            Blob file =Blob.valueOf('https://auxilo--dev.sandbox.file.force.com/sfc/servlet.shepherd/version/download/068Bi000000UygL');
            
            ContentVersion cv = new ContentVersion();
            
            String documentBody = 'NGOAddDocumentBDO="<NGOAddDocumentBDO><cabinetName>'+CommonConstant.cabinetName+'</cabinetName><folderIndex>'+folderIndex+'</folderIndex>'+
                '<documentName>'+documentName+'</documentName><volumeId>1</volumeId><accessType>S</accessType><createdByAppName>pdf</createdByAppName><enableLog>Y</enableLog>'+
                '<FTSFlag>PP</FTSFlag><userName>'+CommonConstant.documentUserName+'</userName><userPassword>'+CommonConstant.documentUserPasword+'</userPassword><comment>'+Comment+'</comment></NGOAddDocumentBDO>"'+
                'file=@"'+file+'"';
            
            payload = documentBody;
            
        }catch(Exception e){
            e.getStackTraceString();
        }
        return payload;
    }
    
    
    public static HttpResponse postCall(String endpoint, String payload , String requestMethod, String contentType, Integer timeout){
        Http http = new Http();      
        
        HttpRequest request = new HttpRequest();
        Map<String,Object> tokenResponse = DmsController.getToken();
        String Auth = LOSToken.getAccessToken();
        
        request.setEndpoint(endpoint);            
        request.setMethod(requestMethod);
        request.setHeader('Authorization', Auth);
        request.setHeader('Content-Type', contentType);
       // request.setHeader('username', );
        request.setBody(payload);
        request.setTimeout(timeout);
        
        HttpResponse response = http.send(request);
        
        return response;
    }
    
    
    public static void mock(){
        
        ContentVersion cv = [SELECT id, Title, VersionData, VersionDataUrl FROM ContentVersion WHERE ContentDocumentId ='069Bi000000UdiLIAS'];
        Blob fileBody = cv.VersionData;
        
        // Blob fileBody = Blob.valueOf('sa');
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://auxapiuat.auxilo.com/newgen/adddoc/addDocument');
        req.setMethod('POST');
        req.setHeader('username', 'crm');
        req.setHeader('Authorization', LOSToken.getAccessToken());        
        
        
        String ngoAddDocumentBDO = '<NGOAddDocumentBDO><cabinetName>los</cabinetName><folderIndex>5486</folderIndex><documentName>Other_addtional_document_CoApp_2</documentName><userDBId></userDBId><volumeId>1</volumeId><accessType>S</accessType><createdByAppName>pdf</createdByAppName><enableLog>Y</enableLog><FTSFlag>PP</FTSFlag><userName>crmuser</userName><userPassword>crm@1234</userPassword><comment>add_comment</comment></NGOAddDocumentBDO>';
        req.setBodyAsBlob(Blob.valueOf('--boundary\r\n' + 
                                       'Content-Disposition: form-data; name="NGOAddDocumentBDO"\r\n' +
                                       'Content-Type: text/xml; charset=UTF-8\r\n\r\n' + ngoAddDocumentBDO + '\r\n' +
                                       '--boundary\r\n' +
                                       'Content-Disposition: form-data; name="file"; filename="Book1.xlsx"\r\n' +
                                       'Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet\r\n\r\n' +
                                       EncodingUtil.base64Decode(EncodingUtil.urlEncode(fileBody.toString() , 'UTF-8')) + '\r\n' +
                                       '--boundary--'));
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
        
    }*/
}