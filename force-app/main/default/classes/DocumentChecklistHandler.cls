public class DocumentChecklistHandler {
    @InvocableMethod
    public static void handleAcceptedOrRejected(List<Document_Checklist__c> newlistDocumentChecklist) {
        System.debug('newlistDocumentChecklist'+newlistDocumentChecklist);
        Set<String> parentLeadIds = new Set<String>();
        Set<String> DocumentChecklistOwnerId = new Set<String>();
        Map<String, Lead> mapParebtIdAndLead = new Map<String, Lead>();
        Map<Id,String> leadVsStageLeadEmail = new  Map<Id,String>();
        Map<Id,String> leadIdVsLeadOwnerEmail = new  Map<Id,String>();
        Map<String, User> mapOwnerIdAndUser = new Map<String, User>(); 
        Map<String, String> mapDocumentChecklistIdAndOwnerEmail = new Map<String, String>();
        //Map<Id, list<Document_Review_Tracker__c>> mapDocChecklistIdToReviewTracker = new Map<Id, list<Document_Review_Tracker__c>>();
        Set<Id> docChecklistIds = new Set<Id>();
         for (Document_Checklist__c checklist : newlistDocumentChecklist) {
            docChecklistIds.add(checklist.Id);
        }
        
        for (Document_Checklist__c ObjDocumentChecklist : newlistDocumentChecklist) {
            DocumentChecklistOwnerId.add(ObjDocumentChecklist.OwnerId);
            parentLeadIds.add(ObjDocumentChecklist.Lead__c);
            mapDocumentChecklistIdAndOwnerEmail.put(ObjDocumentChecklist.Id, ObjDocumentChecklist.Owner.Email);
        }
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        EmailTemplate accptEmailTemp = [SELECT Id, Subject, Body, HTMLValue FROM EmailTemplate WHERE Name ='Accepted Doc Checklist'];
        EmailTemplate rejctEmailTemp = [SELECT Id, Subject, Body, HTMLValue FROM EmailTemplate WHERE Name ='Rejected Doc Checklist'];
        List<OrgWideEmailAddress> owea = [select Id from OrgWideEmailAddress WHERE Address='noreply@auxilo.com'];
        
        List<Lead> parentLeadList = [SELECT Id,Name,Stage_Owner__c,Owner.Email,Stage_Owner__r.Email, Email FROM Lead WHERE Id IN :parentLeadIds];
        List<User> ownerUserList = [SELECT Id, Email FROM User WHERE Id IN :DocumentChecklistOwnerId];
        List<Document_Review_Tracker__c> reviewTrackers = [SELECT Id, Document_Checklist__c, Remark__c FROM Document_Review_Tracker__c WHERE Document_Checklist__c IN :docChecklistIds];
        
         
      /*  for (Document_Review_Tracker__c tracker : reviewTrackers) {
            if(mapDocChecklistIdToReviewTracker.get(tracker.Document_Checklist__c) == null){
                mapDocChecklistIdToReviewTracker.put(tracker.Document_Checklist__c, new list<Document_Review_Tracker__c>{tracker});
            }else{
                mapDocChecklistIdToReviewTracker.get(tracker.Document_Checklist__c).add(tracker);
            }
            
        }
        system.debug('mapDocChecklistIdToReviewTracker:::'+mapDocChecklistIdToReviewTracker);*/
        
        for (Lead ObjLead : parentLeadList) {
            mapParebtIdAndLead.put(ObjLead.Id, ObjLead);
            leadIdVsLeadOwnerEmail.put(ObjLead.Id,ObjLead.Owner.Email);
            if(ObjLead.Stage_Owner__c != null){
              leadVsStageLeadEmail.put(ObjLead.Id,ObjLead.Stage_Owner__r.Email);   
            }
           
        }
        for (User ObjUser : ownerUserList) {
            mapOwnerIdAndUser.put(ObjUser.Id, ObjUser);
        }
        
        
        for (Document_Checklist__c objDocumentChecklist : newlistDocumentChecklist) {
            System.debug('objDocumentChecklist::'+objDocumentChecklist.Status__c);
            if (objDocumentChecklist.Status__c == 'Accepted') {
               // List<String> leadEmail = new List<String>();
                List<String> objDocumentChecklistOwnerEmail = new List<String>();
                List<string> getStageLeadEmail = new  List<string>();
                List<String> getLeadOwnerEmail = new List<string>();
                String leadRecordLink = URL.getSalesforceBaseUrl().toExternalForm() + '/' + objDocumentChecklist.Lead__c;
                system.debug('leadRecordLink'+leadRecordLink);
                String Subject = accptEmailTemp.Subject;
                String body = accptEmailTemp.HTMLValue;
                String getLeadName = mapParebtIdAndLead.get(objDocumentChecklist.Lead__c).Name;
                String getApplicantType = objDocumentChecklist.Applicant_Type__c;
                String getApplicantName = objDocumentChecklist.Applicant_Name__c;
                String getDocSubType = objDocumentChecklist.Doc_Sub_Type__c;
               
                             
                getStageLeadEmail.add(leadVsStageLeadEmail.get(objDocumentChecklist.Lead__c));
                System.debug('getStageLeadEmail::'+getStageLeadEmail);
                getLeadOwnerEmail.add(leadIdVsLeadOwnerEmail.get(objDocumentChecklist.Lead__c));
                System.debug('getLeadOwnerEmail::'+getLeadOwnerEmail);
              //  leadEmail.add(mapParebtIdAndLead.get(objDocumentChecklist.Lead__c).Email);
                objDocumentChecklistOwnerEmail.add(mapOwnerIdAndUser.get(objDocumentChecklist.OwnerId).Email);
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setSubject(Subject);
                if(getLeadName != null) {
                        body = body.replace('{!Document_Checklist__c.Lead_Name__c}',getLeadName);
                    }
                if(getApplicantType != null) {
                        body = body.replace('{!Document_Checklist__c.Applicant_Type__c}',getApplicantType);
                    }
                if(getApplicantName != null) {
                        body = body.replace('{!Document_Checklist__c.Applicant_Name__c}',getApplicantName);
                    }              
                if(getDocSubType != null) {
                        body = body.replace('{!Document_Checklist__c.Doc_Sub_Type__c}',getDocSubType);
                    }
                if(leadRecordLink != null){
                       body = body.replace('{!Document_Checklist__c.Lead__c}',leadRecordLink);
                     system.debug('body::'+body);
                }

                
                email.setHtmlBody(body);
                system.debug('body' + body);
                email.setTemplateId(accptEmailTemp.Id);
                email.setTargetObjectId(mapParebtIdAndLead.get(objDocumentChecklist.Lead__c).Id);
                email.setSaveAsActivity(true);
                email.setToAddresses(getLeadOwnerEmail);
               if(getStageLeadEmail != null && getStageLeadEmail.size() > 0){
                 email.setCcAddresses(getStageLeadEmail);    
                }
                email.setTreatBodiesAsTemplate(true);
                email.setOrgWideEmailAddressId(owea[0].Id);
                email.setPlainTextBody(leadRecordLink);
                email.setTreatTargetObjectAsRecipient(false);
                emailList.add(email);
            } else if (objDocumentChecklist.Status__c == 'Rejected') {
                List<String> leadEmail = new List<String>();
                List<String> objDocumentChecklistOwnerEmail = new List<String>();
                List<string> getStageLeadEmail = new  List<string>();
                List<String> getLeadOwnerEmail = new List<string>();
                String leadRecordLink = URL.getSalesforceBaseUrl().toExternalForm() + '/' + objDocumentChecklist.Lead__c;

                String Subject = rejctEmailTemp.Subject;
                String body = rejctEmailTemp.HTMLValue;
                String getLeadName = mapParebtIdAndLead.get(objDocumentChecklist.Lead__c).Name;
                String getApplicantType = objDocumentChecklist.Applicant_Type__c;
                String getApplicantName = objDocumentChecklist.Applicant_Name__c;
                String getDocSubType = objDocumentChecklist.Doc_Sub_Type__c;
                String remarkDCL = objDocumentChecklist.Remarks__c;
               /*  String remark = '';
                  list<string> remarkList = new list<string>();
                list< Document_Review_Tracker__c > reviewTracker = mapDocChecklistIdToReviewTracker.get(objDocumentChecklist.Id);
                for(Document_Review_Tracker__c drt:reviewTracker){
                    if(drt.Remark__c != null){
                        remarkList.add(drt.Remark__c);
                       
                        
                    }
                }
               remark=string.join(remarkList, ',');
                system.debug('remark ' + remark);*/
              /*  if (reviewTracker != null) {
                    remark = reviewTracker.Remark__c;
                    system.debug('remark ' + remark);
                }*/
                 
                
                getStageLeadEmail.add(leadVsStageLeadEmail.get(objDocumentChecklist.Lead__c));
                System.debug('getStageLeadEmail::'+getStageLeadEmail);
                 getLeadOwnerEmail.add(leadIdVsLeadOwnerEmail.get(objDocumentChecklist.Lead__c));
                System.debug('getLeadOwnerEmail::'+getLeadOwnerEmail);
               // leadEmail.add(mapParebtIdAndLead.get(objDocumentChecklist.Lead__c).Email);
                objDocumentChecklistOwnerEmail.add(mapOwnerIdAndUser.get(objDocumentChecklist.OwnerId).Email);
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setSubject(Subject);
                if(getLeadName != null) {
                        body = body.replace('{!Document_Checklist__c.Lead_Name__c}',getLeadName);
                    }
                if(getApplicantType != null) {
                        body = body.replace('{!Document_Checklist__c.Applicant_Type__c}',getApplicantType);
                    }
                if(getApplicantName != null) {
                        body = body.replace('{!Document_Checklist__c.Applicant_Name__c}',getApplicantName);
                    }         
                if(getDocSubType != null) {
                        body = body.replace('{!Document_Checklist__c.Doc_Sub_Type__c}',getDocSubType);
                    }
            
                
                if(remarkDCL != null) {
                        body = body.replace('{!Document_Checklist__c.Remarks__c}',remarkDCL);
                    } 
                if(leadRecordLink != null){
                       body = body.replace('{!Document_Checklist__c.Lead__c}',leadRecordLink);
                    system.debug('body::'+body);
                }
                
                email.setHtmlBody(body);
                system.debug('body' + body);
                email.setTemplateId(rejctEmailTemp.Id);
                email.setTargetObjectId(mapParebtIdAndLead.get(objDocumentChecklist.Lead__c).Id);
                email.setSaveAsActivity(true);
                email.setTreatTargetObjectAsRecipient(false);
                email.setToAddresses(getLeadOwnerEmail);
                if(getStageLeadEmail != null && getStageLeadEmail.size() > 0){
                 email.setCcAddresses(getStageLeadEmail);    
                }
                email.setTreatBodiesAsTemplate(true);
                email.setOrgWideEmailAddressId(owea[0].Id);
                emailList.add(email);
            }
        }
         System.debug('emailList'+emailList);
        
        if (!emailList.isEmpty()) {
            System.debug('emailList'+emailList);
            Messaging.sendEmail(emailList);
        } 
    }
}