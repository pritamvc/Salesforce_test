@isTest
public class BankStatementTestClassDummy {
    @isTest 
    static void testUploadDownloadMethods(){
        //Test.startTest();
        // Prepare test data
        // You might need to create appropriate test data in your org for Lead, Account and Co_Applicant__c
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Lead LeadObj = TestDataFactory.createLead(True);
        Account AccountObj = TestDataFactory.createPersonAccount(True);
        string base64pdf=TestDataFactory.createBankStatementData();
        
        //Applicant Record
        Co_Applicant__c coApplicantObj = TestDataFactory.CreateCoApplicant(false);
        coApplicantObj.Lead__c = LeadObj.Id;
		coApplicantObj.Account__c= AccountObj .Id;
        insert coApplicantObj;
        
        Id leadId = LeadObj.id; // Replace 'LeadID' with a valid lead ID from your test data
        Id accId = AccountObj.id; // Replace 'AccountID' with a valid account ID from your test data
        String base64PDFData = base64pdf; // Create a valid base64 PDF data string for testing
        String apiName = 'Upload PDF Binary'; // API Name that exists in your custom metadata type
        string password='SWAT0502';
        string fileName='testbank.pdf';
        string apiName1='Download Report Data';
        string apiName2='Download Report Data Excel';
		string docId='DOC05504733';
        // Perform test
        

        // Test uploadBinaryPDF method
        HTTPRequestMock response = new HTTPRequestMock();
        Test.setMock(HttpCalloutMock.class, response);
        system.debug('response@@@@'+response);
        Test.startTest();
        
        system.debug('response'+response);
        String uploadResult = BankStatementAnalyzer.uploadBinaryPDF(leadId ,accId,apiName ,base64PDFData, password, fileName);
        //system.debug('');
        
    }
    
    @isTest 
    static void testDownloadReportDataMethods(){
        //Test.startTest();
        // Prepare test data
        // You might need to create appropriate test data in your org for Lead, Account and Co_Applicant__c
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Lead LeadObj = TestDataFactory.createLead(True);
        Account AccountObj = TestDataFactory.createPersonAccount(True);
        string base64pdf=TestDataFactory.createBankStatementData();
        //Applicant Record
        Co_Applicant__c coApplicantObj = TestDataFactory.CreateCoApplicant(false);
        coApplicantObj.Lead__c = LeadObj.Id;
		coApplicantObj.Account__c= AccountObj .Id;
        insert coApplicantObj;
        
        Bank_Details__c  BankDetailsobj=TestDataFactory.createBankDetails(false);
      		BankDetailsobj.Lead__c = LeadObj.Id;
		  BankDetailsobj.Account__c= AccountObj .Id;
         insert BankDetailsobj;
        
        
        Id leadId = LeadObj.id; // Replace 'LeadID' with a valid lead ID from your test data
        Id accId = AccountObj.id; // Replace 'AccountID' with a valid account ID from your test data
        String base64PDFData = base64pdf; // Create a valid base64 PDF data string for testing
        String apiName = 'Upload PDF Binary'; // API Name that exists in your custom metadata type
        string password='SWAT0502';
        string fileName='testbank.pdf';
        string apiName1='Download Report Data';
        string apiName2='Download Report Data Excel';
		string docId='DOC05504733';
        // Perform test
        

        // Test uploadBinaryPDF method
        HTTPRequestMock response = new HTTPRequestMock();
        Test.setMock(HttpCalloutMock.class, response);
		
        Test.startTest();
        BankStatementAnalyzer.downloadFile( apiName1,docId,leadId ,accId);

        Test.stopTest();
        
        
    }

