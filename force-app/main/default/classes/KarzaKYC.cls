global with sharing class KarzaKYC {
    
    public static void getDocumentOcred(Id leadId) {
        try {
            
            List<ContentVersion> docList = [select id, Title, ContentDocumentId, VersionData, FileType from ContentVersion
                                            where Title in ('pan card','fake-aadhar-complete', 'fake-aadhar-front-full','fake-aadhar-back-full')];
            
            String base64Data = EncodingUtil.base64Encode(docList[0].VersionData);
            
            KycOCRModal kyc = new KycOCRModal();
            kyc.setFile('');
            kyc.setFileBase64(base64Data);
            kyc.setUrl('');
            kyc.setPdfPassword('');
            kyc.setRequiredConfidence(true);
            kyc.setRequiredOcr(true);
            kyc.setReturnQualityChecks(new List<String>{'ALL'});
            kyc.setMaskAadhaarImage('EIGHT_DIGITS');
            kyc.setMaskAadhaarText('EIGHT_DIGITS');
            kyc.setResponseFormat('DOCUMENT');
            kyc.setResponseType('BASE64');
            kyc.setDocTypes(new List<String>{'PAN'});
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://testapi.karza.in/v3/ocr-plus/kyc');
            request.setTimeout(120000);
            request.setMethod('POST');
            request.setHeader('Content-Type', CommonConstant.APPLICATION_JSON);
            request.setHeader('x-karza-key', '3CXmVz52L0erntMn');
            request.setBody(JSON.serialize(kyc));
            
            Http http = new Http();
            HttpResponse response = http.send(request);
            
            Map<String, Object> responseBodyMap = LosUtils.jsonStringToMapConvert(response.getBody());          
            Integer StatusCode = Integer.valueOf(responseBodyMap.get('statusCode'));
            String StatusMessage = responseBodyMap.get('statusMessage').toString();
            
            Error_log__c e = new Error_log__c();
            e.Lead__c = leadId;
            e.Record_Id__c = docList[0].ContentDocumentId;
            e.Record_Type__c = 'ContentDocumentId';
            e.StatusCode__c = StatusCode;
            e.Status__c = StatusMessage != null ? StatusMessage : '';
            e.ApiName__c = 'KYC';
            insert e;
            
            if(StatusCode == 102 ) {
                String jsonString = response.getBody();
                
                Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
                System.debug(Json.serializePretty(jsonMap));
                List<Object> documentsList = (List<Object>)((Map<String, Object>)jsonMap.get('result')).get('documents');
                
                List<Map<String, Object>> documentListMap = new List<Map<String, Object>>();
                
                for(Object o : documentsList) {
                    Map<String, Object> temp = (Map<String, Object>) JSON.deserializeUntyped(Json.serializePretty(o));
                    documentListMap.add(temp);
                }
                
                List<String> base64Str = new List<String>();
                for(Map<String, Object> docMap : documentListMap) {
                    System.debug('O ' + docMap.get('documentBase64'));
                }
            } 
        } catch(Exception e) {
            System.debug('Exception in getDocumentOcred :: ' + e.getMessage() + '. At line no. ' + e.getLineNumber());
        }
    }
    
    public static Boolean insertAndLinkDocumentToLead(String base64, String Title, String pathOnclient, Id leadId) {
        try {
            ContentVersion cv = new ContentVersion();
            cv.VersionData = EncodingUtil.base64Decode(base64);
            cv.Title = Title; 
            cv.PathOnClient = pathOnclient;
            insert cv;
            
            ContentVersion cv1 = [select ContentDocumentId, id from ContentVersion where Id =:cv.Id];
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cv1.ContentDocumentId;
            cdl.LinkedEntityId = leadId;
            insert cdl;
            
            return true;
        } catch(Exception err) {
            System.debug('Exception in insertAndLinkDocumentToLead:: ' + err.getMessage() + '. At line no.-' + err.getLineNumber());
            return false;
        }
    }
    
}