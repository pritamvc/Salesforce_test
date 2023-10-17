public class updateAccountLead {
  @AuraEnabled
    public static void updateAccount(string accountId, String accountName, String FatherFirstName,String FatherLastName, String accountPhone) {
        Account account = [SELECT Id,Name,Father_First_Name__c,Father_Last_Name__c,Phone FROM Account WHERE Id = :accountId];
        account.Name = accountName;
        account.Father_First_Name__c = FatherFirstName ;
          account.Father_Last_Name__c = FatherLastName ;
        account.Phone = accountPhone;
        update account;
     }
}