@isTest
public class FileControllerTest {
    @isTest
    public static void contentDocTestMethod(){
        Document_Checklist__c dcl = new Document_Checklist__c();
        dcl.Applicant_Type__c = 'Applicant';
        dcl.Document_Type__c='KYC Documents';
        dcl.Doc_Sub_Type__c ='Aadhar Card';
        dcl.Applicant_Name__c = 'test';
        insert dcl;
        
        Test.startTest();
        FilesController.fetchFiles(dcl.id);
        Test.stopTest();
        
    }
    
}