public class TempControllerSohail {
    @AuraEnabled
    public static String creatLeadRecord(String wrapperDetails){
        system.debug('wrapperDetails========>' + wrapperDetails);      
        //Single Lead Insertion  
        WrapperClass wrapperrec = (WrapperClass)json.deserialize(wrapperDetails,WrapperClass.Class);      
        Lead singleleadrec = (Lead)json.deserialize(wrapperrec.leadstr,Lead.Class);
        system.debug('singleleadrec========>' + singleleadrec);
        if(singleleadrec != null){                
            upsert singleleadrec;
            system.debug('Updatedsingleleadrec========>' + singleleadrec);
            
            if(wrapperrec.base64Front != Null && wrapperrec.filenameFront !=null){
                ContentVersion cvFront = createContentVersion(wrapperrec.base64Front, wrapperrec.filenameFront,'Front Aadhar');
                ContentDocumentLink cdl = createContentLink(cvFront.Id, singleleadrec.Id);
            }
            
            if(wrapperrec.base64Back != Null && wrapperrec.filenameBack !=null){
                ContentVersion cvBack = createContentVersion(wrapperrec.base64Back, wrapperrec.filenameBack, 'Back Aadhar');
                ContentDocumentLink cdBack = createContentLink(cvBack.Id, singleleadrec.Id);
            }
        }
        RecordType accPersonRecType = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND Name = 'Person Account'];
        /*if(wrapperDetails.personAccStr!=null)
{
for(Account ct:wrapperDetails.personAccStr)
{
ct.RecordTypeId=accPersonRecType.id;
ct.LastName='testacc';
}
insert wrapperDetails.personAccStr;
}  */     
        
