/*********************************************************************************************
* @author          Thinqloud Solutions (Chandrakant More).
* @description     CommonConstant class us Used To store the Common constant used in across the Org.
* @date            06/02/2023.    
**********************************************************************************************/
public class CommonConstant {
    
    public static final String KARZA_API_KEY = '3CXmVz52L0erntMn';
    public static final String COAPPLICANT = 'CoApplicant';
    public static final String KARZAENDPOINT = 'https://auxapiuat.auxilo.com/';
    public static final String REQUEST_METHOD = 'POST';
    
    public static final String LOS_ADHAR_XML_OTP_API_NAME = 'Aadhaar Xml Otp';
    public static final String LOS_ADHAR_VERIFICATION_OTP_API_NAME = 'Aadhar Verification Otp';
    public static final String LOS_BANK_ACC_API_NAME = 'Bank Acc';
    public static final String LOS_DOWNLOAD_ADHAR_XML_API_NAME = 'Download Aadhar Xml';
    public static final String LOS_EMAIL_AUTH_OTP_API_NAME = 'Email Auth Otp';
    public static final String LOS_MOBILE_AUTH_OTP_API_NAME = 'Mobile Auth Otp';
    public static final String LOS_PAN_PROFILE_API_NAME = 'PanProfile';
    public static final String LOS_PASSPORT_VERIFICATION_API_NAME = 'Passport Verification';
    public static final String LOS_VERIFY_EMAIL_OTP_API_NAME = 'Verify Email Otp';
    public static final String LOS_VERIFY_MOBILR_OTP_API_NAME = 'Verify Mobile Otp';
    
    public static final String APPLICATION_JSON = 'application/json';
    public static final String APPLICATION_XML ='application/xml';
    /*remove*/public static final String TEXT_PLAIN ='text/plain';
    public static final String LEAD_FRESH = 'Fresh';
    public static final String LEAD_NEW = 'New';
    public static final String SALES_PROCESSING = 'Sales Processing';
    //start
    //LOS Integration constants
    public static final String REQUEST_TYPE_POST = 'POST'; 
    public static final String LOS_TOKEN = 'token';
    public static final String LOS_EXPIRY = 'expiry';
    public static final String LOS_ACCESS_TOKEN = 'access_token';
    public static final String LOS_EXPIRES_IN = 'expires_in';
    public static final String LOS_TOKEN_API_NAME = 'Get_Token';
    
    public static final String DATA_TRANSFER_API_NAME = 'dataTransfer';
    public static final String WORK_ITEM_API_NAME = 'createWorkitem';
    public static final String MOVABLE_API_NAME = 'movable';
    public static final String IMMOVABLE_API_NAME = 'immovable';  
    public static final String CUSTADDRESS_API_NAME = 'addressDetail';  
    public static final String EMPLOYMENTDETAILS_API_NAME = 'employment';
    
    public static final String LOS_SUCCESS = 'Success';
    public static final Integer LOS_SUCCESS_CODE = 101;
    public static final Integer LOS_FAILURE_CODE = 102;
    public static final String STATUS_SUCCESS = 'success';
    public static final Integer API_COUNT = 17;
    public static final String APPLICANT = 'Applicant';
    public static final Integer DATA_DELETE_BEFORE_DAYS = 30;
    public static final Integer FIVE_MIN_INTERVAL = 5;
    //0end
    
