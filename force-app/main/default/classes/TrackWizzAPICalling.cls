/******************************************************************************************************************
* @author           Rohit Pardeshi
* @description      This Class used to Call TrackWizz Api and take action according to Response
* @Arguments        
* @date             14/08/2023   
*******************************************************************************************************************/
public class TrackWizzAPICalling {
    /******************************************************************************************************************
* @author           Rohit Pardeshi
* @description      This Methos is used to get Applicant Record related to Opportuniy and Call API with Respective 
Applicant TrackWizz Result 
* @Arguments        oppList
* @date             14/08/2023   
*******************************************************************************************************************/
    @InvocableMethod(label='TrackWizzApiFlow' category='Other')
    public static void getRelatedRecordsAndCallTrackWizzApi(List<Opportunity> oppList)
    {
        Map<Id, ContactPointAddress> opportunityCurrentAddressMap = new Map<Id, ContactPointAddress>();
        Map<Id, ContactPointAddress> opportunityPermanantAddressMap = new Map<Id, ContactPointAddress>();
        Integer maxLength = 50;
        Map<Id, String> applicantIdToResponseMap = new Map<Id, String>();
        Map<Id, String> applicantIdToRequestMap = new Map<Id, String>();
        String endPoint;
        String losNameCredential;
        
        String trackWizz = Label.TrackWizz_Api;
        APIConfiguration__mdt apiConfig = [select ApiEndPoint__c, QualifiedApiName, HeaderParameters__c from APIConfiguration__mdt where QualifiedApiName =: trackWizz];
        
        try{
            
            Id opportunityId = oppList[0].Id;
            system.debug('opportunityId' +opportunityId);
            losNameCredential  = [SELECT Id, DeveloperName, Endpoint FROM NamedCredential WHERE DeveloperName =: Label.LOS_API_Name_Credential].Endpoint;
            endPoint = losNameCredential + apiConfig.ApiEndPoint__c;
            List<Co_Applicant__c> coAppList = [SELECT Deal__c, Deal__r.Loan_Application_Number__c, Type__c, Account__c, Account__r.FirstName, Account__r.MiddleName, Account__r.LastName, 
                                               Account__r.PAN_Number__c, Account__r.Passport_Number__c, Account__r.Gender__c, Account__r.Driving_License_Number__c,
                                               Account__r.Date_of_Birth__c, Account__r.PersonMobilePhone, Account__r.Email__c 
                                               FROM Co_Applicant__c WHERE Deal__c =:opportunityId AND (TrackWizz_Result__c = null OR TrackWizz_Result__c = 'Error')];
            System.debug('coApplicantttttt88888' +coAppList.size());
            
            if(coAppList.size() > 0){
                for (ContactPointAddress currentaddress : [SELECT Deal__c, Account__c, Address_1__c, Pin_Code__r.Name, City__c, State__c, Country__c,Pin_Code__r.Country_Code__c 
                                                           FROM ContactPointAddress 
                                                           WHERE Address_Type__c = 'Current Address' AND Deal__c =:opportunityId]) {
                                                               opportunityCurrentAddressMap.put(currentaddress.Account__c, currentaddress);
                                                           }
                system.debug('opportunityCurrentAddressMap' +opportunityCurrentAddressMap);
                for (ContactPointAddress permanantaddress : [SELECT Deal__c, Account__c, Address_1__c, Pin_Code__r.Name, City__c, State__c, Country__c,Pin_Code__r.Country_Code__c
                                                             FROM ContactPointAddress 
                                                             WHERE Address_Type__c = 'Permanent Address' AND Deal__c =:opportunityId]) {
                                                                 opportunityPermanantAddressMap.put(permanantaddress.Account__c, permanantaddress);
                                                             }
                system.debug('opportunityPermanantAddressMap' +opportunityPermanantAddressMap);
                
                //PageReference xmlResource = Page.TrackWizzApi; // Replace with the actual name of your static resource
                
                String staticName = CommonConstant.TRACK_WIZZ_STATIC_RESOURCE;
                StaticResource objSR = [SELECT ID, Body FROM StaticResource WHERE Name =: staticName LIMIT 1];
                
                String xmlString = objSR.Body.toString();
                
                for(Co_Applicant__c objCo : coAppList){
                    String gender = '';
                    String currentAddress1 = '';
                    String currentAddress2 = '';
                    String currentAddress3 = '';
                    String currentcity = '';
                    String currentState = '';
                    String currentCounty = '';
                    String currentCountryCode = '';
                    String currentPinCode = '';
                    String permanentAddress1 = '';
                    String permanentAddress2 = '';
                    String permanentAddress3 = '';
                    String permanentcity = '';
                    String permanentState = '';
                    String permanentCounty = '';
                    String permanentCountryCode = '';
                    String permanentPinCode = '';
                    
                    Integer randomNumber = (Integer)Math.floor(Math.random() * 900000000) + 100000000;
                    DateTime now = DateTime.now();
                    String formattedTime = now.format('HHmm');
                    String finalString = String.valueOf(randomNumber) + formattedTime;
                    Date dateOfBirth = objCo.Account__r.Date_of_Birth__c;
                    String formattedDateOfBirth = dateOfBirth.day() + '-' + dateOfBirth.month().format() + '-' + dateOfBirth.year();
                    system.debug('Gender__c' +objCo.Account__r.Gender__c);
                    if(objCo.Account__r.Gender__c == 'Male'){
                        gender = 'M';
                    }else{
                        gender = 'F';
                    }
                    system.debug('Account__c' +objCo.Account__c);
                    if (opportunityCurrentAddressMap.containsKey(objCo.Account__c)){
                        ContactPointAddress curAddObj = opportunityCurrentAddressMap.get(objCo.Account__c);
                        String addressValue = curAddObj.Address_1__c;
                        currentcity = curAddObj.City__c;
                        currentState = curAddObj.State__c;
                        currentCounty = curAddObj.Country__c;
                        currentPinCode = curAddObj.Pin_Code__r.Name;
                        currentCountryCode = curAddObj.Pin_Code__r.Country_Code__c;
                        
                        if (addressValue.length() <= maxLength) {
                            currentAddress1 = addressValue;
                        } else if (addressValue.length() <= maxLength * 2) {
                            currentAddress1 = addressValue.substring(0, maxLength);
                            currentAddress2 = addressValue.substring(maxLength);
                        } else {
                            currentAddress1 = addressValue.substring(0, maxLength);
                            currentAddress2 = addressValue.substring(maxLength, maxLength * 2);
                            currentAddress3 = addressValue.substring(maxLength * 2, Math.min(addressValue.length(), maxLength * 2 + maxLength));
                        }
                    }
                    
                    if (opportunityPermanantAddressMap.containsKey(objCo.Account__c)){
                        ContactPointAddress perAddObj = opportunityPermanantAddressMap.get(objCo.Account__c);
                        String perAddressValue = perAddObj.Address_1__c;
                        permanentcity = perAddObj.City__c;
                        permanentState = perAddObj.State__c;
                        permanentCounty = perAddObj.Country__c;
                        permanentPinCode = perAddObj.Pin_Code__r.Name;
                        permanentCountryCode = perAddObj.Pin_Code__r.Country_Code__c;
                        
                        if (perAddressValue.length() <= maxLength){
                            permanentAddress1 = perAddressValue;
                        } else if (perAddressValue.length() <= maxLength * 2) {
                            permanentAddress1 = perAddressValue.substring(0, maxLength);
                            permanentAddress2 = perAddressValue.substring(maxLength);
                        } else {
                            permanentAddress1 = perAddressValue.substring(0, maxLength);
                            permanentAddress2 = perAddressValue.substring(maxLength, maxLength * 2);
                            permanentAddress3 = perAddressValue.substring(maxLength * 2, Math.min(perAddressValue.length(), maxLength * 2 + maxLength));
                        }
                    }
                    
                    String individualRequest = xmlString.replace('{finalString}', finalString)
                        .replace('{accountId}', objCo.Account__c)
                        .replace('{applicationFormNumber}', objCo.Deal__r.Loan_Application_Number__c != null ? objCo.Deal__r.Loan_Application_Number__c : '')
                        .replace('{firstName}', objCo.Account__r.FirstName)
                        .replace('{middleName}', objCo.Account__r.MiddleName != null ? objCo.Account__r.MiddleName : '')
                        .replace('{lastName}', objCo.Account__r.LastName)
                        .replace('{gender}', gender)
                        .replace('{panNumber}', objCo.Account__r.PAN_Number__c != null ? objCo.Account__r.PAN_Number__c : '')
                        .replace('{passportNumber}', objCo.Account__r.Passport_Number__c != null ? objCo.Account__r.Passport_Number__c : '')
                        .replace('{DrivingLicenseNumber}', objCo.Account__r.Driving_License_Number__c != null ? objCo.Account__r.Driving_License_Number__c : '')
                        .replace('{dateOfBirth}', formattedDateOfBirth)
                        .replace('{currentAddress1}', currentAddress1)
                        .replace('{currentAddress2}', currentAddress2 != null ? currentAddress2 : '')
                        .replace('{currentAddress3}', currentAddress3 != null ? currentAddress3 : '')
                        .replace('{currentcity}', currentcity != null ? currentcity : '')
                        .replace('{currentState}', currentState != null ? currentState : '')
                        .replace('{currentCountryCode}', currentCountryCode != null ? currentCountryCode : '')
                        .replace('{currentPinCode}', currentPinCode != null ? currentPinCode : '')
                        .replace('{permanentAddress1}', permanentAddress1 != null ? permanentAddress1 : '')
                        .replace('{permanentAddress2}', permanentAddress2 != null ? permanentAddress2 : '')
                        .replace('{permanentAddress3}', permanentAddress3 != null ? permanentAddress3 : '')
                        .replace('{permanentcity}', permanentcity != null ? permanentcity : '')
                        .replace('{permanentState}', permanentState != null ? permanentState : '')
                        .replace('{permanentCountryCode}', permanentCountryCode != null ? permanentCountryCode : '')
                        .replace('{permanentPinCode}', permanentPinCode != null ? permanentPinCode : '')
                        .replace('{mobileNumber}', objCo.Account__r.PersonMobilePhone != null ? objCo.Account__r.PersonMobilePhone : '')
                        .replace('{email}', objCo.Account__r.Email__c != null ? objCo.Account__r.Email__c : '');
                    
                    String token = LOSToken.getAccessToken();
                    HttpRequest httpRequest = new HttpRequest();
                    httpRequest.setEndpoint('callout:LOS_API'+apiConfig.ApiEndPoint__c); // API endpoint  
                    httpRequest.setMethod('POST');
                    httpRequest.setHeader('Authorization', 'Bearer '+token);
                    httpRequest.setHeader('Content-Type', apiConfig.HeaderParameters__c);
                    httpRequest.setBody(individualRequest);
                    
                    //endPoint = httpRequest.getEndPoint();
                    HttpResponse response = new Http().send(httpRequest);
                    applicantIdToResponseMap.put(objCo.Id, response.getBody());
                    applicantIdToRequestMap.put(objCo.Id, httpRequest.getBody());
                }
                
                createDocumentChecklist(opportunityId, applicantIdToResponseMap);
                action(opportunityId, applicantIdToResponseMap, applicantIdToRequestMap, endPoint);
            }
            
        } catch (Exception e) {
            System.debug('Outer Exception: ' + e.getMessage() + '. At line no. ' + e.getLineNumber());
        }
    }
    
