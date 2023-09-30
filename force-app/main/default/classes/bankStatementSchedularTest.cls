@isTest
public class bankStatementSchedularTest {
    @isTest
    static void testExecuteMethod_DownloadReportData() {
        // Create test data
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Account partnerAcc = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: partnerAcc.Id];
        Lead LeadObj = TestDataFactory.createLead(false);
        LeadObj.Source_Category__c = 'Partner';
        LeadObj.Source_Name__c = objSource.Id;
        insert LeadObj;
        Account AccountObj = TestDataFactory.createPersonAccount(True);
        
        Co_Applicant__c coApplicantObj = TestDataFactory.CreateCoApplicant(false);
        coApplicantObj.Lead__c = LeadObj.Id;
		coApplicantObj.Account__c= AccountObj .Id;
        insert coApplicantObj;   
        
        Id leadId = LeadObj.id; // Replace 'LeadID' with a valid lead ID from your test data
        Id accId = AccountObj.id; // Replace 'AccountID' with a valid account ID from your test data
        String apiName = 'Upload PDF Binary';
        String apiName1 = 'Download Report Data';
        String apiName2 = 'Download Report Data Excel';
        String docId = 'DOC05419923';
		string fileName='bankstatement.pdf';
        string password='password';
        Test.startTest();      
       	Datetime now = Datetime.now();
        Datetime scheduledTime = now.addMinutes(1);
        String cronExpression = '' + scheduledTime.second() + ' ' + scheduledTime.minute() + ' ' + scheduledTime.hour() + ' ' + scheduledTime.day() + ' ' + scheduledTime.month() + ' ? ' + scheduledTime.year();
        System.schedule(apiName1+ cronExpression, cronExpression, new BankStatementSchedular(apiName1, docId, leadId, accId, fileName,password));
        //BankStatementSchedular(apiName2, docId, leadId, accId, fileName,password)
        // Call the execute method directly with a mock SchedulableContext
        System.schedule(apiName2+ cronExpression, cronExpression, new  BankStatementSchedular(apiName2, docId, leadId, accId, fileName,password));
        
		System.schedule(apiName+ cronExpression, cronExpression, new  BankStatementSchedular(apiName, docId, leadId, accId, fileName,password));
    }
}