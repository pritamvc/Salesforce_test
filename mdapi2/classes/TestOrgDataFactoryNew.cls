/**
* Author Name : Nupur Singh
* Date : 29/05/2023
* Purpose : Class containing records of various objects to be used in test classes.
*/

public class TestOrgDataFactoryNew {
public static Asset createAsset(Boolean isInsert){
        Asset AssetObj = new Asset(Name = 'Test Asset',Asset_Type__c  = 'Gold',Asset_Value__c  = 1000000);
        if(isInsert)
            insert AssetObj;
        return AssetObj;
    }
    public static Area__c createArea(Boolean isInsert){
        Area__c AreaObj = new Area__c(City_Code__c  = '123',City_Name__c   = 'Pune',Name = 'Test',Area_Name_Taluka__c = 'test');
        if(isInsert)
            insert AreaObj;
        return AreaObj;
    }
    public static List<Asset> createAssetList(Boolean isInsert ){
        List<Asset> AssetList = new List<Asset>();
        Asset assetObj = new Asset(Name = 'Test Asset', Asset_Type__c  = 'Gold', Asset_Value__c  = 1000000,Security_Offered__c = 'Yes',Collateral_Type__c = 'Fixed Deposits');
        AssetList.add(assetObj);
        Asset assetObj2 = new Asset(Name = 'Asset New', Asset_Type__c  = 'Gold', Asset_Value__c  = 9000000,Security_Offered__c = 'Yes',Collateral_Type__c = 'Insurance');
        AssetList.add(assetObj2);
         if(isInsert)
            insert AssetList;
        return AssetList;
    }
    public static Education_Details__c  createEducationDetails(Boolean isInsert){
        Education_Details__c Educationdetailsobj = new Education_Details__c(Education_Qualification__c  = 'Graduate',Percentage_Marks_CGPA__c    = 80, School_College_University__c = 'xyz',Account__c = TestDataFactory.createPersonAccount(true).Id);
        if(isInsert)
            insert Educationdetailsobj;
        return Educationdetailsobj;
    }
    public static List<Education_Details__c> createEduList(Boolean isInsert ){
        List<Education_Details__c> EduList = new List<Education_Details__c>();
        Education_Details__c EduObj = new Education_Details__c(Education_Qualification__c  = 'Graduate',Percentage_Marks_CGPA__c    = 80, School_College_University__c = 'xyz',Account__c = TestDataFactory.createPersonAccount(true).Id);
        EduList.add(EduObj);
        Education_Details__c EduObj2 = new Education_Details__c(Education_Qualification__c  = 'Graduate',Percentage_Marks_CGPA__c    = 82, School_College_University__c = 'abc',Account__c = TestDataFactory.createPersonAccount(true).Id);
        EduList.add(EduObj2);
         if(isInsert)
            insert EduList;
        return EduList;
    }
    public static List<Bank_Details__c>  createBankDetailsList(Boolean isInsert){
        List<Bank_Details__c> BankdetailList = new List<Bank_Details__c>();
        Bank_Details__c  BankDetailsobj = new Bank_Details__c(Account_Holder_Name__c= 'Akshay varma',Account_Number__c ='180201002445',Account_Type__c='Current Account',Name_of_Bank__c= TestDataFactory.createBank(true).Id,Bank_Branch_IFSC__c= TestDataFactory.createBankBranchIFSC(true).Id);
        BankdetailList.add(BankDetailsobj);
        if(isInsert)
            insert BankdetailList ;
        return BankdetailList ;
    } 
    public static Employment_Details__c  createEmploymentdeatils(Boolean isInsert){
        Employment_Details__c Employmentdeatilssobj = new Employment_Details__c();
        if(isInsert)
            insert Employmentdeatilssobj;
        return Employmentdeatilssobj;
    } 
    public static List<Liability__c> createLiabilityList(Boolean isInsert){
        List<Liability__c> Liabilitylist = new List<Liability__c>();
        Liability__c Liabilitysobj = new Liability__c(Loan_Type__c = 'BL');
        Liabilitylist.add(Liabilitysobj);
        if(isInsert)
            insert Liabilitylist ;
        return Liabilitylist ;
    } 
    public static Demography__c createDemography(Boolean isInsert){
        Demography__c Demographyobj = new Demography__c(Father_s_First_Name__c = 'test');
        if(isInsert)
            insert Demographyobj ;
        return Demographyobj ;
    } 
    public static ContactPointAddress  createContactPointAddress(Boolean isInsert){ 
        ContactPointAddress  ContactPointAddressobj = new ContactPointAddress (	Name= 'Permanent',Address_1__c ='Nashik',City__c='NASIK',State__c='MAHARASHTRA',Country__c ='INDIA',Pin_Code__c= createArea(true).Id);
        if(isInsert)
            insert ContactPointAddressobj ;
        return ContactPointAddressobj ;
    } 
}