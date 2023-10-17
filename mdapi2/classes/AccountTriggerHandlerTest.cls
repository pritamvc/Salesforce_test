@IsTest
public class AccountTriggerHandlerTest {
    
    @IsTest
    public static void testAccountDedupe() {
        // Create test data
        Account accrecrds1 =TestDataFactory.createAccount2(true);
        Account accrecrds2 =TestDataFactory.createAccount1(true);
        List<Account> newAccountList = new List<Account>{accrecrds1, accrecrds2};
           
            // Call the method to test
            Test.startTest();
        AccountTriggerHandler.accountDedupe(newAccountList);
        Test.stopTest();
        
        // Add duplicate data
        accrecrds1.Name = 'Duplicate Account';
        
    }
    
    @IsTest
    public static void testGetDuplicateAccount() {
        // Create test data
        Account accrecrds1 =TestDataFactory.createAccount2(true);
        Account accrecrds2 =TestDataFactory.createAccount1(true);
    
        List<Account> newAccountList = new List<Account>{accrecrds1, accrecrds2};
         
        // Call the method to test
        Test.startTest();
        List<Account> duplicateAccounts = AccountTriggerHandler.getDuplicateAccount(newAccountList);
        Test.stopTest();
        
        accrecrds2.Name = 'Duplicate Account';
        
    }

    @IsTest
    public static void testAccountTriggerBeforeInsert() {
        // Test data
        Account accrecrds1 =TestDataFactory.createAccount2(true);
        Account accrecrds2 =TestDataFactory.createAccount1(true);
        Test.startTest();
        Test.stopTest();
        
        // Perform assertions here to verify the expected behavior
    }
    
    @IsTest
    public static void testAccountTriggerBeforeUpdate() {
        // Test data
         Account accrecrds1 =TestDataFactory.createAccount2(true);
        Account accrecrds2 =TestDataFactory.createAccount1(true);        
        Test.startTest();
        update accrecrds2;
        Test.stopTest();
        
    }
}