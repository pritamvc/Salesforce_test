public class FileUploaderClass {
    /********************************************************************************************************
* @author          Kailash
* @description     This method will used to Uploads files.
* @param           base64 The base64-encoded data for the content version.
* @param		   filename The name of the file being uploaded.
* @param		   recordId The ID of the Document_Checklist__c record.
* @param 		   passVal The password value.
* @return 		   The ID of the created ContentDocumentLink.
/********************************************************************************************************/    
    
    @AuraEnabled
    public static String uploadFile(String base64, String filename, String recordId, String passVal) {
        deleteContentDoc(recordId);
        ContentVersion cv = createContentVersion(base64, filename);
        ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
        createContentDistribution(cv);
        List<Document_Checklist__c> docList =[select id, Status__c, IsDocumentComplete__c, Doc_Sub_Type__c, Remarks__c from Document_Checklist__c where id = :recordId];
        List<Document_Checklist__c> docListToUpdate = new List<Document_Checklist__c>();        
        
        for(Document_Checklist__c dc :docList){ 
            dc.Status__c = 'Uploaded';
            dc.IsDocumentComplete__c = false;
            dc.Remarks__c = null;
            docListToUpdate.add(dc);
        }
        update docListToUpdate;
        try {            
            Document_Checklist__c document = [SELECT Id, Document_Type__c, Doc_Sub_Type__c FROM Document_Checklist__c WHERE Id = :recordId LIMIT 1];
            
            /*if (document != null && document.Document_Type__c == 'Income Document' && document.Doc_Sub_Type__c == 'Bank Statement') {
System.debug('Done');
//bank statement
string result=bank( recordId, filename, passVal ,base64);

}*/
        }        catch (Exception e) {
            // Handle any exceptions that occur during the query execution
            System.debug('An error occurred: ' + e.getMessage());
        }
        
        if (cv == null || cdl == null) { return null; }
        return cdl.Id;      
        
    }
    /********************************************************************************************************
* @author          Vaibhav Hinge
* @description     This method will used to Uploads a bank file.
* @param           contentVersionId The ID of the ContentVersion to be linked.
* @param		   filename The name of the file being uploaded.
* @param		   recordId The ID of the Document_Checklist__c record.
* @param 		   passVal The password value.
* @return 		   The ID of the created ContentDocumentLink.
/********************************************************************************************************/    
    @AuraEnabled
    public static String uploadBankFile(String contentVersionId, String filename, String recordId, String passVal) {
        // Delete existing ContentDocumentLink and create a new one
        deleteContentDoc(recordId);
        ContentDocumentLink cdl = createContentLink(contentVersionId, recordId);
        ContentVersion cv =[select Id,ContentDocumentId,Title  FROM ContentVersion WHERE Id =:contentVersionId LIMIT 1];
        createContentDistribution(cv);
        // Update Document_Checklist__c records
        List<Document_Checklist__c> docList =[select id, Status__c, IsDocumentComplete__c, Doc_Sub_Type__c, Remarks__c from Document_Checklist__c where id = :recordId];
        List<Document_Checklist__c> docListToUpdate = new List<Document_Checklist__c>();        
        
        for(Document_Checklist__c dc :docList){   
            dc.Status__c = 'Uploaded';
            dc.IsDocumentComplete__c = false;
            dc.Remarks__c = null;
            docListToUpdate.add(dc);
        }
        update docListToUpdate;
        try {            
            /* Document_Checklist__c document = [SELECT Id, Document_Type__c, Doc_Sub_Type__c FROM Document_Checklist__c WHERE Id = :recordId LIMIT 1];

if (document != null && document.Document_Type__c == 'Income Document' && document.Doc_Sub_Type__c == 'Bank Statement') {
System.debug('Done');
//bank statement
string result=bank( recordId, filename, passVal ,base64);

}*/
        }        catch (Exception e) {
            // Handle any exceptions that occur during the query execution
            System.debug('An error occurred: ' + e.getMessage());
        }
        // Return the ID of the created ContentDocumentLink
        if (contentVersionId == null || cdl == null) { return null; }
        return cdl.Id;   
    }
    
    /***********************************************************
* @description	 Creates a new content version with the given base64-encoded data and filename.
* @param 		 base64 The base64-encoded data for the content version.
* @param 		 filename The filename for the content version.
* @return		 The new content version object, or null if an error occurred during insertion.
************************************************************/   
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
    /******************************************************************************
* @description Creates a new content document link between the given content version and record.
* @param 		contentVersionId The ID of the content version to link.
* @param 		recordId The ID of the record to link the content version to.
* @return 		The new content document link object, or null if an error occurred during insertion.
*************************************************************************************/
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
        try {
            insert cdl;
            return cdl;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    /**************************************************************************
* @description Deletes content document links for document checklist records that meet certain criteria.
* @param 		recordId The ID of the document checklist record to check for content document links.
******************************************************************************/  
    public static void deleteContentDoc(String recordId){
        List<Document_Checklist__c> docList =[select id, Status__c, IsDocumentComplete__c, Doc_Sub_Type__c, Remarks__c from Document_Checklist__c
                                              where id = :recordId AND Doc_Sub_Type__c != 'Aadhar Card' AND Doc_Sub_Type__c != 'Passport'];  
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        List<ContentDocumentLink> deleteCdlList = new List<ContentDocumentLink>();
        set<id> dcIdSet = new set<id>(); 
        if(docList != null && docList.size() > 0){ 
            for(Document_Checklist__c dc :docList){
                dcIdSet.add(dc.id);           
            }
        }
        if(dcIdSet != null && dcIdSet.size() > 0){
            cdlList = [select id, ContentDocumentId, LinkedEntityId, ContentDocument.CreatedDate from ContentDocumentLink where LinkedEntityId IN :dcIdSet];   
        }
        if(cdlList != null && cdlList.size() > 0){
            for(ContentDocumentLink contentDoc :cdlList){
                if(contentDoc.ContentDocument.CreatedDate < system.now()){
                    deleteCdlList.add(contentDoc);
                }
            }
            if(deleteCdlList != null && deleteCdlList.size() > 0){
                delete deleteCdlList; 
            }
        }
        
    }
    /*
public static string bank(id  recordId, string  filename, string Password ,string Base64 )
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
}Commented by Sohail Bank used in phase 2*/
    
    /***********************************************************
* @description	 Creates a content distribution for the given content version.
* @param 		 objContentVersion The content version object.
************************************************************/
    public static void createContentDistribution(ContentVersion objContentVersion) {
        system.debug('IN createContentDistribution');
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
    
    
    /********************************************************************************************************
* @author          Chandrakant More
* @description     This method will used to Save Password On Applicant Record.
* @param		   record id of Applicant and Password need to be saved. 
* @return 		   No-return
* @Date            (21/08/2023) (DD/MM/YYYY)
/********************************************************************************************************/ 
    @AuraEnabled
    public static Void savePasswordForBankStatementDoument(String documentCheclistId, String passwordString) {
        List<Co_Applicant__c> coApplicantListToUpdate = new     List<Co_Applicant__c>();
        if(documentCheclistId != null){
            Document_Checklist__c objectDocumentChecklist = [SELECT Id,Name,Applicant__c,Applicant__r.Bank_Statement_Password__c  from Document_Checklist__c Where Id =: documentCheclistId];
            if(objectDocumentChecklist.Applicant__c != null){
                Co_Applicant__c objectCoApplicant = [SELECT Id,Name,Bank_Statement_Password__c  from Co_Applicant__c where Id =: objectDocumentChecklist.Applicant__c];  
                if(objectCoApplicant != null){
                    objectCoApplicant.Bank_Statement_Password__c = passwordString;
                    coApplicantListToUpdate.add(objectCoApplicant);
                } 
            }
        }
        if(!coApplicantListToUpdate.IsEmpty() && coApplicantListToUpdate.size() > 0){
            Update coApplicantListToUpdate;
        }
    }
}