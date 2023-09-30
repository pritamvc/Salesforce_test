/*
*
*Name  :  LeadDealCourseAndAcademics
*Author:  Sohail Solapure
*Date  :  14/09/2023
*Purpose  Loan Application form-Course and Education section get data, insert, delete and update data.
*
*/    

public class LeadDealCourseAndAcademics {     
    /********************************************************************************************************************************************
    * @author           Sohail Solapure
    * @description      Getting data from Institute
    * @param            instituteId used for pass Institute Id
    * @Arguments        instituteId 
    * @return           Institute Record
    * @date             14/09/2023  
    ********************************************************************************************************************************************/ 
    @AuraEnabled
    public static Institute__c getInstituteRecord(Id instituteId){        
        Institute__c instituteRecord = new  Institute__c();
        instituteRecord = [Select Id, Name, Address__c, City__c, State__c, Country__c, Tel__c, URL_Web__c,Pin_Code__c From Institute__c 
                           WHERE Id =: instituteId];
        return instituteRecord; 
    } 
    
    /********************************************************************************************************************************************
    * @author           Rohit Pardeshi
    * @description      Get instituteId record based on university         
    * @Arguments        universityId
    * @param            universityId used for pass University Id
    * @return           Institute Record List
    * @date             14/09/2023     
    ********************************************************************************************************************************************/     
    @AuraEnabled
    public static List<Institute__c> getInstituteFromUniversity(Id universityId){
        
        List<Institute__c> instituteRecordList = new List<Institute__c>();
        instituteRecordList = [Select Id, Name, University__c From Institute__c 
                               WHERE University__c =: universityId];
        if(instituteRecordList.size() == 1){
            return instituteRecordList;
        } else{
            return null;
        }        
    } 
    
    /********************************************************************************************************************************************
    * @author           Sohail Solapure
    * @description      Get universityId record based on university 
    * @Arguments        universityId
    * @param            universityId used for pass University Id
    * @return           University Record 
    * @date             14/09/2023     
    ********************************************************************************************************************************************/
    @AuraEnabled
    public static University__c getUniversityNameCourse(Id universityId){        
        University__c universityIdRecord = new  University__c();
        universityIdRecord = [Select Id, Name From University__c 
                              WHERE Id =: universityId];
        return universityIdRecord;        
    } 
    
    /********************************************************************************************************************************************
    * @author           Sohail Solapure
    * @description      Get courseNameId record based on courseNameId 
    * @Arguments        courseNameId
    * @param            courseNameId used for pass Course Id
    * @return           Course Record 
    * @date             14/09/2023    
    ********************************************************************************************************************************************/
    @AuraEnabled
    public static Course__c getCourseIdName(Id courseNameId){        
        Course__c courseIdNameRecord = new  Course__c();
        courseIdNameRecord = [Select Id, Name,Course_Name__c From Course__c 
                              WHERE Id =: courseNameId];
        return courseIdNameRecord;           
    } 
    
