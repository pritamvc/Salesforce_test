/**
* Author: Dhanaji Patil
* @description This scheduler is used to call the Data Transfer API.
* @date 08/03/2023
*/
public class SchedulerForDataTransferAPICalling implements Schedulable {
    private Id ids;
    /**
     * Author: Sohail Solapure
     * @description Constructor for initializing the scheduler with an Opportunity.
     * @param ids Opportunity ids to be processed.
     */
    public SchedulerForDataTransferAPICalling(Id ids) {
        this.ids = ids;
    }

    /**
     * Author: Sohail Solapure
     * @description Executes the scheduled job. This method will be called by the scheduler.
     * @param sc The context of the scheduler.
     */
    public void execute(SchedulableContext sc) {
        try {
            String apiName = LOSConstants.DATA_TRANSFER_API_NAME; 
            
            //Collect all opportunities whose LOS Sync is false 
            List<Opportunity> opportunityDataToSync = [SELECT Id,LOS_Sync__c,Lead__c from Opportunity WHERE LOS_Sync__c =: LOSConstants.LOS_FALSE AND Id =: ids];
            
            //Get Lead Ids from Opportunities
            List<String> leadIds = new List<String>();
            for(Opportunity currOpp : opportunityDataToSync){
                leadIds.add(currOpp.Lead__c);
            }

            //Collect all the tracker details 
            List<Tracker__c> trackerTempList = [SELECT Id,Lead__c,ApiName__c,Status__c from Tracker__c WHERE Lead__c != null AND Lead__c IN :leadIds/* AND Status__c =: LOSConstants.LOS_SUCCESS*/];
            
            //Delete the tracker where APiName is same
            Map<String,List<Tracker__c>> trackerTempMap = new Map<String,List<Tracker__c>>();
            Map<String,List<Tracker__c>> trackerTempMapFinal = new Map<String,List<Tracker__c>>();
            List<Tracker__c> deleteTracker = new List<Tracker__c> ();

            //Iterate where tracker is not null
            if(null != trackerTempList && trackerTempList.size() > 0){
                trackerTempMap = addTrackerToMap(trackerTempList);
            }
            //Iterate the tracker list to remove duplicate records with same apiName
            for (String mapKey : trackerTempMap.keySet()){

                //Create temp object to store Tracker
                List<Tracker__c> tempTracker = trackerTempMap.get(mapKey); 
                List<Tracker__c> tempTrackerToDelete = findDuplicateTracker(tempTracker);

                if(tempTrackerToDelete.size() > 0){
                    deleteTracker.addall(deleteTracker(tempTrackerToDelete));
                }
            }

            //If have dupliacte then delete the record
            if(deleteTracker.size() > 0){
                delete deleteTracker;
            }
            
            List<Tracker__c> trackerTempListFinal = [SELECT Id,Lead__c,ApiName__c,Status__c from Tracker__c WHERE Lead__c != null AND Lead__c IN :leadIds AND Status__c =: LOSConstants.LOS_SUCCESS];
            //Iterate where tracker is not null
            if(null != trackerTempListFinal && trackerTempListFinal.size() > 0) {  
                trackerTempMapFinal = addTrackerToMapasLead(trackerTempListFinal);
            }
            
            //Fetch the asset records to check the api for movable/immovable
            List<Asset> assetList = [Select Id,Asset_Type__c,Collateral_Type__c,Security_Offered__c,Lead__c from Asset where Lead__c In :leadIds AND Collateral_Type__c != null];
            Map<String,List<Asset>> assetMap = new Map<String,List<Asset>>();

            for(Asset currAsset: assetList){
                String leadId = currAsset.Lead__c;
                if (assetMap.containsKey(leadId)) {
                    // Lead ID already exists in the map, add the current asset to the existing list
                    List<Asset> existingAssets = assetMap.get(leadId);
                    existingAssets.add(currAsset);
                } 
                else {
                    // Lead ID doesn't exist in the map, create a new list and add the asset to it
                    List<Asset> newAssets = new List<Asset>();
                    newAssets.add(currAsset);
                    assetMap.put(leadId, newAssets);
                }
            }

            //Get all asset records and add to map to check the count
            Map<String,List<Asset>> assetMapForCount = new Map<String,List<Asset>>();
            List<Asset> assetRecords = [SELECT Id,Asset_Type__c,Lead__c FROM Asset WHERE Lead__c IN :leadIds AND Asset_Type__c != null];
            for (Asset asset : assetRecords) {
                if (!assetMapForCount.containsKey(asset.Lead__c)) {
                    assetMapForCount.put(asset.Lead__c, new List<Asset>());
                }
                assetMapForCount.get(asset.Lead__c).add(asset);
            }
            
            //Get all liability records and add to map to check the count
            Map<String,List<Liability__c>> liabilityMapForCount = new Map<String,List<Liability__c>>();
            List<Liability__c> liablityRecords = [SELECT Id,Lead__c FROM Liability__c WHERE Lead__c IN :leadIds];
            for(Liability__c lia : liablityRecords){
                if (!liabilityMapForCount.containsKey(lia.Lead__c)) {
                    liabilityMapForCount.put(lia.Lead__c, new List<Liability__c>());
                }
                liabilityMapForCount.get(lia.Lead__c).add(lia);
            }
            
            //List of leadIds to data transfer
            List<String> finalLeadIdList = new List<String>();
            
            //Create final list for calling data transfer API 
            List<String> apiExcludeList = new List<String>();
            apiExcludeList.add(LOSConstants.DATA_TRANSFER_API_NAME);
            apiExcludeList.add(LOSConstants.MOVABLE_API_NAME);
            apiExcludeList.add(LOSConstants.IMMOVABLE_API_NAME);
            apiExcludeList.add(LOSConstants.ASSET_API_NAME);
            apiExcludeList.add(LOSConstants.LIABILITY_API_NAME);

            //Get the API count
            Integer totalApiCount = [select count() from LosApiMaster__c where Active__c = true and ApiName__c not in:apiExcludeList];
            List<String> movableValues = new List<String>();
            List<String> immovableValues = new List<String>();
            
            //Get Collateral Values with its type movable/immovabe
            List<Collateral_Types_Based_on_LOS_API__mdt> collateralTypes = [SELECT ApiName__c, CollateralType__c FROM Collateral_Types_Based_on_LOS_API__mdt];
            for(Collateral_Types_Based_on_LOS_API__mdt currRecord : collateralTypes){
                if(currRecord.ApiName__c == LOSConstants.MOVABLE_API_NAME){
                    movableValues.add(currRecord.CollateralType__c);
                }
                if(currRecord.ApiName__c == LOSConstants.IMMOVABLE_API_NAME){
                    immovableValues.add(currRecord.CollateralType__c);
                }
            }
            
            //Itearte to check the API count
            for (String mapKey : trackerTempMapFinal.keySet()){
                Integer currCount = totalApiCount;
                
                //Create temp object to store Tracker and Asset
                List<Tracker__c> tempTracker = trackerTempMapFinal.get(mapKey); 
                List<Asset> tempAsset = assetMap.get(mapKey);
                List<Asset> tempAsset1 = assetMapForCount.get(mapKey);
                List<Liability__c> tempLiability = liabilityMapForCount.get(mapKey);
              
                //Iterate over the list 
                if(null != tempTracker && tempTracker.size() > 0) {
                    //For immovable/movable collateral
                    if(tempAsset != null){
                        Boolean movFlag = false;
                        Boolean imovFlag = false;
                        for(Asset currAsset : tempAsset){
                            if(currAsset.Collateral_Type__c != null){
                                //For Movable
                                if(movableValues.contains(currAsset.Collateral_Type__c)){
                                    if(movFlag == false){
                                        currCount++;
                                        movFlag = true;
                                    }
                                }
                                //For Immovable
                                if(immovableValues.contains(currAsset.Collateral_Type__c)){
                                    if(imovFlag == false){
                                        currCount++;
                                        imovFlag = true;
                                    }
                                }
                            }
                        }
                    }
                    
                    //For Assets
                    if(tempAsset1 != null){
                        currCount++;
                    }
                    
                    //For Liability
                    if(tempLiability != null){
                        currCount++;
                    }
                    
                    //If the tracker size is greater then api count then add lead Id
                    if(tempTracker.size() >= currCount){
                        finalLeadIdList.add(mapKey);
                    }
                }
                else {
                    System.debug(LOSConstants.LEADS_TRACKER_EMPTY+ tempTracker.size());
                }
            }
            
            //Calling to data transfer 
            if(null != finalLeadIdList && finalLeadIdList.size()>0) {
                List<Opportunity> oppMaster = getOpportunityList(finalLeadIdList);
                if(null != oppMaster && oppMaster.size() > 0) {
                    for(Opportunity oppObject : oppMaster) {
                        if(oppObject.LOS_Sync__c == false) {
                            Database.executeBatch(new BatchForDataTransferAPICalling(apiName, oppObject));
                        } else {
                            System.debug(LOSConstants.LOS_SYNC + oppObject.Lead__c);
                        }
                        
                    }
                }
                else{
                    System.debug(LOSConstants.OPP_EMPTY);
                }
            }
            else{
                System.debug(LOSConstants.LEAD_EMPTY);
            }
            
            System.abortJob(sc.getTriggerId());
            
        } catch(Exception e) 
        {
            System.debug(LOSConstants.LOS_SCHEDULER_EXCEPTION + e.getMessage() + LOSConstants.QUERY_EXCEPTION_LINE + e.getLineNumber());
        }
    }
    
