public with sharing class ApplicantController {
    @AuraEnabled(cacheable=true)
    public static List<ApplicantDataWrapper> getApplicantData() {
        List<ApplicantDataWrapper> applicantData = new List<ApplicantDataWrapper>();
        
        // Query the custom metadata records for field mapping
        List<FieldMapping__mdt> fieldMappings = [SELECT Object_API_Name__c, Field_API_Name__c, Relationship_Field__c, Lookup_API_Name__c, label FROM FieldMapping__mdt WHERE Object_API_Name__c = 'Co_Applicant__c'];
        
        // Get the API names of the fields to query dynamically
        Set<String> fieldAPINames = new Set<String>();
        for (FieldMapping__mdt fieldMapping : fieldMappings) {
            if (fieldMapping.Object_API_Name__c == 'Co_Applicant__c') {
                fieldAPINames.add(fieldMapping.Field_API_Name__c);
            }
        }
        
        // Build the dynamic SOQL query
        String dynamicQuery = 'SELECT Id';
        for (String fieldAPIName : fieldAPINames) {
            dynamicQuery += ', ' + fieldAPIName;
        }
        dynamicQuery += ' FROM Co_Applicant__c LIMIT 1';
        
        // Query the Applicant object dynamically
        List<SObject> applicants = Database.query(dynamicQuery);
        if (!applicants.isEmpty()) {
            Co_Applicant__c applicant = (Co_Applicant__c)applicants[0];
            
            // Iterate over the field mappings and retrieve the label and value dynamically
            for (FieldMapping__mdt fieldMapping : fieldMappings) {
                String objectAPIName = fieldMapping.Object_API_Name__c;
                String fieldAPIName = fieldMapping.Field_API_Name__c;
                String fieldValue;
                
                if (objectAPIName == 'Co_Applicant__c') {
                    // Retrieve the label dynamically from the custom metadata records based on the field API name
                    if (!fieldMapping.Relationship_Field__c) {
                        String fieldLabel = Schema.getGlobalDescribe().get(objectAPIName).getDescribe().fields.getMap().get(fieldAPIName).getDescribe().getLabel();
                        fieldValue = (applicant != null) ? String.valueOf(applicant.get(fieldAPIName)) : '';
                        
                        // Map field label with value
                        ApplicantDataWrapper dataWrapper = new ApplicantDataWrapper();
                        dataWrapper.fieldLabel = fieldLabel;
                        dataWrapper.fieldValue = fieldValue;
                        
                        // Add the data to the list
                        applicantData.add(dataWrapper);
                    } else {
                        // Handle lookup field value
                        String lookupFieldAPIName = fieldMapping.Lookup_API_Name__c;
                        fieldValue = (applicant != null) ? getLookupFieldValue(lookupFieldAPIName, applicant) : '';
                        
                        // Map field label with value
                        ApplicantDataWrapper dataWrapper = new ApplicantDataWrapper();
                        dataWrapper.fieldLabel = fieldMapping.label;
                        dataWrapper.fieldValue = fieldValue;
                        
                        // Add the data to the list
                        applicantData.add(dataWrapper);
                    }
                }
            }
        }
        
        return applicantData;
    }
    
    public static String getLookupFieldValue(String lookupFieldAPIName, Co_Applicant__c applicant) {
        if (applicant != null && applicant.get(lookupFieldAPIName) != null) {
            String relationshipFieldAPIName = lookupFieldAPIName.substringBefore('.');
            String relatedFieldAPIName = lookupFieldAPIName.substringAfter('.');
            
            FieldMapping__mdt fieldMapping = [SELECT Relationship_Field_API_Name__c FROM FieldMapping__mdt WHERE Object_API_Name__c = 'Co_Applicant__c' AND Lookup_API_Name__c = :lookupFieldAPIName LIMIT 1];
            
            if (fieldMapping != null && fieldMapping.Relationship_Field_API_Name__c != null) {
                String relationshipFieldAPINameFromMetadata = fieldMapping.Relationship_Field_API_Name__c;
                
                // Query the lookup object dynamically
                String query = 'SELECT ' + relatedFieldAPIName + ' FROM ' + relationshipFieldAPINameFromMetadata +
                               ' WHERE Id = \'' + applicant.get(relationshipFieldAPIName) + '\' LIMIT 1';
                List<SObject> lookupObjects = Database.query(query);
                
                if (!lookupObjects.isEmpty()) {
                    SObject lookupObject = lookupObjects[0];
                    if (lookupObject != null) {
                        return String.valueOf(lookupObject.get(relatedFieldAPIName));
                    }
                }
            }
        }
        
        return '';
    }
    
    public class ApplicantDataWrapper {
        @AuraEnabled
        public String fieldLabel { get; set; }
        
        @AuraEnabled
        public String fieldValue { get; set; }
    }
}