        if(wrapperrec.personAccStr != null){
            List<Account> listOfAccounts = (List<Account>)json.deserialize(wrapperrec.personAccStr, List<Account>.Class);         
            //listOfAccounts.Lead__pc =  singleleadrec.Id;   
            System.debug('Person Account Id ==============  '+ listOfAccounts);
            List<Account> listOfAccountsUpdate = new List<Account>();                
            
            for(Account objAccount : listOfAccounts){
                objAccount.RecordTypeId = accPersonRecType.Id;
                objAccount.Lead__c = singleleadrec.Id;
                listOfAccountsUpdate.add(objAccount);
            }
            System.debug('@@listOfAccountsUpdate=====>'+listOfAccountsUpdate);  
            if(!listOfAccountsUpdate.isEmpty()){                    
                insert listOfAccountsUpdate;                         
                System.debug('@@listOfAccountsUpdate Inside If=====>'+listOfAccountsUpdate);   
            } 
        }
        return singleleadrec.Id;
    }
    
    public class WrapperClass{
        @AuraEnabled
        public String leadstr{get;set;}
        @AuraEnabled
        public String base64Front{get;set;} 
        @AuraEnabled
        public String filenameFront{get;set;} 
        @AuraEnabled
        public String base64Back{get;set;} 
        @AuraEnabled
        public String filenameBack{get;set;}
        @AuraEnabled
        public String personAccStr{get;set;}
    }  
    @AuraEnabled
    public static void createContactRecord(string contactstr, string leadID){ 
        system.debug('Lead inside second method======== ' +leadID);
        System.debug('@@contactstr'+contactstr);
        Contact singleContactrec = (Contact)json.deserialize(contactstr,Contact.Class);
        System.debug('@@singleContactrec111====='+singleContactrec);
        //singleContactrec.Lead__c = leadID;
        try {
            if(singleContactrec  != Null){
                insert singleContactrec;
                System.debug('@@singleContactrec'+singleContactrec.Id); 
            } 
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
    }
    
    public class WrapperTest{
        @AuraEnabled
        public Lead LeadRecord{get;set;}
        @AuraEnabled
        public Contact ContactRecord{get;set;} 
    }  
    
    @AuraEnabled
    public static Institute__c getInstituteRecord(Id instituteId){
        Institute__c instituteRecord = new  Institute__c();
        instituteRecord = [Select Id, Name, Address__c, City__c, State__c, Country__c, Tel__c, URL_Web__c,Pin_Code__c From Institute__c 
                           WHERE Id =: instituteId];
        return instituteRecord;
        
    }

    //Added by Rohit Get instituteId record based on univercity 
    @AuraEnabled
    public static List<Institute__c> getInstituteFromUniversity(Id universityId){
        List<Institute__c> instituteRecordList = new List<Institute__c>();
        instituteRecordList = [Select Id, Name, University__c From Institute__c 
                           WHERE University__c =: universityId];
        System.debug('instituteRecordList.length ==>' + instituteRecordList.size());                 
        if(instituteRecordList.size() == 1){
            return instituteRecordList;
        } else{
            return null;
        }        
    }
    
    //To get City,State,Country according to Pincode
    @AuraEnabled
    public static Area__c getPincodeRecord(Id pincode){
        Area__c area = new  Area__c();
        area = [Select Id,City_Name__c,State__c,Country__c,Area_Name_Taluka__c From Area__c 
                           WHERE Id =: pincode];
        return area;
    }
    
    //To get Name of bank,IFSC,MICR from branch
    @AuraEnabled
    public static Bank_Branch_IFSC__c getBranchRecord(Id branchId){
        System.debug(branchId);
        //System.debug(branchAdd);
        Bank_Branch_IFSC__c branchRecord = new  Bank_Branch_IFSC__c();
        branchRecord = [Select Id,Bank__c,MICR__c,IFSC__c,Name From Bank_Branch_IFSC__c WHERE Id =: branchId];
        return branchRecord;
    }
    
     //To get University lookup
    @AuraEnabled
    public static University__c getUniversityNameCourse(Id universityId){
        University__c universityIdRecord = new  University__c();
        universityIdRecord = [Select Id, Name From University__c 
                           WHERE Id =: universityId];
        system.debug('universityIdRecord====>' + universityIdRecord);
        return universityIdRecord;        
    }
    
       //To get Course_Id Name Course Object lookup
       @AuraEnabled
       public static Course__c getCourseIdName(Id courseNameId){
        Course__c courseIdNameRecord = new  Course__c();
        courseIdNameRecord = [Select Id, Name,Course_Name__c From Course__c 
                              WHERE Id =: courseNameId];
           system.debug('courseIdNameRecord====>' + courseIdNameRecord);
           return courseIdNameRecord;           
       }

     //To get Employment Data
     @AuraEnabled(cacheable=true)
     public static list<Employment_Details__c> getEmploymentDetails(String leadGetId){
        list<Employment_Details__c> employmentList = [SELECT Id, Name, Account__c,Account__r.Name,Address_of_Current_Business__c,Date_of_Retirement__c,
                                                        Demography__c,Employment_Type__c,GST_IN__c,Lead__c,Membership_Number__c,
                                                        Monthly_Income__c,Name_Of_The_Company__c,Nature_of_Business__c,Nature_of_Professional__c,
                                                        No_of_Years_with_Current_Employer__c,Official_Email_Id__c,Organisation_Name__c,Pension_Amount__c,
                                                        Role_In_Organization__c,Total_Professional_Experience__c,Type_Of_Company__c
                                                      FROM Employment_Details__c WHERE Lead__c =: leadGetId];
        system.debug('Employment'+employmentList);
         return employmentList;
         
     }

    private static ContentVersion createContentVersion(String base64, String filename, String fileType) {
        
        //String modifiedFileName = fileName+ '0000';
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        if(fileType == 'Front Aadhar'){
            cv.Title = 'FrontAadhar';
        }else{
            cv.Title = 'BackAadhar';
        }
        
        cv.PathOnClient = fileName;
        try {
            insert cv;
            return cv;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id =: contentVersionId
        ].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        // ShareType is either 'V', 'C', or 'I'
        // V = Viewer, C = Collaborator, I = Inferred
        cdl.ShareType = 'V';
        try {
            insert cdl;
            return cdl;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static wrapperClassForCommForm getFinanceData(String leadGetId){
        system.debug('Finance leadId= ' +leadGetId);
        Set<Id> setApplIds = new Set<Id>();
        System.debug('setApplIds:'+setApplIds);
        List<Co_Applicant__c> lstApp = [SELECT Id, Account__r.Name,Name,Type__c,Account__c,Account__r.Id FROM Co_Applicant__c WHERE Lead__c =: leadGetId];
        List<Bank_Details__c> leadBankAccount = new List<Bank_Details__c>();
        List<Asset> asset;
        List<Liability__c> liability;

        for(Co_Applicant__c objApp: lstApp){
            setApplIds.add(objApp.Account__r.Id);
        }  
        
        try{
            leadBankAccount = [SELECT Id,Account__c,Account_Holder_Name__c,Account_Number__c,Account_Operational_Since__c,Account_Type__c,Bank_Branch_IFSC__c,Name_of_Bank__c,IFSC_Code__c,MICR_Code__c from Bank_Details__c Where Account__c In: setApplIds AND Lead__c =:leadGetId];
            System.debug('Bank Record:'+leadBankAccount);
        }
        catch(Exception e){
            System.debug('No bank record');
        }
        
        //Fetch Asset
        
        try{
            asset = [SELECT Id,AccountId,Asset_Type__c,Asset_Value__c,Description from Asset where AccountId = :setApplIds AND Lead__c =:leadGetId AND Asset_Type__c != null];
            System.debug('asset Record:'+asset);
        }
        catch(Exception e){
            System.debug('No asset found');
        }
        
        //For Liability
        
        try{
           liability = [SELECT Id,Account__c,Loan_Type__c,Monthly_Installment__c,Original_Amount__c,Outstanding_Amount__c,Balance_Tenure_In_Months__c from Liability__c where Account__c =:setApplIds AND Lead__c =:leadGetId];
        }
        catch(Exception e){
            System.debug('No liability found');
        }


        wrapperClassForCommForm wc = new wrapperClassForCommForm();
        if(leadBankAccount != null)
            wc.bankAccount = leadBankAccount;
        if(asset != null)
            wc.assetDetails = asset;
        if(liability != null)
            wc.liabilityDetails = liability;
        
        System.debug('wc======>: ' + wc);
        return wc;  

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

    //Return Co_Applicant__c related lead
    @AuraEnabled
    public static List<Co_Applicant__c> getleadWithApplicantsRec(String leadGetId){
        System.debug('Lead Id from component:'+leadGetId);
        List<Co_Applicant__c> applicantsWithLeadIdRec = new  List<Co_Applicant__c>();
        applicantsWithLeadIdRec = [Select Id, Name,Account__c, Account__r.Name,Lead__r.Name, Lead__r.Id,Account__r.Id,Type__c
                                   from Co_Applicant__c where Lead__r.Id =: leadGetId];
        System.debug('applicantsWithLeadIdRec======>: ' + applicantsWithLeadIdRec);
        return applicantsWithLeadIdRec;         
    }

    //Return Co_Applicant__c related lead with Income considered as financial
    @AuraEnabled(cacheable=true)
    public static List<Co_Applicant__c> getleadWithApplicantsRecForAsset(String leadGetId){
        List<Co_Applicant__c> applicantsWithLeadIdRec = new  List<Co_Applicant__c>();
        applicantsWithLeadIdRec = [Select Id,Name,Account__c,Account__r.Name,Lead__r.Id,Account__r.Id,Type__c from Co_Applicant__c where Lead__r.Id = :leadGetId AND Is_Income_Considered_Financial__c = 'Yes'];
        System.debug('applicantsWithLeadIdRec======>: ' + applicantsWithLeadIdRec);
        return applicantsWithLeadIdRec;         
    }
    
    
    @AuraEnabled
    public static wrapperClassForCommForm getWrapperClassCommFormList(String leadGetId) {    
        system.debug('Record Id Lead = ' +leadGetId);
        Lead lstLead;
        try{
            lstLead = [Select Id,Salutation,Name,FirstName,MiddleName,LastName,MobilePhone,Email,Country_of_Study__c,
                        Admission_Status__c,University_Name__c,Course_Category__c,Course_Type__c,Course_Level__c,Course_Stream__c,Course_Name_Lookup__c,
                        Course_Id__c,Course_Start_Date__c,Course_End_Date__c,Analytics_Score_Category__c,Analytics_Test_Score__c,Quantitative_Score__c,Verbal_Score__c,Language_Score_Category__c,
                        Language_Test_Score__c,Tuition_Fees__c,Living_Hostel_Food_Expenses__c,Traveling_Expenses__c,Other_Costs__c,Own_Source__c,
                        Scholarship__c,Others_Fund__c,Total_Costs__c,Total_Funds__c,
                        Loan_Required_A_B__c, Institute_Name__c, Campus__c From Lead Where Id =: leadGetId]; 
                      
        System.debug('lstLead======>: ' + lstLead);
        }
        catch (Exception e) {
            System.debug('Exception occured Lead lstLead.');
        }
        
        Co_Applicant__c appliAcc;
        try{
            appliAcc = [SELECT Id, Name,Type__c,Account__r.Lead__c,Relation_with_applicant__c,Relationship_Proof__c,Applicant_Type__c,Account__c,Account__r.Name, Account__r.Father_First_Name__c,
                                    Account__r.Father_Middle_Name__c, Account__r.Father_Last_Name__c,Account__r.Gender__c,
                                    Account__r.PAN_Number__c, Account__r.Aadhar_Number__c,Account__r.Driving_License_Number__c, Account__r.Voter_ID__c,
                                    Account__r.Is_Income_Considered_Is_Financial__c, Account__r.Passport_Number__c, 
                                    Account__r.Mother_Middle_Name__c, Account__r.Mother_Last_Name__c,
                                    Account__r.Marital_Status__c, Account__r.Spouse_s_First_Name__c, 
                                    Account__r.Spouse_s_Middle_name__c, Account__r.Spouse_s_Last_Name__c, 
                                    Account__r.Is_Communication_address__c,Account__r.Date_of_Birth__c FROM Co_Applicant__c WHERE Lead__c =: leadGetId
                                    AND Type__c = 'Applicant' LIMIT 1];
        System.debug('appliAcc======>: ' + appliAcc.Account__c);
        }
        catch (Exception e) {
            System.debug('Exception occured Co_Applicant__c appliAcc.');
        }
        
        ContactPointAddress AppliCurrentAddress;
        ContactPointAddress AppliPermanentAddress;
        
        try{
            AppliCurrentAddress= [SELECT Id,Name,Lead__c,Address_Type__c,Address_Proof__c,Address_1__c,City__c,
                                                  Country__c,District__c,Landmark__c,Pin_Code__c,State__c,Taluka__c 
                                                  FROM ContactPointAddress WHERE Account__c =:appliAcc.Account__c 
                                                  AND Name='Current'];
            //System.debug('AppliCurrentAddress======>: ' + AppliCurrentAddress);
        
            AppliPermanentAddress= [SELECT Id,Name,Lead__c,Address_Type__c,Address_Proof__c,Address_1__c,City__c,
                                                Country__c,District__c,Landmark__c,Pin_Code__c,State__c,Taluka__c,
                                                Same_as_Current_Address__c FROM ContactPointAddress WHERE Account__c =:appliAcc.Account__c 
                                                  AND Name='Permanent'];
            //System.debug('AppliPermanentAddress======>: ' + AppliPermanentAddress);
        }
        catch (Exception e) {
            System.debug('Exception occured.');
        }
        
        List<Education_Details__c> AppliEduDetails;
        try{
            AppliEduDetails = [Select Id, Name,Lead__c,Education_Qualification__c,Year_Completed__c, 
                               Percentage_Marks_CGPA__c, CGPA__c,School_College_University__c,Course_Start_Date__c,University_Name__c, Course_Name__c 
                               From Education_Details__c  WHERE Account__c =:appliAcc.Account__c AND Lead__r.Id=:leadGetId];
        }
        catch (Exception e) {
            System.debug('Exception occured.');
        }
        
        List<Co_Applicant__c> coApplicantAcc;
        try{
            coApplicantAcc = [SELECT Id, Name,Type__c,Account__r.Lead__c,Relation_with_applicant__c,Relationship_Proof__c,Applicant_Type__c,Account__c,Account__r.Name, Account__r.Mobile_Number__c, 
                                    Account__r.FirstName,Account__r.MiddleName, 
                                    Account__r.LastName,Account__r.Father_First_Name__c, Account__r.Father_Middle_Name__c, 
                                    Account__r.Father_Last_Name__c,Account__r.Gender__c, 
                                    Account__r.PAN_Number__c, Account__r.Aadhar_Number__c,Account__r.Driving_License_Number__c, Account__r.Voter_ID__c,
                                    Account__r.Is_Income_Considered_Is_Financial__c, Account__r.Mother_Frist_Name__c, 
                                    Account__r.Mother_Middle_Name__c, Account__r.Mother_Last_Name__c, 
                                    Account__r.Marital_Status__c, Account__r.Spouse_s_First_Name__c, 
                                    Account__r.Spouse_s_Middle_name__c, Account__r.Spouse_s_Last_Name__c, 
                                    Account__r.Is_Communication_address__c,Account__r.Date_of_Birth__c FROM Co_Applicant__c WHERE Lead__c ='00QBi000003ngcHMAQ' 
                                    AND Type__c = 'Co-applicant'];
        System.debug('coApplicantAcc======>: ' + coApplicantAcc);
        }
        catch (Exception e) {
            System.debug('Exception occured Co_Applicant__c coApplicantAcc.');
        }
        
        
        List<Employment_Details__c> EmploymentDetails;
        try{
            EmploymentDetails = [SELECT Id, Name, Employment_Type__c, Name_Of_The_Company__c, 
                                 No_of_Years_with_Current_Employer__c, Monthly_Income__c, Official_Email_Id__c, Type_Of_Company__c, 
                                 Role_In_Organization__c, Total_Professional_Experience__c, Nature_of_Professional__c, Address_of_Current_Business__c, 
                                 Membership_Number__c, GST_IN__c, Nature_of_Business__c, Date_of_Retirement__c, Organisation_Name__c, Pension_Amount__c, 
                                 Account__c,Account__r.Name, Lead__c, Demography__c FROM Employment_Details__c  WHERE Lead__c =: leadGetId];
            system.debug('EmploymentDetails' +EmploymentDetails);
            system.debug('EmploymentDetailsSize ' +EmploymentDetails.size());
        }
        catch (Exception e) {
            System.debug('Exception occured.');
        }
        Set<Id> setApplIds = new Set<Id>();
        List<Co_Applicant__c> lstApp = [SELECT Id, Account__r.Name,Name,Type__c,Account__c,Account__r.Id FROM Co_Applicant__c WHERE Lead__c ='00QBi000003nvjNMAQ'];
        List<Bank_Details__c> leadBankAccount = new List<Bank_Details__c>();
        List<Asset> asset;
        List<Liability__c> liability;

        for(Co_Applicant__c objApp: lstApp){
            setApplIds.add(objApp.Account__r.Id);
        }  
        
        try{
            leadBankAccount = [SELECT Id,Lead__r.Name,Account_Holder_Name__c,Account_Number__c,Account_Operational_Since__c,Account_Type__c,Bank_Branch_IFSC__c,Name_of_Bank__c,IFSC_Code__c,MICR_Code__c from Bank_Details__c Where Account__c In: setApplIds];
            System.debug('Bank Record:'+leadBankAccount);
        }
        catch(Exception e){
            System.debug('No bank record');
        }
        
        //Fetch Asset
        
        try{
            asset = [SELECT Id,Asset_Type__c,Asset_Value__c,Description from Asset where Lead__c = :setApplIds];
        }
        catch(Exception e){
            System.debug('No asset found');
        }
        
        //For Liability
        
        try{
           liability = [SELECT Id,Loan_Type__c,Monthly_Installment__c,Original_Amount__c,Outstanding_Amount__c,Balance_Tenure_In_Months__c from Liability__c where Lead__c =:setApplIds];
        }
        catch(Exception e){
            System.debug('No liability found');
        }


        wrapperClassForCommForm wc = new wrapperClassForCommForm();
        if(leadBankAccount != null)
            wc.bankAccount = leadBankAccount;
        if(asset != null)
            wc.assetDetails = asset;
        if(liability != null)
            wc.liabilityDetails = liability;
        
        // //Fetch bank accounts
        // List<Bank_Details__c> leadBankAccount = new List<Bank_Details__c>();
        // try{
        //     leadBankAccount = [SELECT Id,Lead__r.Name,Account_Holder_Name__c,Account_Number__c,Account_Operational_Since__c,Account_Type__c,Bank_Branch_IFSC__c,Name_of_Bank__c,IFSC_Code__c,MICR_Code__c from Bank_Details__c Where Lead__c = '00QBi000003nvjNMAQ'];
        //     System.debug('Bank Record:'+leadBankAccount);
        // }
        // catch(Exception e){
        //     System.debug('No bank record');
        // }
        
        // //Fetch Asset
        // List<Asset> asset;
        // try{
        //     asset = [SELECT Id,Asset_Type__c,Asset_Value__c,Description from Asset where Lead__c = '00QBi000003nvjNMAQ'];
        // }
        // catch(Exception e){
        //     System.debug('No asset found');
        // }
        
        // //For Liability
        // List<Liability__c> liability;
        // try{
        //    liability = [SELECT Id,Loan_Type__c,Monthly_Installment__c,Original_Amount__c,Outstanding_Amount__c,Balance_Tenure_In_Months__c from Liability__c where Lead__c ='00QBi000003nvjNMAQ'];
        // }
        // catch(Exception e){
        //     System.debug('No liability found');
        // }
        
        //wrapperClassForCommForm wc = new wrapperClassForCommForm();
        if(lstLead != null)
            wc.LeadRecords = lstLead;  
        if(appliAcc != null)        
            wc.AccRecords = appliAcc;
        if(AppliCurrentAddress != null)
            wc.CPAAppliCurrentRecord = AppliCurrentAddress;  
        if(AppliPermanentAddress != null)
            wc.CPAAppliPermanentRecord = AppliPermanentAddress;
         if(AppliEduDetails != null)
            wc.AppliEduDetailsRecord = AppliEduDetails;   
        if(coApplicantAcc != null)
            wc.AccCoAppliRecords = coApplicantAcc;
        if(EmploymentDetails != null)
            system.debug('EmploymentDetails=====' +EmploymentDetails);
        system.debug('INSIDE IF CONDITION');
        wc.EmploymentRecord = EmploymentDetails;
        system.debug('wc.EmploymentRecord==' +wc.EmploymentRecord);
        
        // //Change for financial section
        // if(leadBankAccount != null)
        //     wc.bankAccount = leadBankAccount;
        // if(asset != null)
        //     wc.assetDetails = asset;
        // if(liability != null)
        //     wc.liabilityDetails = liability;
        
        System.debug('wc======>: ' + wc);
        return wc;   
    }
    
    //Save financial section data
    @AuraEnabled
    public static wrapperClassForCommForm saveFinancialData(List<Bank_Details__c> financialData,List<Asset> assetData,List<Liability__c> liabilityData,String leadGetId, String removedeleteBankIds, String removedeleteAssetId, String removedeleteLiabilityIds){
        //Map<Id,Bank_Details__c> bankIds = new Map<Id,Bank_Details__c>[SELECT Id from Bank_Details__c WHERE Lead__c ='00QBi000003nvjNMAQ'];
        List<Asset> assetDataToUpsert = new List<Asset>();
        List<Liability__c> liabilityDataToUpsert = new List<Liability__c>();
        
        //Lists for Delete fuctionality
        List<Bank_Details__c> deleteBanks = new List<Bank_Details__c>();
        List<Asset> deleteAssets = new List<Asset>();
        List<Liability__c> deleteLiabilities = new List<Liability__c>();
        if(String.isNotBlank(removedeleteBankIds)){
            List<Id> BanksIds = removedeleteBankIds.split(',');
            
            deleteBanks = [SELECT Id FROM Bank_Details__c WHERE Id IN :BanksIds];
        }
        if(String.isNotBlank(removedeleteAssetId)){
            List<Id> AssetsIds = removedeleteAssetId.split(',');
            
            deleteAssets = [SELECT Id FROM Asset WHERE Id IN :AssetsIds];
        }
        if(String.isNotBlank(removedeleteLiabilityIds)){
            List<Id> LiabilitiesIds = removedeleteLiabilityIds.split(',');
            
            deleteLiabilities = [SELECT Id FROM Liability__c WHERE Id IN :LiabilitiesIds];
        }

        System.debug(financialData);
        System.debug(assetData);
        System.debug(liabilityData);
        
        if(financialData != null)
            upsert financialData;
        if(deleteBanks != null && !deleteBanks.isEmpty()){    
            delete deleteBanks;
            System.debug('@@deleteBanks Inside If=====>'+deleteBanks);
        }

        if(assetData != null){
            for(Asset a:assetData){
                if(a.Name == '' && a.Asset_Type__c == '' && a.Asset_Value__c == null && a.Description == ''){
                    System.debug('Not to add data');
                }
                else{
                    assetDataToUpsert.add(a);
                }  
            }
            upsert assetDataToUpsert;
        }
        if(deleteAssets != null && !deleteAssets.isEmpty()){    
            delete deleteAssets;
            System.debug('@@deleteAssets Inside If=====>'+deleteAssets);
        }
            
        if(liabilityData != null){
            for(Liability__c l:liabilityData){
                if(l.Loan_Type__c == '' && l.Monthly_Installment__c == null && l.Balance_Tenure_In_Months__c == null && l.Outstanding_Amount__c == null && l.Original_Amount__c == null){
                    System.debug('Not to add data');
                }
                else{
                    liabilityDataToUpsert.add(l);
                }
            }
            upsert liabilityDataToUpsert;
        }
        if(deleteLiabilities != null && !deleteLiabilities.isEmpty()){    
            delete deleteLiabilities;
            System.debug('@@deleteLiabilities Inside If=====>'+deleteLiabilities);
        }

        wrapperClassForCommForm wc = new wrapperClassForCommForm();
        wc = getFinanceData(leadGetId);
        return wc;
    }
    
    // @AuraEnabled
    // public static string getLeadId(String applicantId){
    //     Co_Applicant__c app = [Select Lead__c from Co_Applicant__c where Id =: applicantId LIMIT 1];
    //     return app.Lead__c;
    // }
    
    @AuraEnabled
    public static wrapperClassForCommForm creatCommFormLeadRecord(String wrapperCommFormDetails, String leadGetId) {
        system.debug('creatCommFormLeadRecord method called ========>'); 
        system.debug('String leadGetId Course========>' + leadGetId);  
        system.debug('wrapperCommFormDetails 585========>' + wrapperCommFormDetails);  
        //Lead upsert 
        wrapperClassForCommForm wrapperRecords = (wrapperClassForCommForm)json.deserialize(wrapperCommFormDetails,wrapperClassForCommForm.Class);      
        system.debug('wrapperRecords========>' + wrapperRecords);
        Lead singleleadSaveRecord = (Lead)json.deserialize(wrapperRecords.leadSaveRec,Lead.Class);
        system.debug('singleleadSaveRecord========>' + singleleadSaveRecord);
        if(singleleadSaveRecord != null){                
            update singleleadSaveRecord;
            system.debug('singleleadSaveRecord========>' + singleleadSaveRecord);
        }    
       
           // Co_Applicant__c AppliAccSaveRecord = (Co_Applicant__c)json.deserialize(wrapperRecords.appliAccSaveRec,Co_Applicant__c.Class);
            Account AccUpdate = (Account)json.deserialize(wrapperRecords.appliAccSaveRec,Account.Class);
            system.debug('AccUpdate========>' + AccUpdate);
            // if(AccUpdate != null){                
            //     update AccUpdate;
            //     system.debug('AccUpdate========>' + AccUpdate);
            // }  
        /*
        //For saving current address
        ContactPointAddress ApplicantcurrentAdd = (ContactPointAddress)json.deserialize(wrapperRecords.appliCurrentAddSave,ContactPointAddress.Class);
        System.debug('Current Address========>' + ApplicantcurrentAdd);
        if(ApplicantcurrentAdd != null){  
            ApplicantcurrentAdd.Name = 'Current';
            ApplicantcurrentAdd.Account__c = AccUpdate.Id;
            upsert ApplicantcurrentAdd;
            system.debug('ApplicantcurrentAdd========>' + ApplicantcurrentAdd);
        }
        
        //For saving permanent address
        ContactPointAddress ApplicantpermanentAdd = (ContactPointAddress)json.deserialize(wrapperRecords.appliPermanentAddSave,ContactPointAddress.Class);
        System.debug('Permanent Address========>' + ApplicantpermanentAdd);
        if(ApplicantpermanentAdd != null){  
            ApplicantpermanentAdd.Name = 'Permanent';
            ApplicantpermanentAdd.Account__c = AccUpdate.Id;
            upsert ApplicantpermanentAdd;
            system.debug('ApplicantpermanentAdd========>' + ApplicantpermanentAdd);
        }       */   
        
         //For saving Education_Details__c      
        
        if(wrapperRecords.appliEduDetailsSave != null){
            System.debug('wrapperRecords.appliEduDetailsSave========>' + wrapperRecords.appliEduDetailsSave);
            List<Education_Details__c> AppliEducationDetail = (List<Education_Details__c>)json.deserialize(wrapperRecords.appliEduDetailsSave,List<Education_Details__c>.Class);
            System.debug('Education_Details__c========>' + AppliEducationDetail);
            
            System.debug('wrapperRecords.removeEducationIds========>' + wrapperRecords.removeEducationIds);            
            List<Education_Details__c> deleteEdu = new List<Education_Details__c>();
            if(String.isNotBlank(wrapperRecords.removeEducationIds)){
                List<Id> eduIds = wrapperRecords.removeEducationIds.split(',');
                
                deleteEdu = [SELECT Id FROM Education_Details__c WHERE Id IN :eduIds];
            }
            List<Education_Details__c> listOfEduDetailsRec = new List<Education_Details__c>();               
            
            for(Education_Details__c objEduDetails : AppliEducationDetail){
                objEduDetails.Account__c = AccUpdate.Id;
                objEduDetails.Lead__c = singleleadSaveRecord.Id;
                listOfEduDetailsRec.add(objEduDetails);
            }
            System.debug('@@listOfEduDetailsRec=====>'+listOfEduDetailsRec);             
                if(!listOfEduDetailsRec.isEmpty()){                  
                    upsert listOfEduDetailsRec;                         
                    System.debug('@@listOfEduDetailsRec Inside If=====>'+listOfEduDetailsRec);   
                } 
                if(deleteEdu != null && !deleteEdu.isEmpty()){    
                    delete deleteEdu;
                    System.debug('@@deleteEdu Inside If=====>'+deleteEdu);
                }               
        }     
        wrapperClassForCommForm fetchEducation = new wrapperClassForCommForm();
        fetchEducation = getWrapperClassCommFormList(leadGetId);
        return fetchEducation;
       
        //return singleleadSaveRecord.Id;
    }
    
    @AuraEnabled
    public static String creatCommFormLeadRecord111(String wrapperCommFormDetails111) {
        system.debug('wrapperCommFormDetails111========>' + wrapperCommFormDetails111);  
        
        wrapperClassForCommForm wrapperRecords111 = (wrapperClassForCommForm)json.deserialize(wrapperCommFormDetails111,wrapperClassForCommForm.Class);      
        system.debug('wrapperRecords111========>' + wrapperRecords111);
         //For Loan update on lEad
       Lead LoanLeadUpdate = (Lead)json.deserialize(wrapperRecords111.loanSectionLeadRec,Lead.Class);
        System.debug('LoanLeadUpdate========>' + LoanLeadUpdate);
        if(LoanLeadUpdate != null){                
            update LoanLeadUpdate;
            system.debug('LoanLeadUpdate========>' + LoanLeadUpdate);
        } 
      
        return LoanLeadUpdate.Id;
    }
    
    public class wrapperClassForCommForm{
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

   /* @AuraEnabled(cacheable=true)
    public static List<wrapperForApplicant> getFinanceData(String leaddID){
        List<wrapperForApplicant> lstwrapperForApplicant = new List<wrapperForApplicant>();
        Map<Id,Co_Applicant__c> mapAccvsAppIds = new Map<Id,Co_Applicant__c>();
        Set<Id> setApplIds = new Set<Id>();
        List<Co_Applicant__c> lstApp = [SELECT Id, Account__r.Name,Name,Type__c,Account__c,Account__r.Id FROM Co_Applicant__c WHERE Lead__c =: leaddID];
        for(Co_Applicant__c objApp: lstApp){
            mapAccvsAppIds.put(objApp.Account__r.Id,objApp);
            setApplIds.add(objApp.Account__r.Id);
        }  
        
        List<Account> lstAcc = [Select Id,(SELECT Id,Account__r.Name,Account_Holder_Name__c,Account_Number__c,Account_Operational_Since__c,Account_Type__c,Bank_Branch_IFSC__c,Name_of_Bank__c,IFSC_Code__c,MICR_Code__c from Bank_Accounts__r) From Account where Id in: setApplIds];
        for(Account objAcc: lstAcc){
            wrapperForApplicant objwrapperForApplicant = new wrapperForApplicant();
            objwrapperForApplicant.objeAcc = objAcc;    
            objwrapperForApplicant.objApplicant = mapAccvsAppIds.get(objAcc.Id);
            SYSTEM.DEBUG('objAcc.Bank Account'+objAcc.Bank_Accounts__r);
            for(Bank_Details__c objBankAdd: objAcc.Bank_Accounts__r){
                    objwrapperForApplicant.appBankAccount = objBankAdd;                
            }
            lstwrapperForApplicant.add(objwrapperForApplicant); 
        }
        return lstwrapperForApplicant;
    }*/
    // @AuraEnabled(cacheable=true)
    // public static List<wrapperForApplicant> getFinanceData(String leaddID){
    //     List<wrapperForApplicant> lstwrapperForApplicant = new List<wrapperForApplicant>();
    //     Map<Id,Co_Applicant__c> mapAccvsAppIds = new Map<Id,Co_Applicant__c>();
    //     Set<Id> setApplIds = new Set<Id>();
    //     List<Co_Applicant__c> lstApp = [SELECT Id, Account__r.Name,Name,Type__c,Account__c,Account__r.Id FROM Co_Applicant__c WHERE Lead__c ='00QBi000003nvjNMAQ'];
    //     for(Co_Applicant__c objApp: lstApp){
    //         mapAccvsAppIds.put(objApp.Account__r.Id,objApp);
    //         setApplIds.add(objApp.Account__r.Id);
    //     }  
        
    //     List<Account> lstAcc = [Select Id,(SELECT Id,Account__r.Name,Account_Holder_Name__c,Account_Number__c,Account_Operational_Since__c,Account_Type__c,Bank_Branch_IFSC__c,Name_of_Bank__c,IFSC_Code__c,MICR_Code__c from Bank_Accounts__r) From Account where Id in: setApplIds];
    //     for(Account objAcc: lstAcc){
            
    //        // 
    //         SYSTEM.DEBUG('objAcc.Bank Account'+objAcc.Bank_Accounts__r);
    //         for(Bank_Details__c objBankAdd: objAcc.Bank_Accounts__r){
    //             wrapperForApplicant objwrapperForApplicant = new wrapperForApplicant();
    //             objwrapperForApplicant.objApplicant = mapAccvsAppIds.get(objAcc.Id);
    //             objwrapperForApplicant.objeAcc = objAcc;    
    //             objwrapperForApplicant.appBankAccount = objBankAdd; 
    //             lstwrapperForApplicant.add(objwrapperForApplicant);                
    //         }
            
    //     }
    //     return lstwrapperForApplicant;
    // }

      //Added by Avadhut Reference Get data
      @AuraEnabled
      public static List<Reference__c> getReferenceList(String leadGetId) {
        System.debug('String leadGetId ---> ' + leadGetId);
          List<Reference__c> refRecordList = new List<Reference__c>();
              refRecordList = [SELECT Id,Account__c,Lead__c,Account__r.Name,Reference_First_Name__c,Reference_Last_Name__c,Reference_Middle_Name__c,Mobile_No__c,
                              Email_Id__c,Landline_No__c,Occupation__c,Reference_Address_1__c,Reference_Address_2__c,Reference_Address_3__c,
                              City__c,District__c,State__c,Country__c,Landmark__c,Pin_Code__c 
                              FROM Reference__c 
                              WHERE Lead__c =: leadGetId];
              System.debug('Reference Record ---> ' + refRecordList);
              return refRecordList;
      }
  
      //Added by Avadhut Reference Upsert data
      @AuraEnabled
      public static List<Reference__c> createReferenceRecord(List<Reference__c> refRecordList, String removeReferenceIds, String leadGetId) {
          System.debug('refRecordList to insert or update--->' + refRecordList);
          System.debug('removeReferenceIds========>' + removeReferenceIds);    
          System.debug('Lead ID from Reference========>' + leadGetId);        
          List<Reference__c> deleteRef = new List<Reference__c>();
          if(String.isNotBlank(removeReferenceIds)){
              List<Id> referenceIds = removeReferenceIds.split(',');
              
              deleteRef = [SELECT Id FROM Reference__c WHERE Id IN :referenceIds];
          }
          if (refRecordList.size()>0) {
  
              upsert refRecordList;
              System.debug('record processed');
          }
          if(deleteRef != null && !deleteRef.isEmpty()){    
              delete deleteRef;
              System.debug('@@deleteRef Inside If=====>'+deleteRef);
          }
          //For insert the same record without duplication from form without refresh the page
          List<Reference__c> fetchReference = new List<Reference__c>();
          fetchReference = getReferenceList(leadGetId);
          System.debug('fetchReference=====>'+fetchReference);
          return fetchReference;
      }

        //Added by Avadhut Collateral Get data
        @AuraEnabled
        public static List<Asset> getCollateralAssetList(String leadGetId) {
          System.debug('String leadGetId ---> ' + leadGetId);
            List<Asset> CollateralAssetRecList = new List<Asset>();
            CollateralAssetRecList = [SELECT Id,AccountId,Lead__c,Property_Owned_By__c, Property_Owned_By__r.Name, 
            Collateral_Type__c,Asset_Value__c,Name ,Description, Area_Sq_Ft__c, Local_Authority__c, 
            Building_House_Name__c, Building_House_No__c, Wing__c, Floor__c, Survey_Plot_No__c, Pin_Code__c, 
            City__c, Area_Taluka_District_Area_name__c, State__c, Country__c, Landmark__c, Security_Offered__c from Asset WHERE Lead__c =: leadGetId AND Collateral_Type__c != null];
                System.debug('CollateralAssetRecList Record ---> ' + CollateralAssetRecList);
                return CollateralAssetRecList;
        }
   //Added by Avadhut Collateral Upsert data
   @AuraEnabled
   public static List<Asset> createCollateralSave(List<Asset> collateralRecordList, String removeCollateralIds, String leadGetId) {
       System.debug('collateralRecordList to insert or update--->' + collateralRecordList);
       System.debug('removeCollateralIds========>' + removeCollateralIds);     
       System.debug('Lead ID from Collateral========>' + leadGetId);               
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
           System.debug('record processed');
       }
       if(deleteCollateral != null && !deleteCollateral.isEmpty()){    
           delete deleteCollateral;
           System.debug('@@deleteCollateral Inside If=====>'+deleteCollateral);
       }

        //For insert the same record without duplication from form without refresh the page
       List<Asset> fetchAsset = new List<Asset>();
       fetchAsset = getCollateralAssetList(leadGetId);
       System.debug('fetchAsset=====>'+fetchAsset);
       return fetchAsset;
   }

    //Added by Avadhut Lead Owner Get data
    @AuraEnabled
    public static User getLeadOwnerInfo(String leadGetId) {
        System.debug('String leadGetId getLeadOwnerInfo ====> ' + leadGetId);
        Lead leadOwner = [SELECT Id, OwnerId FROM Lead WHERE Id =: leadGetId];
        System.debug('leadOwner Record ---> ' + leadOwner);

        User userId = [SELECT Id, Name, MobilePhone FROM User WHERE Id =: leadOwner.OwnerId];
        System.debug('userId Record ---> ' + userId);

        return userId;
    }

    //Meta Data for Language Score category
    @AuraEnabled( cacheable=true )  
    public static List < Language_Score_Setting__mdt > fetchLanguageCategory() {
        
        return [ SELECT Id, MasterLabel, Language_Category__c, Start_Range__c, End_Range__c  FROM Language_Score_Setting__mdt ];
        
    }

    //Meta Data for Analytical Score category
    @AuraEnabled( cacheable=true )  
    public static List < Analytics_Score_Setting__mdt > fetchAnalyticalCategory() {
        
        return [ SELECT Id, MasterLabel, Analytical_Category__c, Start_Range__c, End_Range__c  FROM Analytics_Score_Setting__mdt ];
        
    }

     //Meta Data for Analytical Score GRE category
     @AuraEnabled( cacheable=true )  
     public static List < Analytical_Score_GRE_Setting__mdt > fetchAnalyticalCategoryGRE() {
         
         return [ SELECT Id, MasterLabel, Analytical_Category_GRE__c, Start_Range__c, End_Range__c  FROM Analytical_Score_GRE_Setting__mdt ];
         
     }    

    //Meta Data for Collateral type movable
        @AuraEnabled( cacheable=true )  
        public static List<Collateral_Types_Based_on_LOS_API__mdt> getMovableCollTypeRecords() {
            return [SELECT Id, Label, ApiName__c, CollateralType__c FROM Collateral_Types_Based_on_LOS_API__mdt WHERE ApiName__c = 'movable'];
        }

    //Meta Data for Collateral type immovable
        @AuraEnabled( cacheable=true )  
        public static List<Collateral_Types_Based_on_LOS_API__mdt> getImmovableCollTypeRecords() {
            return [SELECT Id, Label, ApiName__c, CollateralType__c FROM Collateral_Types_Based_on_LOS_API__mdt WHERE ApiName__c = 'immovable'];
        }
    
    //To delete collateral
    @AuraEnabled
    public static void deleteCollateral(String ids){
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
}