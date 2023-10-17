public class AttachPDFToLead {
    
    public final Lead l; // Custom object record
    
    public AttachPDFToLead(ApexPages.StandardController standardPageController) {
        l = (Lead)standardPageController.getRecord();
        system.debug('l' +l);
    }
  
    public PageReference attachPDF() {
        PageReference pdfPage = Page.LoanApplicationPDF;
        pdfPage.getParameters().put('id',l.Id);
        List<Id> leadid = new List<Id>();
        leadid.add(l.id);
        system.debug('leadid' +leadid);
        
        List<Document_Checklist__c> docchklist=[select id from Document_Checklist__c where Document_Type__c='Other Document' and Doc_Sub_Type__c='Application Form' and Lead__c=:leadid];   
        
        Blob pdfBlob;
        if (!Test.isRunningTest()) {
            pdfBlob = pdfPage.getContent();
        } else {
            pdfBlob = Blob.valueOf('Some Text for a boring PDF file...');
        }
        
        // Create a ContentVersion record
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test.pdf',
            VersionData = pdfBlob,
            PathOnClient = 'Test.pdf'
        );
        insert contentVersion;
        
        // Create a ContentDocumentLink to associate the ContentVersion with the Lead record
        System.debug(l.id);
        //    ContentDocumentLink contentLink = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :a.Id LIMIT 1 ];
        // System.debug(contentLink);
        
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion.Id].ContentDocumentId;
        System.debug('conDoc'+conDoc);
        
        For(Document_Checklist__c doc: docchklist){
            createContentDocumenlink(doc.id,conDoc);
        }
        
        PageReference pageWhereWeWantToGo = new ApexPages.StandardController(l).view();
        pageWhereWeWantToGo.setRedirect(true);
        return pageWhereWeWantToGo;
    }
    
    public void createContentDocumenlink(String recordid,String conDoc){
        // Create a ContentDocumentLink to associate the ContentVersion with the Lead record
        ContentDocumentLink newContentLink = new ContentDocumentLink(
            ContentDocumentId = conDoc,
            LinkedEntityId = recordid,
            ShareType = 'V'
        );
        insert newContentLink;
        
    }
    
}