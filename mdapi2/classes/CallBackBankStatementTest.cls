@isTest
public class CallBackBankStatementTest {
    
@isTest
    static void testCreateDocument() {
        // Create test data
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Account AccountObj = TestDataFactory.createPartnerAccount2(true); 
        Source__c objSource = [SELECT Id,Name,Partner_Name__c From Source__c Where Partner_Name__c =: AccountObj.Id]; 
        Co_Applicant__c coApplicant = new Co_Applicant__c();
        Lead LeadObj = TestDataFactory.createLead(False);
        LeadObj.Source_Name__c = objSource.Id;
        LeadObj.Source_Category__c = 'Partner';
        //insert LeadObj;
        
        coApplicant.Document_Id__c = 'DOC06950293';
        coApplicant.Document_Status__c = 'Processed';
        //coApplicant.Lead__c = LeadObj.Id;
        insert coApplicant;
        //String inputJsonData = '{"transactionID":"trans1223","docId":"DOC06950293","status":"Processed","reportFileName":"","endTime":"3","message":"","fileNo":"","requestId":""}';
        //String inputJsonData ='{'transactionID':'trans1223','docId':'DOC06950293','status':'Processed','reportFileName':'','endTime':'3','message':'','fileNo':'','requestId':''}';'
	String inputJsonData = '"transactionID":"trans1223","docId":"DOC06950293","status":"Processed","reportFileName":"","endTime":"3","message":"","fileNo":"","requestId":""}';

        // Mock the REST request
        RestRequest request = new RestRequest();
       // request.params.put('data', inputJsonData);
        //request.setHeader('Authorization', 'Bearer 00DBi0000007KA5!AQEAQJG0nFQMjJubJVQEMmM45qkfT7qm_HzWbIZ9UhuuCTrqjl8Wg.AeiqSb7bS7LqERm25e_G5O6pD1XF4LV8gBLA03.jgf');
        RestContext.request = request;
        Test.startTest();
        // Call the method being tested
        try{
            //String result = CallBackBankStatement.createDocument();
            CallBackBankStatement.responseWrapper response =CallBackBankStatement.createDocument();
        }catch(Exception e){
        
        }
        Test.stopTest();
       
       
    } 
}