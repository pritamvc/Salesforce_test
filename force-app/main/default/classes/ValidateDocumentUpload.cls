public class ValidateDocumentUpload {
    @auraEnabled
    public static String validateDocuments(string leadRecordId){
        system.debug('leadRecordId==>'+leadRecordId);  
        List<Co_Applicant__c> applicantList = new List<Co_Applicant__c>();
        List<Document_Checklist__c> dcList = new List<Document_Checklist__c>();
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        List<Education_Details__c> educationList = new list<Education_Details__c>();
        List<Bank_Details__c> bankDetailList = new  List<Bank_Details__c>();
        map<id, id> idOfdclVsContentDocId = new map<id, id>();
        map<id, List<string>> educationDetailsMap = new map<id, List<string>>();
        map<id, string> bankDetailsMap = new map<id, string>();
        List<String> finalErrorMessage = new List<String>();        
        List<Account> accList = new List<Account>();
        List<Document_Checklist__c> updateDcList = new List<Document_Checklist__c>();
        List<Document_Checklist__c> finalupdateDcList = new List<Document_Checklist__c>();
        List<Employment_Details__c> empDetailList = New List<Employment_Details__c>();
        Map<Id, string> empDetailsMap = New Map<Id, string>();
        
        set<id> dcIdSet = new set<id>();
        dcList = [select id, Name, Applicant__c,Applicant__r.Is_Income_Considered_Financial__c, Lead__c, Applicant_Name__c, Doc_Sub_Type__c, Applicant_Type__c, Document_Type__c, 
                  Applicant__r.Account__r.Name, Applicant__r.Account__c, Applicant__r.Account__r.Aadhar_Number__c,
                  Applicant__r.Account__r.PAN_Number__c, Applicant__r.Account__r.Passport_Number__c, Lead__r.Language_Test_Score__c,Lead__r.Analytics_Test_Score__c,
                  Applicant__r.Account__r.Driving_License_Number__c, Applicant__r.Account__r.Voter_ID__c from Document_Checklist__c where Lead__c = :leadRecordId];
        
        educationList = [select id, Account__c, Account__r.Name, Lead__c, Education_Qualification__c, Course_Name__c from
                         Education_Details__c where Lead__c = :leadRecordId];
        
        if(educationList != null && educationList.size() > 0){
            for(Education_Details__c ed :educationList){
                if(educationDetailsMap.get(ed.Account__c) == null){
                    educationDetailsMap.put(ed.Account__c, new List<String>{ed.Education_Qualification__c});
                }else{
                    educationDetailsMap.get(ed.Account__c).add(ed.Education_Qualification__c);
                }
            }
        }
        //Added By dhanashri
        bankDetailList = [select id,Account__c,Lead__c,Name_of_Bank__c,Account_Number__c,Account_Type__c from Bank_Details__c where
                          Lead__c=:leadRecordId];
        
        if(bankDetailList != null && bankDetailList.size() > 0){
            for(Bank_Details__c bd : bankDetailList){
                
                bankDetailsMap.put(bd.Account__c, bd.Account_Number__c);
                
                
            }
            system.debug('bankDetailsMap::'+bankDetailsMap);
        }
        // End //

        //Added By Rohit 09082023
        empDetailList = [SELECT Id, Account__c, Employment_Type__c FROM Employment_Details__c WHERE
                          Lead__c=:leadRecordId];

        if(empDetailList != null && empDetailList.size() > 0){
            for(Employment_Details__c empObj : empDetailList){
                empDetailsMap.put(empObj.Account__c, empObj.Employment_Type__c);
            }
            system.debug('empDetailsMap::'+empDetailsMap);
        }
        //End//                  
        system.debug('educationDetailsMap==>'+educationDetailsMap);
        if(dcList != null && dcList.size() > 0){
            for(Document_Checklist__c dc :dcList){
                dcIdSet.add(dc.id);
            }
        }
        if(dcIdSet != null){
            cdlList = [SELECT ContentDocumentId,LinkedEntityId,ContentDocument.title FROM ContentDocumentLink WHERE LinkedEntityId IN :dcIdSet];
        }
        if(cdlList != null && cdlList.size() > 0){
            for(ContentDocumentLink cdl :cdlList){
                idOfdclVsContentDocId.put(cdl.LinkedEntityId , cdl.ContentDocumentId);
            }
        }
        string errorMessage = 'Please upload';
        map<string, string> apptypeVsErrorMessageMap = new map<string, string>(); 
        for(Document_Checklist__c dcl :dcList){            
            if(dcl.Doc_Sub_Type__c == 'Aadhar Card' && dcl.Applicant__r.Account__r.Aadhar_Number__c != null &&
               idOfdclVsContentDocId.get(dcl.id) == null){
                   string error = apptypeVsErrorMessageMap.get(dcl.Applicant_Type__c);
                   error = error == null ? errorMessage : error;               
                   error = error+' '+dcl.Doc_Sub_Type__c +' '+'for'+' '+ dcl.Applicant_Name__c+',';
                   apptypeVsErrorMessageMap.put(dcl.Applicant_Type__c, error);
                   system.debug('apptypeVsErrorMessageMap==  '+apptypeVsErrorMessageMap);
               }else if(dcl.Doc_Sub_Type__c == 'Aadhar Card' && dcl.Applicant__r.Account__r.Aadhar_Number__c == null &&
                        idOfdclVsContentDocId.get(dcl.id) == null){
                            dcl.Status__c = 'Not Required';
                            updateDcList.add(dcl);
                            system.debug('updateDcList'+updateDcList);
                            
                        }
            if(dcl.Doc_Sub_Type__c == 'Photo' &&  idOfdclVsContentDocId.get(dcl.id) == null){
                string error = apptypeVsErrorMessageMap.get(dcl.Applicant_Type__c);
                error = error == null ? errorMessage : error;               
                error = error+' '+dcl.Doc_Sub_Type__c +' '+'for'+' '+ dcl.Applicant_Name__c+',';
                apptypeVsErrorMessageMap.put(dcl.Applicant_Type__c, error);
            }
            if(dcl.Doc_Sub_Type__c == 'Email Consent' &&  idOfdclVsContentDocId.get(dcl.id) == null){
                string error = apptypeVsErrorMessageMap.get(dcl.Applicant_Type__c);
                error = error == null ? errorMessage : error;               
                error = error+' '+dcl.Doc_Sub_Type__c +' '+'for'+' '+ dcl.Applicant_Name__c+',';
                apptypeVsErrorMessageMap.put(dcl.Applicant_Type__c, error);
            }
            if(dcl.Doc_Sub_Type__c == 'Language Test Score' && dcl.Lead__r.Language_Test_Score__c != null && idOfdclVsContentDocId.get(dcl.id) == null){
                string error = apptypeVsErrorMessageMap.get(dcl.Applicant_Type__c);
                error = error == null ? errorMessage : error;               
                error = error+' '+dcl.Doc_Sub_Type__c +' '+'for'+' '+ dcl.Applicant_Name__c+',';
                apptypeVsErrorMessageMap.put(dcl.Applicant_Type__c, error);
            }
            if(dcl.Doc_Sub_Type__c == 'Analytical Test Score' && dcl.Lead__r.Analytics_Test_Score__c != null && idOfdclVsContentDocId.get(dcl.id) == null){
                string error = apptypeVsErrorMessageMap.get(dcl.Applicant_Type__c);
                error = error == null ? errorMessage : error;               
                error = error+' '+dcl.Doc_Sub_Type__c +' '+'for'+' '+ dcl.Applicant_Name__c+',';
                apptypeVsErrorMessageMap.put(dcl.Applicant_Type__c, error);
            }
            if(dcl.Doc_Sub_Type__c == 'PAN Card' && dcl.Applicant__r.Account__r.PAN_Number__c != null &&
               idOfdclVsContentDocId.get(dcl.id) == null){
                   string error = apptypeVsErrorMessageMap.get(dcl.Applicant_Type__c);
                   error = error == null ? errorMessage : error;               
                   error = error+' '+dcl.Doc_Sub_Type__c +' '+'for'+' '+ dcl.Applicant_Name__c+',';
                   apptypeVsErrorMessageMap.put(dcl.Applicant_Type__c, error);
                   //errorMessage = +errorMessage+' '+dcl.Doc_Sub_Type__c +' '+'for'+' '+ dcl.Applicant_Name__c+',';
               }/*else if(dcl.Doc_Sub_Type__c == 'PAN Card' && dcl.Applicant__r.Account__r.PAN_Number__c == null &&
idOfdclVsContentDocId.get(dcl.id) == null){
dcl.Status__c = 'Not Required';
updateDcList.add(dcl);
system.debug('updateDcList'+updateDcList);

}*/
            if(dcl.Doc_Sub_Type__c == 'Passport' && dcl.Applicant__r.Account__r.Passport_Number__c != null &&
               idOfdclVsContentDocId.get(dcl.id) == null){
                   string error = apptypeVsErrorMessageMap.get(dcl.Applicant_Type__c);
                   error = error == null ? errorMessage : error;               
                   error = error+' '+dcl.Doc_Sub_Type__c +' '+'for'+' '+ dcl.Applicant_Name__c+',';
                   apptypeVsErrorMessageMap.put(dcl.Applicant_Type__c, error);
                   //errorMessage = +errorMessage+' '+dcl.Doc_Sub_Type__c +' '+'for'+' '+ dcl.Applicant_Name__c+',';
               }
            /*   else if(dcl.Doc_Sub_Type__c == 'Passport' && dcl.Applicant__r.Account__r.Passport_Number__c == null &&
idOfdclVsContentDocId.get(dcl.id) == null){
dcl.Status__c = 'Not Required';
updateDcList.add(dcl);
system.debug('updateDcList'+updateDcList);

}*/
            if(dcl.Doc_Sub_Type__c == 'Driving License' && dcl.Applicant__r.Account__r.Driving_License_Number__c != null &&
               idOfdclVsContentDocId.get(dcl.id) == null){
                   string error = apptypeVsErrorMessageMap.get(dcl.Applicant_Type__c);
                   error = error == null ? errorMessage : error;               
                   error = error+' '+dcl.Doc_Sub_Type__c +' '+'for'+' '+ dcl.Applicant_Name__c+',';
                   apptypeVsErrorMessageMap.put(dcl.Applicant_Type__c, error);
                   //  errorMessage = +errorMessage+' '+dcl.Doc_Sub_Type__c +' '+'for'+' '+ dcl.Applicant_Name__c;
               }/*else if(dcl.Doc_Sub_Type__c == 'Driving License' && dcl.Applicant__r.Account__r.Driving_License_Number__c == null &&
idOfdclVsContentDocId.get(dcl.id) == null){
dcl.Status__c = 'Not Required';
updateDcList.add(dcl);
system.debug('updateDcList'+updateDcList);

}*/
            if(dcl.Doc_Sub_Type__c == 'Voter Id' && dcl.Applicant__r.Account__r.Voter_ID__c != null &&
               idOfdclVsContentDocId.get(dcl.id) == null){
                   string error = apptypeVsErrorMessageMap.get(dcl.Applicant_Type__c);
                   error = error == null ? errorMessage : error;               
                   error = error+' '+dcl.Doc_Sub_Type__c +' '+'for'+' '+ dcl.Applicant_Name__c+',';
                   apptypeVsErrorMessageMap.put(dcl.Applicant_Type__c, error);
                   //  errorMessage = +errorMessage+' '+dcl.Doc_Sub_Type__c +' '+'for'+' '+ dcl.Applicant_Name__c;
               }/*else if(dcl.Doc_Sub_Type__c == 'Voter Id' && dcl.Applicant__r.Account__r.Voter_ID__c == null &&
idOfdclVsContentDocId.get(dcl.id) == null){
dcl.Status__c = 'Not Required';
updateDcList.add(dcl);
system.debug('updateDcList'+updateDcList);
}*/

/*
            //line added by dhanashri
            if(dcl.Doc_Sub_Type__c == 'Salary Slip' && dcl.Applicant__r.Is_Income_Considered_Financial__c == 'Yes' &&
               idOfdclVsContentDocId.get(dcl.id) == null){
                   string error = apptypeVsErrorMessageMap.get(dcl.Applicant_Type__c);
                   error = error == null ? errorMessage : error;               
                   error = error+' '+dcl.Doc_Sub_Type__c +' '+'for'+' '+ dcl.Applicant_Name__c+',';
                   apptypeVsErrorMessageMap.put(dcl.Applicant_Type__c, error);
               }*/
               
               /*else if(dcl.Doc_Sub_Type__c == 'Salary Slip' && dcl.Applicant__r.Is_Income_Considered_Financial__c == 'No' &&
idOfdclVsContentDocId.get(dcl.id) == null){
dcl.Status__c = 'Not Required';
updateDcList.add(dcl);
system.debug('updateDcList'+updateDcList);
}*/

            
                if(dcl.Doc_Sub_Type__c == 'Salary Slip' && empDetailsMap.containsKey(dcl.Applicant__r.Account__c) &&
                empDetailsMap.get(dcl.Applicant__r.Account__c) == 'SALARIED' && dcl.Applicant__r.Is_Income_Considered_Financial__c == 'Yes' &&
                idOfdclVsContentDocId.get(dcl.id) == null){
                    system.debug('Insside doc salaried conditions');
                    string error = apptypeVsErrorMessageMap.get(dcl.Applicant_Type__c);
                    error = error == null ? errorMessage : error;               
                    error = error+' '+dcl.Doc_Sub_Type__c +' '+'for'+' '+ dcl.Applicant_Name__c+',';
                    apptypeVsErrorMessageMap.put(dcl.Applicant_Type__c, error);
                } 

	
            system.debug('BEFORE BANK STATEMET');	
            if(dcl.Doc_Sub_Type__c == 'Bank Statement' && bankDetailsMap.get(dcl.Applicant__r.Account__c) != null &&
               idOfdclVsContentDocId.get(dcl.id) == null){
                   system.debug('INSIDE BANK STATEMET');
                   string error = apptypeVsErrorMessageMap.get(dcl.Applicant_Type__c);
                   error = error == null ? errorMessage : error;               
                   error = error+' '+dcl.Doc_Sub_Type__c +' '+'for'+' '+ dcl.Applicant_Name__c+',';
                   apptypeVsErrorMessageMap.put(dcl.Applicant_Type__c, error);
               }/*else if(dcl.Doc_Sub_Type__c == 'Bank Statement' && bankDetailsMap.get(dcl.Applicant__r.Account__c) == null &&
idOfdclVsContentDocId.get(dcl.id) == null){
dcl.Status__c = 'Not Required';
updateDcList.add(dcl);
system.debug('updateDcList'+updateDcList);
}*/
            //End //
            if(dcl.Doc_Sub_Type__c == '12th' && idOfdclVsContentDocId.get(dcl.id) == null){
                if(educationDetailsMap.containsKey(dcl.Applicant__r.Account__c)){
                    List<String> edDetailsList = educationDetailsMap.get(dcl.Applicant__r.Account__c);
                    set<string> edDetailsSet = new set<String>();
                    edDetailsSet.addall(edDetailsList);
                    system.debug('edDetailsSet==>'+edDetailsSet);
                    if(edDetailsSet.contains('12th')){
                        string error = apptypeVsErrorMessageMap.get(dcl.Applicant_Type__c);
                        error = error == null ? errorMessage : error;               
                        error = error+' '+dcl.Doc_Sub_Type__c+' '+'Certificate'+' '+'for'+' '+ dcl.Applicant_Name__c+',';
                        apptypeVsErrorMessageMap.put(dcl.Applicant_Type__c, error);
                    }
                }/*else{
dcl.Status__c = 'Not Required';
updateDcList.add(dcl);
system.debug('updateDcList'+updateDcList);
}*/
            }
            
            if(dcl.Doc_Sub_Type__c == '10th' && idOfdclVsContentDocId.get(dcl.id) == null){
                if(educationDetailsMap.containsKey(dcl.Applicant__r.Account__c)){
                    List<String> edDetailsList = educationDetailsMap.get(dcl.Applicant__r.Account__c);
                    set<string> edDetailsSet = new set<String>();
                    edDetailsSet.addall(edDetailsList);
                    system.debug('edDetailsSet==>'+edDetailsSet);
                    if(edDetailsSet.contains('10th')){
                        string error = apptypeVsErrorMessageMap.get(dcl.Applicant_Type__c);
                        error = error == null ? errorMessage : error;               
                        error = error+' '+dcl.Doc_Sub_Type__c+' '+'Certificate'+' '+'for'+' '+ dcl.Applicant_Name__c+',';
                        apptypeVsErrorMessageMap.put(dcl.Applicant_Type__c, error);
                    }
                }/*else{
dcl.Status__c = 'Not Required';
updateDcList.add(dcl);
system.debug('updateDcList'+updateDcList);
}*/
                
            }
            
            if(dcl.Doc_Sub_Type__c == 'Graduate' && idOfdclVsContentDocId.get(dcl.id) == null){
                if(educationDetailsMap.containsKey(dcl.Applicant__r.Account__c)){
                    List<String> edDetailsList = educationDetailsMap.get(dcl.Applicant__r.Account__c);
                    set<string> edDetailsSet = new set<String>();
                    edDetailsSet.addall(edDetailsList);
                    system.debug('edDetailsSet==>'+edDetailsSet);
                    if(edDetailsSet.contains('Graduate')){
                        string error = apptypeVsErrorMessageMap.get(dcl.Applicant_Type__c);
                        error = error == null ? errorMessage : error;               
                        error = error+' '+dcl.Doc_Sub_Type__c+' '+'Certificate'+' '+'for'+' '+ dcl.Applicant_Name__c+',';
                        apptypeVsErrorMessageMap.put(dcl.Applicant_Type__c, error);
                    }
                }/*else{
dcl.Status__c = 'Not Required';
updateDcList.add(dcl);
system.debug('updateDcList'+updateDcList);
}*/
                
            }
            
            /*  if(dcl.Doc_Sub_Type__c == 'Post Graduate' && idOfdclVsContentDocId.get(dcl.id) == null){
if(educationDetailsMap.containsKey(dcl.Applicant__r.Account__c)){
List<String> edDetailsList = educationDetailsMap.get(dcl.Applicant__r.Account__c);
set<string> edDetailsSet = new set<String>();
edDetailsSet.addall(edDetailsList);
system.debug('edDetailsSet==>'+edDetailsSet);
if(edDetailsSet.contains('Post Graduate')){
string error = apptypeVsErrorMessageMap.get(dcl.Applicant_Type__c);
error = error == null ? errorMessage : error;               
error = error+' '+dcl.Doc_Sub_Type__c+' '+'Certificate'+' '+'for'+' '+ dcl.Applicant_Name__c+',';
apptypeVsErrorMessageMap.put(dcl.Applicant_Type__c, error);
}
}else{
dcl.Status__c = 'Not Required';
updateDcList.add(dcl);
system.debug('updateDcList'+updateDcList);
}
}    */    
        }
        system.debug('updateDcList'+updateDcList);
        Update updateDcList;
        
        //   system.debug('apptypeVsErrorMessageMap==>'+apptypeVsErrorMessageMap.values()[0]);
        if(apptypeVsErrorMessageMap.values() != null && apptypeVsErrorMessageMap.size() >0 ){
            system.debug('Line 270 apptypeVsErrorMessageMap  ==  '+apptypeVsErrorMessageMap.values()[0]);
            return apptypeVsErrorMessageMap.values()[0];            
        }
        else{
            return null;
        }      
        
        
        
    }   
    
   /* @AuraEnabled
    public static String validateDocumentsUpdated(string leadRecordId){
        system.debug('leadRecordId=================== '+leadRecordId);
        String messagestr ;
        String formatForEmailBody ='Please upload below mandatory documents :'+'\n';
        map<id, id> idOfdclVsContentDocId = new map<id, id>();
        list<Document_Checklist__c> docCheckList = new list<Document_Checklist__c>();
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        set<id> dcIdSet = new set<id>();
        docCheckList =[select id,Name,Doc_Sub_Type__c,Document_Checklist__c.Applicant_Name__c,Remarks__c,Document_Checklist__c.Applicant_Type__c,Status__c,
                       Applicant__r.Account_Name__c,Applicant__r.Type__c,Document_Checklist_Master__c,Document_Checklist_Master__r.IsMandetory__c
                       from Document_Checklist__c where Document_Checklist_Master__r.IsMandetory__c ='Yes' AND (Lead__c = :leadRecordId OR Deal__c =:leadRecordId)
                       order by Applicant__r.Type__c ];
        map<String,List<Document_Checklist__c>> mapTypeVsAccountName = new  map<String,List<Document_Checklist__c>>();
        Map<String, Map<String, List<Document_Checklist__c>>> mapTypeVsMapAcountNameDocumentType = new Map<String, Map<String, List<Document_Checklist__c>>>();
        if(docCheckList != null && docCheckList.size() > 0){
            for(Document_Checklist__c dc :docCheckList){
                dcIdSet.add(dc.id);
            }
        }
        if(dcIdSet != null){
            cdlList = [SELECT ContentDocumentId,LinkedEntityId,ContentDocument.title FROM ContentDocumentLink WHERE LinkedEntityId IN :dcIdSet];
        }
        if(cdlList != null && cdlList.size() > 0){
            for(ContentDocumentLink cdl :cdlList){
                idOfdclVsContentDocId.put(cdl.LinkedEntityId , cdl.ContentDocumentId);
            }
        }
        system.debug('idOfdclVsContentDocId ===== '+ Json.serializePretty(idOfdclVsContentDocId));
        if(!docCheckList.IsEmpty() && docCheckList.size() > 0){
            for (Document_Checklist__c objectDocumentChecklist : docCheckList) {
                if(idOfdclVsContentDocId.get(objectDocumentChecklist.id) == null){
                    //for rejected document
                    // Retrieve the applicant's type and account name
                    String applicantType = objectDocumentChecklist.Applicant__r.Type__c;
                    String applicantAccountName = objectDocumentChecklist.Applicant__r.Account_Name__c;
                    
                    // Retrieve or create the inner map for the applicant type
                    if (mapTypeVsMapAcountNameDocumentType.containsKey(applicantType)) {
                        Map<String, List<Document_Checklist__c>> innerMap = mapTypeVsMapAcountNameDocumentType.get(applicantType);
                        if (!innerMap.containsKey(applicantAccountName)) {
                            innerMap.put(applicantAccountName, new List<Document_Checklist__c>());
                        }
                    } else {
                        mapTypeVsMapAcountNameDocumentType.put(applicantType, new Map<String, List<Document_Checklist__c>>{
                            applicantAccountName => new List<Document_Checklist__c>()
                                });
                    }
                    
                    // Add the document sub-type to the inner map's list
                    List<Document_Checklist__c> documentList = mapTypeVsMapAcountNameDocumentType.get(applicantType).get(applicantAccountName);
                    documentList.add(objectDocumentChecklist);
                }
            }
            // Print the nested map in the desired format
            for (String applicantType : mapTypeVsMapAcountNameDocumentType.keySet()) {
                Map<String, List<Document_Checklist__c>> innerMap = mapTypeVsMapAcountNameDocumentType.get(applicantType);
                // Print the applicant type
                formatForEmailBody = +formatForEmailBody + '     ' + applicantType+'=> '+'\n' ;
                // Print the applicant account names and document sub-types
                for (String applicantAccountName : innerMap.keySet()) {
                    formatForEmailBody =formatForEmailBody +'      '+' ' + applicantAccountName +' : '+'\n';
                    List<Document_Checklist__c> documentList = innerMap.get(applicantAccountName);
                    for (Integer i = 0; i < documentList.size(); i++) {
                        formatForEmailBody ='      ' +formatForEmailBody +'      '+' ' + (i + 1) + ') ' + documentList[i].Doc_Sub_Type__c +'\n' ;
                    } 
                } 
            }
            
        }
        system.debug(formatForEmailBody);
        messagestr = formatForEmailBody;
        return messagestr;
    }*/
}