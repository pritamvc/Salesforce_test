public with sharing class LeadApplicantDetailsClone {
    @AuraEnabled(cacheable=true)
    public static wrapperClassForCommForm getLeadRelatedRecord(String leadGetId) {  
        ///Added By Dhanashri
         List<Document_Checklist__c> dclList = new   List<Document_Checklist__c>();
         Map<Id,list<Document_Checklist__c>> mapapplicantIdvsListOfdcl = new  Map<Id,list<Document_Checklist__c>>();
        Map<Document_Checklist__c,list<ContentVersion>> mapdclVsContentVersion = new Map<Document_Checklist__c,list<ContentVersion>>();
        MAP<Id, list<ContentVersion>> ContentDocIDVSContentVersion = new MAP<Id, list<ContentVersion>>();
        MAP<Id, list<ContentVersion>> ContentdocumentLinnkVSContentVersion = new MAP<Id, list<ContentVersion>>();
         Set<Id> dclIds = new  Set<Id>();
        Set<Id> contentdocId = new  Set<Id>();
         List<ContentDocumentLink> cdlinkList = new  List<ContentDocumentLink>();
        //

        System.debug('String leadGetId:::>>>' + leadGetId);
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
                       Loan_Required_A_B__c, Institute_Name__c, Campus__c, KYC_Consent__c, Applicant_Section__c From Lead Where id =: leadGetId];  
        }
        catch (Exception e) {
            
        }
      
        Co_Applicant__c appliAcc;
        try{
            appliAcc = [SELECT Id, Name,Type__c,Account__r.Lead__c,Relation_with_applicant__c,Relationship_Proof__c,Applicant_Type__c,Account__c,Account__r.Name, Account__r.Father_First_Name__c,
                        Account__r.Father_Middle_Name__c, Account__r.Father_Last_Name__c,Account__r.Gender__c,
                        Account__r.PAN_Number__c, Account__r.Aadhar_Number__c,Account__r.Driving_License_Number__c, Account__r.Voter_ID__c,
                        Account__r.NREG_Number__c,Account__r.CKYC_Number__c,Account__r.Passport_File_Number__c,
                        Account__r.Is_Income_Considered_Is_Financial__c, Account__r.Passport_Number__c, 
                        Account__r.Mother_Middle_Name__c, Account__r.Mother_Last_Name__c, Account__r.Mother_Frist_Name__c,
                        Account__r.Marital_Status__c, Account__r.Spouse_s_First_Name__c, Account__r.PersonMobilePhone, Account__r.PersonEmail,
                        Account__r.Spouse_s_Middle_name__c, Account__r.Spouse_s_Last_Name__c, 
                        Account__r.Is_Communication_address__c,Account__r.Date_of_Birth__c, Aadhar_Verified__c,Email_Verified__c,Mobile_Number_Verified__c,Pan_verified__c FROM Co_Applicant__c WHERE Lead__c =: leadGetId 
                        AND Type__c = 'Applicant' LIMIT 1];
        }
        catch (Exception e) {
            System.debug('Exception occured Co_Applicant__c appliAcc.');
        }
        ///Added By Dhanashri
        dclList = [Select Id,Lead__c,Applicant__c,Doc_Sub_Type__c,Applicant__r.Account__c from Document_Checklist__c
                                               where Lead__c =: leadGetId AND Applicant__c =: appliAcc.Id ];
        system.debug('dclList:::'+dclList); 
         
        if(dclList.size() > 0){
            for(Document_Checklist__c dcl :dclList){
                IF(mapapplicantIdvsListOfdcl.get(dcl.Applicant__r.Account__c) == null){
                    mapapplicantIdvsListOfdcl.put(dcl.Applicant__r.Account__c,new list<Document_Checklist__c>{dcl}); 
                }else{
                    mapapplicantIdvsListOfdcl.get(dcl.Applicant__r.Account__c).add(dcl);
                }
               
                dclIds.add(dcl.Id);
            }  
        }
        system.debug('mapapplicantIdvsListOfdcl:::'+mapapplicantIdvsListOfdcl);      
        
        If(dclIds.size() > 0){
            cdlinkList =[SELECT Id,ContentDocumentId,LinkedEntityId,ContentDocument.Title,ContentDocument.FileType 
                         from ContentDocumentLink where LinkedEntityId IN:dclIds ];
            system.debug('cdlinkList:::'+cdlinkList);  
        }
        
        if(cdlinkList != null && cdlinkList.size() > 0){
            for(ContentDocumentLink cdl :cdlinkList){
                contentdocId.add(cdl.ContentDocumentId);
            }
        }
         system.debug('contentdocId:::'+contentdocId);
        
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        contentVersionList = [SELECT Id, Title,ContentDocumentId ,Document_Type__c,Document_Sub_Type__c,Account__c FROM ContentVersion WHERE 
                              ContentDocumentId IN:contentdocId];
        system.debug('contentVersionLi=> ' +contentVersionList.size());
        
        for(ContentVersion objcv : contentVersionList){
            if(ContentDocIDVSContentVersion.get(objcv.ContentDocumentId) == null){
                ContentDocIDVSContentVersion.put(objcv.ContentDocumentId, new list<ContentVersion>{objcv}); 
            }else{
                ContentDocIDVSContentVersion.get(objcv.ContentDocumentId).add(objcv);
            }
           
        }        
        system.debug('ContentDocIDVSContentVersion=> ' +ContentDocIDVSContentVersion);
        
        for(ContentDocumentLink objcontent : cdlinkList){
            if(ContentDocIDVSContentVersion.containskey(objcontent.ContentDocumentId)){
                ContentdocumentLinnkVSContentVersion.put(objcontent.LinkedEntityId, ContentDocIDVSContentVersion.get(objcontent.ContentDocumentId));
                    }
        }
        system.debug('ContentdocumentLinnkVSContentVersion=> ' +ContentdocumentLinnkVSContentVersion);
        
        for(Document_Checklist__c dcl :dclList){
            if(ContentdocumentLinnkVSContentVersion.containskey(dcl.Id)){
                mapdclVsContentVersion.put(dcl, ContentdocumentLinnkVSContentVersion.get(dcl.Id));
            }
        }
        system.debug('mapdclVsContentVersion=> ' +mapdclVsContentVersion);
            //wrapperClassForCommForm objwrapperForApplicant = new wrapperClassForCommForm();
          //   objwrapperForApplicant.objeAcc = appliAcc.Id;
        
            List<String> aadharList = new List<String>();
            List<String> panList = new List<String>();
            List<String> passportList = new List<String>();
        
        if(mapapplicantIdvsListOfdcl.containsKey(appliAcc.Account__c)){
            system.debug('Line 116:::');
                   for(Document_Checklist__c dcl :mapapplicantIdvsListOfdcl.get(appliAcc.Account__c)){
                if(mapdclVsContentVersion.containsKey(dcl)){
                    for(ContentVersion objContentVersion: mapdclVsContentVersion.get(dcl)){
                        if(dcl.Doc_Sub_Type__c == 'Aadhar Card'){
                            system.debug('Line List121:::');
                            aadharList.add(objContentVersion.Title);
                            system.debug('Line List123:::');
                        }
                        if(dcl.Doc_Sub_Type__c == 'PAN Card'){
                            panList.add(objContentVersion.Title);
                        }
                        if(dcl.Doc_Sub_Type__c == 'Passport'){
                            passportList.add(objContentVersion.Title);
                        }
                    }
                    //objwrapperForApplicant.aadharList = aadharList;
                    system.debug('aadharList:::'+aadharList);
                   // objwrapperForApplicant.panList = panList;
                    //objwrapperForApplicant.passportList = passportList;
                    
                }
            }
            }
        
        
        ////END//
        
        //List<ContactPointAddress> AppliCurrentAddress = new List<ContactPointAddress>();
        ContactPointAddress AppliCurrentAddress = new ContactPointAddress();
        ContactPointAddress AppliPermanentAddress = new ContactPointAddress();
        
        try{
            AppliCurrentAddress= [SELECT Id,Name,Lead__c,Address_Type__c,Address_Proof__c,Address_1__c,City__c,
                                  Country__c,District__c,Landmark__c,Pin_Code__c,State__c,Taluka__c, Years_In_The_Address__c,Is_Communication_address__c
                                  FROM ContactPointAddress WHERE Lead__c =: leadGetId AND Account__c =: appliAcc.Account__c AND Address_Type__c = 'Current Address' LIMIT 1];
            
            AppliPermanentAddress= [SELECT Id,Name,Lead__c,Address_Type__c,Address_Proof__c,Address_1__c,City__c,
                                    Country__c,District__c,Landmark__c,Pin_Code__c,State__c,Taluka__c, Years_In_The_Address__c,Is_Communication_address__c,
                                    Same_as_Current_Address__c  FROM ContactPointAddress WHERE Lead__c =: leadGetId AND Account__c =: appliAcc.Account__c
                                    AND Address_Type__c = 'Permanent Address' LIMIT 1];
        }
        catch (Exception e) {
            System.debug('Error Message: ' + e.getMessage());
        }
        
        //Get Demography 
        Demography__c DemographyDetails = new Demography__c();
        try{
            DemographyDetails = [SELECT Id, Father_s_First_Name__c, Father_s_Middle_Name__c, Father_s_Last_Name__c, Mother_s_First_Name__c,
                                 Mother_s_Middle_Name__c, Mother_s_Last_Name__c, Spouse_s_First_Name__c, Spouse_s_Middle_name__c, Spouse_s_Last_Name__c,
                                 Account__c, Lead__c
                                 FROM Demography__c
                                 WHERE Lead__c =: leadGetId AND Account__c =: appliAcc.Account__c];
        }
        catch (Exception e) {
            System.debug('Exception occured.');
        }
        
        /*List<Co_Applicant__c> coApplicantAcc;
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
                              Account__r.Is_Communication_address__c,Account__r.Date_of_Birth__c FROM Co_Applicant__c WHERE Lead__c =:leadGetId
                              AND Type__c = 'Co-applicant'];
        }
        catch (Exception e) {
            System.debug('Exception occured Co_Applicant__c coApplicantAcc.');
        }*/
        
        wrapperClassForCommForm wc = new wrapperClassForCommForm();
        if(lstLead != null)
            wc.LeadRecords = lstLead;  
        if(appliAcc != null)        
            wc.AccRecords = appliAcc;
        //if(AppliCurrentAddress != null && AppliCurrentAddress.size() > 0)
           // wc.CPAAppliCurrentRecord = AppliCurrentAddress[0]; 
        if(AppliCurrentAddress != null)
            wc.CPAAppliCurrentRecord = AppliCurrentAddress;
        if(AppliPermanentAddress != null)
            wc.CPAAppliPermanentRecord = AppliPermanentAddress;  
        /*if(coApplicantAcc != null)
            wc.AccCoAppliRecords = coApplicantAcc;*/
        if(DemographyDetails != null)
            wc.DemographyRecord = DemographyDetails;
        if(aadharList.size() > 0)
            wc.aadharList = aadharList;
        if(panList.size() > 0)
            wc.panList = panList;
        if(passportList.size() > 0)
            wc.passportList = passportList;
        return wc;   
    }
    
    /********************************************************************************************************
* @author          Rohit Pardeshi
* @description     This Method is use save lead related data like Account, Address, Demography, Co-applicant
* @param           String leadGetId --> Getting from leadApplicantDetailS LWC Component
* @return          wrapperClassForCommForm --> Which includes data related to Lead, Account, Co-aaplicant, Address & 
Demography which is used in leadApplicantDetails LWC Component
*                       
* @date            01-18-2023   
********************************************************************************************************/
    @AuraEnabled
    public static wrapperClassForCommForm creatUpdateApplicantRecord(String wrapperCommFormDetails) {
        
        String accID;
        Co_Applicant__c coApp = new Co_Applicant__c();
        List<Document_Checklist__c> dcList = new List<Document_Checklist__c>();
        //Lead upsert 
        wrapperClassForCommForm wrapperRecords = (wrapperClassForCommForm)json.deserialize(wrapperCommFormDetails,wrapperClassForCommForm.Class);      
        Lead singleleadSaveRecord = (Lead)json.deserialize(wrapperRecords.leadSaveRec,Lead.Class);
        system.debug('singleleadSaveRecord' +singleleadSaveRecord.Id);
        Lead objLead = [SELECT Id, Email, MobilePhone FROM Lead WHERE Id =: singleleadSaveRecord.Id];
        if(singleleadSaveRecord != null){
            singleleadSaveRecord.Email = objLead.Email;
            singleleadSaveRecord.MobilePhone = objLead.MobilePhone;
            update singleleadSaveRecord;
        }  
        
        Account AccUpdate = (Account)json.deserialize(wrapperRecords.appliAccSaveRec,Account.Class);
        Co_Applicant__c coAppUpdate  = (Co_Applicant__c)json.deserialize(wrapperRecords.appliAccSaveRec,Co_Applicant__c.Class);
        List<Co_Applicant__c> applicantList =[SELECT Id,Lead__c,Name,Account__c,Type__c, Is_Income_Considered_Financial__c,Consent__c
                                              FROM Co_Applicant__c
                                              WHERE Lead__c=: singleleadSaveRecord.Id AND Type__c =: 'Applicant'];
        
        if(applicantList.size() > 0){
            for(Co_Applicant__c accfetchId :applicantList){
                accID = accfetchId.Account__c;
            }
        }
        
        if(AccUpdate.Id != null && applicantList.size() == 0){
            update AccUpdate;
            
            coApp.Type__c = 'Applicant';
            coApp.Account__c = AccUpdate.Id;
            coApp.Lead__c = singleleadSaveRecord.Id;
            coApp.Aadhar_Verified__c = coAppUpdate.Aadhar_Verified__c;
            coApp.Email_Verified__c = coAppUpdate.Email_Verified__c;
            coApp.Mobile_Number_Verified__c = coAppUpdate.Mobile_Number_Verified__c;
            coApp.Pan_verified__c = coAppUpdate.Pan_verified__c;
            if(AccUpdate.Is_Income_Considered_Is_Financial__c == 'Yes'){
                coApp.Is_Income_Considered_Financial__c = 'Yes';
            }
            else{
                coApp.Is_Income_Considered_Financial__c = 'No';
            }
            if(singleleadSaveRecord.KYC_Consent__c == true){
                coApp.Consent__c = true;
            }
            else{
                coApp.Consent__c = false;
            }
            insert coApp;
        }
        else if((AccUpdate.Id == null || accID == null) && applicantList.size() == 0){
            insert AccUpdate;
           
            coApp.Type__c = 'Applicant';
            coApp.Account__c = AccUpdate.Id;
            coApp.Lead__c = singleleadSaveRecord.Id;
            coApp.Aadhar_Verified__c = coAppUpdate.Aadhar_Verified__c;
            coApp.Email_Verified__c = coAppUpdate.Email_Verified__c;
            coApp.Mobile_Number_Verified__c = coAppUpdate.Mobile_Number_Verified__c;
            coApp.Pan_verified__c = coAppUpdate.Pan_verified__c;
            if(AccUpdate.Is_Income_Considered_Is_Financial__c == 'Yes'){
                coApp.Is_Income_Considered_Financial__c = 'Yes';
            }
            else{
                coApp.Is_Income_Considered_Financial__c = 'No';
            }
            if(singleleadSaveRecord.KYC_Consent__c == true){
                coApp.Consent__c = true;
            }
            else{
                coApp.Consent__c = false;
            }
            insert coApp;           
        }else if(AccUpdate.Id != null && applicantList.size() > 0){
            update AccUpdate;
            
            List<Co_Applicant__c> updateCoAppliacnt = new List<Co_Applicant__c>();
            for(Co_Applicant__c coAppli : applicantList){
                coAppli.Aadhar_Verified__c = coAppUpdate.Aadhar_Verified__c;
                coAppli.Email_Verified__c = coAppUpdate.Email_Verified__c;
                coAppli.Mobile_Number_Verified__c = coAppUpdate.Mobile_Number_Verified__c;
                coAppli.Pan_verified__c = coAppUpdate.Pan_verified__c;
                if(AccUpdate.Is_Income_Considered_Is_Financial__c == 'Yes'){
                    coAppli.Is_Income_Considered_Financial__c = 'Yes';
                }
                else{
                    coAppli.Is_Income_Considered_Financial__c = 'No';
                }
                if(singleleadSaveRecord.KYC_Consent__c == true){
                    coAppli.Consent__c = true;
                }
                else{
                    coAppli.Consent__c = false;
                }
                
                updateCoAppliacnt.add(coAppli);
            }
            
            update updateCoAppliacnt;
            
        }
        
        //For saving current address
        if(wrapperRecords.appliCurrentAddSave != null){
            ContactPointAddress ApplicantcurrentAdd = (ContactPointAddress)json.deserialize(wrapperRecords.appliCurrentAddSave,ContactPointAddress.Class);
            if(ApplicantcurrentAdd != null){  
                ApplicantcurrentAdd.Account__c = AccUpdate.Id;
                ApplicantcurrentAdd.Lead__c = singleleadSaveRecord.Id;
                upsert ApplicantcurrentAdd;
            }
        }
        //For saving permanent address
        if(wrapperRecords.appliPermanentAddSave != null){
            ContactPointAddress ApplicantpermanentAdd = (ContactPointAddress)json.deserialize(wrapperRecords.appliPermanentAddSave,ContactPointAddress.Class);
            if(ApplicantpermanentAdd != null){  
                ApplicantpermanentAdd.Account__c = AccUpdate.Id;
                ApplicantpermanentAdd.Lead__c = singleleadSaveRecord.Id;
                upsert ApplicantpermanentAdd;
            }          
        }
        
        //For Demography
        Demography__c DemographySaveRecord = (Demography__c)json.deserialize(wrapperRecords.demoSaveRec,Demography__c.Class);        
        
        if(DemographySaveRecord != null){
            DemographySaveRecord.Lead__c =singleleadSaveRecord.Id;
            DemographySaveRecord.Account__c = AccUpdate.Id;
            upsert DemographySaveRecord;
        }      
        
        Co_Applicant__c apllicantrec = [SELECT Id FROM Co_Applicant__c WHERE Lead__c =: singleleadSaveRecord.Id AND Type__c = 'Applicant'];
        system.debug('apllicantrec' +apllicantrec);
        dcList = [Select Id,Lead__c,Applicant__c from Document_Checklist__c where Lead__c =: singleleadSaveRecord.Id AND Applicant__c =: apllicantrec.Id];
        system.debug('dcList' +dcList.size());
        if(dcList.size() == 0){
            system.debug('INSIDE DCLIST NULL');
           CreateDocumentChecklistRecords.documentCheklistmaster(singleleadSaveRecord.Id, apllicantrec.Id); 
        }
        system.debug('Calling updateContentVersionRecord');
        //updateContentVersionRecord(wrapperCommFormDetails);
        wrapperClassForCommForm wc = getLeadRelatedRecord(singleleadSaveRecord.Id);
        return wc;
    }
    
    @AuraEnabled
    public static Area__c getPin(String pin){
        system.debug('pin=> ' +pin);
        Area__c area = new  Area__c();
        area = [Select Id,City_Name__c,State__c,Country__c,Area_Name_Taluka__c From Area__c 
                WHERE Name =: pin];
        return area;
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
    
    //Added by Avadhut Lead Passport number Get data
    @AuraEnabled
    public static Lead getLeadPassportNum(String leadGetId) {
        System.debug('String leadGetId getLeadPassportNum ====> ' + leadGetId);
        Lead leadPassportNum = [SELECT Id,MobilePhone,Email FROM Lead WHERE Id =: leadGetId];
        System.debug('leadPassportNum Record ---> ' + leadPassportNum);                 
        
        return leadPassportNum;
    }
    
    //Added by Rohit 
    public static void updateContentVersionRecord(String wrapperCommFormDetails){
        Map<String, String> AppAndDocTypeVsMasterLable = New Map<String, String>();
        List<ContentVersion> updateContentVersion = New List<ContentVersion>();
        List<String> docName = new List<String>{'Aadhar Back', 'Aadhar Front', 'Pan', 'Passport Front', 'Passport Back' , 
            'Voter Front', 'Voter Back', 'Driving Licence Back' , 'Driving Licence Front'};
                
                List<Document_Name_DMS__mdt> customMetadataRecords = [SELECT MasterLabel, Applicant_Type__c, Document_Type__c 
                                                                      FROM Document_Name_DMS__mdt WHERE Document_Type__c IN :docName];
        system.debug('customMetadataRecords' +customMetadataRecords);
        
        for (Document_Name_DMS__mdt customMetadata : customMetadataRecords){
            AppAndDocTypeVsMasterLable.put(customMetadata.Applicant_Type__c+customMetadata.Document_Type__c, customMetadata.MasterLabel);
        }
        
        system.debug('AppAndDocTypeVsMasterLable=> ' +AppAndDocTypeVsMasterLable);
        
        wrapperClassForCommForm wrapperRecords = (wrapperClassForCommForm)json.deserialize(wrapperCommFormDetails,wrapperClassForCommForm.Class);      
        Lead singleleadSaveRecord = (Lead)json.deserialize(wrapperRecords.leadSaveRec,Lead.Class);
        
        Account AccUpdate = (Account)json.deserialize(wrapperRecords.appliAccSaveRec,Account.Class);
        
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        contentVersionList = [SELECT Id, Title, Document_Sub_Type__c FROM ContentVersion WHERE Lead__c =: singleleadSaveRecord.Id AND Account__c =: AccUpdate.Id];
        system.debug('contentVersionLi=> ' +contentVersionList.size());
        
        for(ContentVersion objContentVersion : contentVersionList){
            if(AppAndDocTypeVsMasterLable.containsKey('Applicant'+objContentVersion.Document_Sub_Type__c)){
                objContentVersion.Title = AppAndDocTypeVsMasterLable.get('Applicant'+objContentVersion.Document_Sub_Type__c);
                updateContentVersion.add(objContentVersion);
            }
        }
        
        try {
            update updateContentVersion;
        } catch (Exception e) {
            System.debug('Error message: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Boolean isPassportUploaded(String leadId) {
        Boolean isUploaded = false;
        
        List<ContentVersion> versions = [SELECT Id FROM ContentVersion WHERE Lead__c = :leadId AND (Title = 'passport_back_App_1' OR Title = 'passport_front_App_1') LIMIT 1];
        
        if (!versions.isEmpty()) {
            isUploaded = true;
        }
        
        return isUploaded;
    }
    
    //Return Co_Applicant__c Mobile,email lead with Income considered as financial
    @AuraEnabled
    public static List<Co_Applicant__c> getFinancialCoApplicants(String leadGetId){
        List<Co_Applicant__c> financialCoApplicants = new  List<Co_Applicant__c>();
        financialCoApplicants = [Select Id,Name,Account__c,Account__r.Name,Account__r.Id,Type__c,Account__r.PersonMobilePhone,Account__r.Email__c,Is_Income_Considered_Financial__c from Co_Applicant__c where Lead__r.Id = :leadGetId AND Is_Income_Considered_Financial__c = 'Yes'AND Type__c != 'Applicant'];
        return financialCoApplicants;         
    }
    
    //To get the Account Ids of Applicant
    @AuraEnabled
    public static Id getCoApplicant(String leadId){
        Id accountId;
        try {  
            List<Co_Applicant__c> lstApp = [SELECT Id, Type__c, Account__c
                                            FROM Co_Applicant__c WHERE Lead__c =: leadId AND Type__c != 'Applicant' LIMIT 1];
            
            if(lstApp.size() > 0){
                accountId = lstApp[0].Account__c;
            }
            system.debug('accountId=>>' +accountId);
            return accountId;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
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
        public Demography__c DemographyRecord{get;set;}
        @AuraEnabled
        public String demoSaveRec{get;set;}
        @AuraEnabled
        public List<Co_Applicant__c> AccCoAppliRecords{get;set;}
        @AuraEnabled
        public List<String> panList{get;set;}
        @AuraEnabled
        public List<String> aadharList{get;set;}
        @AuraEnabled
        public List<String> passportList{get;set;}
        @AuraEnabled
        public List<String> contentVersionList{get;set;}
}
}