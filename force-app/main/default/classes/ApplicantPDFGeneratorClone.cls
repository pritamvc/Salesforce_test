public class ApplicantPDFGeneratorClone {
    
    //public List<Co_Applicant__c> accountData { get; set; }
    public List<Account> accountData { get; set; }
    public List<Lead> leadData { get; set; }
    // public List<Lead> Leadrecord { get; set; }
    public List<Co_Applicant__c> applicantrecd { get; set; }
    public List<Demography__c> demography { get; set; }
    public List<ContactPointAddress> addressCurrent { get; set; }
    public List<ContactPointAddress> addressPermt { get; set; }
    public List<ContactPointAddress> officeaddress { get; set; }
    public List<Co_Applicant__c> coapplicantrecd { get; set; }
    public List<ContactPointAddress> coaddressCurrent { get; set; }
    public List<ContactPointAddress> coaddressPermt { get; set; }
    public List<Education_Details__c> educationrecrds { get; set; }
    public List<Employment_Details__c> Employmentrecrd { get; set; }
    public list<lead>leadrecord{get;set;}
    public list<lead>CourseAcademicrecrd{get;set;}
    public list<Bank_Details__c>BankAccountrecrd{get;set;}
    public list<Asset>Assetrecrd{get;set;}
    public list<Liability__c>Liabilityrecrd{get;set;}
    public list<Asset>Collateralrecrd{get;set;}
    public list<Reference__c>referencrrecrd{get;set;}
    public list<Reference__c>referencaddrrecrd{get;set;}
    public String leadid {get;set;}
    public Set<String> filesDownloadURL {set;get;}
    
    
    public ApplicantPDFGeneratorClone(ApexPages.StandardController controller) {
        
        //String AccountId = ApexPages.currentPage().getParameters().get('id');
        Lead l = (Lead)controller.getRecord();
        //system.debug('Lead record  :' +l);
        leadid = l.Id;
        //Assuming you have SF FILES
        List<ContentDocumentLink> cdLinks =[Select id,ContentDocument.LatestPublishedVersionID from ContentDocumentLink where LinkedEntityId=:leadid ORDER BY SystemModstamp DESC LIMIT 1];
        system.debug('cdLinks' +cdLinks);
        filesDownloadURL =new Set<String>();
        for(ContentDocumentLink cdl: cdLinks){
            filesDownloadURL.add(URL.getSalesforceBaseUrl().toExternalForm() +'/sfc/servlet.shepherd/version/download/'+cdl.ContentDocument.LatestPublishedVersionID);
        }
        
        // Assuming you have Attachments
        
        List<Attachment> attachmentLink = [Select id from Attachment where ParentId=:leadid ];
        
        for(Attachment att: attachmentLink){
            filesDownloadURL.add(URL.getSalesforceBaseUrl().toExternalForm() +'/servlet/servlet.FileDownload?file='+att.Id);
        }
        
        //system.debug('leadid  : ' +leadid);
        //leadid = (Lead)standardPageController.getRecord(); 
        
        //String leadid='00QBi000004tDn7MAE';
        //apexpages.currentpage().getparameters().get('id');
        // String leadid=apexpages.currentpage().getparameters().get('id');
        //system.debug('leadid' +leadid);
        //ApexPages.CurrentPage().getparameters().get('id');
        basicdetails(leadid);
        coapplicantdetails(leadid);
        Leaddetails(leadid);
        Educationdetails(leadid);
        Employmentdetails(leadid);
        bankAccountdetails(leadid);
        Assetsdetails(leadid);
        Liabilitydetails(leadid);
        Collateraldetails(leadid);
        referencedetails(leadid);
        //referencedaddressdetails(leadid);
    }
    
    public void basicdetails(String leadid){
        leadData = new List<Lead>();
        
        leadData = [select id from lead where id=:leadid limit 1];
        applicantrecd=[select Name,Is_Income_Considered_Financial__c,Account__c,Account__r.NREG_Number__c,Account__r.Voter_ID__c,Account__r.CKYC_Number__c,Account__r.Name,Account__r.Passport_File_Number__c,Account__r.Passport_Number__c,Account__r.LastName,Account__r.Aadhar_Number__c,Account__r.PAN_Number__c,Account__r.Date_of_Birth__c,Account__r.MiddleName,Account__r.Email__c, Account__r.Gender__c, Account__r.Marital_Status__c,Account__r.Salutation,Account__r.FirstName from Co_Applicant__c where Type__c ='Applicant' and Lead__c=:leadData[0].id limit 1];
        demography=[select Father_s_First_Name__c,Father_s_Last_Name__c, Father_s_Middle_Name__c,Mother_s_First_Name__c,Mother_s_Last_Name__c,Mother_s_Middle_Name__c,Account__c from Demography__c where Account__c=: applicantrecd[0].Account__c limit 1];
        System.debug('demography'+demography[0].id);
        addressCurrent=[SELECT Pin_Code__r.Name,Address_1__c,State__c,State,Street,City,District__c,Address,Address_Proof__c,Pin_Code__c,Taluka__c,  Country,City__c,  Landmark__c,Country__c,AddressType FROM ContactPointAddress where Address_Type__c='Current Address' and Account__c=:applicantrecd[0].Account__c Limit 1];
        System.debug('addressCurrent'+addressCurrent[0].id);
        addressPermt=[SELECT Pin_Code__r.Name,Address_1__c,Same_as_Current_Address__c,State__c,State,Street,District__c,Address,Address_Proof__c,Pin_Code__c,Taluka__c,  City__c,  Landmark__c,Country,Country__c,AddressType,Is_Communication_address__c,   Years_In_The_Address__c FROM ContactPointAddress where Address_Type__c='Permanent Address' and Account__c=:applicantrecd[0].Account__c Limit 1];
        //System.debug('addressCurrent'+addressPermt[0].id);
        officeaddress=[SELECT Address_1__c,Pin_Code__r.Name,State,State__c,Street,City,District__c,Address,Address_Proof__c,Pin_Code__c,Taluka__c,  City__c,Country,  Landmark__c,Country__c,Address_Type__c FROM ContactPointAddress where Address_Type__c='Office' and Account__c=:applicantrecd[0].Account__c Limit 1];
        //System.debug('addressCurrent'+officeaddress[0].id);
        
        
        
    }
    
    public void coapplicantdetails(String leadid){
        leadData = new List<Lead>();
        
        leadData = [select id from lead where id=:leadid limit 1];
        // List<Co_Applicant__c> coapplicantrecd= new List<Co_Applicant__c>();
        coapplicantrecd=[select Is_Income_Considered_Financial__c,Type__c,Relationship_Proof__c,Relation_with_applicant__c,Date_of_Birth__c,Account__c,Account__r.NREG_Number__c,Account__r.Voter_ID__c,Account__r.CKYC_Number__c,Account__r.Name,Account__r.Passport_File_Number__c,Account__r.Aadhar_Number__c,Account__r.Passport_Number__c,Account__r.PAN_Number__c,Account__r.Date_of_Birth__c,Account__r.MiddleName,Account__r.LastName,Account__r.Email__c, Account__r.Gender__c, Account__r.Marital_Status__c,Account__r.Salutation,Account__r.FirstName from Co_Applicant__c where (Type__c =:CommonConstant.COAPPLICANT OR Type__c = 'Guarantor') AND Lead__c=:leadData[0].id];
        CoaddressCurrent=[SELECT Country,Address_1__c,Pin_Code__r.Name,State__c,State,Street,District__c,Address,Address_Proof__c,Pin_Code__c,Taluka__c,  City__c,  Landmark__c,Country__c,AddressType,   Years_In_The_Address__c FROM ContactPointAddress where Address_Type__c='Current Address' and Account__c=:coapplicantrecd[0].Account__c Limit 1];
        System.debug('addressCurrent'+addressCurrent[0].id);
        CoaddressPermt=[SELECT Same_as_Current_Address__c,Pin_Code__r.Name,State__c,Address_1__c,State,Street,City,District__c,Address,Address_Proof__c,Pin_Code__c,Taluka__c,  City__c,  Landmark__c,Country,Country__c,AddressType,Is_Communication_address__c,   Years_In_The_Address__c FROM ContactPointAddress where Address_Type__c='Permanent Address' and Account__c=:coapplicantrecd[0].Account__c Limit 1];
        System.debug('addressCurrent'+addressCurrent[0].id);
        
        
    }  
    public void Educationdetails(String leadid){ 
        leadData = new List<Lead>();
        //String leadid='00QBi000004t5chMAA';
        leadData = [select id from lead where id=:leadid limit 1];
        educationrecrds = [select School_College_University__c,Account__c,CGPA__c,Year_Completed__c,Course_Start_Date__c,
                           Education_Qualification__c,Percentage_Marks_CGPA__c,Course_Stream__c,Course_Name__c,University_Name__c 
                           from Education_Details__c where Lead__c=:leadData[0].id ];
        
        
    }
    public void Employmentdetails(String leadid){ //Applicant Type,Applicant Name from Applicant 
        //  leadData = new List<Lead>();
        //String leadid='00QBi000004t5chMAA';
        leadData = [select id from lead where id=:leadid limit 1];
        Employmentrecrd = [SELECT Account__c, Account__r.Name,Account__r.Applicant_Type__c,Total_Professional_Experience__c,  No_of_Years_with_Current_Employer__c,Role_In_Organization__c,
                           Employment_Type__c,Nature_of_Professional__c,Membership_Number__c,Name_Of_The_Company__c,  
                           Type_Of_Company__c,GST_IN__c,Monthly_Income__c,Date_of_Retirement__c,Organisation_Name__c,
                           Pension_Amount__c,
                           Official_Email_Id__c from Employment_Details__c where Lead__c=:leadData[0].id];
        system.debug('Employmentrecrd' +Employmentrecrd);
    }
    
    public void Leaddetails(String leadid){
        //leadData = new List<Lead>();
        // String leadid='00QBi000004sAcqMAE';
        //  leadData = [select id from lead where id=:leadid limit 1];
        Leadrecord = [SELECT University_Name__r.Name,Institute_Name__r.Name,Country_of_Study__c,Other_Costs__c,Admission_Status__c,
                      Analytics_Score_Category__c, Quantitative_Score__c,Verbal_Score__c,  Analytics_Test_Score__c,  
                      Language_Score_Category__c,Language_Test_Score__c,  Course_Name_Lookup__c,  
                      Institute_Name__c,Course_Level__c,  Course_Type__c,  Course_Stream__c,  
                      Course_Start_Date__c,Course_End_Date__c,  University_Name__c,  Campus__c,  
                      Course_Category__c,Living_Hostel_Food_Expenses__c,  Tuition_Fees__c,
                      Traveling_Expenses__c,Total_Costs__c,Own_Source__c,Scholarship__c,  
                      Others_Fund__c,Total_Funds__c,  Loan_Required_A_B__c from Lead where id=:leadid limit 1];
        
    }
    
    public void bankAccountdetails(String leadid){ //Applicant Name
        leadData = [select id from lead where id=:leadid limit 1];
        BankAccountrecrd = [SELECT   Account__c, Account__r.Name,Account_Holder_Name__c,  Bank_Branch_IFSC__c,  
                            Bank_Branch_IFSC__r.Name,Bank_Name__c,   IFSC_Code__c,MICR_Code__c,  
                            Account_Number__c,  Account_Type__c,
                            Account_Operational_Since__c from Bank_Details__c where Lead__c=:leadData[0].id];
        
    }
    public void Assetsdetails(String leadid){ //Applicant Name
        leadData = [select id from lead where id=:leadid limit 1];
        Assetrecrd = [SELECT Lead__c,AccountId, Account.Name,Asset_Type__c,Lead__r.Asset_Description__c,Pin_Code__c,Pin_Code__r.Name,Asset_Value__c,Security_Offered__c,  
                      Description from Asset where Lead__c=:leadData[0].id];
        
    }
    public void Liabilitydetails(String leadid){ //Applicant Name
        
        leadData = [select id from lead where id=:leadid limit 1];
        Liabilityrecrd = [SELECT Monthly_Installment__c,Account__c,Original_Amount__c, Account__r.Name,  Loan_Type__c,Outstanding_Amount__c,Balance_Tenure_In_Months__c from   Liability__c where Lead__c=:leadData[0].id];
        
    }
    public void Collateraldetails(String leadid){ 
        leadData = [select id from lead where id=:leadid limit 1];
        Collateralrecrd = [SELECT Lead__c,Security_Offered__c,
                           Property_Owned_By__c,AccountId, Account.Name,State__c,  
                           Landmark__c,  Country__c,  Wing__c,Pin_Code__c,Pin_Code__r.Name,
                           Area_Taluka_District_Area_name__c,  City__c,Floor__c,Survey_Plot_No__c,  
                           Building_House_Name__c,Building_House_No__c,  Collateral_Type__c,  
                           Asset_Value__c,Area_Sq_Ft__c,Local_Authority__c from Asset where Lead__c=:leadData[0].id AND Security_Offered__c='Yes' ];
        
    }
    public void referencedetails(String leadid){ 
        leadData = [select id from lead where id=:leadid limit 1];
        referencrrecrd = [SELECT Reference_Address_1__c,Pin_Code__r.Name,Pin_Code__c,Reference_Address_2__c,  Reference_Address_3__c,District__c,  State__c,Landmark__c,City__c,Country__c,Reference_First_Name__c,Reference_Middle_Name__c,Reference_Last_Name__c,Mobile_No__c,  Email_Id__c,Landline_No__c,Occupation__c from   Reference__c where Lead__c=:leadData[0].id];
        
    }
   
    
}