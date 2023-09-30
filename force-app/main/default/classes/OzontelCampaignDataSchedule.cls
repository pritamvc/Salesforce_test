/**
 * Author: Dhanaji Patil
 * @description OzontelCampaignDataSchedule class is responsible for calling the Ozontel scheduler API.
 *
 * @request Task List: List of Task objects used to schedule the next call.
 * @date 23 Mar 2023
 */
public class OzontelCampaignDataSchedule {
    
    public static String methodType = '';
    public static Integer methodTimeout = 0;
    
    /**
     * Author: Sohail Solapure
     * @description ozontelCampaignDataSchedule method is the start point for the Ozontel campaign data scheduling process.
     * 
     * This method is annotated with @InvocableMethod and takes a list of Task objects as input. It initiates the Ozontel campaign data scheduling logic.
     * 
     * @param taskList List<Task>: List of Task objects containing data for scheduling.
     */
    @InvocableMethod
    public static Void ozontelCampaignDataSchedule(List<Task> taskList){
        if(null != taskList && !String.isEmpty(taskList.toString())){
            pushScheduledCallDetailsToOzontel(taskList);
        } 
    }
    
    /**
     * Author: Sohail Solapure
     * @description pushScheduledCallDetailsToOzontel method is used to push scheduled call details to Ozonetel.
     *
     * @param taskListForcallSchedule List<Task>: List of Task objects containing details of scheduled calls.
     */
    public static void pushScheduledCallDetailsToOzontel(List<Task> taskListForcallSchedule) {
        
        Set<Id> idSet = new Set<Id>();
        Set<Id> callbackidset = new Set<Id>();
        Map<Id, Task> taskMap = new Map<Id, Task>();
        //Making the set of ids and map
        for(Task taskObj :taskListForcallSchedule){
            idSet.add(taskObj.WhoId);
            taskMap.put(taskObj.WhoId,taskObj);
            if(taskObj.call_result__c == 'Call Back'){
                callbackidset.add(taskObj.WhoId);
            }else{
                idSet.add(taskObj.WhoId);
            }
        }
        
        if(callbackidset.size() > 0){
            List<CampaignMember> campaignMembersToDelete = [SELECT Id,Campaign.Name,Campaign.Parent.Name,Lead.MobilePhone FROM CampaignMember WHERE LeadId IN :callbackidset];
            
            if (campaignMembersToDelete != null){
                try{
                    OzontelDeteleLeadDetails.deleteDataFromOzontel(json.serialize(campaignMembersToDelete));
                }catch(System.Exception e){
                    System.debug('Exception:- '+e.getMessage());
                }finally{
                    delete campaignMembersToDelete;
                    
                }
            }
            //Get the Call Back Campaign Details
            try{ 
                Campaign campaignparentRecord = [SELECT Id, Name FROM Campaign WHERE Name =: CommonConstant.CALL_BACK_CAMPAIGN AND IsActive = true];
                if(campaignparentRecord != null){
                    Campaign campaignChildRecord = [SELECT Id, Name,ParentId FROM Campaign WHERE ParentId = :campaignparentRecord.Id AND Name =: CommonConstant.OTHER_CAMPAIGN AND IsActive = true AND Campaign.Parent.IsActive = true];
                    if(campaignChildRecord != null){
                    	List<CampaignMember> campaignMemberToInsert = new List<CampaignMember>();
                    
                        for(String currLead : idSet){
                            CampaignMember campaignMember = new CampaignMember();
                            campaignMember.LeadId = currLead;
                            campaignMember.CampaignId = campaignChildRecord.Id;
                            campaignMember.Is_Ozontel_Sync__c = true;
                            campaignMemberToInsert.add(campaignMember);
                        }
                        
                        //Insert the new CampaignMember List
                        if(campaignMemberToInsert.size() > 0 ){               
                            insert campaignMemberToInsert;
                        }
                        List<CampaignMember> cmList = [SELECT Id,Lead.id,FirstName,LastName,Type,MobilePhone,Campaign.name,CampaignId,Campaign.Priority__c,Campaign.Skill__c,Campaign.Parent.name FROM CampaignMember WHERE Id in:campaignMemberToInsert AND MobilePhone != '' AND Campaign.IsActive = true];
                        String finalEndpoint = generateFinalEndpointForPushToOzontel(cmList,taskMap,true);
                        
                        callOut(finalEndpoint,methodType,methodTimeout);
                    }
                }
                
            }catch(Exception e){
                e.getStackTraceString();
            }
            
        }else{
            /******************* Update the camMember Is_Ozontel_Sync__c flag befor calling *****************/
            
            List<CampaignMember> cmListForUpdateFlag = [SELECT Id FROM CampaignMember WHERE Type='Lead' And Lead.Id In :idSet];
            if(null != cmListForUpdateFlag && cmListForUpdateFlag.size()>0){
                for(CampaignMember campMemberObj :cmListForUpdateFlag){
                    campMemberObj.Is_Ozontel_Sync__c = true;
                }
            }
            update cmListForUpdateFlag;
            
            // get campaign details 
            List<CampaignMember> cmList = [SELECT Id,Lead.id,FirstName,LastName,Type,MobilePhone,Campaign.name,CampaignId,Campaign.Priority__c,Campaign.Skill__c,Campaign.Parent.name FROM CampaignMember WHERE Type='Lead' AND MobilePhone != '' And Lead.Id In :idSet AND Campaign.IsActive = true];
            String finalEndpoint = generateFinalEndpointForPushToOzontel(cmList,taskMap,false);
            try{ 
                callOut(finalEndpoint,methodType,methodTimeout);
            }catch(Exception e){
                e.getStackTraceString();
            }
        }
    }
    
