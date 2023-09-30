public class ReportEmail {
@future(callout=True)
    public static void sendReport() {
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        List<Report> reportList = [SELECT Id, DeveloperName, Name FROM Report WHERE DeveloperName = 'Call_Back_Due_Days_wqw'];
        System.debug('Report name'+reportList);
        String reportId;
        if (reportList.size() > 0) {
            system.debug('In report');
            for (Report report : reportList) {
                reportId = (String) report.Id;
                String reportName = (String) report.Name;
				ApexPages.PageReference objPage = new ApexPages.PageReference('/servlet/PrintableViewDownloadServlet?isdtp=pl&reportId=' + reportId);
				Messaging.EmailFileAttachment objMsgEmailAttach = new Messaging.EmailFileAttachment();
				objMsgEmailAttach.setFileName(reportName + '.xlsx');
				if(!Test.isRunningTest()) {
					objMsgEmailAttach.setBody(objPage.getContent());
				}
				objMsgEmailAttach.setContentType('text/csv');
		attachments.add(objMsgEmailAttach);
            }
        }

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setUseSignature(false);
        // commet it cause it send the email to auxilo members 
         //Id managerRoleId = [SELECT Id FROM UserRole WHERE Name = :CommonConstant.CREDIT_MANAGER AND ParentRoleId != null LIMIT 1].Id;
         //List<User> groupMembers = [SELECT Id, Name, Email FROM User WHERE UserRoleId = :managerRoleId];
    
         List<String> emailIds = new List<String>();
        /* for (User member : groupMembers) {
            emailIds.add(member.Email);
        }*/
    
        // Add a new email address
        
        String newEmail1 = 'harshvardhan.pol@extrapreneursindia.com';
        String newEmail2 = 'vaibhav.hinge@thinqloud.com';
        //String newEmail3 = 'gokul.bhujbal@thinqloud.com';
        //string nopreply='noreply@auxilo.com';
        //string newemail='shubham.jadhav@extrapreneursindia.com';
        
        emailIds.addAll(new List<String>{newEmail1, newEmail2});
                
    	
        //System.debug('Email IDs: ' + emailIds);
        //end
        // get email template 
		EmailTemplate emailTemplate = [SELECT Id, Name, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName ='Overdue_Call_Back_Task_Report' LIMIT 1];
        
        if (emailTemplate != null) {
             String orgWideEmailAddressId = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'No Reply Auxilo' LIMIT 1].Id;
            	mail.setOrgWideEmailAddressId(orgWideEmailAddressId);
            system.debug('setOrgWideEmailAddressId'+orgWideEmailAddressId);
            // Access the email template properties
            
        	//mail.setToAddresses(new List<String>{'harshvardhan.pol@extrapreneursindia.com'});
        	if(emailIds!=NULL){
        		mail.setToAddresses(emailIds);
        		//mail.setSubject('Daily Report from Salesforce');'
        		mail.setSubject(emailTemplate.Subject);
        		mail.setHtmlBody(emailTemplate.HtmlValue);
        		//get url    
        		String instanceUrl = URL.getSalesforceBaseUrl().toExternalForm();
        		String reportUrl = instanceUrl + '/' + reportId;
        		System.debug('Here is the link to the report: ' + reportUrl);
            
        		//mail.setHtmlBody('<br/><br/>Please review daily reports attached.+ <br/><br/><br/><br/>'+reportUrl);
        		mail.setFileAttachments(attachments);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
       else{
            
        }
    }
    
        }