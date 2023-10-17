@isTest
public class TestDataFactory {
    
    // List for Bulk test functionality
    public static List<Lead> createLeadList(Boolean isInsert){
        List<Lead> leadList = new List<Lead>();
        Lead LeadObj = new Lead(FirstName = 'Vibhav', LastName = 'Singh', Email = 'vaibhavsinghtst@gmail.com',MobilePhone = '7200000041', Status='Fresh',KYC_Consent__c = true,csvUserName__c = 'external02@auxilo.com',Product_Category__c ='HEL - INDIA');
        leadList.add(LeadObj);
        Lead LeadObj2 = new Lead(FirstName = 'Vibhav', LastName = 'Singh', Email = 'vaibhavsinghtst2@gmail.com',MobilePhone = '7200000042', Status='Sales Processing',KYC_Consent__c = true,csvUserName__c = 'external02@auxilo.com',Product_Category__c ='HEL - INDIA');
        leadList.add(LeadObj2);
        Lead LeadObj3 = new Lead(FirstName = 'Vibhav', LastName = 'Singh', Email = null,MobilePhone = '7200000042',csvUserName__c = 'external02@auxilo.com', KYC_Consent__c = true,Product_Category__c ='HEL - INDIA');
        leadList.add(LeadObj3);
        Lead LeadObj4 = new Lead(FirstName = 'Vibhav', LastName = 'Singh', Email = 'vaibhavsinghtst4@gmail.com',MobilePhone = null, Status='Sales Processing',KYC_Consent__c = true,csvUserName__c = 'external02@auxilo.com',Product_Category__c ='HEL - INDIA');
        leadList.add(LeadObj4);
        Lead LeadObj5 = new Lead(FirstName = 'Vibhav', LastName = 'Singh', Email = 'vaibhavsinghtst2@gmail.com',MobilePhone = '7200000042', Status='Sales Processing',KYC_Consent__c = true,csvUserName__c = 'external02@auxilo.com',Product_Category__c ='HEL - INDIA');
        leadList.add(LeadObj5);
        Lead LeadObj6 = new Lead(FirstName = 'Ganesh', LastName = 'Patil', Email = 'patilganeshtstst@gmail.com',MobilePhone = '7312124586', Status='Sales Processing',KYC_Consent__c = true,csvUserName__c = 'external02@auxilo.com',Product_Category__c ='HEL - INDIA');
        leadList.add(LeadObj6);
        Lead LeadObj7 = new Lead(FirstName = 'Ganesh', LastName = 'Kale', Email = 'kaleganeshtstst@gmail.com',MobilePhone = '7364824586', Status='Sales Processing',KYC_Consent__c = true,csvUserName__c = 'external02@auxilo.com',Product_Category__c ='HEL - INDIA');
        leadList.add(LeadObj7);
        Lead LeadObj8 = new Lead(FirstName = 'Nitin', LastName = 'Mali', Email = 'nitinmali644554@gmail.com',MobilePhone = '7364824589', Status='Sales Processing',KYC_Consent__c = true,csvUserName__c = 'external02@auxilo.com',Product_Category__c ='HEL - INDIA');
        leadList.add(LeadObj8);
        Lead LeadObj9 = new Lead(FirstName = 'Nitin', LastName = 'Mali', Email = 'nitinmali644554@gmail.com',MobilePhone = '+7415587451', Status='Sales Processing',KYC_Consent__c = true,csvUserName__c = null,Product_Category__c ='HEL - INDIA');
        leadList.add(LeadObj9);
        Lead LeadObj10 = new Lead(FirstName = 'Pankaj', LastName = 'Mali', Email = 'pankajmalitstrr@gmail.com',MobilePhone = '7415587453', Status='Sales Processing',KYC_Consent__c = true,csvUserName__c = 'external02@auxilo.com',Product_Category__c ='HEL - INDIA');
        leadList.add(LeadObj10);
        Lead LeadObj11 = new Lead(FirstName = 'Pankaj', LastName = 'Mali', Email = 'pankajmalitstrr1245@gmail.com',MobilePhone = '7415587453',Product_Category__c ='HEL - INDIA');
        leadList.add(LeadObj11);
        Lead LeadObj12 = new Lead(FirstName = 'Suraj', LastName = 'nemane', Email = 'mahadev123@gmail.com',MobilePhone = '7894561400',Product_Category__c ='HEL - INDIA');
        leadList.add(LeadObj12);
        Lead LeadObj13 = new Lead(FirstName = 'Suraj', LastName = 'nemane', Email = 'mahadev12345@gmail.com',MobilePhone = '7878789',Product_Category__c ='HEL - INDIA');
        leadList.add(LeadObj13);
        Lead LeadObj14 = new Lead(FirstName = 'Suraj', LastName = 'nemane', Email = 'mahadev12345.com',MobilePhone = '7878789784',Product_Category__c ='HEL - INDIA');
        leadList.add(LeadObj14);
        Lead LeadObj15 = new Lead(FirstName = 'Suraj1122', LastName = 'nemane', Email = 'mahadev1478@gmail.com',MobilePhone = '7870009777',Product_Category__c ='HEL - INDIA');
        leadList.add(LeadObj15);
        Lead LeadObj16 = new Lead(FirstName = 'Suraj', LastName = 'nemane@1122', Email = 'mahadev1010@gmail.com',MobilePhone = '7878784712',Product_Category__c ='HEL - INDIA');
        leadList.add(LeadObj16);
        Lead LeadObj17 = new Lead(FirstName = 'Suraj', LastName = 'nemane', Email = 'mahadev1010@gmail.com' ,MobilePhone = null,Product_Category__c ='HEL - INDIA');
        leadList.add(LeadObj17);
        Lead LeadObj18 = new Lead(FirstName = 'Suraj', LastName = null, Email = 'suraj112331@gmail.com' ,MobilePhone = '5075588712',Product_Category__c ='HEL - INDIA');
        leadList.add(LeadObj18);
        Lead LeadObj19 = new Lead(FirstName = 'Vikas', LastName = 'Raje', Email = 'Vikas.com' ,MobilePhone = '787878',Product_Category__c ='HEL - INDIA');
        leadList.add(LeadObj19);
        Lead LeadObj20 = new Lead(FirstName = 'Vikas', LastName = 'Raje', Email = 'Vikas@gmail.com' ,MobilePhone = '7878784545',csvUserName__c = 'externa@auxilo.com',Product_Category__c ='HEL - INDIA');
        leadList.add(LeadObj20);
        Lead LeadObj21 = new Lead(FirstName = 'Vikas', LastName = 'Raje', Email = 'Vikasggh@gmail.com' ,MobilePhone = '7814778454',Gender__c ='Famale',Product_Category__c ='HEL - INDIA');
        leadList.add(LeadObj21);
        Lead LeadObj22 = new Lead(FirstName = 'Mangesh', LastName = 'Jadhav', Email = 'mangeshjadhavtsts@gmail.com' ,MobilePhone = '7814545754',KYC_Consent__c = true, Status='Fresh',Product_Category__c ='HEL - INDIA');
        leadList.add(LeadObj22); 
        Lead LeadObj23 = new Lead(FirstName = 'Vikram', LastName = 'Kate', Email = 'vikramkateststsg@gmail.com' ,MobilePhone = '7817864254',KYC_Consent__c = true, Status='Fresh',csvUserName__c ='vaibhavhinge@thinqloud.com',Product_Category__c ='HEL - INDIA');
        leadList.add(LeadObj23);
        
        if(isInsert)
            insert leadList;
        return leadList;
    }
    
    public static List<Lead> createLeadListForBatch(Boolean isInsert){
        List<Lead> leadList = new List<Lead>();
        for (Integer i = 1; i <= 101; i++) {
            Lead leadObj = new Lead(FirstName = 'Rajendra', MiddleName = 'Akshay', LastName = 'Patil',Email = 'rajendratstpatil' + i + '@example.com',MobilePhone = String.valueOf(1234567290 + i),Product_Category__c ='HEL - INDIA');
            leadList.add(leadObj);
        }
        if(isInsert)
            insert leadList;
        return leadList;
    }
    
    public static List<Lead> createLeadListForBatchForAssignCampaignToLead(Boolean isInsert){
        List<Lead> leadList = new List<Lead>();
        for (Integer i = 1; i <= 11; i++) {
            Lead leadObj = new Lead(FirstName = 'Rajendra',LastName = 'Patil',Email = 'rajendratstpatil' + i + '@example.com',MobilePhone = String.valueOf(1234567290 + i),Product_Category__c ='HEL - INDIA');
            leadList.add(leadObj);
        }
        if(isInsert)
            insert leadList;
        return leadList;
    }
    
