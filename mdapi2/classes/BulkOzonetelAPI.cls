/**
 * Author: Dhanaji Patil
 * Description: BulkOzonetelAPI class is used to create payload and call the Ozontel API to add leads.
 * 
 * This class takes a list of lead IDs as input and constructs the necessary payload for adding leads using
 * the Ozontel API. The actual API call is made to Ozontel to add the leads.
 * 
 * @param requestIds A list of lead IDs to retrieve lead details for the Ozontel API call.
 * @return This method does not return any value.
 * @description 
 * @date 17/03/2023
 */
public class BulkOzonetelAPI{
    
    public static String methodType = '';
    public static Integer methodTimeout = 0;
    
    /**
     * Author: Sohail Solapure
     * Description: Method to push data to Ozonetel.
     * 
     * This method is responsible for pushing data, associated with a set of Campaign Member IDs,
     * to the Ozonetel system. The data is prepared and sent using the Ozonetel API for processing.
     * @description
     * @param setCampaignmemberId A set of Campaign Member IDs for which data needs to be pushed to Ozonetel.
     */
    public static void pushDataToOzontel(Set<Id> setCampaignmemberId){
        //Created a map of Campaign Name And Campaign Maember
        Map<String,List<Id>> mapCampaignNameAndCampaignMaemberId = createMapOfCampNameAndCamMemberId(setCampaignmemberId);
        
        for(String key: mapCampaignNameAndCampaignMaemberId.keySet()){
            makeDataAndCallingToOzontel(key,mapCampaignNameAndCampaignMaemberId); 
        }
    }
    
    /**
     * Author: Sohail Solapure
     * Description: Method to make data and initiate a call to Ozonetel.
     * 
     * This method is responsible for creating the necessary data and initiating a call to the Ozonetel system.
     * The provided key and map are used to construct data for the Ozonetel API call, which is then executed.
     * 
     * @param key The key used for data processing.
     * @param mapCampaignNameAndCampaignMaemberId A map containing campaign names as keys and lists of Campaign Member IDs as values.
     */
    public static void makeDataAndCallingToOzontel(String key,Map<String,List<Id>> mapCampaignNameAndCampaignMaemberId) {
        //Get final Endpoints
        String finalEndpoint = generateApiUrlForPost(key,mapCampaignNameAndCampaignMaemberId);
        //Call To ozontel with details
        
        if(null != finalEndpoint && !String.isEmpty(finalEndpoint)){
            if(!System.isFuture() && !System.isBatch()){
                callOut(finalEndpoint,methodType,methodTimeout);
            }else{
                callOutWithoutFuture(finalEndpoint,methodType,methodTimeout);
            }
            Set<Id> cmIds = new Set<Id>();
            for (Id acc : mapCampaignNameAndCampaignMaemberId.get(key)) 
            {
                cmIds.add(acc);
            }
            if(null != cmIds && cmIds.size()>0){
                List<CampaignMember> cmList = new List<CampaignMember>();
                cmList = [SELECT Id,Lead.id,Is_Ozontel_Sync__c FROM CampaignMember WHERE Type='Lead' AND MobilePhone != '' and Is_Ozontel_Sync__c =false AND id IN :cmIds ];
                for(CampaignMember campObj : cmList){
                    campObj.Is_Ozontel_Sync__c = true;
                }
                update cmList;
            }
        }
    }
    
