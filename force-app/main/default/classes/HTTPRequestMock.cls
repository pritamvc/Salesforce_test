/**
 * Author: Sohail Solapure
 * @description This class is used to mock HTTP requests for testing purposes.
 * 
 * @description This mock class is intended for use in testing scenarios where HTTP callouts need to be mocked.
 * It implements the HttpCalloutMock interface and provides a way to simulate HTTP responses and behavior.
 * @return No return value.
 */
@isTest
public class HTTPRequestMock implements HttpCalloutMock {
    protected String status;
    protected String bodyAsString;
    private Integer calloutCounter = 0;

    /**
     * Author: Sohail Solapure
     * @description This constructor is used to initialize an instance of the HTTPRequestMock class.
     * 
     * This constructor takes a parameter 'status', which is used to define the desired HTTP response status
     * for the mocked HTTP request. It allows customization of the response behavior for testing purposes.
     * 
     * @param status The desired HTTP response status to be simulated.
     */
    public HTTPRequestMock(String status){
        this.status = status;
    }

    /**
     * Author: Sohail Solapure
     * @description This constructor is used to initialize an instance of the HTTPRequestMock class.
     * 
     * This constructor does not require any parameters and can be used to create an instance of the
     * HTTPRequestMock class for simulating HTTP requests in a test scenario.
     */
    public HTTPRequestMock(){
    }

