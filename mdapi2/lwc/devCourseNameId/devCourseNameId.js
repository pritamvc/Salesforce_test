import { api, LightningElement, track, wire } from 'lwc';
import getLookupData from '@salesforce/apex/CourseSectionLookupField.getLookupData';
import getLookupDataInstitute from '@salesforce/apex/CourseSectionLookupField.getLookupDataInstitute';
import getLookupDataCourse from '@salesforce/apex/CourseSectionLookupField.getLookupDataCourse';

export default class DevCourseNameId extends LightningElement {
    @api universityObj = 'University__c';
    @track universityId;   //University ID stored in this variable
    @api countryOfStudy; //Name of the coutry of study field on lead from Parent

    @api iconName;
    @api searchPlaceholder = 'Search Universities...';
    @track selectedName;
    @track recordsUniversity;
    @track isValueSelected;
    @track blurTimeout;
    @track searchTerm;

    //Institute fields
   // @api instituteObj = 'Institute__c';
    @track recordsInst;
    @track instituteId;

    @api iconName2;
    @api searchPlaceholder2 = 'Search Institutes...';
    @track selectedInstituteId;
    @track selectedInstituteName;
    @track isValueSelectedInstitute = false;
    @track searchTermInstitute;
    @track blurTimeout2;

    //Course Fields
    @track recordsCourse;

    @api iconName3;
    @api searchPlaceholder3 = 'Search Courses...';
    @track selectedCourseId;
    @track selectedCourseName;
    @track isValueSelectedCourse = false;
    @track searchTermCourse;
    @track blurTimeout3;

   

    //css
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = '';
    @track boxClass2 = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass2 = '';
    @track boxClass3 = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass3 = '';

    // @wire(getLookupData, {
    //     searchTerm: '$searchTerm', universityObject: '$universityObj',
    //     countryOfStudyLead: '$countryOfStudy'})
    //     //, searchTermInstitute : '$searchTermInstitute', instituteObject : '$instituteObj'
    // wiredRecords({ error, data }) {
    //     if (data) {
    //         console.log('data===>', JSON.stringify(data));
    //        // if(data.university != ''){
    //         this.error = undefined;
    //         this.recordsUniversity = data;
    //         console.log(' this.recordsUniversity===>', JSON.stringify(this.recordsUniversity));
    //      //   }
    //       //  if(data.institute != ''){
    //         // this.recordsInst = data.institute;
    //         // console.log(' this.recordsInst===>', JSON.stringify(this.recordsInst));
    //       //  }
    //     } else if (error) {
    //         this.error = error;
    //         console.log('  this.error===>', JSON.stringify(this.error));
    //         this.recordsUniversity = undefined;
    //       //  this.recordsInst = undefined;
    //     }
    // }

    handleClick() {
        this.searchTerm = '';
        this.inputClass = 'slds-has-focus';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
        console.log('countryOfStudy check===>', this.countryOfStudy);
    }

