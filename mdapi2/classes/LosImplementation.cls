/**
 * @Name  LosImplementation
 * @Author  Thinqloud Solutions (Dhanaji Patil, Aasim Shaikh)
 * @description LosImplementation class
 * @Date  Feb 20, 2023
 * @Purpose This class is used for integrating LOS API logic.
 * @param
 */
public class LosImplementation {   
    
    /**
     * Authors: Aasim Shaikh, Dhanaji Patil
     * @description This method is used to create a work item.
     * 
     * @param opp The Opportunity for which the work item is being created.
     * @param locationCode The location code associated with the work item.
     * @date 28 Feb 2023
     */
    public static void createWorkItem(Opportunity opp, String locationCode){ 
        String accId = opp.AccountId;
        try{
            //Get metadata for create work item 
            APIConfiguration__mdt apiConfig = [SELECT Label, QualifiedApiName,HeaderParameters__c, ApiEndPoint__c, RequestMethod__c, 
                                               RequestTimeout__c  from APIConfiguration__mdt where QualifiedApiName =: System.Label.Create_Work_Item]; 
            
            String endpoint = LOSConstants.ENDPOINT + apiConfig.ApiEndPoint__c;
            String token = LOSToken.getAccessToken(); 
            
            //Get request body for Token
            APIConfiguration__mdt userNameConfig = [select Request_Body__c from APIConfiguration__mdt where QualifiedApiName =: System.Label.LOS_Token];
            
            //Convert the string to map
            Map<String,Object> requestBodyMap = LosUtils.jsonStringToMapConvert(userNameConfig.Request_Body__c);
            String userName = requestBodyMap.get(LOSConstants.AUTHENTICATED_USER).toString();
            
            //Creating the Http request
            HttpRequest request = LosUtils.createRequestForWorkItem(endpoint,apiConfig.RequestMethod__c, userName, token);
            
            //Generate request body
            String xmlBody = LosUtils.generateRequest(System.Label.WI_OPTION, System.Label.WI_AUTH_CODE, System.Label.WI_SEGMNET_CODE, locationCode, System.Label.WI_BRANCH_CODE,opp);            
            request.setBody(xmlBody); 
            
            //Send Http Request to get response
            HttpResponse wrResponse = LosUtils.postCall(request);
            
            //If response statusCode is 200 
            if(wrResponse.getStatusCode() == 200) {
                String resBody = wrResponse.getBody();
                
                //Deserialize the response data 
                LosResponseModel workItemsResponse = (LosResponseModel)JSON.deserialize(resBody, LosResponseModel.class);
                
                //Add deserialized data to Map string of string
                Map<String, String> xmlParsed = parseXMl(workItemsResponse.dataResponse); 
                
                //Tracking api requests/response and to create history in tracker
                trackApiRequest(opp, apiConfig.QualifiedApiName, xmlBody, resBody, accId);
                
                // Inserting ProcessInstanceId, ApplicationNumber, FolderIndex into deal obj
                if( xmlParsed.get(LOSConstants.PROCESS_INSTANCE_ID) != null){   
                    
                    //Add data to opportunity and update the record            
                    opp.LOS_Id__c = xmlParsed.get(LOSConstants.PROCESS_INSTANCE_ID);
                    opp.Loan_Application_Number__c = xmlParsed.get(LOSConstants.APPLICATION_NUMBER);
                    opp.Folder_Index__c = Integer.valueOf(xmlParsed.get(LOSConstants.FOLDER_INDEX));
                    opp.Name = opp.Name +'_'+opp.Loan_Application_Number__c;
                    update opp;                
                }            
                else {
                    //Tracking failed api requests/response and create history in Error log
                    trackFailedApiRequest(opp, apiConfig.QualifiedApiName, xmlBody, resBody, accId);
                    //Send email with failed apiName 
                    LosUtils.sendMailForFailedLosApi(opp, apiConfig.QualifiedApiName);
                }
            }  
            else {
                // Tracks if service is down
                LosImplementation.trackException(opp, wrResponse.getBody(), accId);
            }
            
        } 
        catch(Exception e) {
            e.getStackTraceString();
            //Tracking failed api requests/response and create history in Error log
            trackException(opp, e.getMessage(), accId);
        }       
    }    
    
