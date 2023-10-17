/*********************************************************************************************
* @author          Thinqloud Solutions (Aqueel)
* @description     This class we are using for MobileVerification for Loan Application Form
* @date            24/01/2023    
* @testClass: 
**********************************************************************************************/
global with sharing class MobileVerification { 
    /********************************************************************************************************
* @author          Aqueel
* @description     This method we are use to send OTP to customer in Loan Application Form
* @param           String mobile,String consent, Id leadId
* @return          String : Returning response body
* @date            24/01/2023   
********************************************************************************************************/
    @AuraEnabled
    global static String OtpRequest(String mobile,String consent, Id leadId) {
        String mobileAuthOtp = Label.Mobile_Auth_Otp;
        KARZA_API_Detail__mdt apiConfig = [select ApiEndPoint__c from KARZA_API_Detail__mdt where QualifiedApiName =: mobileAuthOtp];
        String token = LOSToken.getAccessToken();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:LOS_API'+apiConfig.ApiEndPoint__c);
        //request.setEndpoint('https://testapi.karza.in/v2/mobile/otp');
        request.setMethod(CommonConstant.REQUEST_METHOD);
        request.setHeader('Authorization', token);
        request.setHeader('Content-Type', 'application/json');
        Map<String,Object> requestMap = new Map<String,Object>();
        requestMap.put('mobile',mobile);
        requestMap.put('consent',consent);
        request.setBody(JSON.serialize(requestMap)); 
        HttpResponse response = http.send(request);
        
        createErrorLogRecord(leadId, request.getBody(), response.getBody());
        try {
            
            if(response.getStatusCode() == 200){
                
            }else{
                
            }
        } catch (Exception e) {

        }
        return response.getBody();
    }
    /********************************************************************************************************
* @author          Aqueel
* @description     This method we are use to verify the OTP in Loan Application Form
* @param           String otp,String request_Id, Id leadId
* @return          String : Returning response body
* @date            24/01/2023   
********************************************************************************************************/
    @AuraEnabled
    global static String OtpVerify(String otp,String request_Id, Id leadId) {
        String verifymobileOtp = Label.Verify_Mobile_Otp;
        KARZA_API_Detail__mdt apiConfig = [select ApiEndPoint__c from KARZA_API_Detail__mdt where QualifiedApiName =: verifymobileOtp];
        
        String token = LOSToken.getAccessToken();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:LOS_API'+apiConfig.ApiEndPoint__c);
        request.setMethod(CommonConstant.REQUEST_METHOD);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', token);
        Map<String,Object> requestMap = new Map<String,Object>();
        requestMap.put('otp',otp);
        requestMap.put('request_id',request_id);
        request.setBody(JSON.serialize(requestMap));
        HttpResponse response = http.send(request);
        createErrorLogRecord(leadId, request.getBody(), response.getBody());
        try {
            if(response.getStatusCode() == 200){
                
            }else{

            }
            return response.getBody();
        } catch (Exception e) {
            return e.getMessage();
        }
        
    }
    
    /******************************************************************************************************************
* @author           Rohit Pardeshi
* @description      This method is used to Create record of Error Log 
* @Arguments        leadId, StatusCode, StatusMessage, request, response
* @date             04/07/2023   
*******************************************************************************************************************/
    public static void createErrorLogRecord(Id leadId, String request, String response) {
        try {
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response);
            Map<String, Object> dataResponse = (Map<String, Object>) jsonResponse.get('dataResponse');
            Map<String, Object> result = (Map<String, Object>) dataResponse.get('result');
            String statusCodeString = (String) dataResponse.get('status-code');
        	Integer statusCode = Integer.valueOf(statusCodeString);
            String statusMessage = (String) result.get('message');
            String leadIdStr = String.valueOf(leadId);
            
            Error_log__c e = new Error_log__c();
            if (leadIdStr.startsWith('00Q')){
               e.Lead__c = leadId; 
            }else{
               e.Deal__c = leadId; 
            }
            e.Record_Type__c = CommonConstant.ERROR_LOG_MOBILE;
            e.StatusCode__c = statusCode;
            e.Status__c = result != null ? statusMessage : '';
            e.ApiName__c = CommonConstant.API_NAME;
            e.Request__c = request;
            e.Response__c = response;
            insert e;
            
        } catch (Exception e) {
        }
    }   
}