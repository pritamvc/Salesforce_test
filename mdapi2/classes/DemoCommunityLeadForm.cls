/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-11-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class DemoCommunityLeadForm{
    @AuraEnabled(cacheable=true)
    public static List<wrapperForApplicant> getCoapp(String leadId){
        SYSTEM.DEBUG('String leaddID Demo '+leadId);
        List<wrapperForApplicant> lstwrapperForApplicant = new List<wrapperForApplicant>();
        Map<Id,Co_Applicant__c> mapAccvsAppIds = new Map<Id,Co_Applicant__c>();
        Set<Id> setApplIds = new Set<Id>();
        List<Co_Applicant__c> lstApp = [SELECT Id, Account__r.Name,Name,Type__c,Relation_with_applicant__c,Relation_others__c,Is_Income_Considered_Financial__c,
                                        Relationship_Proof__c,Account__c,Account__r.Id
                                        FROM Co_Applicant__c WHERE Lead__c =: leadId AND Type__c != 'Applicant'];
        For(Co_Applicant__c objApp: lstApp){
            mapAccvsAppIds.put(objApp.Account__r.Id,objApp);
            setApplIds.add(objApp.Account__r.Id);
        }        
        SYSTEM.DEBUG('lstApp '+lstApp );
        SYSTEM.DEBUG('mapAccvsAppIds Account Id & Co-appli Record==> '+mapAccvsAppIds );
        SYSTEM.DEBUG('setApplIds Account Id==> '+setApplIds );
        List<Account> lstAcc = [Select Id, FirstName,MiddleName,LastName,Date_of_Birth__c,PersonMobilePhone,PersonEmail,Mobile_Abroad__c,
                                Father_Name__c,Mother_Name__c,Gender__c,Marital_Status__c,Is_Income_Considered_Is_Financial__c,
                                Passport_Number__c, Aadhar_Number__c,PAN_Number__c,Driving_License_Number__c,
                                Dirving_License_Expiry_Date__c,Voter_Id__c,Passport_File_Number__c,NREG_Number__c,CKYC_Number__c,
                                (SELECT Id,Name,Address_Type__c,Address_Proof__c,Address_1__c,Pin_Code__c,City__c,Taluka__c,District__c,
                                 Landmark__c,State__c,Country__c,Years_In_The_Address__c,Same_as_Current_Address__c
                                 FROM Contact_Point_Addresses__r),(Select Father_s_First_Name__c,Mother_s_First_Name__c FROM Demography__r) From Account where Id in: setApplIds];
        SYSTEM.DEBUG('list of acc from Set Id===> '+lstAcc);
        for(Account objAcc: lstAcc){
            wrapperForApplicant objwrapperForApplicant = new wrapperForApplicant();
            objwrapperForApplicant.objeAcc = objAcc;    
            objwrapperForApplicant.objApplicant = mapAccvsAppIds.get(objAcc.Id);
            SYSTEM.DEBUG('objAcc.ContactPointAddresses'+objAcc.ContactPointAddresses);
            
                for(ContactPointAddress objContAdd: objAcc.Contact_Point_Addresses__r){
                    if(objContAdd.Address_Type__c == 'Current Address'){
                        objwrapperForApplicant.appCurrentAdd = objContAdd;
                    }
                    if(objContAdd.Address_Type__c== 'Permanent Address'){
                        objwrapperForApplicant.appPermanentAdd =  objContAdd;
                    }                
                }

            if(objAcc.Demography__r != null && objAcc.Demography__r.size() != 0 ){
                system.debug('INSIDE ADDRESS IF CONDITION');
                for(Demography__c demo:objAcc.Demography__r){
                    objwrapperForApplicant.appDemography = demo;
                }
            }else{
                system.debug('INSIDE ADDRESS ELSE CONDITION');
            	Demography__C dm = new Demography__C();
            	objwrapperForApplicant.appDemography = dm;
            }  
            lstwrapperForApplicant.add(objwrapperForApplicant);  
        }
        return lstwrapperForApplicant;
        
    }
    
    @AuraEnabled
    public static List<wrapperForApplicant> getEmploymentWithAddress(String leadId){
        SYSTEM.DEBUG('String leaddID Demo '+leadId);
        List<wrapperForApplicant> lstwrapperForApplicant = new List<wrapperForApplicant>();
        Map<Id,Employment_Details__c> mapAccvsAppIds = new Map<Id,Employment_Details__c>();
        Set<Id> setApplIds = new Set<Id>();
        List<Employment_Details__c> lstApp = [SELECT Id, Name, Employment_Type__c, Name_Of_The_Company__c, 
                                 No_of_Years_with_Current_Employer__c, Monthly_Income__c, Official_Email_Id__c, Type_Of_Company__c, 
                                 Role_In_Organization__c, Total_Professional_Experience__c, Nature_of_Professional__c, Address_of_Current_Business__c, 
                                 Membership_Number__c,GST_IN__c, Nature_of_Business__c, Date_of_Retirement__c, Organisation_Name__c, Pension_Amount__c, 
                                 Account__c,Account__r.Name, Lead__c, Demography__c FROM Employment_Details__c WHERE Lead__c =: leadId];
        system.debug('lstApp size' +lstApp.size());
       system.debug('lstApp' +lstApp);
        
        For(Employment_Details__c objApp: lstApp){
            mapAccvsAppIds.put(objApp.Account__c,objApp);
            setApplIds.add(objApp.Account__c);
        }        
       
        system.debug('mapAccvsAppIds size ' +mapAccvsAppIds.size());
            system.debug('mapAccvsAppIds ' +mapAccvsAppIds);
        SYSTEM.DEBUG('setApplIds Account Id==> '+setApplIds );
        List<Account> lstAcc = [Select Id, FirstName,MiddleName,LastName,Date_of_Birth__c,PersonMobilePhone,PersonEmail,
                                Father_Name__c,Mother_Name__c,Gender__c,Marital_Status__c,Is_Income_Considered_Is_Financial__c,
                                Passport_Number__c, Aadhar_Number__c,PAN_Number__c,Driving_License_Number__c,
                                Dirving_License_Expiry_Date__c,Voter_Id__c,Passport_File_Number__c,
                                (SELECT Id,Name,Address_Type__c,Address_Proof__c,Address_1__c,Pin_Code__c,City__c,Taluka__c,District__c,
                                 Landmark__c,State__c,Country__c,Years_In_The_Address__c,Same_as_Current_Address__c
                                 FROM Contact_Point_Addresses__r WHERE Address_Type__c = 'Office' AND Lead__c =: leadId) From Account where Id in: setApplIds];
        SYSTEM.DEBUG('list of acc from Set Id===> '+lstAcc);
        SYSTEM.DEBUG('list size '+lstAcc.size());
        for(Account objAcc: lstAcc){
            system.debug('erecorddd == ' +mapAccvsAppIds.get(objAcc.Id));
            wrapperForApplicant objwrapperForApplicant = new wrapperForApplicant();
            objwrapperForApplicant.objeAcc = objAcc;    
            objwrapperForApplicant.objEmployment = mapAccvsAppIds.get(objAcc.Id);
            system.debug('objwrapperForApplicant.objEmployment' +JSON.serialize(objwrapperForApplicant.objEmployment)); 
            system.debug('objwrapperForApplicant..id===' +objwrapperForApplicant.objEmployment.Id);
            
            if(objAcc.Contact_Point_Addresses__r != null && objAcc.Contact_Point_Addresses__r.size() != 0 ){
                system.debug('INSIDE ADDRESS IF CONDITION');
           
            for(ContactPointAddress objContAdd: objAcc.Contact_Point_Addresses__r){
                if(objContAdd.Address_Type__c == 'Office'){
                    objwrapperForApplicant.appOfficeAdd = objContAdd;
                }                  
            }
        }else {
            system.debug('INSIDE ADDRESS ELSE CONDITION');
            ContactPointAddress cs = new ContactPointAddress();
            objwrapperForApplicant.appOfficeAdd = cs;
        }

        lstwrapperForApplicant.add(objwrapperForApplicant);
        }
        system.debug('lstwrapperForApplicant' +lstwrapperForApplicant);
        return lstwrapperForApplicant;  
    }
    
   @AuraEnabled
    public static void communityWrapperFormMethod(String wrapperCommFormCoAppliDetails) {
        System.debug('wrapperCommFormCoAppliDetails========>' + wrapperCommFormCoAppliDetails); 

    }
        
    public class wrapperForApplicant{           
        @AuraEnabled
        public Account objeAcc{get;set;}
        @AuraEnabled
        public Co_Applicant__c objApplicant{get;set;} 
        @AuraEnabled
        public ContactPointAddress appCurrentAdd{get;set;}
        @AuraEnabled
        public ContactPointAddress appPermanentAdd{get;set;}
        @AuraEnabled
        public Employment_Details__c objEmployment{get;set;}
        @AuraEnabled
        public ContactPointAddress appOfficeAdd{get;set;} 
        @AuraEnabled
        public Demography__c appDemography{get;set;} 
    }

   //To save co-applicant
    @AuraEnabled
    public static List<wrapperForApplicant> saveCoApplicant(List<wrapperForApplicant> coApplicantData,String leadId){
        List<Co_Applicant__c> applicantlistToInsert = new List<Co_Applicant__c>();
        List<ContactPointAddress> addressListToInsert = new List<ContactPointAddress>();
        List<Demography__c> demographyToAdd = new List<Demography__c>();
        Id personAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        String aadharNumber;
        String maskAadhar;
        String lastFourDigits;
        
        for(wrapperForApplicant co : coApplicantData){
            aadharNumber = co.objeAcc.Aadhar_Number__c;

            if(co.objeAcc != null){
                co.objeAcc.RecordTypeId = personAccount;
                 if(String.isNotBlank(co.objeAcc.Aadhar_Number__c)){
                    system.debug('INSIDE ADHARR NOT NULL');
                    aadharNumber = co.objeAcc.Aadhar_Number__c;
                    lastFourDigits = aadharNumber.substring(aadharNumber.length()-4, aadharNumber.length());
                    maskAadhar = 'XXXXXXXX'+lastFourDigits;
                    system.debug('maskAadhar' +maskAadhar);
                    co.objeAcc.Aadhar_Number__c = maskAadhar;
            }
                
                upsert co.objeAcc;
            }  
            if(co.objApplicant != null){
                co.objApplicant.Account__c = co.objeAcc.Id;
                co.objApplicant.Lead__c = leadId;
                applicantlistToInsert.add(co.objApplicant);
            }
            if(co.appCurrentAdd != null){
                co.appCurrentAdd.Account__c = co.objeAcc.Id;
                co.appCurrentAdd.Lead__c = leadId;
                addressListToInsert.add(co.appCurrentAdd);
            }
            if(co.appPermanentAdd != null){
                co.appPermanentAdd.Account__c = co.objeAcc.Id;
                co.appPermanentAdd.Lead__c = leadId;
                addressListToInsert.add(co.appPermanentAdd);
            }
            if(co.appDemography != null && co.objApplicant.Type__c == 'Co-applicant'){
                co.appDemography.Lead__c = leadId;
                co.appDemography.Account__c = co.objeAcc.Id;
                demographyToAdd.add(co.appDemography);
            }   
        } 

        if(applicantlistToInsert != null){
            system.debug('#######applicantlistToInsert');
            system.debug('#######applicantlistToInsert'+applicantlistToInsert);
            upsert applicantlistToInsert;
        }
        if(addressListToInsert != null){
            system.debug('#######addressListToInsert');
            upsert addressListToInsert;
        }
        if(demographyToAdd != null){
            system.debug('#######demographyToAdd');
            upsert demographyToAdd;
        }    

        List<wrapperForApplicant> wc = getCoapp(leadId);
        return wc;
    }
    
    //To delete co-applicant
   @AuraEnabled
    public static List<wrapperForApplicant> deleteCoApplicant(String accId, String leadId){
        Account acc;
        List<Co_Applicant__c> appList;
        List<ContactPointAddress> address;
        List<Demography__c> demoGraphy;
        List<Reference__c> reference;
        List<Bank_Details__c> bankAccount;
        List<Asset> asset;
        List<Liability__c> liability;
        List<Employment_Details__c> employment;
        
        
        Co_Applicant__c deletCoApp;
        try{
            acc = [SELECT Id from Account WHERE Id =:accId];
            appList = [SELECT Id from Co_Applicant__c where Account__c =: accId];
            address = [SELECT Id, Account__c, Lead__c, Address_Type__c From ContactPointAddress WHERE Account__c =: accId AND Lead__c =: leadId];
            deletCoApp = [SELECT Id from Co_Applicant__c where Account__c =: accId AND Lead__c =: leadId];   
            demoGraphy = [SELECT Id FROM Demography__c WHERE Account__c =: accId AND Lead__c =: leadId];
            reference = [SELECT Id FROM Reference__c WHERE Account__c =: accId AND Lead__c =: leadId];
            bankAccount = [SELECT Id FROM Bank_Details__c WHERE Account__c =: accId AND Lead__c =: leadId];
            asset = [SELECT Id FROM Asset WHERE AccountId =: accId AND Lead__c =: leadId];
            liability = [SELECT Id FROM Liability__c WHERE Account__c =: accId AND Lead__c =: leadId];
            employment = [SELECT Id FROM Employment_Details__c WHERE Account__c =: accId AND Lead__c =: leadId];
            List<ContentVersion> contentVersionsToDelete = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Account__c =: accId AND Lead__c =: leadId];
            List<Id> contentDocumentIdsToDelete = new List<Id>();
            for (ContentVersion cv : contentVersionsToDelete) {
                contentDocumentIdsToDelete.add(cv.ContentDocumentId);
            }
            List<ContentDocument> contentDocumentsToDelete = [SELECT Id FROM ContentDocument WHERE Id IN :contentDocumentIdsToDelete];
            
            
            if(appList.size() == 1 && !appList.isEmpty()){
                if(acc != null)
                    delete acc;
            }
            
            if(deletCoApp != null ){
                delete deletCoApp;
            }
            if(!address.isEmpty()){
                delete address;
            }
            
            if(!demoGraphy.isEmpty()){
                delete demoGraphy;
            }
            if(!reference.isEmpty()){
                delete reference;
            }
            if(!bankAccount.isEmpty()){
                delete bankAccount;
            }
            if(!liability.isEmpty()){
                delete liability;
            }
            if(!employment.isEmpty()){
                delete employment;
            }
            if(!contentDocumentsToDelete.isEmpty()){
                delete contentDocumentsToDelete;
            }
            if(!asset.isEmpty()){
                system.debug('Inside asset delete IFFF');
                //delete asset;
            }
            
        }
        catch(Exception e){
            System.debug('No records');
        }
        
        List<wrapperForApplicant> wc = getCoapp(leadId);
        return wc;         
    }  
    
    //To save Employment & Address
    @AuraEnabled
    public static List<wrapperForApplicant> saveEmployment(List<wrapperForApplicant> employmentAddressData,String leadId){
        system.debug('employmentAddressData' +employmentAddressData);
        system.debug('leadId' +leadId);
        List<Employment_Details__c> applicantlistToInsert = new List<Employment_Details__c>();
        List<ContactPointAddress> addressListToInsert = new List<ContactPointAddress>();

            for(wrapperForApplicant co : employmentAddressData){
                system.debug('co.appOfficeAdd.Id ' +co.appOfficeAdd.Id);
                system.debug('co.appOfficeAdd ' +co.appOfficeAdd);

                system.debug('All account Id===' +co.objEmployment.Account__c);
                system.debug('Em0loymentt===' +co.objEmployment);

                if(co.objEmployment != null){
                    applicantlistToInsert.add(co.objEmployment);
                }                
                
                Account acc = [SELECT Name FROM Account WHERE Id = :co.objEmployment.Account__c];
                system.debug('acc Employemnt: ' + acc.Name);
                if(co.appOfficeAdd != null && co.objEmployment.Employment_Type__c != 'Student' && co.objEmployment.Employment_Type__c != 'Homemaker'){
                    
                    system.debug('Account Name: ' + acc.Name);
                    co.appOfficeAdd.Account__c = co.objEmployment.Account__c;
                    co.appOfficeAdd.Lead__c = leadId;
                    co.appOfficeAdd.Name = acc.Name;
                    addressListToInsert.add(co.appOfficeAdd);
                }
            }

                if(applicantlistToInsert != null){
                    system.debug('INSERT EMPLOYMENT');
                    upsert applicantlistToInsert;
                }
            
                if(addressListToInsert != null){
                    system.debug('INSERT ADDRESS');
                    upsert addressListToInsert;
                }
        
        List<wrapperForApplicant> wc = getEmploymentWithAddress(leadId);
        return wc;            
    }
    
	//To delete Employmenet & Address
    @AuraEnabled
    public static List<wrapperForApplicant> deleteEmployment(String employmentId){
        
        List<ContactPointAddress> add = new List<ContactPointAddress>();
        Employment_Details__c emp = [SELECT Id, Lead__c, Account__c from Employment_Details__c where Id =:employmentId];
        
        add = [SELECT Id, Account__c, Lead__c, Address_Type__c 
                                   From ContactPointAddress WHERE Address_Type__c = 'Office' AND Account__c =: emp.Account__c AND Lead__c =: emp.Lead__c];
        if(emp != null)
        delete emp;
        if(add != null)
        delete add;
        
        List<wrapperForApplicant> wc = getEmploymentWithAddress(emp.Lead__c);
        return wc;
        
    }    

    //To Get Employment Account whos Is Income Considered/Is Financial is YES
    @AuraEnabled
    public static List<Id> getAccountsFromEmploymentAndCoApplicants(String leadId){
        system.debug('leadId' +leadId);
        List<Id> returnAccountId = new List<Id>();
        List<Co_Applicant__c> coApplicantList = new List<Co_Applicant__c>();

        coApplicantList = [SELECT Id, Account__c FROM Co_Applicant__c 
                           WHERE Lead__c =: leadId AND Is_Income_Considered_Financial__c = 'Yes'];
        System.debug('coApplicantList = ' +coApplicantList.size());

        if(coApplicantList.size() > 0){
            for(Co_Applicant__c coApp : coApplicantList){
                returnAccountId.add(coApp.Account__c);
            }
        }

        system.debug('returnAccountId = ' +returnAccountId);

        return returnAccountId;            
    }

    @AuraEnabled
    public static List<wrapperForApplicant> findDupAccountWithPANMatch(String panNumber){
        system.debug('panNumber = ' +panNumber);
        List<wrapperForApplicant> coApplicantWrapperForApplicant = new List<wrapperForApplicant>();
        String accountId;
 
        Account acc = [SELECT Id, PAN_Number__c FROM Account WHERE PAN_Number__c =:panNumber];
        system.debug('acc = ' +acc);

        if(acc != null){
            system.debug('INSIDE IF');
            coApplicantWrapperForApplicant = DemoCommunityLeadForm.getAllRelatedRecordOfCoApp(acc.Id);
            system.debug('coApplicantWrapperForApplicant = ' +coApplicantWrapperForApplicant);
            return coApplicantWrapperForApplicant;
        }else{
            return coApplicantWrapperForApplicant;
        }  
    }

    public static List<wrapperForApplicant> getAllRelatedRecordOfCoApp(String accountId){
        system.debug('accountId = ' +accountId);
        List<wrapperForApplicant> lstwrapperForApplicant = new List<wrapperForApplicant>();

        List<Account> lstAcc = [Select Id, FirstName,MiddleName,LastName,Date_of_Birth__c,PersonMobilePhone,PersonEmail,
                                Father_Name__c,Mother_Name__c,Gender__c,Marital_Status__c,Is_Income_Considered_Is_Financial__c,
                                Passport_Number__c, Aadhar_Number__c,PAN_Number__c,Driving_License_Number__c,
                                Dirving_License_Expiry_Date__c,Voter_Id__c,Passport_File_Number__c,
                                (SELECT Id,Name,Address_Type__c,Address_Proof__c,Address_1__c,Pin_Code__c,City__c,Taluka__c,District__c,
                                 Landmark__c,State__c,Country__c,Years_In_The_Address__c,Same_as_Current_Address__c
                                 FROM Contact_Point_Addresses__r),(Select Father_s_First_Name__c,Mother_s_First_Name__c FROM Demography__r) 
                                 FROM Account WHERE Id =: accountId];
        system.debug('list of acc from Set Id===> '+lstAcc);

        for(Account objAcc: lstAcc){
            wrapperForApplicant objwrapperForApplicant = new wrapperForApplicant();
            objwrapperForApplicant.objeAcc = objAcc;    
            //objwrapperForApplicant.objApplicant = mapAccvsAppIds.get(objAcc.Id);

                for(ContactPointAddress objContAdd: objAcc.Contact_Point_Addresses__r){
                    if(objContAdd.Address_Type__c == 'Current Address'){
                        system.debug('###Current Address'+objContAdd.Address_Type__c);
                        objwrapperForApplicant.appCurrentAdd = objContAdd;
                    }
                    if(objContAdd.Address_Type__c== 'Permanent Address'){
                         system.debug('###Permanent Address'+objContAdd.Address_Type__c);
                        objwrapperForApplicant.appPermanentAdd =  objContAdd;
                    }                
                }
                for(Demography__c demo:objAcc.Demography__r){
                    objwrapperForApplicant.appDemography = demo;
                }
            lstwrapperForApplicant.add(objwrapperForApplicant);   
        }
        return lstwrapperForApplicant;
    }

    @AuraEnabled
    public static wrapperForApplicant duplicateAccount(string duplicateParameter, string duplicateValue, Date matchDOB){
        system.debug('duplicateParameter = ' +duplicateParameter);
        system.debug('duplicateValue = ' +duplicateValue);
        system.debug('matchDOB = ' +matchDOB);

        String accountId;
        List<wrapperForApplicant> lstwrapperForApplicant = new List<wrapperForApplicant>();
        wrapperForApplicant objwrapperForApplicant = new wrapperForApplicant();

        if(duplicateParameter == 'Aadhar Number'){
            Account acc = [SELECT Id, Aadhar_Number__c FROM Account WHERE Aadhar_Number__c =:duplicateValue AND Date_of_Birth__c =:matchDOB AND Aadhar_Number__c != null ORDER by createdDate DESC LIMIT 1];
            system.debug('acc = ' +acc);
            accountId = acc.Id;
        }
        else if(duplicateParameter == 'PAN Number'){
            Account acc = [SELECT Id, PAN_Number__c FROM Account WHERE PAN_Number__c =:duplicateValue AND  PAN_Number__c != null ORDER by createdDate DESC LIMIT 1];
            system.debug('acc = ' +acc);
            accountId = acc.Id;
        }
        else if(duplicateParameter == 'Passport Number'){
            Account acc = [SELECT Id, Passport_Number__c FROM Account WHERE Passport_Number__c =:duplicateValue AND Passport_Number__c != null ORDER by createdDate DESC LIMIT 1];
            system.debug('acc = ' +acc);
            accountId = acc.Id;
        }
        else if(duplicateParameter == 'Driving License Number'){
            Account acc = [SELECT Id, Driving_License_Number__c FROM Account WHERE Driving_License_Number__c =:duplicateValue AND Driving_License_Number__c != null ORDER by createdDate DESC LIMIT 1];
            system.debug('acc = ' +acc);
            accountId = acc.Id;
        }
        else if(duplicateParameter == 'Voter ID'){
            Account acc = [SELECT Id, Voter_ID__c FROM Account WHERE Voter_ID__c =:duplicateValue AND Voter_ID__c != null ORDER by createdDate DESC LIMIT 1];
            system.debug('acc = ' +acc);
            accountId = acc.Id;
        }

        List<Account> lstAcc = [Select Id, FirstName,MiddleName,LastName,Date_of_Birth__c,PersonMobilePhone,PersonEmail,
                                Father_Name__c,Mother_Name__c,Gender__c,Marital_Status__c,Is_Income_Considered_Is_Financial__c,
                                Passport_Number__c, Aadhar_Number__c,PAN_Number__c,Driving_License_Number__c,
                                Dirving_License_Expiry_Date__c,Voter_Id__c,Passport_File_Number__c,
                                (SELECT Id,Name,Address_Type__c,Address_Proof__c,Address_1__c,Pin_Code__c,City__c,Taluka__c,District__c,
                                 Landmark__c,State__c,Country__c,Years_In_The_Address__c,Same_as_Current_Address__c,Is_Communication_address__c
                                 FROM Contact_Point_Addresses__r WHERE Address_Type__c != 'Office'),(Select Father_s_First_Name__c,Father_s_Middle_Name__c,
                                 Father_s_Last_Name__c,Mother_s_Middle_Name__c,Mother_s_First_Name__c, 
                                 Mother_s_Last_Name__c,Spouse_s_First_Name__c,Spouse_s_Middle_name__c,Spouse_s_Last_Name__c 
                                 FROM Demography__r) 
                                 FROM Account WHERE Id =: accountId];
        system.debug('list of acc from Set Id===> '+lstAcc);

        for(Account objAcc: lstAcc){
            
            //wrapperClassForCommForm objwrapperForApplicant = new wrapperClassForCommForm();
            objwrapperForApplicant.objeAcc = objAcc;
            objwrapperForApplicant.objApplicant = new Co_Applicant__c();

                for(ContactPointAddress objContAdd: objAcc.Contact_Point_Addresses__r){
                    if(objContAdd.Address_Type__c == 'Current Address'){
                        objwrapperForApplicant.appCurrentAdd = objContAdd;
                    }
                    if(objContAdd.Address_Type__c== 'Permanent Address'){
                        objwrapperForApplicant.appPermanentAdd =  objContAdd;
                    }                
                }
                for(Demography__c demo:objAcc.Demography__r){
                    objwrapperForApplicant.appDemography = demo;
                }
            //lstwrapperForApplicant.add(objwrapperForApplicant);   
        }

        return objwrapperForApplicant;
    }

    @AuraEnabled
    public static string getAccountIdFromCoApplicant(String leadId){
       String accountId;
        try {
            
            List<Co_Applicant__c> lstApp = [SELECT Id, Type__c, Account__c
                                            FROM Co_Applicant__c WHERE Lead__c =: leadId AND Type__c = 'Applicant' LIMIT 1];

            system.debug('lstApp==> ' +lstApp);

            if(lstApp.size() > 0){
                accountId = lstApp[0].Account__c;
                }

            system.debug('accountId==>' +accountId);
                return accountId;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}