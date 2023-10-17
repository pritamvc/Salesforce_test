public class TestOrgDataFactory {
    
    public static List<Lead> createLeadList(Boolean isInsert ){
        List<Lead> leadList = new List<Lead>();
        Lead LeadObj = new Lead(FirstName = 'Vibhav', LastName = 'Singh', Email = 'vaibhavsinghtst@gmail.com',MobilePhone = '7200000041', Status='Fresh',KYC_Consent__c = true,csvUserName__c = 'external02@auxilo.com');
        leadList.add(LeadObj);
        Lead LeadObj2 = new Lead(FirstName = 'Vibhav', LastName = 'Singh', Email = 'vaibhavsinghtst2@gmail.com',MobilePhone = '7200000042', Status='Sales Processing',KYC_Consent__c = true,csvUserName__c = 'external02@auxilo.com');
        leadList.add(LeadObj2);
        Lead LeadObj3 = new Lead(FirstName = 'Vibhav', LastName = 'Singh', Email = null,MobilePhone = '7200000042',csvUserName__c = 'external02@auxilo.com', KYC_Consent__c = true);
        leadList.add(LeadObj3);
        Lead LeadObj4 = new Lead(FirstName = 'Vibhav', LastName = 'Singh', Email = 'vaibhavsinghtst4@gmail.com',MobilePhone = null, Status='Sales Processing',KYC_Consent__c = true,csvUserName__c = 'external02@auxilo.com');
        leadList.add(LeadObj4);
        Lead LeadObj5 = new Lead(FirstName = 'Vibhav', LastName = 'Singh', Email = 'vaibhavsinghtst2@gmail.com',MobilePhone = '7200000042', Status='Sales Processing',KYC_Consent__c = true,csvUserName__c = 'external02@auxilo.com');
        leadList.add(LeadObj5);
        Lead LeadObj6 = new Lead(FirstName = 'Ganesh', LastName = 'Patil', Email = 'patilganeshtstst@gmail.com',MobilePhone = '7312124586', Status='Sales Processing',KYC_Consent__c = true,csvUserName__c = 'external02@auxilo.com');
        leadList.add(LeadObj6);
        Lead LeadObj7 = new Lead(FirstName = 'Ganesh', LastName = 'Kale', Email = 'kaleganeshtstst@gmail.com',MobilePhone = '7364824586', Status='Sales Processing',KYC_Consent__c = true,csvUserName__c = 'external02@auxilo.com');
        leadList.add(LeadObj7);
        Lead LeadObj8 = new Lead(FirstName = 'Nitin', LastName = 'Mali', Email = 'nitinmali644554@gmail.com',MobilePhone = '7364824589', Status='Sales Processing',KYC_Consent__c = true,csvUserName__c = 'external02@auxilo.com');
        leadList.add(LeadObj8);
        Lead LeadObj9 = new Lead(FirstName = 'Nitin', LastName = 'Mali', Email = 'nitinmali644554@gmail.com',MobilePhone = '+7415587451', Status='Sales Processing',KYC_Consent__c = true,csvUserName__c = null);
        leadList.add(LeadObj9);
        Lead LeadObj10 = new Lead(FirstName = 'Pankaj', LastName = 'Mali', Email = 'pankajmalitstrr@gmail.com',MobilePhone = '7415587453', Status='Sales Processing',KYC_Consent__c = true,csvUserName__c = 'external02@auxilo.com');
        leadList.add(LeadObj10);
        Lead LeadObj11 = new Lead(FirstName = 'Pankaj', LastName = 'Mali', Email = 'pankajmalitstrr1245@gmail.com',MobilePhone = '7415587453');
        leadList.add(LeadObj11);
        Lead LeadObj12 = new Lead(FirstName = 'Suraj', LastName = 'nemane', Email = 'mahadev123@gmail.com',MobilePhone = '7894561400');
        leadList.add(LeadObj12);
        Lead LeadObj13 = new Lead(FirstName = 'Suraj', LastName = 'nemane', Email = 'mahadev12345@gmail.com',MobilePhone = '7878789');
        leadList.add(LeadObj13);
        Lead LeadObj14 = new Lead(FirstName = 'Suraj', LastName = 'nemane', Email = 'mahadev12345.com',MobilePhone = '7878789784');
        leadList.add(LeadObj14);
        Lead LeadObj15 = new Lead(FirstName = 'Suraj1122', LastName = 'nemane', Email = 'mahadev1478@gmail.com',MobilePhone = '7870009777');
        leadList.add(LeadObj15);
        Lead LeadObj16 = new Lead(FirstName = 'Suraj', LastName = 'nemane@1122', Email = 'mahadev1010@gmail.com',MobilePhone = '7878784712');
        leadList.add(LeadObj16);
        Lead LeadObj17 = new Lead(FirstName = 'Suraj', LastName = 'nemane', Email = 'mahadev1010@gmail.com' ,MobilePhone = null);
        leadList.add(LeadObj17);
        Lead LeadObj18 = new Lead(FirstName = 'Suraj', LastName = null, Email = 'suraj112331@gmail.com' ,MobilePhone = '5075588712');
        leadList.add(LeadObj18);
        Lead LeadObj19 = new Lead(FirstName = 'Vikas', LastName = 'Raje', Email = 'Vikas.com' ,MobilePhone = '787878');
        leadList.add(LeadObj19);
        Lead LeadObj20 = new Lead(FirstName = 'Vikas', LastName = 'Raje', Email = 'Vikas@gmail.com' ,MobilePhone = '7878784545',csvUserName__c = 'externa@auxilo.com');
        leadList.add(LeadObj20);
        Lead LeadObj21 = new Lead(FirstName = 'Vikas', LastName = 'Raje', Email = 'Vikasggh@gmail.com' ,MobilePhone = '7814778454',Gender__c ='Famale');
        leadList.add(LeadObj21);
        Lead LeadObj22 = new Lead(FirstName = 'Mangesh', LastName = 'Jadhav', Email = 'mangeshjadhavtsts@gmail.com' ,MobilePhone = '7814545754',KYC_Consent__c = true, Status='Fresh');
        leadList.add(LeadObj22); 
        Lead LeadObj23 = new Lead(FirstName = 'Vikram', LastName = 'Kate', Email = 'vikramkateststsg@gmail.com' ,MobilePhone = '7817864254',KYC_Consent__c = true, Status='Fresh',csvUserName__c ='vaibhavhinge@thinqloud.com');
        leadList.add(LeadObj23);
        
        if(isInsert)
            insert leadList;
        return leadList;
    }
    public static Bank_Branch_IFSC__c  createBankBranchIFSC(Boolean isInsert){
        Bank_Branch_IFSC__c  BankBranchIFSCobj = new Bank_Branch_IFSC__c(Name= 'BKC-NAMANCHAMBERSBRANCH');
        if(isInsert)
            insert BankBranchIFSCobj ;
        return BankBranchIFSCobj;
    } 
    public static Bank_Details__c  createBankDetails(Boolean isInsert){
        Bank_Details__c  BankDetailsobj = new Bank_Details__c(Account_Holder_Name__c= 'Akshay varma',Account_Number__c ='180201002445',Account_Type__c='Current Account',Name_of_Bank__c= createBank(true).Id,Bank_Branch_IFSC__c= createBankBranchIFSC(true).Id);
        if(isInsert)
            insert BankDetailsobj ;
        return BankDetailsobj ;
    } 
    
     public static Bank__c  createBank(Boolean isInsert){
        Bank__c  Bankobj = new Bank__c(Name= 'The Shirpur Peoples Co-op Bank LTD',Bank_Code__c = 22);
        if(isInsert)
            insert Bankobj ;
        return Bankobj;
    } 
    public static Liability__c createLiability(Boolean isInsert){
        Liability__c Liabilitysobj = new Liability__c(Loan_Type__c = 'BL');
        if(isInsert)
            insert Liabilitysobj ;
        return Liabilitysobj ;
    } 
    public static Asset createAsset(Boolean isInsert){
        Asset AssetObj = new Asset(Name = 'Test Asset',Asset_Type__c  = 'Gold',Asset_Value__c  = 1000000);
        if(isInsert)
            insert AssetObj;
        return AssetObj;
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
     // Create User Record
        public static User createUser(Boolean isInsert){
            Profile profileId = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            User UserObj = new User( FirstName = 'John', LastName = 'Doe',Email = 'johndoe@example.com',Username = 'johndoeauxilo@example.com',Alias = 'jdoe',ProfileId = profileId.Id, TimeZoneSidKey = 'America/Los_Angeles',LocaleSidKey = 'en_US',EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US');
            if(isInsert)
                insert UserObj;
            return UserObj;
        }
    
    public static Lead createLead(Boolean isInsert ){
        University__c universityObj = new University__c();
        Course__c courseObj = new Course__c();
        Source__c sourceObj = new Source__c();
        sourceObj.Name = 'XYZ';
        insert sourceObj;
        Lead LeadObj = new Lead( Source_Name__c=sourceObj.Id,FirstName = 'MangeshtEST',Course_Id__c =courseObj.Id,University_Name__c= universityObj.Id, LastName = 'JadhavtEST',	Source_Category__c  = 'Partner',Email = 'mangeshjadhavtsts@TEST.com' ,MobilePhone = '7814545548',KYC_Consent__c = true, Status='Fresh',OwnerId = userinfo.getUserId());
        if(isInsert)
            insert LeadObj;
        return LeadObj;
    }
   public static University__c createUniversity(Boolean isInsert,String countryName) {
            University__c universityObj = new University__c(Name = 'Test University',Country_Name__c = countryName,Country_Code__c='123456');
            if(isInsert)
            insert universityObj;
        return universityObj;
        }

        public static Institute__c createInstitute(Boolean isInsert,Id universityId) {
            Institute__c instituteObj = new Institute__c(Name = 'Test Institute',University__c = universityId, Address__c='New Avenue',State__c='NJ',Ranking_by_Auxilo__c= 'A',City__c='NY',Country__c ='USA');
            if(isInsert)
            insert instituteObj;
        return instituteObj;
        }
        

    public static Course__c createCourse(Boolean isInsert,Id instituteId) {
            Course__c courseObj = new Course__c(Course_Name__c= 'MBA',Course_Id__c = 1234,Institute__c = instituteId);
            if(isInsert)
            insert courseObj;
        return courseObj;
        }
    public static Area__c createArea(Boolean isInsert){
        Area__c AreaObj = new Area__c(City_Code__c  = '123',City_Name__c   = 'Pune',Name = 'Test',Area_Name_Taluka__c = 'test');
        if(isInsert)
            insert AreaObj;
        return AreaObj;
    }
    public static Account createPersonAccount(Boolean isInsert){
        Account AccountObj = new Account( LastName = 'Person Account', Partner_Code__c = 'AUXMAGG001',RecordTypeId = getRecordTypeIdPersonAccount(true));
        if(isInsert)
            insert AccountObj;
        return AccountObj;
    }
    public static Co_Applicant__c CreateCoApplicant(Boolean isInsert){
        Co_Applicant__c coApplicantObj = new Co_Applicant__c(Type__c = 'Applicant', Account__c = createPersonAccount(true).Id);
        if(isInsert)
            insert coApplicantObj;
        return coApplicantObj;
    } 
    
    public static ContactPointAddress  createContactPointAddress(Boolean isInsert){
        ContactPointAddress  ContactPointAddressobj = new ContactPointAddress ( Name= 'Current',Address_Type__c='Current Address',Address_1__c ='Nashik',City__c='NASIK',State__c='MAHARASHTRA',Country__c ='INDIA',Pin_Code__c= createArea(true).Id);
        if(isInsert)
            insert ContactPointAddressobj;
        return ContactPointAddressobj;
    } 
     public static Employment_Details__c  createEmploymentdeatils(Boolean isInsert){
        Employment_Details__c Employmentdeatilssobj = new Employment_Details__c();
        if(isInsert)
            insert Employmentdeatilssobj;
        return Employmentdeatilssobj;
    } 
    public static String getRecordTypeIdPersonAccount(Boolean accountPartner ){
        String RecordTypeId;
        if(accountPartner){recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();}
        return RecordTypeId;
    } 
    
    public static Reference__c createReference(Boolean isInsert){
        Reference__c Referenceobj = new Reference__c(Reference_First_Name__c = 'Shreyas',Email_Id__c='rahul.shukla@gmail.com',Landline_No__c='1987654',Occupation__c='Working',Reference_Address_1__c='Avenue1',Reference_Address_2__c='Avenue2',Reference_Address_3__c='Avenue3',
                                                    City__c='Wakad',	District__c='Aundh',	Country__c='India', Account__c = TestDataFactory.createPersonAccount(true).Id,Pin_Code__c= createArea(true).Id);
        if(isInsert)
            insert Referenceobj ;
        return Referenceobj ;
    } 
    
    
    
    public static Task createLeadTask(Boolean isInsert,String callresult){
     	List<Lead> leadList = TestDataFactory.createLeadList(false);
                    datetime d= system.today();
            String datetimeformt= d.format();
      // Lead lrecrds=TestOrgDataFactory.createLead(true);
        //Task TaskObj = new Task(call_back_date_time_New__c=datetimeformt,agentStatus__c=callresult,Call_Result__c=callresult,callStatus__c=callresult, Subject = 'Create Task', Priority = 'High', Status = 'Open',ActivityDate = System.Today(),	Description = 'Test',	WhoId = leadList[0].id,	OwnerId = userinfo.getUserId() );
         Task TaskObj = new Task(agentId__c= Userinfo.getUserId(),Subject='Inbound',CallDisposition= 'Test Disposition',Call_Back_Date_time__c = system.today(),Sales_Comment__c='Completed', call_back_date_time_New__c=datetimeformt,agentStatus__c=callresult,Call_Result__c=callresult,callStatus__c=callresult, Priority = 'High', Status = 'Completed',ActivityDate = System.Today(),	Description = 'Test',	WhoId = leadList[0].id,	OwnerId = userinfo.getUserId() );                        
                                
        if(isInsert)
            insert TaskObj;
        return TaskObj;
    }
    
    
    // Create Campaign record
    public static Campaign createCampaign(Boolean isInsert) {
        Campaign campaignObject = new Campaign(Name = 'Fresh_Consent_Campaign',Priority__c = 0);
        if(isInsert)
            insert campaignObject;
        return campaignObject;
    }
    public static CampaignMember createCampaignMember(Boolean isInsert) {
        CampaignMember CampaignMemberObject = new CampaignMember(LeadId =createLead(true).Id , CampaignId =createCampaign(true).Id, Status = 'Sent');
        if(isInsert)
            insert CampaignMemberObject;
        return CampaignMemberObject;
    }
    
    public static List<CampaignMember> createCampaignMemberList(Boolean isInsert) {
        List<CampaignMember> CampaignMemberList= new  List<CampaignMember>();
        CampaignMemberList.add(createCampaignMember(true));
        if(isInsert)
            insert CampaignMemberList;
        return CampaignMemberList;
    }
    
    public static Account createAccount(Boolean isInsert){
        Account AccountObj = new Account();
        AccountObj.Name = 'Partner Account';
        AccountObj.Partner_Code__c = 'AUXMAGG001';
        AccountObj.PAN_Number__c = 'PAN123';
        AccountObj.Date_of_Birth__c= Date.newInstance(1990, 1, 1);
        AccountObj.Aadhar_Number__c='123456789012';
        AccountObj.Passport_Number__c = 'PASS123';
        AccountObj.Driving_License_Number__c = 'DL123';
        AccountObj.Voter_ID__c = 'VOTER123';
        AccountObj.RecordTypeId = getRecordTypeId(true);
        if(isInsert)
            insert AccountObj;
        return AccountObj;
    }
    public static Account createAccount1(Boolean isInsert){
        Account AccountObj = new Account();
        AccountObj.Name = 'Partner1 Account';
        AccountObj.Partner_Code__c = 'AUXMAGG002';
        AccountObj.PAN_Number__c = 'PAN456';
        AccountObj.Date_of_Birth__c= Date.newInstance(1990, 2, 2);
        AccountObj.Aadhar_Number__c='987654321098';
        AccountObj.Passport_Number__c = 'PASS456';
        AccountObj.Driving_License_Number__c = 'DL456';
        AccountObj.Voter_ID__c = 'VOTER456';
        AccountObj.RecordTypeId = getRecordTypeId(true);
        if(isInsert)
            insert AccountObj;
        return AccountObj;
    }
    
    public static Source__c createSource(Boolean isInsert){
        Account AccountObj = TestDataFactory.createAccount(true);
        Source__c SourceObject = new Source__c(Name ='	Yocketz', Partner_Name__c = AccountObj.Id,Source_Category__c = 'Partner',Lead_Gate__c ='Distribution Partners', Source_Type__c ='Consultants', Lead_Source__c='Education Partners', Sub_Source_Type__c='Accounts Relationship Manager');
        if(isInsert)
            insert SourceObject;
        return SourceObject;
    } 
    
    // Create Method To Get RecordTypeId
    public static String getRecordTypeId(Boolean accountPartner ){
        String RecordTypeId;
        if(accountPartner){recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Account').getRecordTypeId();}
        return RecordTypeId;
    } 
     public static Demography__c createDemography(Boolean isInsert){
        Demography__c Demographyobj = new Demography__c(Father_s_First_Name__c = 'test');
        if(isInsert)
            insert Demographyobj ;
        return Demographyobj ;
    } 
    public static Education_Details__c  createEducationDetails(Boolean isInsert){
        Education_Details__c Educationdetailsobj = new Education_Details__c(Education_Qualification__c  = 'Graduate',Percentage_Marks_CGPA__c    = 80, School_College_University__c = 'xyz',Account__c = TestDataFactory.createPersonAccount(true).Id);
        if(isInsert)
            insert Educationdetailsobj;
        return Educationdetailsobj;
    }
    // Custom Setting Record Creation
    public static Dedupe_Management__c CreateDedupeManagementCustomSetting(Boolean isInsert){
        Dedupe_Management__c customSettingDedupeManagemen = new Dedupe_Management__c(Name ='Manage Dedupe Days', Lead_stage_is_closed__c = 5 ,Lead_stage_converted__c = 5);
        if(isInsert)
            insert customSettingDedupeManagemen;
        return customSettingDedupeManagemen;
    }
    public static Pin_Code__c createPinCode(Boolean isInsert){
        Pin_Code__c PinCodeobj = new Pin_Code__c(Name = '411152');
        if(isInsert)
            insert PinCodeobj ;
        return PinCodeobj ;
    }   
    public static ContentVersion createContentVersion(Boolean isInsert){
        Account accObj = new Account();
       
        ContentVersion Contversionobj = new ContentVersion(	Document_Type__c = 'Aadhar Card',	Applicant_Type__c= 'Applicant',	Account__c =accObj.id,	Document_Sub_Type__c='Aadhar Back',Title = 'Aadhar_card_front.png',PathOnClient = 'Photo.png',VersionData = Blob.valueOf('Test Photo'));
        if(isInsert)
            insert Contversionobj ;
        return Contversionobj ;
    }   
    
    public static Document_Name_DMS__mdt createDocumentName(String masterLabel, String applicantType, String documentType){
        Document_Name_DMS__mdt DocNameobj = new Document_Name_DMS__mdt(MasterLabel = masterLabel,
        Applicant_Type__c = applicantType,
        Document_Type__c = documentType);
   
        return DocNameobj ;
    }     
    // Creation Of Queues Records
    public static Group createSalesProcessingQueu(Boolean isInsert) {
        Group salesProcessingQueue = new Group(Name = 'Sales Processing',Type = 'Queue');
        if(isInsert)
            insert salesProcessingQueue;
        return salesProcessingQueue;
    } 
   
    // cteation of string as header for bulk upload finctionality 
     public static final String fieldsString = 'Account Open Since,Account Type,City,Country,Country of Study,Date Of Birth(DD/MM/YYYY),Email,First Name,Gender,KYC Consent,Landmark,Last Name,Lead Source,Mobile Number,Name,Service Branch,State,University Name,User Name';

    
    
}