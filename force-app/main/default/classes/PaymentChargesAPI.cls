@RestResource(urlMapping = '/PaymentChargesAPI/*')
global with sharing class PaymentChargesAPI {
    @HttpPost
    global static void calculateCharges(){
        Restresponse res = RestContext.response;

        try{
            String requestBody = RestContext.request.requestBody.toString();
            System.debug('Request Body - '+ requestBody);

            Map<String,String> requestWrap = (Map<String,String>)JSON.deserialize(requestBody, Map<String,String>.Class);
            system.debug('Wrapper Deserialized'+ requestWrap);

            if(!requestWrap.isEmpty() && requestWrap.containsKey('caseId')){
                Case caseRec = [SELECT Id,Subject,SR_Sub_Type__c,Account.Name,Collateral_Swap_Charges__c,FC_Statement_Charge__c,Balance_Due_for_Forclosure__c,
                            NACH_Swap_charges__c,Document_Handling_Fees__c, Account.PersonEmail,Account.Phone,
                            LAN__r.Loan_Application_Number__c,LAN__r.Loan_Segment__c FROM Case
                            WHERE Id = :requestWrap.get('caseId')];
                if(caseRec != null){
                    PaymentResponse pr = new PaymentResponse();
                    System.debug('Case :'+caseRec);
                    pr.PaymentType = caseRec.SR_Sub_Type__c;
                    pr.AccountName = caseRec.Account.name;
                    pr.Amount = caseRec.Collateral_Swap_Charges__c + caseRec.NACH_Swap_charges__c + caseRec.FC_Statement_Charge__c + caseRec.Document_Handling_Fees__c + caseRec.Balance_Due_for_Forclosure__c;
                    pr.LAN = caseRec.LAN__r.Loan_Application_Number__c;
                    pr.Segment = caseRec.LAN__r.Loan_Segment__c;
                    pr.Email = caseRec.Account.PersonEmail;
                    pr.Mobile = caseRec.Account.Phone;
                    if(pr != null){
                        res.statusCode = 200;
                        res.responseBody = Blob.valueOf(JSON.serialize(pr));
                    }
                }else{
                    res.statusCode = 500;
                    res.responseBody = Blob.valueOf(JSON.serialize('{"errorMessage": "Case does not exist","status": "failure"}'));
                }
            }
        } catch (Exception e){
            //Returning Error if any exception has occured
            system.debug('Exception Line Number'+e.getLineNumber());
            system.debug('Exception Message'+e.getMessage());
            RestResponse restResponse = RestContext.response;
            res.statusCode = 500;
            Blob.valueOf(JSON.serialize(e.getMessage()));
        }
    }

    public class PaymentResponse {
        public String PaymentType;
        public String AccountName;
        public Decimal Amount;
        public String LAN;
        public String Segment;
        public String Mobile;
        public String Email;
    }
}