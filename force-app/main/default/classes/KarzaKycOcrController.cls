/*********************************************************************************************
*Name        :  KarzaKycOcrController
*@author     :  Aasim Shaikh
*@date       :  20/04/2023
@description : This class is used for Integrate Karza Kyc Ocr API Logic.
*
*********************************************************************************************/
global with sharing class KarzaKycOcrController {
    /********************************************************************************************************************************************
* @author           Aasim Shaikh
* @description      This method is used to call karza kyc document ocr api
* @param        	leadId, account id, base64 strinng, file name, filedocType, existingAadhar, existingPAN, existingVoter, exisitngPassport, 
					existingDL, applicantType, existingapplicantId
*@return			wrapperClass
* @date             20/04/2023     
********************************************************************************************************************************************/
    @AuraEnabled
    public static wrapperClass getDocumentOcred(Id leadId, Id accId, String base64, String fileName, String filedocType, String existingAadhar, String existingPAN, String existingVoter, String exisitngPassport, String existingDL, String applicantType, String existingapplicantId, List<wrapperForApplicant> coApplicantData) {
        String jsonString;
        Integer statusCode;
        Id dupAccountId;
        String diplicateParamater;
        String duplicateValue;
        String apiAadharNumber;
        String apiAadharLastFourDigit;
        Date leadDOB;
        Id applicantId;
        Id formAccountId;
        Integer status;
        String errorMessage;
        List<ContactPointAddress> cpa = new  List<ContactPointAddress>();
        
        wrapperClass wc = new wrapperClass();
        try {
            Blob blobData = EncodingUtil.base64Decode(base64);
            String base64Data = EncodingUtil.base64Encode(blobData);
            
            String methodName = System.Label.OCR_API;
            KARZA_API_Detail__mdt apiConfig = [SELECT Label, QualifiedApiName, ApiEndPoint__c, Api_Key__c, RequestMethod__c,  RequestTimeout__c  
                                               FROM KARZA_API_Detail__mdt WHERE QualifiedApiName =: methodName];
            Integer requestTimeout = Integer.valueOf(apiConfig.RequestTimeout__c);
            
            KycOCRModal kyc = new KycOCRModal();
            kyc.setFile('');
            kyc.setFileBase64(base64Data);
            kyc.setUrl('');
            kyc.setPdfPassword('');
            kyc.setRequiredConfidence(true);
            kyc.setRequiredOcr(true);
            kyc.setReturnQualityChecks(new List<String>{'ALL'});
            kyc.setMaskAadhaarImage('EIGHT_DIGITS');
            kyc.setMaskAadhaarText('EIGHT_DIGITS');
            kyc.setResponseFormat('DOCUMENT');
            kyc.setResponseType('BASE64');
            kyc.setDocTypes(new List<String>{filedocType});
            
            HttpRequest request = new HttpRequest();
            String endPoint = 'callout:karzaAPI' +apiConfig.ApiEndPoint__c;
            request.setEndpoint(endPoint);
            request.setTimeout(requestTimeout);
            request.setMethod(apiConfig.RequestMethod__c);
            request.setHeader('Content-Type', CommonConstant.APPLICATION_JSON);
            request.setHeader('x-karza-key', apiConfig.Api_Key__c);
            request.setBody(JSON.serialize(kyc));
            
            Http http = new Http();
            HttpResponse response = http.send(request);
            
            Map<String, Object> responseBodyMap = LosUtils.jsonStringToMapConvert(response.getBody()); 
            statusCode = Integer.valueOf(responseBodyMap.get('statusCode'));
            String statusMessage = responseBodyMap.get('statusMessage') != null ? responseBodyMap.get('statusMessage').toString() : '';
            if(statusCode == null){
                status = Integer.valueOf(responseBodyMap.get('status'));
                errorMessage = responseBodyMap.get('error').toString();
            }
            createErrorLogRecord(leadId, statusCode, statusMessage, request.getBody(), response.getBody());
            
            //fOR tESTTING PURPOSE ADDED 105 CHANGED IT TO statusCode == 101 once testing done
            if(statusCode == 105) {
                jsonString = response.getBody();
                
                Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
                List<Object> documentsList = (List<Object>)((Map<String, Object>)jsonMap.get('result')).get('documents');
                List<Map<String, Object>> documentListMap = new List<Map<String, Object>>();
                
                for(Object o : documentsList) {
                    Map<String, Object> temp = (Map<String, Object>) JSON.deserializeUntyped(Json.serializePretty(o));
                    documentListMap.add(temp);
                }
                
                List<String> base64Str = new List<String>();
                for(Map<String, Object> docMap : documentListMap){
                    if (docMap.containsKey('documentBase64') && docMap.get('documentBase64') != null) {
                        base64Str.add(docMap.get('documentBase64').toString());
                    }else{
                        base64Str.add(base64);
                    }   
                }
                
                formAccountId = accId;//formAccountId is use store initial accountId from Loan application Form
                wc = populateDataFromKyc(documentListMap, leadId, accId);
                
                if(wc.apiDocumentType == CommonConstant.DOCUMENT_TYPE_AADHAR){
                    apiAadharLastFourDigit = wc.leadAadharNumber.substring(wc.leadAadharNumber.length() - 4);
                    apiAadharNumber = 'XXXXXXXX'+apiAadharLastFourDigit;
                    if(wc.leadDOB != null){
                        leadDOB = Date.valueOf(wc.leadDOB); 
                    }   
                }
                
                if(wc.apiDocumentType == CommonConstant.DOCUMENT_TYPE_AADHAR){
                    diplicateParamater = CommonConstant.PARAMETER_AADHAR;
                    duplicateValue = apiAadharNumber;
                }else if(wc.apiDocumentType == CommonConstant.DOCUMENT_TYPE_PAN){
                    diplicateParamater = CommonConstant.PARAMETER_PAN;
                    duplicateValue = wc.apiPANNumber;
                }else if(wc.apiDocumentType == CommonConstant.DOCUMENT_TYPE_PASSPORT){
                    diplicateParamater = CommonConstant.PARAMETER_PASSPORT;
                    duplicateValue = wc.apiPassportNumber;
                }

                if(applicantType != CommonConstant.APPLICANT){
                    wc.kycAlreadyPresen = checkKYCAlreadyPresent(coApplicantData, diplicateParamater, duplicateValue, accId);
                }
                
                dupAccountId = getAccount(diplicateParamater, duplicateValue, leadDOB, wc.apiYearOfBirth);
                
                if(dupAccountId != null && accId == null){
                    Account acc = [SELECT Id, Date_of_Birth__c, Aadhar_Number__c, Passport_Number__c, Passport_File_Number__c, PAN_Number__c, Voter_ID__c, Driving_License_Number__c, CKYC_Number__c,
                                   NREG_Number__c FROM Account WHERE Id =: dupAccountId];
                    
                    cpa = [SELECT Id,Name,Address_Type__c,Address_Proof__c,Address_1__c,Pin_Code__c,City__c,Taluka__c,District__c,
                           Landmark__c,State__c,Country__c,Years_In_The_Address__c,Same_as_Current_Address__c
                           FROM ContactPointAddress WHERE Account__c =: dupAccountId AND Address_Type__c = 'Current Address' ORDER BY CreatedDate DESC LIMIT 1];
                    
                    if(cpa.size() > 0){
                        Area__C  pinCode = [SELECT Id,Name FROM Area__C WHERE Id =: cpa[0].Pin_Code__c];
                        wc.leadPinCode = pinCode.Name;
                        wc.leadCurrentAddress = cpa[0].Address_1__c;
                        wc.leadLandmark = cpa[0].Landmark__c;
                    }
                    
                    accId = dupAccountId;
                    wc.leadDOB = String.valueOf(acc.Date_of_Birth__c);
                    wc.leadAadharNumber = acc.Aadhar_Number__c;
                    wc.leadPANNumber = acc.PAN_Number__c;
                    wc.leadPassportNumber = acc.Passport_Number__c;
                    wc.leadPassportFileNumber = acc.Passport_File_Number__c;
                    wc.leadVoterIdNumber = acc.Voter_ID__c;
                    wc.leadDLNumber = acc.Driving_License_Number__c;
                    wc.leadCKYCNumber = acc.CKYC_Number__c;
                    wc.leadNREGNumber = acc.NREG_Number__c;
                }   
                
                if(applicantType != CommonConstant.APPLICANT){
                    applicantId = LeadCoapplicantEmploymentController.getAccountIdFromCoApplicant(leadId);
                    if(accId != null && wc.documentSubType != 'BACK' && formAccountId != null){
                        wc.kycNameMatch = checkCoApplicantNameWithKYC(accId, wc);
                    }
                }else{
                    String updatedLeadId = leadId;
                    if (updatedLeadId.startsWith('00Q')){
                        Lead objLead = [SELECT Id, Applicant_Category__c FROM Lead WHERE Id =: leadId];
                        applicantId = LeadApplicantDetails.getCoApplicant(leadId);
                        if(objLead.Applicant_Category__c == CommonConstant.APPLICANT){
                            if(wc.documentSubType != 'BACK' && formAccountId != null){
                                wc.kycNameMatch = checkCoApplicantNameWithKYC(accId, wc);
                            }
                    }else{
                        if(accId != null && wc.documentSubType != 'BACK' && formAccountId != null){
                            wc.kycNameMatch = checkCoApplicantNameWithKYC(accId, wc);
                        }
                    }
                    }else{
                        Opportunity objLead = [SELECT Id, Applicant_Category__c FROM Opportunity WHERE Id =: leadId];
                        applicantId = LeadApplicantDetails.getCoApplicant(leadId);
                        if(objLead.Applicant_Category__c == CommonConstant.APPLICANT){
                            if(wc.documentSubType != 'BACK' && formAccountId != null){
                                wc.kycNameMatch = checkCoApplicantNameWithKYC(accId, wc);
                            }
                        }else{
                            if(accId != null && wc.documentSubType != 'BACK' && formAccountId != null){
                                wc.kycNameMatch = checkCoApplicantNameWithKYC(accId, wc);
                            }
                        }
                    }
                    /*Lead objLead = [SELECT Id, Applicant_Category__c FROM Lead WHERE Id =: leadId];
                    applicantId = LeadApplicantDetails.getCoApplicant(leadId);
                    if(objLead.Applicant_Category__c == CommonConstant.APPLICANT){
                        if(wc.documentSubType != 'BACK' && formAccountId != null){
                            wc.kycNameMatch = checkCoApplicantNameWithKYC(accId, wc);
                        }
                    }else{
                        if(accId != null && wc.documentSubType != 'BACK' && formAccountId != null){
                            wc.kycNameMatch = checkCoApplicantNameWithKYC(accId, wc);
                        }
                    }*/
                }
                
                if(wc.KYCAlreadyPresen == true){     
                    
                }else if(wc.kycNameMatch == false){
                    
                }else if(accId == applicantId && applicantId != null){
                    
                }else if(accId != dupAccountId && dupAccountId != null){
                    
                }else if(wc.apiDocumentType == CommonConstant.DOCUMENT_TYPE_AADHAR && existingAadhar != apiAadharLastFourDigit && !String.isBlank(existingAadhar)){
                    
                }else if(wc.apiDocumentType == CommonConstant.DOCUMENT_TYPE_PAN && existingPAN != wc.apiPANNumber && !String.isBlank(existingPAN)){
                    
                }else if(wc.apiDocumentType == CommonConstant.DOCUMENT_TYPE_PASSPORT && exisitngPassport != wc.apiPassportNumber && !String.isBlank(exisitngPassport)){
                    
                }else{  
                    wc.accountId = insertAndLinkDocumentToLead(base64Str, fileName, filedocType, leadId, accId, existingAadhar, wc, apiAadharLastFourDigit, diplicateParamater, applicantType,existingapplicantId);
                }
                
            } else {
                
            }
        } catch(Exception e) {
             System.debug('Exception in getDocumentOcred :: ' + e.getMessage() + '. At line no. ' + e.getLineNumber());
        }
        System.debug('accound is:'+ wc.accountId);
        //wc.apistatusCode = statusCode;
        wc.apistatusCode = 105;
        wc.apiStatus = status;
        wc.apiError = errorMessage;
        return wc;
    }
    
    /******************************************************************************************************************
    * @author           Rohit Pardeshi
    * @description      This method is used to Create record of Error Log 
    * @param        	Id leadId, Integer statusCode, String statusMessage, String request, String response
    * @return			NA
    * @date             07/06/2023   
    *******************************************************************************************************************/
    public static void createErrorLogRecord(Id leadId, Integer statusCode, String statusMessage, String request, String response) {
        try {
            Integer requestBodyLength = request.length();
            Integer responseBodyLength = response.length();
            String updatedLeadId = leadId;
            Error_log__c e = new Error_log__c();
            if (updatedLeadId.startsWith('00Q')){
                   e.Lead__c = leadId;
            }else{
                    e.Deal__c = leadId;
            }
            //e.Lead__c = leadId;
            e.Record_Type__c = CommonConstant.ERROR_LOG_RECORD_TYPE;
            if (statusCode != null) {
                e.StatusCode__c = statusCode;
            } else {
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response);
                e.StatusCode__c = Integer.valueOf(jsonResponse.get('status'));
            }
            e.Status__c = statusMessage != null ? statusMessage : '';
            e.ApiName__c = CommonConstant.ERROR_LOG_API_NAME;
            if (requestBodyLength < 131072) {
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
    
    /********************************************************************************************************************************************
* @author           Aasim Shaikh
* @description      This method is used to save and link ocr document to lead/ account
* @param        	List<String> base64List, String title, String filedocType, Id leadId, Id accId, String aadharNumber, 
					wrapperClass wc, String apiAadharNumber, String docName,String applicantType, String existingapplicantId
* @return			Id : Account Id
* @date             25/04/2023   
********************************************************************************************************************************************/
    public static Id insertAndLinkDocumentToLead(List<String> base64List, String title, String filedocType, Id leadId, Id accId, String aadharNumber, wrapperClass wc, String apiAadharNumber, String docName,String applicantType, String existingapplicantId) {
        List<Document_Checklist__c> finalList = new list<Document_Checklist__c>();
        try {
            String updatedLeadId = leadId;
            Co_Applicant__c coApp = new Co_Applicant__c();
            List<ContentVersion> cvList = new List<ContentVersion>();
            Account newAccount;

            if(accId == null){
                newAccount = new Account();
                newAccount.FirstName = wc.leadFirstName;
                
                if(wc.leadLastName == null ){
                    newAccount.LastName = wc.leadMiddleName;
                }else if(wc.leadLastName != null ){
                    newAccount.LastName = wc.leadLastName;
                    newAccount.MiddleName = wc.leadMiddleName;
                }
                
                if(wc.leadDOB != null){
                    newAccount.Date_of_Birth__c = Date.valueOf(wc.leadDOB.replace('/', '-')); 
                }
                if(apiAadharNumber != null){
                    newAccount.Aadhar_Number__c = 'XXXXXXXX'+apiAadharNumber;
                }
                
                newAccount.Gender__c = wc.leadGender;
                if(wc.apiPANNumber != null){
                    newAccount.PAN_Number__c = wc.apiPANNumber; 
                }
                if(wc.apiPassportNumber != null){
                    newAccount.Passport_Number__c = wc.apiPassportNumber; 
                }
                wc.newAccountCreated = true;
                insert newAccount; 
            }
            
            if(existingapplicantId == null){
                coApp.Type__c = applicantType;
                if(accId == null){
                    coApp.Account__c = newAccount.Id; 
                }else{
                    coApp.Account__c = accId;
                    coApp.Is_Existing_Customer__c = true;
                }
                
                if (updatedLeadId.startsWith('00Q')){
                   coApp.Lead__c = leadId;
                }else{
                    coApp.Deal__c = leadId;
                }
                //coApp.Lead__c = leadId;
                insert coApp;
                finalList = CreateDocumentChecklistRecords.documentCheklistmaster(leadId, coApp.Id);
                wc.applicantRecordID = coApp.Id;
            }else{
                wc.applicantRecordID = existingapplicantId;
            }

            String docFileExtension = title.substringAfterLast('.');
            if(docName == CommonConstant.PARAMETER_AADHAR){
                if(!docFileExtension.equalsIgnoreCase('jpg')) {
                    title = title.substringBeforeLast('.') + '.jpeg';
                }
            }
            
            for(String base64 : base64List) {
                ContentVersion cv = new ContentVersion();
                cv.VersionData = EncodingUtil.base64Decode(base64);               
                cv.Title = title; 
                cv.PathOnClient = title;
                if((wc.documentSubType == 'FRONT_BOTTOM' || wc.documentSubType == 'FRONT_TOP') && wc.apiDocumentType == CommonConstant.DOCUMENT_TYPE_AADHAR){
                    cv.Document_Sub_Type__c = 'Aadhar Front';
                    cv.Document_Type__c = CommonConstant.CV_DOCUMENT_TYPE_AADHAR;
                }else if(wc.documentSubType == 'BACK' && wc.apiDocumentType == CommonConstant.DOCUMENT_TYPE_AADHAR){
                    cv.Document_Sub_Type__c = 'Aadhar Back';
                    cv.Document_Type__c = CommonConstant.CV_DOCUMENT_TYPE_AADHAR;
                }else if(wc.apiDocumentType == CommonConstant.DOCUMENT_TYPE_PAN){
                    cv.Document_Sub_Type__c = 'Pan';
                    cv.Document_Type__c = CommonConstant.CV_DOCUMENT_TYPE_PAN;
                }else if(wc.documentSubType == 'FRONT' && wc.apiDocumentType == CommonConstant.DOCUMENT_TYPE_PASSPORT){
                    cv.Document_Sub_Type__c = 'Passport Front';
                    cv.Document_Type__c = CommonConstant.CV_DOCUMENT_TYPE_PASSPORT;
                }else if(wc.documentSubType == 'BACK' && wc.apiDocumentType == CommonConstant.DOCUMENT_TYPE_PASSPORT){
                    cv.Document_Sub_Type__c = 'Passport Back';
                    cv.Document_Type__c = CommonConstant.CV_DOCUMENT_TYPE_PASSPORT;
                }
                
                if(accId == null){
                    cv.Account__c = newAccount.Id;
                }else{
                    cv.Account__c = accId;
                }
           
				if (updatedLeadId.startsWith('00Q')){
                   cv.Lead__c = leadId;
                }else{
                    cv.Deal__c = leadId;
                }                
                //cv.Lead__c = leadId;
                cvList.add(cv);
            }
            insert cvList;
            /*  List<ContentDistribution> lstContentDistribution = new List<ContentDistribution>();
for(ContentVersion objContentVersion: cvList){
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
insert lstContentDistribution;*/
            // create task to call createTask method from LoanApplicationFormHelper
            if (updatedLeadId.startsWith('00Q')){
               LoanApplicationFormHelper.createTask(leadId,CommonConstant.DISPOSITION_READY_TO_APPLY);
            }
            
            
            List<ContentVersion> cvLinkList = [select ContentDocumentId, id from ContentVersion where Id =:cvList];
            List<ContentDocumentLink> contentDocumentLink = new List<ContentDocumentLink>();
            
            List<Document_Checklist__c> dcList = new List<Document_Checklist__c>();
            if(filedocType == 'AADHAAR'){
                dcList = [select id, Applicant_Name__c, Lead__c, Applicant_Type__c, Doc_Sub_Type__c,Status__c, 
                          Applicant__r.Account__c from Document_Checklist__c where 
                          (Id in:finalList OR ((Lead__c = :leadId Or Deal__c = :leadId) AND Applicant__r.Account__c = :accId))
                          AND Doc_Sub_Type__c = 'Aadhar Card'];
            }else if(filedocType == 'PAN'){
                dcList = [select id, Applicant_Name__c, Lead__c, Applicant_Type__c, Doc_Sub_Type__c,Status__c, 
                          Applicant__r.Account__c from Document_Checklist__c where 
                          (Id in:finalList OR ((Lead__c = :leadId Or Deal__c = :leadId) AND Applicant__r.Account__c = :accId))
                          AND Doc_Sub_Type__c = 'PAN Card'];
            }else if(filedocType == 'PASSPORT'){
                dcList = [select id, Applicant_Name__c, Lead__c, Applicant_Type__c, Doc_Sub_Type__c,Status__c, 
                          Applicant__r.Account__c from Document_Checklist__c where 
                          (Id in:finalList OR ((Lead__c = :leadId Or Deal__c = :leadId) AND Applicant__r.Account__c = :accId)) 
                          AND Doc_Sub_Type__c = 'Passport'];
            }

            if(dcList.size() > 0){
                updateDCLStatus(dcList);
                for(ContentVersion cvLink : cvLinkList) {
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = cvLink.ContentDocumentId;
                    cdl.LinkedEntityId = dcList[0].Id;
                    contentDocumentLink.add(cdl);
                }
            }
            
            for(ContentVersion cvLink : cvLinkList) {
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = cvLink.ContentDocumentId;
                if(accId == null){
                    cdl.LinkedEntityId = newAccount.Id;
                }else{
                    cdl.LinkedEntityId = accId;
                }
                
                contentDocumentLink.add(cdl);
            }

            if(contentDocumentLink != null && contentDocumentLink.size() > 0){
                insert contentDocumentLink;
            }
            List<ContentDistribution> lstContentDistribution = new List<ContentDistribution>();
            for(ContentVersion objContentVersion: cvList){
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
            
            if (accId == null) {
                return newAccount.Id;
            } else {
                return accId;
            }
            
        } catch(Exception err) {
            System.debug('Exception in insertAndLinkDocumentToLead:: ' + err.getMessage() + '. At line no.-' + err.getLineNumber());
            return null;
        }
    }

    /******************************************************************************************************************
    * @author           Dhanashri Pimplapure
    * @description      This method is used to Create record of Error Log 
    * @param        	List<Document_Checklist__c> dclList : List of Document Checklist
    * @return			NA
    * @date             15/06/2023   
    *******************************************************************************************************************/
    public static void updateDCLStatus(List<Document_Checklist__c> dclList){
        list<Document_Checklist__c> dcRecordList = [Select id, Status__c from Document_Checklist__c where
                                                    ID IN : dclList];
        list<Document_Checklist__c> fianlDclList = new list<Document_Checklist__c>();
        if(dcRecordList != null && dcRecordList.size() > 0){
            for(Document_Checklist__c dcl : dcRecordList){
                dcl.Status__c = 'Uploaded';
                fianlDclList.add(dcl);
            }
        }
        if(fianlDclList != null && fianlDclList.size() > 0){
            Update fianlDclList;
        }
    }
    
    /******************************************************************************************************************
    * @author           Aasim Shaikh
    * @description      This method is used to deserialise kyc ocr api response and store required fields
    * @param        	List<Map<String, Object>> documentListMap, String leadId, String accId
    * @return			wrapperClass
    * @date             21/04/2023   
    *******************************************************************************************************************/
    public static wrapperClass populateDataFromKyc(List<Map<String, Object>> documentListMap, String leadId, String accId) {
        system.debug('Populate ');
        String gender = null;
        String name = null;
        String aadharMaskedNo = null;
        String panNo = null;
        String passportNo = null;
        String dateOfBirth = null;
        String surname = null;
        String fullAddress = null;
        String apiyob = null;
         
        wrapperClass wc = new wrapperClass();
        
        try{
        for(Map<String, Object> docMap : documentListMap) {
            
            String documentType = docMap.get('documentType').toString();
            wc.documentSubType = docMap.get('subType').toString();
            wc.apiDocumentType = documentType;
            
            Map<String, Object> additionalDetails = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(docMap.get('additionalDetails')));            
            Map<String, Object> ocrData = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(docMap.get('ocrData')));             
            Map<String, Object> addressSplit = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(additionalDetails.get('addressSplit')));
            Map<String, Object> careOfDetails = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(additionalDetails.get('careOfDetails')));
            
            if(documentType == CommonConstant.DOCUMENT_TYPE_AADHAR) {  
                Map<String, Object> aadharMasked = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(ocrData.get('aadhaar'))); 
                Map<String, Object> genderObj = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(ocrData.get('gender'))); 
                Map<String, Object> nameObj = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(ocrData.get('name')));
                Map<String, Object> dateOfBirthObj = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(ocrData.get('dob')));
                Map<String, Object> fullAddressObj = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(ocrData.get('address')));
                Map<String, Object> yob = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(ocrData.get('yob')));
                
                fullAddress = fullAddressObj != null ? fullAddressObj.get('value').toString() : '';
                if(!String.isEmpty(fullAddress)) {
                    Integer fullAddressLength = fullAddress.length();
                    if (fullAddressLength < 255) {
                        wc.leadCurrentAddress = fullAddress;
                    }else{
                        wc.leadCurrentAddress = fullAddress.substring(0, 255);
                    }
                    //wc.leadCurrentAddress = fullAddress;
                }
                
                aadharMaskedNo = aadharMasked != null ? aadharMasked.get('value').toString() : '';
                if(!String.isEmpty(aadharMaskedNo)) {
                    wc.leadAadharNumber = aadharMaskedNo;
                }
                
                gender = genderObj != null ? genderObj.get('value').toString() : '';
                if(!String.isEmpty(gender)) {
                    if(gender == 'MALE' || gender == 'Male'){
                        wc.leadGender = 'Male';
                    }else if(gender == 'FEMALE' || gender == 'Female'){
                        wc.leadGender = 'Female';
                    }
                }
                
                name = nameObj != null ? nameObj.get('value').toString() : '';
                if(!String.isBlank(name)) {
                    
                    // Split the name into an array of individual names
                    String[] nameParts = name.split(' ');
                    
                    String firstName = '';
                    String middleName = '';
                    String lastName = '';
                    
                    if (nameParts.size() > 0) {
                        firstName = nameParts[0];
                        wc.leadFirstName = firstName;
                    }
                    
                    if (nameParts.size() > 1) {
                        middleName = nameParts[1];
                        wc.leadMiddleName = middleName;
                    }
                    
                    if (nameParts.size() > 2) {
                        lastName = nameParts[2];
                        wc.leadLastName = lastName;
                    }
                }
                
                apiyob = yob != null ? yob.get('value').toString() : '';
                if(!String.isBlank(apiyob)){
                    wc.apiYearOfBirth = apiyob;
                }
				List<String> dateParts = New List<String>();
                dateOfBirth = dateOfBirthObj != null ? dateOfBirthObj.get('value').toString() : '';
                if(!String.isBlank(dateOfBirth)) {
                    if (dateOfBirth.contains('/')) {
                      dateParts = dateOfBirth.split('/');  
                    }else if(dateOfBirth.contains('-')){
                      dateParts = dateOfBirth.split('-');  
                    }
                    Date dobDate = Date.newInstance(Integer.valueOf(dateParts[2]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[0]));
                    Datetime formattedDOB = Datetime.newInstance(dobDate.year(), dobDate.month(), dobDate.day());
                    wc.leadDOB = formattedDOB.format('yyyy-MM-dd');
                }
            }
            
            if(documentType == CommonConstant.DOCUMENT_TYPE_PAN) {
                Map<String, Object> panObj = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(ocrData.get('pan'))); 
                Map<String, Object> nameObj = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(ocrData.get('name'))); 
                
                panNo = panObj != null ? panObj.get('value').toString() : '';
                
                if(!String.isBlank(panNo)) {
                    wc.apiPANNumber = panNo;
                }
                
                name = nameObj != null ? nameObj.get('value').toString() : '';
                if(!String.isBlank(name)) {
                    
                    // Split the name into an array of individual names
                    String[] nameParts = name.split(' ');
                    
                    String firstName = '';
                    String middleName = '';
                    String lastName = '';
                    
                    if (nameParts.size() > 0) {
                        firstName = nameParts[0];
                        wc.leadFirstName = firstName;
                    }
                    
                    if (nameParts.size() > 1) {
                        middleName = nameParts[1];
                        wc.leadMiddleName = middleName;
                    }
                    
                    if (nameParts.size() > 2) {
                        lastName = nameParts[2];
                        wc.leadLastName = lastName;
                    }
                }              
            }
            
            if(documentType == CommonConstant.DOCUMENT_TYPE_PASSPORT) {
                Map<String, Object> passportObj = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(ocrData.get('passportNumber'))); 
                Map<String, Object> nameObj = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(ocrData.get('givenName')));
                Map<String, Object> surnameObj = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(ocrData.get('surname')));
                
                passportNo = passportObj != null ? passportObj.get('value').toString() : '';
                if(!String.isEmpty(passportNo)) {
                    //acc.Passport_Number__c = passportNo;
                    wc.apiPassportNumber = passportNo;
                }
                
                name = nameObj != null ? nameObj.get('value').toString() : '';
                
                if(!String.isBlank(name)) {
                    String[] nameParts = name.split(' ');
                    
                    String firstName = '';
                    String middleName = '';
                    
                    if (nameParts.size() > 0) {
                        firstName = nameParts[0];
                        wc.leadFirstName = firstName;
                    }
                    
                    if (nameParts.size() > 1) {
                        middleName = nameParts[1];
                        wc.leadMiddleName = middleName;
                    }
                    
                }
                
                surname = surnameObj != null ? surnameObj.get('value').toString() : '';
                
                if(!String.isBlank(surname)) {
                    wc.leadLastName = surname;
                }
                
            }
            
            if(careOfDetails != null && documentType == CommonConstant.DOCUMENT_TYPE_AADHAR) {
                if(careOfDetails.get('relation') == 'FATHER') {
                    String fatherName = careOfDetails != null ? careOfDetails.get('name').toString() : '';
                    String[] fatherNameSplit = fatherName.split(' ');
                    if(fatherNameSplit.size() > 0){
                        wc.leadFatherFirstName = fatherNameSplit[0];
                    }
                    if(fatherNameSplit.size() > 1){
                        wc.leadFatherLastName = fatherNameSplit[1];
                    }
                    
                } 
            }
            
            if(addressSplit != null && documentType == CommonConstant.DOCUMENT_TYPE_AADHAR) {
                //wc.leadCurrentAddress = addressSplit.get('building').toString();
                wc.leadPinCode = addressSplit.get('pin').toString();
                wc.leadLandmark = addressSplit.get('landmark').toString();
                //wc.leadhouse = addressSplit.get('house').toString();
            }           
        }
        }catch(Exception err) {
            System.debug('Getting Error While Populating:: ' + err.getMessage() + '. At line no.-' + err.getLineNumber());
            return null;
        }
        return wc;
    }
    