    public static final String ERROR_MSG_FOR_CAMPAIGN_LOGICAL_CONDITION = 'Please remove any extra space from the campaign logic condition';  
    public static final String ERROR_MSG_FOR_PARENT_CAMPAIGN = 'Please remove extra space from Parent campaign logical condition, Campaign Name is ';  
    public static final String ERROR_MSG_FOR_CHILD_CAMPAIGN = 'Please remove extra space from logical condition, The child campaign name is ';
    public static final String ERROR_MSG_FOR_CHILD_PARENT_CAMPAIGN = ' and parent campaign name is ';
    //start
    //Error Msg For LOS Batch
    public static final String ERROR_LEAD_OBJECT_IS_EMPTY = 'Lead details Object is Empty ::';
    public static final String ERROR_TRACKER_OBJECT_IS_EMPTY = 'Tracker details Object is Empty ::';
    public static final String ERROR_TRACKER_OBJECT_IS_VALUE_EMPTY = 'In the Tracker details object Lead__c or ApiName__c is Empty ';
    public static final String ERROR_OPPORTUNATY_OBJECT_IS_EMPTY = 'Opportunity object details is Empty for the lead id is :: ';
    public static final String ERROR_TRACKER_OBJECT_STATUS = 'TrackMaster status is not success for all the API for the lead id Is :: ';
    public static final String ERROR_COAPPLICANT_OBJECT_IS_EMPTY = 'Co_Applicant__c object details is empty for the lead id Is :: ';
    public static final String ERROR_LOS_API_MASTER_OBJECT_IS_EMPTY = 'LosApiMaster__c object details is empty, Please cross check the APi details. ';
    public static final String ERROR_OPPORTUNATY_OBJECT_IS_EMPTY1 = 'Opportunity object details is Empty ';
    //end
    public static final String SUCCESS = 'Success';
    public static final String SUCCESS_CODE = '200';
    public static final String OK = 'Ok';
    public static final String SUCCESS_RESON_TEXT = 'Call data logged successfully..';
    public static final String FAIL = 'Fail';
    public static final String FAIL_CODE = '400';
    public static final String BAD_REQUEST = 'Bad Request';
    
    public static final String API_TYPE_GET = 'GET';
    public static final String API_TYPE_POST = 'POST';
    public static final integer API_TIMEOUT_IN_MILISECOND = 120000;
    
    //Common Constants For Ozontel 
    public static final String PARAM_DATA = 'data'; 
    public static final String PROGRESSIVE_DAIALING = 'Progressive Dialing';
    public static final String PROGRESSIVE = 'Progressive';
    public static final String INBOUND = 'InBound';
    public static final String COMPLETED = 'Completed';
    public static final String CALLBACKAPI = 'CallBackAPI';
    
    public static final String PUSH_TO_OZONTEL = 'Push To Ozontel';
    public static final String DELETE_FROM_OZONTEL = 'Delete From Ozontel';
    public static final String SCHEDULE_CALL_DETAILS = 'Schedule Call details';
    public static final String BULK_DELETE_FROM_OZONTEL = 'Bulk Delete From Ozontel';
    public static final String INBOUND_MISSED_CALL_DESPOSITION = 'Inbound Missed Call';
    public static final String IVR = 'IVR';
    public static final String USER_DESCONNECT_AGENT_STATUS = 'user_disconnected';
    
    public static final String PROVOID_CAMPAIGN_NAME = 'Campaign name should not be empty. Please provoid campaign name!!';
    public static final String PROVOID_PHONE_NUMBER = 'Phone Number should not be empty. Please provoid Phone Number!!';
    public static final String PROVOID_SCHEDULE_TIME = 'Schedule time should not be empty. Please provoid Schedule time!!';
    
    //Partner api constants
    public static final String STATUS_NOT_AVAILABLE = 'Status not available';
    public static final String FAILURE = 'FAILURE';
    public static final String FIRST_NAME_ERROR = 'First Name should not be blank';
    public static final String LAST_NAME_ERROR = 'Last Name should not be blank';
    public static final String EMAIL_ERROR = 'Email id should be valid';
    public static final String EMAIL_BLANK = 'Email should not be blank';
    public static final String MOBILE_ERROR = 'Mobile no should be valid';
    public static final String MOBILE_BLANK = 'Mobile should not be blank';
    public static final String PARTNER_ID_ERROR = 'Partner Id should not be blank';
    public static final String INVALID_USERNAME = 'Invalid UserName';
    public static final String INVALID_PARTNER_ID = 'Invalid Partner Id';
    public static final String INVALID_SOURCE_ID = 'Invalid Source Id';
    public static final String UNIQUE_ID_BLANK = 'Please send the unique Id';
    public static final String UNMANAGED_FIELD_ERROR = ': Please provide correct / valid fields.';
    
