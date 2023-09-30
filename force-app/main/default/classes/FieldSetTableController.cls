public class FieldSetTableController {
    public List<SObject> dynamicData { get; set; }
    public List<Schema.FieldSetMember> fieldSetMembers { get; set; }
    public List<Co_Applicant__c> applicant { get; set; }
    
    public FieldSetTableController() {
        applicant = new List<Co_Applicant__c>();
        // Retrieve the field set members dynamically
        fieldSetMembers = getFieldSetMembers('Co_Applicant__c', 'ApplicantPdf');
        
        // Query the object dynamically using the field set members
        String query = generateDynamicQuery();
        dynamicData = Database.query(query);
    }
    
    private List<Schema.FieldSetMember> getFieldSetMembers(String objectAPIName, String fieldSetName) {
        return Schema.SObjectType.Co_Applicant__c.FieldSets.getMap().get('ApplicantPdf').getFields();
    }
    
    private String generateDynamicQuery() {
        String query = 'SELECT ';
        
        // Append the field set member API names to the query
        for (Schema.FieldSetMember fieldSetMember : fieldSetMembers) {
            query += fieldSetMember.getFieldPath() + ', ';
        }
        
        // Remove the trailing comma and space
        query = query.substring(0, query.length() - 2);
        
        // Specify the object to query (e.g., Account, Custom_Object__c)
        query += 'Id FROM Co_Applicant__c';
        dynamicData = Database.query( query );  
        return query;
    }
}