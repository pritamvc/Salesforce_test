global with sharing class temp1bank {
   global static HttpRequest createHttpRequest(String apiName, String requestBody ,String password, String fileName) {
    Bank_Statement_Cofiguration__mdt bankStatementConfig;
    try {
        bankStatementConfig = [SELECT Label, ApiEndPoint__c, RequestMethod__c, metadata__c, auth_token__c, Content_Type__c
                                                FROM Bank_Statement_Cofiguration__mdt
                                                WHERE ApiName__c = :apiName
                                                LIMIT 1]; // Ensures only one record is returned
    } catch (Exception e) {
        // Handle API call error
    }

    HttpRequest httpRequest = new HttpRequest();
    httpRequest.setEndpoint('callout:Bank_Statement_Analysis_API'+bankStatementConfig.ApiEndPoint__c);
    httpRequest.setMethod(bankStatementConfig.RequestMethod__c);
    
    if (apiName =='Upload PDF Binary') {  
        httpRequest.setHeader('Content-Type', bankStatementConfig.Content_Type__c);
        if(fileName != Null) {
            httpRequest.setHeader('filename', fileName);
        } else {
            String defaultFileName = 'test.pdf';
            httpRequest.setHeader('filename', defaultFileName);
        }
        httpRequest.setHeader('metadata','{ "password":"' + password + '" ,"bank":"", "name":"" }');
    } else {
        httpRequest.setHeader('Content-Type', bankStatementConfig.Content_Type__c);
    }
    
    httpRequest.setHeader('auth-token', bankStatementConfig.auth_token__c ); // Add the auth-token header
    httpRequest.setBody(requestBody);
    return httpRequest;
}
@AuraEnabled
global static String uploadPdfAsBinary(Id leadId, Id accId, String apiName, String base64PDFData, String password, String fileName) {
    String apiResponse = '';
    String downloadReportApi = 'Download Report Data';
    String downloadExcelReportApi = 'Download Report Data Excel';

    // Select Co-Applicant
    Co_Applicant__c coApp;
    try {
        coApp = [Select Id, Document_Id__c, Document_Status__c from Co_Applicant__c where Lead__c =: leadId AND Account__c =:accId];
    } catch (Exception e) {
        // Handle API call error
    }

    // Create the request body
    Map<String, String> bodyMap = new Map<String, String>();
    bodyMap.put('file', base64PDFData);
    String requestBodyJson = JSON.serialize(bodyMap);

    // Create a new HTTP request
    HttpRequest httpRequest = createHttpRequest(apiName, requestBodyJson, password, fileName);

    // Send the HTTP request
    Http http = new Http();
    HttpResponse httpResponse;

    try {
        httpResponse = http.send(httpRequest);
    } catch (Exception e) {
        // Handle API call error
        return 'Error calling the API: ' + e.getMessage();
    }

    List<String> responseList = new List<string>();
    // Successful API call
    apiResponse = httpResponse.getBody();
    responseList.add(apiResponse);
    // Parse the JSON response
    Map<String, Object> responseObj = (Map<String, Object>) JSON.deserializeUntyped(apiResponse);

    // Check the response
    String functionResult;
    if (httpResponse.getStatusCode() == 200) {
        String docId = (String) responseObj.get('docId');
        String documentStatus = (String) responseObj.get('status');

        // Update the records
        coApp.Document_Id__c = docId;
        // coApp.Document_Status__c = documentStatus ;
        update coApp;

        // Call the downloadFile method after 1 minute
        Datetime now = Datetime.now();
        Datetime scheduledTime = now.addMinutes(1);
        String cronExpression = '' + scheduledTime.second() + ' ' + scheduledTime.minute() + ' ' + scheduledTime.hour() + ' ' + scheduledTime.day() + ' ' + scheduledTime.month() + ' ? ' + scheduledTime.year();

        // Scheduler Download File Job
        System.schedule('Download File Job', cronExpression, new BankStatementSchedular(downloadReportApi, docId, leadId, accId));
        // Scheduler Download File Excel Job
        System.schedule('Download File Excel Job', cronExpression, new BankStatementSchedular(downloadExcelReportApi, docId, leadId, accId));

        // Request body
        String requestBody ='File uploaded successfully.';
        //storeErrorLogs(leadId, accountId, httpRequest.getEndpoint(), httpRequest.getBody(), httpResponse.getBody(), documentStatus, httpResponse.getStatusCode());
        storeErrorLogs(leadId, accId, httpRequest.getEndpoint(), requestBody, httpResponse.getBody(), (String) responseObj.get('status'), httpResponse.getStatusCode() );
        functionResult = requestBody;
        return apiResponse;
    } else {
        // API call returned an error
        functionResult = 'API call failed with status code: ' + httpResponse.getStatusCode();
        String requestBody ='File not uploaded successfully.';
        storeErrorLogs(leadId, accId, httpRequest.getEndpoint(), requestBody, httpResponse.getBody(), (String) responseObj.get('status'), httpResponse.getStatusCode() );
    }
    return apiResponse;
}
// 2. Download Report Data
@AuraEnabled
@future(callout=true)
global static void downloadFile(String apiName, String documentId, Id leadId, Id accountId) {
    String apiResponse = '';
    String fileName = 'test.pdf';
    String downloadExcelReportApi = 'Download Report Data Excel';

    // Create a new HTTP request
    HttpRequest httpRequest = createHttpRequest(apiName, documentId, '', fileName);

    // Send the HTTP request
    Http http = new Http();
    HttpResponse httpResponse;

    try {
        httpResponse = http.send(httpRequest);
    } catch (Exception e) {
        // Handle API call error
    }

    apiResponse = httpResponse.getBody();

    // Parse the JSON response
    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(apiResponse);

    // Check the response
    if (httpResponse.getStatusCode() == 200) {
        // Get the document status
        String documentStatus = (String) responseMap.get('status');

        // Get Document_Id__c, Document_Status__c
        try{
            Co_Applicant__c coApp = [SELECT Id, Document_Status__c from Co_Applicant__c where Lead__c =: leadId AND Account__c =: accountId];
            coApp.Document_Status__c = documentStatus;
            update coApp;
        } catch(Exception e){
            
        }

        if (documentStatus.equals('Processed') || documentStatus.equals('Downloaded')) {
            Response response = (Response)JSON.deserialize(apiResponse, Response.class);
            Decimal averageBalance;
            Decimal totalNetCredits;
            Decimal averageReceiptLastSixMonths;

            for (Data currentData : response.data) {
                CamAnalysisData camAnalysisData = currentData.camAnalysisData;

                averageBalance = camAnalysisData.averageBalance;
                totalNetCredits = camAnalysisData.totalNetCredits;
                //averageReceiptLastSixMonths = camAnalysisData.averageReceiptLastSixMonths;
            }

            try{
                List<Bank_Details__c> bankDetailsList = [SELECT Id, Average_Balance__c, Average_Balance_Last_Six_Months__c, Total_Net_Credits__c FROM Bank_Details__c WHERE Lead__c = :leadId AND Account__c = :accountId];

                if (!bankDetailsList.isEmpty()) {
                    for (Bank_Details__c bankDetail : bankDetailsList) {
                        bankDetail.Average_Balance__c = averageBalance;
                        bankDetail.Average_Balance_Last_Six_Months__c = averageReceiptLastSixMonths;
                        bankDetail.Total_Net_Credits__c = totalNetCredits;
                    }
                    update bankDetailsList;
                }
            } catch(Exception e){
                
            }
        }

        //call error log method
        storeErrorLogs(leadId, accountId, httpRequest.getEndpoint(), httpRequest.getBody(), httpResponse.getBody(), documentStatus, httpResponse.getStatusCode());
    } else {
        // API call returned an error
        apiResponse = 'API call failed with status code: ' + httpResponse.getStatusCode();
        
        //call error log method
        storeErrorLogs(leadId, accountId, httpRequest.getEndpoint(), httpRequest.getBody(), httpResponse.getBody(), (String) responseMap.get('status'), httpResponse.getStatusCode());
    }
}
// 3. Download Report Data Excel API
@AuraEnabled
@future(callout=true)
global static void downloadFileExcel(Id leadId, Id accountId, String apiName, String documentId) {
    String apiResponse = '';
    String requestBody = '';
    String fileName = 'test.pdf';

    // Create a new HTTP request
    HttpRequest httpRequest = createHttpRequest(apiName, documentId, '', fileName);

    // Send the HTTP request
    Http http = new Http();
    HttpResponse httpResponse;

    try {
        httpResponse = http.send(httpRequest);
    } catch (Exception e) {
        // Handle API call error 
    }

    // Check the response
    if (httpResponse.getStatusCode() == 200) {
        // Successful API call
        requestBody = httpResponse.getBody();

        // Process the response as needed
        apiResponse = EncodingUtil.base64Encode(httpResponse.getBodyAsBlob());
        
        // Convert binary data to Base64 string
        Blob binaryData = Blob.valueOf(requestBody);
        
        string fullFileName = documentId + '.xlsx';           
        CommunityLeadFormController.saveBase64File(leadId, accountId, apiResponse, fullFileName);
        // Call saveBase64FileAcc
        CommunityLeadFormController.saveBase64FileAcc(leadId, accountId, apiResponse, fullFileName);
        
        String status = 'completed';
        // Call error log method   
        storeErrorLogs(leadId, accountId, httpRequest.getEndpoint(), httpRequest.getBody(), httpResponse.getBody(), status, httpResponse.getStatusCode());
    } else if (httpResponse.getStatusCode() == 204) {
        // Successful API call
        apiResponse = 'Request processed successfully. No content available with status code: ' + httpResponse.getStatusCode();
        String status = 'In process';
        // Call error log method
        storeErrorLogs(leadId, accountId, httpRequest.getEndpoint(), httpRequest.getBody(), httpResponse.getBody(), status, httpResponse.getStatusCode());
    } else {
        // API call returned an error
        apiResponse = 'API call failed with status code: ' + httpResponse.getStatusCode(); 
        // Call error log method
        String status = 'Failed';
        storeErrorLogs(leadId, accountId, httpRequest.getEndpoint(), httpRequest.getBody(), httpResponse.getBody(), status, httpResponse.getStatusCode());
    }
}
public class CamAnalysisData {
    public Decimal averageBalance;
    public Decimal totalNetCredits;
    public Decimal averageReceiptLastSixMonth;
}

    public class Data {
        
        public CamAnalysisData camAnalysisData;
    }
    
    public class Response {
        
        public List<Data> data;
    }
    
    @AuraEnabled
    global static string getIsIncomeConsideredFinancial(Id leadId, id accId) {
        // Query for a Co_Applicant__c record   // lead '00QBi000004ZvxBMAS'  Account__c = '001Bi000006vZAUIA2'
        
        Co_Applicant__c coApplicant = [SELECT Id, Is_Income_Considered_Financial__c
                                        FROM Co_Applicant__c
                                        WHERE Lead__c = :leadId
                                        AND Account__c =:accId
                                        LIMIT 1];
                                        
        
        return coApplicant.Is_Income_Considered_Financial__c;
    }    
    global static void storeErrorLogs(Id leadId, Id accId, String apiEndpoint, String request, String responseBody, String status, Integer statusCode) {
    // Create new error log record for requested response
    Error_log__c errorLogObj = new Error_log__c();
    errorLogObj.Lead__c = leadId;
    errorLogObj.Account__c = accId;
    errorLogObj.ApiName__c = apiEndpoint;
    errorLogObj.Request__c = request;
    errorLogObj.Response__c = responseBody;
    errorLogObj.Status__c = status;
    errorLogObj.StatusCode__c = statusCode;
    
    try {
        insert errorLogObj;
        
    } catch (DmlException e) {
      
    }
}
}