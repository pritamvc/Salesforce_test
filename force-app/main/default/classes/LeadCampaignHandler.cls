/*********************************************************************************************
* @author          Dhanaji Patil
* @description     This LeadCampaignHandler class is written for assign campaigns to lead depend upon the campaign logical conditions
* @date            21 April 2023  
* @Request:        Lead List
* @return          void
**********************************************************************************************/

public class LeadCampaignHandler {
    
    public static String operatorExpression = '[&|]{2}|&&|\\|\\||[=!><]=|[=!<>]';
    Public static void campaignAssignmentOnLead(List<Lead> leadListFromtrigger) {
        try {
            String leadQuery = System.Label.Get_Lead_Details_For_Campaign_Logic+' where id in :leadListFromtrigger';
            List<Lead> leadList = Database.query(leadQuery);
            
            /********* Collect Parent and child Campiagn list **********************/
            Campaign[] parentCampaignList = [SELECT Id,Name,Campaign_logic__c,ParentId, Parent.Name,Priority__c,IsActive  from Campaign where ParentId = null AND IsActive = true AND Campaign_logic__c != null order by Priority__c asc];
            Campaign[] childCampaignList = [SELECT Id,Name,Campaign_logic__c,ParentId, Parent.Name,Priority__c,IsActive  from Campaign  where ParentId != null AND IsActive = true AND Campaign_logic__c != null order by Priority__c desc];
            
            /********* Create Map Of Parent campaign Id vs Logical Condition **********************/
            Map<String,String> mapOfParentCampIdAndLogicCondition = new Map<String,String>();
            Map<String,String> mapOfParentCampNameAndLogicCondition = new Map<String,String>();
            for(Campaign parentCampObject : parentCampaignList){
                mapOfParentCampIdAndLogicCondition.put(parentCampObject.id,parentCampObject.Campaign_logic__c);
                mapOfParentCampNameAndLogicCondition.put(parentCampObject.name, parentCampObject.Campaign_logic__c);
            }
            
            /********* collect Map Of Parent campaign Id vs Child Campaign List **********************/
            Map<String,List<Campaign>> mapOfParentCampIdAndChildCampList = getmapOfParentCampIdAndChildCampList(childCampaignList);
            
            /***************************** set campaign name to lead depend upoun campaign logical conditioon ********************************/
            setCampMember(mapOfParentCampIdAndLogicCondition, mapOfParentCampIdAndChildCampList, leadList, leadListFromtrigger, mapOfParentCampNameAndLogicCondition);
            
        } catch(Exception e) {
            System.debug('Exception:'+e.getMessage());
            System.debug('At:'+e.getLineNumber());
            e.getMessage();
            /*for(Lead leadObject : leadListFromtrigger) {
leadObject.addError(e.getMessage());
} */
        }
    }
    
    /***************************** set campaign name to lead depend upoun campaign logical conditioon ********************************/
    Public static void setCampMember(Map<String,String> mapOfParentCampIdAndLogicCondition,Map<String,List<Campaign>> mapOfParentCampIdAndChildCampList,List<Lead> leadList, List<Lead> leadListFromtrigger,Map<String,String> mapOfParentCampNameAndLogicCondition) {
        
        if(null != leadList && leadList.size() < 10){
            
            List<CampaignMember> campaignMemberList = new List<CampaignMember>();
            Map<String,Lead> parentCampVsLead = new Map<String,Lead>();
            System.debug('Size od map:'+mapOfParentCampIdAndLogicCondition);
            System.debug('Size od map:'+mapOfParentCampIdAndLogicCondition.size());
            if(!mapOfParentCampIdAndLogicCondition.IsEmpty() && mapOfParentCampIdAndLogicCondition.size() >0) {
                SYstem.debug('Lead:'+leadList);
                if(null != leadList && leadList.size()>0){
                    For(Lead leadObject : leadList) {
                        try{
                            
                                campaignMemberList = assignCampaignMemberTolead(leadObject, campaignMemberList, mapOfParentCampIdAndLogicCondition, mapOfParentCampIdAndChildCampList, leadListFromtrigger, mapOfParentCampNameAndLogicCondition);
                            
                            System.debug('Cam list: '+campaignMemberList);
                            System.debug('Cam list: '+campaignMemberList.size());
                        } catch(DmlException e) {
                            e.getCause();
                        }
                    }
                } 
            }
            
            if(campaignMemberList.size() > 0) {
                campaignAssignmentAndOzontelInteraction(campaignMemberList);
            }
        }else{
            Database.executeBatch(new BatchForAssignCampaignToLead(mapOfParentCampIdAndLogicCondition, mapOfParentCampIdAndChildCampList, leadList, leadListFromtrigger, mapOfParentCampNameAndLogicCondition),200);
        }
    }
    
