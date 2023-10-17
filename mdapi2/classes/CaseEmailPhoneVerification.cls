global class CaseEmailPhoneVerification {
    @InvocableMethod(label='Phone/Email Verification' description='method description')
    global static void verification(Params[] params){
        String verificationUrl;
        Case caseObj = params[0].caseObj;
        String accountName = [SELECT Name FROM Account WHERE Id = :caseObj.AccountId].Name;
        String accountEmail = [SELECT PersonEmail FROM Account WHERE Id = :caseObj.AccountId].PersonEmail;
        if(params[0].type == 'Phone'){
            if(params[0].email_phone != null){
                verificationUrl = Label.MobileVerificationLink + '?Salesforceid='+ caseObj.Id+'&mobile=' + EncodingUtil.base64Encode(Blob.valueof(caseObj.New_Mobile_Number__c));
                String msgTemplate = EncodingUtil.urlEncode(Label.PhoneVerificationMessage.replace('@__123__@',verificationUrl),'UTF-8');
                String endpoint = Label.VerificationEndPoint.replace('phone_no',params[0].email_phone).replace('msgTemplate',msgTemplate);
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(endpoint);
                request.setMethod('POST');
                HttpResponse response = http.send(request);
                System.debug('Phone verficationCallout Response -->' + response.getbody());
                System.debug('Response Status Code -->'+response.getStatusCode());
                if(response.getStatusCode() == 200){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    EmailTemplate et =[Select Id,HtmlValue, DeveloperName From EmailTemplate where Id =: Label.VerificationEmailTemplateId];
                    System.debug(et.HtmlValue);
                    String emailBody = ((String)et.HtmlValue).replace('##site##',String.valueOf(verificationUrl)).replace('{!Receiving_User.Name}',accountName);
                    mail.setToAddresses(new String[] {accountEmail});
                    mail.setHtmlBody(emailBody);
                    mail.setWhatId(caseObj.Id);
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    if (results[0].success){
                        Task t = new Task();
                        t.Subject = 'Verification SMS Sent-' + params[0].email_phone + '-' + System.today();
                        t.WhatId = caseObj.Id;
                        t.Status = 'Completed';
                        t.Description = 'Verification Message Sent';
                        t.OwnerId = System.UserInfo.getUserId();
                        insert t;
                        System.debug('TASK -->'+t);
                    }
                    }
                }
            }else if(params[0].type == 'Email'){
                System.debug(caseObj);
                verificationUrl = Label.EmailVerificationLink + '?Salesforceid='+ caseObj.Id +'&email=' +EncodingUtil.base64Encode(Blob.valueof(caseObj.New_Email__c)) ;
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                EmailTemplate et =[Select Id,HtmlValue, DeveloperName From EmailTemplate where Id =: Label.VerificationEmailTemplateId];
                System.debug(et.HtmlValue);
                String emailBody = ((String)et.HtmlValue).replace('##site##',String.valueOf(verificationUrl)).replace('{!Receiving_User.Name}',accountName);
                mail.setToAddresses(new String[] {caseObj.New_Email__c});
                mail.setHtmlBody(emailBody);
                mail.setWhatId(caseObj.Id);
                Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                if (results[0].success){
                    Task t = new task();
                    t.Subject = 'Verification Email Sent-' + params[0].email_phone + '-' + System.today();
                    t.WhatId = caseObj.Id;
                    t.Status = 'Completed';
                    t.Description = 'Verification Email Sent';
                    t.OwnerId = System.UserInfo.getUserId();
                    insert t;
                }
            }
        }
        global class Params {
            @InvocableVariable
            global String email_phone;
            
            @InvocableVariable
            global String type;
            
            @InvocableVariable
            global Case caseObj;
        }
    }