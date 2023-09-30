@isTest
public class LeadCoapplicantEmploymentControllerTest {
    @isTest
    Public static void testLeadApplicantDetails() {
        
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true); 
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        Lead lrecrds=TestDataFactory.createLead(false);
        lrecrds.Source_Name__c = objSource.Id;
        insert lrecrds;
        Account arecrds = TestDataFactory.createPersonAccount(true);
        Co_Applicant__c applicantrecrds = TestDataFactory.CreateCoApplicant(true);
        Co_Applicant__c coApplicantrecrds = TestDataFactory.CreateCoApplicantRecord(false);
        coApplicantrecrds.Lead__c = lrecrds.Id;
        coApplicantrecrds.Account__c = arecrds.Id;
        insert coApplicantrecrds;
        //Pin_Code__c Pinrecrds=TestDataFactory.createPinCode(true);
        Area__c Arearecrds = TestDataFactory.createArea(true);
        Employment_Details__c emprecrds = TestDataFactory.createEmploymentdeatils(false);
        emprecrds.Employment_Type__c = 'Salaried';
        emprecrds.Lead__c = lrecrds.Id;
        emprecrds.Account__c = arecrds.Id;
        insert emprecrds;
        ContactPointAddress officeaddressrecrds = TestDataFactory.createContactPointAddressOffice(false);
        officeaddressrecrds.Lead__c = lrecrds.Id;
        officeaddressrecrds.Account__c = arecrds.Id;
        insert officeaddressrecrds;
        ContactPointAddress currentaddressrecrds = TestDataFactory.createContactPointAddress(false);
        currentaddressrecrds.Lead__c = lrecrds.Id;
        currentaddressrecrds.Account__c = arecrds.Id;
        insert currentaddressrecrds;
        ContactPointAddress permenentrecrds = TestDataFactory.createContactPointAddressPer(false);
        permenentrecrds.Lead__c = lrecrds.Id;
        permenentrecrds.Account__c = arecrds.Id;
        insert permenentrecrds;
        ContentVersion aadharCVRecord = TestDataFactory.createAadharCVRecord(false);
        aadharCVRecord.Lead__c = lrecrds.Id;
        aadharCVRecord.Account__c = arecrds.Id;
        insert aadharCVRecord;
        ContentVersion panCVRecord = TestDataFactory.createPANCVRecord(false);
        panCVRecord.Lead__c = lrecrds.Id;
        panCVRecord.Account__c = arecrds.Id;
        insert panCVRecord;
        ContentVersion passportCVRecord = TestDataFactory.createPassportCVRecord(false);
        passportCVRecord.Lead__c = lrecrds.Id;
        passportCVRecord.Account__c = arecrds.Id;
        insert passportCVRecord;
        Reference__c refRecord = TestDataFactory.createReference(false);
        refRecord.Lead__c = lrecrds.Id;
        refRecord.Account__c = arecrds.Id;
        insert refRecord;     
        Bank_Details__c bankRecord = TestDataFactory.createBankDetails(false);
        bankRecord.Lead__c = lrecrds.Id;
        bankRecord.Account__c = arecrds.Id;
        insert bankRecord;
        Demography__c demorecrds = TestDataFactory.createDemography(false);
        demorecrds.Lead__c = lrecrds.Id;
        demorecrds.Account__c = arecrds.Id;
        insert demorecrds;
        Liability__c liabilityRecord = TestDataFactory.createLiability(false);
        liabilityRecord.Lead__c = lrecrds.Id;
        liabilityRecord.Account__c = arecrds.Id;
        insert liabilityRecord;
        Employment_Details__c deleteemprecrds = TestDataFactory.createEmploymentdeatils(false);
        deleteemprecrds.Employment_Type__c = 'Salaried';
        deleteemprecrds.Lead__c = lrecrds.Id;
        deleteemprecrds.Account__c = arecrds.Id;
        insert deleteemprecrds;
        Document_Checklist__c dclRecord = TestDataFactory.createDocumnetChecklist(false);
        dclRecord.Lead__c = lrecrds.Id;
        dclRecord.Applicant__c = coApplicantrecrds.Id;
        insert dclRecord;      
        Test.startTest();
        LeadCoapplicantEmploymentController.getCoapp(lrecrds.id);
        LeadCoapplicantEmploymentController.getEmploymentWithAddress(lrecrds.id);
        LeadCoapplicantEmploymentController.getAccountIdFromCoApplicant(lrecrds.id);
        LeadCoapplicantEmploymentController.checkPinCodeAvailable(Arearecrds.Name);
        LeadCoapplicantEmploymentController.updateEmploymentCheck(lrecrds.id, true);
        LeadCoapplicantEmploymentController.updateCheck(lrecrds.id, true);
        LeadCoapplicantEmploymentController.getCheck(lrecrds.id);
        LeadCoapplicantEmploymentController.getleadWithApplicantsRec(lrecrds.id);
        LeadCoapplicantEmploymentController.getAccountsFromEmploymentAndCoApplicants(lrecrds.id);
        LeadCoapplicantEmploymentController.getAccountIdFromCoApplicant(lrecrds.id);
        LeadCoapplicantEmploymentController.deleteEmployment(emprecrds.Id);
        LeadCoapplicantEmploymentController.deleteCoApplicant(arecrds.Id,lrecrds.id);
        LeadCoapplicantEmploymentController.getCheckDetails(lrecrds.id);
        LeadCoapplicantEmploymentController.updateQuestionOnLead(lrecrds.id, 'Deseased', null);
        LeadCoapplicantEmploymentController.getQuestionFromLead(lrecrds.id);
        Test.stopTest();
    }
    @isTest
    Public static void testgetCoapp() {
        
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true); 
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        Lead lrecrds=TestDataFactory.createLead(false);
        lrecrds.Source_Name__c = objSource.Id;
        insert lrecrds;
        
        Account arecrds = TestDataFactory.createPersonAccount(true);
        
        Co_Applicant__c applicantrecrds = TestDataFactory.CreateCoApplicant(true);
        Co_Applicant__c coApplicantrecrds = TestDataFactory.CreateCoApplicantRecord(false);
        coApplicantrecrds.Lead__c = lrecrds.Id;
        coApplicantrecrds.Account__c = arecrds.Id;
        coApplicantrecrds.Type__c = 'CoApplicant';
        insert coApplicantrecrds;
        
        ContentVersion aadharCVRecord = TestDataFactory.createAadharCVRecord(false);
        aadharCVRecord.Lead__c = lrecrds.Id;
        aadharCVRecord.Account__c = arecrds.Id;
        insert aadharCVRecord;
        
        Document_Checklist__c dclRecord = TestDataFactory.createDocumnetChecklist(false);
        dclRecord.Lead__c = lrecrds.Id;
        dclRecord.Applicant__c = coApplicantrecrds.Id;
        insert dclRecord;
        
        ContentDocumentLink cdlRecord = TestDataFactory.createContentDocumentLink(false);
        cdlRecord.ContentDocumentId = aadharCVRecord.ContentDocumentId;
        cdlRecord.LinkedEntityId = dclRecord.Id;
        cdlRecord.ShareType ='v';
      //  insert cdlRecord;

        
        Test.startTest();
        LeadCoapplicantEmploymentController.getCoapp(lrecrds.id);
        Test.stopTest();
    }
    
    @isTest
    Public static void saveLeadApplicantDetails() {
        
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
		Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true); 
        Lead lrecrds=TestDataFactory.createLead(false);

        Account arecrds = TestDataFactory.createPersonAccount(true);
        
        Co_Applicant__c coApplicantrecrds = TestDataFactory.CreateCoApplicantRecord(false);

        Employment_Details__c emprecrds = TestDataFactory.createEmploymentdeatils(false);
        emprecrds.Lead__c = lrecrds.Id;
        emprecrds.Account__c = arecrds.Id;
        emprecrds.Employment_Type__c = 'Student';
        insert emprecrds;

        ContactPointAddress officeaddressrecrds = TestDataFactory.createContactPointAddressOffice(false);
        officeaddressrecrds.Lead__c = lrecrds.Id;
		officeaddressrecrds.Account__c = arecrds.Id;
        insert officeaddressrecrds;
        ContactPointAddress currentaddressrecrds = TestDataFactory.createContactPointAddress(false);

        ContactPointAddress permenentrecrds = TestDataFactory.createContactPointAddressPer(false);

        Demography__c demorecrds = TestDataFactory.createDemography(false);
        
        Account duplicateaccrecrds = TestDataFactory.createPersonAccount(false);
        duplicateaccrecrds.Voter_ID__c = 'XUA7748460';
        insert duplicateaccrecrds;
        ContactPointAddress dupcurrentaddressrecrds = TestDataFactory.createContactPointAddress(false);
        dupcurrentaddressrecrds.Account__c = duplicateaccrecrds.Id;
		insert dupcurrentaddressrecrds;
        ContactPointAddress duppermenentrecrds = TestDataFactory.createContactPointAddressPer(false);
        duppermenentrecrds.Account__c = duplicateaccrecrds.Id;
		insert duppermenentrecrds;
        Demography__c dupdemorecrds = TestDataFactory.createDemography(false);
        dupdemorecrds.Account__c = duplicateaccrecrds.Id;
        insert dupdemorecrds;
        
        List<LeadCoapplicantEmploymentController.wrapperForApplicant> coApplicantWrapperList = new List<LeadCoapplicantEmploymentController.wrapperForApplicant>();
        LeadCoapplicantEmploymentController.wrapperForApplicant objwrapperForApplicant = new LeadCoapplicantEmploymentController.wrapperForApplicant();
        objwrapperForApplicant.objeAcc = arecrds;
        objwrapperForApplicant.objApplicant = coApplicantrecrds;
        objwrapperForApplicant.appCurrentAdd = currentaddressrecrds;
        objwrapperForApplicant.appPermanentAdd = permenentrecrds;
        objwrapperForApplicant.appDemography = demorecrds;
        coApplicantWrapperList.add(objwrapperForApplicant);
        
        List<LeadCoapplicantEmploymentController.wrapperForApplicant> employmentWrapperList = new List<LeadCoapplicantEmploymentController.wrapperForApplicant>();
        LeadCoapplicantEmploymentController.wrapperForApplicant objwrapperForApplicant1 = new LeadCoapplicantEmploymentController.wrapperForApplicant();
        objwrapperForApplicant1.objEmployment = emprecrds;
        objwrapperForApplicant1.appOfficeAdd = officeaddressrecrds;
        employmentWrapperList.add(objwrapperForApplicant1);
                  
        Test.startTest();
        LeadCoapplicantEmploymentController.duplicateAccount('Voter ID', 'XUA7748460', system.today());
        LeadCoapplicantEmploymentController.saveCoApplicant(coApplicantWrapperList, lrecrds.id);
        LeadCoapplicantEmploymentController.saveEmployment(employmentWrapperList, lrecrds.id);
        Test.stopTest();
    }
    
    @isTest
