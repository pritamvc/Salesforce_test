/*********************************************************************************************
* @author          Thinqloud Solutions (Rohit Pardeshi)
* @description     This class we are using for leadApplicantDetailS LWC Component for 
				   Applicant Details Section From loanApplicationForm.
* @date            01-18-2023    
* @testClass: 
**********************************************************************************************/
public class LeadApplicantDetails {
    /********************************************************************************************************
* @author          Rohit Pardeshi
* @description     This Method is use Get lead related data like Account, Address, Demography, Co-applicant
* @param           String leadGetId --> Getting from leadApplicantDetailS LWC Component
* @return          wrapperClassForCommForm --> Which includes data related to Lead, Account, Co-aaplicant, Address & 
				   Demography which is used in leadApplicantDetails LWC Component
*                       
* @date            01-18-2023   
********************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static wrapperClassForCommForm getLeadRelatedRecord(String leadGetId) {    
        Lead lstLead;
        List<Document_Checklist__c> dclList = new   List<Document_Checklist__c>();
        Map<Id,list<Document_Checklist__c>> mapapplicantIdvsListOfdcl = new  Map<Id,list<Document_Checklist__c>>();
        Map<Document_Checklist__c,list<ContentVersion>> mapdclVsContentVersion = new Map<Document_Checklist__c,list<ContentVersion>>();
        MAP<Id, list<ContentVersion>> contentDocIDVSContentVersion = new MAP<Id, list<ContentVersion>>();
        MAP<Id, list<ContentVersion>> contentdocumentLinnkVSContentVersion = new MAP<Id, list<ContentVersion>>();
        Set<Id> dclIds = new  Set<Id>();
        Set<Id> contentdocId = new  Set<Id>();
        List<ContentDocumentLink> cdlinkList = new  List<ContentDocumentLink>();
        try{
            lstLead = [Select Id,Salutation,FirstName,MiddleName,LastName,Date_of_Birth__c,MobilePhone,Email,Country_of_Study__c,
                       Admission_Status__c,University_Name__c,Course_Category__c,Course_Type__c,Course_Level__c,Course_Stream__c,Course_Name_Lookup__c,
                       Course_Start_Date__c,Course_End_Date__c,Analytics_Score_Category__c,Analytics_Test_Score__c,Language_Score_Category__c,
                       Language_Test_Score__c,Tuition_Fees__c,Living_Hostel_Food_Expenses__c,Traveling_Expenses__c,Other_Costs__c,Own_Source__c,
                       Scholarship__c,Others_Fund__c ,Gender__c,
                       Total_Costs__c,Total_Funds__c,Applicant_Category__c,
                       Loan_Required_A_B__c, Institute_Name__c, Campus__c, KYC_Consent__c,Applicant_Section__c From Lead Where id =: leadGetId];  
        }
        catch (Exception e) {
            
        }
        
        Co_Applicant__c appliAcc;
        try{
            appliAcc = [SELECT Id, Name,Type__c,Account__r.Lead__c,Relation_with_applicant__c,Relationship_Proof__c,Applicant_Type__c,Account__c,Account__r.Name, Account__r.Gender__c,Account__r.FirstName,Account__r.MiddleName,Account__r.LastName,
                        Account__r.PAN_Number__c, Account__r.Aadhar_Number__c,Account__r.Driving_License_Number__c, Account__r.Voter_ID__c,
                        Account__r.NREG_Number__c,Account__r.CKYC_Number__c,Account__r.Passport_File_Number__c,
                        Account__r.Is_Income_Considered_Is_Financial__c, Account__r.Passport_Number__c,                 
                        Account__r.Marital_Status__c, Account__r.PersonMobilePhone, Account__r.PersonEmail, Account__r.Name_Reference_From__c, Account__r.Date_of_Birth__c, Aadhar_Verified__c,Email_Verified__c,Mobile_Number_Verified__c,Pan_verified__c FROM Co_Applicant__c WHERE Lead__c =: leadGetId 
                        AND Type__c = 'Applicant' LIMIT 1];
        }
        catch (Exception e) {
        }
        
        
        ///Added By Dhanashri
        if(appliAcc != null){
            dclList = [Select Id,Lead__c,Applicant__c,Doc_Sub_Type__c,Applicant__r.Account__c from Document_Checklist__c
                       where Lead__c =: leadGetId AND Applicant__c =: appliAcc.Id ];
        }
        
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
        
        If(dclIds.size() > 0){
            cdlinkList =[SELECT Id,ContentDocumentId,LinkedEntityId,ContentDocument.Title,ContentDocument.FileType 
                         from ContentDocumentLink where LinkedEntityId IN:dclIds ];
        }
        
        if(cdlinkList != null && cdlinkList.size() > 0){
            for(ContentDocumentLink cdl :cdlinkList){
                contentdocId.add(cdl.ContentDocumentId);
            }
        }
        
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        contentVersionList = [SELECT Id, Title,ContentDocumentId ,Document_Type__c,Document_Sub_Type__c,Account__c FROM ContentVersion WHERE 
                              ContentDocumentId IN:contentdocId];
        
        for(ContentVersion objcv : contentVersionList){
            if(contentDocIDVSContentVersion.get(objcv.ContentDocumentId) == null){
                contentDocIDVSContentVersion.put(objcv.ContentDocumentId, new list<ContentVersion>{objcv}); 
            }else{
                contentDocIDVSContentVersion.get(objcv.ContentDocumentId).add(objcv);
            }
            
        }        
        
        for(ContentDocumentLink objcontent : cdlinkList){
            if(contentDocIDVSContentVersion.containskey(objcontent.ContentDocumentId)){
                contentdocumentLinnkVSContentVersion.put(objcontent.LinkedEntityId, contentDocIDVSContentVersion.get(objcontent.ContentDocumentId));
            }
        }
        
        for(Document_Checklist__c dcl :dclList){
            if(contentdocumentLinnkVSContentVersion.containskey(dcl.Id)){
                mapdclVsContentVersion.put(dcl, contentdocumentLinnkVSContentVersion.get(dcl.Id));
            }
        }
        
        List<String> aadharList = new List<String>();
        List<String> panList = new List<String>();
        List<String> passportList = new List<String>();
        
        if(appliAcc != null){
            if(mapapplicantIdvsListOfdcl.containsKey(appliAcc.Account__c)){
                for(Document_Checklist__c dcl :mapapplicantIdvsListOfdcl.get(appliAcc.Account__c)){
                    if(mapdclVsContentVersion.containsKey(dcl)){
                        for(ContentVersion objContentVersion: mapdclVsContentVersion.get(dcl)){
                            if(dcl.Doc_Sub_Type__c == 'Aadhar Card'){
                                aadharList.add(objContentVersion.Title);
                            }
                            if(dcl.Doc_Sub_Type__c == 'PAN Card'){
                                panList.add(objContentVersion.Title);
                            }
                            if(dcl.Doc_Sub_Type__c == 'Passport'){
                                passportList.add(objContentVersion.Title);
                            }
                        }
                    }
                }
            }  
        }
        
        
        
        ////END//
        
        //List<ContactPointAddress> AppliCurrentAddress = new List<ContactPointAddress>();
        ContactPointAddress appliCurrentAddress = new ContactPointAddress();
        ContactPointAddress appliPermanentAddress = new ContactPointAddress();
        
        try{
            appliCurrentAddress= [SELECT Id,Name,Lead__c,Address_Type__c,Address_Proof__c,Address_1__c,City__c,
                                  Country__c,District__c,Landmark__c,Pin_Code__c,State__c,Taluka__c, Years_In_The_Address__c,Is_Communication_address__c
                                  FROM ContactPointAddress WHERE Lead__c =: leadGetId AND Account__c =: appliAcc.Account__c AND Address_Type__c = 'Current Address' LIMIT 1];
            
            appliPermanentAddress= [SELECT Id,Name,Lead__c,Address_Type__c,Address_Proof__c,Address_1__c,City__c,
                                    Country__c,District__c,Landmark__c,Pin_Code__c,State__c,Taluka__c, Years_In_The_Address__c,Is_Communication_address__c,
                                    Same_as_Current_Address__c  FROM ContactPointAddress WHERE Lead__c =: leadGetId AND Account__c =: appliAcc.Account__c
                                    AND Address_Type__c = 'Permanent Address' LIMIT 1];
        }
        catch (Exception e) {
        }
        
        //Get Demography 
        Demography__c demographyDetails = new Demography__c();
        try{
            demographyDetails = [SELECT Id, Father_s_First_Name__c, Father_s_Middle_Name__c, Father_s_Last_Name__c, Mother_s_First_Name__c,
                                 Mother_s_Middle_Name__c, Mother_s_Last_Name__c, Spouse_s_First_Name__c, Spouse_s_Middle_name__c, Spouse_s_Last_Name__c, Account__c, Lead__c, F_TITLE__c, M_TITLE__c, S_TITLE__c
                                 FROM Demography__c
                                 WHERE Lead__c =: leadGetId AND Account__c =: appliAcc.Account__c];
        }
        catch (Exception e) {
        }
        
        wrapperClassForCommForm wc = new wrapperClassForCommForm();
        if(lstLead != null)
            wc.LeadRecords = lstLead;  
        if(appliAcc != null)        
            wc.AccRecords = appliAcc;
        //if(AppliCurrentAddress != null && AppliCurrentAddress.size() > 0)
        // wc.CPAAppliCurrentRecord = AppliCurrentAddress[0]; 
        if(appliCurrentAddress != null)
            wc.CPAAppliCurrentRecord = appliCurrentAddress;
        if(appliPermanentAddress != null)
            wc.CPAAppliPermanentRecord = appliPermanentAddress;  
        /*if(coApplicantAcc != null)
wc.AccCoAppliRecords = coApplicantAcc;*/
        if(demographyDetails != null)
            wc.DemographyRecord = demographyDetails;
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
* @param           String wrapperCommFormDetails 
* @return          wrapperClassForCommForm --> After saving the records at the end we are again calling 
				   getLeadRelatedRecord method to return data which will be used in LWC
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
        Lead objLead = [SELECT Id, Email, Applicant_Category__c,FirstName, Date_of_Birth__c, Gender__c, MiddleName, LastName,MobilePhone FROM Lead WHERE Id =: singleleadSaveRecord.Id];
        if(singleleadSaveRecord != null){
            singleleadSaveRecord.Email = objLead.Email;
            singleleadSaveRecord.MobilePhone = objLead.MobilePhone;
            if(objLead.Applicant_Category__c == CommonConstant.APPLICANT){
                update singleleadSaveRecord;            
            }
        }  
        