    /**
     * Author: Sohail Solapure
     * Description: Method to generate an API URL for POST request.
     * 
     * This method is responsible for generating a URL that will be used for making a POST request to an API.
     * The provided key and map are used to construct the URL based on the API's requirements and the provided data.
     *
     * @param key The key used for URL generation.
     * @param mapCampaignNameAndCampaignMemberId A map containing campaign names as keys and lists of Campaign Member IDs as values.
     * @return A string containing the generated API URL for the POST request.
     */
    public static String generateApiUrlForPost(String key,Map<String,List<Id>> mapCampaignNameAndCampaignMaemberId){
        try{
            String campaignName = key;
            Set<Id> cmIds = new Set<Id>();
            
            
            for (Id acc : mapCampaignNameAndCampaignMaemberId.get(key)) {
                cmIds.add(acc);
            }
            
            // Collect Ozontel Api Deails
            Ozontel_API_Configuration_Detail__mdt ozontelApiConfigDetails = callectOzontelApiConfigration(CommonConstant.PUSH_TO_OZONTEL);
            
            methodType = ozontelApiConfigDetails.RequestMethod__c;
            methodTimeout = Integer.valueOf(ozontelApiConfigDetails.RequestTimeout__c);
            
            // TO create a final data url for post
            String finalEndpoint = createFinalUrlToCallOzontel(ozontelApiConfigDetails.ApiKey__c,ozontelApiConfigDetails.ApiEndPoint__c,ozontelApiConfigDetails.UserName__c,campaignName,cmIds);
            return finalEndpoint;
        }catch(System.Exception e){
            e.getMessage();
        }
        return null;
    }
    
    /**
     * Author: Sohail Solapure
     * Description: Method to create the final URL for calling Ozonetel.
     * 
     * This method is responsible for creating the final URL that will be used to call the Ozonetel API.
     * The provided parameters, such as the API key, API URL, username, campaign name, and Campaign Member IDs,
     * are used to construct the URL based on the API's requirements and the provided data.
     * 
     * @param apikey The API key required for authentication.
     * @param apiUrl The base URL of the Ozonetel API.
     * @param username The username associated with the API call.
     * @param campaignName The name of the campaign for which the API call is being made.
     * @param cmIds A set of Campaign Member IDs used for the API call.
     * @return A string containing the final URL for calling the Ozonetel API.
     * 
     */
    public static String createFinalUrlToCallOzontel(String apikey, String apiUrl, String username, String campaignName,Set<Id> cmIds) {
        
        // Collect CampaignMember details
        List<CampaignMember> cmList = new List<CampaignMember>();
        cmList = [SELECT Id,Lead.id,Lead.Name,name,FirstName,LastName,Type,MobilePhone,Campaign.name,CampaignId,Campaign.Priority__c,Campaign.Skill__c,Campaign.Parent.name FROM CampaignMember WHERE Type='Lead' AND MobilePhone != '' and Is_Ozontel_Sync__c =false AND id IN :cmIds ];
        if(null != cmList && cmList.size()>0) {
            String url =apiUrl+System.Label.ActionForOzontel+'=&'+System.Label.ApiKeyLebalForOzontel+'='+apikey+'&'+System.Label.UserNameLebalForOzontel+'='+username+'&'+System.Label.CheckDuplicateLebalForOzontel+'=true&'+System.Label.CampaignNameLebalForOzontel+'='+campaignName;
            
            String urlEnd=']}';
            String bulkData ='&bulkData={"map":["PhoneNumber","Name","LeadLASTName","ScheduledTime","Skill","AgentID","Priority"],"data":[';
            String strbulkData ;
            try{
                //Making the dynamic bulk data for post lead details to ozontel
                
                for (CampaignMember obj: cmList){
                    if(strbulkData == Null || String.isBlank(strbulkData)){
                        strbulkData = '["'+obj.MobilePhone+'","'+obj.FirstName+'","'+obj.LastName+'","'+''+'","'+obj.Campaign.Skill__c+'","'+''+'","'+String.valueOf(obj.Campaign.Priority__c)+'"]';
                    }
                    else{
                        strbulkData = strbulkData+',["'+obj.MobilePhone+'","'+obj.FirstName+'","'+obj.LastName+'","'+''+'","'+obj.Campaign.Skill__c+'","'+''+'","'+String.valueOf(obj.Campaign.Priority__c)+'"]';
                    }
                }
                
            }catch(System.Exception e){
                e.getMessage();
            }
            
            String finalEndpoint =url+bulkData+strbulkData+urlEnd;
            return finalEndpoint;
        }
        return null;
    } 
    