 @isTest 
    static void testDownloadReportDataExcelMethods(){
        Test.startTest();
        // Prepare test data
        // You might need to create appropriate test data in your org for Lead, Account and Co_Applicant__c
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Lead LeadObj = TestDataFactory.createLead(True);
        Account AccountObj = TestDataFactory.createPersonAccount(True);
        string base64pdf=TestDataFactory.createBankStatementData();
        //Applicant Record
        Co_Applicant__c coApplicantObj = TestDataFactory.CreateCoApplicant(false);
        coApplicantObj.Lead__c = LeadObj.Id;
		coApplicantObj.Account__c= AccountObj .Id;
        insert coApplicantObj;
        
        Id leadId = LeadObj.id; // Replace 'LeadID' with a valid lead ID from your test data
        Id accId = AccountObj.id; // Replace 'AccountID' with a valid account ID from your test data
        String base64PDFData = base64pdf; // Create a valid base64 PDF data string for testing
        String apiName = 'Upload PDF Binary'; // API Name that exists in your custom metadata type
        string password='SWAT0502';
        string fileName='testbank.pdf';
        string apiName1='Download Report Data';
        string apiName2='Download Report Data Excel';
		string docId='DOC05504733';
        // Perform test
        

        // Test uploadBinaryPDF method
        HTTPRequestMock response = new HTTPRequestMock();
        Test.setMock(HttpCalloutMock.class, response);

        
        //BankStatementAnalyzer.downloadFile( apiName1,docId,leadId ,accId);
        BankStatementAnalyzer.downloadFileExcel(leadId,accId, apiName2, docId);
        
        
        
        //Test.stopTest();
        
        
    }
    @isTest 
    static void testgetIsIncomeConsideredFinancialMethods(){
        Test.startTest();
        // Prepare test data
        // You might need to create appropriate test data in your org for Lead, Account and Co_Applicant__c
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Lead LeadObj = TestDataFactory.createLead(True);
        Account AccountObj = TestDataFactory.createPersonAccount(True);
        string base64pdf=TestDataFactory.createBankStatementData();
        //Applicant Record
        Co_Applicant__c coApplicantObj = TestDataFactory.CreateCoApplicant(false);
        coApplicantObj.Lead__c = LeadObj.Id;
		coApplicantObj.Account__c= AccountObj .Id;
        insert coApplicantObj;
        
        
        Id leadId = LeadObj.id; // Replace 'LeadID' with a valid lead ID from your test data
        Id accId = AccountObj.id; // Replace 'AccountID' with a valid account ID from your test data
        String base64PDFData = base64pdf; // Create a valid base64 PDF data string for testing
       
        

        // Test uploadBinaryPDF method
        HTTPRequestMock response = new HTTPRequestMock();
        Test.setMock(HttpCalloutMock.class, response);   
        BankStatementAnalyzer.getIsIncomeConsideredFinancial(leadId,accId);
    }
        @isTest
    static void testStoreErrorLogs() {
        Test.startTest();
        // Prepare test data
        // You might need to create appropriate test data in your org for Lead, Account and Co_Applicant__c
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Lead LeadObj = TestDataFactory.createLead(True);
        Account AccountObj = TestDataFactory.createPersonAccount(True);
        string base64pdf=TestDataFactory.createBankStatementData();
        //Applicant Record
        Co_Applicant__c coApplicantObj = TestDataFactory.CreateCoApplicant(false);
        coApplicantObj.Lead__c = LeadObj.Id;
		coApplicantObj.Account__c= AccountObj .Id;
        insert coApplicantObj;
        
        Id leadId = LeadObj.id; // Replace 'LeadID' with a valid lead ID from your test data
        Id accId = AccountObj.id; // Replace 'AccountID' with a valid account ID from your test data
        String base64PDFData = base64pdf; // Create a valid base64 PDF data string for testing
        String apiEndpoint = 'https://example.com/api';
        String request = 'Sample Request Body';
        String responseBody = 'Sample Response Body';
        String status = 'Error';
        Integer statusCode = 500;
        
        //Test.startTest();
        
        // Call the method to store the error logs
        BankStatementAnalyzer.storeErrorLogs(leadId, accId, apiEndpoint, request, responseBody, status, statusCode);
        
        Test.stopTest();
    }
     @isTest
    static void testCamAnalysisData() {
        // Create test data
        Decimal averageBalance = 5000.0;
        Decimal totalNetCredits = 10000.0;
        Decimal averageReceiptLastSixMonth = 2000.0;
        
        // Create an instance of the outer class Abc
        BankStatementAnalyzer BankStatementAnalyzerInstance = new BankStatementAnalyzer();
        
        // Create an instance of the inner class CamAnalysisData
        BankStatementAnalyzer.CamAnalysisData camAnalysisData = new BankStatementAnalyzer.CamAnalysisData();
		camAnalysisData.averageBalance = averageBalance;
        camAnalysisData.totalNetCredits = totalNetCredits;
        camAnalysisData.averageReceiptLastSixMonth = averageReceiptLastSixMonth;
    }
        
       
}