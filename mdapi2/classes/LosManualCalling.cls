/*
* 
* @author          Aasim Shaikh
* @description     This class is used to call failed los api.
* @Request         List<Id> myLeads
* @return          No return any value 
* @date            09/03/2023    
* @param
*/
global class LosManualCalling {
    @InvocableMethod(label='LosAPIFlow' category='Other')
    global static void callToLOS(List<Id> leadID) {
        LOSToken.getAccessToken();
        Opportunity oppMaster = LosUtils.getOportunityDetails(leadID[0])[0];
        
        if(oppMaster != null && oppMaster.LOS_Id__c != null) {
            //Calling failed los api
            Database.executeBatch(new BatchFailedLOSDealDataSync(leadID),1);
        } 
        else {
            //Calling the los process from start 
            SchedularToCallFailedCreateWIForDeal m = new SchedularToCallFailedCreateWIForDeal(oppMaster);
            DateTime now  = DateTime.now();  
            Integer interval = 5;
            DateTime nextRunTime = now.addSeconds(interval);
                
            String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
                    nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + 
                    nextRunTime.month() + ' ? ' + nextRunTime.year();                               
                
            System.schedule('LOS Create WI ' + cronString, cronString, m);           
        } 
    }
}