    /**
     * Author: Sohail Solapure
     * Description: Method to send a callout request asynchronously.
     * 
     * This method is responsible for sending a callout request to a specified endpoint asynchronously.
     * The provided parameters, such as the final endpoint, method type (GET, POST, etc.), and timeout value,
     * are used to configure and perform the callout to the external system.
     *
     * @param finalEndpoint The final endpoint URL to which the callout request will be sent.
     * @param methodType The HTTP method type to be used for the callout (GET, POST, etc.).
     * @param timeOut The timeout value (in milliseconds) for the callout request.
     * 
     */
    @future(callout=true)
    public static void callOut(String finalEndpoint,String methodType, Integer timeOut){
        try{
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http = new Http();
            
            request.setMethod(methodType);
            request.setTimeout(timeOut);
            request.setEndpoint(finalEndpoint.replace(' ', '%20'));
            response=http.send(request);
        }catch(System.Exception e){
            e.getMessage();
        } 
    }
    
    /**
     * Author: Sohail Solapure
     * Description: Method to send a callout request synchronously.
     * 
     * This method is responsible for sending a callout request to a specified endpoint synchronously.
     * The provided parameters, such as the final endpoint, method type (GET, POST, etc.), and timeout value,
     * are used to configure and perform the callout to the external system.
     * 
     * @param finalEndpoint The final endpoint URL to which the callout request will be sent.
     * @param methodType The HTTP method type to be used for the callout (GET, POST, etc.).
     * @param timeOut The timeout value (in milliseconds) for the callout request.
     * 
     */
    public static void callOutWithoutFuture(String finalEndpoint,String methodType, Integer timeOut){
        try{
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http = new Http();
            
            request.setMethod(methodType);
            request.setTimeout(timeOut);
            
            request.setEndpoint(finalEndpoint.replace(' ', '%20'));
            response=http.send(request);
        }catch(System.Exception e){
            e.getMessage();
        } 
    }
    
    /**
     * Author: Sohail Solapure
     * Description: Method to push data to Ozonetel in batch.
     * 
     * This method is responsible for pushing data to the Ozonetel system in a batch manner.
     * The provided set of Campaign Member IDs is used to determine the data to be pushed,
     * and the data is processed and sent to Ozonetel using the Ozonetel API.
     *
     * @param setCampaignmemberId A set of Campaign Member IDs for which data needs to be pushed to Ozonetel.
     * 
     */
    public static void pushDataToOzontelfotBatch(Set<Id> setCampaignmemberId){
        //Created a map of Campaign Name And Campaign Maember
        Map<String,List<Id>> mapCampaignNameAndCampaignMaemberId = createMapOfCampNameAndCamMemberId(setCampaignmemberId);
        
        for(String key: mapCampaignNameAndCampaignMaemberId.keySet()){
            makeDataAndCallingToOzontel(key,mapCampaignNameAndCampaignMaemberId);
        } 
    }
    
    /**
     * Author: Sohail Solapure
     * Description: Method to return configuration details by API name.
     * 
     * This method is responsible for retrieving configuration details for a specific Ozonetel API by its name.
     * The provided API name is used to identify the configuration details associated with that API,
     * and the corresponding configuration detail records are returned.
     * 
     * @param apiName The name of the Ozonetel API for which configuration details are to be retrieved.
     * @return An instance of the Ozontel_API_Configuration_Detail__mdt metadata type containing the configuration details.
     * 
     */
    public static Ozontel_API_Configuration_Detail__mdt callectOzontelApiConfigration(String apiName){
        Ozontel_API_Configuration_Detail__mdt ozontelApiConfigDetails =null;
        try{
            ozontelApiConfigDetails = [select id, ApiName__c, ApiEndPoint__c, ApiKey__c, UserName__c, RequestMethod__c, RequestTimeout__c from Ozontel_API_Configuration_Detail__mdt where ApiName__c = :apiName];
        }catch(System.Exception e){
            e.getMessage();
        } 
        return ozontelApiConfigDetails;
    }
    