/*******************************************************************************************************************************************
* @author          Rohit Pardeshi
* @description     This Method is use get duplicate account with respective parameters like Aadhar Number, PAN Number, Passport Number
* @param           String duplicateParameter --> Paramater used to get duplicate account
				   string duplicateValue --> Value as per duplicate paramater to get duplicate account
				   Date matchDOB --> Date of birth used to when duplicate paramater is Aadhar Number    
* @return          Id --> Duplicate account Id                 
* @date            06-06-2023   
*********************************************************************************************************************************************/
    @AuraEnabled
    public static Id getAccount(String duplicateParameter, string duplicateValue, Date matchDOB, String yearOfBirth){
        Id accountId;
        List<Account> acc = new List<Account>();
        
        if(duplicateParameter == CommonConstant.PARAMETER_AADHAR){
            if(matchDOB != null){
                acc = [SELECT Id, Aadhar_Number__c FROM Account WHERE Aadhar_Number__c =:duplicateValue AND Date_of_Birth__c =:matchDOB AND Aadhar_Number__c != null AND Date_of_Birth__c != null ORDER by createdDate DESC LIMIT 1];
                if(!acc.isEmpty()){
                    accountId = acc[0].Id;
                }
            }else if(yearOfBirth != null){
                acc = [SELECT Id, Aadhar_Number__c,Date_of_Birth__c FROM Account WHERE Aadhar_Number__c =:duplicateValue AND Aadhar_Number__c != null AND Date_of_Birth__c != null];
                for (Account account : acc) {
                    Date dob = account.Date_of_Birth__c;
                    if (dob != null) {
                        String year = String.valueOf(dob.year());
                        if (year == yearOfBirth) {
                            accountId = account.Id;
                            break;
                        }
                    }
                }
            }
            
        }else if(duplicateParameter == CommonConstant.PARAMETER_PAN){
            acc = [SELECT Id, PAN_Number__c FROM Account WHERE PAN_Number__c =:duplicateValue AND  PAN_Number__c != null ORDER by createdDate DESC LIMIT 1];
            if(!acc.isEmpty()){
                    accountId = acc[0].Id;
                }
        }else if(duplicateParameter == CommonConstant.PARAMETER_PASSPORT){
            acc = [SELECT Id, Passport_Number__c FROM Account WHERE Passport_Number__c =:duplicateValue AND Passport_Number__c != null ORDER by createdDate DESC LIMIT 1];
            if(!acc.isEmpty()){
                    accountId = acc[0].Id;
                }
        }

        return accountId;
    }
    
    /*******************************************************************************************************************************************
* @author          Rohit Pardeshi
* @description     This Method is use override the KYC ContentVersion document
* @param           String Title --> Title of Document from getting from leadApplicantDetails LWC Component
Id leadId --> It is used to delete record of that Account
wrapperClass wc --> It is the response from OCR API. Used to refere the documentSubType  
Id accId --> It is used to delete record of that Account
* @return                               
* @date            06-06-2023   
*********************************************************************************************************************************************/
    /*public static void deleteContentVersionRecord(String Title, Id leadId, wrapperClass wc, Id accId){
List<ContentDocumentLink> contentDocumentLinksAccountListToDelete = new List<ContentDocumentLink>();
List<ContentDocument> deleteContentDoc = new List<ContentDocument>();
String documentSubType;

if(wc.documentSubType != null){
if((wc.documentSubType == 'FRONT_BOTTOM' || wc.documentSubType == 'FRONT_TOP') && wc.apiDocumentType == CommonConstant.DOCUMENT_TYPE_AADHAR){
documentSubType = 'Aadhar Front';
}else if(wc.documentSubType == 'BACK' && wc.apiDocumentType == CommonConstant.DOCUMENT_TYPE_AADHAR){
documentSubType = 'Aadhar Back';
}else if(wc.apiDocumentType == CommonConstant.DOCUMENT_TYPE_PAN){
documentSubType = 'Pan';
}else if(wc.documentSubType == 'FRONT' && wc.apiDocumentType == CommonConstant.DOCUMENT_TYPE_PASSPORT){
documentSubType = 'Passport Front';
}else if(wc.documentSubType == 'BACK' && wc.apiDocumentType == CommonConstant.DOCUMENT_TYPE_PASSPORT){
documentSubType = 'Passport Back';
}
}

String documentTitle = Title.split('\\.')[0];

List<String> docName = new List<String>{documentTitle+'.pdf', documentTitle+'.jpg', documentTitle+'.jpeg', documentTitle+'.png'};

if(accId != null){
contentDocumentLinksAccountListToDelete = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:accId];

set<Id> contentDocId = new set<Id>();                                    
for(ContentDocumentLink objCon: contentDocumentLinksAccountListToDelete){
contentDocId.add(objCon.ContentDocumentId);
}

List<ContentVersion> contentVersionList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :contentDocId AND 
Document_Sub_Type__c =: documentSubType];

Set<Id> contentDocumentLinkIdsToDelete = new Set<Id>();
for (ContentVersion cv : contentVersionList) {
contentDocumentLinkIdsToDelete.add(cv.ContentDocumentId);
}

deleteContentDoc = [SELECT Id FROM ContentDocument WHERE Id IN: contentDocumentLinkIdsToDelete];          
}
try{
if(!deleteContentDoc.isEmpty()){
delete deleteContentDoc;
system.debug('RECORD DELETED SUCCESSFULLY');
}
}
catch (Exception e) {
System.debug('Exception occured deleting the record' +e.getMessage());
}   
}*/
    
    /*******************************************************************************************************************************************
* @author          Rohit Pardeshi
* @description     This Method is use check the Name of the KYC Documents and verify that document which are uploding are of same person
* @param           Id leadId --> Getting from leadApplicantDetails LWC Component
wrapperClass wc --> It is the response from OCR API          
* @return          Boolean --> Returns true if Applicant Names are matching with KYC Document                    
* @date            06-06-2023   
*********************************************************************************************************************************************/
    /*public static Boolean checkNameWithKYC(Id leadId, wrapperClass wc){
try {
List<Lead> leadList = [SELECT FirstName, MiddleName, LastName FROM Lead WHERE Id = :leadId];
system.debug('leadList' + leadList);

List<String> kycNameList = new List<String>();
if(wc.leadFirstName != null){
kycNameList.add(wc.leadFirstName.toLowerCase());
}
if(wc.leadMiddleName != null){
kycNameList.add(wc.leadMiddleName.toLowerCase());
}
if(wc.leadLastName != null){
kycNameList.add(wc.leadLastName.toLowerCase());
}

system.debug('kycNameList=>' +kycNameList);   
List<String> lowerCaseLeadList = new List<String>();
for (Lead lead : leadList) {
if(lead.FirstName != null){
String[] firstNameParts = lead.FirstName.split(' ');
for (String part : firstNameParts) {
lowerCaseLeadList.add(part.toLowerCase());
}
}
if(lead.MiddleName != null){
String[] middleNameParts = lead.MiddleName.split(' ');
for (String part : middleNameParts) {
lowerCaseLeadList.add(part.toLowerCase());
}
}
if(lead.LastName != null){
String[] lastNameParts = lead.LastName.split(' ');
for (String part : lastNameParts) {
lowerCaseLeadList.add(part.toLowerCase());
}
}
}

Integer matches = 0;
for (String kycName : kycNameList) {
if (lowerCaseLeadList.contains(kycName)) {
matches++;
if (matches >= 2) {
return true;
}
}
}
return false;
} catch (Exception ex) {
System.debug('An exception occurred: ' + ex.getMessage());
return false;
}
}*/
    
