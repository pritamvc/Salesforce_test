import { LightningElement, wire, api, track } from 'lwc';
import createUpdateLeadWithRelatedInformation from '@salesforce/apex/LeadCourseAndAcademics.createUpdateLeadWithRelatedInformation';
import getInstituteRecord from '@salesforce/apex/LeadCourseAndAcademics.getInstituteRecord';
import getCourseEducationaData from '@salesforce/apex/LeadCourseAndAcademics.getWrapperClassCommFormList';
import getCourseIdName from '@salesforce/apex/LeadCourseAndAcademics.getCourseIdName';
import fetchLanguageCategory from '@salesforce/apex/LeadCourseAndAcademics.fetchLanguageCategory';
import fetchAnalyticalCategory from '@salesforce/apex/LeadCourseAndAcademics.fetchAnalyticalCategory';
import fetchAnalyticalCategoryGRE from '@salesforce/apex/LeadCourseAndAcademics.fetchAnalyticalCategoryGRE';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import getUniversityName from '@salesforce/apex/LeadCourseAndAcademics.getUniversityName';
import getLookupData from '@salesforce/apex/LeadCourseAndAcademics.getLookupData';
import updateLeadTotalPercentage from '@salesforce/apex/DocumentVerification.updateLeadTotalPercentage';
import SUBMITACTION from '@salesforce/messageChannel/submit__c';
import progressBar from '@salesforce/messageChannel/progressBar__c';
import { publish, MessageContext } from 'lightning/messageService';
import getSectionWeightage from '@salesforce/apex/LoanApplicationFormHelper.getSectionWeightage';
import EDUCATION from '@salesforce/schema/Education_Details__c';
import TYPE_OF_SCORE from '@salesforce/schema/Education_Details__c.Type_of_Score__c';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import LEAD from '@salesforce/schema/Education_Details__c';
import HIGH_QUALIFICATION from '@salesforce/schema/Lead.Highest_Education_Qualification__c';

export default class LeadCourseAndAcademics extends LightningElement {
    @api getCourseData;
    @api leadRecordId;
    @wire(MessageContext)
    messageContext;
    message;
    @track todaysDate;
    @track getCoursePerc;
    @track listOfEducationalTable;
    @track isFieldDisabled = true;
    @api objectName = 'Lead';
    @api recordTypeId;

    //Course detail section
    @track courseStartDate;
    @track courseEndDate;
    @track universityName;
    @track courseCampus;
    @track courseTel;
    @track URLWeb;
    @track contPersonInstitute;
    @track contPersonNum;
    @track contPersonEmail;
    @track courseName;
    @track langTestScore;
    @track analyticalTestScore;
    @track quanTestScore;
    @track verbalTestScore;
    @track intake;
    //Country of Study from SFDC
    @track CountryOfStudy;
    @api CountryOfStudyField = 'Country_of_Study__c';
    @track CountryOfStudyLabel;
    @api CountryOfStudyValue;
    @track CountryOfStudyFieldOptions;
    apiCountryOfStudyObjFieldName;
    //Addmission Status from SFDC
    @track AdmissionStatus;
    @api AdmissionStatusField = 'Admission_Status__c';
    @track AdmissionStatusLabel;
    @api AdmissionStatusValue;
    @track AdmissionStatusOptions;
    apiAdmissionStatus;
    //Course Duration (Month) from SFDC
    @track CourseDurationValue;
    @api CourseDurationField = 'Course_Duration_Months__c';
    @track CourseDurationLabel;
    @track CourseDurationOptions;
    apiCourseDurationStatus;
    //Course Category from SFDC
    @track CourseCategory;
    @api CourseCategoryField = 'Course_Category__c';
    @track CourseCategoryLabel;
    @api CourseCategoryValue;
    @track CourseCategoryOptions;
    apiCourseCategory;
    //Course Type from SFDC
    @track CourseType;
    @api CourseTypeField = 'Course_Type__c';
    @track CourseTypeLabel;
    @api CourseTypeValue;
    @track CourseTypeOptions;
    apiCourseType;
    @track universityNameString
    //Course Level from SFDC
    @track CourseLevel;
    @api CourseLevelField = 'Course_Level__c';
    @track CourseLevelLabel;
    @api CourseLevelValue;
    @track CourseLevelOptions;
    apiCourseLevel;

    //Language Score Category from SFDC
    @track LangScoreCategory;
    @api LangScoreCategoryField = 'Language_Score_Category__c';
    @track LangScoreCategoryLabel;
    @api LangScoreCategoryValue;
    @track LangScoreCategoryOptions;
    @track ShowFieldsCourseUniversity = false;
    apiLangScoreCategory;
    //Analytics Score Category from SFDC
    @track AnalytScoreCategory;
    @api AnalytScoreCategoryField = 'Analytics_Score_Category__c';
    @track AnalytScoreCategoryLabel;
    @api AnalytScoreCategoryValue;
    @track AnalytScoreCategoryOptions;
    apiAnalytScoreCategory;
    //Intake on Course section from SFDC -Added by Avadhut -13-07-23
    @track Intake;
    @api IntakeField = 'Intake__c';
    @track IntakeLabel;
    @api IntakeValue;
    @track IntakeOptions;
    apiIntake;
    //Education Details from SFDC
    @api objectNameEduDetails = 'Education_Details__c';
    @api recordTypeId2;
    @track EducationDetails;
    @api EducationDetailsField = 'Education_Qualification__c';
    @track EducationDetailsLabel;
    @api EducationDetailsValue;
    @track EducationDetailsOptions;
    @track CourseStreamEduOptions;
    apiEducationDetails;

    @track YearCompleted;
    @track PercentageMarks;
    @track SchoolCollegeUniversity;

    //Institute creation on Lead lookup
    // @track selectedAccount; 
    //@track ApplicantPassportNumber = '';
    @track instituteResult;
    @track errors;
    @track instAdderess;
    @track instCity;
    @track instState;
    @track instCountry;
    @track instPINCode;
    @track InstituteId;
    @track isLoading = false;
    @track startDate = false;
    @track year10 = '';
    @track year12 = '';

    @track cgpaDisable = false;//^(?:[0-4](?:\.\d{1,2})?|5(?:\.0{1,2})?)$

    @track pattern5 = "^(?:[1-4](?:\.[0-9]{1,2})?|5(?:\.0{1,2})?)$"; //"^(5(\.([0-4][0-9]|50)?)?|[0-9](\.\d{1,2})?)$";/^(?:[1-4](?:\.[0-9])?|5(?:\.0)?)$/
    @track pattern10 = "^(?:[1-9](?:\.[0-9]{1,2})?|10(?:\.0{1,2})?)$";//^(10(\.([0-4][0-9]|50)?)?|[0-9](\.\d{1,2})?)$";
    @track patternValue;

    @track nextPage = false;
    //@track firstCheck = false;
    @track courseCheck = false;
    @track leadID;
connectedCallback() {     
        this.getCourseEducationaFunction();
        this.getLangScoreCategoryFunc();
        this.getanalyticalScoreCategoryFunc();
        this.getanalyticalScoreCategoryGREFunc();            
        this.todaysDate = new Date().toISOString().split('T')[0];
               
    }

    @wire(getObjectInfo, { objectApiName: '$objectName' })
    getObjectData1({ error, data }) {
        if (data) {
            if (this.recordTypeId == null)
                this.recordTypeId = data.defaultRecordTypeId;

            this.apiCountryOfStudyObjFieldName = this.objectName + '.' + this.CountryOfStudyField;
            this.CountryOfStudyLabel = data.fields[this.CountryOfStudyField].label;

            this.apiAdmissionStatus = this.objectName + '.' + this.AdmissionStatusField;
            this.AdmissionStatusLabel = data.fields[this.AdmissionStatusField].label;

            //Added By Rohit
            this.apiCourseDurationStatus = this.objectName + '.' + this.CourseDurationField;
            this.CourseDurationLabel = data.fields[this.CourseDurationField].label;

            this.apiCourseCategory = this.objectName + '.' + this.CourseCategoryField;
            this.CourseCategoryLabel = data.fields[this.CourseCategoryField].label;

            this.apiCourseType = this.objectName + '.' + this.CourseTypeField;
            this.CourseTypeLabel = data.fields[this.CourseTypeField].label;

            this.apiCourseLevel = this.objectName + '.' + this.CourseLevelField;
            this.CourseLevelLabel = data.fields[this.CourseLevelField].label;
            
            this.apiLangScoreCategory = this.objectName + '.' + this.LangScoreCategoryField;
            this.LangScoreCategoryLabel = data.fields[this.LangScoreCategoryField].label;

            this.apiAnalytScoreCategory = this.objectName + '.' + this.AnalytScoreCategoryField;
            this.AnalytScoreCategoryLabel = data.fields[this.AnalytScoreCategoryField].label;

            this.apiIntake = this.objectName + '.' + this.IntakeField;
            this.IntakeLabel = data.fields[this.IntakeField].label;
        } else if (error) {
            console.log(error);
        }
    }

