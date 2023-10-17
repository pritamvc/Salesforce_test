public class DealLoanApplicationFormHelper {
    @AuraEnabled
    public static wrapperClassApplicationForm getWrapperClassApplicationForm(String leadGetId) {    
        Set<Id> coApplicantIDSet = new Set<Id>();
        Lead getLeadRecord;
        Co_Applicant__c getApplicantRecord;
        ContactPointAddress ApplicantCurrentAddress;
        ContactPointAddress ApplicantPermanentAddress;
        List<Education_Details__c> educationDetailsList;
        List<Co_Applicant__c> coApplicantDetailsList;
        List<Employment_Details__c> employmentDetailsList;
        List<Co_Applicant__c> coApplicantList = new List<Co_Applicant__c>();
        try{
            getLeadRecord = [Select Id,Salutation,Name,FirstName,MiddleName,LastName,MobilePhone,Email,Country_of_Study__c,
                             Admission_Status__c,University_Name__c,Course_Category__c,Course_Type__c,Course_Level__c,Course_Stream__c,Course_Name_Lookup__c,
                             Course_Start_Date__c,Course_End_Date__c,Analytics_Score_Category__c,Analytics_Test_Score__c,Language_Score_Category__c,
                             Language_Test_Score__c,Tuition_Fees__c,Living_Hostel_Food_Expenses__c,Traveling_Expenses__c,Other_Costs__c,Own_Source__c,
                             Scholarship__c,Others_Fund__c,Total_Costs__c,Total_Funds__c,
                             Loan_Required_A_B__c, Institute_Name__c, Campus__c From Lead Where Id =: leadGetId]; 
            
        }
        catch (Exception e) {
            System.debug('Exception occured Lead getLeadRecord.');
        }
        
        try{
            getApplicantRecord = [SELECT Id, Name,Type__c,Account__r.Lead__c,Relation_with_applicant__c,Relationship_Proof__c,Applicant_Type__c,Account__c,Account__r.Name, Account__r.Father_First_Name__c,
                                  Account__r.Father_Middle_Name__c, Account__r.Father_Last_Name__c,Account__r.Gender__c,
                                  Account__r.PAN_Number__c, Account__r.Aadhar_Number__c,Account__r.Driving_License_Number__c, Account__r.Voter_ID__c,
                                  Account__r.Is_Income_Considered_Is_Financial__c, Account__r.Passport_Number__c, 
                                  Account__r.Mother_Middle_Name__c, Account__r.Mother_Last_Name__c,
                                  Account__r.Marital_Status__c, Account__r.Spouse_s_First_Name__c, 
                                  Account__r.Spouse_s_Middle_name__c, Account__r.Spouse_s_Last_Name__c, 
                                  Account__r.Is_Communication_address__c,Account__r.Date_of_Birth__c FROM Co_Applicant__c WHERE Lead__c =: leadGetId
                                  AND Type__c = 'Applicant' LIMIT 1];
        }
        catch (Exception e) {
            System.debug('Exception occured Co_Applicant__c getApplicantRecord.');
        }
        
        try{
            ApplicantCurrentAddress= [SELECT Id,Name,Lead__c,Address_Type__c,Address_Proof__c,Address_1__c,City__c,
                                      Country__c,District__c,Landmark__c,Pin_Code__c,State__c,Taluka__c 
                                      FROM ContactPointAddress WHERE Account__c =:getApplicantRecord.Account__c 
                                      AND Name='Current'];
            
            ApplicantPermanentAddress= [SELECT Id,Name,Lead__c,Address_Type__c,Address_Proof__c,Address_1__c,City__c,
                                        Country__c,District__c,Landmark__c,Pin_Code__c,State__c,Taluka__c,
                                        Same_as_Current_Address__c FROM ContactPointAddress WHERE Account__c =:getApplicantRecord.Account__c 
                                        AND Name='Permanent'];
        }
        catch (Exception e) {
            System.debug('Exception occured.');
        }
        
        
        try{
            educationDetailsList = [Select Id, Name,Lead__c,Education_Qualification__c,Year_Completed__c, 
                                    Percentage_Marks_CGPA__c, School_College_University__c  
                                    From Education_Details__c  WHERE Account__c =:getApplicantRecord.Account__c];
        }
        catch (Exception e) {
            System.debug('Exception occured.');
        }
        
        try{
            coApplicantDetailsList = [SELECT Id, Name,Type__c,Account__r.Lead__c,Relation_with_applicant__c,Relationship_Proof__c,Applicant_Type__c,Account__c,Account__r.Name, Account__r.Mobile_Number__c, 
                                      Account__r.FirstName,Account__r.MiddleName, 
                                      Account__r.LastName,Account__r.Father_First_Name__c, Account__r.Father_Middle_Name__c, 
                                      Account__r.Father_Last_Name__c,Account__r.Gender__c, 
                                      Account__r.PAN_Number__c, Account__r.Aadhar_Number__c,Account__r.Driving_License_Number__c, Account__r.Voter_ID__c,
                                      Account__r.Is_Income_Considered_Is_Financial__c, Account__r.Mother_Frist_Name__c, 
                                      Account__r.Mother_Middle_Name__c, Account__r.Mother_Last_Name__c, 
                                      Account__r.Marital_Status__c, Account__r.Spouse_s_First_Name__c, 
                                      Account__r.Spouse_s_Middle_name__c, Account__r.Spouse_s_Last_Name__c, 
                                      Account__r.Is_Communication_address__c,Account__r.Date_of_Birth__c FROM Co_Applicant__c WHERE Lead__c =: leadGetId 
                                      AND Type__c =:CommonConstant.COAPPLICANT];
        }
        catch (Exception e) {
            System.debug('Exception occured Co_Applicant__c coApplicantDetailsList.');
        }
        
        try{
            employmentDetailsList = [SELECT Id, Name, Employment_Type__c, Name_Of_The_Company__c, 
                                     No_of_Years_with_Current_Employer__c, Monthly_Income__c, Official_Email_Id__c, Type_Of_Company__c, 
                                     Role_In_Organization__c, Total_Professional_Experience__c, Nature_of_Professional__c, Address_of_Current_Business__c, 
                                     Membership_Number__c, GST_IN__c, Nature_of_Business__c, Date_of_Retirement__c, Organisation_Name__c, Pension_Amount__c, 
                                     Account__c,Account__r.Name, Lead__c FROM Employment_Details__c  WHERE Lead__c =: leadGetId];
        }
        catch (Exception e) {
            System.debug('Exception occured.');
        }
        
        coApplicantList = [SELECT Id, Account__r.Name,Name,Type__c,Account__c,Account__r.Id FROM Co_Applicant__c WHERE Lead__c =: leadGetId];
        List<Bank_Details__c> leadBankAccount = new List<Bank_Details__c>();
        List<Asset> asset;
        List<Liability__c> liability;
        
        for(Co_Applicant__c objApp: coApplicantList){
            coApplicantIDSet.add(objApp.Account__r.Id);
        }  
        
        try{
            leadBankAccount = [SELECT Id,Lead__r.Name,Account_Holder_Name__c,Account_Number__c,Account_Operational_Since__c,Account_Type__c,Bank_Branch_IFSC__c,Name_of_Bank__c,IFSC_Code__c,MICR_Code__c from Bank_Details__c Where Account__c In: coApplicantIDSet];
        }
        catch(Exception e){
            System.debug('No bank record');
        }
        
        try{
            asset = [SELECT Id,Asset_Type__c,Asset_Value__c,Description from Asset where Lead__c = :coApplicantIDSet];
        }
        catch(Exception e){
            System.debug('No asset found');
        }
        
        //For Liability
        
        try{
            liability = [SELECT Id,Loan_Type__c,Monthly_Installment__c,Original_Amount__c,Outstanding_Amount__c,Balance_Tenure_In_Months__c from Liability__c where Lead__c =:coApplicantIDSet];
        }
        catch(Exception e){
            System.debug('No liability found');
        }
        
        
        wrapperClassApplicationForm wc = new wrapperClassApplicationForm();
        if(leadBankAccount != null)
            wc.bankAccount = leadBankAccount;
        if(asset != null)
            wc.assetDetails = asset;
        if(liability != null)
            wc.liabilityDetails = liability;
        if(getLeadRecord != null)
            wc.LeadRecords = getLeadRecord;  
        if(getApplicantRecord != null)        
            wc.AccRecords = getApplicantRecord;
        if(ApplicantCurrentAddress != null)
            wc.CPAAppliCurrentRecord = ApplicantCurrentAddress;  
        if(ApplicantPermanentAddress != null)
            wc.CPAAppliPermanentRecord = ApplicantPermanentAddress;
        if(educationDetailsList != null)
            wc.AppliEduDetailsRecord = educationDetailsList;   
        if(coApplicantDetailsList != null)
            wc.AccCoAppliRecords = coApplicantDetailsList;
        if(employmentDetailsList != null)
            wc.EmploymentRecord = employmentDetailsList;
        return wc;   
    }  
    
    public class wrapperClassApplicationForm{
        @AuraEnabled
        public Lead LeadRecords{get;set;}             
        @AuraEnabled
        public String leadSaveRec{get;set;}
        @AuraEnabled
        public Co_Applicant__c AccRecords{get;set;} 
        @AuraEnabled
        public String appliAccSaveRec{get;set;}
        @AuraEnabled
        public ContactPointAddress CPAAppliCurrentRecord{get;set;}
        @AuraEnabled
        public String appliCurrentAddSave{get;set;}
        @AuraEnabled
        public ContactPointAddress CPAAppliPermanentRecord{get;set;}        
        @AuraEnabled
        public String appliPermanentAddSave{get;set;}               
        @AuraEnabled
        public String loanSectionLeadRec{get;set;}
        @AuraEnabled
        public List<Education_Details__c> AppliEduDetailsRecord{get;set;}   
        @AuraEnabled
        public String appliEduDetailsSave{get;set;} 
        @AuraEnabled
        public List<Co_Applicant__c> AccCoAppliRecords{get;set;}
        @AuraEnabled
        public List<Employment_Details__c> EmploymentRecord{get;set;}
        @AuraEnabled
        public String removeEducationIds{get;set;}
        
        //Change for Financial Section
        @AuraEnabled
        public List<Bank_Details__c> bankAccount{get;set;}
        @AuraEnabled
        public String bankAccountSave{get;set;}
        @AuraEnabled
        public List<Asset> assetDetails{get;set;}
        @AuraEnabled
        public String assetRecordSave{get;set;}
        @AuraEnabled
        public List<Liability__c> liabilityDetails{get;set;}
        @AuraEnabled
        public String liabilityRecordSave{get;set;}
        
    }  
    public class wrapperForApplicant{           
        @AuraEnabled
        public Account objeAcc{get;set;}
        @AuraEnabled
        public Co_Applicant__c objApplicant{get;set;} 
        @AuraEnabled
        public Bank_Details__c appBankAccount{get;set;}       
    }
    
    //Methods starts for collateral section
    @AuraEnabled
    public static List<Co_Applicant__c> getleadWithApplicantsRecForAsset(String leadGetId){
        List<Co_Applicant__c> applicantsWithLeadIdRec = new  List<Co_Applicant__c>();
        applicantsWithLeadIdRec = [Select Id,Name,Account__c,Account__r.Name,Lead__r.Id,Account__r.Id,Type__c, Deal__c from Co_Applicant__c where (Lead__r.Id = :leadGetId OR Deal__c =: leadGetId) AND Is_Income_Considered_Financial__c = 'Yes'];
        return applicantsWithLeadIdRec;         
    }
    
    @AuraEnabled
    public static Area__c getPincodeRecord(Id pincode){
        system.debug('pincode==>' +pincode);
        Area__c area = new  Area__c();
        area = [Select Id,City_Name__c,State__c,Country__c,Area_Name_Taluka__c From Area__c WHERE Id =: pincode];
        return area;
    }
    
    @AuraEnabled
    public static List<Asset> getCollateralAssetList(String leadGetId) {
        List<Asset> CollateralAssetRecList = new List<Asset>();
        CollateralAssetRecList = [SELECT Id,AccountId,Lead__c,Property_Owned_By__c, Property_Owned_By__r.Name, 
                                  Collateral_Type__c,Asset_Value__c,Name ,Description, Area_Sq_Ft__c, Local_Authority__c, 
                                  Building_House_Name__c, Building_House_No__c, Wing__c, Floor__c, Survey_Plot_No__c, Pin_Code__c, 
                                  City__c, Area_Taluka_District_Area_name__c, State__c, Country__c, Landmark__c, Security_Offered__c, Address_Type_Asset__c from Asset WHERE (Lead__c =: leadGetId OR Deal__c =: leadGetId) AND Collateral_Type__c != null];
        return CollateralAssetRecList;
    }
    
    @AuraEnabled
    public static List<Asset> createCollateralSave(List<Asset> collateralRecordList, String removeCollateralIds, String leadGetId) { 
        System.debug('Remove Id:'+ removeCollateralIds);
        List<Asset> deleteCollateral = new List<Asset>();
        if(String.isNotBlank(removeCollateralIds)){
            List<Id> collateralIds = removeCollateralIds.split(',');
            deleteCollateral = [SELECT Id FROM Asset WHERE Id IN :collateralIds];
        }
        if (collateralRecordList.size()>0) { 
            for(Asset assetlist : collateralRecordList) {
                assetlist.Security_Offered__c = 'Yes'; 
                assetlist.Name = assetlist.Collateral_Type__c;                  
            }           
            //collateralRecordList.add(assetlist);          
            upsert collateralRecordList;
        }
        
        if(deleteCollateral != null && !deleteCollateral.isEmpty()){    
            delete deleteCollateral;
        }
        
        //For insert the same record without duplication from form without refresh the page
        List<Asset> fetchAsset = new List<Asset>();
        fetchAsset = getCollateralAssetList(leadGetId);
        return fetchAsset;
    }
    
    @AuraEnabled
    public static void deleteCollateral(String ids,String leadGetId){
        List<Id> collateralIds;
        if(String.isNotBlank(ids)){
            collateralIds = ids.split(',');
        }
        System.debug('Ids'+collateralIds);
        List<Asset> deleteAsset = [SELECT Id from Asset WHERE Id In: collateralIds];
        if(deleteAsset != null){
            delete deleteAsset;
        }
    }
    
    @AuraEnabled 
    public static List<Collateral_Types_Based_on_LOS_API__mdt> getMovableCollTypeRecords() {
        return [SELECT Id, Label, ApiName__c, CollateralType__c FROM Collateral_Types_Based_on_LOS_API__mdt WHERE ApiName__c = 'movable'];
    }
    
    @AuraEnabled 
    public static List<Collateral_Types_Based_on_LOS_API__mdt> getImmovableCollTypeRecords() {
        return [SELECT Id, Label, ApiName__c, CollateralType__c FROM Collateral_Types_Based_on_LOS_API__mdt WHERE ApiName__c = 'immovable'];
    }
    
    //To get the weightage of section
    @AuraEnabled
    public static Decimal getSectionWeightage(String sectionName){
        System.debug('In weightage');
        Loan_Application_Form_s_Sections__mdt sectionData = [SELECT Id,Label,Weightage__c FROM Loan_Application_Form_s_Sections__mdt WHERE MasterLabel =: sectionName LIMIT 1];
        return sectionData.Weightage__c;
    }
    
    @AuraEnabled(cacheable=true)
    public static String DMSNames(){
        List<Map<String, Object>> results = new List<Map<String, Object>>();
        for(Document_Name_DMS__mdt dms : Document_Name_DMS__mdt.getAll().values()) {
            Map<String, Object> result = new Map<String, Object>();
            
            result.put('id', dms.Id);
            result.put('label', dms.MasterLabel);
            result.put('documentType', dms.Document_Type__c);
            result.put('applicantType', dms.Applicant_Type__c);
            
            results.add(result);
        }
        
        return JSON.serialize(results);
    }
    
    //Return Co_Applicant__c related lead
    @AuraEnabled
    public static List<Co_Applicant__c> getleadWithApplicantsRec(String leadGetId){
        system.debug('Call getleadWithApplicantsRec');
        system.debug('leadGetId==2515151' +leadGetId);
        List<Co_Applicant__c> applicantsWithLeadIdRec = new  List<Co_Applicant__c>();
        applicantsWithLeadIdRec = [Select Id, Name, Account__r.Name,Lead__r.Name, Lead__r.Id,Type__c,Account__c,Lead__c,Lead__r.Document_Checked__c 
                                   from Co_Applicant__c where Lead__c =: leadGetId];
        System.debug('applicantsWithLeadIdRec======>: ' + applicantsWithLeadIdRec);
        return applicantsWithLeadIdRec;         
    }
    
    @AuraEnabled
    public static void saveBase64File(Id leadId, Id accountId, String base64File, String fileName) {
        List<Co_Applicant__c> lstCoapp = [Select Id from Co_Applicant__c where Account__c =:accountId];
        system.debug('Calling Api ');
        // Create new ContentVersion record
        ContentVersion cv = new ContentVersion();
        cv.Title = fileName;
        cv.PathOnClient = fileName;
        cv.Lead__c = leadId;
        cv.Account__c=accountId;
        cv.VersionData = EncodingUtil.base64Decode(base64File);
        insert cv;
        
        // Create new ContentDocumentLink with lead record
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id =: cv.Id
        ].ContentDocumentId;
        cdl.LinkedEntityId = leadId;
        
        // cdl.ShareType = 'V';
        try {
            insert cdl;   
            system.debug('Calling done successfully ==========!'+ cdl.ContentDocumentId);
            
        } catch(DMLException e) {
            System.debug(e);   
        } 
        
        // Create new ContentDocumentLink with account record
        ContentDocumentLink cdlA = new ContentDocumentLink();
        cdlA.ContentDocumentId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id =: cv.Id
        ].ContentDocumentId;
        cdlA.LinkedEntityId = accountId;
        // cdlA.ShareType = 'V';
        try {
            insert cdlA;
            system.debug('Calling done successfully ==========! '+ cdl.ContentDocumentId);
            
        } catch(DMLException e) {
            System.debug(e);  
        }
    }
    
    @AuraEnabled
    public static void saveBase64FileAcc(Id leadId, Id accountId, String base64File, String fileName) {
        // Create new ContentVersion record
        ContentVersion cv1 = new ContentVersion();
        cv1.Title = fileName;
        cv1.PathOnClient = fileName;
        cv1.Account__c=accountId;
        cv1.Lead__c=leadId;
        cv1.VersionData = EncodingUtil.base64Decode(base64File);
        insert cv1;
        
        // Create new ContentDocumentLink record
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id =: cv1.Id
        ].ContentDocumentId;
        cdl.LinkedEntityId = accountId;
        //cdl.ShareType = 'V';
        try {
            insert cdl;
            system.debug('Calling done successfully ==========! '+ cdl.ContentDocumentId);
            
        } catch(DMLException e) {
            System.debug(e);  
        }
    }
    //Method use for user clicks on the "Submit" button, the post "Application Formalities Completed" Task create.
    @AuraEnabled
    public static void createTask(Id leadId,string callResult) {
        string taskCallResult;
        if(callResult=='finalSubmit'){
            taskCallResult=CommonConstant.DISPOSITION_APPLICATION_FORMALITIES_COMPLETED;
        }
        /*  
if(callResult=='docSubmit'){
taskCallResult=CommonConstant.DISPOSITION_READY_TO_APPLY;
} */
        if(callResult==CommonConstant.DISPOSITION_READY_TO_APPLY){
            taskCallResult=CommonConstant.DISPOSITION_READY_TO_APPLY;
        }
        list<Task> oldAppFormilityCheck = [SELECT Id FROM Task WHERE WhoId =:leadId AND Call_Result__c =:taskCallResult];
        if(oldAppFormilityCheck.size()==0){
            Task task = new Task();
            task.Call_Result__c=taskCallResult;
            task.OwnerId=UserInfo.getUserId();
            task.Priority='Normal';
            task.Status='Completed';
            task.Subject=taskCallResult;
            task.WhoId=leadId;
            task.Type='Disposition';
            insert task;
        }     
    }   
    
    //Return Bank branches on selected bank id
    @AuraEnabled
    public static List<Bank_Branch_IFSC__c> getBranch(Id bankId){
        System.debug('Bank Id:'+bankId);
        List<Bank_Branch_IFSC__c> bankBranch = new  List<Bank_Branch_IFSC__c>();
        bankBranch = [Select Id,Name from Bank_Branch_IFSC__c where Bank__c =: bankId];
        System.debug('bankBranch======>: ' + bankBranch);
        return bankBranch;         
    }
}