    /********************************************************************************************************************************************
    * @author           Sohail Solapure
    * @description      Get data from objects as Lead, Co-applicant, Account, Education. 
    * @Arguments        leadGetId
    * @param            leadGetId used for pass Lead Id
    * @return           Wrapper
    * @date             14/09/2023     
    ********************************************************************************************************************************************/
    @AuraEnabled
    public static WrapperClassLoanApplicationForm getWrapperClassCommFormList(String leadGetId) {    
        
        Opportunity lstLead;
        try{
            lstLead = [Select Id,Name,Country_of_Study__c,
                       Admission_Status__c,University__c,Course_Category__c,Course_Type__c,Course_Level__c,Course_Stream__c,Course_Name__c,
                       Course_Id__c,Course_Start_Date__c,Course_End_Date__c,Analytics_Score_Category__c,Analytics_Test_Score__c,Quantitative_Score__c,Verbal_Score__c,Language_Score_Category__c,
                       Language_Test_Score__c,Course_Duration_Months__c,Institute__c, Campus__c,Highest_Education_Qualification__c,Course_Sub_Stream__c, Intake_New__c From Opportunity Where Id =: leadGetId]; 
        }
        catch (Exception e) {
      		e.getCause(); 
        }
        
        Co_Applicant__c appliAcc;
        try{
            appliAcc = [SELECT Id, Name,Type__c,Account__r.Lead__c,Relation_with_applicant__c,Relationship_Proof__c,Applicant_Type__c,Account__c,Account__r.Name, 
                        Account__r.Gender__c,
                        Account__r.PAN_Number__c, Account__r.Aadhar_Number__c,Account__r.Driving_License_Number__c, Account__r.Voter_ID__c,
                        Account__r.Is_Income_Considered_Is_Financial__c, Account__r.Passport_Number__c, 
                        Account__r.Marital_Status__c, 
                        Account__r.Date_of_Birth__c FROM Co_Applicant__c WHERE Deal__c =: leadGetId
                        AND Type__c = 'Applicant' LIMIT 1];
        }
        catch (Exception e) {
            e.getCause();
        }
        
        List<Education_Details__c> appliEduDetails;
        try{
            appliEduDetails = [Select Id, Name,Lead__c,Education_Qualification__c,Year_Completed__c,Type_of_Score__c,
                               Percentage_Marks_CGPA__c, CGPA__c,School_College_University__c,Course_Start_Date__c,University_Name__c, Course_Name__c,Course_Stream__c
                               From Education_Details__c WHERE Account__c =:appliAcc.Account__c AND Deal__r.Id=:leadGetId];
        }
        catch (Exception e) {
            e.getCause();
        }
        
        List<Co_Applicant__c> coApplicantAcc;
        try{
            coApplicantAcc = [SELECT Id, Name,Type__c,Account__r.Lead__c,Relation_with_applicant__c,Relationship_Proof__c,Applicant_Type__c,Account__c,Account__r.Name, Account__r.Mobile_Number__c, 
                              Account__r.FirstName,Account__r.MiddleName, 
                              Account__r.LastName,Account__r.Gender__c, 
                              Account__r.PAN_Number__c, Account__r.Aadhar_Number__c,Account__r.Driving_License_Number__c, Account__r.Voter_ID__c,
                              Account__r.Is_Income_Considered_Is_Financial__c, 
                              
                              Account__r.Marital_Status__c, 
                              Account__r.Date_of_Birth__c FROM Co_Applicant__c WHERE Deal__c =:leadGetId 
                              AND Type__c =:CommonConstant.COAPPLICANT];
        }
        catch (Exception e) {
            e.getCause();
        }
        
        WrapperClassLoanApplicationForm wc = new WrapperClassLoanApplicationForm();
        if(lstLead != null){
            wc.leadRecords = lstLead;  
        }            
        if(appliAcc != null){
            wc.accRecords = appliAcc;
        }                    
        if(appliEduDetails != null){
            wc.appliEduDetailsRecord = appliEduDetails;
        }                       
        return wc;   
    } 
    