    /**
     * Author: Dhanaji Patil
     * @description This method is used to call the Data Transfer API.
     *
     * @param opp The Opportunity for which the Data Transfer API is being called.
     * @param token The authentication token used for the API call.
     * @date 28 Feb 2023
     */
    public static void callingDataTransferAPI(Opportunity opp, String token){
        String accId = opp.AccountId;
        try {
            if(null != token && !String.isEmpty(token)) {
                //Get metadata configuration for data transfer api
                APIConfiguration__mdt apiConfig = [SELECT Label, QualifiedApiName, ApiEndPoint__c, RequestMethod__c, HeaderParameters__c, 
                                                   RequestTimeout__c  from APIConfiguration__mdt where QualifiedApiName =: System.Label.Data_Transfer_API]; 
                
                //Get status and statusCode 
                Integer statusCode = LOSConstants.LOS_SUCCESS_CODE;
                
                //Generate request body for data transfer api
                Map<String, Object> dataTransferObj = LosUtils.generateData(opp);
                
                //If dataTransferObj is ot null 
                if(null != dataTransferObj) {
                    //Set endpoint url 
                    String endpoint = LOSConstants.ENDPOINT + apiConfig.ApiEndPoint__c; 
                    
                    //Create Http request 
                    HttpRequest request = LosUtils.createRequest(endpoint, token);                        
                    request.setBody(JSON.serialize(dataTransferObj));
                    
                    //Get response 
                    HttpResponse infoResponse = LosUtils.postCall(request);
                    
                    //If statusCode of response is 200 
                    if(infoResponse.getStatusCode() == 200) {
                        String resBody = infoResponse.getBody();
                        
                        //Deserialize the response
                        LosResponseModel leadDataTransferResponse = (LosResponseModel)JSON.deserialize(resBody, LosResponseModel.class);
                        
                        //Tracking api requests/response to create history in Tracker
                        trackApiRequest(opp, apiConfig.QualifiedApiName, request.getBody(), resBody, accId);
                        
                        //Tracking failed api requests/response to create history in Error log
                        trackFailedApiRequest(opp, apiConfig.QualifiedApiName, request.getBody(), resBody, accId);
                        
                        if(leadDataTransferResponse.status.equalsIgnoreCase(LOSConstants.LOS_SUCCESS) && leadDataTransferResponse.statusCode == LOSConstants.LOS_SUCCESS_CODE) {
                            //Update LOS Sync to true and update the record
                            opp.LOS_Sync__c = true;
                            update opp;
                        } 
                        else if(!leadDataTransferResponse.status.equalsIgnoreCase(LOSConstants.LOS_SUCCESS) && leadDataTransferResponse.statusCode != LOSConstants.LOS_SUCCESS_CODE) {
                            //Send email if api failed
                            LosUtils.sendMailForFailedLosApi(opp, apiConfig.QualifiedApiName);
                        }
                    }  
                    else {
                        //Tracks if service is down
                        LosImplementation.trackException(opp, infoResponse.getBody(), accId);
                    }
                } 
                else {
                    System.debug(LOSConstants.ERROR_MSG);
                }                            
                
            } else {
                System.debug(LOSConstants.TOKEN_ERROR);
            }
        } 
        catch(Exception e){
            //Track the exception 
            trackException(opp, e.getMessage(), accId);
        }
    }
    
    
    /**
     * Author: Aasim Shaikh
     * @description This method is used to call all LOS APIs except Work Item and DataTransfer.
     *
     * @param apiMaster The LosApiMaster__c record representing the API to be called.
     * @param opp The Opportunity related to the API call.
     * @param coApp The Co_Applicant__c record related to the API call.
     * @return List<Map<String, Object>> The list of responses from the API calls.
     * @date 28 Feb 2023
     */
    public static List<Map<String, Object>> callingDynamicImpl(LosApiMaster__c apiMaster, Opportunity opp, Co_Applicant__c coApp){        
        List<Map<String, Object>> leadDetailsModel = new List<Map<String, Object>>();
        String accId = coApp.Account__c;
        try {
            string token = LOSToken.getAccessToken();
            
            if(null == opp.Lead__c) {
                System.debug(LOSConstants.LEAD_ERROR);                
            } 
            else {
                //If token is not null
                if(null != token && !String.isEmpty(token)) {
                    
                    //Get LOS Map Id and Account Id
                    String losMappingId =  apiMaster.Id;
                    String accountId = coApp.Account__c;
                    
                    //Mapping of LOS mapping 
                    leadDetailsModel = LOSHTTPUtils.getDynamicLosMapping(opp.Lead__c, accountId, losMappingId);                     
                } 
                else {
                    System.debug(LOSConstants.TOKEN_ERROR);
                }
            }  
        } 
        catch(Exception e) {
            //Track the exception
            trackException(opp, e.getMessage(), accId);
        }
        return leadDetailsModel;
    }
    
