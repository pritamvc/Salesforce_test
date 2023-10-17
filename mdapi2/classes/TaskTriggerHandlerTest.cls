@isTest
public class TaskTriggerHandlerTest {
    @isTest
    Public static void testTasktrigger() {
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Fresh','New',True);
        Task TaskObj = TestDataFactory.createTaskRecordTrigger('Call Back',False);
        TaskObj.WhoId =objLead.Id;
        insert TaskObj;
        TaskObj.Call_Result__c ='Bad Call';
        Update TaskObj;
        TaskObj.Call_Result__c ='Call Back';
        TaskObj.call_back_date_time_New__c = '';
        Update TaskObj;
        /* datetime d= system.today();
String datetimeformt= d.format();
TaskObj.call_back_date_time_New__c = datetimeformt;
Update TaskObj;*/
        TaskObj.whoId =null;
        Update TaskObj; 
        system.Test.stopTest();
    } 
    
    @isTest
    Public static void testTaskLeadFreshNew() {
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Fresh','New',True);
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Call Back',False);
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        taskList.add(TaskObjDispositionCallBack);
        
        Task TaskObjDispositionCallDenied = TestDataFactory.createTaskRecordTrigger('Customer Denied the Loan not interested',False);
        TaskObjDispositionCallDenied.WhoId =objLead.Id;
        taskList.add(TaskObjDispositionCallDenied);
        
        Task TaskObjDispositionFutureProspect = TestDataFactory.createTaskRecordTrigger('Future Prospect',False);
        TaskObjDispositionFutureProspect.WhoId =objLead.Id;
        taskList.add(TaskObjDispositionFutureProspect);
        
        Task TaskObjDispositionInvalid = TestDataFactory.createTaskRecordTrigger('Invalid',False);
        TaskObjDispositionInvalid.WhoId =objLead.Id;
        taskList.add(TaskObjDispositionInvalid);
        
        Task TaskObjDispositionNonDuableAuxilo = TestDataFactory.createTaskRecordTrigger('Not Doable By Auxilo',False);
        TaskObjDispositionNonDuableAuxilo.WhoId =objLead.Id;
        taskList.add(TaskObjDispositionNonDuableAuxilo);
        
        Task TaskObjDispositionPassiveTransfer = TestDataFactory.createTaskRecordTrigger('Passive Transfer to CEM',False);
        TaskObjDispositionPassiveTransfer.WhoId =objLead.Id;
        taskList.add(TaskObjDispositionPassiveTransfer);
        
        Task TaskObjDispositionTriPartyCall = TestDataFactory.createTaskRecordTrigger('Tri Party Call',False);
        TaskObjDispositionTriPartyCall.WhoId =objLead.Id;
        taskList.add(TaskObjDispositionTriPartyCall);
        
        /*Task TaskObjDispositionWillingToApply = TestDataFactory.createTaskRecordTrigger('Willing To Apply',False);
TaskObjDispositionWillingToApply.WhoId =objLead.Id;
insert TaskObjDispositionWillingToApply;
taskList.add(TaskObjDispositionWillingToApply);*/
        
        Task TaskObjDispositionActiveTransfer = TestDataFactory.createTaskRecordTrigger('Active Transfer to CEM',False);
        TaskObjDispositionActiveTransfer.WhoId =objLead.Id;
        taskList.add(TaskObjDispositionActiveTransfer);    
        
        Task TaskObjDispositionApplicationFormalitiesCompleted = TestDataFactory.createTaskRecordTrigger('Application Formalities Completed',False);
        TaskObjDispositionApplicationFormalitiesCompleted.WhoId =objLead.Id;
        taskList.add(TaskObjDispositionApplicationFormalitiesCompleted); 
        
        Task TaskObjDispositionDuplicateLead = TestDataFactory.createTaskRecordTrigger('Duplicate Lead',False);
        TaskObjDispositionDuplicateLead.WhoId =objLead.Id;
        taskList.add(TaskObjDispositionDuplicateLead);  
        
        //TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        
        system.Test.stopTest();
    } 
    
