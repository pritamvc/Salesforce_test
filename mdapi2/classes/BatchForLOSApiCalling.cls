/*
* 
* @author          Dhanaji Patil
* @description     This Batch is used to push the deal/lead details to LOS API.
* @Request         Lead Id
* @return          No return any value 
* @date            02/03/2023    
* 
* Not in use
*/

global class BatchForLOSApiCalling implements Database.Batchable<Map<String, Opportunity>>, Database.AllowsCallouts {
     
    private String applicantAccType;
    private String applicantAccId;
    private String reApiName;
    
    private Opportunity reOppMaster;
    private List<Map<String, Opportunity>> finalListMap = new List<Map<String, Opportunity>>();
    
    /********************************** created constructor for set the values **********************************/
    public BatchForLOSApiCalling(String apiName, Opportunity oppObject, String accType, String accId) {      
        this.reOppMaster = oppObject;
        this.reApiName = apiName;
        this.applicantAccType = accType;
        this.applicantAccId = accId;
    }
    
    public BatchForLOSApiCalling(String apiName, String leadId) {
        Opportunity oppObject = LosUtils.getOportunityDetails(leadId)[0];        
        this.reOppMaster = oppObject;
        this.reApiName = apiName;
        
        List<Co_Applicant__c> coAppMaster = LosUtils.getCoApplicantDetails(oppObject.Lead__c);        
        this.applicantAccType = coAppMaster[0].Type__c;
        this.applicantAccId = coAppMaster[0].Account__c;
    }
    /********************************** start method to retun list map for execution **********************************/
    public List<Map<String, Opportunity>> start(Database.BatchableContext BC) {
        Map<String,Opportunity> mapData = new Map<String,Opportunity>();
        mapData.put(reApiName, reOppMaster);
        finalListMap.add(mapData);
        return finalListMap;
    }
    
    /************************ execute is used to perform api calling operation ****************************************/
    global void execute(Database.BatchableContext BC, List<Map<String, Opportunity>> requestMap) {
        
        try {
            if(null != requestMap && requestMap.size()>0) {
                System.debug('requestMap::::::::::::::::::::::::::: ' + JSON.serializePretty(requestMap));
                Map<String,Opportunity> mapObject =  requestMap[0];
                String apiName = null;
                Opportunity oppObject = new Opportunity();
                String leadId = null;
                String processInstanceId = null;
                String applicationNumber = null;
                for (String key : mapObject.keySet()) {
                    apiName = key; 
                    oppObject= mapObject.get(key);
                }
                if(null != oppObject){
                    leadId = oppObject.Lead__c;
                    processInstanceId = oppObject.LOS_Id__c;
                    applicationNumber = oppObject.Loan_Application_Number__c;
                    if(null != leadId && !String.isEmpty(leadId)){
                        List<Opportunity> oppMaster = LosUtils.getOportunityDetails(leadId);
                        if(null != oppMaster && oppMaster.size()> 0){
                            
                            //************************ get Acc type details from Co_Applicant__c ****************************************
                            
                            if(null != applicantAccType && null != applicantAccId){
                                
                                // hard code for appicant only
                                String accType = applicantAccType;
                                String accId = applicantAccId;
                                
                                DateTime now  = DateTime.now();
                                Integer interval = 10 ;
                                DateTime nextRunTime = now.addSeconds(interval);
                                String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
                                    nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + 
                                    nextRunTime.month() + ' ? ' + nextRunTime.year();                               
                                 
                            
                            } else {
                                System.debug(LOSConstants.ERROR_COAPPLICANT_OBJECT_IS_EMPTY+leadId);
                            }                            
                        } else {
                            System.debug(LOSConstants.ERROR_OPPORTUNATY_OBJECT_IS_EMPTY +leadId);
                        }                        
                    } else {
                        System.debug(LOSConstants.ERROR_LEAD_OBJECT_IS_EMPTY);
                    }    
                } else {
                    System.debug(LOSConstants.ERROR_LEAD_OBJECT_IS_EMPTY);
                }  
            } else {
                System.debug(LOSConstants.ERROR_OPPORTUNATY_OBJECT_IS_EMPTY1);
            }  
        } catch(Exception e) {
            System.debug('Exception is :: '+e.getCause());
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
        // future use
    }
    
}