    /**
     * Author: Sohail Solapure
     * Description: Invocable method for Bulk Ozonetel API Flow.
     * 
     * This method is an invocable method designed to be used in process automation, such as flows.
     * It is responsible for receiving a list of campaign IDs and performing a Bulk Ozonetel API operation.
     * The provided campaign IDs are used as input, and the method performs the required operations
     * for the Bulk Ozonetel API flow.
     * 
     * @param campaignId A list of campaign IDs for which the Bulk Ozonetel API operation is to be performed.
     * @return A list of strings containing the result of the Bulk Ozonetel API flow.
     * 
     */
    @InvocableMethod(label='BulkOzonetelAPIFlow' category='Other')
    public static List<String> bulkOzonetelAPIFlow(List<String> campaignId){
        List<String> textList = new List<String> ();
        if(null != campaignId && campaignId.size()>0){
            textList = sendBulkData(campaignId[0]);
        }
        
        return textList;
    }
    
   /**
     * Author: Sohail Solapure
     * Description: Method to send data in bulk.
     * 
     * This method is responsible for sending data in bulk based on the provided campaign ID.
     * The provided campaign ID is used to identify the data to be sent, and the method performs
     * the required operations to send the data in bulk.
     * 
     * @param campId The campaign ID for which bulk data is to be sent.
     * @return A list of strings containing the result of the bulk data sending operation.
     * 
     */
    public static List<String> sendBulkData(string campId)
    {
        List<String> textList = new List<String> ();
        if(null != campId && campId != ''){
            /************************ checking this campaign is parent or chield *******************************/
            List<Campaign> campaignList = [SELECT Id,Name, ParentId, Parent.Name,IsActive,Parent.IsActive FROM Campaign 
                                           WHERE Id = :campId AND IsActive = true];
            if(null != campaignList && campaignList.size()>0){
                if(null != campaignList[0].ParentId && null != campaignList[0].Parent.Name && campaignList[0].Parent.IsActive == true){
                    List<CampaignMember> campMemberIdList = new List<CampaignMember>();
                    List<Id> listOfCampMemberIds = new List<Id>();
                    campMemberIdList = [SELECT Id,Lead.Name FROM CampaignMember WHERE Type='Lead' AND Campaignid = :campId];
                    if(null != campMemberIdList && campMemberIdList.size()>0){
                        for(CampaignMember campMemberObj : campMemberIdList){
                            listOfCampMemberIds.add(campMemberObj.id);
                            campMemberObj.Is_Ozontel_Sync__c = false;
                        }
                        String parentCampName = campaignList[0].parent.Name;
                        setCampaignMemberAndCampaignNameForRepushToOzonetel(parentCampName,listOfCampMemberIds,campMemberIdList,true);
                        //integer size = campMemberIdList.size();
                        textList.add('Lead records pushed to ozonetel successfully !!!');
                    }else{
                        textList.add('Please add Lead details.');
                    }
                }else{
                    /******************** Collect parent and chield campaign Ids *******************/
                    String campaignId = getParentCampaignId(campId);
                    List<String> chieldCampaignIds = getChieldCampaignIds(campaignId);
                    chieldCampaignIds.add(campaignId);
                    
                    if(null != chieldCampaignIds && chieldCampaignIds.size() >0) {
                        List<CampaignMember> campMemberIdList = new List<CampaignMember>();
                        List<Id> listOfCampMemberIds = new List<Id>();
                        campMemberIdList = [SELECT Id,Lead.Name FROM CampaignMember WHERE Type='Lead' AND Campaignid in :(chieldCampaignIds)];
                        
                        // collect listOfCampMemberIds
                        for(CampaignMember campMemberObj : campMemberIdList){
                            listOfCampMemberIds.add(campMemberObj.id);
                            campMemberObj.Is_Ozontel_Sync__c = false;
                        }
                        if(null != campMemberIdList && campMemberIdList.size()>0){
                            List<Campaign> parentCampaignName = [select id,Name from Campaign where id = :campaignId];
                            setCampaignMemberAndCampaignNameForRepushToOzonetel(parentCampaignName[0].Name,listOfCampMemberIds,campMemberIdList,true);
                            //integer size = campMemberIdList.size();
                            textList.add('Lead records pushed to ozonetel successfully !!!');
                        }else{
                            textList.add('Please add Lead details.');
                        }
                    }
                }
            }
        }
        return textList;
    }