    /*********************************************************************************************************************
* @author           Rohit Pardeshi
* @description      This method is used to create Document checklist respective Applicant while lead converting
* @Arguments        oppId, appliIdToResponseMap
* @date             21/08/2023   
***********************************************************************************************************************/
    public static void createDocumentChecklist(Id oppId, Map<Id, String> appliIdToResponseMap){
        system.debug('appliIdToResponseMap' +appliIdToResponseMap);
        Map<String, Document_Checklist_Master__c> typeVsDocMaster = New Map<String, Document_Checklist_Master__c>();
        Map<String, String> typeVsDMSLable= New Map<String, String>();
        List<Document_Checklist__c> insertDocCheckList = New List<Document_Checklist__c>();
        //Set<Id> existingApplicantIds = new Set<Id>();
        Map<Id, Document_Checklist__c> applicantIdVsdocChekList = New Map<Id, Document_Checklist__c>();
        
        String jsonString;
        try{
            String docSubType = CommonConstant.CV_DOC_SUB_TYPE;
            Id leadId = [SELECT Id, Lead__c FROM Opportunity WHERE Id =:oppId].Lead__c;
            List<Document_Name_DMS__mdt> documentNames = [SELECT Id,Label,Applicant_Type__c,Document_Type__c FROM Document_Name_DMS__mdt WHERE Document_Type__c =: docSubType];
            system.debug('documentNames' +documentNames.size());
            
            for(Document_Name_DMS__mdt objdms : documentNames){
                typeVsDMSLable.put(objdms.Applicant_Type__c, objdms.Label);
            }
            system.debug('typeVsDMSLable' +typeVsDMSLable);
            
            List<Document_Checklist_Master__c> listDCLMaster = [SELECT Id,Applicant_Type__c,Document_Sub_Type__c,Auto_Create_Checklist__c,Document_Type__c,File_Size__c,
                                                                File_Types__c,Instruction_To_Upload_Documents__c,IsMandetory__c FROM
                                                                Document_Checklist_Master__c WHERE Document_Sub_Type__c =:docSubType];
            system.debug('listDCLMaster ' +listDCLMaster.size());
            
            for(Document_Checklist_Master__c objmaster : listDCLMaster){
                typeVsDocMaster.put(objmaster.Applicant_Type__c, objmaster);
            }
            system.debug('typeVsDocMaster' +typeVsDocMaster);
            
            
            List<Co_Applicant__c> coappList = [SELECT Id, Deal__c, Type__c, Account__c, Account__r.FirstName,Account__r.LastName 
                                               FROM Co_Applicant__c
                                               WHERE Deal__c =: oppId];
            system.debug('coappList ' +coappList.size());
            
            List<Document_Checklist__c> docCheckList = [SELECT Id, Deal__c, Applicant__c, Applicant__r.Account__c, Doc_Sub_Type__c, Document_Type__c, Lead__c,Status__c
                                                        FROM Document_Checklist__c
                                                        WHERE Deal__c =: oppId AND Doc_Sub_Type__c =: docSubType AND Applicant__c IN :coappList];
            system.debug('docCheckList ' +docCheckList.size());
            if(docCheckList.size() > 0){
                for(Document_Checklist__c objdc : docCheckList){
                    //existingApplicantIds.add(objdc.Applicant__c);
                    applicantIdVsdocChekList.put(objdc.Applicant__c, objdc);
                }
            }
            system.debug('applicantIdVsdocChekList' +applicantIdVsdocChekList.size());
            
            for(Co_Applicant__c  objcoapp : coappList){
                system.debug('objcoapp.Type__c '+objcoapp.Type__c);
                if(!applicantIdVsdocChekList.containsKey(objcoapp.Id)){
                    Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(appliIdToResponseMap.get(objcoapp.Id));
                    String match = String.valueOf(jsonMap.get('Matched'));
                    Document_Checklist_Master__c dcm = typeVsDocMaster.get(objcoapp.Type__c);
                    Document_Checklist__c dc = new Document_Checklist__c();
                    dc.Applicant_Name__c =objcoapp.Account__r.FirstName + ' '+objcoapp.Account__r.LastName;
                    dc.Applicant_Type__c = dcm.Applicant_Type__c;
                    dc.Applicant__c = objcoapp.Id;
                    dc.Doc_Sub_Type__c = dcm.Document_Sub_Type__c;
                    dc.Document_Checklist_Master__c = dcm.id;
                    dc.Document_Type__c = dcm.Document_Type__c;
                    dc.File_Size__c = dcm.File_Size__c;
                    dc.File_Types__c = dcm.File_Types__c;
                    if(match == CommonConstant.TRACK_WIZZ_RESULT_MATCH || match == CommonConstant.TRACK_WIZZ_RESULT_NOT_MATCH){
                        dc.Status__c = 'Uploaded';
                    }else{
                        dc.Status__c = 'Pending';
                    }
                    
                    dc.Document_Instruction__c = dcm.Instruction_To_Upload_Documents__c;
                    dc.Lead__c = leadId;
                    dc.Deal__c = oppId;
                    dc.IsMandatory__c = dcm.IsMandetory__c;
                    dc.Document_DMS_Name__c = typeVsDMSLable.get(objcoapp.Type__c);
                    insertDocCheckList.add(dc);
                }
            }
            system.debug('insertDocCheckList ' +insertDocCheckList.size());
            insert insertDocCheckList;  
        }catch(Exception e){
            System.debug('Exception Occurs while creating Document Checklist:: ' + e.getMessage() + '. At line no. ' + e.getLineNumber());
        }
    }
    /******************************************************************************************************************
* @author           Rohit Pardeshi
* @description      This Method is to update the status of Document Chelist
* @Arguments        
* @date             22/08/2023   
*******************************************************************************************************************/
    public static void updateDocumentChecklistStatus(List<Document_Checklist__c> docList){
        List<Document_Checklist__c> updateDoc = New List<Document_Checklist__c>();
        try{
            for(Document_Checklist__c objdoc : docList){
                objdoc.Status__c = 'Uploaded';
                updateDoc.add(objdoc);
            }
            
            update updateDoc;
        }catch(Exception e){
            System.debug('Exception Occurs while updating Document Checklist:: ' + e.getMessage() + '. At line no. ' + e.getLineNumber());
        }
    }
    