    /**
     * Author: Sohail Solapure
     * @description generateFinalEndpointForPushToOzontel method is used to generate the final URL endpoint for pushing data to Ozonetel.
     * 
     * @param cmList List<CampaignMember>: List of CampaignMember objects containing relevant data.
     * @param taskMap Map<Id, Task>: Map of Task objects with Ids as keys.
     * @param isCallback Boolean: A flag indicating whether the data push is for a callback.
     * @return String: The generated final URL endpoint for pushing data to Ozonetel.
     */
    public static String generateFinalEndpointForPushToOzontel(List<CampaignMember> cmList, Map<Id, Task> taskMap, Boolean isCallback) {
        try{
            
            //Get APi details from metadata
            Ozontel_API_Configuration_Detail__mdt ozontelApiConfigDetails = BulkOzonetelAPI.callectOzontelApiConfigration(CommonConstant.SCHEDULE_CALL_DETAILS);
            methodType = ozontelApiConfigDetails.RequestMethod__c;
            methodTimeout = Integer.valueOf(ozontelApiConfigDetails.RequestTimeout__c);
            String finalUrl = createFinalUrlWithDynamicBulkData(ozontelApiConfigDetails.ApiKey__c,ozontelApiConfigDetails.ApiEndPoint__c,ozontelApiConfigDetails.UserName__c,cmList,taskMap);
            
            /************************** if old details present on ozontel then delete **************************/
            if(isCallback == false){
                try{
                    //calling to delete method to delete old lead campaign details
                    OzontelDeteleLeadDetails.deleteDataFromOzontel(json.serialize(cmList));
                }catch(System.Exception e){
                    e.getMessage();
                }
            }
            return finalUrl;
        }catch(System.Exception e){
            e.getMessage();
        }
        
        return null;
    }
    