    //Country of Study
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: '$apiCountryOfStudyObjFieldName' })
    getPicklistValues2({ error, data }) {
        if (data) {
            this.CountryOfStudyFieldOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };
            });
        } else if (error) {
            console.log(error);
        }
    }

    //Admission Status   
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: '$apiAdmissionStatus' })
    getPicklistValues3({ error, data }) {
        if (data) {
            this.AdmissionStatusOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };
            });
        } else if (error) {
            console.log(error);
        }
    }

    //Course Category   
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: '$apiCourseCategory' })
    getPicklistValues4({ error, data }) {
        if (data) {
            this.CourseCategoryOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };
            });
        } else if (error) {
            console.log(error);
        }
    }

    //Course Type   
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: '$apiCourseType' })
    getPicklistValues5({ error, data }) {
        if (data) {
            this.CourseTypeOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };
            });
        } else if (error) {
            console.log(error);
        }
    }

    //Course Level   
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: '$apiCourseLevel' })
    getPicklistValues6({ error, data }) {
        if (data) {
            this.CourseLevelOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };
            });
        } else if (error) {
            console.log(error);
        }
    }    

    //Language Score Category
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: '$apiLangScoreCategory' })
    getPicklistValues8({ error, data }) {
        if (data) {
            // Map picklist values
            this.LangScoreCategoryOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };
            });
        } else if (error) {
            console.log(error);
        }
    }

    //Analytics Score Category
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: '$apiAnalytScoreCategory' })
    getPicklistValues9({ error, data }) {
        if (data) {
            // Map picklist values
            this.AnalytScoreCategoryOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };
            });
        } else if (error) {
            console.log(error);
        }
    }
    //Intake -Added by Avadhut -13-07-23
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: '$apiIntake' })
    getPicklistValues101({ error, data }) {
        if (data) {
            // Map picklist values
            this.IntakeOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };
            });
        } else if (error) {
            console.log(error);
        }
    }

    //Added By Rohit
    //Admission Status   
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: '$apiCourseDurationStatus' })
    getPicklistValues10({ error, data }) {
        if (data) {
            this.CourseDurationOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };
            });
        } else if (error) {
            console.log(error);
        }
    }

    //Education Details Picklist field from SFDC
    @wire(getObjectInfo, { objectApiName: '$objectNameEduDetails' })
    getObjectData3({ error, data }) {
        if (data) {
            if (this.recordTypeId2 == null)
                this.recordTypeId2 = data.defaultRecordTypeId;
            //Education Details
            this.apiEducationDetails = this.objectNameEduDetails + '.' + this.EducationDetailsField;
            this.EducationDetailsLabel = data.fields[this.EducationDetailsField].label;
        } else if (error) {
            // Handle error
            console.log(error);
        }
    }
    //Education Details picklist
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId2', fieldApiName: '$apiEducationDetails' })
    getPicklistValues0001({ error, data }) {
        if (data) {
            // Map picklist values
            this.EducationDetailsOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };
            });
        } else if (error) {
            // Handle error
            console.log(error);
        }
    }
   
    @track courseSubStreamValues = [];
    @track courStreamValue = [];
    @track selectedCourSubStreamValue;
    @track picklistValuesObj = {};
    @track selectedCourStreamValue;

    @wire(getPicklistValuesByRecordType, { objectApiName: 'Lead', recordTypeId: '$recordTypeId' })
        newPicklistValues({ error, data }) {
            if (data) { 
                this.error = null;
                this.picklistValuesObj = data.picklistFieldValues;

                let courseSubStreamList = data.picklistFieldValues.Course_Sub_Stream__c.values;                

                let courseSubStreamValues = courseSubStreamList.map(item => ({
                    label: item.label,
                    value: item.value
                }));
                this.courseSubStreamValues = courseSubStreamValues;
                getCourseEducationaData({ leadGetId: this.leadRecordId })
            .then(result => {
                this.wrapperLoanApplicationFormResult = result;
                this.selectedCourSubStreamValue = this.wrapperLoanApplicationFormResult.leadRecords.Course_Sub_Stream__c;
                this.setcourestreamvalueCourseSec();
            })
            .catch(error => {
                console.log('Get Course error', JSON.stringify(error));
            }); 
            }
            else if (error) {
                this.error = JSON.stringify(error);
                console.log(JSON.stringify(error));
            }
        }

    @track endDateGreaterStart;
    @wire(getObjectInfo, { objectApiName: EDUCATION })
    objectInfo1;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo1.data.defaultRecordTypeId', fieldApiName: TYPE_OF_SCORE })
    TypeOfScoreOptions;

    @wire(getObjectInfo, { objectApiName: LEAD })
    LeadobjectInfo1;

    @wire(getPicklistValues, { recordTypeId: '$LeadobjectInfo1.data.defaultRecordTypeId', fieldApiName: HIGH_QUALIFICATION })
    HighQualificationOptions;

    dependentDisabled = true;
    showdependent = false;
    @track controllerFieldApiName = 'Education_Qualification__c';
    @track dependentFieldApiName = 'Course_Stream__c';

    @track controllerValue;
    @track dependentValue;

    @track controllingPicklist = [];
    dependentPicklist;
    @track finalDependentVal = [];

    @wire(getPicklistValuesByRecordType, { objectApiName: '$objectNameEduDetails', recordTypeId: '$objectInfo1.data.defaultRecordTypeId' })
    fetchPicklist({ error, data }) {

        if (data && data.picklistFieldValues) {
            data.picklistFieldValues[this.controllerFieldApiName].values.forEach(optionData => {
                this.controllingPicklist.push({ label: optionData.label, value: optionData.value });
            });

            this.dependentPicklist = data.picklistFieldValues[this.dependentFieldApiName];
            this.setcourestreamvalue();

        } else if (error) {
            console.log(error);
        }
    }

    //Method to show dependent picklist values on select of qualification
    fetchDependentValue(event) {
        var foundelement = this.listOfEducationalTable.find(ele => ele.Id == event.target.dataset.id);

        foundelement.dependentDisabled = true;
        foundelement.finalDependentVal = [];
        foundelement.showdependent = false;
        const selectedVal = event.target.value;
        foundelement.controllerValue = selectedVal;
        let controllerValues = this.dependentPicklist.controllerValues;
        this.dependentPicklist.values.forEach(depVal => {
            depVal.validFor.forEach(depKey => {
                if (depKey === controllerValues[selectedVal]) {
                    foundelement.dependentDisabled = false;
                    foundelement.showdependent = true;
                    foundelement.finalDependentVal.push({ label: depVal.label, value: depVal.value });
                }
            });
        });
    }

    //Method to show dependent picklist values on select of qualification
    fetchDependentValueOnLoad(element) {

        element.dependentDisabled = true;
        element.finalDependentVal = [];
        element.showdependent = false;
        const selectedVal = element.Education_Qualification__c;
        element.controllerValue = selectedVal;
        let controllerValues = this.dependentPicklist.controllerValues;
        this.dependentPicklist.values.forEach(depVal => {
            depVal.validFor.forEach(depKey => {
                if (depKey === controllerValues[selectedVal]) {
                    element.dependentDisabled = false;
                    element.showdependent = true;
                    element.finalDependentVal.push({ label: depVal.label, value: depVal.value });
                }
            });
        });
    }

    handleCourseSubStreamChange(event) {
            this.selectedCourSubStreamValue = event.target.value;            
            if (this.selectedCourSubStreamValue) {
                let data = this.picklistValuesObj;
                let totalCourseStreamValues = data.Course_Stream__c;
                let controllerValueIndex = totalCourseStreamValues.controllerValues[this.selectedCourSubStreamValue];

                let courseStreamPicklistValues = data.Course_Stream__c.values;

                let courseStreamPicklists = courseStreamPicklistValues
                    .filter(key => key.validFor.includes(controllerValueIndex))
                    .map(item => ({
                        label: item.label,
                        value: item.value
                    }));

                this.courStreamValue = courseStreamPicklists;
            }
        }

    handleCourseStreamChange(event) {
        this.selectedCourStreamValue = event.target.value;        
    }

    fetchCourseStreamValuesOnLoad(selectedCourSubStreamValue) {
        if (selectedCourSubStreamValue) {
            let data = this.picklistValuesObj;
            let totalCourseStreamValues = data.Course_Stream__c;
            let controllerValueIndex = totalCourseStreamValues.controllerValues[selectedCourSubStreamValue];
    
            let courseStreamPicklistValues = data.Course_Stream__c.values;
    
            let courseStreamPicklists = courseStreamPicklistValues
                .filter(key => key.validFor.includes(controllerValueIndex))
                .map(item => ({
                    label: item.label,
                    value: item.value
                }));
    
            this.courStreamValue = courseStreamPicklists;
        }
    }
    @track langCategoryMetaData;
    //Get Metadata Language Category 
    getLangScoreCategoryFunc() {
        fetchLanguageCategory({})
            .then(result => {
                this.langCategoryMetaData = result;
            })
            .catch(error => {
                console.log('fetchLanguageCategory error', error);
            });
    }

    @track analyticalCategoryMetaData;
    //Get Metadata Analytical Category 
    getanalyticalScoreCategoryFunc() {
        fetchAnalyticalCategory({})
            .then(result => {
                this.analyticalCategoryMetaData = result;
            })
            .catch(error => {
                console.log('fetchAnalyticalCategory error', error);
            });
    }

    @track analyticalCategoryMetaDataGRE;
    //Get Metadata Analytical Category 
    getanalyticalScoreCategoryGREFunc() {
        fetchAnalyticalCategoryGRE({})
            .then(result => {
                this.analyticalCategoryMetaDataGRE = result;
            })
            .catch(error => {
                console.log('fetchAnalyticalCategoryGRE error', error);
            });
    }

    //Get Course and education data
    getCourseEducationaFunction() {
        console.log('leadRecordId=== ',this.leadRecordId);
        getCourseEducationaData({ leadGetId: this.leadRecordId })
            .then(result => {
                this.wrapperLoanApplicationFormResult = result;
                //Lead 
                this.leadID = this.wrapperLoanApplicationFormResult.leadRecords.Id;

                this.CountryOfStudyValue = this.wrapperLoanApplicationFormResult.leadRecords.Country_of_Study__c;
                this.AdmissionStatus = this.wrapperLoanApplicationFormResult.leadRecords.Admission_Status__c;
                this.InstituteId = this.wrapperLoanApplicationFormResult.leadRecords.Institute_Name__c;
                this.universityName = this.wrapperLoanApplicationFormResult.leadRecords.University_Name__c;
                this.courseCampus = this.wrapperLoanApplicationFormResult.leadRecords.Campus__c;
                this.CourseCategoryValue = this.wrapperLoanApplicationFormResult.leadRecords.Course_Category__c;
                this.CourseTypeValue = this.wrapperLoanApplicationFormResult.leadRecords.Course_Type__c;
                this.CourseLevelValue = this.wrapperLoanApplicationFormResult.leadRecords.Course_Level__c;
                this.selectedCourStreamValue = this.wrapperLoanApplicationFormResult.leadRecords.Course_Stream__c;
                this.selectedCourSubStreamValue = this.wrapperLoanApplicationFormResult.leadRecords.Course_Sub_Stream__c;
                this.courseName = this.wrapperLoanApplicationFormResult.leadRecords.Course_Id__c;
                this.courseStartDate = this.wrapperLoanApplicationFormResult.leadRecords.Course_Start_Date__c;
                this.courseEndDate = this.wrapperLoanApplicationFormResult.leadRecords.Course_End_Date__c;
                this.LangScoreCategoryValue = this.wrapperLoanApplicationFormResult.leadRecords.Language_Score_Category__c;
                this.langTestScore = this.wrapperLoanApplicationFormResult.leadRecords.Language_Test_Score__c;
                this.AnalytScoreCategoryValue = this.wrapperLoanApplicationFormResult.leadRecords.Analytics_Score_Category__c;
                this.analyticalTestScore = this.wrapperLoanApplicationFormResult.leadRecords.Analytics_Test_Score__c;
                this.quanTestScore = this.wrapperLoanApplicationFormResult.leadRecords.Quantitative_Score__c;
                this.verbalTestScore = this.wrapperLoanApplicationFormResult.leadRecords.Verbal_Score__c;
                this.Intake = this.wrapperLoanApplicationFormResult.leadRecords.Intake__c;
                //this.ApplicantPassportNumber = this.wrapperLoanApplicationFormResult.leadRecords.Passport_Number__c;
                this.courseCheck = this.wrapperLoanApplicationFormResult.leadRecords.Course_Section__c;
                this.CourseDurationValue = this.wrapperLoanApplicationFormResult.leadRecords.Course_Duration_Months__c;
                this.QuesForEducationDetails = this.wrapperLoanApplicationFormResult.leadRecords.Highest_Education_Qualification__c;
                //Applicant Account
                if (this.wrapperLoanApplicationFormResult.accRecords != null) {
                    if (this.wrapperLoanApplicationFormResult.accRecords.Account__c != undefined) {
                        this.AppliAccID = this.wrapperLoanApplicationFormResult.accRecords.Account__c;
                    }
                }

                getUniversityName({ parentId: this.InstituteId })
                    .then(result => {
                        this.ShowFieldsCourseUniversity = true;

                        // Extract the university name and ID from the result map
                        const universityName = Object.keys(result)[0];
                        const universityId = result[universityName];

                        // Assign the values to the respective variables
                        this.universityName = universityId;
                        this.universityNameString = universityName;
                    })
                    .catch(error => {
                        this.errors = error;
                    });

                //Check if Admission Status is Confirmed or Applied then show Universityn campus & Institute fields
                if (this.AdmissionStatus == "Confirmed" || this.AdmissionStatus == "Applied") {
                    this.ShowFieldsCourseUniversity = true;
                }
                else {
                    this.ShowFieldsCourseUniversity = false;
                }
                if (this.AnalytScoreCategoryValue === "GRE") {
                    this.isQuantVerbalShowHide = true;
                } else {
                    this.isQuantVerbalShowHide = false;
                }
                if (this.AnalytScoreCategoryValue === "NA") {
                    this.isAnalyticScoreShowHide = false;
                } else {
                    this.isAnalyticScoreShowHide = true;
                }
                if (this.LangScoreCategoryValue === "NA") {
                    this.isLangScoreShowHide = false;
                } else {
                    this.isLangScoreShowHide = true;
                }
                //Education Data               
                if (Array.isArray(this.wrapperLoanApplicationFormResult.appliEduDetailsRecord) && this.wrapperLoanApplicationFormResult.appliEduDetailsRecord.length > 0) {
                   
                    this.listOfEducationalTable = JSON.parse(JSON.stringify(this.wrapperLoanApplicationFormResult.appliEduDetailsRecord));
                    //this.firstCheck = true;
                } 
                /*else {
                    console.log('INSIDE else NULL CONDITION');
                    let randomId = Math.random() * 16;
                    let myNewElement = { Id: randomId, Education_Qualification__c: "", Type_of_Score__c: "", Year_Completed__c: null, Percentage_Marks_CGPA__c: "", CGPA__c: "", School_College_University__c: "", University_Name__c: "", Course_Name__c: "", Course_Stream__c: "", Course_Start_Date__c: null, Intake__c: "" };
                    this.listOfEducationalTable = [myNewElement];
                }*/
                if (this.listOfEducationalTable.length > 0) {
                    this.listOfEducationalTable.length + 1;
                }

                this.listOfEducationalTable.forEach(element => {
                    if (element.Education_Qualification__c === 'Graduate' || element.Education_Qualification__c === 'Post Graduate') {
                        element.startDate = true;
                    }
                    if (element.Type_of_Score__c === 'Percentage')
                        element.cgpaDisable = true;
                    else
                        element.cgpaDisable = false;
                    if (element.Type_of_Score__c === '5 Point CGPA') {
                        element.patternValue = this.pattern5;
                        element.cgpaCal = 5;
                    }
                    if (element.Type_of_Score__c === '10 Point CGPA') {
                        element.patternValue = this.pattern10;
                        element.cgpaCal = 10;
                    }
                    // this.fetchDependentValueOnLoad(element);
                    // var dependentPicklist = document.querySelector('lightning-combobox[name="CourseStreamEdu"][data-id="' + element.Id + '"]');

                    // if (dependentPicklist) {
                    //     dependentPicklist.disabled = false;
                    //     dependentPicklist.value = rec.Course_Stream__c;
                    // }
                     this.setcourestreamvalue();
                });

                // this.error = error;
            })
            .catch(error => {
                console.log('Get Course error', JSON.stringify(error));
                console.log('Get Course error2222', error);
            });
    }

    //Education Section add row
    addRow() {
        let randomId = Math.random() * 16;
        let myNewElement = { Id: randomId, Education_Qualification__c: "", Type_of_Score__c: "", Year_Completed__c: null, Percentage_Marks_CGPA__c: "", CGPA__c: "", School_College_University__c: "", University_Name__c: "", Course_Name__c: "", Course_Stream__c: "", Course_Start_Date__c: null, Intake__c: "" };
        if (this.listOfEducationalTable.length < 8) {
            this.listOfEducationalTable = [...this.listOfEducationalTable, myNewElement];
        }
        else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: "You cannot add more than 8 Education details",
                    variant: 'error',
                }),
            );
        }
    }
    //Education Section Delete row
    @track deleteEmpIds = '';
    removeTheRowEducational(event) {
        if (isNaN(event.target.dataset.id)) {
            this.deleteEmpIds = this.deleteEmpIds + ',' + event.target.dataset.id;
        }

        if (this.listOfEducationalTable.length > 1) {
            this.listOfEducationalTable.splice(this.listOfEducationalTable.findIndex(row => row.Id === event.target.dataset.id), 1);
        }
    }

    // Education field onchange method
    handlechange(event) {
        if (event.target.name == "Country of Study") {
            this.CountryOfStudyValue = event.target.value;
            if (this.AdmissionStatus == 'Applied' || this.AdmissionStatus == 'Confirmed') {
                this.AdmissionStatus = '';
                this.ShowFieldsCourseUniversity = false;
                this.universityName = '';
                this.universityNameString = '';
                this.InstituteId = '';
                this.courseName = '';
            }
            if (this.CountryOfStudyValue != 'INDIA' && (this.getCourseData == '' || this.getCourseData == undefined)) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please ensure to add Passport Number in Applicant section',
                        variant: 'error',
                    }),
                );
            }
        }
        if (event.target.name == "courseTel" && event.target.value != "") {
            this.courseTel = event.target.value;
        }
        if (event.target.name == "URLWeb" && event.target.value != "") {
            this.URLWeb = event.target.value;
        }
        if (event.target.name == "contPersonInstitute" && event.target.value != "") {
            this.contPersonInstitute = event.target.value;
        }
        if (event.target.name == "contPersonNum" && event.target.value != "") {
            this.contPersonNum = event.target.value;
        }
        if (event.target.name == "contPersonEmail" && event.target.value != "") {
            this.contPersonEmail = event.target.value;
        }
        if (event.target.name == "Campus") {
            this.courseCampus = event.target.value;
        }
        if (event.target.name == "Course Category") {
            this.CourseCategoryValue = event.target.value;
        }
        if (event.target.name == "Course Type") {
            this.CourseTypeValue = event.target.value;
        }
        if (event.target.name == "Course Level") {
            this.CourseLevelValue = event.target.value;
        }
        if (event.target.name == "analyticalTestScore") {
            this.analyticalTestScore = event.target.value;
        }
        if (event.target.name == "Intake") {
            this.Intake = event.target.value;
        }
    }

    //Handle change for Language Score Category and Language Test Score
    handleLangScore(event) {
        const fieldName = event.target.name;
        const fieldValue = event.target.value;
        if (fieldName === "Language Score Category") {
            this.LangScoreCategoryValue = fieldValue;

            if (this.LangScoreCategoryValue === "NA") {
                this.isLangScoreShowHide = false;
                this.langTestScore = null;
            } else {
                this.isLangScoreShowHide = true;
            }

        } else if (fieldName === "langTestScore") {
            this.langTestScore = fieldValue;

            const selectedRecord = this.langCategoryMetaData.find(record => record.Language_Category__c === this.LangScoreCategoryValue);

            if (selectedRecord) {
                const startRange = selectedRecord.Start_Range__c;
                const endRange = selectedRecord.End_Range__c;
                if (this.langTestScore < startRange || this.langTestScore > endRange) {
                    const toastEvent = new ShowToastEvent({
                        title: "Invalid Score",
                        message: `Language Test Score for ${this.LangScoreCategoryValue} must be between ${startRange} to ${endRange}.`,
                        variant: "error"
                    });
                    this.dispatchEvent(toastEvent);
                }
            }
        }
    }

    @track isQuantVerbalShowHide = false;
    @track isAnalyticScoreShowHide = false;

    @track isLangScoreShowHide = false;
    //Handle change for Analytical Score Category and Analytical Test Score
    handleAnalyticalScore(event) {
        const fieldName = event.target.name;
        const fieldValue = event.target.value;
        if (fieldName === "Analytics Score Category") {
            this.AnalytScoreCategoryValue = fieldValue;

            if (this.AnalytScoreCategoryValue === "GRE") {
                this.isQuantVerbalShowHide = true;
            } else {
                this.isQuantVerbalShowHide = false;
                this.quanTestScore = null;
                this.verbalTestScore = null;
                this.analyticalTestScore = null;
            }
            if (this.AnalytScoreCategoryValue === "NA") {
                this.isAnalyticScoreShowHide = false;
                this.quanTestScore = null;
                this.verbalTestScore = null;
                this.analyticalTestScore = null;
            } else {
                this.isAnalyticScoreShowHide = true;
            }

        } else if (fieldName === "analyticalTestScore") {
            this.analyticalTestScore = fieldValue;

            const selectedRecord = this.analyticalCategoryMetaData.find(record => record.Analytical_Category__c === this.AnalytScoreCategoryValue);

            if (selectedRecord) {
                const startRange = selectedRecord.Start_Range__c;
                const endRange = selectedRecord.End_Range__c;
                if (this.analyticalTestScore < startRange || this.analyticalTestScore > endRange) {
                    const toastEvent = new ShowToastEvent({
                        title: "Invalid Score",
                        message: `Analytical Test Score for ${this.AnalytScoreCategoryValue} must be between ${startRange} to ${endRange}.`,
                        variant: "error"
                    });
                    this.dispatchEvent(toastEvent);
                }
            }
        }
        if (fieldName === "QuanTestScore") {
            this.quanTestScore = fieldValue;

            const selectedRecord1 = this.analyticalCategoryMetaDataGRE.find(record => record.Analytical_Category_GRE__c === this.AnalytScoreCategoryValue);

            if (selectedRecord1) {
                const startRange = selectedRecord1.Start_Range__c;
                const endRange = selectedRecord1.End_Range__c;
                if (this.quanTestScore < startRange || this.quanTestScore > endRange) {
                    const toastEvent = new ShowToastEvent({
                        title: "Invalid Score",
                        message: `Quantitative Test Score for ${this.AnalytScoreCategoryValue} must be between ${startRange} to ${endRange}.`,
                        variant: "error"
                    });
                    this.dispatchEvent(toastEvent);
                }else{
                    if (this.isQuantVerbalShowHide) {
                        this.analyticalTestScore = parseFloat(this.quanTestScore) + parseFloat(this.verbalTestScore);
                    }
                }
            }
        }

        if (fieldName === "VerbalTestScore") {
            this.verbalTestScore = fieldValue;

            const selectedRecord1 = this.analyticalCategoryMetaDataGRE.find(record => record.Analytical_Category_GRE__c === this.AnalytScoreCategoryValue);

            if (selectedRecord1) {
                const startRange = selectedRecord1.Start_Range__c;
                const endRange = selectedRecord1.End_Range__c;
                if (this.verbalTestScore < startRange || this.verbalTestScore > endRange) {
                    const toastEvent = new ShowToastEvent({
                        title: "Invalid Score",
                        message: `Verbal Test Score for ${this.AnalytScoreCategoryValue} must be between ${startRange} to ${endRange}.`,
                        variant: "error"
                    });
                    this.dispatchEvent(toastEvent);
                }else{
                    if (this.isQuantVerbalShowHide) {
                        this.analyticalTestScore = parseFloat(this.quanTestScore) + parseFloat(this.verbalTestScore);
                    }
                }
            }
        }
    }

    handleStartDate(event) {
        if (event.target.name == "courseStartDate") {
            this.courseStartDate = event.target.value;
            let date1 = new Date(this.courseStartDate).toISOString().split('T')[0];
            let currentdate = new Date().toISOString().split('T')[0];
            if (date1 >= currentdate) {

                //Added By Rohit
                if (this.CourseDurationValue != undefined) {
                    // Retrieve the selected course start date and duration value
                    const courseStartDate = new Date(this.courseStartDate);
                    const courseDurationValue = parseInt(this.CourseDurationValue);

                    // Calculate the course end date
                    const courseEndDate = new Date(courseStartDate.getFullYear() + Math.floor(courseDurationValue / 12), courseStartDate.getMonth() + (courseDurationValue % 12), courseStartDate.getDate());

                    // Format the course end date in 'dd/MM/yyyy' format
                    const formattedEndDate = courseEndDate.toISOString().split('T')[0];

                    // Assign the formatted end date to the component property
                    this.courseEndDate = formattedEndDate;
                }

            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: "The Course Start Date should not be earlier than today's date.",
                        variant: 'error',
                    }),
                );
                this.courseStartDate = null;
            }
        }
    }

    handleEndDate(event) {
        if (event.target.name == "courseEndDate") {
            this.courseEndDate = event.target.value;
            let date1 = new Date(this.courseStartDate).toISOString().split('T')[0];
            let date2 = new Date(this.courseEndDate).toISOString().split('T')[0];

            if (date2 > date1) {
                console.log('5 date1==>', date1);
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'The Course End Date must be greater than the Course Start date',
                        variant: 'error',
                    }),
                );
                this.courseEndDate = null;
            }
        }
    }
    handleCourseUniversityShowHide(event) {
        if (event.target.name == "Admission Status") {
            this.AdmissionStatus = event.target.value;
        }
        if (event.target.name == "Admission Status" && event.target.value !== "Not Applied") {
            this.ShowFieldsCourseUniversity = true;
            this.universityName = '';
            this.universityNameString = '';
            this.InstituteId = '';
            this.courseCampus = '';
            this.courseName = '';
        }
        else {
            this.ShowFieldsCourseUniversity = false;
        }
    }

    @track universityNameIdResult;
    @track errorsUniversityId;


    handleInstitute(event) {
        const selectedId = event.detail.selectedId;
        if (selectedId === '') {
            this.universityName = '';
            this.universityNameString = '';
        }
        //this.ShowFieldsCourseUniversity = true ;
        this.InstituteId = selectedId;
        getUniversityName({ parentId: this.InstituteId })
            .then(result => {
                this.ShowFieldsCourseUniversity = true;

                // Extract the university name and ID from the result map
                const universityName = Object.keys(result)[0];
                const universityId = result[universityName];

                // Assign the values to the respective variables
                this.universityName = universityId;
                this.universityNameString = universityName;

            })
            .catch(error => {
                this.errors = error;
            });
        getLookupData({ objectApiName: "Course__c", countryOfStudyLead: this.CountryOfStudyValue, parentId: this.InstituteId, label: "Course" })
            .then(result => {
                let option = [];
                for (var key in result) {
                    option.push({
                        label: result[key].Course_Name__c,
                        value: result[key].Id
                    });
                }
                // this.courseName = option;
            })
            .catch(error => {
                console.log(error);
            });

    }
    handleCourse(event) {
        const selectedId = event.detail.selectedId;
        this.courseName = selectedId;
    }

    @track InstituteIdFromUnivercity;
    handleCourseInstAndCampusShowHide(event) {
        const selectedId = event.detail.selectedId;
        // if (event.target.name == "universityName") {
        this.universityName = selectedId;
        if (this.universityName == '') {
            this.InstituteId = '';
            this.courseName = '';
        }
        this.showInstitute = true;
    }

    //Course Id Name Lookup Lead    
    @track CourseIdNameIdResult;
    @track errorsCourseIdName;
    handleCourseIdNameLead(event) {
        if (event.target.name == "courseName") {
            this.courseName = event.target.value;
        }

        getCourseIdName({ courseNameId: this.courseName }) //this parameter is passed to Class-CommunityLeadFormController.getInstituteRecord
            .then(result => {
                this.CourseIdNameIdResult = result;
            })
            .catch(error => {
                this.errorsCourseIdName = error;
            });

    }

    /**********Institure info Update method************/
    handleInstituteSelection(event) {
        this.InstituteId = event.target.value;

        getInstituteRecord({ instituteId: this.InstituteId }) //this parameter is passed to Class-CommunityLeadFormController.getInstituteRecord
            .then(result => {
                this.instituteResult = result;
                if (this.instituteResult.Address__c != null) {
                    this.instAdderess = this.instituteResult.Address__c;
                }
                this.instCity = this.instituteResult.City__c;
                this.instState = this.instituteResult.State__c;
                this.instCountry = this.instituteResult.Country__c;
                this.instPINCode = this.instituteResult.Pin_Code__c;
                this.courseTel = this.instituteResult.Tel__c;
                this.URLWeb = this.instituteResult.URL_Web__c;
            })
            .catch(error => {
                this.errors = error;
            });
    }

    @track QuesForEducationDetails;
    handleQuesForEducationDetails(event) {
        this.QuesForEducationDetails = event.target.value

        if (this.AppliAccID != undefined && this.listOfEducationalTable == undefined) {
            let randomId = Math.random() * 16;
            let myNewElement = { Id: randomId, Education_Qualification__c: "", Year_Completed__c: "", Percentage_Marks_CGPA__c: "", CGPA__c: "", School_College_University__c: "", Course_Name__c: "", Course_Stream__c: "", Intake__c: "" };
            this.listOfEducationalTable = [myNewElement];
        } else if (this.listOfEducationalTable == undefined) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Applicant record is mandatory for Education Details.',
                variant: 'error'
            }));
        }
    }

    @track percentageReadOnly = false;
    @track cgpaReadOnly = false;

    //For validation:
    @track percentageNotValid = false;
    @track CGPAMarksNotValid = false;
    @track date3;
    @track date4;
    //update table row values in list
    updateValues(event) {
        var foundelement = this.listOfEducationalTable.find(ele => ele.Id == event.target.dataset.id);
        if (event.target.name === 'EducationDetails') {
            let newEducationDetailsValue = event.target.value;
            if (newEducationDetailsValue == '10th' || newEducationDetailsValue == '12th') {
                let duplicateIndex = this.listOfEducationalTable.findIndex(ele => ele.Id !== foundelement.Id && ele.Education_Qualification__c === newEducationDetailsValue);
                if (duplicateIndex !== -1) {
                    // If the value already exists in the table, show an error message and set the value to the previous value
                    foundelement.Education_Qualification__c = null;
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: 'This Education Qualification is already present in the details',
                        variant: 'error'
                    }));
                }
                else {
                    // If the value is unique, update the value and store it in the EducationDetails variable
                    foundelement.Education_Qualification__c = newEducationDetailsValue;
                    this.EducationDetails = newEducationDetailsValue;
                }
            }
            else {
                foundelement.Education_Qualification__c = event.target.value;
            }
            if (foundelement.Education_Qualification__c === 'Graduate' || foundelement.Education_Qualification__c === 'Post Graduate') {
                foundelement.startDate = true;
            }
            else {
                foundelement.startDate = false;
            }
            this.fetchDependentValue(event);
        }
        else if (event.target.name === 'TypeOfScore') {
            foundelement.Type_of_Score__c = event.target.value;
            foundelement.CGPA__c = null;
            foundelement.Percentage_Marks_CGPA__c = null;
            if (event.target.value == 'Percentage')
                foundelement.cgpaDisable = true;
            else
                foundelement.cgpaDisable = false;
            if (event.target.value == '5 Point CGPA') {
                foundelement.cgpaCal = 5;
                foundelement.patternValue = this.pattern5;
            }
            if (event.target.value == '10 Point CGPA') {
                foundelement.cgpaCal = 10;
                foundelement.patternValue = this.pattern10;
            }
        }
        else if (event.target.name === 'StartDate') {
            foundelement.Course_Start_Date__c = event.target.value;
            this.YearCompleted = foundelement.Year_Completed__c;
        }
        else if (event.target.name === 'EndDate') {
            foundelement.Year_Completed__c = event.target.value;

            if (foundelement.Education_Qualification__c === '10th') {
                this.year10 = new Date(foundelement.Year_Completed__c).getFullYear();
            }

            if (foundelement.Education_Qualification__c === '12th') {
                this.year12 = new Date(foundelement.Year_Completed__c).getFullYear();
            }

            if (foundelement.Education_Qualification__c === 'Graduate' || foundelement.Education_Qualification__c === 'Post Graduate') {
                let date1 = new Date(foundelement.Course_Start_Date__c).toISOString().split('T')[0];
                let date2 = new Date(foundelement.Year_Completed__c).toISOString().split('T')[0];
                this.date3 = new Date(foundelement.Course_Start_Date__c).getFullYear();
                this.date4 = new Date(foundelement.Year_Completed__c).getFullYear();
                if (date2 > date1) {
                    if (this.date3 != this.date4) {
                        console.log('5 date1==>', date1);
                    } else {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'The Course Start Date and End Date cannot be in the same year',
                                variant: 'error',
                            }),
                        );
                        foundelement.Year_Completed__c = null;
                    }
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'The Course End Date must be greater than the Course Start date',
                            variant: 'error',
                        }),
                    );
                    foundelement.Year_Completed__c = null;
                }
            }
            this.YearCompleted = foundelement.Year_Completed__c;
        }
        else if (event.target.name === 'PercentageMarks') {
            let fieldValue = event.target.value;
            let pattern = /^(?!0*(\.0+)?$)\d{1,2}(\.\d{1,2})?$/;
            if (!pattern.test(fieldValue) && fieldValue != '') {
                foundelement.percentageNotValid = true;
            } else {
                foundelement.Percentage_Marks_CGPA__c = event.target.value;
                //foundelement.CGPA__c = (foundelement.Percentage_Marks_CGPA__c / 9.5).toFixed(2);
                foundelement.percentageNotValid = false;
                foundelement.CGPAMarksNotValid = false;
            }
        }
        else if (event.target.name === 'CGPAMarks') {
            let fieldValue = event.target.value;
            let pattern;
            if (foundelement.Type_of_Score__c == '5 Point CGPA')
                pattern = /^(?:[1-4](?:\.[0-9]{1,2})?|5(?:\.0{1,2})?)$/;
            if (foundelement.Type_of_Score__c == '10 Point CGPA')
                pattern = /^(?:[1-9](?:\.[0-9]{1,2})?|10(?:\.0{1,2})?)$/;
            if (!pattern.test(fieldValue) && fieldValue != '') {
                foundelement.CGPAMarksNotValid = true;
            } else {
                foundelement.CGPA__c = event.target.value;
                foundelement.Percentage_Marks_CGPA__c = parseFloat(((foundelement.CGPA__c * 100) / foundelement.cgpaCal).toFixed(2));
                foundelement.CGPAMarksNotValid = false;
                foundelement.percentageNotValid = false;
            }
        }
        else if (event.target.name === 'SchoolCollegeUniversity') {
            foundelement.School_College_University__c = event.target.value;
            this.SchoolCollegeUniversity = foundelement.School_College_University__c;
        }
        else if (event.target.name === 'University') {
            foundelement.University_Name__c = event.target.value;
        }
        else if (event.target.name === 'CourseNameEdu') {
            foundelement.Course_Name__c = event.target.value;
        }
        else if (event.target.name === 'CourseStreamEdu') {
            foundelement.Course_Stream__c = event.target.value;
        }
    }

    handleSaveCourseEduSection() {

        var universityError;
        var instituteError;
        var courseError;
        var duplicateError;
        var educationError;
        var courseStartError;
        var countryError;
        var courseStartDateError;
        var courseEndDateError;

        let hasGraduate = false;
        let hasPostGraduate = false;
        let has10th = false;
        let has12th = false;
        let hasDiploma = false;

        var eduErrorForOnlyReqTen = false;
        var eduErrorForTwlReqTen = false;
        var eduErrorNotTenTwelve = false;
        var eduErrorForDiplomaReqTen = false;
        var eduErrorForCerfiReqTen = false;
        var eduErrorPostGraduate = false;
        var highestEduQualiError;

        var percentCgpaErrorNull = false;
        var percentCgpaErrorGreater = false;
        var quantError;
        var verbalError;
        var langScoreCategotyError;
        var analyticalScoreCategotyError;
        var analylScoreCateyGREQuatError;
        var analytScoreCateyGREVerbalError;

        var tenYearNotTwelveNbefore;
        var gradNotLessOrEqualTenTwelve;
        var postGradNotLessOrEqualTenTwelve;

        var admissionStatusError;

        if (this.CountryOfStudyValue == '' || this.CountryOfStudyValue == undefined) {
            countryError = true;
        }
        else if (this.AdmissionStatus == '' || this.AdmissionStatus == undefined) {
            admissionStatusError = true;
        }
        else if ((this.AdmissionStatus == 'Confirmed' || this.AdmissionStatus == 'Applied') && (this.universityName == '' || this.universityName == undefined)) {
            instituteError = true;
        }
        else if ((this.AdmissionStatus == 'Confirmed' || this.AdmissionStatus == 'Applied') && this.universityName != '' && (this.InstituteId == '' || this.InstituteId == undefined)) {
            instituteError = true;
        }
        else if ((this.AdmissionStatus == 'Confirmed' || this.AdmissionStatus == 'Applied') && this.universityName != '' && this.InstituteId != '' && (this.courseName == '' || this.courseName == undefined)) {
            courseError = true;
        }
        else if ((this.courseStartDate != null) && (this.courseEndDate == '' || this.courseEndDate == undefined)) {
            courseStartDateError = true;
        }
        else if ((this.courseEndDate != null) && (this.courseStartDate == '' || this.courseStartDate == undefined)) {
            courseEndDateError = true;
        }
        else if (this.langCategoryMetaData.length > 0) {
            const selectedRecord = this.langCategoryMetaData.find(record => record.Language_Category__c === this.LangScoreCategoryValue);

            if (selectedRecord) {
                var startRange = selectedRecord.Start_Range__c;
                var endRange = selectedRecord.End_Range__c;
                if (this.langTestScore < startRange || this.langTestScore > endRange) {
                    langScoreCategotyError = true;
                }
            }
        }

        if (this.analyticalCategoryMetaData.length > 0) {
            const selectedRecord1 = this.analyticalCategoryMetaData.find(record => record.Analytical_Category__c === this.AnalytScoreCategoryValue);

            if (selectedRecord1) {
                var startRange1 = selectedRecord1.Start_Range__c;
                var endRange1 = selectedRecord1.End_Range__c;
                if (this.analyticalTestScore < startRange1 || this.analyticalTestScore > endRange1) {
                    analyticalScoreCategotyError = true;
                }
            }
        }
        if (this.analyticalCategoryMetaDataGRE.length > 0) {
            const selectedRecord1 = this.analyticalCategoryMetaDataGRE.find(record => record.Analytical_Category_GRE__c === this.AnalytScoreCategoryValue);
            if (selectedRecord1) {
                var startRange2 = selectedRecord1.Start_Range__c;
                var endRange2 = selectedRecord1.End_Range__c;
                if ((this.AnalytScoreCategoryValue == 'GRE') && (this.quanTestScore == null || this.quanTestScore == '')) {
                    quantError = true;
                } else if (this.quanTestScore < startRange2 || this.quanTestScore > endRange2) {
                    analylScoreCateyGREQuatError = true;
                } else if ((this.AnalytScoreCategoryValue == 'GRE') && (this.verbalTestScore == null || this.verbalTestScore == '')) {
                    verbalError = true;
                } else if (this.verbalTestScore < startRange2 || this.verbalTestScore > endRange2) {
                    analytScoreCateyGREVerbalError = true;
                }
            }
        }

        // Iterate through the educational table       
        if (this.listOfEducationalTable != null || this.listOfEducationalTable != undefined) {
            this.listOfEducationalTable.forEach((rec) => {
                if (rec.Education_Qualification__c == '10th') {
                    has10th = true;
                } else if (rec.Education_Qualification__c == '12th') {
                    has12th = true;
                } else if (rec.Education_Qualification__c == 'Graduate') {
                    hasGraduate = true;
                } else if (rec.Education_Qualification__c == 'Post Graduate') {
                    hasPostGraduate = true;
                } else if (rec.Education_Qualification__c == 'Diploma') {
                    hasDiploma = true;
                }
            });
        }

        if (this.listOfEducationalTable != null || this.listOfEducationalTable != undefined) {
            if (this.QuesForEducationDetails == '' || this.QuesForEducationDetails == undefined) {
                highestEduQualiError = true;
            }

            // Check conditions based on QuesForEducationDetails value
            if (this.QuesForEducationDetails == '10th') {
                if (!has10th || has12th || hasGraduate || hasPostGraduate || hasDiploma) {
                    eduErrorForOnlyReqTen = true;
                }
            } else if (this.QuesForEducationDetails == '12th') {
                if (!has10th || !has12th || hasGraduate || hasPostGraduate || hasDiploma) {
                    eduErrorForTwlReqTen = true;
                }
            } else if (this.QuesForEducationDetails == 'Diploma') {
                if (!has10th || !hasDiploma || hasGraduate || hasPostGraduate) {
                    eduErrorForDiplomaReqTen = true;
                }
            } else if (this.QuesForEducationDetails == 'Graduate') {
                if (!has10th || (!has12th && !hasDiploma) || !hasGraduate || hasPostGraduate) {
                    eduErrorNotTenTwelve = true;
                }
            } else if (this.QuesForEducationDetails == 'Post Graduate') {
                if (!has10th || (!has12th && !hasDiploma) || !hasGraduate || !hasPostGraduate) {
                    eduErrorPostGraduate = true;
                }
            }
        }

        if (this.listOfEducationalTable != null || this.listOfEducationalTable != undefined) {
            for (var i = 0; i < this.listOfEducationalTable.length; i++) {
                var recEdu = this.listOfEducationalTable[i];
                if (recEdu.Education_Qualification__c == '10th') {
                    this.year10 = new Date(recEdu.Year_Completed__c).getFullYear();
                    var year10FullDate = new Date(recEdu.Year_Completed__c);
                }
                if (recEdu.Education_Qualification__c == '12th') {
                    this.year12 = new Date(recEdu.Year_Completed__c).getFullYear();
                    var year12FullDate = new Date(recEdu.Year_Completed__c);
                }
                if (recEdu.Education_Qualification__c == 'Graduate') {
                    var GradStartDate = new Date(recEdu.Course_Start_Date__c);
                    var GradEndDate = new Date(recEdu.Year_Completed__c);
                }

                if (recEdu.Education_Qualification__c == 'Post Graduate') {
                    var PostGradStartDate = new Date(recEdu.Course_Start_Date__c);
                    var PostGradEndDate = new Date(recEdu.Year_Completed__c);
                }

                if (recEdu.Education_Qualification__c == '12th' && this.year12 <= this.year10 && this.year10 !== '' && this.year12 !== '') {
                    tenYearNotTwelveNbefore = true;
                    if (tenYearNotTwelveNbefore)
                        break;
                }

                else if ((GradStartDate <= year10FullDate || GradStartDate <= year12FullDate) && (year10FullDate !== '' || year12FullDate !== '') && recEdu.Education_Qualification__c == 'Graduate') {
                    gradNotLessOrEqualTenTwelve = true;
                    if (gradNotLessOrEqualTenTwelve)
                        break;
                }
                else if ((PostGradStartDate <= year10FullDate || PostGradStartDate <= year12FullDate || PostGradStartDate <= GradStartDate) && (year10FullDate !== '' || year12FullDate !== '' || GradStartDate !== '') && recEdu.Education_Qualification__c == 'Post Graduate') {
                    postGradNotLessOrEqualTenTwelve = true;
                    if (postGradNotLessOrEqualTenTwelve)
                        break;
                }
                else if (PostGradStartDate <= GradEndDate && GradEndDate !== '' && recEdu.Education_Qualification__c == 'Post Graduate') {
                    postGradNotLessOrEqualTenTwelve = true;
                    if (postGradNotLessOrEqualTenTwelve)
                        break;
                }
            }
        }

        if (this.listOfEducationalTable != undefined) {
            for (var i = 0; i < this.listOfEducationalTable.length; i++) {
                var record = this.listOfEducationalTable[i];
                if (record.Education_Qualification__c == null) {
                    duplicateError = true;
                    if (duplicateError)
                        break;
                }
                if (record.Education_Qualification__c == '' || record.Education_Qualification__c == undefined ||
                    record.School_College_University__c == '' || record.School_College_University__c == undefined ||
                    record.Year_Completed__c == '' || record.Year_Completed__c == undefined ||
                    record.University_Name__c == '' || record.University_Name__c == undefined) {
                    educationError = true;
                    if (educationError)
                        break;
                }
                else if ((record.Education_Qualification__c == 'Graduate' || record.Education_Qualification__c == 'Post Graduate') && (record.Course_Start_Date__c == '' || record.Course_Start_Date__c == undefined)) {
                    courseStartError = true;
                    if (courseStartError)
                        break;
                }
                if (record.percentageNotValid == true) {
                    percentCgpaErrorNull = true;
                    if (percentCgpaErrorNull)
                        break;

                }
                else if (record.CGPAMarksNotValid == true) {
                    percentCgpaErrorNull = true;
                    if (percentCgpaErrorNull)
                        break;
                }
                else if (record.Percentage_Marks_CGPA__c > 100 || record.CGPA__c > 10.52 || record.Percentage_Marks_CGPA__c < 0 || record.CGPA__c < 0) {
                    percentCgpaErrorGreater = true;
                    if (percentCgpaErrorGreater)
                        break;
                }
                else if (record.Percentage_Marks_CGPA__c == '' /*|| record.CGPA__c == ''*/) {
                    percentCgpaErrorNull = true;
                    if (percentCgpaErrorNull)
                        break;
                }
            }
        }

        if (countryError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select Country of Study',
                    variant: 'error',
                }),
            );
        }
        else if (admissionStatusError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please select Admission Status',
                    variant: 'Error',
                }),
            );
        }
        else if (universityError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please select University',
                    variant: 'Error',
                }),
            );
        }
        else if (instituteError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please select Institute',
                    variant: 'Error',
                }),
            );
        }
        else if (courseError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please select Course',
                    variant: 'Error',
                }),
            );
        }
        else if (courseEndDateError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please select a valid Course Start Date.',
                    variant: 'Error',
                }),
            );
        }
        else if (courseStartDateError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please select a valid Course End Date.',
                    variant: 'Error',
                }),
            );
        }
        else if (duplicateError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please fill in all mandatory fields for the Education details',
                    variant: 'Error',
                }),
            );
        }
        else if (educationError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please fill in all mandatory fields for the Education details',
                    variant: 'Error',
                }),
            );
        }
        else if (courseStartError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please select Course Start Date',
                    variant: 'Error',
                }),
            );
        }
        else if (percentCgpaErrorGreater) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter a valid percentage',
                    variant: 'Error',
                }),
            );
        }
        else if (percentCgpaErrorNull) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter a valid percentage or CGPA',
                    variant: 'Error',
                }),
            );
        } else if (langScoreCategotyError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: `Language Test Score for ${this.LangScoreCategoryValue} must be between ${startRange} to ${endRange}.`,
                    variant: 'Error',
                }),
            );
        } else if (analyticalScoreCategotyError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: `Analytical Test Score for ${this.AnalytScoreCategoryValue} must be between ${startRange1} to ${endRange1}.`,
                    variant: 'Error',
                }),
            );
        } else if (analylScoreCateyGREQuatError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: `Quantitative Test Score for ${this.AnalytScoreCategoryValue} must be between ${startRange2} to ${endRange2}.`,
                    variant: 'Error',
                }),
            );
        } else if (analytScoreCateyGREVerbalError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: `Verbal Test Score for ${this.AnalytScoreCategoryValue} must be between ${startRange2} to ${endRange2}.`,
                    variant: 'Error',
                }),
            );
        } else if (quantError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter valid a Quantitative Score.',
                    variant: 'Error',
                }),
            );
        } else if (verbalError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter valid a Verbal score.',
                    variant: 'Error',
                }),
            );
        } else if (highestEduQualiError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please select the Highest Education Qualification',
                    variant: 'Error',
                }),
            );
        } else if (tenYearNotTwelveNbefore) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'The End date of 12th grade must be after the End date of 10th grade.',
                    variant: 'Error',
                }),
            );
        } else if (gradNotLessOrEqualTenTwelve) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'The Start date of Graduation must be after the End date of 12th grade.',
                    variant: 'Error',
                }),
            );
        } else if (postGradNotLessOrEqualTenTwelve) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'The Start date of Post Graduation must be after the End date of Graduation or the End date of 12th grade.',
                    variant: 'Error',
                }),
            );
        } else if (eduErrorForOnlyReqTen) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Information!!',
                    message: 'Add only 10th details for highest qualification as 10th',
                    variant: 'Info',
                }),
            );
        } else if (eduErrorForTwlReqTen) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Information!!',
                    message: 'Add only 10th & 12th details for highest qualification as 12th',
                    variant: 'Info',
                }),
            );
        } else if (eduErrorForDiplomaReqTen) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Information!!',
                    message: 'Add only 10th & Diploma details for highest qualification as Diploma',
                    variant: 'Info',
                }),
            );
        } else if (eduErrorNotTenTwelve) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Information!!',
                    message: 'Add only 10th, 12th or Diploma and Graduation details for highest qualification as Graduation',
                    variant: 'Info',
                }),
            );
        } else if (eduErrorPostGraduate) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Information!!',
                    message: 'Add only 10th, 12th or Diploma, Graduation & Post-Graduation details for highest qualification as Post-Graduation',
                    variant: 'Info',
                }),
            );
        }

        else {
            this.isLoading = true;
            let CourseSecSaveRec = {
                Id: this.leadID,
                Institute_Name__c: this.InstituteId,
                Country_of_Study__c: this.CountryOfStudyValue,
                Admission_Status__c: this.AdmissionStatus,
                University_Name__c: this.universityName,
                Campus__c: this.courseCampus,
                Course_Category__c: this.CourseCategoryValue,
                Course_Type__c: this.CourseTypeValue,
                Course_Level__c: this.CourseLevelValue,
                Course_Stream__c: this.selectedCourStreamValue,
                Course_Sub_Stream__c: this.selectedCourSubStreamValue,
                Course_Id__c: this.courseName,
                Course_Start_Date__c: this.courseStartDate,
                Course_End_Date__c: this.courseEndDate,
                Language_Score_Category__c: this.LangScoreCategoryValue,
                Language_Test_Score__c: this.langTestScore,
                Analytics_Score_Category__c: this.AnalytScoreCategoryValue,
                Analytics_Test_Score__c: this.analyticalTestScore,
                Verbal_Score__c: this.verbalTestScore,
                Quantitative_Score__c: this.quanTestScore,
                Highest_Education_Qualification__c: this.QuesForEducationDetails,
                Course_Duration_Months__c: this.CourseDurationValue,
                Intake__c: this.Intake

            }
            let CourseAppliAccDataSaveRec = {
                Id: this.AppliAccID
            }
            if (this.deleteEmpIds !== '') {
                this.deleteEmpIds = this.deleteEmpIds.substring(0);
            }

            if (this.listOfEducationalTable != null || this.listOfEducationalTable != undefined) {
                this.listOfEducationalTable.forEach(res => {
                    if (!isNaN(res.Id)) {
                        res.Id = null;
                    }
                });
                this.listOfEducationalTable.forEach(res => {
                    res.finalDependentVal = null;
                });
            }
            //Wrapper Class variable      
            let wrapperCommFormRecord = {
                leadSaveRec: JSON.stringify(CourseSecSaveRec),
                appliEduDetailsSave: JSON.stringify(this.listOfEducationalTable),
                appliAccSaveRec: JSON.stringify(CourseAppliAccDataSaveRec),
                removeEducationIds: this.deleteEmpIds
            }

            createUpdateLeadWithRelatedInformation({
                wrapperLoanApplicationForm: JSON.stringify(wrapperCommFormRecord),
                leadGetId: this.leadRecordId
            })
                .then(response => {
                    this.wrapperLoanApplicationFormResult = response;

                    //Lead Applicant
                    this.leadID = this.wrapperLoanApplicationFormResult.leadRecords.Id;

                    this.CountryOfStudyValue = this.wrapperLoanApplicationFormResult.leadRecords.Country_of_Study__c;
                    this.AdmissionStatus = this.wrapperLoanApplicationFormResult.leadRecords.Admission_Status__c;
                    this.universityName = this.wrapperLoanApplicationFormResult.leadRecords.University_Name__c;
                    this.courseCampus = this.wrapperLoanApplicationFormResult.leadRecords.Campus__c;
                    this.InstituteId = this.wrapperLoanApplicationFormResult.leadRecords.Institute_Name__c;
                    this.CourseCategoryValue = this.wrapperLoanApplicationFormResult.leadRecords.Course_Category__c;
                    this.CourseTypeValue = this.wrapperLoanApplicationFormResult.leadRecords.Course_Type__c;
                    this.CourseLevelValue = this.wrapperLoanApplicationFormResult.leadRecords.Course_Level__c;
                    this.selectedCourStreamValue = this.wrapperLoanApplicationFormResult.leadRecords.Course_Stream__c;
                    this.selectedCourSubStreamValue = this.wrapperLoanApplicationFormResult.leadRecords.Course_Sub_Stream__c;
                    this.courseName = this.wrapperLoanApplicationFormResult.leadRecords.Course_Id__c;
                    this.courseStartDate = this.wrapperLoanApplicationFormResult.leadRecords.Course_Start_Date__c;
                    this.courseEndDate = this.wrapperLoanApplicationFormResult.leadRecords.Course_End_Date__c;
                    this.LangScoreCategoryValue = this.wrapperLoanApplicationFormResult.leadRecords.Language_Score_Category__c;
                    this.langTestScore = this.wrapperLoanApplicationFormResult.leadRecords.Language_Test_Score__c;
                    this.AnalytScoreCategoryValue = this.wrapperLoanApplicationFormResult.leadRecords.Analytics_Score_Category__c;
                    this.analyticalTestScore = this.wrapperLoanApplicationFormResult.leadRecords.Analytics_Test_Score__c;
                    this.courseCheck = this.wrapperLoanApplicationFormResult.leadRecords.Course_Section__c;
                    this.QuesForEducationDetails = this.wrapperLoanApplicationFormResult.leadRecords.Highest_Education_Qualification__c;
                    this.CourseDurationValue = this.wrapperLoanApplicationFormResult.leadRecords.Course_Duration_Months__c;
                    this.Intake = this.wrapperLoanApplicationFormResult.leadRecords.Intake__c;

                    //Check if Admission Status is Confirmed or Applied then show Universityn campus & Institute fields
                    if (this.AdmissionStatus == "Confirmed" || this.AdmissionStatus == "Applied") {
                        this.ShowFieldsCourseUniversity = true;
                    }
                    else {
                        this.ShowFieldsCourseUniversity = false;
                    }

                    if (this.AnalytScoreCategoryValue === "GRE") {
                        this.isQuantVerbalShowHide = true;
                    } else {
                        this.isQuantVerbalShowHide = false;
                    }

                    if (this.AnalytScoreCategoryValue === "NA") {
                        this.isAnalyticScoreShowHide = false;
                    } else {
                        this.isAnalyticScoreShowHide = true;
                    }

                    if (this.LangScoreCategoryValue === "NA") {
                        this.isLangScoreShowHide = false;
                    } else {
                        this.isLangScoreShowHide = true;
                    }                    

                    if (this.wrapperLoanApplicationFormResult.appliEduDetailsRecord != undefined) {
                        this.listOfEducationalTable = JSON.parse(JSON.stringify(this.wrapperLoanApplicationFormResult.appliEduDetailsRecord));
                    }
                    // else {
                    //     let randomId = Math.random() * 16;
                    //     let myNewElement = { Id: randomId, Education_Qualification__c: "", Year_Completed__c: "", Percentage_Marks_CGPA__c: "", CGPA__c: "", School_College_University__c: "", Course_Name__c: "", Course_Stream__c: "", Intake__c: "" };
                    //     this.listOfEducationalTable = [myNewElement];
                    // }

                    if (this.listOfEducationalTable != undefined) {
                        this.listOfEducationalTable.forEach(element => {
                            if (element.Education_Qualification__c == 'Graduate' || element.Education_Qualification__c == 'Post Graduate') {
                                element.startDate = true;
                            }
                            if (element.Type_of_Score__c === 'Percentage')
                                element.cgpaDisable = true;
                            else
                                element.cgpaDisable = false;
                            this.fetchDependentValueOnLoad(element);
                            var dependentPicklist = document.querySelector('lightning-combobox[name="CourseStreamEdu"][data-id="' + element.Id + '"]');

                            if (dependentPicklist) {
                                dependentPicklist.disabled = false;
                                dependentPicklist.value = rec.Course_Stream__c;
                            }
                        });
                    }

                    if (this.listOfEducationalTable != undefined) {
                        if (this.listOfEducationalTable.length > 0) {
                            this.listOfEducationalTable.length + 1;
                        }
                    }

                    //Applicant Account
                    if (this.wrapperLoanApplicationFormResult.accRecords != undefined) {
                        this.AppliAccID = this.wrapperLoanApplicationFormResult.accRecords.Account__c;
                    }

                    // if (response != null) {
                    //     console.log('response inside if=====>' + response);
                    // }
                    this.isLoading = false;

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Successfully Saved',
                            variant: 'Success',
                        }),
                    );

                }).catch(error => {
                    console.log(error);
                    console.log
                    this.isLoading = false;
                    this.handleErrorMessage(error);
                })
        }
    }

    handleNextCourseEduSection() {

        var isError = false;
        var universityError;
        var instituteError;
        var courseError;
        var educationError;
        var courseStartError;
        var duplicateError;
        var sameyear;
        var countryError;

        var passportError;

        let hasGraduate = false;
        let hasPostGraduate = false;
        let has10th = false;
        let has12th = false;
        let hasDiploma = false;

        var eduErrorForOnlyReqTen = false;
        var eduErrorForTwlReqTen = false;
        var eduErrorNotTenTwelve = false;
        var eduErrorForDiplomaReqTen = false;
        var eduErrorForCerfiReqTen = false;
        var eduErrorPostGraduate = false;
        var highestEduQualiError;

        var percentCgpaErrorNull = false;
        var percentCgpaErrorGreater = false;
        var quantError;
        var verbalError;
        var langScoreCategotyError;
        var analyticalScoreCategotyError;
        var analylScoreCateyGREQuatError;
        var analytScoreCateyGREVerbalError;
        var perError;
        var cgpaError;

        var tenYearNotTwelveNbefore;
        var gradNotLessOrEqualTenTwelve;
        var postGradNotLessOrEqualTenTwelve;

        var applicantReqError; //For Applicant check for Edu details

        if (this.CountryOfStudyValue == '' || this.CountryOfStudyValue == undefined ||
            this.AdmissionStatus == '' || this.AdmissionStatus == undefined ||
            this.CourseCategoryValue == '' || this.CourseCategoryValue == undefined ||
            this.CourseTypeValue == '' || this.CourseTypeValue == undefined ||
            this.CourseLevelValue == '' || this.CourseLevelValue == undefined ||
            this.selectedCourStreamValue == '' || this.selectedCourStreamValue == undefined ||
            this.LangScoreCategoryValue == '' || this.LangScoreCategoryValue == undefined ||
            ((this.LangScoreCategoryValue != 'NA') && (this.langTestScore == '' || this.langTestScore == undefined)) ||
            this.AnalytScoreCategoryValue == '' || this.AnalytScoreCategoryValue == undefined ||
            ((this.AnalytScoreCategoryValue != 'NA') && (this.analyticalTestScore == '' || this.analyticalTestScore == undefined))) {
            isError = true;
        }
        else if (this.CountryOfStudyValue == '' || this.CountryOfStudyValue == undefined) {
            countryError = true;
        }
        else if (this.CountryOfStudyValue != 'INDIA' && (this.getCourseData == '' || this.getCourseData == undefined)) {
            passportError = true;
        }

        if ((this.AdmissionStatus == 'Confirmed' || this.AdmissionStatus == 'Applied') && (this.universityName == '' || this.universityName == undefined)) {
            instituteError = true;
        }
        else if ((this.AdmissionStatus == 'Confirmed' || this.AdmissionStatus == 'Applied') && this.universityName != '' && (this.InstituteId == '' || this.InstituteId == undefined)) {
            instituteError = true;
        }
        else if ((this.AdmissionStatus == 'Confirmed' || this.AdmissionStatus == 'Applied') && this.universityName != '' && this.InstituteId != '' && (this.courseName == '' || this.courseName == undefined)) {
            courseError = true;
        }
        else if (this.langCategoryMetaData.length > 0) {
            const selectedRecord = this.langCategoryMetaData.find(record => record.Language_Category__c === this.LangScoreCategoryValue);

            if (selectedRecord) {
                var startRange = selectedRecord.Start_Range__c;
                var endRange = selectedRecord.End_Range__c;
                if (this.langTestScore < startRange || this.langTestScore > endRange) {
                    langScoreCategotyError = true;
                }
            }
        }

        if (this.analyticalCategoryMetaData.length > 0) {
            const selectedRecord1 = this.analyticalCategoryMetaData.find(record => record.Analytical_Category__c === this.AnalytScoreCategoryValue);

            if (selectedRecord1) {
                var startRange1 = selectedRecord1.Start_Range__c;
                var endRange1 = selectedRecord1.End_Range__c;
                if (this.analyticalTestScore < startRange1 || this.analyticalTestScore > endRange1) {
                    analyticalScoreCategotyError = true;
                }
            }
        }
        if (this.analyticalCategoryMetaDataGRE.length > 0) {
            const selectedRecord1 = this.analyticalCategoryMetaDataGRE.find(record => record.Analytical_Category_GRE__c === this.AnalytScoreCategoryValue);
            if (selectedRecord1) {
                var startRange2 = selectedRecord1.Start_Range__c;
                var endRange2 = selectedRecord1.End_Range__c;

                if ((this.AnalytScoreCategoryValue == 'GRE') && (this.quanTestScore == null || this.quanTestScore == '')) {
                    quantError = true;
                } else if (this.quanTestScore < startRange2 || this.quanTestScore > endRange2) {
                    analylScoreCateyGREQuatError = true;
                } else if ((this.AnalytScoreCategoryValue == 'GRE') && (this.verbalTestScore == null || this.verbalTestScore == '')) {
                    verbalError = true;
                } else if (this.verbalTestScore < startRange2 || this.verbalTestScore > endRange2) {
                    analytScoreCateyGREVerbalError = true;
                }
            }
        }

        if (this.QuesForEducationDetails == '' || this.QuesForEducationDetails == undefined) {
            highestEduQualiError = true;
        }

        // Iterate through the educational table
        if (this.listOfEducationalTable != null || this.listOfEducationalTable != undefined) {
            this.listOfEducationalTable.forEach((rec) => {
                if (rec.Education_Qualification__c == '10th') {
                    has10th = true;
                } else if (rec.Education_Qualification__c == '12th') {
                    has12th = true;
                } else if (rec.Education_Qualification__c == 'Graduate') {
                    hasGraduate = true;
                } else if (rec.Education_Qualification__c == 'Post Graduate') {
                    hasPostGraduate = true;
                } else if (rec.Education_Qualification__c == 'Diploma') {
                    hasDiploma = true;
                }
            });
        }

        // Check conditions based on QuesForEducationDetails value        
        if (this.AppliAccID == undefined) {
            applicantReqError = true;
        }
        else if (this.QuesForEducationDetails == '10th') {
            if (!has10th || has12th || hasGraduate || hasPostGraduate || hasDiploma) {
                eduErrorForOnlyReqTen = true;
            }
        } else if (this.QuesForEducationDetails == '12th') {
            if (!has10th || !has12th || hasGraduate || hasPostGraduate || hasDiploma) {
                eduErrorForTwlReqTen = true;
            }
        } else if (this.QuesForEducationDetails == 'Diploma') {
            if (!has10th || !hasDiploma || hasGraduate || hasPostGraduate) {
                eduErrorForDiplomaReqTen = true;
            }
        } else if (this.QuesForEducationDetails == 'Graduate') {
            if (!has10th || (!has12th && !hasDiploma) || !hasGraduate || hasPostGraduate) {
                eduErrorNotTenTwelve = true;
            }
        } else if (this.QuesForEducationDetails == 'Post Graduate') {
            if (!has10th || (!has12th && !hasDiploma) || !hasGraduate || !hasPostGraduate) {
                eduErrorPostGraduate = true;
            }
        }

        if (this.listOfEducationalTable != null || this.listOfEducationalTable != undefined) {
            for (var i = 0; i < this.listOfEducationalTable.length; i++) {
                var recEdu = this.listOfEducationalTable[i];
                if (recEdu.Education_Qualification__c == '10th') {
                    this.year10 = new Date(recEdu.Year_Completed__c).getFullYear();
                    var year10FullDate = new Date(recEdu.Year_Completed__c);
                }
                if (recEdu.Education_Qualification__c == '12th') {
                    this.year12 = new Date(recEdu.Year_Completed__c).getFullYear();
                    var year12FullDate = new Date(recEdu.Year_Completed__c);
                }
                if (recEdu.Education_Qualification__c == 'Graduate') {
                    var GradStartDate = new Date(recEdu.Course_Start_Date__c);
                    var GradEndDate = new Date(recEdu.Year_Completed__c);
                }

                if (recEdu.Education_Qualification__c == 'Post Graduate') {
                    var PostGradStartDate = new Date(recEdu.Course_Start_Date__c);
                    var PostGradEndDate = new Date(recEdu.Year_Completed__c);
                }

                if (recEdu.Education_Qualification__c == '12th' && this.year12 <= this.year10 && this.year10 !== '' && this.year12 !== '') {
                    tenYearNotTwelveNbefore = true;
                    if (tenYearNotTwelveNbefore)
                        break;
                }

                else if ((GradStartDate <= year10FullDate || GradStartDate <= year12FullDate) && (year10FullDate !== '' || year12FullDate !== '') && recEdu.Education_Qualification__c == 'Graduate') {
                    gradNotLessOrEqualTenTwelve = true;
                    if (gradNotLessOrEqualTenTwelve)
                        break;
                }
                else if ((PostGradStartDate <= year10FullDate || PostGradStartDate <= year12FullDate || PostGradStartDate <= GradStartDate) && (year10FullDate !== '' || year12FullDate !== '' || GradStartDate !== '') && recEdu.Education_Qualification__c == 'Post Graduate') {
                    postGradNotLessOrEqualTenTwelve = true;
                    if (postGradNotLessOrEqualTenTwelve)
                        break;
                }
                else if (PostGradStartDate <= GradEndDate && GradEndDate !== '' && recEdu.Education_Qualification__c == 'Post Graduate') {
                    postGradNotLessOrEqualTenTwelve = true;
                    if (postGradNotLessOrEqualTenTwelve)
                        break;
                }
            }
        }

        if (this.listOfEducationalTable != null || this.listOfEducationalTable != undefined) {
            for (var i = 0; i < this.listOfEducationalTable.length; i++) {
                var record = this.listOfEducationalTable[i];

                if (record.Education_Qualification__c == null) {
                    duplicateError = true;
                    if (duplicateError)
                        break;
                }
                if (record.Education_Qualification__c == '' || record.Education_Qualification__c == undefined ||
                    record.School_College_University__c == '' || record.School_College_University__c == undefined ||
                    record.Year_Completed__c == '' || record.Year_Completed__c == undefined ||
                    record.University_Name__c == '' || record.University_Name__c == undefined) {
                    educationError = true;
                    if (educationError)
                        break;
                }
                else if ((record.Education_Qualification__c == 'Graduate' || record.Education_Qualification__c == 'Post Graduate') && (record.Course_Start_Date__c == '' || record.Course_Start_Date__c == undefined)) {
                    courseStartError = true;
                    if (courseStartError)
                        break;
                }
                if (record.percentageNotValid == true) {
                    percentCgpaErrorNull = true;
                    if (percentCgpaErrorNull)
                        break;
                }
                else if (record.CGPAMarksNotValid == true) {
                    percentCgpaErrorNull = true;
                    if (percentCgpaErrorNull)
                        break;
                }
                else if (record.Percentage_Marks_CGPA__c > 100 || record.CGPA__c > 10.52 || record.Percentage_Marks_CGPA__c < 0 || record.CGPA__c < 0) {
                    percentCgpaErrorGreater = true;
                    if (percentCgpaErrorGreater)
                        break;
                }
                else if (record.Percentage_Marks_CGPA__c == '' /*|| record.CGPA__c == ''*/) {
                    percentCgpaErrorNull = true;
                    if (percentCgpaErrorNull)
                        break;
                }
                else if (recEdu.Type_of_Score__c == 'Percentage' && (recEdu.Percentage_Marks_CGPA__c == '' || recEdu.Percentage_Marks_CGPA__c == undefined)) {

                    perError = true;
                    if (perError)
                        break;
                }
                else if ((recEdu.Type_of_Score__c == '5 Point CGPA' || recEdu.Type_of_Score__c == '10 Point CGPA') && (recEdu.CGPA__c == '' || recEdu.CGPA__c == undefined)) {
                    cgpaError = true;
                    if (cgpaError)
                        break;
                }
            }
        }

        if (countryError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select Country of Study',
                    variant: 'error',
                }),
            );
        }
        else if (passportError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please ensure to add Passport Number in Applicant section',
                    variant: 'error',
                }),
            );
        }
        else if (isError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please fill in all mandatory fields for the Course details',
                    variant: 'Error',
                }),
            );
        }
        else if (universityError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please select University',
                    variant: 'Error',
                }),
            );
        }
        else if (instituteError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please select Institute',
                    variant: 'Error',
                }),
            );
        }
        else if (courseError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please select Course',
                    variant: 'Error',
                }),
            );
        }
        else if (duplicateError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please fill in all mandatory fields for the Education details',
                    variant: 'Error',
                }),
            );
        }
        else if (educationError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please fill in all mandatory fields for the Education details',
                    variant: 'Error',
                }),
            );
        }
        else if (courseStartError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please select Course Start Date',
                    variant: 'Error',
                }),
            );
        }
        else if (percentCgpaErrorNull) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter a valid percentage',
                    variant: 'Error',
                }),
            );
        }
        else if (percentCgpaErrorGreater) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter a valid percentage or CGPA',
                    variant: 'Error',
                }),
            );
        } else if (langScoreCategotyError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: `Language Test Score for ${this.LangScoreCategoryValue} must be between ${startRange} to ${endRange}.`,
                    variant: 'Error',
                }),
            );
        } else if (analyticalScoreCategotyError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: `Analytical Test Score for ${this.AnalytScoreCategoryValue} must be between ${startRange1} to ${endRange1}.`,
                    variant: 'Error',
                }),
            );
        } else if (analylScoreCateyGREQuatError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: `Quantitative Test Score for ${this.AnalytScoreCategoryValue} must be between ${startRange2} to ${endRange2}.`,
                    variant: 'Error',
                }),
            );
        } else if (analytScoreCateyGREVerbalError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: `Verbal Test Score for ${this.AnalytScoreCategoryValue} must be between ${startRange2} to ${endRange2}.`,
                    variant: 'Error',
                }),
            );
        } else if (quantError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter valid a Quantitative Score.',
                    variant: 'Error',
                }),
            );
        } else if (verbalError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter valid a Verbal Score.',
                    variant: 'Error',
                }),
            );
        } else if (highestEduQualiError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please select the Highest Education Qualification.',
                    variant: 'Error',
                }),
            );
        } else if (applicantReqError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Applicant record is mandatory for Education Details.',
                    variant: 'Error',
                }),
            );
        } else if (tenYearNotTwelveNbefore) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'The End date of 12th grade must be after the End date of 10th grade.',
                    variant: 'Error',
                }),
            );
        } else if (gradNotLessOrEqualTenTwelve) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'The Start date of Graduation must be after the End date of 12th grade.',
                    variant: 'Error',
                }),
            );
        } else if (postGradNotLessOrEqualTenTwelve) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'The Start date of Post Graduation must be after the End date of Graduation or the End date of 12th grade.',
                    variant: 'Error',
                }),
            );
        }
        else if (perError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please provide the percentage.',
                    variant: 'Error',
                }),
            );
        }
        else if (cgpaError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please provide the CGPA',
                    variant: 'Error',
                }),
            );
        } else if (eduErrorForOnlyReqTen) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Add only 10th details for highest qualification as 10th',
                    variant: 'Error',
                }),
            );
        } else if (eduErrorForTwlReqTen) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Add only 10th & 12th details for highest qualification as 12th',
                    variant: 'Error',
                }),
            );
        } else if (eduErrorForDiplomaReqTen) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Add only 10th & Diploma details for highest qualification as Diploma',
                    variant: 'Error',
                }),
            );
        } else if (eduErrorNotTenTwelve) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Add only 10th, 12th or Diploma & Graduation details for highest qualification as Graduation',
                    variant: 'Error',
                }),
            );
        } else if (eduErrorPostGraduate) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Add only 10th, 12th or Diploma, Graduation & Post-Graduation details for highest qualification as Post-Graduation',
                    variant: 'Error',
                }),
            );
        }
        else {
            this.isLoading = true;

            let sum = 0;
            if (this.courseCheck == true) {
                sum = 0;
            }
            else {
                //Get the weightage for Applicant Section
                getSectionWeightage({ sectionName: 'Course' })
                    .then(result => {
                        sum = result;
                    })
                    .catch(error => {

                    })
            }
            let CourseSecSaveRec = {
                Id: this.leadID,
                Institute_Name__c: this.InstituteId,
                Country_of_Study__c: this.CountryOfStudyValue,
                Admission_Status__c: this.AdmissionStatus,
                University_Name__c: this.universityName,
                Campus__c: this.courseCampus,
                Course_Category__c: this.CourseCategoryValue,
                Course_Type__c: this.CourseTypeValue,
                Course_Level__c: this.CourseLevelValue,
                Course_Stream__c: this.selectedCourStreamValue,
                Course_Sub_Stream__c: this.selectedCourSubStreamValue,
                Course_Id__c: this.courseName,
                Course_Start_Date__c: this.courseStartDate,
                Course_End_Date__c: this.courseEndDate,
                Language_Score_Category__c: this.LangScoreCategoryValue,
                Language_Test_Score__c: this.langTestScore,
                Analytics_Score_Category__c: this.AnalytScoreCategoryValue,
                Analytics_Test_Score__c: this.analyticalTestScore,
                Verbal_Score__c: this.verbalTestScore,
                Quantitative_Score__c: this.quanTestScore,
                Highest_Education_Qualification__c: this.QuesForEducationDetails,
                Course_Section__c: true,
                Course_Duration_Months__c: this.CourseDurationValue,
                Intake__c: this.Intake
            }
            let CourseAppliAccDataSaveRec = {
                Id: this.AppliAccID
            }
            if (this.deleteEmpIds !== '') {
                this.deleteEmpIds = this.deleteEmpIds.substring(0);
            }

            this.listOfEducationalTable.forEach(res => {
                if (!isNaN(res.Id)) {
                    res.Id = null;
                }
            });
            this.listOfEducationalTable.forEach(res => {
                res.finalDependentVal = null;
            });

            //Wrapper Class variable      
            let wrapperCommFormRecord = {
                leadSaveRec: JSON.stringify(CourseSecSaveRec),
                appliEduDetailsSave: JSON.stringify(this.listOfEducationalTable),
                appliAccSaveRec: JSON.stringify(CourseAppliAccDataSaveRec),
                removeEducationIds: this.deleteEmpIds
            }

            createUpdateLeadWithRelatedInformation({
                wrapperLoanApplicationForm: JSON.stringify(wrapperCommFormRecord),
                leadGetId: this.leadRecordId
            })
                .then(response => {
                    this.wrapperLoanApplicationFormResult = response;                    
                    //Lead Applicant                    
                    this.leadID = this.wrapperLoanApplicationFormResult.leadRecords.Id;                   
                    this.CountryOfStudyValue = this.wrapperLoanApplicationFormResult.leadRecords.Country_of_Study__c;
                    this.AdmissionStatus = this.wrapperLoanApplicationFormResult.leadRecords.Admission_Status__c;
                    this.universityName = this.wrapperLoanApplicationFormResult.leadRecords.University_Name__c;
                    this.courseCampus = this.wrapperLoanApplicationFormResult.leadRecords.Campus__c;
                    this.InstituteId = this.wrapperLoanApplicationFormResult.leadRecords.Institute_Name__c;
                    this.CourseCategoryValue = this.wrapperLoanApplicationFormResult.leadRecords.Course_Category__c;
                    this.CourseTypeValue = this.wrapperLoanApplicationFormResult.leadRecords.Course_Type__c;
                    this.CourseLevelValue = this.wrapperLoanApplicationFormResult.leadRecords.Course_Level__c;
                    this.selectedCourStreamValue = this.wrapperLoanApplicationFormResult.leadRecords.Course_Stream__c;
                    this.selectedCourSubStreamValue = this.wrapperLoanApplicationFormResult.leadRecords.Course_Sub_Stream__c;
                    this.courseName = this.wrapperLoanApplicationFormResult.leadRecords.Course_Id__c;
                    this.courseStartDate = this.wrapperLoanApplicationFormResult.leadRecords.Course_Start_Date__c;
                    this.courseEndDate = this.wrapperLoanApplicationFormResult.leadRecords.Course_End_Date__c;
                    this.LangScoreCategoryValue = this.wrapperLoanApplicationFormResult.leadRecords.Language_Score_Category__c;
                    this.langTestScore = this.wrapperLoanApplicationFormResult.leadRecords.Language_Test_Score__c;
                    this.AnalytScoreCategoryValue = this.wrapperLoanApplicationFormResult.leadRecords.Analytics_Score_Category__c;
                    this.analyticalTestScore = this.wrapperLoanApplicationFormResult.leadRecords.Analytics_Test_Score__c;
                    this.courseCheck = this.wrapperLoanApplicationFormResult.leadRecords.Course_Section__c;
                    this.QuesForEducationDetails = this.wrapperLoanApplicationFormResult.leadRecords.Highest_Education_Qualification__c;
                    this.CourseDurationValue = this.wrapperLoanApplicationFormResult.leadRecords.Course_Duration_Months__c;
                    this.Intake = this.wrapperLoanApplicationFormResult.leadRecords.Intake__c;

                    //Check if Admission Status is Confirmed or Applied then show Universityn campus & Institute fields
                    if (this.AdmissionStatus == "Confirmed" || this.AdmissionStatus == "Applied") {
                        this.ShowFieldsCourseUniversity = true;
                    }
                    else {
                        this.ShowFieldsCourseUniversity = false;
                    }

                    if (this.AnalytScoreCategoryValue === "GRE") {
                        this.isQuantVerbalShowHide = true;
                    } else {
                        this.isQuantVerbalShowHide = false;
                    }

                    if (this.AnalytScoreCategoryValue === "NA") {
                        this.isAnalyticScoreShowHide = false;
                    } else {
                        this.isAnalyticScoreShowHide = true;
                    }
                    if (this.LangScoreCategoryValue === "NA") {
                        this.isLangScoreShowHide = false;
                    } else {
                        this.isLangScoreShowHide = true;
                    }

                    if (this.wrapperLoanApplicationFormResult.appliEduDetailsRecord.length > 0) {
                        this.listOfEducationalTable = JSON.parse(JSON.stringify(this.wrapperLoanApplicationFormResult.appliEduDetailsRecord));
                    } else {
                        let randomId = Math.random() * 16;
                        let myNewElement = { Id: randomId, Education_Qualification__c: "", Year_Completed__c: "", Percentage_Marks_CGPA__c: "", CGPA__c: "", School_College_University__c: "", Course_Name__c: "", Course_Stream__c: "", Intake__c: "" };
                        this.listOfEducationalTable = [myNewElement];
                    }
                    this.listOfEducationalTable.forEach(element => {
                        if (element.Education_Qualification__c == 'Graduate' || element.Education_Qualification__c == 'Post Graduate') {
                            element.startDate = true;
                        }
                        if (element.Type_of_Score__c === 'Percentage')
                            element.cgpaDisable = true;
                        else
                            element.cgpaDisable = false;
                        this.fetchDependentValueOnLoad(element);
                        var dependentPicklist = document.querySelector('lightning-combobox[name="CourseStreamEdu"][data-id="' + element.Id + '"]');

                        if (dependentPicklist) {
                            dependentPicklist.disabled = false;
                            dependentPicklist.value = rec.Course_Stream__c;
                        }
                    });
                    if (this.listOfEducationalTable.length > 0) {
                        this.listOfEducationalTable.length + 1;
                    }
                    //Applicant Account
                    this.AppliAccID = this.wrapperLoanApplicationFormResult.accRecords.Account__c;
                    if (response != null) {
                        console.log('response inside if=====>' + response);
                    }
                    this.isLoading = false;

                    //Progress bar update
                    if (sum != 0) {
                        let newPerc = sum;

                        //Update the weightage
                        updateLeadTotalPercentage({ leadId: this.leadRecordId, percentage: newPerc })
                            .then(result => {
                                let ProgrssValueOfLoanSection = { ProgrssValueOfLoanSection: result };
                                publish(this.messageContext, progressBar, ProgrssValueOfLoanSection);

                            })
                            .catch(error => {
                                console.error(error);
                                // Add any error handling here
                            });
                    }
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Successfully Saved',
                            variant: 'Success',
                        }),
                    );
                    //send success msg to submit button 
                    let courseandAcademicsSection = false;
                    publish(this.messageContext, SUBMITACTION, {
                        courseandAcademicsSection: courseandAcademicsSection
                    });
                    // next section
                    const onNextEvent = new CustomEvent('next', {
                        detail: {
                            nextValue: '4',
                        },
                    });
                    this.dispatchEvent(onNextEvent);

                }).catch(error => {
                    console.log(error);
                    this.isLoading = false;
                    this.handleErrorMessage(error);
                })
        }
    }

    handleCourseDuration(event) {

        if (event.target.name == "Course Duration (Months)") {
            this.CourseDurationValue = event.target.value;
        }

        if (this.courseStartDate != undefined) {
            // Retrieve the selected course start date and duration value
            const courseStartDate = new Date(this.courseStartDate);

            const courseDurationValue = parseInt(this.CourseDurationValue);

            // Calculate the course end date
            const courseEndDate = new Date(courseStartDate.getFullYear() + Math.floor(courseDurationValue / 12), courseStartDate.getMonth() + (courseDurationValue % 12), courseStartDate.getDate());

            // Format the course end date in 'dd/MM/yyyy' format
            const formattedEndDate = courseEndDate.toISOString().split('T')[0];

            // Assign the formatted end date to the component property
            this.courseEndDate = formattedEndDate;
        }
    }

    handleErrorMessage(error) {

        console.log('ERrrorr ' , JSON.stringify(error))
        let errorMessage = 'An error occurred';
        let finalErrorMessage = JSON.stringify(error);
        if (error.body && error.body.fieldErrors &&  Object.keys(error.body.fieldErrors).length > 0) {
            console.log('INSIDE IF');
            const fieldErrors = error.body.fieldErrors;
            const firstFieldName = Object.keys(fieldErrors)[0];
            if (fieldErrors[firstFieldName].length > 0) {
                errorMessage = fieldErrors[firstFieldName][0].message;
            }
        } else if (error.body.pageErrors && error.body.pageErrors.length > 0) {
            console.log('INSIDE ELSE IF');
            errorMessage = error.body.pageErrors[0].message;
        } else {
            console.log('INSIDE ELSE');
            errorMessage = finalErrorMessage;
        }

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error!!',
                message: errorMessage,
                variant: 'Error',
            }),
        );
    }

    setcourestreamvalue() {

        this.listOfEducationalTable?.forEach(element => {
            this.fetchDependentValueOnLoad(element);
            var dependentPicklist = document.querySelector('lightning-combobox[name="CourseStreamEdu"][data-id="' + element.Id + '"]');

            if (dependentPicklist) {
                dependentPicklist.disabled = false;
                dependentPicklist.value = rec.Course_Stream__c;
            }
        });
    }

    setcourestreamvalueCourseSec() {
        this.fetchCourseStreamValuesOnLoad(this.selectedCourSubStreamValue);
        var dependentPicklist = document.querySelector('lightning-combobox[name="Course Stream"]');
        if (dependentPicklist) {
        dependentPicklist.value = this.selectedCourStreamValue;
        }
    }
}