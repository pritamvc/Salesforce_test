public class DocumentNamesDms {
    @AuraEnabled(cacheable=true)
    public static String DMSNames(){
        List<Map<String, Object>> results = new List<Map<String, Object>>();
        for(Document_Name_DMS__mdt dms : Document_Name_DMS__mdt.getAll().values()) {
            Map<String, Object> result = new Map<String, Object>();
          
            result.put('id', dms.Id);
            result.put('label', dms.MasterLabel);
            result.put('documentType', dms.Document_Type__c);
            result.put('applicantType', dms.Applicant_Type__c);
            
            results.add(result);
        }
        
        return JSON.serialize(results);
    }
}