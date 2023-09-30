/*********************************************************************************************
* @author          Vaibhav Hinge
* @description     This Class used for Dynamic make field Mandatory for willing to apply disposition .
* @date            30 May 2023  
* @testClass:      
**********************************************************************************************/
public class WillingToApplyMandFields {
    
    /****************************************
     *@description   This class represents a wrapper for the Lead object and its null field labels.
     ******************************************/
    public class LeadWrapper {
        @InvocableVariable
        public Lead lead;
        @InvocableVariable
        public List<String> nullFieldLabels;
    }

    /**********************************************************************************************
     * @author          Vaibhav Hinge
     * @description     Returns the mandatory fields for the specified Lead Ids.
     * @param           leadIds The list of Lead Ids.
     * @return          The list of LeadWrapper objects containing the Lead and its null field labels.
     *************************************************************************************************/
    @InvocableMethod(label='Get Willing To Apply Mandatory Fields' description='Returns the mandatory fields for the specified Lead Ids')
    public static List<LeadWrapper> getWTAMandField(List<String> leadIds){
        List<Schema.FieldSetMember> fieldSetMembers = getFieldSetMembers('Willing_To_Apply', 'Lead');
        String query = 'SELECT ';
        for (Schema.FieldSetMember fieldSetMember : fieldSetMembers) {
            query += fieldSetMember.getFieldPath() + ', ';
        }
        query = query.removeEnd(', ');
        query += ' FROM Lead WHERE Id IN :leadIds';
        
        List<Lead> leads = Database.query(query);
        
        List<LeadWrapper> leadWrappers = new List<LeadWrapper>();
        for (Lead lead : leads) {
            LeadWrapper wrapper = new LeadWrapper();
            wrapper.lead = lead;
            wrapper.nullFieldLabels = getNullFieldLabels(lead, fieldSetMembers);
            leadWrappers.add(wrapper);
        }
        return leadWrappers;
    }
    /*****************************************************************
     * @author          Vaibhav Hinge
     * @description     method used for getting a fields from field set
     * @param           fieldSetName which are created on Object.
     * @param           objectName .
     * @return          The list of FieldSetMembers.
     ******************************************************************/
    public static List<Schema.FieldSetMember> getFieldSetMembers(String fieldSetName, String objectName) {
        Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType sObjectTypeObj = globalDescribeMap.get(objectName);
        Schema.DescribeSObjectResult describeSObjectResultObj = sObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = describeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields();
    }

    
     /*****************************************************************
     * @author          Vaibhav Hinge
     * @description     method use for getting label of null fields
     * @param           lead The Lead object.
     * @param           fieldSetMembers The list of field set members.
     * @return          The list of null field labels.
     ******************************************************************/
    private static List<String> getNullFieldLabels(Lead lead, List<Schema.FieldSetMember> fieldSetMembers) {
        List<String> nullFieldLabels = new List<String>();
        for (Schema.FieldSetMember fieldSetMember : fieldSetMembers) {
            String fieldName = fieldSetMember.getFieldPath();
            if (lead.get(fieldName) == null) {
                nullFieldLabels.add('\n'+'\u2022' + ' '+fieldSetMember.getLabel());
            }
        }
               return nullFieldLabels;
    }
}