Public static void testUpdateContentVersionRecord() {
          Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
    	Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true); 
         Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        Lead lrecrds=TestDataFactory.createLead(false);
        lrecrds.Source_Name__c = objSource.Id;
        insert lrecrds;
        Account arecrds = TestDataFactory.createPersonAccount(true);
        
        Lead testLead = new Lead(LastName = 'Test', Company = 'TestCo',Source_Name__c= objSource.Id,Product_Category__c ='HEL - INDIA');
        insert testLead;
        Co_Applicant__c testCoApplicant = new Co_Applicant__c(
            Lead__c = lrecrds.Id,
            Account__c = arecrds.Id,
            Type__c = CommonConstant.COAPPLICANT,
            Naming_Order__c = 1
        );
        insert testCoApplicant;
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test data'),
            IsMajorVersion = true,
            Account__c = testCoApplicant.Account__c,
            Document_Sub_Type__c = 'Aadhar Back',
            Lead__c = testLead.Id
        );
        insert testContentVersion;

        Account testAccount = new Account(
            LastName = 'pol', 
            FirstName = 'Harsh', 
            PersonEmail = 'harsh139@gmail.com', 
            PersonMobilePhone = '1234567890');
        insert testAccount;
        Co_Applicant__c testCoApplicant1 = new Co_Applicant__c(
            Lead__c = testLead.Id, 
            Type__c = 'Applicant', 
            Account__c = testAccount.Id);
        insert testCoApplicant1;
        
        Test.startTest();
        //LeadCoapplicantEmploymentController.updateContentVersionRecord(testLead.Id); 
		Account returnedAccount = LeadCoapplicantEmploymentController.getApplicantEmailAndMobile(testLead.Id);
		Id returnedAccountId = LeadCoapplicantEmploymentController.getAccountIdFromCoApplicant(testLead.Id);
        Test.stopTest();
          
    }
}