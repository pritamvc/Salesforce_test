public class leadDataDisplay {
@AuraEnabled(cacheable=true)
public static Account getAccountDetails(String recordId ){
    system.debug('recordId'+recordId);

		Account eachAccount = new Account();

		if (Account.sObjectType.getDescribe().isAccessible() && Schema.sObjectType.Account.fields.Name.isAccessible()){

			eachAccount = [SELECT Id, Account_Name_Formula__c,Father_First_Name__c,Father_Last_Name__c,PersonMobilePhone

			  FROM Account

			  WHERE Id =: recordId ];

		}

		return eachAccount;
    

	}
      @AuraEnabled
    public static void updateAccount(string recordId, String Account_Name_Formula, String Father_First_Name ,String Father_Last_Name , String PersonMobilePhone) {
      	Account acc = new Account();

		if (Account.sObjectType.getDescribe().isAccessible() && Schema.sObjectType.Account.fields.Name.isAccessible()){

			acc = [SELECT Id, Account_Name_Formula__c,Father_First_Name__c,Father_Last_Name__c,PersonMobilePhone

			  FROM Account

			  WHERE Id =: recordId ];
            acc.Father_First_Name__c=Father_First_Name;
            acc.PersonMobilePhone=PersonMobilePhone;

		}

		Update acc;
    
     }

}