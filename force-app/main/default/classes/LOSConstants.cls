/*
* @author          Sohail Solapure
* @description     LOS constants class
* @return          No return any value 
* @param    
*/
public class LOSConstants {
    //LOS Integration constants
    public static final String REQUEST_TYPE_POST = 'POST'; 
    public static final String LOS_TOKEN = 'token';
    public static final String LOS_EXPIRY = 'expiry';
    public static final String LOS_ACCESS_TOKEN = 'access_token';
    public static final String LOS_EXPIRES_IN = 'expires_in';
    public static final String LOS_TOKEN_API_NAME = 'Get_Token';
    
    //LOS Exceptions 
    public static final String ERROR = 'Error: ';
    public static final String LOS_TOKEN_EXCEPTION = 'Exception While Generate Token :: ';
    public static final String REQUEST_EXCEPTION = 'Exception While creating request :: ';
    public static final String REQ_EXCEPTION = 'Exception While sending request ::';
    public static final String EMAIL_EXCEPTION = 'Exception While sending email ::';
    public static final String ERROR_EXCEPTION = 'Exception while save the Error log :';
    public static final String QUERY_EXCEPTION = 'Exception Error in repository :';
    public static final String QUERY_EXCEPTION_LINE = ' at line no. - ';
    public static final String ERROR_MSG = 'Collected lead dataTransfer details object is Empty'; 
    public static final String TOKEN_ERROR = 'Exception while geting token';
    public static final String LEAD_ERROR = 'Lead Id is not mapped';
    public static final String INSERTION_EXCEPTION = 'Exception in putInsertionOrder :';
    public static final String NO_INSERTION_EXCEPTION = 'No Insertion Order';
    public static final String LOS_FAILED_EXCEPTION = 'Exception in BatchFailedLOSDealDataSync :: ';
    public static final String LOS_SCHEDULER_EXCEPTION = 'Exception in schedulerForDataTransferAPICalling : ';
    
    //LOS API names
    public static final String WORK_ITEM_API_NAME = 'createWorkitem';
    public static final String DATA_TRANSFER_API_NAME = 'dataTransfer';
    public static final String MOVABLE_API_NAME = 'movable';
    public static final String IMMOVABLE_API_NAME = 'immovable';  
    public static final String CUSTADDRESS_API_NAME = 'addressDetail';  
    public static final String EMPLOYMENTDETAILS_API_NAME = 'employment';
    public static final String ASSET_API_NAME = 'assetDetails';
    public static final String LIABILITY_API_NAME = 'liabilityDetails';
    public static final String EXAM_SCORE_API_NAME = 'examScore';
    
    //API request/response fields
    public static final String LOS_SUCCESS = 'Success';
    public static final String LOS_FAIL = 'Fail';
    public static final Boolean LOS_FALSE = false;
    public static final Integer LOS_SUCCESS_CODE = 101;
    public static final Integer LOS_FAILURE_CODE = 102;
    public static final String STATUS_SUCCESS = 'Success';
    public static final String STATUS = 'status';
    public static final String STATUS_CODE = 'statusCode';
    public static final String DOCUMENT_INDEX = 'documentIndex';
    public static final Integer API_COUNT = 17;
    public static final Integer DATA_DELETE_BEFORE_DAYS = 30;
    public static final String AUTHENTICATED_USER = 'authenticated_userid';
    public static final String TEXT_PLAIN = 'text/plain';
    public static final String USER_NAME ='userName';
    public static final String AUTHORIZATION = 'Authorization';
    public static final String BEARER = 'Bearer ';
    public static final String CONTENT_TYPE = 'Content-Type';
    public static final String APPLICATION_JSON = 'application/json';
    
    //LOS fields
    public static final String PROCESS_INSTANCE_ID = 'ProcessInstanceId';
    public static final String APPLICATION_NUMBER = 'ApplicationNumber';
    public static final String FOLDER_INDEX = 'FolderIndex';
    
    //System data
    public static final String ENDPOINT = 'callout:LOS_API';
    public static final String LOCAL_TOKEN = 'local.StoreAccessToken';
    
