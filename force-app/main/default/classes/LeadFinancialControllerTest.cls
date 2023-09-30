@istest
public class LeadFinancialControllerTest {
    @isTest
    Public static void testLeadFinancialController() {
        
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Lead lrecrds=TestDataFactory.createLead(true);
        Bank_Branch_IFSC__c bankbranchrecrds=TestDataFactory.createBankBranchIFSC(true);
         List<Bank_Details__c> bdList = new List<Bank_Details__c>();
        Bank_Details__c bankdetailsrecds =TestDataFactory.createBankDetails(true);
        bdList.add(bankdetailsrecds);
        List<Asset> assetList = new List<Asset>();
        Asset assetrecds =TestDataFactory.createAsset(true);
        assetList.add(assetrecds);
        List<Liability__c> libList = new List<Liability__c>();
        Liability__c libsrecds =TestDataFactory.createLiability(true);
        libList.add(libsrecds);
        LeadFinancialController.getCoApplicants(lrecrds.id);
        LeadFinancialController.getFinancialCoApplicants(lrecrds.id);
        LeadFinancialController.getFinanceData(lrecrds.Id);
         LeadFinancialController.getBankBranchDetails(bankbranchrecrds.id);
        LeadFinancialController.updateFinancialCheck(lrecrds.id,true);
       LeadFinancialController.saveFinancialData(bdList,assetList,libList,lrecrds.id,null,null,null);
        
    }

}