    /******************************************************************************************************************
* @author           Rohit Pardeshi
* @description      With respectiive response take action like createContentDocumentAPI and updateTrackWizzResponseOnApplicant
* @Arguments        oppId, appliIdToResponseMap, appliIdToRequestMap, endPoint
* @date             16/08/2023   
*******************************************************************************************************************/
    public static void action(Id oppId, Map<Id, String> appliIdToResponseMap, Map<Id, String> appliIdToRequestMap, String endPoint){
        Integer statusCode;
        String jsonString;
        Map<Id, String> applicantIdToBase64 = new Map<Id, String>();
        Map<Id, String> applicantIdVsMatchedResult = new Map<Id, String>();
        Map<Id, Id> applicantIdVsAccountId = new Map<Id, Id>();
        Map<Id, String> applicantIdVsResponse = New Map<Id, String>();
        
        try{
            List<Co_Applicant__c> applicantList = [SELECT Id, Account__c FROM Co_Applicant__c WHERE Id IN :appliIdToResponseMap.keySet()];
            system.debug('applicantList' +applicantList.size());
            
            if (!applicantList.isEmpty()){
                for(Co_Applicant__c objCo : applicantList){
                    applicantIdVsAccountId.put(objCo.Id, objCo.Account__c);
                }
            }
            system.debug('applicantIdVsAccountId' +applicantIdVsAccountId);   
            
            for (Id key : appliIdToResponseMap.keySet()){
                Id accountId = applicantIdVsAccountId.get(key);
                String response = appliIdToResponseMap.get(key);
                String request = appliIdToRequestMap.get(key);
                Map<String, Object> responseBodyMap = LosUtils.jsonStringToMapConvert(response); 
                createErrorLogRecord(oppId, request, response,accountId, endPoint, key);
                statusCode = Integer.valueOf(responseBodyMap.get('statusCode'));
                jsonString = response;
                Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
                String match = String.valueOf(jsonMap.get('Matched'));
                String baseFile = String.valueOf(jsonMap.get(' doccontent'));
                if(statusCode == 101 && (match == CommonConstant.TRACK_WIZZ_RESULT_MATCH || match == CommonConstant.TRACK_WIZZ_RESULT_NOT_MATCH)){
                    applicantIdToBase64.put(key, baseFile);
                }else{
                    applicantIdVsResponse.put(key, response);
                }
                applicantIdVsMatchedResult.put(key, match);
            }
            
            if (applicantIdToBase64 != null && !applicantIdToBase64.isEmpty()) {
                createContentDocumentAPI(oppId, applicantIdToBase64);
            }
            
            updateTrackWizzResponseOnApplicant(oppId, applicantIdVsMatchedResult);
            
            if(applicantIdVsResponse != null && !applicantIdVsResponse.isEmpty()){
                sendEmailOnAPIError(oppId, applicantIdVsResponse, endPoint);
            }
            
            
        }catch(Exception e){
            System.debug('Exception Occurs: ' + e.getMessage() + '. At line no. ' + e.getLineNumber());
        }
    }
    /******************************************************************************************************************
* @author           Rohit Pardeshi
* @description      This method Send Email
* @Arguments        applicantIdVsResponse
* @date             21/08/2023   
*******************************************************************************************************************/
    public static void sendEmailOnAPIError(Id oppId, Map<Id, String> applicantIdVsResponse, String apiName){
        Map<Id, Id> accIdVsErrorId = New Map<Id, Id>();
        List<Messaging.SingleEmailMessage > emailList=new List<Messaging.SingleEmailMessage >();
        try{
            List<Co_Applicant__c> applicantList = [SELECT Id, Account__c FROM Co_Applicant__c WHERE Id IN :applicantIdVsResponse.keySet()];
            system.debug('applicantList' +applicantList);
            List<Error_log__c> errorList = [SELECT Id, Account__c FROM Error_log__c WHERE ApiName__c =: apiName AND Deal__c =: oppId ORDER BY CreatedDate ASC];
            system.debug('errorList' +errorList);
            
            for(Error_log__c obje : errorList){
                accIdVsErrorId.put(obje.Account__c, obje.Id);
            }
            system.debug('accIdVsErrorId ' +accIdVsErrorId);
            
            EmailTemplate et =[Select Id,Subject,HtmlValue, DeveloperName From EmailTemplate where DeveloperName =: Label.TrackWizz_Api_Fail_Email];
            system.debug('et ' +et);
            List<OrgWideEmailAddress> orgEmailAddress=[select Id from OrgWideEmailAddress WHERE DisplayName =: System.Label.Organization_Wide_Email_Addresses];
            string subject = et.subject;
            List<String> toAddresses = new List<String>();
            List<String> ccAddresses = new List<String>();
            String LOS_Failed_Email_Address = label.LOS_Failed_Email_Address;
            ccAddresses = LOS_Failed_Email_Address.split(',');
            toAddresses.add(UserInfo.getUserEmail());
            
            for (Co_Applicant__c objapp : applicantList){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                if(orgEmailAddress.size() > 0){
                    mail.setOrgWideEmailAddressId(orgEmailAddress[0].Id); 
                }
                Id errorLogId = accIdVsErrorId.get(objapp.Account__c);
                String errorURL = '';
                errorURL = System.URL.getSalesforceBaseURL().toExternalForm() + '/'+ errorLogId;
                String emailBody = ((String)et.HtmlValue).replace(CommonConstant.TRACK_WIZZ_OPPId, oppId).replace(LOSConstants.ERROR_LOG_LINK,errorURL);
                mail.setSubject(subject);
                mail.setHtmlBody(emailBody);
                mail.setToAddresses(toAddresses);
                mail.setccAddresses(ccAddresses);
                mail.setTreatBodiesAsTemplate(True); 
                //mail.setTargetObjectId(opp.Lead__c);
                mail.setWhatId(oppId);
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setSaveAsActivity(false);
                emailList.add(mail);
                
            }
            
            if(emailList.size() > 0){
                Messaging.SendEmailResult[] results =Messaging.sendEmail(emailList);
                System.debug(results);   
                if(results.size() > 0){
                    if(results.get(0).isSuccess()){
                        System.debug('Success'+results);
                    }
                }
                
            }
            
        }catch(Exception e){
            System.debug('Exception Occurs while sending Email:: ' + e.getMessage() + '. At line no. ' + e.getLineNumber());
        }
    }
    /******************************************************************************************************************
* @author           Rohit Pardeshi
* @description      This method is used to Content version record and Link the pdf getting from response with respective
Document Checklist and Account
* @Arguments        oppId, appliIdToBaseFile
* @date             17/08/2023   
*******************************************************************************************************************/
    public static void createContentDocumentAPI(Id oppId, Map<Id, String> appliIdToBaseFile){
        
        Set<Id> appIds = appliIdToBaseFile.keySet();
        Map<Id, Document_Checklist__c> appliIdVsDocCheckListId = New Map<Id, Document_Checklist__c>();
        Map<Id, Id> accountIdVsContentDocId = New Map<Id, Id>();
        Map<Id, Id> applicantIdVsContentDocId = New Map<Id, Id>();
        List<ContentVersion> cvList = new List<ContentVersion>();
        List<ContentDocumentLink> contentDocumentLink = new List<ContentDocumentLink>();
        List<Document_Checklist__c> docList = New List<Document_Checklist__c>();
        try{
            String docSubType = CommonConstant.CV_DOC_SUB_TYPE;
            List<Document_Checklist__c> docCheckList = [SELECT Id, Deal__c, Applicant__c, Applicant__r.Account__c, Doc_Sub_Type__c, Document_Type__c, Lead__c, Status__c
                                                        FROM Document_Checklist__c
                                                        WHERE Deal__c =: oppId AND Doc_Sub_Type__c =: docSubType AND Applicant__c IN :appIds];
            system.debug('docCheckList' +docCheckList.size());
            
            For(Document_Checklist__c objDoc : docCheckList){
                appliIdVsDocCheckListId.put(objDoc.Applicant__c, objDoc);
            }
            system.debug('appliIdVsDocCheckListId' +appliIdVsDocCheckListId);
            for (Id key : appliIdToBaseFile.keySet()){
                String base64File = appliIdToBaseFile.get(key);
                Document_Checklist__c relatedDocCheck = appliIdVsDocCheckListId.get(key);
                ContentVersion cv = new ContentVersion();
                cv.VersionData = EncodingUtil.base64Decode(base64File);               
                cv.Title = CommonConstant.CV_TITLE; 
                cv.PathOnClient = CommonConstant.CV_PATHONCLIENT;
                cv.Account__c = relatedDocCheck.Applicant__r.Account__c;
                cv.Document_Sub_Type__c = CommonConstant.CV_DOC_SUB_TYPE;
                cvList.add(cv);
            }
            insert cvList;
            
            List<ContentVersion> cvLinkList = [SELECT Id, Title, Account__c, ContentDocumentId FROM ContentVersion WHERE Id =:cvList];
            system.debug('cvLinkList'  +cvLinkList.size());
            
            for(ContentVersion objCv : cvLinkList){
                accountIdVsContentDocId.put(objCv.Account__c, objCv.ContentDocumentId);
            }
            system.debug('accountIdVsContentDocId' +accountIdVsContentDocId);
            
            List<ContentDistribution> lstContentDistribution = new List<ContentDistribution>();
            for(ContentVersion objContentVersion: cvLinkList){
                ContentDistribution cd = new ContentDistribution();
                cd.Name = objContentVersion.Title;
                cd.ContentVersionId = objContentVersion.id;
                cd.PreferencesAllowViewInBrowser= true;
                cd.PreferencesLinkLatestVersion=true;
                cd.PreferencesNotifyOnVisit=false;
                cd.PreferencesPasswordRequired=false;
                cd.PreferencesAllowOriginalDownload= true;
                lstContentDistribution.add(cd);
            }
            insert lstContentDistribution;
            
            for (Id applicantId : appliIdVsDocCheckListId.keySet()) {
                if (accountIdVsContentDocId.containsKey(appliIdVsDocCheckListId.get(applicantId).Applicant__r.Account__c)) {
                    applicantIdVsContentDocId.put(applicantId, accountIdVsContentDocId.get(appliIdVsDocCheckListId.get(applicantId).Applicant__r.Account__c));
                }
            }
            system.debug('applicantIdVsContentDocId' +applicantIdVsContentDocId);
            
            for(Id keyvalue : appliIdToBaseFile.keySet()){
                Document_Checklist__c relatedDocCheck = appliIdVsDocCheckListId.get(keyvalue);
                docList.add(relatedDocCheck);
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = applicantIdVsContentDocId.get(keyvalue);
                cdl.LinkedEntityId = relatedDocCheck.Id;
                contentDocumentLink.add(cdl);
                
                ContentDocumentLink cd2 = new ContentDocumentLink();
                cd2.ContentDocumentId = applicantIdVsContentDocId.get(keyvalue);
                cd2.LinkedEntityId = relatedDocCheck.Applicant__r.Account__c;
                contentDocumentLink.add(cd2);                
            }
            
            if(contentDocumentLink != null && contentDocumentLink.size() > 0){
                insert contentDocumentLink;
            }
            
            if(docList.size() > 0){
                updateDocumentChecklistStatus(docList); 
            }
            
        }catch(Exception e){
            System.debug('Exception Occurs while creating Documents: ' + e.getMessage() + '. At line no. ' + e.getLineNumber());
        }
    }
    
