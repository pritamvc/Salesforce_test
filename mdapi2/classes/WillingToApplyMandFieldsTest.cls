/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-24-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@IsTest
public class WillingToApplyMandFieldsTest {
    @IsTest
    public static void testGetWTAMandField() {
        // Create test data
         Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        List<Lead> testLeads = new List<Lead>();
        Source__c sourceObj =  new Source__c();
        sourceObj.Name = 'XYZ';
        insert sourceObj;
        Lead lrecrds=TestDataFactory.createLead(true);
        lead leadrecrds = new lead();
        leadrecrds.Source_Name__c = sourceObj.Id;
        leadrecrds.LastName = 'JadhavtEST';
        //insert leadrecrds;
        testLeads.add(lrecrds);
   

        // Call the method to be tested
        List<String> leadIds = new List<String>();
        for (Lead testLead1 : testLeads) {
            leadIds.add(testLead1.Id);
        }
        Test.startTest();
        List<WillingToApplyMandFields.LeadWrapper> result = WillingToApplyMandFields.getWTAMandField(leadIds);
        Test.stopTest();

        // Verify the result
        System.assertEquals(testLeads.size(), result.size(), 'Incorrect result size');
        for (Integer i = 0; i < result.size(); i++) {
            WillingToApplyMandFields.LeadWrapper wrapper = result[i];
            Lead testLead2 = testLeads[i];

            // Verify the Lead object
            System.assertEquals(lrecrds.Id, wrapper.lead.Id, 'Incorrect Lead Id');

            // Verify the nullFieldLabels
            List<String> nullFieldLabels = wrapper.nullFieldLabels;
          
        }
    }
}