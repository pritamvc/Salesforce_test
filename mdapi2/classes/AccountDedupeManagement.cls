
/*********************************************************************************************
* @author          Thinqloud Solutions (Rohit Pardeshi)
* @description     This class we are using for Account Duplicate Management.
* @date            10/04/2023    
* @testClass: 
**********************************************************************************************/
public class AccountDedupeManagement {
    
    /********************************************************************************************************
* @author          Rohit Pardeshi
* @description     This Method is use for account Dedupe in manual case
* @param           List<Lead> newLeadList : List of new list
* @return          
*                       
* @date            10/04/2023  
********************************************************************************************************/   
    public static void accountDedupe(List<Account> newAccountList)
    {
        /*******************Put new lead data in Map*************************************/
        Map<String, Account> newAccountPan = new Map<String, Account>();
        Map<Date, Account> newAccountDOB = new Map<Date, Account>();
        Map<String, Account> newAccountAdharNumber = new Map<String, Account>();
        Map<String, Account> newAccountPassportNumber = new Map<String, Account>();
        Map<String, Account> newAccountDLNumber = new Map<String, Account>();
        Map<String, Account> newAccountVoterID = new Map<String, Account>();
        String newAadharNumber;
        String aadharLast;
        String finalAadhar;
        String errorMessage;
        Id currentAccountId;
        
        /***************Collect New Account information in MAP ***********************************************************/
        for(Account newaccount : newAccountList){
            if(newaccount.Id != null){
                currentAccountId = newaccount.Id;
            }
            if(newaccount.Aadhar_Number__c != null){
                newAadharNumber = newaccount.Aadhar_Number__c;
                if(newAadharNumber.length() == 12){
                    aadharLast = newaccount.Aadhar_Number__c.substring(8, 12);
                    finalAadhar = 'XXXXXXXX'+aadharLast;
                }
                else if(newAadharNumber.length() == 4){
                    finalAadhar = 'XXXXXXXX'+newAadharNumber;
                }
            }

            if(newaccount.PAN_Number__c != null){
               newAccountPan.put(newaccount.PAN_Number__c, newaccount); 
            }
            
            if(newaccount.Date_of_Birth__c != null){
              newAccountDOB.put(newaccount.Date_of_Birth__c, newaccount);  
            }
            
            if(newaccount.Passport_Number__c != null){
             newAccountPassportNumber.put(newaccount.Passport_Number__c, newaccount);
            }
            
            if(newaccount.Driving_License_Number__c != null){
              newAccountDLNumber.put(newaccount.Driving_License_Number__c, newaccount);  
            }
            
            if(newaccount.Voter_ID__c != null){
              newAccountVoterID.put(newaccount.Voter_ID__c, newaccount);
            }
            
        }
        
        /***************Get duplicate Account from system based on parameters********************************************/
        List<Account> dupAccounts = new List<Account>([SELECT Id, PAN_Number__c, Date_of_Birth__c, Aadhar_Number__c, Passport_Number__c,
                                                       Driving_License_Number__c, Voter_ID__c FROM Account 
                                                       WHERE ((PAN_Number__c IN :newAccountPan.keySet() 
                                                               OR (Date_of_Birth__c IN :newAccountDOB.keySet() AND Aadhar_Number__c =: finalAadhar)
                                                               OR Passport_Number__c IN :newAccountPassportNumber.keySet() OR Driving_License_Number__c IN :newAccountDLNumber.keySet()
                                                               OR Voter_ID__c IN :newAccountVoterID.keySet()) AND (PAN_Number__c != NULL OR Date_of_Birth__c != NULL
                                                               OR Aadhar_Number__c != NULL OR Passport_Number__c != NULL OR Driving_License_Number__c != NULL OR Voter_ID__c != NULL) AND Id !=: currentAccountId)]);

        /***************Collect duplicate Account as per dedupe parameter sequence wise in MAP********************************************/
        Map<String, Id> panMatch = new Map<String, Id>();
        Map<Date, Id> dobMatch = new Map<Date, Id>();
        Map<String, Id> adharMatch = new Map<String, Id>();
        Map<String, Id> passportNumberMatch = new Map<String, Id>();
        Map<String, Id> dlnumberMatch = new Map<String, Id>();
        Map<String, Id> voterIDMatch = new Map<String, Id>();
        
        for(Account dupaccount : dupAccounts)
        {
            if(dupaccount.PAN_Number__c != null){
                panMatch.put(dupaccount.PAN_Number__c, dupaccount.Id);
            }
            if(dupaccount.Date_of_Birth__c != null){
                dobMatch.put(dupaccount.Date_of_Birth__c, dupaccount.Id);
            }
            if(dupaccount.Aadhar_Number__c != null){
                adharMatch.put(dupaccount.Aadhar_Number__c, dupaccount.Id);
            }
            if(dupaccount.Passport_Number__c != null){
                passportNumberMatch.put(dupaccount.Passport_Number__c, dupaccount.Id); 
            }
            if(dupaccount.Driving_License_Number__c != null){
                dlnumberMatch.put(dupaccount.Driving_License_Number__c, dupaccount.Id);
            }
            if(dupaccount.Voter_ID__c != null){
                voterIDMatch.put(dupaccount.Voter_ID__c, dupaccount.Id); 
            }
        }
        
        /***************Check and Get exact match duplicate Account in a MAP********************************************/
        Set<Id> dupaccountId = new Set<Id>();
        Map<Id, String> duplicateSetId = new Map<Id, String>();
        
        for(Account newacc : newAccountList)
        {
            if(panMatch.containsKey(newacc.PAN_Number__c)){
                dupaccountId.add(panMatch.get(newacc.PAN_Number__c)); 
                errorMessage = CommonConstant.PAN_NUMBER_DUPLICATE;
            }
            else if(dobMatch.containsKey(newacc.Date_of_Birth__c) && adharMatch.containsKey(finalAadhar)){
                dupaccountId.add(dobMatch.get(newacc.Date_of_Birth__c));
                errorMessage = CommonConstant.AADHAR_NUMBER_DUPLICATE;
            }
            else if(passportNumberMatch.containsKey(newacc.Passport_Number__c)){
                dupaccountId.add(passportNumberMatch.get(newacc.Passport_Number__c));
                errorMessage = CommonConstant.PASSPOST_NUMBER_DUPLICATE;
            }
            else if(dlnumberMatch.containsKey(newacc.Driving_License_Number__c)){
                dupaccountId.add(dlnumberMatch.get(newacc.Driving_License_Number__c));
                errorMessage = CommonConstant.DL_NUMBER_DUPLICATE;
            }
            else if(voterIDMatch.containsKey(newacc.Voter_ID__c)){
                dupaccountId.add(voterIDMatch.get(newacc.Voter_ID__c));
                errorMessage = CommonConstant.VOTER_ID_DUPLICATE;
            } 
        }
        
        for(Account acc : newAccountList){
            if(!dupaccountId.IsEmpty() && dupaccountId.size() >0 && !dupaccountId.contains(acc.Id)){
                acc.addError(errorMessage + '. Account Id : ' +dupaccountId);
            }
        }   
    }
    
    @AuraEnabled
    public static Account getDupAccountCommunityForm(String adharNumber, String panNumber, Date dateOfBirth){
        Account acc = new Account();
        return acc;
    }
}