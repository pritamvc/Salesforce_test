/*
*  
* @author          Aasim Shaikh
* @description     This Batch is used to call LOS api in bulk.
* @Request         Lead Id
* @return          No return any value 
* @date            02/03/2023    
* 
*/
global class BatchForLosApiCallingInBulk implements Database.Batchable<Map<String, Object>>, Database.AllowsCallouts {
    
    private String endpoint;
    private Opportunity opp;
    private String accountId;    
    private String methodName;    
    private List<Map<String, Object>> finalListMap;   
    
    public BatchForLosApiCallingInBulk(String endpoint, Opportunity opp, String accountId, String methodName, List<Map<String, Object>> finalListMap) {    
        this.endpoint = endpoint; 
        this.opp = opp;
        this.accountId = accountId;
        this.methodName = methodName;
        this.finalListMap = finalListMap;
    }
    
    global Iterable<Map<String, Object>> start(Database.BatchableContext bc) {
        return this.finalListMap;
    }
    
    global void execute(Database.BatchableContext bc, List<Map<String, Object>> finalListMap) {
        try {
            if(finalListMap.size() > 0) {       
                for(Map<String, Object> addMap : finalListMap) {
                    
                    Map<String, Object> leadDetailsModel = new Map<String, Object>(addMap);            
                    // process instance Id
                    leadDetailsModel.put('WI_NAME', opp.LOS_Id__c);
                    
                    String token = LOSToken.getAccessToken();            
                    HttpRequest request = LosUtils.createRequest(endpoint,token); 
                    
                    request.setBody(JSON.serialize(leadDetailsModel));
                    System.debug(JSON.serializePretty(leadDetailsModel));
                    HttpResponse infoResponse = LosUtils.postCall(request);
                    
                    if(infoResponse.getStatusCode() == 200) {
                        String resBody = infoResponse.getBody();
                        System.debug(' Lead Details Response :: '+ infoResponse.getBody());
                        
                        LosResponseModel leadDetailsResponse = (LosResponseModel)JSON.deserialize(resBody, LosResponseModel.class);
                        
                        // tracking api requests/response
                        //LosImplementation.trackResponse(leadId, accountId, methodName, JSON.serializePretty(leadDetailsModel), resBody, resBody);
                        LosImplementation.trackApiRequest(opp, methodName, request.getBody(), resBody);
                        LosImplementation.errorLog(opp.Lead__c, accountId, methodName, JSON.serializePretty(leadDetailsModel), resBody, resBody);
                        if(!leadDetailsResponse.status.equalsIgnoreCase(CommonConstant.LOS_SUCCESS) && leadDetailsResponse.StatusCode != CommonConstant.LOS_SUCCESS_CODE) {
                            // tracking failed api requests/response
                            LosImplementation.trackFailedApiRequest(opp, methodName, request.getBody(), resBody);
                            // send email for failed api 
                            LosUtils.sendMailForFailedLosApi(opp.Lead__c, methodName);
                        } 
                    } else {
                        // Tracks if service is down
                        LosImplementation.trackException(opp, infoResponse.getBody());
                    }
                }
            } else{
                System.debug('Payload is empty ');
            }
            
        } catch(Exception e) {
            System.debug('Exception in BatchForLosApiCallingInBulk: ' + e.getMessage() +'. At line no.- ' + e.getMessage());
            LosImplementation.trackException(opp, e.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        
    }
    
}