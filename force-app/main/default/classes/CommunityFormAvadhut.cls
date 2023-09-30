/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 01-18-2023
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

public class CommunityFormAvadhut {
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
    
    //To get City,State,Country according to Pincode
    @AuraEnabled
    public static Area__c getPincodeRecord(Id pincode){
        Area__c area = new  Area__c();
        area = [Select Id,City_Name__c,State__c,Country__c,Area_Name_Taluka__c From Area__c 
                WHERE Id =: pincode];
        return area;
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
    //To get Employment Data
    @AuraEnabled(cacheable=true)
    public static list<Employment_Details__c> getEmploymentDetails(){
        list<Employment_Details__c> employmentList = [SELECT Id, Name, Account__c,Account__r.Name,Address_of_Current_Business__c,Date_of_Retirement__c,
                                                      Demography__c,Employment_Type__c,GST_IN__c,Lead__c,Membership_Number__c,
                                                      Monthly_Income__c,Name_Of_The_Company__c,Nature_of_Business__c,Nature_of_Professional__c,
                                                      No_of_Years_with_Current_Employer__c,Official_Email_Id__c,Organisation_Name__c,Pension_Amount__c,
                                                      Role_In_Organization__c,Total_Professional_Experience__c,Type_Of_Company__c
                                                      FROM Employment_Details__c WHERE Lead__c= '00QBi000003guP3MAI'];
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
    
    //Return Co_Applicant__c related lead
    @AuraEnabled(cacheable=true)
    public static List<Co_Applicant__c> getleadWithApplicantsRec(){
        List<Co_Applicant__c> applicantsWithLeadIdRec = new  List<Co_Applicant__c>();
        applicantsWithLeadIdRec = [Select Id, Name, Account__r.Name,Lead__r.Name, Lead__r.Id,Lead__r.Is_Income_Considered_Is_Financial__c,Type__c
                                   from Co_Applicant__c where Lead__r.Id = '00QBi000003guP3MAI'];
        System.debug('applicantsWithLeadIdRec======>: ' + applicantsWithLeadIdRec);
        return applicantsWithLeadIdRec;         
    }
    
    
    @AuraEnabled(cacheable=true)
    public static wrapperClassForCommForm getWrapperClassCommFormList() {    
        // System.debug('String leaddID======>: ' + leaddID);
        Lead lstLead;
        try{
            lstLead = [Select Id,Salutation,FirstName,MiddleName,LastName,Date_of_Birth__c,MobilePhone,Email,Country_of_Study__c,
                       Admission_Status__c,University_Name__c,Course_Category__c,Course_Type__c,Course_Level__c,Course_Stream__c,Course_Name_Lookup__c,
                       Course_Start_Date__c,Course_End_Date__c,Analytics_Score_Category__c,Analytics_Test_Score__c,Language_Score_Category__c,
                       Language_Test_Score__c,Tuition_Fees__c,Living_Hostel_Food_Expenses__c,Traveling_Expenses__c,Other_Costs__c,Own_Source__c,
                       Scholarship__c,Others_Fund__c,Reference_First_Name__c,Reference_Middle_Name__c,Reference_Last_Name__c,Reference_Address_1__c,
                       Reference_Address_2__c,Reference_Address_3__c,Mobile_No_Reference__c,Email_Reference__c,Landline_No_Reference__c,
                       Occupation_Reference__c,City_Name_Reference__c,State_Reference__c,Area_Taluka_District_Area_name_Reference__c,
                       Country_Reference__c,Landmark_Reference__c,Pin_Code_Reference__c,Total_Costs__c,Total_Funds__c,
                       Loan_Required_A_B__c, Institute_Name__c, Campus__c From Lead Where id ='00QBi000003ngcHMAQ']; 
            
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
                        Account__r.Mother_Middle_Name__c, Account__r.Mother_Last_Name__c, Account__r.Mother_Frist_Name__c,
                        Account__r.Marital_Status__c, Account__r.Spouse_s_First_Name__c, 
                        Account__r.Spouse_s_Middle_name__c, Account__r.Spouse_s_Last_Name__c, 
                        Account__r.Is_Communication_address__c,Account__r.Date_of_Birth__c FROM Co_Applicant__c WHERE Lead__c = '00QBi000003ngcHMAQ' LIMIT 1];
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
                               Percentage_Marks_CGPA__c, School_College_University__c  
                               From Education_Details__c  WHERE Account__c =:appliAcc.Account__c];
        }
        catch (Exception e) {
            System.debug('Exception occured.');
        }
        
        List<Employment_Details__c> EmploymentDetails;
        try{
            EmploymentDetails = [SELECT Id, Name, Employment_Type__c, Name_Of_The_Company__c, 
                                 No_of_Years_with_Current_Employer__c, Monthly_Income__c, Official_Email_Id__c, Type_Of_Company__c, 
                                 Role_In_Organization__c, Total_Professional_Experience__c, Nature_of_Professional__c, Address_of_Current_Business__c, 
                                 Membership_Number__c, GST_IN__c, Nature_of_Business__c, Date_of_Retirement__c, Organisation_Name__c, Pension_Amount__c, 
                                 Account__c, Lead__c, Demography__c FROM Employment_Details__c  WHERE Account__c =:appliAcc.Account__c];
            system.debug('EmploymentDetails' +EmploymentDetails);
            system.debug('EmploymentDetailsSize ' +EmploymentDetails.size());
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
        
        wrapperClassForCommForm wc = new wrapperClassForCommForm();
        
        if(lstLead != null)
            wc.LeadRecords = lstLead;  
            system.debug('wc.LeadRecords===>'+ wc.LeadRecords);
        if(appliAcc != null)        
            wc.AccRecords = appliAcc;
            system.debug('wc.AccRecords===>'+ wc.AccRecords);
        if(AppliCurrentAddress != null)
            wc.CPAAppliCurrentRecord = AppliCurrentAddress;  
            system.debug('wc.CPAAppliCurrentRecord===>'+ wc.CPAAppliCurrentRecord);
        if(AppliPermanentAddress != null)
            wc.CPAAppliPermanentRecord = AppliPermanentAddress;
            system.debug('wc.CPAAppliPermanentRecord===>'+ wc.CPAAppliPermanentRecord);
        if(AppliEduDetails != null)
            wc.AppliEduDetailsRecord = AppliEduDetails;   
            system.debug('wc.AppliEduDetailsRecord===>'+ wc.AppliEduDetailsRecord);
        if(coApplicantAcc != null)
            wc.AccCoAppliRecords = coApplicantAcc;
            system.debug('wc.AccCoAppliRecords===>'+ wc.AccCoAppliRecords);
        if(EmploymentDetails != null)
            system.debug('EmploymentDetails=====' +EmploymentDetails);     
        wc.EmploymentRecord = EmploymentDetails;
        system.debug('wc.EmploymentRecord==' +wc.EmploymentRecord);
        
        
        System.debug('wc======>: ' + wc);
        system.debug('wcEmployment>:' +wc.EmploymentRecord);
        return wc;   
    }
    
    @AuraEnabled
    public static String creatCommFormLeadRecord(String wrapperCommFormDetails) {
        system.debug('wrapperCommFormDetails========>' + wrapperCommFormDetails);  
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
        if(AccUpdate != null){                
            update AccUpdate;
            system.debug('AccUpdate========>' + AccUpdate);
        }  
        
        //For saving current address
        if(wrapperRecords.appliCurrentAddSave != null){
            ContactPointAddress ApplicantcurrentAdd = (ContactPointAddress)json.deserialize(wrapperRecords.appliCurrentAddSave,ContactPointAddress.Class);
            System.debug('Current Address========>' + ApplicantcurrentAdd);
            if(ApplicantcurrentAdd != null){  
                ApplicantcurrentAdd.Name = 'Current';
                ApplicantcurrentAdd.Account__c = AccUpdate.Id;
                upsert ApplicantcurrentAdd;
                system.debug('ApplicantcurrentAdd========>' + ApplicantcurrentAdd);
            }
        }
        //For saving permanent address
        if(wrapperRecords.appliPermanentAddSave != null){
            ContactPointAddress ApplicantpermanentAdd = (ContactPointAddress)json.deserialize(wrapperRecords.appliPermanentAddSave,ContactPointAddress.Class);
            System.debug('Permanent Address========>' + ApplicantpermanentAdd);
            if(ApplicantpermanentAdd != null){  
                ApplicantpermanentAdd.Name = 'Permanent';
                ApplicantpermanentAdd.Account__c = AccUpdate.Id;
                upsert ApplicantpermanentAdd;
                system.debug('ApplicantpermanentAdd========>' + ApplicantpermanentAdd);
            }          
        }
        //For saving Education_Details__c
        //List<Account> listOfAccounts = (List<Account>)json.deserialize(wrapperrec.personAccStr, List<Account>.Class);
        
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
        
        //For Loan update on lEad
        /*Lead LoanLeadUpdate = (Lead)json.deserialize(wrapperRecords.loanSectionLeadRec,Lead.Class);
System.debug('LoanLeadUpdate========>' + LoanLeadUpdate);
if(LoanLeadUpdate != null){                
upsert LoanLeadUpdate;
system.debug('LoanLeadUpdate========>' + LoanLeadUpdate);
}  */       
        return singleleadSaveRecord.Id;
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
    } 
    @AuraEnabled
    public static void saveBase64File(Id leadId, Id accountId, String base64File, String fileName) {
        // Create new ContentVersion record
        ContentVersion cv = new ContentVersion();
        cv.Title = fileName;
        cv.PathOnClient = fileName;
        cv.VersionData = EncodingUtil.base64Decode(base64File);
        cv.Origin = 'H';
        cv.FirstPublishLocationId = accountId;
        System.debug(cv);
        insert cv;
        
        // Create new ContentDocumentLink record
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
            SELECT ContentDocumentId FROM ContentVersion WHERE ContentDocumentId = 'a06Bi000003OfMrIAK'
        ].Id;
        cdl.LinkedEntityId = leadId;
        cdl.ShareType = 'V';
        try {
            insert cdl;
            
        } catch(DMLException e) {
            System.debug(e);
            
        }
    }
}