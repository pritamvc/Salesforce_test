/*
* 
* @author          Aasim shaikh, Dhanaji Patil
* @description     This scheduler is used to call Los api except create work item and data transfer.
* @Request         methodName, processInstanceId, leadId, accountId, accType
* @return          No return any value 
* @date            15/03/2023    
* @param
*/
global class SchedularLOSDealDataSync implements Schedulable  {
    
    private String methodName;
    private LosApiMaster__c apiMaster;
    private Opportunity opp;
    private Co_Applicant__c coApp;
    private String accountId;
    private String accType;
    private List<Map<String, Object>> leadDetailsModel;
   
    /*
    * @author          Sohail Solapure
    * @description     constructor
    * @return          No return any value 
    * @param    
    */
    public SchedularLOSDealDataSync (LosApiMaster__c apiMaster, Opportunity opp, Co_Applicant__c coApp) {
        this.apiMaster = apiMaster; 
        this.opp = opp;    
        this.coApp = coApp;
        
        this.accountId = coApp.Account__c;
        this.accType = coApp.Type__c;
        this.methodName = apiMaster.ApiName__c;
    }
    
    /*
    * @author          Sohail Solapure
    * @description     exeute method
    * @return          No return any value 
    * @param    
    */
    global void execute(SchedulableContext sc) {
        try {              
            //Return payload based on methodname
            leadDetailsModel = new List<Map<String, Object>>();
            if(methodName != LOSConstants.EXAM_SCORE_API_NAME){
            	leadDetailsModel = LosImplementation.callingDynamicImpl(apiMaster, opp, coApp);
            }
            else{
                leadDetailsModel = LOSHTTPUtils.getDynamicLosMappingForExamScore(opp.Lead__c,accountId,apiMaster.Id,0);
                leadDetailsModel.addAll(LOSHTTPUtils.getDynamicLosMappingForExamScore(opp.Lead__c,accountId,apiMaster.Id,1));
            } 
            
            if(leadDetailsModel.size() > 0) {
                APIConfiguration__mdt apiConfig = [SELECT Label, QualifiedApiName, ApiEndPoint__c, RequestMethod__c, 
                                                   RequestTimeout__c  from APIConfiguration__mdt where QualifiedApiName=:methodName];
                
                for(Map<String, Object> addMap : leadDetailsModel) {
                    String endpoint = LOSConstants.ENDPOINT + apiConfig.ApiEndPoint__c;
                    List<Map<String, Object>> newList = new List<Map<String, Object>>();
                    newList.add(addMap);
                    BatchLOSDealDataSync callToLos = new BatchLOSDealDataSync(endpoint, opp, accountId, methodName, newList);
                    if(methodName.equalsIgnoreCase(LOSConstants.IMMOVABLE_API_NAME) || methodName.equalsIgnoreCase(LOSConstants.MOVABLE_API_NAME)) {
                        String collateralType = null; 
                        Double assetValue = null;
                        
                        collateralType = addMap.get(LOSConstants.COLL_TYPE).toString();
                        if(addMap.containsKey(LOSConstants.AMOUNT)) {
                            assetValue = (Double) addMap.get(LOSConstants.AMOUNT);
                        } else if(addMap.containsKey(LOSConstants.MARKET_VALUE)) {
                            assetValue = (Double)addMap.get(LOSConstants.MARKET_VALUE);
                        }
                        
                        Asset applicantAsset = [select id, Security_Offered__c, Collateral_Type__c from Asset where Collateral_Type__c =:collateralType and 
                                                Asset_Value__c =:assetValue and AccountId =:accountId and  Lead__c =:opp.Lead__c];
                        String isSecurityOffered = applicantAsset.Security_Offered__c != null ? applicantAsset.Security_Offered__c : LOSConstants.SECURITY_NO ;
                        
                        if(isSecurityOffered.equalsIgnoreCase(LOSConstants.SECURITY_Yes)) {
                            List<Collateral_Types_Based_on_LOS_API__mdt> isValidCollateral = [Select ApiName__c, CollateralType__c, id  from Collateral_Types_Based_on_LOS_API__mdt
                                                                                              where ApiName__c =:methodName and CollateralType__c =:collateralType];
                            if(isValidCollateral.size() > 0) {
                                Database.executeBatch(callToLos,1);                                
                            } 
                        } 
                    } 
                    else {
                        Database.executeBatch(callToLos,1);                       
                    }                
                }            
            } 
            Id jobId = sc.getTriggerId();
            System.abortJob(jobId);
        } catch(Exception e) {
            e.getStackTraceString();
            System.debug('Exception in SchedularLOSDealDataSync execute ::::: ' + e.getMessage() +'. At line no.- ' + e.getLineNumber());
            LosImplementation.trackException(opp, e.getMessage(), accountId);
        }
    }
    
}