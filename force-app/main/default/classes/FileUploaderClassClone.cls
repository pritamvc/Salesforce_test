public with sharing class FileUploaderClassClone {
    @AuraEnabled
 public static String uploadFile(String base64, String filename, String recordId, String passVal) {
     system.debug('In FileUploaderClassClone');
     	deleteContentDoc(recordId);
       ContentVersion cv = createContentVersion(base64, filename);
       ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
       List<Document_Checklist__c> docList =[select id, Status__c, IsDocumentComplete__c, Doc_Sub_Type__c, Remarks__c from Document_Checklist__c where id = :recordId];
        List<Document_Checklist__c> docListToUpdate = new List<Document_Checklist__c>();        
        
        for(Document_Checklist__c dc :docList){          
            dc.Status__c = 'Pending';
            dc.IsDocumentComplete__c = false;
            dc.Remarks__c = null;
            docListToUpdate.add(dc);
        }
        system.debug('docListToUpdate'+docListToUpdate);
       update docListToUpdate;
     try {
         
     	Document_Checklist__c document = [SELECT Id, Document_Type__c, Doc_Sub_Type__c FROM Document_Checklist__c WHERE Id = :recordId LIMIT 1];
    
        if (document != null && document.Document_Type__c == 'Income Document' && document.Doc_Sub_Type__c == 'Bank Statement') {
            System.debug('Done');
            //bank statement
           // string result=bank( recordId, filename, passVal ,base64);
           
    }
     }
     catch (Exception e) {
        // Handle any exceptions that occur during the query execution
        System.debug('An error occurred: ' + e.getMessage());
    }
     
		
     
       if (cv == null || cdl == null) { return null; }
       return cdl.Id;      
    
 }
  
  @AuraEnabled
    public static String uploadChunkedFile(String recordId, String fileName, String fileContent, String contentVersionId) {
     //  try { 
        deleteContentDoc(recordId);
       // fileContent = EncodingUtil.urlDecode(fileContent, 'UTF-8');
       
        if (String.isBlank(contentVersionId)) {
            ContentVersion cvObj = new ContentVersion(); 
            cvObj.Title = fileName; 
            cvObj.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlDecode(fileContent, 'UTF-8'));
            cvObj.PathOnClient =  fileName;
            cvObj.IsMajorVersion = false;
            insert cvObj;
  system.debug('##cvObj   '+cvObj.Id);            
            // Create a ContentDocumentLink
            ContentDocumentLink cdl = createContentLink(cvObj.Id, recordId);
            contentVersionId = cvObj.Id;
            
            // Create a ContentDistribution record
            createContentDistribution(cvObj);
        } else {
            system.debug('##Else cvObj   '+contentVersionId); 
            ContentVersion cvObj = [SELECT Id, VersionData,ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionId];
               // String existingFileContent = EncodingUtil.base64Encode(cvObj.VersionData);
                cvObj.VersionData = EncodingUtil.base64Decode(EncodingUtil.base64Encode(cvObj.VersionData) + EncodingUtil.urlDecode(fileContent, 'UTF-8')); 
                update cvObj;
            
            
            }
        
        
        List<Document_Checklist__c> docList =[select id, Status__c, IsDocumentComplete__c, Doc_Sub_Type__c, Remarks__c from Document_Checklist__c where id = :recordId];
        List<Document_Checklist__c> docListToUpdate = new List<Document_Checklist__c>();        
        
        for(Document_Checklist__c dc :docList){          
            dc.Status__c = 'Uploaded';
            dc.IsDocumentComplete__c = false;
            dc.Remarks__c = null;
            docListToUpdate.add(dc);
        }
        update docListToUpdate;
           return Id.valueOf(contentVersionId);
      //  } catch (Exception ex) {
          // System.debug('An error occurred: ' + ex.getMessage());
         //  throw new AuraHandledException(ex.getMessage());
      //  }
    }
