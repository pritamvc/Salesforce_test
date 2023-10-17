@IsTest
private class TestLeadLoanRequirements {
    
    @IsTest
    public static void testGetWrapperClassApplicationForm() {
        // Create test data
        Lead testLead = new Lead(
            FirstName = 'John',
            LastName = 'Doe',
            Company = 'Test Company',
            Status = 'Open',
            Language_Test_Score__c = 80,
            Tuition_Fees__c = 10000,
            Living_Hostel_Food_Expenses__c = 5000,
            Traveling_Expenses__c = 2000,
            Other_Costs__c = 1000,
            Own_Source__c = 5000,
            Scholarship__c = 3000,
            Others_Fund__c = 2000
           
        );
        insert testLead;
        
        // Call the method being tested
        Test.startTest();
        LeadLoanRequirements.wrapperClassApplicationForm result = LeadLoanRequirements.getWrapperClassApplicationForm(testLead.Id);
        Test.stopTest();
        
        // Verify the results
        System.assertEquals(testLead.Id, result.LeadLoanRecords.Id, 'The Lead Id should match');
        // Add additional assertions for other properties if needed
    }
    
    @IsTest
    static void testSaveUpdateLoanOnLead() {
        // Create test data
        Lead testLead = new Lead(
            FirstName = 'John',
            LastName = 'Doe',
            Company = 'Test Company',
            Status = 'Open'
        );
        insert testLead;
        
        LeadLoanRequirements.wrapperClassApplicationForm wrapper = new LeadLoanRequirements.wrapperClassApplicationForm();
        wrapper.LeadLoanRecords = testLead;
        wrapper.loanSectionLeadRec = JSON.serialize(testLead);
        
        // Call the method being tested
        Test.startTest();
        String leadId = LeadLoanRequirements.saveUpdateLoanOnLead(JSON.serialize(wrapper));
        Test.stopTest();
        
        // Verify the results
       // Lead updatedLead = [SELECT Id, Lead_form_Weightage__c FROM Lead WHERE Id = :leadId];
        //System.assertEquals(9.375, updatedLead.Lead_form_Weightage__c, 'The Lead form weightage should be updated');
    }
}