global with sharing class MobileNoCommunityVerify {
        @AuraEnabled
        global static String OtpRequest(String mobile,String consent) {

       list<Account> checkNo =[SELECT id,PersonMobilePhone FROM Account WHERE PersonMobilePhone=:mobile ];
       if(checkNo.size()>0){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setTimeout(60000);
        request.setEndpoint(CommonConstant.KARZAENDPOINT+'v2/mobile/otp');
        request.setMethod(CommonConstant.REQUEST_METHOD);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('x-karza-key',CommonConstant.KARZA_API_KEY);
         Map<String,Object> requestMap = new Map<String,Object>();
        requestMap.put('mobile',mobile);
        requestMap.put('consent',consent);
        request.setBody(JSON.serialize(requestMap)); 
        
        System.debug(request);
        HttpResponse response = http.send(request);
        try {
            
            if(response.getStatusCode() == 200){
                System.debug('Success: ' + response.getBody());
                
            }else{
                
                System.debug('Error: ' + response.getStatusCode() +' '+ response.getStatus());
                
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
        return response.getBody();
       }else{
        //('Please Enter Registered Mobile Number');
        return null;
       }
        }
        @AuraEnabled
        global static String OtpVerify(String otp,String request_Id) {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(CommonConstant.KARZAENDPOINT+'v2/mobile/status');
            request.setMethod(CommonConstant.REQUEST_METHOD);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('x-karza-key', CommonConstant.KARZA_API_KEY);
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('otp',otp);
            requestMap.put('request_id',request_id);
            request.setBody(JSON.serialize(requestMap));
            System.debug(requestMap);
            HttpResponse response = http.send(request);
            try {
                if(response.getStatusCode() == 200){
                    System.debug('Success: ' + response.getBody());
                    
                }else{
                    System.debug('Error: ' + response.getStatusCode() +' '+ response.getStatus());
                    
                }
                return response.getBody();
            } catch (Exception e) {
                System.debug('Error: ' + e.getMessage());
                return e.getMessage();
            }
            
        }
        
    }