    /**
     * Author: Sohail Solapure
     * @description Returns a list of Opportunity objects based on the provided lead IDs.
     * @param leadIdList A list of lead IDs for which to retrieve opportunities.
     * @return          A list of Opportunity objects related to the provided lead IDs.
     */
    public static List<Opportunity> getOpportunityList (List<String> leadIdList){
        List<Opportunity> oppMasterObj = new List<Opportunity>();
        if(null != leadIdList && leadIdList.size() > 0) {
            oppMasterObj = LosUtils.getOportunityListDetails(leadIdList);
        }
        return oppMasterObj; 
    }

    /**
     * Author: Sohail Solapure
     * @description Returns a list of Opportunity objects based on the provided lead IDs.
     * @param trackerDeleteList  A list of Tracker__c records to be deleted.
     * @return List<Tracker__c>  A list of Opportunity objects related to the provided lead IDs.
     */
    public static List<Tracker__c> deleteTracker(List<Tracker__c> trackerDeleteList){
        Set<String> apiNames = new Set<String>();
        Boolean allSuccess = false;
        Integer failureCount = 0;
        Integer successCount = 0;

        List<Tracker__c> deleteDupTrackerList = new List<Tracker__c>();    
        List<Tracker__c> failureRecord = new List<Tracker__c>();
        List<Tracker__c> successRecord = new List<Tracker__c>();

        //Iterate over the tempTrackerToDelete list and check conditions
        for (Tracker__c tracker : trackerDeleteList) {
            apiNames.add(tracker.ApiName__c);
            if (tracker.Status__c.equalsIgnoreCase('Success')) {
                allSuccess = true;
                successCount++;
                successRecord.add(tracker);
            }
            else{
                failureCount++;
                failureRecord.add(tracker);
                allSuccess = false;
            }
        }

        // Delete the duplicate records if all conditions are met
        if (apiNames.size() == 1 && successCount > 0 && allSuccess) {
            for (Integer i = trackerDeleteList.size() - 1; i > 0; i--) {
                deleteDupTrackerList.add(trackerDeleteList[i]);
            }
        }
        else if(failureCount > 0 && failureRecord != null && successRecord != null && successCount > 0){
            if(failureRecord.size() > 1){
                for(Integer i=failureRecord.size()-1;i>0;i--){
                    deleteDupTrackerList.add(failureRecord[i]);  
                } 
            }

            if(successRecord.size() > 0){
               deleteDupTrackerList.addall(successRecord);
            }
        }
        else if(failureCount > 0 && failureRecord != null){
            if(failureRecord.size() > 1){
                for(Integer i=failureRecord.size()-1;i>0;i--){
                    deleteDupTrackerList.add(failureRecord[i]);
                }
            }
        }
        return deleteDupTrackerList;
    }

