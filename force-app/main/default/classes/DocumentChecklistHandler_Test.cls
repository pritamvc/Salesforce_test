@isTest
public class DocumentChecklistHandler_Test {
	
    static testmethod void testData(){
        
        Source__c src = new Source__c(Name = 'Test',Lead_Gate__c = 'Distribution Partners', Lead_Source__c ='Business Partners', Source_Type__c ='Auxilo',
                                     Sub_Source_Type__c = 'Agencies', Source_Category__c = 'Partner');
        insert src;
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_IN', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Kolkata', UserName='standarduser@testorg.com');
            
          id userId2 = UserInfo.getUserId();
          id userId3 = UserInfo.getUserId(); 
        Lead newLead = new Lead();
        newLead.FirstName ='Lead';
        newLead.LastName = 'Testing';
        newLead.Email = 'leadTesting@gmail.com';
        newLead.MobilePhone = '5654565555';
        newLead.Source_Category__c = 'Partner';
        newLead.Source_Name__c = src.id;
        newLead.OwnerId = u.Id;
        insert newLead;
        newLead.Stage_Owner__c=UserInfo.getUserId();
        
        update newLead;
        
        String gsRecordTypeID = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account(FirstName = 'Test', LastName = 'new', recordTypeId = gsRecordTypeID);
        insert acc;
        Account newAcc = new Account(FirstName = 'Test1', LastName = 'new1', recordTypeId = gsRecordTypeID);
        insert newAcc;
        
        Co_Applicant__c app = new Co_Applicant__c(Account__c = acc.id, Type__c = 'Applicant');
        insert app;         
        id userId = UserInfo.getUserId();
        Document_Checklist__c dc = new Document_Checklist__c(ownerID = userId ,Lead__c = newLead.id, Applicant__c = app.id, Applicant_Type__c = 'Applicant',
                                                            Document_Type__c = 'KYC Documents', Doc_Sub_Type__c = 'Aadhar Card', Status__c = 'Accepted');
        insert dc;
        /*Document_Checklist__c dc1 = new Document_Checklist__c(ownerID = userId ,Lead__c = newLead.id, Applicant__c = app.id, Applicant_Type__c = 'Applicant',
                                                            Document_Type__c = 'KYC Documents', Doc_Sub_Type__c = 'Aadhar Card', Status__c = 'Rejected');
        insert dc1;*/
        List<Document_Checklist__c> dcList = new List<Document_Checklist__c>{dc};
      //  List<Document_Checklist__c> dcList1 = new List<Document_Checklist__c>{dc1};    
            test.startTest();
        	DocumentChecklistHandler.handleAcceptedOrRejected(dcList);
        	//DocumentChecklistHandler.handleAcceptedOrRejected(dcList1);
        	test.stopTest();
    }
    static testmethod void testData2(){   
         Source__c src = new Source__c(Name = 'Test',Lead_Gate__c = 'Distribution Partners', Lead_Source__c ='Business Partners', Source_Type__c ='Auxilo',
                                     Sub_Source_Type__c = 'Agencies', Source_Category__c = 'Partner');
        insert src;
          id userId2 = UserInfo.getUserId();
          id userId3 = UserInfo.getUserId(); 
        Lead newLead = new Lead();
        newLead.FirstName ='Lead';
        newLead.LastName = 'Testing';
        newLead.Email = 'leadTesting@gmail.com';
        newLead.MobilePhone = '5654565555';
        newLead.Source_Category__c = 'Partner';
        newLead.Source_Name__c = src.id;
        newLead.OwnerId = userId3;
        insert newLead;
        newLead.Stage_Owner__c=UserInfo.getUserId();
        update newLead;
        
        String gsRecordTypeID = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account(FirstName = 'Test', LastName = 'new', recordTypeId = gsRecordTypeID);
        insert acc;
        Account newAcc = new Account(FirstName = 'Test1', LastName = 'new1', recordTypeId = gsRecordTypeID);
        insert newAcc;
        
        Co_Applicant__c app = new Co_Applicant__c(Account__c = acc.id, Type__c = 'Applicant');
        insert app;         
        id userId = UserInfo.getUserId();
      /*  Document_Checklist__c dc = new Document_Checklist__c(ownerID = userId ,Lead__c = newLead.id, Applicant__c = app.id, Applicant_Type__c = 'Applicant',
                                                            Document_Type__c = 'KYC Documents', Doc_Sub_Type__c = 'Aadhar Card', Status__c = 'Accepted');
        insert dc;*/
        Document_Checklist__c dc1 = new Document_Checklist__c(ownerID = userId ,Lead__c = newLead.id, Applicant__c = app.id, Applicant_Type__c = 'Applicant',
                                                            Document_Type__c = 'KYC Documents', Doc_Sub_Type__c = 'Aadhar Card', Status__c = 'Rejected');
        insert dc1;
       // List<Document_Checklist__c> dcList = new List<Document_Checklist__c>{dc};
        List<Document_Checklist__c> dcList1 = new List<Document_Checklist__c>{dc1};    
            test.startTest();
        //	DocumentChecklistHandler.handleAcceptedOrRejected(dcList);
        	DocumentChecklistHandler.handleAcceptedOrRejected(dcList1);
        	test.stopTest();
    
    
    }
    
}