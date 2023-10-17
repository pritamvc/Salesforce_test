@isTest
public class CreateDocumentChecklistRecordsTest {
    @isTest
    static void testCreateDocMethod(){
         Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
          List<Document_Checklist__c> finalList = new list<Document_Checklist__c>();

         Source__c src = new Source__c(Name = 'Test',Lead_Gate__c = 'Distribution Partners', Lead_Source__c ='Business Partners', Source_Type__c ='Auxilo',
                                     Sub_Source_Type__c = 'Agencies', Source_Category__c = 'Partner');
        insert src;
        Lead leadRecord = new Lead();
        leadRecord.FirstName = 'Lead';
        leadRecord.LastName ='Test';
        leadRecord.Email = 'test101@gmail.com';
        leadRecord.MobilePhone = '5454253649';
        leadRecord.Source_Category__c = 'Partner';
        leadRecord.Source_Name__c = src.id;
        insert leadRecord;
       
        String gsRecordTypeID = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account(FirstName = 'Test', LastName = 'new', recordTypeId = gsRecordTypeID);
        insert acc;
        
        Co_Applicant__c coApp = new Co_Applicant__c(Account__c = acc.id, Type__c = CommonConstant.COAPPLICANT);
        insert coApp;
        
       Co_Applicant__c coApp1 = [Select Id,Account__r.FirstName,Account__r.LastName from Co_Applicant__c where Id =:coApp.Id ];
        
       Document_Checklist_Master__c  dcm = new Document_Checklist_Master__c();
            dcm.Applicant_Type__c = coApp.Type__c;
            dcm.Document_Sub_Type__c = 'Aadhar Card';
            dcm.Document_Type__c = 'KYC Documents';
            dcm.File_Size__c = 1;
            dcm.File_Types__c = 'PDF';
            dcm.Instruction_To_Upload_Documents__c = 'Please upload the required documents';
            dcm.IsMandetory__c = 'Yes';
            insert  dcm;
   
        
        Test.startTest();
         List<Document_Checklist__c> result = CreateDocumentChecklistRecords.documentCheklistmaster(leadRecord.Id,coApp.Id);
        Test.stopTest();
    
    }

}