import { LightningElement, wire, api, track } from 'lwc';
import creatCommFormLeadRecords from '@salesforce/apex/CommunityLeadFormTusharController.creatCommFormLeadRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import getInstituteRecord from '@salesforce/apex/CommunityLeadFormTusharController.getInstituteRecord';
import getUniversityNameCourse from '@salesforce/apex/CommunityLeadFormTusharController.getUniversityNameCourse';
import getCourseEducationaData from '@salesforce/apex/CommunityLeadFormTusharController.getWrapperClassCommFormList';
import getCourseIdName from '@salesforce/apex/CommunityLeadFormTusharController.getCourseIdName';

export default class CourseAcademicsChild extends LightningElement {

    @api leadRecordId;

    @track todaysDate;
    
    @track listOfEducationalTable;

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
    @track instituteResult;
    @track errors;
    @track instAdderess;
    @track instCity;
    @track instState;
    @track instCountry;
    @track instPINCode;
    @track InstituteId;
    @track isLoading = false;
    @track showInstitute = false;

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
        this.getCourseEducationaFunction();
        //this.triggerEventOnce();              
        this.todaysDate = new Date().toISOString().split('T')[0];  
    }

    //Get Course and education data
    getCourseEducationaFunction() {
        console.log("DATA NEW COURSE EDU 3");
        console.log('Lead Id', this.leadRecordId);
        getCourseEducationaData({})
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
                console.log('this.universityName get data===>' + this.universityName );
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

                //Check if Admission Status is Confirmed or Applied then show Universityn campus & Institute fields
                if (this.AdmissionStatus == "Confirmed" || this.AdmissionStatus == "Applied") {
                    this.ShowFieldsCourseUniversity = true;
                    console.log("this.ShowFieldsCourseUniversity====  " + this.ShowFieldsCourseUniversity);
                }
                else {
                    this.ShowFieldsCourseUniversity = false;
                    console.log("this.ShowFieldsCourseUniversity====  " + this.ShowFieldsCourseUniversity);
                }
                if(this.universityName !== ''){
                    this.showInstitute = true;
                    console.log('Showing institute data');
                }

                // //Education Data
                // console.log("this.wrapperForCommLeadForm.AppliEduDetailsRecord.length===>" + this.wrapperForCommLeadForm.AppliEduDetailsRecord.length);
                // if (this.wrapperForCommLeadForm.AppliEduDetailsRecord.length > 0) {
                //     this.listOfEducationalTable = JSON.parse(JSON.stringify(this.wrapperForCommLeadForm.AppliEduDetailsRecord));
                // } else {
                //     let randomId = Math.random() * 16;
                //     let myNewElement = { Id: randomId, Education_Qualification__c: "", Year_Completed__c: "", Percentage_Marks_CGPA__c: "", School_College_University__c: "" };
                //     console.log("myNewElement===>" + myNewElement);
                //     this.listOfEducationalTable = [myNewElement];

                //     console.log("this.listOfEducationalTable===>" + this.listOfEducationalTable);
                // }
                // if (this.listOfEducationalTable.length > 0) {
                //     this.listOfEducationalTable.length + 1;
                // }
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
        let myNewElement = { Id: randomId, Education_Qualification__c: "", Year_Completed__c: "", Percentage_Marks_CGPA__c: "", School_College_University__c: "" };
        console.log("myNewElement===>" + myNewElement);
        this.listOfEducationalTable = [...this.listOfEducationalTable, myNewElement];
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
        deleteRecord(this.deleteEmpIds)
            .then(() => {
                console.log('Deleting the record...');
            })
            .catch(error => {

            });
    }
    
    // Education field onchange method
    handlechange(event) {
        if (event.target.name == "Country of Study") {
            this.CountryOfStudyValue = event.target.value;
            if(this.AdmissionStatus == 'Applied' || this.AdmissionStatus == 'Confirmed'){
                this.AdmissionStatus = '';
                this.ShowFieldsCourseUniversity = false;
                this.universityName = '';
                this.InstituteId = '';
                this.courseName = '';
                console.log(this.AdmissionStatus);
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
        // if (event.target.name == "courseName") {
        //     this.courseName = event.target.value;
        //     console.log("this.courseName====  " + this.courseName);
        // }
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
        if (event.target.name == "Language Score Category") {
            this.LangScoreCategoryValue = event.target.value;
            console.log("this.LangScoreCategoryValue====  " + this.LangScoreCategoryValue);
        }
        if (event.target.name == "langTestScore") {
            this.langTestScore = event.target.value;
            console.log("this.langTestScore====  " + this.langTestScore);
        }
        if (event.target.name == "Analytics Score Category") {
            this.AnalytScoreCategoryValue = event.target.value;
            console.log("this.AnalytScoreCategoryValue====  " + this.AnalytScoreCategoryValue);
        }
        if (event.target.name == "analyticalTestScore") {
            this.analyticalTestScore = event.target.value;
            console.log("this.analyticalTestScore====  " + this.analyticalTestScore);
        }
    }

    handleStartDate(event){
        if (event.target.name == "courseStartDate") {
            this.courseStartDate = event.target.value;
            console.log("this.courseStartDate====  " + this.courseStartDate);
            let date1 = new Date(this.courseStartDate).toISOString().split('T')[0];
            console.log('5 date1==>', date1);
            let currentdate = new Date().toISOString().split('T')[0];
            console.log('5 currentdate==>', currentdate);
            if(date1 >= currentdate){
                console.log('5 date1==>', date1);
            }else{
              
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

    handleEndDate(event){
        if (event.target.name == "courseEndDate") {
            this.courseEndDate = event.target.value;
            console.log("this.courseEndDate====  " + this.courseEndDate);
            let date1 =new Date(this.courseStartDate).toISOString().split('T')[0];
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
            this.courseCampus = '';
            this.courseCampus = '';     
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

    handleInstitute(event){
        const selectedId = event.detail.selectedId;
        console.log('Selected Id====><><><><><>:', selectedId);

        this.InstituteId = selectedId;
        console.log("this.instituteName====  " + this.InstituteId);
    }
    handleCourse(event){
        const selectedId = event.detail.selectedId;
        console.log('Selected Id====><><><><><>:', selectedId);

        this.courseName = selectedId;
        console.log("this.instituteName====  " + this.InstituteId);
    }
    handleCourseInstAndCampusShowHide(event) {        
            const selectedId = event.detail.selectedId;
            console.log('Selected Id====><><><><><>:', selectedId);
    
            // Do something with the selectedId
       
        // if (event.target.name == "universityName") {
            this.universityName = selectedId;
            console.log("this.universityName====  " + this.universityName);
            this.showInstitute = true;

       // }

        // getUniversityNameCourse({ universityId: this.universityName }) //this parameter is passed to Class-CommunityLeadFormController.getInstituteRecord
        //     .then(result => {
        //         this.universityNameIdResult = result;
        //         console.log('universityNameIdResult=======> ' + JSON.stringify(this.universityNameIdResult));
        //     })
        //     .catch(error => {
        //         this.errorsUniversityId = error;
        //         console.log('errorsUniversityId=======> ' + this.errorsUniversityId);
        //     });

    }

   

    //Course Id Name Lookup Lead 
 //Avadhut Code
 @track CourseIdNameIdResult;
 @track errorsCourseIdName;
 handleCourseIdNameLead(event) {
    // if (event.target.name == "courseName") {
    //     this.courseName = event.target.value;
    //     console.log("this.courseName====  " + this.courseName);
    // }
    const selectedCourseId = event.detail;   
    console.log('Selected selectedCourseId====><><><><><>:', selectedCourseId);
    this.courseName = selectedCourseId;
    console.log("this.courseName====  " + this.courseName);


     getCourseIdName({ courseNameId: this.courseName }) //this parameter is passed to Class-CommunityLeadFormController.getInstituteRecord
         .then(result => {
             this.CourseIdNameIdResult = result;
             //this.courseName = this.CourseIdNameIdResult.Id;
             console.log('CourseIdNameIdResult=======> ' + JSON.stringify(this.CourseIdNameIdResult));
             //console.log('this.courseName getCourseIdName=======> ' + this.courseName);
            })
         .catch(error => {
             this.errorsCourseIdName = error;
             console.log('errorsCourseIdName=======> ' + this.errorsCourseIdName);
         });

 }

    /**********Institure info Update method************/
    handleInstituteSelection(event) {

        console.log('Inside handleInstituteSelection ');
        const selectedInstituteId = event.detail;
        console.log('selectedInstituteId Id====><><><><><>:', selectedInstituteId);
        
        this.InstituteId = selectedInstituteId;
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

    //update table row values in list
    // updateValues(event) {
    //     console.log('this.listOfEducationalTable valuessss===>' + JSON.stringify(this.listOfEducationalTable));
    //     var foundelement = this.listOfEducationalTable.find(ele => ele.Id == event.target.dataset.id);
    //     console.log('foundelement' + JSON.stringify(foundelement));
    //     if (event.target.name === 'EducationDetails') {
    //         foundelement.Education_Qualification__c = event.target.value;
    //         this.EducationDetails = foundelement.Education_Qualification__c;
    //         console.log('this.EducationDetails update values handle', this.EducationDetails);
    //     } else if (event.target.name === 'YearCompleted') {
    //         foundelement.Year_Completed__c = event.target.value;
    //         this.YearCompleted = foundelement.Year_Completed__c;
    //         console.log('this.YearCompleted update values handle', this.YearCompleted);
    //     } else if (event.target.name === 'PercentageMarks') {
    //         foundelement.Percentage_Marks_CGPA__c = event.target.value;
    //         this.PercentageMarks = foundelement.Percentage_Marks_CGPA__c;
    //         console.log('this.PercentageMarks update values handle', this.PercentageMarks);
    //     } else if (event.target.name === 'SchoolCollegeUniversity') {
    //         foundelement.School_College_University__c = event.target.value;
    //         this.SchoolCollegeUniversity = foundelement.School_College_University__c;
    //         console.log('this.SchoolCollegeUniversity update values handle', this.SchoolCollegeUniversity);
    //     }
    // }

    handleSaveCourseEduSection() {
        // console.log('this.EducationDetails SAVE====>', JSON.stringify(this.listOfEducationalTable));
        // console.log('this.EducationDetails SAVE====>', this.listOfEducationalTable.length);
        var isError = false;
        console.log('this.YearCompleted SAVE====>', this.YearCompleted);
        console.log('this.PercentageMarks SAVE====>', this.PercentageMarks);
        console.log('this.SchoolCollegeUniversity SAVE====>', this.SchoolCollegeUniversity);
        if (this.CountryOfStudyValue == '' || this.CountryOfStudyValue == undefined ||
            this.AdmissionStatus == '' || this.AdmissionStatus == undefined ||
            ((this.AdmissionStatus == 'Confirmed' || this.AdmissionStatus == 'Applied') && 
            (this.universityName == '' || this.universityName == undefined || 
            this.courseCampus == '' || this.courseCampus == undefined )) ||
            this.universityName == '' || this.universityName == undefined ||
            this.courseName == '' || this.courseName == undefined ||
            this.InstituteId == '' || this.InstituteId == undefined ||
            this.CourseCategoryValue == '' || this.CourseCategoryValue == undefined ||
            this.CourseTypeValue == '' || this.CourseTypeValue == undefined ||
            this.CourseLevelValue == '' || this.CourseLevelValue == undefined ||
            this.CourseStreamValue == '' || this.CourseStreamValue == undefined ||
            this.LangScoreCategoryValue == '' || this.LangScoreCategoryValue == undefined ||
            this.langTestScore == '' || this.langTestScore == undefined ||
            this.AnalytScoreCategoryValue == '' || this.AnalytScoreCategoryValue == undefined ||
            this.analyticalTestScore == '' || this.analyticalTestScore == undefined 
            // ||
            // this.courseName == '' || this.courseName == undefined
        ) {
            isError = true;
        }
        // if (this.listOfEducationalTable.length > 0) {
        //     for (var i = 0; i < this.listOfEducationalTable.length; i++) {
        //         var record = this.listOfEducationalTable[i];
        //         console.log('record:', record.Education_Qualification__c);
        //         if (record.Education_Qualification__c == '' || record.Education_Qualification__c == undefined) {
        //             isError = true;
        //         }
        //         else if (record.Percentage_Marks_CGPA__c == '' || record.Percentage_Marks_CGPA__c == undefined) {
        //             isError = true;
        //         }
        //         else if (record.School_College_University__c == '' || record.School_College_University__c == undefined) {
        //             isError = true;
        //         }
        //         else if (record.Year_Completed__c == '' || record.Year_Completed__c == undefined) {
        //             isError = true;
        //         }
        //     }
        // }
        if (!isError) {
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
                Analytics_Test_Score__c: this.analyticalTestScore
            }
            console.log('CourseSecSaveRec=====>' + JSON.stringify(CourseSecSaveRec));
            let CourseAppliAccDataSaveRec = {
                Id: this.AppliAccID
            }
            if (this.deleteEmpIds !== '') {
                this.deleteEmpIds = this.deleteEmpIds.substring(0);
            }

            // this.listOfEducationalTable.forEach(res => {
            //     if (!isNaN(res.Id)) {
            //         res.Id = null;
            //         console.log(' res.Id====>' + res.Id);
            //     }
            // });

            console.log(' this.deleteEmpIds====>' + this.deleteEmpIds);
            //Wrapper Class variable      
            let wrapperCommFormRecord = {
                leadSaveRec: JSON.stringify(CourseSecSaveRec),
               // appliEduDetailsSave: JSON.stringify(this.listOfEducationalTable),
                appliAccSaveRec: JSON.stringify(CourseAppliAccDataSaveRec),
                removeEducationIds: this.deleteEmpIds
            }
            console.log('wrapperCommFormRecord=====>' + JSON.stringify(wrapperCommFormRecord));

            creatCommFormLeadRecords({
                wrapperCommFormDetails: JSON.stringify(wrapperCommFormRecord),
            })
                .then(response => {

                    this.wrapperForCommLeadForm = response;
                    console.log('Lead Data SAVE Method', +JSON.stringify(this.wrapperForCommLeadForm));
                  //  console.log('University id', +this.wrapperForCommLeadForm);

                    // //Lead Applicant
                    // this.leadID = this.wrapperForCommLeadForm.LeadRecords.Id;
                    // console.log('this.leadID data===>' + this.leadID);

                    // this.CountryOfStudyValue = this.wrapperForCommLeadForm.LeadRecords.Country_of_Study__c;
                    // this.AdmissionStatus = this.wrapperForCommLeadForm.LeadRecords.Admission_Status__c;
                    // console.log('this.AdmissionStatus data===>' + this.AdmissionStatus);
                    // this.universityName = this.wrapperForCommLeadForm.LeadRecords.University_Name__c;
                    // this.courseCampus = this.wrapperForCommLeadForm.LeadRecords.Campus__c;
                    // this.InstituteId = this.wrapperForCommLeadForm.LeadRecords.Institute_Name__c;
                    // this.CourseCategoryValue = this.wrapperForCommLeadForm.LeadRecords.Course_Category__c;
                    // console.log('this.CourseCategoryValue data===>' + this.CourseCategoryValue);
                    // this.CourseTypeValue = this.wrapperForCommLeadForm.LeadRecords.Course_Type__c;
                    // this.CourseLevelValue = this.wrapperForCommLeadForm.LeadRecords.Course_Level__c;
                    // this.CourseStreamValue = this.wrapperForCommLeadForm.LeadRecords.Course_Stream__c;
                    // this.courseName = this.wrapperForCommLeadForm.LeadRecords.Course_Id__c;
                    // console.log('this.courseName data===>' + this.courseName);
                    // this.courseStartDate = this.wrapperForCommLeadForm.LeadRecords.Course_Start_Date__c;
                    // this.courseEndDate = this.wrapperForCommLeadForm.LeadRecords.Course_End_Date__c;
                    // this.LangScoreCategoryValue = this.wrapperForCommLeadForm.LeadRecords.Language_Score_Category__c;
                    // this.langTestScore = this.wrapperForCommLeadForm.LeadRecords.Language_Test_Score__c;
                    // this.AnalytScoreCategoryValue = this.wrapperForCommLeadForm.LeadRecords.Analytics_Score_Category__c;
                    // this.analyticalTestScore = this.wrapperForCommLeadForm.LeadRecords.Analytics_Test_Score__c;

                    // //Check if Admission Status is Confirmed or Applied then show Universityn campus & Institute fields
                    // if (this.AdmissionStatus == "Confirmed" || this.AdmissionStatus == "Applied") {
                    //     this.ShowFieldsCourseUniversity = true;
                    //     console.log("this.ShowFieldsCourseUniversity====  " + this.ShowFieldsCourseUniversity);
                    // }
                    // else {
                    //     this.ShowFieldsCourseUniversity = false;
                    //     console.log("this.ShowFieldsCourseUniversity====  " + this.ShowFieldsCourseUniversity);
                    // }
                    // // console.log("this.wrapperForCommLeadForm.AppliEduDetailsRecord.length===>" + this.wrapperForCommLeadForm.AppliEduDetailsRecord.length);
                    // // if (this.wrapperForCommLeadForm.AppliEduDetailsRecord.length > 0) {
                    // //     this.listOfEducationalTable = JSON.parse(JSON.stringify(this.wrapperForCommLeadForm.AppliEduDetailsRecord));
                    // // } else {
                    // //     let randomId = Math.random() * 16;
                    // //     let myNewElement = { Id: randomId, Education_Qualification__c: "", Year_Completed__c: "", Percentage_Marks_CGPA__c: "", School_College_University__c: "" };
                    // //     console.log("myNewElement===>" + myNewElement);
                    // //     this.listOfEducationalTable = [myNewElement];

                    // //     console.log("this.listOfEducationalTable===>" + this.listOfEducationalTable);
                    // // }
                    // // if (this.listOfEducationalTable.length > 0) {
                    // //     this.listOfEducationalTable.length + 1;
                    // // }
                    // //Applicant Account
                    // this.AppliAccID = this.wrapperForCommLeadForm.AccRecords.Account__c;
                    // console.log('this.AppliAccID data===>' + this.AppliAccID);

                    //NEw code 29-Mar
                    // if (this.AdmissionStatus == "Not Applied") {                       
                    //     this.universityName = '';
                    //     this.courseCampus = '';
                    //     this.courseCampus = '';
                    //     console.log("this.ShowFieldsCourseUniversity====  " + this.ShowFieldsCourseUniversity);
                    // }

                    console.log(response);
                    if (response != null) {
                        console.log('response inside if=====>' + response);
                    }
                    this.isLoading = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Sucess',
                            message: 'Successfully Saved',
                            variant: 'Success',
                        }),
                    );

                }).catch(error => {
                    console.log(error);
                    this.isLoading = false;
                })
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please fill all the mandatory fields',
                    variant: 'Error',
                }),
            );
        }
    }

}