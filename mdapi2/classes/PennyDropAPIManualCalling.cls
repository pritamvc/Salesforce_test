global class PennyDropAPIManualCalling {
    @InvocableMethod(label='PennyDropAPIFlow' category='Other')
    global static void callToPennyDropAPI(List<Id> LeadID) {
        if(LeadID.size() > 0){
            // Create an instance of the batch class
            BatchPennyDropAPI batchInstance = new BatchPennyDropAPI(LeadID[0]);
            // Specify the batch size and additional optional parameters
            Integer batchSize = 200; 
            Database.ExecuteBatch(batchInstance, batchSize);
        }
    }
}