    /**
     * Author: Sohail Solapure
     * Description: Method for setting campaign members to repush to Ozonetel.
     * 
     * This method is responsible for setting campaign members to be repushed to Ozonetel.
     * The provided parameters include the parent campaign name, a list of campaign member IDs,
     * a list of campaign member records, and a flag to determine the repush status.
     * The method performs the required operations to update the campaign members and their repush status.
     * 
     * @param parentCampaignName The name of the parent campaign for which members are to be repushed.
     * @param listOfCampMemberIds A list of campaign member IDs to be repushed.
     * @param campMemberIdList A list of CampaignMember records associated with the campaign members.
     * @param flag A boolean flag indicating the repush status (true for repush, false otherwise).
     * 
     */
    public static void setCampaignMemberAndCampaignNameForRepushToOzonetel(String parentCampiagnName,  List<Id> listOfCampMemberIds, List<CampaignMember> campMemberIdList, Boolean flag){
        if(null != parentCampiagnName && listOfCampMemberIds.size()>0){
            //Created a map of Campaign Name And Campaign Member
            Map<String,List<Id>> mapCampaignNameAndCampaignMaemberId = new Map<String,List<Id>>();
            mapCampaignNameAndCampaignMaemberId.put(parentCampiagnName,listOfCampMemberIds);
            
            /************************* calling to create dynamic data method *******************************/
            for(String key: mapCampaignNameAndCampaignMaemberId.keySet()){
                try{
                    if(flag){
                        RepushLeadOzonetelScheduler sch = new RepushLeadOzonetelScheduler(key,mapCampaignNameAndCampaignMaemberId,campMemberIdList);
                        DateTime scheduledTime = DateTime.now().addMinutes(1);
                        String cronExp = '0 ' + scheduledTime.minute() + ' ' + scheduledTime.hour() + ' ' +scheduledTime.day() + ' ' + scheduledTime.month() + ' ? ' + scheduledTime.year();
                        System.schedule('Ozonetel Schedule', cronExp, sch);
                        
                    }
                }catch(System.Exception e){
                    e.getMessage();
                }
            } 
        }
    }
    
    /**
     * Author: Sohail Solapure
     * Description: Method for scheduling the batch job to repush campaign members to Ozonetel.
     * 
     * This method is responsible for scheduling the batch job to repush campaign members to Ozonetel.
     * The provided list of CampaignMember records serves as the input for the repush operation.
     * The method performs the required operations to create and schedule the batch job for repushing campaign members.
     * 
     * @param campMemberIdList A list of CampaignMember records to be repushed to Ozonetel.
     * 
     */
    public static void scheduleTheJobForRepushToOzonetel(List<CampaignMember> campMemberIdList){
        integer cnt = 0;
        integer timeAdded = 1;
        Integer lstSize = campMemberIdList.size();
        List<CampaignMember> tempCampaignMemberList = new List<CampaignMember>();
        for(integer i=0; i<campMemberIdList.size(); i++) {
            tempCampaignMemberList.add(campMemberIdList[i]);
            lstSize = lstSize-1;
            cnt=cnt+1;        
            if(cnt==190 || lstSize==0){                   
                DateTime now  = DateTime.now();
                DateTime nextRunTime = now.addMinutes(timeAdded);
                timeAdded = timeAdded+1;
                String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' +  
                    nextRunTime.month() + ' ? ' + nextRunTime.year();
                SchedulerForPushLeadsToOzontel leadList = new SchedulerForPushLeadsToOzontel(tempCampaignMemberList);
                System.schedule('RePushToOzonetel_'+nextRunTime+'_'+campMemberIdList[i].Id, cronString , leadList);
                cnt = 0;
                tempCampaignMemberList.clear();
            }
        }
    }
    
