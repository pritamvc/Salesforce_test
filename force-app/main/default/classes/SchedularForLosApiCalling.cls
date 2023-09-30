/*
* 
* @author          Aasim shaikh, Dhanaji Patil
* @description     This scheduler is used to call Los api except create work item and data transfer.
* @Request         methodName, processInstanceId, leadId, accountId, accType
* @return          No return any value 
* @date            15/03/2023    
* 
*/
global class SchedularForLosApiCalling implements Schedulable  {
    
    public String methodName;
    public Opportunity opp;
    public Co_Applicant__c coApp;
    public String accountId;
    public String accType;
    public List<Map<String, Object>> leadDetailsModel;
   
    // constructor
    public SchedularForLosApiCalling(String methodName, Opportunity opp, Co_Applicant__c coApp) {
        this.methodName = methodName; 
        this.opp = opp;    
        this.coApp = coApp;
        
        this.accountId = coApp.Account__c;
        this.accType = coApp.Type__c;
    }
    
    global void execute(SchedulableContext sc) {
        try {  
            
            //Return payload based on methodname
            leadDetailsModel =  LosImplementation.callingDynamicImpl(methodName, opp, coApp);
            
            if(leadDetailsModel.size() > 0) {
                APIConfiguration__mdt apiConfig = [SELECT Label, QualifiedApiName, ApiEndPoint__c, RequestMethod__c, 
                                                   RequestTimeout__c  from APIConfiguration__mdt where QualifiedApiName=:methodName];
                
                for(Map<String, Object> addMap : leadDetailsModel) {
                    String endpoint = 'callout:LOS_API' + apiConfig.ApiEndPoint__c;
                    List<Map<String, Object>> newList = new List<Map<String, Object>>();
                    newList.add(addMap);
                    BatchForLosApiCallingInBulk callToLos = new BatchForLosApiCallingInBulk(endpoint, opp, accountId, methodName, newList);
                    if(methodName.equalsIgnoreCase(CommonConstant.IMMOVABLE_API_NAME) || methodName.equalsIgnoreCase(CommonConstant.MOVABLE_API_NAME)) {
                        String collateralType = null; 
                        Double assetValue = null;
                        
                        collateralType = addMap.get('COLL_TYPE').toString();
                        if(addMap.containsKey('AMOUNT')) {
                            assetValue = (Double) addMap.get('AMOUNT');
                        } else if(addMap.containsKey('MARKET_VALUE')) {
                            assetValue = (Double)addMap.get('MARKET_VALUE');
                        }
                        
                        Asset applicantAsset = [select id, Security_Offered__c, Collateral_Type__c from Asset where Collateral_Type__c =:collateralType and 
                                                Asset_Value__c =:assetValue and AccountId =:accountId and  Lead__c =:opp.Lead__c];
                        String isSecurityOffered = applicantAsset.Security_Offered__c;
                        
                        if(isSecurityOffered.equalsIgnoreCase('Yes')) {
                            List<Collateral_Types_Based_on_LOS_API__mdt> isValidCollateral = [Select ApiName__c, CollateralType__c, id  from Collateral_Types_Based_on_LOS_API__mdt
                                                                                              where ApiName__c =:methodName and CollateralType__c =:collateralType];
                            if(isValidCollateral.size() > 0) {
                                Database.executeBatch(callToLos,1);
                                Id jobId = sc.getTriggerId();
                                System.abortJob(jobId);
                            } else {
                                Id jobId = sc.getTriggerId();
                                System.abortJob(jobId);
                                System.debug('Job Ended for: '+ methodName);
                            }
                        } else {
                            Id jobId = sc.getTriggerId();
                            System.abortJob(jobId);
                            System.debug('Security is not offered for account Id: ' + accountId + '. For asset record id: ' + applicantAsset.Id);
                        }
                    } 
                    else {
                        Database.executeBatch(callToLos,1);
                        Id jobId = sc.getTriggerId();
                        System.abortJob(jobId);
                        System.debug('Job Ended for: '+ methodName);
                    }                
                }            
            }else{
                System.debug('No Data collected for leadId : '+ opp.Lead__c);
            }  
        } catch(Exception e) {
            e.getStackTraceString();
            System.debug('Exception in SchedularForLosApiCalling execute ::::: ' + e.getMessage() +'. At line no.- ' + e.getLineNumber());
            LosImplementation.trackException(opp, e.getMessage());
        }
    }
    
}