    public static final String SUCCESS_PARTNER = 'SUCCESS';
    public static final String OPEN = 'Open';
    public static final String LEAD_CREATED = 'Lead Created Successfully';
    public static final String LEAD_DUPLICATE = 'Your request has been acknowledged';
    
    
    // REGULAR EXPRESSIONS
    public static final String EMAIL_REGEX = '^\\w+([\\.-]?\\w+)*@\\w+([\\.-]?\\w+)*(\\.\\w{2,3})+$';
    public static final String MOBILE_REGEX = '^[0-9]{10}';
    
    //LOS constants
    public static final String LOS_OPTION = 'WFUploadWorkItem';
    public static final String AUTH_CODE = 'brpaLF1zkC4XRgyG+97Okg==';
    public static final String SEGMENT_CODE = '1';
    public static final String BRANCH_CODE = '1';
    
    //Duplicate Management Lead
    public static final String TASK_SUBJECT = 'Lead is showing interest again';
    public static final String LOST_STAGE = 'Lost';
    public static final String CONVERTED_STAGE = 'Converted';
    public static final String TASK_STATUS = 'Open';
    public static final String TASK_PRIORITY = 'Normal';
    public static final String TASK_PRIORITY_HIGH = 'High';
    public static final String FNAME_MOBILE_EMAIL_MATCH = 'First Name, Mobile & Email.';
    public static final String FNAME_MOBILE_MATCH = 'First Name & Mobile.';
    public static final String FNAME_EMAIL_MATCH = 'First Name & Email.';
    public static final String MOBILE_EMAIL_MATCH = 'Mobile & Email.';
    public static final String MOBILE_MATCH = 'Mobile Number.';
    public static final String EMAIL_MATCH = 'Email.';
    
    //Duplicate Management Account
    public static final String PAN_NUMBER_DUPLICATE = 'An account exists with the PAN Number';
    public static final String AADHAR_NUMBER_DUPLICATE = 'An account exists with the Aadhar Number';
    public static final String PASSPOST_NUMBER_DUPLICATE = 'An account exists with the Passport Number';
    public static final String DL_NUMBER_DUPLICATE = 'An account exists with the Driving licence Number';
    public static final String VOTER_ID_DUPLICATE = 'An account exists with the Voter Id';
    public static final String MANAGE_DEDUPE_DAYS = 'Manage Dedupe Days';//Custom setting
    
    //Bulk Upload Lead constants
    public static final String DUPLICATE_RECOED = 'Duplicate Record';
    public static final String INVALID_MOBILE_NUMBER = 'Invalid Mobile Number';
    public static final String INVALID_EMAIL = 'Invalid Email'; 
    public static final String INVALID_MOBILE_NUMBER_AND_EMAIL = 'Invalid Mobile Number And Email'; 
    public static final String BLANK_MOBILE_NUMBER = 'Mobile Number should not be blank.';
    public static final String BLANK_EMAIL = 'Email should not be blank.';
    public static final String BLANK_LAST_NAME = 'Last Name should not be blank.';
    // public static final String INVALID_LAST_NAME ='Invalid Last Name';
    // public static final String INVALID_FIRST_NAME ='Invalid First Name';
    public static final String INVALID_USER_NAME = 'Please make sure valid Salesforce user name in the CSV file'; 
    public static final String DUPLICATE_EMAIL_IN_CSV = 'Duplicate Email found inside csv';
    public static final String DUPLICATE_MOBILE_NUMBER_IN_CSV = 'Duplicate Mobile Number found inside csv.';
    
    public static final String ERROR_FILE_FORMATE_AND_NAME = 'ErrorsFile'+system.now()+'.csv';
    public static final String ERROR_FILE_NAME = 'Error File';
    public static final String ERROR_MESSAGE_FIELD_NAME_CSV = 'Error Message';
    public static final String BATCH_CALLED_FROM_BULK_UPLOADS_LEADS_MESSAGE = 'Attention: Processing Leads. The number of processing leads has exceeded 200, it will take a little time to complete the process.Unprocessed leads have been sent to you via email.';
    
