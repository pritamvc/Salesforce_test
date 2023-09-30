/********************************************************************************************************
* @author          Kailash Bhadane
* @description     Class to get all the applicant, co-applicant and guarantor for document checklist 
* @date            25/05/2023
* @param           
* @return         
**********************************************************************************************************/ 
public with sharing class GetDocumentChecklistRecords {
    @AuraEnabled(cacheable=true)
    public static list<Document_Checklist__c> fetchChecklistRecordsForApplicant(string recordId){
        list<Document_Checklist__c> docCheckList =[select id, Applicant__r.Is_Income_Considered_Financial__c,Name,File_Size__c,File_Types__c,Document_Checklist_Master__r.IsMandetory__c ,Document_Instruction__c, Applicant__c, Lead__c, IsDocumentComplete__c, Remarks__c, Lead_Name__c, Status__c,Target_Date__c,Received_Date__c, Doc_Sub_Type__c, Applicant_Name__c, Applicant_Type__c, Document_Type__c,
                                                   			Applicant__r.Account__r.Name,Deal__c,Document_Checklist_Master__r.File_Size__c,Document_Checklist_Master__r.File_Types__c from Document_Checklist__c where Applicant__r.Type__c = :'Applicant' AND (Lead__c = :recordId OR Deal__c =:recordId) order by Document_Type__c ];
        if(docCheckList != null && docCheckList.size() > 0){
            return docCheckList;
        }else{
            return null;
        }
    }
    
    @AuraEnabled
    public static list<Document_Checklist__c> fetchChecklistRecordsForApplicantUpdated(string recordId){
        list<Document_Checklist__c> docCheckList =[select id, Applicant__r.Is_Income_Considered_Financial__c,Name,File_Size__c,File_Types__c,Document_Checklist_Master__r.IsMandetory__c ,Document_Instruction__c, Applicant__c, Lead__c, IsDocumentComplete__c, Remarks__c, Lead_Name__c, Status__c,Target_Date__c,Received_Date__c, Doc_Sub_Type__c, Applicant_Name__c, Applicant_Type__c, Document_Type__c,
                                                   				Applicant__r.Account__r.Name,Deal__c,Document_Checklist_Master__r.File_Size__c,Document_Checklist_Master__r.File_Types__c from Document_Checklist__c where Applicant__r.Type__c = :'Applicant' AND (Lead__c = :recordId OR Deal__c =:recordId) order by Document_Type__c ];
        if(docCheckList != null && docCheckList.size() > 0){
            return docCheckList;
        }else{
            return null;
        }
    }
    
    @AuraEnabled
    public static string getContentDocument(id docId){
        ContentDocumentLink contentDocumen = [SELECT ContentDocumentId, LinkedEntityId 
                                              FROM   ContentDocumentLink 
                                              WHERE  LinkedEntityId =: docId order by ContentDocument.CreatedDate desc limit 1];
        string contentDoc = contentDocumen.ContentDocumentId;
        return contentDoc;
        
    }
    @AuraEnabled(cacheable=true)
    public static wrapperClass getCoApplicant(string recordId){
        list<Account> accList = new list<Account>();
        map<id, list<Document_Checklist__c>> idVsDocCheclistMap = new map<id, list<Document_Checklist__c>>();
        map<string, list<Document_Checklist__c>> appNameVsDocCheclistMap = new map<string, list<Document_Checklist__c>>();
        map<id, string> idVsAppNameMap = new map<id, string>();
        list<Document_Checklist__c> docCheckList =[select id, Name,File_Size__c,File_Types__c,Document_Checklist_Master__r.IsMandetory__c, Document_Instruction__c, Applicant__c, Lead__c,Deal__c,IsDocumentComplete__c, Remarks__c, Lead_Name__c,
                                                   Status__c,Target_Date__c,Received_Date__c, Doc_Sub_Type__c, Applicant_Name__c, Applicant_Type__c, Document_Type__c, Applicant__r.Account__r.Name,Applicant__r.Is_Income_Considered_Financial__c,
                                                   Applicant__r.Account__c,Document_Checklist_Master__r.File_Size__c,Document_Checklist_Master__r.File_Types__c from Document_Checklist__c where Applicant__r.Type__c =:CommonConstant.COAPPLICANT AND (Lead__c = :recordId OR Deal__c =:recordId) order by Document_Type__c];
        set<id> accIdSet = new set<id>();
        wrapperClass wrapperObj;
        integer i = 1;
        if(docCheckList != null && docCheckList.size() > 0){
            for (Document_Checklist__c applicant :docCheckList){
                if(accIdSet.contains(applicant.Applicant__r.Account__c) == false){
                    Account accObj = new Account();
                    accObj.id = applicant.Applicant__r.Account__c;
                    accObj.Name = applicant.Applicant__r.Account__r.Name;
                    accIdSet.add(accObj.id);
                    accList.add(accObj);
                }
                idVsAppNameMap.put(applicant.Applicant__r.Account__c, applicant.Applicant__r.Account__r.Name);
                if(idVsDocCheclistMap.get(applicant.Applicant__r.Account__c) == null){
                    idVsDocCheclistMap.put(applicant.Applicant__r.Account__c, new list<Document_Checklist__c>
                                           {applicant});
                }else{
                    idVsDocCheclistMap.get(applicant.Applicant__r.Account__c).add(applicant);
                }
            }
            for(id appId :idVsDocCheclistMap.keySet()){
                string appName;
                if(idVsAppNameMap.containsKey(appId)){
                    appName = idVsAppNameMap.get(appId);                           
                }
                List<Document_Checklist__c> documentCheckList = idVsDocCheclistMap.get(appId);
                for(Document_Checklist__c dc :documentCheckList){
                    if(appNameVsDocCheclistMap.get(i+'.'+appName) == null){
                        
                        appNameVsDocCheclistMap.put(i+'.'+appName, new List<Document_Checklist__c>{dc});
                        
                        
                        
                    }else{
                        appNameVsDocCheclistMap.get(i+'.'+appName).add(dc);
                    }
                }
                i++;
            }
            wrapperObj = new wrapperClass(appNameVsDocCheclistMap, accList);
        }
        return wrapperObj;
    }
    
    @AuraEnabled
    public static wrapperClass getCoApplicantUpdated(string recordId){
        list<Account> accList = new list<Account>();
        map<id, list<Document_Checklist__c>> idVsDocCheclistMap = new map<id, list<Document_Checklist__c>>();
        map<string, list<Document_Checklist__c>> appNameVsDocCheclistMap = new map<string, list<Document_Checklist__c>>();
        map<id, string> idVsAppNameMap = new map<id, string>();
        list<Document_Checklist__c> docCheckList =[select id, Name,File_Size__c,File_Types__c,Document_Checklist_Master__r.IsMandetory__c, Document_Instruction__c, Applicant__c, Lead__c,Deal__c,IsDocumentComplete__c, Remarks__c, Lead_Name__c,
                                                   Status__c,Target_Date__c,Received_Date__c, Doc_Sub_Type__c, Applicant_Name__c, Applicant_Type__c, Document_Type__c, Applicant__r.Account__r.Name,Applicant__r.Is_Income_Considered_Financial__c,
                                                   Applicant__r.Account__c,Document_Checklist_Master__r.File_Size__c,Document_Checklist_Master__r.File_Types__c from Document_Checklist__c where Applicant__r.Type__c =:CommonConstant.COAPPLICANT AND (Lead__c = :recordId OR Deal__c =:recordId) order by Document_Type__c];
        set<id> accIdSet = new set<id>();
        wrapperClass wrapperObj;
        integer i = 1;
        if(docCheckList != null && docCheckList.size() > 0){
            for (Document_Checklist__c applicant :docCheckList){
                if(accIdSet.contains(applicant.Applicant__r.Account__c) == false){
                    Account accObj = new Account();
                    accObj.id = applicant.Applicant__r.Account__c;
                    accObj.Name = applicant.Applicant__r.Account__r.Name;
                    accIdSet.add(accObj.id);
                    accList.add(accObj);
                }
                idVsAppNameMap.put(applicant.Applicant__r.Account__c, applicant.Applicant__r.Account__r.Name);
                if(idVsDocCheclistMap.get(applicant.Applicant__r.Account__c) == null){
                    idVsDocCheclistMap.put(applicant.Applicant__r.Account__c, new list<Document_Checklist__c>
                                           {applicant});
                }else{
                    idVsDocCheclistMap.get(applicant.Applicant__r.Account__c).add(applicant);
                }
            }
            for(id appId :idVsDocCheclistMap.keySet()){
                string appName;
                if(idVsAppNameMap.containsKey(appId)){
                    appName = idVsAppNameMap.get(appId);                           
                }
                List<Document_Checklist__c> documentCheckList = idVsDocCheclistMap.get(appId);
                for(Document_Checklist__c dc :documentCheckList){
                    if(appNameVsDocCheclistMap.get(i+'.'+appName) == null){
                        
                        appNameVsDocCheclistMap.put(i+'.'+appName, new List<Document_Checklist__c>{dc});
                        
                    }else{
                        appNameVsDocCheclistMap.get(i+'.'+appName).add(dc);
                    }
                }
                i++;
            }
            wrapperObj = new wrapperClass(appNameVsDocCheclistMap, accList);
        }
        return wrapperObj;
    }
    public class wrapperClass{
        @AuraEnabled
        public Map<string, list<Document_Checklist__c>> appNameVsDocCheclistMap{get; set;}
        @AuraEnabled
        public list<Account> accList{get; set;}
        public wrapperClass(map<string, list<Document_Checklist__c>> appNameVsDocCheclistMap, List<Account> accList){
            this.appNameVsDocCheclistMap = appNameVsDocCheclistMap;
            this.accList = accList;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static wrapperClassForGuarantor getGuarantor(string recordId){
        list<Account> accList = new list<Account>();
        map<id, list<Document_Checklist__c>> idVsDocCheclistMap = new map<id, list<Document_Checklist__c>>();
        map<string, list<Document_Checklist__c>> guarantorNameVsDocCheclistMap = new map<string, list<Document_Checklist__c>>();
        map<id, string> idVsGuarantorNameMap = new map<id, string>();
        list<Document_Checklist__c> docCheckList =[select id, Name,File_Size__c,File_Types__c, Document_Checklist_Master__r.IsMandetory__c, Document_Instruction__c, Applicant__c, Lead__c,
                                                   IsDocumentComplete__c, Remarks__c, Lead_Name__c, Status__c,Target_Date__c,Received_Date__c,
                                                   Doc_Sub_Type__c, Applicant_Name__c, Applicant_Type__c, Document_Type__c, Applicant__r.Account__r.Name,Applicant__r.Is_Income_Considered_Financial__c, Applicant__r.Account__c,Deal__c,
                                                   Document_Checklist_Master__r.File_Size__c,Document_Checklist_Master__r.File_Types__c
                                                   from Document_Checklist__c where Applicant__r.Type__c = :'Guarantor' AND (Lead__c = :recordId OR Deal__c =:recordId) order by Document_Type__c];
        set<id> accIdSet = new set<id>();
        wrapperClassForGuarantor wrapperObj;
        integer i = 1;
        if(docCheckList != null && docCheckList.size() > 0){
            for (Document_Checklist__c applicant :docCheckList){
                if(accIdSet.contains(applicant.Applicant__r.Account__c) == false){
                    Account accObj = new Account();
                    accObj.id = applicant.Applicant__r.Account__c;
                    accObj.Name = applicant.Applicant__r.Account__r.Name;
                    accIdSet.add(accObj.id);
                    accList.add(accObj);
                }
                idVsGuarantorNameMap.put(applicant.Applicant__r.Account__c, applicant.Applicant__r.Account__r.Name);
                if(idVsDocCheclistMap.get(applicant.Applicant__r.Account__c) == null){
                    idVsDocCheclistMap.put(applicant.Applicant__r.Account__c, new list<Document_Checklist__c>
                                           {applicant});
                }else{
                    idVsDocCheclistMap.get(applicant.Applicant__r.Account__c).add(applicant);
                }
            }
            for(id appId :idVsDocCheclistMap.keySet()){
                string appName;
                if(idVsGuarantorNameMap.containsKey(appId)){
                    appName = idVsGuarantorNameMap.get(appId);                           
                }
                List<Document_Checklist__c> documentCheckList = idVsDocCheclistMap.get(appId);
                for(Document_Checklist__c dc :documentCheckList){
                    if(guarantorNameVsDocCheclistMap.get(i+'.'+appName) == null){
                        
                        guarantorNameVsDocCheclistMap.put(i+'.'+appName, new List<Document_Checklist__c>{dc});
                        
                    }
                    
                    else{
                        guarantorNameVsDocCheclistMap.get(i+'.'+appName).add(dc);
                    }
                }
                i++;
            }
            wrapperObj = new wrapperClassForGuarantor(guarantorNameVsDocCheclistMap, accList);
        }
        return wrapperObj;
    }
    
    @AuraEnabled
    public static wrapperClassForGuarantor getGuarantorUpdated(string recordId){
        list<Account> accList = new list<Account>();
        map<id, list<Document_Checklist__c>> idVsDocCheclistMap = new map<id, list<Document_Checklist__c>>();
        map<string, list<Document_Checklist__c>> guarantorNameVsDocCheclistMap = new map<string, list<Document_Checklist__c>>();
        map<id, string> idVsGuarantorNameMap = new map<id, string>();
        list<Document_Checklist__c> docCheckList =[select id, Name,File_Size__c,File_Types__c, Document_Checklist_Master__r.IsMandetory__c, Document_Instruction__c, Applicant__c, Lead__c,
                                                   IsDocumentComplete__c, Remarks__c, Lead_Name__c, Status__c,Target_Date__c,Received_Date__c,Applicant__r.Is_Income_Considered_Financial__c,
                                                   Doc_Sub_Type__c, Applicant_Name__c, Applicant_Type__c, Document_Type__c, Applicant__r.Account__r.Name, Applicant__r.Account__c,Deal__c,Document_Checklist_Master__r.File_Size__c,
                                                   Document_Checklist_Master__r.File_Types__c
                                                   from Document_Checklist__c where Applicant__r.Type__c = :'Guarantor' AND (Lead__c = :recordId OR Deal__c =:recordId) order by Document_Type__c];
        set<id> accIdSet = new set<id>();
        wrapperClassForGuarantor wrapperObj;
        integer i = 1;
        if(docCheckList != null && docCheckList.size() > 0){
            for (Document_Checklist__c applicant :docCheckList){
                if(accIdSet.contains(applicant.Applicant__r.Account__c) == false){
                    Account accObj = new Account();
                    accObj.id = applicant.Applicant__r.Account__c;
                    accObj.Name = applicant.Applicant__r.Account__r.Name;
                    accIdSet.add(accObj.id);
                    accList.add(accObj);
                }
                idVsGuarantorNameMap.put(applicant.Applicant__r.Account__c, applicant.Applicant__r.Account__r.Name);
                if(idVsDocCheclistMap.get(applicant.Applicant__r.Account__c) == null){
                    idVsDocCheclistMap.put(applicant.Applicant__r.Account__c, new list<Document_Checklist__c>
                                           {applicant});
                }else{
                    idVsDocCheclistMap.get(applicant.Applicant__r.Account__c).add(applicant);
                }
            }
            for(id appId :idVsDocCheclistMap.keySet()){
                string appName;
                if(idVsGuarantorNameMap.containsKey(appId)){
                    appName = idVsGuarantorNameMap.get(appId);                           
                }
                List<Document_Checklist__c> documentCheckList = idVsDocCheclistMap.get(appId);
                for(Document_Checklist__c dc :documentCheckList){
                    if(guarantorNameVsDocCheclistMap.get(i+'.'+appName) == null){
                        
                        guarantorNameVsDocCheclistMap.put(i+'.'+appName, new List<Document_Checklist__c>{dc});
                        
                    }else{
                        guarantorNameVsDocCheclistMap.get(i+'.'+appName).add(dc);
                    }
                }
                i++;
            }
            wrapperObj = new wrapperClassForGuarantor(guarantorNameVsDocCheclistMap, accList);
        }
        return wrapperObj;
    }
    public class wrapperClassForGuarantor{
        @AuraEnabled
        public Map<string, list<Document_Checklist__c>> guarantorNameVsDocCheclistMap{get; set;}
        @AuraEnabled
        public list<Account> accList{get; set;}
        public wrapperClassForGuarantor(map<string, list<Document_Checklist__c>> guarantorNameVsDocCheclistMap, List<Account> accList){
            this.guarantorNameVsDocCheclistMap = guarantorNameVsDocCheclistMap;
            this.accList = accList;
        }
    }
    
    @AuraEnabled
    public static void updateStatusOnDocChecklist(string recordId){
        List<Document_Checklist__c> docList =[select id, Status__c, IsDocumentComplete__c,Deal__c
                                              from Document_Checklist__c where id = :recordId];
        List<Document_Checklist__c> docListToUpdate = new List<Document_Checklist__c>();
        for(Document_Checklist__c dc :docList){
            dc.Status__c = 'Pending';
            dc.IsDocumentComplete__c = false;
            docListToUpdate.add(dc);
        }
        update docListToUpdate;
    }
    
    @AuraEnabled
    public static void updateDockChecklist(List<String> docIdList){
        List<Document_Checklist__c> docListUpdate = new List<Document_Checklist__c>();
        List<Document_Checklist__c> docList = [select id, Status__c, Remarks__c, IsDocumentComplete__c from Document_Checklist__c where id IN :docIdList];
        if(docList != null && docList.size() > 0){
            for(Document_Checklist__c doc :docList){
                if(doc.Status__c == 'Accepted'){
                    doc.IsDocumentComplete__c = true;
                    doc.Remarks__c = null;
                    docListUpdate.add(doc);
                }else if(doc.Status__c == 'Pending'){
                    doc.IsDocumentComplete__c = false;
                    doc.Remarks__c = null;
                    docListUpdate.add(doc);
                }else if(doc.Status__c == 'Rejected'){
                    doc.IsDocumentComplete__c = false;
                    docListUpdate.add(doc);
                }     
            }
        }
        if(docListUpdate != null && docListUpdate.size() > 0){
            update docListUpdate;
        }
        
        
    }   
    
    @AuraEnabled
    public static Boolean getSalesProfile(){ 
        List<User> userlst = new List<User>();
        userlst = [select id, profile.name from user where profileId =: UserInfo.getProfileId()];
        Set<String> SalesalesProfileSet = new Set<String>();
         string customLablelSales = System.Label.Profiles_Sales_Names;
        SalesalesProfileSet = Utility.getSetFromString(customLablelSales);
            if(SalesalesProfileSet.contains(userlst[0].profile.name)){
            return false;
        }else{
            return true;
        }
    } 
    
    @AuraEnabled
    public static Boolean getProfileLoginDesk(){ 
        List<User> userlst = new List<User>();
        userlst = [select id, profile.name from user where profileId =: UserInfo.getProfileId()];
        if(userlst[0].profile.name == System.Label.Profile_Login_Desk || userlst[0].profile.name == System.Label.Profile_Login_Desk_Executive ){
            return true;
        }else{
            return false;
        }
    } 
    
    @AuraEnabled
    public static String sendDocumentStatusViaEmailNotification(string recordId){
        String messagestr ;
        try {
            list<Document_Checklist__c> docCheckList =[select id,Name,Doc_Sub_Type__c,Remarks__c,Status__c,Applicant__r.Account_Name__c,Applicant__r.Type__c from Document_Checklist__c where Status__c ='Rejected' AND (Lead__c = :recordId OR Deal__c =:recordId) order by Applicant__r.Type__c ];
            map<String,List<Document_Checklist__c>> mapTypeVsAccountName = new  map<String,List<Document_Checklist__c>>();
            Map<String, Map<String, List<Document_Checklist__c>>> mapTypeVsMapAcountNameDocumentType = new Map<String, Map<String, List<Document_Checklist__c>>>();
            if(!docCheckList.IsEmpty() && docCheckList.size() > 0){
                for (Document_Checklist__c objectDocumentChecklist : docCheckList) {
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
                
                String formatForEmailBody ='';
                // Print the nested map in the desired format
                for (String applicantType : mapTypeVsMapAcountNameDocumentType.keySet()) {
                    Map<String, List<Document_Checklist__c>> innerMap = mapTypeVsMapAcountNameDocumentType.get(applicantType);
                    // Print the applicant type
                    formatForEmailBody = formatForEmailBody + '<b>' + applicantType + ':</b>'+'<br>' ;
                    // Print the applicant account names and document sub-types
                    for (String applicantAccountName : innerMap.keySet()) {
                        formatForEmailBody ='      ' +formatForEmailBody +'      '+'<u>' + applicantAccountName + '</u>'+'<br>' ;
                        List<Document_Checklist__c> documentList = innerMap.get(applicantAccountName);
                        for (Integer i = 0; i < documentList.size(); i++) {
                            formatForEmailBody ='      ' +formatForEmailBody +'      '+' ' + (i + 1) + ') ' + documentList[i].Doc_Sub_Type__c +' : '+ documentList[i].Remarks__c+'<br>' ;
                        }
                    }
                }
                EmailTemplate RejectedAcceptedEmailTemp = [SELECT Id, Subject, Body, HTMLValue FROM EmailTemplate WHERE Name ='Rejected/Accepted Bulk Doc Checklist send Via Email'];
                List<Lead> objecteadlist = [select id,Name,Stage_Owner__r.Email,Stage_Owner__c, Owner.Email,Owner.Name,OwnerId from Lead where Id = : recordId];
                List<OrgWideEmailAddress> owea = [select Id from OrgWideEmailAddress WHERE Address='noreply@auxilo.com'];
                List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                List<String> SetToAddress = new List<String>();
                List<String> SetToCCAddress = new List<String>();
                List<Task> taskList = new List<Task>();
                String leadRecordLink ;
                for(Lead objlead :objecteadlist){
                    leadRecordLink = URL.getSalesforceBaseUrl().toExternalForm() + '/' + objlead.Id;
                    String Subject = RejectedAcceptedEmailTemp.Subject;
                    String body = RejectedAcceptedEmailTemp.HTMLValue;
                    String getLeadName = objlead.Owner.Name;
                    String getApplicantType = formatForEmailBody;
                    if(objlead.Owner.Email != null){
                        SetToAddress.add(objlead.Owner.Email);
                    }
                    if(objlead.Stage_Owner__r.Email != null){
                        SetToCCAddress.add(objlead.Stage_Owner__r.Email);
                    }
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setSubject(RejectedAcceptedEmailTemp.Subject);
                    if(getLeadName != null) {
                        body = body.replace('{!Document_Checklist__c.Lead_Name__c}',getLeadName);
                    }
                    if(getApplicantType != null) {
                        body = body.replace('{!Document_Checklist__c.Applicant_Type__c}',getApplicantType);
                    }
                    if(leadRecordLink != null){
                        body = body.replace('{!Document_Checklist__c.Lead__c}',leadRecordLink);
                    }
                    
                    email.setHtmlBody(body);
                    //  email.setPlainTextBody(body);
                    email.setTemplateId(RejectedAcceptedEmailTemp.Id);
                    email.setTargetObjectId(objlead.Id);
                    email.setSaveAsActivity(true);
                    email.setTreatTargetObjectAsRecipient(false);
                    email.setToAddresses(SetToAddress);
                    if(!SetToCCAddress.IsEmpty() && SetToCCAddress.size() > 0){
                        email.setCcAddresses(SetToCCAddress);    
                    }
                    email.setTreatBodiesAsTemplate(true);
                    email.setOrgWideEmailAddressId(owea[0].Id);
                    emailList.add(email);
                    String plainTextBody = body.stripHtmlTags();
                    Task objectTask = new Task();
                    objectTask.Subject = 'Document Issues';
                    objectTask.Status = CommonConstant.TASK_STATUS;
                    objectTask.Priority = CommonConstant.TASK_PRIORITY_HIGH;
                    objectTask.OwnerId = objlead.OwnerId;
                    objectTask.WhoId =objlead.Id;
                    objectTask.Description =plainTextBody;
                    objectTask.Type = 'QC_Query';
                    taskList.add(objectTask);
                }
                if (!emailList.isEmpty()) {
                    Messaging.sendEmail(emailList);
                }
                if(!taskList.IsEmpty() && taskList.size() >0){
                    try {
                        insert taskList;
                    }catch(Exception e) {
                        for(Lead objLead : objecteadlist ) 
                            objLead.addError(CommonConstant.ERROR_CONSTANT + e.getMessage());
                    }
                }
                messagestr = 'Success! The status of '+docCheckList.size() +' rejected documents has been shared with the sales user.';
                updateLeadStatus(recordId);
            }else if (docCheckList.size() == 0) {
                messagestr = 'Error!  currently, we are unable to find any rejected documents.'; 
            }
        } catch (Exception e) {
            messagestr = 'Error : ' + e.getMessage();
        }
        return messagestr;
    }
    
/********************************************************************************************************
* @author          Rohit Pardeshi
* @description     This Method is to update the Lead Status when Login Desk user Submit Document Issues  
* @param           string recordId --> recordId will be LeadId or DealId
* @return          NA                
* @date            11-09-2023   
********************************************************************************************************/
    public static void updateLeadStatus(string recordId){
        try{
            Lead updateLead = [SELECT ID, Status, Status__c FROM Lead WHERE Id =:recordId];
            
            //updateLead.Status = Label.Lead_Stage_Applying;
            updateLead.Status__c = Label.Lead_Status_QC_Sales_Query;
            updateLead.StageStatusChangeTime__c  = DateTime.now();
            update updateLead;
            
        }catch (Exception e) {
            system.debug('Error Occurs ' +e.getMessage());
        }       
        
    }
}