@isTest
public class TaskTriggerHandlerTestModified {
    @isTest
    Public static void testTasktrigger() {
        system.Test.startTest();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Fresh','New',True);
        system.debug('First Method objLead Line 7= '+objLead);
        Task TaskObj = TestDataFactory.createTaskRecordTrigger('Call Back',False);
        TaskObj.WhoId =objLead.Id;
        insert TaskObj;
        TaskObj.Call_Result__c ='Bad Call';
        Update TaskObj;
        TaskObj.Call_Result__c ='Call Back';
        TaskObj.call_back_date_time_New__c = '';
        Update TaskObj;
        datetime d= system.today();
        String datetimeformt= d.format();
        TaskObj.call_back_date_time_New__c = datetimeformt;
        Update TaskObj;
        TaskObj.agentStatus__c ='user_disconnected';
        Update TaskObj;
        TaskObj.whoId =null;
        Update TaskObj;
        system.debug('First Method  TaskObj.WhoId Line 10= '+TaskObj.WhoId);
        system.Test.stopTest();
    } 
    /********************************************************* FreshNew *********************************************************************/
    @isTest
    Public static void testTaskLeadFreshNew() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Fresh','New',True);
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Call Back',False);
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        // insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        
        Task TaskObjDispositionCallDenied = TestDataFactory.createTaskRecordTrigger('Customer Denied the Loan not interested',False);
        TaskObjDispositionCallDenied.WhoId =objLead.Id;
        //insert TaskObjDispositionCallDenied;
        taskList.add(TaskObjDispositionCallDenied);
        
        Task TaskObjDispositionFutureProspect = TestDataFactory.createTaskRecordTrigger('Future Prospect',False);
        TaskObjDispositionFutureProspect.WhoId =objLead.Id;
        //  insert TaskObjDispositionFutureProspect;
        taskList.add(TaskObjDispositionFutureProspect);
        
        Task TaskObjDispositionInvalid = TestDataFactory.createTaskRecordTrigger('Invalid',False);
        TaskObjDispositionInvalid.WhoId =objLead.Id;
        //  insert TaskObjDispositionInvalid;
        taskList.add(TaskObjDispositionInvalid);
        
        Task TaskObjDispositionNonDuableAuxilo = TestDataFactory.createTaskRecordTrigger('Not Doable By Auxilo',False);
        TaskObjDispositionNonDuableAuxilo.WhoId =objLead.Id;
        // insert TaskObjDispositionNonDuableAuxilo;
        taskList.add(TaskObjDispositionNonDuableAuxilo);
        
        Task TaskObjDispositionPassiveTransfer = TestDataFactory.createTaskRecordTrigger('Passive Transfer to CEM',False);
        TaskObjDispositionPassiveTransfer.WhoId =objLead.Id;
        // insert TaskObjDispositionPassiveTransfer;
        taskList.add(TaskObjDispositionPassiveTransfer);
        
        Task TaskObjDispositionTriPartyCall = TestDataFactory.createTaskRecordTrigger('Tri Party Call',False);
        TaskObjDispositionTriPartyCall.WhoId =objLead.Id;
        //  insert TaskObjDispositionTriPartyCall;
        taskList.add(TaskObjDispositionTriPartyCall);
        
        Task TaskObjDispositionWillingToApply = TestDataFactory.createTaskRecordTrigger('Willing To Apply',False);
        TaskObjDispositionWillingToApply.WhoId =objLead.Id;
        insert TaskObjDispositionWillingToApply;
        taskList.add(TaskObjDispositionWillingToApply);
        
        Task TaskObjDispositionActiveTransfer = TestDataFactory.createTaskRecordTrigger('Active Transfer to CEM',False);
        TaskObjDispositionActiveTransfer.WhoId =objLead.Id;
        //  insert TaskObjDispositionActiveTransfer;
        taskList.add(TaskObjDispositionActiveTransfer);    
        
        Task TaskObjDispositionApplicationFormalitiesCompleted = TestDataFactory.createTaskRecordTrigger('Application Formalities Completed',False);
        TaskObjDispositionApplicationFormalitiesCompleted.WhoId =objLead.Id;
        //  insert TaskObjDispositionApplicationFormalitiesCompleted;
        taskList.add(TaskObjDispositionApplicationFormalitiesCompleted); 
        