    /**
     * Author: Sohail Solapure
     * @description Method to add trackers list in map at related apiNames
     * @param trackerList Trackers to delete.
     * @return Map<String,List<Tracker__c>> 
     */
    public Map<String,List<Tracker__c>> addTrackerToMap(List<Tracker__c> trackerList){
        Map<String,List<Tracker__c>> trackerTempMap = new Map<String,List<Tracker__c>>();
        
        for(Tracker__c trackerTempObj : trackerList) {
            List<Tracker__c> mapList = new List<Tracker__c>();
            mapList.add(trackerTempObj);
            if(trackerTempMap.containsKey(trackerTempObj.ApiName__c)){
                mapList.addall(trackerTempMap.get(trackerTempObj.ApiName__c));
                trackerTempMap.put(trackerTempObj.ApiName__c, mapList);
            }else{                    
                trackerTempMap.put(trackerTempObj.ApiName__c, mapList);
            }   
        }     
        return trackerTempMap;
    }

    /**
     * Author: Sohail Solapure
     * @description  Method to add trackers list in map at related lead id
     * @param trackerList trackerlist to add in map
     * @return Map<String,List<Tracker__c>> 
     */
    public static Map<String,List<Tracker__c>> addTrackerToMapasLead(List<Tracker__c> trackerList){
        Map<String,List<Tracker__c>> trackerTempMap = new Map<String,List<Tracker__c>>();
        
        for(Tracker__c trackerTempObj : trackerList) {
            List<Tracker__c> mapList = new List<Tracker__c>();
            mapList.add(trackerTempObj);
            if(trackerTempMap.containsKey(trackerTempObj.Lead__c)){
                mapList.addall(trackerTempMap.get(trackerTempObj.Lead__c));
                trackerTempMap.put(trackerTempObj.Lead__c, mapList);
            }else{                    
                trackerTempMap.put(trackerTempObj.Lead__c, mapList);
            }   
        }     
        return trackerTempMap;
    }

