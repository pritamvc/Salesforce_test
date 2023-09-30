/*********************************************************************************************
* @author          Harshvardhan Pol
* @description     This is a RestController class used to handle and manage bank statement api requests
* @date            01/06/2023    
**********************************************************************************************/
@RestResource(urlMapping='/bankStatement')
global class CallBackBankStatement {
    global class responseWrapper {
        
        //global String message {get;set;} 
        global String status {get;set;} 
        //global String resonText {get;set;} 
        global String statusCode {get;set;}
                       
        //constructor 
        global responseWrapper() {
            this.status = '';
            //this.resonText = '';
            this.statusCode = '';
        }
    }
    Global class RequestBody {
        public string transactionID;
        public String docId;
        public String status;
        public String reportFileName;
        public String endTime;
        public String message;
        public String fileNo;
        public String requestId;
    }
    
    
    public static List<Co_Applicant__c> getLeadAndAccountUsingDocId(String documentId) {
    Map<String, Id> leadAndAccountIds = new Map<String, Id>();

    List<Co_Applicant__c> coApplicants = new List<Co_Applicant__c>();
    coApplicants = [
        SELECT Id, Lead__c, Account__c,Document_Status__c
        FROM Co_Applicant__c
        WHERE Document_Id__c = :documentId
    ];
    return coApplicants;
}
    
    
    @HttpPost
    global static responseWrapper createDocument() {
        responseWrapper responseJSON = new responseWrapper();
        String inputJsonData = RestContext.request.params.get(CommonConstant.PARAM_DATA);
        //string inputJsonData='data={"transactionID":"trans1223","docId":"DOC06917269","status":"Processed","reportFileName":"","endTime":"3","message":"","fileNo":"","requestId":""}';
        system.debug('inputJsonData'+inputJsonData);
        Error_log__c errorLogObj = new Error_log__c();
    
    //errorLogObj.Request__c = inputJsonData ;
   
    //insert errorLogObj;
        
            RequestBody callDetails = new RequestBody();
            if( inputJsonData!= null && inputJsonData != '') {
                
                system.debug('In 1st if ');
                callDetails = (RequestBody)System.JSON.deserialize(inputJsonData, RequestBody.class);
                Error_log__c errorLogObjtest = new Error_log__c();
    
                errorLogObjtest.Request__c = string.valueof(callDetails );
                system.debug('============================================');
               	system.debug('callDetails'+callDetails);
                //insert errorLogObjtest;
        
            }
        // deserialize request data in temp object
        RestRequest req = RestContext.request;
       // RequestBody requestBody = (RequestBody)JSON.deserialize(req.requestBody.toString(), RequestBody.class);
        
        String docId = callDetails.docId;
        String status = callDetails.status;
        string apiname='Download Report Data';
        string response='';
        string fileName='test.pdf';
        string password ='none';
        // call too get lead id and account id
        List<Co_Applicant__c> lstCoApplicant =  getLeadAndAccountUsingDocId(docId);
  		system.debug('lstCoApplicant'+lstCoApplicant);
        system.debug('*******************************************************************************');
        system.debug('Docid'+lstCoApplicant[0].Document_Status__c);
	    storeErrorLogs(lstCoApplicant[0].Lead__c,  lstCoApplicant[0].Account__c,inputJsonData,lstCoApplicant[0].Document_Status__c);    
        //get file name
        Map<String, Integer> myMap = new Map<String, Integer>();
        if(lstCoApplicant.size() > 0 &&
           lstCoApplicant[0].Document_Status__c == 'In Progress' || lstCoApplicant[0].Document_Status__c == 'Submitted'||lstCoApplicant[0].Document_Status__c == 'Rejected' ||   lstCoApplicant[0].Document_Status__c =='Processed' || lstCoApplicant[0].Document_Status__c =='Downloaded'){
                  system.debug('Call call back url downloadFile');
                  	//String leadIds = String.valueOf(lstCoApplicant[0].Lead__c);
            		//BatchBankStatement batch = new BatchBankStatement(leadIds);
            		//Database.executeBatch(batch,1);
            		system.debug('lstCoApplicant[0].Lead__c'+lstCoApplicant[0].Lead__c);
               		system.debug('lstCoApplicant[0].Account__c'+lstCoApplicant[0].Account__c);
                    //BankStatementAnalyzer.downloadFile( apiName , docId,lstCoApplicant[0].Lead__c , lstCoApplicant[0].Account__c,fileName);
                    //storeErrorLogs(lstCoApplicant[0].Lead__c,  lstCoApplicant[0].Account__c,inputJsonData,lstCoApplicant[0].Document_Status__c);
                  
                Datetime now = Datetime.now();
                Datetime scheduledTime = now.addMinutes(1);
                String cronExpression = '' + scheduledTime.second() + ' ' + scheduledTime.minute() + ' ' + scheduledTime.hour() + ' ' + scheduledTime.day() + ' ' + scheduledTime.month() + ' ? ' + scheduledTime.year();
                system.debug('cronExpression'+cronExpression);
                Integer randomNum = Crypto.getRandomInteger();
                System.debug(randomNum); // Print the random number to the debug logs
                //scheduler Download File Job                
                System.schedule('Download Report Data' + cronExpression+randomNum, cronExpression, new BankStatementSchedular(apiName, docId, lstCoApplicant[0].Lead__c ,lstCoApplicant[0].Account__c , fileName,password));
            
                responseJSON.status='Success';
               	responseJSON.statusCode='101';
                return   responseJSON;
           }
           
        /*else if( lstCoApplicant.size() > 0 && lstCoApplicant[0].Document_Status__c =='Downloaded')
        {
           
           //return 'Success';
           responseJSON.status='Fail';
           responseJSON.statusCode='102';
            return  responseJSON;
        }
         else if( lstCoApplicant.size() > 0 && lstCoApplicant[0].Document_Status__c =='Processed')
        {
           //return 'Success';
           responseJSON.status='Processed';
            return  responseJSON;
        }
        else if(lstCoApplicant.size() > 0 &&
                lstCoApplicant[0].Document_Status__c == 'In Progress'){
                    return  responseJSON;
                }
        else  if(lstCoApplicant.size() > 0 && lstCoApplicant[0].Document_Status__c == 'Rejected'){
             return  responseJSON;
        }*/

        else{
            system.debug('in pro');
            //return 'new';
            responseJSON.status='Fail';
            responseJSON.statusCode='102';
            return  responseJSON;

        }
        // Add key-value pairs to the map
        
       // return responseJSON.status;
    }
    //public static void storeErrorLogs(Id leadId, Id accId,Id dealId , String apiEndpoint, String request, String responseBody, String status, Integer statusCode) {
public static void storeErrorLogs(Id leadId, Id accId,  String request, String status){
        // Create new error log record for requested response
        Error_log__c errorLogObj = new Error_log__c();
        errorLogObj.Lead__c = leadId;
        errorLogObj.Account__c = accId;
    	//errorLogObj.Deal__c = dealId;
        //errorLogObj.ApiName__c = apiEndpoint;
        errorLogObj.Request__c = request;
        //errorLogObj.Response__c = responseBody;
        errorLogObj.Status__c = status;
        //errorLogObj.StatusCode__c = statusCode;
        
        try {
            system.debug('In error object ');
            insert errorLogObj;
            
        } catch (DmlException e) {
            
        }
    }
}