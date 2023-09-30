@isTest
public class LeadApplicantDetailsTest {
    
    @isTest
    Public static void testLeadApplicantDetails() {        
        
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
		Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);        
        Lead lrecrds=TestDataFactory.createLead(true);
        Area__c Arearecrds = TestDataFactory.createArea(true);
        //Demography__c demorecrds = TestOrgDataFactory.createDemography(true);
        LeadApplicantDetails.getLeadRelatedRecord(lrecrds.id);
        LeadApplicantDetails.getLeadOwnerInfo(lrecrds.id);
        LeadApplicantDetails.getLeadPassportNum(lrecrds.id);
        LeadApplicantDetails.isPassportUploaded(lrecrds.id);
        LeadApplicantDetails.getPin(Arearecrds.Name);
        LeadApplicantDetails.getFinancialCoApplicants(lrecrds.id);
        LeadApplicantDetails.getCoApplicant(lrecrds.id);
	}
    
    @isTest
    Public static void testLeadDealApplicantDetails() {        
        
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
		Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);        
        Lead lrecrds=TestDataFactory.createLead(true);
        Area__c Arearecrds = TestDataFactory.createArea(true);
        //Demography__c demorecrds = TestOrgDataFactory.createDemography(true);
        DealLeadApplicantDetails.getLeadRelatedRecord(lrecrds.id);
        DealLeadApplicantDetails.getLeadOwnerInfo(lrecrds.id);
        DealLeadApplicantDetails.getLeadPassportNum(lrecrds.id);
        DealLeadApplicantDetails.isPassportUploaded(lrecrds.id);
        DealLeadApplicantDetails.getPin(Arearecrds.Name);
        DealLeadApplicantDetails.getFinancialCoApplicants(lrecrds.id);
        DealLeadApplicantDetails.getCoApplicant(lrecrds.id);
	}
    
    @IsTest
    public static void testCreatUpdateApplicantRecord() {
        // Test data setup
        //Lead testLead = new Lead();
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
         Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Lead lrecrds=TestDataFactory.createLead(true);
        // Set required fields on testLead
        Account accrecrds =TestDataFactory.createPersonAccount(true);
        // Set required fields on testAccount
        list<Demography__c> demglist= new list<Demography__c>();
        Demography__c demorecrds = TestDataFactory.createDemography(true);
        //demglist.add(demorecrds);
        List<Co_Applicant__c> coapplist = new list<Co_Applicant__c>();
        Co_Applicant__c coapprecrds = TestDataFactory.CreateCoApplicant(true);
        coapprecrds.Lead__c =lrecrds.id;
        coapprecrds.Account__c=accrecrds.id;
        update coapprecrds;
        coapplist.add(coapprecrds);
        //List<ContactPointAddress> contactpointList = new List<ContactPointAddress>();
       // ContactPointAddress contpointrecrds = TestDataFactory.createContactPointAddress(true);
        //contactpointList.add(contpointrecrds);
        // Set required fields on testCoApplicant
        
        // Create wrapper class instance
        LeadApplicantDetails.wrapperClassForCommForm wrapper = new LeadApplicantDetails.wrapperClassForCommForm();
        wrapper.LeadRecords = lrecrds;
        wrapper.leadSaveRec = JSON.serialize(lrecrds);
        wrapper.AccRecords = coapprecrds;
        wrapper.demoSaveRec=JSON.serialize(demorecrds);
        wrapper.appliAccSaveRec = JSON.serialize(accrecrds);
        wrapper.AccCoAppliRecords =coapplist;
       // wrapper.CPAAppliPermanentRecord = contpointrecrds;
        //  wrapper.appliAccSaveRec = accrecrds;
        // Set other fields in the wrapper
        
        // Serialize the wrapper class instance
        //String serializedWrapper = JSON.serialize(wrapper);
        
        // Call the method being tested
        Test.startTest();
        LeadApplicantDetails.wrapperClassForCommForm result = LeadApplicantDetails.creatUpdateApplicantRecord(JSON.serialize(wrapper));
        Test.stopTest();
        
        // Perform assertions to validate the results
        System.assertEquals(lrecrds.Id, result.LeadRecords.Id);
        if (wrapper.appliCurrentAddSave != null) {
            ContactPointAddress updatedCurrentAddress = [SELECT Id, Address_Type__c FROM ContactPointAddress ];
            System.assertEquals('Test Current Address', updatedCurrentAddress.Address_Type__c);
            // Perform assertions on other fields if needed
        }
        
        // Verify that the permanent address was upserted if it was present in the wrapper
        if (wrapper.appliPermanentAddSave != null) {
            ContactPointAddress updatedPermanentAddress = [SELECT Id, Address_Type__c FROM ContactPointAddress ];
            System.assertEquals('Test Permanent Address', updatedPermanentAddress.Address_Type__c);
            // Perform assertions on other fields if needed
        }
        // Example: System.assertEquals(expectedValue, result.someField);
    }
    
    @IsTest
    public static void testCreatUpdateApplicantRecordDeal() {
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Opportunity lrecrds = TestDataFactory.createOpportunity2(true);
        Account accrecrds =TestDataFactory.createPersonAccount(true);
        List<Demography__c> demglist= new list<Demography__c>();
        Demography__c demorecrds = TestDataFactory.createDemography(true);
        List<Co_Applicant__c> coapplist = new list<Co_Applicant__c>();
        Co_Applicant__c coapprecrds = TestDataFactory.CreateCoApplicant(true);
        coapprecrds.Deal__c =lrecrds.id;
        coapprecrds.Account__c=accrecrds.id;
        update coapprecrds;
        coapplist.add(coapprecrds);
        
        DealLeadApplicantDetails.wrapperClassForCommForm wrapper = new DealLeadApplicantDetails.wrapperClassForCommForm();
        wrapper.LeadRecords = lrecrds;
        wrapper.leadSaveRec = JSON.serialize(lrecrds);
        wrapper.AccRecords = coapprecrds;
        wrapper.demoSaveRec=JSON.serialize(demorecrds);
        wrapper.appliAccSaveRec = JSON.serialize(accrecrds);
        wrapper.AccCoAppliRecords =coapplist;
        
        // Call the method being tested
        Test.startTest();
        DealLeadApplicantDetails.wrapperClassForCommForm result = DealLeadApplicantDetails.creatUpdateApplicantRecord(JSON.serialize(wrapper));
        Test.stopTest();
    }
    
    @IsTest
    public static void testCreatUpdateApplicantRecord3() {
        // Test data setup
        //Lead testLead = new Lead();
        
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Lead lrecrds=TestDataFactory.createLead(true);
        // Set required fields on testLead
        Account accrecrds =TestDataFactory.createPersonAccount(true);
        // Set required fields on testAccount
        list<Demography__c> demglist= new list<Demography__c>();
        Demography__c demorecrds = TestDataFactory.createDemography(true);
        //demglist.add(demorecrds);
        List<Co_Applicant__c> coapplist = new list<Co_Applicant__c>();
        Co_Applicant__c coapprecrds = TestDataFactory.CreateCoApplicant(true);
        coapprecrds.Lead__c =lrecrds.id;
        coapprecrds.Account__c=accrecrds.id;
        update coapprecrds;
        coapplist.add(coapprecrds);
        //List<ContactPointAddress> contactpointList = new List<ContactPointAddress>();
       // ContactPointAddress contpointrecrds = TestDataFactory.createContactPointAddress(true);
        //contactpointList.add(contpointrecrds);
        // Set required fields on testCoApplicant
        
        // Create wrapper class instance
        LeadApplicantDetails.wrapperClassForCommForm wrapper = new LeadApplicantDetails.wrapperClassForCommForm();
        wrapper.LeadRecords = lrecrds;
        wrapper.leadSaveRec = JSON.serialize(lrecrds);
        wrapper.AccRecords = coapprecrds;
        wrapper.demoSaveRec=JSON.serialize(demorecrds);
        wrapper.appliAccSaveRec = JSON.serialize(accrecrds);
        wrapper.AccCoAppliRecords =coapplist;
      //  wrapper.CPAAppliPermanentRecord = contpointrecrds;
        
        // Set other fields in the wrapper
        
        // Serialize the wrapper class instance
        //String serializedWrapper = JSON.serialize(wrapper);
        
        // Call the method being tested
        Test.startTest();
        LeadApplicantDetails.wrapperClassForCommForm result = LeadApplicantDetails.creatUpdateApplicantRecord(JSON.serialize(wrapper));
        Test.stopTest();
    }
    
    @IsTest
    public static void testCreatUpdateDealApplicantRecord3() {
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Opportunity lrecrds = TestDataFactory.createOpportunity2(true);
        Account accrecrds =TestDataFactory.createPersonAccount(true);
        list<Demography__c> demglist= new list<Demography__c>();
        Demography__c demorecrds = TestDataFactory.createDemography(true);
        List<Co_Applicant__c> coapplist = new list<Co_Applicant__c>();
        Co_Applicant__c coapprecrds = TestDataFactory.CreateCoApplicant(true);
        coapprecrds.Deal__c =lrecrds.id;
        coapprecrds.Account__c=accrecrds.id;
        update coapprecrds;
        coapplist.add(coapprecrds);
       
        DealLeadApplicantDetails.wrapperClassForCommForm wrapper = new DealLeadApplicantDetails.wrapperClassForCommForm();
        wrapper.LeadRecords = lrecrds;
        wrapper.leadSaveRec = JSON.serialize(lrecrds);
        wrapper.AccRecords = coapprecrds;
        wrapper.demoSaveRec=JSON.serialize(demorecrds);
        wrapper.appliAccSaveRec = JSON.serialize(accrecrds);
        wrapper.AccCoAppliRecords =coapplist;
        
        // Call the method being tested
        Test.startTest();
        DealLeadApplicantDetails.wrapperClassForCommForm result = DealLeadApplicantDetails.creatUpdateApplicantRecord(JSON.serialize(wrapper));
        Test.stopTest();
    }
    
    @IsTest
    public static void testCreatUpdateApplicantRecord1() {
        // Test data setup
        //Lead testLead = new Lead();
        
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Lead lrecrds=TestDataFactory.createLead(true);
        // Set required fields on testLead
        Account accrecrds =TestDataFactory.createPersonAccount(false);
        // Set required fields on testAccount
        list<Demography__c> demglist= new list<Demography__c>();
        Demography__c demorecrds = TestDataFactory.createDemography(true);
        //demglist.add(demorecrds);
        List<Co_Applicant__c> coapplist = new list<Co_Applicant__c>();
        Co_Applicant__c coapprecrds = TestDataFactory.CreateCoApplicant(true);
        coapplist.add(coapprecrds);
        //List<ContactPointAddress> contactpointList = new List<ContactPointAddress>();
        ContactPointAddress contpointrecrds = TestDataFactory.createContactPointAddress(false);
        ContactPointAddress percontpointrecrds = TestDataFactory.createContactPointAddressPer(false);
        //contactpointList.add(contpointrecrds);
        // Set required fields on testCoApplicant
        
        // Create wrapper class instance
        LeadApplicantDetails.wrapperClassForCommForm wrapper = new LeadApplicantDetails.wrapperClassForCommForm();
        wrapper.LeadRecords = lrecrds;
        wrapper.leadSaveRec = JSON.serialize(lrecrds);
        wrapper.AccRecords = coapprecrds;
        wrapper.demoSaveRec=JSON.serialize(demorecrds);
        wrapper.appliAccSaveRec = JSON.serialize(accrecrds);
        wrapper.AccCoAppliRecords =coapplist;
        //wrapper.CPAAppliPermanentRecord = contpointrecrds;
        wrapper.appliCurrentAddSave = JSON.serialize(contpointrecrds);
        wrapper.appliPermanentAddSave = JSON.serialize(percontpointrecrds);
        
        // Set other fields in the wrapper
        
        // Serialize the wrapper class instance
        //String serializedWrapper = JSON.serialize(wrapper);
        
        // Call the method being tested
        Test.startTest();
        LeadApplicantDetails.wrapperClassForCommForm result = LeadApplicantDetails.creatUpdateApplicantRecord(JSON.serialize(wrapper));
        Test.stopTest();
        
        // Example: System.assertEquals(expectedValue, result.someField);
    }
    
    @IsTest
    public static void testCreatUpdateDealApplicantRecord1() {        
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Opportunity lrecrds = TestDataFactory.createOpportunity2(true);
        Account accrecrds =TestDataFactory.createPersonAccount(false);
        list<Demography__c> demglist= new list<Demography__c>();
        Demography__c demorecrds = TestDataFactory.createDemography(true);
        List<Co_Applicant__c> coapplist = new list<Co_Applicant__c>();
        Co_Applicant__c coapprecrds = TestDataFactory.CreateCoApplicant(true);
        coapplist.add(coapprecrds);
        //List<ContactPointAddress> contactpointList = new List<ContactPointAddress>();
        ContactPointAddress contpointrecrds = TestDataFactory.createContactPointAddress(false);
        ContactPointAddress percontpointrecrds = TestDataFactory.createContactPointAddressPer(false);
        
        // Create wrapper class instance
        DealLeadApplicantDetails.wrapperClassForCommForm wrapper = new DealLeadApplicantDetails.wrapperClassForCommForm();
        wrapper.LeadRecords = lrecrds;
        wrapper.leadSaveRec = JSON.serialize(lrecrds);
        wrapper.AccRecords = coapprecrds;
        wrapper.demoSaveRec=JSON.serialize(demorecrds);
        wrapper.appliAccSaveRec = JSON.serialize(accrecrds);
        wrapper.AccCoAppliRecords =coapplist;
        //wrapper.CPAAppliPermanentRecord = contpointrecrds;
        wrapper.appliCurrentAddSave = JSON.serialize(contpointrecrds);
        wrapper.appliPermanentAddSave = JSON.serialize(percontpointrecrds);
        
        // Call the method being tested
        Test.startTest();
        DealLeadApplicantDetails.wrapperClassForCommForm result = DealLeadApplicantDetails.creatUpdateApplicantRecord(JSON.serialize(wrapper));
        Test.stopTest();
    }
    
    @IsTest
    public static void testCreatUpdateApplicantRecord2() {
        // Test data setup
        //Lead testLead = new Lead();
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Lead lrecrds=TestDataFactory.createLead(true);
        // Set required fields on testLead
        Account accrecrds =TestDataFactory.createPersonAccount(true);
        // Set required fields on testAccount
        list<Demography__c> demglist= new list<Demography__c>();
        Demography__c demorecrds = TestDataFactory.createDemography(true);
        //demglist.add(demorecrds);
        List<Co_Applicant__c> coapplist = new list<Co_Applicant__c>();
        Co_Applicant__c coapprecrds = TestDataFactory.CreateCoApplicant(true);
        coapplist.add(coapprecrds);
        //List<ContactPointAddress> contactpointList = new List<ContactPointAddress>();
       // ContactPointAddress contpointrecrds = TestDataFactory.createContactPointAddress(true);
        //contactpointList.add(contpointrecrds);
        // Set required fields on testCoApplicant
        
        // Create wrapper class instance
        LeadApplicantDetails.wrapperClassForCommForm wrapper = new LeadApplicantDetails.wrapperClassForCommForm();
        wrapper.LeadRecords = lrecrds;
        wrapper.leadSaveRec = JSON.serialize(lrecrds);
        wrapper.AccRecords = coapprecrds;
        wrapper.demoSaveRec=JSON.serialize(demorecrds);
        wrapper.appliAccSaveRec = JSON.serialize(accrecrds);
        wrapper.AccCoAppliRecords =coapplist;
       // wrapper.CPAAppliPermanentRecord = contpointrecrds;
        
        // Set other fields in the wrapper
        
        // Serialize the wrapper class instance
        //String serializedWrapper = JSON.serialize(wrapper);
        
        // Call the method being tested
        Test.startTest();
        LeadApplicantDetails.wrapperClassForCommForm result = LeadApplicantDetails.creatUpdateApplicantRecord(JSON.serialize(wrapper));
        Test.stopTest();
        
        // Example: System.assertEquals(expectedValue, result.someField);
    }
    
    @IsTest
    public static void testCreatUpdateDealApplicantRecord2() {
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Opportunity lrecrds = TestDataFactory.createOpportunity2(true);
        Account accrecrds =TestDataFactory.createPersonAccount(true);
        list<Demography__c> demglist= new list<Demography__c>();
        Demography__c demorecrds = TestDataFactory.createDemography(true);
        List<Co_Applicant__c> coapplist = new list<Co_Applicant__c>();
        Co_Applicant__c coapprecrds = TestDataFactory.CreateCoApplicant(true);
        coapplist.add(coapprecrds);
        
        // Create wrapper class instance
        DealLeadApplicantDetails.wrapperClassForCommForm wrapper = new DealLeadApplicantDetails.wrapperClassForCommForm();
        wrapper.LeadRecords = lrecrds;
        wrapper.leadSaveRec = JSON.serialize(lrecrds);
        wrapper.AccRecords = coapprecrds;
        wrapper.demoSaveRec=JSON.serialize(demorecrds);
        wrapper.appliAccSaveRec = JSON.serialize(accrecrds);
        wrapper.AccCoAppliRecords =coapplist;
        
        // Call the method being tested
        Test.startTest();
        DealLeadApplicantDetails.wrapperClassForCommForm result = DealLeadApplicantDetails.creatUpdateApplicantRecord(JSON.serialize(wrapper));
        Test.stopTest();
    }
    /*
    @IsTest
    static void testUpdateContentVersionRecord() {
        // Create test data
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Lead testLead=TestDataFactory.createLead(true);
        Co_Applicant__c coapprecrds = TestDataFactory.CreateCoApplicant(true);
        // Set required fields on testLead
        Account testAccount =TestDataFactory.createPersonAccount(true);
        ContentVersion contrecd =TestDataFactory.createContentVersion(true);
        // Create test ContentVersion records
        // Create test ContentVersion records
        
        // Create test Document_Name_DMS__mdt records
        //Document_Name_DMS__mdt customMetadataRecords =TestDataFactory.createDocumentName(); 
        
        
        // Create the wrapper class and JSON representation
        LeadApplicantDetails.wrapperClassForCommForm wrapper = new LeadApplicantDetails.wrapperClassForCommForm();
        wrapper.leadSaveRec = JSON.serialize(testLead);
        wrapper.appliAccSaveRec = JSON.serialize(testAccount);
        String wrapperCommFormDetails = JSON.serialize(wrapper);
        
        // Call the method to test
        Test.startTest();
        //LeadApplicantDetails.updateContentVersionRecord(wrapperCommFormDetails);
        Test.stopTest();
        
        // Perform assertions
        List<ContentVersion> updatedContentVersions = [SELECT Id, Title,Document_Type__c,Applicant_Type__c,PathOnClient FROM ContentVersion WHERE Lead__c = :testLead.Id];
        //System.assertEquals(2, updatedContentVersions.size());
        
    }*/
    
    @IsTest
    public static void testCreatUpdateApplicantRecord4() {
        
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        Lead lrecrds=TestDataFactory.createLead(false);
        lrecrds.Source_Name__c = objSource.Id;
        insert lrecrds;
        Account arecrds = TestDataFactory.createPersonAccount(true);
        Co_Applicant__c applicantrecrds = TestDataFactory.CreateCoApplicant(false);
        applicantrecrds.Account__c =arecrds.Id;
        applicantrecrds.Lead__c = lrecrds.Id;
        insert applicantrecrds;
    }
    
    @IsTest
    public static void testCreatUpdateDealApplicantRecord4() { 
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        Opportunity lrecrds = TestDataFactory.createOpportunity2(true);
        Account arecrds = TestDataFactory.createPersonAccount(true);
        Co_Applicant__c applicantrecrds = TestDataFactory.CreateCoApplicant(false);
        applicantrecrds.Account__c =arecrds.Id;
        applicantrecrds.Deal__c = lrecrds.Id;
        insert applicantrecrds;
    }
    
    @IsTest
    public static void testsavedOCRDoc1() {
        
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        Lead lrecrds=TestDataFactory.createLead(false);
        lrecrds.Source_Name__c = objSource.Id;
        insert lrecrds;
        Account arecrds = TestDataFactory.createPersonAccount(true);
        Co_Applicant__c applicantrecrds = TestDataFactory.CreateCoApplicant(false);
        applicantrecrds.Account__c =arecrds.Id;
        applicantrecrds.Lead__c = lrecrds.Id;
        insert applicantrecrds;
        Test.startTest();
        
        List<LeadApplicantDetails.contentVersionWrapper> WrapperList = new List<LeadApplicantDetails.contentVersionWrapper>();
        LeadApplicantDetails.contentVersionWrapper objwrapperForApplicant = new LeadApplicantDetails.contentVersionWrapper();
        objwrapperForApplicant.docType = 'PASSPORT';
        objwrapperForApplicant.fullName = 'My Passport';
        objwrapperForApplicant.base64 = 'vdavadvaa';
        WrapperList.add(objwrapperForApplicant);
        
        LeadApplicantDetails.savedOCRDoc(WrapperList, lrecrds.Id, arecrds.Id);
        Test.stopTest();
    }
    
    @IsTest
    public static void testsavedDealOCRDoc1() { 
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        Opportunity lrecrds = TestDataFactory.createOpportunity2(true);
        Account arecrds = TestDataFactory.createPersonAccount(true);
        Co_Applicant__c applicantrecrds = TestDataFactory.CreateCoApplicant(false);
        applicantrecrds.Account__c =arecrds.Id;
        applicantrecrds.Deal__c = lrecrds.Id;
        insert applicantrecrds;
        Test.startTest();
        
        List<DealLeadApplicantDetails.contentVersionWrapper> WrapperList = new List<DealLeadApplicantDetails.contentVersionWrapper>();
        DealLeadApplicantDetails.contentVersionWrapper objwrapperForApplicant = new DealLeadApplicantDetails.contentVersionWrapper();
        objwrapperForApplicant.docType = 'PASSPORT';
        objwrapperForApplicant.fullName = 'My Passport';
        objwrapperForApplicant.base64 = 'vdavadvaa';
        WrapperList.add(objwrapperForApplicant);
        
        DealLeadApplicantDetails.savedOCRDoc(WrapperList, lrecrds.Id, arecrds.Id);
        Test.stopTest();
    }
    
     @IsTest
    public static void testsavedOCRDoc2() {
        
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        Lead lrecrds=TestDataFactory.createLead(false);
        lrecrds.Source_Name__c = objSource.Id;
        insert lrecrds;
        Account arecrds = TestDataFactory.createPersonAccount(true);
        Co_Applicant__c applicantrecrds = TestDataFactory.CreateCoApplicant(false);
        applicantrecrds.Account__c =arecrds.Id;
        applicantrecrds.Lead__c = lrecrds.Id;
        insert applicantrecrds;
        Test.startTest();
        
        List<LeadApplicantDetails.contentVersionWrapper> WrapperList = new List<LeadApplicantDetails.contentVersionWrapper>();
        LeadApplicantDetails.contentVersionWrapper objwrapperForApplicant = new LeadApplicantDetails.contentVersionWrapper();
        objwrapperForApplicant.docType = 'Aadhar Card';
        objwrapperForApplicant.fullName = 'My Passport';
        objwrapperForApplicant.base64 = 'vdavadvaa';
        WrapperList.add(objwrapperForApplicant);
        
        LeadApplicantDetails.savedOCRDoc(WrapperList, lrecrds.Id, arecrds.Id);
        Test.stopTest();
    }
    
    @IsTest
    public static void testsavedDealOCRDoc2() {
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        Opportunity lrecrds = TestDataFactory.createOpportunity2(true);
        Account arecrds = TestDataFactory.createPersonAccount(true);
        Co_Applicant__c applicantrecrds = TestDataFactory.CreateCoApplicant(false);
        applicantrecrds.Account__c =arecrds.Id;
        applicantrecrds.Deal__c = lrecrds.Id;
        insert applicantrecrds;
        Test.startTest();
        
        List<DealLeadApplicantDetails.contentVersionWrapper> WrapperList = new List<DealLeadApplicantDetails.contentVersionWrapper>();
        DealLeadApplicantDetails.contentVersionWrapper objwrapperForApplicant = new DealLeadApplicantDetails.contentVersionWrapper();
        objwrapperForApplicant.docType = 'Aadhar Card';
        objwrapperForApplicant.fullName = 'My Passport';
        objwrapperForApplicant.base64 = 'vdavadvaa';
        WrapperList.add(objwrapperForApplicant);
        
        DealLeadApplicantDetails.savedOCRDoc(WrapperList, lrecrds.Id, arecrds.Id);
        Test.stopTest();
    }
    
     @IsTest
    public static void testsavedOCRDoc3() {
        
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        Lead lrecrds=TestDataFactory.createLead(false);
        lrecrds.Source_Name__c = objSource.Id;
        insert lrecrds;
        Account arecrds = TestDataFactory.createPersonAccount(true);
        Co_Applicant__c applicantrecrds = TestDataFactory.CreateCoApplicant(false);
        applicantrecrds.Account__c =arecrds.Id;
        applicantrecrds.Lead__c = lrecrds.Id;
        insert applicantrecrds;
        Test.startTest();
        
        List<LeadApplicantDetails.contentVersionWrapper> WrapperList = new List<LeadApplicantDetails.contentVersionWrapper>();
        LeadApplicantDetails.contentVersionWrapper objwrapperForApplicant = new LeadApplicantDetails.contentVersionWrapper();
        objwrapperForApplicant.docType = 'PAN Card';
        objwrapperForApplicant.fullName = 'My Passport';
        objwrapperForApplicant.base64 = 'vdavadvaa';
        WrapperList.add(objwrapperForApplicant);
        
        LeadApplicantDetails.savedOCRDoc(WrapperList, lrecrds.Id, arecrds.Id);
        Test.stopTest();
    }
    
    @IsTest
    public static void testsavedDealOCRDoc3() {  
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        Opportunity lrecrds = TestDataFactory.createOpportunity2(true);
        Account arecrds = TestDataFactory.createPersonAccount(true);
        Co_Applicant__c applicantrecrds = TestDataFactory.CreateCoApplicant(false);
        applicantrecrds.Account__c =arecrds.Id;
        applicantrecrds.Deal__c = lrecrds.Id;
        insert applicantrecrds;
        Test.startTest();
        
        List<DealLeadApplicantDetails.contentVersionWrapper> WrapperList = new List<DealLeadApplicantDetails.contentVersionWrapper>();
        DealLeadApplicantDetails.contentVersionWrapper objwrapperForApplicant = new DealLeadApplicantDetails.contentVersionWrapper();
        objwrapperForApplicant.docType = 'PAN Card';
        objwrapperForApplicant.fullName = 'My Passport';
        objwrapperForApplicant.base64 = 'vdavadvaa';
        WrapperList.add(objwrapperForApplicant);
        
        DealLeadApplicantDetails.savedOCRDoc(WrapperList, lrecrds.Id, arecrds.Id);
        Test.stopTest();
    }
    
        @IsTest
    public static void testupdateEmailAndMobileVerified() {
        
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        Lead lrecrds=TestDataFactory.createLead(false);
        lrecrds.Source_Name__c = objSource.Id;
        insert lrecrds;
        Account arecrds = TestDataFactory.createPersonAccount(true);
        Co_Applicant__c applicantrecrds = TestDataFactory.CreateCoApplicant(false);
        applicantrecrds.Account__c =arecrds.Id;
        applicantrecrds.Lead__c = lrecrds.Id;
        insert applicantrecrds;
        Test.startTest();
        String parameter = 'Mobile';
        LeadApplicantDetails.updateEmailAndMobileVerified(parameter, applicantrecrds.Id);
        Test.stopTest();
    }
    
    @IsTest
    public static void testupdateEmailAndMobileVerifiedDeal() {    
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(true);
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        Opportunity lrecrds = TestDataFactory.createOpportunity2(true);
        Account arecrds = TestDataFactory.createPersonAccount(true);
        Co_Applicant__c applicantrecrds = TestDataFactory.CreateCoApplicant(false);
        applicantrecrds.Account__c =arecrds.Id;
        applicantrecrds.Deal__c = lrecrds.Id;
        insert applicantrecrds;
        Test.startTest();
        String parameter = 'Mobile';
        DealLeadApplicantDetails.updateEmailAndMobileVerified(parameter, applicantrecrds.Id);
        Test.stopTest();
    }
}