    /**
     * Author: Sohail Solapure
     * @description Method to find the duplicates tracker records with same apiNames
     * @param tempTracker A list of lead IDs for which to retrieve opportunities.
     * @return List<Tracker__c>
     */
    public static List<Tracker__c> findDuplicateTracker(List<Tracker__c> tempTracker){
        List<Tracker__c> tempTrackerToDelete = new List<Tracker__c>();
        //Create a map to store the count of each apiname
        Map<String, Integer> apinameCountMap = new Map<String, Integer>();
                
        //Count the occurrences of each apiname
        for (Tracker__c tracker : tempTracker) {
            String currApiName = tracker.ApiName__c;
            if (apinameCountMap.containsKey(currApiName)) {
                apinameCountMap.put(currApiName, apinameCountMap.get(currApiName) + 1);
            } else {
                apinameCountMap.put(currApiName, 1);
            }
        }

        //Delete the trackers with duplicate apiname
        for (String currApiname : apinameCountMap.keySet()) {
            Integer count = apinameCountMap.get(currApiname);
            if (count > 1) {
                for (Integer i = tempTracker.size() - 1; i >= 0; i--) {
                    if (tempTracker[i].ApiName__c.equals(currApiname) && count > 1) {
                        tempTrackerToDelete.add(tempTracker[i]);
                    }
                }
            }
        }
        return tempTrackerToDelete;
    }

    /*private Integer getApiCount(String leadId) {
        Integer count = 0;
        Integer applicantCount = [select count()  from Co_Applicant__c where Lead__c =:leadId and Type__c =: LOSConstants.APPLICANT];
        Integer coApplicantCount = [select count()  from Co_Applicant__c where Lead__c =:leadId and Type__c !=: LOSConstants.APPLICANT];
        
        List<String> apiExcludeList = new List<String>();
        apiExcludeList.add(LOSConstants.WORK_ITEM_API_NAME);
        apiExcludeList.add(LOSConstants.DATA_TRANSFER_API_NAME);
        
        if(applicantCount != 0) {
            Integer apiCount = [select count()  from LosApiMaster__c where Active__c = true and ApiName__c not in:apiExcludeList];
            count = applicantCount * apiCount;
        }
        if(coApplicantCount != 0) {
            Integer apiCount = [select count()  from LosApiMaster__c where Active__c = true and ApiName__c not in:apiExcludeList and ForCoApplicant__c = true];
            count = applicantCount * apiCount;
        }
        count = count + 1; // Adding one extra count for create work item.
        return count;
    }*/
}