        Account accUpdate = (Account)json.deserialize(wrapperRecords.appliAccSaveRec,Account.Class);
        Co_Applicant__c coAppUpdate  = (Co_Applicant__c)json.deserialize(wrapperRecords.appliAccSaveRec,Co_Applicant__c.Class);
        List<Co_Applicant__c> applicantList =[SELECT Id,Lead__c,Name,Account__c,Type__c, Is_Income_Considered_Financial__c,Consent__c
                                              FROM Co_Applicant__c
                                              WHERE Lead__c=: singleleadSaveRecord.Id AND Type__c =: 'Applicant'];
        
        if(applicantList.size() > 0){
            for(Co_Applicant__c accfetchId :applicantList){
                accID = accfetchId.Account__c;
            }
        }
        
        if(accUpdate.Id != null && applicantList.size() == 0){
            update accUpdate;
            coApp.Name = accUpdate.FirstName + ' ' + accUpdate.LastName;
            coApp.Type__c = 'Applicant';
            coApp.Account__c = accUpdate.Id;
            coApp.Lead__c = singleleadSaveRecord.Id;
            coApp.Aadhar_Verified__c = coAppUpdate.Aadhar_Verified__c;
            coApp.Email_Verified__c = coAppUpdate.Email_Verified__c;
            coApp.Mobile_Number_Verified__c = coAppUpdate.Mobile_Number_Verified__c;
            coApp.Pan_verified__c = coAppUpdate.Pan_verified__c;
            if(accUpdate.Is_Income_Considered_Is_Financial__c == 'Yes'){
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
            coApp.Is_Existing_Customer__c = coAppUpdate.Is_Existing_Customer__c;
            insert coApp;
        }
        else if((accUpdate.Id == null || accID == null) && applicantList.size() == 0){
            insert accUpdate;
            coApp.Name = accUpdate.FirstName + ' ' + accUpdate.LastName;
            coApp.Type__c = 'Applicant';
            coApp.Account__c = accUpdate.Id;
            coApp.Lead__c = singleleadSaveRecord.Id;
            coApp.Aadhar_Verified__c = coAppUpdate.Aadhar_Verified__c;
            coApp.Email_Verified__c = coAppUpdate.Email_Verified__c;
            coApp.Mobile_Number_Verified__c = coAppUpdate.Mobile_Number_Verified__c;
            coApp.Pan_verified__c = coAppUpdate.Pan_verified__c;
            if(accUpdate.Is_Income_Considered_Is_Financial__c == 'Yes'){
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
            coApp.Is_Existing_Customer__c = coAppUpdate.Is_Existing_Customer__c;
            insert coApp;           
        }else if(accUpdate.Id != null && applicantList.size() > 0){
            update accUpdate;
            
            List<Co_Applicant__c> updateCoAppliacnt = new List<Co_Applicant__c>();
            for(Co_Applicant__c coAppli : applicantList){
                coAppli.Name = accUpdate.FirstName + ' ' + accUpdate.LastName;
                coAppli.Aadhar_Verified__c = coAppUpdate.Aadhar_Verified__c;
                coAppli.Email_Verified__c = coAppUpdate.Email_Verified__c;
                coAppli.Mobile_Number_Verified__c = coAppUpdate.Mobile_Number_Verified__c;
                coAppli.Pan_verified__c = coAppUpdate.Pan_verified__c;
                if(accUpdate.Is_Income_Considered_Is_Financial__c == 'Yes'){
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
                coApp.Is_Existing_Customer__c = coAppUpdate.Is_Existing_Customer__c;
                updateCoAppliacnt.add(coAppli);
            }
            
            update updateCoAppliacnt;
            
        }
        
        //For saving current address
        if(wrapperRecords.appliCurrentAddSave != null){
            ContactPointAddress applicantcurrentAdd = (ContactPointAddress)json.deserialize(wrapperRecords.appliCurrentAddSave,ContactPointAddress.Class);
            if(applicantcurrentAdd != null){  
                applicantcurrentAdd.Account__c = accUpdate.Id;
                applicantcurrentAdd.Lead__c = singleleadSaveRecord.Id;
                upsert applicantcurrentAdd;
            }
        }
        //For saving permanent address
        if(wrapperRecords.appliPermanentAddSave != null){
            ContactPointAddress applicantpermanentAdd = (ContactPointAddress)json.deserialize(wrapperRecords.appliPermanentAddSave,ContactPointAddress.Class);
            if(applicantpermanentAdd != null){  
                applicantpermanentAdd.Account__c = accUpdate.Id;
                applicantpermanentAdd.Lead__c = singleleadSaveRecord.Id;
                upsert applicantpermanentAdd;
            }          
        }
        
        //For Demography
        Demography__c demographySaveRecord = (Demography__c)json.deserialize(wrapperRecords.demoSaveRec,Demography__c.Class);        
        
        if(demographySaveRecord != null){
            demographySaveRecord.Lead__c =singleleadSaveRecord.Id;
            demographySaveRecord.Account__c = accUpdate.Id;
            upsert demographySaveRecord;
        }      
        Co_Applicant__c apllicantrec = [SELECT Id FROM Co_Applicant__c WHERE Lead__c =: singleleadSaveRecord.Id AND Type__c = 'Applicant'];
        dcList = [Select Id,Lead__c,Applicant__c from Document_Checklist__c where Lead__c =: singleleadSaveRecord.Id AND Applicant__c =: apllicantrec.Id];
        if(dcList.size() == 0){
            CreateDocumentChecklistRecords.documentCheklistmaster(singleleadSaveRecord.Id, apllicantrec.Id); 
        }
        wrapperClassForCommForm wc = getLeadRelatedRecord(singleleadSaveRecord.Id);
        return wc;
    }
    
 /********************************************************************************************************
* @author          Avadhut Suryavanshi
* @description     This Method is use get record of area object with repective pin
* @param           String pin 
* @return          Area__c --> Area Object Record
*                       
* @date            01-18-2023   
********************************************************************************************************/
    @AuraEnabled
    public static Area__c getPin(String pin){
        Area__c area = new  Area__c();
        area = [Select Id,City_Name__c,State__c,Country__c,Area_Name_Taluka__c From Area__c 
                WHERE Name =: pin];
        return area;
    }
    
  /********************************************************************************************************
* @author          Avadhut Suryavanshi
* @description     This Method is leadowner details
* @param           String leadGetId
* @return          User
*                       
* @date            01-18-2023   
********************************************************************************************************/
    @AuraEnabled
    public static User getLeadOwnerInfo(String leadGetId) {
        Lead leadOwner = [SELECT Id, OwnerId FROM Lead WHERE Id =: leadGetId];        
        User userId = [SELECT Id, Name, MobilePhone FROM User WHERE Id =: leadOwner.OwnerId];
        
        return userId;
    }
    
   /********************************************************************************************************
* @author          Avadhut Suryavanshi
* @description     This Method is to get Lead Mobile and Email
* @param           String leadGetId
* @return          Lead
*                       
* @date            01-18-2023   
********************************************************************************************************/
    @AuraEnabled
    public static Lead getLeadPassportNum(String leadGetId) {
        
        Lead leadPassportNum = [SELECT Id,MobilePhone,Email FROM Lead WHERE Id =: leadGetId];
        
        return leadPassportNum;
    }
    
  /********************************************************************************************************
* @author          Avadhut Suryavanshi
* @description     This Method is get Passport Number of Applicant
* @param           String leadGetId
* @return          Co_Applicant__c
*                       
* @date            01-18-2023   
********************************************************************************************************/
    @AuraEnabled
    public static Co_Applicant__c getAccountPassportNum(String leadGetId) {
        
        Co_Applicant__c accPassportNum = [Select Id,Name,Account__c,Account__r.Name,Account__r.Id,Type__c,Account__r.Passport_Number__c  from Co_Applicant__c where Lead__r.Id = :leadGetId AND Type__c = 'Applicant'];                      
        
        return accPassportNum;
    }
    
    /*//Added by Rohit 
    public static void updateContentVersionRecord(String wrapperCommFormDetails){
        Map<String, String> appAndDocTypeVsMasterLable = New Map<String, String>();
        List<ContentVersion> updateContentVersion = New List<ContentVersion>();
        List<String> docName = new List<String>{'Aadhar Back', 'Aadhar Front', 'Pan', 'Passport Front', 'Passport Back' , 
            'Voter Front', 'Voter Back', 'Driving Licence Back' , 'Driving Licence Front'};
                
                List<Document_Name_DMS__mdt> customMetadataRecords = [SELECT MasterLabel, Applicant_Type__c, Document_Type__c 
                                                                      FROM Document_Name_DMS__mdt WHERE Document_Type__c IN :docName];
        system.debug('customMetadataRecords' +customMetadataRecords);
        
        for (Document_Name_DMS__mdt customMetadata : customMetadataRecords){
            appAndDocTypeVsMasterLable.put(customMetadata.Applicant_Type__c+customMetadata.Document_Type__c, customMetadata.MasterLabel);
        }
        
        system.debug('appAndDocTypeVsMasterLable=> ' +appAndDocTypeVsMasterLable);
        
        wrapperClassForCommForm wrapperRecords = (wrapperClassForCommForm)json.deserialize(wrapperCommFormDetails,wrapperClassForCommForm.Class);      
        Lead singleleadSaveRecord = (Lead)json.deserialize(wrapperRecords.leadSaveRec,Lead.Class);
        
        Account accUpdate = (Account)json.deserialize(wrapperRecords.appliAccSaveRec,Account.Class);
        
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        contentVersionList = [SELECT Id, Title, Document_Sub_Type__c FROM ContentVersion WHERE Lead__c =: singleleadSaveRecord.Id AND Account__c =: accUpdate.Id];
        system.debug('contentVersionLi=> ' +contentVersionList.size());
        
        for(ContentVersion objContentVersion : contentVersionList){
            if(appAndDocTypeVsMasterLable.containsKey('Applicant'+objContentVersion.Document_Sub_Type__c)){
                objContentVersion.Title = appAndDocTypeVsMasterLable.get('Applicant'+objContentVersion.Document_Sub_Type__c);
                updateContentVersion.add(objContentVersion);
            }
        }
        
        try {
            update updateContentVersion;
        } catch (Exception e) {
            System.debug('Error message: ' + e.getMessage());
        }
    }*/
    
 /********************************************************************************************************
* @author          Avadhut Suryavanshi
* @description     This Method is Check Applicant Paassword is uplodaed or not
* @param           String leadId
* @return          Boolean 
*                       
* @date            01-18-2023   
********************************************************************************************************/
    @AuraEnabled
    public static Boolean isPassportUploaded(String leadId) {
        Boolean isUploaded = false;
        
        List<ContentVersion> versions = [SELECT Id FROM ContentVersion WHERE Lead__c = :leadId AND (Title = 'passport_back_App_1' OR Title = 'passport_front_App_1') LIMIT 1];
        
        if (!versions.isEmpty()) {
            isUploaded = true;
        }
        
        return isUploaded;
    }
    
   /********************************************************************************************************
* @author          Avadhut Suryavanshi
* @description     This Method is to get getFinancialCoApplicants
* @param           String leadGetId
* @return          List<Co_Applicant__c> --> Return list of Co_Applicant__c Mobile,email lead with Income considered as financial 
*                       
* @date            01-18-2023   
********************************************************************************************************/
    @AuraEnabled
    public static List<Co_Applicant__c> getFinancialCoApplicants(String leadGetId){
        List<Co_Applicant__c> financialCoApplicants = new  List<Co_Applicant__c>();
        financialCoApplicants = [Select Id,Name,Account__c,Account__r.Name,Account__r.Id,Type__c,Account__r.PersonMobilePhone,Account__r.Email__c,Is_Income_Considered_Financial__c from Co_Applicant__c where Lead__r.Id = :leadGetId AND Is_Income_Considered_Financial__c = 'Yes'AND Type__c != 'Applicant'];
        return financialCoApplicants;         
    }
    
/********************************************************************************************************
* @author          Avadhut Suryavanshi
* @description     This Method is to get CoApplicant applicant account
* @param           String leadId
* @return          Id --> Id of Co-Applicant Account
*                       
* @date            01-18-2023   
********************************************************************************************************/
    @AuraEnabled
    public static Id getCoApplicant(String leadId){
        Id accountId;
        try {  
            List<Co_Applicant__c> lstApp = [SELECT Id, Type__c, Account__c
                                            FROM Co_Applicant__c WHERE (Lead__c =: leadId OR Deal__c =: leadId) AND Type__c != 'Applicant' LIMIT 1];
            
            if(lstApp.size() > 0){
                accountId = lstApp[0].Account__c;
            }
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
    
    /********************************************************************************************************
* @author          Rohit Pardeshi
* @description     On Application form when mobile and Email is verfied then on applicant update the status 
* @param           String parameter, Id applicantId
* @return          NA
*                       
* @date            01-18-2023   
********************************************************************************************************/
    @AuraEnabled
    public static void updateEmailAndMobileVerified(String parameter, Id applicantId) {
        try {
            if (applicantId != null) {
                Co_Applicant__c appliAcc = [SELECT Id, Mobile_Number_Verified__c, Email_Verified__c FROM Co_Applicant__c WHERE Id = :applicantId];
                if (parameter == 'Email') {
                    appliAcc.Email_Verified__c = true;
                } else if (parameter == 'Mobile') {
                    appliAcc.Mobile_Number_Verified__c = true; 
                }
                update appliAcc; 
            }
        } catch (Exception e) {
        }
    }
    
/********************************************************************************************************
* @author          Rohit Pardeshi
* @description     This method is used to save the document even if OCR Fails
* @param           List<contentVersionWrapper> ocrRecords, Id leadId, Id accountId
* @return          NA
*                       
* @date            04/07/2023   
********************************************************************************************************/
    @AuraEnabled
    public static void savedOCRDoc(List<contentVersionWrapper> ocrRecords, Id leadId, Id accountId) {
        List<ContentVersion> cvList = new List<ContentVersion>();
        List<ContentDocumentLink> contentDocumentLink = new List<ContentDocumentLink>();
        String documentType;
        
        try {
            for (ContentVersionWrapper record : ocrRecords) {
                if(record.docType == CommonConstant.DOCUMENT_TYPE_AADHAR){
                   documentType = CommonConstant.CV_DOCUMENT_TYPE_AADHAR; 
                }else if(record.docType == CommonConstant.DOCUMENT_TYPE_PAN){
                   documentType = CommonConstant.CV_DOCUMENT_TYPE_PAN; 
                }else if(record.docType == CommonConstant.DOCUMENT_TYPE_PASSPORT){
                    documentType = CommonConstant.CV_DOCUMENT_TYPE_PASSPORT; 
                }
                ContentVersion cv = new ContentVersion();
                cv.VersionData = EncodingUtil.base64Decode(record.base64);
                cv.Title = record.fullName;
                cv.PathOnClient = record.fullName;
                cv.Document_Type__c = documentType;
                cv.Lead__c = leadId;
                cv.Account__c = accountId;
                cvList.add(cv);
            }
            insert cvList;
            
            List<ContentVersion> cvLinkList = [SELECT ContentDocumentId,Document_Type__c, Id FROM ContentVersion WHERE Id IN :cvList];
            List<Document_Checklist__c> dcList = new List<Document_Checklist__c>();
            
            if (cvLinkList.size() > 0) {
                for (ContentVersion cvLink : cvLinkList) {
                    if (cvLink.Document_Type__c == CommonConstant.CV_DOCUMENT_TYPE_AADHAR) {
                        dcList = [SELECT Id FROM Document_Checklist__c WHERE Lead__c = :leadId AND Applicant__r.Account__c = :accountId AND Doc_Sub_Type__c = 'Aadhar Card' LIMIT 1];
                        ContentDocumentLink cdl = new ContentDocumentLink();
                        cdl.ContentDocumentId = cvLink.ContentDocumentId;
                        cdl.LinkedEntityId = dcList.isEmpty() ? null : dcList[0].Id;
                        contentDocumentLink.add(cdl);
                    } else if (cvLink.Document_Type__c == CommonConstant.CV_DOCUMENT_TYPE_PAN) {
                        dcList = [SELECT Id FROM Document_Checklist__c WHERE Lead__c = :leadId AND Applicant__r.Account__c = :accountId AND Doc_Sub_Type__c = 'PAN Card' LIMIT 1];
                        ContentDocumentLink cdl = new ContentDocumentLink();
                        cdl.ContentDocumentId = cvLink.ContentDocumentId;
                        cdl.LinkedEntityId = dcList.isEmpty() ? null : dcList[0].Id;
                        contentDocumentLink.add(cdl);
                    } else if (cvLink.Document_Type__c ==  CommonConstant.CV_DOCUMENT_TYPE_PASSPORT) {
                        dcList = [SELECT Id FROM Document_Checklist__c WHERE Lead__c = :leadId AND Applicant__r.Account__c = :accountId AND Doc_Sub_Type__c = 'Passport' LIMIT 1];
                        ContentDocumentLink cdl = new ContentDocumentLink();
                        cdl.ContentDocumentId = cvLink.ContentDocumentId;
                        cdl.LinkedEntityId = dcList.isEmpty() ? null : dcList[0].Id;
                        contentDocumentLink.add(cdl);
                    }
                    
                    ContentDocumentLink cd2 = new ContentDocumentLink();
                            cd2.ContentDocumentId = cvLink.ContentDocumentId;
                            cd2.LinkedEntityId = accountId;
                            contentDocumentLink.add(cd2);
                }
                if(contentDocumentLink != null){
                    insert contentDocumentLink;
                }
                
            }
        } catch (Exception e) {

        }
    }   
    
    public class contentVersionWrapper {
        @AuraEnabled
        public String docType{get;set;}
        @AuraEnabled
        public String fullName{get;set;}
        @AuraEnabled
        public String base64{get;set;}
        
/*
        public ContentVersionWrapper(String docType, String fullName, String base64) {
            this.docType = docType;
            this.fullName = fullName;
            this.base64 = base64;
        }*/
    }
}