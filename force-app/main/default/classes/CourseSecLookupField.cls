public class CourseSecLookupField {
    @AuraEnabled(cacheable=true)
    public static List<Object> getCourseLookupData(String objectApiName, String countryOfStudyLead,String parentId,String label) {
        List<Object> resultList = new List<Object>();
        
        if(label == 'University'){
            System.debug('In university code');
       
            if(!String.isBlank(countryOfStudyLead)) {
            String universityQuery = 'SELECT Id, Name FROM ' + objectApiName + ' WHERE Country_Name__c = \'' + countryOfStudyLead + '\'';

            System.debug('universityQuery 1='+ universityQuery);
            List<sObject> universityList = Database.query(universityQuery);
            resultList.addAll(universityList);
            }
        }
        else if(label == 'Institute'){
            System.debug('University Id:'+parentId);
            String instituteQuery = 'SELECT Id, Name FROM ' + objectApiName + ' WHERE University__c = \'' + String.escapeSingleQuotes(parentId) + '\'';
            System.debug('institute1=' + instituteQuery);

            List<sObject> instituteList = Database.query(instituteQuery );
            resultList.addAll(instituteList );
        }
        else if(label == 'Course'){
            System.debug('In course code');
            String universityQuery = 'SELECT Id, Course_Name__c FROM ' + objectApiName + ' WHERE Institute__c= \'' + String.escapeSingleQuotes(parentId) + '\'';

            System.debug('universityQuery 1='+ universityQuery);
            List<sObject> universityList = Database.query(universityQuery);
            resultList.addAll(universityList);
        }
        return resultList;
    }
}