    /**
     * Author: Sohail Solapure
     * @description This method is used to provide a simulated HTTP response for the mock request.
     * 
     * This method takes an HTTPRequest object as input and generates a simulated HTTP response
     * for the mock request. The generated response can be customized for testing purposes.
     * 
     * @param request The HTTPRequest object representing the mock request.
     * @return HTTPResponse The simulated HTTP response for the mock request.
     */
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
         calloutCounter++;
        if(request.getEndpoint() == LOSConstants.ENDPOINT+'/api/oauth2/token'){
            bodyAsString = '{"access_token": "bCaREZW9CyTcLsjC9S7aBB9BlzFZPfYV","expires_in": 7200,"refresh_token": "Be58ELIzrjHBPJUkfo22BPGfd2XjCQn2","token_type": "bearer"}';
        }
        else if(request.getEndpoint() == LOSConstants.ENDPOINT+'/los/leadInfo'){
            if(this.status == 'createWorkItemFails'){
                bodyAsString = '{"dataResponse":"Record was Successfully inserted.","message":"Request Completed Successfully.","transactionid":"leadInfo7531","status":"Failure","statusCode":102}';  
            }else{
                bodyAsString = '{"dataResponse":"Record was Successfully inserted.","message":"Request Completed Successfully.","transactionid":"leadInfo7531","status":"Success","statusCode":101}';  
            }
        }
        else if(request.getEndpoint() == LOSConstants.ENDPOINT+'/los/assetDetails'){
            bodyAsString = '{"dataResponse":"Record was Successfully inserted.","message":"Request Completed Successfully.","transactionid":"assetDetails7283","status":"Success","statusCode":101}';
        }
        else if(request.getEndpoint() == LOSConstants.ENDPOINT+'/los/bankAccount'){
            bodyAsString = '{"dataResponse":"Record was Successfully inserted.","message":"Request Completed Successfully.","transactionid":"bankAccount7279","status":"Success","statusCode":101}';
        }   
        else if(request.getEndpoint() == LOSConstants.ENDPOINT+'/los/credit'){
            bodyAsString = '{"dataResponse":"Record was Successfully inserted.","message":"Request Completed Successfully.","transactionid":"credit7285","status":"Success","statusCode":101}';
        } 
        else if(request.getEndpoint() == LOSConstants.ENDPOINT+'/los/courseDetail'){
            bodyAsString = '{"dataResponse":"Record was Successfully inserted.","message":"Request Completed Successfully.","transactionid":"courseDetail7263","status":"Success","statusCode":101}';
        }
        else if(request.getEndpoint() == LOSConstants.ENDPOINT+'/newgen/createworkitem/createWorkitem' || request.getEndpoint() == LOSConstants.ENDPOINT+'/newgen-new/createworkitem/createWorkitemNew'){
            if(this.status == 'createWorkItemFails'){
                bodyAsString = '{"dataResponse":"<LosWebservice_Output><Option>WFUploadWorkItem</Option><Exception><MainCode>0</MainCode></Exception><ProcessInstanceId>null</ProcessInstanceId><WorkStageId>1</WorkStageId><CreationDateTime>2023-05-24 19:33:25</CreationDateTime><FolderIndex></FolderIndex><ApplicationNumber></ApplicationNumber></LosWebservice_Output>","message":"Request Completed Successfully.","transactionid":"createWorkitem5854","status":"Failure","statusCode":102}';
            }else if(this.status == 'createWorkItemFailure'){
                bodyAsString = '{"dataResponse":"<LosWebservice_Output><Option>WFUploadWorkItem</Option><Exception><MainCode>0</MainCode></Exception><ProcessInstanceId></ProcessInstanceId><WorkStageId>1</WorkStageId><CreationDateTime>2023-05-24 19:33:25</CreationDateTime><FolderIndex></FolderIndex><ApplicationNumber></ApplicationNumber></LosWebservice_Output>","message":"Request Completed Successfully.","transactionid":"createWorkitem5854","status":"Failure","statusCode":102}';
                response.setBody(bodyAsString);
                response.setStatus('Fail');
                response.setStatusCode(400);
                return response;
            }
            else{
                bodyAsString = '{"dataResponse":"<LosWebservice_Output><Option>WFUploadWorkItem</Option><Exception><MainCode>0</MainCode></Exception><ProcessInstanceId>LOS-00000000009028478-PROCESS</ProcessInstanceId><WorkStageId>1</WorkStageId><CreationDateTime>2023-05-24 19:33:25</CreationDateTime><FolderIndex>37640</FolderIndex><ApplicationNumber>100419028478</ApplicationNumber></LosWebservice_Output>","message":"Request Completed Successfully.","transactionid":"createWorkitem5854","status":"Success","statusCode":101}';
            }
        }
        else if(request.getEndpoint() == LOSConstants.ENDPOINT+'/los/addressDetail'){
            bodyAsString = '{"dataResponse":"Record was Successfully inserted.","message":"Request Completed Successfully.","transactionid":"addressDetail7280","status":"Success","statusCode":101}';
        }
        else if(request.getEndpoint() == LOSConstants.ENDPOINT+'/los/gridDetails'){
            bodyAsString = '{"dataResponse":"Record was Successfully inserted.","message":"Request Completed Successfully.","transactionid":"gridDetails7281","status":"Success","statusCode":101}';
        }
        else if(request.getEndpoint() == LOSConstants.ENDPOINT+'/los/custNiReference'){
            bodyAsString = '{"dataResponse":"Record was Successfully inserted.","message":"Request Completed Successfully.","transactionid":"custNiReference7267","status":"Success","statusCode":101}';
        }
        else if(request.getEndpoint() == LOSConstants.ENDPOINT+'/los/dataTransfer'){
            bodyAsString = '{"dataResponse":"Record was Successfully inserted.","message":"Request Completed Successfully.","transactionid":"dataTransfer7286","status":"Success","statusCode":101}';
        }
        else if(request.getEndpoint() == LOSConstants.ENDPOINT+'/los_crud/preEduDetails?Action=Add'){
            bodyAsString = '{"dataResponse":"Record was Successfully inserted.","message":"Request Completed Successfully.","transactionid":"preEduDetails924","status":"Success","statusCode":101}';
        }
        else if(request.getEndpoint() == LOSConstants.ENDPOINT+'/los/employment'){
            bodyAsString = '{"dataResponse":"Record was Successfully inserted.","message":"Request Completed Successfully.","transactionid":"employment7275","status":"Success","statusCode":101}';
        }
        else if(request.getEndpoint() == LOSConstants.ENDPOINT+'/los/immovable'){
            bodyAsString = '{"dataResponse":"Record was Successfully inserted.","message":"Request Completed Successfully.","transactionid":"immovable7282","status":"Success","statusCode":101}';
        }
        else if(request.getEndpoint() == LOSConstants.ENDPOINT+'/los/movable'){
            bodyAsString = '{"dataResponse":"Record was Successfully inserted.","message":"Request Completed Successfully.","transactionid":"movable7282","status":"Success","statusCode":101}';
        }
        else if(request.getEndpoint() == LOSConstants.ENDPOINT+'/los/liabilityDetails'){
            bodyAsString = '{"dataResponse":"Record was Successfully inserted.","message":"Request Completed Successfully.","transactionid":"liabilityDetails7282","status":"Success","statusCode":101}';
        }
        else if(request.getEndpoint() == LOSConstants.ENDPOINT+'/los/personalDetail'){
            bodyAsString = '{"dataResponse":"Record was Successfully inserted.","message":"Request Completed Successfully.","transactionid":"personalDetail7215","status":"Success","statusCode":101}';
        }
        else if(request.getEndpoint() == LOSConstants.ENDPOINT+'/los_crud/examScore?Action=Add'){
            bodyAsString = '{"dataResponse":"Record was Successfully inserted.","message":"Request Completed Successfully.","transactionid":"examScore918","status":"Success","statusCode":101}';
        }
        else if(request.getEndpoint() ==  'callout:DMS_Api'){
            if(this.status == 'DMSFail'){
                bodyAsString = '{"dmsStatusCode":"0","message":"Request Completed Successfully.","documentVersionNo":"1.0","transactionid":"dmsUtility973","statusCode":102,"documentIndex":"","status":"Failure"}';
            }else{
                bodyAsString = '{"dmsStatusCode":"0","message":"Request Completed Successfully.","documentVersionNo":"1.0","transactionid":"dmsUtility973","statusCode":101,"documentIndex":"807387","status":"Success"}';
            }
        }

