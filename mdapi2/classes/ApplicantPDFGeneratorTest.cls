@isTest
public class ApplicantPDFGeneratorTest {
    
    @isTest
    Public static void basicApplicantDetails() {
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Lead lrecrds=TestDataFactory.createLead(true);
        Account accountRecrds =TestDataFactory.createPersonAccount(true); 
        
        Demography__c demorcrds = TestDataFactory.createDemography(true);
        demorcrds.Account__c=accountRecrds.Id;
        demorcrds.Lead__c=lrecrds.Id;
        update demorcrds;
        Co_Applicant__c coapp = TestDataFactory.CreateCoApplicant(true);
        coapp.Type__c ='Applicant';
        coapp.Account__c=accountRecrds.Id;
        coapp.Lead__c=lrecrds.id;
        update coapp;
        Asset assrecrds = TestDataFactory.createAsset(true);
        assrecrds.Accountid=accountRecrds.Id;
        assrecrds.Lead__c=lrecrds.id;
        update assrecrds;
        Asset collrecrds = TestDataFactory.createAsset(true);
        collrecrds.Security_Offered__c= 'Yes';
        collrecrds.Accountid=accountRecrds.Id;
        collrecrds.Lead__c=lrecrds.id;
        update collrecrds;
        Education_Details__c edurecrds = TestDataFactory.createEducationDetails(true);
        edurecrds.Lead__c=lrecrds.id;
        update edurecrds;
        Employment_Details__c emprecrds = TestDataFactory.createEmploymentdeatils(true);
        emprecrds.Lead__c=lrecrds.id;
        emprecrds.Account__c=accountRecrds.Id;
        update emprecrds;
        Liability__c librecrds = TestDataFactory.createLiability(true);
        librecrds.Account__c=accountRecrds.Id;
        librecrds.Lead__c=lrecrds.id;
        update librecrds;
        
        Reference__c refrecrd = TestDataFactory.createReference(true);
        refrecrd.Account__c=accountRecrds.Id;
        refrecrd.Lead__c=lrecrds.id;
        update refrecrd;
        Bank_Details__c bankRecrds = TestDataFactory.createBankDetails(true);
        bankRecrds.Lead__c=lrecrds.id;
        bankRecrds.Account__c=accountRecrds.Id;
        update bankRecrds;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(lrecrds);
        ApplicantPDFGenerator  obj = new ApplicantPDFGenerator(sc);
        
        obj.applicantDetails(lrecrds.id);
        obj.coApplicantDetails(lrecrds.id);
        obj.leadDetails(lrecrds.id);
        obj.referenceDetails(lrecrds.id);
        obj.bankAccountDetails(lrecrds.id);
        obj.assetsDetails(lrecrds.id);
        obj.employmentDetails(lrecrds.id);
        
        obj.liabilityDetails(lrecrds.id);
        obj.collateralDetails(lrecrds.id);
        
    }
    
    @isTest
    Public static void basicCoappliantDetails() {
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Lead lrecrds=TestDataFactory.createLead(true);
        Account accountRecrds =TestDataFactory.createPersonAccount(true);        
        
        Demography__c demorcrds = TestDataFactory.createDemography(true);
        demorcrds.Account__c=accountRecrds.Id;
        demorcrds.Lead__c=lrecrds.Id;
        update demorcrds;
        
        Co_Applicant__c coapp = TestDataFactory.CreateCoApplicant(true);
        coapp.Type__c =CommonConstant.COAPPLICANT;
        coapp.Account__c=accountRecrds.Id;
        coapp.Lead__c=lrecrds.id;
        update coapp;
        
        Asset assrecrds = TestDataFactory.createAsset(true);
        assrecrds.Accountid=accountRecrds.Id;
        assrecrds.Lead__c=lrecrds.id;
        update assrecrds;
        
        Asset collrecrds = TestDataFactory.createAsset(true);
        collrecrds.Security_Offered__c= 'Yes';
        collrecrds.Accountid=accountRecrds.Id;
        collrecrds.Lead__c=lrecrds.id;
        update collrecrds;
        
        Education_Details__c edurecrds = TestDataFactory.createEducationDetails(true);
        edurecrds.Lead__c=lrecrds.id;
        edurecrds.Account__c=accountRecrds.Id;
        update edurecrds;
        
        Employment_Details__c emprecrds = TestDataFactory.createEmploymentdeatils(true);
        emprecrds.Lead__c=lrecrds.id;
        emprecrds.Account__c=accountRecrds.Id;
        update emprecrds;
        
        Liability__c librecrds = TestDataFactory.createLiability(true);
        librecrds.Account__c=accountRecrds.Id;
        librecrds.Lead__c=lrecrds.id;
        update librecrds;
        
        Reference__c refrecrd = TestDataFactory.createReference(true);
        refrecrd.Account__c=accountRecrds.Id;
        refrecrd.Lead__c=lrecrds.id;
        update refrecrd;
        
        ContactPointAddress currentrecrds =TestDataFactory.createContactPointAddress(true);
        currentrecrds.Address_Type__c='Current Address';
        currentrecrds.Account__c=accountRecrds.Id;
        currentrecrds.Lead__c= lrecrds.id;
        update currentrecrds;
        
        ContactPointAddress permnentrecrds = TestDataFactory.createContactPointAddressPer(true);
        permnentrecrds.Address_Type__c='Permanent Address';
        permnentrecrds.Account__c=accountRecrds.Id;
        permnentrecrds.Lead__c=lrecrds.id;
        update permnentrecrds;
        
        ContactPointAddress officerecrds =TestDataFactory.createContactPointAddressOffice(true);
        officerecrds.Address_Type__c='Office';
        officerecrds.Account__c=accountRecrds.Id;
        officerecrds.Lead__c=lrecrds.id;
        update officerecrds;
        
        Bank_Details__c bankRecrds = TestDataFactory.createBankDetails(true);
        bankRecrds.Lead__c=lrecrds.id;
        bankRecrds.Account__c=accountRecrds.Id;
        update bankRecrds;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(lrecrds);
        ApplicantPDFGenerator  obj = new ApplicantPDFGenerator(sc);
        
        obj.applicantDetails(lrecrds.id);
        obj.coapplicantDetails(lrecrds.id);
        obj.leadDetails(lrecrds.id);
    }
    
    
}