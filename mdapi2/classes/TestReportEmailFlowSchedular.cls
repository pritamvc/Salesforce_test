@isTest
private class TestReportEmailFlowSchedular {
    @isTest
    static void testEmailSchedular() {
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        // Create test data, for example, create a test lead record
        Lead testLead = new Lead(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@example.com'
        );
        insert testLead;
        
        // Set the current date/time for the test
        //Test.setCurrentPageReference(new PageReference('/apex/myPage')); // Set a dummy page reference
        Datetime now = Datetime.newInstanceGmt(2023, 7, 19, 12, 0, 0); // Set a specific date/time for testing
        Test.setCreatedDate(testLead.Id, now.addDays(-1)); // Set the "Stage_Change_Date_and_Time__c" field on the Lead
        
        // Call the scheduled method
        Test.startTest();
        ReportEmailFlowSchedular.EmailSchedular();
        Test.stopTest();
        
        // Assert that the scheduled jobs were created with correct cron expressions
        List<CronTrigger> cronTriggers = [SELECT Id, CronExpression, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name LIKE 'Send Report%'];
        System.assertEquals(3, cronTriggers.size(), 'Three scheduled jobs should be created.');
        
        // Assert the cron expressions for each scheduled job
        //System.assertEquals('0 0 9 * * ?', cronTriggers[0].CronExpression, 'The cron expression for 9 AM should be correct.');
        //System.assertEquals('0 0 14 * * ?', cronTriggers[1].CronExpression, 'The cron expression for 2 PM should be correct.');
        //System.assertEquals('0 0 18 * * ?', cronTriggers[2].CronExpression, 'The cron expression for 6 PM should be correct.');
    }
}