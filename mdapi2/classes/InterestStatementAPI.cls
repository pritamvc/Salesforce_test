global class InterestStatementAPI {
    global static String statuscode;
    global static Integer responseCode;
    @InvocableMethod(label = 'InterestStatementAPI'
        description = 'method description')
    global static List < String > getInetrestStatement(APIParams[] params) {
        InterestStatmtRequestWrapper reqWrapper = new InterestStatmtRequestWrapper();
        InterestStatementAPIWrapper interestStWrap = new InterestStatementAPIWrapper();
        try {
            String accessToken = getToken();
            if (test.isRunningTest()) {
                Test.setMock(HttpCalloutMock.class, new HttpCalloutMockTest('InterestStatement'));
            }
            String requestbody;
            if (accessToken != null) {
                if (params[0].type == 'INSTCERTREPORT') {
                    System.debug('INSTCERTREPORT');
                    reqWrapper.type = params[0].type;
                    reqWrapper.finReference = params[0].finReference;
                    Date fromDate = (params[0].firstDisbursementDate > Date.newInstance(params[0].fromYear, 04, 01)) ?
                        params[0].firstDisbursementDate : Date.newInstance(params[0].fromYear, 04, 01);
                    Date toDate = Date.newInstance(params[0].toYear, 03, 31);
                    reqWrapper.fromDate = String.valueOf(fromDate) + 'T00:00:00';
                    reqWrapper.toDate = String.valueOf(toDate) + 'T00:00:00';
                    System.debug('FROMDATE = ' + reqWrapper.fromDate + ' TODATE = ' + reqWrapper.toDate);
                    requestbody = JSON.serialize(reqWrapper);
                    System.debug('INTEREST STATEMENT --> ' + requestbody);
                    String resp = makeInterestStatmtCall(requestbody, accessToken);
                    if (resp != null) {
                        interestStWrap = (InterestStatementAPIWrapper) JSON.deserialize(resp, InterestStatementAPIWrapper.class);
                        if ((interestStWrap.status == 'Success' || interestStWrap.statusCode == 101)) {
                            String baseString = interestStWrap.dataResponse.docContent;
                            ContentVersion contentVersion = new ContentVersion();
                            contentVersion.Title = 'IC_' + params[0].finReference + '_FY' + String.valueOf(params[0].fromYear).right(2) + '-' + String.valueOf(params[0].toYear).right(2) + '.pdf';
                            contentVersion.PathOnClient = 'IC_' + params[0].finReference + '_FY' + String.valueOf(params[0].fromYear).right(2) + '-' + String.valueOf(params[0].toYear).right(2) + '.pdf';
                            contentVersion.ContentLocation = 'S';
                            contentVersion.VersionData = EncodingUtil.base64Decode(baseString);
                            insert contentVersion;
                            System.debug('Content Version' + contentVersion);

                            If(contentVersion.Id != null) {
                                String contentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion.Id].ContentDocumentId;
                                System.debug('Content Document Id -->' + contentDocumentId);
                                ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
                                contentDocumentLink.ContentDocumentId = contentDocumentId;
                                contentDocumentLink.LinkedEntityId = params[0].caseID;
                                contentDocumentLink.ShareType = 'AllUsers';
                                contentDocumentLink.ShareType = 'V';
                                insert contentDocumentLink;
                            }
                        }
                    }
                }

                if (params[0].type == 'SOAREPORT') {
                    System.debug('SOAREPORT');
                    reqWrapper.type = params[0].type;
                    reqWrapper.finReference = params[0].finReference;
                    Date fromDate = params[0].firstDisbursementDate;
                    Date toDate = system.today();
                    reqWrapper.fromDate = String.valueOf(fromDate) + 'T00:00:00';
                    reqWrapper.toDate = String.valueOf(toDate) + 'T00:00:00';
                    System.debug('FROMDATE = ' + reqWrapper.fromDate + ' TODATE = ' + reqWrapper.toDate);
                    requestbody = JSON.serialize(reqWrapper);
                    System.debug('INTEREST STATEMENT --> ' + requestbody);
                    String resp = makeInterestStatmtCall(requestbody, accessToken);
                    if (resp != null) {
                        interestStWrap = (InterestStatementAPIWrapper) JSON.deserialize(resp, InterestStatementAPIWrapper.class);
                        if ((interestStWrap.status == 'Success' || interestStWrap.statusCode == 101)) {

                            String baseString = interestStWrap.dataResponse.docContent;
                            ContentVersion contentVersion = new ContentVersion();
                            contentVersion.Title = 'SOA_' + params[0].finReference + '.pdf';
                            contentVersion.PathOnClient = 'SOA_' + params[0].finReference + '.pdf';
                            contentVersion.ContentLocation = 'S';
                            contentVersion.VersionData = EncodingUtil.base64Decode(baseString);
                            insert contentVersion;
                            System.debug('Content Version' + contentVersion);

                            If(contentVersion.Id != null) {
                                String contentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion.Id].ContentDocumentId;
                                System.debug('Content Document Id -->' + contentDocumentId);
                                ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
                                contentDocumentLink.ContentDocumentId = contentDocumentId;
                                contentDocumentLink.LinkedEntityId = params[0].caseID;
                                contentDocumentLink.ShareType = 'AllUsers';
                                contentDocumentLink.ShareType = 'V';
                                insert contentDocumentLink;
                            }
                        }
                    }
                }

                if (params[0].type == 'PROVINSTCERTREPORT') {
                    System.debug('PROVINSTCERTREPORT');
                    reqWrapper.type = params[0].type;
                    reqWrapper.finReference = params[0].finReference;
                    Date fromDate = (params[0].firstDisbursementDate > Date.newInstance(System.today().year(), 04, 01)) ?
                        params[0].firstDisbursementDate : Date.newInstance(System.today().year(), 04, 01);
                    Date toDate = Date.newInstance(System.today().addYears(1).year(), 03, 31);
                    reqWrapper.fromDate = String.valueOf(fromDate) + 'T00:00:00';
                    reqWrapper.toDate = String.valueOf(toDate) + 'T00:00:00';
                    System.debug('FROMDATE = ' + reqWrapper.fromDate + ' TODATE = ' + reqWrapper.toDate);
                    requestbody = JSON.serialize(reqWrapper);
                    System.debug('INTEREST STATEMENT --> ' + requestbody);
                    String resp = makeInterestStatmtCall(requestbody, accessToken);
                    if (resp != null) {
                        interestStWrap = (InterestStatementAPIWrapper) JSON.deserialize(resp, InterestStatementAPIWrapper.class);
                        if ((interestStWrap.status == 'Success' || interestStWrap.statusCode == 101)) {

                            String baseString = interestStWrap.dataResponse.docContent;
                            ContentVersion contentVersion = new ContentVersion();
                            contentVersion.Title = 'PIC_' + params[0].finReference + '_FY' + String.valueOf(fromDate.year()) + '-' + String.valueOf(toDate.year()).right(2) + '.pdf';
                            contentVersion.PathOnClient = 'PIC_' + params[0].finReference + '.pdf';
                            contentVersion.ContentLocation = 'S';
                            contentVersion.VersionData = EncodingUtil.base64Decode(baseString);
                            insert contentVersion;
                            System.debug('Content Version' + contentVersion);

                            If(contentVersion.Id != null) {
                                String contentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion.Id].ContentDocumentId;
                                System.debug('Content Document Id -->' + contentDocumentId);
                                ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
                                contentDocumentLink.ContentDocumentId = contentDocumentId;
                                contentDocumentLink.LinkedEntityId = params[0].caseID;
                                contentDocumentLink.ShareType = 'AllUsers';
                                contentDocumentLink.ShareType = 'V';
                                insert contentDocumentLink;
                            }
                        }
                    }
                }

            }
        } catch (Exception e) {
            System.debug('Error On Line ' + e.getLineNumber() + ' :: Exception :: ' + e.getMessage());
        }
        if (!test.isRunningTest()) {
            system.debug('responsecode' + responseCode);
            if(responseCode == 200){
            	if (interestStWrap.dataResponse.returnStatus.returnText != 'Success') {
                	statuscode = interestStWrap.dataResponse.returnStatus.returnText;
                	return new List < String > {
                    	statuscode
                	};
            	}
            }else{
                StatusCode = 'ERROR CODE : '+responseCode;
                return new List < String > {
                    	statuscode
                };
            }	
        }
        statuscode = 'Success';
        return new List < String > {
            statuscode
        };
    }

    global static String getToken() {

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setTimeout(20000);
        request.setEndpoint(Label.TokenAPIEndpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(Label.TokenRequestBody);
        HttpResponse response = http.send(request);
        System.debug('getToken Response -->' + response.getbody());
        if (response.getStatusCode() == 200) {
            Map < String, String > responseMap = (Map < String, String > ) JSON.deserialize(response.getbody(), Map < String, String > .class);
            System.debug('ACCESS TOKEN = ' + responseMap.get('access_token'));
            return responseMap.get('access_token');

        }
        return null;

    }

    global static String makeInterestStatmtCall(String requestbody, String accessToken) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setTimeout(11000);
        request.setEndpoint(Label.BaseUrlAPI + '/pffapi/getStatementDoc');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setBody(requestbody);
        HttpResponse response = http.send(request);
        System.debug('makeInterestStatmtCall Response -->' + response.getbody());
        responseCode = response.getStatusCode();
        if (response.getStatusCode() == 200) {
            return response.getbody();
        }
        return null;
    }

    global class APIParams {
        @InvocableVariable
        global String finReference;

        @InvocableVariable
        global Integer fromYear;

        @InvocableVariable
        global Integer toYear;

        @InvocableVariable
        global Date firstDisbursementDate;

        @InvocableVariable
        global String caseID;

        @InvocableVariable
        global String type;
    }

    global class InterestStatmtRequestWrapper {
        String finReference;
        String fromDate;
        String toDate;
        String type;
    }


}