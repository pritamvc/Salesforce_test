/**
* Author: Thinqloud Solutions (Dhanaji Patil)
* @description This OpportunityTriggerHandler class is used to call the DmsManualCalling  to collect the document details and upload them to the LOS.
*             
* @date 10 May 2023
*/
public class OpportunityTriggerHandler {
    /**
     * Author: Thinqloud Solutions (Dhanaji Patil)
     * @description This OpportunityTriggerHandler class is used to call the DmsManualCalling to collect the document details and upload them to the LOS.
     *              
     * @param opportunityUpdatedList List<Opportunity> containing the updated Opportunities to process.
     * @date 10 May 2023
     */
    public static void updateDMSDataSync(List<Opportunity> opportunityUpdatedList) {
        List<Id> leadIDList = new List<Id>();
        if(null != opportunityUpdatedList && opportunityUpdatedList.size()>0){
            for(Opportunity oppbj : opportunityUpdatedList){
                leadIDList.add(oppbj.Lead__c);
            }
        }

        //Created the leadId list and passing to the callToLOSWhenSync
        if(null != leadIDList && leadIDList.size()>0){
            DmsManualCalling.callToLOSWhenSync(leadIDList);
        }
    }
}