    //OCR API
    public static final String DOCUMENT_TYPE_AADHAR = 'AADHAAR';
    public static final String DOCUMENT_TYPE_PAN = 'PAN';
    public static final String DOCUMENT_TYPE_PASSPORT = 'PASSPORT';
    public static final String DOCUMENT_TYPE_VOTER = 'VOTER';
    public static final String DOCUMENT_TYPE_DL = 'DL';
    public static final String ERROR_LOG_RECORD_TYPE = 'ContentDocumentId';
    public static final String ERROR_LOG_API_NAME = 'Karza KYC OCR API';
    public static final String PARAMETER_AADHAR = 'Aadhar Number';
    public static final String PARAMETER_PAN = 'PAN Number';
    public static final String PARAMETER_VOTER = 'Voter ID';
    public static final String PARAMETER_PASSPORT = 'Passport Number';
    public static final String PARAMETER_DL = 'Driving License Number';
    public static final String CV_DOCUMENT_TYPE_AADHAR = 'Aadhar Card';
    public static final String CV_DOCUMENT_TYPE_PAN = 'PAN Card';
    public static final String CV_DOCUMENT_TYPE_PASSPORT = 'Passport';
    public static final String CV_DOCUMENT_TYPE_VOTER = 'Voter Id';
    public static final String CV_DOCUMENT_TYPE_DL = 'Driving License';
    
    //Mobile and Email Verification
    public static final String ERROR_LOG_MOBILE = 'Mobile Verification';
    public static final String ERROR_LOG_EMAIL = 'Email Verification';
    public static final String API_NAME = 'Karza API';
    
    //TrackWizz Api 
    public static final String TRACKWIZZ_API = 'TrackWizz API';
    public static final String CV_TITLE = 'TrackWizz Screening Doc';
    public static final String CV_PATHONCLIENT = 'TrackWizz Screening Doc.pdf';
    public static final String CV_DOC_SUB_TYPE = 'Screening';
    public static final String APPLICANT_TRACK_RESULT_NOT_MATCH = 'Not Match';
    public static final String TRACK_WIZZ_RESULT_NOT_MATCH = 'Not_Match';
    public static final String TRACK_WIZZ_RESULT_MATCH = 'Match';
    public static final String TRACK_WIZZ_RESULT_ERROR = 'Error';
    public static final String TRACK_WIZZ_STATIC_RESOURCE = 'TrackWizzApi';
    public static final String TRACK_WIZZ_OPPId = '{!Opportunity.Id}';
    
    //Campaign Management
    public static final String ERROR_CONSTANT = 'The following exception has occurred: ';
    public static final String PRIORITY_DUPLICATE_PARENT_ERROR = 'Campaign parent priority must be unique.The following priority already exists on : ';
    public static final String PRIORITY_DUPLICATE_CHIELD_ERROR = 'Campaign Child priority must be unique.The following priority already exists on : ';
    
    //Lead Management (Applicant)
    public static final String FINANCIAL_CO_APPLICANT = 'FinancialCoApplicant';
    public static final String NON_FINANCIAL_CO_APPLICANT = 'NonFinancialCoApplicant';
    public static final Integer INT_VALUE_ZERO = 0;
    public static final Integer INT_VALUE_ONE = 1;
    
    //Lead Assignment
    public static final String CC_QUEUE = '%Call Center Exception Queue%';
    public static final String CALL_CENTER_QUEUE = '%Call Center%'; //Avadhut 04-07
    public static final String SALES_QUEUE = '%Sales Processing Exception Queue%';
    public static final String APPLYING_QUEUE = '%Applying Exception Queue%';
    public static final String ASM = ' ASM';
    public static final String CONTACT_CENTER = 'Contact Center';
    public static final String EXECEPTION_QUEUE = 'Exception Queue';
    public static final String QUEUE = 'Queue';
    public static final String LOGIN_DESK = 'Login Desk';
    public static final Integer MAX_VALUE = 999999999; 
    public static final String LEAD_ASSIGNMENT = 'Lead_Assignment';
    public static final String LEAD_ESCALATION = 'Lead_Escalation';
    public static final String APPLYING = 'Applying';
    public static final String USER_ROLE_ASM = 'ASM';
    public static final String LD = ' LD';
    public static final String QUEUE_LIKE = '%';
    public static final String SPACE = ' ';
    public static final String ASM_LIKE = '%ASM%';
    public static final String ASM_NAME = 'ASM%';
    public static final String LEAD_TASK_ASSIGN_TO_CC_QUEUE_EMAIL = 'Task_assigned_for_Status_Call_center_tri_party_to_CC_queue';
    public static final String LEAD_TRIPARTY_CALL_DONE_EMAIL_TO_SALES_USER = 'Task_assigned_for_Status_Tri_party_call_done_to_Lead_Owner_Sales';
    
