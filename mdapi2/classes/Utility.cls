/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-11-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class Utility {
    /********************************************************************************************************
* @author          Chandrakant More
* @description     assignOwnerBasedOnUserName this method is used to assign the owner to the lead based on User Name .
* @param           userName (set<string>) : It will accept the set of user name and return User Id vs Username Map.
* @return          Map<String,String>
* @date            06/02/2023   
********************************************************************************************************/
    public static Map<String,String> assignOwnerBasedOnUserName(set<string> userName){
        List<User> activeUserlist =  new List<User>();
        List<User> inactiveUserlist =  new List<User>();
        activeUserlist = [Select Id,Username,Service_Branch__c From User where IsActive = true AND Username In:userName];
        inactiveUserlist = [Select Id,Username,Service_Branch__c From User where IsActive = false AND Username In:userName];
        Group queueId = [SELECT Id, Name, Type from Group WHERE Type =: System.Label.Group_Type AND Name =: System.Label.Exception_Queue];
        Map<String,String> mapUserNameAndOwnerId = new Map<String,String>();
        if(!activeUserlist.Isempty() && activeUserlist.size() >0 ) {
            for(User objUser : activeUserlist ){
                mapUserNameAndOwnerId.put(objUser.Username,objUser.Id);
            }
        }
        if(!inactiveUserlist.Isempty() && inactiveUserlist.size() >0 ) {
            for(User objUser : inactiveUserlist ){
                mapUserNameAndOwnerId.put(objUser.Username,queueId.Id);
            }
        }
        return mapUserNameAndOwnerId ;
    }
    
    /********************************************************************************************************
* @author          Chandrakant More
* @description     assignOwnerAndServiceBranchBasedOnUserName this method is used to assign the owner and Service branch to the lead based on User Name .
* @param           userName (set<string>) : It will accept the set of user name and return User Id vs Username Map.
* @return          Map<String, SObject>
* @date            08/06/2023  (DD/MM/YYY) 
********************************************************************************************************/
    public static  Map<String, SObject> assignOwnerAndServiceBranchBasedOnUserName(set<string> userName){
        List<User> activeUserlist =  new List<User>();
        List<User> inactiveUserlist =  new List<User>();
        activeUserlist = [Select Id,Username,Service_Branch__c From User where IsActive = true AND Username In:userName];
        inactiveUserlist = [Select Id,Username,Service_Branch__c From User where IsActive = false AND Username In:userName];
        Group queueId = [SELECT Id, Name, Type from Group WHERE Type =: System.Label.Group_Type AND Name =: System.Label.Sales_Processing_Exception_Queue_Queue];
        Map<String, SObject> mapUserNameAndOwnerId = new Map<String, SObject>(); 
        if(!activeUserlist.Isempty() && activeUserlist.size() >0 ) {
            for(User objUser : activeUserlist ){
                mapUserNameAndOwnerId.put(objUser.Username,objUser);
            }
        }
        if(!inactiveUserlist.Isempty() && inactiveUserlist.size() >0 ) {
            for(User objUser : inactiveUserlist ){
                mapUserNameAndOwnerId.put(objUser.Username,queueId);
            }
        }
        return mapUserNameAndOwnerId ;
    }
    
    /********************************************************************************************************
* @author          Chandrakant More
* @description     createCSVfile this method is used to create csv file with error record.
* @param           duplicateLeadsRecords (List) : To get the list of duplicate lead from BulkUploadLeadsForPartners class.
accountId (string) : To get the partner Id to set the file in attachment .
* @return          No-return
* @date            06/02/2023   
********************************************************************************************************/
    public static void createCSVfile(List<Lead> duplicateLeadsRecords,string accountId,string csvFileTittle,string HeaderFromCSV) {
        String updatedHeaderInCSVWithErrorMessage = HeaderFromCSV+','+CommonConstant.ERROR_MESSAGE_FIELD_NAME_CSV;
        map<string,string> mapFieldLabelAndAPI = new map<string,string>();
        List<String> csvRowValues = new List<String>();
        Set<String> columnSet = new Set<String>(updatedHeaderInCSVWithErrorMessage.split(','));
        
        Import_Lead_Header_Field_Mapping__mdt[] importLeadHeaderFieldMappingArray = [Select MasterLabel,Field_API_Name__c from Import_Lead_Header_Field_Mapping__mdt
                                                                                     where MasterLabel In:columnSet];
        
        if(importLeadHeaderFieldMappingArray.size()>0) {
            for(Import_Lead_Header_Field_Mapping__mdt ObjMetadataRecord : importLeadHeaderFieldMappingArray){
                mapFieldLabelAndAPI.put(ObjMetadataRecord.MasterLabel,ObjMetadataRecord.Field_API_Name__c);
            }
        }
        system.debug('duplicateLeadsRecords in Utility'+duplicateLeadsRecords);
        for (Lead l : duplicateLeadsRecords) {
            system.debug('Inside For loop Utility');
            String rowStr ='';
            for (String fieldName : columnSet) {
                system.debug('Inside For loop Utility columnSet'+ fieldName);
                if (mapFieldLabelAndAPI.containsKey(fieldName)) {
                    String fieldValue = String.valueOf(l.get(mapFieldLabelAndAPI.get(fieldName)));
                    rowStr += fieldValue + ',';
                } 
            }
            rowStr += l.ErrorMessage__c.replace('\n', '.');
            system.debug('rowStr===='+rowStr);
            csvRowValues.add(rowStr);
        } 
        if(csvRowValues.size() > 0) {
            String csvFile = updatedHeaderInCSVWithErrorMessage +'\n'+ String.join(csvRowValues,'\n');
            ContentVersion contentVersion = createContentVersion(csvFileTittle+CommonConstant.ERROR_FILE_FORMATE_AND_NAME, Blob.valueOf(csvFile));
            insert contentVersion;
            Id contentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;
            ContentDocumentLink contentDocumentLink = createContentDocumentLink(contentDocumentId,accountId);
            insert contentDocumentLink;
            BulkUploadLeadsForPartners.sendEmailToLoggedInUser(contentVersion.Id,csvFileTittle);
        }                
    }
    
    /********************************************************************************************************
* @author          Chandrakant More
* @description     createContentVersion this method is used to create csv file with error record.
* @param           name (String) : set the error csv file name in system.
* @return          No-return
* @date            06/02/2023   
********************************************************************************************************/
    public static ContentVersion createContentVersion(String name, Blob body) {
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.PathOnClient = name;
        contentVersion.Title = name;
        contentVersion.VersionData = body;
        return contentVersion;
    }
    
    /********************************************************************************************************
* @author          Chandrakant More
* @description     createContentDocumentLink this method is used to add created csv file in parent record (Partner Account).
* @param           contentDocumentId (Id) : get file ID
* @param           parentId (Id) : get parent Account ID
* @return          No-return
* @date            06/02/2023   
********************************************************************************************************/
    Public  static ContentDocumentLink createContentDocumentLink(Id contentDocumentId, Id parentId){
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = contentDocumentId;
        contentDocumentLink.LinkedEntityId = parentId;
        //  contentDocumentLink.ShareType = System.Label.Share_Type;
        contentDocumentLink.Visibility = System.Label.Document_Visibility;
        return contentDocumentLink;
    }  
    
    
    /********************************************************************************************************
* @author          Chandrakant More
* @description     dynamicBulkUploadLeadsCSVTemplate this method is used to pass the dynamic header for CSV template download.
* @param           No Parameter
* @return          String : Pass head (fields names) for download template.
* @date            22/04/2023   
********************************************************************************************************/
    @AuraEnabled (cacheable=true)
    public static String dynamicBulkUploadLeadsCSVTemplate(){
        String dynamicCSVTemplate = System.Label.Bulk_Upload_Leads_CSV_Template_Header;
        return dynamicCSVTemplate;
    }  
    /********************************************************************************************************
* @author          Chandrakant More
* @description     dynamicBulkUploadLeadsCSVTemplate this method is used to pass the dynamic header for CSV template download.
* @param           No Parameter
* @return          String : Pass head (fields names) for download template.
* @date            22/04/2023   
********************************************************************************************************/
    /*****This Commented by Vaibhav *******/

    // @AuraEnabled (cacheable=true)
    // public static List<User> setVisibilityOfComponentBasedOnRole(){
    //     String roleString = System.Label.Bulk_Lead_Upload_Accessibility_Based_On_Role;
    //     Set<String> columnSetRoleString = new Set<String>(roleString.split(','));
    //     List<User> listUser = [Select Id,Name,UserRole.Name from User Where Id =: UserInfo.getUserId() AND UserRole.Name In : columnSetRoleString ];
    //     return listUser;
    // } 
    
    /********************************************************************************************************
* @author          Chandrakant More
* @description     getSetFromString this method is used to return set of string From Custom label.
* @param           No Parameter
* @return          Set<String>: Pass head (fields names) for download template.
* @date            22/04/2023   
********************************************************************************************************/
     public static Set<String> getSetFromString(String inputString) {
        Set<String> resultSet = new Set<String>();
        if (String.isNotBlank(inputString)) {
            List<String> valuesList = inputString.split(',');
            for (String value : valuesList) {
                resultSet.add(value.trim());
            }
        }
         system.debug('resultSet== '+resultSet);
        return resultSet;
    }
}