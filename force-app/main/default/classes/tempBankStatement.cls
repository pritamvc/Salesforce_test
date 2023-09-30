/*********************************************************************************************
* @author          Harshvardhan Pol
* @description     This Class is used for uploading a bank statement and downloading the statement report
* @date             
* @testClass:      
**********************************************************************************************/

global with sharing class tempBankStatement {    
        // Common method to create an HTTP request for 2 and 3
global static HttpRequest createHttpRequest(String apiName, String requestBody ,String password,String fileName) {
    	Bank_Statement_Cofiguration__mdt bsc;
        try{
             bsc = [SELECT Label, ApiEndPoint__c, RequestMethod__c, metadata__c, auth_token__c,Content_Type__c
                                                     FROM Bank_Statement_Cofiguration__mdt
                                                     WHERE ApiName__c = :apiName
                                                     LIMIT 1]; // Ensures only one record is returned
        }
        catch (Exception e) {
                // Handle API call error
                system.debug( 'Error to get metadata: ' + e.getMessage());
            }
        // Print the values
        System.debug('Label: ' + bsc.Label);
        System.debug('API End Point: ' + bsc.ApiEndPoint__c);
        System.debug('Request Method: ' + bsc.RequestMethod__c);
        System.debug('Metadata: ' + bsc.metadata__c);
        System.debug('Auth Token: ' + bsc.auth_token__c);
        System.debug('Content-Type ' + bsc.Content_Type__c);

        
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint('https://cartbi.com'+bsc.ApiEndPoint__c);
        httpRequest.setMethod(bsc.RequestMethod__c);
        if (apiName =='Upload PDF Binary')
            {	
                System.debug('In if set containt type');
                httpRequest.setHeader('Content-Type', bsc.Content_Type__c);
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
            	httpRequest.setHeader('Content-Type', bsc.Content_Type__c);
        }
        httpRequest.setHeader('auth-token', bsc.auth_token__c ); // Add the auth-token header
        httpRequest.setBody(requestBody);
        system.debug('Done the http request ');
        system.debug(httpRequest);
        return httpRequest;
    }
    
    
    
        
    
    // 1. Upload file with base64
    @AuraEnabled
    global static String uploadBinaryPDF(Id leadId , Id accId,String apiName , String base64PDFData,String password,String fileName  ) {
        //password:this.password,filename:this.fileName
                        
        //, response,fileName
        ////Id leadId , Id accountId, 
        //String apiEndpoint = 'https://cartbi.com/api/uploadBinary';
        String response = '';
        string body='';
        string apiname2='Download Report Data';
        string apiname3='Download Report Data Excel';
        string DownloadReportDataResponse='';
        string DownloadReportDataExcel='';
        string apiEndpoint;
        Integer StatusCode;
        string requestBody ;
        string responseBody;
        string status ; 

        system.debug('lead ID ===>'+ leadId);
        system.debug('account ID ===>'+accId);
        //Select Co-Applicant
        Co_Applicant__c coApp ;
        try{
        coApp = [Select Id,Document_Id__c,Document_Status__c from Co_Applicant__c where Lead__c =: leadId AND Account__c =:accId];
        }
        catch (Exception e) {
                // Handle API call error
                system.debug( 'Error to get coApp in uploadBinaryPDF ' + e.getMessage());
            }

        // Create the request body
        
        Map<String, String> bodyMap = new Map<String, String>();
        bodyMap.put('file',base64PDFData);
        String requestBodyJson = JSON.serialize(bodyMap);
        //request.setBody(bodyJson);
		
        
        // Create a new HTTP request
        
        HttpRequest httpRequest = createHttpRequest(apiName, requestBodyJson,password,fileName);
        system.debug('requestBodyJson==>'+ requestBodyJson);
        System.debug('httpRequest.getEndpoint()'+ httpRequest.getEndpoint());
        

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
        response = httpResponse.getBody();
        responseList.add(response);
        // Parse the JSON response
        Map<String, Object> responseObj = (Map<String, Object>) JSON.deserializeUntyped(response);
		
        // Check the response
        if (httpResponse.getStatusCode() == 200) {
            /*List<String> responseList = new List<string>();
            // Successful API call
            response = httpResponse.getBody();
            responseList.add(response);
            // Parse the JSON response
			Map<String, Object> responseObj = (Map<String, Object>) JSON.deserializeUntyped(response);*/
            //get the document id
            //object docId ='';
            String docId = (String) responseObj.get('docId');
            String documentStatus= (String) responseObj.get('status');
            system.debug('Documet ID '+ docId);
            system.debug('Documet status  '+ documentStatus);
            System.debug('API Response: ' + response);
            //update the records 
            coApp.Document_Id__c = docId;
            //coApp.Document_Status__c = documentStatus ;
            update coApp;
            //response=docId
            //
            // Call the downloadFile method after 1 minute
        Datetime now = Datetime.now();
        Datetime scheduledTime = now.addMinutes(1);
        String cronExpression = '' + scheduledTime.second() + ' ' + scheduledTime.minute() + ' ' + scheduledTime.hour() + ' ' + scheduledTime.day() + ' ' + scheduledTime.month() + ' ? ' + scheduledTime.year();
        System.schedule('Download File Job', cronExpression, new bankStatementSchedular(apiName2, docId, leadId, accId));
    
        // Call the downloadFileExcel method after 1 minute
        //Datetime scheduledTimeExcel = now.addMinutes(1);
        //String cronExpressionExcel = '' + scheduledTimeExcel.second() + ' ' + scheduledTimeExcel.minute() + ' ' + scheduledTimeExcel.hour() + ' ' + scheduledTimeExcel.day() + ' ' + scheduledTimeExcel.month() + ' ? ' + scheduledTimeExcel.year();
        System.schedule('Download File Excel Job', cronExpression, new bankStatementSchedular(apiName3, docId, leadId, accId));
       
			//parameters for eoor log 
            apiEndpoint =httpRequest.getEndpoint();
            StatusCode = httpResponse.getStatusCode();
            requestBody =requestBodyJson;
            responseBody=httpResponse.getBody();
            status =  (String) responseObj.get('status');
            //call error log method
            storeErrorLogs(leadId,accId,apiEndpoint,requestBody,responseBody,Status,StatusCode);
            // Process the response as needed
            System.debug('API Response: ' + response);
        } else {
            // API call returned an error
            response = 'API call failed with status code: ' + httpResponse.getStatusCode();
            
             //parameters for eoor log 
            apiEndpoint =httpRequest.getEndpoint();
            StatusCode = httpResponse.getStatusCode();
            requestBody =requestBodyJson;
            responseBody=httpResponse.getBody();
            status =  (String) responseObj.get('status');
            //call error log method
            storeErrorLogs(leadId,accId,apiEndpoint,requestBody,responseBody,Status,StatusCode);
        }
        
        	//parameters for eoor log 
            apiEndpoint =httpRequest.getEndpoint();
            StatusCode = httpResponse.getStatusCode();
            requestBody =requestBodyJson;
            responseBody=httpResponse.getBody();
            status =  (String) responseObj.get('status');
            //call error log method
            storeErrorLogs(leadId,accId,apiEndpoint,requestBody,responseBody,Status,StatusCode);
		
        return response;
    }

    // 2. Download Report Data
    @AuraEnabled
    @future(callout=true)
    global static void downloadFile( String apiName , String docId,Id leadId , Id accId) {
        //String apiEndpoint = 'https://cartbi.com/api/downloadFile';
        String response1 = '';
		String password ='temp';
        String filename ='test.pdf';
        string apiname3='Download Report Data Excel';
        string apiEndpoint;
        Integer StatusCode;
        string requestBody ;
        string responseBody;
        string status ; 
        // Create a new HTTP request
        HttpRequest httpRequest = createHttpRequest(apiName, docId,password,filename);
        system.debug('httpRequest==>'+ httpRequest );
		
        
        
        // Send the HTTP request
        Http http = new Http();
        HttpResponse httpResponse;

        try {
            httpResponse = http.send(httpRequest);
        } catch (Exception e) {
            // Handle API call error
            system.debug('Error calling the API: ' + e.getMessage());
        }
        	response1 = httpResponse.getBody();

            // Process the response as needed
            System.debug('API Response: ' + response1);
          
            // Parse the JSON response
			Map<String, Object> responseObj1 = (Map<String, Object>) JSON.deserializeUntyped(response1);


        // Check the response
        if (httpResponse.getStatusCode() == 200) {
            // Successful API call
            
                        //get the document id
            //object docId ='';
            String documentStatus= (String) responseObj1.get('status');
            system.debug('documentStatus'+ documentStatus);
            //get Document_Id__c,Document_Status__c
            try{
                Co_Applicant__c coApp = [Select Id,Document_Status__c from Co_Applicant__c where Lead__c =: leadId AND Account__c =:accId];
                coApp.Document_Status__c = documentStatus ;
                update coApp;
            }
            catch(Exception e){
                    system.debug('Error update details  ' + e.getMessage());
                } 
            if (documentStatus == 'Processed' || documentStatus =='Downloaded' ){
                
                System.debug('In if');
                // Then, in your code where you receive the JSON response:
                //String jsonResponse = 'your_json_string';  // Replace this with your actual JSON string
                
                Response response = (Response)JSON.deserialize(response1, Response.class);
                Decimal averageBalance ;
                Decimal totalNetCredits ;
                Decimal averageReceiptLastSixMonth ;
                
                
                for (Data dataObj : response.data) {
                    CamAnalysisData camAnalysisData = dataObj.camAnalysisData;
                    System.debug('averageBalance: ' + camAnalysisData.averageBalance);
                    System.debug('totalNetCredits: ' + camAnalysisData.totalNetCredits);
                    System.debug('averageReceiptLastSixMonth: ' + camAnalysisData.averageReceiptLastSixMonth);
                    
                    averageBalance = camAnalysisData.averageBalance;
                    totalNetCredits =camAnalysisData.totalNetCredits;
                    averageReceiptLastSixMonth = camAnalysisData.averageReceiptLastSixMonth;
                }
                	system.debug('Out of for');
                	
					System.debug('averageBalance: ' + averageBalance);
                    System.debug('totalNetCredits: ' + totalNetCredits);
                    System.debug('averageReceiptLastSixMonth: ' + averageReceiptLastSixMonth);
                
                try{
                    //Bank_Details__c lstapp = [Select Id, Average_Balance__c,Average_Balance_Last_Six_Months__c,Total_Net_Credits__c from Bank_Details__c where  Lead__c ='00QBi000004bMyYMAU' AND Account__c ='001Bi000006wGk7IAE' ];
						//Select Id,Average_Balance__c,Average_Balance_Last_Six_Months__c,Total_Net_Credits__c from Bank_Details__c where  Lead__c ='00QBi000004ZvxBMAS' 
					system.debug('lead id=='+leadId); 
                    system.debug('accId id=='+accId); 
                	//Bank_Details__c lstapp = [Select Id, Average_Balance__c from Bank_Details__c where  Lead__c =:leadId AND Account__c =:accId];
					//system.debug('list<Bank_Details__c> lstapp  '+ lstapp);

                    //lstapp.Average_Balance__c = averageBalance ;
                    //update  lstapp ;
                    //lstapp.Average_Balance_Last_Six_Months__c = averageReceiptLastSixMonth;
                    //lstapp.Total_Net_Credits__c = totalNetCredits;
                    List<Bank_Details__c> lstapp = [SELECT Id, Average_Balance__c, Average_Balance_Last_Six_Months__c, Total_Net_Credits__c FROM Bank_Details__c WHERE Lead__c = :leadId AND Account__c = :accId];

                    if (!lstapp.isEmpty()) {
                        for (Integer i = 0; i < lstapp.size(); i++) {
                            Bank_Details__c bankDetail = lstapp[i];
                            bankDetail.Average_Balance__c = averageBalance;
                            bankDetail.Average_Balance_Last_Six_Months__c = averageReceiptLastSixMonth;
                            bankDetail.Total_Net_Credits__c = totalNetCredits;
                        }
                    
                        update lstapp;
                    }
                   
                    system.debug('@@ Download File Job api value set  @@');
                    
                }
                catch(Exception e){
                    system.debug('Error calling the API: ' + e.getMessage());
                }
    
            }
            
            //return documentStatus;
            try{
                system.debug('@@ Download File Excel Job scheduled @@');
                Datetime now = Datetime.now();
                Datetime scheduledTime = now.addMinutes(1);
                String cronExpression = '' + scheduledTime.second() + ' ' + scheduledTime.minute() + ' ' + scheduledTime.hour() + ' ' + scheduledTime.day() + ' ' + scheduledTime.month() + ' ? ' + scheduledTime.year();    
                System.schedule('Download File Excel Job', cronExpression, new bankStatementSchedular(apiName3, docId, leadId, accId));

            }
            catch(Exception e){
                    system.debug('Error calling the  @@ Download File Excel Job scheduled @@API ' + e.getMessage());
                
                }
            
            //parameters for eoor log 
            apiEndpoint =httpRequest.getEndpoint();
            StatusCode = httpResponse.getStatusCode();
            //requestBody =requestBodyJson;
            //responseBody=httpResponse.getBody();
            //status =  (String) responseObj.get('status');
            //call error log method
            storeErrorLogs(leadId,accId,apiEndpoint,requestBody,responseBody,Status,StatusCode);
       
            
            
        } 
        
        else {
            // API call returned an error
            response1 = 'API call failed with status code: ' + httpResponse.getStatusCode();
            
            
        }

        //return response1;
    }

    // 3. Download Report Data Excel API
    @AuraEnabled
    @future(callout=true)
    global static void  downloadFileExcel( Id leadId, Id accId, String apiName, String docId) {
        //String apiEndpoint = 'https://cartbi.com/api/downloadFileAsExcel';
        String response = '';
        string body ='';
        String password ='temp';
        String filename ='test.pdf';

        // Create a new HTTP request
        HttpRequest httpRequest = createHttpRequest(apiName, docId,password,filename);

        // Send the HTTP request
        Http http = new Http();
        HttpResponse httpResponse;
        

        try {
            httpResponse = http.send(httpRequest);
        } catch (Exception e) {
            // Handle API call error
         //   return 'Error calling the API: ' + e.getMessage();
        }

        // Check the response
        if (httpResponse.getStatusCode() == 200) {
            // Successful API call
            body = httpResponse.getBody();

            // Process the response as needed
            //System.debug('API Response: ' + response);
            response = EncodingUtil.base64Encode(httpResponse.getBodyAsBlob());
             // Convert binary data to Base64 string
            Blob binaryData = Blob.valueOf(body);
            
            //String base64String = base64Encode(binaryData);
            //response = EncodingUtil.base64Encode(binaryData);

            // Print the Base64 encoded string	
            System.debug('Base64 Encoded String: ' + response);
            //Id leadId, Id accountId, String base64File, String fileName
            string fullfileName=docId+'.xlsx';
            system.debug('name of file=====>'+ fullfileName);
            //call saveBase64 file
            //ID acid=';00QBi000004bMs7MAE
            CommunityLeadFormController.saveBase64File(leadId,accId, response,fullfileName);
            //call saveBase64FileAcc
            CommunityLeadFormController.saveBase64FileAcc(leadId,accId,response,fullfileName);
            system.debug('all call done ................................');
            
        }
        else if(httpResponse.getStatusCode() == 204){
    		// Successful API call
             response = 'Request processed successfully. No content available with status code: ' + httpResponse.getStatusCode();
			// Process the response as needed
            System.debug('API Response: ' +'Request processed successfully. No content available.');   
        }
        
        else {
            // API call returned an error
            response = 'API call failed with status code: ' + httpResponse.getStatusCode();
        }
		
//        return response;
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
        system.debug('lead@@'+leadId);
        system.debug('Account@@'+accId);
        Co_Applicant__c coApplicant = [SELECT Id, Is_Income_Considered_Financial__c
                                        FROM Co_Applicant__c
                                        WHERE Lead__c = :leadId
                                        AND Account__c =:accId
                                        LIMIT 1];
                                        
        // Print the Is_Income_Considered_Financial__c field to the debug logs
        System.debug('Is_Income_Considered_Financial__c: ' + coApplicant.Is_Income_Considered_Financial__c);
        
        return coApplicant.Is_Income_Considered_Financial__c;
    }
        
     @AuraEnabled
     // Error log method
    global static void storeErrorLogs(Id leadId, Id accId,String apiEndpoint,String request, String responseBody,String Status,Integer StatusCode) {
     //Create new error log record for requested response
        Error_log__c errorLogObj = new Error_log__c();
        errorLogObj.Lead__c = leadId;
        errorLogObj.Account__c=accId;
        errorLogObj.ApiName__c = apiEndpoint;
        errorLogObj.Request__c = request;
        errorLogObj.Response__c = responseBody;
        errorLogObj.Status__c = Status;
        errorLogObj.StatusCode__c = StatusCode;
        try{
        	insert errorLogObj;
        }
         catch (Exception e) {
            // Handle API call error
         system.debug('Error calling the API: ' + e.getMessage());
        }

        
        
    }
    @AuraEnabled
    global static String getTypeFromCoApplicant(Id leadId, Id accId) {
        system.debug('IN getTypeFromCoApplicant ');
    String query = 'SELECT Id, Type__c FROM Co_Applicant__c WHERE Lead__c = :leadId AND Account__c = :accId';
    List<Co_Applicant__c> coApplicants = Database.query(query);

    if (!coApplicants.isEmpty()) {
        Co_Applicant__c coApplicant = coApplicants[0];
        String type = coApplicant.Type__c;
        System.debug('Type__c: ' + type);
        return type;
    } else {
        System.debug('No matching Co_Applicant__c record found.');
        return null;
    }
}

        
}