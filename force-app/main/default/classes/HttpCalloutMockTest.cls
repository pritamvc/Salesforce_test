@isTest
public class HttpCalloutMockTest implements HttpCalloutMock{
    public String requestType = '';
    public HttpCalloutMockTest(){
    }
    
    public HttpCalloutMockTest(String requestType){
        this.requestType = requestType;
    }
    
    public HTTPResponse respond(HTTPRequest req){
        HttpResponse response = new HttpResponse();
        if(requestType =='InterestStatement'){
            String body = '';
            body =  '{"dataResponse":{"finReference":"100219000454","docContent":"JVBERi0xLjUNCjQgMCBvYmo","returnStatus":{"returnCode":"0000","returnText":"Success"}},"message":"Request Completed Successfully.","status":"Success","statusCode": 101}';
            
            response.setHeader('Content-Type', 'application/json');
            response.setBody(body);
            response.setStatusCode(200);
        }else if(requestType == 'CaseEmailPhoneVerificationTest'){
            String body = '';
            body = '{"access_token":"w7587w4eiyfsudg"}';
            response.setHeader('Content-Type', 'application/json');
            response.setBody(body);
            response.setStatusCode(200);
        }else if(requestType == 'GetIFSCDetailsAPI'){
			String body = '';
            body = '{ "dataResponse": [ { "CUST_ID": "CU0000000000902518901", "IFSC": "BARB0DBCKOP", "BNK_AC_ID": "16", "NACH_STATUS": "SUCCESS", "INSTALL_PERCENT": "100", "TRAN_ID": "1820700796", "NACH_STATUS_DATE": "2022-06-13 01:08:35.0", "AUX_BNK_CODE": "12", "MOBILE_NO1": "9833999166", "COLL_END_AT": "", "STRT_MTH": "2022-06-13 00:00:00.0", "MOBILE_NO2": "", "ACC_NUM": "99650100006881", "MICR": "400012304", "END_MTH": "2032-07-13 00:00:00.0", "REC_CRT_DT": "", "COLL_FRQ": "MNTH", "COLL_MAX_AMT": "58728", "ACCOUNT_HOLDER_NAME": "Ajay Udayraj Yadav", "WI_NAME": "LOS-00000000009025189-PROCESS", "NPCI_BNK_DC_CODE": "12870", "EMAIL_ID2": "", "ACC_TYPE": "Savings Account", "APPLICATION_NO": "100219025189", "BRANCH_NAME": "CHARKOP", "EMAIL_ID1": "ajayyadav01@gmail.com", "NPCI_BNK_NETB_CODE": "9490", "BANK_NAME": "BANK OF BARODA", "COLL_TYPE": "M" } ], "message": "All Request Completed Successfully.", "transactionid": "nachSetup21938", "status": "Success", "statusCode": 101 }';
            response.setHeader('Content-Type', 'application/json');
            response.setBody(body);
            response.setStatusCode(200);            
        }else if(requestType == 'access_token'){
            String body = '';
            body = '{"access_token":"w7587w4eiyfsudg"}';
            response.setHeader('Content-Type', 'application/json');
            response.setBody(body);
            response.setStatusCode(200);
        }else if(requestType == 'Penny_Drop')
        {
            String body = '';
            body = '{"dataResponse":{"result":{"bankTxnStatus": true,"accountName": "Mr  HARSHVARDHAN SHR","accountNumber": "35939548644","ifsc": "SBIN0012842","bankResponse": "Transaction Successful"},"status-code": "101","request_id": "38e5eee3-5eac-4729-9ce2-74c14b5a78a9"},"message": "Request Completed Successfully.","transactionid": "pennyDrop1033","status": "Success","statusCode": 101}';
            response.setHeader('Content-Type', 'application/json');
            response.setBody(body);
            response.setStatusCode(200);
        }
        return response;
        
    }
}