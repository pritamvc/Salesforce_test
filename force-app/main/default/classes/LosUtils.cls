/**
 * Name: LosUtils
 * Author: Thinqloud Solutions (Dhanaji Patil)
 * @description This class defines common utility methods for LOS integration.
 * 
 * @Date Feb 20, 2023
 * @Purpose This class is designed to provide common utility methods for LOS integration.
 * @param 
 */
public class LosUtils {
    /**
     * Author: Dhanaji Patil
     * @description This method is used to create an HTTP request.
     *
     * @param url The URL for the HTTP request.
     * @param token The authentication token to be included in the request.
     * @date 28 Feb 2023
     * @return The created HTTP request.
     */
    public static HttpRequest createRequest(String url, String token) {
        HttpRequest request = new HttpRequest();
        try {
            APIConfiguration__mdt apiConfig = [select Request_Body__c from APIConfiguration__mdt where QualifiedApiName =: LOSConstants.LOS_TOKEN_API_NAME];
            Map<String,Object> requestBodyMap = jsonStringToMapConvert(apiConfig.Request_Body__c);
            String userName = requestBodyMap.get(LOSConstants.AUTHENTICATED_USER).toString();
            
            request.setTimeout(120000);
            request.setEndpoint(url);
            request.setMethod(LOSConstants.REQUEST_TYPE_POST);
            request.setHeader(LOSConstants.USER_NAME, userName);
            request.setHeader(LOSConstants.AUTHORIZATION, LOSConstants.BEARER + token);
            request.setHeader(LOSConstants.CONTENT_TYPE, LOSConstants.APPLICATION_JSON);
        } 
        catch (Exception e) {
            System.debug(LOSConstants.REQUEST_EXCEPTION + e.getMessage());
        }
        return request;
    }
    
    /**
     * Author: Dhanaji Patil
     * @description This method is used to make an HTTP POST API request.
     * 
     * @param request The HTTP request to be sent.
     * @return HttpResponse The HTTP response received.
     * @date 28 Feb 2023
     */
    public static HttpResponse postCall(HttpRequest request) {
        
        Http http = new Http();       
        HttpResponse response = http.send(request);  
        try { 
            if(response.getStatusCode() == 200){
                System.debug(LOSConstants.LOS_SUCCESS + response.getBody());
            }
            else{
                System.debug(LOSConstants.ERROR + response.getStatusCode() +' '+ response.getStatus());  
            }
        } 
        catch (Exception e) {
            System.debug(LOSConstants.REQ_EXCEPTION + e.getMessage());
        }
        return response;
    }
    
    /*****************************************************
    * @author Dhanaji Patil
    * @description This method is used to check api response (Success/Failure)
    * @Arguments  Response string 
    * @return String (Success/Failure)       
    * @date 28/02/2023    
    ****************************************************
    Commented by Sohail not in use 1-6-23
    public static String checkResponse(String response){
        String res = null;
        try{
            if(null != response && !String.isEmpty(response)) {
                LosResponseModel convertedResponse = (LosResponseModel)JSON.deserialize(response, LosResponseModel.class);
                if((null != convertedResponse.status || !String.isEmpty(convertedResponse.status)) && (LOSConstants.LOS_SUCCESS.equalsIgnoreCase(convertedResponse.status)) 
                   && (null != convertedResponse.statusCode) && (LOSConstants.LOS_SUCCESS_CODE == convertedResponse.statusCode)) {
                       res = LOSConstants.LOS_SUCCESS;
                }
                else{
                    res = LOSConstants.LOS_FAIL;
                }
            }
            else{
                res = LOSConstants.LOS_FAIL;
            }
        } 
        catch (Exception e) {
            System.debug(LOSConstants.ERROR + e.getMessage());
            res = LOSConstants.LOS_FAIL;
        }
        return res;   
    }*/
    