    // Create User Record
    public static User createUser(Boolean isInsert){
        Profile profileId = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User UserObj = new User( FirstName = 'John', LastName = 'Doe',Email = 'johndoe@example.com',Username = 'johndoeauxilo@example.com',Alias = 'jdoe',ProfileId = profileId.Id, TimeZoneSidKey = 'America/Los_Angeles',LocaleSidKey = 'en_US',EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US');
        if(isInsert)
            insert UserObj;
        return UserObj;
    }
    
    public static User createUserUserProfile(Boolean isInsert){
        Profile profileId = [SELECT Id FROM Profile WHERE Name='Sales Profile'];
        User UserObj = new User( FirstName = 'John', LastName = 'Doe',Email = 'johndoe@example.com',Username = 'johndoeauxilo@example.com',Alias = 'jdoe',ProfileId = profileId.Id, TimeZoneSidKey = 'America/Los_Angeles',LocaleSidKey = 'en_US',EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US');
        if(isInsert)
            insert UserObj;
        return UserObj;
    }
    
    public static User createUserCallCenterProfile(Boolean isInsert){
        Profile profileId = [SELECT Id FROM Profile WHERE Name='Call Center Team'];
        User UserObj = new User( FirstName = 'Vikas', LastName = 'Rathi',Email = 'vikaststrathi@example.com',Username = 'vikashraathi@example.com',Alias = 'vrathi',ProfileId = profileId.Id, TimeZoneSidKey = 'America/Los_Angeles',LocaleSidKey = 'en_US',EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US');
        if(isInsert)
            insert UserObj;
        return UserObj;
    }
    
    public static User createUserCallCenter(Boolean isInsert){
        Profile profileId = [SELECT Id FROM Profile WHERE Name='Sales Profile'];
        User UserObj = new User( FirstName = 'John', LastName = 'Doe',Email = 'johndoe@example.com',Username = 'johndoeauxilo@example.com',Alias = 'jdoe',ProfileId = profileId.Id, TimeZoneSidKey = 'America/Los_Angeles',LocaleSidKey = 'en_US',EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US');
        if(isInsert)
            insert UserObj;
        return UserObj;
    }
    
    public static Lead createLead(Boolean isInsert ){
        Lead LeadObj = new Lead(FirstName = 'Rajendra', MiddleName = 'Akshay',LastName = 'Patil', 
                                Email = 'mangeshjadhavtsts@gmail.com' ,MobilePhone = '7814545548',
                                KYC_Consent__c = true, Status='Fresh',Service_Branch__c='PUNE',Product_Category__c ='HEL - INDIA',
                                Tuition_Fees__c=1000,Source_Category__c='Partner',Source_Name__c=createSourceWithoutPartner(true).Id,
                                Analytics_Score_Category__c='GRE', Quantitative_Score__c=150,Verbal_Score__c=160, Analytics_Test_Score__c=250);
        if(isInsert)
            insert LeadObj;
        return LeadObj;
    }
    
    public static Lead createLead1(Boolean isInsert ){
        Lead LeadObj = new Lead(FirstName = 'Rajendra', MiddleName = 'Akshay',LastName = 'Patil', Stage_Owner__c=userinfo.getUserId(),
                                Email = 'mangeshjadhavtsts@gmail.com' ,MobilePhone = '7814545548',
                                KYC_Consent__c = true, Status='Fresh',Service_Branch__c='PUNE',Product_Category__c ='HEL - INDIA',
                                Tuition_Fees__c=1000,Source_Category__c='Partner',Source_Name__c=createSourceWithoutPartner(true).Id,
                                Analytics_Score_Category__c='GRE', Quantitative_Score__c=150,Verbal_Score__c=160, Analytics_Test_Score__c=250);
        if(isInsert)
            insert LeadObj;
        return LeadObj;
    }
    public static Opportunity createOpportunity2(Boolean isInsert){
        Opportunity oppObj = new Opportunity(Name='Mangesh',AccountId=createAccount(true).Id,CloseDate=System.today(),StageName='Credit Underwriter',Lead__c=createLead1(true).Id,LOS_Id__c='LOS-00000000009028478-PROCESS',LOS_Sync__c=true,Folder_Index__c=1234);
        if(isInsert)
            insert oppObj;
        return oppObj;
    }
    
    public static Lead createLeadForOpp(Boolean isInsert ){
        Lead LeadObj = new Lead(FirstName = 'Mangesh', LastName = 'Jadhav', Email = 'mangeshjadhavtsts1@gmail.com' ,MobilePhone = '7814545558',KYC_Consent__c = true, Status='Fresh',Service_Branch__c='PUNE',Tuition_Fees__c=1000,Source_Category__c='Partner',Source_Name__c=createSourceWithoutPartner(true).Id,Product_Category__c ='HEL - INDIA');
        if(isInsert)
            insert LeadObj;
        return LeadObj;
    }
    
    
    
    public static Lead createLeadWithDiffName(Boolean isInsert ){
        Lead LeadObj = new Lead(FirstName = 'Manish', LastName = 'Jadhav', Email = 'manishjadhavtsts@gmail.com' ,MobilePhone = '7878455548',KYC_Consent__c = true, Status='Fresh',Service_Branch__c='PUNE',Tuition_Fees__c=1000,Source_Category__c='Partner',Source_Name__c=createSourceWithoutPartner(true).Id,Product_Category__c ='HEL - INDIA');
        if(isInsert)
            insert LeadObj;
        return LeadObj;
    }
    
    public static Lead createLeadForOppFail(Boolean isInsert ){
        Lead LeadObj = new Lead(FirstName = 'Ganesh', LastName = 'Kale', Email = 'kaleganeshtstst@gmail.com',MobilePhone = '7364824586', Status='Sales Processing',KYC_Consent__c = true,csvUserName__c = 'external02@auxilo.com',Source_Category__c='Partner',Source_Name__c=createSourceWithoutPartner(true).Id,Product_Category__c ='HEL - INDIA');
        if(isInsert)
            insert LeadObj;
        return LeadObj;
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
    public static Account createAccount2(Boolean isInsert){
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
    
    public static Lead createLead4(Boolean isInsert ){
        Lead LeadObj = new Lead(FirstName = 'Ganesh', LastName = 'Kale', Email = 'kaleganeshtstst@gmail.com',MobilePhone = '7364824586',Source_Category__c='Partner',Source_Name__c=createSourceWithoutPartner(true).Id,Product_Category__c ='HEL - INDIA');
        if(isInsert)
            insert LeadObj;
        return LeadObj;
    } 
    
    
    // Create Campaign record
    public static Campaign createCampaign(Boolean isInsert) {
        Campaign campaignObject = new Campaign(Name = 'Fresh_Consent_Campaign',Priority__c = 1);
        if(isInsert)
            insert campaignObject;
        return campaignObject;
    }
    
    public static Campaign createCampaignParent(Boolean isInsert) {
        Campaign campaignObject = new Campaign(Name = 'Test Parent',Priority__c = 50);
        if(isInsert)
            insert campaignObject;
        return campaignObject;
    }
    //Record Campaign Member
    public static CampaignMember createCampaignMember(Boolean isInsert) {
        CampaignMember CampaignMemberObject = new CampaignMember(LeadId =createLead(true).Id , CampaignId =createCampaign(true).Id, Status = 'Sent');
        if(isInsert)
            insert CampaignMemberObject;
        return CampaignMemberObject;
    }
    
    public static CampaignMember createCampaignMember2(Boolean isInsert) {
        CampaignMember CampaignMemberObject = new CampaignMember(Status = 'Sent');
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
    // Parten Account Bulk Upload Functionality 
    public static Account createAccount(Boolean isInsert){
        Account AccountObj = new Account( Name = 'Parther Account', Partner_Code__c = 'AUXMAGG001',RecordTypeId = getRecordTypeId(true));
        if(isInsert)
            insert AccountObj;
        return AccountObj;
    }
    
    public static Account createPartnerAccount2(Boolean isInsert){
        Account AccountObj = new Account( Name = 'Yocketz', Partner_Code__c = 'ACCRM0015',RecordTypeId = getRecordTypeId(true),Preferred_Partner__c = true);
        if(isInsert)
            insert AccountObj;
        return AccountObj;
    }
    
    
    // Parten Account Bulk Upload Functionality 
    public static Account createPersonAccount(Boolean isInsert){
        Date birthdate = Date.today().addYears(-20);
        Account AccountObj = new Account(FirstName = 'Account', LastName = 'Person Account',	PersonEmail ='Test@gmail.com', Partner_Code__c = 'AUXMAGG001',Gender__c = 'Male',Date_of_Birth__c =birthdate,  RecordTypeId = getRecordTypeIdPersonAccount(true));
        if(isInsert)
            insert AccountObj;
        return AccountObj;
    }
    
    public static Source__c createSource(Boolean isInsert){
        Account AccountObj = TestDataFactory.createAccount(true);
        Source__c SourceObject = new Source__c(Name ='  Yocketz', Partner_Name__c = AccountObj.Id,Source_Category__c = 'Partner',Lead_Gate__c ='Distribution Partners', Source_Type__c ='Consultants', Lead_Source__c='Education Partners', Sub_Source_Type__c='Accounts Relationship Manager');
        if(isInsert)
            insert SourceObject;
        return SourceObject;
    } 
    
    public static Source__c createSourceWithoutPartner(Boolean isInsert){
        //Account AccountObj = TestDataFactory.createAccount(true);
        Source__c SourceObject = new Source__c(Name ='  Yocketz',Source_Category__c = 'Partner',Lead_Gate__c ='Distribution Partners', Source_Type__c ='Consultants', Lead_Source__c='Education Partners', Sub_Source_Type__c='Accounts Relationship Manager');
        if(isInsert)
            insert SourceObject;
        return SourceObject;
    } 
    
    // Create Method To Get RecordTypeId Partner_Account
    public static String getRecordTypeId(Boolean accountPartner ){
        String RecordTypeId;
        if(accountPartner){recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Account').getRecordTypeId();}
        return RecordTypeId;
    } 
    
    // Create Method To Get RecordTypeId PersonAccount
    public static String getRecordTypeIdPersonAccount(Boolean accountPartner ){
        String RecordTypeId;
        if(accountPartner){recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();}
        return RecordTypeId;
    } 
    
    // Create Method To Get RecordTypeId LeadB2C
    public static String getRecordTypeIdLeadB2C(){
        String RecordTypeId;
        recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('B2C').getRecordTypeId();
        return RecordTypeId;
    } 
    
    // Custom Setting Record Creation
    public static Dedupe_Management__c CreateDedupeManagementCustomSetting(Boolean isInsert){
        Dedupe_Management__c customSettingDedupeManagemen = new Dedupe_Management__c(Name ='Manage Dedupe Days', Lead_stage_is_closed__c = 5 ,Lead_stage_converted__c = 5);
        if(isInsert)
            insert customSettingDedupeManagemen;
        return customSettingDedupeManagemen;
    }
    
    // Custom Setting Record Creation
    public static Triggers_Setup__c CreateLeadTriggerCustomSetting(Boolean isInsert){
        Triggers_Setup__c customSettingLeadTriggerManagemen = new Triggers_Setup__c(Name = 'Lead Trigger',Trigger_Name__c ='LeadTrigger', Trigger_On__c = true );
        if(isInsert)
            insert customSettingLeadTriggerManagemen;
        return customSettingLeadTriggerManagemen;
    }
    
    public static Partner_Naming_Configrations__c CreatePartnerNamingConfigrationsCustomSetting(Boolean isInsert){
        Partner_Naming_Configrations__c customSettingPartnerNamingConfigrations = new Partner_Naming_Configrations__c(Name ='AI Driven', Auto_increment_basis_category__c = '014' ,Partner_Category__c = 'AI Driven',Static__c='ALDRIV');
        if(isInsert)
            insert customSettingPartnerNamingConfigrations;
        return customSettingPartnerNamingConfigrations;	
    } 
    
    
    // Applicant/Co-Applicant Record Creation
    public static Co_Applicant__c CreateCoApplicant(Boolean isInsert){
        Co_Applicant__c coApplicantObj = new Co_Applicant__c(Type__c = 'Applicant', Account__c = createPersonAccount(true).Id);
        if(isInsert)
            insert coApplicantObj;
        return coApplicantObj;
    } 
    //ContentDocumentLink
    public static Account createLinkedEntity(Boolean isInsert){
        Account testAccount = new Account(Name = 'Test Account');
        if(isInsert)
            insert testAccount;
        return testAccount;
    }
    
    // Applicant/Co-Applicant Record Creation
    public static Co_Applicant__c CreateCoApplicantRecord(Boolean isInsert){
        Co_Applicant__c coApplicantObj = new Co_Applicant__c( Account__c = createPersonAccount(true).Id,Is_Income_Considered_Financial__c='Yes');
        if(isInsert)
            insert coApplicantObj;
        return coApplicantObj;
    } 
    
    // Creation Of Queues Records
    public static Group createSalesProcessingQueu(Boolean isInsert) {
        Group salesProcessingQueue = new Group(Name = 'Sales Processing',Type = 'Queue');
        if(isInsert)
            insert salesProcessingQueue;
        return salesProcessingQueue;
    } 
    
    // Creation Of Queues Records Exception Queue
    public static Group createExceptionQueue(Boolean isInsert) {
        Group ExceptionQueueQueue = new Group(Name = 'Exception Queue',Type = 'Queue');
        if(isInsert)
            insert ExceptionQueueQueue;
        return ExceptionQueueQueue;
    } 
    // Creation Of Group Records
    public static Group createSalesProcessingGroup(Boolean isInsert) {
        Group salesProcessingGroup = new Group(Name = 'AHMEDABAD ASM2',Type = 'Queue');
        
        if(isInsert)
            insert salesProcessingGroup;
        QueueSObject q = new QueueSObject(QueueId = salesProcessingGroup.Id, SobjectType = 'Lead');
        QueueSObject q1 = new QueueSObject(QueueId = salesProcessingGroup.Id, SobjectType = 'Task');
        return salesProcessingGroup;
    } 
    
    // Creation Of Group Records
    public static Group createYocketsGroup(Boolean isInsert) {
        Group yocketsQueueGroup = new Group(Name = 'Yocketz Queue',Type  = 'Queue');
        if(isInsert)
            
            insert yocketsQueueGroup;
        return yocketsQueueGroup;
    } 
    // Creation Of Group Records
     public static Group createDealCreditUserGroup(Boolean isInsert) {
        Group dealCreditUserGroup = new Group(Name = 'DELHI North CU RM1',Type  = 'Queue');
        if(isInsert)
            
            insert dealCreditUserGroup;
        return dealCreditUserGroup;
    } 
    
    // Creation Of Group Records
    public static Group createCallCenterQueue(Boolean isInsert) {
        Group callCenterGroup = new Group(Name = 'Call Center',Type  = 'Queue');
        if(isInsert)
            
            insert callCenterGroup;
        return callCenterGroup;
    }
    
    public static Asset createAsset(Boolean isInsert){
        Asset AssetObj = new Asset(Name = 'Test Asset',Asset_Type__c  = 'Gold',Asset_Value__c  = 1000000);
        if(isInsert)
            insert AssetObj;
        return AssetObj;
    }
    
    public static Asset createAssetRecord(Boolean isInsert){
        Asset AssetObj = new Asset(Name = 'Test Asset',Collateral_Type__c= 'FD',Security_Offered__c='Yes',Asset_Value__c=10000);
        if(isInsert)
            insert AssetObj;
        return AssetObj;
    }
    
    public static Area__c createArea(Boolean isInsert){
        Area__c AreaObj = new Area__c(City_Code__c  = '123', City_Name__c   = 'Pune',Name = '112233',Area_Name_Taluka__c = 'test',Country_Code__c = 'IN');
        if(isInsert)
            insert AreaObj;
        return AreaObj;
    }
    
    public static List<Asset> createAssetList(Boolean isInsert ){
        List<Asset> AssetList = new List<Asset>();
        Asset assetObj = new Asset(Name = 'Test Asset', Asset_Type__c  = 'Gold', Asset_Value__c  = 1000000,Security_Offered__c = 'Yes',Collateral_Type__c = 'FD');
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
    public static Employment_Details__c  createEmploymentdeatils(Boolean isInsert){
        Employment_Details__c Employmentdeatilssobj = new Employment_Details__c(Employment_Type__c = 'Student');
        if(isInsert)
            insert Employmentdeatilssobj;
        return Employmentdeatilssobj;
    } 
    public static Liability__c createLiability(Boolean isInsert){
        Liability__c Liabilitysobj = new Liability__c(Loan_Type__c = 'BL');
        if(isInsert)
            insert Liabilitysobj ;
        return Liabilitysobj ;
    } 
    public static Demography__c createDemography(Boolean isInsert){
        Demography__c Demographyobj = new Demography__c(Father_s_First_Name__c = 'test');
        if(isInsert)
            insert Demographyobj ;
        return Demographyobj ;
    } 
    
    public static Reference__c createReference(Boolean isInsert){
        Reference__c Referenceobj = new Reference__c(Reference_First_Name__c = 'Shreyas',Reference_Address_1__c ='Pune');
        if(isInsert)
            insert Referenceobj ;
        return Referenceobj ;
    } 
    
    /*public static Pin_Code__c createPinCode(Boolean isInsert){
Pin_Code__c PinCodeobj = new Pin_Code__c(Name = '411152');
if(isInsert)
insert PinCodeobj ;
return PinCodeobj ;
}*/    
    public static ContactPointAddress  createContactPointAddress(Boolean isInsert){
        ContactPointAddress  ContactPointAddressobj = new ContactPointAddress ( Name= 'Current',Address_Type__c='Current Address',Address_1__c ='Nashik',City__c='NASIK',State__c='MAHARASHTRA',Country__c ='INDIA',Pin_Code__c= createArea(true).Id);
        if(isInsert)
            insert ContactPointAddressobj ;
        return ContactPointAddressobj ;
    } 
    
    public static ContactPointAddress  createContactPointAddressPer(Boolean isInsert){
        ContactPointAddress  ContactPointAddressobj = new ContactPointAddress ( Name= 'Permanent',Address_Type__c='Permanent Address',Address_1__c ='Nashik',City__c='NASIK',State__c='MAHARASHTRA',Country__c ='INDIA',Pin_Code__c= createArea(true).Id);
        if(isInsert)
            insert ContactPointAddressobj ;
        return ContactPointAddressobj ;
    } 
    
    public static ContactPointAddress  createContactPointAddressOffice(Boolean isInsert){
        ContactPointAddress  ContactPointAddressobj = new ContactPointAddress ( Name= 'Office',Address_Type__c='Office',Address_1__c ='Nashik',City__c='NASIK',State__c='MAHARASHTRA',Country__c ='INDIA',Pin_Code__c= createArea(true).Id);
        if(isInsert)
            insert ContactPointAddressobj ;
        return ContactPointAddressobj ;
    } 
    
    public static Bank__c  createBank(Boolean isInsert){
        Bank__c  Bankobj = new Bank__c(Name= 'The Shirpur Peoples Co-op Bank LTD',Bank_Code__c = 22);
        if(isInsert)
            insert Bankobj ;
        return Bankobj;
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
    
    
    // cteation of string as header for bulk upload finctionality 
    public static final String fieldsString = 'Account Open Since,Account Type,City,Country,Country of Study,Date Of Birth(DD/MM/YYYY),Email,First Name,Gender,KYC Consent,Landmark,Last Name,Lead Source,Mobile Number,Name,Service Branch,State,University Name,User Name';
    
    //Create LOS Map Data
    public static  List<LosApiMap__c> createLOSMapData(){
        List<LosApiMap__c> losApiMapList = new List<LosApiMap__c>();
        
        LosApiMaster__c apiMaster1 = new LosApiMaster__c(ApiName__c='createWorkitem',Active__c=true,ForCoApplicant__c=false);
        insert apiMaster1;
        
        LosApiMaster__c apiMaster2 = new LosApiMaster__c(ApiName__c='leadInfo',Active__c=true,ForCoApplicant__c=false);
        insert apiMaster2;
        
        LosApiMap__c map1 = new LosApiMap__c(SalesforceLable__c='Country_of_Study__c',LosLable__c='COUNTRY',TableName__c='Lead',LosApiMaster__c=apiMaster2.Id);
        LosApiMap__c map2 = new LosApiMap__c(SalesforceLable__c='FirstName',LosLable__c='NAME_OF_THE_PROSPECT',TableName__c='Lead',LosApiMaster__c=apiMaster2.Id);
        LosApiMap__c map33 = new LosApiMap__c(SalesforceLable__c='',LosLable__c='HOW_DID_YOU_KNOW',TableName__c='',LosApiMaster__c=apiMaster2.Id);
        LosApiMap__c map35 = new LosApiMap__c(SalesforceLable__c='CreatedDate',LosLable__c='APP_DATE',TableName__c='Lead',LosDataType__c='DATE',LosApiMaster__c=apiMaster2.Id);
        LosApiMap__c map36 = new LosApiMap__c(SalesforceLable__c='Loan_Required_A_B__c',LosLable__c='LOAN_AMOUNT',TableName__c='Lead',LosDataType__c='NUMBER',LosApiMaster__c=apiMaster2.Id);
        LosApiMap__c map39 = new LosApiMap__c(LosLable__c='EXPECTED_DIS_TYPE',TableName__c='',LosDataType__c='DATE',Default__c='11-11-2022',LosApiMaster__c=apiMaster2.Id);
        LosApiMap__c map44 = new LosApiMap__c(SalesforceLable__c='Source_Name__r.Name',LosLable__c='NAME',TableName__c='Lead',LosDataType__c='',Default__c='',LosApiMaster__c=apiMaster2.Id);

        losApiMapList.add(map1);
        losApiMapList.add(map2);
        losApiMapList.add(map33);
        losApiMapList.add(map35);
        losApiMapList.add(map36);
        losApiMapList.add(map39);
        losApiMapList.add(map44);
        LosApiMaster__c apiMaster3 = new LosApiMaster__c(ApiName__c='courseDetail',Active__c=true,ForCoApplicant__c=false);
        insert apiMaster3;
        
        LosApiMap__c map3 = new LosApiMap__c(SalesforceLable__c='Country_of_Study__c',LosLable__c='COUNTRY',TableName__c='Lead',LosApiMaster__c=apiMaster3.Id);
        LosApiMap__c map4 = new LosApiMap__c(SalesforceLable__c='Course_Type__c',LosLable__c='COURSE_TYPE',TableName__c='Lead',LosApiMaster__c=apiMaster3.Id);
        
        losApiMapList.add(map3);
        losApiMapList.add(map4);
        
        LosApiMaster__c apiMaster4 = new LosApiMaster__c(ApiName__c='examScore',Active__c=true,ForCoApplicant__c=false);
        insert apiMaster4;
        
        LosApiMap__c map5 = new LosApiMap__c(SalesforceLable__c='Analytics_Score_Category__c',LosLable__c='SCORE_SUB_CATEGORY',TableName__c='Lead',LosApiMaster__c=apiMaster4.Id);
        LosApiMap__c map6 = new LosApiMap__c(SalesforceLable__c='Analytics_Test_Score__c',LosLable__c='ANALYTICAL',TableName__c='Lead',LosApiMaster__c=apiMaster4.Id);
        
        losApiMapList.add(map5);
        losApiMapList.add(map6);
        
        LosApiMaster__c apiMaster5 = new LosApiMaster__c(ApiName__c='preEduDetails',Active__c=true,ForCoApplicant__c=false);
        insert apiMaster5;
        
        LosApiMap__c map7 = new LosApiMap__c(SalesforceLable__c='Education_Qualification__c',LosLable__c='EDUCATIONAL_DETAIL',TableName__c='Education_Details__c',LosApiMaster__c=apiMaster5.Id);
        LosApiMap__c map8 = new LosApiMap__c(SalesforceLable__c='Percentage_Marks_CGPA__c',LosLable__c='PERCENTAGE_MARKS',TableName__c='Education_Details__c',LosApiMaster__c=apiMaster5.Id);
        
        losApiMapList.add(map7);
        losApiMapList.add(map8);
        
        LosApiMaster__c apiMaster6 = new LosApiMaster__c(ApiName__c='custNiReference',Active__c=true,ForCoApplicant__c=true);
        insert apiMaster6;
        
        LosApiMap__c map9 = new LosApiMap__c(SalesforceLable__c='Reference_First_Name__c',LosLable__c='FIRST_NAME',TableName__c='Reference__c',LosApiMaster__c=apiMaster6.Id);
        LosApiMap__c map10 = new LosApiMap__c(SalesforceLable__c='Reference_Last_Name__c',LosLable__c='LAST_NAME',TableName__c='Reference__c',LosApiMaster__c=apiMaster6.Id);
        
        losApiMapList.add(map9);
        losApiMapList.add(map10);
        
        LosApiMaster__c apiMaster7 = new LosApiMaster__c(ApiName__c='gridDetails',Active__c=true,ForCoApplicant__c=true);
        insert apiMaster7;
        
        LosApiMap__c map11 = new LosApiMap__c(SalesforceLable__c='Account__r.Name',LosLable__c='CUST_NAME',TableName__c='Demography__c',LosApiMaster__c=apiMaster7.Id);
        LosApiMap__c map12 = new LosApiMap__c(SalesforceLable__c='Type__c',LosLable__c='CUST_TYPE',TableName__c='Co_Applicant__c',LosApiMaster__c=apiMaster7.Id);
        
        losApiMapList.add(map11);
        losApiMapList.add(map12);
        
        LosApiMaster__c apiMaster8 = new LosApiMaster__c(ApiName__c='personalDetail',Active__c=true,ForCoApplicant__c=true);
        insert apiMaster8;
        
        LosApiMap__c map13 = new LosApiMap__c(SalesforceLable__c='Account__r.PersonBirthdate',LosLable__c='DATE_OF_BIRTH',TableName__c='Demography__c',LosApiMaster__c=apiMaster8.Id);
        LosApiMap__c map14 = new LosApiMap__c(SalesforceLable__c='Type__c',LosLable__c='CUSTOMERTYPE',TableName__c='Co_Applicant__c',LosApiMaster__c=apiMaster8.Id);
        LosApiMap__c map37 = new LosApiMap__c(SalesforceLable__c='Account__r.PAN_Number__c',LosLable__c='PAN_AVAILABLE',TableName__c='Demography__c',LosDataType__c='BOOLEAN',LosApiMaster__c=apiMaster8.Id);
        
        losApiMapList.add(map13);
        losApiMapList.add(map14);
        losApiMapList.add(map37);
        
        LosApiMaster__c apiMaster9 = new LosApiMaster__c(ApiName__c='addressDetail',Active__c=true,ForCoApplicant__c=true);
        insert apiMaster9;
        
        LosApiMap__c map15 = new LosApiMap__c(SalesforceLable__c='Address_1__c',LosLable__c='CURR_RES_ADDRESS1',TableName__c='ContactPointAddress',LosDataType__c  ='Current Address',LosApiMaster__c=apiMaster9.Id);
        LosApiMap__c map16 = new LosApiMap__c(SalesforceLable__c='Years_In_The_Address__c',LosLable__c='CURR_YEAR_STAY',TableName__c='ContactPointAddress',LosDataType__c  ='Current Address',LosApiMaster__c=apiMaster9.Id);
        
        losApiMapList.add(map15);
        losApiMapList.add(map16);
        
        LosApiMaster__c apiMaster10 = new LosApiMaster__c(ApiName__c='employment',Active__c=true,ForCoApplicant__c=true);
        insert apiMaster10;
        
        LosApiMap__c map17 = new LosApiMap__c(SalesforceLable__c='Employment_Type__c',LosLable__c='OCCUPATION_TYPE',TableName__c='Employment_Details__c',LosDataType__c='',LosApiMaster__c=apiMaster10.Id);
        LosApiMap__c map18 = new LosApiMap__c(SalesforceLable__c='Name',LosLable__c='EMPLOYER_NAME',TableName__c='Employment_Details__c',LosDataType__c='',LosApiMaster__c=apiMaster10.Id);
        LosApiMap__c map34 = new LosApiMap__c(SalesforceLable__c='Address_1__c',LosLable__c='EMP_ADDRESS_LINE_1',TableName__c='ContactPointAddress',LosApiMaster__c=apiMaster10.Id);
        LosApiMap__c map38 = new LosApiMap__c(SalesforceLable__c='Total_Professional_Experience__c',LosLable__c='NO_OF_YEARS_BUSINESS',TableName__c='Employment_Details__c',LosDataType__c='NUMBER',LosApiMaster__c=apiMaster10.Id);
        
        losApiMapList.add(map17);
        losApiMapList.add(map18);
        losApiMapList.add(map34);
        losApiMapList.add(map38);
        
        
        LosApiMaster__c apiMaster11 = new LosApiMaster__c(ApiName__c='bankAccount',Active__c=true,ForCoApplicant__c=true);
        insert apiMaster11;
        
        LosApiMap__c map19 = new LosApiMap__c(SalesforceLable__c='Bank_Name__c',LosLable__c='BANK_NAME',TableName__c='Bank_Details__c',LosApiMaster__c=apiMaster11.Id);
        LosApiMap__c map20 = new LosApiMap__c(SalesforceLable__c='Account_Type__c',LosLable__c='ACC_TYPE',TableName__c='Bank_Details__c',LosApiMaster__c=apiMaster11.Id);
        
        losApiMapList.add(map19);
        losApiMapList.add(map20);
        
        LosApiMaster__c apiMaster12 = new LosApiMaster__c(ApiName__c='immovable',Active__c=true,ForCoApplicant__c=true);
        insert apiMaster12;
        
        LosApiMap__c map21 = new LosApiMap__c(SalesforceLable__c='Collateral_Type__c',LosLable__c='COLL_TYPE',TableName__c='Asset',LosApiMaster__c=apiMaster12.Id);
        LosApiMap__c map22 = new LosApiMap__c(SalesforceLable__c='Account_Holder_Name__c',LosLable__c='ACCOUNT_HOLDER_NAME',TableName__c='Bank_Details__c',LosApiMaster__c=apiMaster12.Id);
        LosApiMap__c map40 = new LosApiMap__c(SalesforceLable__c='Asset_Value__c',LosLable__c='MARKET_VALUE',TableName__c='Asset',LosDataType__c='NUMBER',LosApiMaster__c=apiMaster12.Id);
        
        losApiMapList.add(map21);
        losApiMapList.add(map22);
        losApiMapList.add(map40);
        
        LosApiMaster__c apiMaster13 = new LosApiMaster__c(ApiName__c='movable',Active__c=true,ForCoApplicant__c=true);
        insert apiMaster13;
        
        LosApiMap__c map23 = new LosApiMap__c(SalesforceLable__c='Collateral_Type__c',LosLable__c='COLL_TYPE',TableName__c='Asset',LosApiMaster__c=apiMaster13.Id);
        LosApiMap__c map24 = new LosApiMap__c(SalesforceLable__c='Asset_Value__c',LosLable__c='AMOUNT',TableName__c='Asset',LosApiMaster__c=apiMaster13.Id);
        
        losApiMapList.add(map23);
        losApiMapList.add(map24);
        
        LosApiMaster__c apiMaster14 = new LosApiMaster__c(ApiName__c='assetDetails',Active__c=true,ForCoApplicant__c=true);
        insert apiMaster14;
        
        LosApiMap__c map25 = new LosApiMap__c(SalesforceLable__c='Asset_Type__c',LosLable__c='ASSET_TYPE',TableName__c='Asset',LosApiMaster__c=apiMaster14.Id);
        LosApiMap__c map26 = new LosApiMap__c(SalesforceLable__c='Asset_Value__c',LosLable__c='ASSET_VALUE',TableName__c='Asset',LosApiMaster__c=apiMaster14.Id);
        
        losApiMapList.add(map25);
        losApiMapList.add(map26);
        
        LosApiMaster__c apiMaster15 = new LosApiMaster__c(ApiName__c='liabilityDetails',Active__c=true,ForCoApplicant__c=true);
        insert apiMaster15;
        
        LosApiMap__c map27 = new LosApiMap__c(SalesforceLable__c='Loan_Type__c',LosLable__c='TYPE_OF_LOAN',TableName__c='Liability__c',LosApiMaster__c=apiMaster15.Id);
        LosApiMap__c map28 = new LosApiMap__c(SalesforceLable__c='Original_Amount__c',LosLable__c='LOAN_AMOUNT',TableName__c='Liability__c',LosApiMaster__c=apiMaster15.Id);
        
        losApiMapList.add(map27);
        losApiMapList.add(map28);
        
        LosApiMaster__c apiMaster16 = new LosApiMaster__c(ApiName__c='credit',Active__c=true,ForCoApplicant__c=true);
        insert apiMaster16;
        
        LosApiMap__c map29 = new LosApiMap__c(SalesforceLable__c='Cibil_Score__c',LosLable__c='CIBIL_SCORE',TableName__c='Demography__c',LosApiMaster__c=apiMaster16.Id);
        LosApiMap__c map30 = new LosApiMap__c(SalesforceLable__c='Type__c',LosLable__c='APP_TYPE',TableName__c='Co_Applicant__c',LosApiMaster__c=apiMaster16.Id);
        
        losApiMapList.add(map29);
        losApiMapList.add(map30);
        
        LosApiMaster__c apiMaster17 = new LosApiMaster__c(ApiName__c='dataTransfer',Active__c=true,ForCoApplicant__c=false);
        insert apiMaster17;
        
        LosApiMap__c map41 = new LosApiMap__c(SalesforceLable__c='LOS_Id__c',LosLable__c='WI_NAME',TableName__c='Opportunity',LosApiMaster__c=apiMaster17.Id);
        LosApiMap__c map31 = new LosApiMap__c(SalesforceLable__c='Lead__c',LosLable__c='LEAD_ID',TableName__c='Opportunity',LosApiMaster__c=apiMaster17.Id);
        LosApiMap__c map32 = new LosApiMap__c(SalesforceLable__c='Loan_Application_Number__c',LosLable__c='APPLICATION_NO',TableName__c='Opportunity',LosApiMaster__c=apiMaster17.Id);
        LosApiMap__c map42 = new LosApiMap__c(LosDataType__c='DATE',LosLable__c='INSERTIONDATE',LosApiMaster__c=apiMaster17.Id);
        LosApiMap__c map43 = new LosApiMap__c(LosDataType__c='DATE',Default__c='N',LosApiMaster__c=apiMaster17.Id);
        
        losApiMapList.add(map31);
        losApiMapList.add(map32);
        losApiMapList.add(map41);
        losApiMapList.add(map42);
        losApiMapList.add(map43);
        
        insert losApiMapList;
        return losApiMapList;
    } 
    
    //Create one Tracker for Opportunity
    public static void createTracker(Id oppId,Id leadId){
        Tracker__c trackerObj  = new Tracker__c();
        trackerObj.Lead__c =  leadId;
        trackerObj.Deal__c = oppId;
        trackerObj.Status__c = 'Failure';
        trackerObj.StatusCode__c = 102;
        trackerObj.ApiName__c = 'leadInfo';
        insert trackerObj;
    }
 //Create one opportunity
    public static Opportunity createOpportunity(Boolean isInsert){
        User dealOwner = createUserActive(true);
        Opportunity oppObj = new Opportunity(Name = 'Test Opportunity', StageName = 'Closed Won', CloseDate = Date.today(), AccountId=createAccount(true).Id);
        if(isInsert)
            insert oppObj;
        return oppObj;
    }    
    //Create one opportunity
    public static Opportunity createOpportunity1(Boolean isInsert){
        User dealOwner = createUserActive(true);
        Opportunity oppObj = new Opportunity(Name='Mangesh',AccountId=createAccount(true).Id,CloseDate=System.today(),StageName='Credit Underwriter',Lead__c=createLead(true).Id,LOS_Id__c='LOS-00000000009028478-PROCESS',LOS_Sync__c=true,Folder_Index__c=1234,Stage_Owner__c=dealOwner.Id,Deal_stage_owner_Id__c=dealOwner.Id);
        if(isInsert)
            insert oppObj;
        return oppObj;
    }
    
    //Create one opportunity
    public static Opportunity createOpportunityForScheduler(Boolean isInsert){
        Opportunity oppObj = new Opportunity(Name='Mangesh',AccountId=createAccount(true).Id,CloseDate=System.today(),StageName='Credit Underwriter',Lead__c=createLeadForOpp(true).Id,Folder_Index__c=1234);
        if(isInsert)
            insert oppObj;
        return oppObj;
    }
    
    public static Opportunity createOpportunityForFails(Boolean isInsert){
        User dealOwner = createUserActive(true);
        Opportunity oppObj = new Opportunity(Name='Mangesh',AccountId=createAccount(true).Id,CloseDate=System.today(),StageName='Credit Underwriter',Lead__c=createLeadForOppFail(true).Id,Folder_Index__c=1234,Stage_Owner__c=dealOwner.Id,Deal_stage_owner_Id__c=dealOwner.Id);
        if(isInsert)
            insert oppObj;
        return oppObj;
    }
    
    
    
    
    public static void createTrackerList(){
        List<Tracker__c> trackers = new List<Tracker__c>();
        for (Integer i = 0; i < 10; i++) {
            Tracker__c tracker = new Tracker__c();
            tracker.ApiName__c = 'Test Tracker ' + i;
            tracker.Status__c = 'Success';
            trackers.add(tracker);
        }
        insert trackers;
    }
    
    public static void createTrackerListOpp(Opportunity opp){
        List<Tracker__c> trackers = new List<Tracker__c>();
        for (Integer i = 0; i < 10; i++) {
            Tracker__c tracker = new Tracker__c();
            tracker.ApiName__c = 'Test Tracker ' + i;
            tracker.Status__c = 'Success';
            tracker.Lead__c = opp.Lead__c;
            tracker.Deal__c = opp.Id;
            trackers.add(tracker);
        }
        insert trackers;
    }
    
    
    public static void createErrorLog(){
        List<Error_log__c> errorLogs = new List<Error_log__c>();
        for (Integer i = 0; i < 10; i++) {
            Error_log__c errorLog = new Error_log__c();
            errorLog.ApiName__c = 'Test Error Log ' + i;
            errorLog.Status__c = 'Error';
            errorLogs.add(errorLog);
        }
        insert errorLogs;
    }
    
    public static void createDocuments(Id oppId,Integer size){
        List<ContentVersion> contentVersionsToInsert = new List<ContentVersion>();
        Set<Id> docIds = new Set<Id>();
        Document_Checklist__c docChecklist = new Document_Checklist__c();
        docChecklist.Applicant_Name__c = 'Test';
        docChecklist.Applicant_Type__c = 'Applicant';
        docChecklist.Document_DMS_Name__c = 'TestDoc';
        docChecklist.Deal__c = oppId;
        insert docChecklist;
        
        List<ContentDocumentLink> contentDocumentLinkToInsert = new List<ContentDocumentLink>();
        
        for (Integer i = 1; i <= size; i++) {
            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S'; 
            cv.PathOnClient = 'path/to/file' + i + '.pdf'; 
            cv.Title = 'File ' + i+'.jpg'; 
            cv.VersionData = Blob.valueOf('Content of file ' + i); 
            contentVersionsToInsert.add(cv);
        }
        insert contentVersionsToInsert;
        for(ContentVersion cv : contentVersionsToInsert){
            docIds.add(cv.Id);
        }
        
        List<ContentVersion> contentVersions = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN  :docIds];
        for(ContentVersion cv : contentVersions){
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cv.ContentDocumentId;
            cdl.LinkedEntityId = docChecklist.Id; 
            //cdl.ShareType = 'V'; 
            cdl.Visibility = 'AllUsers'; 
            contentDocumentLinkToInsert.add(cdl);
        }
        // Insert the ContentVersion records
        insert contentDocumentLinkToInsert;
    }
    
    public static void createDMSTracker(Opportunity opp){
        Tracker__c trackerObj  = new Tracker__c();
        trackerObj.Lead__c =  opp.Lead__c;
        trackerObj.Deal__c = opp.Id;
        trackerObj.Status__c = 'Failure';
        trackerObj.StatusCode__c = 102;
        trackerObj.ApiName__c = 'DMS';
        trackerObj.Record_Type__c = 'ContentDocumentId';
        insert trackerObj;
    }
    
    public static void createSuccessTracker(Opportunity opp){
        List<Tracker__c> trackerList = new List<Tracker__c>();
        for(Integer i=0;i<12;i++){
            Tracker__c trackerObj  = new Tracker__c(Lead__c=opp.Lead__c,Deal__c=opp.Id,Status__c='Success',StatusCode__c=101,ApiName__c='Test'+i);
            trackerList.add(trackerObj);
        }
        insert trackerList;  
    }
    //Bank Statement 
    public static string createBankStatementData() {
        // Name of the Static Resource
        String staticResourceName = 'BankStatementPDF';
        
        // Retrieve the Static Resource
        StaticResource sr;
        try {
            sr = [SELECT Id, Body FROM StaticResource WHERE Name = :staticResourceName LIMIT 1];
        } catch (QueryException e) {
            System.debug('No StaticResource found with the name ' + staticResourceName);
            return 'none';
        }
        
        // Get the PDF as a Blob
        Blob pdfBlob = sr.Body;
        
        // Convert the Blob to a Base64 String
        String base64PDF = EncodingUtil.base64Encode(pdfBlob);
        
        return base64PDF;
        
    }
    
    public static void createFailErrorLog(Opportunity opp){
        Error_log__c errorLog = new Error_log__c();
        errorLog.ApiName__c = 'Test Error Log';
        errorLog.Status__c = 'Error';
        errorLog.Lead__c = opp.Lead__c;
        errorLog.Deal__c = opp.Id;
        insert errorLog;
    }
    
    public static ContentVersion createAadharCVRecord(Boolean isInsert ){
        ContentVersion cvObj = new ContentVersion(Title = 'TEST',PathOnClient = 'Test',VersionData = Blob.valueOf('Test document data'),Document_Type__c = 'Aadhar Card');
        if(isInsert)
            insert cvObj;
        return cvObj;
    }
    
    public static ContentVersion createPANCVRecord(Boolean isInsert ){
        ContentVersion cvObj = new ContentVersion(Title = 'TEST',PathOnClient = 'Test',VersionData = Blob.valueOf('Test document data'),Document_Type__c = 'PAN Card');
        if(isInsert)
            insert cvObj;
        return cvObj;
    }
    
    public static ContentVersion createPassportCVRecord(Boolean isInsert ){
        ContentVersion cvObj = new ContentVersion(Title = 'TEST',PathOnClient = 'Test',VersionData = Blob.valueOf('Test document data'),Document_Type__c = 'Passport');
        if(isInsert)
            insert cvObj;
        return cvObj;
    }
    public static ContentVersion createBankStatementCVRecord(Boolean isInsert ){
        ContentVersion cvObj = new ContentVersion(Title = 'TEST',PathOnClient = 'Test',VersionData = Blob.valueOf('Test document data'),Document_Type__c = 'PAN Card');
        if(isInsert)
            insert cvObj;
        return cvObj;
    }
    
    // create Task Record //Data From
    public static Task createLeadTask(Boolean isInsert){
        datetime d= system.today();
        String datetimeformt= d.format();
        Task TaskObj = new Task(Call_Result__c='Bad Call',agentId__c= Userinfo.getUserId(),Subject='Call',Call_Back_Date_time__c = system.today(),Sales_Comment__c='Completed', call_back_date_time_New__c=datetimeformt, Priority = 'High', Status = 'Completed',ActivityDate = System.Today(),Description = 'Test',OwnerId = userinfo.getUserId() );                        
        
        if(isInsert)
            insert TaskObj;
        return TaskObj;
    }
    //harsh
    public static Task createLeadTask1(Boolean isInsert){
        datetime d= system.today();
        String datetimeformt= d.format();
        Task TaskObj = new Task(Call_Result__c='Call Back',agentId__c= Userinfo.getUserId(),Subject='Call',Call_Back_Date_time__c = system.today(),Sales_Comment__c='Completed', call_back_date_time_New__c=datetimeformt, Priority = 'High', Status = 'Completed',ActivityDate = System.Today(),Description = 'Test',OwnerId = userinfo.getUserId() );                        
        
        if(isInsert)
            insert TaskObj;
        return TaskObj;
    }
    // create Task Record For Task Trigger
    public static Task createTaskRecordTrigger(String CallResultName,Boolean isInsert){
        datetime d= system.today();
        String datetimeformt= d.format();
        Task TaskObj = new Task(Call_Result__c=CallResultName,agentId__c= Userinfo.getUserId(),Subject='Call',Call_Back_Date_time__c = system.today(),Sales_Comment__c='Completed', call_back_date_time_New__c=datetimeformt, Priority = 'High', Status = 'Completed',ActivityDate = System.Today(),Description = 'Test',OwnerId = userinfo.getUserId(),callStartTime__c =system.now(),Caller_Id__c ='08888292103');                        
        
        if(isInsert)
            insert TaskObj;
        return TaskObj;
    }
    
    //For Duplicate Mgt Test Data
    // Create User Record
    public static User createUserActive(Boolean isInsert){
        Profile profileId = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User UserObjActive = new User( FirstName = 'Jatin', LastName = 'Sharma',Email = 'jatinsharma12341@example.com',Username = 'jatinsharmaauxilo@example.com',Alias = 'jshar',ProfileId = profileId.Id, TimeZoneSidKey = 'America/Los_Angeles',LocaleSidKey = 'en_US',EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US',IsActive=true);
        if(isInsert)
            insert UserObjActive;
        return UserObjActive;
    }
     public static UserRole createUserRole(Boolean isInsert){
        UserRole UserRole = new UserRole( Name = 'Credit Manager');
        if(isInsert)
            insert UserRole;
        return UserRole;
    }
    
    public static User createUserInactive(Boolean isInsert){
        Profile profileId = [SELECT Id FROM Profile WHERE Name='Sales Profile'];
        User UserObjInactive = new User( FirstName = 'Nitin', LastName = 'Patil',Email = 'nitinpatil4121@example.com',Username = 'nitinpatilauxilo@example.com',Alias = 'npatil',ProfileId = profileId.Id, TimeZoneSidKey = 'America/Los_Angeles',LocaleSidKey = 'en_US',EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US',IsActive=false);
        if(isInsert)
            insert UserObjInactive;
        return UserObjInactive;
    }
    
    public static Lead createLeadDup1(Boolean isInsert ){
        Lead LeadObj1 = new Lead(FirstName = 'Mangesh', LastName = 'Jadhav', Email = 'mangeshjadhavtsts@gmail.com' ,MobilePhone = '7814545548',KYC_Consent__c = true, Status='Fresh',Service_Branch__c='PUNE',Tuition_Fees__c=1000,Product_Category__c ='HEL - INDIA');
        if(isInsert)
            insert LeadObj1;
        return LeadObj1;
    }
    
    public static Lead createLeadDup2(Boolean isInsert ){
        Lead LeadObj2 = new Lead(FirstName = 'Mangesh', LastName = 'Jadhav', Email = 'mangeshjadhavtsts@gmail.com' ,MobilePhone = '7814545548',KYC_Consent__c = true, Status='Fresh',Service_Branch__c='PUNE',Tuition_Fees__c=1000,Product_Category__c ='HEL - INDIA');
        if(isInsert)
            insert LeadObj2;
        return LeadObj2;
    }
    
    public static Lead createLeadDup3(Boolean isInsert ){
        Lead LeadObj3 = new Lead(FirstName = 'Mangesh', LastName = 'Jadhav', Email = 'mangeshjadhavtsts@gmail.com' ,MobilePhone = '7814545548',KYC_Consent__c = true, Status='Fresh',Service_Branch__c='PUNE',Tuition_Fees__c=1000,Product_Category__c ='HEL - INDIA');
        if(isInsert)
            insert LeadObj3;
        return LeadObj3;
    }
    
    //For PartnerController
    public static Lead createLeadPartner(Boolean isInsert ){
        Lead LeadObjPartner = new Lead(FirstName = 'Mahesh', LastName = 'Kadam', Email = 'maheshkadamsss@gmail.com' ,MobilePhone = '8745754589',KYC_Consent__c = true, Status='Fresh',Service_Branch__c='PUNE',Tuition_Fees__c=1000,Product_Category__c ='HEL - INDIA');
        if(isInsert)
            insert LeadObjPartner;
        return LeadObjPartner;
    } //            Ozontel_API_Configuration_Detail__mdt ozontelApiConfigDetails = BulkOzonetelAPI.callectOzontelApiConfigration(CommonConstant.BULK_DELETE_FROM_OZONTEL);
    
    public static Ozontel_API_Configuration_Detail__mdt getOzontelAPIConfigurationDetailmdt(){
        Ozontel_API_Configuration_Detail__mdt ozontelApiConfigDetails = BulkOzonetelAPI.callectOzontelApiConfigration(CommonConstant.BULK_DELETE_FROM_OZONTEL);     
        return ozontelApiConfigDetails;
    }
    
    public static void createRoundRobbinCustomSetting(){
        
        List<RoundRobinUserCount__c> roundRobinUserCounts = new List<RoundRobinUserCount__c>();
        
        RoundRobinUserCount__c queue1 = new RoundRobinUserCount__c();
        queue1.Current_User_Count__c = 0;
        queue1.Queue_Name__c = 'AHMEDABAD LD';
        queue1.Name = 'AHMEDABAD LD';
        roundRobinUserCounts.add(queue1);
        
        RoundRobinUserCount__c queue2 = new RoundRobinUserCount__c();
        queue2.Current_User_Count__c = 0;
        queue2.Queue_Name__c = 'BENGALURU LD';
        queue2.Name = 'BENGALURU LD';
        roundRobinUserCounts.add(queue2);
        
        RoundRobinUserCount__c queue3 = new RoundRobinUserCount__c();
        queue3.Current_User_Count__c = 0;
        queue3.Queue_Name__c = 'CHENNAI LD';
        queue3.Name = 'CHENNAI LD';
        roundRobinUserCounts.add(queue3);
        
        RoundRobinUserCount__c queue4 = new RoundRobinUserCount__c();
        queue4.Current_User_Count__c = 0;
        queue4.Queue_Name__c = 'Contact Center LD';
        queue4.Name = 'Contact Center LD';
        roundRobinUserCounts.add(queue4);
        
        RoundRobinUserCount__c queue5 = new RoundRobinUserCount__c();
        queue5.Current_User_Count__c = 0;
        queue5.Queue_Name__c = 'DELHI LD';
        queue5.Name = 'DELHI LD';
        roundRobinUserCounts.add(queue5);
        
        RoundRobinUserCount__c queue6 = new RoundRobinUserCount__c();
        queue6.Current_User_Count__c = 0;
        queue6.Queue_Name__c = 'Gradright East Queue';
        queue6.Name = 'Gradright East Queue';
        roundRobinUserCounts.add(queue6);
        
        RoundRobinUserCount__c queue7 = new RoundRobinUserCount__c();
        queue7.Current_User_Count__c = 0;
        queue7.Queue_Name__c = 'Gradright West Queue';
        queue7.Name = 'Gradright West Queue';
        roundRobinUserCounts.add(queue7);
        
        RoundRobinUserCount__c queue8 = new RoundRobinUserCount__c();
        queue8.Current_User_Count__c = 0;
        queue8.Queue_Name__c = 'Gradright North Queue';
        queue8.Name = 'Gradright North Queue';
        roundRobinUserCounts.add(queue8);
        
        RoundRobinUserCount__c queue9 = new RoundRobinUserCount__c();
        queue9.Current_User_Count__c = 0;
        queue9.Queue_Name__c = 'Gradright South Queue';
        queue9.Name = 'Gradright South Queue';
        roundRobinUserCounts.add(queue9);
        
        RoundRobinUserCount__c queue10 = new RoundRobinUserCount__c();
        queue10.Current_User_Count__c = 0;
        queue10.Queue_Name__c = 'Gradright Queue';
        queue10.Name = 'Gradright Queue';
        roundRobinUserCounts.add(queue10);
        
        RoundRobinUserCount__c queue11 = new RoundRobinUserCount__c();
        queue11.Current_User_Count__c = 0;
        queue11.Queue_Name__c = 'HYDERABAD LD';
        queue11.Name = 'HYDERABAD LD';
        roundRobinUserCounts.add(queue11);
        
        RoundRobinUserCount__c queue12 = new RoundRobinUserCount__c();
        queue12.Current_User_Count__c = 0;
        queue12.Queue_Name__c = 'MUMBAI LD';
        queue12.Name = 'MUMBAI LD';
        roundRobinUserCounts.add(queue12);
        
        RoundRobinUserCount__c queue13 = new RoundRobinUserCount__c();
        queue13.Current_User_Count__c = 0;
        queue13.Queue_Name__c = 'PUNE LD';
        queue13.Name = 'PUNE LD';
        roundRobinUserCounts.add(queue13);
        
        RoundRobinUserCount__c queue14 = new RoundRobinUserCount__c();
        queue14.Current_User_Count__c = 0;
        queue14.Queue_Name__c = 'Yocketz East Queue';
        queue14.Name = 'Yocketz East Queue';
        roundRobinUserCounts.add(queue14);
        
        RoundRobinUserCount__c queue15 = new RoundRobinUserCount__c();
        queue15.Current_User_Count__c = 0;
        queue15.Queue_Name__c = 'Yocketz West Queue';
        queue15.Name = 'Yocketz West Queue';
        roundRobinUserCounts.add(queue15);
        
        RoundRobinUserCount__c queue16 = new RoundRobinUserCount__c();
        queue16.Current_User_Count__c = 0;
        queue16.Queue_Name__c = 'Yocketz North Queue';
        queue16.Name = 'Yocketz North Queue';
        roundRobinUserCounts.add(queue16);
        
        RoundRobinUserCount__c queue17 = new RoundRobinUserCount__c();
        queue17.Current_User_Count__c = 0;
        queue17.Queue_Name__c = 'Yocketz South Queue';
        queue17.Name = 'Yocketz South Queue';
        roundRobinUserCounts.add(queue17);
        
        RoundRobinUserCount__c queue18 = new RoundRobinUserCount__c();
        queue18.Current_User_Count__c = 0;
        queue18.Queue_Name__c = 'Yocketz Queue';
        queue18.Name = 'Yocketz Queue';
        roundRobinUserCounts.add(queue18);
        
        RoundRobinUserCount__c queue19 = new RoundRobinUserCount__c();
        queue19.Current_User_Count__c = 0;
        queue19.Queue_Name__c = 'AHMEDABAD';
        queue19.Name = 'AHMEDABAD';
        roundRobinUserCounts.add(queue19);
        
        RoundRobinUserCount__c queue20 = new RoundRobinUserCount__c();
        queue20.Current_User_Count__c = 0;
        queue20.Queue_Name__c = 'BENGALURU';
        queue20.Name = 'BENGALURU';
        roundRobinUserCounts.add(queue20);
        
        RoundRobinUserCount__c queue21 = new RoundRobinUserCount__c();
        queue21.Current_User_Count__c = 0;
        queue21.Queue_Name__c = 'CHENNAI';
        queue21.Name = 'CHENNAI';
        roundRobinUserCounts.add(queue21);
        
        RoundRobinUserCount__c queue22 = new RoundRobinUserCount__c();
        queue22.Current_User_Count__c = 0;
        queue22.Queue_Name__c = 'DELHI';
        queue22.Name = 'DELHI';
        roundRobinUserCounts.add(queue22);
        
        RoundRobinUserCount__c queue23 = new RoundRobinUserCount__c();
        queue23.Current_User_Count__c = 0;
        queue23.Queue_Name__c = 'HYDERABAD';
        queue23.Name = 'HYDERABAD';
        roundRobinUserCounts.add(queue23);
        
        RoundRobinUserCount__c queue24 = new RoundRobinUserCount__c();
        queue24.Current_User_Count__c = 0;
        queue24.Queue_Name__c = 'MUMBAI';
        queue24.Name = 'MUMBAI';
        roundRobinUserCounts.add(queue24);
        
        RoundRobinUserCount__c queue25 = new RoundRobinUserCount__c();
        queue25.Current_User_Count__c = 0;
        queue25.Queue_Name__c = 'PUNE';
        queue25.Name = 'PUNE';
        roundRobinUserCounts.add(queue25);
        
        insert roundRobinUserCounts;
        
        
    }
    public static Lead createLeadTaskTrigger(String StageName,String StatusName,Boolean isInsert ){
        Campaign campaignObject = createCampaign(false);
        campaignObject.Name ='Call_Back';
        campaignObject.Campaign_logic__c = 'Status = Fresh && KYC_Consent__c = true';
        campaignObject.IsActive = true;
        insert campaignObject;
        Campaign campaignObjectChild = createCampaign(false);
        campaignObjectChild.Name ='Other';
        campaignObjectChild.ParentId =campaignObject.Id;
        campaignObjectChild.Campaign_logic__c = 'Status = Fresh && KYC_Consent__c = true';
        campaignObjectChild.IsActive = true;
        insert campaignObjectChild;
        Dedupe_Management__c customSettingDedupeManagemen = CreateDedupeManagementCustomSetting(true);
        Account AccountObj = createAccount(true);
        //Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id];
        Source__c objSource = createSourceWithoutPartner(true);
        Lead LeadObj = new Lead(FirstName = 'Rajendra', MiddleName = 'Akshay',LastName = 'Patil',	Source_Name__c =objSource.Id, Email = 'mangeshjadhavtsts@gmail.com' ,MobilePhone = '7814545548',KYC_Consent__c = true, Status=StageName,Status__c=StatusName,Service_Branch__c='PUNE',Tuition_Fees__c=1000,Source_Category__c='Partner',OwnerId =createUser(true).Id,Product_Category__c ='HEL - INDIA');
        if(isInsert)
            insert LeadObj;
        return LeadObj;
    }
    
    //for LOS api tracker with same apiname
    public static List<Tracker__c> createSameTracker(Opportunity opp){
        List<Tracker__c> trackerList = new List<Tracker__c>();
        for(Integer i=0;i<2;i++){
            Tracker__c trackerRecord = new Tracker__c(ApiName__c='Test',Deal__c=opp.Id,Lead__c=opp.Lead__c,Status__c='Success');
            trackerList.add(trackerRecord);
        }
        insert trackerList;
        return trackerList;
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
    public static List<Liability__c> createLiabilityList(Boolean isInsert){
        List<Liability__c> Liabilitylist = new List<Liability__c>();
        Liability__c Liabilitysobj = new Liability__c(Loan_Type__c = 'BL');
        Liabilitylist.add(Liabilitysobj);
        if(isInsert)
            insert Liabilitylist ;
        return Liabilitylist ;
    } 
    public static University__c createUniversity(Boolean isInsert,String countryName) {
        University__c universityObj = new University__c(Name = 'Test University',Country_Name__c = countryName,Country_Code__c='123456');
        if(isInsert)
            insert universityObj;
        return universityObj;
    }
    
    public static Institute__c createInstitute(Boolean isInsert,Id universityId) {
        Institute__c instituteObj = new Institute__c(Name = 'Test Institute',University__c = universityId, Address__c='New Avenue',State__c='US',Ranking_by_Auxilo__c= 'A',City__c='Gainesville',Country__c ='UNITED STATES OF AMERICA');
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
    
    public static ContentVersion createContentVersion(Boolean isInsert){
        Account accObj = new Account();
        
        ContentVersion Contversionobj = new ContentVersion(	Document_Type__c = 'Aadhar Card', Applicant_Type__c= 'Applicant',	Account__c =accObj.id,	Document_Sub_Type__c='Aadhar Back',Title = 'Aadhar_card_front.png',PathOnClient = 'Photo.png',VersionData = Blob.valueOf('Test Photo'));
        if(isInsert)
            insert Contversionobj ;
        return Contversionobj ;
    }
    
    public static ContentDocumentLink createContentDocumentLink(Boolean isInsert){
        ContentDocumentLink objcdl = new ContentDocumentLink();
        if(isInsert)
            insert objcdl ;
        return objcdl ;
    }
    
    public static Document_Checklist__c createDocumnetChecklist(Boolean isInsert){
        Document_Checklist__c objdcl = new Document_Checklist__c(Applicant_Name__c = 'Test');
        if(isInsert)
            insert objdcl ;
        return objdcl ;
    }
    
    public static Document_Checklist_Master__c createDocumnetChecklistMaster(Boolean isInsert){
        Document_Checklist_Master__c objdcl = new Document_Checklist_Master__c(Document_Type__c = 'Other Document');
        if(isInsert)
            insert objdcl ;
        return objdcl ;
    }
     public static Document_Checklist_Master__c createDocumnetChecklistMaster1(Boolean isInsert){
        Document_Checklist_Master__c objdcl = new Document_Checklist_Master__c(Document_Type__c = 'Other Document',	Document_Sub_Type__c='Application Form',Auto_Create_Checklist__c=false,Applicant_Type__c='Applicant');
        if(isInsert)
            insert objdcl ;
        return objdcl ;
    }
    
    
    public static void createInboundSource(Boolean isInsert){
        Account acc= new Account(Name='Inbound');
        insert acc;
        Source__c inboundSource = new Source__c();
        inboundSource.Lead_Gate__c = 'Open Market';
        inboundSource.Lead_Source__c = 'Organic';
        inboundSource.Source_Type__c = 'Inbound Phone Call';
        inboundSource.Sub_Source_Type__c = 'Inbound Phone Call';
        inboundSource.Partner_Name__c = acc.Id;
        inboundSource.Name = 'Inbound';
        
        if(isInsert)
            insert inboundSource;      
    }
    
    public static void createFailDocuments(Opportunity opp,Integer size){
        List<ContentVersion> contentVersionsToInsert = new List<ContentVersion>();
        Set<Id> docIds = new Set<Id>();
        Document_Checklist__c docChecklist = new Document_Checklist__c();
        docChecklist.Applicant_Name__c = 'Test';
        docChecklist.Applicant_Type__c = 'Applicant';
        docChecklist.Document_DMS_Name__c = 'TestDoc';
        docChecklist.Deal__c = opp.Id;
        insert docChecklist;
        
        List<ContentDocumentLink> contentDocumentLinkToInsert = new List<ContentDocumentLink>();
        
        for (Integer i = 1; i <= size; i++) {
            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S'; 
            cv.PathOnClient = 'path/to/file' + i + '.pdf'; 
            cv.Title = 'File ' + i+'.jpg'; 
            cv.VersionData = Blob.valueOf('Content of file ' + i); 
            contentVersionsToInsert.add(cv);
        }
        insert contentVersionsToInsert;
        for(ContentVersion cv : contentVersionsToInsert){
            docIds.add(cv.Id);
        }
        
        List<ContentVersion> contentVersions = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN  :docIds];
        for(ContentVersion cv : contentVersions){
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cv.ContentDocumentId;
            cdl.LinkedEntityId = docChecklist.Id; 
            //cdl.ShareType = 'V'; 
            cdl.Visibility = 'AllUsers'; 
            contentDocumentLinkToInsert.add(cdl);
        }
        // Insert the ContentVersion records
        insert contentDocumentLinkToInsert;
        
        Tracker__c trackerObj  = new Tracker__c();
        trackerObj.Lead__c =  opp.Lead__c;
        trackerObj.Deal__c = opp.Id;
        trackerObj.Status__c = 'Failure';
        trackerObj.StatusCode__c = 102;
        trackerObj.ApiName__c = 'DMS';
        trackerObj.Record_Type__c = 'ContentDocumentId';
        trackerObj.Record_Id__c = docChecklist.Id;
        insert trackerObj;
    }
     public static void ReportEmaillead(Boolean isInsert){
            Lead leadObj = new Lead(FirstName = 'Rajendra',LastName = 'Patil',Email = 'rajendratstpatil@example.com',MobilePhone = '9673741025',Source_Name__c=createSourceWithoutPartner(true).Id);
            insert leadObj;
    }
}