/*********************************/
 @AuraEnabled
    public static String uploadChunkedFile1(String recordId, String fileName, String fileContent, String contentVersionId) {
       try { 
        deleteContentDoc(recordId);
       // fileContent = EncodingUtil.urlDecode(fileContent, 'UTF-8');
        Blob newBlobData = EncodingUtil.base64Decode(fileContent);
        
        if (String.isBlank(contentVersionId)) {
            // Create a new ContentVersion record with BLOB data
            ContentVersion cvObj = new ContentVersion(); 
            cvObj.Title = fileName; 
            cvObj.VersionData = newBlobData;
            cvObj.PathOnClient = fileName;
            cvObj.IsMajorVersion = false;
            insert cvObj;
            
            // Create a ContentDocumentLink
            ContentDocumentLink cdl = createContentLink(cvObj.Id, recordId);
            contentVersionId = cvObj.Id;
            
            // Create a ContentDistribution record
            createContentDistribution(cvObj);
        } else {
            // Retrieve existing ContentVersion
            ContentVersion cvObj = [SELECT Id, VersionData FROM ContentVersion WHERE Id = :contentVersionId];
            
            // Combine the new binary data with existing data
            Blob existingData = cvObj.VersionData;
            Blob combinedData = Blob.valueOf(existingData.toString() + newBlobData.toString());
            
            // Update the existing ContentVersion with the combined BLOB data
            cvObj.VersionData = combinedData;
            update cvObj;
            }
        List<Document_Checklist__c> docList =[select id, Status__c, IsDocumentComplete__c, Doc_Sub_Type__c, Remarks__c from Document_Checklist__c where id = :recordId];
        List<Document_Checklist__c> docListToUpdate = new List<Document_Checklist__c>();        
        
        for(Document_Checklist__c dc :docList){          
            dc.Status__c = 'Uploaded';
            dc.IsDocumentComplete__c = false;
            dc.Remarks__c = null;
            docListToUpdate.add(dc);
        }
        update docListToUpdate;
           return Id.valueOf(contentVersionId);
        } catch (Exception ex) {
           System.debug('An error occurred: ' + ex.getMessage());
           throw new AuraHandledException(ex.getMessage());
        }
    }    
    /***********************************/
 @AuraEnabled
 public static String uploadFileChunk(String base64, String filename, String recordId, String passVal, Integer chunkNumber, Integer totalChunks) {
     try {
         // Calculate the start and end indices for the current chunk
         Integer chunkSize = 2097152; // 2 MB in bytes
         Integer startIdx = (chunkNumber - 1) * chunkSize;
         Integer endIdx = Math.min(startIdx + chunkSize, base64.length());

         // Extract the chunk data
         String chunkData = base64.substring(startIdx, endIdx);

         // Create ContentVersion record for the current chunk
         ContentVersion cv = createContentVersion(chunkData, filename);
         ContentDocumentLink cdl = createContentLink(cv.Id, recordId);


         // Update Document_Checklist__c records after processing the last chunk
         if (chunkNumber == totalChunks) {
        List<Document_Checklist__c> docList =[select id, Status__c, IsDocumentComplete__c, Doc_Sub_Type__c, Remarks__c from Document_Checklist__c where id = :recordId];
        List<Document_Checklist__c> docListToUpdate = new List<Document_Checklist__c>();        
       
             for (Document_Checklist__c dc : docList) {
                 dc.Status__c = 'Uploaded';
                 dc.IsDocumentComplete__c = false;
                 dc.Remarks__c = null;
                 docListToUpdate.add(dc);
             }
             update docListToUpdate;
         }

         return 'Success';
     } catch (Exception e) {
         return 'Error: ' + e.getMessage();
     }
 }