    //Disposition Constants stages/Status
    public static final String LEAD_STATUS_FRESH = 'Fresh';
    public static final String LEAD_STATUS_NEW = 'New';
    public static final String LEAD_STATUS_ESCALATED = 'Escalated' ;
    public static final String LEAD_STATUS_SUSPRCT = 'Suspect';
    public static final String LEAD_STATUS_NOT_CONTACTED = 'Not Contacted';
    public static final String LEAD_STATUS_CONTACTED  = 'Contacted';
    public static final String LEAD_STATUS_SALES_PROCESSING  = 'Sales Processing';
    public static final String LEAD_STATUS_ACTIVE = 'Active';
    public static final String LEAD_STATUS_LOST = 'Lost';
    public static final String LEAD_STATUS_INERT = 'Inert' ;
    public static final String LEAD_STATUS_PROSPECT = 'Prospect' ;
    public static final String LEAD_STATUS_INACTIVE = 'Inactive';
    public static final String LEAD_STATUS_CALL_CENTER_TRIPARTY = 'Call centre triparty' ;
    public static final String LEAD_STATUS_CALL_CENTER_TEAM_PROFILE = 'Call Center Team';
    public static final String LEAD_STATUS_FUTURE_PROSPECT = 'Future Prospect' ;
    public static final String LEAD_STATUS_APPLYING = 'Applying' ;
    public static final String LEAD_STATUS_NOT_INTRESTED = 'Not Interested' ;
    public static final String LEAD_STATUS_NOT_DOABLE = 'Not Doable' ;
    public static final String LEAD_STATUS_QC_NEW = 'QC - New' ;
    public static final String LEAD_STATUS_QC_WIP = 'QC - WIP';
    public static final String LEAD_STATUS_QC_SALES_QUERY = 'QC - Sales Query' ;
    public static final String LEAD_STATUS_LOST_REASON_ERROR_ON_TASK = 'Please mention the lead Lost reason' ;
    public static final String LEAD_STATUS_INVALID = 'Invalid' ;
    public static final String LEAD_STATUS_DUPLICATE_LEADS = 'Duplicate Leads';
    public static final String LEAD_STATUS_CONVERTED = 'Converted' ;
    public static final String LEAD_STATUS_PUST_TO_LOS = 'Push to LOS' ;
    public static final String LEAD_REASON_INVALID_NUMBER ='Invalid Number';
    public static final String LEAD_REASON_WRONG_NUMBER = 'Wrong Number';
    //Disposition Constants Dispositions Names
    public static final String DISPOSITION_CALL_BACK = 'Call Back';
    public static final String DISPOSITION_CUSTOMER_DENIED_THE_LOAN = 'Customer Denied the Loan';
    public static final String DISPOSITION_CUSTOMER_DENIED_THE_LOAN_NOT_INTERESTED ='Customer Denied the Loan not interested';
    public static final String DISPOSITION_FUTURE_PROSPECT = 'Future Prospect';
    public static final String DISPOSITION_INVALID = 'Invalid';
    public static final String DISPOSITION_NOT_DOABLE_BY_AUXILO = 'Not Doable By Auxilo';
    public static final String DISPOSITION_PASSIVE_TRANSFER_TO_CEM = 'Passive Transfer to CEM';
    public static final String DISPOSITION_TRI_PARTY_CALL = 'Tri Party Call';
    public static final String DISPOSITION_WILLING_TO_APPLY = 'Willing To Apply';
    public static final String DISPOSITION_ACTIVE_TRANSFER_TO_CEM = 'Active Transfer to CEM';
    public static final String DISPOSITION_APPLICATION_FORMALITIES_COMPLETED = 'Application Formalities Completed';
    public static final String DISPOSITION_DUPLICATE_LEADS = 'Duplicate Lead';
    public static final String DISPOSITION_READY_TO_APPLY = 'Ready to Apply';
    public static final String DISPOSITION_CALL_DONE = 'Call Done';
    public static final String DISPOSITION_BAD_CALL = 'Bad Call';
    
