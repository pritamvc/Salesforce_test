@IsTest
public class LeadCourseAndAcademicsTest {
    
    @IsTest
    public static void testGetCourseLookupDataUniversity() {
        
        String countryOfStudyLead = 'United States';
        
        // Create a test record
        University__c universityRecord = TestDataFactory.createUniversity(true,countryOfStudyLead);
        //insert universityRecord;
        
        // Call the method under test
        Test.startTest();
        LeadCourseAndAcademics.getInstituteFromUniversity(universityRecord.id);
        LeadCourseAndAcademics.getUniversityNameCourse(universityRecord.id);
        
        Test.stopTest();
    }
    
    @IsTest
    public static void testGetCourseLookupDataInstitute() {
        
        //String parentId = 'unversityId';
        //String label = 'Intitute';
        String countryOfStudyLead = 'United States';
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);  
        Lead lrecrds=TestDataFactory.createLead(true);
        University__c universityRecord = TestDataFactory.createUniversity(true,countryOfStudyLead);        
        Institute__c instituteRecord = TestDataFactory.createInstitute(true,universityRecord.ID);
        Course__c courseRecord =  TestDataFactory.createCourse(true,instituteRecord.ID);
        
        Test.startTest();
        LeadCourseAndAcademics.getInstituteRecord(instituteRecord.id);
        LeadCourseAndAcademics.getCourseIdName(courseRecord.ID);
        LeadCourseAndAcademics.getWrapperClassCommFormList(lrecrds.Id);
        //LeadCourseAndAcademics.createUpdateLeadWithRelatedInformation(null,lrecrds.Id);
        LeadCourseAndAcademics.fetchLanguageCategory();
        LeadCourseAndAcademics.fetchAnalyticalCategory();
        LeadCourseAndAcademics.fetchAnalyticalCategoryGRE();
        LeadCourseAndAcademics.getLookupData('Institute__c',null,universityRecord.Id,'Institute');
        LeadCourseAndAcademics.getUniversityName(instituteRecord.id);
        
