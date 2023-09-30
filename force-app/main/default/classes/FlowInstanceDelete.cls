public class FlowInstanceDelete {
    @AuraEnabled(cacheable=true)
    public static void abortFlow(String[] flowName){
        System.debug('Flow Names:'+flowName);
        String flowNa = '%'+flowName[0]+'%';
        System.debug('Flow Name'+flowNa);
        //List<FlowInterview> interviews = [SELECT Id,InterviewStatus FROM FlowInterview WHERE InterviewLabel Like :flowNa /*AND InterviewStatus = 'Running'*/];
        FlowInterview[] interviews1 = [SELECT Id FROM FlowInterview WHERE InterviewLabel like: flowNa];
        //if(!interviews1.isEmpty()){
            //delete interviews1;
            /*for(FlowInterview currInterview : interviews){
                //currInterview.InterviewStatus = 'Paused';
                //currInterview.delete();
            }*/
            //Database.update(interviews);
        //}
    }
    
    @AuraEnabled(cacheable=true)
    public static String getPausedId() {
        // Get the ID of the running user.
        String currentUser = UserInfo.getUserId();
        // Find all of that user’s paused interviews for the Survey customers flow.
        List<FlowInterview> interviews =
             [SELECT Id FROM FlowInterview WHERE CreatedById = :currentUser AND
                 InterviewLabel LIKE '%Customer Basic Details%'];
        if (interviews == null || interviews.isEmpty()) {
            return null; // early out
        }
        // Return the ID for the first interview in the list.
        return interviews.get(0).Id;
    }
}