@isTest
public class FileUploaderClassTest {
    
    static testmethod void method1(){
        string passwordString = '123457tst';
        
        string base = 'tesinigmydocument';
        string filename = 'test file';
        Document_Checklist__c dc = new Document_Checklist__c();
        dc.Applicant_Name__c = 'test';
        insert dc;
        
        ContentVersion cvObj = TestDataFactory.createAadharCVRecord(true);
        string accid = dc.id;
        system.Test.startTest();
        FileUploaderClass.uploadFile(base,filename,accid, null);
        FileUploaderClass.uploadBankFile(cvObj.Id,filename,accid, null);
        FileUploaderClass.savePasswordForBankStatementDoument(dc.Id,passwordString);
        system.Test.stopTest();
    }
}