    /******************************************************************************************************************
* @author           Rohit Pardeshi
* @description      This method is updated TrackWizz Api result on Applicant record(TrackWizz_Result__c)
* @Arguments        oppId, appliIdVsAPIResponse
* @date             17/08/2023   
*******************************************************************************************************************/
    public static void updateTrackWizzResponseOnApplicant(Id oppId, Map<Id, String> appliIdVsAPIResponse){
        List<Co_Applicant__c> applicantsToUpdate = new List<Co_Applicant__c>();
        try{
            List<Co_Applicant__c> applicantList = [SELECT Id, TrackWizz_Result__c FROM Co_Applicant__c WHERE Id IN :appliIdVsAPIResponse.keySet()];
            system.debug('applicantList' +applicantList.size());
            
            if (!applicantList.isEmpty()){
                for(Co_Applicant__c objCo : applicantList){
                    String matchResponse = appliIdVsAPIResponse.get(objCo.Id);
                    if(matchResponse == CommonConstant.TRACK_WIZZ_RESULT_NOT_MATCH){
                        objCo.TrackWizz_Result__c = CommonConstant.APPLICANT_TRACK_RESULT_NOT_MATCH;
                    }else{
                        objCo.TrackWizz_Result__c = matchResponse;
                    }
                    applicantsToUpdate.add(objCo);
                }
            }
            
            if (!applicantsToUpdate.isEmpty()) {
                update applicantsToUpdate;
            }
            
            updateDealTrackWizzSync(oppId, appliIdVsAPIResponse);
            
        }catch (Exception e) {
            System.debug('Exception Occurs while updating Applicant Records: ' + e.getMessage() + '. At line no. ' + e.getLineNumber());
        }
    }
    /*******************************************************************************************************************************************
* @author           Rohit Pardeshi
* @description      When All the Applicants Trackwizz screening is completed this method is used to update Deal TrackWizz_Sync__c Field
* @Arguments        oppId, appliIdVsAPIResponse
* @date             17/08/2023   
********************************************************************************************************************************************/
    public static void updateDealTrackWizzSync(Id oppId, Map<Id, String> appliIdVsAPIResponse){
        try{
            List<Co_Applicant__c> applicantList = [SELECT Id, TrackWizz_Result__c FROM Co_Applicant__c WHERE Id IN :appliIdVsAPIResponse.keySet()];
            system.debug('applicantList' +applicantList);
            if (!applicantList.isEmpty()){
                Boolean allMatchOrNotMatch = true;
                for(Co_Applicant__c objCo : applicantList){
                    if(objCo.TrackWizz_Result__c == CommonConstant.TRACK_WIZZ_RESULT_ERROR || objCo.TrackWizz_Result__c == '' || objCo.TrackWizz_Result__c == null){
                        allMatchOrNotMatch = false;
                        break;
                    }
                }
                if(allMatchOrNotMatch){
                    Opportunity oppRecord = [SELECT Id, TrackWizz_Sync__c From Opportunity WHERE Id =: oppId];
                    oppRecord.TrackWizz_Sync__c = true;
                    update oppRecord;
                }
            }
        }catch (Exception e) {
            System.debug('Exception Occurs while updating Deal Record: ' + e.getMessage() + '. At line no. ' + e.getLineNumber());
        }
    }
    /******************************************************************************************************************
* @author           Rohit Pardeshi
* @description      This method is used to Create record of Error Log 
* @Arguments        oppId, request, response, request, accId, endPoint, ApplicantId
* @date             16/08/2023   
*******************************************************************************************************************/
    public static void createErrorLogRecord(Id oppId, String request, String response, Id accId, String endPoint, Id applicantId) {
        try {
            Integer requestBodyLength = request.length();
            Integer responseBodyLength = response.length();
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response);            
            Error_log__c e = new Error_log__c();
            e.Deal__c = oppId;
            e.ApiName__c = 'Screening';
            e.Account__c = accId;
            e.Record_Id__c = applicantId;
            if (jsonResponse.containsKey('statusCode')){
                e.StatusCode__c = Integer.valueOf(jsonResponse.get('statusCode'));
            }
            if(jsonResponse.containsKey('status')){
               e.Status__c = String.valueOf(jsonResponse.get('status')); 
            }else{
               e.Status__c = 'Failure';  
            }
            if(requestBodyLength < 131072){
                e.Request__c = request;
            }else{
                e.Request__c = request.substring(0, 131072);
            }
            if (responseBodyLength < 131072) {
                e.Response__c = response;
            }else{
                e.Response__c = response.substring(0, 131072);
            }
            insert e;
            
        } catch (Exception ex) {
            System.debug('An error occurred while creating the error log record: ' + ex.getMessage());
        }
    }
}