/*******************************************************************************************************************************************
* @author          Rohit Pardeshi
* @description     This Method is use update the KYC value like Aadhar, PAN & Passport while uploading respective Documents
* @param           Id accountId --> Getting from leadCoApplicantGuarantor LWC Component
				   String docType --> Getting from leadCoApplicantGuarantor/leadApplicantDetails LWC Component
				   String value --> Getting from leadCoApplicantGuarantor/leadApplicantDetails LWC Component
* @return          NA                    
* @date            06-06-2023   
*********************************************************************************************************************************************/
    @AuraEnabled
    public static void updateKYCAccount(Id accountId, String docType, String value){
        try {
            Account objAccount = [SELECT Id FROM Account WHERE Id = :accountId];
            
            if (docType == CommonConstant.DOCUMENT_TYPE_AADHAR) {
                objAccount.Aadhar_Number__c = value;
            } else if (docType == CommonConstant.DOCUMENT_TYPE_PAN) {
                objAccount.PAN_Number__c = value;
            } else if (docType == CommonConstant.DOCUMENT_TYPE_PASSPORT) {
                objAccount.Passport_Number__c = value;
            }
            update objAccount;
            
        } catch (Exception e) {
            System.debug('Exception occurred: ' + e.getMessage());
        }
    }
    
