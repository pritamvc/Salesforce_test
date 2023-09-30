public class AccountController{
    @AuraEnabled
    public static List<Account> getPendingAccounts() {
        return [SELECT Id,Name, AccountNumber,Rating,IsDocumentComplete__c,Industry from Account];
    }
}