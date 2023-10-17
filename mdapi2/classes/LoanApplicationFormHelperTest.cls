/**
* Author Name : Nupur Singh
* Date : 29/05/2023
* Purpose : Class containing tests for LoanApplicationFormHelper
*/

@Istest
public class LoanApplicationFormHelperTest {
    @isTest
    static void testGetWrapperClassApplicationForm(){
        Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Lead LeadObj = TestDataFactory.createLead(true);
        string LeadIdStr = LeadObj.id;
        Asset Assetobj = TestDataFactory.createAsset(true);
        String Assetstr = Assetobj.id;
        System.debug('Asset : '+Assetobj.Id);
        Area__c Areaobj = TestDataFactory.createArea(true);
        Id areaId = Areaobj.id;
        String SectionName = 'Applicant';
        Account accobj = TestDataFactory.createPersonAccount(true);
        Co_Applicant__c coApplicantObj = TestDataFactory.CreateCoApplicant(true);
        coApplicantObj.Account__c = accobj.Id;
        update coApplicantObj;
        String ocappId = coApplicantObj.Id;
        System.debug('Applicant : '+coApplicantObj.Id);
        liability__c liabilityobj = TestDataFactory.createLiability(true);
        ContactPointAddress contactpointaddressobjnew = TestDataFactory.createContactPointAddress(true);
        system.debug('##Name'+contactpointaddressobjnew.Name);
        contactpointaddressobjnew.Account__c = accobj.Id;
        contactpointaddressobjnew.Pin_Code__c = areaId;
        contactpointaddressobjnew.Lead__c = LeadObj.Id;
        update contactpointaddressobjnew;
        ContactPointAddress contactpointaddressobj = TestDataFactory.createContactPointAddressOffice(true);
        contactpointaddressobj.Account__c = accobj.Id;
        contactpointaddressobj.Pin_Code__c = areaId;
        update contactpointaddressobj;
        Bank_Details__c bankobj = TestDataFactory.createBankDetails(true);
        Education_Details__c Educationdetailsobj = TestDataFactory.createEducationDetails(true);
        List<Bank_Details__c> banklist = TestDataFactory.createBankDetailsList(true);
        List<Education_Details__c> EduList = TestDataFactory.createEduList(true);
        Bank_Branch_IFSC__c  BankBranchIFSCobj = TestDataFactory.createBankBranchIFSC(true);
        List<Asset> assetlist = TestDataFactory.createAssetList(true);
        List<Liability__c> Liabilitylist = TestDataFactory.createLiabilityList(true);
        LoanApplicationFormHelper.wrapperClassApplicationForm wrapper= new LoanApplicationFormHelper.wrapperClassApplicationForm();
        String base64PDFData = 'test';
        string fileName='testbank.pdf';
        wrapper.leadSaveRec = 'test' ;
        wrapper.appliAccSaveRec = 'test';
        wrapper.appliCurrentAddSave = 'test';
        wrapper.AccRecords = coApplicantObj;
        wrapper.CPAAppliCurrentRecord = contactpointaddressobj;
        wrapper.appliCurrentAddSave = 'test';
        wrapper.CPAAppliPermanentRecord = contactpointaddressobj;
        wrapper.appliPermanentAddSave = 'test';
        wrapper.loanSectionLeadRec = 'test';
        wrapper.AppliEduDetailsRecord = EduList;
        wrapper.appliEduDetailsSave = 'test';
        wrapper.removeEducationIds = 'test';
        wrapper.bankAccount = banklist;
        wrapper.bankAccountSave = 'test';
        wrapper.assetDetails = assetlist;
        wrapper.assetRecordSave = 'test';
        wrapper.liabilityDetails = Liabilitylist;
        wrapper.liabilityRecordSave = 'test';
        LoanApplicationFormHelper.wrapperForApplicant wrappernew= new LoanApplicationFormHelper.wrapperForApplicant();
        wrappernew.appBankAccount = bankobj;
        wrappernew.objApplicant = coApplicantObj;
        wrappernew.objeAcc = accobj; 
        LoanApplicationFormHelper.getWrapperClassApplicationForm(LeadIdStr);
        LoanApplicationFormHelper.getCollateralAssetList(LeadIdStr);
        LoanApplicationFormHelper.getleadWithApplicantsRecForAsset(LeadIdStr);
        LoanApplicationFormHelper.getleadWithApplicantsRec(LeadIdStr);
        LoanApplicationFormHelper.getMovableCollTypeRecords();
        LoanApplicationFormHelper.getImmovableCollTypeRecords();
        LoanApplicationFormHelper.getPincodeRecord(areaId);
        LoanApplicationFormHelper.deleteCollateral(Assetstr,LeadIdStr);
        LoanApplicationFormHelper.saveBase64File(LeadObj.Id,accobj.Id,base64PDFData,fileName);
        LoanApplicationFormHelper.saveBase64FileAcc(LeadObj.Id,accobj.Id,base64PDFData,fileName);
        LoanApplicationFormHelper.DMSNames();
        LoanApplicationFormHelper.createCollateralSave(assetlist,Assetstr,LeadIdStr);
        LoanApplicationFormHelper.getSectionWeightage(SectionName);  
        LoanApplicationFormHelper.getBranch(BankBranchIFSCobj.Id);  
        Test.stopTest();    
    }
}