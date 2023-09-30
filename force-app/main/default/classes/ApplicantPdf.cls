public class ApplicantPdf {
    
    Public List<String> allFieldName{get;set;}
    Public Set<String> showName{get;set;}
    Public SObject sobj{get;set;}
    
    Public ApplicantPdf(){
        
        
        sobj = Schema.getGlobalDescribe().get('Co_Applicant__c').newSObject();
        allFieldName = new List<String>();
        Map<String, Schema.SobjectField> allMap =  Schema.SobjectType.Co_Applicant__c.fields.getMap();
        for(Schema.SobjectField field : allMap.values())
        {  
            Schema.DescribeFieldResult dfr = field.getDescribe();
            if(dfr.isCreateable())
                allFieldName.add(dfr.getName());             
        }
    }
    
}