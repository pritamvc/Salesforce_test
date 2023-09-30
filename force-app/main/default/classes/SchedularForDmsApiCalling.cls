/*
* 
* @author          Aasim shaikh, Dhanaji Patil
* @description     This scheduler is used to call add document dms Api.
* @Request         None
* @return          No return any value 
* @date            15/03/2023    
* @param
*/
global class SchedularForDmsApiCalling implements Schedulable, Database.AllowsCallouts {
    private Map<String,Object>  requestBody;
    private ContentVersion cv;
    private Opportunity opp;
    private Document_Checklist__c docChecklist;
    
    /*
    * @author          Sohail Solapure
    * @description     constructor
    * @return          No return any value 
    * @param    
    */
    public SchedularForDmsApiCalling(Map<String,Object>  requestBody, ContentVersion cv, Opportunity oppObj,Document_Checklist__c docChecklist) {
        this.requestBody = requestBody;
        this.cv = cv;
        this.opp = oppObj;
        this.docChecklist = docChecklist;
    }
    
    /*
    * @author          Sohail Solapure
    * @description     execute method
    * @return          No return any value 
    * @param    
    */
    global void execute(SchedulableContext sc) {   
        String endpoint = 'callout:DMS_Api';
        List<Map<String, Object>> requestBodyList = new List<Map<String, Object>>();
        requestBodyList.add(requestBody);
        BatchForApiCalling batch = new BatchForApiCalling(endpoint, requestBodyList, cv, opp, docChecklist);
        Database.executeBatch(batch, 1);
        System.abortJob(sc.getTriggerId()); 
    }  
}