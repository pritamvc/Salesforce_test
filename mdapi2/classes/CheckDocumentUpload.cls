public class CheckDocumentUpload{
    @AuraEnabled
    public static String mandatoryDocumentCheck(String leadId){
        String message = 'Success';
        List<ContentDocumentLink> ContentDocumentId = new List<ContentDocumentLink>();
        ContentDocumentId = [
            SELECT ContentDocumentId,LinkedEntityId  
            FROM ContentDocumentLink
            WHERE LinkedEntityId =: leadId];
        List<Co_Applicant__c> applicantsWithLeadIdRec = new  List<Co_Applicant__c>();
        applicantsWithLeadIdRec = [Select Id, Name, Account__r.Id,Insertion_Order__c
                                   from Co_Applicant__c where Lead__r.Id =: leadId];
        Map<Id,Decimal> mapAccIdvsOrder= new Map<Id,Decimal>();
        for(Co_Applicant__c objCoApp: applicantsWithLeadIdRec ){
            mapAccIdvsOrder.put(objCoApp.Account__r.Id,objCoApp.Insertion_Order__c);
        }   
        Integer appDocumentCount =  0; 
        Integer CoAppDocumentCount =  0;
        Map<Id, List<String>> accountFileNames = new Map<Id, List<String>>();
        Map<Id, List<String>> accountmandatoryFileNames = new Map<Id, List<String>>();
        for (Account a: [SELECT Name, (SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.ContentSize,ContentDocument.FileType FROM 
                ContentDocumentLinks) FROM Account where Id in:mapAccIdvsOrder.keyset()]) {
            system.debug('a.ContentDocumentLinks'+a.ContentDocumentLinks.size()); 
            List<String> fileNames = new List<String>();  
            List<String> mandatoryFileNames = new List<String>(); 
                    if(mapAccIdvsOrder.get(a.Id) == 0){
                        if(a.PAN_Number__c != null){
                            mandatoryFileNames.add('pan_card_App_1');    
                        }                          
                    }
                    if(mapAccIdvsOrder.get(a.Id) >= 1){
                        if(a.PAN_Number__c != null){
                            mandatoryFileNames.add('pan_card_CoApp_'+mapAccIdvsOrder.get(a.Id));    
                        }   
                    }
            for (ContentDocumentLink cdl: a.ContentDocumentLinks) {
                 fileNames.add(cdl.ContentDocument.Title);
                 
                if(mapAccIdvsOrder.get(a.Id) == 0){
                    if(cdl.ContentDocument.Title == 'Aadhar_card_App_1'+'.'+cdl.ContentDocument.FileType.toLowercase() ){
                    }
                    if(cdl.ContentDocument.Title== 'passport_App_1'+'.'+cdl.ContentDocument.FileType.toLowercase()){

                    }
                    if(cdl.ContentDocument.Title== 'Photo_App1' + cdl.ContentDocument.FileType.toLowercase()){
                    }
                    if(cdl.ContentDocument.Title== 'pan_card_App_1'+'.'+cdl.ContentDocument.FileType.toLowercase()){
                    }
                } 
                if(mapAccIdvsOrder.get(a.Id) >= 1){
                    system.debug('cdl.ContentDocument.Title'+cdl.ContentDocument.Title); 
                    system.debug('cdl.ContentDocument.FileType'+cdl.ContentDocument.FileType.toLowercase());
                    system.debug('mapAccIdvsOrder.get(a.Id)'+mapAccIdvsOrder.get(a.Id));
                    if(cdl.ContentDocument.Title == 'Aadhar_card_CoApp_'+mapAccIdvsOrder.get(a.Id)+'.'+cdl.ContentDocument.FileType.toLowercase()){
                        CoAppDocumentCount ++;
                    }
                   /* if(cdl.ContentDocument.Title== 'passport_App_1'){
                    
                    }
                    if(cdl.ContentDocument.Title== 'Photo_App1'){
                    
                    }*/
                    if(cdl.ContentDocument.Title== 'passport_CoApp_'+mapAccIdvsOrder.get(a.Id)+'.'+cdl.ContentDocument.FileType.toLowercase()){
                        CoAppDocumentCount ++;
                    }
                    if(cdl.ContentDocument.Title == 'pan_card_CoApp_'+mapAccIdvsOrder.get(a.Id)+'.'+cdl.ContentDocument.FileType.toLowercase()){
                        CoAppDocumentCount ++;
                    }
                }   
            }
            accountFileNames.put(a.Id, fileNames);
        }
        if(appDocumentCount < 5 || CoAppDocumentCount < ((applicantsWithLeadIdRec.size() -1) * 5)){
            message = 'Error';    
        }else{
            if(applicantsWithLeadIdRec.size() >= 2 && (appDocumentCount >= 5 && CoAppDocumentCount >= ((applicantsWithLeadIdRec.size() -1) * 5))){
                Decimal leadWeightage = DocumentVerification.getLeadTotalPercentage(leadId);
                leadWeightage = 25;
                DocumentVerification.updateLeadTotalPercentage(leadId, leadWeightage,true);  
                message = 'Success';
            }else{
                message = 'Error';    
            }              
        }
        system.debug('message '+message );
        system.debug('message '+appDocumentCount );
        system.debug('CoAppDocumentCount'+CoAppDocumentCount);
        return message;
    }
    @AuraEnabled
    public static String mandatoryDocument(String leadId){
        String message = 'Success';
        List<ContentDocumentLink> ContentDocumentId = new List<ContentDocumentLink>();
        List<ContentVersion> lstContentversion = [SELECT Id,Lead__c, ContentDocumentId FROM ContentVersion WHERE Lead__c = :leadId];
        system.debug('a.lstContentversion '+lstContentversion );
        list<ID> lstFileid = new list<ID>();
        list<ID> lstcontentdocid = new list<ID>();
        for(ContentVersion obj: lstContentversion ){
            lstFileid.add(obj.ContentDocumentId);
        }
        system.debug('a.lstFileid'+lstFileid); 
        /*ContentDocumentId = [
            SELECT ContentDocumentId,LinkedEntityId  
            FROM ContentDocumentLink
            WHERE LinkedEntityId =: leadId and ContentDocumentId in:lstFileid];*/
        List<Co_Applicant__c> applicantsWithLeadIdRec = new  List<Co_Applicant__c>();
        applicantsWithLeadIdRec = [Select Id, Name, Account__r.Id,Insertion_Order__c
                                   from Co_Applicant__c where Lead__r.Id =: leadId];
                                   
        Map<Id,Decimal> mapAccIdvsOrder= new Map<Id,Decimal>();
        
        for(Co_Applicant__c objCoApp: applicantsWithLeadIdRec ){
            mapAccIdvsOrder.put(objCoApp.Account__r.Id,objCoApp.Insertion_Order__c);
        }   
        ContentDocumentId = [
            SELECT ContentDocumentId,LinkedEntityId  
            FROM ContentDocumentLink
            WHERE LinkedEntityId  in:mapAccIdvsOrder.keyset()];
            
        for(ContentDocumentLink contentdocid: ContentDocumentId ){
            lstcontentdocid.add(contentdocid.ContentDocumentId);
        }    
        system.debug('a.lstcontentdocid'+lstcontentdocid);   
        Integer appDocumentCount =  0; 
        Integer CoAppDocumentCount =  0;
        for (Account a: [SELECT Name, (SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.ContentSize,ContentDocument.FileType FROM 
                ContentDocumentLinks where ContentDocumentId in:lstcontentdocid) FROM Account where Id in:mapAccIdvsOrder.keyset()]) {
            system.debug('a.ContentDocumentLinks'+a.ContentDocumentLinks.size());    
            for (ContentDocumentLink cdl: a.ContentDocumentLinks) {
                 
                if(mapAccIdvsOrder.get(a.Id) == 0){
                    if(cdl.ContentDocument.Title == 'Aadhar_card_App_1'+'.'+cdl.ContentDocument.FileType.toLowercase() ){
                        appDocumentCount ++;
                    }
                    if(cdl.ContentDocument.Title== 'passport_App_1'+'.'+cdl.ContentDocument.FileType.toLowercase()){
                        appDocumentCount ++;

                    }
                   /* if(cdl.ContentDocument.Title== 'Photo_App1'){
                    
                    }*/
                    if(cdl.ContentDocument.Title== 'pan_card_App_1'+'.'+cdl.ContentDocument.FileType.toLowercase()){
                        appDocumentCount ++;
                    }
                } 
                if(mapAccIdvsOrder.get(a.Id) >= 1){
                system.debug('cdl.ContentDocument.Title'+cdl.ContentDocument.Title); 
                system.debug('cdl.ContentDocument.FileType'+cdl.ContentDocument.FileType.toLowercase());
                system.debug('mapAccIdvsOrder.get(a.Id)'+mapAccIdvsOrder.get(a.Id));
                    if(cdl.ContentDocument.Title == 'Aadhar_card_CoApp_'+mapAccIdvsOrder.get(a.Id)+'.'+cdl.ContentDocument.FileType.toLowercase()){
                        CoAppDocumentCount ++;
                    }
                   /* if(cdl.ContentDocument.Title== 'passport_App_1'){
                    
                    }
                    if(cdl.ContentDocument.Title== 'Photo_App1'){
                    
                    }*/
                    if(cdl.ContentDocument.Title== 'passport_CoApp_'+mapAccIdvsOrder.get(a.Id)+'.'+cdl.ContentDocument.FileType.toLowercase()){
                        CoAppDocumentCount ++;
                    }
                    if(cdl.ContentDocument.Title == 'pan_card_CoApp_'+mapAccIdvsOrder.get(a.Id)+'.'+cdl.ContentDocument.FileType.toLowercase()){
                        CoAppDocumentCount ++;
                    }
                }   
            }
        }
        if(appDocumentCount < 5 || CoAppDocumentCount < ((applicantsWithLeadIdRec.size() -1) * 5)){
            message = 'Error';    
        }else{
            if(applicantsWithLeadIdRec.size() >= 2 && (appDocumentCount >= 5 && CoAppDocumentCount >= ((applicantsWithLeadIdRec.size() -1) * 5))){
                Decimal leadWeightage = DocumentVerification.getLeadTotalPercentage(leadId);
                leadWeightage = 25;
                DocumentVerification.updateLeadTotalPercentage(leadId, leadWeightage,true);  
                message = 'Success';
            }else{
                message = 'Error';    
            }              
        }
        system.debug('message '+message );
        system.debug('message '+appDocumentCount );
        system.debug('CoAppDocumentCount'+CoAppDocumentCount);
        return message;
    }
}