    /**
     * Author: Dhanaji Patil
     * @description This method is used to format a Date object into a string (DD/MM/YYYY) format.
     * 
     * @param d The Date object to be formatted.
     * @return String The formatted date string (DD/MM/YYYY).
     * @date 28 Feb 2023
     */
    public static String formatDate(Date d) {
        return d.day() + '-' + d.month() + '-' + d.year();
    }
    
    /**
     * Author: Aasim Shaikh
     * @description This method is used to format a date and dateTime object into a string (DD/MM/YYYY) format.
     * 
     * @param dateStr The date or dateTime object to be formatted.
     * @return String The formatted date string (DD/MM/YYYY).
     * @date 28 Feb 2023
     */
    public static String getFormatedDate(Object dateStr) {       
        String formattedDateString = null;      
        if(dateStr instanceof Datetime) {
            Date d = Date.valueOf(dateStr);
            formattedDateString = LosUtils.formatDate(d);
        } 
        else {
            DateTime dt = DateTime.valueOf(dateStr);
            Date d = dt.date();
            formattedDateString = LosUtils.formatDate(d);
        }         
        return formattedDateString;
    }
    
    /**
     * Author: Aasim Shaikh
     * @description This method is used to convert a JSON string into a Map.
     * 
     * @param jsonString The JSON string to be converted.
     * @return Map<String, Object> The Map representation of the JSON data.
     * @date 28 Feb 2023
     */
    public static Map<String,Object> jsonStringToMapConvert(String jsonString) {
        Map<String,Object> convertedMap = new Map<String,Object>();
        convertedMap = (Map<String,Object>) JSON.deserializeUntyped(jsonString);       
        return convertedMap;
    }
    
    /**
     * Author: Aasim Shaikh
     * @description This method is used to send an email when a LOS API fails.
     * 
     * @param opp The Opportunity object associated with the failed API call.
     * @param apiName The name of the API that failed.
     * @date 04 Apr 2023
     */
    public static void sendMailForFailedLosApi(Opportunity opp, String apiName) {
        try{ 
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            Error_log__c errorLog = [SELECT Id from Error_log__c WHERE ApiName__c =: apiName AND Deal__c =: opp.Id ORDER BY CreatedDate LIMIT 1];
            EmailTemplate et =[Select Id,Subject,HtmlValue, DeveloperName From EmailTemplate where DeveloperName =: Label.Los_Api_Failed_Email];
            List<OrgWideEmailAddress> orgEmailAddress=[select Id from OrgWideEmailAddress WHERE DisplayName =: System.Label.Organization_Wide_Email_Addresses];
            
            if(orgEmailAddress.size() > 0){
                mail.setOrgWideEmailAddressId(orgEmailAddress[0].Id); 
            }
            String errorURL = '';
            if(errorLog != null){
                errorURL = System.URL.getSalesforceBaseURL().toExternalForm() + '/'+ errorLog.Id;
            }
            
            List<String> toAddresses = new List<String>();
            List<String> ccAddresses = new List<String>();
            String losFailedEmailAddress = label.LOS_Failed_Email_Address;
            ccAddresses = losFailedEmailAddress.split(',');
            toAddresses.add(UserInfo.getUserEmail()); 
            String emailBody = ((String)et.HtmlValue).replace(LOSConstants.API_NAME, apiName).replace(LOSConstants.ERROR_LOG_LINK,errorURL);
            String newSubject = et.Subject.replace(LOSConstants.API_NAME, apiName);
            mail.setSubject(newSubject);
            mail.setHtmlBody(emailBody);
            mail.setToAddresses(toAddresses);
            mail.setccAddresses(ccAddresses);
            mail.setTreatBodiesAsTemplate(True); 
            mail.setTargetObjectId(opp.Lead__c);
            mail.setWhatId(opp.Id);
            mail.setTreatTargetObjectAsRecipient(false);
            mail.setSaveAsActivity(false);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } 
        catch(Exception e) {
            System.debug(LOSConstants.EMAIL_EXCEPTION + e.getMessage() + LOSConstants.QUERY_EXCEPTION_LINE + e.getLineNumber());
        }     
    }
    
