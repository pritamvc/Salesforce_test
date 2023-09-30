/**
 * @Name: LOSHTTPUtils
 * @Author: Thinqloud Solutions (Dhanaji Patil, Aasim Shaikh)
 * @description Dynamic mapping class
 * @Date: Feb 20, 2023
 * @Purpose: This class is used for creating dynamic queries.
 */
public class LOSHTTPUtils{
    
    /**
     * Author: Aasim Shaikh
     * @description This method creates a payload as expected to call a Loan Origination System (LOS) API.
     * 
     * This method takes several arguments, including leadId, accountId, and accType (Applicant/Co-Applicant/Guarantor),
     * as well as losMappingID (This ID is from LosApiMaster__c - unique to each LOS API and
     * 
     * @param leadId The Lead ID associated with the payload.
     * @param accountId The Account ID associated with the payload.
     * @param losMappingId The ID from LosApiMaster__c unique to each LOS API.
     * @return List<Map<String, Object>> A list of maps where the key is the LOS field name and the value is the corresponding Salesforce value.
     * @date 28/02/2023
     */
    public static List<Map<String, Object>> getDynamicLosMapping(String leadId, String accountId, String losMappingId) {
        String apiName = null; 
        Map<String, Object> payloadMap = new Map<String, Object>();
        List<Map<String, Object>> payloadMapInList = new List<Map<String, Object>>();
        
        try {
            //Get all mapped fields from mapId
            List<LosApiMap__c> mappingFields = [SELECT Id, Name, Default__c, TableName__c, LosApiMaster__c, LosApiMaster__r.ApiName__c, LosLable__c, SalesforceLable__c, LosDataType__c FROM LosApiMap__c
                                                WHERE LosApiMaster__c =:losMappingId];
            
            //Assign apiName from result
            apiName = mappingFields[0].LosApiMaster__r.ApiName__c;
            
            // Mapping unique tableNames
            Set<String> tableNames = new Set<String>();
            for (LosApiMap__c field : mappingFields) {
                if (field.TableName__c != null) {
                    tableNames.add(field.TableName__c);
                }
            }
            
            //Get all table names from mapId and above's tableName
            List<LosApiMap__c> tableMapping = [SELECT Id, Name, Default__c, TableName__c, LosApiMaster__c, LosApiMaster__r.ApiName__c, LosLable__c, SalesforceLable__c, LosDataType__c FROM
                                               LosApiMap__c WHERE LosApiMaster__c =:losMappingId and TableName__c in:tableNames];
            
            Map<String, List<LosApiMap__c>> tableTOLosMapping = new Map<String, List<LosApiMap__c>>();
            
            // Mapping LosApiMap__c obj againts key(TableName)
            for (LosApiMap__c add : tableMapping) {
                List<LosApiMap__c> mapList = new List<LosApiMap__c>();
                mapList.add(add);
                if (tableTOLosMapping.containsKey(add.TableName__c)) {
                    mapList.addAll(tableTOLosMapping.get(add.TableName__c));
                    tableTOLosMapping.put(add.TableName__c, mapList);
                } 
                else {
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
                
                // Dynamic method to generate query string                   
                for (LosApiMap__c addMap : tableTOLosMapping.get(tableName)) {
                    String sfLabel = addMap.SalesforceLable__c;
                    if (sfLabel != null && (!sfLabel.equalsIgnoreCase(LOSConstants.ID)) && addMap.Default__c == null) {
                        qryParams.add(sfLabel);
                    }
                }
                
                // adds unique select parameters only
                for (String param : qryParams) {
                    qry += param + ',';
                }
                
                //Create a query as per mappedFields and tableName
                if(tableName.equalsIgnoreCase(LOSConstants.LEAD_NAME)) {
                    qry = LOSConstants.SELECT_FROM + qry + LOSConstants.ID_FROM + tableName + LOSConstants.WHERE_LEADID;
                } 
                else if(tableName.equalsIgnoreCase(LOSConstants.ACCOUNT_NAME)) {
                    qry = LOSConstants.SELECT_FROM + qry + LOSConstants.ID_FROM + tableName + LOSConstants.WHERE_ACCID;
                } 
                else if(tableName.equalsIgnoreCase(LOSConstants.ASSET_NAME)) {
                    qry = LOSConstants.SELECT_FROM + qry + LOSConstants.ID_FROM + tableName + LOSConstants.WHERE_LEAD_ACC_ID;
                    if(apiName == LOSConstants.ASSET_API_NAME){
                        qry += LOSConstants.ASSET_TYPE;
                    }
                    if(apiName == LOSConstants.IMMOVABLE_API_NAME || apiName == LOSConstants.MOVABLE_API_NAME){
                        qry += LOSConstants.COLLATERAL_TYPE;
                    }
                } 
                else if(apiName == LOSConstants.CUSTADDRESS_API_NAME && tableName == LOSConstants.ADDRESS_NAME) { 
                    List<String> addressList = new List<String>();
                    addressList.add(LOSConstants.CURRENT_ADDRESS);
                    addressList.add(LOSConstants.PERMANENT_ADDRESS);
                    
                    qry = LOSConstants.SELECT_FROM + qry + LOSConstants.ID_FROM + tableName + LOSConstants.WHERE_LEAD_ACC_ADD;
                    
                } 
                else if(apiName == LOSConstants.EMPLOYMENTDETAILS_API_NAME && tableName == LOSConstants.ADDRESS_NAME) {
                    List<String> addressType = new List<String>();
                    addressType.add(LOSConstants.OFFICE_ADDRESS);
                    qry = LOSConstants.SELECT_FROM + qry + LOSConstants.ID_FROM + tableName + LOSConstants.WHERE_LEAD_ACC_ADD_LIMIT;  
                } 
                else {
                    qry = LOSConstants.SELECT_FROM + qry + LOSConstants.ID_FROM + tableName + LOSConstants.WHERE_LEAD_ACCOUNTID;
                }  
                
                //Create object and get data as fer requested query
                List<SObject> leadData = new List<SObject>();
                leadData = Database.query(qry);  
                if(leadData.size() == 0){ 
                    Set<String> labelSet = new Set<String>();
                    String labels = System.Label.Except_Table;
                    String[] labelArray = labels.split(',');
                    for (String label : labelArray) {
                        labelSet.add(label.trim());
                    }
                    
                    if(labelSet.contains(tableName)){
                        SObject myObject;
                        Type objectType = Type.forName(tableName);
                        
                        if (objectType != null && objectType.newInstance() instanceof SObject) {
                            myObject = (SObject)objectType.newInstance();
                        }
                        for (String param : qryParams){
                            myObject.put(param,null);
                        }
                        leadData.add(myObject);
                    }                      
                }
                
                //If leadDate has data means query return rows
                if(leadData.size() > 0) {
                    for(Integer i = 0; i < leadData.size(); i++) {
                        Map<String,Object> tempMap = new Map<String,Object>(payloadMap);
                        
                        //Populates data into map.
                        populateData(tempMap,  tableTOLosMapping, tableName, leadData[i], accountId, losMappingId);
                        
                        if(leadData.size() == 1 && payloadMapInList.size() > 0) {
                            for(Map<String, Object> addObj : payloadMapInList) {
                                addObj.putAll(tempMap);
                            }
                        } 
                        else {
                            payloadMapInList.add(tempMap);
                        }   
                    }
                } 
                else {
                    return new List<Map<String, Object>>();
                }
            }     
            
            if(payloadMapInList != null && payloadMapInList.size() > 0){       
                //Calling insertion logic                        
                putInsertionOrder(payloadMapInList);
                
                //Customizes payload for addressDetail api
                if(apiName == LOSConstants.CUSTADDRESS_API_NAME) {
                    populateAddressData(payloadMapInList);
                }
                
                //Customizes payload for employmentDetail api
                if(apiName == LOSConstants.EMPLOYMENTDETAILS_API_NAME){
                    populateEmploymentData(payloadMapInList, losMappingId);
                }
            }
        } 
        catch (Exception e) {
            e.getStackTraceString();
            System.debug(LOSConstants.QUERY_EXCEPTION + e.getMessage() + LOSConstants.QUERY_EXCEPTION_LINE + e.getLineNumber());
            return new List<Map<String, Object>>();
        }
        return payloadMapInList;
    }  
    
    /**
     * Author: Aasim Shaikh
     * @description This method is used to create a payload by populating data.
     * @date 23/03/2023
     * 
     * @param payloadMap The map to populate with data.
     * @param tableTOLosMapping The map containing LOS API mapping data.
     * @param tableName The name of the table for mapping.
     * @param leadData The SObject containing lead data.
     * @param accountId The Account ID associated with the payload.
     * @param losMappingId The ID from LosApiMaster__c to get LOS API master data.
     */   
    public static void populateData(Map<String,Object> payloadMap, Map<String, List<LosApiMap__c>> tableTOLosMapping, String tableName,SObject leadData, String accountId, String losMAppingId) {                                  
        for (LosApiMap__c addMap : tableTOLosMapping.get(tableName)) {
            if (addMap.SalesforceLable__c != null && leadData != null) {
                //Check for relation fields means from parent object some fields are fetched child oject
                String[] checkRelationField = addMap.SalesforceLable__c.split(LOSConstants.SPLIT);
                
                if (checkRelationField.size() > 1) {
                    String key = checkRelationField[0];
                    String value = checkRelationField[1];
                    
                    Object leadObjData = leadData.getSobject(key) != null ? leadData.getSobject(key).get(value) : '';
                    
                    //Get the formatted date which saves in SF
                    if(leadObjData instanceOf Date || leadObjData instanceOf Datetime){
                        leadObjData = LosUtils.getFormatedDate(leadObjData);
                    }      
                    
                    //If the datatype is boolean then we are sending data as 0/1
                    if(addMap.LosDataType__c!= null && addMap.LosDataType__c.equalsIgnoreCase(LOSConstants.BOOLEAN_TYPE)) {
                        leadObjData = leadObjData != null ? 1 : 0 ;
                    }
                    
                    //If the datatype is number then that number or 0
                    if(addMap.LosDataType__c!= null && addMap.LosDataType__c.equalsIgnoreCase(LOSConstants.NUMBER_TYPE)) {
                        leadObjData = leadObjData != null ? leadObjData : 0 ;
                    }
                    payloadMap.put(addMap.LosLable__c, leadObjData != null ? leadObjData : addMap.Default__c != null ? addMap.Default__c : ''); 
                    
                } 
                else {
                    Object leadObjData = leadData.get(addMap.SalesforceLable__c)!= null ? leadData.get(addMap.SalesforceLable__c) : '';
                    
                    //Get the formatted date which saves in SF
                    if(leadObjData instanceOf Date || leadObjData instanceOf Datetime) {
                        leadObjData = LosUtils.getFormatedDate(leadObjData);
                    }
                    
                    //If the datatype is boolean then we are sending data as 0/1
                    if(addMap.LosDataType__c!= null && addMap.LosDataType__c.equalsIgnoreCase(LOSConstants.BOOLEAN_TYPE)) {
                        leadObjData = leadObjData != null ? 1 : 0 ;
                    }
                    
                    //If the datatype is number then that number or 0
                    if(addMap.LosDataType__c!= null && addMap.LosDataType__c.equalsIgnoreCase(LOSConstants.NUMBER_TYPE)) {
                        leadObjData = leadObjData != null ? leadObjData : 0 ;
                    }
                    payloadMap.put(addMap.LosLable__c, leadObjData != null ? leadObjData : addMap.Default__c != null ? addMap.Default__c : '');  
                }
            } 
            else {
                payloadMap.put(addMap.LosLable__c, addMap.Default__c != null ? addMap.Default__c : '');
            }
        }   
    }
    
    /**
     * Author: Aasim Shaikh
     * @description This method is used to customize the payload for the addressDetail API
     * 
     * @param payloadList The list of maps representing the payload to be customized.
     * @date 31/03/2023
     */
    public static void populateAddressData(List<Map<String,Object>> payloadList) {
        // Will hold first item current/permanent address type object.
        Map<String, Object> tempAddressMap = null; 
        
        for(Integer i = 0; i < payloadList.size(); i++) {
            if(i == 0) {               
                tempAddressMap = new Map<String, Object>(payloadList[0]);
                Object perData = tempAddressMap.get(LOSConstants.CURR_IS_IT_CORRESPOND);
                if (perData == true || perData == false){
                    tempAddressMap.put(LOSConstants.CURR_IS_IT_CORRESPOND, (Boolean)perData ? LOSConstants.CORRESPOND_YES : LOSConstants.CORRESPOND_NO);
                }
            } 
            else {
                //Inserts current/permanent address values in, pre occupied current/permanent address values.
                String addressType = payloadList[i].get(LOSConstants.ADDRESS_TYPE).toString();
                List<LosApiMap__c> permanentLosLabel = [select id, LosLable__c, SalesforceLable__c,LosDataType__c from LosApiMap__c 
                                                        where LosDataType__c =:addressType]; 
                
                for(LosApiMap__c perAddressMap : permanentLosLabel) {
                    Object perData = payloadList[i].get(perAddressMap.LosLable__c);
                    if(perData == true || perData == false){
                        tempAddressMap.put(perAddressMap.LosLable__c, perData == true?LOSConstants.CORRESPOND_YES:LOSConstants.CORRESPOND_No);
                    }
                    else{
                        tempAddressMap.put(perAddressMap.LosLable__c, perData);
                    }
                }   
            }
        }
        payloadList.clear();
        payloadList.add(tempAddressMap);
    }
    
    /**
     * Author: Aasim Shaikh
     * @description This method is used to customize the payload for the employmentDetail API.
     * 
     * @param payloadList The list of maps representing the payload to be customized.
     * @param losMappingId The ID from LosApiMaster__c to get LOS API master data.
     * @date 31/03/2023
     */
    public static void  populateEmploymentData(List<Map<String,Object>> payloadList, String losMappingId) {
        for(Integer i = 0 ; i < payloadList.size(); i++) {
            Map<String,Object> tempPayload = new Map<String,Object>(payloadList[i]);
            String empType = tempPayload.get(LOSConstants.OCCUPATION_TYPE).toString();
            
            //Create list to exclude the data while querying
            List<String> excludeParams = new List<String>();
            excludeParams.add(null);
            excludeParams.add(empType);
            excludeParams.add(LOSConstants.NUMBER_TYPE);
            
            List<LosApiMap__c> employmentAddressExcludeList = [select id, LosApiMaster__c, LosApiMaster__r.ApiName__c, LosLable__c,LosDataType__c from LosApiMap__c 
                                                               where LosApiMaster__c=:losMappingId and LosDataType__c not in:excludeParams];
            for(LosApiMap__c addMap : employmentAddressExcludeList) {
                payloadList[i].put(addMap.LosLable__c, '');
            }
        }
    }
    
    /**
     * Author: Aasim Shaikh
     * @description This method inserts insertion parameters according to individual API's logic.
     *
     * @param payload The list of maps representing the payload to be modified with insertion parameters.
     * @date 20/03/2023
     */
    public static void putInsertionOrder(List<Map<String, Object>> payload){
        try {
            for(Integer i = 0; i < payload.size(); i++) {
                if(payload[i].containsKey(LOSConstants.INSERTIONORDER_ID)) {
                    Integer insertionOrderId =  Integer.valueOf(payload[i].get(LOSConstants.INSERTIONORDER_ID));
                    payload[i].put(LOSConstants.INSERTIONORDER_ID, insertionOrderId + i);
                } 
                else {
                    System.debug(LOSConstants.NO_INSERTION_EXCEPTION);
                }
            }           
        } 
        catch(Exception e){
            e.getStackTraceString();
            System.debug(LOSConstants.INSERTION_EXCEPTION + e.getMessage() + LOSConstants.QUERY_EXCEPTION_LINE + e.getLineNumber());
        }
    }
    
     /**
     * Author: Sohail Solapure
     * @description This method is used to create a request dynamically for exam scores.
     * 
     * @param leadId The Lead ID associated with the request.
     * @param accountId The Account ID associated with the request.
     * @param losMappingId The ID from LosApiMaster__c to get LOS API master data.
     * @param size The size of the request.
     * @return List<Map<String, Object>>
     * @date 14/08/2023
     */
    public static List<Map<String, Object>> getDynamicLosMappingForExamScore(String leadId, String accountId, String losMappingId,Integer size) {
        String apiName = null; 
        Map<String, Object> payloadMap = new Map<String, Object>();
        List<Map<String, Object>> payloadMapInList = new List<Map<String, Object>>();
        
        try {
            //Get all mapped fields from mapId
            List<LosApiMap__c> mappingFields = [SELECT Id, Name, Default__c, TableName__c, LosApiMaster__c, LosApiMaster__r.ApiName__c, LosLable__c, SalesforceLable__c, LosDataType__c FROM LosApiMap__c
                                                WHERE LosApiMaster__c =:losMappingId];
            
            //Assign apiName from result
            apiName = mappingFields[0].LosApiMaster__r.ApiName__c;
            
            // Mapping unique tableNames
            Set<String> tableNames = new Set<String>();
            for (LosApiMap__c field : mappingFields) {
                if (field.TableName__c != null) {
                    tableNames.add(field.TableName__c);
                }
            }
            
            //Get all table names from mapId and above's tableName
            List<LosApiMap__c> tableMapping = [SELECT Id, Name, Default__c, TableName__c, LosApiMaster__c, LosApiMaster__r.ApiName__c, LosLable__c, SalesforceLable__c, LosDataType__c FROM
                                               LosApiMap__c WHERE LosApiMaster__c =:losMappingId and TableName__c in:tableNames];
            
            Map<String, List<LosApiMap__c>> tableTOLosMapping = new Map<String, List<LosApiMap__c>>();
            
            // Mapping LosApiMap__c obj againts key(TableName)
            for (LosApiMap__c add : tableMapping) {
                List<LosApiMap__c> mapList = new List<LosApiMap__c>();
                mapList.add(add);
                if (tableTOLosMapping.containsKey(add.TableName__c)) {
                    mapList.addAll(tableTOLosMapping.get(add.TableName__c));
                    tableTOLosMapping.put(add.TableName__c, mapList);
                } 
                else {
                    tableTOLosMapping.put(add.TableName__c, mapList);
                }
            }
            
            // Maps LOS label which has no SF mapping.
            for (LosApiMap__c addMap : mappingFields) {
                if (addMap.TableName__c == null) {
                    payloadMap.put(addMap.LosLable__c, addMap.Default__c != null ? addMap.Default__c : '');
                }
                if(addMap.Default__c != null && addMap.Default__c != '0'){
                    String[] defaultValues = addMap.Default__c.split(',');
                    payloadMap.put(addMap.LosLable__c, defaultValues[size] != null ? defaultValues[size] : '');
                }
            }
            
            // Maps key:value for each table/object present.
            for (String tableName : tableNames) {
                String qry = '';
                Set<String> qryParams = new Set<String>();
                
                // Dynamic method to generate query string                   
                for (LosApiMap__c addMap : tableTOLosMapping.get(tableName)) {
                    String sfLabel = addMap.SalesforceLable__c;
                    if (sfLabel != null && (!sfLabel.equalsIgnoreCase(LOSConstants.ID)) && addMap.Default__c == null) {
                        qryParams.add(sfLabel);
                    }
                }
                
                // adds unique select parameters only
                for (String param : qryParams) {
                    if(param.contains(',')){
                        String[] salesforceField = param.split(',');
                        qry += salesforceField[size] + ',';
                    }
                    else{
                        if(!qry.contains(param)){
                        	qry += param + ',';
                        }
                    }    
                }
                
                //Create a query as per mappedFields and tableName
                if(tableName.equalsIgnoreCase(LOSConstants.LEAD_NAME)) {
                    qry = LOSConstants.SELECT_FROM + qry + LOSConstants.ID_FROM + tableName + LOSConstants.WHERE_LEADID;
                } 
                else {
                    qry = LOSConstants.SELECT_FROM + qry + LOSConstants.ID_FROM + tableName + LOSConstants.WHERE_LEAD_ACCOUNTID;
                }  
                
                //Create object and get data as fer requested query
                List<SObject> leadData = new List<SObject>();
                leadData = Database.query(qry);  
                //If leadDate has data means query return rows
                if(leadData.size() > 0) {
                    for(Integer i = 0; i < leadData.size(); i++) {
                        Map<String,Object> tempMap = new Map<String,Object>(payloadMap);
                        
                        //Populates data into map.
                        populateDataForExamScore(tempMap,  tableTOLosMapping, tableName, leadData[i], accountId, losMappingId, size);
                        
                        if(leadData.size() == 1 && payloadMapInList.size() > 0) {
                            for(Map<String, Object> addObj : payloadMapInList) {
                                addObj.putAll(tempMap);
                            }
                        } 
                        else {
                            payloadMapInList.add(tempMap);
                        }   
                    }
                } 
            }     
            
            if(payloadMapInList != null && payloadMapInList.size() > 0){       
                //Calling insertion logic                        
                putInsertionOrder(payloadMapInList);
            }
        }
        catch (Exception e) {
            e.getStackTraceString();
            System.debug(LOSConstants.QUERY_EXCEPTION + e.getMessage() + LOSConstants.QUERY_EXCEPTION_LINE + e.getLineNumber());
            return new List<Map<String, Object>>();
        }
        return payloadMapInList;
    }  
    
    /**
     * Author: Sohail Solapure
     * @description This method is used to populate data for exam scores.
     *  
     * @param payloadMap The map to populate with data.
     * @param tableTOLosMapping The map containing LOS API mapping data.
     * @param tableName The name of the table for mapping.
     * @param leadData The SObject containing lead data.
     * @param accountId The Account ID associated with the payload.
     * @param losMAppingId The ID from LosApiMaster__c to get LOS API master data.
     * @param size The size of the request.
     * @date 16/08/2023
     */
    public static void populateDataForExamScore(Map<String,Object> payloadMap, Map<String, List<LosApiMap__c>> tableTOLosMapping, String tableName,SObject leadData, String accountId, String losMAppingId,Integer size) {
                                        
        for (LosApiMap__c addMap : tableTOLosMapping.get(tableName)) {
            if (addMap.SalesforceLable__c != null && leadData != null) {
                Object leadObjData;
                if(addMap.SalesforceLable__c.contains(',')){
                    String[] salesforceFields = addMap.SalesforceLable__c.split(',');
                    leadObjData = leadData.get(salesforceFields[size])!= null ? leadData.get(salesforceFields[size]) : '';
                }
                else{
                	leadObjData = leadData.get(addMap.SalesforceLable__c)!= null ? leadData.get(addMap.SalesforceLable__c) : '';
                }
                //If the datatype is number then that number or 0
                if(addMap.LosDataType__c != null && addMap.LosDataType__c.equalsIgnoreCase(LOSConstants.NUMBER_TYPE)) {
                    leadObjData = leadObjData != null ? leadObjData : 0 ;
                }
                payloadMap.put(addMap.LosLable__c, leadObjData != null ? leadObjData : addMap.Default__c != null ? addMap.Default__c : '');  
            }
            else {
                payloadMap.put(addMap.LosLable__c, addMap.Default__c != null ? addMap.Default__c : '');
            }
            String scoreCategory = payloadMap.get('SCORE_CATEGORY').toString();
            if(scoreCategory == 'Language'){
                String[] languageRemove = System.Label.Language_Score_Remove_Fields.split(',');
                for(String currField:languageRemove){
                    payloadMap.put(currField,0);
                }
            }
        }   
    }
    
    /******************************************************************************************************
    * @author Aasim Shaikh
    * @description This method generates query with all the SF apiName, objName present in LosApiMap__c
    * @Note This method is not used in LOS integration whatsoever. This is for developer's reference only.           
    * @date 20/03/2023  
    * param  
    ********************************************************************************************************/
    /*public static void generateQuery() {
        List<String> queries = new List<String>();
        List<String> ids = new List<String> {'a0aBi000002POfXIAW', 'a0aBi000002POfoIAG'} ;

        List<LosApiMap__c> mappingFields = [
        select id, Name, Default__c, TableName__c, LosApiMaster__c, LosApiMaster__r.ApiName__c, LosLable__c, SalesforceLable__c, LosDataType__c
        from LosApiMap__c where TableName__c !=null and LosApiMaster__c not in:ids];

        //Get tableName from resulted query
        Set<String> tableNames = new Set<String>();
        for (LosApiMap__c field : mappingFields) {
            tableNames.add(field.TableName__c);
        }

        for (String addMap : tableNames) {
            //System.debug('tableName: '+addMap);
            String qry = '';

            //Get fields data and label information on requested tableName
            List<LosApiMap__c> allFieldsInObj = [SELECT Id, Name, Default__c, TableName__c, LosApiMaster__c, LosApiMaster__r.ApiName__c, LosLable__c, SalesforceLable__c, LosDataType__c
            from LosApiMap__c where TableName__c =:addMap and LosApiMaster__c not in:ids];

            for (LosApiMap__c qryMap : allFieldsInObj) {
                String sfLabel = qryMap.SalesforceLable__c;
                if (qryMap.SalesforceLable__c != null && (!sfLabel.equalsIgnoreCase(LOSConstants.ID)) && (!qry.contains(sfLabel)) && qryMap.Default__c == null) {
                qry += qryMap.SalesforceLable__c + ', ';
            }
        }
        qry = LOSConstants.SELECT_FROM + qry + LOSConstants.ID_FROM + addMap;
        queries.add(qry);
        }
        for (String qry : queries) {
            System.debug(qry);
        }
    }  */ 
}