    /********************************************************************************************************************************************
    * @author           Sohail Solapure
    * @description      fetchEducation and delete data to the objects using wrapper class passed from LWC
    * @Arguments        wrapperLoanApplicationForm, leadGetId
    * @param            leadGetId used for pass Lead Id and wrapperLoanApplicationForm as wrapper passed from LWC
    * @return           fetchEducation
    * @date             20/06/2023     
    ********************************************************************************************************************************************/
    @AuraEnabled
    public static WrapperClassLoanApplicationForm createUpdateLeadWithRelatedInformation(String wrapperLoanApplicationForm, String leadGetId) {
        
        WrapperClassLoanApplicationForm fetchEducation = new WrapperClassLoanApplicationForm();
        //try {
        //Lead Update 
        WrapperClassLoanApplicationForm wrapperClassInstance = (WrapperClassLoanApplicationForm)json.deserialize(wrapperLoanApplicationForm,WrapperClassLoanApplicationForm.Class);      
        Opportunity leadRecord = (Opportunity)json.deserialize(wrapperClassInstance.leadSaveRec,Opportunity.Class);
        if(leadRecord != null){                
            update leadRecord;
        }    
        Account accountRecord = (Account)json.deserialize(wrapperClassInstance.appliAccSaveRec,Account.Class);
        if(wrapperClassInstance.appliEduDetailsSave != null){
            
            List<Education_Details__c> educationDetailList = (List<Education_Details__c>)json.deserialize(wrapperClassInstance.appliEduDetailsSave,List<Education_Details__c>.Class);
            List<Education_Details__c> deleteEdu = new List<Education_Details__c>();
            
            if(String.isNotBlank(wrapperClassInstance.removeEducationIds)){
                List<Id> eduIds = wrapperClassInstance.removeEducationIds.split(',');
                
                deleteEdu = [SELECT Id FROM Education_Details__c WHERE Id IN :eduIds];
            }
            List<Education_Details__c> listOfEduDetailsRec = new List<Education_Details__c>();               
            Opportunity opp = [SELECT Id,Lead__c from Opportunity where Id=:leadRecord.Id];
            for(Education_Details__c objEduDetails : educationDetailList){
                objEduDetails.Account__c = accountRecord.Id;
                objEduDetails.Deal__c = leadRecord.Id;
                objEduDetails.Lead__c = opp.Lead__c;
                listOfEduDetailsRec.add(objEduDetails);
            }
            if(!listOfEduDetailsRec.isEmpty()){                  
                upsert listOfEduDetailsRec;                         
            } 
            if(deleteEdu != null && !deleteEdu.isEmpty()){  
                delete deleteEdu;
            }               
        }     
        
        fetchEducation = getWrapperClassCommFormList(leadGetId);
        return fetchEducation;        
    }    
    
    /********************************************************************************************************************************************
    * @author           Sohail Solapure
    * @description      wrapper class
    * @Arguments        NA
    * @param            NA
    * @return           NA
    * @date             14/09/2023     
    ********************************************************************************************************************************************/
    public class WrapperClassLoanApplicationForm{
        /*
        * @author           Sohail Solapure
        * @description      leadRecords
        * @Arguments        NA
        * @param            NA
        * @return           NA
        * @date             14/09/2023     
        */ 
        @AuraEnabled
        public Opportunity leadRecords{get;set;} 
        /*
        * @author           Sohail Solapure
        * @description      leadSaveRec
        * @Arguments        NA
        * @param            NA
        * @return           NA
        * @date             14/09/2023     
        */
        @AuraEnabled
        public String leadSaveRec{get;set;}
        /*
        * @author           Sohail Solapure
        * @description      accRecords
        * @Arguments        NA
        * @param            NA
        * @return           NA
        * @date             14/09/2023    
        */ 
        @AuraEnabled
        public Co_Applicant__c accRecords{get;set;} 
        /*
        * @author           Sohail Solapure
        * @description      appliAccSaveRec
        * @Arguments        NA
        * @param            NA
        * @return           NA
        * @date             14/09/2023     
        */ 
        @AuraEnabled
        public String appliAccSaveRec{get;set;}   
        /*
        * @author           Sohail Solapure
        * @description      appliEduDetailsRecord
        * @Arguments        NA
        * @param            NA
        * @return           NA
        * @date             14/09/2023     
        */     
        @AuraEnabled
        public List<Education_Details__c> appliEduDetailsRecord{get;set;} 
        /*
        * @author           Sohail Solapure
        * @description      appliEduDetailsSave
        * @Arguments        NA
        * @param            NA
        * @return           NA
        * @date             14/09/2023     
        */   
        @AuraEnabled
        public String appliEduDetailsSave{get;set;}  
        /*
        * @author           Sohail Solapure
        * @description      removeEducationIds
        * @Arguments        NA
        * @param            NA
        * @return           NA
        * @date             14/09/2023     
        */  
        @AuraEnabled
        public String removeEducationIds{get;set;}
        /*
        * @author           Sohail Solapure
        * @description      errorMessage
        * @Arguments        NA
        * @param            NA
        * @return           NA
        * @date             14/09/2023     
        */ 
        @AuraEnabled
        public String errorMessage{get;set;}
    }  
    
