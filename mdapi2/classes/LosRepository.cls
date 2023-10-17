/*
*
*Name  :  LosRepository
*Author:  Thinqloud Solutions (Dhanaji Patil, Aasim Shaikh)
*Date  :  Feb 20, 2023
*Purpose : This class we are using for create dynamic query.
*
*/

global with sharing class LosRepository {
    
    /********************************************************************************************************
* @author Aasim Shaikh
* @description This method create payload as expected to call los api
* @Arguments leadId, accountId, accType(Applicant/Co-Applicant/Gaurantor)
* @Arguments losMappingID(This id is from LosApiMaster__c - unique to each los api and
*LosApiMap__c - > LosMapId__c contains all fields that are mapped in SF.)
* @return List<Map<String, Object>> - KEY(LOS-fieldsName) : Value(SF- corr. value against Key)      
* @date 28/02/2023    
********************************************************************************************************/
    public static List<Map<String, Object>> getDynamicLosMapping(String leadId, String accountId, String losMappingId) {
        
        Map<String, Object> payloadMap = new Map<String, Object>();
        List<Map<String, Object>> payloadMapInList = new List<Map<String, Object>>();
        try {
            List<LosApiMap__c> mappingFields = [
                select id, Name, Default__c, TableName__c, LosMapId__c, LosLable__c, SalesforceLable__c, LosDataType__c from LosApiMap__c
                where LosMapId__c =:losMappingId];
            
            // Mapping unique tableNames
            Set<String> tableNames = new Set<String>();
            for (LosApiMap__c field : mappingFields) {
                if (field.TableName__c != null) {
                    tableNames.add(field.TableName__c);
                }
            }
            System.debug('set: ' + tableNames + ' size:' + tableNames.size() + ' losMappingId:' + losMappingId);
            
            List<LosApiMap__c> tableMapping = [
                select id, Name, Default__c, TableName__c, LosMapId__c, LosLable__c, SalesforceLable__c, LosDataType__c from
                LosApiMap__c where LosMapId__c =:losMappingId and TableName__c in:tableNames];
            
            System.debug('tableMapping size ::: ' + tableMapping.size());
            Map<String, List<LosApiMap__c>> tableTOLosMapping = new Map<String, List<LosApiMap__c>>();
            
            // Mapping LosApiMap__c obj againts key(TableName)
            for (LosApiMap__c add : tableMapping) {
                List<LosApiMap__c> mapList = new List<LosApiMap__c>();
                mapList.add(add);
                if (tableTOLosMapping.containsKey(add.TableName__c)) {
                    mapList.addAll(tableTOLosMapping.get(add.TableName__c));
                    tableTOLosMapping.put(add.TableName__c, mapList);
                } else {
                    tableTOLosMapping.put(add.TableName__c, mapList);
                }
            }
            
            // Maps LOS label which has no SF mapping.
            for (LosApiMap__c addMap : mappingFields) {
                if (addMap.TableName__c == null) {
                    payloadMap.put(addMap.LosLable__c, addMap.Default__c != null ? addMap.Default__c : '');
                }
            }
            
            // Maps key:value for each table/object present.
            for (String tableName : tableNames) {
                String qry = '';
                Set<String> qryParams = new Set<String>();
                
                System.debug('LosApiMap__c size for LosMapId__c : ' + losMappingId + ' and table ' + tableName + ' -' + tableMapping.size());
                
                // Dynamic method to generate query string                   
                for (LosApiMap__c addMap : tableTOLosMapping.get(tableName)) {
                    String sfLabel = addMap.SalesforceLable__c;
                    if (sfLabel != null && (!sfLabel.equalsIgnoreCase('Id')) && addMap.Default__c == null) {
                        qryParams.add(sfLabel);
                    }
                }
                
                // adds unique select parameters only
                for (String param : qryParams) {
                    qry += param + ',';
                }
                
                System.debug('tableName: ' + tableName);
                if(tableName.equalsIgnoreCase('Lead')) {
                    qry = 'Select ' + qry + 'id FROM ' + tableName + ' where Id =:leadId';
                } else if(tableName.equalsIgnoreCase('Account')) {
                    qry = 'Select ' + qry + 'id FROM ' + tableName + ' where Id =:leadId';
                } else if(tableName.equalsIgnoreCase('Asset')) {
                    qry = 'Select ' + qry + 'id FROM ' + tableName + ' where AccountId =:accountId and Lead__c =:leadId';
                } else if(losMappingId == CommonConstant.CUSTADDRESS_API_ID && tableName == 'ContactPointAddress' ) {                    
                    List<String> addressType = new List<String>();
                    addressType.add('Current Address');
                    addressType.add('Permanent Address');
                    qry = 'Select ' + qry + 'id FROM ' + tableName + ' where Account__c =:accountId and Lead__c =:leadId and Address_Type__c in:addressType';
                    
                } else if(losMappingId == CommonConstant.EMPLOYMENTDETAILS_API_ID && tableName == 'ContactPointAddress' ) {
                    List<String> addressType = new List<String>();
                    addressType.add('Office');
                    qry = 'Select ' + qry + 'id FROM ' + tableName + ' where Account__c =:accountId and Lead__c =:leadId and Address_Type__c in:addressType limit 1';
                    
                } else {
                    qry = 'Select ' + qry + 'id FROM ' + tableName + ' where Account__c =:accountId and Lead__c =:leadId';
                }  
                
                System.debug('query: ' + qry);
                List<SObject> leadData = Database.query(qry);  
                System.debug('leadData size :::::::: ' + leadData.size());
                
                if(leadData.size() > 0) {
                    for(Integer i = 0; i < leadData.size(); i++) {
                        Map<String,Object> tempMap = new Map<String,Object>(payloadMap);
                        // populates data into map.
                        populateData(tempMap,  tableTOLosMapping, tableName, leadData[i], accountId, losMappingId);
                        
                        if(leadData.size() == 1 && payloadMapInList.size() > 0) {
                            for(Map<String, Object> addObj : payloadMapInList) {
                                addObj.putAll(tempMap);
                            }
                        } else {
                            payloadMapInList.add(tempMap);
                        }
                        
                    }
                } else {
                    return new List<Map<String, Object>>();
                }
            }            
            // calling insertion logic                        
            putInsertionOrder(payloadMapInList);
            // customizes payload for addressDetail api
            if(losMappingId == CommonConstant.CUSTADDRESS_API_ID) {
                populateAddressData(payloadMapInList);
            }
            // customizes payload for employmentDetail api
            if(losMappingId == CommonConstant.EMPLOYMENTDETAILS_API_ID) {
                populateEmploymentData(payloadMapInList, losMappingId);
            }
        } catch (Exception e) {
            e.getStackTraceString();
            System.debug('Error in repository:::::' + e.getMessage() + ' at line no. - ' + e.getLineNumber());
            return new List<Map<String, Object>>();
        }
        System.debug('List of payload %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' + JSON.serialize(payloadMapInList));
        return payloadMapInList;
    }  
    
      /********************************************************************************************************
        * @author Aasim Shaikh
        * @description This method is used to create payload - populates data.
        * @Arguments los Payload, accountId, losMappingId(to get los api master data)         
        * @date 23/03/2023    
	  ********************************************************************************************************/    
    public static void populateData(Map<String,Object> payloadMap, Map<String, List<LosApiMap__c>> tableTOLosMapping, String tableName, 
                                    SObject leadData, String accountId, String losMAppingId) {
                     
        for (LosApiMap__c addMap : tableTOLosMapping.get(tableName)) {
            if (addMap.SalesforceLable__c != null && leadData != null) {

                String[] checkRelationField = addMap.SalesforceLable__c.split('\\.');
                
                if (checkRelationField.size() > 1) {
                    String key = checkRelationField[0];
                    String value = checkRelationField[1];
                    
                    Object leadObjData = leadData.getSobject(key) != null ? leadData.getSobject(key).get(value) : '';
                    
                    if(leadObjData instanceOf Date || leadObjData instanceOf Datetime){
                        leadObjData = LosUtils.getFormatedDate(leadObjData);
                    }                             
                    if(addMap.LosDataType__c!= null && addMap.LosDataType__c.equalsIgnoreCase('BOOLEAN')) {
                        leadObjData = leadObjData != null ? 1 : 0 ;
                    }
                    if(addMap.LosDataType__c!= null && addMap.LosDataType__c.equalsIgnoreCase('NUMBER')) {
                        leadObjData = leadObjData != null ? leadObjData : 0 ;
                    }
                    payloadMap.put(addMap.LosLable__c, leadObjData != null ? leadObjData : addMap.Default__c != null ? addMap.Default__c : ''); 
                    
                } else {
                    Object leadObjData = leadData.get(addMap.SalesforceLable__c)!= null ? leadData.get(addMap.SalesforceLable__c) : '';
                    
                    if(leadObjData instanceOf Date || leadObjData instanceOf Datetime) {
                        leadObjData = LosUtils.getFormatedDate(leadObjData);
                    }
                    if(addMap.LosDataType__c!= null && addMap.LosDataType__c.equalsIgnoreCase('BOOLEAN')) {
                        leadObjData = leadObjData != null ? 1 : 0 ;
                    }
                    if(addMap.LosDataType__c!= null && addMap.LosDataType__c.equalsIgnoreCase('NUMBER')) {
                        leadObjData = leadObjData != null ? leadObjData : 0 ;
                    }
                    payloadMap.put(addMap.LosLable__c, leadObjData != null ? leadObjData : addMap.Default__c != null ? addMap.Default__c : '');
                    
                }
            } else {
                payloadMap.put(addMap.LosLable__c, addMap.Default__c != null ? addMap.Default__c : '');
            }
        }
         
    }
    
    /********************************************************************************************************
        * @author Aasim Shaikh
        * @description This method is used to customize payload for addressDetail api.
        * @Arguments los Payload        
        * @date 31/03/2023    
	  ********************************************************************************************************/    
    public static void populateAddressData(List<Map<String,Object>> payloadList) {
        // Will hold first item current/permanent address type object.
        Map<String, Object> tempAddressMap = null; 
        
        for(Integer i = 0; i < payloadList.size(); i++) {
            if(i == 0) {               
                tempAddressMap = new Map<String, Object>(payloadList[0]);
            } else {
                //Inserts current/permanent address values in, pre occupied current/permanent address values.
                String addressType = payloadList[i].get('ADDRESS_TYPE').toString();
                List<LosApiMap__c> permanentLosLabel = [select id, LosLable__c, SalesforceLable__c,LosDataType__c from LosApiMap__c 
                                                        where LosDataType__c =:addressType]; 
                
                for(LosApiMap__c perAddressMap : permanentLosLabel) {
                    Object perData = payloadList[i].get(perAddressMap.LosLable__c);
                    tempAddressMap.put(perAddressMap.LosLable__c, perData);
                }
                
            }
        }
        payloadList.clear();
        payloadList.add(tempAddressMap);
    }
    
    /********************************************************************************************************
        * @author Aasim Shaikh
        * @description This method is used to customize payload for employmentDetail api
        * @Arguments los Payload        
        * @date 31/03/2023    
	  ********************************************************************************************************/
    public static void  populateEmploymentData(List<Map<String,Object>> payloadList, String losMAppingId) {
        for(Integer i = 0 ; i < payloadList.size(); i++) {
            Map<String,Object> tempPayload = new Map<String,Object>(payloadList[i]);
            String empType = tempPayload.get('OCCUPATION_TYPE').toString();
            
            List<String> excludeParams = new List<String>();
            excludeParams.add(null);
            excludeParams.add(empType);
            excludeParams.add('NUMBER');
            List<LosApiMap__c> employmentAddressExcludeList = [select id,LosMapId__c, LosLable__c,LosDataType__c from LosApiMap__c 
                                                               where LosMapId__c='a0aBi000002POfhIAG' and LosDataType__c not in:excludeParams];
            for(LosApiMap__c addMap : employmentAddressExcludeList) {
                payloadList[i].put(addMap.LosLable__c, '');
            }
        }
    }
    /********************************************************************************************************
* @author Aasim Shaikh
* @description This method inserts insertion paramenter according to individual api's logic 
* @Arguments los Payload, accountId, losMappingId(to get los api master data)         
* @date 20/03/2023    
********************************************************************************************************/
    public static void putInsertionOrder(List<Map<String, Object>> payload){
        try {
            for(Integer i = 0; i < payload.size(); i++) {
                if(payload[i].containsKey('INSERTIONORDER_ID')) {
                    Integer INSERTIONORDER_ID =  Integer.valueOf(payload[i].get('INSERTIONORDER_ID'));
                    payload[i].put('INSERTIONORDER_ID', INSERTIONORDER_ID + i);
                } else {
                    System.debug(' No INSERTIONORDER_ID ');
                }
            }        
            
        } catch(Exception e){
            e.getStackTraceString();
            System.debug('Exception in putInsertionOrder: ' + e.getMessage() + '. At line no.- ' + e.getLineNumber());
        }
    }
    
    /******************************************************************************************************
* @author Aasim Shaikh
* @description This method generates query with all the SF apiName, objName present in LosApiMap__c
* @Note This method is not used in LOS integration whatsoever. This is for developer's reference only.           
* @date 20/03/2023    
********************************************************************************************************/
    public static void generateQuery() {
        List<String> queries = new List<String>();
        List<String> ids = new List<String> {'a0aBi000002POfXIAW', 'a0aBi000002POfoIAG'} ;
            
		List<LosApiMap__c> mappingFields = [
                select id, Name, Default__c, TableName__c, LosMapId__c, LosLable__c, SalesforceLable__c, LosDataType__c
                from LosApiMap__c where TableName__c !=null and LosMapId__c not in:ids];
        
        Set<String> tableNames = new Set<String>();
        for (LosApiMap__c field : mappingFields) {
            tableNames.add(field.TableName__c);
        }
        System.debug('Size: ' + tableNames.size());
        for (String addMap : tableNames) {
            //System.debug('tableName: '+addMap);
            String qry = '';
            List<LosApiMap__c> allFieldsInObj = [
                select id, Name, Default__c, TableName__c, LosMapId__c, LosLable__c, SalesforceLable__c, LosDataType__c
                from LosApiMap__c where TableName__c =:addMap and LosMapId__c not in:
                ids];
            for (LosApiMap__c qryMap : allFieldsInObj) {
                String sfLabel = qryMap.SalesforceLable__c;
                if (qryMap.SalesforceLable__c != null && (!sfLabel.equalsIgnoreCase('Id')) && (!qry.contains(sfLabel)) && qryMap.Default__c == null) {
                    qry += qryMap.SalesforceLable__c + ', ';
                }
            }
            qry = 'Select ' + qry + 'id FROM ' + addMap;
            queries.add(qry);
        }
        for (String qry : queries) {
            System.debug(qry);
        }
    }
    
}