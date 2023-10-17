@isTest
public class FileUploaderClass_Test {

    static testmethod void method1(){
        
    string base = 'tesinigmydocument';
    string filename = 'test file';
    Document_Checklist__c dc = new Document_Checklist__c();
        dc.Applicant_Name__c = 'test';
  /*  Account acc = new Account();
    acc.Name = 'test';
    insert acc; */
        insert dc;

    string accid = dc.id;
    
    FileUploaderClass.uploadFile(base,filename,accid);
    }
}