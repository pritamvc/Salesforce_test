import { LightningElement, wire, api, track } from 'lwc';
import creatCommFormLeadRecords from '@salesforce/apex/TempControllerSohail.creatCommFormLeadRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import getInstituteRecord from '@salesforce/apex/TempControllerSohail.getInstituteRecord';
import getUniversityNameCourse from '@salesforce/apex/TempControllerSohail.getUniversityNameCourse';
import getCourseEducationaData from '@salesforce/apex/TempControllerSohail.getWrapperClassCommFormList';
import getCourseIdName from '@salesforce/apex/TempControllerSohail.getCourseIdName';
import fetchLanguageCategory from '@salesforce/apex/TempControllerSohail.fetchLanguageCategory';
import fetchAnalyticalCategory from '@salesforce/apex/TempControllerSohail.fetchAnalyticalCategory';
import fetchAnalyticalCategoryGRE from '@salesforce/apex/TempControllerSohail.fetchAnalyticalCategoryGRE';
import getUniversityName from '@salesforce/apex/CourseSectionLookupField.getUniversityName';
import getLookupData from '@salesforce/apex/CourseSectionLookupField.getLookupData';
import getLeadTotalPercentage from '@salesforce/apex/DocumentVerification.getLeadTotalPercentage';
import updateLeadTotalPercentage from '@salesforce/apex/DocumentVerification.updateLeadTotalPercentage';
import updateCoursePercentage from '@salesforce/apex/ProgressBarPercent.updateCoursePercentage';
import getLeadCoursePercentage from '@salesforce/apex/ProgressBarPercent.getLeadCoursePercentage';
import SUBMITACTION from '@salesforce/messageChannel/submit__c';
import progressBar from '@salesforce/messageChannel/progressBar__c';
import { publish, MessageContext } from 'lightning/messageService';
import getInstituteFromUniversity from '@salesforce/apex/TempControllerSohail.getInstituteFromUniversity';

export default class CourseAcademicsChild extends LightningElement {
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
    //Course Stream from SFDC
    @track CourseStream;
    @api CourseStreamField = 'Course_Stream__c';
    @track CourseStreamLabel;
    @api CourseStreamValue;
    @track CourseStreamOptions;
    apiCourseStream;
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
    //Education Details from SFDC
    @api objectNameEduDetails = 'Education_Details__c';
    @api recordTypeId2;
    @track EducationDetails;
    @api EducationDetailsField = 'Education_Qualification__c';
    @track EducationDetailsLabel;
    @api EducationDetailsValue;
    @track EducationDetailsOptions;
    apiEducationDetails;

    @track YearCompleted;
    @track PercentageMarks;
    @track SchoolCollegeUniversity;

    //Institute creation on Lead lookup
    // @track selectedAccount; 
    @track ApplicantPassportNumber = '';
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

    @track nextPage = false;

    @wire(getObjectInfo, { objectApiName: '$objectName' })
    getObjectData1({ error, data }) {
        if (data) {
            if (this.recordTypeId == null)
                this.recordTypeId = data.defaultRecordTypeId;

            this.apiCountryOfStudyObjFieldName = this.objectName + '.' + this.CountryOfStudyField;
            this.CountryOfStudyLabel = data.fields[this.CountryOfStudyField].label;

            this.apiAdmissionStatus = this.objectName + '.' + this.AdmissionStatusField;
            this.AdmissionStatusLabel = data.fields[this.AdmissionStatusField].label;

            this.apiCourseCategory = this.objectName + '.' + this.CourseCategoryField;
            this.CourseCategoryLabel = data.fields[this.CourseCategoryField].label;

            this.apiCourseType = this.objectName + '.' + this.CourseTypeField;
            this.CourseTypeLabel = data.fields[this.CourseTypeField].label;

            this.apiCourseLevel = this.objectName + '.' + this.CourseLevelField;
            this.CourseLevelLabel = data.fields[this.CourseLevelField].label;

            this.apiCourseStream = this.objectName + '.' + this.CourseStreamField;
            this.CourseStreamLabel = data.fields[this.CourseStreamField].label;

            this.apiLangScoreCategory = this.objectName + '.' + this.LangScoreCategoryField;
            this.LangScoreCategoryLabel = data.fields[this.LangScoreCategoryField].label;

            this.apiAnalytScoreCategory = this.objectName + '.' + this.AnalytScoreCategoryField;
            this.AnalytScoreCategoryLabel = data.fields[this.AnalytScoreCategoryField].label;

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
            console.log('==============CountryOfStudyFieldOptionsdata  ' + data);

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
            console.log('==============AdmissionStatusOptions' + data);

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
            console.log('==============CourseCategoryOptions' + data);

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
            console.log('==============CourseCategoryOptions' + data);

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
            console.log('==============CourseLevelOptions' + data);

        } else if (error) {
            console.log(error);
        }
    }

