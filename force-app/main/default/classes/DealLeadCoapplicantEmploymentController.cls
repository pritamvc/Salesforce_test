public class DealLeadCoapplicantEmploymentController {
    
    /*******For Co-Applicant section************/
    
    //To fetch the co-applicant data on load
    @AuraEnabled
    public static List<wrapperForApplicant> getCoapp(String leadId){
        system.debug('leadId= '+leadId);
        List<wrapperForApplicant> lstwrapperForApplicant = new List<wrapperForApplicant>();
        Map<Id,Co_Applicant__c> mapAccvsAppIds = new Map<Id,Co_Applicant__c>();
        Map<Id, List<String>> accountIdvsListOfTtitle = new Map<Id, List<String>>();
        Set<Id> setApplIds = new Set<Id>();
        //Addded by dhanashri
        Set<Id> dclIds = new  Set<Id>();
        Set<Id> coAppIds = new  Set<Id>();
        Set<Id> contentdocId = new  Set<Id>();
        Map<Id,list<Document_Checklist__c>> mapapplicantIdvsListOfdcl = new  Map<Id,list<Document_Checklist__c>>();
        Map<Document_Checklist__c,list<ContentVersion>> mapdclVsContentVersion = new Map<Document_Checklist__c,list<ContentVersion>>();
        List<ContentDocumentLink> cdlinkList = new  List<ContentDocumentLink>();
        MAP<Id, list<ContentVersion>> contentDocIDVSContentVersion = new MAP<Id, list<ContentVersion>>();
        MAP<Id, list<ContentVersion>> contentdocumentLinnkVSContentVersion = new MAP<Id, list<ContentVersion>>();
        /////
        List<Co_Applicant__c> lstApp = [SELECT Id, Account__r.Name,Name,Type__c,Relation_with_applicant__c,Relation_others__c,Is_Income_Considered_Financial__c,
                                        Relationship_Proof__c,Account__c,Account__r.Id,Mobile_Number_Verified__c,Email_Verified__c, QUALIFICATION__c
                                        FROM Co_Applicant__c WHERE (Lead__c =: leadId OR Deal__c =: leadId) AND Type__c != 'Applicant'];
        
             //Addded by dhanashri
        if(lstApp.size() > 0){                                     
            for(Co_Applicant__c ca:lstApp){
                coAppIds.add(ca.id);
                
            }
        }
        
        List<Document_Checklist__c> dclList = [Select Id,Lead__c,Applicant__c,Doc_Sub_Type__c,Applicant__r.Account__c from Document_Checklist__c
                                               where (Lead__c =: leadId OR Deal__c =: leadId) AND Applicant__c IN: coAppIds ];
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
        system.debug('mapdclVsContentVersion=> ' +mapdclVsContentVersion);
        
        List<Account> lstAcc = [Select Id, FirstName,MiddleName,LastName,Date_of_Birth__c,PersonMobilePhone,PersonEmail, Mobile_Abroad__c,
                                Father_Name__c,Mother_Name__c,Gender__c,Marital_Status__c,Is_Income_Considered_Is_Financial__c,
                                Passport_Number__c, Aadhar_Number__c,PAN_Number__c,Driving_License_Number__c,Name_Reference_From__c,
                                Dirving_License_Expiry_Date__c,Voter_Id__c,Passport_File_Number__c,NREG_Number__c,CKYC_Number__c, Salutation,
                                (SELECT Id,Name,Address_Type__c,Address_Proof__c,Address_1__c,Pin_Code__c,City__c,Taluka__c,District__c,
                                 Landmark__c,State__c,Country__c,Years_In_The_Address__c,Same_as_Current_Address__c
                                 FROM Contact_Point_Addresses__r),(Select Father_s_First_Name__c,Mother_s_First_Name__c, F_TITLE__c,M_TITLE__c FROM Demography__r) From Account where Id in: setApplIds ORDER BY CreatedDate ASC];
        system.debug('lstAcc' +lstAcc.size());
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
        system.debug('COAPPLICANT SAVE METHOD CAALING');
        List<Co_Applicant__c> applicantlistToInsert = new List<Co_Applicant__c>();
        List<ContactPointAddress> addressListToInsert = new List<ContactPointAddress>();
        List<Demography__c> demographyToAdd = new List<Demography__c>();
        List<Document_Checklist__c> dcList = new List<Document_Checklist__c>();
        Map<Id, List<Document_Checklist__c>> applicantIdvsDcList = new  Map<Id, List<Document_Checklist__c>>();
        Id personAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        String aadharNumber;
        String maskAadhar;
        String lastFourDigits;
        String documentType;
        Map<Id,String> mapAccIdvsAppType = new Map<Id,String>();
        List<ContentVersion> contentVersionsToInsert = new List<ContentVersion>();
        for(wrapperForApplicant co : coApplicantData){
            aadharNumber = co.objeAcc.Aadhar_Number__c;
            system.debug('co.objeAccID' +co.objeAcc.Id);
            system.debug('co.objeAcc==' +co.objeAcc);
            if(co.objeAcc != null){
                co.objeAcc.RecordTypeId = personAccount;
                system.debug('Aadhar_Number__c' +co.objeAcc.Aadhar_Number__c);
                if(String.isNotBlank(co.objeAcc.Aadhar_Number__c)){
                    aadharNumber = co.objeAcc.Aadhar_Number__c;
                    lastFourDigits = aadharNumber.substring(aadharNumber.length()-4, aadharNumber.length());
                    maskAadhar = 'XXXXXXXX'+lastFourDigits;
                    co.objeAcc.Aadhar_Number__c = maskAadhar;
                }   
                System.debug('DAta to check:'+co.objeAcc);
                upsert co.objeAcc;
                
            }  
            if(co.objApplicant != null){
                co.objApplicant.Name = co.objeAcc.FirstName + ' ' + co.objeAcc.LastName;
                co.objApplicant.Account__c = co.objeAcc.Id;
                if (leadId.startsWith('00Q')){
                    co.objApplicant.Lead__c = leadId;
                }else{
                    co.objApplicant.Deal__c = leadId;
                }
                
                applicantlistToInsert.add(co.objApplicant);
                mapAccIdvsAppType.put(co.objeAcc.Id,co.objApplicant.Type__c);
            }
            
            if(co.appCurrentAdd != null){
                system.debug('appCurrentAdd'+co.appCurrentAdd.Name);
                co.appCurrentAdd.Account__c = co.objeAcc.Id;
                if (leadId.startsWith('00Q')){
                    co.appCurrentAdd.Lead__c = leadId;
                }else{
                    co.appCurrentAdd.Deal__c = leadId;
                }
                
                addressListToInsert.add(co.appCurrentAdd);
            }
            if(co.appPermanentAdd != null){
                system.debug('appPermanentAdd'+co.appPermanentAdd.Name);
                co.appPermanentAdd.Account__c = co.objeAcc.Id;
                if (leadId.startsWith('00Q')){
                    co.appPermanentAdd.Lead__c = leadId;
                }else{
                    co.appPermanentAdd.Deal__c = leadId;
                }
                
                addressListToInsert.add(co.appPermanentAdd);
            }
            if(co.appDemography != null && co.objApplicant.Type__c == CommonConstant.COAPPLICANT){
                if (leadId.startsWith('00Q')){
                    co.appDemography.Lead__c = leadId;
                }else{
                    co.appDemography.Deal__c = leadId;
                }
                
                co.appDemography.Account__c = co.objeAcc.Id;
                demographyToAdd.add(co.appDemography);
            }
            system.debug('co.ocrDocumentRecords' +co.ocrDocumentRecords);
            if (co.ocrDocumentRecords != null && !co.ocrDocumentRecords.isEmpty()){
                
                for (Map<String, Object> ocrRecord : co.ocrDocumentRecords) {
                String docType = (String)ocrRecord.get('docType');
                String fullName = (String)ocrRecord.get('fullName');
                String base64 = (String)ocrRecord.get('base64');
                    system.debug('docType' +docType);
                    system.debug('fullName' +fullName);
                    system.debug('base64' +base64);

                 if(docType == CommonConstant.DOCUMENT_TYPE_AADHAR){
                   documentType = CommonConstant.CV_DOCUMENT_TYPE_AADHAR; 
                }else if(docType == CommonConstant.DOCUMENT_TYPE_PAN){
                   documentType = CommonConstant.CV_DOCUMENT_TYPE_PAN; 
                }else if(docType == CommonConstant.DOCUMENT_TYPE_PASSPORT){
                    documentType = CommonConstant.CV_DOCUMENT_TYPE_PASSPORT; 
                }
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.Title = fullName;
                contentVersion.VersionData = EncodingUtil.base64Decode(base64);
                contentVersion.PathOnClient = fullName;
                contentVersion.Account__c = co.objeAcc.Id;
                contentVersion.Document_Type__c = documentType;
                if (leadId.startsWith('00Q')){
                    contentVersion.Lead__c = leadId;
                }
                else{
                    contentVersion.Deal__c = leadId;
                }
                contentVersionsToInsert.add(contentVersion);
            }
            }
        } 
        
        if(applicantlistToInsert != null){
            system.debug('applicantlistToInsert::'+applicantlistToInsert);
            upsert applicantlistToInsert;
            updateDCLApplicant(applicantlistToInsert);
        }
        if(addressListToInsert != null){
            upsert addressListToInsert;
        }
        if(demographyToAdd != null){
            upsert demographyToAdd;
        }
        
        if(contentVersionsToInsert != null){
            system.debug('Inserted Successfully');
            insert contentVersionsToInsert;
        }
        
        system.debug('contentVersionsToInsert' +contentVersionsToInsert);
        system.debug('contentVersionsToInsert' +contentVersionsToInsert.size());
        dcList = [Select Id,Lead__c,Applicant__c from Document_Checklist__c where (Lead__c =: leadId OR Deal__c =: leadId) AND Applicant__c IN:applicantlistToInsert];
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
        system.debug('contentVersionsToInsert33333' +contentVersionsToInsert);
        system.debug('contentVersionsToInsert33333' +contentVersionsToInsert.size());
        if(contentVersionsToInsert != null){
            createOCRDocuments(leadId, contentVersionsToInsert);
        }
        
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
            dcList = [select id,Applicant__c,Doc_Sub_Type__c from Document_Checklist__c where Applicant__c In: appList];
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
        
        //Get the document names list as per type of applicant
        List<Document_Name_DMS__mdt> documentNames = [SELECT Id,Label,Applicant_Type__c,Document_Type__c FROM Document_Name_DMS__mdt];
        
        Map<String, List<Document_Name_DMS__mdt>> documentMap = new Map<String, List<Document_Name_DMS__mdt>>();
        for (Document_Name_DMS__mdt document : documentNames) {
            if (documentMap.containsKey(document.Applicant_Type__c)) {
                List<Document_Name_DMS__mdt> documents = documentMap.get(document.Applicant_Type__c);
                documents.add(document);
            } else {
                List<Document_Name_DMS__mdt> documents = new List<Document_Name_DMS__mdt>();
                documents.add(document);
                documentMap.put(document.Applicant_Type__c, documents);
            }
        }
        if(dcList != null && dcList.size() >0){
            for( Co_Applicant__c app:appList){
                if(coIdVsDocList.get(app.Id) != null && coIdVsDocList.containskey(app.Id)){
                    for(Document_Checklist__c dc : coIdVsDocList.get(app.Id) ){
                        dc.Applicant_Type__c = app.Type__c;
                        List<Document_Name_DMS__mdt> documentsForType = documentMap.get(app.Type__c);
                        for(Document_Name_DMS__mdt currName : documentsForType){
                            if(dc.Doc_Sub_Type__c == currName.Document_Type__c){
                                dc.Document_DMS_Name__c = currName.Label;
                                break;
                            }
                        }
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
        Map<String, String> appAndDocTypeVsMasterLable = New Map<String, String>();
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
            appAndDocTypeVsMasterLable.put(customMetadata.Applicant_Type__c+customMetadata.Document_Type__c, customMetadata.MasterLabel);
        }
        
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
            
            if(appAndDocTypeVsMasterLable.containsKey(applicantType+objContentVersion.Document_Sub_Type__c)){
                system.debug('Inside If condition');
                objContentVersion.Title = appAndDocTypeVsMasterLable.get(applicantType+objContentVersion.Document_Sub_Type__c) + accoutIdvsCoAppObj.get(objContentVersion.Account__c).Naming_Order__c;
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
            address = [SELECT Id, Account__c, Lead__c, Address_Type__c From ContactPointAddress WHERE Account__c =: accId AND (Lead__c =: leadId OR Deal__c =: leadId)];
            deletCoApp = [SELECT Id from Co_Applicant__c where Account__c =: accId AND (Lead__c =: leadId OR Deal__c =: leadId)];   
            demoGraphy = [SELECT Id FROM Demography__c WHERE Account__c =: accId AND (Lead__c =: leadId OR Deal__c =: leadId)];
            reference = [SELECT Id FROM Reference__c WHERE Account__c =: accId AND (Lead__c =: leadId OR Deal__c =: leadId)];
            bankAccount = [SELECT Id FROM Bank_Details__c WHERE Account__c =: accId AND (Lead__c =: leadId OR Deal__c =: leadId)];
            asset = [SELECT Id FROM Asset WHERE AccountId =: accId AND (Lead__c =: leadId OR Deal__c =: leadId)];
            liability = [SELECT Id FROM Liability__c WHERE Account__c =: accId AND (Lead__c =: leadId OR Deal__c =: leadId)];
            employment = [SELECT Id FROM Employment_Details__c WHERE Account__c =: accId AND (Lead__c =: leadId OR Deal__c =: leadId)];
            //List<ContentVersion> contentVersionsToDelete = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Account__c =: accId AND Lead__c =: leadId];
            List<ContentVersion> contentVersionsToDelete = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Account__c =: accId];
            dcList = [Select Id,Lead__c,Applicant__r.Account__c from Document_Checklist__c where (Lead__c =: leadId OR Deal__c =: leadId) AND Applicant__r.Account__c =:accId];
            List<Id> contentDocumentIdsToDelete = new List<Id>();
            for (ContentVersion cv : contentVersionsToDelete) {
                contentDocumentIdsToDelete.add(cv.ContentDocumentId);
            }
            List<ContentDocument> contentDocumentsToDelete = [SELECT Id FROM ContentDocument WHERE Id IN :contentDocumentIdsToDelete];
            
            
           /* if(appList.size() == 1 && !appList.isEmpty()){
                if(acc != null)
                    delete acc;
            }*/
            
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
                                            FROM Co_Applicant__c WHERE (Lead__c =: leadId OR Deal__c =: leadId) AND Type__c = 'Applicant' LIMIT 1];
            
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
                                         WHERE (Lead__c = :leadId OR Deal__c =:leadId)  AND Type__c = 'Applicant'
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
        
        List<Employment_Details__c> lstApp = [SELECT Id, Name, Employment_Type__c, Name_Of_The_Company__c, 
                                              No_of_Years_with_Current_Employer__c, Monthly_Income__c, Official_Email_Id__c, Type_Of_Company__c, 
                                              Role_In_Organization__c, Total_Professional_Experience__c, NatureofProfession__c, Address_of_Current_Business__c, 
                                              Membership_Number__c,GST_IN__c, NatureofBusiness__c, Date_of_Retirement__c, Organisation_Name__c, Pension_Amount__c, 
                                              Account__c,Account__r.Name, Lead__c, Sector__c,Deal__c FROM Employment_Details__c WHERE (Lead__c =: leadId OR Deal__c =:leadId)];
        
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
                                 FROM Contact_Point_Addresses__r WHERE Address_Type__c = 'Office') From Account WHERE Id in: setApplIds];
        system.debug('lstAcc' +lstAcc);
        system.debug('lstAccName' +lstAcc[0].Name);
        
        for(Account objAcc: lstAcc){
            wrapperForApplicant objwrapperForApplicant = new wrapperForApplicant();
            objwrapperForApplicant.objeAcc = objAcc;    
            objwrapperForApplicant.objEmployment = mapAccvsAppIds.get(objAcc.Id);
            //objwrapperForApplicant.objApplicant = objAcc.Name;kar
            
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
                co.objEmployment.NatureofProfession__c = '';
                co.objEmployment.Membership_Number__c = null;
                co.objEmployment.NatureofBusiness__c = '';
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
                if (leadId.startsWith('00Q')){
                    co.appOfficeAdd.Lead__c = leadId;
                }else{
                    co.appOfficeAdd.Deal__c = leadId;
                }
                
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
        Employment_Details__c emp = [SELECT Id, Lead__c, Deal__c,Account__c from Employment_Details__c where Id =:employmentId];
        
        add = [SELECT Id, Account__c, Lead__c, Address_Type__c 
               From ContactPointAddress WHERE Address_Type__c = 'Office' AND Account__c =: emp.Account__c AND (Lead__c =: emp.Lead__c OR Deal__c =: emp.Deal__c)];
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
                           WHERE (Lead__c =: leadId OR Deal__c =: leadId) AND Is_Income_Considered_Financial__c = 'Yes'];
        
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
        applicantsWithLeadIdRec = [Select Id, Name,Account__c, Account__r.Name,Lead__r.Name, Lead__r.Id,Account__r.Id,Type__c, Is_Income_Considered_Financial__c,Deal__c
                                   from Co_Applicant__c where (Lead__r.Id =: leadGetId OR Deal__c =:leadGetId)];
        return applicantsWithLeadIdRec;         
    }
    
    //Get check for co-applicant
    @AuraEnabled
    public static Lead getCheck(String leadId){
        return [SELECT Id,Co_applicant_Section__c,Employment_Section__c,Document_Checked__c,Financial_Section__c,Reference_Section__c,Name FROM Lead WHERE Id =: leadId];
    }
    
    //Get check for co-applicant
    @AuraEnabled
    public static Lead getCheckDetails(String leadId){
        return[SELECT Id,Applicant_Section__c, Co_applicant_Section__c, Employment_Section__c, Financial_Section__c, Reference_Section__c, Loan_Required_A_B__c,Course_Section__c, Name FROM Lead WHERE Id = :leadId];
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
    
    //Update Why_Mother_Father_are_not_Co_Applicants__c Field of Lead //Added By Rohit
    @AuraEnabled
    public static void updateQuestionOnLead(Id leadId, String questionAnswer, String otherReason) {
        try {
            String leadIdStr = String.valueOf(leadId);
            if (leadIdStr.startsWith('00Q')){
                Lead objLead = [SELECT Id, Why_Mother_Father_are_not_Co_Applicants__c, Other_Reason__c FROM Lead WHERE Id = :leadId];
                
                if (objLead != null) {
                    objLead.Why_Mother_Father_are_not_Co_Applicants__c = questionAnswer;
                    objLead.Other_Reason__c = otherReason;
                    update objLead;
                }
            }else{
                Opportunity objeOpp = [SELECT Id, Mother_Father_non_Co_Applicants_reason__c, Other_Reason__c FROM Opportunity WHERE Id =: leadId];
                if (objeOpp != null) {
                    objeOpp.Mother_Father_non_Co_Applicants_reason__c = questionAnswer;
                    objeOpp.Other_Reason__c = otherReason;
                    update objeOpp;
                }
            }
            
        } catch (Exception ex) {
            System.debug('An error occurred: ' + ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static SObject  getQuestionFromLead(Id leadId) {
        try {
            String leadIdStr = String.valueOf(leadId);
            if (leadIdStr.startsWith('00Q')){
                Lead objLead = [SELECT Id, Why_Mother_Father_are_not_Co_Applicants__c, Other_Reason__c FROM Lead WHERE Id = :leadId];
                return objLead;
            }else{
                Opportunity objeOpp = [SELECT Id, Mother_Father_non_Co_Applicants_reason__c, Other_Reason__c FROM Opportunity WHERE Id =: leadId];
                return objeOpp;
            }
        } catch (Exception e) {
            System.debug('An error occurred while retrieving the lead: ' + e.getMessage());
        }
        return null;
    }
    
    //When OCR fails save the documnet
    public static void createOCRDocuments(Id leadId, List<ContentVersion> cvList) {
        system.debug('cvList' + cvList.size());
        Set<Id> accountId = new Set<Id>();
        List<Document_Checklist__c> dcList = new List<Document_Checklist__c>();
        List<ContentDocumentLink> contentDocumentLink = new List<ContentDocumentLink>();
        Map<Id, List<ContentVersion>> accountIdvsCVRecord = new Map<Id, List<ContentVersion>>();
        
        List<ContentVersion> cvLinkList = [SELECT ContentDocumentId, Document_Type__c, Account__c, Id FROM ContentVersion WHERE Id IN :cvList];
        
        for (ContentVersion obj : cvLinkList) {
            System.debug('Document_Type__c' + obj.Document_Type__c);
            system.debug('objContnetDocumentId' + obj.ContentDocumentId);
            accountId.add(obj.Account__c);
            
            if (!accountIdvsCVRecord.containsKey(obj.Account__c)) {
                accountIdvsCVRecord.put(obj.Account__c, new List<ContentVersion>());
            }
            accountIdvsCVRecord.get(obj.Account__c).add(obj);
        }
        
        try {
            dcList = [SELECT Id, Lead__c, Applicant__c, Doc_Sub_Type__c, Applicant__r.Account__c FROM Document_Checklist__c WHERE (Lead__c =: leadId OR Deal__c =: leadId) AND Applicant__r.Account__c IN :accountId];
            system.debug('dcList' + dcList.size());
            
            for (Document_Checklist__c objdcl : dcList) {
                Id accId = objdcl.Applicant__r.Account__c;
                if (accountIdvsCVRecord.containsKey(accId)) {
                    List<ContentVersion> cvRecords = accountIdvsCVRecord.get(accId);
                    for (ContentVersion cv : cvRecords) {
                        if (objdcl.Doc_Sub_Type__c == cv.Document_Type__c) {
                            system.debug('INSIDE IF CONDITION');
                            ContentDocumentLink cdl = new ContentDocumentLink();
                            cdl.ContentDocumentId = cv.ContentDocumentId;
                            cdl.LinkedEntityId = objdcl.Id;
                            contentDocumentLink.add(cdl);
                            
                            ContentDocumentLink cd2 = new ContentDocumentLink();
                            cd2.ContentDocumentId = cv.ContentDocumentId;
                            cd2.LinkedEntityId = cv.Account__c;
                            contentDocumentLink.add(cd2);
                            
                        }
                    }
                }
            }
            
            system.debug('contentDocumentLink size=>' + contentDocumentLink.size());
            
            if (!contentDocumentLink.isEmpty()) {
                insert contentDocumentLink;
            }
        } catch (Exception e) {
            // Handle or log the exception
            System.debug('Exception :: ' + e.getMessage() + '. At line no. ' + e.getLineNumber());
            //System.debug('An error occurred: ' + e.getMessage());
        }
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
        @AuraEnabled
    	public List<Map<String, Object>> ocrDocumentRecords {get; set;}
    }
}