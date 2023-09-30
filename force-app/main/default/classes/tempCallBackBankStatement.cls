@RestResource(urlMapping='/bankStatementtemp')
global class tempCallBackBankStatement {
    global class responseWrapper {
        
        //global String message {get;set;} 
        global String status {get;set;} 
        global String resonText {get;set;} 
        global String statusCode {get;set;}
        
    //    "docId": "DOC05419923",
    //"status": "Downloaded",
    //"message": null,
    //"periodStart": null,
   // "periodEnd": null,
    //"documents": null,
        
        
        //constructor
        global responseWrapper() {
            //this.message = '';
            this.status = '';
            this.resonText = '';
            this.statusCode = '';
        }
    }
    public class RequestBody {
        public String docId;
        public String status;
        public String reportFileName;
        public String endTime;
        public String message;
        public String fileNo;
        public String requestId;
    }
    
public static Map<String, Id> getLeadAndAccountId(String documentId) {
    Map<String, Id> leadAndAccountIds = new Map<String, Id>();

    List<Co_Applicant__c> coApplicants = [
        SELECT Id, Lead__c, Account__c
        FROM Co_Applicant__c
        WHERE Document_Id__c = :documentId
    ];

    for (Co_Applicant__c coApplicant : coApplicants) {
        if (coApplicant.Lead__c != null) {
            leadAndAccountIds.put('LeadId', coApplicant.Lead__c);
        }

        if (coApplicant.Account__c != null) {
            leadAndAccountIds.put('AccountId', coApplicant.Account__c);
        }
    }

    return leadAndAccountIds;
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
        system.debug(' @@@@@@@@@@@ ');
        String inputJsonData = RestContext.request.params.get(CommonConstant.PARAM_DATA);

            if(null != inputJsonData && inputJsonData != '') {
                RequestBody callDetails = new RequestBody();
                
                callDetails = (RequestBody)System.JSON.deserialize(inputJsonData, RequestBody.class);
                system.debug('callDetails@@@'+callDetails);
            }
        /******************************* deserialize request data in temp object *************************************/
        RestRequest req = RestContext.request;
        RequestBody requestBody = (RequestBody)JSON.deserialize(req.requestBody.toString(), RequestBody.class);
        
        String docId = requestBody.docId;
        String status = requestBody.status;
        String reportFileName = requestBody.reportFileName;
        String endTime = requestBody.endTime;
        String message = requestBody.message;
        String fileNo = requestBody.fileNo;
        String requestId = requestBody.requestId;
        string apiname='Download Report Data';
        string response='';
        // call too get lead id and account id
        List<Co_Applicant__c> lstCoApplicant =  getLeadAndAccountUsingDocId(docId);
       /* Map<String, Id> result = getLeadAndAccountId(docId);
        
        id leadId =result.get('LeadId');
        id accId=result.get('AccountId');*/
        
        // Process the request and create the document
        
        // Your logic to create the document goes here
        // ...
        
        // Return the docId
        Map<String, Integer> myMap = new Map<String, Integer>();
        if(lstCoApplicant.size() > 0 && 
           (lstCoApplicant[0].Document_Status__c != 'Processed' || lstCoApplicant[0].Document_Status__c !='Downloaded')){
            
                BankStatementAnalyzer.downloadFile( apiName , docId,lstCoApplicant[0].Lead__c , lstCoApplicant[0].Account__c);
            
        }
       
         system.debug('Response @@@@@@@'+ response);
        
        //Map<String, Object> responseObj1 = (Map<String, Object>) JSON.deserializeUntyped(response);
            //get the document id
            //object docId ='';
      //      String documentStatus= (String) responseObj1.get('status');
        //    system.debug('documentStatus @@@@@@'+ documentStatus);
        	

        // Add key-value pairs to the map
        responseJSON.statusCode = '200';
        responseJSON.status = 'ok';
        responseJSON.resonText ='ok';
        return responseJSON;
    }
    
    
    
}