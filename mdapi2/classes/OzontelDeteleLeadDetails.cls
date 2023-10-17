/********************************************************************************************************
* @author          Dhanaji Patil
* @description     OzontelDeteleLeadDetails this class is used to delete old Lead campaign details from the ozontel.
* @request         CampaignMember (List) 
* @return          void
* @date            23/03/2023  
* param 
********************************************************************************************************/
global class OzontelDeteleLeadDetails {
    /*
    * @author          Sohail Solapure
    * @description     This methos is used to delete single lead data From Ozontel
    * @return          No return any value 
    * @param    
    */
    //@future (callout=true)
    public static Void deleteDataFromOzontel(String campaignmemberObjectString){
        if(null != campaignmemberObjectString) {
            /****************** deserialize the json string object ***********************************/
            List<CampaignMember> campaignMemberToApi = (List<CampaignMember>)Json.deserialize(campaignmemberObjectString,List<CampaignMember>.class);
            for(CampaignMember campMemberObj: CampaignMemberToApi){
                try{
                    // checking parent campaign
                    String campaignName = '';
                    if(null != campMemberObj.Campaign.Parent.Name && campMemberObj.Campaign.Parent.Name  != ''){
                        campaignName = campMemberObj.Campaign.Parent.Name;
                    }else{
                        campaignName = campMemberObj.Campaign.Name;
                    }
                    
                    
                    if(null != campaignName && campaignName != '' && null != campMemberObj.Lead.MobilePhone && campMemberObj.Lead.MobilePhone != '') {
                        deleteBulkLeadDataFromOzontel(campaignName,'','','',campMemberObj.Lead.MobilePhone);
                    }
                    
                }catch(System.Exception e){
                    e.getMessage();
                }
            } 
        }
    }
    
    /*
    * @author          Sohail Solapure
    * @description     This methos is used to delete Bulk lead Data From Ozontel like campaign, Skill,agentId,call status
    * @return          No return any value 
    * @param    
    */
    public static Void deleteBulkLeadDataFromOzontel(String campaignName, String skill, String agentId, String callStatus, String phoneNumber){
        if(null != campaignName && campaignName !=''){
            //Collect Api details from metadata            
            Ozontel_API_Configuration_Detail__mdt ozontelApiConfigDetails = BulkOzonetelAPI.callectOzontelApiConfigration(CommonConstant.BULK_DELETE_FROM_OZONTEL);
            String methodType = ozontelApiConfigDetails.RequestMethod__c;
            Integer methodTimeout = Integer.valueOf(ozontelApiConfigDetails.RequestTimeout__c);
            try{
                // Create final Url from campMemberObj
                String finalEndpoint =ozontelApiConfigDetails.ApiEndPoint__c+'apiKey='+ozontelApiConfigDetails.ApiKey__c+'&userName='+ozontelApiConfigDetails.UserName__c+'&campaignName='+campaignName+'&'+'phoneNumber='+phoneNumber.remove('+')+'&skill='+skill+'&agentId='+agentId+'&status='+callStatus;
                if(!System.isFuture() && !System.isBatch()){
                    callOut(finalEndpoint,methodType,methodTimeout);
                }else{
                    BulkOzonetelAPI.callOutWithoutFuture(finalEndpoint,methodType,methodTimeout);
                }
            }catch(System.Exception e){
                System.debug(e.getMessage());
            }
        }
    }

    /*
    * @author          Sohail Solapure
    * @description     callout method
    * @return          No return any value 
    * @param    
    */
    @future(callout=true)
    public static Void callOut(String finalEndpoint,String methodType, Integer timeOut){
        try{
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http = new Http();
            
            request.setMethod(methodType);
            request.setTimeout(timeOut);
            
            request.setEndpoint(finalEndpoint.deleteWhitespace());
            response=http.send(request);
            system.debug(response.getBody());
        }catch(System.Exception e){
            System.debug('Error Mesage:'+e.getMessage());
        } 
    }
}