    /**
     * Author: Dhanaji Patil
     * @description This method is used to parse an XML string into a Map<String, String>.
     *
     * @param strResp The XML string to be parsed.
     * @return Map<String, String> A map containing element names as keys and element values as values.
     * @date 28 Feb 2023
     */
    public static Map<String,String> parseXMl(String strResp) {
        
        Map<string, String> mapData = new Map<string, String>();
        Dom.Document doc = new Dom.Document();  
        doc.load(strResp);  
        Dom.XMLNode rootElement = doc.getRootElement();  
        
        for ( Dom.XMLNode childElement : rootElement.getChildElements() ) {
            //root elements of each array
            mapData.put(String.valueOf(childElement.getName()), String.valueOf(childElement.getText()));
        }  
        return mapData;
    }   
    
    /*****************************************************
    * @author Dhanaji Patil
    * @description This method is used to track api request
    * @Arguments  leadId, apiName, request, responseBody, responseModel         
    * @date 28/02/2023   
    * @param 
    ****************************************************  
    Commented by Sohail not in Use 31-5-23
    public static void trackResponse(String leadId, String accId, String apiName, String request, String responseBody, String responseModel) {

    if(null != apiName && null != request && null != responseBody && null != responseModel ) {

    //Get the Tracker record if present with requested leadId,apiName and accountId
    List<Tracker__c> checktrackDetailsobj = [Select Id, ApiName__c, Deal__c, Lead__c, Request__c, Response__c, Status__c, StatusCode__c  from Tracker__c 
    where Lead__c =: leadId and ApiName__c =: apiName and Account__c =: accId];

    //Convert the string to Map
    Map<String, Object> responseModelMap = LosUtils.jsonStringToMapConvert(responseModel);

    //Create record of tracker and insert
    Tracker__c trackDetailsobj = new Tracker__c();
    trackDetailsobj.Lead__c =  leadId;
    trackDetailsobj.Account__c = accId;
    trackDetailsobj.ApiName__c = apiName;
    trackDetailsobj.Request__c = request;
    trackDetailsobj.Response__c = responseBody;
    trackDetailsobj.Status__c = responseModelMap.get(LOSConstants.STATUS).toString();
    trackDetailsobj.StatusCode__c = Integer.valueOf(responseModelMap.get(LOSConstants.STATUS_CODE));
    insert trackDetailsobj;
    }      
    }*/
        
        /*****************************************************
    * @author Dhanaji Patil
    * @description This method is used to track failed api request
    * @Arguments  leadId, apiName, request, responseBody, responseModel         
    * @date 28/02/2023    
    ****************************************************
    Commented by Sohail not in use 31-5-23
    public static void errorLog(String leadId, String accId, String apiName, String request, String responseBody, String responseModel){

    if(null != apiName && null != request && null != responseBody && null != responseModel ) {
    try{
    //Convert string to Map
    Map<String, Object> responseModelMap = LosUtils.jsonStringToMapConvert(responseModel);

    //Create record of error log and insert 
    Error_log__c errorLogObj = new Error_log__c();
    errorLogObj.Lead__c = leadId;
    errorLogObj.Account__c = accId;
    errorLogObj.ApiName__c = apiName;
    errorLogObj.Request__c = request;
    errorLogObj.Response__c = responseBody;
    errorLogObj.Status__c = responseModelMap.get(LOSConstants.STATUS).toString();
    errorLogObj.StatusCode__c = Integer.valueOf(responseModelMap.get(LOSConstants.STATUS_CODE));
    insert errorLogObj;  
    }
    catch(exception e){
    e.getStackTraceString();
    System.debug(LOSConstants.ERROR_EXCEPTION + e.getStackTraceString());   
    }  
    }      
    } */   
    
    /**
     * Author: Aasim Shaikh
     * @description This method is used to track an API request.
     * 
     * @param opp The Opportunity related to the API request.
     * @param apiName The name of the API being called.
     * @param request The request payload sent to the API.
     * @param responseBody The response body received from the API.
     * @param accountId The ID of the account associated with the API request.
     * @date 29 Mar 2023
     */
    public static void trackApiRequest(Opportunity opp, String apiName, String request, String responseBody, String accountId) {
        //Convert string to map response
        Map<String, Object> responseBodyMap = LosUtils.jsonStringToMapConvert(responseBody);
        
        //Get the existing tracker record for requested apiName and opp
        List<Tracker__c> trackerLog = [select Id, ApiName__c, Deal__c, Lead__c, Status__c, StatusCode__c,Account__c from Tracker__c 
                                       where Deal__c =:opp.Id and ApiName__c =:apiName];
        
        String status = responseBodyMap.get(LOSConstants.STATUS).toString();
        Integer statusCode = Integer.valueOf(responseBodyMap.get(LOSConstants.STATUS_CODE));
        
        //If the length of list is greater then 0  
        if(trackerLog.size() > 0) {
            // Update only if existing record is success. If failure skip process altogether,
            if(trackerLog[0].Status__c == LOSConstants.LOS_SUCCESS && trackerLog[0].StatusCode__c == LOSConstants.LOS_SUCCESS_CODE) {
                trackerLog[0].Lead__c =  opp.Lead__c;
                trackerLog[0].Deal__c = opp.Id;
                trackerLog[0].Request__c = request;
                trackerLog[0].Response__c = responseBody;
                trackerLog[0].Status__c = status;
                trackerLog[0].StatusCode__c = statusCode;
                trackerLog[0].Account__c = accountId;
                update trackerLog[0];
            } 
        } 
        //Otherwise create new record
        else {
            Tracker__c trackDetailsobj = new Tracker__c();
            trackDetailsobj.Lead__c =  opp.Lead__c;
            trackDetailsobj.Deal__c = opp.Id;
            trackDetailsobj.ApiName__c = apiName;
            trackDetailsobj.Request__c = request;
            trackDetailsobj.Response__c = responseBody;
            trackDetailsobj.Status__c = status;
            trackDetailsobj.StatusCode__c = statusCode;  
            trackDetailsobj.Account__c = accountId;
            insert trackDetailsobj;
        }
    }
    
