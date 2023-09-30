@isTest
public class KarzaKycOcrControllerTest {
    @isTest
    Public static void testKarzaKycOcrControllerTestForAadhar1(){
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        Lead lrecrds=TestDataFactory.createLead(false);
        lrecrds.Source_Name__c = objSource.Id;
        insert lrecrds;
        Account applicantarecrds = TestDataFactory.createPersonAccount(true);
        Account coapplicantarecrds = TestDataFactory.createPersonAccount(false);
        coapplicantarecrds.FirstName = 'Rajendra';
        coapplicantarecrds.LastName = 'Patil';
        insert coapplicantarecrds;
        Co_Applicant__c applicantrecrds = TestDataFactory.CreateCoApplicant(false);
        applicantrecrds.Lead__c = lrecrds.Id;
        applicantrecrds.Account__c = applicantarecrds.Id;        
        Co_Applicant__c coApplicantrecrds = TestDataFactory.CreateCoApplicantRecord(false);
        coApplicantrecrds.Lead__c = lrecrds.Id;
        coApplicantrecrds.Account__c = coapplicantarecrds.Id;
        insert coApplicantrecrds;
        //Pin_Code__c Pinrecrds=TestDataFactory.createPinCode(true);
        Area__c Arearecrds = TestDataFactory.createArea(true);
        Test.startTest();
        HTTPRequestMock response = new HTTPRequestMock('AADHAR FRONT');
        Test.setMock(HttpCalloutMock.class, response);
        KarzaKycOcrController.updateKYCAccount(applicantarecrds.Id, 'PASSPORT' , 'IHJVG8452B');
        KarzaKycOcrController.getDocumentOcred(lrecrds.Id, applicantarecrds.Id, 'SGVsbG8gV29ybGQ=', 'Applicant aadhar.pdf' , 'AADHAR', null, null, null, null, null, 'Applicant', null, null);
        Test.stopTest();
    }
    
    @isTest
    Public static void testKarzaKycOcrControllerTestForAadhar2(){
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        Lead lrecrds=TestDataFactory.createLead(false);
        lrecrds.Source_Name__c = objSource.Id;
        insert lrecrds;
        Test.startTest();
        HTTPRequestMock response = new HTTPRequestMock('AADHAR FRONT');
        Test.setMock(HttpCalloutMock.class, response);
        KarzaKycOcrController.getDocumentOcred(lrecrds.Id, null, 'SGVsbG8gV29ybGQ=', 'Applicant aadhar.pdf' , 'AADHAR', null, null, null, null, null, 'Applicant', null, null);
        Test.stopTest();
    }
    
    @isTest
    Public static void testKarzaKycOcrControllerTestForAadhar3(){
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        Lead lrecrds=TestDataFactory.createLead(false);
        lrecrds.Source_Name__c = objSource.Id;
        insert lrecrds;
        Test.startTest();
        HTTPRequestMock response = new HTTPRequestMock('AADHAR BACK');
        Test.setMock(HttpCalloutMock.class, response);
        KarzaKycOcrController.getDocumentOcred(lrecrds.Id, null, 'SGVsbG8gV29ybGQ=', 'Applicant aadhar.pdf' , 'AADHAR', null, null, null, null, null, 'Applicant', null, null);
        Test.stopTest();
    }
    
    @isTest
    Public static void testKarzaKycOcrControllerTestForPAN(){
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        Lead lrecrds=TestDataFactory.createLead(false);
        lrecrds.Source_Name__c = objSource.Id;
        insert lrecrds;
        Test.startTest();
        HTTPRequestMock response = new HTTPRequestMock('PAN');
        Test.setMock(HttpCalloutMock.class, response);
        KarzaKycOcrController.getDocumentOcred(lrecrds.Id, null, 'SGVsbG8gV29ybGQ=', 'Applicant PAN.pdf' , 'PAN', null, null, null, null, null, 'Applicant', null, null);
        Test.stopTest();
    }
    
    @isTest
    Public static void testKarzaKycOcrControllerTestForPassportBack(){
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        Lead lrecrds=TestDataFactory.createLead(false);
        lrecrds.Source_Name__c = objSource.Id;
        insert lrecrds;
        Test.startTest();
        HTTPRequestMock response = new HTTPRequestMock('PASSPORT BACK');
        Test.setMock(HttpCalloutMock.class, response);
        KarzaKycOcrController.getDocumentOcred(lrecrds.Id, null, 'SGVsbG8gV29ybGQ=', 'Applicant Passport.pdf' , 'PASSPORT', null, null, null, null, null, 'Applicant', null, null);
        Test.stopTest();
    }
    