        Test.stopTest();
        
    }
    @IsTest
    public static void testGetCourseLookupDataCourse() {
        
        //String parentId = 'instituteId';
        //String label = 'University';
        String countryOfStudyLead = 'United States';
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);  
        List<lead> leadlist = new List<Lead>();
        Lead lrecrds=TestDataFactory.createLead(true);
        leadlist.add(lrecrds);
        University__c universityRecord = TestDataFactory.createUniversity(true,countryOfStudyLead);        
        Institute__c instituteRecord = TestDataFactory.createInstitute(true,universityRecord.ID);
        Course__c courseRecord =  TestDataFactory.createCourse(true,instituteRecord.ID);
        
        Test.startTest();
        LeadCourseAndAcademics.getInstituteRecord(instituteRecord.id);
        LeadCourseAndAcademics.getCourseIdName(courseRecord.ID);
        LeadCourseAndAcademics.getWrapperClassCommFormList(lrecrds.Id);
        //LeadCourseAndAcademics.createUpdateLeadWithRelatedInformation(null,lrecrds.Id);
        LeadCourseAndAcademics.fetchLanguageCategory();
        LeadCourseAndAcademics.fetchAnalyticalCategory();
        LeadCourseAndAcademics.fetchAnalyticalCategoryGRE();
        LeadCourseAndAcademics.getLookupData('Course__c',null,instituteRecord.ID,'Course');
        LeadCourseAndAcademics.getWrapperClassCommFormList(leadlist[0].Id);        
        Test.stopTest();
        
    }
    @isTest
    static void testCreateUpdateLeadWithRelatedInformation() {
        // Create test data
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);  
        // Create test data
        Lead lrecrds=TestDataFactory.createLead(true);
        Account accrecrds =TestDataFactory.createPersonAccount(true);
        Co_Applicant__c coapprecrds = TestDataFactory.CreateCoApplicant(true);
        Education_Details__c edrecrds =TestDataFactory.createEducationDetails(true);
        
        // Create an instance of the wrapper class
        LeadCourseAndAcademics.WrapperClassLoanApplicationForm testWrapper = new LeadCourseAndAcademics.WrapperClassLoanApplicationForm();
        testWrapper.leadRecords = lrecrds;
        testWrapper.leadSaveRec = JSON.serialize(lrecrds);
        testWrapper.accRecords = coapprecrds;        
        testWrapper.appliAccSaveRec = JSON.serialize(accrecrds);
        testWrapper.appliEduDetailsRecord = new List<Education_Details__c>{ edrecrds };
            testWrapper.appliEduDetailsSave = JSON.serialize(new List<Education_Details__c>{ edrecrds });
        
        // Call the method to be tested
        Test.startTest();
        LeadCourseAndAcademics.WrapperClassLoanApplicationForm result = LeadCourseAndAcademics.createUpdateLeadWithRelatedInformation(JSON.serialize(testWrapper), lrecrds.Id);
        Test.stopTest();
        
        // Perform assertions
        System.assertEquals(lrecrds.Id, result.leadRecords.Id);
        // Perform other assertions as needed
        // ...
    }
    
     @IsTest
    public static void testCustomValidationHandler() {   
       // Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);   
       String countryOfStudyLead = 'United States';  
        
        Analytics_Score_Setting__mdt analyticsScore =[SELECT id,Analytical_Category__c,End_Range__c,Start_Range__c,Error_Message__c FROM Analytics_Score_Setting__mdt LIMIT 1 ];
        Language_Score_Setting__mdt languageScore =[SELECT id,Language_Category__c,End_Range__c,Start_Range__c,Error_Message__c FROM Language_Score_Setting__mdt LIMIT 1];
        Analytical_Score_GRE_Setting__mdt analyticsScoreGRE =[SELECT id,Analytical_Category_GRE__c,End_Range__c,Start_Range__c,Verbal_score_error_msg__c,Quantitative_score_error_msg__c FROM Analytical_Score_GRE_Setting__mdt LIMIT 1];
        
        University__c universityRecord = TestDataFactory.createUniversity(true,countryOfStudyLead);        
        Institute__c instituteRecord = TestDataFactory.createInstitute(true,universityRecord.ID);
        Course__c courseRecord =  TestDataFactory.createCourse(true,instituteRecord.ID);
        
        List<lead> leadlist = new List<Lead>();
        
        Lead lrecrds=TestDataFactory.createLead(false);
        lrecrds.Analytics_Score_Category__c=analyticsScore.Analytical_Category__c;
        lrecrds.Analytics_Test_Score__c=analyticsScore.End_Range__c;
        lrecrds.Language_Score_Category__c=languageScore.Language_Category__c;
        lrecrds.Language_Test_Score__c=languageScore.End_Range__c;
        
        
         
        //Record create for Verbal and Quantitave score.
        Lead lrecrds2=TestDataFactory.createLead(false);
        lrecrds2.Admission_Status__c='Confirmed';
        lrecrds2.University_Name__c=universityRecord.Id;
        lrecrds2.Institute_Name__c=instituteRecord.Id;
        lrecrds2.Course_Id__c=courseRecord.Id;
        lrecrds2.Analytics_Score_Category__c=analyticsScoreGRE.Analytical_Category_GRE__c;
        lrecrds.Analytics_Test_Score__c=260;
        lrecrds2.Verbal_Score__c=analyticsScoreGRE.End_Range__c;
        lrecrds2.Quantitative_Score__c=analyticsScoreGRE.End_Range__c;
        
        leadlist.add(lrecrds2);
        leadlist.add(lrecrds);
       

        Test.startTest();
        CustomValidationHandler.CustomValidationMethod(leadlist);
        Test.stopTest();
        if (!lrecrds.getErrors().isEmpty()) {
            System.assertEquals(AnalyticsScore.Error_Message__c, lrecrds.getErrors().get(0).getMessage());
        }
        
    }
    
    @IsTest
    public static void testGetCourseLookupDataUniversityDeal() {
        String countryOfStudyLead = 'United States';
        
        // Create a test record
        University__c universityRecord = TestDataFactory.createUniversity(true,countryOfStudyLead);
        //insert universityRecord;
        
        // Call the method under test
        Test.startTest();
        LeadDealCourseAndAcademics.getInstituteFromUniversity(universityRecord.id);
        LeadDealCourseAndAcademics.getUniversityNameCourse(universityRecord.id); 
        Test.stopTest();
    }
    
    @IsTest
    public static void testGetCourseLookupDataInstituteDeal() {
       
        String countryOfStudyLead = 'United States';
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);  
        Opportunity lrecrds = TestDataFactory.createOpportunity2(true);
        University__c universityRecord = TestDataFactory.createUniversity(true,countryOfStudyLead);        
        Institute__c instituteRecord = TestDataFactory.createInstitute(true,universityRecord.ID);
        Course__c courseRecord =  TestDataFactory.createCourse(true,instituteRecord.ID);
        
        Test.startTest();
        LeadDealCourseAndAcademics.getInstituteRecord(instituteRecord.id);
        LeadDealCourseAndAcademics.getCourseIdName(courseRecord.ID);
        LeadDealCourseAndAcademics.getWrapperClassCommFormList(lrecrds.Id);
        //LeadCourseAndAcademics.createUpdateLeadWithRelatedInformation(null,lrecrds.Id);
        LeadDealCourseAndAcademics.fetchLanguageCategory();
        LeadDealCourseAndAcademics.fetchAnalyticalCategory();
        LeadDealCourseAndAcademics.fetchAnalyticalCategoryGRE();
        LeadDealCourseAndAcademics.getLookupData('Institute__c',null,universityRecord.Id,'Institute');
        LeadDealCourseAndAcademics.getUniversityName(instituteRecord.id);
        
        Test.stopTest();  
    }
    
    @IsTest
    public static void testGetCourseLookupDataCourseDeal() {
        
        //String parentId = 'instituteId';
        //String label = 'University';
        String countryOfStudyLead = 'United States';
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);  
        List<lead> leadlist = new List<Lead>();
        Lead lrecrds=TestDataFactory.createLead(true);
        leadlist.add(lrecrds);
        University__c universityRecord = TestDataFactory.createUniversity(true,countryOfStudyLead);        
        Institute__c instituteRecord = TestDataFactory.createInstitute(true,universityRecord.ID);
        Course__c courseRecord =  TestDataFactory.createCourse(true,instituteRecord.ID);
        
        Test.startTest();
        LeadDealCourseAndAcademics.getInstituteRecord(instituteRecord.id);
        LeadDealCourseAndAcademics.getCourseIdName(courseRecord.ID);
        LeadDealCourseAndAcademics.getWrapperClassCommFormList(lrecrds.Id);
        //LeadCourseAndAcademics.createUpdateLeadWithRelatedInformation(null,lrecrds.Id);
        LeadDealCourseAndAcademics.fetchLanguageCategory();
        LeadDealCourseAndAcademics.fetchAnalyticalCategory();
        LeadDealCourseAndAcademics.fetchAnalyticalCategoryGRE();
        LeadDealCourseAndAcademics.getLookupData('Course__c',null,instituteRecord.ID,'Course');
        LeadDealCourseAndAcademics.getWrapperClassCommFormList(leadlist[0].Id);        
        Test.stopTest();
        
    }
    
    @isTest
    static void testCreateUpdateLeadWithRelatedInformationDeal() {
        // Create test data
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Triggers_Setup__c customSettingLeadTriggerManagemen = TestDataFactory.CreateLeadTriggerCustomSetting(true);  
        // Create test data
        Opportunity lrecrds = TestDataFactory.createOpportunity2(true);
        Account accrecrds =TestDataFactory.createPersonAccount(true);
        Co_Applicant__c coapprecrds = TestDataFactory.CreateCoApplicant(true);
        Education_Details__c edrecrds =TestDataFactory.createEducationDetails(true);
        
        // Create an instance of the wrapper class
        LeadDealCourseAndAcademics.WrapperClassLoanApplicationForm testWrapper = new LeadDealCourseAndAcademics.WrapperClassLoanApplicationForm();
        testWrapper.leadRecords = lrecrds;
        testWrapper.leadSaveRec = JSON.serialize(lrecrds);
        testWrapper.accRecords = coapprecrds;        
        testWrapper.appliAccSaveRec = JSON.serialize(accrecrds);
        testWrapper.appliEduDetailsRecord = new List<Education_Details__c>{ edrecrds };
            testWrapper.appliEduDetailsSave = JSON.serialize(new List<Education_Details__c>{ edrecrds });
        
        // Call the method to be tested
        Test.startTest();
        LeadDealCourseAndAcademics.WrapperClassLoanApplicationForm result = LeadDealCourseAndAcademics.createUpdateLeadWithRelatedInformation(JSON.serialize(testWrapper), lrecrds.Id);
        Test.stopTest();
        
        // Perform assertions
        System.assertEquals(lrecrds.Id, result.leadRecords.Id);
        // Perform other assertions as needed
        // ...
    }
}