/*******************************************************************************************************************************************
* @author          Rohit Pardeshi
* @description     This Method is use check the Name of the KYC Documents and verify that document which are uploding are of same person
* @param           Id accId --> Getting from leadCoApplicantGuarantor LWC Component
				   wrapperClass wc --> It is the response from OCR API          
* @return          Boolean --> Returns true if Co-applicant/Gurantor Names are matching                      
* @date            06-06-2023   
*********************************************************************************************************************************************/
    public static Boolean checkCoApplicantNameWithKYC(Id accId, wrapperClass wc){
        try {
            List<Account> accList = [SELECT FirstName, MiddleName, LastName FROM Account WHERE Id = :accId];   
            
            List<String> kycNameList = new List<String>();
            if(wc.leadFirstName != null){
                kycNameList.add(wc.leadFirstName.toLowerCase());
            }
            if(wc.leadMiddleName != null){
                kycNameList.add(wc.leadMiddleName.toLowerCase());
            }
            if(wc.leadLastName != null){
                kycNameList.add(wc.leadLastName.toLowerCase());
            }

            List<String> lowerCaseAccountList = new List<String>();
            for (Account objacc : accList) {
                if(objacc.FirstName != null){
                    String[] firstNameParts = objacc.FirstName.split(' ');
                    for (String part : firstNameParts) {
                        lowerCaseAccountList.add(part.toLowerCase());
                    }
                }
                if(objacc.MiddleName != null){
                    String[] middleNameParts = objacc.MiddleName.split(' ');
                    for (String part : middleNameParts) {
                        lowerCaseAccountList.add(part.toLowerCase());
                    }
                }
                if(objacc.LastName != null){
                    String[] lastNameParts = objacc.LastName.split(' ');
                    for (String part : lastNameParts) {
                        lowerCaseAccountList.add(part.toLowerCase());
                    }
                }           
            }
            
            Integer matches = 0;
            for (String kycName : kycNameList) {
                if (lowerCaseAccountList.contains(kycName)) {
                    matches++;
                    if (matches >= 1) {
                        return true;
                    }
                }
            }
            return false;
        } catch (Exception ex) {
            System.debug('An exception occurred: ' + ex.getMessage());
            return false;
             
        }
    }
    
    /*******************************************************************************************************************************************
* @author          Rohit Pardeshi
* @description     This Method is use check KYC details are already in listOfAccounts in leadCoapplicantGurantor LWC Component
* @param           List<wrapperForApplicant> coApplicantData --> Getting from leadCoApplicantGuarantor LWC Component
				   String duplicateParameter --> Paramater used to get duplicate account
				   String duplicateValue --> Value as per duplicate paramater to get duplicate account, Id accId --> Account Id
* @return          Boolean --> Returns true if KYC details are already in listOfAccounts                 
* @date            08-06-2023   
*********************************************************************************************************************************************/
    public static Boolean checkKYCAlreadyPresent(List<wrapperForApplicant> coApplicantData, String duplicateParameter, String duplicateValue, Id accId) {
        try {
            String aadharNumber;
            String lastFourDigits;
            String dupAadharLastFourDigits;
            
            for(wrapperForApplicant co : coApplicantData) {
                if(co.objeAcc != null) {
                    if(String.isNotBlank(co.objeAcc.Aadhar_Number__c) && duplicateParameter == CommonConstant.PARAMETER_AADHAR && co.objeAcc.Id != accId) {
                        aadharNumber = co.objeAcc.Aadhar_Number__c;
                        lastFourDigits = aadharNumber.substring(aadharNumber.length() - 4, aadharNumber.length());
                        dupAadharLastFourDigits = duplicateValue.substring(duplicateValue.length() - 4, duplicateValue.length());
                        
                        if(lastFourDigits == dupAadharLastFourDigits) {
                            return true;
                        }
                    } else if(String.isNotBlank(co.objeAcc.PAN_Number__c) && duplicateParameter == CommonConstant.PARAMETER_PAN && co.objeAcc.Id != accId) {
                        if(co.objeAcc.PAN_Number__c == duplicateValue) {
                            return true;
                        }
                    } else if(String.isNotBlank(co.objeAcc.Passport_Number__c) && duplicateParameter == CommonConstant.PARAMETER_PASSPORT && co.objeAcc.Id != accId) {
                        if(co.objeAcc.Passport_Number__c == duplicateValue) {
                            return true;
                        }
                    }
                }
            }
        }catch (Exception e) {
            System.debug('An error occurred: ' + e.getMessage());
        }
        return false;
    }
    
    public class wrapperClass{   
        @AuraEnabled
        public String leadGender{get;set;}
        @AuraEnabled
        public String leadAadharNumber{get;set;}
        @AuraEnabled
        public String leadName{get;set;}
        @AuraEnabled
        public String leadDOB{get;set;}
        @AuraEnabled
        public String leadFatherFirstName{get;set;}
        @AuraEnabled
        public String leadFatherLastName{get;set;}
        @AuraEnabled
        public String leadMotherName{get;set;}
        @AuraEnabled
        public String leadCurrentAddress{get;set;} 
        @AuraEnabled
        public String leadPinCode{get;set;}
        @AuraEnabled
        public String leadLandmark{get;set;}
        @AuraEnabled
        public Integer apistatusCode{get;set;}
        @AuraEnabled
        public String leadhouse{get;set;}
        @AuraEnabled
        public String leadFirstName{get;set;}
        @AuraEnabled
        public String leadMiddleName{get;set;}
        @AuraEnabled
        public String leadLastName{get;set;}
        @AuraEnabled
        public String apiDocumentType{get;set;}
        @AuraEnabled
        public Id accountId{get;set;}
        @AuraEnabled
        public String leadPANNumber{get;set;}
        @AuraEnabled
        public String leadPassportNumber{get;set;}
        @AuraEnabled
        public String leadPassportFileNumber{get;set;}
        @AuraEnabled
        public String leadVoterIdNumber{get;set;}
        @AuraEnabled
        public String leadDLNumber{get;set;}
        @AuraEnabled
        public String leadCKYCNumber{get;set;}
        @AuraEnabled
        public String leadNREGNumber{get;set;}
        @AuraEnabled
        public String apiPANNumber{get;set;}
        @AuraEnabled
        public String apiVoterNumber{get;set;}
        @AuraEnabled
        public String apiPassportNumber{get;set;}
        @AuraEnabled
        public String apiDLNumber{get;set;}
        @AuraEnabled
        public String documentSubType{get;set;}  
        @AuraEnabled
        public Boolean newAccountCreated{get;set;}
        @AuraEnabled
        public Boolean kycNameMatch{get;set;}
        @AuraEnabled
        public String applicantRecordID{get;set;}
        @AuraEnabled
        public Boolean kycAlreadyPresen{get;set;}
        @AuraEnabled
        public Integer apiStatus{get;set;}
        @AuraEnabled
        public String apiError{get;set;}
        @AuraEnabled
        public String apiYearOfBirth{get;set;}
    }
    
    public class wrapperForApplicant{           
        @AuraEnabled
        public Account objeAcc{get;set;}
    }
}