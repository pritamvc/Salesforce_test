@IsTest
public class CourseSecLookupFieldTest {
    
    
    @IsTest
    public static void testGetCourseLookupData_University() {
        // Create test data
        String objectApiName = 'University__c';
        String countryOfStudyLead = 'United States';
        String parentId = 'unversityId';
        String label = 'University';
        
        // Create a test record
        University__c universityRecord = TestDataFactory.createUniversity(true,countryOfStudyLead);
        
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
        University__c universityRecord = TestDataFactory.createUniversity(true,countryOfStudyLead);        
        String label = 'Institute';
        
        // Create a test record
        Institute__c instituteRecord = TestDataFactory.createInstitute(true,universityRecord.ID);
        
        // Call the method under test
        Test.startTest();
        List<Object> resultList = CourseSecLookupField.getCourseLookupData(objectApiName, countryOfStudyLead, universityRecord.ID, label);
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
        String label = 'Course';
        
        String countryOfStudyLead = 'United States';
        University__c universityRecord = TestDataFactory.createUniversity(true,countryOfStudyLead);        
        
        // Create a test record
        Institute__c instituteRecord = TestDataFactory.createInstitute(true,universityRecord.ID);
        
        // Create a test record
        Course__c courseRecord = TestDataFactory.createCourse(true,instituteRecord.ID);
        
        // Call the method under test
        Test.startTest();
        List<Object> resultList = CourseSecLookupField.getCourseLookupData(objectApiName, countryOfStudyLead, instituteRecord.ID, label);
        Test.stopTest();
        
        // Verify the results
        System.assertEquals(1, resultList.size());
        sObject resultRecord = (sObject)resultList[0];
        System.assertEquals(courseRecord.Id, resultRecord.get('Id'));
        System.assertEquals(courseRecord.Course_Name__c, resultRecord.get('Course_Name__c'));
        
        // Cleanup the test data
        delete courseRecord;
    }
}