    /**
     * Author: Sohail Solapure
     * @description createFinalUrlWithDynamicBulkData method is used to create the final URL endpoint with dynamic bulk data.
     * 
     * @param apikey String: The API key used for authentication.
     * @param apiUrl String: The API URL for the endpoint.
     * @param username String: The username associated with the request.
     * @param cmList List<CampaignMember>: List of CampaignMember objects containing relevant data.
     * @param taskMap Map<Id, Task>: Map of Task objects with Ids as keys.
     * @return String: The generated final URL endpoint with dynamic bulk data.
     */
    public static String createFinalUrlWithDynamicBulkData(String apikey,String apiUrl,String username, List<CampaignMember> cmList, Map<Id, Task> taskMap) {
        
        String campaignName = '';
        if(null != cmList[0].Campaign.Parent.name && !String.isEmpty(cmList[0].Campaign.Parent.name)){
            campaignName = cmList[0].Campaign.Parent.name;
        }else{
            campaignName =cmList[0].Campaign.name;
        }
        
        String url =apiUrl+System.Label.ActionForOzontel+'=&'+System.Label.ApiKeyForOzontel+'='+apikey+'&'+System.Label.CampaignNameForOzontel+'='+campaignName;
        String bulkData ='&bulkData={"map":["PhoneNumber","Name","LeadLASTName","ScheduledTime","Skill","Priority"],"data":[';
        String strbulkData ;
        // iterate the CampaignMember and making the bulk data for post
        for(CampaignMember resObj : cmList) {
            if(strbulkData == Null || String.isBlank(strbulkData))
            {
                Task tempTask = taskMap.get(resObj.Lead.id);
                strbulkData = '["'+resObj.MobilePhone+'","'+resObj.FirstName+'","'+resObj.LastName+'","'+formatDate(tempTask.call_back_date_time_New__c)+'","'+resObj.Campaign.Skill__c+'","'+resObj.Campaign.Priority__c+'"]';
            }
            else
            {
                Task tempTask = taskMap.get(resObj.Lead.id);
                strbulkData = strbulkData+',["'+resObj.MobilePhone+'","'+resObj.FirstName+'","'+resObj.LastName+'","'+formatDate(tempTask.call_back_date_time_New__c)+'","'+resObj.Campaign.Skill__c+'","'+resObj.Campaign.Priority__c+'"]';
            }
        }
        
        String urlEnd=']}';
        String finalEndpoint =url+bulkData+strbulkData+urlEnd;
        return finalEndpoint;
    }
    
    /**
     * Author: Sohail Solapure
     * @description callOut method is used for making a callout to an external API.
     * 
     * This method is annotated with the @future(callout=true) annotation, allowing it to perform callouts. It takes the final endpoint (finalEndpoint) of the API, the HTTP method type (methodType), and the API timeout duration in milliseconds (apiTimeout) as input parameters. It does not return any value.
     * 
     * @param finalEndpoint String: The final URL endpoint of the external API.
     * @param methodType String: The HTTP method type for the callout (e.g., GET, POST, etc.).
     * @param apiTimeout Integer: The timeout duration in milliseconds for the API call.
     */
    @future(callout = true)
    public static void callOut(String finalEndpoint, String methodType, Integer apiTimeout) {
        
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();  
        
        Http http = new Http();
        try{
            if(null != finalEndpoint && !String.isBlank(finalEndpoint)) { 
                request.setMethod(methodType);
                request.setTimeout(apiTimeout);
                request.setEndpoint(finalEndpoint.replace(' ', '%20'));
                response=http.send(request);
                
            }
        }catch(Exception e){
            e.getStackTraceString();
        }
    }
    
    /**
     * Author: Sohail Solapure
     * @description formatDate method is used to convert a string representation of a date (strDate) into a Datetime object.
     *
     * @param strDate String: The string representation of a date to be converted.
     * @return Datetime: A Datetime object representing the parsed date from the input string.
     */
    public static Datetime formatDate(String strDate) {
        String finalDate = '';
        if(null != strDate && strDate != '') {
            try{
                string[] dateTimePart = strDate.split(' ');
                string[] datePart = dateTimePart[0].split('/');
                finalDate = (datePart[2] + '-' + datePart[0] + '-' + datePart[1]+' '+dateTimePart[1]);
            }catch(Exception e){
                e.getStackTraceString();
            }
        }
        DateTime finalFormatedDatetime = DateTime.valueOfGMT(finalDate);
        return finalFormatedDatetime;
    }
    
    /**
     * Author: Sohail Solapure
     * @description convertDateIstToGMT method is used to convert a DateTime value from the IST (Indian Standard Time) timezone to the GMT (Greenwich Mean Time) timezone.
     * 
     * @param convertDatetime String: The string representation of a DateTime value in IST timezone.
     * @return DateTime: A DateTime object representing the same moment in time in GMT timezone.
     */
    public static DateTime convertDateIstToGMT(String convertDatetime){
        DateTime finalConvertedDateTime;
        try{
            if(null != convertDatetime) {
                String recivedDateTime =  convertDatetime.remove('T');
                DateTime convertedGmtDateTime = DateTime.valueOfGMT(recivedDateTime);
                DateTime convertedDateTime = convertedGmtDateTime.addHours(5);
                finalConvertedDateTime = convertedDateTime.addMinutes(30);
            }
        }catch(Exception e){
            e.getCause();
        } 
        return finalConvertedDateTime;
    }
    
}