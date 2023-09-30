@isTest
public class ValidateDocumentUploadTest {
     @isTest
    static void testValidateDocuments() {
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        List<Document_Checklist__c> docList = new  List<Document_Checklist__c>();
        set<id> ids = new set<id>();
        Source__c src = new Source__c(Name = 'Test',Lead_Gate__c = 'Distribution Partners', Lead_Source__c ='Business Partners', Source_Type__c ='Auxilo',
                                     Sub_Source_Type__c = 'Agencies', Source_Category__c = 'Partner');
        insert src;
        Lead leadRecord = new Lead();
        leadRecord.FirstName = 'Lead';
        leadRecord.LastName ='Test';
        leadRecord.Email = 'test10@gmail.com';
        leadRecord.MobilePhone = '5454253659';
        leadRecord.Source_Category__c = 'Partner';
        leadRecord.Source_Name__c = src.id;
        leadRecord.Product_Category__c = 'HEL - INDIA';
        insert leadRecord;
        
        leadRecord.Language_Test_Score__c=4.00;
        leadRecord.Analytics_Test_Score__c=260.00;
        
        UPDATE leadRecord;
     
        String gsRecordTypeID = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account(FirstName = 'Test', LastName = 'new', recordTypeId = gsRecordTypeID,Aadhar_Number__c ='567878787876',
                                 PAN_Number__c = 'WERFD1234G',Driving_License_Number__c ='234567899',Passport_Number__c = '	K35674504');
        insert acc;
        
        Co_Applicant__c coApp = new Co_Applicant__c(Account__c = acc.id, Type__c = CommonConstant.COAPPLICANT,Is_Income_Considered_Financial__c = 'Yes');
        insert coApp;
        
        
        Document_Checklist__c dc = new Document_Checklist__c(Lead__c = leadRecord.id, Applicant__c = coApp.id, Applicant_Type__c = CommonConstant.COAPPLICANT,
                                                            Document_Type__c = 'KYC Documents', Doc_Sub_Type__c = 'Aadhar Card');
        
        insert dc;
        
        Document_Checklist__c dc2 = new Document_Checklist__c(Lead__c = leadRecord.id, Applicant__c = coApp.id, Applicant_Type__c = CommonConstant.COAPPLICANT,
                                                            Document_Type__c = 'Other Document', Doc_Sub_Type__c = 'Photo');
        
        insert dc2;
        Document_Checklist__c dc3 = new Document_Checklist__c(Lead__c = leadRecord.id, Applicant__c = coApp.id, Applicant_Type__c = CommonConstant.COAPPLICANT,
                                                            Document_Type__c = 'KYC Documents', Doc_Sub_Type__c = 'PAN Card');
        
        insert dc3;
        
         Document_Checklist__c dc4 = new Document_Checklist__c(Lead__c = leadRecord.id, Applicant__c = coApp.id, Applicant_Type__c = 'Applicant',
                                                            Document_Type__c = 'Academic Document', Doc_Sub_Type__c = '10th');
        
        insert dc4;
         Document_Checklist__c dc5 = new Document_Checklist__c(Lead__c = leadRecord.id, Applicant__c = coApp.id, Applicant_Type__c = 'Applicant',
                                                            Document_Type__c = 'Academic Document', Doc_Sub_Type__c = '12th');
        
        insert dc5;
         Document_Checklist__c dc6 = new Document_Checklist__c(Lead__c = leadRecord.id, Applicant__c = coApp.id, Applicant_Type__c = 'Applicant',
                                                            Document_Type__c = 'Academic Document', Doc_Sub_Type__c = 'Graduate');
        
        insert dc6;
         Document_Checklist__c dc7 = new Document_Checklist__c(Lead__c = leadRecord.id, Applicant__c = coApp.id, Applicant_Type__c = 'Applicant',
                                                            Document_Type__c = 'Academic Document', Doc_Sub_Type__c = 'Language Test Score');
        
        insert dc7;
         Document_Checklist__c dc8 = new Document_Checklist__c(Lead__c = leadRecord.id, Applicant__c = coApp.id, Applicant_Type__c = 'Applicant',
                                                            Document_Type__c = 'Academic Document', Doc_Sub_Type__c = 'Analytical Test Score');
        
        insert dc8;
        
        Document_Checklist__c dc9 = new Document_Checklist__c(Lead__c = leadRecord.id, Applicant__c = coApp.id, Applicant_Type__c = CommonConstant.COAPPLICANT,
                                                            Document_Type__c = 'KYC Documents', Doc_Sub_Type__c = 'Passport');
        
        insert dc9;
        
        Document_Checklist__c dc10 = new Document_Checklist__c(Lead__c = leadRecord.id, Applicant__c = coApp.id, Applicant_Type__c = CommonConstant.COAPPLICANT,
                                                            Document_Type__c = 'KYC Documents', Doc_Sub_Type__c = 'Driving License');
        
        insert dc10;
        
         Document_Checklist__c dc11 = new Document_Checklist__c(Lead__c = leadRecord.id, Applicant__c = coApp.id, Applicant_Type__c = 'Applicant',
                                                            Document_Type__c = 'KYC Documents', Doc_Sub_Type__c = 'Voter Id');
        
        insert dc11;
        
        Document_Checklist__c dc12 = new Document_Checklist__c(Lead__c = leadRecord.id, Applicant__c = coApp.id, Applicant_Type__c = 'Applicant',
                                                            Document_Type__c = 'Income Document', Doc_Sub_Type__c = 'Salary Slip');
        
        insert dc12;
        
        Document_Checklist__c dc13 = new Document_Checklist__c(Lead__c = leadRecord.id, Applicant__c = coApp.id, Applicant_Type__c = CommonConstant.COAPPLICANT,
                                                            Document_Type__c = 'Income Document', Doc_Sub_Type__c = 'Bank Statement');
        
        insert dc13;
        Document_Checklist__c dc14 = new Document_Checklist__c(Lead__c = leadRecord.id, Applicant__c = coApp.id, Applicant_Type__c = CommonConstant.COAPPLICANT,
                                                            Document_Type__c = 'Other Document', Doc_Sub_Type__c = 'Email Consent');
        
        insert dc14;
        
        
        Education_Details__c eduDetails = new Education_Details__c(Lead__c = leadRecord.id,Account__c= acc.id,Education_Qualification__c = '10th');
        insert eduDetails;
        
        Education_Details__c eduDetails1 = new Education_Details__c(Lead__c = leadRecord.id,Account__c= acc.id,Education_Qualification__c = '12th');
        insert eduDetails1;
     
        
        Bank_Details__c bankDetails = new Bank_Details__c(Account__c = acc.id,Lead__c = leadRecord.id,Account_Number__c ='656565656566');
        insert bankDetails;
        
         
        Test.startTest();
        String result = ValidateDocumentUpload.validateDocuments(leadRecord.Id);
        Test.stopTest();
        
        
    }

}