   /**
     * Author: Sohail Solapure
     * Description: Method for creating a map of campaign names with associated member IDs.
     * 
     * This method is responsible for creating a map that associates campaign names with lists of member IDs.
     * The provided set of campaign member IDs is used to identify which members belong to which campaigns.
     * The method performs the required operations to generate the map of campaign names and their associated member IDs.
     * 
     * @param setOfCampMemberIds A set of CampaignMember IDs to be included in the map.
     * @return A map where each campaign name is associated with a list of member IDs.
     * 
     */
    public static Map<String,List<Id>> createMapOfCampNameAndCamMemberId(Set<Id> setOfCampMemberIds){
        //List<Id> newCamId = new List<Id>(setOfCampMemberIds);
        
        Map<String,List<Id>> mapCampaignNameAndCampaignMaemberId = new Map<String,List<Id>>();
        List<CampaignMember> campaignMemberToApi = new List<CampaignMember>();
        campaignMemberToApi = [SELECT Id,Lead.Id,Lead.Name,Name,FirstName,LastName,Type,Lead.MobilePhone,Campaign.Name,CampaignId,Campaign.Priority__c,Campaign.Skill__c,Campaign.Parent.Name FROM CampaignMember WHERE Type = 'Lead' AND Lead.MobilePhone != '' and Is_Ozontel_Sync__c = false AND Id IN :setOfCampMemberIds AND Campaign.IsActive = true AND Campaign.Parent.IsActive = true];
        if(!campaignMemberToApi.IsEmpty() && campaignMemberToApi.size() > 0){
            for(CampaignMember objectCampaignMember : campaignMemberToApi) {
                String campName = '';
                if(null != objectCampaignMember.Campaign.Parent.name && !String.isEmpty(objectCampaignMember.Campaign.Parent.name)){
                    campName = objectCampaignMember.Campaign.Parent.name;
                }else{
                    campName = objectCampaignMember.Campaign.Name;
                }
                if(mapCampaignNameAndCampaignMaemberId.containsKey(campName)) {
                    List<Id> usersId = mapCampaignNameAndCampaignMaemberId.get(campName);
                    usersId.add(objectCampaignMember.Id);
                    mapCampaignNameAndCampaignMaemberId.put(campName, usersId);
                } else {
                    mapCampaignNameAndCampaignMaemberId.put(campName, new List<Id> { objectCampaignMember.Id });
                }
            }        
        }
        return mapCampaignNameAndCampaignMaemberId;
    }
    
    /**
     * Author: Sohail Solapure
     * Description: Method for getting the parent campaign ID.
     * 
     * This method is responsible for retrieving the parent campaign ID associated with a given campaign ID.
     * The provided campaign ID is used to determine the parent campaign ID, if applicable.
     * The method performs the required operations to identify and return the parent campaign ID.
     * 
     * @param campId The campaign ID for which the parent campaign ID is to be retrieved.
     * @return The parent campaign ID associated with the provided campaign ID.
     * 
     */
    public static String getParentCampaignId(String campId){
        String finalCampId = '';
        List<Campaign> campaignList = [select id,Name, ParentId, parent.Name from Campaign where id = :campId AND IsActive = true];
        if(null != campaignList && campaignList.size()>0) {
            if(null != campaignList[0].ParentId && !String.isEmpty(campaignList[0].ParentId)){
                finalCampId = campaignList[0].ParentId;
            }else{
                finalCampId = campId;
            }
        }
        return finalCampId;
    }
    
    /**
    * Author: Sohail Solapure
    * Description: Method for getting child campaign IDs.
    * 
    * This method is responsible for retrieving the child campaign IDs associated with a given parent campaign ID.
    * The provided parent campaign ID is used to determine the child campaign IDs, if applicable.
    * The method performs the required operations to identify and return the list of child campaign IDs.
    * 
    * @param parentCampiagnIds The parent campaign ID for which child campaign IDs are to be retrieved.
    * @return A list of child campaign IDs associated with the provided parent campaign ID.
    * 
    */
    public static List<String> getChieldCampaignIds(String parentCampiagnIds){
        List<String> chieldCampaignIds = new List<String>();
        List<Campaign> campaignList = [select id,Name, ParentId, parent.Name,Parent.IsActive from Campaign where ParentId = :parentCampiagnIds 
                                       AND IsActive = true AND Parent.IsActive = true];
        if(null != campaignList && campaignList.size()>0) {
            for(Campaign campaignObj : campaignList){
                chieldCampaignIds.add(campaignObj.id);
            }
        }
        return chieldCampaignIds;
    }
}