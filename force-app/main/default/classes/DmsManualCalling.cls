/*
* 
* @author          Aasim Shaikh
* @description     This class is used to call failed DMS api.
* @Request         List<Id> myLeads
* @return          No return any value 
* @date            09/03/2023   
* @param 
*  
*/
global class DmsManualCalling {
    /*
    * @author          Sohail Solapure
    * @description     call to dms
    * @return          No return any value 
    * @param    
    */
    @InvocableMethod(label='DmsApiFlow' category='Other')
    global static void callToLOS(List<Id> leadID) {
        LOSToken.getAccessToken();
        
        //Get the opportuity and related documents which are failed
        List<Opportunity> deal = DmsUtils.getOportunityDetails(leadID[0]);
        Map<Document_Checklist__c, List<ContentVersion>> documentsList = DmsUtils.getDocumentListForFailedDmsApi(deal[0]);
        
        if(null != documentsList && documentsList.size() > 0){
            callingToDMSBacth(deal,documentsList);
        }
        
        //If we get list as zero then collect all documents of deal
        else{
            documentsList =  DmsUtils.getDocumentList(deal[0]);
            if(null != documentsList && documentsList.size() > 0){
                callingToDMSBacth(deal,documentsList);
            }
        }
    }
    
   /*
    * @author          Sohail Solapure
    * @description     call when los sync
    * @return          No return any value 
    * @param    
    */
    global static void callToLOSWhenSync(List<Id> leadID) {
        LOSToken.getAccessToken();
        
        //Get the opportuity and related documents 
        List<Opportunity> deal = DmsUtils.getOportunityDetails(leadID[0]);
        Map<Document_Checklist__c, List<ContentVersion>> documentsList = DmsUtils.getDocumentList(deal[0]);
        
        if(deal[0].LOS_Sync__c == true && deal[0].TrackWizz_Sync__c == true && documentsList.size() > 0){
            callingToDMSBacth(deal,documentsList); 
        }
    }
    
    /*
    * @author          Sohail Solapure
    * @description     to call batch
    * @return          No return any value 
    * @param    
    */
    global static void callingToDMSBacth(List<Opportunity> deal, Map<Document_Checklist__c, List<ContentVersion>> documentsList) {
        if(null != documentsList && documentsList.size() > 0){
            BatchForDmsApiCalling dmsBatch = new BatchForDmsApiCalling(deal, documentsList);
            Database.executeBatch(dmsBatch);
        }
    }
}