/*************************************/  
   @testvisible
    private static ContentVersion createContentVersion(String base64, String filename) {
   ContentVersion cv = new ContentVersion();
   cv.VersionData = EncodingUtil.base64Decode(base64);
   cv.Title = filename;
   cv.PathOnClient = filename;
   try {
     insert cv;
     return cv;
   } catch(DMLException e) {
     System.debug(e);
     return null;
   }
 }
   @testvisible
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
             if (contentVersionId == null || recordId == null) { return null; }
   ContentDocumentLink cdl = new ContentDocumentLink();
   cdl.ContentDocumentId = [
     SELECT ContentDocumentId 
     FROM ContentVersion 
     WHERE Id =: contentVersionId
   ].ContentDocumentId;
   cdl.LinkedEntityId = recordId;
   // ShareType is either 'V', 'C', or 'I'
   // V = Viewer, C = Collaborator, I = Inferred
   cdl.ShareType = 'V';
   try {
     insert cdl;
     return cdl;
   } catch(DMLException e) {
     System.debug(e);
     return null;
   }
 }

 public static void deleteContentDoc(String recordId){
  List<Document_Checklist__c> docList =[select id, Status__c, IsDocumentComplete__c, Doc_Sub_Type__c, Remarks__c from Document_Checklist__c
        where id = :recordId AND Doc_Sub_Type__c != 'Aadhar Card' AND Doc_Sub_Type__c != 'Passport'];  
    List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        List<ContentDocumentLink> deleteCdlList = new List<ContentDocumentLink>();
        set<id> dcIdSet = new set<id>(); 
        system.debug('docList'+docList);
    if(docList != null && docList.size() > 0){ 
    for(Document_Checklist__c dc :docList){
      dcIdSet.add(dc.id);           
    }
  }
  system.debug('dcIdSet'+dcIdSet);
  if(dcIdSet != null && dcIdSet.size() > 0){
    cdlList = [select id, ContentDocumentId, LinkedEntityId, ContentDocument.CreatedDate from ContentDocumentLink where LinkedEntityId IN :dcIdSet];   
  }
  system.debug('cdlList'+cdlList);
    if(cdlList != null && cdlList.size() > 0){
     for(ContentDocumentLink contentDoc :cdlList){
       if(contentDoc.ContentDocument.CreatedDate < system.now()){
         deleteCdlList.add(contentDoc);
       }
     }
     system.debug('deleteCdlList==>'+deleteCdlList);
     if(deleteCdlList != null && deleteCdlList.size() > 0){
     delete deleteCdlList; 
     }
    }

 }
  /*  public static string bank(id  recordId, string  filename, string Password ,string Base64 )
    {	
        system.debug('In bank ');
        system.debug( 'recordId==='+ recordId + ' filename==='+ filename +'  Password=======' + ' '+ Password+'Base64===== ' + Base64 );
        if(password==NULL)
        {
            password='none';
        }
        system.debug('RecordId'+ recordId);
     	system.debug('File name '+filename);
     	//accid and lead id get
     	//check isfinaltial
     	string documentid='done';
     	string leadId='';
        string accId ='';
     	string apiName='Upload PDF Binary';
        string isFinantial='';
     	//string password='pass';
     	string newfilename='test.pdf';
     	//string fileName = filename;
     	if(newfilename==NULL)
        {
            newfilename='bankStatement.pdf';
        }
        if(Password==NULL){
             Password='none';
        }
        try{
     	      Document_Checklist__c document = [SELECT Lead__c,Applicant__r.Account__c FROM Document_Checklist__c WHERE Id = :recordId LIMIT 1];
            if (document != null) {
                leadId = document.Lead__c;
                accId = document.Applicant__r.Account__c;
            }
        }
        catch (QueryException ex) {
        // Handle the query exception
        System.debug('QueryException: ' + ex.getMessage());
        }
        try{
		isFinantial=BankStatementAnalyzer.getIsIncomeConsideredFinancial(leadId,  accId);
        }
        catch (QueryException ex) {
        // Handle the query exception
        System.debug('QueryException in get finaltial yes or NO: ' + ex.getMessage());
       }
        if(isFinantial=='Yes'){
            System.debug('all '+leadId+' '+accId+' '+ newfilename +' '+ password);
     	
            string docId=base64;
            //system.debug('Document return '+documentid);
            // Call the downloadFile method after 1 minute
            Datetime now = Datetime.now();
            Datetime scheduledTime = now.addMinutes(1);
            String cronExpression = '' + scheduledTime.second() + ' ' + scheduledTime.minute() + ' ' + scheduledTime.hour() + ' ' + scheduledTime.day() + ' ' + scheduledTime.month() + ' ? ' + scheduledTime.year();
            System.debug('cronExpression'+cronExpression);
            //scheduler Download File Job
            System.debug('all parameters '+'apiName'+apiName+'leadId'+ leadId+'accId'+accId+' fileName'+ fileName+'base64='+docId);
            System.schedule('Upload PDF Binary' + cronExpression, cronExpression, new BankStatementSchedular(apiName, docId, leadId, accId, fileName,password));
            String massage='Job scheduled';
            return massage;
        }
       else if(isFinantial=='No')
       {
           string massage='If "Is_Income_Considered_Financial" is currently set to "NO," please update it to "YES"';
           return massage ;
       }
        else{
             string massage='If "Is_Income_Considered_Financial" is currently set to "NO," please update it to "YES" and unexpected error';
           return massage ;
        }     
    }
*/
    public static void createContentDistribution(ContentVersion objContentVersion) {
        ContentDistribution cd = new ContentDistribution();
        cd.Name = objContentVersion.Title;
        cd.ContentVersionId = objContentVersion.id;
        cd.PreferencesAllowViewInBrowser= true;
        cd.PreferencesLinkLatestVersion=true;
        cd.PreferencesNotifyOnVisit=false;
        cd.PreferencesPasswordRequired=false;
        cd.PreferencesAllowOriginalDownload= true;
        insert cd;
    }
   
}