    onBlur() {
        this.blurTimeout = setTimeout(() => { this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus' }, 300);
    }

    onSelect(event) {        
        let selectedId = event.currentTarget.dataset.id;
        console.log('selectedId on Select===>', selectedId);
        this.universityId = selectedId;
        console.log('this.universityId on Select===>', this.universityId);

        let selectedName = event.currentTarget.dataset.name;
        console.log('selectedName on Select===>', selectedName);
        
        getLookupDataInstitute({universityId: this.universityId})
        .then(result => {
            console.log('result on Select getLookupDataInstitute===>', JSON.stringify(result));
            this.recordsInst = result;
            console.log(' this.recordsInst===>', JSON.stringify(this.recordsInst));
        })
        .catch(error => {
            console.log('error on Select getLookupDataInstitute===>', JSON.stringify(error));
        });     

        const valueSelectedEvent = new CustomEvent('lookupselected', { detail: selectedId });
        console.log('valueSelectedEvent on Select===>', valueSelectedEvent);
        this.dispatchEvent(valueSelectedEvent);

        this.isValueSelected = true;
        this.selectedName = selectedName;
        if (this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';   
    }

    handleRemovePill() {
        this.isValueSelected = false;
    }

    onChange(event) {
        this.searchTerm = event.target.value;
        console.log('this.searchTerm on change===>', this.searchTerm);
    }

    //Institute
    handleClickInstitute() {
        this.searchTermInstitute = '';
        this.inputClass2 = 'slds-has-focus';
        this.boxClass2 = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
        console.log('University ID check===>', this.universityID);
    }

    onBlurInstitute() {
        this.blurTimeout2 = setTimeout(() => { this.boxClass2 = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus' }, 300);
    }

    onSelectInstitute(event) {
        let selectedInstituteId = event.currentTarget.dataset.id;
        console.log('selectedInstituteId on Select===>', selectedInstituteId);
        this.instituteId = selectedInstituteId;
        console.log('this.instituteId on onSelectInstitute===>', this.instituteId);

        let selectedInstituteName = event.currentTarget.dataset.name;
        console.log('selectedInstituteName on onSelectInstitute===>', selectedInstituteName);

        getLookupDataCourse({instituteId: this.instituteId})
        .then(result => {
            console.log('result on onSelectInstitute getLookupDataCourse===>', JSON.stringify(result));
            this.recordsCourse = result;
            console.log(' this.recordsCourse===>', JSON.stringify(this.recordsCourse));
        })
        .catch(error => {
            console.log('error on onSelectInstitute getLookupDataCourse===>', JSON.stringify(error));
        });     
        
        const valueSelectedEventInst = new CustomEvent('lookupselectedInstituteId', { detail: selectedInstituteId });
        console.log('valueSelectedEventInst on Select===>', valueSelectedEventInst);
        this.dispatchEvent(valueSelectedEventInst);

        this.isValueSelectedInstitute = true;
        this.selectedInstituteName = selectedInstituteName;
        if (this.blurTimeout2) {
            clearTimeout(this.blurTimeout2);
        }
        this.boxClass2 = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    }

    handleRemovePillInst() {
        this.isValueSelectedInstitute = false;
    }

    onChangeInstitute(event) {
        this.searchTermInstitute = event.target.value;
        console.log('this.searchTermInstitute on change===>', this.searchTermInstitute);

        // const searchTermEvent = new CustomEvent('serachtermselected', { detail:  this.searchTermInstitute });
        // console.log('searchTermEvent on Select===>', searchTermEvent);
        // this.dispatchEvent(searchTermEvent);
    }

     //Course
     handleClickCourse() {
        this.searchTermCourse = '';
        this.inputClass3 = 'slds-has-focus';
        this.boxClass3 = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
    }

    onBlurCourse() {
        this.blurTimeout3 = setTimeout(() => { this.boxClass3 = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus' }, 300);
    }

    onSelectCourse(event) {
        let selectedCourseId = event.currentTarget.dataset.id;
        console.log('selectedCourseId on Select===>', selectedCourseId);
        this.courseId = selectedCourseId;
        console.log('this.courseId on onSelectCourse===>', this.courseId);

        let selectedCourseName = event.currentTarget.dataset.name;
        console.log('selectedCourseName on onSelectCourse===>', selectedCourseName);

        // getLookupDataCourse({instituteId: this.instituteId})
        // .then(result => {
        //     console.log('result on onSelectCourse getLookupDataCourse===>', JSON.stringify(result));
        //     this.recordsCourse = result;
        //     console.log(' this.recordsCourse===>', JSON.stringify(this.recordsCourse));
        // })
        // .catch(error => {
        //     console.log('error on onSelectCourse getLookupDataCourse===>', JSON.stringify(error));
        // });     
        
        const valueSelectedEventCourse = new CustomEvent('lookupselectedCourseId', { detail: selectedCourseId });
        console.log('valueSelectedEventCourse on Select===>', valueSelectedEventCourse);
        this.dispatchEvent(valueSelectedEventCourse);

        this.isValueSelectedCourse = true;
        this.selectedCourseName = selectedCourseName;
        if (this.blurTimeout3) {
            clearTimeout(this.blurTimeout3);
        }
        this.boxClass2 = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    }

    handleRemovePillCourse() {
        this.isValueSelectedCourse = false;
    }

    onChangeCourse(event) {
        this.searchTermCourse = event.target.value;
        console.log('this.searchTermCourse on change===>', this.searchTermCourse);

        // const searchTermEvent = new CustomEvent('serachtermselected', { detail:  this.searchTermInstitute });
        // console.log('searchTermEvent on Select===>', searchTermEvent);
        // this.dispatchEvent(searchTermEvent);
    }
}