    /********************************************************************************************************************************************
    * @author           Sohail Solapure
    * @description      Meta data for Language Score
    * @Arguments        wrapperLoanApplicationForm, leadGetId
    * @param            NA
    * @return           Meta data for Language Score
    * @date             14/09/2023     
    ********************************************************************************************************************************************/
    @AuraEnabled(cacheable=true )  
    public static List<Language_Score_Setting__mdt> fetchLanguageCategory() {
        return [SELECT Id, MasterLabel, Language_Category__c, Start_Range__c, End_Range__c FROM Language_Score_Setting__mdt];    
    }
    
    /********************************************************************************************************************************************
    * @author           Sohail Solapure
    * @description      Meta data for Analytics Score
    * @Arguments        wrapperLoanApplicationForm, leadGetId
    * @param            NA
    * @return           Meta data for Analytics Score
    * @date             14/09/2023     
    ********************************************************************************************************************************************/
    @AuraEnabled(cacheable=true)  
    public static List<Analytics_Score_Setting__mdt> fetchAnalyticalCategory() {
        return [SELECT Id, MasterLabel, Analytical_Category__c, Start_Range__c, End_Range__c FROM Analytics_Score_Setting__mdt];
    }
    
    /********************************************************************************************************************************************
    * @author           Sohail Solapure
    * @description      Meta data for Analytics Score for GRE
    * @Arguments        wrapperLoanApplicationForm, leadGetId
    * @param            NA
    * @return           Meta data for Analytics Score for GRE
    * @date             14/09/2023     
    ********************************************************************************************************************************************/
    @AuraEnabled(cacheable=true)  
    public static List < Analytical_Score_GRE_Setting__mdt > fetchAnalyticalCategoryGRE() {
        return [SELECT Id, MasterLabel, Analytical_Category_GRE__c, Start_Range__c, End_Range__c FROM Analytical_Score_GRE_Setting__mdt];  
    }   
    
    /********************************************************************************************************************************************
    * @author           Sohail Solapure
    * @description      Get lookup data of Institute and course
    * @Arguments        objectApiName, countryOfStudyLead, parentId, label
    * @param            objectApiName, countryOfStudyLead, parentId, label
    * @return           Return lookup data of Institute and course
    * @date             14/09/2023     
    ********************************************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Object> getLookupData(String objectApiName, String countryOfStudyLead,String parentId,String label) {
        
        List<Object> resultList = new List<Object>();
        if(label == 'Institute'){
            String instituteQuery = 'SELECT Id, Name, University__r.Country_Name__c FROM ' + objectApiName + ' WHERE University__r.Country_Name__c = \'' + countryOfStudyLead + '\'';
            List<sObject> instituteList = Database.query(instituteQuery );
            resultList.addAll(instituteList );
        }
        else if(label == 'Course'){
            String universityQuery = 'SELECT Id, Course_Name__c FROM ' + objectApiName + ' WHERE Institute__c= \'' + String.escapeSingleQuotes(parentId) + '\'';
            List<sObject> universityList = Database.query(universityQuery);
            resultList.addAll(universityList);
        }
        return resultList;
    }
    
    /********************************************************************************************************************************************
    * @author           Sohail Solapure
    * @description      Get instituteRecord using University id i.e parantId
    * @Arguments        parentId
    * @param            parentId
    * @return           Return instituteRecord using University id i.e parantId
    * @date             14/09/2023     
    ********************************************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getUniversityName(String parentId) {  
        Map<String,String> mapUniversityNameVsId = new Map<String,String>();
        Institute__c instituteRecord = [Select Id,Name,University__r.Name,University__r.Country_Name__c From Institute__c where Id =: parentId];
        mapUniversityNameVsId.put(instituteRecord.University__r.Name,instituteRecord.University__c);
        return mapUniversityNameVsId;
    }
}