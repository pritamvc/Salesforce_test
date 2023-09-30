/**
 * Author: Dhanaji Patil
 * Description: This Batch class is used to push Fresh deal details to the LOS API.
 * 
 * This batch job takes a list of Opportunity records as input and pushes their details to the LOS API.
 * It is designed to execute callouts using the AllowsCallouts interface.
 * 
 * @param Opportunity The Opportunity records containing the deal details to be pushed.
 * @return This batch class does not return any value.
 * @date 02/03/2023
 * @description This batch class orchestrates the transfer of fresh deal details to the LOS API. It processes
 *              each Opportunity's information and constructs the necessary request for pushing the data to the API.
 *              The actual callout to the LOS API is performed during the execution of the batch job.
 */
public class BatchForDataTransferAPICalling implements Database.Batchable<Map<String, Opportunity>>, Database.AllowsCallouts {
    
    private String reApiName;
    private Opportunity reOppMaster;
    private List<Map<String, Opportunity>> finalListMap1 = new List<Map<String, Opportunity>>();
    
    /**
     * Author: Sohail Solapure
     * Description: Constructor for the BatchForDataTransferAPICalling class.
     * 
     * This constructor initializes the BatchForDataTransferAPICalling class with the required parameters for
     * pushing fresh deal details to the specified API.
     * 
     * @param apiName The name of the API to which the fresh deal details will be pushed.
     * @param oppObject The Opportunity object containing the deal details to be pushed.
     * @description This constructor initializes the BatchForDataTransferAPICalling class with the provided
     */
    public BatchForDataTransferAPICalling(String apiName, Opportunity oppObject){
        this.reApiName = apiName;
        this.reOppMaster = oppObject;
    }
    
    /**
     * Author: Sohail Solapure
     * Description: The start method of the BatchForDataTransferAPICalling class.
     * 
     * This method is called at the beginning of the batch job and returns the initial set of Opportunity records
     * to be used for pushing fresh deal details to the API.
     * 
     * @param bc The batchable context provided by Salesforce.
     * @return A list of maps, where each map contains an Opportunity record to be processed by the batch job's execute method.
     * @description This method serves as the starting point for the batch job's execution. 
     */
    public List<Map<String, Opportunity>> start(Database.BatchableContext bc){
        Map<String,Opportunity> map1 = new Map<String,Opportunity>();
        map1.put(reApiName,reOppMaster);
        finalListMap1.add(map1);
        return finalListMap1;
    }
    
    /**
     * Author: Sohail Solapure
     * Description: The execute method of the BatchForDataTransferAPICalling class.
     * 
     * This method is responsible for processing a batch of Opportunity records and pushing their deal details
     * to the specified API.
     * 
     * @param bc The batchable context provided by Salesforce.
     * @param requestMap A list of maps, where each map contains an Opportunity record to be processed by the batch job.
     * @description This method executes the core processing logic of the batch job.
     */
    public void execute(Database.BatchableContext bc, List<Map<String, Opportunity>> requestMap) {
        String accId;
        try {
            if(null != requestMap && requestMap.size() > 0) {
                Map<String,Opportunity> mapObject =  requestMap[0];
                String apiName = null;
                Opportunity oppObject = new Opportunity();
                
                for (String key : mapObject.keySet()) {
                    apiName = key; 
                    oppObject= mapObject.get(key);
                    accId = oppObject.AccountId;
                }
                
                if(null != oppObject) {
                    String token = LOSToken.getAccessToken();
                    LosImplementation.callingDataTransferAPI(oppObject, token);                    
                }    
            }      
        }
        catch(Exception e){
            //Track the exception
            LosImplementation.trackException(reOppMaster, e.getMessage(), accId);
        } 
    }
     
   /**
     * Author: Sohail Solapure
     * Description: The finish method of the BatchForDataTransferAPICalling class.
     * 
     * This method is called after all batches are processed, allowing for any finalization logic.
     * 
     * @param bc The batchable context provided by Salesforce.
     * @description This method is executed once all batches of Opportunity records have been processed.
     */
    public void finish(Database.BatchableContext bc) {
        List<Opportunity> opportunityUpdatedList = new List<Opportunity>();
        opportunityUpdatedList.add(this.reOppMaster);
        
        //Call this method to schedule DMS api to send documents
        OpportunityTriggerHandler.updateDMSDataSync(opportunityUpdatedList);

    } 
}