    //Object names
    public static final String ID = 'Id';
    public static final String LEAD_NAME = 'Lead';
    public static final String ACCOUNT_NAME = 'Account';
    public static final String ASSET_NAME = 'Asset';
    public static final String OPPORTUNITY_NAME = 'Opportunity';
    public static final String ADDRESS_NAME = 'ContactPointAddress';
    public static final String DEMOGRAPHY = 'Demography__c';
    
    //Address types
    public static final String CURRENT_ADDRESS = 'Current Address';
    public static final String PERMANENT_ADDRESS = 'Permanent Address';
    public static final String OFFICE_ADDRESS = 'Office';
    
    //Query
    public static final String SELECT_FROM = 'SELECT ';
    public static final String ID_FROM = 'Id FROM ';
    public static final String WHERE_ACCID = ' WHERE Id =:accountId';
    public static final String WHERE_LEADID = ' WHERE Id =:leadId';
    public static final String WHERE_OPPID = ' WHERE Id =:oppId';
    public static final String WHERE_LEAD_ACC_ID = ' WHERE AccountId =: accountId and Lead__c =: leadId';
    public static final String WHERE_LEAD_ACCOUNTID = ' WHERE Account__c =: accountId and Lead__c =: leadId';
    public static final String ASSET_TYPE = ' and Asset_Type__c  != null';
    public static final String COLLATERAL_TYPE = ' and Collateral_Type__c != null';
    
    public static final String WHERE_LEAD_ACC_ADD = ' WHERE Account__c =: accountId and Lead__c =: leadId and Address_Type__c in: addressList';
    public static final String WHERE_LEAD_ACC_ADD_LIMIT = ' WHERE (Account__c =: accountId and Lead__c =: leadId) or Address_Type__c in: addressType LIMIT 1';
    public static final String OPP_QUERY = 'SELECT Id,Name, Lead__c, LOS_Id__c, LOS_Sync__c, Folder_Index__c, Loan_Application_Number__c,AccountId FROM Opportunity WHERE Lead__c = :leadId';
    public static final String OPP_QUERY_LIST = 'Select Id,Name, Lead__c, LOS_Id__c, LOS_Sync__c, Folder_Index__c, Loan_Application_Number__c,AccountId from Opportunity where Lead__c in :strLeadIdList';
    public static final String COAPP_QUERY = 'SELECT Id, Account__c, Lead__c, Type__c FROM Co_Applicant__c WHERE Lead__c = :leadId';
    
    //Email variables
    public static final String API_NAME = '{!ApiName}';
    public static final String ERROR_LOG_LINK = '{!ErrorLogLink}';
    
    public static final String APPLICANT = 'Applicant';
    public static final Integer FIVE_MIN_INTERVAL = 5;
    public static final String SCHEDULE_LEADID = ' LeadId- ';
    public static final String SCHEDULE_ACCOUNTID =' AccountId- ';
    
    //Create work item request parameters
    public static final String LEAD_ID = 'LEAD_ID';
    public static final String WI_NAME = 'WI_NAME';
    public static final String APPLICATION_NO = 'APPLICATION_NO';
    public static final String INSERTIONDATE = 'INSERTIONDATE';
    public static final String STATUS_DATA = 'STATUS'; 
    public static final String COMPLETIONDATE = 'COMPLETIONDATE';
    public static final String FAILURE_REASON = 'FAILURE_REASON';
    public static final String LOCATION_CODE = '004';
    
    //Create work item request body
    public static final String OPTION_START = '<LosWebservice_Input><Option>';
    public static final String OPTION_END = '</Option><AuthCode>';    
    public static final String SEGMENT_START = '</AuthCode><SegmentCode>';
    public static final String SEGMENT_END = '</SegmentCode><LocationCode>';
    public static final String BRANCH_START = '</LocationCode><BranchCode>';
    public static final String BRANCH_END = '</BranchCode><Attributes><LEAD_ID>';
    public static final String LEAD_END = '</LEAD_ID></Attributes></LosWebservice_Input>';
    
