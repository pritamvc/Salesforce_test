@isTest
private class TestReportEmail {
    @isTest
    static void testSendReport() {
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        TestDataFactory.ReportEmaillead(true);
        List<Report> reportList = [SELECT Id, DeveloperName, Name FROM Report WHERE DeveloperName =: 'Call_Back_Due_Days_wqw'];
        Test.startTest();
        
        //Report testReport = new Report(Name = 'Call_Back_Due_Days_wqw', Name = 'Call Back Due Days_wqw');
        //insert testReport;
        ReportEmail.sendReport();
        Test.stopTest();
    }
}