    @isTest
    Public static void testTaskLeadFreshNewtwo() {
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Fresh','New',True);
        
        
        Task TaskObjDispositionPushToLos = TestDataFactory.createTaskRecordTrigger('Push to LOS',False);
        TaskObjDispositionPushToLos.WhoId =objLead.Id;
        taskList.add(TaskObjDispositionPushToLos);  
        
        Task TaskObjDispositionBadCall = TestDataFactory.createTaskRecordTrigger('Bad Call',False);
        TaskObjDispositionBadCall.WhoId =objLead.Id;
        taskList.add(TaskObjDispositionBadCall);  
        
        Task TaskObjDispositionReadyToApply = TestDataFactory.createTaskRecordTrigger('Ready to Apply',False);
        TaskObjDispositionReadyToApply.WhoId =objLead.Id;
        taskList.add(TaskObjDispositionReadyToApply);  
        
        Task TaskObjDispositionPartialDocument = TestDataFactory.createTaskRecordTrigger('Partial Documents Received',False);
        TaskObjDispositionPartialDocument.WhoId =objLead.Id;
        taskList.add(TaskObjDispositionPartialDocument);  
        
        Task TaskObjDispositionInboundMissedCall = TestDataFactory.createTaskRecordTrigger('Inbound Missed Call',False);
        TaskObjDispositionInboundMissedCall.WhoId =objLead.Id;
        taskList.add(TaskObjDispositionInboundMissedCall); 
        
        Task TaskObjDispositionOnlineApplication = TestDataFactory.createTaskRecordTrigger('Online Application Form Fulfilment Initiated',False);
        TaskObjDispositionOnlineApplication.WhoId =objLead.Id;
        taskList.add(TaskObjDispositionOnlineApplication); 
        
        Task TaskObjDispositionOnApplicationDropped = TestDataFactory.createTaskRecordTrigger('Application Fulfilment Dropped',False);
        TaskObjDispositionOnApplicationDropped.WhoId =objLead.Id;
        taskList.add(TaskObjDispositionOnApplicationDropped); 
        
        Task TaskObjDispositionODoNotDisturb = TestDataFactory.createTaskRecordTrigger('Do Not Disturb',False);
        TaskObjDispositionODoNotDisturb.WhoId =objLead.Id;
        taskList.add(TaskObjDispositionODoNotDisturb); 
        
        Task TaskObjDispositionCallDone = TestDataFactory.createTaskRecordTrigger('Call Done',False);
        TaskObjDispositionCallDone.WhoId =objLead.Id;
        taskList.add(TaskObjDispositionCallDone); 
        
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testTaskLeadSalesProcessingCallBack() {
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Suspect','Contacted',True);
       /* Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Call Back',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        objLead.Call_Back_Count__c = 15;
        update objLead;
       */ Task TaskObjDispositionCallBackUpdated = TestDataFactory.createTaskRecordTrigger('Call Back',False);
        TaskObjDispositionCallBackUpdated.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBackUpdated.WhoId =objLead.Id;
        insert TaskObjDispositionCallBackUpdated;
        taskList.add(TaskObjDispositionCallBackUpdated);
        // TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        
        system.Test.stopTest();
    }  
    @isTest
    Public static void testTaskLeadProspectActiveCallBack() {
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Prospect','Active',True);
       /* Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Call Back',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        objLead.Call_Back_Count__c = 20;
        update objLead;
       */ Task TaskObjDispositionCallBackUpdated = TestDataFactory.createTaskRecordTrigger('Call Back',False);
        TaskObjDispositionCallBackUpdated.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBackUpdated.WhoId =objLead.Id;
        insert TaskObjDispositionCallBackUpdated;
        taskList.add(TaskObjDispositionCallBackUpdated);
        TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testTaskLeadApplyingInactiveCallBack() {
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Sales Processing','New',True);
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Future Prospect',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        //insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        //TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testTaskLeadSalesProcessingAtiveApplying() {
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Applying','Active',True);
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Future Prospect',False);
        TaskObjDispositionCallBack.call_back_date_time_New__c =string.ValueOf(System.Today());
        TaskObjDispositionCallBack.WhoId =objLead.Id;
        //insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        //TaskTriggerHandler.updateStageStatusFromDisposition(taskList,true,true);
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testTaskLeadSalesProcessingCallcentretripartyCallBack() {
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
    Public static void testTaskLeadApplyingFutureProspectBadCallCallCount() {
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
    Public static void testupdateSubjectStatusFromDispositiont() {
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
        //TaskTriggerHandler.updateSubjectStatusFromDisposition(taskList);
        TaskTriggerHandler.dateFormating(TaskObjDispositionCallBack.call_back_date_time_New__c);
        system.Test.stopTest();
    }
    
    
    @isTest
    Public static void testassignmentOfStageOwnerToParentlead() {
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        User UserObj = [SELECT Id,Username,Profile.Name FROM User Where  Profile.Name = 'System Administrator' Limit 1];
        List<Task> taskList = New  List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Fresh','New',false);
        objLead.Stage_Owner__c = UserObj.Id;
        insert objLead;
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
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
        //TaskTriggerHandler.alertLeadOwnerWhenInbboundMissedCall(taskList);
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testupdateMissedCallSubjectFromDisposition() {
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        List<Task> taskList = New  List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Fresh','New',true);
        Task TaskObj = TestDataFactory.createTaskRecordTrigger('Tri Party Call',False);
        TaskObj.WhoId = objLead.Id;
        TaskObj.callStartTime__c = System.now();
        TaskObj.call_back_date_time_New__c ='10/31/2023 18:19:03';
        TaskObj.Caller_Id__c = '07387110120';
        TaskObj.Call_Result__c = null;
        taskObj.agentStatus__c=null;
        taskObj.Status = 'Open';
        insert TaskObj;
        taskObj.agentStatus__c='user_disconnected';
        //taskObj.Status = 'Completed';
        //  Update TaskObj;
        taskList.add(TaskObj);
        //TaskTriggerHandler.updateMissedCallSubjectFromDisposition(taskList);
        system.Test.stopTest();
    }
    
    @isTest
    Public static void testallocateTaskToLead() {
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
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
    
    /*@isTest
    Public static void testsendEmailNotificationToLoginDeskUserAfterCompleteDocumentIssue() {
        //TestDataFactory.createInboundSource(true);
        system.Test.startTest();
        Profile loginDeskProfile = [SELECT Id FROM Profile WHERE Name = 'Login Desk' LIMIT 1];
        User UserObj = new User(
            Username = 'testusevvyr@example.com',
            LastName = 'Test User',
            Alias = 'tuser',
            Email = 'testuser@qqexample.comqqq',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = loginDeskProfile.Id,LanguageLocaleKey='en_US'
        );
        insert UserObj;
        //User UserObj = [SELECT Id,Username,Profile.Name FROM User Where  Profile.Name = 'Login Desk' Limit 1];
        List<Task> taskList = new List<Task>();
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Applying','Active',false);
        objLead.Stage_Owner__c = UserObj.Id;
        insert objLead ;
        Task TaskObjDispositionCallBack = TestDataFactory.createTaskRecordTrigger('Call Back',False);
        TaskObjDispositionCallBack.Subject = 'Document Issues';
        TaskObjDispositionCallBack.Status = 'Completed';
        TaskObjDispositionCallBack.WhoId = objLead.Id;
        insert TaskObjDispositionCallBack;
        taskList.add(TaskObjDispositionCallBack);
        TaskTriggerHandler.sendEmailNotificationToLoginDeskUserAfterCompleteDocumentIssue(taskList);
        
        system.Test.stopTest();
    }*/
    
    @isTest 
    static void testUpdateStageStatusFromDisposition() {
        Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        // Create test data
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Fresh','New',true);

        Task testTask = new Task(
            Subject = 'Test Task',
            WhoId = objLead.Id,
            Reason__c = 'No Security',Call_Result__c='Bad Call' // You need to provide appropriate value
        );
        insert testTask;

        TaskTriggerHandler.updateStageStatusFromDispositionForCustomerDeniedLoanAndNotDoable(objLead, CommonConstant.LEAD_STATUS_NOT_INTRESTED, testTask);
        Test.stopTest();
    }
    
    @isTest static void testUpdateStageStatusFromDispositionForFutureProspect() {
        Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);

        // Create test lead and task records
        Lead objLead =TestDataFactory.createLeadTaskTrigger('Fresh','New',true);

        Task testTask = new Task(
            WhoId = objLead.Id,
            call_back_date_time_New__c = '10/31/2023 18:19:03'
            // Populate other required fields
        );
        insert testTask;

        // Call the method to be tested
        TaskTriggerHandler.updateStageStatusFromDispositionForFutureProspect(objLead, testTask);
        Test.stopTest();
    }
    
    @isTest static void testUpdateStageStatusFromDispositionForFutureProspect1() {
        Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);

        // Create test lead and task records
        Lead objLead =TestDataFactory.createLeadTaskTrigger(CommonConstant.LEAD_STATUS_SALES_PROCESSING ,'New',true);

        Task testTask = new Task(
            WhoId = objLead.Id,
            call_back_date_time_New__c = '10/31/2023 18:19:03'
            // Populate other required fields
        );
        insert testTask;

        // Call the method to be tested
        TaskTriggerHandler.updateStageStatusFromDispositionForFutureProspect(objLead, testTask);
        Test.stopTest();
    }
    
    @isTest static void testUpdateStageStatusFromDispositionForFutureProspect2() {
        Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);

        // Create test lead and task records
        Lead objLead =TestDataFactory.createLeadTaskTrigger(CommonConstant.LEAD_STATUS_APPLYING,CommonConstant.LEAD_STATUS_ACTIVE,true);

        Task testTask = new Task(
            WhoId = objLead.Id,
            call_back_date_time_New__c = '10/31/2023 18:19:03'
            // Populate other required fields
        );
        insert testTask;

        // Call the method to be tested
        TaskTriggerHandler.updateStageStatusFromDispositionForFutureProspect(objLead, testTask);
        Test.stopTest();
    }
    
    @isTest static void testUpdateStageStatusFromDispositionForInvalid() {
        Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);

        Lead objLead =TestDataFactory.createLeadTaskTrigger('Fresh','New',true);

        Task testTask = new Task(
            WhoId = objLead.Id,
            Description = 'Some description' // Add a description to simulate valid condition
        );
        insert testTask;

        // Call the method to be tested
        TaskTriggerHandler.updateStageStatusFromDispositionForInvalid(objLead, testTask);
        Test.stopTest();
    }
    
    @isTest static void testUpdateStageStatusFromDispositionForActiveTransfer() {
        Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);

        Lead objLead =TestDataFactory.createLeadTaskTrigger('Fresh','New',true);

        Task testTask = new Task(
            WhoId = objLead.Id,
            Description = 'Some description' // Add a description to simulate valid condition
            // Populate other required fields
        );
        insert testTask;

        Boolean senEmailToQueue = true; // You can set this based on your test scenario

        // Call the method to be tested
        TaskTriggerHandler.updateStageStatusFromDispositionForActiveTransfer(objLead, testTask, senEmailToQueue);
        Test.stopTest();
    }
    
    
    @isTest static void testSendEmailNotificationToLoginDeskUserAfterCompleteDocumentIssue() {
        Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);

        User u=TestDataFactory.createUserCallCenter(false);
        u.Email = 'testnotification@gmail.com';
        u.Username = 'testnotification@gmail.com';
        insert u;
        Lead objLead1 =TestDataFactory.createLeadTaskTrigger('Fresh','New',false);
        objLead1.Stage_Owner__c = u.Id;
        insert objLead1;
        // Create test lead records
        //Lead testLead1 = new Lead(Stage_Owner__c = '005xx', Stage_Owner__r = new User(Email = 'user1@example.com', Name = 'User 1'), Owner = new User(Email = 'user2@example.com'));
        //Lead testLead2 = new Lead(Stage_Owner__c = '006xx', Stage_Owner__r = new User(Email = 'user3@example.com', Name = 'User 3'), Owner = new User(Email = 'user4@example.com'));
        //insert new List<Lead>{objLead1};

        // Create test task records
        Task testTask1 = new Task(WhoId = objLead1.Id);
        insert new List<Task>{testTask1};

        List<Task> completedTasks = new List<Task>{testTask1};

        // Call the method to be tested
        TaskTriggerHandler.sendEmailNotificationToLoginDeskUserAfterCompleteDocumentIssue(completedTasks);
        Test.stopTest();
    }
    
    @isTest static void testCreateMapOfAgentIdVsUser() {
        Test.startTest();
        // Create test task records
        Task testTask1 = new Task(agentId__c = 'agent1@example.com');
        Task testTask2 = new Task(agentId__c = 'agent2@example.com');
        insert new List<Task>{testTask1, testTask2};

        List<Task> taskList = new List<Task>{testTask1, testTask2};

        // Call the method to be tested
        Map<String, User> resultMap = TaskTriggerHandler.createMapOfAgentIdVsUser(taskList);

        Test.stopTest();
    }
    
    @isTest static void testAssignUserToTheLeadTask() {
        Test.startTest();

        // Create a Profile for the User
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User']; // Replace with an actual profile name

        // Create and insert a new User
        User testUser = new User(
            LastName = 'TestUserLastName',
            Email = 'testuser@example.com',
            UserName='testusewr@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = testProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        // Create a task record
        Task testTask = new Task(agentId__c = testUser.Username);
        Task newTask = new Task();

        Map<String, User> userMap = new Map<String, User>{
            testUser.Username => testUser
        };

        // Call the method to be tested
        TaskTriggerHandler.assignUserToTheLeadTask(testTask, newTask, userMap);

        Test.stopTest();
    }
    
    
    @isTest static void testUpdateSubjectStatusFromDisposition() {
        Test.startTest();
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);

         Lead objLead1 =TestDataFactory.createLeadTaskTrigger('Fresh','New',true);

        // Create test task records
        Task testTask = new Task(
            WhoId = objLead1.Id,
            Call_Result__c = 'Invalid',
            call_back_date_time_New__c = '10/31/2023 18:19:03',
            agentId__c = 'agent1@example.com'
            // Populate other required fields
        );
        insert testTask;

        List<Task> dispositionTaskList = new List<Task>{testTask};

        // Call the method to be tested
        TaskTriggerHandler.updateSubjectStatusFromDisposition(dispositionTaskList);

        Test.stopTest();
    }

}