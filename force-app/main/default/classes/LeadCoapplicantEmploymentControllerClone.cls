public with sharing class LeadCoapplicantEmploymentControllerClone {
    
    /*******For Co-Applicant section************/
    
    //To fetch the co-applicant data on load
    @AuraEnabled
    public static List<wrapperForApplicant> getCoapp(String leadId){
        List<wrapperForApplicant> lstwrapperForApplicant = new List<wrapperForApplicant>();
        Map<Id,Co_Applicant__c> mapAccvsAppIds = new Map<Id,Co_Applicant__c>();
        
        Map<Id, List<String>> accountIdvsListOfTtitle = new Map<Id, List<String>>();
        Set<Id> setApplIds = new Set<Id>();
        //Addded by dhanashri
        Set<Id> dclIds = new  Set<Id>();
        Map<Id, List<String>> dclListVsTitle = new Map<Id, List<String>>();
        map<id, id> dclIdVsContentDocId = new map<id, id>();
        Map<Id, String> dclIdvsDocTtitle = new Map<Id, String>();
        Set<Id> coAppIds = new  Set<Id>();
        Set<Id> contentdocId = new  Set<Id>();
        Map<Id,list<Document_Checklist__c>> mapapplicantIdvsListOfdcl = new  Map<Id,list<Document_Checklist__c>>();
        Map<Document_Checklist__c,list<ContentVersion>> mapdclVsContentVersion = new Map<Document_Checklist__c,list<ContentVersion>>();
        List<ContentDocumentLink> cdlinkList = new  List<ContentDocumentLink>();
        MAP<Id, list<ContentVersion>> ContentDocIDVSContentVersion = new MAP<Id, list<ContentVersion>>();
        MAP<Id, list<ContentVersion>> ContentdocumentLinnkVSContentVersion = new MAP<Id, list<ContentVersion>>();
        /////
        
        Map<Id,List<ContentVersion>> mapAccvsFiles = new Map<Id,List<ContentVersion>>();
        List<Co_Applicant__c> lstApp = [SELECT Id, Account__r.Name,Name,Type__c,Relation_with_applicant__c,Relation_others__c,Is_Income_Considered_Financial__c,
                                        Relationship_Proof__c,Account__c,Account__r.Id
                                        FROM Co_Applicant__c WHERE Lead__c =: leadId AND Type__c != 'Applicant'];
        
         //Addded by dhanashri
        if(lstApp.size() > 0){                                     
            for(Co_Applicant__c ca:lstApp){
                coAppIds.add(ca.id);
                
            }
        }
        
        List<Document_Checklist__c> dclList = [Select Id,Lead__c,Applicant__c,Doc_Sub_Type__c,Applicant__r.Account__c from Document_Checklist__c
                                               where Lead__c =: leadId AND Applicant__c IN: coAppIds ];
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
        
        For(Co_Applicant__c objApp: lstApp){
            mapAccvsAppIds.put(objApp.Account__r.Id,objApp);
            setApplIds.add(objApp.Account__r.Id);
        }
        
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
        
        
        List<Account> lstAcc = [Select Id, FirstName,MiddleName,LastName,Date_of_Birth__c,PersonMobilePhone,PersonEmail, Mobile_Abroad__c,
                                Father_Name__c,Mother_Name__c,Gender__c,Marital_Status__c,Is_Income_Considered_Is_Financial__c,
                                Passport_Number__c, Aadhar_Number__c,PAN_Number__c,Driving_License_Number__c,
                                Dirving_License_Expiry_Date__c,Voter_Id__c,Passport_File_Number__c,NREG_Number__c,CKYC_Number__c,
                                (SELECT Id,Name,Address_Type__c,Address_Proof__c,Address_1__c,Pin_Code__c,City__c,Taluka__c,District__c,
                                 Landmark__c,State__c,Country__c,Years_In_The_Address__c,Same_as_Current_Address__c
                                 FROM Contact_Point_Addresses__r),(Select Father_s_First_Name__c,Mother_s_First_Name__c FROM Demography__r) From Account where Id in: setApplIds ORDER BY CreatedDate ASC];
        for(Account objAcc: lstAcc){
            wrapperForApplicant objwrapperForApplicant = new wrapperForApplicant();
            objwrapperForApplicant.objeAcc = objAcc;    
            objwrapperForApplicant.objApplicant = mapAccvsAppIds.get(objAcc.Id);
            if(accountIdvsListOfTtitle != null){
                objwrapperForApplicant.contentVersionList = accountIdvsListOfTtitle.get(objAcc.Id); 
            }
            /////Dhanashri
            List<String> aadharList = new List<String>();
            List<String> panList = new List<String>();
            List<String> passportList = new List<String>();
            
            if(mapapplicantIdvsListOfdcl.containsKey(objAcc.Id)){
                for(Document_Checklist__c dcl :mapapplicantIdvsListOfdcl.get(objAcc.Id)){
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
                        objwrapperForApplicant.aadharList = aadharList;
                        objwrapperForApplicant.panList = panList;
                        objwrapperForApplicant.passportList = passportList;
                        
                    }
                }
            }
            
            ////End
            
            
            /*if(mapAccvsFiles.get(objAcc.Id) !=null){
List<String> aadharList = new List<String>();
List<String> panList = new List<String>();
List<String> passportList = new List<String>();
for(ContentVersion objContentVersion: mapAccvsFiles.get(objAcc.Id)){
if(objContentVersion.Document_Type__c == 'Aadhar Card'){
aadharList.add(objContentVersion.Title);
}
if(objContentVersion.Document_Type__c == 'PAN Card'){
panList.add(objContentVersion.Title);
}
if(objContentVersion.Document_Type__c == 'Passport'){
passportList.add(objContentVersion.Title);
}
}
objwrapperForApplicant.aadharList = aadharList;
objwrapperForApplicant.panList = panList;
objwrapperForApplicant.passportList = passportList;
}*/
            
            if(objAcc.Contact_Point_Addresses__r != null && objAcc.Contact_Point_Addresses__r.size() != 0 ){
                for(ContactPointAddress objContAdd: objAcc.Contact_Point_Addresses__r){
                    system.debug('objContAdd=>' +objContAdd);
                    system.debug('objAcc.Contact_Point_Addresses__r' +objAcc.Contact_Point_Addresses__r);
                    if(objContAdd.Address_Type__c == 'Current Address'){
                        objwrapperForApplicant.appCurrentAdd = objContAdd;
                    }
                    if(objContAdd.Address_Type__c== 'Permanent Address'){
                        objwrapperForApplicant.appPermanentAdd =  objContAdd;
                    }                
                }
            }else{
                ContactPointAddress cpaobj = new ContactPointAddress();
                objwrapperForApplicant.appCurrentAdd = cpaobj;
                objwrapperForApplicant.appPermanentAdd =  cpaobj;
            }
            
            if(objAcc.Demography__r != null && objAcc.Demography__r.size() != 0 ){
                for(Demography__c demo:objAcc.Demography__r){
                    objwrapperForApplicant.appDemography = demo;
                }
            }else{
                Demography__C dm = new Demography__C();
                objwrapperForApplicant.appDemography = dm;
            }  
            lstwrapperForApplicant.add(objwrapperForApplicant);  
        }
        return lstwrapperForApplicant; 
    }
    
    //To save co-applicant
    @AuraEnabled
    public static List<wrapperForApplicant> saveCoApplicant(List<wrapperForApplicant> coApplicantData,String leadId){
        List<Co_Applicant__c> applicantlistToInsert = new List<Co_Applicant__c>();
        List<ContactPointAddress> addressListToInsert = new List<ContactPointAddress>();
        List<Demography__c> demographyToAdd = new List<Demography__c>();
        List<Document_Checklist__c> dcList = new List<Document_Checklist__c>();
        Map<Id, List<Document_Checklist__c>> applicantIdvsDcList = new  Map<Id, List<Document_Checklist__c>>();
        Id personAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        String aadharNumber;
        String maskAadhar;
        String lastFourDigits;
        Map<Id,String> mapAccIdvsAppType = new Map<Id,String>();
        for(wrapperForApplicant co : coApplicantData){
            aadharNumber = co.objeAcc.Aadhar_Number__c;
            
            if(co.objeAcc != null){
                co.objeAcc.RecordTypeId = personAccount;
                if(String.isNotBlank(co.objeAcc.Aadhar_Number__c)){
                    aadharNumber = co.objeAcc.Aadhar_Number__c;
                    lastFourDigits = aadharNumber.substring(aadharNumber.length()-4, aadharNumber.length());
                    maskAadhar = 'XXXXXXXX'+lastFourDigits;
                    co.objeAcc.Aadhar_Number__c = maskAadhar;
                }   
                upsert co.objeAcc;
                
            }  
            if(co.objApplicant != null){
                co.objApplicant.Account__c = co.objeAcc.Id;
                co.objApplicant.Lead__c = leadId;
                applicantlistToInsert.add(co.objApplicant);
                mapAccIdvsAppType.put(co.objeAcc.Id,co.objApplicant.Type__c);
            }
            
            if(co.appCurrentAdd != null){
                system.debug('appCurrentAdd'+co.appCurrentAdd.Name);
                co.appCurrentAdd.Account__c = co.objeAcc.Id;
                co.appCurrentAdd.Lead__c = leadId;
                addressListToInsert.add(co.appCurrentAdd);
            }
            if(co.appPermanentAdd != null){
                system.debug('appPermanentAdd'+co.appPermanentAdd.Name);
                co.appPermanentAdd.Account__c = co.objeAcc.Id;
                co.appPermanentAdd.Lead__c = leadId;
                addressListToInsert.add(co.appPermanentAdd);
            }
            if(co.appDemography != null && co.objApplicant.Type__c == CommonConstant.COAPPLICANT){
                co.appDemography.Lead__c = leadId;
                co.appDemography.Account__c = co.objeAcc.Id;
                demographyToAdd.add(co.appDemography);
            }   
        } 
        
        if(applicantlistToInsert != null){
            upsert applicantlistToInsert;
            updateDCLApplicant(applicantlistToInsert);
        }
        if(addressListToInsert != null){
            upsert addressListToInsert;
        }
        if(demographyToAdd != null){
            upsert demographyToAdd;
        }
        
        dcList = [Select Id,Lead__c,Applicant__c from Document_Checklist__c where Lead__c =: leadId AND Applicant__c IN:applicantlistToInsert];
        for(Document_Checklist__c objdc : dcList){
            if(applicantIdvsDcList.get(objdc.Applicant__c) == null){
                applicantIdvsDcList.put(objdc.Applicant__c,new list<Document_Checklist__c>{objdc}); 
            }else{
                applicantIdvsDcList.get(objdc.Applicant__c).add(objdc);
            }
        }
        
        for(Co_Applicant__c objCo : applicantlistToInsert){
            if(applicantIdvsDcList.get(objCo.Id) == null){
                system.debug('INSIDE DCLIST NULL');
                CreateDocumentChecklistRecords.documentCheklistmaster(leadId, objCo.Id);
            }
        }

        //LeadCoapplicantEmploymentController.updateContentVersionRecord(leadId);
        
        List<wrapperForApplicant> wc = getCoapp(leadId);
        return wc;
    }
    //Added By dhanashri  to update DCL Applican Type
    public static void updateDCLApplicant(List<Co_Applicant__c> applicantId){
        List<Document_Checklist__c> dcList = new List<Document_Checklist__c>();
        Map<id,List<Document_Checklist__c>> coIdVsDocList = new   Map<id,List<Document_Checklist__c>>();
        List<Co_Applicant__c> appList = [Select id,Type__c from Co_Applicant__c where id IN:applicantId];
        
        System.debug('appList::'+appList);
        if( appList != null && appList.size() > 0){
            dcList = [select id,Applicant__c from Document_Checklist__c where Applicant__c In: appList];
        }
        for(Document_Checklist__c dc : dcList ){
             IF(coIdVsDocList.get(dc.Applicant__c) == null){
                    coIdVsDocList.put(dc.Applicant__c,new list<Document_Checklist__c>{dc}); 
                }else{
                    coIdVsDocList.get(dc.Applicant__c).add(dc);
                }
            
        }
        
          System.debug('dcList::'+dcList);
        List<Document_Checklist__c> finalList = new List<Document_Checklist__c>();
        
        if(dcList != null && dcList.size() >0){
            for( Co_Applicant__c app:appList){
                if(coIdVsDocList.get(app.Id) != null && coIdVsDocList.containskey(app.Id)){
                    for(Document_Checklist__c dc : coIdVsDocList.get(app.Id) ){
                        dc.Applicant_Type__c = app.Type__c;
                        finalList.add(dc);
                    }
                }
            }
            System.debug('finalList::'+finalList);
            if(finalList != null && finalList.size() > 0){
              System.debug('Line 289::');   
            update finalList;
        }
        }
        
        
        
    }
  /////
    
    //Added by Rohit 
    public static void updateContentVersionRecord(String leadId){
        Map<String, String> AppAndDocTypeVsMasterLable = New Map<String, String>();
        List<ContentVersion> updateContentVersion = New List<ContentVersion>();
        String applicantType;
        Map<Id, Co_Applicant__c> accoutIdvsCoAppObj = new Map<Id, Co_Applicant__c>();
        List<Co_Applicant__c > existingApplicantList = new List<Co_Applicant__c>();
        List<String> docName = new List<String>{'Aadhar Back', 'Aadhar Front', 'Pan', 'Passport Front', 'Passport Back' , 
            'Voter Front', 'Voter Back', 'Driving Licence Back' , 'Driving Licence Front'};
                
                List<Document_Name_DMS__mdt> customMetadataRecords = [SELECT MasterLabel, Applicant_Type__c, Document_Type__c 
                                                                      FROM Document_Name_DMS__mdt WHERE Document_Type__c IN :docName];
        system.debug('customMetadataRecords' +customMetadataRecords);
        
        for (Document_Name_DMS__mdt customMetadata : customMetadataRecords){
            AppAndDocTypeVsMasterLable.put(customMetadata.Applicant_Type__c+customMetadata.Document_Type__c, customMetadata.MasterLabel);
        }
        
        system.debug('AppAndDocTypeVsMasterLable=> ' +AppAndDocTypeVsMasterLable);
        
        existingApplicantList =[SELECT Id,Name,Lead__c,Account__c,Type__c,Naming_Order__c FROM Co_Applicant__c 
                                WHERE Lead__c =:leadId AND Type__c != null AND Type__c != 'Applicant' order by CreatedDate ASC];
        
        for(Co_Applicant__c objCoApp : existingApplicantList){
            accoutIdvsCoAppObj.put(objCoApp.Account__c, objCoApp);
        }
        
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        contentVersionList = [SELECT Id, Title, Document_Sub_Type__c,Account__c FROM ContentVersion WHERE Lead__c =: leadId AND Account__c IN: accoutIdvsCoAppObj.keyset()];
        system.debug('contentVersionLi=> ' +contentVersionList.size());
        
        for(ContentVersion objContentVersion : contentVersionList){
            system.debug('Applicant TAYpe' +accoutIdvsCoAppObj.get(objContentVersion.Account__c).Type__c);
            system.debug('Document  TAYpe' +objContentVersion.Document_Sub_Type__c);
            system.debug('Number order' +accoutIdvsCoAppObj.get(objContentVersion.Account__c).Naming_Order__c);
            if(accoutIdvsCoAppObj.get(objContentVersion.Account__c).Type__c == CommonConstant.COAPPLICANT){
                system.debug('INSIDE APPLICANT TYPE Co-applicant');
                applicantType = CommonConstant.COAPPLICANT;
            }else{
                applicantType = accoutIdvsCoAppObj.get(objContentVersion.Account__c).Type__c;
            }
            
            if(AppAndDocTypeVsMasterLable.containsKey(applicantType+objContentVersion.Document_Sub_Type__c)){
                system.debug('Inside If condition');
                objContentVersion.Title = AppAndDocTypeVsMasterLable.get(applicantType+objContentVersion.Document_Sub_Type__c) + accoutIdvsCoAppObj.get(objContentVersion.Account__c).Naming_Order__c;
                updateContentVersion.add(objContentVersion);
                system.debug('updateContentVersion========>>> ' +updateContentVersion);
            }
            system.debug('updateContentVersion=>' +updateContentVersion);
        }
        
        try {
            if(!updateContentVersion.isEmpty()){
                update updateContentVersion;
            }
            
            System.debug('Success: Ttile updated Successfully.');
        } catch (Exception e) {
            System.debug('Error message: ' + e.getMessage());
        }
    }
    
    //To delete co-applicant
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
        List<Document_Checklist__c> dcList;
        
        
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
            dcList = [Select Id,Lead__c,Applicant__r.Account__c from Document_Checklist__c where Lead__c =: leadId AND Applicant__r.Account__c =:accId];
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
            if(!dcList.isEmpty()){
                delete dcList;
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
    
    //To get the Account Ids of Applicant
    @AuraEnabled
    public static Id getAccountIdFromCoApplicant(String leadId){
        Id accountId;
        try {  
            List<Co_Applicant__c> lstApp = [SELECT Id, Type__c, Account__c
                                            FROM Co_Applicant__c WHERE Lead__c =: leadId AND Type__c = 'Applicant' LIMIT 1];
            
            if(lstApp.size() > 0){
                accountId = lstApp[0].Account__c;
            }
            system.debug('accountId=>>' +accountId);
            return accountId;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //To get the Applicant Email and Mobile
    @AuraEnabled
    public static Account getApplicantEmailAndMobile(String leadId) {
        try {
            Co_Applicant__c applicant = [SELECT Id, Type__c, Account__r.PersonMobilePhone, Account__r.PersonEmail
                                         FROM Co_Applicant__c
                                         WHERE Lead__c = :leadId AND Type__c = 'Applicant'
                                         LIMIT 1];
            
            if (applicant != null && applicant.Account__r != null) {
                Account acc = applicant.Account__r;
                system.debug('PersonMobilePhone: ' + acc.PersonMobilePhone);
                system.debug('PersonEmail: ' + acc.PersonEmail);
                return acc;
            }
            
            return null; 
        } catch (Exception e) {
            throw new AuraHandledException('An error occurred while retrieving applicant information: ' + e.getMessage());
        }
    }
    
    //To find the duplicate Account for Co-applicant
    @AuraEnabled
    public static wrapperForApplicant duplicateAccount(string duplicateParameter, string duplicateValue, Date matchDOB){
        system.debug('duplicateValue' +duplicateValue);
        String accountId;
        List<wrapperForApplicant> lstwrapperForApplicant = new List<wrapperForApplicant>();
        wrapperForApplicant objwrapperForApplicant = new wrapperForApplicant();
        List<Account> acc = new List<Account>();
        
        if(duplicateParameter == 'Aadhar Number'){
            acc = [SELECT Id, Aadhar_Number__c FROM Account WHERE Aadhar_Number__c =:duplicateValue AND Date_of_Birth__c =:matchDOB AND Aadhar_Number__c != null AND Date_of_Birth__c != NULL ORDER by createdDate DESC LIMIT 1];
        }
        else if(duplicateParameter == 'PAN Number'){
            acc = [SELECT Id, PAN_Number__c FROM Account WHERE PAN_Number__c =:duplicateValue AND  PAN_Number__c != null ORDER by createdDate DESC LIMIT 1];
        }
        else if(duplicateParameter == 'Passport Number'){
            acc = [SELECT Id, Passport_Number__c FROM Account WHERE Passport_Number__c =:duplicateValue AND Passport_Number__c != null ORDER by createdDate DESC LIMIT 1];
        }
        else if(duplicateParameter == 'Driving License Number'){
            acc = [SELECT Id, Driving_License_Number__c FROM Account WHERE Driving_License_Number__c =:duplicateValue AND Driving_License_Number__c != null ORDER by createdDate DESC LIMIT 1];
        }
        else if(duplicateParameter == 'Voter ID'){
            system.debug('INSIDE VOTER');
            acc = [SELECT Id, Voter_ID__c FROM Account WHERE Voter_ID__c =:duplicateValue AND Voter_ID__c != null ORDER by createdDate DESC LIMIT 1];
        }
        
        system.debug('accacc' +acc);
        if(!acc.isEmpty()){
            accountId = acc[0].Id;
        }
        
        system.debug('accountId' +accountId);
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
    
    /*******For Employment section************/
    
    //To get Employment with address
    @AuraEnabled
    public static List<wrapperForApplicant> getEmploymentWithAddress(String leadId){
        List<wrapperForApplicant> lstwrapperForApplicant = new List<wrapperForApplicant>();
        Map<Id,Employment_Details__c> mapAccvsAppIds = new Map<Id,Employment_Details__c>();
        Set<Id> setApplIds = new Set<Id>();
        
        List<Co_Applicant__c> coApplicants = [Select Id, Name,Account__c, Account__r.Name,Lead__r.Name, Lead__r.Id,Account__r.Id,Type__c
                                              from Co_Applicant__c where Lead__r.Id =: leadId and Account__c != null ORDER BY Type__c ASC];
        
        List<Employment_Details__c> lstApp = [SELECT Id, Name, Employment_Type__c, Name_Of_The_Company__c, 
                                              No_of_Years_with_Current_Employer__c, Monthly_Income__c, Official_Email_Id__c, Type_Of_Company__c, 
                                              Role_In_Organization__c, Total_Professional_Experience__c, Nature_of_Professional__c, Address_of_Current_Business__c, 
                                              Membership_Number__c, GST_IN__c, Nature_of_Business__c, Date_of_Retirement__c, Organisation_Name__c, Pension_Amount__c, 
                                              Account__c,Account__r.Name, Lead__c, Demography__c FROM Employment_Details__c WHERE Lead__c =: leadId];
        
        if(lstApp.size() > 0){
            For(Employment_Details__c objApp: lstApp){
                mapAccvsAppIds.put(objApp.Account__c,objApp);
                setApplIds.add(objApp.Account__c);
            }        
            
            List<Account> lstAcc = [Select Id, Name,FirstName,MiddleName,LastName,Date_of_Birth__c,PersonMobilePhone,PersonEmail,
                                    Father_Name__c,Mother_Name__c,Gender__c,Marital_Status__c,Is_Income_Considered_Is_Financial__c,
                                    Passport_Number__c, Aadhar_Number__c,PAN_Number__c,Driving_License_Number__c,
                                    Dirving_License_Expiry_Date__c,Voter_Id__c,Passport_File_Number__c,
                                    (SELECT Id,Name,Address_Type__c,Address_Proof__c,Address_1__c,Pin_Code__c,City__c,Taluka__c,District__c,
                                     Landmark__c,State__c,Country__c,Years_In_The_Address__c,Same_as_Current_Address__c
                                     FROM Contact_Point_Addresses__r WHERE Address_Type__c = 'Office' AND Lead__c =: leadId) From Account where Id in: setApplIds];
            system.debug('lstAcc' +lstAcc);
            system.debug('lstAccName' +lstAcc[0].Name);
            
            for(Account objAcc: lstAcc){
                wrapperForApplicant objwrapperForApplicant = new wrapperForApplicant();
                objwrapperForApplicant.objeAcc = objAcc;    
                objwrapperForApplicant.objEmployment = mapAccvsAppIds.get(objAcc.Id);
                //objwrapperForApplicant.objApplicant = objAcc.Name;
                
                if(objAcc.Contact_Point_Addresses__r != null && objAcc.Contact_Point_Addresses__r.size() != 0 ){                
                    for(ContactPointAddress objContAdd: objAcc.Contact_Point_Addresses__r){
                        if(objContAdd.Address_Type__c == 'Office'){
                            objwrapperForApplicant.appOfficeAdd = objContAdd;
                        }                  
                    }
                }
                else {
                    ContactPointAddress cs = new ContactPointAddress();
                    objwrapperForApplicant.appOfficeAdd = cs;
                }
                
                lstwrapperForApplicant.add(objwrapperForApplicant);
            }
        }
        
        return lstwrapperForApplicant;  
    }
    
    //To save Employment & Address
    @AuraEnabled
    public static List<wrapperForApplicant> saveEmployment(List<wrapperForApplicant> employmentAddressData,String leadId){
        List<Employment_Details__c> applicantlistToInsert = new List<Employment_Details__c>();
        List<ContactPointAddress> addressListToInsert = new List<ContactPointAddress>();
        List<ContactPointAddress> deleteAddress = new List<ContactPointAddress>();
        
        Set<Id> addressId = new Set<Id>();
        
        for(wrapperForApplicant co : employmentAddressData){
            if(co.objEmployment.Id != null &&  co.appOfficeAdd.Id != null && (co.objEmployment.Employment_Type__c == 'Student' || co.objEmployment.Employment_Type__c == 'Homemaker')){
                system.debug('inside if condition');
                addressId.add(co.appOfficeAdd.Id);
                co.objEmployment.Name_Of_The_Company__c = '';
                co.objEmployment.Type_Of_Company__c = '';
                co.objEmployment.Role_In_Organization__c = '';
                co.objEmployment.Official_Email_Id__c = '';
                co.objEmployment.Monthly_Income__c = null;
                co.objEmployment.No_of_Years_with_Current_Employer__c = null;
                co.objEmployment.Total_Professional_Experience__c = null;
                co.objEmployment.Nature_of_Professional__c = '';
                co.objEmployment.Membership_Number__c = null;
                co.objEmployment.Nature_of_Business__c = '';
                co.objEmployment.Date_of_Retirement__c = null;
                co.objEmployment.Organisation_Name__c = '';
                co.objEmployment.Pension_Amount__c = null;         
            }
            
            if(co.objEmployment != null){
                applicantlistToInsert.add(co.objEmployment);
            }                
            
            Account acc = [SELECT Name FROM Account WHERE Id = :co.objEmployment.Account__c];
            if(co.appOfficeAdd != null && co.objEmployment.Employment_Type__c != 'Student' && co.objEmployment.Employment_Type__c != 'Homemaker'){
                co.appOfficeAdd.Account__c = co.objEmployment.Account__c;
                co.appOfficeAdd.Lead__c = leadId;
                co.appOfficeAdd.Name = acc.Name;
                addressListToInsert.add(co.appOfficeAdd);
            }
        }
        
        if(applicantlistToInsert != null){
            upsert applicantlistToInsert;
        }
        
        if(addressListToInsert != null){
            upsert addressListToInsert;
        }
        
        system.debug('addressId=> ' +addressId);
        if(addressId.size() != 0){
            deleteAddress = [SELECT Id FROM ContactPointAddress WHERE Id IN :addressId];
            system.debug('deleteAddress=> ' +deleteAddress);
            if(deleteAddress.size() != 0){
                delete deleteAddress;
            }
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
        List<Id> returnAccountId = new List<Id>();
        List<Co_Applicant__c> coApplicantList = new List<Co_Applicant__c>();
        
        coApplicantList = [SELECT Id, Account__c FROM Co_Applicant__c 
                           WHERE Lead__c =: leadId AND Is_Income_Considered_Financial__c = 'Yes'];
        
        if(coApplicantList.size() > 0){
            for(Co_Applicant__c coApp : coApplicantList){
                returnAccountId.add(coApp.Account__c);
            }
        }
        
        return returnAccountId;            
    }
    
    @AuraEnabled
    public static List<Co_Applicant__c> getleadWithApplicantsRec(String leadGetId){
        List<Co_Applicant__c> applicantsWithLeadIdRec = new  List<Co_Applicant__c>();
        applicantsWithLeadIdRec = [Select Id, Name,Account__c, Account__r.Name,Lead__r.Name, Lead__r.Id,Account__r.Id,Type__c, Is_Income_Considered_Financial__c
                                   from Co_Applicant__c where Lead__r.Id =: leadGetId];
        return applicantsWithLeadIdRec;         
    }
    
    //Get check for co-applicant
    @AuraEnabled
    public static Lead getCheck(String leadId){
        return [SELECT Id,Co_applicant_Section__c,Employment_Section__c,Document_Checked__c,Financial_Section__c,Reference_Section__c,Name FROM Lead WHERE Id =: leadId];
    }
    
    //Get check for co-applicant
    @AuraEnabled
    public static Lead updateCheck(String leadId,Boolean isCheck){
        Lead rec = [SELECT Id,Co_applicant_Section__c FROM Lead WHERE Id =: leadId];
        rec.Co_applicant_Section__c = isCheck;
        update rec;
        return rec;
    }
    
    //Get check for employemnt
    @AuraEnabled
    public static Lead updateEmploymentCheck(String leadId,Boolean isCheck){
        Lead rec = [SELECT Id,Employment_Section__c FROM Lead WHERE Id =: leadId];
        rec.Employment_Section__c = isCheck;
        update rec;
        return rec;
    }
    
    @AuraEnabled
    public static Boolean checkPinCodeAvailable(String pin){
        List<Area__c> areaList = new List<Area__c>();
        
        areaList = [Select Id,City_Name__c,State__c,Country__c,Area_Name_Taluka__c From Area__c 
                    WHERE Name =: pin];
        
        return areaList.size() > 0;        
    }
    
    //Wrapper class for Applicant-CoApplicant data 
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