        else if(request.getEndpoint() == 'callout:Bank_Statement_Analysis_API'+'/api/uploadBinary'){
            bodyAsString = '{"docId": "DOC05431212","status": "Submitted","message": null,"periodStart": null,"periodEnd": null,"documents": null,"fileName": "test.pdf","uploadTime": 1685612728141,"ocrFile": false,"fileCount": 1,"totalPages": 3,"error": false}';
            response.setStatusCode(200);
            response.setStatus('Success');
            response.setBody(bodyAsString);
            return response;
        }
        else if(request.getEndpoint() == 'callout:LOS_API/tssapi/tssAml'){
            if(this.status == 'SUCCESS'){
              bodyAsString = '{"Matched":"Not_Match","RequestId":"8489194291107","ResponseId":"1803968","ScreeningResults":"[]","AlertCount":0,"message":"Request Completed Successfully.","transactionid":"tssAml285","RequestStatus":"Accepted_By_TrackWizz","status":"Success","statusCode":101," doccontent":"JVBERi0xLjcKJeLjz9MKNSAwIG9iago8PC9GaWx0ZXIvRmxhdGVEZWNvZGUvTGVuZ3RoIDM4Mz4+c3RyZWFtCnicfVNNT8JAFLzvr3je8MC6H92v3kTAkCBqWYk30rSrgAICJUR/vW0ptiXS9tBM8mbey8x0gzoW3fQpUAb2DXGNBShDsOZgY9S6fXkdDB+hPxiNe8GkB08TC0PbvbYL1LPoGW0QgewN7hFJmQfEJSjNMVOwREKYE/hE4wvTmgisRDFdgIvTmImScITNC4TQ2XBlSY7PSIUFjJQWCINN5sBRb/uOWqNw6XxIn7uZS8JVxYJ/6Exgj9f5D2ESzVzsw2idTHPQKCHTEIysSwRus3e7BAZdH7SnDTUeM5QS1awkJPbMudLua73auVyKasKN1E2h5k57GuuKhzlsjEpRD3NeoRxxI0cqg7UsOQW+XCDpCcxNUaACNF916mexsJFSL0x5VZ2Um86AHk1Pb+IpW+eWY0FomuP5txpnN0zc1M6zejHCeJvoNkt/SOoT5QtxMVsJwihMvGwNrSS7cFHiYuh8g92G0cdh/vNzlZYOAhettzH01/tVjP9UfwHT+951CmVuZHN0cmVhbQplbmRvYmoKNCAwIG9iago8PC9Db250ZW50cyA1IDAgUi9NZWRpYUJveFswIDAgNTk1IDg0Ml0vUGFyZW50IDIgMCBSL1Jlc291cmNlczw8L0ZvbnQ8PC9GMSA2IDAgUi9GMiA3IDAgUj4+Pj4vVHJpbUJveFswIDAgNTk1IDg0Ml0vVHlwZS9QYWdlPj4KZW5kb2JqCjEgMCBvYmoKPDwvUGFnZXMgMiAwIFIvVHlwZS9DYXRhbG9nPj4KZW5kb2JqCjMgMCBvYmoKPDwvQ3JlYXRpb25EYXRlKEQ6MjAyMzA4MjExMTA3NTUrMDUnMzAnKS9Nb2REYXRlKEQ6MjAyMzA4MjExMTA3NTUrMDUnMzAnKS9Qcm9kdWNlcihpVGV4dK4gNy4xLjE2IKkyMDAwLTIwMjEgaVRleHQgR3JvdXAgTlYgXChBR1BMLXZlcnNpb25cKSk+PgplbmRvYmoKNiAwIG9iago8PC9CYXNlRm9udC9IZWx2ZXRpY2EtQm9sZC9FbmNvZGluZy9XaW5BbnNpRW5jb2RpbmcvU3VidHlwZS9UeXBlMS9UeXBlL0ZvbnQ+PgplbmRvYmoKNyAwIG9iago8PC9CYXNlRm9udC9IZWx2ZXRpY2EvRW5jb2RpbmcvV2luQW5zaUVuY29kaW5nL1N1YnR5cGUvVHlwZTEvVHlwZS9Gb250Pj4KZW5kb2JqCjIgMCBvYmoKPDwvQ291bnQgMS9LaWRzWzQgMCBSXS9UeXBlL1BhZ2VzPj4KZW5kb2JqCnhyZWYKMCA4CjAwMDAwMDAwMDAgNjU1MzUgZiAKMDAwMDAwMDYwNyAwMDAwMCBuIAowMDAwMDAwOTkxIDAwMDAwIG4gCjAwMDAwMDA2NTIgMDAwMDAgbiAKMDAwMDAwMDQ2NSAwMDAwMCBuIAowMDAwMDAwMDE1IDAwMDAwIG4gCjAwMDAwMDA4MTAgMDAwMDAgbiAKMDAwMDAwMDkwMyAwMDAwMCBuIAp0cmFpbGVyCjw8L0lEIFs8NGY1NmRkZjI4N2I5ZDBjZTJmODJkMmFhMDM5ZWNhY2I+PDRmNTZkZGYyODdiOWQwY2UyZjgyZDJhYTAzOWVjYWNiPl0vSW5mbyAzIDAgUi9Sb290IDEgMCBSL1NpemUgOD4+CiVpVGV4dC03LjEuMTYKc3RhcnR4cmVmCjEwNDIKJSVFT0YK"}';  
            }else if(this.status == 'FAILURE'){
              bodyAsString = '{"Matched":"Error","RequestId":"5619363151150","ResponseID":"1804872","RejectionCode":"RC694","ScreeningResults":"[]","RejectionMessage":"RC694 : PAN is incorrect.The expected format is 5 charaters, 4 numbers and 1 charater (eg: Dummy1234D).","AlertCount":0,"message":"Request Completed Successfully.","transactionid":"tssAml394","status":"Failure","statusCode":102,"RequestStatus":"Rejected_By_TrackWizz"}';
            }
            
            response.setStatusCode(200);
            response.setStatus('Success');
            response.setBody(bodyAsString);
            return response;
        }
        else if(request.getEndpoint() == 'callout:LOS_API/karza/pennyDrop')
        {
            if(this.status == 'SUCCESS'){
            bodyAsString = '{"dataResponse":{"result":{"bankTxnStatus": true,"accountName": "Mr  HARSHVARDHAN SHR","accountNumber": "35939548644","ifsc": "SBIN0012842","bankResponse": "Transaction Successful"},"status-code": "101","request_id": "38e5eee3-5eac-4729-9ce2-74c14b5a78a9"},"message": "Request Completed Successfully.","transactionid": "pennyDrop1033","status": "Success","statusCode": 101}';
        }
            response.setStatusCode(200);
            response.setStatus('Success');
            response.setBody(bodyAsString);
            return response;
        }
        else if(request.getEndpoint() == 'callout:Bank_Statement_Analysis_API'+'/api/downloadFile'){
            bodyAsString = '{"docId": "DOC05419923","status": "Downloaded","message": null,"periodStart": null,"periodEnd": null,"documents": null,"data": [{"bankName": "ICICI","bankFullName": "ICICI Bank Ltd","accountNumber": "136701513149","accountName": "SWATI YADAV","ifscCode": "ICIC0001367","accountType": "Saving","accountOpeningDate": null,"productType": null,"periodStart": "29/04/2023","periodEnd": "29/05/2023","address": "B/65,SHRI HARI KRISHNA ,PARK SOCIETY OPP , GHODASAR,CADILA RLY CROSSING AHMEDABAD GUJARAT - INDIA - 380050","email": null,"mobileNumber": null,"panNumber": null,"monthsEvaluated": 2,"documentType": "Statement","camAnalysisData": {"odCcLimit": 0.0,"inwardReturnCount": 0,"outwardReturnCount": 0,"inwardReturnAmount": 0.0,"outwardReturnAmount": 0.0,"totalNetCredits": 581539.0,"averageBalance": 230641.98935483882,"customAverageBalance": 235456.28428571433,"customAverageBalanceLastThreeMonth": 235456.28428571433,"averageBalanceLastThreeMonth": 230641.98935483882,"averageBalanceLastSixMonth": 230641.98935483882,"averageBalanceLastTwelveMonth": 230641.98935483882,"averageReceiptLastSixMonth": 290769.5,"averageReceiptLastTwelveMonth": 290769.5,"salaryCreditCountLastThreeMonth": 0,"salaryCreditCountLastSixMonth": 0,"minBalanceLastThreeMonth": 168018.57,"minBalanceLastSixMonth": 168018.57,"minBalanceChargeCountLastSixMonth": 0}}]}';
            response.setStatusCode(200);
            response.setStatus('Success');
            response.setBody(bodyAsString);
            return response;
        }
        else if(request.getEndpoint() == 'callout:Bank_Statement_Analysis_API'+'/api/downloadFileAsExcel'){   
            if (calloutCounter == 1) {
                bodyAsString = '{"docId": "DOC05419923","status": "Downloaded" }';
                response.setStatusCode(500);
                response.setStatus('Success');
                response.setBody(bodyAsString);
                return response;
            }
            else  {
                bodyAsString = '{"docId": "DOC05419923","status": "Downloaded" }';
                response.setStatusCode(204);
                response.setStatus('Success');
                response.setBody(bodyAsString);
                return response;
            }
        }
        else if(request.getEndpoint() == 'callout:karzaAPI'+'/ocr-plus/kyc'){
            if(this.status == 'AADHAR BACK'){
                bodyAsString = '{"requestId":"3e99988f-78fa-4346-8167-6dc91d5f6c5c","result":{"documents":[{"documentType":"AADHAAR","subType":"BACK","pageNo":1,"ocrData":{"aadhaar":{"value":"********2192","confidence":1.0},"address":{"value":"AadarshaNagar,NavinVasahat,Supa,Ahmadnagar,Maharashtra414301","confidence":1.0},"pin":{"value":"414301","confidence":1.0},"vid":{"value":"","confidence":0}},"additionalDetails":{"inputMaskStatus":{"isMasked":false,"maskedBy":null,"confidence":null},"outputMaskStatus":true,"verhoeffCheck":true,"qr":null,"barcode":null,"addressSplit":{"building":"","city":"Supa","district":"AhmedNagar","pin":"414301","floor":"","house":"","locality":"AadarshaNagar","state":"Maharashtra","street":"","complex":"","landmark":"","untagged":"NavinVasahat"},"careOfDetails":{"relation":"FATHER","name":""}},"qualityChecks":[{"score":0.74,"flag":false,"type":"BRIGHTNESS"},{"score":0.0,"flag":false,"type":"BLACK_AND_WHITE"},{"score":0.29,"flag":false,"type":"BLUR"},{"score":0.0,"flag":false,"type":"CUT_CARD"}],"documentLink":"https://download.karza.in/kyc-ocr/MWorQ2lTU25PcE1SVnBRR3Q3KzV2aSsxNXhXMnJMaWJXRFRUalZOQUtwNXFBbllBZlhuVVNaTXpxTUhpZlNXNEZYOEFQdVRGVDRRdGh4STlJbVRRRXFxaTBWOEdxQlF4bWR6OFZNaWE5WEdNS0M1dW14WDFrd0tqbG5WU2crM2ZNRnJjTmJSWnAyR1dNOGplYTE2UEtHbUliRUZyOU1DZ25yQlhmV2o3RHlrQUF0eGR6cCtZcEprbU9RdjNQVGE1SlJMU1dHemJuL0ZyOHJJVUtHZnYxQT09"}]},"statusCode":101}';  
            }else if(this.status == 'AADHAR FRONT'){
                bodyAsString = '{"requestId":"749b5092-4b09-47a8-a60a-036624d22c4d","result":{"documents":[{"documentType":"AADHAAR","subType":"FRONT_BOTTOM","pageNo":1,"ocrData":{"aadhaar":{"value":"********9973","confidence":1.0},"dob":{"value":"29/03/1996","confidence":1.0},"father":{"value":"GOKULSING PATIL","confidence":0},"gender":{"value":"MALE","confidence":1.0},"husband":{"value":"","confidence":0},"mother":{"value":"","confidence":0},"name":{"value":"Rajendra Akshay Patil","confidence":1.0},"vid":{"value":"","confidence":0},"yob":{"value":"","confidence":0}},"additionalDetails":{"inputMaskStatus":{"isMasked":false,"maskedBy":null,"confidence":null},"outputMaskStatus":true,"verhoeffCheck":true,"qr":null,"barcode":null},"qualityChecks":[{"score":0.62,"flag":false,"type":"BRIGHTNESS"},{"score":0.0,"flag":false,"type":"BLACK_AND_WHITE"},{"score":0.41,"flag":false,"type":"BLUR"},{"score":0.23,"flag":false,"type":"CUT_CARD"}],"documentLink":"https://download.karza.in/kyc-ocr/MWorQ2lTU25PcE1SVnBRR3Q3KzV2cHI5bkMzSlM2R2NOUUZ3czlGOWN1dTJzcXhXY0RVVUVwSEN1ZEVGVVIwMDZTS3pWdExUdVFmb2V5RW0zanE2YmtTZXpFQThadXJ5Ti9KNyt6S1YvT01MakNvanJoK293MmpGOVJ4WEp6Q1dQSW5pcEZoTlUvTG1nSjJxQVFCeXE5YmhKbVJLZ1N3Vk1tV21XMWJ5Wng3bjdwM0tEa2RJRHBaY3hkZnhPWWUzdlBYSU1oMEhHUkVXQUMzS09BUVJYSmpqd0E2RTBLbWk3aXZqTTZmeHF0UT0="}]},"statusCode":101}';
            }else if(this.status == 'PAN'){
                bodyAsString = '{"requestId":"070240c7-4bb7-4792-8d06-1b999a7f2a56","result":{"documents":[{"documentType":"PAN","subType":"","pageNo":1,"ocrData":{"dob":{"value":"29/03/1996","confidence":1.0},"doi":{"value":"13/09/2014","confidence":1},"father":{"value":"GOKULSING PATIL","confidence":0.91},"name":{"value":"PATIL RAJENDRA AKSHAY","confidence":1.0},"pan":{"value":"CQPPP4434G","confidence":1.0}},"additionalDetails":{},"qualityChecks":[{"score":0.7,"flag":false,"type":"BRIGHTNESS"},{"score":0.0,"flag":false,"type":"BLACK_AND_WHITE"},{"score":0.0,"flag":false,"type":"BLUR"},{"score":0.22,"flag":false,"type":"CUT_CARD"}],"documentLink":null}]},"statusCode":101}';
            }else if(this.status == 'PASSPORT BACK'){
                bodyAsString = '{"requestId":"b9a36277-c273-4e74-a831-97b34cca744b","result":{"documents":[{"documentType":"PASSPORT","subType":"BACK","pageNo":1,"ocrData":{"father":{"value":"RAJENDRA AKSHAY PATIL","confidence":1.0},"fileNumber":{"value":"PNM066859068422","confidence":0.92},"mother":{"value":"AKSHAY PATIL","confidence":1.0},"oldDoi":{"value":"","confidence":0.0},"oldPassportNumber":{"value":"","confidence":0.0},"oldPlaceOfIssue":{"value":"","confidence":0.0},"passportNumber":{"value":"W5257680","confidence":0.95},"pin":{"value":"416115","confidence":0.8},"spouse":{"value":"","confidence":0.0},"address":{"value":"24/9,DATTMANDIRPATHIMAGE,DATTNAGAR,ICHALKARANJI,KOLHAPUR,PIN:416115,MAHARASHTRA,INDIA","confidence":0.96}},"additionalDetails":{"addressSplit":{"building":"DATTMANDIR","city":"","district":"Kolhapur","pin":"416115","floor":"","house":"24/9","locality":"DATTNAGARICHALKARANJI","state":"Maharashtra","street":"","complex":"","landmark":"","untagged":"PIN:"}},"qualityChecks":[{"score":0.63,"flag":false,"type":"BRIGHTNESS"},{"score":0.0,"flag":false,"type":"BLACK_AND_WHITE"},{"score":0.37,"flag":false,"type":"BLUR"},{"score":0.29,"flag":false,"type":"CUT_CARD"}],"documentLink":null}]},"statusCode":101}';
            }else if(this.status == 'PASSPORT FRONT'){
                bodyAsString = '{"requestId":"6a7e5c4b-9caa-4116-a3fe-b600024399e3","result":{"documents":[{"documentType":"PASSPORT","subType":"FRONT","pageNo":1,"ocrData":{"countryCode":{"value":"IND","confidence":0.51},"dob":{"value":"07/03/2000","confidence":0.9},"doe":{"value":"20/09/2032","confidence":0.9},"doi":{"value":"21/09/2022","confidence":0.9},"gender":{"value":"MALE","confidence":0.87},"givenName":{"value":"RAJENDRAAKSHAYPATIL","confidence":0.51},"nationality":{"value":"","confidence":0.0},"passportNumber":{"value":"N5257680","confidence":0.7},"placeOfBirth":{"value":"LONDA,KARNATAKA","confidence":1.0},"placeOfIssue":{"value":"PUNE","confidence":1.0},"surname":{"value":"PATIL","confidence":0.51},"type":{"value":"P","confidence":0.51},"mrzLine1":{"value":"P<INDSOLAPURE<<SOHAIL<SAMIR<<<<<<<<<<<<<<<<<","confidence":0.51},"mrzLine2":{"value":"W5257680<9IND0003078M3209206M066859068422<48","confidence":0.51}},"additionalDetails":{},"qualityChecks":[{"score":0.68,"flag":false,"type":"BRIGHTNESS"},{"score":0.0,"flag":false,"type":"BLACK_AND_WHITE"},{"score":0.0,"flag":false,"type":"BLUR"},{"score":0.32,"flag":false,"type":"CUT_CARD"}],"documentLink":null}]},"statusCode":101}';
            } 
        }
        response.setStatusCode(200);
        response.setStatus('Success');
        response.setBody(bodyAsString);
        return response;
    } 
}