    public static final String SPLIT = '\\.';
    public static final String BOOLEAN_TYPE = 'BOOLEAN';
    public static final String DATE_TYPE = 'DATE';
    public static final String NUMBER_TYPE = 'NUMBER';
    public static final String ADDRESS_TYPE = 'ADDRESS_TYPE';
    public static final String OCCUPATION_TYPE = 'OCCUPATION_TYPE';
    public static final String INSERTIONORDER_ID = 'INSERTIONORDER_ID';
    public static final String COLL_TYPE = 'COLL_TYPE';
    public static final String CURR_IS_IT_CORRESPOND = 'CURR_IS_IT_CORRESPOND';
    public static final String CORRESPOND_YES = 'Yes';
    public static final String CORRESPOND_NO = 'No';
    public static final String AMOUNT = 'AMOUNT';
    public static final String MARKET_VALUE = 'MARKET_VALUE';
    public static final String SECURITY_YES = 'Yes';
    public static final String SECURITY_NO = 'No';
    
    //Error Msg For LOS Batch
    public static final String ERROR_LEAD_OBJECT_IS_EMPTY = 'Lead details Object is Empty ::';
    public static final String ERROR_TRACKER_OBJECT_IS_EMPTY = 'Tracker details Object is Empty ::';
    public static final String ERROR_TRACKER_OBJECT_IS_VALUE_EMPTY = 'In the Tracker details object Lead__c or ApiName__c is Empty ';
    public static final String ERROR_OPPORTUNATY_OBJECT_IS_EMPTY = 'Opportunity object details is Empty for the lead id is :: ';
    public static final String ERROR_TRACKER_OBJECT_STATUS = 'TrackMaster status is not success for all the API for the lead id Is :: ';
    public static final String ERROR_COAPPLICANT_OBJECT_IS_EMPTY = 'Co_Applicant__c object details is empty for the lead id Is :: ';
    public static final String ERROR_LOS_API_MASTER_OBJECT_IS_EMPTY = 'LosApiMaster__c object details is empty, Please cross check the APi details. ';
    public static final String ERROR_OPPORTUNATY_OBJECT_IS_EMPTY1 = 'Opportunity object details is Empty ';
    
    //LOS Debugs
    public static final String LOS_SCHEDULE = 'LOS Api scheduled successfully for lead id:';
    public static final String LOS_SCHEDULE_FAILS = 'LOS Api schedules failed for lead id:'; 
    public static final String LOS_CREATE = 'LOS scheduler for Create WI API Calling at ';
    public static final String LOS_SCHEDULE_NAME = 'LOS - ';
    public static final String DATA_TRANSER_NAME = 'Data Transfer API for ';
    public static final String DATA_TRANSER_FOR_FAILED = 'Data Transfer API';
    public static final String WORK_ITEM_FAILED = 'Create work item api has failed';
    public static final String LEADS_TRACKER_EMPTY = 'Lead did not added because of success API count is ::';
    public static final String LOS_SYNC = 'LOS already synced for LeadId- ';
    public static final String OPP_EMPTY = 'Opportunity object is empty ';
    public static final String LEAD_EMPTY = 'Final LeadIds for Data transfer is empty !!!....';
    
    //DMS Integration Constants
    public static final String DMS_FAIL = 'Failure';
    public static final String DMS_SUCCESS = 'Success';
    public static final Integer DMS_SUCCESS_CODE = 101;
    public static final Integer DMS_FAILURE_CODE = 102;
    public static final String DOCUMENT_ID = 'ContentDocumentId';
    
    //DMS request parameters
    public static final String DMS_FOLDER_INDEX = 'folderIndex';
    public static final String DOCUMENT_NAME = 'documentName';
    public static final String COMMENT = 'Comment';
    public static final String CREATED_BY = 'createdByAppName';
    public static final String FILE_NAME = 'file';
    public static final String DMS_SCHEDULE_NAME = 'DMS -';
    public static final String DMS = 'DMS - ';
    
    //DMS Exceptions
    public static final String DMS_DOCUMENT_EXCEPTION = 'Exception while getting documents ::';
    
    //PennyDrop Email variables
    public static final String API_NAMES = '{!ApiName}';
    public static final String ERROR_LOG_LINKS = '{!ErrorLogLink}';
}