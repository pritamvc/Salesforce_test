public class CourseSectionLookupField {
    @AuraEnabled(cacheable=true)
    public static List<Object> getLookupData(String objectApiName, String countryOfStudyLead,String parentId,String label) {
        system.debug('objectApiName======================= Inside Looupchild class =='+objectApiName);
        system.debug('countryOfStudyLead======================= Inside Looupchild class =='+countryOfStudyLead);
        system.debug('parentId======================= Inside Looupchild class =='+parentId);
        system.debug('label======================= Inside Looupchild class =='+label);
        
        
        List<Object> resultList = new List<Object>();
        
        /*   if(label == 'University'){
System.debug('In university code');

if(!String.isBlank(countryOfStudyLead)) {
String universityQuery = 'SELECT Id, Name FROM ' + objectApiName + ' WHERE Country_Name__c = \'' + countryOfStudyLead + '\'';

System.debug('universityQuery 1='+ universityQuery);
List<sObject> universityList = Database.query(universityQuery);
resultList.addAll(universityList);
}
} */
        if(label == 'Institute'){
            // System.debug('University Id:'+parentId);
            String instituteQuery = 'SELECT Id, Name, University__r.Country_Name__c FROM ' + objectApiName + ' WHERE University__r.Country_Name__c = \'' + countryOfStudyLead + '\'';
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
    
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getUniversityName(String parentId) {
        Map<String,String> mapUniversityNameVsId = new Map<String,String>();
        Institute__c InstituteRecord = [Select Id,Name,University__r.Name,University__r.Country_Name__c From Institute__c where Id =: parentId];
        mapUniversityNameVsId.put(InstituteRecord.University__r.Name,InstituteRecord.University__c);
        return mapUniversityNameVsId;
    }
}