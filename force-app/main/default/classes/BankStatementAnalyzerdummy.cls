/*********************************************************************************************
* @author          Harshvardhan Pol
* @description     This Class is used for uploading a bank statement and downloading the statement report
* @date             
* @testClass:      
**********************************************************************************************/
global with sharing class BankStatementAnalyzerdummy{
 
global static HttpRequest createHttpRequest(String apiName, String requestBody ,String password,String fileName) {
        Bank_Statement_Cofiguration__mdt configRecord;
        system.debug('String fileName@@@ HttpRequest createHttpRequest'+fileName);
        try{
             configRecord = [SELECT Label, ApiEndPoint__c, RequestMethod__c, metadata__c, auth_token__c,Content_Type__c
                                                     FROM Bank_Statement_Cofiguration__mdt
                                                     WHERE ApiName__c = :apiName
                                                     LIMIT 1]; // Ensures only one record is returned
        }
        catch (Exception e) {
                // Handle API call error
            }
        
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint('callout:Bank_Statement_Analysis_API'+configRecord.ApiEndPoint__c);
        httpRequest.setMethod(configRecord.RequestMethod__c);
        httpRequest.setTimeout(120000);
        if (apiName =='Upload PDF Binary')
            {   
                httpRequest.setHeader('Content-Type', configRecord.Content_Type__c);
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
                httpRequest.setHeader('Content-Type', configRecord.Content_Type__c);
        }
        httpRequest.setHeader('auth-token', configRecord.auth_token__c ); // Add the auth-token header
        httpRequest.setBody(requestBody);
        system.debug('requestbody   '+requestBody);
        system.debug('httpRequest@@  '+httpRequest);
        return httpRequest;
    }
 
    // 1. Upload file with base64
    @AuraEnabled
    @future(callout=true)
    global static void uploadBinaryPDF(Id leadId , Id accId,String apiName , String base64PDFData,String password,String fileName  ) {
        system.debug('all parameters '+'apiName=='+apiName+' leadId=='+ leadId+'accId=='+accId+' fileName==='+ fileName+'base64=='+base64PDFData);
        //Savepoint sp = Database.setSavepoint();
        String response = '';
        string apiname2='Download Report Data';
        string apiname3='Download Report Data Excel';
        system.debug('String fileName@@@'+fileName);
        //Select Co-Applicant
        Co_Applicant__c coApp ;
        try{
        coApp = [Select Id,Document_Id__c,Document_Status__c from Co_Applicant__c where Lead__c =: leadId AND Account__c =:accId];
        }
        catch (Exception e) {
                // Handle API call error  
                system.debug('Error in Co_Applicant__c'+e.getMessage());
            }

        // Create the request body
        
        Map<String, String> bodyMap = new Map<String, String>();
        bodyMap.put('file',base64PDFData);
        String requestBodyJson = JSON.serialize(bodyMap);
        // Create a new HTTP request        
        HttpRequest httpRequest = createHttpRequest(apiName, requestBodyJson,password,fileName);
        // Send the HTTP request
        Http http = new Http();
        HttpResponse httpResponse;
		
        try {
            httpResponse = http.send(httpRequest);
            
        } catch (Exception e) {
            // Handle API call error
             //Database.rollback(sp);
            system.debug('In exception');
           system.debug('Error calling the API: ' + e.getMessage());
            //return 'Error calling the API: ' + e.getMessage();
        }
        
        // Successful API call
        response = httpResponse.getBody();
        
        // Parse the JSON response
        Map<String, Object> responseObj = (Map<String, Object>) JSON.deserializeUntyped(response);
        
        // Check the response
        if (httpResponse.getStatusCode() == 200) {
            String docId = (String) responseObj.get('docId');
            String documentStatus= (String) responseObj.get('status');
           	system.debug('IN 200');
            system.debug('docId'+docId);
            if((responseObj.get('status')=='Submitted') && (docId != NULL))
            {
                try{
                    //update the records 
                    coApp.Document_Id__c = (String) responseObj.get('docId');
                    //coApp.Document_Status__c = documentStatus ;
                    update coApp;
                    system.debug('docid updated');
                    }
                catch (Exception e) {
                    // Handle API call error
                     system.debug('cant docid updated'+e.getMessage());
                    }      
                // Call the downloadFile method after 1 minute
                Datetime now = Datetime.now();
                Datetime scheduledTime = now.addMinutes(1);
                String cronExpression = '' + scheduledTime.second() + ' ' + scheduledTime.minute() + ' ' + scheduledTime.hour() + ' ' + scheduledTime.day() + ' ' + scheduledTime.month() + ' ? ' + scheduledTime.year();
                system.debug('cronExpression'+cronExpression);
                   //scheduler Download File Job
                System.schedule('Download File Job' + cronExpression, cronExpression, new BankStatementSchedular(apiName2, docId, leadId, accId, fileName));
               }
            // requestBody
            string requestBody ='file upload successfully.';
            storeErrorLogs(leadId,accId,httpRequest.getEndpoint(),requestBody,httpResponse.getBody(),(String) responseObj.get('status'),httpResponse.getStatusCode() );      
        } else {
            // API call returned an error
            response = 'API call failed with status code: ' + httpResponse.getStatusCode();
            
            string requestBody ='File not upload successfully.';
            storeErrorLogs(leadId,accId,httpRequest.getEndpoint(),requestBody,httpResponse.getBody(),(String) responseObj.get('status'),httpResponse.getStatusCode() );
        
        }  
        system.debug('response'+response);
        //return response;
    }

    // 2. Download Report Data
    @AuraEnabled
    @future(callout=true)
    global static void downloadFile( String apiName , String docId,Id leadId , Id accId,String fileName) {
        
        String response1 = '';
        String password ='';
        //String filename ='test.pdf';
        string apiname3 = 'Download Report Data Excel';
        string status ; 
        // Create a new HTTP request
        HttpRequest httpRequest = createHttpRequest(apiName, docId,password,fileName);
        
        
        // Send the HTTP request
        Http http = new Http();
        HttpResponse httpResponse;

        try {
            httpResponse = http.send(httpRequest);
        } catch (Exception e) {
            // Handle API call error
            
        }
            response1 = httpResponse.getBody();

          
            // Parse the JSON response
            Map<String, Object> responseObj1 = (Map<String, Object>) JSON.deserializeUntyped(response1);


        // Check the response
        if (httpResponse.getStatusCode() == 200) {
            
            //get the document status
            String documentStatus= (String) responseObj1.get('status');
            //get Document_Id__c,Document_Status__c
            try{
                Co_Applicant__c coApp = [Select Id,Document_Status__c from Co_Applicant__c where Lead__c =: leadId AND Account__c =:accId];
                coApp.Document_Status__c = documentStatus ;
                update coApp;
            }
            catch(Exception e){
                    
                } 
            //call validation
            if (documentStatus == 'Processed' || documentStatus =='Downloaded' ){
                string validationStatus='';
                Response response = (Response)JSON.deserialize(response1, Response.class);
                Decimal averageBalance ;
                Decimal totalNetCredits ;
                Decimal averageReceiptLastSixMonth ;
                
                List<Object> data = (List<Object>) responseObj1.get('data');

                // Access the first element of the "data" array
                Map<String, Object> dataObj1 = (Map<String, Object>) data[0];
                
                // Access the "accountNumber" value
                String accountNumber = (String) dataObj1.get('accountNumber');
                String accountName = (String) dataObj1.get('accountName');
                //call method validations pass accountNumber and accountName
                validationStatus=bankStatementValidation(accountNumber,accountName,leadId ,accId);
                
                if(validationStatus=='True')
                {
                    Datetime now = Datetime.now();
                    Datetime scheduledTime = now.addMinutes(1);
                    String cronExpression = '' + scheduledTime.second() + ' ' + scheduledTime.minute() + ' ' + scheduledTime.hour() + ' ' + scheduledTime.day() + ' ' + scheduledTime.month() + ' ? ' + scheduledTime.year();
                    //scheduler Download File Excel Job
                    System.schedule('Download File Excel Job'+cronExpression, cronExpression, new BankStatementSchedular(apiName3, docId, leadId, accId, fileName));
                    for (Data dataObj : response.data) {
                        CamAnalysisData camAnalysisData = dataObj.camAnalysisData;
                        averageBalance = camAnalysisData.averageBalance;
                        totalNetCredits =camAnalysisData.totalNetCredits;
                        averageReceiptLastSixMonth = camAnalysisData.averageReceiptLastSixMonth;
                    }
                
                    try{
                        
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
       
                    }
                    catch(Exception e)
                    {
                    }
                        }
                    }
                //call error log method
                storeErrorLogs(leadId,accId,httpRequest.getEndpoint(),httpRequest.getBody(),httpResponse.getBody(),(String) responseObj1.get('status'),httpResponse.getStatusCode() );
                
            } 
            
            else {
                // API call returned an error
                response1 = 'API call failed with status code: ' + httpResponse.getStatusCode();
                
                //call error log method
                storeErrorLogs(leadId,accId,httpRequest.getEndpoint(),httpRequest.getBody(),httpResponse.getBody(),(String) responseObj1.get('status'),httpResponse.getStatusCode() );

        }

       
    }

    // 3. Download Report Data Excel API
    @AuraEnabled
    @future(callout=true)
    global static void  downloadFileExcel( Id leadId, Id accId, String apiName, String docId,String fileName) {
        String response = '';
        string body ='';
        String password ='';
        //String filename ='test.pdf';
        system.debug('String fileName@@@ Download Report Excel Data'+fileName);
        // Create a new HTTP request
        HttpRequest httpRequest = createHttpRequest(apiName, docId,password,fileName);

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
            body = httpResponse.getBody();

            // Process the response as needed
            response = EncodingUtil.base64Encode(httpResponse.getBodyAsBlob());
             // Convert binary data to Base64 string
            Blob binaryData = Blob.valueOf(body);
            
            Integer dotIndex = fileName.lastIndexOf('.');
            String nameWithoutExtension = fileName.substring(0, dotIndex);
            string fullfileName=nameWithoutExtension+'.xlsx';           
            LoanApplicationFormHelper.saveBase64File(leadId,accId, response,fullfileName);
            //call saveBase64FileAcc
            LoanApplicationFormHelper.saveBase64FileAcc(leadId,accId,response,fullfileName);
            
            String status = 'completed';
            //call error log method   
            storeErrorLogs(leadId,accId,httpRequest.getEndpoint(),httpRequest.getBody(),httpResponse.getBody(),status,httpResponse.getStatusCode() );
            
        }
        else if(httpResponse.getStatusCode() == 204){
            // Successful API call
             response = 'Request processed successfully. No content available with status code: ' + httpResponse.getStatusCode();
            // Process the response as needed
                   
            string status = 'In process';
            //call error log method
           
            storeErrorLogs(leadId,accId,httpRequest.getEndpoint(),httpRequest.getBody(),httpResponse.getBody(),status,httpResponse.getStatusCode() );
        } 
        else {
            // API call returned an error
            response = 'API call failed with status code: ' + httpResponse.getStatusCode(); 
            //call error log method
             string status = 'Failed';
            storeErrorLogs(leadId,accId,httpRequest.getEndpoint(),httpRequest.getBody(),httpResponse.getBody(),status,httpResponse.getStatusCode() );
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
    global static string bankStatementValidation(string accountNumber,string accountName ,Id leadId , Id accId){
        //all need variables 
        
        String savedAccountNumberLastFourNumbers='';
        String bankStatementLastFourNumbers='';
        String savedAccountNumber_C='';
        string savedName='';
        string savedFirstName='';
        string savedMiddelename='';
        string savedLastName='';
        string bankStatementaccountNumber=accountNumber;
        String bankStatementName=accountName;
        string bankStatementFirstName='';
        string bankStatementLastName='';
        string bankStatementMiddeleName='';
        string savedFirstNameAndDigits='';
        string savedLastNameAndDigits='';
        string savedMiddleNameAndDigits='';
        string bankFirstNameAndDigits='';
        string bankLastNameAndDigits='';
        string bankMiddleNameAndDigits='';
        string result='False';
        //get saved name and account number 
         try{
             //get saved account number 
                List<Bank_Details__c> SavedBankDetails = [SELECT Id, Account_Number__c FROM Bank_Details__c WHERE Lead__c = :leadId AND Account__c = :accId LIMIT 1];
                if (!SavedBankDetails.isEmpty()) {
                    Bank_Details__c bankDetails = SavedBankDetails[0];
                    savedAccountNumber_C = bankDetails.Account_Number__c;
                    System.debug('Saved Account number Account Number_C: ' + savedAccountNumber_C);
                }}
                catch(Exception e){
                    system.debug('getting error to fetch savedAccountNumber_C '+ e);
                }
        
                try{
                    //get saved name
                    List<Account> accounts = [SELECT Id, Name FROM Account WHERE Id = :accId LIMIT 1];
                    if (!accounts.isEmpty()) {
                        Account account = accounts[0];
                        savedName=account.Name;
                        System.debug('Account Name: ' + account.Name);
                    } else {
                        System.debug('No Account found with the specified ID.');
                    }
                }
                catch(Exception e){
                    system.debug('getting error to fetch savedAccountNumber_C '+ e);
                }
        
                try{                  
                    //last 4 number of saved and bankstatement account number 
                    savedAccountNumberLastFourNumbers = savedAccountNumber_C.substring(savedAccountNumber_C.length() - 4);
                    bankStatementLastFourNumbers=accountNumber.substring(accountNumber.length() - 4);
                }
                catch(Exception e){
                    system.debug('getting error  '+ e);
                }
            try{
            //get first,middle,last name of saved name 
                //String fullName = 'HARSHVARDHAN SHRIKANT POL';
                String[] nameParts = savedName.split(' ');
                       
                savedFirstName = nameParts[0].toUpperCase();
                savedLastName = nameParts[nameParts.size() - 1].toUpperCase();
                
                // Extract middle name(s)
                if (nameParts.size() > 2) {

                
                for (Integer i = 1; i < nameParts.size() - 1; i++) {
                    savedMiddelename += nameParts[i] + ' ';
                }
                savedMiddelename = savedMiddelename.trim().toUpperCase();
                }
                
                            
        }
        catch(Exception e){
                    system.debug('getting error  '+ e);
                }
        
        try{
            
            //get first,middle,last name of bank statement name 
                //String fullName = 'HARSHVARDHAN SHRIKANT POL';
                String[] nameParts = bankStatementName.split(' ');
                bankStatementFirstName = nameParts[0].toUpperCase();
                bankStatementLastName = nameParts[nameParts.size() - 1].toUpperCase();
                
            
       
                // Extract middle name(s)
                if (nameParts.size() > 2) {

                
                for (Integer i = 1; i < nameParts.size() - 1; i++) {
                    bankStatementMiddeleName+= nameParts[i] + ' ';
                }
                bankStatementMiddeleName= bankStatementMiddeleName.trim().toUpperCase();
                }
                
                }
                catch(Exception e){
                            system.debug('getting error  '+ e);
                        }
        try {
            //combination of name
            savedFirstNameAndDigits = savedFirstName+savedAccountNumberLastFourNumbers;
            savedLastNameAndDigits=savedLastName+savedAccountNumberLastFourNumbers;
            savedMiddleNameAndDigits=savedMiddelename+savedAccountNumberLastFourNumbers;
            bankFirstNameAndDigits=bankStatementFirstName+bankStatementLastFourNumbers;
            bankLastNameAndDigits=bankStatementLastName+bankStatementLastFourNumbers;
            bankMiddleNameAndDigits=bankStatementMiddeleName+bankStatementLastFourNumbers;
        }
        catch(Exception e){
                            system.debug('getting error  '+ e);
                        }
        try {
            if((accountNumber==savedAccountNumber_C)||(savedFirstNameAndDigits==bankFirstNameAndDigits)||(savedLastNameAndDigits==bankLastNameAndDigits)||(savedMiddleNameAndDigits==bankMiddleNameAndDigits))
            {
                system.debug('condition satisfied of bank analysis');
               result='True'; 
            }
            
        }
        catch(Exception e){
                            system.debug('getting error  '+ e);
                        }
        
        return result;
            
        }
        
        global static String getFileName(String apiName, String docId, Id leadId, Id accId, String initialFileName) {
    String responseString = '';
    String password = '';
    String targetApiName = 'Download Report Data Excel';
    String targetStatus;
    
    // Create a new HTTP request
    HttpRequest httpRequest = createHttpRequest(apiName, docId, password, initialFileName);
    
    // Send the HTTP request
    Http http = new Http();
    HttpResponse httpResponse;
    
    try {
        httpResponse = http.send(httpRequest);
        responseString = httpResponse.getBody();
    } catch (Exception e) {
        // Handle API call error
    }
    
    // Parse the JSON response
    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseString);
    
    // Check the response
    if (httpResponse.getStatusCode() == 200) {
        // Get the document status
        targetStatus = (String) responseMap.get('status');
        
        // Get the "fileDetails" list
        List<Object> fileDetails = (List<Object>) responseMap.get('fileDetails');
        if (fileDetails != null && !fileDetails.isEmpty()) {
            Map<String, Object> fileDetail = (Map<String, Object>) fileDetails[0];
            String newFileName = (String) fileDetail.get('fileName');
            
            System.debug('New File Name: ' + newFileName);
            
            // Modify the file name if it contains "_decrypted"
            String updatedFileName = newFileName;
            if (newFileName.contains('_decrypted')) {
                updatedFileName = newFileName.replace('_decrypted', '');
            }
            
            System.debug('Modified value: ' + updatedFileName);
            return updatedFileName;
        }
    }
    
    return docId + '.xlsx';
}
    
  
    
}