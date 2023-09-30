/**
 * Author: Aasim Shaikh
 * Description: This Batch class is used to call the LOS API in bulk.
 * 
 * This batch job takes a list of Lead IDs as input and performs bulk API calls to the LOS system.
 * It is designed to execute callouts using the AllowsCallouts interface.
 * 
 * @param Map<String, Object> A map containing Lead IDs for which the LOS API calls need to be made.
 * @return This batch class does not return any value.
 * @date 02/03/2023
 * @description This batch class orchestrates the bulk call to the LOS API for the provided Lead IDs.
 */
public class BatchLOSDealDataSync implements Database.Batchable<Map<String, Object>>, Database.AllowsCallouts {
    
    private String endpoint;
    private Opportunity opp;
    private String accountId;    
    private String methodName;    
    private List<Map<String, Object>> finalListMap;   
    
    /**
     * Author: Sohail Solapure
     * Description: Constructor for the BatchLOSDealDataSync class.
     * 
     * This constructor initializes the BatchLOSDealDataSync class with the required parameters for calling the LOS API.
     * 
     * @param endpoint The API endpoint for the LOS API calls.
     * @param opp The Opportunity object associated with the API calls.
     * @param accountId The ID of the account associated with the Opportunity.
     * @param methodName The name of the method to be called in the LOS API.
     * @param finalListMap A list of maps containing data to be sent in the API calls.
     * @description This constructor initializes the BatchLOSDealDataSync class with the specified parameters.
     */
    public BatchLOSDealDataSync(String endpoint, Opportunity opp, String accountId, String methodName, List<Map<String, Object>> finalListMap) {    
        this.endpoint = endpoint; 
        this.opp = opp;
        this.accountId = accountId;
        this.methodName = methodName;
        this.finalListMap = finalListMap;
    }

    /**
     * Author: Sohail Solapure
     * Description: The start method of the BatchLOSDealDataSync class.
     * 
     * This method is called at the beginning of the batch job and returns the initial set of data maps
     * to be used for making API calls to the LOS system.
     * 
     * @param bc The batchable context provided by Salesforce.
     * @return An iterable of maps, where each map contains data for an API call to the LOS system.
     * @description This method serves as the starting point for the batch job's execution. 
     */
    public Iterable<Map<String, Object>> start(Database.BatchableContext bc) {
        return this.finalListMap;
    }
    
    /**
     * Author: Sohail Solapure
     * Description: The execute method of the BatchLOSDealDataSync class.
     * 
     * This method is responsible for processing a batch of data maps and making API calls to the LOS system.
     * 
     * @param bc The batchable context provided by Salesforce.
     * @param finalListMap A list of maps, where each map contains data for an API call to the LOS system.
     * @description This method executes the core processing logic of the batch job. 
     */
    public void execute(Database.BatchableContext bc, List<Map<String, Object>> finalListMap) {
        try {
            if(finalListMap.size() > 0) {       
                for(Map<String, Object> addMap : finalListMap) {
                    
                    Map<String, Object> leadDetailsModel = new Map<String, Object>(addMap);            
                    // process instance Id
                    leadDetailsModel.put(LOSConstants.WI_NAME, opp.LOS_Id__c);
                    
                    //Get token and create HTTP request
                    String token = LOSToken.getAccessToken();            
                    HttpRequest request = LosUtils.createRequest(endpoint,token); 
                    
                    //Set request body and send http request
                    request.setBody(JSON.serialize(leadDetailsModel));
                    HttpResponse infoResponse = LosUtils.postCall(request);
                    
                    if(infoResponse.getStatusCode() == 200) {
                        String resBody = infoResponse.getBody();
                        
                        //Deserialize the requested response
                        LosResponseModel leadDetailsResponse = (LosResponseModel)JSON.deserialize(resBody, LosResponseModel.class);
                        
                        //Tracking api requests/response
                        LosImplementation.trackApiRequest(opp, methodName, request.getBody(), resBody, accountId);
                        
                        //Tracking failed api requests/response
                        LosImplementation.trackFailedApiRequest(opp, methodName, request.getBody(), resBody, accountId);
                        
                        //If failed then send email 
                        if(!leadDetailsResponse.status.equalsIgnoreCase(LOSConstants.LOS_SUCCESS) && leadDetailsResponse.statusCode != LOSConstants.LOS_SUCCESS_CODE) {
                            LosUtils.sendMailForFailedLosApi(opp, methodName);
                        } 
                    } 
                    else {
                        // Tracks if service is down
                        LosImplementation.trackException(opp, infoResponse.getBody(), accountId);
                    }
                }
            }             
        } 
        catch(Exception e) {
            //Track the exception
            LosImplementation.trackException(opp, e.getMessage(), accountId);
        }
    }
    
    /**
     * Author: Sohail Solapure
     * Description: The finish method of the BatchLOSDealDataSync class.
     * 
     * This method is called after all batches are processed, allowing for any finalization logic.
     * 
     * @param bc The batchable context provided by Salesforce.
     * @description This method is executed once all batches of data maps have been processed.
     */
    public void finish(Database.BatchableContext bc) {      
    }  
}