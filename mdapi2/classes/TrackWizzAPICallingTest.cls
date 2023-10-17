@isTest
public class TrackWizzAPICallingTest {

    @isTest
    static void testTrackWizzApi() {
        
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);  
        User dealOwner = TestDataFactory.createUserActive(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Date birthdate = Date.today().addYears(-20);
        Account AccountObj = TestDataFactory.createPersonAccount(True);
        
        Account coAppaccount = TestDataFactory.createPersonAccount(false);
        coAppaccount.FirstName = 'Account';
        coAppaccount.LastName = 'CoApplicant';
        coAppaccount.PAN_Number__c = 'AYSDG8451G';
        coAppaccount.Gender__c = 'Female';
        coAppaccount.Date_of_Birth__c = birthdate;
        insert coAppaccount;
        
        Opportunity opp = TestDataFactory.createOpportunity2(true);
        
        //Applicant Record
        Co_Applicant__c coApplicantObj = TestDataFactory.CreateCoApplicant(false);
        //coApplicantObj.Lead__c = LeadObj.Id;
        coApplicantObj.Account__c = AccountObj.Id;
        coApplicantObj.Deal__c = opp.Id;
        insert coApplicantObj;
        
        Source__c SourceObject = TestDataFactory.createSource(false);
        SourceObject.Name = 'Inbound';
        SourceObject.Partner_Name__c = null;
        insert SourceObject;
        
        //Co-Applicant Record
        Co_Applicant__c coApplicantObj1 = TestDataFactory.CreateCoApplicantRecord(false);
        //coApplicantObj1.Lead__c = LeadObj.Id;
        coApplicantObj1.Account__c = coAppaccount.Id;
        coApplicantObj1.Deal__c = opp.Id;
        insert coApplicantObj1;

        
        //ContactPointAddress(Address Record) for Applicant
        ContactPointAddress  ContactPointAddressobj  = TestDataFactory.createContactPointAddress(true);
        //ContactPointAddressobj.Lead__c = LeadObj.Id;
        ContactPointAddressobj.Account__c = coApplicantObj1.Account__c;
        ContactPointAddressobj.Deal__c = opp.Id;
        ContactPointAddressobj.Address_1__c = 'Rukhmai Niwas surynagari midc jalcohi baramati Near SAMARATH ';
        update ContactPointAddressobj;
        
        //ContactPointAddress(Address Record) for Applicant
        ContactPointAddress  ContactPointAddressobj3  = TestDataFactory.createContactPointAddressPer(true);
        //ContactPointAddressobj3.Lead__c = LeadObj.Id;
        ContactPointAddressobj3.Account__c =coApplicantObj1.Account__c;
        ContactPointAddressobj3.Deal__c = opp.Id;
        ContactPointAddressobj3.Address_1__c = 'Rukhmai Niwas surynagari midc jalcohi baramati Near SAMARATH';
        update ContactPointAddressobj3;
        
        //ContactPointAddress(Address Record) for Co-Applicant
        ContactPointAddress  ContactPointAddressobj1  = TestDataFactory.createContactPointAddress(true);
        //ContactPointAddressobj1.Lead__c = LeadObj.Id;
        ContactPointAddressobj1.Account__c = coApplicantObj1.Account__c;
        ContactPointAddressobj1.Deal__c = opp.Id;
        ContactPointAddressobj1.Address_1__c = 'Rukhmai Niwas surynagari midc jalcohi baramati Near SAMARATH pOLICE CHOWKIIII shiavay Grocery shopppppppppppp';
        update ContactPointAddressobj1;

        //ContactPointAddress(Address Record) for Co-Applicant's office
        ContactPointAddress  ContactPointAddressobj2  = TestDataFactory.createContactPointAddressOffice(true);
        //ContactPointAddressobj2.Lead__c = LeadObj.Id;
        ContactPointAddressobj2.Account__c = coApplicantObj1.Account__c;
        ContactPointAddressobj1.Deal__c = opp.Id;
        ContactPointAddressobj1.Address_1__c = 'Rukhmai Niwas surynagari midc jalcohi baramati Near SAMARATH pOLICE CHOWKIIII shiavay Grocery shopppppppppppp';
        update ContactPointAddressobj2;
        
        Document_Checklist_Master__c  docChecklistApplicant  = TestDataFactory.createDocumnetChecklistMaster(false);
        docChecklistApplicant.Applicant_Type__c = 'Applicant';
        docChecklistApplicant.Document_Sub_Type__c = 'Screening';
        docChecklistApplicant.IsMandetory__c = 'No';
        docChecklistApplicant.Auto_Create_Checklist__c = false;
        insert docChecklistApplicant;
        
        Document_Checklist_Master__c  docChecklistCoApp  = TestDataFactory.createDocumnetChecklistMaster(false);
        docChecklistCoApp.Applicant_Type__c = 'CoApplicant';
        docChecklistCoApp.Document_Sub_Type__c = 'Screening';
        docChecklistCoApp.IsMandetory__c = 'No';
        docChecklistCoApp.Auto_Create_Checklist__c = false;
        insert docChecklistCoApp;
        
        List<Opportunity> oppList = New List<Opportunity>();
        oppList.add(opp);
        Test.startTest();
        HTTPRequestMock response = new HTTPRequestMock('SUCCESS');
        Test.setMock(HttpCalloutMock.class, response);
		TrackWizzAPICalling.getRelatedRecordsAndCallTrackWizzApi(oppList);
        Test.stopTest();
    }
    
