@isTest
public class ReportEmailSchedularTest {
    @isTest
    static void testReportEmailSchedular() {
        ReportEmailSchedular schedular = new ReportEmailSchedular('1');
        Test.startTest();
        System.schedule('Test Report Email Schedular', '0 0 * * * ?', schedular);
        Test.stopTest();
    }
        @isTest
    static void testReportEmailSchedular2() {
        ReportEmailSchedular schedular = new ReportEmailSchedular('2');
        Test.startTest();
        System.schedule('Test Report Email Schedular', '0 0 * * * ?', schedular);
        Test.stopTest();     
    }
    @isTest
    static void testReportEmailSchedular3() {
        ReportEmailSchedular schedular = new ReportEmailSchedular('3');
        Test.startTest();
        System.schedule('Test Report Email Schedular', '0 0 * * * ?', schedular);
        Test.stopTest();     
    }
}