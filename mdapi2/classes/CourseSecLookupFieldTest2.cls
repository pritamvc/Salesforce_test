/*@isTest
public class CourseSecLookupFieldTest {
@isTest
    Public static void testCourseSecLookupField() {
        
        Dedupe_Management__c customSettingDedupeManagemen = TestDataFactory.CreateDedupeManagementCustomSetting(true);
        Lead lrecrds=TestOrgDataFactory.createLead(true);
        University__c unvrecrds=TestOrgDataFactory.createUniversity(true,'USA');
       Institute__c insrecrds = TestOrgDataFactory.createInstitute(true);
          Course__c courrecrds = TestOrgDataFactory.createCourse(true);
        
        CourseSecLookupField.getCourseLookupData(null,null,null,null);

    }
    
}*/

@IsTest
public class CourseSecLookupFieldTest2 {
    @IsTest
    public static void testGetCourseLookupData_University() {
        // Create test data
        String objectApiName = 'University__c';
        String countryOfStudyLead = 'United States';
        String parentId = null;
        String label = 'University';

        // Create a mock university record
        University__c universityRecord = new University__c();
        universityRecord.Name = 'Test University';
        universityRecord.Country_Name__c = countryOfStudyLead;
        insert universityRecord;

        // Call the method under test
        Test.startTest();
        List<Object> resultList = CourseSecLookupField.getCourseLookupData(objectApiName, countryOfStudyLead, parentId, label);
        Test.stopTest();

        // Verify the results
        System.assertEquals(1, resultList.size());
        sObject resultRecord = (sObject)resultList[0];
        System.assertEquals(universityRecord.Id, resultRecord.get('Id'));
        System.assertEquals(universityRecord.Name, resultRecord.get('Name'));

        // Cleanup the test data
        delete universityRecord;
    }

 @IsTest
public static void testGetCourseLookupData_Institute() {
        // Create test data
        String objectApiName = 'Institute__c';
        String countryOfStudyLead = 'United States';
        String parentId = null;
        String label = 'Institute';

        // Create a mock university record
        Institute__c InstituteRecord = new Institute__c();
        InstituteRecord.Name = 'Test University';
        insert InstituteRecord;

        // Call the method under test
        Test.startTest();
        List<Object> resultList = CourseSecLookupField.getCourseLookupData(objectApiName, countryOfStudyLead, parentId, label);
        Test.stopTest();

        // Verify the results
        System.assertEquals(1, resultList.size());
        sObject resultRecord = (sObject)resultList[0];
        System.assertEquals(InstituteRecord.Id, resultRecord.get('Id'));
        System.assertEquals(InstituteRecord.Name, resultRecord.get('Name'));

        // Cleanup the test data
        delete InstituteRecord;
    }
}