    @isTest
    static void testTrackWizzApifailure() {
        
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);  
        User dealOwner = TestDataFactory.createUserActive(true);
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Date birthdate = Date.today().addYears(-20);
        Account AccountObj = TestDataFactory.createPersonAccount(True);
        
        Account coAppaccount = TestDataFactory.createPersonAccount(false);
        coAppaccount.FirstName = 'Account';
        coAppaccount.LastName = 'CoApplicant';
        coAppaccount.PAN_Number__c = 'AYSDG8451G';
        coAppaccount.Gender__c = 'Female';
        coAppaccount.Date_of_Birth__c = birthdate;
        insert coAppaccount;
        
        Opportunity opp = TestDataFactory.createOpportunity2(true);
        
        //Applicant Record
        Co_Applicant__c coApplicantObj = TestDataFactory.CreateCoApplicant(false);
        //coApplicantObj.Lead__c = LeadObj.Id;
        coApplicantObj.Account__c = AccountObj.Id;
        coApplicantObj.Deal__c = opp.Id;
        insert coApplicantObj;
        
        Source__c SourceObject = TestDataFactory.createSource(false);
        SourceObject.Name = 'Inbound';
        SourceObject.Partner_Name__c = null;
        insert SourceObject;
        
        //Co-Applicant Record
        Co_Applicant__c coApplicantObj1 = TestDataFactory.CreateCoApplicantRecord(false);
        //coApplicantObj1.Lead__c = LeadObj.Id;
        coApplicantObj1.Account__c = coAppaccount.Id;
        coApplicantObj1.Deal__c = opp.Id;
        insert coApplicantObj1;

        
        //ContactPointAddress(Address Record) for Applicant
        ContactPointAddress  ContactPointAddressobj  = TestDataFactory.createContactPointAddress(true);
        //ContactPointAddressobj.Lead__c = LeadObj.Id;
        ContactPointAddressobj.Account__c = coApplicantObj1.Account__c;
        ContactPointAddressobj.Deal__c = opp.Id;
        ContactPointAddressobj.Address_1__c = 'Rukhmai Niwas surynagari midc jalcohi baramati Near SAMARATH ';
        update ContactPointAddressobj;
        
        //ContactPointAddress(Address Record) for Applicant
        ContactPointAddress  ContactPointAddressobj3  = TestDataFactory.createContactPointAddressPer(true);
        //ContactPointAddressobj3.Lead__c = LeadObj.Id;
        ContactPointAddressobj3.Account__c =coApplicantObj1.Account__c;
        ContactPointAddressobj3.Deal__c = opp.Id;
        ContactPointAddressobj3.Address_1__c = 'Rukhmai Niwas surynagari midc jalcohi baramati Near SAMARATH';
        update ContactPointAddressobj3;
        
        //ContactPointAddress(Address Record) for Co-Applicant
        ContactPointAddress  ContactPointAddressobj1  = TestDataFactory.createContactPointAddress(true);
        //ContactPointAddressobj1.Lead__c = LeadObj.Id;
        ContactPointAddressobj1.Account__c = coApplicantObj1.Account__c;
        ContactPointAddressobj1.Deal__c = opp.Id;
        ContactPointAddressobj1.Address_1__c = 'Rukhmai Niwas surynagari midc jalcohi baramati Near SAMARATH pOLICE CHOWKIIII shiavay Grocery shopppppppppppp';
        update ContactPointAddressobj1;
        
        //ContactPointAddress(Address Record) for Co-Applicant's office
        ContactPointAddress  ContactPointAddressobj2  = TestDataFactory.createContactPointAddressOffice(true);
        //ContactPointAddressobj2.Lead__c = LeadObj.Id;
        ContactPointAddressobj2.Account__c = coApplicantObj1.Account__c;
        ContactPointAddressobj1.Deal__c = opp.Id;
        ContactPointAddressobj1.Address_1__c = 'Rukhmai Niwas surynagari midc jalcohi baramati Near SAMARATH pOLICE CHOWKIIII shiavay Grocery shopppppppppppp';
        update ContactPointAddressobj2;
        
        Document_Checklist_Master__c  docChecklistApplicant  = TestDataFactory.createDocumnetChecklistMaster(false);
        docChecklistApplicant.Applicant_Type__c = 'Applicant';
        docChecklistApplicant.Document_Sub_Type__c = 'Screening';
        docChecklistApplicant.IsMandetory__c = 'No';
        docChecklistApplicant.Auto_Create_Checklist__c = false;
        insert docChecklistApplicant;
        
        Document_Checklist_Master__c  docChecklistCoApp  = TestDataFactory.createDocumnetChecklistMaster(false);
        docChecklistCoApp.Applicant_Type__c = 'CoApplicant';
        docChecklistCoApp.Document_Sub_Type__c = 'Screening';
        docChecklistCoApp.IsMandetory__c = 'No';
        docChecklistCoApp.Auto_Create_Checklist__c = false;
        insert docChecklistCoApp;
        
        List<Opportunity> oppList = New List<Opportunity>();
        oppList.add(opp);
        Test.startTest();
        HTTPRequestMock response = new HTTPRequestMock('FAILURE');
        Test.setMock(HttpCalloutMock.class, response);
		TrackWizzAPICalling.getRelatedRecordsAndCallTrackWizzApi(oppList);
        Test.stopTest();
    }
}