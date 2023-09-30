@isTest
public  class SchedulerForDeleteTrackerAndLogsTest {
    testMethod  public static void testDelete(){
        TestDataFactory.createTrackerList();
        TestDataFactory.createErrorLog();
		List<Tracker__c> trackerList = [Select Id from Tracker__c limit 5];
        List<Error_log__c> errorLogList = [Select Id from Error_log__c limit 5];
        
        SchedulerForDeleteTrackerAndLogs scheduler = new SchedulerForDeleteTrackerAndLogs();
		BatchForDeleteOldTrackerDetails trackerBatch = new BatchForDeleteOldTrackerDetails(trackerList);
        BatchForDeleteOldLogDetails errorlogBatch = new BatchForDeleteOldLogDetails(errorLogList);
        
        Test.startTest();
        scheduler.execute(null);
        Database.executeBatch(trackerBatch);
        Database.executeBatch(errorlogBatch);
        Test.stopTest();
    }
    
    /*testMethod  public static void testDelete1(){
        SchedulerForDeleteTrackerAndLogs scheduler = new SchedulerForDeleteTrackerAndLogs();
        Test.startTest();
        scheduler.execute(null);
        Test.stopTest();
    }*/
}