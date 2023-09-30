/*********************************************************************************************
* @author          Aasim Shaikh
* @description     This is a RestController class used to handle and manage partner api requests
* @date            24/02/2023    
**********************************************************************************************/
@RestResource(urlMapping='/partner/lead/*')
global class PartnerController {
    
    /********************************************************************************************************
* @author          Aasim Shaikh
* @description     This GET method is to make API Call
* @param           NA
* @return          NA
* @date            24/02/2023    
********************************************************************************************************/
    @HttpGet
    global static void getstatusOfLead() {    
        RestRequest req = RestContext.request; 
        RestResponse restContext = RestContext.response;
        restContext.addHeader('Content-Type', CommonConstant.APPLICATION_JSON);        
        
        Map<String,Object> msg = new Map<String,String>();
        String emailid = req.params.get('emailId');
        String mobileNO = req.params.get('mobileNO');
        String partnerId = req.params.get('partnerId');        
        
        try {           
            List<Lead> leadLst = new List<Lead>();            
            String qry = '';
            String selectParams = '';
            if( emailid != '' && mobileNO != '') {                
                qry += 'Email=:emailid and MobilePhone =:mobileNO';
            } else if(emailid != '') {
                qry += 'Email =:emailid';
            } else {
                qry += 'MobilePhone =:mobileNO';
            }
            
            // getting all the select fields to be returned            
            for(Partner_Get_API_Response_Field_Mapping__mdt addMap : Partner_Get_API_Response_Field_Mapping__mdt.getall().values()) {
                if(addMap.Field_API_Name__c != null && (!selectParams.contains(addMap.Field_API_Name__c))){
                    selectParams += addMap.Field_API_Name__c + ',';
                }
            }             
            String recordType = System.Label.Lead_B2C_Record_Type;
            qry = 'SELECT Id, ' + selectParams + 'Source_Name__r.Partner_Name__r.Partner_Code__c, status FROM Lead WHERE '
                + qry + ' and Source_Name__r.Partner_Name__r.Partner_Code__c =:partnerId and RecordType.DeveloperName =:recordType';
            
            leadLst = Database.query(qry);
            
            if(leadLst.size() > 0) {               
                List<Lead_status__mdt> statusList = [SELECT status__c, Partnerstatus__c FROM Lead_status__mdt where status__c =:leadLst[0].status];
                String status = statusList.size() != 0 ? statusList[0].Partnerstatus__c: CommonConstant.status_NOT_AVAILABLE;
               
                // Mapping all the select fields to be returned 
                for(Partner_Get_API_Response_Field_Mapping__mdt addMap : Partner_Get_API_Response_Field_Mapping__mdt.getall().values()){
                    if(addMap.Field_API_Name__c != null){                        
                        msg.put(addMap.MasterLabel, leadLst[0].get(addMap.Field_API_Name__c)!=null ? String.ValueOf(leadLst[0].get(addMap.Field_API_Name__c)):'');
                    }
                }               
                msg.put('status', status);
                restContext.responseBody = Blob.valueOf(JSON.serialize(msg));            
            } else {
                msg.put('status', CommonConstant.FAILURE);
                msg.put('message', 'No Record found for email id ' + emailid + ' and mobile no. ' + mobileNO + ' with partner id: ' + partnerId);
                restContext.statusCode = 400;
                restContext.responseBody = Blob.valueOf(JSON.serialize(msg));
            }
        }
        catch(Exception e) {
            e.getStackTraceString();
            msg.put('status', CommonConstant.FAILURE);
            msg.put('message',e.getMessage());
            restContext.statusCode = 400;
            restContext.responseBody = Blob.valueOf(JSON.serialize(msg));
        }
    }     
    
    /********************************************************************************************************
* @author          Aasim Shaikh
* @description     This POST method will create a lead and map it to corresponding partner.
* @payload         As a payload a json is accepted for this method. Content of json can be dynamically 
*                  added by adding it in  Lead_Fields__mdt meta data     
* @return          NA
* @date            24/02/2023    
********************************************************************************************************/
    @HttpPost               
    global static void createLead() {
        
        Map<String,String> res = new Map<String,String>();
        String jsonString = RestContext.request.requestBody.toString();        
        
        RestResponse restContext = RestContext.response;
        restContext.addHeader('Content-Type', CommonConstant.APPLICATION_JSON);
        
        try {
            Map<String,Object> jsonData = (Map<String,Object>) JSON.deserializeUntyped(jsonString);
            
            for(String key: jsonData.keySet()){
                Object fieldType = jsonData.get(key);
                if (!(fieldType instanceof Boolean)){
                    String value = String.valueOf(jsonData.get(key));  
                    jsonData.put(key, value.trim());
                }
            }
            
            PartnerController.LeadModel getLeadParameters = (PartnerController.LeadModel)JSON.deserialize(JSON.serialize(jsonData), PartnerController.LeadModel.class);
            
            List<Lead>  newLinelst = new List<Lead>();
            Lead newLead = new Lead();
            newLead.FirstName = getLeadParameters.FirstName;
            newLead.Email = getLeadParameters.Email;
            newLead.MobilePhone = getLeadParameters.MobilePhone;
            newLinelst.add(newLead);
            
            // Owner Assignment based On User Name
            String userName = (String) jsonData.get('UserName');   
            Set<string> userNameSet = new Set<String>();
            if(String.isEmpty(userName)) {
                userName = null;
            }
            userNameSet.add(userName);
            
            String Email = (String) jsonData.get('Email');
            String MobilePhone = (String) jsonData.get('MobilePhone');
            
            String partnerId = (String) jsonData.get('PartnerId');
            String sourceId = (String) jsonData.get('SourceId');
            List<Source__c> sourceLst = new List<Source__c>();
            Boolean sourceIdPresent = false;
            Boolean partnerIdPresent = false;
            if(!String.isEmpty(sourceId)) {
                Integer intValSourceId = Integer.valueOf(sourceId);
                sourceLst = [select id, Partner_Name__c,Source_Category__c,Partner_Name__r.Partner_Code__c from Source__c 
                             where Source_Id__c =:intValSourceId and Source_Id__c != null limit 1];
                if(sourceLst.size() == 0 || sourceLst.size() == null) {
                    sourceIdPresent = true;
                }
            } else if(!String.isEmpty(partnerId)){
                sourceLst = [SELECT Id, Partner_Name__c, Source_Category__c, Partner_Name__r.Partner_Code__c FROM Source__c 
                             WHERE Partner_Name__r.Partner_Code__c = :partnerId and Partner_Name__r.Partner_Code__c != null limit 1];
                if(sourceLst.size() == 0 || sourceLst.size() == null) {
                    partnerIdPresent = true;
                }
            }              
            
            if(sourceLst.size() > 0) {
                String unManagedField = checkForValidJson(jsonData);
                Lead leadToAdd = getLeadMapping(jsonData);
                Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(System.Label.Lead_B2C_Record_Type).getRecordTypeId();
                If(recordTypeId != null) {
                    leadToAdd.RecordTypeId = recordTypeId;
                }
                // checks if received parameters in body are valid or not . e.g. checks email against email regex 
                Boolean validBody = checkForValidBody(leadToAdd, res, partnerId);
                
                if(!String.isEmpty(unManagedField) ) {
                    res.put('status', CommonConstant.FAILURE);
                    res.put('message', unManagedField + CommonConstant.UNMANAGED_FIELD_ERROR);
                    restContext.statusCode = 400;
                    restContext.responseBody = Blob.valueOf(JSON.serialize(res)); 
                }
                else if(!validBody) {                    
                    restContext.statusCode = 400;
                    restContext.responseBody = Blob.valueOf(JSON.serialize(res));
                } else if(Email != NULL || MobilePhone != NULL) {
                    Set<Id> receivedSetOfId = DuplicateManagement.leadDuplicate(newLinelst, sourceLst[0].Id);
                    
                    if(receivedSetOfId.size() == 0 || receivedSetOfId.isEmpty()) {
                        if(userName != null){
                            Map<String, SObject> mapUsernameAndOwnerId = new Map<String, SObject>();
                            mapUsernameAndOwnerId = Utility.assignOwnerAndServiceBranchBasedOnUserName(userNameSet);
                            Map<String,String> ownerAssignment = Utility.assignOwnerBasedOnUserName(userNameSet);
                            if(ownerAssignment.IsEmpty()) {
                                res.put('status', CommonConstant.FAILURE);
                                res.put('message', CommonConstant.INVALID_USERNAME);
                                restContext.statusCode = 400;
                                restContext.responseBody = Blob.valueOf(JSON.serialize(res));  
                            } else if(mapUsernameAndOwnerId.containsKey(userName) && 
                                      mapUsernameAndOwnerId.get(userName) != null) {
                                          
                                          leadToAdd.OwnerId = mapUsernameAndOwnerId.get(userName).Id;
                                          Schema.DescribeSObjectResult describeResult = mapUsernameAndOwnerId.get(userName).Id.getSObjectType().getDescribe();
                                          string objectName = describeResult.getName();
                                          if(objectName == System.Label.Object_Name_User){
                                              leadToAdd.OwnerId = ((User)mapUsernameAndOwnerId.get(userName)).Id;
                                              if(((User)mapUsernameAndOwnerId.get(userName)).Service_Branch__c != null){
                                                  leadToAdd.Service_Branch__c = ((User)mapUsernameAndOwnerId.get(userName)).Service_Branch__c;
                                              }
                                          } else if(objectName == System.Label.Object_Name_Group){
                                              leadToAdd.OwnerId = ((Group)mapUsernameAndOwnerId.get(userName)).Id;
                                          }
                                          
                                          // leadToAdd.OwnerId = ownerAssignment.get(UserName);
                                          leadToAdd.status = CommonConstant.SALES_PROCESSING;
                                          leadToAdd.Source_Category__c =  sourceLst[0].Source_Category__c;
                                          leadToAdd.Source_Name__c =  sourceLst[0].id; 
                                          leadToAdd.status__c = CommonConstant.LEAD_NEW;
                                          leadToAdd.Lead_Origin__c= 'API';
                                          insert leadToAdd;
                                          List<Lead> lstLead = new List<Lead>([Select id,Lead_Id__c from Lead where id =:leadToAdd.Id]);
                                          res.put('status',CommonConstant.SUCCESS_PARTNER);
                                          res.put('message', CommonConstant.LEAD_CREATED);
                                          if(lstLead.size() > 0){
                                              res.put('leadid',lstLead[0].Lead_Id__c);
                                          }
                                          restContext.statusCode = 201;
                                          restContext.responseBody = Blob.valueOf(JSON.serialize(res));
                                      }   
                        } else if(userName == null) {
                            Group callCenterQueue = [SELECT Id, Name, Type from Group WHERE Type = 'Queue' AND Name =: System.Label.Call_Center_Queue];
                            leadToAdd.OwnerId = callCenterQueue.Id;
                            leadToAdd.status = CommonConstant.LEAD_FRESH ;
                            leadToAdd.Source_Category__c =  sourceLst[0].Source_Category__c;
                            leadToAdd.Source_Name__c =  sourceLst[0].id;
                            leadToAdd.status__c = CommonConstant.LEAD_NEW;
                            leadToAdd.Lead_Origin__c= 'API';
                            insert leadToAdd;
                            
                            List<Lead> lstLead = new List<Lead>([Select id,Lead_Id__c from Lead where id =:leadToAdd.Id]);
                            res.put('status', CommonConstant.SUCCESS_PARTNER);
                            res.put('message', CommonConstant.LEAD_CREATED);
                            if(lstLead.size() > 0){
                                res.put('leadid',lstLead[0].Lead_Id__c);
                            }
                            
                            restContext.statusCode = 201;
                            restContext.responseBody = Blob.valueOf(JSON.serialize(res));
                        }
                        
                    } else if(receivedSetOfId.size() > 0 || !receivedSetOfId.isEmpty()) {
                        res.put('status', CommonConstant.SUCCESS_PARTNER);
                        res.put('message', CommonConstant.LEAD_DUPLICATE);
                        restContext.statusCode = 201;
                        restContext.responseBody = Blob.valueOf(JSON.serialize(res));
                    }
                }   
            } else {
                res.put('status', CommonConstant.FAILURE);
                if(sourceIdPresent) {
                    res.put('message', CommonConstant.INVALID_SOURCE_ID);
                }else if(partnerIdPresent) {
                    res.put('message', CommonConstant.INVALID_PARTNER_ID);
                }else if(!sourceIdPresent && !sourceIdPresent) {
                    res.put('message', CommonConstant.UNIQUE_ID_BLANK);
                }   
                restContext.statusCode = 400;
                restContext.responseBody = Blob.valueOf(JSON.serialize(res));
            }  
        } catch(Exception e) {
            e.getStackTraceString();
            res.put('status', CommonConstant.FAILURE);
            res.put('message', e.getMessage());
            restContext.statusCode = 400;
            restContext.responseBody = Blob.valueOf(JSON.serialize(res));
        }
    }
    
    public class LeadModel {
        public String firstName;
        public String email;
        public String MobilePhone;
    }
    
/********************************************************************************************************
* @author          Aasim Shaikh
* @description     This method is used to lead Mapping
* @param           Map<String,Object> jsonData
* @return          Lead
*                       
* @date            04/07/2023   
********************************************************************************************************/
    @TestVisible private static Lead getLeadMapping(Map<String,Object> jsonData ) {
        Map<String, Object> leadMapMappingTable = new Map<String,Object>();
        Lead lead = new Lead();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('Lead');
        Schema.DescribeSObjectResult objDesc = objType.getDescribe();
        for (Lead_Fields__mdt mappingTableRec : Lead_Fields__mdt.getall().Values()) {
            if (mappingTableRec.DeveloperName != null && mappingTableRec.FieldAPIName__c != Null ) {   
                system.debug(mappingTableRec.FieldAPIName__c);
                Schema.DescribeFieldResult fieldDesc = objDesc.fields.getMap().get(mappingTableRec.FieldAPIName__c).getDescribe();
                if(fieldDesc.getType() == Schema.DisplayType.INTEGER){
                    leadMapMappingTable.put(mappingTableRec.FieldAPIName__c , Integer.valueOf(jsonData.get(mappingTableRec.Label)));  
                }
                if(fieldDesc.getType() == Schema.DisplayType.DOUBLE){
                    leadMapMappingTable.put(mappingTableRec.FieldAPIName__c , DOUBLE.valueOf(jsonData.get(mappingTableRec.Label)));  
                }else{
                    leadMapMappingTable.put(mappingTableRec.FieldAPIName__c , jsonData.get(mappingTableRec.Label));  
                }               
                
            }
        }        
        for(String key: leadMapMappingTable.keySet()) { 
            lead.put(key , leadMapMappingTable.get(key));        
        }   
        return lead;
    }
    
/*****************************************************************************************************************
* @author          Aasim Shaikh
* @description     This method is used to checkForValidJson
* @param           Map<String,Object> json
* @return          String unManagedFields
*                       
* @date            04/07/2023   
***************************************************************************************************************************/
    @TestVisible private static String checkForValidJson(Map<String,Object> json) {
        Map<String,Object> jsonData = new Map<String,Object>(json);
        String unManagedFields = '';
        
        for (Lead_Fields__mdt mappingTableRec : Lead_Fields__mdt.getall().Values()) {
            if (mappingTableRec.DeveloperName != null && mappingTableRec.FieldAPIName__c != Null ) {                    
                jsonData.remove(mappingTableRec.Label);   
            }
        }  
        if(jsonData.size() > 0) {
            for(String key: jsonData.keySet()) { 
                if(key == 'PartnerId' || key == 'SourceId' || key == 'UserName') {
                    jsonData.remove(key);
                } else {
                    unManagedFields += key ;
                    jsonData.remove(key);  
                    unManagedFields += jsonData.size() != 0 ? ', ' : ' ';  
                }            
            }
        }
        
        return unManagedFields;
    }
  
/***************************************************************************************************************************
* @author          Aasim Shaikh
* @description     This method is used to checkForValidBody
* @param           Lead leadToAdd, Map<String,String> res, String partnerId
* @return          Boolean
*                       
* @date            04/07/2023   
*************************************************************************************************************************/
    @TestVisible private static Boolean checkForValidBody(Lead leadToAdd, Map<String,String> res, String partnerId) {
        if(leadToAdd.FirstName == '') {
            res.put('status', CommonConstant.FAILURE);
            res.put('message',CommonConstant.FIRST_NAME_ERROR);
            return false;
        } else if(leadToAdd.FirstName == NULL) {
            res.put('status', CommonConstant.FAILURE);
            res.put('message',CommonConstant.FIRST_NAME_ERROR);
            return false;
        } else if(leadToAdd.LastName == '') {
            res.put('status', CommonConstant.FAILURE);
            res.put('message', CommonConstant.LAST_NAME_ERROR);
            return false;
        } else if(leadToAdd.LastName == NULL) {
            res.put('status', CommonConstant.FAILURE);
            res.put('message', CommonConstant.LAST_NAME_ERROR);
            return false;
        } else if(leadToAdd.Email == '') {
            res.put('status', CommonConstant.FAILURE);
            res.put('message', CommonConstant.EMAIL_BLANK);
            return false;
        } else if(leadToAdd.Email == NULL) {
            res.put('status', CommonConstant.FAILURE);
            res.put('message', CommonConstant.EMAIL_BLANK);
            return false;
        } else if(!Pattern.matches(CommonConstant.EMAIL_REGEX, leadToAdd.Email)) {
            res.put('status', CommonConstant.FAILURE);
            res.put('message', CommonConstant.EMAIL_ERROR);
            return false;
        } else if(leadToAdd.MobilePhone == '') {
            res.put('status', CommonConstant.FAILURE);
            res.put('message', CommonConstant.MOBILE_BLANK);
            return false;
        } else if(leadToAdd.MobilePhone == NULL) {
            res.put('status', CommonConstant.FAILURE);
            res.put('message', CommonConstant.MOBILE_BLANK);
            return false;
        } else if(!Pattern.matches(CommonConstant.MOBILE_REGEX, leadToAdd.MobilePhone)) {
            res.put('status', CommonConstant.FAILURE);
            res.put('message', CommonConstant.MOBILE_ERROR);
            return false;
        }else {
            return true;
        }
    }
}