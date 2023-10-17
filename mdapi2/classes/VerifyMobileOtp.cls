global with sharing class VerifyMobileOtp { 
    global static void otpVerify(String otp,String requestId) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(' https://testapi.karza.in/v3/email-async/verify-otp');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('x-karza-key', '3CXmVz52L0erntMn');
        Map<String,Object> requestMap = new Map<String,Object>();
        requestMap.put('otp',otp);
        requestMap.put('requestId',requestId);
        request.setBody(JSON.serialize(requestMap));
        try {
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 200){
                System.debug('Success: ' + response.getBody());
               
            }else{
                System.debug('Error: ' + response.getStatusCode() +' '+ response.getStatus());
               
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
    }
}