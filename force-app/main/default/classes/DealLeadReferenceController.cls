/*********************************************************************************************
* @author          Vaibhav Hinge
* @description     This Class used get and save a refetrence data.
* @date            26 April 2023  
* @testClass:      
**********************************************************************************************/

public class DealLeadReferenceController {

    /********************************************************************************************************
   * @author          Vaibhav Hinge
   * @description     Method used for return city,Taluka,state and Country on the basis of pincode
   * @param           pincode
   * @return		   area
   * @date            27/04/2023 (April,2023)
   ********************************************************************************************************/
     @AuraEnabled
       public static Area__c getPincodeRecord(Id pincode){
           Area__c area = new  Area__c();
           //Query Area__c records for fetching pincode related data
           area = [Select Id,City_Name__c,State__c,Country__c,Area_Name_Taluka__c From Area__c 
                   WHERE Id =: pincode];
           return area;
       }
    /********************************************************************************************************
   * @author          Vaibhav Hinge
   * @description     Method used for update and insert reference record
   * @param           refRecordList
   * @param           leadGetId
   * @return		   Reference related to lead ids
   * @date            27/04/2023 (April,2023)
   ********************************************************************************************************/    
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
    /********************************************************************************************************
   * @author          Vaibhav Hinge
   * @description     method used for get Reference and Co-applicant data
   * @param           leadGetId
   * @return		   such record if reference are available then this otherwise return accounts
   * @date            27/04/2023 (April,2023)
   ********************************************************************************************************/    
     @AuraEnabled
       public static List<sObject> getReferenceAndAppList(String leadGetId) {
           system.debug('####leadGetId'+leadGetId);
           //list used for return the stored reference and co-applicant record
           List<sObject> records = new List<sObject>();
           map<id,id>mapAccountId = new map<id,id>();
           Set<Id> setAppIds = new Set<Id>();
           // Query on Co_Applicant__c records
           List<Co_Applicant__c> coApplicants = [Select Id, Name,Account__c, Account__r.Name,Lead__r.Name, Lead__r.Id,Account__r.Id,Type__c, Deal__c
                                                 from Co_Applicant__c where (Lead__r.Id =: leadGetId OR Deal__c =: leadGetId) and Account__c != null ORDER BY Type__c ASC];
           
           for (Co_Applicant__c objCoApp: coApplicants) {
               setAppIds.add(objCoApp.Account__c);
           }
           // Query on Reference__c records
           List<Reference__c> references = [SELECT Id,Account__c,Lead__c,REF_Title__c,Account__r.Name,Reference_First_Name__c,Reference_Last_Name__c,Reference_Middle_Name__c,Mobile_No__c,
                                            Email_Id__c,Landline_No__c,Occupation__c,Reference_Address_1__c,Reference_Address_2__c,Reference_Address_3__c,
                                            City__c,District__c,State__c,Country__c,Landmark__c,Pin_Code__c,Deal__c 
                                            FROM Reference__c 
                                            WHERE (Lead__c =: leadGetId OR Deal__c =: leadGetId) and Account__c in: setAppIds];
           // Add Reference__c records to records list
           records.addAll(references);
           
           // Add Co_Applicant__c records to records list if the associated Account ID is not present in any Reference__c records
           Set<Id> referenceAccountIds = new Set<Id>();
           //Iterate through the list of Reference 
           for (Reference__c reference : references) {
               if(reference.Account__c != null){
                   referenceAccountIds.add(reference.Account__c); 
               }
           }
           //Iterate through the list of Co_Applicant 
           for (Co_Applicant__c coApplicant : coApplicants) {
               //to check referenceAccountIds set collection contain account if yes then add in record list
               if (!referenceAccountIds.contains(coApplicant.Account__c)) {
                   records.add(coApplicant);
               }
           }
           // return Co_Applicant and Reference records
           return records;
       }
       
    /********************************************************************************************************
   * @author          Vaibhav Hinge
   * @description     method used for get Reference section fill complete
   * @param           leadId
   * @param           isCheck
   * @return		   Reference_Section checked or not
   * @date            27/04/2023 (April,2023)
   ********************************************************************************************************/    
      @AuraEnabled
       public static Lead updateReferenceCheck(String leadId,Boolean isCheck){
           Lead rec = [SELECT Id,Reference_Section__c FROM Lead WHERE Id =: leadId];
           rec.Reference_Section__c = isCheck;
           update rec;
           return rec;
       }
       
       /********************************************************************************************************
   * @author          Chandrakant More
   * @description     getPicklistValues this method used get the picklist value for salutation.
   * @return          List<String>   return picklist value for salutation in Reference section
   * @date            17/08/2023 (DD/MM/YYYY)
   ********************************************************************************************************/
       @AuraEnabled(cacheable=true)
       public static List<String> getPicklistValues() {
           List<String> picklistValues = new List<String>();
           
           Schema.DescribeFieldResult fieldResult = Reference__c.REF_Title__c.getDescribe();
           List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
           
           for (Schema.PicklistEntry entry : entries) {
               picklistValues.add(entry.getLabel());
           }
           system.debug('picklistValues== '+picklistValues);
           return picklistValues;
       }
       
   }