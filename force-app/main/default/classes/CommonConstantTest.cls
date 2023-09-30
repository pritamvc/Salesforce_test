@isTest
public class CommonConstantTest {
    @isTest
    static void testErrorMessage() {
        Integer totalLeads = 10;
        Integer duplicateLeads = 5;
        Integer insetedLeads = 5;
        String expectedErrorMessage = 'Out of 10 leads 5 are inserted and 5 have error lead.';

        String errorMessage = CommonConstant.errorMessage(totalLeads, duplicateLeads, insetedLeads);

        System.assertEquals(expectedErrorMessage, errorMessage, 'Error message should match the expected value.');
    }

    @isTest
    static void testErrorMessage_AllLeadsDuplicate() {
        Integer totalLeads = 10;
        Integer duplicateLeads = 10;
        Integer insetedLeads = 0;
        String expectedErrorMessage = 'All the leads have error hence these are not inserted in the Salesforce system.' + '\n' + 'Error has been emailed to you.';

        String errorMessage = CommonConstant.errorMessage(totalLeads, duplicateLeads, insetedLeads);

        System.assertEquals(expectedErrorMessage, errorMessage, 'Error message should match the expected value.');
    }

    @isTest
    static void testErrorMessage_AllLeadsInserted() {
        Integer totalLeads = 10;
        Integer duplicateLeads = 0;
        Integer insetedLeads = 10;
        String expectedErrorMessage = 'All Leads are inserted successfully.';

        String errorMessage = CommonConstant.errorMessage(totalLeads, duplicateLeads, insetedLeads);

        System.assertEquals(expectedErrorMessage, errorMessage, 'Error message should match the expected value.');
    }

    // Add more test methods to cover other methods and variables in the CommonConstant class.
}