    //Commented by Sohail not in Use 31-5-23
    /*public static void trackApiRequestHardCode(Opportunity opp, String apiName, String Status,Integer StatusCode , String reason) {

    //Get the existing tracker record for requested apiName and opp
    List<Tracker__c> trackerLog = [select Id, ApiName__c, Deal__c, Lead__c, Status__c, StatusCode__c from Tracker__c 
    where Deal__c =:opp.Id and ApiName__c =:apiName];        

    //If the length of list is greater then 0  
    if(trackerLog.size() > 0) {
    // Update only if existing record is success. If failure skip process altogether,
    if(trackerLog[0].Status__c == LOSConstants.LOS_SUCCESS && trackerLog[0].StatusCode__c == LOSConstants.LOS_SUCCESS_CODE) {
    trackerLog[0].Lead__c =  opp.Lead__c;
    trackerLog[0].Deal__c = opp.Id;
    trackerLog[0].Request__c = reason;
    trackerLog[0].Response__c = reason;
    trackerLog[0].Status__c = Status;
    trackerLog[0].StatusCode__c = StatusCode;
    update trackerLog[0];
    } 
    } 
    //Otherwise create new record
    else {
    Tracker__c trackDetailsobj = new Tracker__c();
    trackDetailsobj.Lead__c =  opp.Lead__c;
    trackDetailsobj.Deal__c = opp.Id;
    trackDetailsobj.ApiName__c = apiName;
    trackDetailsobj.Request__c = reason;
    trackDetailsobj.Response__c = reason;
    trackDetailsobj.Status__c = Status;
    trackDetailsobj.StatusCode__c = StatusCode;                
    insert trackDetailsobj;
    }
    }*/
    
    /**
     * Author: Aasim Shaikh
     * @description This method is used to track an API request.
     *
     * @param opp The Opportunity related to the API request.
     * @param apiName The name of the API being called.
     * @param request The request payload sent to the API.
     * @param responseBody The response body received from the API.
     * @param accountId The ID of the account associated with the API request.
     * @date 29 Mar 2023
     */
    public static void trackFailedApiRequest(Opportunity opp, String apiName, String request, String responseBody, String accountId) {
        //Convert string to Map
        Map<String, Object> responseBodyMap = LosUtils.jsonStringToMapConvert(responseBody);
        
        //Create new error log record for requested response
        Error_log__c errorLogObj = new Error_log__c();
        errorLogObj.Lead__c = opp.Lead__c;
        errorLogObj.Deal__c = opp.Id;
        errorLogObj.ApiName__c = apiName;
        errorLogObj.Request__c = request;
        errorLogObj.Response__c = responseBody;
        errorLogObj.Status__c = responseBodyMap.get(LOSConstants.STATUS).toString();
        errorLogObj.StatusCode__c = Integer.valueOf(responseBodyMap.get(LOSConstants.STATUS_CODE));
        errorLogObj.Account__c = accountId;
        insert errorLogObj;
    }
    
    /**
     * Author: Aasim Shaikh
     * @description This method is used to track an exception that occurred in the code.
     * 
     * @param opp The Opportunity related to the exception.
     * @param exceptionMessage The message describing the exception.
     * @param accountId The ID of the account associated with the exception (if applicable).
     * @date 04 Apr 2023
     */
    public static void trackException(Opportunity opp, String exceptionMessage, String accountId) {
        //Create new error log record for requested exception
        Error_log__c errorLogObj = new Error_log__c();
        errorLogObj.Lead__c = opp.Lead__c;
        errorLogObj.Deal__c = opp.Id;
        errorLogObj.Request__c = exceptionMessage;
        errorLogObj.Account__c = accountId;
        insert errorLogObj;
    }  
}