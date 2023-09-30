/*****************************************************
* @author Dhanaji Patil
* @description This Class is used to collect callback api response and create task on related lead
* @Arguments  call details  
* @return responses
* @date 27/03/2023    
*****************************************************/

@RestResource(urlMapping='/callDetails')
global class BulkOzontelCallBack {
    /**
     * Author: Sohail Solapure
     * @description This method retrieves the response from Ozonetel after a callback.
     * 
     * This method is responsible for receiving and processing the response from Ozonetel
     * after a callback has been made. It expects a specific format of response and
     * processes it accordingly. There is no return value from this method.
     * 
     * @return No return value.
     * @param None.
     */
    @HttpPost
    global static ResponseWrapper getCallBackResponse() { 
        ResponseWrapper responseJSON = new ResponseWrapper();
        List<Lead> leadList = new List<Lead>();
        try{ 
            //Collect param data from request 
            String inputJsonData = RestContext.request.params.get(CommonConstant.PARAM_DATA);
            String jsonString = RestContext.request.requestBody.toString();  
            
            if(null != inputJsonData && inputJsonData != '') {
                OzontelCallDetailsParse callDetails = new OzontelCallDetailsParse();
                //Deserialize request data in temp object 
                callDetails = (OzontelCallDetailsParse)System.JSON.deserialize(inputJsonData, OzontelCallDetailsParse.class);
                System.debug('callDetails@@@'+callDetails);
                
                //If the Type is Progressive then need to create task on related lead separately
                if(((null != callDetails.Comments && !String.isEmpty(callDetails.Comments)) || (null != callDetails.Disposition && !String.isEmpty(callDetails.Disposition)))
                   && ( /*callDetails.Type.equalsIgnoreCase(CommonConstant.INBOUND) ||*/ callDetails.Type.equalsIgnoreCase(CommonConstant.PROGRESSIVE_DAIALING) || callDetails.Type.equalsIgnoreCase(CommonConstant.PROGRESSIVE))){
                       //List<Lead> leadObj = new List<Lead>();
                       try{
                           createNewTaskWithDesposition(callDetails);
                           responseJSON.statusCode = CommonConstant.SUCCESS_CODE;
                           responseJSON.status = CommonConstant.SUCCESS;
                           responseJSON.resonText =CommonConstant.SUCCESS_RESON_TEXT;
                       }
                       catch(Exception e){
                           if(leadList != null && leadList.size() > 0){
                               errorLog(leadList[0].id,CommonConstant.CALLBACKAPI,e.getMessage());
                           }else{
                               errorLog('',CommonConstant.CALLBACKAPI,e.getMessage());
                           }
                           e.getCause(); 
                       }  
                   }
                else if(String.isEmpty(callDetails.AgentID) && String.isEmpty(callDetails.AgentName) && String.isEmpty(callDetails.AgentPhoneNumber)/* && String.isEmpty(callDetails.DialStatus) */&& callDetails.Type.equalsIgnoreCase(CommonConstant.INBOUND)){
                    try{
                        createNewTaskWithDesposition(callDetails);
                        responseJSON.statusCode = CommonConstant.SUCCESS_CODE;
                        responseJSON.status = CommonConstant.SUCCESS;
                        responseJSON.resonText =CommonConstant.SUCCESS_RESON_TEXT;
                    }
                    catch(Exception e){
                        e.getCause();
                        if(leadList != null && leadList.size() > 0){
                            errorLog(leadList[0].id,CommonConstant.CALLBACKAPI,e.getMessage());
                        }else{
                            errorLog('',CommonConstant.CALLBACKAPI,e.getMessage());
                        }
                    }  
                }
                else{
                    responseJSON.statusCode = CommonConstant.FAIL_CODE;
                    responseJSON.status = CommonConstant.FAIL;
                    responseJSON.resonText =CommonConstant.BAD_REQUEST;
                    return responseJSON;
                }
            }
            else if(jsonString != null && jsonString != ''){
                OzontelCallDetailsParse callDetails = new OzontelCallDetailsParse();
                //Deserialize request data in temp object 
                callDetails = (OzontelCallDetailsParse)System.JSON.deserialize(jsonString, OzontelCallDetailsParse.class);
                System.debug('callDetails@@@'+callDetails);
                
                if(callDetails.Disconnectedtype == 'IVRHangup'){
                    try{
                        createNewTaskWithDesposition(callDetails);
                        responseJSON.statusCode = CommonConstant.SUCCESS_CODE;
                        responseJSON.status = CommonConstant.SUCCESS;
                        responseJSON.resonText =CommonConstant.SUCCESS_RESON_TEXT;
                    }
                    catch(Exception e){
                        if(leadList != null && leadList.size() > 0){
                            errorLog(leadList[0].id,CommonConstant.CALLBACKAPI,e.getMessage());
                        }else{
                            errorLog('',CommonConstant.CALLBACKAPI,e.getMessage());
                        }
                    }  
                }
                else{
                    responseJSON.statusCode = CommonConstant.FAIL_CODE;
                    responseJSON.status = CommonConstant.FAIL;
                    responseJSON.resonText =CommonConstant.BAD_REQUEST;
                    return responseJSON;
                }
            }
            else{
                responseJSON.statusCode = CommonConstant.FAIL_CODE;
                responseJSON.status = CommonConstant.FAIL;
                responseJSON.resonText =CommonConstant.BAD_REQUEST;
                return responseJSON;
            }   
        }catch(Exception e){
            e.getStackTraceString();
            responseJSON.resonText = e.getMessage();
            responseJSON.statusCode = CommonConstant.FAIL_CODE;
            responseJSON.status = CommonConstant.FAIL;
            if(leadList != null && leadList.size() > 0){
                errorLog(leadList[0].id,CommonConstant.CALLBACKAPI,e.getMessage());
            }else{
                errorLog('',CommonConstant.CALLBACKAPI,e.getMessage());
            }
            return responseJSON;
        } 
        
        return responseJSON;
    }
    
    /**
     * Author: Sohail Solapure
     * @description This method creates a new task with disposition information.
     * 
     * This method is responsible for creating a new task in your Salesforce organization
     * and associating it with the provided Ozonetel call details and disposition information.
     * The call details and disposition are expected to be provided as a parameter.
     * 
     * @param callDetails The call details and disposition information for the task.
     */
    public static void createNewTaskWithDesposition(OzontelCallDetailsParse callDetails){
        Boolean isLeadInsert = false;
        List<Lead> leadList = new List<Lead>();
        try{
            String mobileNo = getMobileNo(callDetails); 
            leadList = [select id,  FirstName from Lead where MobilePhone = :mobileNo and IsConverted= false order by CreatedDate desc];
            List<Task> checkingTask = new List<Task>();
            if(leadList != null && leadList.size()>0){
                //checkingOldDesposition(leadList ,callDetails);
                checkingTask = [select id,Caller_Id__c,UC_Id__c,Call_Result__c  from task where whoId = :leadList[0].id AND UC_Id__c = :callDetails.monitorUCID order by CreatedDate desc];
            }
            
            if(checkingTask.size() == 0) {
                //Set data to task Object 
                Task t = new Task();
                
                t.AgentPhoneNumber__c = callDetails.AgentPhoneNumber;
                t.agentId__c =callDetails.AgentID;
                t.agentNumber__c = callDetails.AgentPhoneNumber;
                t.agentStatus__c= callDetails.AgentStatus;
                t.Caller_Id__c = callDetails.CallerID;
                t.did__c = callDetails.Did;
                t.Location__c = callDetails.Location;
                t.Monitor_UCID__c = callDetails.monitorUCID;
                t.uui__c = callDetails.UUI;
                t.callStatus__c = callDetails.Status;
                t.DialStatus__c = callDetails.DialStatus;
                t.DialedNumber__c = callDetails.DialedNumber;
                t.ActivityDate = date.today();
                t.AudioFile__c = callDetails.AudioFile;
                t.Call_Result__c = callDetails.Disposition;
                t.Call_Type__c = callDetails.Type;
                t.campaignName__c = callDetails.CampaignName;
                t.customerStatus__c = callDetails.DialStatus;
                t.Description = callDetails.Comments;
                t.skillName__c = callDetails.Skill;
                t.UC_Id__c = callDetails.monitorUCID;
                t.CallDurationInSeconds = calculateDuration(callDetails.Duration);
                t.Status = CommonConstant.COMPLETED;
                t.Sales_Comment__c = CommonConstant.COMPLETED;
                t.callStartTime__c = (dateFormating(callDetails.StartTime));
                t.callEndTime__c = (dateFormating(callDetails.EndTime));
                t.Type = 'CC_Callback';
                
                //For progressive 
                if(null != callDetails.Comments && !String.isEmpty(callDetails.Comments)){
                    t.Subject = callDetails.Disposition+' - '+callDetails.Comments;
                }else{
                    t.Subject = callDetails.Disposition;
                }
                
                //For IVR
                if(String.isEmpty(callDetails.AgentID) && String.isEmpty(callDetails.AgentName) && String.isEmpty(callDetails.AgentPhoneNumber) /*&& String.isEmpty(callDetails.DialStatus) */&& callDetails.Type.equalsIgnoreCase(CommonConstant.INBOUND)){
                    t.Subject = CommonConstant.INBOUND_MISSED_CALL_DESPOSITION;
                    t.Call_Result__c = CommonConstant.INBOUND_MISSED_CALL_DESPOSITION;
                    t.Call_Type__c = CommonConstant.IVR;
                }
                
                //For to add task to related lead
                if(null != leadList && leadList.size()>0) {
                    t.WhoId = leadList[0].id;
                }
                else{
                    //Get the Inbound Source record
                    Source__c inboundSource = [SELECT Id from Source__c WHERE Name = 'Inbound' LIMIT 1];
                    
                    //Get the details of Call Center
                    Group callCenter = [SELECT Id,Name,(SELECT UserOrGroupId FROM GroupMembers) FROM Group WHERE Type =: System.Label.Group_Type AND Name =: System.Label.Call_Center_Queue LIMIT 1];
                    
                    //Create new Lead from Inbound Missed Call
                    Lead newLead = new Lead();
                    newLead.MobilePhone = t.Caller_Id__c.removeStart('0');
                    newLead.Email = t.Caller_Id__c.removeStart('0')+'@no-email.com';
                    newLead.Source_Category__c = 'Inbound';
                    newLead.Source_Name__c = inboundSource.Id;
                    newLead.LastName = 'Inbound';
                    newLead.KYC_Consent__c = true;
                    newLead.OwnerId = callCenter.Id;
                    newLead.Call_Result__c = CommonConstant.INBOUND_MISSED_CALL_DESPOSITION;
                    newLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(System.Label.Lead_B2C_Record_Type).getRecordTypeId();
                    newLead.Lead_Origin__c='Dialer';
                    insert newLead;
                    leadList.add(newLead);
                    //Attach task to new Created Lead
                    t.WhoId = newLead.Id;
                    isLeadInsert = true;
                }
                
                if(isLeadInsert == false){
                    insert t; 
                }
                else{
                    Integer delaySeconds = 15;
                    System.enqueueJob(new TaskScheduler(t, delaySeconds));
                }
            }
        }catch(Exception e){
            System.debug(e.getMessage());
        } 
        finally{  
            /******************************* save logs details in error log object *************************************/
            errorLog(leadList != null ?leadList[0].id:'',CommonConstant.CALLBACKAPI,String.valueOf(callDetails));
        }
    }
    
    /******************************* checking old deposition ************************************
public static Void checkingOldDesposition(List<Lead> leadList,OzontelCallDetailsParse callDetails){
if(leadList != null && leadList.size()>0) {
List<Task> getTask = [select id,Caller_Id__c,UC_Id__c,Call_Result__c  from task where whoId = :leadList[0].id and UC_Id__c = :callDetails.monitorUCID];
if(null != getTask && getTask.size()>0){
delete getTask;
}
}
}Commented by Sohail 1 Aug 23 not to delete task created from cti or callback class*/
    
    
    /**
     * Author: Sohail Solapure
     * @description This method converts a date from string format to a DateTime object.
     * 
     * This method is responsible for taking a date string as input and converting it into
     * a DateTime object. The formatted DateTime object is returned. Note that this method
     * does not modify the input string; it only returns the corresponding DateTime object.
     * 
     * @param convertDatetime The date string to be converted.
     * @return The formatted DateTime object.
     */
    public static DateTime dateFormating(String convertDatetime){
        DateTime finalConvertedDateTime;
        try{
            if(null != convertDatetime) {
                String recivedDateTime =  convertDatetime.remove('T');
                DateTime convertedGmtDateTime = DateTime.valueOfGMT(recivedDateTime);
                DateTime convertedDateTime = convertedGmtDateTime.addHours(-5);
                finalConvertedDateTime = convertedDateTime.addMinutes(-30);
            }
        }catch(Exception e){
            e.getCause();
        } 
        return finalConvertedDateTime;
    }
    
    /**
     * Author: Sohail Solapure
     * @description This method retrieves the mobile number from the provided Ozonetel call details.
     * 
     * This method is responsible for extracting the mobile number from the provided Ozonetel
     * call details and returning it as a string. The call details are expected to be provided
     * as a parameter.
     * 
     * @param callDetails The call details from which to extract the mobile number.
     * @return The mobile number as a string.
     */
    public static String getMobileNo(OzontelCallDetailsParse callDetails){
        String mobileNo = '';
        if(CommonConstant.INBOUND.equalsIgnoreCase(callDetails.Type) || callDetails.Type.equalsIgnoreCase(CommonConstant.PROGRESSIVE_DAIALING) || callDetails.Type.equalsIgnoreCase(CommonConstant.PROGRESSIVE)){
            mobileNo = callDetails.CallerID.removeStart('0');
        }else{
            if(null != callDetails.DialedNumber && !String.isEmpty(callDetails.DialedNumber)){
                mobileNo = callDetails.DialedNumber;
            }else{
                mobileNo = callDetails.CallerID;
            }
        }
        
        return mobileNo;
    }

    /**
     * Author: Sohail Solapure
     * @description This class is used for deserialization of a response.
     * 
     * This class defines the structure for deserializing a response from a certain source.
     * It is designed to match the structure of the response data for effective deserialization.
     */
    global class ResponseWrapper {
        
        //global String message {get;set;} 
        global String status {get;set;} 
        global String resonText {get;set;} 
        global String statusCode {get;set;} 
        
        
        //constructor
        global ResponseWrapper() {
            //this.message = '';
            this.status = '';
            this.resonText = '';
            this.statusCode = '';
        }
    }
    
    
    /**
     * Author: Dhanaji Patil
     * @description This class is used to deserialize a response object from Ozonetel.
     * 
     * This class defines the structure and methods for deserializing a response object
     * obtained from Ozonetel. It handles the deserialization process to convert the
     * response data into usable format.
     * 
     * @return The deserialized responses.
     * @param None.
     * @date 27/03/2023
     */
    public class OzontelCallDetailsParse {
        
        public String AgentPhoneNumber;
        public String CallerID;
        public String Disposition;
        public String CallerConfAudioFile;
        public String TransferredTo;
        public String Apikey;
        public String Did;
        public string StartTime;
        public String CallDuration;
        public string EndTime;
        public String ConfDuration;
        public String CustomerStatus;
        public String TimeToAnswer;
        public String monitorUCID;
        public String AgentID;
        public String AgentStatus;
        public String Location;
        public String FallBackRule;
        public String CampaignStatus;
        public String Duration;
        public String Status;
        public String AgentUniqueID;
        public String UserName;
        public String HangupBy;
        public String AudioFile;
        public String PhoneName;
        public String TransferType;
        public String DialStatus;
        public String CampaignName;
        public String UUI;
        public String AgentName;
        public String Skill;
        public String DialedNumber;
        public String Type;
        public String Comments;
        public String Disconnectedtype;
    }
    
    /**
     * Author: Dhanaji Patil
     * @description This method is used to format a date into the (DD/MM/YYYY) format.
     * 
     * This method takes a date as input and formats it into the DD/MM/YYYY format.
     * The formatted date is returned as a string.
     * 
     * @param dateToFormat The date to be formatted.
     * @return The formatted date as a string in the DD/MM/YYYY format.
     * @date 28/02/2023
     */
    public static String formatDate(Date d) {
        return d.day() + '/' + d.month() + '/' + d.year();
    }
    
    /**
     * Author: Dhanaji Patil
     * @description This method is used to calculate duration in seconds based on a provided duration string.
     * 
     * This method takes a duration string as input and calculates the equivalent duration in seconds.
     * The duration string should be in a recognizable format (e.g., "HH:mm:ss" or similar). The calculated
     * duration in seconds is returned.
     * 
     * @param duration The duration string to be converted and calculated.
     * @return The calculated duration in seconds.
     * @date 28/03/2023
     */
    public static Integer calculateDuration(String duration) {
        Integer finalDuration = 0;
        try{
            if(null != duration && !String.isEmpty(duration)) {
                
                //Splited the time duration in hr, min and sec
                string[] splitted = duration.split(':');
                String hr = splitted[0];
                String min = splitted[1];
                String sec = splitted[2];
                
                //Here calcutlate the total duration
                if(null != hr && !String.isEmpty(hr)) {
                    finalDuration = finalDuration + (integer.valueof(hr)*60*60);
                }
                if(null != min && !String.isEmpty(min)) {
                    finalDuration = finalDuration + (integer.valueof(min)*60);
                }
                if(null != sec && !String.isEmpty(sec)) {
                    finalDuration = finalDuration + (integer.valueof(sec));
                }
            }
        }catch(Exception e){
            e.getCause();
        } 
        
        return finalDuration;
    }
    
    
    /**
     * Author: Dhanaji Patil
     * @description This method is used to track the details of a callback API.
     * 
     * This method takes various parameters related to the callback event and logs
     * the details for tracking purposes. The parameters leadId, apiName, and request
     * are expected to be provided. No return value is expected from this method.
     * 
     * @param leadId The lead ID associated with the callback event.
     * @param apiName The name of the callback API.
     * @param request The details of the API request.
     * @date 28/03/2023
     */
    public static void errorLog(String leadId, String apiName, String request){
        
        if(null != leadId && null != apiName && null != request ) {
            try{
                Error_log__c errorLogObj = new Error_log__c();
                errorLogObj.Lead__c = leadId;
                errorLogObj.ApiName__c = apiName;
                errorLogObj.Request__c = request;
                errorLogObj.Status__c = CommonConstant.SUCCESS;
                errorLogObj.StatusCode__c =Integer.valueOf(CommonConstant.SUCCESS_CODE);
                
                insert errorLogObj;
                
            }catch(exception e){
                e.getStackTraceString();
            }  
        }      
    }       
}