    //Course Stream   
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: '$apiCourseStream' })
    getPicklistValues7({ error, data }) {
        if (data) {
            this.CourseStreamOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };
            });
            console.log('==============CourseCategoryOptions' + data);

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
            console.log('==============CourseCategoryOptions' + data);

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
            console.log('==============CourseCategoryOptions' + data);

        } else if (error) {
            console.log(error);
        }
    }

    //Education Details Picklist field from SFDC
    @wire(getObjectInfo, { objectApiName: '$objectNameEduDetails' })
    getObjectData3({ error, data }) {
        console.log('Inside objectNameEduDetails: Edu Details');
        console.log('objectApiName' + this.objectApiName);
        if (data) {
            console.log('Inside if');
            if (this.recordTypeId2 == null)
                console.log('Inside recordTypeId2');
            this.recordTypeId2 = data.defaultRecordTypeId;
            console.log('Inside this.recordTypeId2' + this.recordTypeId2); //its Edu details acc recordtpye
            //Education Details
            this.apiEducationDetails = this.objectNameEduDetails + '.' + this.EducationDetailsField;
            this.EducationDetailsLabel = data.fields[this.EducationDetailsField].label;
        } else if (error) {
            // Handle error
            console.log('==============Error ');
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
            console.log('==============EducationDetailsOptions' + data);

        } else if (error) {
            // Handle error
            console.log('==============Error  ' + error);
            console.log(error);
        }
    }
    @track endDateGreaterStart;
    connectedCallback() {
        console.log("getCourseData connectedCallback:", this.getCourseData);
        this.getCourseEducationaFunction();
        this.getLangScoreCategoryFunc();
        this.getanalyticalScoreCategoryFunc();
        this.getanalyticalScoreCategoryGREFunc();
        //this.triggerEventOnce();              
        this.todaysDate = new Date().toISOString().split('T')[0];
    }
    @track langCategoryMetaData;
    //Get Metadata Language Category 
    getLangScoreCategoryFunc() {
        fetchLanguageCategory({})
            .then(result => {
                console.log('fetchLanguageCategory', result);
                this.langCategoryMetaData = result;
                console.log('this.langCategoryMetaData', JSON.stringify(this.langCategoryMetaData));
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
                console.log('fetchAnalyticalCategory', result);
                this.analyticalCategoryMetaData = result;
                console.log('this.analyticalCategoryMetaData', JSON.stringify(this.analyticalCategoryMetaData));
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
                console.log('fetchAnalyticalCategoryGRE', result);
                this.analyticalCategoryMetaDataGRE = result;
                console.log('this.analyticalCategoryMetaDataGRE', JSON.stringify(this.analyticalCategoryMetaDataGRE));
            })
            .catch(error => {
                console.log('fetchAnalyticalCategoryGRE error', error);
            });
    }

    //Get Course and education data
    getCourseEducationaFunction() {
        console.log("DATA NEW COURSE EDU 3");
        console.log('Lead Id', this.leadRecordId);
        getCourseEducationaData({ leadGetId: this.leadRecordId })
            .then(result => {
                this.wrapperForCommLeadForm = result;
                console.log('Lead Data and Education Data', +this.wrapperForCommLeadForm);

                //Lead 
                this.leadID = this.wrapperForCommLeadForm.LeadRecords.Id;
                console.log('this.leadID data===>' + this.leadID);

                this.CountryOfStudyValue = this.wrapperForCommLeadForm.LeadRecords.Country_of_Study__c;
                this.AdmissionStatus = this.wrapperForCommLeadForm.LeadRecords.Admission_Status__c;
                console.log('this.AdmissionStatus data===>' + this.AdmissionStatus);
                this.universityName = this.wrapperForCommLeadForm.LeadRecords.University_Name__c;
                this.courseCampus = this.wrapperForCommLeadForm.LeadRecords.Campus__c;
                this.InstituteId = this.wrapperForCommLeadForm.LeadRecords.Institute_Name__c;
                this.CourseCategoryValue = this.wrapperForCommLeadForm.LeadRecords.Course_Category__c;
                console.log('this.CourseCategoryValue data===>' + this.CourseCategoryValue);
                this.CourseTypeValue = this.wrapperForCommLeadForm.LeadRecords.Course_Type__c;
                this.CourseLevelValue = this.wrapperForCommLeadForm.LeadRecords.Course_Level__c;
                this.CourseStreamValue = this.wrapperForCommLeadForm.LeadRecords.Course_Stream__c;
                this.courseName = this.wrapperForCommLeadForm.LeadRecords.Course_Id__c;
                this.courseStartDate = this.wrapperForCommLeadForm.LeadRecords.Course_Start_Date__c;
                this.courseEndDate = this.wrapperForCommLeadForm.LeadRecords.Course_End_Date__c;
                this.LangScoreCategoryValue = this.wrapperForCommLeadForm.LeadRecords.Language_Score_Category__c;
                this.langTestScore = this.wrapperForCommLeadForm.LeadRecords.Language_Test_Score__c;
                this.AnalytScoreCategoryValue = this.wrapperForCommLeadForm.LeadRecords.Analytics_Score_Category__c;
                this.analyticalTestScore = this.wrapperForCommLeadForm.LeadRecords.Analytics_Test_Score__c;
                this.quanTestScore = this.wrapperForCommLeadForm.LeadRecords.Quantitative_Score__c;
                this.verbalTestScore = this.wrapperForCommLeadForm.LeadRecords.Verbal_Score__c;
                this.ApplicantPassportNumber = this.wrapperForCommLeadForm.LeadRecords.Passport_Number__c;
                console.log('passport number:' + this.ApplicantPassportNumber);

                    getUniversityName({ parentId: this.InstituteId })
                    .then(result => {
                        this.ShowFieldsCourseUniversity = true;
                        console.log('result====University Name===> ' + JSON.stringify(result));
                    
                        // Extract the university name and ID from the result map
                        const universityName = Object.keys(result)[0];
                        const universityId = result[universityName];

                        // Assign the values to the respective variables
                        this.universityName = universityId;
                        this.universityNameString = universityName;
                      })
                      .catch(error => {
                        this.errors = error;
                        console.log('errors=======> ' + this.errors);
                      });
                

                //Check if Admission Status is Confirmed or Applied then show Universityn campus & Institute fields
                if (this.AdmissionStatus == "Confirmed" || this.AdmissionStatus == "Applied") {
                    this.ShowFieldsCourseUniversity = true;
                    console.log("this.ShowFieldsCourseUniversity====  " + this.ShowFieldsCourseUniversity);
                }
                else {
                    this.ShowFieldsCourseUniversity = false;
                    console.log("this.ShowFieldsCourseUniversity====  " + this.ShowFieldsCourseUniversity);
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
                //Education Data
                console.log("this.wrapperForCommLeadForm.AppliEduDetailsRecord.length===>" + this.wrapperForCommLeadForm.AppliEduDetailsRecord.length);
                if (this.wrapperForCommLeadForm.AppliEduDetailsRecord.length > 0) {
                    this.listOfEducationalTable = JSON.parse(JSON.stringify(this.wrapperForCommLeadForm.AppliEduDetailsRecord));
                } else {
                    let randomId = Math.random() * 16;
                    let myNewElement = { Id: randomId, Education_Qualification__c: "", Year_Completed__c: null, Percentage_Marks_CGPA__c: "", CGPA__c: "", School_College_University__c: "", University_Name__c: "", Course_Name__c: "", Course_Stream__c: "", Course_Start_Date__c: null };
                    console.log("myNewElement===>" + myNewElement);
                    this.listOfEducationalTable = [myNewElement];

                    console.log("this.listOfEducationalTable===>" + this.listOfEducationalTable);
                }
                if (this.listOfEducationalTable.length > 0) {
                    this.listOfEducationalTable.length + 1;
                }

                this.listOfEducationalTable.forEach(element => {
                    if (element.Education_Qualification__c === 'Graduate' || element.Education_Qualification__c === 'Post Graduate') {
                        element.startDate = true;
                    }
                });
                //Applicant Account
                this.AppliAccID = this.wrapperForCommLeadForm.AccRecords.Account__c;
                console.log('this.AppliAccID data===>' + this.AppliAccID);

                console.log(error);
                this.error = error;
            })
            .catch(error => {
            });
    }

    //Education Section add row
    addRow() {
        let randomId = Math.random() * 16;
        console.log("randomId===>" + randomId);
        let myNewElement = { Id: randomId, Education_Qualification__c: "", Year_Completed__c: null, Percentage_Marks_CGPA__c: "", CGPA__c: "", School_College_University__c: "", University_Name__c: "", Course_Name__c: "", Course_Stream__c: "", Course_Start_Date__c: null };
        console.log("myNewElement===>" + myNewElement);
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

        console.log("this.listOfEducationalTableaddRow===>" + this.listOfEducationalTable);
    }
    //Education Section Delete row
    @track deleteEmpIds = '';
    removeTheRowEducational(event) {
        console.log("Remove clicked ");
        if (isNaN(event.target.dataset.id)) {
            this.deleteEmpIds = this.deleteEmpIds + ',' + event.target.dataset.id;
        }
        console.log("this.deleteEmpIds== " + this.deleteEmpIds);
        console.log("this.deleteEmpIds.length== " + this.deleteEmpIds.length);
        console.log("this.listOfEducationalTable.length== " + this.listOfEducationalTable.length);
        if (this.listOfEducationalTable.length > 1) {
            this.listOfEducationalTable.splice(this.listOfEducationalTable.findIndex(row => row.Id === event.target.dataset.id), 1);
        }
    }

    // Education field onchange method
    handlechange(event) {
        if (event.target.name == "Country of Study") {
            this.CountryOfStudyValue = event.target.value;
            console.log("getCourseData handlechange:", this.getCourseData);
            if (this.AdmissionStatus == 'Applied' || this.AdmissionStatus == 'Confirmed') {
                this.AdmissionStatus = '';
                this.ShowFieldsCourseUniversity = false;
                this.universityName = '';
                this.universityNameString = '';
                this.InstituteId = '';
                this.courseName = '';
                console.log(this.AdmissionStatus);
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
            console.log("this.CountryOfStudyValue====  " + this.CountryOfStudyValue);
        }
        if (event.target.name == "courseTel" && event.target.value != "") {
            this.courseTel = event.target.value;
            console.log("this.courseTel====  " + this.courseTel);
        }
        if (event.target.name == "URLWeb" && event.target.value != "") {
            this.URLWeb = event.target.value;
            console.log("this.URLWeb====  " + this.URLWeb);
        }
        if (event.target.name == "contPersonInstitute" && event.target.value != "") {
            this.contPersonInstitute = event.target.value;
            console.log("this.contPersonInstitute====  " + this.contPersonInstitute);
        }
        if (event.target.name == "contPersonNum" && event.target.value != "") {
            this.contPersonNum = event.target.value;
            console.log("this.contPersonNum====  " + this.contPersonNum);
        }
        if (event.target.name == "contPersonEmail" && event.target.value != "") {
            this.contPersonEmail = event.target.value;
            console.log("this.contPersonEmail====  " + this.contPersonEmail);
        }
        if (event.target.name == "Campus") {
            this.courseCampus = event.target.value;
            console.log("this.courseCampus====  " + this.courseCampus);
        }
        if (event.target.name == "Course Category") {
            this.CourseCategoryValue = event.target.value;
            console.log("this.CourseCategoryValue====  " + this.CourseCategoryValue);
        }
        if (event.target.name == "Course Type") {
            this.CourseTypeValue = event.target.value;
            console.log("this.CourseTypeValue====  " + this.CourseTypeValue);
        }
        if (event.target.name == "Course Level") {
            this.CourseLevelValue = event.target.value;
            console.log("this.CourseLevelValue====  " + this.CourseLevelValue);
        }
        if (event.target.name == "Course Stream") {
            this.CourseStreamValue = event.target.value;
            console.log("this.CourseStreamValue====  " + this.CourseStreamValue);
        }
        if (event.target.name == "analyticalTestScore") {
            this.analyticalTestScore = event.target.value;
            console.log("this.analyticalTestScore====  " + this.analyticalTestScore);
        }
    }

    //Handle change for Language Score Category and Language Test Score
    handleLangScore(event) {
        const fieldName = event.target.name;
        const fieldValue = event.target.value;
        if (fieldName === "Language Score Category") {
            this.LangScoreCategoryValue = fieldValue;
            console.log("this.LangScoreCategoryValue====  " + this.LangScoreCategoryValue);
        } else if (fieldName === "langTestScore") {
            this.langTestScore = fieldValue;
            console.log("this.langTestScore====  " + this.langTestScore);
            console.log("this.LangScoreCategoryValue HC====  " + this.LangScoreCategoryValue);
            console.log("this.langCategoryMetaData HC====  " + this.langCategoryMetaData);

            const selectedRecord = this.langCategoryMetaData.find(record => record.Language_Category__c === this.LangScoreCategoryValue);

            if (selectedRecord) {
                const startRange = selectedRecord.Start_Range__c;
                console.log("startRange HC====  " + startRange);
                const endRange = selectedRecord.End_Range__c;
                console.log("endRange HC====  " + endRange);
                if (this.langTestScore < startRange || this.langTestScore > endRange) {
                    const toastEvent = new ShowToastEvent({
                        title: "Invalid Score",
                        message: `Language Test Score for ${this.LangScoreCategoryValue} should be ${startRange} to ${endRange}.`,
                        // message: `The language test score is not within the valid range for ${this.LangScoreCategoryValue}`,
                        variant: "error"
                    });
                    this.dispatchEvent(toastEvent);
                }
            }
        }
    }

    @track isQuantVerbalShowHide = false;
    @track isAnalyticScoreShowHide = false;
    //Handle change for Analytical Score Category and Analytical Test Score
    handleAnalyticalScore(event) {
        const fieldName = event.target.name;
        const fieldValue = event.target.value;
        if (fieldName === "Analytics Score Category") {
            this.AnalytScoreCategoryValue = fieldValue;
            console.log("this.AnalytScoreCategoryValue====  " + this.AnalytScoreCategoryValue);

            if (this.AnalytScoreCategoryValue === "GRE") {
                this.isQuantVerbalShowHide = true;
                console.log("this.isQuantVerbalShowHide if====  " + this.isQuantVerbalShowHide);
            } else {
                this.isQuantVerbalShowHide = false;
                console.log("this.isQuantVerbalShowHide else====  " + this.isQuantVerbalShowHide);
                this.quanTestScore = null;
                this.verbalTestScore = null;
                // this.analyticalTestScore = null;
            }
            if (this.AnalytScoreCategoryValue === "NA") {
                this.isAnalyticScoreShowHide = false;
                this.quanTestScore = null;
                this.verbalTestScore = null;
                //this.analyticalTestScore = null;
                console.log("this.isAnalyticScoreShowHide if====  " + this.isAnalyticScoreShowHide);
            } else {
                this.isAnalyticScoreShowHide = true;
                console.log("this.isAnalyticScoreShowHide else====  " + this.isAnalyticScoreShowHide);

            }

        } else if (fieldName === "analyticalTestScore") {
            this.analyticalTestScore = fieldValue;
            console.log("this.analyticalTestScore====  " + this.analyticalTestScore);
            console.log("this.AnalytScoreCategoryValue HC====  " + this.AnalytScoreCategoryValue);
            console.log("this.analyticalCategoryMetaData HC====  " + this.analyticalCategoryMetaData);

            const selectedRecord = this.analyticalCategoryMetaData.find(record => record.Analytical_Category__c === this.AnalytScoreCategoryValue);

            if (selectedRecord) {
                const startRange = selectedRecord.Start_Range__c;
                console.log("startRange HC====  " + startRange);
                const endRange = selectedRecord.End_Range__c;
                console.log("endRange HC====  " + endRange);
                if (this.analyticalTestScore < startRange || this.analyticalTestScore > endRange) {
                    const toastEvent = new ShowToastEvent({
                        title: "Invalid Score",
                        message: `Analytical Test Score for ${this.AnalytScoreCategoryValue} should be ${startRange} to ${endRange}.`,
                        // message: `The analytical test score is not within the valid ${startRange} - ${endRange} for ${this.AnalytScoreCategoryValue}`,
                        variant: "error"
                    });
                    this.dispatchEvent(toastEvent);
                }
            }
        }
        if (fieldName === "QuanTestScore") {
            this.quanTestScore = fieldValue;
            console.log("this.quanTestScore HC 3====  " + this.quanTestScore);
            console.log("this.AnalytScoreCategoryValue HC 3====  " + this.AnalytScoreCategoryValue);
            console.log("this.analyticalCategoryMetaDataGRE HC 3====  " + this.analyticalCategoryMetaDataGRE);

            const selectedRecord1 = this.analyticalCategoryMetaDataGRE.find(record => record.Analytical_Category_GRE__c === this.AnalytScoreCategoryValue);

            if (selectedRecord1) {
                const startRange = selectedRecord1.Start_Range__c;
                console.log("startRange HC 3====  " + startRange);
                const endRange = selectedRecord1.End_Range__c;
                console.log("endRange HC 3====  " + endRange);
                if (this.quanTestScore < startRange || this.quanTestScore > endRange) {
                    const toastEvent = new ShowToastEvent({
                        title: "Invalid Score",
                        message: `Quantitative Test Score for ${this.AnalytScoreCategoryValue} should be ${startRange} to ${endRange}.`,
                        // message: `The quantitative test score is not within the valid range for ${this.AnalytScoreCategoryValue}`,
                        variant: "error"
                    });
                    this.dispatchEvent(toastEvent);
                }
            }
        }

        if (fieldName === "VerbalTestScore") {
            this.verbalTestScore = fieldValue;
            console.log("this.verbalTestScore HC 4====  " + this.verbalTestScore);
            console.log("this.AnalytScoreCategoryValue HC 4====  " + this.AnalytScoreCategoryValue);
            console.log("this.analyticalCategoryMetaDataGRE HC 4====  " + this.analyticalCategoryMetaDataGRE);

            const selectedRecord1 = this.analyticalCategoryMetaDataGRE.find(record => record.Analytical_Category_GRE__c === this.AnalytScoreCategoryValue);

            if (selectedRecord1) {
                const startRange = selectedRecord1.Start_Range__c;
                console.log("startRange HC 3====  " + startRange);
                const endRange = selectedRecord1.End_Range__c;
                console.log("endRange HC 3====  " + endRange);
                if (this.verbalTestScore < startRange || this.verbalTestScore > endRange) {
                    const toastEvent = new ShowToastEvent({
                        title: "Invalid Score",
                        message: `Verbal Test Score for ${this.AnalytScoreCategoryValue} should be ${startRange} to ${endRange}.`,
                        // message: `The verbal test score is not within the valid range for ${this.AnalytScoreCategoryValue}`,
                        variant: "error"
                    });
                    this.dispatchEvent(toastEvent);
                }
            }
        }
    }

    handleStartDate(event) {
        if (event.target.name == "courseStartDate") {
            this.courseStartDate = event.target.value;
            console.log("this.courseStartDate====  " + this.courseStartDate);
            let date1 = new Date(this.courseStartDate).toISOString().split('T')[0];
            console.log('5 date1==>', date1);
            let currentdate = new Date().toISOString().split('T')[0];
            console.log('5 currentdate==>', currentdate);
            if (date1 >= currentdate) {
                console.log('5 date1==>', date1);
            } else {

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: "Course Start Date should not less than today's date",
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
            console.log("this.courseEndDate====  " + this.courseEndDate);
            let date1 = new Date(this.courseStartDate).toISOString().split('T')[0];
            let date2 = new Date(this.courseEndDate).toISOString().split('T')[0];

            if (date2 > date1) {
                console.log('5 date1==>', date1);
                console.log('5 date2==>', date2);
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Course End Date should not greater than Course Start date',
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
            console.log("this.AdmissionStatus====  " + this.AdmissionStatus);
        }
        if (event.target.name == "Admission Status" && event.target.value !== "Not Applied") {
            this.ShowFieldsCourseUniversity = true;
            this.universityName = '';
            this.universityNameString= '';
            this.InstituteId = '';
            this.courseCampus = '';
            this.courseName = '';
            console.log("this.ShowFieldsCourseUniversity====  " + this.ShowFieldsCourseUniversity);
        }
        else {
            this.ShowFieldsCourseUniversity = false;
            console.log("this.ShowFieldsCourseUniversity====  " + this.ShowFieldsCourseUniversity);
        }
    }
    //Avadhut Code
    @track universityNameIdResult;
    @track errorsUniversityId;
   

    handleInstitute(event) {
        const selectedId = event.detail.selectedId;
        console.log('Selected Id====><><><><><>:', selectedId);
        if(selectedId === ''){
            console.log('selectedId === inside insititude null');
            this.universityName = '';
            this.universityNameString= '';
        }
        //this.ShowFieldsCourseUniversity = true ;
        this.InstituteId = selectedId;
        console.log("this.instituteName====  " + this.InstituteId);
        getUniversityName({ parentId: this.InstituteId })
        .then(result => {
            this.ShowFieldsCourseUniversity = true;
            console.log('result====University Name===> ' + JSON.stringify(result));
        
            // Extract the university name and ID from the result map
            const universityName = Object.keys(result)[0];
            const universityId = result[universityName];
        
            console.log('University Name: ' + universityName);
            console.log('University ID: ' + universityId);
        
            // Assign the values to the respective variables
            this.universityName = universityId;
            this.universityNameString = universityName;
            console.log('Map get id name this.universityName 111',this.universityName);
            console.log('Map get id name this.universityNameString 111 ',this.universityNameString);
          })
          .catch(error => {
            this.errors = error;
            console.log('errors=======> ' + this.errors);
          });
            console.log("this.instituteName====  " + this.InstituteId);
            console.log("this.CountryOfStudyValue  " + this.CountryOfStudyValue);
            console.log('Handle institute called theGetdata method before %%%%%%%%%%%%%%');
            getLookupData({objectApiName: "Course__c",countryOfStudyLead:this.CountryOfStudyValue,parentId:this.InstituteId,label:"Course"})
            // .then(result => {
            //     console.log('Handle institute called theGetdata method %%%%%%%%%%%%%%');
            //     console.log('Result:' + JSON.stringify(result));
            //     console.log('Result:Length' + result.length);
            //     let option = [];
            //         for (var key in result) {
            //             option.push({
            //                 label: result[key].Course_Name__c,
            //                 value: result[key].Id
            //             });
            //         }
            //     this.courseName = option;
    
            //     if (this.value !== '') {
            //         const selectedName = this.options.find(option => option.value === this.value)?.label || '';
            //         this.selectedValue = selectedName;
            //         const inputField = this.template.querySelector('lightning-input');
            //         if (inputField) {
            //             inputField.value = selectedName;
            //         }
            //     }
            // })
            // .catch(error => {
            //     console.log('Error while getting bank branches' + JSON.stringify(error));
            // });
            .then(result => {
                console.log('Handle institute called theGetdata method %%%%%%%%%%%%%%');
                console.log("this.result &&&&",this.result);
                let option = [];
                    for (var key in result) {
                        option.push({
                            label: result[key].Course_Name__c,
                            value: result[key].Id
                        });
                    }
               // this.courseName = option;
                console.log("option &&&&",option);
                console.log("option.value &&&&",option.value);
                console.log("this.courseName&&&&",this.courseName)

            })
            .catch(error => {
                console.log(error);
            });
         
    }
    handleCourse(event) {
        const selectedId = event.detail.selectedId;
        console.log('Selected Id====><><><><><>:', selectedId);

        this.courseName = selectedId;
        console.log("this.instituteName====  " + this.InstituteId);
    }

    @track InstituteIdFromUnivercity;
    handleCourseInstAndCampusShowHide(event) {
        const selectedId = event.detail.selectedId;
        console.log('Selected Id====><><><><><>:', selectedId);

        // Do something with the selectedId

        // if (event.target.name == "universityName") {
        this.universityName = selectedId;
        if (this.universityName == '') {
            this.InstituteId = '';
            this.courseName = '';
        }
        console.log("this.universityName====  " + this.universityName);
        this.showInstitute = true;
    }

    //Course Id Name Lookup Lead 
    //Avadhut Code
    @track CourseIdNameIdResult;
    @track errorsCourseIdName;
    handleCourseIdNameLead(event) {
        if (event.target.name == "courseName") {
            this.courseName = event.target.value;
            console.log("this.courseName====  " + this.courseName);
        }

        getCourseIdName({ courseNameId: this.courseName }) //this parameter is passed to Class-CommunityLeadFormController.getInstituteRecord
            .then(result => {
                this.CourseIdNameIdResult = result;
                console.log('CourseIdNameIdResult=======> ' + JSON.stringify(this.CourseIdNameIdResult));

            })
            .catch(error => {
                this.errorsCourseIdName = error;
                console.log('errorsCourseIdName=======> ' + this.errorsCourseIdName);
            });

    }

    /**********Institure info Update method************/
    handleInstituteSelection(event) {
        this.InstituteId = event.target.value;
        console.log("The InstituteId id is=====>" + this.InstituteId);

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
                console.log('instituteResult=======> ' + JSON.stringify(this.instituteResult));
                console.log('Address 1=======> ' + this.instituteResult.Address__c);
                console.log('this.instAdderess ' + this.instAdderess);
            })
            .catch(error => {
                this.errors = error;
                console.log('errors=======> ' + this.errors);
            });

    }
    @track percentageReadOnly = false;
    @track cgpaReadOnly = false;

    //For validation:
    @track percentageNotValid = false;
    @track CGPAMarksNotValid = false;

    //update table row values in list
    updateValues(event) {
        console.log('this.listOfEducationalTable valuessss===>' + JSON.stringify(this.listOfEducationalTable));
        var foundelement = this.listOfEducationalTable.find(ele => ele.Id == event.target.dataset.id);
        console.log('foundelement' + JSON.stringify(foundelement));
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
                    console.log('this.EducationDetails update values handle', this.EducationDetails);
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
        }
        else if (event.target.name === 'StartDate') {
            foundelement.Course_Start_Date__c = event.target.value;
            this.YearCompleted = foundelement.Year_Completed__c;
            console.log('this.YearCompleted update values handle', this.YearCompleted);
        }
        else if (event.target.name === 'EndDate') {
            foundelement.Year_Completed__c = event.target.value;

            if (foundelement.Education_Qualification__c === '10th') {
                this.year10 = new Date(foundelement.Year_Completed__c).getFullYear();
                console.log('10 date year:' + this.year10);
            }

            if (foundelement.Education_Qualification__c === '12th') {
                this.year12 = new Date(foundelement.Year_Completed__c).getFullYear();
                console.log('12 date year:' + this.year12);
            }

            if (foundelement.Education_Qualification__c === 'Graduate' || foundelement.Education_Qualification__c === 'Post Graduate') {
                let date1 = new Date(foundelement.Course_Start_Date__c).toISOString().split('T')[0];
                let date2 = new Date(foundelement.Year_Completed__c).toISOString().split('T')[0];
                let date3 = new Date(foundelement.Course_Start_Date__c).getFullYear();
                let date4 = new Date(foundelement.Year_Completed__c).getFullYear();
                if (date2 > date1) {
                    console.log('5 date1==>', date1);
                    console.log('5 date2==>', date2);
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Course End Date should be greater than Course Start date',
                            variant: 'error',
                        }),
                    );
                    foundelement.Year_Completed__c = null;
                }
                if (date3 != date4) {
                    console.log('5 date1==>', date1);
                    console.log('5 date2==>', date2);
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Course Start Date and End Date cannot be in same year',
                            variant: 'error',
                        }),
                    );
                    foundelement.Year_Completed__c = null;
                }
            }
            this.YearCompleted = foundelement.Year_Completed__c;
            console.log('this.YearCompleted update values handle', this.YearCompleted);
        }
        else if (event.target.name === 'PercentageMarks') {  
            let fieldValue = event.target.value;  
            let pattern = /^\d{1,2}(\.\d{1,2})?$/;
            if (!pattern.test(fieldValue) && fieldValue != '') {         
                foundelement.percentageNotValid = true;
                console.log('  foundelement.percentageNotValid if:', foundelement.percentageNotValid);
            }else{            
                foundelement.Percentage_Marks_CGPA__c = event.target.value;
                foundelement.CGPA__c = (foundelement.Percentage_Marks_CGPA__c / 9.5).toFixed(2);
                console.log('foundelement.Percentage_Marks_CGPA__c update values handle', foundelement.Percentage_Marks_CGPA__c);
                foundelement.percentageNotValid = false;
                foundelement.CGPAMarksNotValid = false;
                console.log('  foundelement.percentageNotValid else:', foundelement.percentageNotValid);
            }            
        }
        else if (event.target.name === 'CGPAMarks') {            
            let fieldValue = event.target.value;  
            let pattern = /^(10(\.([0-4][0-9]|50)?)?|[0-9](\.\d{1,2})?)$/;
            if (!pattern.test(fieldValue) && fieldValue != '') {         
                foundelement.CGPAMarksNotValid = true;
                console.log('  foundelement.CGPAMarksNotValid if:', foundelement.CGPAMarksNotValid);
            }else{            
                foundelement.CGPA__c = event.target.value;
                foundelement.Percentage_Marks_CGPA__c = parseFloat((foundelement.CGPA__c * 9.5).toFixed(2));
                console.log('foundelement.CGPA__c update values handle', foundelement.CGPA__c);
                foundelement.CGPAMarksNotValid = false;
                foundelement.percentageNotValid = false;
                console.log('  foundelement.CGPAMarksNotValid else:', foundelement.CGPAMarksNotValid);
            }     
        }
        else if (event.target.name === 'SchoolCollegeUniversity') {
            foundelement.School_College_University__c = event.target.value;
            this.SchoolCollegeUniversity = foundelement.School_College_University__c;
            console.log('this.SchoolCollegeUniversity update values handle', this.SchoolCollegeUniversity);
        }
        else if (event.target.name === 'University') {
            foundelement.University_Name__c = event.target.value;
        }
        else if (event.target.name === 'CourseNameEdu') {
            foundelement.Course_Name__c = event.target.value;
            console.log('foundelement.Course_Name__c==>', foundelement.Course_Name__c);
        }
        else if (event.target.name === 'CourseStreamEdu') {
            foundelement.Course_Stream__c = event.target.value;
            console.log('foundelement.Course_Stream__c==>', foundelement.Course_Stream__c);
        }
    }

    handleSaveCourseEduSection() {

        var universityError;
        var instituteError;
        var courseError;
        var sameyear;
        var countryError;
        var courseStartDateError;
        var courseEndDateError;

        //ARS Code
        let hasGraduate = false;
        let hasPostGraduate = false;
        let has10th = false;
        let has12th = false;
       
        var percentCgpaErrorNull = false;
        var percentCgpaErrorGreater = false;

        var quantError;
        var verbalError;
        var langScoreCategotyError;
        var analyticalScoreCategotyError;
        var analylScoreCateyGREQuatError;
        var analytScoreCateyGREVerbalError;

        if (this.CountryOfStudyValue == '' || this.CountryOfStudyValue == undefined) {
            countryError = true;
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
                console.log("startRange HC L====  " + startRange);
                var endRange = selectedRecord.End_Range__c;
                console.log("endRange HC L====  " + endRange);
                if (this.langTestScore < startRange || this.langTestScore > endRange) {
                    langScoreCategotyError = true;
                }
            }
        }

        if (this.analyticalCategoryMetaData.length > 0) {
            const selectedRecord1 = this.analyticalCategoryMetaData.find(record => record.Analytical_Category__c === this.AnalytScoreCategoryValue);

            if (selectedRecord1) {
                var startRange1 = selectedRecord1.Start_Range__c;
                console.log("startRange HC A====  " + startRange1);
                var endRange1 = selectedRecord1.End_Range__c;
                console.log("endRange HC A====  " + endRange1);
                if (this.analyticalTestScore < startRange1 || this.analyticalTestScore > endRange1) {
                    analyticalScoreCategotyError = true;
                }
            }
        }
        if (this.analyticalCategoryMetaDataGRE.length > 0) {
            const selectedRecord1 = this.analyticalCategoryMetaDataGRE.find(record => record.Analytical_Category_GRE__c === this.AnalytScoreCategoryValue);
            if (selectedRecord1) {
                var startRange2 = selectedRecord1.Start_Range__c;
                console.log("startRange2 HC 3====  " + startRange2);
                var endRange2 = selectedRecord1.End_Range__c;
                console.log("endRange2 HC 3====  " + endRange2);
                console.log("this.quanTestScore HC 3====  " + this.quanTestScore);
                console.log("this.verbalTestScore HC 3====  " + this.verbalTestScore);
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

        //ARS 
        this.listOfEducationalTable.forEach((rec) => {
            if (rec.Education_Qualification__c == 'Graduate') {
                console.log('Inside Graduate record 1');
                hasGraduate = true;
                console.log('Graduate record 1 :', hasGraduate);
            } else if (rec.Education_Qualification__c == 'Post Graduate') {
                console.log('Inside Post Graduate record 1');
                hasPostGraduate = true;
                console.log('Post Graduate record 1 :', hasPostGraduate);
            } else if (rec.Education_Qualification__c == '10th') {
                console.log('Inside 10th record 1');
                has10th = true;
                console.log('10th record 1 :', has10th);
            } else if (rec.Education_Qualification__c == '12th') {
                console.log('Inside 12th record 1');
                has12th = true;
                console.log('12th record 1:', has12th);
            }
        });

        if (this.listOfEducationalTable.length > 0) {
            for (var i = 0; i < this.listOfEducationalTable.length; i++) {

                var record = this.listOfEducationalTable[i];
                console.log('record:', record.Education_Qualification__c);

                if (this.year10 === this.year12 && this.year10 != '' && this.year12 != '') {
                    sameyear = true;
                    if (sameyear)
                        break;
                }

                else if (record.percentageNotValid == true) {
                    percentCgpaErrorNull = true;
                    if (percentCgpaErrorNull)
                        break;
                } 
                else if(record.CGPAMarksNotValid == true){
                    percentCgpaErrorNull = true;
                    if (percentCgpaErrorNull)
                        break;
                } 
                else if (record.Percentage_Marks_CGPA__c > 100 || record.CGPA__c > 10.52 || record.Percentage_Marks_CGPA__c < 0 || record.CGPA__c < 0) {
                    percentCgpaErrorGreater = true;
                    if (percentCgpaErrorGreater)
                        break;
                }
            }
        }

        if (countryError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please enter Country of Study',
                    variant: 'error',
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
                    message: 'Please enter course start date',
                    variant: 'Error',
                }),
            );
        }

        else if (courseStartDateError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter course end date',
                    variant: 'Error',
                }),
            );
        }

        else if (sameyear) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Course End Date cannot be same of 10th and 12th',
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
                    message: `Language Test Score for ${this.LangScoreCategoryValue} should be ${startRange} to ${endRange}.`,
                    variant: 'Error',
                }),
            );
        } else if (analyticalScoreCategotyError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: `Analytical Test Score for ${this.AnalytScoreCategoryValue} should be ${startRange1} to ${endRange1}.`,
                    variant: 'Error',
                }),
            );
        } else if (analylScoreCateyGREQuatError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: `Quantitative Test Score for ${this.AnalytScoreCategoryValue} should be ${startRange2} to ${endRange2}.`,
                    variant: 'Error',
                }),
            );
        } else if (analytScoreCateyGREVerbalError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: `Verbal Test Score for ${this.AnalytScoreCategoryValue} should be ${startRange2} to ${endRange2}.`,
                    variant: 'Error',
                }),
            );
        } else if (quantError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter valid Quantitative Score.',
                    variant: 'Error',
                }),
            );
        } else if (verbalError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter valid Verbal score.',
                    variant: 'Error',
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
                Course_Stream__c: this.CourseStreamValue,
                Course_Id__c: this.courseName,
                Course_Start_Date__c: this.courseStartDate,
                Course_End_Date__c: this.courseEndDate,
                Language_Score_Category__c: this.LangScoreCategoryValue,
                Language_Test_Score__c: this.langTestScore,
                Analytics_Score_Category__c: this.AnalytScoreCategoryValue,
                Analytics_Test_Score__c: this.analyticalTestScore,
                Verbal_Score__c: this.verbalTestScore,
                Quantitative_Score__c: this.quanTestScore
            }
            console.log('CourseSecSaveRec=====>' + JSON.stringify(CourseSecSaveRec));
            let CourseAppliAccDataSaveRec = {
                Id: this.AppliAccID
            }
            if (this.deleteEmpIds !== '') {
                this.deleteEmpIds = this.deleteEmpIds.substring(0);
            }

            this.listOfEducationalTable.forEach(res => {
                if (!isNaN(res.Id)) {
                    res.Id = null;
                    console.log(' res.Id====>' + res.Id);
                }
            });

            console.log(' this.deleteEmpIds====>' + this.deleteEmpIds);
            console.log('LIst of Table ' + JSON.stringify(this.listOfEducationalTable));
            //Wrapper Class variable      
            let wrapperCommFormRecord = {
                leadSaveRec: JSON.stringify(CourseSecSaveRec),
                appliEduDetailsSave: JSON.stringify(this.listOfEducationalTable),
                appliAccSaveRec: JSON.stringify(CourseAppliAccDataSaveRec),
                removeEducationIds: this.deleteEmpIds
            }

            creatCommFormLeadRecords({
                wrapperCommFormDetails: JSON.stringify(wrapperCommFormRecord),
                leadGetId: this.leadRecordId
            })
                .then(response => {
                    this.wrapperForCommLeadForm = response;
                    console.log('Lead Data and Education Data', +this.wrapperForCommLeadForm);

                    //Lead Applicant
                    this.leadID = this.wrapperForCommLeadForm.LeadRecords.Id;
                    console.log('this.leadID data===>' + this.leadID);

                    this.CountryOfStudyValue = this.wrapperForCommLeadForm.LeadRecords.Country_of_Study__c;
                    this.AdmissionStatus = this.wrapperForCommLeadForm.LeadRecords.Admission_Status__c;
                    console.log('this.AdmissionStatus data===>' + this.AdmissionStatus);
                    this.universityName = this.wrapperForCommLeadForm.LeadRecords.University_Name__c;
                    this.courseCampus = this.wrapperForCommLeadForm.LeadRecords.Campus__c;
                    this.InstituteId = this.wrapperForCommLeadForm.LeadRecords.Institute_Name__c;
                    this.CourseCategoryValue = this.wrapperForCommLeadForm.LeadRecords.Course_Category__c;
                    console.log('this.CourseCategoryValue data===>' + this.CourseCategoryValue);
                    this.CourseTypeValue = this.wrapperForCommLeadForm.LeadRecords.Course_Type__c;
                    this.CourseLevelValue = this.wrapperForCommLeadForm.LeadRecords.Course_Level__c;
                    this.CourseStreamValue = this.wrapperForCommLeadForm.LeadRecords.Course_Stream__c;
                    this.courseName = this.wrapperForCommLeadForm.LeadRecords.Course_Id__c;
                    console.log('this.courseName data===>' + this.courseName);
                    this.courseStartDate = this.wrapperForCommLeadForm.LeadRecords.Course_Start_Date__c;
                    this.courseEndDate = this.wrapperForCommLeadForm.LeadRecords.Course_End_Date__c;
                    this.LangScoreCategoryValue = this.wrapperForCommLeadForm.LeadRecords.Language_Score_Category__c;
                    this.langTestScore = this.wrapperForCommLeadForm.LeadRecords.Language_Test_Score__c;
                    this.AnalytScoreCategoryValue = this.wrapperForCommLeadForm.LeadRecords.Analytics_Score_Category__c;
                    this.analyticalTestScore = this.wrapperForCommLeadForm.LeadRecords.Analytics_Test_Score__c;

                    //Check if Admission Status is Confirmed or Applied then show Universityn campus & Institute fields
                    if (this.AdmissionStatus == "Confirmed" || this.AdmissionStatus == "Applied") {
                        this.ShowFieldsCourseUniversity = true;
                        console.log("this.ShowFieldsCourseUniversity====  " + this.ShowFieldsCourseUniversity);
                    }
                    else {
                        this.ShowFieldsCourseUniversity = false;
                        console.log("this.ShowFieldsCourseUniversity====  " + this.ShowFieldsCourseUniversity);
                    }
                    console.log("this.wrapperForCommLeadForm.AppliEduDetailsRecord.length===>" + this.wrapperForCommLeadForm.AppliEduDetailsRecord.length);

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

                    if (this.wrapperForCommLeadForm.AppliEduDetailsRecord.length > 0) {
                        this.listOfEducationalTable = JSON.parse(JSON.stringify(this.wrapperForCommLeadForm.AppliEduDetailsRecord));
                    } else {
                        let randomId = Math.random() * 16;
                        let myNewElement = { Id: randomId, Education_Qualification__c: "", Year_Completed__c: "", Percentage_Marks_CGPA__c: "", CGPA__c: "", School_College_University__c: "", Course_Name__c: "", Course_Stream__c: "" };
                        console.log("myNewElement===>" + myNewElement);
                        this.listOfEducationalTable = [myNewElement];

                        console.log("this.listOfEducationalTable===>" + this.listOfEducationalTable);
                    }
                    this.listOfEducationalTable.forEach(element => {
                        if (element.Education_Qualification__c == 'Graduate' || element.Education_Qualification__c == 'Post Graduate') {
                            element.startDate = true;
                        }
                    });
                    if (this.listOfEducationalTable.length > 0) {
                        this.listOfEducationalTable.length + 1;
                    }
                    //Applicant Account
                    this.AppliAccID = this.wrapperForCommLeadForm.AccRecords.Account__c;
                    console.log('this.AppliAccID data===>' + this.AppliAccID);

                    console.log(response);
                    if (response != null) {
                        console.log('response inside if=====>' + response);
                    }
                    this.isLoading = false;
                    /****progress bar data pass****/

                    getLeadTotalPercentage({ leadId: this.leadRecordId })
                        .then(result => {
                            console.log('Total pppercentagee:', result);
                            let newPerc = 27;
                            let ProgrssValueOfLoanSection = { ProgrssValueOfLoanSection: newPerc };
                            console.log('ProgressValueOfLoanSection +++', ProgrssValueOfLoanSection);
                            publish(this.messageContext, progressBar, ProgrssValueOfLoanSection);
                            updateLeadTotalPercentage({ leadId: this.leadRecordId, percentage: newPerc })
                                .then(result => {
                                    if (result === 'Success') {
                                        console.log('Lead updated successfully');
                                        // Add any success logic here
                                    } else {
                                        console.error('Failed to update Lead');
                                        // Add any failure logic here
                                    }
                                })
                                .catch(error => {
                                    console.error(error);
                                    // Add any error handling here
                                });
                        })
                        .catch(error => {
                            console.error(error);
                        });

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Successfully Saved',
                            variant: 'Success',
                        }),
                    );

                }).catch(error => {
                    console.log(error);
                    this.isLoading = false;
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
        var campusError;
        var passportError;
        //ARS Code
        let hasGraduate = false;
        let hasPostGraduate = false;
        let has10th = false;
        let has12th = false;

        var eduErrorForTwlReqTen = false;
        var eduErrorNotTenTwelve = false;
        var eduErrorPostGraduate = false;

        var percentCgpaErrorNull = false;
        var percentCgpaErrorGreater = false;

        var quantError;
        var verbalError;
        var langScoreCategotyError;
        var analyticalScoreCategotyError;
        var analylScoreCateyGREQuatError;
        var analytScoreCateyGREVerbalError;

        if (this.CountryOfStudyValue == '' || this.CountryOfStudyValue == undefined) {
            countryError = true;
        }
        else if (this.CountryOfStudyValue != 'INDIA' && (this.getCourseData == '' || this.getCourseData == undefined)) {
            passportError = true;
        }
        else if (this.CountryOfStudyValue == '' || this.CountryOfStudyValue == undefined ||
            this.AdmissionStatus == '' || this.AdmissionStatus == undefined ||
            this.CourseCategoryValue == '' || this.CourseCategoryValue == undefined ||
            this.CourseTypeValue == '' || this.CourseTypeValue == undefined ||
            this.CourseLevelValue == '' || this.CourseLevelValue == undefined ||
            this.CourseStreamValue == '' || this.CourseStreamValue == undefined ||
            this.LangScoreCategoryValue == '' || this.LangScoreCategoryValue == undefined ||
            this.langTestScore == '' || this.langTestScore == undefined ||
            this.AnalytScoreCategoryValue == '' || this.AnalytScoreCategoryValue == undefined ||
            this.analyticalTestScore == '' || this.analyticalTestScore == undefined) {
            isError = true;
        }
        else if ((this.AdmissionStatus == 'Confirmed' || this.AdmissionStatus == 'Applied') && (this.courseCampus == '' || this.courseCampus == undefined)) {
            campusError = true;
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
                console.log("startRange HC L====  " + startRange);
                var endRange = selectedRecord.End_Range__c;
                console.log("endRange HC L====  " + endRange);
                if (this.langTestScore < startRange || this.langTestScore > endRange) {
                    langScoreCategotyError = true;
                }
            }
        }

        if (this.analyticalCategoryMetaData.length > 0) {
            const selectedRecord1 = this.analyticalCategoryMetaData.find(record => record.Analytical_Category__c === this.AnalytScoreCategoryValue);

            if (selectedRecord1) {
                var startRange1 = selectedRecord1.Start_Range__c;
                console.log("startRange HC A====  " + startRange1);
                var endRange1 = selectedRecord1.End_Range__c;
                console.log("endRange HC A====  " + endRange1);
                if (this.analyticalTestScore < startRange1 || this.analyticalTestScore > endRange1) {
                    analyticalScoreCategotyError = true;
                }
            }
        }
        if (this.analyticalCategoryMetaDataGRE.length > 0) {
            const selectedRecord1 = this.analyticalCategoryMetaDataGRE.find(record => record.Analytical_Category_GRE__c === this.AnalytScoreCategoryValue);
            if (selectedRecord1) {
                var startRange2 = selectedRecord1.Start_Range__c;
                console.log("startRange2 HC 3====  " + startRange2);
                var endRange2 = selectedRecord1.End_Range__c;
                console.log("endRange2 HC 3====  " + endRange2);
                console.log("this.quanTestScore HC 3====  " + this.quanTestScore);
                console.log("this.verbalTestScore HC 3====  " + this.verbalTestScore);
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

        //ARS 
        this.listOfEducationalTable.forEach((rec) => {
            if (rec.Education_Qualification__c == 'Graduate') {
                console.log('Inside Graduate record 1');
                hasGraduate = true;
                console.log('Graduate record 1 :', hasGraduate);
            } else if (rec.Education_Qualification__c == 'Post Graduate') {
                console.log('Inside Post Graduate record 1');
                hasPostGraduate = true;
                console.log('Post Graduate record 1 :', hasPostGraduate);
            } else if (rec.Education_Qualification__c == '10th') {
                console.log('Inside 10th record 1');
                has10th = true;
                console.log('10th record 1 :', has10th);
            } else if (rec.Education_Qualification__c == '12th') {
                console.log('Inside 12th record 1');
                has12th = true;
                console.log('12th record 1:', has12th);
            }

            //12 check 10 needed
            if (has12th == true && has10th == false) {
                eduErrorForTwlReqTen = true;
                console.log('eduErrorForTwlReqTen:', eduErrorForTwlReqTen);
            }
            else {
                eduErrorForTwlReqTen = false;
                console.log('eduErrorForTwlReqTen false:', eduErrorForTwlReqTen);
            }
            //Graduate check 10 & 12 needed
            if (hasGraduate == true && (has10th == false || has12th == false)) {
                eduErrorNotTenTwelve = true;
                console.log('eduErrorNotTenTwelve:', eduErrorNotTenTwelve);
            }
            else {
                eduErrorNotTenTwelve = false;
                console.log('eduErrorNotTenTwelve false:', eduErrorNotTenTwelve);
            }
            //Post Graduate check gratuate & 10 & 12 needed
            if (hasPostGraduate == true && (hasGraduate == false || has10th == false || has12th == false)) {
                eduErrorPostGraduate = true;
                console.log('eduErrorPostGraduate:', eduErrorPostGraduate);
            }
            else {
                eduErrorPostGraduate = false;
                console.log('eduErrorPostGraduate false:', eduErrorPostGraduate);
            }
        });

        if (this.listOfEducationalTable.length > 0) {
            for (var i = 0; i < this.listOfEducationalTable.length; i++) {

                var record = this.listOfEducationalTable[i];
                console.log('record:', record.Education_Qualification__c);

                if (record.Education_Qualification__c == null) {
                    duplicateError = true;
                    if (duplicateError)
                        break;
                }
                else if (this.year10 === this.year12 && this.year10 != '' && this.year12 != '') {
                    sameyear = true;
                    if (sameyear)
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
                else if(record.CGPAMarksNotValid == true){
                    percentCgpaErrorNull = true;
                    if (percentCgpaErrorNull)
                        break;
                }               
                else if (record.Percentage_Marks_CGPA__c > 100 || record.CGPA__c > 10.52 || record.Percentage_Marks_CGPA__c < 0 || record.CGPA__c < 0) {
                    percentCgpaErrorGreater = true;
                    if (percentCgpaErrorGreater)
                        break;
                }
            }
        }

        if (countryError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please enter Country of Study',
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
                    message: 'Please fill all Course mandatory fields',
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

        else if (campusError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please add Campus',
                    variant: 'Error',
                }),
            );
        }

        else if (duplicateError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please fill the Education details',
                    variant: 'Error',
                }),
            );
        }

        else if (educationError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please fill all Education mandatory fields',
                    variant: 'Error',
                }),
            );
        }

        else if (sameyear) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Course End Date cannot be same of 10th and 12th',
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

        else if (eduErrorForTwlReqTen) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please ensure to add 10th details for 12th',
                    variant: 'Error',
                }),
            );
        }
        else if (eduErrorNotTenTwelve) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please ensure to add 10th & 12th details for Graduation',
                    variant: 'Error',
                }),
            );
        }
        else if (eduErrorPostGraduate) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please ensure to add 10th, 12th & Graduate details for Post-Graduation',
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
                    message: `Language Test Score for ${this.LangScoreCategoryValue} should be ${startRange} to ${endRange}.`,
                    variant: 'Error',
                }),
            );
        } else if (analyticalScoreCategotyError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: `Analytical Test Score for ${this.AnalytScoreCategoryValue} should be ${startRange1} to ${endRange1}.`,
                    variant: 'Error',
                }),
            );
        } else if (analylScoreCateyGREQuatError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: `Quantitative Test Score for ${this.AnalytScoreCategoryValue} should be ${startRange2} to ${endRange2}.`,
                    variant: 'Error',
                }),
            );
        } else if (analytScoreCateyGREVerbalError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: `Verbal Test Score for ${this.AnalytScoreCategoryValue} should be ${startRange2} to ${endRange2}.`,
                    variant: 'Error',
                }),
            );
        } else if (quantError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter valid Quantitative Score.',
                    variant: 'Error',
                }),
            );
        } else if (verbalError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter valid Verbal Score.',
                    variant: 'Error',
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
                Course_Stream__c: this.CourseStreamValue,
                Course_Id__c: this.courseName,
                Course_Start_Date__c: this.courseStartDate,
                Course_End_Date__c: this.courseEndDate,
                Language_Score_Category__c: this.LangScoreCategoryValue,
                Language_Test_Score__c: this.langTestScore,
                Analytics_Score_Category__c: this.AnalytScoreCategoryValue,
                Analytics_Test_Score__c: this.analyticalTestScore,
                Verbal_Score__c: this.verbalTestScore,
                Quantitative_Score__c: this.quanTestScore
            }
            console.log('CourseSecSaveRec=====>' + JSON.stringify(CourseSecSaveRec));
            let CourseAppliAccDataSaveRec = {
                Id: this.AppliAccID
            }
            if (this.deleteEmpIds !== '') {
                this.deleteEmpIds = this.deleteEmpIds.substring(0);
            }

            this.listOfEducationalTable.forEach(res => {
                if (!isNaN(res.Id)) {
                    res.Id = null;
                    console.log(' res.Id====>' + res.Id);
                }
            });

            console.log(' this.deleteEmpIds====>' + this.deleteEmpIds);
            console.log('LIst of Table ' + JSON.stringify(this.listOfEducationalTable));
            //Wrapper Class variable      
            let wrapperCommFormRecord = {
                leadSaveRec: JSON.stringify(CourseSecSaveRec),
                appliEduDetailsSave: JSON.stringify(this.listOfEducationalTable),
                appliAccSaveRec: JSON.stringify(CourseAppliAccDataSaveRec),
                removeEducationIds: this.deleteEmpIds
            }

            creatCommFormLeadRecords({
                wrapperCommFormDetails: JSON.stringify(wrapperCommFormRecord),
                leadGetId: this.leadRecordId
            })
                .then(response => {
                    this.wrapperForCommLeadForm = response;
                    console.log('Lead Data and Education Data', +this.wrapperForCommLeadForm);

                    //Lead Applicant
                    this.leadID = this.wrapperForCommLeadForm.LeadRecords.Id;
                    console.log('this.leadID data===>' + this.leadID);

                    this.CountryOfStudyValue = this.wrapperForCommLeadForm.LeadRecords.Country_of_Study__c;
                    this.AdmissionStatus = this.wrapperForCommLeadForm.LeadRecords.Admission_Status__c;
                    console.log('this.AdmissionStatus data===>' + this.AdmissionStatus);
                    this.universityName = this.wrapperForCommLeadForm.LeadRecords.University_Name__c;
                    this.courseCampus = this.wrapperForCommLeadForm.LeadRecords.Campus__c;
                    this.InstituteId = this.wrapperForCommLeadForm.LeadRecords.Institute_Name__c;
                    this.CourseCategoryValue = this.wrapperForCommLeadForm.LeadRecords.Course_Category__c;
                    console.log('this.CourseCategoryValue data===>' + this.CourseCategoryValue);
                    this.CourseTypeValue = this.wrapperForCommLeadForm.LeadRecords.Course_Type__c;
                    this.CourseLevelValue = this.wrapperForCommLeadForm.LeadRecords.Course_Level__c;
                    this.CourseStreamValue = this.wrapperForCommLeadForm.LeadRecords.Course_Stream__c;
                    this.courseName = this.wrapperForCommLeadForm.LeadRecords.Course_Id__c;
                    console.log('this.courseName data===>' + this.courseName);
                    this.courseStartDate = this.wrapperForCommLeadForm.LeadRecords.Course_Start_Date__c;
                    this.courseEndDate = this.wrapperForCommLeadForm.LeadRecords.Course_End_Date__c;
                    this.LangScoreCategoryValue = this.wrapperForCommLeadForm.LeadRecords.Language_Score_Category__c;
                    this.langTestScore = this.wrapperForCommLeadForm.LeadRecords.Language_Test_Score__c;
                    this.AnalytScoreCategoryValue = this.wrapperForCommLeadForm.LeadRecords.Analytics_Score_Category__c;
                    this.analyticalTestScore = this.wrapperForCommLeadForm.LeadRecords.Analytics_Test_Score__c;

                    //Check if Admission Status is Confirmed or Applied then show Universityn campus & Institute fields
                    if (this.AdmissionStatus == "Confirmed" || this.AdmissionStatus == "Applied") {
                        this.ShowFieldsCourseUniversity = true;
                        console.log("this.ShowFieldsCourseUniversity====  " + this.ShowFieldsCourseUniversity);
                    }
                    else {
                        this.ShowFieldsCourseUniversity = false;
                        console.log("this.ShowFieldsCourseUniversity====  " + this.ShowFieldsCourseUniversity);
                    }
                    console.log("this.wrapperForCommLeadForm.AppliEduDetailsRecord.length===>" + this.wrapperForCommLeadForm.AppliEduDetailsRecord.length);

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

                    if (this.wrapperForCommLeadForm.AppliEduDetailsRecord.length > 0) {
                        this.listOfEducationalTable = JSON.parse(JSON.stringify(this.wrapperForCommLeadForm.AppliEduDetailsRecord));
                    } else {
                        let randomId = Math.random() * 16;
                        let myNewElement = { Id: randomId, Education_Qualification__c: "", Year_Completed__c: "", Percentage_Marks_CGPA__c: "", CGPA__c: "", School_College_University__c: "", Course_Name__c: "", Course_Stream__c: "" };
                        console.log("myNewElement===>" + myNewElement);
                        this.listOfEducationalTable = [myNewElement];

                        console.log("this.listOfEducationalTable===>" + this.listOfEducationalTable);
                    }
                    this.listOfEducationalTable.forEach(element => {
                        if (element.Education_Qualification__c == 'Graduate' || element.Education_Qualification__c == 'Post Graduate') {
                            element.startDate = true;
                        }
                    });
                    if (this.listOfEducationalTable.length > 0) {
                        this.listOfEducationalTable.length + 1;
                    }
                    //Applicant Account
                    this.AppliAccID = this.wrapperForCommLeadForm.AccRecords.Account__c;
                    console.log('this.AppliAccID data===>' + this.AppliAccID);

                    console.log(response);
                    if (response != null) {
                        console.log('response inside if=====>' + response);
                    }
                    this.isLoading = false;
                    /****progress bar data pass****/

                    getLeadTotalPercentage({ leadId: this.leadRecordId })
                        .then(result => {
                            console.log('Total pppercentagee:', result);
                            getLeadCoursePercentage({ leadId: this.leadRecordId })
                                .then(res => {
                                    this.getCoursePerc = res;
                                })
                            let newPerc = this.getCoursePerc == 13 ? 0 : 13;
                            updateCoursePercentage({ leadId: this.leadRecordId, percentage: newPerc })
                                .then(result => {
                                    if (result === 'Success') {
                                        console.log('Lead updated successfully');
                                        // Add any success logic here
                                    } else {
                                        console.error('Failed to update Lead');
                                        // Add any failure logic here
                                    }
                                })
                                .catch(error => {
                                    console.error(error);
                                    // Add any error handling here
                                });
                            updateLeadTotalPercentage({ leadId: this.leadRecordId, percentage: newPerc })
                                .then(result => {
                                    if (result === 'Success') {
                                        console.log('Lead updated successfully');
                                        // Add any success logic here
                                    } else {
                                        console.error('Failed to update Lead');
                                        // Add any failure logic here
                                    }
                                })
                                .catch(error => {
                                    console.error(error);
                                    // Add any error handling here
                                });

                            let ProgrssValueOfLoanSection = { ProgrssValueOfLoanSection: newPerc };
                            console.log('ProgressValueOfLoanSection +++', ProgrssValueOfLoanSection);
                            publish(this.messageContext, progressBar, ProgrssValueOfLoanSection);
                        })
                        .catch(error => {
                            console.error(error);
                        });
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Successfully Saved',
                            variant: 'Success',
                        }),
                    );
                    //send success msg to submit button 
                    let courseandAcademicsSection = false;
                    publish(this.messageContext, SUBMITACTION , {
                        courseandAcademicsSection : courseandAcademicsSection
                    });
                    console.log('###Publishmsg course is'+courseandAcademicsSection);
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
                })
        }
    }

}