    /**
     * Author: Dhanaji Patil
     * @description This method is used to retrieve Opportunity details based on a Lead Id.
     *
     * @param leadId The Id of the Lead for which Opportunity details need to be retrieved.
     * @return List<Opportunity> A list of Opportunity records associated with the specified Lead Id.
     * @date 28 Feb 2023
     */
    public static List<Opportunity> getOportunityDetails(String leadId) {
        if(null != leadId && leadId != ''){
            String oopQuery = LOSConstants.OPP_QUERY;
            return Database.query(oopQuery);
        }
        return null;
    }
    
    /**
     * Author: Dhanaji Patil
     * @description This method is used to retrieve Opportunity details based on a list of Lead Ids.
     * 
     * @param strLeadIdList A list of Lead Ids for which Opportunity details need to be retrieved.
     * @return List<Opportunity> A list of Opportunity records associated with the specified Lead Ids.
     * @date 28 Feb 2023
     */
    public static List<Opportunity> getOportunityListDetails(List<String> strLeadIdList) {
        
        if(null != strLeadIdList){
            String oopQuery = LOSConstants.OPP_QUERY_LIST;
            return Database.query(oopQuery);
        }
        return null;
    }
    /**
     * Author: Dhanaji Patil
     * @description This method is used to retrieve Co-Applicant details based on a Lead Id.
     * 
     * @param leadId The Id of the Lead for which Co-Applicant details need to be retrieved.
     * @return List<Co_Applicant__c> A list of Co-Applicant records associated with the specified Lead Id.
     * @date 28 Feb 2023
     */
    public static List<Co_Applicant__c> getCoApplicantDetails(String leadId) {
        
        if(null != leadId && leadId != ''){
            String coAppQuery = LOSConstants.COAPP_QUERY;
            return Database.query(coAppQuery);
        }
        return null;
    }
    
    /*****************************************************
    * @author Dhanaji Patil
    * @description This method is used to get CoApplicant Details
    * @Arguments List<LeadId> 
    * @return List<Co_Applicant__c>       
    * @date 28/02/2023  
    * @param    
    ****************************************************
    Commented by Sohail not in use 1-6-23
    public List<Opportunity> getOpportunityList (List<Tracker__c> trackerList){
        List<Opportunity> oppMasterObj = new List<Opportunity>();
        if(null != trackerList && trackerList.size() > 0) {
            List<String> strLeadIdList = new List<String>();
            if(null != trackerList && trackerList.size() > 0) {
                for(Tracker__c leadId : trackerList) {
                    strLeadIdList.add(leadId.Lead__c);
                }
                if(null != strLeadIdList && strLeadIdList.size()>0){
                    oppMasterObj = getOportunityListDetails(strLeadIdList);
                }
            }
        }
        return oppMasterObj;
    }*/

    /**
     * Author: Sohail Solapure
     * @description This method is used to create an HTTP request for creating a Work Item.
     *
     * @param endpoint The API endpoint for the request.
     * @param methodName The name of the API method.
     * @param userName The username associated with the API call.
     * @param token The authentication token for the API call.
     * @return HttpRequest The constructed HTTP request.
     * @date 12 May 2023
     */
    public static HttpRequest createRequestForWorkItem(String endpoint,String methodName,String userName,String token) {
        HttpRequest request = new HttpRequest();
        try {            
            request.setTimeout(120000);
            request.setEndpoint(endpoint);
            request.setMethod(methodName);
            request.setHeader(LOSConstants.USER_NAME, userName);
            request.setHeader(LOSConstants.AUTHORIZATION, token);
            request.setHeader(LOSConstants.CONTENT_TYPE, LOSConstants.TEXT_PLAIN);
        } 
        catch (Exception e) {
            System.debug(LOSConstants.ERROR + e.getMessage());
        }
        return request;
    }

