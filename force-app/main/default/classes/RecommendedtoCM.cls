/*********************************************************************************************
    * @author          Vaibhav Hinge
    * @description     This Class used for Dynamic make field Mandatory Recommended to CM in LOS disposition .
    * @date            30 May 2023  
    * @testClass:      
    **********************************************************************************************/ 
    public class RecommendedtoCM {
    /****************************************
     *@description   This class represents a wrapper for the Deal object and its null field labels.
     ******************************************/
    public class DealWrapper {
        @InvocableVariable
        public Opportunity opp;
        @InvocableVariable
        public List<String> nullFieldLabels;
    }
/**********************************************************************************************
     * @author          Vaibhav Hinge
     * @description     Returns the mandatory fields for the specified Deal Ids.
     * @param           dealIds The list of Deal Ids.
     * @return          The list of LeadWrapper objects containing the Deal and its null field labels.
*************************************************************************************************/
    @InvocableMethod(label='Recommended to CM')
   public static List<DealWrapper> getRecommendedToCMField(List<String> dealIds){
    List<Schema.FieldSetMember> fieldSetMembers = getFieldSetMembers('Recommended_to_CM', 'Opportunity');
    String query = 'SELECT ';
    for (Schema.FieldSetMember fieldSetMember : fieldSetMembers) {
        query += fieldSetMember.getFieldPath() + ', ';
    }
    query = query.removeEnd(', ');
    query += ' FROM Opportunity WHERE Id IN :dealIds';
    
    List<Opportunity> opps = Database.query(query);
    
    List<DealWrapper> dealWrappers = new List<DealWrapper>();
    for (Opportunity opp : opps) {
        if (opp != null) { // add null check
            DealWrapper wrapper = new DealWrapper();
            wrapper.opp = opp;
            wrapper.nullFieldLabels = getNullFieldLabels(opp, fieldSetMembers);
            dealWrappers.add(wrapper);
        }
    }
    return dealWrappers;
}
    
/*****************************************************************
     * @author          Vaibhav Hinge
     * @description     method used for getting fields from field set
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
     * @param           opp Deal object.
     * @param           fieldSetMembers The list of field set members.
     * @return          The list of null field labels.
******************************************************************/
    private static List<String> getNullFieldLabels(Opportunity opp, List<Schema.FieldSetMember> fieldSetMembers) {
        List<String> nullFieldLabels = new List<String>();
        for (Schema.FieldSetMember fieldSetMember : fieldSetMembers) {
            String fieldName = fieldSetMember.getFieldPath();
            if (opp.get(fieldName) == null) {
                nullFieldLabels.add('\n'+'\u2022' + ' '+fieldSetMember.getLabel());
            }
        }
        return nullFieldLabels;
    }
}