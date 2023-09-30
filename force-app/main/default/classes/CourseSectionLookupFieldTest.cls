@IsTest
public class CourseSectionLookupFieldTest {
@IsTest
    public static void testGetCourseLookupData_University() {
        // Create test data
        String objectApiName = 'University__c';
        String countryOfStudyLead = 'United States';
        String parentId = 'unversityId';
        String label = 'University';

        // Create a test record
        University__c universityRecord = TestDataFactory.createUniversity(true,countryOfStudyLead);
        //insert universityRecord;

        // Call the method under test
        Test.startTest();
        List<Object> resultList = CourseSectionLookupField.getLookupData(objectApiName, countryOfStudyLead, parentId, label);
        Test.stopTest();

        // Verify the results
        //System.assertEquals(1, resultList.size());
        //sObject resultRecord = (sObject)resultList[0];
        //System.assertEquals(universityRecord.Id, resultRecord.get('Id'));
       // System.assertEquals(universityRecord.Name, resultRecord.get('Name'));

        // Cleanup the test data
        delete universityRecord;
    }

    @IsTest
    public static void testGetCourseLookupData_Institute() {
        // Create test data
        String objectApiName = 'Institute__c';
        //String countryOfStudyLead = null;
        //String parentId = 'a0KBi000001wWWxMAM';
        String countryOfStudyLead = 'United States';
      University__c universityRecord = TestDataFactory.createUniversity(true,countryOfStudyLead);        
        //  String parentId ='universityId';
        String label = 'Institute';

        // Create a test record
        Institute__c instituteRecord = TestDataFactory.createInstitute(true,universityRecord.ID);
        //insert instituteRecord;

        // Call the method under test
        Test.startTest();
        List<Object> resultList = CourseSectionLookupField.getLookupData(objectApiName, countryOfStudyLead, universityRecord.ID, label);
        Test.stopTest();

        // Verify the results
        System.assertEquals(1, resultList.size());
        sObject resultRecord = (sObject)resultList[0];
        System.assertEquals(instituteRecord.Id, resultRecord.get('Id'));
        System.assertEquals(instituteRecord.Name, resultRecord.get('Name'));

        // Cleanup the test data
        delete instituteRecord;
    }

    @IsTest
    public static void testGetCourseLookupData_Course() {
        // Create test data
        String objectApiName = 'Course__c';
       // String countryOfStudyLead = null;
        //String parentId = 'a0JBi0000000sZtMAI';
     // String parentId = 'instituteId';
        String label = 'Course';

         String countryOfStudyLead = 'United States';
      University__c universityRecord = TestDataFactory.createUniversity(true,countryOfStudyLead);        
         // String parentId ='universityId';
       // String label = 'Institute';

        // Create a test record
        Institute__c instituteRecord = TestDataFactory.createInstitute(true,universityRecord.ID);
        
        // Create a test record
        Course__c courseRecord = TestDataFactory.createCourse(true,instituteRecord.ID);
        //insert courseRecord;

        // Call the method under test
        Test.startTest();
        List<Object> resultList = CourseSectionLookupField.getLookupData(objectApiName, countryOfStudyLead, instituteRecord.ID, label);
        Test.stopTest();

        // Verify the results
        System.assertEquals(1, resultList.size());
        sObject resultRecord = (sObject)resultList[0];
        System.assertEquals(courseRecord.Id, resultRecord.get('Id'));
        System.assertEquals(courseRecord.Course_Name__c, resultRecord.get('Course_Name__c'));

        // Cleanup the test data
        delete courseRecord;
    }
    @IsTest
    static void testGetUniversityName() {
        // Create test data
        Institute__c institute = new Institute__c();
        institute.Name = 'Test Institute';
        University__c university = new University__c();
        university.Name = 'Test University';
        university.Country_Name__c = 'Test Country';
        insert university;
        institute.University__c = university.Id;
        insert institute;
        
        Test.startTest();
        // Call the method to test
        Map<String, String> result = CourseSectionLookupField.getUniversityName(institute.Id);
        
        // Perform assertions
        System.assertEquals(1, result.size(), 'Expected one result');
        //System.assertEquals('Test University', result.get('Test University'), 'Expected University name');
        
        Test.stopTest();
    }
}