    /**
     * Author: Sohail Solapure
     * @description This method is used to generate the XML body of the request.
     *
     * @param option The option parameter.
     * @param authCode The authentication code.
     * @param segmentcode The segment code.
     * @param locationCode The location code.
     * @param branchCode The branch code.
     * @param opp The Opportunity object.
     * @return String The generated XML body string.
     * @date 12 May 2023
     */
    public static String generateRequest(String option,String authCode,String segmentcode,String locationCode,String branchCode,Opportunity opp){
        String body = LOSConstants.OPTION_START + option + LOSConstants.OPTION_END + authCode + LOSConstants.SEGMENT_START + segmentcode +
        LOSConstants.SEGMENT_END + locationCode + LOSConstants.BRANCH_START + branchCode + LOSConstants.BRANCH_END + opp.Lead__c + LOSConstants.LEAD_END;
        return body;
    }

    /**
     * Author: Sohail Solapure
     * @description This method is used to generate the request body for the data transfer API.
     * 
     * @param opp The Opportunity object.
     * @return Map<String, Object> The generated request body map.
     * @date 12 May 2023
     */
    public static Map<String, Object> generateData(Opportunity opp){
        String oppId = opp.Id;
        Map<String, Object> dataTransferObj = new Map<String, Object>();
        Set<String> tableNames = new Set<String>();

        //Get the API name of data transfer
        LosApiMaster__c dataTransferAPI = [SELECT Id,ApiName__c from LosApiMaster__c where ApiName__c =: LOSConstants.DATA_TRANSFER_API_NAME LIMIT 1];
        
        //Get the records of data transfer API to map
        List<LosApiMap__c> dataTransferMap = [SELECT Id,LosLable__c, SalesforceLable__c, Default__c,LosDataType__c,TableName__c  from LosApiMap__c where LosApiMaster__c =: dataTransferAPI.Id];
        
        //Iterate the table to add values to request map
        for(LosApiMap__c currMap : dataTransferMap){
            if(currMap.LosDataType__c == LOSConstants.DATE_TYPE){
                dataTransferObj.put(currMap.LosLable__c,LosUtils.formatDate(Date.today()));
            }
            else if(currMap.Default__c != null){
                dataTransferObj.put(currMap.LosLable__c,currMap.Default__c);
            }
            else if(currMap.TableName__c != null){
                tableNames.add(currMap.TableName__c);
            }
            else{
                dataTransferObj.put(currMap.LosLable__c,currMap.Default__c);
            }
        }
        
        //Get data for table names
        String qry = '';
        Set<String> qryParams = new Set<String>();

        //Get the mapping records whose tableName is present
        List<LosApiMap__c> tableMapping = [SELECT Id, Name, Default__c, TableName__c, LosApiMaster__c, LosApiMaster__r.ApiName__c, LosLable__c, SalesforceLable__c, LosDataType__c FROM LosApiMap__c WHERE LosApiMaster__c =:dataTransferAPI.Id and TableName__c in:tableNames];
        
        //Mapping LosApiMap__c obj againts key(TableName)
        for (String tableName : tableNames){
            for (LosApiMap__c add : tableMapping){
                qryParams.add(add.SalesforceLable__c);
            }

            //Adds unique select parameters only
            for(String param : qryParams) {
                qry += param + ',';
            }
            qry = LOSConstants.SELECT_FROM + qry + LOSConstants.ID_FROM + tableName + LOSConstants.WHERE_OPPID;
        }

        //Create a query as per mappedFields and tableName
        Opportunity oppData = Database.query(qry);

        for(LosApiMap__c add : tableMapping){
            //String sfData = add.SalesforceLable__c;
            dataTransferObj.put(add.LosLable__c, oppData.get(add.SalesforceLable__c));
        }
        return dataTransferObj;
    }
}