        Task TaskObjDispositionDuplicateLead = TestDataFactory.createTaskRecordTrigger('Duplicate Lead',False);
        TaskObjDispositionDuplicateLead.WhoId =objLead.Id;
        // insert TaskObjDispositionDuplicateLead;
        taskList.add(TaskObjDispositionDuplicateLead);  
        
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        
        system.Test.stopTest();
    } 
    
    @isTest
    Public static void testTaskLeadFreshNewtwo() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Fresh','New',True);
        
        
        Task TaskObjDispositionPushToLos = TestDataFactory.createTaskRecordTrigger('Push to LOS',False);
        TaskObjDispositionPushToLos.WhoId =objLead.Id;
        //  insert TaskObjDispositionPushToLos;
        taskList.add(TaskObjDispositionPushToLos);  
        
        Task TaskObjDispositionBadCall = TestDataFactory.createTaskRecordTrigger('Bad Call',False);
        TaskObjDispositionBadCall.WhoId =objLead.Id;
        // insert TaskObjDispositionBadCall;
        taskList.add(TaskObjDispositionBadCall);  
        
        Task TaskObjDispositionReadyToApply = TestDataFactory.createTaskRecordTrigger('Ready to Apply',False);
        TaskObjDispositionReadyToApply.WhoId =objLead.Id;
        //  insert TaskObjDispositionReadyToApply;
        taskList.add(TaskObjDispositionReadyToApply);  
        
        Task TaskObjDispositionPartialDocument = TestDataFactory.createTaskRecordTrigger('Partial Documents Received',False);
        TaskObjDispositionPartialDocument.WhoId =objLead.Id;
        //  insert TaskObjDispositionPartialDocument;
        taskList.add(TaskObjDispositionPartialDocument);  
        
        Task TaskObjDispositionInboundMissedCall = TestDataFactory.createTaskRecordTrigger('Inbound Missed Call',False);
        TaskObjDispositionInboundMissedCall.WhoId =objLead.Id;
        // insert TaskObjDispositionInboundMissedCall;
        taskList.add(TaskObjDispositionInboundMissedCall); 
        
        Task TaskObjDispositionOnlineApplication = TestDataFactory.createTaskRecordTrigger('Online Application Form Fulfilment Initiated',False);
        TaskObjDispositionOnlineApplication.WhoId =objLead.Id;
        // insert TaskObjDispositionOnlineApplication;
        taskList.add(TaskObjDispositionOnlineApplication); 
        
        Task TaskObjDispositionOnApplicationDropped = TestDataFactory.createTaskRecordTrigger('Application Fulfilment Dropped',False);
        TaskObjDispositionOnApplicationDropped.WhoId =objLead.Id;
        //  insert TaskObjDispositionOnApplicationDropped;
        taskList.add(TaskObjDispositionOnApplicationDropped); 
        
        Task TaskObjDispositionODoNotDisturb = TestDataFactory.createTaskRecordTrigger('Do Not Disturb',False);
        TaskObjDispositionODoNotDisturb.WhoId =objLead.Id;
        // insert TaskObjDispositionODoNotDisturb;
        taskList.add(TaskObjDispositionODoNotDisturb); 
        
        Task TaskObjDispositionCallDone = TestDataFactory.createTaskRecordTrigger('Call Done',False);
        TaskObjDispositionCallDone.WhoId =objLead.Id;
        //  insert TaskObjDispositionCallDone;
        taskList.add(TaskObjDispositionCallDone); 
        
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        // TaskTriggerHandler.assignmentOfStageOwnerToParentlead(taskList);
        
        system.Test.stopTest();
    }
    /*********************************************************SuspectContacted*********************************************************************/
    /*  @isTest
Public static void testTaskLeadSuspectContacted() {
system.Test.startTest();
List<Task> taskList = new List<Task>();
Lead objLead =TestDataFactory.createLeadTaskTrigger('Suspect','Contacted',True);
Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Call Back',False);
TaskObjDispositionCallBack.WhoId =objLead.Id;
insert TaskObjDispositionCallBack;
taskList.add(TaskObjDispositionCallBack);

Task TaskObjDispositionCallDenied = TestDataFactory.createTaskRecordTrigger('Customer Denied the Loan not interested',False);
TaskObjDispositionCallDenied.WhoId =objLead.Id;
insert TaskObjDispositionCallDenied;
taskList.add(TaskObjDispositionCallDenied);

Task TaskObjDispositionFutureProspect = TestDataFactory.createTaskRecordTrigger('Future Prospect',False);
TaskObjDispositionFutureProspect.WhoId =objLead.Id;
insert TaskObjDispositionFutureProspect;
taskList.add(TaskObjDispositionFutureProspect);

Task TaskObjDispositionInvalid = TestDataFactory.createTaskRecordTrigger('Invalid',False);
TaskObjDispositionInvalid.WhoId =objLead.Id;
insert TaskObjDispositionInvalid;
taskList.add(TaskObjDispositionInvalid);

Task TaskObjDispositionNonDuableAuxilo = TestDataFactory.createTaskRecordTrigger('Not Doable By Auxilo',False);
TaskObjDispositionNonDuableAuxilo.WhoId =objLead.Id;
insert TaskObjDispositionNonDuableAuxilo;
taskList.add(TaskObjDispositionNonDuableAuxilo);

Task TaskObjDispositionPassiveTransfer = TestDataFactory.createTaskRecordTrigger('Passive Transfer to CEM',False);
TaskObjDispositionPassiveTransfer.WhoId =objLead.Id;
insert TaskObjDispositionPassiveTransfer;
taskList.add(TaskObjDispositionPassiveTransfer);

Task TaskObjDispositionTriPartyCall = TestDataFactory.createTaskRecordTrigger('Tri Party Call',False);
TaskObjDispositionTriPartyCall.WhoId =objLead.Id;
insert TaskObjDispositionTriPartyCall;
taskList.add(TaskObjDispositionTriPartyCall);

Task TaskObjDispositionWillingToApply = TestDataFactory.createTaskRecordTrigger('Willing To Apply',False);
TaskObjDispositionWillingToApply.WhoId =objLead.Id;
insert TaskObjDispositionWillingToApply;
taskList.add(TaskObjDispositionWillingToApply);

Task TaskObjDispositionActiveTransfer = TestDataFactory.createTaskRecordTrigger('Active Transfer to CEM',False);
TaskObjDispositionActiveTransfer.WhoId =objLead.Id;
insert TaskObjDispositionActiveTransfer;
taskList.add(TaskObjDispositionActiveTransfer);    

Task TaskObjDispositionApplicationFormalitiesCompleted = TestDataFactory.createTaskRecordTrigger('Application Formalities Completed',False);
TaskObjDispositionApplicationFormalitiesCompleted.WhoId =objLead.Id;
insert TaskObjDispositionApplicationFormalitiesCompleted;
taskList.add(TaskObjDispositionApplicationFormalitiesCompleted); 

Task TaskObjDispositionDuplicateLead = TestDataFactory.createTaskRecordTrigger('Duplicate Lead',False);
TaskObjDispositionDuplicateLead.WhoId =objLead.Id;
insert TaskObjDispositionDuplicateLead;
taskList.add(TaskObjDispositionDuplicateLead);  

TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);

system.Test.stopTest();
}

@isTest
Public static void testTaskLeadSuspectContactedtwo() {
system.Test.startTest();
List<Task> taskList = new List<Task>();
Lead objLead =TestDataFactory.createLeadTaskTrigger('Suspect','Contacted',True);


Task TaskObjDispositionPushToLos = TestDataFactory.createTaskRecordTrigger('Push to LOS',False);
TaskObjDispositionPushToLos.WhoId =objLead.Id;
insert TaskObjDispositionPushToLos;
taskList.add(TaskObjDispositionPushToLos);  

Task TaskObjDispositionBadCall = TestDataFactory.createTaskRecordTrigger('Bad Call',False);
TaskObjDispositionBadCall.WhoId =objLead.Id;
insert TaskObjDispositionBadCall;
taskList.add(TaskObjDispositionBadCall);  

Task TaskObjDispositionReadyToApply = TestDataFactory.createTaskRecordTrigger('Ready to Apply',False);
TaskObjDispositionReadyToApply.WhoId =objLead.Id;
insert TaskObjDispositionReadyToApply;
taskList.add(TaskObjDispositionReadyToApply);  

Task TaskObjDispositionPartialDocument = TestDataFactory.createTaskRecordTrigger('Partial Documents Received',False);
TaskObjDispositionPartialDocument.WhoId =objLead.Id;
insert TaskObjDispositionPartialDocument;
taskList.add(TaskObjDispositionPartialDocument);  

Task TaskObjDispositionInboundMissedCall = TestDataFactory.createTaskRecordTrigger('Inbound Missed Call',False);
TaskObjDispositionInboundMissedCall.WhoId =objLead.Id;
insert TaskObjDispositionInboundMissedCall;
taskList.add(TaskObjDispositionInboundMissedCall); 

Task TaskObjDispositionOnlineApplication = TestDataFactory.createTaskRecordTrigger('Online Application Form Fulfilment Initiated',False);
TaskObjDispositionOnlineApplication.WhoId =objLead.Id;
insert TaskObjDispositionOnlineApplication;
taskList.add(TaskObjDispositionOnlineApplication); 

Task TaskObjDispositionOnApplicationDropped = TestDataFactory.createTaskRecordTrigger('Application Fulfilment Dropped',False);
TaskObjDispositionOnApplicationDropped.WhoId =objLead.Id;
insert TaskObjDispositionOnApplicationDropped;
taskList.add(TaskObjDispositionOnApplicationDropped); 

Task TaskObjDispositionODoNotDisturb = TestDataFactory.createTaskRecordTrigger('Do Not Disturb',False);
TaskObjDispositionODoNotDisturb.WhoId =objLead.Id;
insert TaskObjDispositionODoNotDisturb;
taskList.add(TaskObjDispositionODoNotDisturb); 

Task TaskObjDispositionCallDone = TestDataFactory.createTaskRecordTrigger('Call Done',False);
TaskObjDispositionCallDone.WhoId =objLead.Id;
insert TaskObjDispositionCallDone;
taskList.add(TaskObjDispositionCallDone); 

TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);

system.Test.stopTest();
}
/*********************************************************Prosprct Active*********************************************************************/
    /*  @isTest
Public static void testTaskLeadProsprctActive() {
system.Test.startTest();
List<Task> taskList = new List<Task>();
Lead objLead =TestDataFactory.createLeadTaskTrigger('Prospect','Active',True);
Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Call Back',False);
TaskObjDispositionCallBack.WhoId =objLead.Id;
insert TaskObjDispositionCallBack;
taskList.add(TaskObjDispositionCallBack);

Task TaskObjDispositionCallDenied = TestDataFactory.createTaskRecordTrigger('Customer Denied the Loan not interested',False);
TaskObjDispositionCallDenied.WhoId =objLead.Id;
insert TaskObjDispositionCallDenied;
taskList.add(TaskObjDispositionCallDenied);

Task TaskObjDispositionFutureProspect = TestDataFactory.createTaskRecordTrigger('Future Prospect',False);
TaskObjDispositionFutureProspect.WhoId =objLead.Id;
insert TaskObjDispositionFutureProspect;
taskList.add(TaskObjDispositionFutureProspect);

Task TaskObjDispositionInvalid = TestDataFactory.createTaskRecordTrigger('Invalid',False);
TaskObjDispositionInvalid.WhoId =objLead.Id;
insert TaskObjDispositionInvalid;
taskList.add(TaskObjDispositionInvalid);

Task TaskObjDispositionNonDuableAuxilo = TestDataFactory.createTaskRecordTrigger('Not Doable By Auxilo',False);
TaskObjDispositionNonDuableAuxilo.WhoId =objLead.Id;
insert TaskObjDispositionNonDuableAuxilo;
taskList.add(TaskObjDispositionNonDuableAuxilo);

Task TaskObjDispositionPassiveTransfer = TestDataFactory.createTaskRecordTrigger('Passive Transfer to CEM',False);
TaskObjDispositionPassiveTransfer.WhoId =objLead.Id;
insert TaskObjDispositionPassiveTransfer;
taskList.add(TaskObjDispositionPassiveTransfer);

Task TaskObjDispositionTriPartyCall = TestDataFactory.createTaskRecordTrigger('Tri Party Call',False);
TaskObjDispositionTriPartyCall.WhoId =objLead.Id;
insert TaskObjDispositionTriPartyCall;
taskList.add(TaskObjDispositionTriPartyCall);

Task TaskObjDispositionWillingToApply = TestDataFactory.createTaskRecordTrigger('Willing To Apply',False);
TaskObjDispositionWillingToApply.WhoId =objLead.Id;
insert TaskObjDispositionWillingToApply;
taskList.add(TaskObjDispositionWillingToApply);

Task TaskObjDispositionActiveTransfer = TestDataFactory.createTaskRecordTrigger('Active Transfer to CEM',False);
TaskObjDispositionActiveTransfer.WhoId =objLead.Id;
insert TaskObjDispositionActiveTransfer;
taskList.add(TaskObjDispositionActiveTransfer);    

Task TaskObjDispositionApplicationFormalitiesCompleted = TestDataFactory.createTaskRecordTrigger('Application Formalities Completed',False);
TaskObjDispositionApplicationFormalitiesCompleted.WhoId =objLead.Id;
insert TaskObjDispositionApplicationFormalitiesCompleted;
taskList.add(TaskObjDispositionApplicationFormalitiesCompleted); 

Task TaskObjDispositionDuplicateLead = TestDataFactory.createTaskRecordTrigger('Duplicate Lead',False);
TaskObjDispositionDuplicateLead.WhoId =objLead.Id;
insert TaskObjDispositionDuplicateLead;
taskList.add(TaskObjDispositionDuplicateLead);  

TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);

system.Test.stopTest();
}

@isTest
Public static void testTaskLeadProsprctActivetwo() {
system.Test.startTest();
List<Task> taskList = new List<Task>();
Lead objLead =TestDataFactory.createLeadTaskTrigger('Prospect','Active',True);


Task TaskObjDispositionPushToLos = TestDataFactory.createTaskRecordTrigger('Push to LOS',False);
TaskObjDispositionPushToLos.WhoId =objLead.Id;
insert TaskObjDispositionPushToLos;
taskList.add(TaskObjDispositionPushToLos);  

Task TaskObjDispositionBadCall = TestDataFactory.createTaskRecordTrigger('Bad Call',False);
TaskObjDispositionBadCall.WhoId =objLead.Id;
insert TaskObjDispositionBadCall;
taskList.add(TaskObjDispositionBadCall);  

Task TaskObjDispositionReadyToApply = TestDataFactory.createTaskRecordTrigger('Ready to Apply',False);
TaskObjDispositionReadyToApply.WhoId =objLead.Id;
insert TaskObjDispositionReadyToApply;
taskList.add(TaskObjDispositionReadyToApply);  

Task TaskObjDispositionPartialDocument = TestDataFactory.createTaskRecordTrigger('Partial Documents Received',False);
TaskObjDispositionPartialDocument.WhoId =objLead.Id;
insert TaskObjDispositionPartialDocument;
taskList.add(TaskObjDispositionPartialDocument);  

Task TaskObjDispositionInboundMissedCall = TestDataFactory.createTaskRecordTrigger('Inbound Missed Call',False);
TaskObjDispositionInboundMissedCall.WhoId =objLead.Id;
insert TaskObjDispositionInboundMissedCall;
taskList.add(TaskObjDispositionInboundMissedCall); 

Task TaskObjDispositionOnlineApplication = TestDataFactory.createTaskRecordTrigger('Online Application Form Fulfilment Initiated',False);
TaskObjDispositionOnlineApplication.WhoId =objLead.Id;
insert TaskObjDispositionOnlineApplication;
taskList.add(TaskObjDispositionOnlineApplication); 

Task TaskObjDispositionOnApplicationDropped = TestDataFactory.createTaskRecordTrigger('Application Fulfilment Dropped',False);
TaskObjDispositionOnApplicationDropped.WhoId =objLead.Id;
insert TaskObjDispositionOnApplicationDropped;
taskList.add(TaskObjDispositionOnApplicationDropped); 

Task TaskObjDispositionODoNotDisturb = TestDataFactory.createTaskRecordTrigger('Do Not Disturb',False);
TaskObjDispositionODoNotDisturb.WhoId =objLead.Id;
insert TaskObjDispositionODoNotDisturb;
taskList.add(TaskObjDispositionODoNotDisturb); 

Task TaskObjDispositionCallDone = TestDataFactory.createTaskRecordTrigger('Call Done',False);
TaskObjDispositionCallDone.WhoId =objLead.Id;
insert TaskObjDispositionCallDone;
taskList.add(TaskObjDispositionCallDone); 

TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);

system.Test.stopTest();
}
/*********************************************************SalesProcessignNew*********************************************************************/
    /*    @isTest
Public static void testTaskLeadSalesProcessingNew() {
system.Test.startTest();
List<Task> taskList = new List<Task>();
Lead objLead =TestDataFactory.createLeadTaskTrigger('Sales Processing','New',True);
Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Call Back',False);
TaskObjDispositionCallBack.WhoId =objLead.Id;
insert TaskObjDispositionCallBack;
taskList.add(TaskObjDispositionCallBack);

Task TaskObjDispositionCallDenied = TestDataFactory.createTaskRecordTrigger('Customer Denied the Loan not interested',False);
TaskObjDispositionCallDenied.WhoId =objLead.Id;
insert TaskObjDispositionCallDenied;
taskList.add(TaskObjDispositionCallDenied);

Task TaskObjDispositionFutureProspect = TestDataFactory.createTaskRecordTrigger('Future Prospect',False);
TaskObjDispositionFutureProspect.WhoId =objLead.Id;
insert TaskObjDispositionFutureProspect;
taskList.add(TaskObjDispositionFutureProspect);

Task TaskObjDispositionInvalid = TestDataFactory.createTaskRecordTrigger('Invalid',False);
TaskObjDispositionInvalid.WhoId =objLead.Id;
insert TaskObjDispositionInvalid;
taskList.add(TaskObjDispositionInvalid);

Task TaskObjDispositionNonDuableAuxilo = TestDataFactory.createTaskRecordTrigger('Not Doable By Auxilo',False);
TaskObjDispositionNonDuableAuxilo.WhoId =objLead.Id;
insert TaskObjDispositionNonDuableAuxilo;
taskList.add(TaskObjDispositionNonDuableAuxilo);

Task TaskObjDispositionPassiveTransfer = TestDataFactory.createTaskRecordTrigger('Passive Transfer to CEM',False);
TaskObjDispositionPassiveTransfer.WhoId =objLead.Id;
insert TaskObjDispositionPassiveTransfer;
taskList.add(TaskObjDispositionPassiveTransfer);

Task TaskObjDispositionTriPartyCall = TestDataFactory.createTaskRecordTrigger('Tri Party Call',False);
TaskObjDispositionTriPartyCall.WhoId =objLead.Id;
insert TaskObjDispositionTriPartyCall;
taskList.add(TaskObjDispositionTriPartyCall);

Task TaskObjDispositionWillingToApply = TestDataFactory.createTaskRecordTrigger('Willing To Apply',False);
TaskObjDispositionWillingToApply.WhoId =objLead.Id;
insert TaskObjDispositionWillingToApply;
taskList.add(TaskObjDispositionWillingToApply);

Task TaskObjDispositionActiveTransfer = TestDataFactory.createTaskRecordTrigger('Active Transfer to CEM',False);
TaskObjDispositionActiveTransfer.WhoId =objLead.Id;
insert TaskObjDispositionActiveTransfer;
taskList.add(TaskObjDispositionActiveTransfer);    

Task TaskObjDispositionApplicationFormalitiesCompleted = TestDataFactory.createTaskRecordTrigger('Application Formalities Completed',False);
TaskObjDispositionApplicationFormalitiesCompleted.WhoId =objLead.Id;
insert TaskObjDispositionApplicationFormalitiesCompleted;
taskList.add(TaskObjDispositionApplicationFormalitiesCompleted); 

Task TaskObjDispositionDuplicateLead = TestDataFactory.createTaskRecordTrigger('Duplicate Lead',False);
TaskObjDispositionDuplicateLead.WhoId =objLead.Id;
insert TaskObjDispositionDuplicateLead;
taskList.add(TaskObjDispositionDuplicateLead);  

TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);

system.Test.stopTest();
}

@isTest
Public static void testTaskLeadSaplesprocessingNewtwo() {
system.Test.startTest();
List<Task> taskList = new List<Task>();
Lead objLead =TestDataFactory.createLeadTaskTrigger('Sales Processing','New',True);


Task TaskObjDispositionPushToLos = TestDataFactory.createTaskRecordTrigger('Push to LOS',False);
TaskObjDispositionPushToLos.WhoId =objLead.Id;
insert TaskObjDispositionPushToLos;
taskList.add(TaskObjDispositionPushToLos);  

Task TaskObjDispositionBadCall = TestDataFactory.createTaskRecordTrigger('Bad Call',False);
TaskObjDispositionBadCall.WhoId =objLead.Id;
insert TaskObjDispositionBadCall;
taskList.add(TaskObjDispositionBadCall);  

Task TaskObjDispositionReadyToApply = TestDataFactory.createTaskRecordTrigger('Ready to Apply',False);
TaskObjDispositionReadyToApply.WhoId =objLead.Id;
insert TaskObjDispositionReadyToApply;
taskList.add(TaskObjDispositionReadyToApply);  

Task TaskObjDispositionPartialDocument = TestDataFactory.createTaskRecordTrigger('Partial Documents Received',False);
TaskObjDispositionPartialDocument.WhoId =objLead.Id;
insert TaskObjDispositionPartialDocument;
taskList.add(TaskObjDispositionPartialDocument);  

Task TaskObjDispositionInboundMissedCall = TestDataFactory.createTaskRecordTrigger('Inbound Missed Call',False);
TaskObjDispositionInboundMissedCall.WhoId =objLead.Id;
insert TaskObjDispositionInboundMissedCall;
taskList.add(TaskObjDispositionInboundMissedCall); 

Task TaskObjDispositionOnlineApplication = TestDataFactory.createTaskRecordTrigger('Online Application Form Fulfilment Initiated',False);
TaskObjDispositionOnlineApplication.WhoId =objLead.Id;
insert TaskObjDispositionOnlineApplication;
taskList.add(TaskObjDispositionOnlineApplication); 

Task TaskObjDispositionOnApplicationDropped = TestDataFactory.createTaskRecordTrigger('Application Fulfilment Dropped',False);
TaskObjDispositionOnApplicationDropped.WhoId =objLead.Id;
insert TaskObjDispositionOnApplicationDropped;
taskList.add(TaskObjDispositionOnApplicationDropped); 

Task TaskObjDispositionODoNotDisturb = TestDataFactory.createTaskRecordTrigger('Do Not Disturb',False);
TaskObjDispositionODoNotDisturb.WhoId =objLead.Id;
insert TaskObjDispositionODoNotDisturb;
taskList.add(TaskObjDispositionODoNotDisturb); 

Task TaskObjDispositionCallDone = TestDataFactory.createTaskRecordTrigger('Call Done',False);
TaskObjDispositionCallDone.WhoId =objLead.Id;
insert TaskObjDispositionCallDone;
taskList.add(TaskObjDispositionCallDone); 

TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);

system.Test.stopTest();
}
/*********************************************************ApplyingActive*********************************************************************/
    /*   @isTest
Public static void testTaskLeadApplyingActive() {
system.Test.startTest();
List<Task> taskList = new List<Task>();
Lead objLead =TestDataFactory.createLeadTaskTrigger('Applying','Active',True);
Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Call Back',False);
TaskObjDispositionCallBack.WhoId =objLead.Id;
insert TaskObjDispositionCallBack;
taskList.add(TaskObjDispositionCallBack);

Task TaskObjDispositionCallDenied = TestDataFactory.createTaskRecordTrigger('Customer Denied the Loan not interested',False);
TaskObjDispositionCallDenied.WhoId =objLead.Id;
insert TaskObjDispositionCallDenied;
taskList.add(TaskObjDispositionCallDenied);

Task TaskObjDispositionFutureProspect = TestDataFactory.createTaskRecordTrigger('Future Prospect',False);
TaskObjDispositionFutureProspect.WhoId =objLead.Id;
insert TaskObjDispositionFutureProspect;
taskList.add(TaskObjDispositionFutureProspect);

Task TaskObjDispositionInvalid = TestDataFactory.createTaskRecordTrigger('Invalid',False);
TaskObjDispositionInvalid.WhoId =objLead.Id;
insert TaskObjDispositionInvalid;
taskList.add(TaskObjDispositionInvalid);

Task TaskObjDispositionNonDuableAuxilo = TestDataFactory.createTaskRecordTrigger('Not Doable By Auxilo',False);
TaskObjDispositionNonDuableAuxilo.WhoId =objLead.Id;
insert TaskObjDispositionNonDuableAuxilo;
taskList.add(TaskObjDispositionNonDuableAuxilo);

Task TaskObjDispositionPassiveTransfer = TestDataFactory.createTaskRecordTrigger('Passive Transfer to CEM',False);
TaskObjDispositionPassiveTransfer.WhoId =objLead.Id;
insert TaskObjDispositionPassiveTransfer;
taskList.add(TaskObjDispositionPassiveTransfer);

Task TaskObjDispositionTriPartyCall = TestDataFactory.createTaskRecordTrigger('Tri Party Call',False);
TaskObjDispositionTriPartyCall.WhoId =objLead.Id;
insert TaskObjDispositionTriPartyCall;
taskList.add(TaskObjDispositionTriPartyCall);

Task TaskObjDispositionWillingToApply = TestDataFactory.createTaskRecordTrigger('Willing To Apply',False);
TaskObjDispositionWillingToApply.WhoId =objLead.Id;
insert TaskObjDispositionWillingToApply;
taskList.add(TaskObjDispositionWillingToApply);

Task TaskObjDispositionActiveTransfer = TestDataFactory.createTaskRecordTrigger('Active Transfer to CEM',False);
TaskObjDispositionActiveTransfer.WhoId =objLead.Id;
insert TaskObjDispositionActiveTransfer;
taskList.add(TaskObjDispositionActiveTransfer);    

Task TaskObjDispositionApplicationFormalitiesCompleted = TestDataFactory.createTaskRecordTrigger('Application Formalities Completed',False);
TaskObjDispositionApplicationFormalitiesCompleted.WhoId =objLead.Id;
insert TaskObjDispositionApplicationFormalitiesCompleted;
taskList.add(TaskObjDispositionApplicationFormalitiesCompleted); 

Task TaskObjDispositionDuplicateLead = TestDataFactory.createTaskRecordTrigger('Duplicate Lead',False);
TaskObjDispositionDuplicateLead.WhoId =objLead.Id;
insert TaskObjDispositionDuplicateLead;
taskList.add(TaskObjDispositionDuplicateLead);  

TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);

system.Test.stopTest();
}

@isTest
Public static void testTaskLeadApplyingActivetwo() {
system.Test.startTest();
List<Task> taskList = new List<Task>();
Lead objLead =TestDataFactory.createLeadTaskTrigger('Applying','Active',True);


Task TaskObjDispositionPushToLos = TestDataFactory.createTaskRecordTrigger('Push to LOS',False);
TaskObjDispositionPushToLos.WhoId =objLead.Id;
insert TaskObjDispositionPushToLos;
taskList.add(TaskObjDispositionPushToLos);  

Task TaskObjDispositionBadCall = TestDataFactory.createTaskRecordTrigger('Bad Call',False);
TaskObjDispositionBadCall.WhoId =objLead.Id;
insert TaskObjDispositionBadCall;
taskList.add(TaskObjDispositionBadCall);  

Task TaskObjDispositionReadyToApply = TestDataFactory.createTaskRecordTrigger('Ready to Apply',False);
TaskObjDispositionReadyToApply.WhoId =objLead.Id;
insert TaskObjDispositionReadyToApply;
taskList.add(TaskObjDispositionReadyToApply);  

Task TaskObjDispositionPartialDocument = TestDataFactory.createTaskRecordTrigger('Partial Documents Received',False);
TaskObjDispositionPartialDocument.WhoId =objLead.Id;
insert TaskObjDispositionPartialDocument;
taskList.add(TaskObjDispositionPartialDocument);  

Task TaskObjDispositionInboundMissedCall = TestDataFactory.createTaskRecordTrigger('Inbound Missed Call',False);
TaskObjDispositionInboundMissedCall.WhoId =objLead.Id;
insert TaskObjDispositionInboundMissedCall;
taskList.add(TaskObjDispositionInboundMissedCall); 

Task TaskObjDispositionOnlineApplication = TestDataFactory.createTaskRecordTrigger('Online Application Form Fulfilment Initiated',False);
TaskObjDispositionOnlineApplication.WhoId =objLead.Id;
insert TaskObjDispositionOnlineApplication;
taskList.add(TaskObjDispositionOnlineApplication); 

Task TaskObjDispositionOnApplicationDropped = TestDataFactory.createTaskRecordTrigger('Application Fulfilment Dropped',False);
TaskObjDispositionOnApplicationDropped.WhoId =objLead.Id;
insert TaskObjDispositionOnApplicationDropped;
taskList.add(TaskObjDispositionOnApplicationDropped); 

Task TaskObjDispositionODoNotDisturb = TestDataFactory.createTaskRecordTrigger('Do Not Disturb',False);
TaskObjDispositionODoNotDisturb.WhoId =objLead.Id;
insert TaskObjDispositionODoNotDisturb;
taskList.add(TaskObjDispositionODoNotDisturb); 

Task TaskObjDispositionCallDone = TestDataFactory.createTaskRecordTrigger('Call Done',False);
TaskObjDispositionCallDone.WhoId =objLead.Id;
insert TaskObjDispositionCallDone;
taskList.add(TaskObjDispositionCallDone); 

TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);

system.Test.stopTest();
} */
    @isTest
    Public static void testTaskLeadSalesProcessingCallBack() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Sales Processing','Active',True);
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Call Back',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testTaskLeadSuspectContacteCallBack() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Suspect','Contacted',True);
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Call Back',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        objLead.Call_Back_Count__c = 15;
        update objLead;
        Task TaskObjDispositionCallBackUpdated = TestDataFactory.createTaskRecordTrigger('Call Back',False);
        TaskObjDispositionCallBackUpdated.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBackUpdated.WhoId =objLead.Id;
        insert TaskObjDispositionCallBackUpdated;
        taskList.add(TaskObjDispositionCallBackUpdated);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        
        system.Test.stopTest();
    }
    @isTest
    Public static void testTaskLeadProspectActiveCallBack() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Prospect','Active',True);
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Call Back',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        objLead.Call_Back_Count__c = 20;
        update objLead;
        Task TaskObjDispositionCallBackUpdated = TestDataFactory.createTaskRecordTrigger('Call Back',False);
        TaskObjDispositionCallBackUpdated.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBackUpdated.WhoId =objLead.Id;
        insert TaskObjDispositionCallBackUpdated;
        taskList.add(TaskObjDispositionCallBackUpdated);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testTaskLeadApplyingInactiveCallBack() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Applying','Inactive',True);
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Call Back',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testTaskLeadProspectInactiveCallBack() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Prospect','Inactive',True);
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Call Back',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        system.Test.stopTest();
    } 
    
    @isTest
    Public static void testTaskLeadSalesProcessingNewFutureProspect() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Sales Processing','New',True);
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Future Prospect',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testTaskLeadSalesProcessingAtiveApplying() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Applying','Active',True);
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Future Prospect',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testTaskLeadSalesProcessingCallcentretripartyCallBack() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Sales Processing','Call centre triparty',True);
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Call Back',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);        
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testTaskLeadSalesProcessingEscalatedCallBack() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Sales Processing','Escalated',True);
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Call Back',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);        
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testTaskLeadSalesProcessingInactiveCallBack() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Sales Processing','Inactive',True);
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Call Back',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);        
    }
    
    Public static void testTaskLeadFreshNewForBothCallBack() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Fresh','New',True);
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Not Doable By Auxilo',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.Reason__c ='Document Issue';
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        Task TaskObjDispositionCallBackCustomerLoan = TestDataFactory.createTaskRecordTrigger('Customer Denied the Loan not interested',False);
        TaskObjDispositionCallBackCustomerLoan.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBackCustomerLoan.Reason__c ='Self Funding';
        TaskObjDispositionCallBackCustomerLoan.WhoId =objLead.Id;
        insert TaskObjDispositionCallBackCustomerLoan;
        taskList.add(TaskObjDispositionCallBackCustomerLoan);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);        
    }
    
    
    @isTest
    Public static void testTaskLeadFreshNewPassiveTransfer() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Fresh','New',True);
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Passive Transfer to CEM',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        system.Test.stopTest();
    }
    @isTest
    Public static void testTaskLeadFreshNewPassiveTransferwithoutServiceBranch() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Fresh','New',False);
        objLead.Service_Branch__c = null;
        insert objLead;
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Passive Transfer to CEM',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testTaskLeadSalesProcessingCallcentretripartyTriPartyCall() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Sales Processing','Call centre triparty',True);
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Tri Party Call',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testTaskLeadFreshNewActiveToTransfer() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Fresh','New',True);
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Active Trasfer to CEM',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        TaskObjDispositionCallBack.Description = 'Test';
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testTaskLeadApplyingActiveApplicationFormalitiesCompleted() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Applying','Active',True);
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Application Formalities Completed',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        TaskObjDispositionCallBack.Description = 'Test';
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testTaskLeadFreshNewDuplicateLead() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Fresh','New',True);
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Duplicate Lead',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testTaskLeadSalesProcessingActiveReadytoApply() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Sales Processing','Active',True);
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Ready to Apply',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testTaskLeadProsprctInActiveCallDone() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Prospect','Inactive',True);
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Call Done',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testTaskLeadProsprctFutureProspectCallDone() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Prospect','Future Prospect',True);
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Call Done',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        TaskObjDispositionCallBack.Call_Back_Date_time__c =System.today() + 1;
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testTaskLeadSalesProcessingInactiveCallDone() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Sales Processing','Inactive',True);
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Call Done',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testTaskLeadFreshNewBadCall() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Fresh','New',True);
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Bad Call',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        TaskObjDispositionCallBack.Reason__c ='Document Issue';
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        system.Test.stopTest();
    }
    @isTest
    Public static void testTaskLeadSuspectContactedBadCallCount() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Suspect','Contacted',true);
        objLead.Bad_Call_Count__c =15 ;
        update objLead;
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Bad Call',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        TaskObjDispositionCallBack.Reason__c ='Document Issue';
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testTaskLeadProspectActiveBadCall() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Prospect','Active',True);
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Bad Call',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        TaskObjDispositionCallBack.Reason__c ='Document Issue';
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        system.Test.stopTest();
    }
    @isTest
    Public static void testTaskLeadProspectActiveBadCallBadCallCount() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Prospect','Active',true);
        objLead.Bad_Call_Count__c =20;
        update objLead;
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Bad Call',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        TaskObjDispositionCallBack.Reason__c ='Document Issue';
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testTaskLeadSalesProcessingInActiveBadCall() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Sales Processing','Inactive',True);
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Bad Call',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        TaskObjDispositionCallBack.Reason__c ='Document Issue';
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testTaskLeadSalesProcessingNewBadCall() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Sales Processing','New',True);
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Bad Call',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        TaskObjDispositionCallBack.Reason__c ='Document Issue';
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        system.Test.stopTest();
    }
    @isTest
    Public static void testTaskLeadSalesProcessingNewBadCallCallCount() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Sales Processing','New',true);
        objLead.Bad_Call_Count__c =5;
        update objLead;
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Bad Call',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        TaskObjDispositionCallBack.Reason__c ='Document Issue';
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testTaskLeadSalesProcessingCallcentretripartyBadCallCallCount() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Sales Processing','Call centre triparty',true);
        objLead.Bad_Call_Count__c =20;
        update objLead;
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Bad Call',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        TaskObjDispositionCallBack.Reason__c ='Document Issue';
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testTaskLeadApplyingActiveBadCall() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Applying','Active',True);
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Bad Call',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        TaskObjDispositionCallBack.Reason__c ='Document Issue';
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testTaskLeadApplyingActiveBadCallCallCount() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Applying','Active',true);
        objLead.Bad_Call_Count__c =7;
        update objLead;
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Bad Call',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        TaskObjDispositionCallBack.Reason__c ='Document Issue';
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testTaskLeadApplyingInctiveBadCall() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Applying','Inactive',True);
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Bad Call',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        TaskObjDispositionCallBack.Reason__c ='Document Issue';
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testTaskLeadApplyingFutureProspectBadCall() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Applying','Future Prospect',True);
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Bad Call',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        TaskObjDispositionCallBack.Reason__c ='Document Issue';
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testTaskLeadApplyingFutureProspectBadCallCallCount() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Applying','Future Prospect',true);
        objLead.Bad_Call_Count__c =7;
        update objLead;
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Bad Call',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        TaskObjDispositionCallBack.Reason__c ='Document Issue';
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testupdateSubjectStatusFromDispositiont() {
        system.Test.startTest();
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Fresh','New',true);
        objLead.Bad_Call_Count__c =7;
        update objLead;
        datetime d= system.today()+1;
        String datetimeformt= d.format();
        Task TaskObjDispositionCallBackFirst = TestDataFactory.createTaskRecordTrigger('call Back',False);
        TaskObjDispositionCallBackFirst.call_back_date_time_New__c ='05/31/2023 18:19:03';
        TaskObjDispositionCallBackFirst.WhoId =objLead.Id;
        TaskObjDispositionCallBackFirst.Status ='Open';
        insert TaskObjDispositionCallBackFirst;
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Call Done',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =	'05/31/2023 18:19:03';
        TaskObjDispositionCallBack.Call_Back_Date_time__c =(TaskTriggerHandler.dateFormating(TaskObjDispositionCallBack.call_back_date_time_New__c));
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        TaskTriggerHandler.updateSubjectStatusFromDisposition(taskList);
        TaskTriggerHandler.dateFormating(TaskObjDispositionCallBack.call_back_date_time_New__c);
        system.Test.stopTest();
    }
    
    
    @isTest
    Public static void testassignmentOfStageOwnerToParentlead() {
        system.Test.startTest();
        User UserObj = [SELECT Id,Username,Profile.Name FROM User Where  Profile.Name = 'System Administrator' Limit 1];
        List<Task> taskList = New  List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Fresh','New',True);
        Task TaskObj = TestDataFactory.createTaskRecordTrigger('Tri Party Call',False);
        datetime d= system.today();
        String datetimeformt= d.format();
        TaskObj.call_back_date_time_New__c = datetimeformt;
        TaskObj.WhoId =objLead.Id;
        TaskObj.agentId__c =UserObj.Username;
        insert TaskObj;
        taskList.add(TaskObj);
        TaskTriggerHandler.assignmentOfStageOwnerToParentlead(taskList);
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testcreateMapOfMobileNumberVsLead() {
        system.Test.startTest();
        List<Task> taskList = New  List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Fresh','New',False);
        objLead.MobilePhone ='7387116477';
        insert objLead;
        Task TaskObj = TestDataFactory.createTaskRecordTrigger('Tri Party Call',False);
        TaskObj.WhoId =objLead.Id;
        TaskObj.Caller_Id__c = '07387116477';
        insert TaskObj;
        taskList.add(TaskObj);
        TaskTriggerHandler.createMapOfMobileNumberVsLead(taskList);
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testalertLeadOwnerWhenInbboundMissedCall() {
        system.Test.startTest();
        List<Task> taskList = New  List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Fresh','New',True);
        Task TaskObj = TestDataFactory.createTaskRecordTrigger('Call Back',False);
        datetime d= system.today();
        String datetimeformt= d.format();
        TaskObj.call_back_date_time_New__c = datetimeformt;
        TaskObj.WhoId =objLead.Id;
        TaskObj.agentStatus__c ='user_disconnected';
        insert TaskObj;
        taskList.add(TaskObj);
        Task TaskObjOwnerNul = TestDataFactory.createTaskRecordTrigger('Call Back',False);
        TaskObjOwnerNul.call_back_date_time_New__c = datetimeformt;
        TaskObjOwnerNul.whoId =null;
        TaskObjOwnerNul.agentStatus__c ='user_disconnected';
        insert TaskObjOwnerNul;
        taskList.add(TaskObjOwnerNul);
        TaskTriggerHandler.alertLeadOwnerWhenInbboundMissedCall(taskList);
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testupdateMissedCallSubjectFromDisposition() {
        system.Test.startTest();
        List<Task> taskList = New  List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Fresh','New',true);
        Task TaskObj = TestDataFactory.createTaskRecordTrigger('Tri Party Call',False);
        TaskObj.WhoId = objLead.Id;
        TaskObj.callStartTime__c = System.now();
        TaskObj.call_back_date_time_New__c ='10/31/2023 18:19:03';
        TaskObj.Caller_Id__c = '07387110120';
        TaskObj.Call_Result__c = null;
        taskObj.agentStatus__c=null;
        insert TaskObj;
        taskObj.agentStatus__c='user_disconnected';
        //Update TaskObj;
        taskList.add(TaskObj);
        //   TaskTriggerHandler.updateMissedCallSubjectFromDisposition(taskList);
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testallocateTaskToLead() {
        system.Test.startTest();
        Map<String,Lead> leadMap = new Map<String,Lead>();
        List<Task> taskList = New  List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Fresh','New',False);
        objLead.MobilePhone ='7387110120';
        leadMap.put(objLead.MobilePhone,objLead);
        Task TaskObj = TestDataFactory.createTaskRecordTrigger('Tri Party Call',False);
        TaskObj.WhoId = null;
        TaskObj.Caller_Id__c = '7387110120';
        insert TaskObj;
        taskList.add(TaskObj);
        TaskTriggerHandler.allocateTaskToLead(TaskObj,TaskObj,leadMap);
        TaskTriggerHandler.setStatusAndLostReson(TaskObj,TaskObj,leadMap);
        system.Test.stopTest();
    }
    
    
}