    //Validation Errors
    public static final String ANALYTICS_TEST_SCORE = 'Please enter valid Analytics test score.'; 
    public static final String LANGUAGE_TEST_SCORE = 'Please enter valid Language test score.';
    public static final String UNIVERSITY_NAME ='Please enter University Name.';
    public static final String INSTITUTE_NAME ='Please enter Institute Name.';
    public static final String COURSE_NAME ='Please select course.';
    
    //For Collateral Type to check movable or immovable
    public static final String FIXED_DEPOSIT = 'Fixed Deposits';
    public static final String COMMERCIAL_PROPERTY = 'Commercial Property';
    public static final String RESIDENTIAL_PROPERTY = 'Residential Property';
    public static final String INSURANCE = 'Insurance';
    public static final String LAND_PLOT = 'Land Plot';
    /*remove*/public static final Boolean LOS_FAIL = false;
    
    //For campaign
    public static final String CALL_BACK_CAMPAIGN = 'Call_Back';
    public static final String OTHER_CAMPAIGN = 'Other';
    
    //For email alert 
    public static final String TASK_LEAD_OWNER = '{!leadOwner}';
    public static final String TASK_DATE_TIME = '{!dateTime}';
    public static final String TASK_CALLER_NUMBER = '{!number}';
    public static final String TASK_LINK = '{!taskLink}';
    
    // Deal Stage and status
    public static final String DATAENTERY = 'Data Entry';
    public static final String CREDIT_ASSESSMENT ='Credit Assessment';
    public static final String LOSTDEAL = 'Lost';
    public static final String CA_NEW ='New';
    public static final String WIP ='WIP';
    public static final String APPROVER = 'Approver';
    public static final String REJECTET_CA = 'Rejected at CA';
    public static final String REJECTET_CM = 'Rejected by CM';
    
    
    
    //Deal Assignment
    public static final String DATAENTERYQUEUE = 'Data Entry Queue';
    public static final String QUEUES = 'Queue';
    public static final String RM_LIKE = '%RM%';
    public static final String USER_ROLE_RM = ' CU RM';
    public static final String RM_NAME = ' CU RM%';
    public static final String CM_LIKE = '%CM';
    public static final String USER_ROLE_CM = ' CM';
    public static final String CM_NAME = ' CM%';
    public static final String DEAL_ASSIGNMENT_TEMPLATE = 'Deal_Assignment';
    public static final String DEAL_RE_APPEAL_TEMPLATE = 'Deal_Re_Appeal';
    public static final String DETAENTRY_MANAGER = 'Data Entry Manager';
    public static final String CREDIT_MANAGER = 'CC Manager';
    public static final String REFEREBACK = 'Refer back reason :';
    public static final String CA_APPROVERQUEUE = 'Credit Assessment Approver Queue';
    public static final String DEAL_APPROVAL_TEMPLATE = 'Credit_Assessment_Approver';
    public static final String REGULAR_GROUP = 'Regular';
    public static final String RCM_MANAGER_LIKE = 'RCM%';
    public static final String CC_BRANCH = 'CC ';
    public static final String CM_ROLE = 'CM ';
    
    /********************************************************************************************************
* @author          Chandrakant More
* @description     errorMessage this method used to display error message on UI by calling in BulkUploadLeadWithAccPartnerController
* @param totalLeads,duplicateLeads and insetedLeadsget list size to display on error screen. 
* @return          String of error message   
* @date            06/02/2023   
********************************************************************************************************/
    public static String errorMessage(Integer totalLeads,Integer duplicateLeads,Integer insetedLeads){
        string errorstring;
        if(totalLeads == duplicateLeads){
            errorstring = 'All the leads have error hence these are not inserted in the Salesforce system.'+'\n' +'Error has been emailed to you.';
        }
        if(insetedLeads > 0  && duplicateLeads > 0){
            errorstring = 'Out of '+totalLeads+' leads '+insetedLeads+' are inserted and '+duplicateLeads+ ' have error lead.';
        } 
        
        if(insetedLeads > 0  && duplicateLeads == 0){
            errorstring = 'All Leads are inserted successfully.';
        } 
        return errorstring ;
    }
    
}