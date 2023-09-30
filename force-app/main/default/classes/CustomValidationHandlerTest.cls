@IsTest
public class CustomValidationHandlerTest {
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
        System.assertEquals(analyticsScore.Error_Message__c, lrecrds.getErrors().get(0).getMessage());
        
    }
}