    /***************************** This method is used to iterate the lead list and assign to child campaign to the lead********************************/
    Public static List<CampaignMember> assignCampaignMemberTolead(Lead leadObject, List<CampaignMember> campaignMemberList, Map<String,String> mapOfParentCampIdAndLogicCondition,Map<String,List<Campaign>> mapOfParentCampIdAndChildCampList, List<Lead> leadListFromtrigger,Map<String,String> mapOfParentCampNameAndLogicCondition) {
        try{
            Map<String, Object> leadMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(leadObject));
            for (String parentCampLogicalCodition : mapOfParentCampIdAndLogicCondition.values()) {
                String finalParentCondition = parentCampLogicalCodition;
                Integer parentConditionMaxSpaces = spaceChecking(finalParentCondition);                        
                finalParentCondition = createFinalLogicalCondition(parentCampLogicalCodition, leadMap, leadObject);
                System.debug('condition check:'+checkingConditionWithRTExpression(finalParentCondition));
                /**************************** checking RTExpression ********************************************************************/
                if(checkingConditionWithRTExpression(finalParentCondition) == 1)
                {
                    campaignMemberList = createCampaignMemberForUpload(mapOfParentCampIdAndLogicCondition, parentCampLogicalCodition, mapOfParentCampIdAndChildCampList, leadListFromtrigger, leadMap, leadObject, finalParentCondition, campaignMemberList);
                    break; 
                }
                else{
                    continue;
                }  
            }
        } catch(DmlException e) {
            e.getCause();
        }
        return campaignMemberList;
    }
    
    /*****************************Collecting the child campaign list from parent campaign ID********************************/
    Public static List<CampaignMember> createCampaignMemberForUpload(Map<String,String> mapOfParentCampIdAndLogicCondition,String parentCampLogicalCodition, Map<String,List<Campaign>> mapOfParentCampIdAndChildCampList,List<Lead> leadListFromtrigger,Map<String, Object> leadMap,Lead leadObject,String finalParentCondition,List<CampaignMember> campaignMemberList) {
        String parentCampId = getParentCampaignId(mapOfParentCampIdAndLogicCondition, parentCampLogicalCodition);
        if(mapOfParentCampIdAndChildCampList.containsKey(parentCampId)){
            campaignMemberList = collectFinalCampaignMemberList(parentCampId, mapOfParentCampIdAndChildCampList, leadListFromtrigger, leadMap, leadObject, campaignMemberList);   
        }
        return campaignMemberList;
    }
    
    /*************************** collect the campaign Member List *************************************/
    Public static List<CampaignMember> collectFinalCampaignMemberList(String parentCampId, Map<String,List<Campaign>> mapOfParentCampIdAndChildCampList, List<Lead> leadListFromtrigger,Map<String, Object> leadMap,Lead leadObject,List<CampaignMember> campaignMemberList) {
        List<Campaign> childCampList = mapOfParentCampIdAndChildCampList.get(parentCampId);
        System.debug('parentcampId:'+parentCampId);
        SYstem.debug('child data :'+childCampList);
        Boolean childampMapFlag = false;
        for(Campaign childCampObj : childCampList){
            String childCampCondition = childCampObj.Campaign_logic__c;
            //childCampCondition = assigneCampMemberToLead(childCampCondition, leadMap, leadObject);
            childCampCondition = createFinalLogicalCondition(childCampCondition, leadMap, leadObject);
            System.debug('Data to check :'+childCampCondition);
            /***************************** here condition matched then assign campaign to lead and break the loop ********************************/
            if(checkingConditionWithRTExpression(childCampCondition) == 1) {
                campaignMemberList = assignCampaignMembers(campaignMemberList, leadObject, childCampObj);
                childampMapFlag = true;
                break;
            }
            else{
                continue;
            }
        } if(!childampMapFlag){
            for(Campaign childCampObj : childCampList){
                if(childCampObj.Name== System.Label.Campaign_Name_Other ){
                    campaignMemberList = assignCampaignMembers(campaignMemberList, leadObject, childCampObj);
                }
            }
        }
        return campaignMemberList;
    }
    
    /*************************** collect parent campaign id from map *************************************/
    Public static String getParentCampaignId(Map<String,String> mapOfParentCampIdAndLogicCondition, String parentCampLogicalCodition) {
        String parentCampId = '';
        for (String key : mapOfParentCampIdAndLogicCondition.keySet()) {
            if (mapOfParentCampIdAndLogicCondition.get(key) == parentCampLogicalCodition) {
                parentCampId = key;
                break;
            }
        }
        return parentCampId;
    }
    
    /*************************** Create a campaign member object and add in list *************************************/
    Public static List<CampaignMember> assignCampaignMembers(List<CampaignMember> campaignMemberList, Lead leadObject,Campaign childCampObj) {
        CampaignMember cm= New CampaignMember(
            CampaignId = childCampObj.id,
            LeadId = leadObject.Id,
            Status = System.Label.Campaign_Member_Status_Sent);
        campaignMemberList.add(cm);
        return campaignMemberList;
    }
    
    /************* Create a final logical condition for Rt expression check ***************************/
    Public static String createFinalLogicalCondition(String campLogicalCodition,Map<String, Object> leadMap,Lead leadObject) {
        
        String conditionWithReplaceOperatior = campLogicalCodition.replaceAll(operatorExpression, ',').trim();
        List<string> conditionLogicalList = conditionWithReplaceOperatior.split(',');
        
        /*********************** collect field Value and replace it in logical condition **************************/
        String finalUpdatedCondition = collectFieldValue(conditionLogicalList,campLogicalCodition,leadMap,leadObject);
        
        /***************************** To append double quotes before and after each word in the string ********************************/
        finalUpdatedCondition =  addDoubleQuateToText(finalUpdatedCondition);
        System.debug('Data to check in final method: '+finalUpdatedCondition);
        return finalUpdatedCondition;
    }
    
    /************* Set a extra space parent campaign error with campaign name to retuen ***************************/
    /* Public static void setErrorWithCampName(Map<String,String> mapOfParentCampNameAndLogicCondition, List<Lead> leadListFromtrigger, String parentCampLogicalCodition) {
String parentCampName = '';
for (String key : mapOfParentCampNameAndLogicCondition.keySet()) {
if (mapOfParentCampNameAndLogicCondition.get(key) == parentCampLogicalCodition) {
parentCampName = key;
break;
}
}
leadListFromtrigger[0].addError(CommonConstant.ERROR_MSG_FOR_PARENT_CAMPAIGN+parentCampName);
}  */ //commented after discussion with Dhanaji on date 01/06/2023
    
    /************* Create Map Of Parent campaign Id vs Child Campaign List ***************************/
    Public static  Map<String,List<Campaign>> getmapOfParentCampIdAndChildCampList(Campaign[] childCampaignList) {
        Map<String,List<Campaign>> mapOfParentCampIdAndChildCampList = new Map<String,List<Campaign>>();
        if(null != childCampaignList && childCampaignList.size()>0){
            for(Campaign childCampObj : childCampaignList){
                if(mapOfParentCampIdAndChildCampList.containsKey(childCampObj.ParentId)){
                    List<Campaign> campainList = mapOfParentCampIdAndChildCampList.get(childCampObj.ParentId);
                    campainList.add(childCampObj);
                    mapOfParentCampIdAndChildCampList.put(childCampObj.ParentId, campainList);
                }else{
                    mapOfParentCampIdAndChildCampList.put(childCampObj.ParentId, new List<Campaign> {childCampObj});
                }
            }  
        }
        return mapOfParentCampIdAndChildCampList;
    }
    
    
    /************* checking space in logical condition ***************************/
    Public static Integer spaceChecking(String text) {
        Integer maxSpaces = 0;
        if(null != text && text != ''){
            String[] substrings = text.split(' ');
            Integer consecutiveSpaces = 0;
            for(Integer i = 0; i < substrings.size(); i++) {
                if(substrings[i] == '') {consecutiveSpaces++;} else {
                    maxSpaces = Math.max(maxSpaces, consecutiveSpaces);consecutiveSpaces = 0;
                }
            }
        }
        return maxSpaces;
    }
    
    /********************************** This method used for assign campaign when lead give the missed call ************************************/
    Public static void campaignAssignmentOnMissedCallDesposition(List<Lead> leadList) {
        
        set<id> leadIdSet = new set<id>();
        if(null != leadList && leadList.size()>0){
            for(Lead leadObject : leadList) {
                leadIdSet.add(leadObject.id);
            }
            List<CampaignMember> campaignMemberList = new List<CampaignMember>();
            if(null != leadIdSet) {
                /****************** collect campaign member list ********************************************/
                CampaignMember[] oldCampaignMemberList = [SELECT Id, LeadId, Name, CampaignId, Campaign.Name, Campaign.ParentId,Campaign.Parent.Name,Lead.MobilePhone from CampaignMember where Type ='Lead' AND LeadId in :leadIdSet order by CreatedDate desc];
                Campaign[] childCampaign = [SELECT Id, Name, ParentId, Parent.Name,Priority__c,IsActive  from Campaign  where ParentId != null AND name = :System.Label.Campaign_Name_Inbound_Missed_Call /*AND IsActive = true*/ order by Priority__c asc];
                if(null != oldCampaignMemberList && oldCampaignMemberList.size()>0 && null != childCampaign && childCampaign.size()>0){
                    for(CampaignMember leadCampMemberObj : oldCampaignMemberList) {
                        String parentCampId = leadCampMemberObj.Campaign.ParentId;
                        for(Campaign childCampObj : childCampaign){
                            if(childCampObj.ParentId == parentCampId){
                                CampaignMember cm= New CampaignMember(CampaignId = childCampObj.id,LeadId = leadCampMemberObj.LeadId,Status = System.Label.Campaign_Member_Status_Sent);
                                campaignMemberList.add(cm);
                                break;
                            }else{
                                continue;
                            }
                        }
                    }
                }
            }
            if(campaignMemberList.size() > 0) {
                campaignAssignmentAndOzontelInteraction(campaignMemberList);
            }
        }
    }
    
    /********************************** This method used for lead details Add/delete from CampaignMember and ozontel  ************************************/
    Public static void campaignAssignmentAndOzontelInteraction(List<CampaignMember> campaignMemberList) {
        try{
            
            List<CampaignMember> newCampaignMemberList = new List<CampaignMember>();
            Set<Id> setCampaignMember = new set<Id>();
            Set<Id> setLeadId = new Set<Id>();
            
            if(!campaignMemberList.IsEmpty() && campaignMemberList.size() > 0) {
                insert campaignMemberList ;
                newCampaignMemberList = [SELECT Id,Name,Campaign.Name,LeadId,CampaignId,Lead.MobilePhone,
                Lead.Call_Result__c,Is_Ozontel_Sync__c From CampaignMember where Id In : campaignMemberList
                ];
            }
            if(!newCampaignMemberList.IsEmpty() && newCampaignMemberList.size() > 0 ) {
                for(CampaignMember objectCampaignMember : newCampaignMemberList) {
                    setCampaignMember.add(objectCampaignMember.Id);
                    setLeadId.add(objectCampaignMember.LeadId);
                } 
                /*************** class to delete old campaign Member associated with same Lead *************/
                CampaignMemberHelper.OnLeadCreationDeleteOldCampMember(setCampaignMember,setLeadId);
            }
            
            if(setCampaignMember.size() < 10){
                BulkOzonetelAPI.pushDataToOzontel(setCampaignMember);
            }else if((!setCampaignMember.IsEmpty() && setCampaignMember.size() > 0 ) || Test.isRunningTest()){  
                /************ To call api from trigger(for calling future method)*******************/
                /*********** Here is to cretae a scheduler for lead details upload on ozonetel *****************************/
                integer cnt = 0;
                integer batchSize = 0;
                integer timeAdded = 1;
                Integer lstSize = newCampaignMemberList.size();
                List<CampaignMember> tempCampaignMemberList = new List<CampaignMember>();
                for(integer i=0; i<newCampaignMemberList.size(); i++) {
                    
                    tempCampaignMemberList.add(newCampaignMemberList[i]);
                    lstSize = lstSize-1;
                    cnt=cnt+1;        
                    if(cnt==190 || lstSize==0){                   
                        DateTime now  = DateTime.now();
                        DateTime nextRunTime = now.addMinutes(timeAdded);
                        timeAdded = timeAdded+1;
                        String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' +  
                            nextRunTime.month() + ' ? ' + nextRunTime.year();
                        SchedulerForPushLeadsToOzontel leadList = new SchedulerForPushLeadsToOzontel(tempCampaignMemberList);
                        System.schedule('PushToOzonetel_'+nextRunTime+'_'+newCampaignMemberList[i].Id, cronString , leadList);
                        cnt = 0;
                        tempCampaignMemberList.clear();
                    }   
                }
            }
        } catch(DmlException e) {
            e.getMessage();
        }
        
    }
    
    /***************************** To append double quotes before and after each word in the string ********************************/
    public static String addDoubleQuateToText(String inputText){
        List<String> operators = new List<String>{'=', '!=', '<', '<=', '>', '>=', '&&', '||'};
            String finalCondition = '';
        if(null != inputText && inputText != ''){
            List<String> words = inputText.split(' ');
            for(Integer i=0; i<words.size(); i++) {
                if(operators.contains(words[i])){
                    continue;
                }else{
                    if(!words[i].startsWith('(')) {
                        if(!words[i].endsWith(')')) {
                            words[i] = '"' + words[i] + '"';
                        }else{
                            words[i] = words[i].substring(0, words[i].length() - 1);
                            words[i] = '"' + words[i] + '")';
                        }
                    }
                    else{
                        words[i] = words[i].substring(1, words[i].length() - 1);
                        words[i] = '("' + words[i] + '"';
                    }
                }
            }
            finalCondition = String.join(words, ' ');
        }
        return finalCondition;
    }
    
    /***************************** Checking the RT_Expression ********************************/
    public static integer checkingConditionWithRTExpression(String inputRTExpressionForCheck){
        integer generatedExpressionFlag = 0;
        System.debug('exp check:'+inputRTExpressionForCheck);
        if(null != inputRTExpressionForCheck && inputRTExpressionForCheck != ''){
            System.debug('in if');
            try{
                RT_Expression expression = new RT_Expression('');
                expression = new RT_Expression(inputRTExpressionForCheck.toLowerCase());
                generatedExpressionFlag = integer.valueOf(expression.eval());
                
            } catch(Exception e) {
                e.getMessage();
            }
        }
        return generatedExpressionFlag;
    }
    
    /***************************** Checking the RT_Expression ********************************/
    public static String collectFieldValue(List<String> strListValues, String logicalCondition,Map<String, Object> leadMap,Lead leadObject){
        String finallogicalCondition = logicalCondition;
        
        if(null != strListValues && strListValues.size()>0){
            for(String varOfConditionLogic : strListValues){
                if(varOfConditionLogic.contains('__r')){
                    try{
                        String fieldValue = '';
                        String[] checkRelationField = varOfConditionLogic.split('\\.');
                        integer cnt = checkRelationField.size();
                        if(2 == cnt){
                            System.debug('checkRelationField[0:'+checkRelationField[0]);
                            String key = '';
                            if(checkRelationField[0].contains('(')){
                                key = checkRelationField[0].replaceAll('(','');
                            }else{
                                key = checkRelationField[0].trim();
                            }
                           // String key = checkRelationField[0].replaceAll('(','');
                            String value = checkRelationField[1].trim();
                            
                            fieldValue = String.valueOf(leadObject.getSobject(key.removeStart('(')) != null ? leadObject.getSobject(key).get(value.removeEnd(')')) : '');
                            System.debug('fieldValue:'+fieldValue);
                        } else if(3 == cnt){
                            String key = checkRelationField[0].trim();String value = checkRelationField[1].trim();String value1 = checkRelationField[2].trim();
                            
                            System.debug('key:'+key);
                            key = key.removeStart('(');value1 = value1.removeEnd(')');
                          //  fieldValue = String.valueOf(leadObject.getSobject(key) != null ? leadObject.getSobject(key).getSobject(value).get(value1) : '');
                            if(leadObject.getSobject(key) != null ){
                                if(leadObject.getSobject(key).getSobject(value) != null ){
                                    if(leadObject.getSobject(key).getSobject(value).get(value1) != null ){
                                        fieldValue =  String.valueOf(leadObject.getSobject(key).getSobject(value).get(value1));   
                                    }else{
                                        fieldValue ='';
                                    }    
                                }    
                            }
                            System.debug('fieldValue:'+fieldValue);
                        }
                        if(null != fieldValue && fieldValue != ''){
                            fieldValue = fieldValue.replace(' ', '~');
                            varOfConditionLogic = varOfConditionLogic.removeStart('(').removeEnd(')');
                            System.debug('val:'+varOfConditionLogic);
                            if(finallogicalCondition.contains(varOfConditionLogic)) {
                                finallogicalCondition = finallogicalCondition.replaceAll(varOfConditionLogic.trim(), fieldValue);
                            }
                        }
                        else{
                            continue;
                        }
                    } catch(DmlException e) {
                        e.getMessage();
                    }
                }
                else{
                    String fieldValue = String.valueOf(leadMap.get(varOfConditionLogic.trim()));
                    if(null != fieldValue && fieldValue != ''){
                        fieldValue = fieldValue.replace(' ', '~');
                        finallogicalCondition = finallogicalCondition.replaceAll(varOfConditionLogic.trim(), fieldValue);
                    }
                    else{
                        continue;
                    }
                }
            }   
        }
        return finallogicalCondition;
    }
}