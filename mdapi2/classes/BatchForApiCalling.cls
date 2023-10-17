/**
 * Author: Aasim Shaikh
 * Description: This Batch class is used to perform API calls.
 * 
 * This batch job takes a list of lead IDs as input and performs API calls for each lead.
 * It is designed to execute callouts using the AllowsCallouts interface.
 * 
 * @param myLeads A list of lead IDs for which the API calls need to be made.
 * @return This batch class does not return any value.
 * @date 09/03/2023
 * @description This batch class orchestrates the execution of API calls for a documents      
 */
public class BatchForApiCalling implements Database.Batchable<Map<String, Object>>, Database.AllowsCallouts {
    
    private String endPoint;
    private List<Map<String, Object>> requestBody;
    private ContentVersion cv;
    private Opportunity opp;
    private Document_Checklist__c docChecklist;
    
    /**
     * Author: Sohail Solapure
     * Description: Constructor for the BatchForApiCalling class.
     * 
     * This constructor initializes the BatchForApiCalling class with the required parameters for making API calls.
     * It takes an API endpoint, request body, ContentVersion, Opportunity, and Document_Checklist__c object as inputs.
     * 
     * @param endPoint The API endpoint to which the calls will be made.
     * @param requestBody The request body for the API calls.
     * @param cv The ContentVersion object associated with the API calls.
     * @param oppObj The Opportunity object associated with the API calls.
     * @param docChecklist The Document_Checklist__c object associated with the API calls.
     * @description This constructor initializes the BatchForApiCalling class with the specified parameters
     */
    public BatchForApiCalling(String endPoint, List<Map<String, Object>> requestBody, ContentVersion cv, Opportunity oppObj,Document_Checklist__c docChecklist) {
        this.endPoint = endPoint;
        this.requestBody = requestBody;
        this.cv = cv;
        this.opp = oppObj;
        this.docChecklist = docChecklist;
    }
    
    /**
     * Author: Sohail Solapure
     * Description: The start method of the BatchForApiCalling class.
     * 
     * This method is called at the beginning of the batch job and returns the initial set of request bodies
     * to be used for making API calls.
     * 
     * @param bc The batchable context provided by Salesforce.
     * @return A list of request bodies to be processed by the batch job's execute method.
     * @description This method serves as the starting point for the batch job's execution.
     */
    public List<Map<String, Object>> start(Database.BatchableContext bc) {
        return this.requestBody;
    }
    
    /**
     * Author: Sohail Solapure
     * Description: The execute method of the BatchForApiCalling class.
     * 
     * This method is responsible for processing a batch of request bodies and making API calls for each batch.
     * 
     * @param bc The batchable context provided by Salesforce.
     * @param requestBody A list of request bodies to be processed by the batch job.
     * @description This method serves as the staexecuterting point for the batch job's execution.
     */
    public void execute(Database.BatchableContext bc, List<Map<String, Object>> requestBody) {
        
        for(Map<String, Object> addMap : requestBody) {
            Map<String, Object> addDocumentBody = new Map<String, Object>(addMap); 
            
            String token = LOSToken.getAccessToken(); 
            
            //Create HTTP request and serialize the request body
            HttpRequest request = LosUtils.createRequest(endpoint, token);
            request.setBody(JSON.serialize(addDocumentBody));
            
            //Send the request and get the response
            HttpResponse infoResponse = LosUtils.postCall(request);
            
            //Deserialize the response and collect parameters
            Map<String, Object> responseBodyMap = LosUtils.jsonStringToMapConvert(infoResponse.getBody());
            String status = responseBodyMap.get(LOSConstants.STATUS).toString();
            Integer statusCode = Integer.valueOf(responseBodyMap.get(LOSConstants.STATUS_CODE));
            String documentIndex = responseBodyMap.get(LOSConstants.DOCUMENT_INDEX).toString();
            
            //Create tracker and error log records for request
            DmsUtils.trackDmsApiRequest(opp, LOSConstants.DMS+docChecklist.DMS_Name__c, request.getBody(), infoResponse.getBody(), docChecklist);
            DmsUtils.trackFailedDmsApiRequest(opp, LOSConstants.DMS+docChecklist.DMS_Name__c, request.getBody(), infoResponse.getBody(), docChecklist);
            ContentVersion objContentVersion = new ContentVersion(Id=cv.Id);
            DmsUtils.updateDocumentIndex(objContentVersion, documentIndex);
            
            //Send email if API fails
            if(!status.endsWithIgnoreCase(LOSConstants.DMS_SUCCESS) && statusCode != LOSConstants.DMS_SUCCESS_CODE) {
                DmsUtils.sendMailForFailedDMSApi(opp,LOSConstants.DMS+docChecklist.DMS_Name__c);
            }
        } 
    }
    
    /**
     * Author: Sohail Solapure
     * Description: The finish method of the BatchForApiCalling class.
     * 
     * This method is called after all batches are processed, allowing for any finalization logic.
     * 
     * @param bc The batchable context provided by Salesforce.
     * @description This method serves as the finish point for the batch job's execution.
     */
    public void finish(Database.BatchableContext bc) { 
    }
}