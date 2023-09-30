public class Demo {
    public static void matchLeads() {
        
        
        // Create a list to store the matching records
        List<Lead> matchingRecords = new List<Lead>();

        // Loop through the records and evaluate the conditions for each record
        for (Lead record : [Select id, Status, KYC_Consent__c,Loan_Required_A_B__c  from Lead limit 5]) {
            String exp;
            Boolean isMatch = true;
            for (Campaign  condition : [Select Id,Parent.Name,Campaign_logic__c From Campaign  where Campaign_logic__c != null and id='701Bi000005kmjZIAQ' limit 1]) {
                RT_Expression expression = new RT_Expression('');
                boolean ifEvalIsTrue;
                List<String> filterLogicSplittedbySpace = condition.Campaign_logic__c.split(' ');
                String field = filterLogicSplittedbySpace[0];
                String operator = filterLogicSplittedbySpace[1];
                String objValue = filterLogicSplittedbySpace[2];
                /*for (String str : filterLogicSplittedbySpace){
                    exp +=str;
                    system.debug(str);
                }*/
                exp = String.valueOf(record.get(field)) +' '+ string.valueOf(operator)  +' '+  String.valueOf(objValue);
                System.debug('exp: ' + exp);
                expression = new RT_Expression(exp);
                if(expression.eval() == 1){
                    ifEvalIsTrue = true;
                }else{
                    ifEvalIsTrue = false;
                }
                System.debug('ifEvalIsTrue : ' + ifEvalIsTrue );
                if (ifEvalIsTrue) {
                    matchingRecords.add(record);
                }
            }
            
        }

        System.debug('Matching records: ' + matchingRecords);
        
        
    }
}