    @isTest
    Public static void testKarzaKycOcrControllerTestForPassportFront(){
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        Lead lrecrds=TestDataFactory.createLead(false);
        lrecrds.Source_Name__c = objSource.Id;
        insert lrecrds;
        Test.startTest();
        HTTPRequestMock response = new HTTPRequestMock('PASSPORT FRONT');
        Test.setMock(HttpCalloutMock.class, response);
        KarzaKycOcrController.getDocumentOcred(lrecrds.Id, null, 'SGVsbG8gV29ybGQ=', 'Applicant Passport.pdf' , 'PASSPORT', null, null, null, null, null, 'Applicant', null, null);
        Test.stopTest();
    }
    
    @isTest
    Public static void testKarzaKycOcrControllerTestForPassportCApplicant(){
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        Lead lrecrds=TestDataFactory.createLead(false);
        lrecrds.Source_Name__c = objSource.Id;
        insert lrecrds;
        Test.startTest();
        HTTPRequestMock response = new HTTPRequestMock('PASSPORT FRONT');
        Test.setMock(HttpCalloutMock.class, response);
        KarzaKycOcrController.getDocumentOcred(lrecrds.Id, null, 'SGVsbG8gV29ybGQ=', 'Applicant Passport.pdf' , 'PASSPORT', null, null, null, null, null, CommonConstant.COAPPLICANT, null, null);
        Test.stopTest();
    }
    
    @isTest
    Public static void testKarzaKycOcrControllerTestForAadharDuplicate(){
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        Lead lrecrds=TestDataFactory.createLead(false);
        lrecrds.Source_Name__c = objSource.Id;
        insert lrecrds;
        Account applicantarecrds = TestDataFactory.createPersonAccount(false);
        applicantarecrds.Aadhar_Number__c = 'XXXXXXXX9973';
        applicantarecrds.Date_of_Birth__c = Date.newInstance(1996, 3, 29);
        insert applicantarecrds;

        //ContactPointAddress contpointrecrds = TestDataFactory.createContactPointAddress(true);
        //Pin_Code__c Pinrecrds=TestDataFactory.createPinCode(true);
        Area__c Arearecrds = TestDataFactory.createArea(true);
        Test.startTest();
        HTTPRequestMock response = new HTTPRequestMock('AADHAR FRONT');
        Test.setMock(HttpCalloutMock.class, response);
        KarzaKycOcrController.getDocumentOcred(lrecrds.Id, null, 'SGVsbG8gV29ybGQ=', 'Applicant aadhar.pdf' , 'AADHAR', null, null, null, null, null, 'Applicant', null, null);
        Test.stopTest();
    }

   	@isTest
    Public static void testcheckCoApplicantNameWithKYC(){
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        Lead lrecrds=TestDataFactory.createLead(false);
        lrecrds.Source_Name__c = objSource.Id;
        insert lrecrds;
        Account applicantarecrds = TestDataFactory.createPersonAccount(false);
        applicantarecrds.FirstName = 'Rajendra';
        applicantarecrds.MiddleName = 'Akshay';
        applicantarecrds.LastName = 'Patil';
        applicantarecrds.Aadhar_Number__c = 'XXXXXXXX9973';
        insert applicantarecrds;
        
        //ContactPointAddress contpointrecrds = TestDataFactory.createContactPointAddress(true);
        //Pin_Code__c Pinrecrds=TestDataFactory.createPinCode(true);
        Area__c Arearecrds = TestDataFactory.createArea(true);
        
        KarzaKycOcrController.wrapperClass wrapper = new KarzaKycOcrController.wrapperClass();
        wrapper.leadFirstName = 'Rajendra';
        wrapper.leadMiddleName = 'Akshay';
        wrapper.leadLastName = 'Patil';
        
        Test.startTest();
        HTTPRequestMock response = new HTTPRequestMock('AADHAR FRONT');
        Test.setMock(HttpCalloutMock.class, response);
        KarzaKycOcrController.checkCoApplicantNameWithKYC(applicantarecrds.Id, wrapper);
        Test.stopTest();
    }
}