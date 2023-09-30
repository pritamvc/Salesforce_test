public with sharing class FieldMappingController {
    @AuraEnabled(cacheable=true)
    public static List<FieldMapping__mdt> getFieldMappings() {
        return [SELECT Object_API_Name__c, Field_API_Name__c, Relationship_Field__c, Lookup_API_Name__c, label FROM FieldMapping__mdt WHERE Object_API_Name__c = 'Co_Applicant__c'];
    }
}