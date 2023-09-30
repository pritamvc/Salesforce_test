public class LeadReference {
 @AuraEnabled
    public static Area__c getPincodeRecord(Id pincode){
        Area__c area = new  Area__c();
       //Query Area__c records for fetching pincode related data
        area = [Select Id,City_Name__c,State__c,Country__c,Area_Name_Taluka__c From Area__c 
                           WHERE Id =: pincode];
        return area;
    }
      @AuraEnabled
      public static List<Reference__c> createReferenceRecord(List<Reference__c> refRecordList, String leadGetId) {  
         // to check list having not null then perform DML(UPSERT)
          if (refRecordList.size()>0) {  
              upsert refRecordList;
          }
          //For insert the same record without duplication from form without refresh the page
          List<Reference__c> fetchReference = new List<Reference__c>();
          fetchReference = getReferenceAndAppList(leadGetId);
          return fetchReference;
      }
    @AuraEnabled
  public static List<sObject> getReferenceAndAppList(String leadGetId) {
    List<sObject> records = new List<sObject>();
    map<id,id>mapAccountId = new map<id,id>();
      // Query Co_Applicant__c records
    List<Co_Applicant__c> coApplicants = [Select Id, Name,Account__c, Account__r.Name,Lead__r.Name, Lead__r.Id,Account__r.Id,Type__c
                                   from Co_Applicant__c where Lead__r.Id =: leadGetId ];
    
      // Query Reference__c records
    List<Reference__c> references = [SELECT Id,Account__c,Lead__c,Account__r.Name,Reference_First_Name__c,Reference_Last_Name__c,Reference_Middle_Name__c,Mobile_No__c,
                              Email_Id__c,Landline_No__c,Occupation__c,Reference_Address_1__c,Reference_Address_2__c,Reference_Address_3__c,
                              City__c,District__c,State__c,Country__c,Landmark__c,Pin_Code__c 
                              FROM Reference__c 
                              WHERE Lead__c =: leadGetId];
      // Add Reference__c records to records list
      records.addAll(references);
   
    // Add Co_Applicant__c records to records list if the associated Account ID is not present in any Reference__c records
      Set<Id> referenceAccountIds = new Set<Id>();
      for (Reference__c reference : references) {
        if(reference.Account__c != null){
            referenceAccountIds.add(reference.Account__c); 
        }
        referenceAccountIds.add(reference.Account__c);
    }
    for (Co_Applicant__c coApplicant : coApplicants) {
        if (!referenceAccountIds.contains(coApplicant.Account__c)) {
            records.add(coApplicant);
        }
    }
    return records;
}

}