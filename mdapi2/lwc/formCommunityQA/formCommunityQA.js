import { LightningElement, wire, api, track } from 'lwc';
import creatLeadRecord from '@salesforce/apex/CommunityLeadFormController.creatLeadRecord';
import creatCommFormLeadRecords from '@salesforce/apex/CommunityLeadFormController.creatCommFormLeadRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import getInstituteRecord from '@salesforce/apex/CommunityLeadFormController.getInstituteRecord';
import getUniversityNameCourse from '@salesforce/apex/CommunityLeadFormController.getUniversityNameCourse';
import getWrapperClassCommFormLists from '@salesforce/apex/CommunityLeadFormController.getWrapperClassCommFormList';
import getPincodeRecord from '@salesforce/apex/CommunityLeadFormController.getPincodeRecord';
import OtpRequest from '@salesforce/apex/EmailVerification.OtpRequest';
import updateLeadFromCommunity from '@salesforce/apex/AccountTriggerHandler.updateLeadFromCommunityForm';
import OtpRequestMob from '@salesforce/apex/MobileVerification.OtpRequest';
import OtpVerify from '@salesforce/apex/EmailVerification.verify';
import OtpVerifyMob from '@salesforce/apex/MobileVerification.OtpVerify';
import AadharVerification from '@salesforce/apex/DocumentVerification.AadharVerification';
import downloadAadhar from '@salesforce/apex/DocumentVerification.DownloadAadhar';
import panVerification from '@salesforce/apex/DocumentVerification.PanProfile';
import getDeplicateAccout from '@salesforce/apex/AccountTriggerHandler.getDupAccountCommunityForm';
import getCoAppRecords from '@salesforce/apex/DemoCommunityLeadForm.getCoapp';
//import communityWrapperFormMethod from '@salesforce/apex/DemoCommunityLeadForm.communityWrapperFormMethod';

export default class CommunityFormARS extends LightningElement {
    @track todaysDate;
   @track isStepOne = true;
    @track currentStep = "1";
    activeSections = [''];

    @track LfNName;
    @track middleName;
    @track LLastName;
    @track LDateOfBirth;
    @track LEmail;
    @track LMobile;
   
    @track FatherFirstName;
    @track FatherMiddleName;
    @track FatherLastName;
    @track LMotherName; 
    @track LMotherLastName;
    @track SpouseFirstName;
    @track SpouseMiddleName;
    @track SpouseLastName;
    @track PANNumber;
    @track ckycNumber;
    @track LAadharNumber;    
    @track driveLicenseNumber;
    @track voterId;
    @track passportNumber;   
    //Address Current
    @track ApplicurrentAddress;
    @track appliCurrentCity;
    @track appliCurrentTaluka;
   // @track appliCurrentDistrict;
    @track appliCurrentPincode;
    @track appliCurrentLandmark;
    @track appliCurrentState;
    @track appliCurrentCountry;
    //Address Permanent
    @track permanentAddress;
    @track appliPermanentCity;
    @track appliPermanentTaluka;
    @track appliPermanentDistrict;
    @track appliPermanentPincode;
    @track appliPermanentLandmark;
    @track appliPermanentState;
    @track appliPermanentCountry;
   // @track IsCommunicationAddress;
   @track AppliPermIsCommAddressvalue = '';   
   //Applicant section lead
    //Gender from SFDC
    @track LGender;    
    @api objectName = 'Lead';
    @api fieldName = 'Gender__c';
    @track fieldLabel;
    @api recordTypeId;
    @api value;
    @api otp;
    @api request_id;
    @track options;
    apiFieldName;
    //Salutation
    @track salutation;   
    @api salutationField = 'Salutation';
    @track salutationLabel;    
    @api salutationValue;
    @track salutationOptions;
    apisalutation;
    //Is Income Considered / Is Financial
    @track isIncomeConsiderIsFin;   
    @api isIncomeConsiderIsFinField = 'Is_Income_Considered_Is_Financial__c';
    @track isIncomeConsiderIsFinLabel;    
    @api isIncomeConsiderIsFinValue;
    @track isIncomeConsiderIsFinOptions;
    apiisIncomeConsiderIsFin;
    //Marital Status Lead
    @track maritalStatus;   
    @api maritalStatusField = 'Marital_Status__c';
    @track maritalStatusLabel;    
    @api maritalStatusValue;
    @track maritalStatusOptions;
    apimaritalStatus;
     //Appli Address Type
     @track appliAddressType;   
     @api appliAddressTypeField = 'Address_Type__c';
     @track appliAddressTypeLabel;    
     @api appliAddressTypeValue;
     @track appliAddressTypeOptions;
     apiappliAddressType;
     //Appli Address Proof
     @track appliAddressProof;   
     @api appliAddressProofField = 'Address_Proof__c';
     @track appliAddressProofLabel;    
     @api appliAddressProofValue;
     @track appliAddressProofOptions;
     apiappliAddressProof;
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

     @track EduYearCompleted;
     @track EduPercentageMarksCGPA;
     @track EduSchoolCollegeUniversity;
    //Co-applicant picklist
    @api recordTypeId3;
    @api objectNameCoAppli = 'Co_Applicant__c';
    //Relationship with Applicant from Co-appli from SFDC
    @track RelshipWithAppliPerAcc;
    @api RelshipWithAppliPerAccField = 'Relation_with_applicant__c';
    @track RelshipWithAppliPerAccLabel;    
    @api RelshipWithAppliPerAccValue;
    @track RelshipWithAppliPerAccOptions;
     apiRelshipWithAppliPerAcc;
    //Relationship Proof from Co-appli from SFDC
    @track RelshipProofPerAcc;
    @api RelshipProofPerAccField = 'Relationship_Proof__c';
    @track RelshipProofPerAccLabel;    
    @api RelshipProofPerAccValue;
    @track RelshipProofPerAccOptions;
    apiRelshipProofPerAcc;
     //Type of Applicant from Co-appli from SFDC
     @track TypeOfAppliFromCoAppli;
     @api TypeOfAppliFromCoAppliField = 'Type__c';
     @track TypeOfAppliFromCoAppliLabel;    
     @api TypeOfAppliFromCoAppliValue;
     @track TypeOfAppliFromCoAppliOptions;
     apiTypeOfAppliFromCoAppli;
     
    //Show Hide fields
    @track ShowFieldsAppliSpouse = false;
    @track ShowFieldsCourseUniversity = false;
    @track ShowFieldsCourseInstAndCampus = false;
    @track ShowFieldsApplicantCategory = false;    
    @track ShowFieldsRelationWithAppliIfOther = false;
    @track ShowFieldsAppliDriveLicDateofExpiry = false;
    @track ShowFieldsCoAppliDriveLicDateofExpiry = false;
   
    @track instituteResult;
    @track errors;
    @track instAdderess;
    @track instCity;
    @track instState;
    @track instCountry;
    @track instPINCode;
    @track InstituteId;   
    @track isLoading = false;
    //verification
    @track otpValue;
    @track otpValueMob;
    @track otpValueAadhar;
    @track errormsg="";
    @track verified=false;
    @track buttonLabel = 'Verify Email';
    @track buttonStyle = 'display:none';
    @track verifiedMob=false;
    @track buttonLabelMob = 'Verify Mobile';
    @track buttonStyleMob = 'display:none';
    @track verifiedAadhar=false;
    @track buttonLabelAadhar = 'Verify Aadhar';
    @track buttonStyleAadhar = 'display:none';
    @track verifiedPan=false;
    @track buttonLabelPan = 'Verify PAN';
    @track buttonStylePan = 'display:none';;
    @track aadharLastFour = '';
    @track sumScore=0;
    @track sumScorePercent=0;
    @track matchText='';
    @track verifiedbuttonAadhar=false;
    @track activeSections = [];
    @track isOpen1 = false;
    @track isOpen2 = false;
    @track isOpen3 = false;
   @track displayText = 'display:none;'
   @track displayTextMob = 'display:none;'
   @track displayTextAadhar = 'display:none;'
    
    @track currentPath = "1";
  
     @track activeSectionMessage = 'A';
    
    //Table section list
    @track listOfCoappliAccTable;   
    @track listOfEducationalTable;
    @track listOfApplicants;
    //Lead Id variable
     @track leadId;
    //Set Time out
    timeSpan = 60000;
    event1;
    //Account Picklist values 
    @api recordTypeId1;
    @api objectNameAcc = 'Account';
    //Marital Status from Account from SFDC
    @track MaritalStatusPerAcc;
    @api MaritalStatusPerAccField = 'Marital_Status__c';
    @track MaritalStatusPerAccLabel;    
    @api MaritalStatusPerAccValue;
    @track MaritalStatusPerAccOptions;
    apiMaritalStatusPerAcc;
    //Gender from Account from SFDC
    @track GenderPerAcc;
    @api GenderPerAccField = 'Gender__c';
    @track GenderPerAccLabel;    
    @api GenderPerAccValue;
    @track GenderPerAccOptions;
    apiGenderPerAcc;
    
    //Address Proof Current address from Account from SFDC
    @track AddProofCurrentPerAcc;
    @api AddProofCurrentPerAccField = 'Address_Proof__c';
    @track AddProofCurrentPerAccLabel;    
    @api AddProofCurrentPerAccValue;
    @track AddProofCurrentPerAccOptions;
    apiAddProofCurrentPerAcc;
    //Address Proof Permanent address from Account from SFDC
    @track AddProofPermantPerAcc;
    @api AddProofPermantPerAccField = 'Address_Proof__c';
    @track AddProofPermantPerAccLabel;    
    @api AddProofPermantPerAccValue;
    @track AddProofPermantPerAccOptions;
    apiAddProofPermantPerAcc;
    //Co-applicant or Guarator Category from Account from SFDC
    @track AppliCategoryPerAcc;
    @api AppliCategoryPerAccField = 'Applicant_Category__c';
    @track AppliCategoryPerAccLabel;    
    @api AppliCategoryPerAccValue;
    @track AppliCategoryPerAccOptions;
    apiAppliCategoryPerAcc;   
    //Employment Details Section
    //Employment Type from Account from SFDC
    @track EmploymentTypePerAcc;
    @api EmploymentTypePerAccField = 'Employment_Type__c';
    @track EmploymentTypePerAccLabel;    
    @api EmploymentTypePerAccValue;
    @track EmploymentTypePerAccOptions;
    apiEmploymentTypePerAcc;
    //No. of Years with current employer from Account from SFDC
    @track NumYearsCurrEmployerPerAcc;
    @api NumYearsCurrEmployerPerAccField = 'No_Of_Years_with_Current_Employer__c';
    @track NumYearsCurrEmployerPerAccLabel;    
    @api NumYearsCurrEmployerPerAccValue;
    @track NumYearsCurrEmployerPerAccOptions;
    apiNumYearsCurrEmployerPerAcc;
    //Type of Company from Account from SFDC
    @track TypeOfCompanyPerAcc;
    @api TypeOfCompanyPerAccField = 'Type_Of_Company__c';
    @track TypeOfCompanyPerAccLabel;    
    @api TypeOfCompanyPerAccValue;
    @track TypeOfCompanyPerAccOptions;
    apiTypeOfCompanyPerAcc;
    //Role in Organization from Account from SFDC
    @track RoleInOrgPerAcc;
    @api RoleInOrgPerAccField = 'Role_In_Organization__c';
    @track RoleInOrgPerAccLabel;    
    @api RoleInOrgPerAccValue;
    @track RoleInOrgPerAccOptions;
    apiRoleInOrgPerAcc;
     //Is Income Considered / Is Financial from Account from SFDC
     @track isIncomeConsiderIsFinPerAcc;   
     @api isIncomeConsiderIsFinPerAccField = 'Is_Income_Considered_Is_Financial__c';
     @track isIncomeConsiderIsFinPerAccLabel;    
     @api isIncomeConsiderIsFinPerAccValue;
     @track isIncomeConsiderIsFinPerAccOptions;
     apiisIncomeConsiderIsFinPerAcc;
  //otp modal
  @track showModal = false;
  @track showModalAadhar = false;
  @track showModalMobile = false;
  @track requestIdTemp='';
  @track requestIdMob='';
  @track requestIdAadhar='';
  @track consent = false;
  @track open = true;
   secFive = false;
   secSix = false;
   secSeven = false;
   secEight = false;
   secNine = false;
   secTen = false;
   @track EduIndex;
  
  handleClickFive() {
    this.secFive = true;
    this.secSix = false;
    this.secSeven = false;
    this.secEight = false;
    this.secNine = false;
    this.secTen = false;
}
   handleClickSix() {
    this.secFive = false;
    this.secSix = true;
    this.secSeven = false;
    this.secEight = false;
    this.secNine = false;
    this.secTen = false;
}
   handleClickSeven() {
    this.secFive = false;
    this.secSix = false;
    this.secSeven = true;
    this.secEight = false;
    this.secNine = false;
    this.secTen = false;
}
   handleClickEight() {
    this.secFive = false;
    this.secSix = false;
    this.secSeven = false;
    this.secEight = true;
    this.secNine = false;
    this.secTen = false;
}
   handleClickNine() {
    this.secFive = false;
    this.secSix = false;
    this.secSeven = false;
    this.secEight = false;
    this.secNine = true;
    this.secTen = false;
}
   handleClickTen() {
    this.secFive = false;
    this.secSix = false;
    this.secSeven = false;
    this.secEight = false;
    this.secNine = false;
    this.secTen = true;
}
  closeModal() {
    this.showModal = false;
    this.otpValue = ""
  }
  closeModalMobile() {
    this.showModalMobile = false;
    this.otpValueMob=""
 
  }
  closeModalAadhar() {
    this.showModalAadhar = false;
    this.otpValueAadhar=""
  }
  handleConsentChange(event) {
    this.consent = event.target.checked;
    console.log(this.consent ? 'yes':'no');
  }
  handleConsentChange(event) {
    this.consent = event.target.checked;
    console.log(this.consent ? 'yes':'no');
  }
  @wire(OtpVerify, {otp: '$otp', request_id: '$request_id'})
 otpVerify({error, data}) {
 if (error) { 
 console.log("error");
 }
 if (data) { 
 this.showModalMobile = false;
      const event = new ShowToastEvent({
       title: 'Success',
       message: 'Mobile Number Verified!',
       variant: 'success',
   });
   this.dispatchEvent(event);
   console.log(data);
 }
 }
    @wire(getObjectInfo, { objectApiName: '$objectName' })
    getObjectData1({ error, data }) {
        if (data) {
            if (this.recordTypeId == null)
                this.recordTypeId = data.defaultRecordTypeId;

                this.apiFieldName = this.objectName + '.' + this.fieldName;
                this.fieldLabel = data.fields[this.fieldName].label;

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

                   this.apisalutation = this.objectName + '.' + this.salutationField;
                   this.salutationLabel = data.fields[this.salutationField].label;

                    this.apiisIncomeConsiderIsFin = this.objectName + '.' + this.isIncomeConsiderIsFinField;
                    this.isIncomeConsiderIsFinLabel = data.fields[this.isIncomeConsiderIsFinField].label;

                    this.apimaritalStatus = this.objectName + '.' + this.maritalStatusField;
                    this.maritalStatusLabel = data.fields[this.maritalStatusField].label;

                    this.apiappliAddressType = this.objectName + '.' + this.appliAddressTypeField;
                    this.appliAddressTypeLabel = data.fields[this.appliAddressTypeField].label;

                     this.apiappliAddressProof = this.objectName + '.' + this.appliAddressProofField;
                     this.appliAddressProofLabel = data.fields[this.appliAddressProofField].label;
        } else if (error) {           
            console.log(error);
        }
    }         
   
    //Gender
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: '$apiFieldName' })
    getPicklistValues1({ error, data }) {
        if (data) {
            // Map picklist values
            this.options = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };
            });
            console.log('==============Genderoptionsdata  ' + data);
        } else if (error) {           
            console.log(error);
        }
    }

    //Country of Study
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: '$apiCountryOfStudyObjFieldName' })
    getPicklistValues2({ error, data }) {
        if (data) {
            // Map picklist values
            this.CountryOfStudyFieldOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };               
            });
            console.log('==============CountryOfStudyFieldOptionsdata  ' + data);

        } else if (error) {         
            console.log('==============Error  ' + error);
           
        }
    }

    //Admission Status   
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: '$apiAdmissionStatus' })
    getPicklistValues3({ error, data }) {
        if (data) {
            // Map picklist values
            this.AdmissionStatusOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };               
            });
            console.log('==============AdmissionStatusOptions' + data);

        } else if (error) {        
            console.log('Error  ' + error);
          
        }
    }

    //Course Category   
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: '$apiCourseCategory' })
    getPicklistValues4({ error, data }) {
        if (data) {
            // Map picklist values
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
            // Map picklist values
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
            // Map picklist values
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
            // Map picklist values
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

    //Salutation
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: '$apisalutation' })
    getPicklistValues10({ error, data }) {
        if (data) {
            // Map picklist values
            this.salutationOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };               
            });
            console.log('==============salutationOptions' + data);

        } else if (error) {          
            console.log(error);
        }
    }

    //Is Income Considered / Is Financial 
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: '$apiisIncomeConsiderIsFin' })
    getPicklistValues11({ error, data }) {
        if (data) {
            // Map picklist values
            this.isIncomeConsiderIsFinOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };               
            });
            console.log('==============isIncomeConsiderIsFinOptions' + data);

        } else if (error) {       
            console.log(error);
        }
    }

    //Marital Status
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: '$apimaritalStatus' })
    getPicklistValues12({ error, data }) {
        if (data) {
            // Map picklist values
            this.maritalStatusOptions = data.values.map(plValue => {
                return {
                      label: plValue.label,
                      value: plValue.value
                };               
            });
            console.log('==============maritalStatusOptions' + data);
  
        } else if (error) {            
            console.log(error);
        }
    }

    //Appli Address Type
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: '$apiappliAddressType' })
    getPicklistValues13({ error, data }) {
        if (data) {
            // Map picklist values
            this.appliAddressTypeOptions = data.values.map(plValue => {
                return {
                      label: plValue.label,
                      value: plValue.value
                };               
            });
            console.log('==============appliAddressTypeOptions' + data);
  
        } else if (error) {           
            console.log(error);
        }
    }

     //Appli Address Proof
     @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: '$apiappliAddressProof' })
     getPicklistValues14({ error, data }) {
         if (data) {
             // Map picklist values
             this.appliAddressProofOptions = data.values.map(plValue => {
                 return {
                       label: plValue.label,
                       value: plValue.value
                 };               
             });
             console.log('==============appliAddressProofOptions' + data);
   
         } else if (error) {       
             console.log(error);
         }
     }   
       
    //Account Picklist field from SFDC
    @wire(getObjectInfo, { objectApiName: '$objectNameAcc' })
    getObjectData2({ error, data }) {
        console.log('Inside objectApiName: Account');
        console.log('objectApiName' + this.objectApiName);
        if (data) {
            console.log('Inside if');
            if (this.recordTypeId1 == null)
            console.log('Inside recordTypeId1');
                this.recordTypeId1 = data.defaultRecordTypeId;
                console.log('Inside this.recordTypeId1' + this.recordTypeId1); //its Non indivial acc recordtpye
              
                this.apiMaritalStatusPerAcc = this.objectNameAcc + '.' + this.MaritalStatusPerAccField;
                this.MaritalStatusPerAccLabel = data.fields[this.MaritalStatusPerAccField].label;  
              
                this.apiGenderPerAcc = this.objectNameAcc + '.' + this.GenderPerAccField;
                this.GenderPerAccLabel = data.fields[this.GenderPerAccField].label;                  
          
                this.apiAddProofCurrentPerAcc = this.objectNameAcc + '.' + this.AddProofCurrentPerAccField;
                this.AddProofCurrentPerAccLabel = data.fields[this.AddProofCurrentPerAccField].label;   

                this.apiAddProofPermantPerAcc = this.objectNameAcc + '.' + this.AddProofPermantPerAccField;
                this.AddProofPermantPerAccLabel = data.fields[this.AddProofPermantPerAccField].label;   

                this.apiEmploymentTypePerAcc = this.objectNameAcc + '.' + this.EmploymentTypePerAccField;
                this.EmploymentTypePerAccLabel = data.fields[this.EmploymentTypePerAccField].label; 
       
                this.apiNumYearsCurrEmployerPerAcc = this.objectNameAcc + '.' + this.NumYearsCurrEmployerPerAccField;
                this.NumYearsCurrEmployerPerAccLabel = data.fields[this.NumYearsCurrEmployerPerAccField].label; 

                this.apiTypeOfCompanyPerAcc = this.objectNameAcc + '.' + this.TypeOfCompanyPerAccField;
                this.TypeOfCompanyPerAccLabel = data.fields[this.TypeOfCompanyPerAccField].label; 

                this.apiRoleInOrgPerAcc = this.objectNameAcc + '.' + this.RoleInOrgPerAccField;
                this.RoleInOrgPerAccLabel = data.fields[this.RoleInOrgPerAccField].label; 

                this.apiisIncomeConsiderIsFinPerAcc = this.objectNameAcc + '.' + this.isIncomeConsiderIsFinPerAccField;
                this.isIncomeConsiderIsFinPerAccLabel = data.fields[this.isIncomeConsiderIsFinPerAccField].label; 

        } else if (error) {           
            console.log(error);
        }     
    }

    //Marital Status - Account
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId1', fieldApiName: '$apiMaritalStatusPerAcc' })
    getPicklistValues011({ error, data }) {
        if (data) {
            // Map picklist values
            this.MaritalStatusPerAccOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };               
            });
            console.log('==============MaritalStatusAccOptions  ' + data);

        } else if (error) {
         
            console.log(error);
        }
    }

    //Gender - Account
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId1', fieldApiName: '$apiGenderPerAcc' })
    getPicklistValues012({ error, data }) {
        if (data) {
            // Map picklist values
            this.GenderPerAccOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };               
            });
            console.log('==============GenderAccOptions  ' + data);

        } else if (error) {
        
            console.log(error);
        }
    }
    
     //Address Proof Current - Account 
     @wire(getPicklistValues, { recordTypeId: '$recordTypeId1', fieldApiName: '$apiAddProofCurrentPerAcc' })
     getPicklistValues015({ error, data }) {
         if (data) {
             // Map picklist values
             this.AddProofCurrentPerAccOptions = data.values.map(plValue => {
                 return {
                     label: plValue.label,
                     value: plValue.value
                 };               
             });
             console.log('==============AddProofCurrentPerAcc  ' + data);
 
         } else if (error) {
         
             console.log(error);
         }
     }

     //Address Proof Permanent - Account 
     @wire(getPicklistValues, { recordTypeId: '$recordTypeId1', fieldApiName: '$apiAddProofPermantPerAcc' })
     getPicklistValues016({ error, data }) {
         if (data) {
             // Map picklist values
             this.AddProofPermantPerAccOptions = data.values.map(plValue => {
                 return {
                     label: plValue.label,
                     value: plValue.value
                 };               
             });
             console.log('==============RelshipProofOptions  ' + data);
 
         } else if (error) {
        
             console.log(error);
         }
     }

     //Employment Type - Account 
     @wire(getPicklistValues, { recordTypeId: '$recordTypeId1', fieldApiName: '$apiEmploymentTypePerAcc' })
     getPicklistValues017({ error, data }) {
         if (data) {
             // Map picklist values
             this.EmploymentTypePerAccOptions = data.values.map(plValue => {
                 return {
                     label: plValue.label,
                     value: plValue.value
                 };               
             });
             console.log('==============EmploymentTypePerAccOptions  ' + data);
 
         } else if (error) {
       
             console.log(error);
         }
     }

     //No. of Years with current employer - Account
     @wire(getPicklistValues, { recordTypeId: '$recordTypeId1', fieldApiName: '$apiNumYearsCurrEmployerPerAcc' })
     getPicklistValues018({ error, data }) {
         if (data) {
       
             this.NumYearsCurrEmployerPerAccOptions = data.values.map(plValue => {
                 return {
                     label: plValue.label,
                     value: plValue.value
                 };               
             });
             console.log('==============NumYearsCurrEmployerPerAccOptions  ' + data);
 
         } else if (error) {
        
             console.log(error);
         }
     }

     //Type of Company - Account
     @wire(getPicklistValues, { recordTypeId: '$recordTypeId1', fieldApiName: '$apiTypeOfCompanyPerAcc' })
     getPicklistValues019({ error, data }) {
         if (data) {
       
             this.TypeOfCompanyPerAccOptions = data.values.map(plValue => {
                 return {
                     label: plValue.label,
                     value: plValue.value
                 };               
             });
             console.log('==============TypeOfCompanyPerAccOptions  ' + data);
 
         } else if (error) {
       
             console.log(error);
         }
     }
     //Role in organisation - Account
     @wire(getPicklistValues, { recordTypeId: '$recordTypeId1', fieldApiName: '$apiRoleInOrgPerAcc' })
     getPicklistValues020({ error, data }) {
         if (data) {
       
             this.RoleInOrgPerAccOptions = data.values.map(plValue => {
                 return {
                     label: plValue.label,
                     value: plValue.value
                 };               
             });
             console.log('==============RoleInOrgPerAccOptions  ' + data);
 
         } else if (error) {
      
             console.log(error);
         }
     }
     //Co-Applicant or Guarator Category - Account
     @wire(getPicklistValues, { recordTypeId: '$recordTypeId1', fieldApiName: '$apiAppliCategoryPerAcc' })
     getPicklistValues021({ error, data }) {
         if (data) {
      
             this.AppliCategoryPerAccOptions = data.values.map(plValue => {
                 return {
                     label: plValue.label,
                     value: plValue.value
                 };               
             });
             console.log('==============AppliCategoryPerAccOptions  ' + data);
 
         } else if (error) {
          
             console.log(error);
         }
     }    
    //Is Income Considered / Is Financial - Account 
     @wire(getPicklistValues, { recordTypeId: '$recordTypeId1', fieldApiName: '$apiisIncomeConsiderIsFinPerAcc' })
     getPicklistValues022({ error, data }) {
         if (data) {
           
             this.isIncomeConsiderIsFinPerAccOptions = data.values.map(plValue => {
                 return {
                     label: plValue.label,
                     value: plValue.value
                 };               
             });
             console.log('==============isIncomeConsiderIsFinPerAccOptions  ' + data);
 
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
       
             this.EducationDetailsOptions = data.values.map(plValue => {
                 return {
                       label: plValue.label,
                       value: plValue.value
                 };               
             });
             console.log('==============EducationDetailsOptions' + data);
   
         } else if (error) {
          
             console.log(error);
         }
     }
      // Co-applicant Picklist field from SFDC
    @wire(getObjectInfo, { objectApiName: '$objectNameCoAppli' })
    getObjectData4({ error, data }) {
        debugger;
        console.log('Inside objectApiName: Co-applicant');
        console.log('objectApiName' + this.objectApiName);
        if (data) {
            console.log('Inside if');
            if (this.recordTypeId3 == null)
            console.log('Inside recordTypeId3');
                this.recordTypeId3 = data.defaultRecordTypeId;
                console.log('Inside this.recordTypeId3' + this.recordTypeId3); //its Non indivial acc recordtpye           
                this.apiRelshipWithAppliPerAcc = this.objectNameCoAppli + '.' + this.RelshipWithAppliPerAccField;
                this.RelshipWithAppliPerAccLabel = data.fields[this.RelshipWithAppliPerAccField].label;  
               
                this.apiRelshipProofPerAcc = this.objectNameCoAppli + '.' + this.RelshipProofPerAccField;
                this.RelshipProofPerAccLabel = data.fields[this.RelshipProofPerAccField].label;  
               
                this.apiTypeOfAppliFromCoAppli = this.objectNameCoAppli + '.' + this.TypeOfAppliFromCoAppliField;
                this.TypeOfAppliFromCoAppliLabel = data.fields[this.TypeOfAppliFromCoAppliField].label;   
                
        } else if (error) {         
            console.log('==============Error ');
            console.log(error);
        }     
    }
    //Relationship with Student-  Co-applicant
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId3', fieldApiName: '$apiRelshipWithAppliPerAcc' })
    getPicklistValues0002({ error, data }) {
        if (data) {
            // Map picklist values
            this.RelshipWithAppliPerAccOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };               
            });
            console.log('==============RelshipWithAppliOptions  ' + data);

        } else if (error) {
          
            console.log(error);
        }
    }
     //Relationship Proof - Co-applicant
     @wire(getPicklistValues, { recordTypeId: '$recordTypeId3', fieldApiName: '$apiRelshipProofPerAcc' })
     getPicklistValues0003({ error, data }) {
         if (data) {
           
             this.RelshipProofPerAccOptions = data.values.map(plValue => {
                 return {
                     label: plValue.label,
                     value: plValue.value
                 };               
             });
             console.log('==============RelshipProofOptions  ' + data);
 
         } else if (error) {
           
             console.log(error);
         }
     }
     //Type of Applicant - Co-applicant
     @wire(getPicklistValues, { recordTypeId: '$recordTypeId3', fieldApiName: '$apiTypeOfAppliFromCoAppli' })
     getPicklistValues0004({ error, data }) {
         if (data) {
        
             this.TypeOfAppliFromCoAppliOptions = data.values.map(plValue => {
                 return {
                     label: plValue.label,
                     value: plValue.value
                 };               
             });
             console.log('==============TypeOfAppliFromCoAppliOptions  ' + data);
 
         } else if (error) {
         
             console.log(error);
         }
     }
    //TABLE FORMAT CODE 22-Jan    
    handleOtpValueChange(event) {
        this.otpValue = event.target.value;
    }
    handleOtpforMob(event){
        this.otpValueMob = event.target.value
    }
    handleAadharOtp(event){
        this.otpValueAadhar = event.target.value
    }
    handleGetOTP(){
        console.log('Lemail',this.LEmail);
        this.verified=true;
        setTimeout(() => {
            this.verified = false;
        }, 5000)
        if(this.LEmail!=undefined&&this.LEmail!=""){
            this.showModal = true;
            OtpRequest({ email: this.LEmail})
            .then((result) => {
              console.log("suc",result);
                let responseObj = JSON.parse(result);
                this.requestIdTemp = responseObj.requestId;
                console.log(this.requestIdTemp);
                if (responseObj.statusCode==101) {
                    const event = new ShowToastEvent({
                        title: 'Success',
                        message: 'OTP sent successfully!',
                        variant: 'success',
                    });
                    this.dispatchEvent(event);
                }else{
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: 'Failed to send OTP. Please try again!',
                        variant: 'error',
                        });
                        this.dispatchEvent(event);
                }
            })
            .catch((error) => {
              console.error("er",error);
            });
    }
    }
    handleVerify(){
  
        OtpVerify({ 'otp':this.otpValue, 'requestId':this.requestIdTemp})
        .then((result) => {
            let responseObj = JSON.parse(result);
            if (responseObj.statusCode==101) {
                this.showModal=false;
                this.verified=true;
                this.buttonStyle='display:none'
                this.displayText='display:block;  color:green; font-weight:bold;'
                const event = new ShowToastEvent({
                    title: 'Success',
                    message: 'Email Verified successfully!',
                    variant: 'success',
                });
                this.dispatchEvent(event);
                this.buttonLabel = 'Verified';
            }else{
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: 'Please Enter Correct OTP',
                    variant: 'error',
                    });
                    this.dispatchEvent(event);
            }
        console.log("result log",result);
        })
        .catch((error) => {
            console.error("error",error);
        });
    console.log("Email Verification Done");
}
 handleVerifyAadhar(){
    this.verifiedbuttonAadhar=true;
    setTimeout(() => {
        this.verifiedbuttonAadhar = false;
    }, 5000)
       
        downloadAadhar({ 'otp': this.otpValueAadhar,'aadhaarNo':this.LAadharNumber, 'requestId':this.requestIdAadhar,'consent':'y'})
            .then((result) => {
                let responseObj = JSON.parse(result);
                console.log("result log",responseObj);
                if (responseObj.statusCode==101) {
                    this.showModalAadhar=false;
                    
                    this.buttonLabelAadhar = 'Verified';
                    this.buttonStyleAadhar = 'display:none';
                    this.displayTextAadhar='display:block;  color:green; font-weight:bold;'
                    const event = new ShowToastEvent({
                        title: 'Success',
                        message: 'Aadhar Verified successfully!',
                        variant: 'success',
                    });
                    this.verifiedAadhar=true;
                    this.dispatchEvent(event);
                }else{
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: 'Please Enter Correct OTP',
                        variant: 'error',
                        });
                        this.dispatchEvent(event);
                }
            })
            .catch((error) => {
                console.error("error",error);
            });
        console.log("aadhar Verification");
    }
 GetOtpAadhar(){
    this.verifiedAadhar=true;
    setTimeout(() => {
        this.verifiedAadhar = false;
    }, 5000)
    console.log(this.LAadharNumber);
    if(this.LAadharNumber!=""&&this.LAadharNumber!=undefined){
        AadharVerification({aadhaarNo:this.LAadharNumber,consent:'y'})
        .then((result) => {
            
            let responseObj = JSON.parse(result);
            console.log(responseObj);
            this.requestIdAadhar = responseObj.requestId;
            if (responseObj.statusCode==101) {
                this.showModalAadhar = true;
                const event = new ShowToastEvent({
                    title: 'Success',
                    message: 'OTP sent successfully!',
                    variant: 'success',
                });
                this.dispatchEvent(event);
                
            }else{
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: 'Failed to send OTP. Please try again!',
                    variant: 'error',
                    });
                    this.dispatchEvent(event);
            }
        })
        .catch((error)=>{
            console.log(error);
        })
    }
 }
 @track duplicateAccountResult;
 @track makeadhardisable = false;
 @track makepandisable = false;
 @track makepassportdisable = false;
 @track makevoteriddisable = false;
 @track makedrivingdisable = false;

 panVerification(event){
    if(this.LAadharNumber==undefined||this.LAadharNumber==undefined){
        const event = new ShowToastEvent({
            title: 'Error',
            message: 'Please Fill Aadhar Number!!',
            variant: 'error',
            });
            this.dispatchEvent(event);
    }
    console.log("Pan Verification Started");
    if(this.PANNumber!=""&&this.PANNumber!=undefined){
        this.aadharLastFour = this.LAadharNumber.slice(-4)
      
        panVerification({'pan':this.PANNumber,'aadhaarLastFour':this.aadharLastFour , 'dob':this.LDateOfBirth,'name':this.LfNName+' '+this.LLastName,'address':this.ApplicurrentAddress+" "+this.appliCurrentCity,'getContactDetails':'y','PANStatus':'y','consent':'y'})
        .then((result) => {
            let responseObj = JSON.parse(result);
            console.log(responseObj);
            if (responseObj.statusCode==101) {
                let profileMatch = responseObj.result.profileMatch;
                for (let i = 0; i < profileMatch.length; i++) {
                  this.sumScore += profileMatch[i].matchScore;
                }
                this.sumScorePercent=(this.sumScore/3)*100;
                this.sumScorePercent= Math.floor(this.sumScorePercent * 100) / 100;              
                const event = new ShowToastEvent({
                    title: 'Success',
                    message: 'PAN verified!!',
                    variant: 'success',
                });
                this.dispatchEvent(event);
                this.buttonLabelPan = 'Verified';
                this.verifiedPan=true;
                this.makepandisable = true;
                this.makeadhardisable = true;
                this.buttonStylePan='display:none; font-weight:bold;'
                this.matchText=this.sumScorePercent+'% PROFILE MATCHED';
            }else{
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: 'PAN not Verified Please Try Again with Correct Details!!',
                    variant: 'error',
                    });
                    this.dispatchEvent(event);
            }
        })
        .catch((error)=>{
            console.log(error);
        })    
    if (event.target.name == "passportNumber" && event.target.value != "") {
        this.passportNumber = event.target.value;   
    }
    if (event.target.name == "Driving_License_Number__c" && event.target.value !="") {
        this.Driving_License_Number__c = event.target.value;    
    }
    if (event.target.name == "voterId" && event.target.value != "") {
            this.voterId = event.target.value;          
    }


      /*********Get DuplicateAccount ******************/
      getDeplicateAccout({'adharNumber':this.LAadharNumber , 'panNumber':this.PANNumber,'dateOfBirth':this.LDateOfBirth})
    .then((result) => {
        this.duplicateAccountResult = result;
        console.log(this.duplicateAccountResult);

            if (this.duplicateAccountResult.Passport_Number__c != null) {
                this.passportNumber =  this.duplicateAccountResult.Passport_Number__c;
                this.makepassportdisable =true;
            }
            if (this.duplicateAccountResult.Driving_License_Number__c != null) {
                this.Driving_License_Number__c =  this.duplicateAccountResult.Driving_License_Number__c;
                this.makedrivingdisable = true;
            }
            if (this.duplicateAccountResult.Voter_ID__c != null) {
                this.voterId =  this.duplicateAccountResult.Voter_ID__c;
                this.makevoteriddisable = true;
            }          
    })
    .catch((error)=>{
        console.log(error);
    })
}
 }
 
 handleGetOTPMobile(){
    this.verifiedMob=true;
    setTimeout(() => {
        this.verifiedMob = false;
    }, 5000)
    if(this.LMobile!=""&&this.LMobile!=undefined){
        OtpRequestMob({ mobile: this.LMobile, consent:'y'})
        .then((result) => {
            console.log("full",result);
            let responseObj = JSON.parse(result);
            console.log(responseObj);
            this.requestIdMob = responseObj['request_id'];
            console.log("reqid",this.requestIdMob);
            if (responseObj['status-code']==101) {
             this.showModalMobile = true;
             const event = new ShowToastEvent({
              title: 'Success',
              message: 'OTP sent successfully!',
              variant: 'success',
          });
          this.dispatchEvent(event);
         }else{
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Failed to send OTP. Please try again!',
                variant: 'error',
                });
                this.dispatchEvent(event);         }
        })
        .catch((error) => {
            console.error("error",error);
        });
    }
 }
 
 
 handleVerifyMob(){  
        OtpVerifyMob({ otp: this.otpValueMob, request_id:this.requestIdMob})
        .then((result) => {
            console.log("full",result);
            let responseObj = JSON.parse(result);
            console.log(responseObj);
            if (responseObj['status-code']==101) {
             this.showModalMobile = false;
             this.displayTextMob='display:block;  color:green; font-weight:bold;'
             this.buttonStyleMob = 'display:none';
             const event = new ShowToastEvent({
              title: 'Success',
              message: 'Mobile Number Verified!',
              variant: 'success',
          });
          this.dispatchEvent(event);
         }else{
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Failed to Verify! Please try again!',
                variant: 'error',
                });
                this.dispatchEvent(event);
         }
        })
        .catch((error) => {
            console.error("error",error);
        });
    console.log("mobile Verification Done");
 }

    connectedCallback() {        
        this.triggerEventOnce();         
        this.todaysDate = new Date().toISOString().split('T')[0];        
    }

    triggerEventOnce() {        
          this.event1 = setInterval(() => {
            if(this.LLastName !=null && (this.LEmail !=null || this.LMobile !=null)){
          this.handleSaveTwo(creatLeadRecord);
          //this.isLoading = false;
        }}, this.timeSpan);
        
    }
    customMessage(customMessage) {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Notification",
            message: customMessage,
            variant: "success"
          })
        );
      }   

    //Co-applicant Section
   addRowlistOfApplicants() {
    let randomId = Math.random() * 16;
    console.log("randomId===>" + randomId);
    let myNewElement = { Id: randomId,Type__c: "", Relation_with_applicant__c: "", Relation_others__c: "",Relationship_Proof__c: "",FirstName: "",MiddleName: "",LastName: "",PersonBirthdate: "",PersonMobilePhone: "",PersonEmail: "",Father_Name__c: "",Mother_Name__c: "",Gender__c: "",Marital_Status__c: "",Is_Income_Considered_Is_Financial__c: "",Address_Proof__c: "",Marital_Status__c: "",Address_1__c: "",Pin_Code__c: "",City__c: "",Taluka__c: "",District__c: "",Landmark__c: "",State__c: "",Country__c: "",Years_In_The_Address__c: "",Same_as_Current_Address__c: "",Aadhar_Number__c: "",PAN_Number__c: "",Passport_Number__c: "",Driving_License_Number__c: "",Dirving_License_Expiry_Date__c: "",Voter_ID__c: ""};
    console.log("myNewElement===>" + myNewElement);        
    this.listOfApplicants = [...this.listOfApplicants, myNewElement];
    console.log("this.listOfApplicantsaddRow===>" + this.listOfApplicants);    
}
@track deleteCoAppliIds = '';
removelistOfApplicants(event) {
    console.log("Remove clicked ");
    if(isNaN(event.target.dataset.id)){
        this.deleteCoAppliIds = this.deleteCoAppliIds + ',' + event.target.dataset.id;
    }
    console.log("this.deleteCoAppliIds== " + this.deleteCoAppliIds);
    console.log("this.deleteCoAppliIds.length== " + this.deleteCoAppliIds.length);
    console.log("this.listOfApplicants.length== " + this.listOfApplicants.length);
    if(this.listOfApplicants.length > 1){
    this.listOfApplicants.splice(this.listOfApplicants.findIndex(row => row.Id === event.target.dataset.id), 1);
    }       
}
    //Education Section
    addRow() {
        let randomId = Math.random() * 16;
        console.log("randomId===>" + randomId);
        let myNewElement = { Id: randomId,Education_Qualification__c: "", Year_Completed__c: "", Percentage_Marks_CGPA__c: "",School_College_University__c: ""};
        console.log("myNewElement===>" + myNewElement);        
        this.listOfEducationalTable = [...this.listOfEducationalTable, myNewElement];
        console.log("this.listOfEducationalTableaddRow===>" + this.listOfEducationalTable);
        
    }
   
    @track deleteEmpIds = '';
    removeTheRowEducational(event) {
        console.log("Remove clicked ");
         if(isNaN(event.target.dataset.id)){
             this.deleteEmpIds = this.deleteEmpIds + ',' + event.target.dataset.id;
         }
         console.log("this.deleteEmpIds== " + this.deleteEmpIds);
         console.log("this.deleteEmpIds.length== " + this.deleteEmpIds.length);
        console.log("this.listOfEducationalTable.length== " + this.listOfEducationalTable.length);
        if(this.listOfEducationalTable.length > 1){
        this.listOfEducationalTable.splice(this.listOfEducationalTable.findIndex(row => row.Id === event.target.dataset.id), 1);
        }       
    }
    
    newChange(event){
        this.LEmail = event.target.value; 
        if (this.LEmail.match(/[A-Za-z0-9._-]+@[a-z0-9]+\.[a-z]{2,}$/)) {
            this.buttonStyle = 'display:block';
        }else{
            this.buttonStyle = 'display:none';
        }
    }
    newChangeMob(event){
        this.LMobile = event.target.value; 
        if (this.LMobile.match(/[0-9]{10}$/)) {
            this.buttonStyleMob = 'display:block';
        }else{
            this.buttonStyleMob = 'display:none';
        }
    }
    newChangeAadhar(event){
        this.LAadharNumber = event.target.value; 
        if (this.LAadharNumber.match(/[0-9]{12}/)) {
            this.buttonStyleAadhar = 'display:block';
        }else{
            this.buttonStyleAadhar = 'display:none';
        }
       
    }
    newChangePan(event){
        this.PANNumber = event.target.value.toUpperCase(); 
        if (this.PANNumber.match(/[A-Z]{5}[0-9]{4}[A-Z]{1}$/)) {
            this.buttonStylePan = 'display:block';
        }else{
            this.buttonStylePan = 'display:none';
        }
    }

    handlechange(event) {

        if (event.target.name == "salutation" ) {         
            this.leadSalutation = event.target.value;          
        }   
        if (event.target.name == "firstName") {         
            this.leadFirstName = event.target.value;          
        }
        if (event.target.name == "LastName1" ) {
            this.leadLastName = event.target.value;         
        }
        if (event.target.name == "middleName" && event.target.value != "") {
            this.leadMiddleName = event.target.value;        
        }
        if (event.target.name == "Email") {
            this.leadEmail = event.target.value;      
        }
        if (event.target.name == "MotherFirstName") {
            this.AppliMotherFirstName = event.target.value;           
        }   
        if (event.target.name == "MotherMiddleName" && event.target.value != "") {
            this.AppliMotherMiddleName = event.target.value;           
        }                 
        if (event.target.name == "MotherLastName" && event.target.value != "") {
            this.AppliMotherLastName = event.target.value;        
        }
        if (event.target.name == "Date of Birth" && event.target.value != "") {
            this.AppliDOB = event.target.value;         
        }
        if (event.target.name == "AadharNumber" && event.target.value != "") {
            this.LAadharNumber = event.target.value;           
        }    
        if (event.target.name == "Gender" && event.target.value != "") {
            this.AppliGender = event.target.value;          
        }
        if (event.target.name == "Mobile" ) {
            this.leadMobile = event.target.value;            
        }
        if (event.target.name == "FatherFirstName" ) {
            this.AppliFatherFirstName = event.target.value;        
        } 
        if (event.target.name == "FatherMiddleName" && event.target.value != "") {
            this.AppliFatherMiddleName = event.target.value;         
        } 
        if (event.target.name == "FatherLastName" && event.target.value != "") {
            this.AppliFatherLastName = event.target.value;        
        }
        if (event.target.name == "SpouseFirstName") {
            this.AppliSpouseFirstName = event.target.value;       
        }
        if (event.target.name == "SpouseMiddleName" && event.target.value != "") {
            this.AppliSpouseMiddleName = event.target.value;       
        }
        if (event.target.name == "SpouseLastName" && event.target.value != "") {
            this.AppliSpouseLastName = event.target.value;     
        }  
        if (event.target.name == "PANNumber" && event.target.value != "") {
            this.PANNumber = event.target.value;       
        }  
        if (event.target.name == "ckycNumber" && event.target.value != "") {
            this.ckycNumber = event.target.value;        
        }   
        if (event.target.name == "voterId" && event.target.value != "") {
            this.voterId = event.target.value;       
        }   
        if (event.target.name == "passportNumber" && event.target.value != "") {
            this.passportNumber = event.target.value;      
        }   
        if (event.target.name == "Is Income Considered/Is Financial" && event.target.value != "") {
            this.AppliIsIncomeConsiderIsFin = event.target.value;       
        }
        if (event.target.name == "appliCurrentAddProof") {
            this.AppliCurrentAddProof = event.target.value;       
        }   
        if (event.target.name == "ApplicurrentAddress") {
            this.AppliCurrentAddress = event.target.value;      
        }   
        if (event.target.name == "appliCurrentCity") {
            this.AppliCurrentCity = event.target.value;       
        }  
        if (event.target.name == "appliCurrentTaluka") {
            this.AppliCurrentTaluka = event.target.value;       
        }   
         if (event.target.name == "appliCurrentDistrict" && event.target.value != "") {
             this.AppliCurrentDistrict = event.target.value;   
         }   
        if (event.target.name == "appliCurrentPincode") {
            this.AppliCurrentPincode = event.target.value;     
        }   
        if (event.target.name == "appliCurrentLandmark") {
            this.AppliCurrentLandmark = event.target.value;      
        }   
        if (event.target.name == "appliCurrentState" ) {
            this.AppliCurrentState = event.target.value;          
        }   
        if (event.target.name == "appliCurrentCountry" ) {
            this.AppliCurrentCountry = event.target.value.toUpperCase();        
        }   
        if (event.target.name == "appliPermanentAddressProof") {
            this.AppliPermanentAddProof = event.target.value;          
        }  
        if (event.target.name == "permanentAddress") {
            this.AppliPermanentAddress = event.target.value;           
        }   
        if (event.target.name == "appliPermanentCity" ) {
            this.AppliPermanentCity = event.target.value;        
        }   
        if (event.target.name == "appliPermanentTaluka" ) {
            this.AppliPermanentTaluka = event.target.value;       
        }   
        if (event.target.name == "appliPermanentDistrict" ) {
            this.AppliPermanentDistrict = event.target.value;      
        }   
        if (event.target.name == "appliPermanentPincode" ) {
            this.AppliPermanentPincode = event.target.value;      
        }   
        if (event.target.name == "appliPermanentLandmark" ) {
            this.AppliPermanentLandmark = event.target.value;     
        }   
        if (event.target.name == "appliPermanentState" ) {
            this.AppliPermanentState = event.target.value;       
        }   
        if (event.target.name == "appliPermanentCountry" ) {
            this.AppliPermanentCountry = event.target.value.toUpperCase();         
        }   
        if (event.target.name == "Country of Study" && event.target.value != "") {
            this.CountryOfStudyValue = event.target.value;        
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
        if (event.target.name == "courseName" && event.target.value != "") {
            this.courseName = event.target.value;       
        }
        if (event.target.name == "Campus" && event.target.value != "") {
            this.courseCampus = event.target.value;        
        }
        if (event.target.name == "Course Category" && event.target.value != "") {
            this.CourseCategoryValue = event.target.value;         
        }
        if (event.target.name == "Course Type" && event.target.value != "") {
            this.CourseTypeValue = event.target.value;           
        }
        if (event.target.name == "Course Level" && event.target.value != "") {
            this.CourseLevelValue = event.target.value;           
        }
        if (event.target.name == "Course Stream" && event.target.value != "") {
            this.CourseStreamValue = event.target.value;          
        }
        if (event.target.name == "courseStartDate" && event.target.value != "") {
            this.courseStartDate = event.target.value;        
        }
        if (event.target.name == "courseEndDate" && event.target.value != "") {
            this.courseEndDate = event.target.value;           
        }
        if (event.target.name == "Language Score Category" && event.target.value != "") {
            this.LangScoreCategoryValue = event.target.value;      
        }
        if (event.target.name == "langTestScore" && event.target.value != "") {
            this.langTestScore = event.target.value;        
        }
        if (event.target.name == "Analytics Score Category" && event.target.value != "") {
            this.AnalytScoreCategoryValue = event.target.value;         
        }
        if (event.target.name == "analyticalTestScore" && event.target.value != "") {
            this.analyticalTestScore = event.target.value;           
        }
    }
    handleAppliSpouseShowHide(event){
        if (event.target.name == "Marital Status" && event.target.value != "") {
            this.AppliMaritlStatus = event.target.value;
            console.log("this.AppliMaritlStatus333333====  " + this.AppliMaritlStatus);
        }
         if (event.target.value === "Married") {
            this.ShowFieldsAppliSpouse = true;
            console.log("this.ShowFieldsAppliSpouse====  " + this.ShowFieldsAppliSpouse);
        } 
        else{
            this.ShowFieldsAppliSpouse = false;
            console.log("this.ShowFieldsAppliSpouse====  " + this.ShowFieldsAppliSpouse);
        }  
    }
    handleCourseUniversityShowHide(event){
        if (event.target.name == "Admission Status" && event.target.value != "") {
            this.AdmissionStatus = event.target.value;
            console.log("this.AdmissionStatus====  " + this.AdmissionStatus);
        }
         if (event.target.name == "Admission Status" && event.target.value !== "Not Applied") {
            this.ShowFieldsCourseUniversity = true;
            console.log("this.ShowFieldsCourseUniversity====  " + this.ShowFieldsCourseUniversity);
        } 
        else{
            this.ShowFieldsCourseUniversity = false;
            console.log("this.ShowFieldsCourseUniversity====  " + this.ShowFieldsCourseUniversity);
        }  
    }
    //Avadhut Code
    @track universityNameIdResult;
    @track errorsUniversityId;
    handleCourseInstAndCampusShowHide(event){
        if (event.target.name == "universityName" && event.target.value != "") {
            this.universityName = event.target.value;
            console.log("this.universityName====  " + this.universityName);
        }            
        getUniversityNameCourse({ universityId: this.universityName }) //this parameter is passed to Class-CommunityLeadFormController.getInstituteRecord
        .then(result => {
            this.universityNameIdResult = result;
            console.log('universityNameIdResult=======> ' + JSON.stringify(this.universityNameIdResult));
        })
        .catch(error => {
            this.errorsUniversityId = error;
            console.log('errorsUniversityId=======> ' + this.errorsUniversityId);
        });

    }
    handleApplicantCategory(event){
        if (event.target.name == "ApplicantCategory" && event.target.value != "") {
            this.AppliCategoryvalue = event.target.value;
            console.log("this.AppliCategoryvalue====  " + this.AppliCategoryvalue);
        }    
        if (event.target.name == "ApplicantCategory" && event.target.value !=="Guarantor") {
            this.ShowFieldsApplicantCategory = true;
            console.log("this.ShowFieldsApplicantCategory====  " + this.ShowFieldsApplicantCategory);
        } 
        else{
            this.ShowFieldsApplicantCategory = false;
            console.log("this.ShowFieldsApplicantCategory====  " + this.ShowFieldsApplicantCategory);
        }  
    }
    handleRelationWithApplicant(event){
        if (event.target.name == "Relationship with Applicant" && event.target.value != "") {
            this.RelshipWithAppliPerAcc = event.target.value;
            console.log("this.RelshipWithAppliPerAcc====  " + this.RelshipWithAppliPerAcc);
        }    
        if (event.target.name == "Relationship with Applicant" && event.target.value ==="OTHER") {
            this.ShowFieldsRelationWithAppliIfOther = true;
            console.log("this.ShowFieldsRelationWithAppliIfOther====  " + this.ShowFieldsRelationWithAppliIfOther);
        } 
        else{
            this.ShowFieldsRelationWithAppliIfOther = false;
            console.log("this.ShowFieldsRelationWithAppliIfOther====  " + this.ShowFieldsRelationWithAppliIfOther);
        }  
    }  
    handleAppliDriveLicDateOfExpiry(event){
        if (event.target.name == "driveLicenseNumber" && event.target.value != "") {
            this.driveLicenseNumber = event.target.value;
            console.log("this.driveLicenseNumber====  " + this.driveLicenseNumber);
        }   
        if (event.target.name == "driveLicenseNumber" && event.target.value !="") {
            this.ShowFieldsAppliDriveLicDateofExpiry = true;
            console.log("this.ShowFieldsAppliDriveLicDateofExpiry====  " + this.ShowFieldsAppliDriveLicDateofExpiry);
        } 
        else{
            this.ShowFieldsAppliDriveLicDateofExpiry = false;
            console.log("this.ShowFieldsAppliDriveLicDateofExpiry====  " + this.ShowFieldsAppliDriveLicDateofExpiry);
        }  
    }        
    handleCoAppliDriveLicDateOfExpiry(event){
        if (event.target.name == "Driving_License_Number__c" && event.target.value !="") {
            this.Driving_License_Number__c = event.target.value;
            console.log("this.Driving_License_Number__c====  " + this.Driving_License_Number__c);
        }
         if (event.target.name === "Driving_License_Number__c" && event.target.value !="") {
            this.ShowFieldsCoAppliDriveLicDateofExpiry = true;
            console.log("this.ShowFieldsCoAppliDriveLicDateofExpiry====  " + this.ShowFieldsCoAppliDriveLicDateofExpiry);
        } 
        else{
            this.ShowFieldsCoAppliDriveLicDateofExpiry = false;
            console.log("this.ShowFieldsCoAppliDriveLicDateofExpiry====  " + this.ShowFieldsCoAppliDriveLicDateofExpiry);
        }  
    }    

@track makePermanentAddProofdisabled = false;

    handleAppliPermanentAddBox(event){
         //Same as Current address checkbox   
       this.AppliPermanentSameAsCurrent = event.target.checked; 
       console.log("Chhecked: " + event.target.checked);
        if(this.AppliPermanentSameAsCurrent == true){
            this.AppliPermanentAddProof = this.AppliCurrentAddProof;
            this.AppliPermanentAddress = this.AppliCurrentAddress;
            this.AppliPermanentCity = this.AppliCurrentCity;
            this.AppliPermanentTaluka = this.AppliCurrentTaluka;
            this.AppliPermanentDistrict = this.AppliCurrentDistrict;
            this.AppliPermanentPincode = this.AppliCurrentPincode;
            this.AppliPermanentLandmark = this.AppliCurrentLandmark;
            this.AppliPermanentState = this.AppliCurrentState;
            this.AppliPermanentCountry = this.AppliCurrentCountry;

            if(this.AppliCurrentCountry == 'INDIA'){
            this.AppliPermIsCommAddressvalue = 'Current Address';
            this.makePermanentAddProofdisabled = true;
            }
        }
        if(this.AppliPermanentSameAsCurrent == false){
            this.makePermanentAddProofdisabled = false;
        }
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
    @track YearCompleted;
    @track PercentageMarks;
    @track SchoolCollegeUniversity;
     //update table row values in list
     updateValues(event){
        console.log('this.listOfEducationalTable valuessss===>' + JSON.stringify(this.listOfEducationalTable));
        var foundelement = this.listOfEducationalTable.find(ele => ele.Id == event.target.dataset.id);
        console.log('foundelement' + JSON.stringify(foundelement));
        if(event.target.name === 'EducationDetails'){   
            foundelement.Education_Qualification__c = event.target.value;
            this.EducationDetails = foundelement.Education_Qualification__c;
           console.log('this.EducationDetails update values handle' , this.EducationDetails);
        } else if(event.target.name === 'YearCompleted'){
            foundelement.Year_Completed__c = event.target.value;
            this.YearCompleted = foundelement.Year_Completed__c;
           console.log('this.YearCompleted update values handle', this.YearCompleted);
        } else if(event.target.name === 'PercentageMarks'){
            foundelement.Percentage_Marks_CGPA__c = event.target.value;
            this.PercentageMarks = foundelement.Percentage_Marks_CGPA__c;
            console.log('this.PercentageMarks update values handle', this.PercentageMarks);
        } else if(event.target.name === 'SchoolCollegeUniversity'){
            foundelement.School_College_University__c = event.target.value;
            this.SchoolCollegeUniversity = foundelement.School_College_University__c;
            console.log('this.SchoolCollegeUniversity update values handle', this.SchoolCollegeUniversity);
        }
    }  

    @track coAppliRelationOthersAppli;
    @track coAppliRelationProof;
     //Co-appli Address Current
   @track coApplicurrentAddress;
   @track coAppliCurrentCity;
   @track coAppliCurrentTaluka;
   @track coAppliCurrentDistrict;
   @track coAppliCurrentPincode;
   @track coAppliCurrentLandmark;
   @track coAppliCurrentState;
   @track coAppliCurrentCountry;
   @track coAppliYearInAddress;
   //Co-appli Address Permanent
   @track coAppliSameasCurrentAddr;
   @track coApplipermanentAddress;
   @track coAppliPermanentCity;
   @track coAppliPermanentTaluka;
   @track coAppliPermanentDistrict;
   @track coAppliPermanentPincode;
   @track coAppliPermanentLandmark;
   @track coAppliPermanentState;
   @track coAppliPermanentCountry;

   @track CoAppliFirstName; 
   @track CoAppliMiddleName;
   @track CoAppliLastName;
   @track CoAppliDOB;
   @track CoAppliMobile;
   @track CoAppliEmail;
   @track CoAppliFatherName;
   @track CoAppliMothersName;
   @track CoAppliGender;
   @track coAppliMaritalStatus;
   @track coAppliIsIncomeConFin;
   @track coAppliCurrentAddressProof;
   @track coAppliPermanentAddProof;

   handleCoappliAcc(event) {          
    debugger;
    console.log('this.listOfApplicants valuessss===>' + JSON.stringify(this.listOfApplicants));
    var foundelementCoAppli = this.listOfApplicants.find(ele => ele.objeAcc.Id == event.target.dataset.id);
    console.log('foundelementCoAppli' + JSON.stringify(foundelementCoAppli));
    if(event.target.name === 'RelationOthersAppliCo'){   
        foundelementCoAppli.Relation_others__c = event.target.value;
        this.coAppliRelationOthersAppli = foundelementCoAppli.Relation_others__c;
        console.log('this.coAppliRelationOthersAppli' + this.coAppliRelationOthersAppli); 
    }else if(event.target.name === 'coAppliRelationProof'){   
        foundelementCoAppli.Relationship_Proof__c = event.target.value;
        this.coAppliRelationProof = foundelementCoAppli.Relationship_Proof__c;
        console.log('this.coAppliRelationProof' + this.coAppliRelationProof);              
    }else if(event.target.name === 'FirstNameCoAppli'){   
        foundelementCoAppli.FirstName = event.target.value;
        this.CoAppliFirstName = foundelementCoAppli.FirstName;
        console.log('this.CoAppliFirstName' + event.target.value);
    }else if(event.target.name === 'MiddleNameCoAppli'){   
        foundelementCoAppli.MiddleName = event.target.value;
        this.CoAppliMiddleName = foundelementCoAppli.MiddleName;
        console.log('this.CoAppliMiddleName' + this.CoAppliMiddleName);
    }else if(event.target.name === 'LastNameCoAppli'){   
        foundelementCoAppli.LastName = event.target.value;
        this.CoAppliLastName = foundelementCoAppli.LastName;
        console.log('this.CoAppliLastName' + this.CoAppliLastName);
    }else if(event.target.name === 'PersonBirthdateCoAppli'){   
        foundelementCoAppli.PersonBirthdate = event.target.value;
        this.CoAppliDOB = foundelementCoAppli.PersonBirthdate;
        console.log('this.CoAppliDOB' + this.CoAppliDOB);
    }else if(event.target.name === 'PersonMobilePhoneCoAppli'){   
        foundelementCoAppli.PersonMobilePhone = event.target.value;
        this.CoAppliMobile = foundelementCoAppli.PersonMobilePhone;
        console.log('this.CoAppliMobile' + this.CoAppliMobile);
    }else if(event.target.name === 'PersonEmailCoAppli'){   
        foundelementCoAppli.PersonEmail = event.target.value;
        this.CoAppliEmail = foundelementCoAppli.PersonEmail;
        console.log('this.CoAppliEmail' + this.CoAppliEmail);
    }else if(event.target.name === 'FatherNameCoAppli'){   
        foundelementCoAppli.Father_Name__c = event.target.value;
        this.CoAppliFatherName = foundelementCoAppli.Father_Name__c;
        console.log('this.CoAppliFatherName' + this.CoAppliFatherName);
    }else if(event.target.name === 'MothersNameCoAppli'){   
        foundelementCoAppli.Mother_Name__c = event.target.value;
        this.CoAppliMothersName = foundelementCoAppli.Mother_Name__c;
        console.log('this.CoAppliMothersName' + this.CoAppliMothersName);
    }else if(event.target.name === 'MothersNameCoAppli'){   
        foundelementCoAppli.Mother_Name__c = event.target.value;
        this.CoAppliMothersName = foundelementCoAppli.Mother_Name__c;
        console.log('this.CoAppliMothersName' + this.CoAppliMothersName);
    }else if(event.target.name === 'GenderCoAppli'){   
        foundelementCoAppli.Gender__c = event.target.value;
        this.CoAppliGender = foundelementCoAppli.Gender__c;
        console.log('this.CoAppliGender' + this.CoAppliGender);
    }else if(event.target.name === 'coAppliMaritalStatus'){   
        foundelementCoAppli.Marital_Status__c = event.target.value;
        this.coAppliMaritalStatus = foundelementCoAppli.Marital_Status__c;
        console.log('this.coAppliMaritalStatus' + this.coAppliMaritalStatus);
    }else if(event.target.name === 'coAppliIsIncomeConFin'){   
        foundelementCoAppli.Is_Income_Considered_Is_Financial__c = event.target.value;
        this.coAppliIsIncomeConFin = foundelementCoAppli.Is_Income_Considered_Is_Financial__c;
        console.log('this.coAppliIsIncomeConFin' + this.coAppliIsIncomeConFin);
    }else if(event.target.name === 'coAppliCurrentAddressProof'){   
        foundelementCoAppli.Address_Proof__c = event.target.value;
        this.coAppliCurrentAddressProof = foundelementCoAppli.Address_Proof__c;
        console.log('this.coAppliCurrentAddressProof' + this.coAppliCurrentAddressProof);
    }else if(event.target.name === 'coApplicurrentAddress'){   
        foundelementCoAppli.Address_1__c = event.target.value;
        this.coApplicurrentAddress = foundelementCoAppli.Address_1__c;
        console.log('this.coApplicurrentAddress' + this.coApplicurrentAddress);
    }else if(event.target.name === 'coAppliCurrentPincode'){   
        foundelementCoAppli.Pin_Code__c = event.target.value;
        this.coAppliCurrentPincode = foundelementCoAppli.Pin_Code__c;
        console.log('this.coAppliCurrentPincode' + this.coAppliCurrentPincode);
    }else if(event.target.name === 'coAppliCurrentCity'){   
        foundelementCoAppli.City__c = event.target.value;
        this.coAppliCurrentCity = foundelementCoAppli.City__c;
        console.log('this.coAppliCurrentCity' + this.coAppliCurrentCity);
    }else if(event.target.name === 'coAppliCurrentTaluka'){   
        foundelementCoAppli.Taluka__c = event.target.value;
        this.coAppliCurrentTaluka = foundelementCoAppli.Taluka__c;
        console.log('this.coAppliCurrentTaluka' + this.coAppliCurrentTaluka);
    }else if(event.target.name === 'coAppliCurrentDistrict'){   
        foundelementCoAppli.District__c = event.target.value;
        this.coAppliCurrentDistrict = foundelementCoAppli.District__c;
        console.log('this.coAppliCurrentDistrict' + this.coAppliCurrentDistrict);
    }else if(event.target.name === 'coAppliCurrentLandmark'){   
        foundelementCoAppli.Landmark__c = event.target.value;
        this.coAppliCurrentLandmark = foundelementCoAppli.Landmark__c;
        console.log('this.coAppliCurrentLandmark' + this.coAppliCurrentLandmark);
    }else if(event.target.name === 'coAppliCurrentState'){   
        foundelementCoAppli.State__c = event.target.value;
        this.coAppliCurrentState = foundelementCoAppli.State__c;
        console.log('this.coAppliCurrentState' + this.coAppliCurrentState);
    }else if(event.target.name === 'coAppliCurrentCountry'){   
        foundelementCoAppli.Country__c = event.target.value;
        this.coAppliCurrentCountry = foundelementCoAppli.Country__c;
        console.log('this.coAppliCurrentCountry' + this.coAppliCurrentCountry);
    }else if(event.target.name === 'coAppliYearInAddress'){   
        foundelementCoAppli.Years_In_The_Address__c = event.target.value;
        this.coAppliYearInAddress = foundelementCoAppli.Years_In_The_Address__c;
        console.log('this.coAppliYearInAddress' + this.coAppliYearInAddress);     
    }else if(event.target.name === 'coAppliSameasCurrentAddr'){   
        foundelementCoAppli.Same_as_Current_Address__c = event.target.value;
        this.coAppliSameasCurrentAddr = foundelementCoAppli.Same_as_Current_Address__c;
        console.log('this.coAppliSameasCurrentAddr' + this.coAppliSameasCurrentAddr);
    }else if(event.target.name === 'coAppliPermanentAddProof'){   
        foundelementCoAppli.Address_Proof__c = event.target.value;
        this.coAppliPermanentAddProof = foundelementCoAppli.Address_Proof__c;
        console.log('this.coAppliPermanentAddProof' + this.coAppliPermanentAddProof);  
    }else if(event.target.name === 'coApplipermanentAddress'){   
        foundelementCoAppli.Address_1__c = event.target.value;
        this.coApplipermanentAddress = foundelementCoAppli.Address_1__c;
        console.log('this.coApplipermanentAddress' + this.coApplipermanentAddress);   
    }else if(event.target.name === 'coAppliPermanentCity'){   
        foundelementCoAppli.City__c = event.target.value;
        this.coAppliPermanentCity = foundelementCoAppli.City__c;
        console.log('this.coAppliPermanentCity' + this.coAppliPermanentCity);
    }else if(event.target.name === 'coAppliPermanentTaluka'){   
        foundelementCoAppli.Taluka__c = event.target.value;
        this.coAppliPermanentTaluka = foundelementCoAppli.Taluka__c;
        console.log('this.coAppliPermanentTaluka' + this.coAppliPermanentTaluka);   
    }else if(event.target.name === 'coAppliPermanentDistrict'){   
        foundelementCoAppli.District__c = event.target.value;
        this.coAppliPermanentDistrict = foundelementCoAppli.District__c;
        console.log('this.coAppliPermanentDistrict' + this.coAppliPermanentDistrict);
    }else if(event.target.name === 'coAppliPermanentLandmark'){   
        foundelementCoAppli.Landmark__c = event.target.value;
        this.coAppliPermanentLandmark = foundelementCoAppli.Landmark__c;
        console.log('this.coAppliPermanentLandmark' + this.coAppliPermanentLandmark); 
    }else if(event.target.name === 'coAppliPermanentState'){   
        foundelementCoAppli.State__c = event.target.value;
        this.coAppliPermanentState = foundelementCoAppli.State__c;
        console.log('this.coAppliPermanentState' + this.coAppliPermanentState);  
    }else if(event.target.name === 'coAppliPermanentCountry'){   
        foundelementCoAppli.Country__c = event.target.value;
        this.coAppliPermanentCountry = foundelementCoAppli.Country__c;
        console.log('this.coAppliPermanentCountry' + this.coAppliPermanentCountry);
    }else if(event.target.name === 'coAppliPermanentCountry'){   
        foundelementCoAppli.Country__c = event.target.value;
        this.coAppliPermanentCountry = foundelementCoAppli.Country__c;
        console.log('this.coAppliPermanentCountry' + this.coAppliPermanentCountry);          

    }                                
}      
   
    handleSaveTwo() {
         this.isLoading = true; 

            let LeadRecord = {
                FirstName: this.LfNName,
                Email: this.LEmail,
                LastName: this.LLastName,
                MobilePhone: this.LMobile,
                Mother_s_First_Name__c: this.LMotherName,
                Mother_s_Middle_Name__c : this.LMotherMiddleName,
                Mother_s_Last_Name__c: this.LMotherLastName,
                Date_of_Birth__c: this.LDateOfBirth,
                Gender__c: this.LGender,
                Aadhar_Number__c: this.LAadharNumber,
                Marital_Status__c : this.maritalStatus,
                Father_s_First_Name__c : this.FatherFirstName,
                Father_s_Middle_Name__c : this.FatherMiddleName,
                Father_s_Last_Name__c : this.FatherLastName,
                Spouse_s_First_Name__c : this.SpouseFirstName,
                Spouse_s_Middle_Name__c:this.SpouseMiddleName,
                Spouse_s_Last_Name__c:this.SpouseLastName,
                PAN_Number__c : this.PANNumber,
                CKYC_Number__c : this.ckycNumber,                
                Driving_License_Number__c : this.driveLicenseNumber,
                Voter_Id__c : this.voterId,
                Passport_Number__c : this.passportNumber,
                Id : this.leadId     
            }
            //Wrapper Class variable
            let wrapperAllRecord ={
                leadstr: JSON.stringify(LeadRecord),            
            }

            creatLeadRecord({
                wrapperDetails : JSON.stringify(wrapperAllRecord)               
            })
                .then(response => {
                    if(response != null){
                        this.leadId = response;
                        console.log('this.leadId=====>' + this.leadId);
                    }
                    console.log(response);
                    this.isLoading = false;
                    
                }).catch(error => {
                    console.log(error);
                    this.isLoading = false;
                })

    }
    // Aadhar File Upload 
    get acceptedFormats() {
        return ['.pdf', '.png', '.jpeg'];
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
    }

    newToast(title, message, varient) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: varient,
        });
        this.dispatchEvent(evt);

    }

    @track fileDataFront;
    openFrontfileUpload(event) {
        const file = event.target.files[0]
        var reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]
            this.fileDataFront = {
                'base64Front': base64,
                'filenameFront': file.name,
            }
            console.log('file data' + this.fileDataFront)

            const customEvent = new CustomEvent("filedatachild", {
                detail: JSON.stringify(this.fileDataFront)
            });

            this.dispatchEvent(customEvent)
        }
        reader.readAsDataURL(file)
        console.log('file' + file.name);

    }

    @track fileDataBack;
    openBackfileUpload(event) {
        const file = event.target.files[0]
        var reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]
            this.fileDataBack = {
                'base64Back': base64,
                'filenameBack': file.name,
            }
            console.log('file data' + this.fileDataBack)

            const customEvent = new CustomEvent("filedatachild", {
                detail: JSON.stringify(this.fileDataBack)
            });

            this.dispatchEvent(customEvent)
        }
        reader.readAsDataURL(file)
        console.log('file' + file.name);
    }
    value = 10;
    radius = "circular";
    size = "medium";
    showDescription = true;
    description = "Progress..";
    variant = "error";
    customColor;

    code = "";

    @api recordId;
    @track wrapperForCommLeadForm;
    @track leadID;
    @track leadSalutation; 
    @track leadFirstName;
    @track leadMiddleName;
    @track leadLastName;
    @track leadMobile;
    @track leadEmail;
    //Appli Account
    @track AppliAccID;
    @track AppliFullName;
    @track AppliFatherFirstName;
    @track AppliFatherMiddleName;
    @track AppliFatherLastName;
    @track AppliGender;
    @track AppliIsIncomeConsiderIsFin;
    @track AppliMotherFirstName;
    @track AppliMotherMiddleName;
    @track AppliMotherLastName;
    @track AppliMaritlStatus;
    @track AppliSpouseFirstName;
    @track AppliSpouseMiddleName;
    @track AppliSpouseLastName;
    @track AppliDOB;
    //Applicant Current Address
    @track AppliCurrentAddID;
    @track AppliCurrentAddProof;
    @track AppliCurrentAddress;
    @track AppliCurrentCity;
    @track AppliCurrentTaluka;
    @track AppliCurrentDistrict;
    @track AppliCurrentPincode;
    @track AppliCurrentLandmark;
    @track AppliCurrentState;
    @track AppliCurrentCountry; 
    @track AreaPinCode;
    @track AreaPinCodeResult;
    //Applicant Permanent Address
    @track AppliPermanentAddID;
    @track AppliPermanentAddProof;
    @track AppliPermanentAddress;
    @track AppliPermanentCity;
    @track AppliPermanentTaluka;
    @track AppliPermanentDistrict;
    @track AppliPermanentPincode;
    @track AppliPermanentLandmark;
    @track AppliPermanentState;
    @track AppliPermanentCountry;
    @track AppliPermanentSameAsCurrent;
    @track error;

    @track City__c;

    handlePincodeSelection(event){
        this.AreaPinCode = event.target.value;
        console.log('result'+this.AreaPinCode);
        getPincodeRecord({ pincode: this.AreaPinCode }) //this parameter is passed to Class-CommunityLeadFormController.getPincodeRecord
            .then(result => {
                console.log('In pincode section',JSON.stringify(result));
                this.AreaPinCodeResult = result;
                
                console.log('pincodeResult=======> ' + JSON.stringify(this.AreaPinCodeResult));
                this.AppliCurrentPincode = this.AreaPinCodeResult.Id;
                this.AppliCurrentCity = this.AreaPinCodeResult.City_Name__c;
                this.AppliCurrentState = this.AreaPinCodeResult.State__c;
                this.AppliCurrentCountry = this.AreaPinCodeResult.Country__c;
                this.AppliCurrentDistrict = this.AreaPinCodeResult.Area_Name_Taluka__c;
                this.AppliCurrentTaluka = this.AreaPinCodeResult.Area_Name_Taluka__c;
            })
            .catch(error => {
                this.errors = error;
                console.log('errors=======> ' + this.errors);
            });
    }

    handlePincodeSelection1(event){
        this.AreaPinCode = event.target.value;
        console.log('result'+this.AreaPinCode);
        getPincodeRecord({ pincode: this.AreaPinCode }) //this parameter is passed to Class-CommunityLeadFormController.getPincodeRecord
            .then(result => {
                console.log('In pincode section',JSON.stringify(result));
                this.AreaPinCodeResult = result;
                
                console.log('pincodeResult=======> ' + JSON.stringify(this.AreaPinCodeResult));
                this.AppliPermanentPincode = this.AreaPinCodeResult.Id;
                this.AppliPermanentCity = this.AreaPinCodeResult.City_Name__c;
                this.AppliPermanentState = this.AreaPinCodeResult.State__c;
                this.AppliPermanentCountry = this.AreaPinCodeResult.Country__c;
                this.AppliPermanentDistrict = this.AreaPinCodeResult.Area_Name_Taluka__c;
                this.AppliPermanentTaluka = this.AreaPinCodeResult.Area_Name_Taluka__c;
            })
            .catch(error => {
                this.errors = error;
                console.log('errors=======> ' + this.errors);
            });
    }
    @track AreaPinCode3;
    @track AreaPinCodeResult3; 
        handleCoAppliCurrentPincode(event){
           
            this.AreaPinCode3 = event.target.value;
            console.log('result Coappli Current'+this.AreaPinCode3);
            getPincodeRecord({ pincode: this.AreaPinCode3 }) //this parameter is passed to Class-CommunityLeadFormController.getPincodeRecord
                .then(result => {
                    console.log('In pincode section Coappli Current',JSON.stringify(result));
                    this.AreaPinCodeResult3 = result;
                    console.log('AreaPinCodeResult3 Coappli Current=======> ' + JSON.stringify(this.AreaPinCodeResult3));

                    if(this.listOfApplicants.length > 0){
                        console.log('Inside the coapppli if');
                        for ( var i = 0; i < this.listOfApplicants.length; i++ ) {
                            console.log('Inside the coapppli for');
                             var recordPincode = this.listOfApplicants[i].appCurrentAdd;                 
                             console.log('recordPincode1:',recordPincode.Pin_Code__c);
                             console.log('recordPincode2:',recordPincode.City__c);
                             console.log('recordPincode3:',recordPincode.District__c);
                             recordPincode.Pin_Code__c = this.AreaPinCodeResult3.Pin_Code__c; 
                             recordPincode.City__c = this.AreaPinCodeResult3.City__c;  
                             recordPincode.District__c = this.AreaPinCodeResult3.District__c;                        
                           
                        }                
                    } 
                   
                })
                .catch(error => {
                    this.errors = error;
                    console.log('errorsCoappli=======> ' + this.errors);
                });
        }

    @wire(getCoAppRecords, {})
    getCoapp({ error, data }) {
        console.log('getCoapp====>' + JSON.stringify(data));
        if (data) {            
            console.log('data inside If' + data);   
            if(data != '' || data != undefined){
                this.listOfApplicants = JSON.parse((JSON.stringify(data)));
                console.log(' this.listOfApplicants data inside If' +  JSON.stringify(this.listOfApplicants)); 
            }else{          
                let randomId = Math.random() * 16;
                console.log("randomId===>" + randomId);
                let myNewElement = { Id: randomId,Type__c: "", Relation_with_applicant__c: "", Relation_others__c: "",Relationship_Proof__c: "",FirstName: "",MiddleName: "",LastName: "",PersonBirthdate: "",PersonMobilePhone: "",PersonEmail: "",Father_Name__c: "",Mother_Name__c: "",Gender__c: "",Marital_Status__c: "",Is_Income_Considered_Is_Financial__c: "",Address_Proof__c: "",Marital_Status__c: "",Address_1__c: "",Pin_Code__c: "",City__c: "",Taluka__c: "",District__c: "",Landmark__c: "",State__c: "",Country__c: "",Years_In_The_Address__c: "",Same_as_Current_Address__c: "",Aadhar_Number__c: "",PAN_Number__c: "",Passport_Number__c: "",Driving_License_Number__c: "",Dirving_License_Expiry_Date__c: "",Voter_ID__c: ""};
                console.log("myNewElement===>" + myNewElement);        
                this.listOfApplicants = [...this.listOfApplicants, myNewElement];
                console.log("this.listOfApplicantsaddRow===>" + this.listOfApplicants);                    
            }       
            // this.listOfApplicants = JSON.parse((JSON.stringify(data)));
            // console.log('this.listOfApplicants data' + JSON.stringify(this.listOfApplicants));  
            // console.log('this.listOfApplicants.objeAcc' + JSON.stringify(this.listOfApplicants[0].objeAcc)); 
            // let check = this.listOfApplicants[1].objeAcc;
            // console.log('this.listOfApplicants.objeAcc check' + JSON.stringify(check));        
        }
        
    }
 
    @wire(getWrapperClassCommFormLists, {})
    wiredWrapperClassCommFormList({ error, data }) {
        console.log('dataTest1====>' + JSON.stringify(data));
        if (data) {
            console.log('data inside If' + data);
            this.wrapperForCommLeadForm = data;

            
            this.leadID = this.wrapperForCommLeadForm.LeadRecords.Id;
            console.log('this.leadID data===>' + this.leadID);
            this.leadSalutation = this.wrapperForCommLeadForm.LeadRecords.Salutation;
            if(this.wrapperForCommLeadForm.LeadRecords.FirstName != null){
                this.leadFirstName = this.wrapperForCommLeadForm.LeadRecords.FirstName;
            }
            console.log('this.leadFirstName data===>' + this.leadFirstName);
            this.leadMiddleName = this.wrapperForCommLeadForm.LeadRecords.MiddleName;
            this.leadLastName = this.wrapperForCommLeadForm.LeadRecords.LastName;
           // this.leadDOB = this.wrapperForCommLeadForm.LeadRecords.Date_of_Birth__c;            
            this.leadMobile = this.wrapperForCommLeadForm.LeadRecords.MobilePhone;
            this.leadEmail = this.wrapperForCommLeadForm.LeadRecords.Email;
            this.CountryOfStudyValue = this.wrapperForCommLeadForm.LeadRecords.Country_of_Study__c;
            this.AdmissionStatus = this.wrapperForCommLeadForm.LeadRecords.Admission_Status__c;
            console.log('this.AdmissionStatus data===>' + this.AdmissionStatus);
            this.universityName = this.wrapperForCommLeadForm.LeadRecords.University_Name__c;
            this.courseCampus = this.wrapperForCommLeadForm.LeadRecords.Campus__c;
            this.InstituteId = this.wrapperForCommLeadForm.LeadRecords.Institute_Name__c;
            this.CourseCategoryValue = this.wrapperForCommLeadForm.LeadRecords.Course_Category__c;
            this.CourseTypeValue = this.wrapperForCommLeadForm.LeadRecords.Course_Type__c;
            this.CourseLevelValue = this.wrapperForCommLeadForm.LeadRecords.Course_Level__c;
            this.CourseStreamValue = this.wrapperForCommLeadForm.LeadRecords.Course_Stream__c;
            this.courseName = this.wrapperForCommLeadForm.LeadRecords.Course_Name_Lookup__c;
            this.courseStartDate = this.wrapperForCommLeadForm.LeadRecords.Course_Start_Date__c;
            this.courseEndDate = this.wrapperForCommLeadForm.LeadRecords.Course_End_Date__c;
            this.LangScoreCategoryValue = this.wrapperForCommLeadForm.LeadRecords.Language_Score_Category__c;
            this.langTestScore = this.wrapperForCommLeadForm.LeadRecords.Language_Test_Score__c; 
            this.AnalytScoreCategoryValue = this.wrapperForCommLeadForm.LeadRecords.Analytics_Score_Category__c;
            this.analyticalTestScore = this.wrapperForCommLeadForm.LeadRecords.Analytics_Test_Score__c;

            if(this.wrapperForCommLeadForm.LeadRecords.Aadhar_Number__c != null){
                this.LAadharNumber = this.wrapperForCommLeadForm.LeadRecords.Aadhar_Number__c;             
                this.makeadhardisable =true;
            }
            if(this.wrapperForCommLeadForm.LeadRecords.PAN_Number__c != null){
                this.PANNumber = this.wrapperForCommLeadForm.LeadRecords.PAN_Number__c;
                this.makepandisable = true;
            }
            if(this.wrapperForCommLeadForm.LeadRecords.Passport_Number__c != null){
                this.passportNumber = this.wrapperForCommLeadForm.LeadRecords.Passport_Number__c;
                this.makepassportdisable = true;
            }
            if(this.wrapperForCommLeadForm.LeadRecords.Driving_License_Number__c != null){
                this.Driving_License_Number__c = this.wrapperForCommLeadForm.LeadRecords.Driving_License_Number__c;
                this.makedrivingdisable = true;
            }
            if(this.wrapperForCommLeadForm.LeadRecords.Voter_Id__c != null){
                this.voterId = this.wrapperForCommLeadForm.LeadRecords.Voter_Id__c;
                this.makevoteriddisable = true;
            }

            //Applicant Account
            this.AppliAccID = this.wrapperForCommLeadForm.AccRecords.Account__c;
            console.log('this.AppliAccID data===>' + this.AppliAccID);
            this.AppliFullName = this.wrapperForCommLeadForm.LeadRecords.FirstName;
            console.log('this.AppliFullName data===>' + this.AppliFullName);
            this.AppliFatherFirstName = this.wrapperForCommLeadForm.AccRecords.Account__r.Father_First_Name__c;
            console.log('this.AppliFatherFirstName data===>' + this.AppliFatherFirstName);
            this.AppliFatherMiddleName = this.wrapperForCommLeadForm.AccRecords.Account__r.Father_Middle_Name__c;
            this.AppliFatherLastName = this.wrapperForCommLeadForm.AccRecords.Account__r.Father_Last_Name__c;
            this.AppliGender = this.wrapperForCommLeadForm.AccRecords.Account__r.Gender__c;
            this.AppliIsIncomeConsiderIsFin = this.wrapperForCommLeadForm.AccRecords.Account__r.Is_Income_Considered_Is_Financial__c;
            this.AppliMotherFirstName = this.wrapperForCommLeadForm.AccRecords.Account__r.Mother_Frist_Name__c;
            this.AppliMotherMiddleName = this.wrapperForCommLeadForm.AccRecords.Account__r.Mother_Middle_Name__c;
            this.AppliMotherLastName = this.wrapperForCommLeadForm.AccRecords.Account__r.Mother_Last_Name__c;
            this.AppliMaritlStatus = this.wrapperForCommLeadForm.AccRecords.Account__r.Marital_Status__c;
            console.log(' this.AppliMaritlStatus data1111===>' +  this.AppliMaritlStatus);
            this.AppliSpouseFirstName = this.wrapperForCommLeadForm.AccRecords.Account__r.Spouse_s_First_Name__c;
            this.AppliSpouseMiddleName = this.wrapperForCommLeadForm.AccRecords.Account__r.Spouse_s_Middle_name__c;
            this.AppliSpouseLastName = this.wrapperForCommLeadForm.AccRecords.Account__r.Spouse_s_Last_Name__c;
            this.AppliDOB = this.wrapperForCommLeadForm.AccRecords.Account__r.Date_of_Birth__c; 
            console.log(' this.AppliDOB data===>' +  this.AppliDOB);
            this.AppliPermIsCommAddressvalue = this.wrapperForCommLeadForm.AccRecords.Account__r.Is_Communication_address__c;    
           //Check if Marital status is Marriend then show Spouse fields
            if(this.AppliMaritlStatus == "Married"){
                this.ShowFieldsAppliSpouse = true;
            }
            else{
                this.ShowFieldsAppliSpouse = false;
            }
            //Check if Admission Status is Confirmed or Applied then show Universityn campus & Institute fields
            if (this.AdmissionStatus == "Confirmed" || this.AdmissionStatus == "Applied") {
                this.ShowFieldsCourseUniversity = true;
                console.log("this.ShowFieldsCourseUniversity====  " + this.ShowFieldsCourseUniversity);
            } 
            else{
                this.ShowFieldsCourseUniversity = false;
                console.log("this.ShowFieldsCourseUniversity====  " + this.ShowFieldsCourseUniversity);
            }  
            //Applicant Current Address
            this.AppliCurrentAddID = this.wrapperForCommLeadForm.CPAAppliCurrentRecord.Id;
            this.AppliCurrentName = this.wrapperForCommLeadForm.CPAAppliCurrentRecord.Name;
            console.log('this.AppliCurrentName data===>' + this.AppliCurrentName);
            this.AppliCurrentAddProof = this.wrapperForCommLeadForm.CPAAppliCurrentRecord.Address_Proof__c;
            this.AppliCurrentAddress = this.wrapperForCommLeadForm.CPAAppliCurrentRecord.Address_1__c;
            this.AppliCurrentCity = this.wrapperForCommLeadForm.CPAAppliCurrentRecord.City__c;
            this.AppliCurrentTaluka = this.wrapperForCommLeadForm.CPAAppliCurrentRecord.Taluka__c;
            this.AppliCurrentDistrict = this.wrapperForCommLeadForm.CPAAppliCurrentRecord.District__c;
            this.AppliCurrentPincode = this.wrapperForCommLeadForm.CPAAppliCurrentRecord.Pin_Code__c;
            console.log('this.AppliCurrentPincode data===>' + this.AppliCurrentPincode);
            this.AppliCurrentLandmark = this.wrapperForCommLeadForm.CPAAppliCurrentRecord.Landmark__c;
            this.AppliCurrentState = this.wrapperForCommLeadForm.CPAAppliCurrentRecord.State__c;
            this.AppliCurrentCountry = this.wrapperForCommLeadForm.CPAAppliCurrentRecord.Country__c;
          
            //Applicant Permanent Address
            this.AppliPermanentAddID = this.wrapperForCommLeadForm.CPAAppliPermanentRecord.Id;
            this.AppliPermanentName = this.wrapperForCommLeadForm.CPAAppliPermanentRecord.Name;
            this.AppliPermanentAddProof = this.wrapperForCommLeadForm.CPAAppliPermanentRecord.Address_Proof__c;
            this.AppliPermanentAddress = this.wrapperForCommLeadForm.CPAAppliPermanentRecord.Address_1__c;
            this.AppliPermanentCity = this.wrapperForCommLeadForm.CPAAppliPermanentRecord.City__c;
            this.AppliPermanentTaluka = this.wrapperForCommLeadForm.CPAAppliPermanentRecord.Taluka__c;
            this.AppliPermanentDistrict = this.wrapperForCommLeadForm.CPAAppliPermanentRecord.District__c;
            this.AppliPermanentPincode = this.wrapperForCommLeadForm.CPAAppliPermanentRecord.Pin_Code__c;
            console.log('this.AppliPermanentPincode data===>' + this.AppliPermanentPincode);
            this.AppliPermanentLandmark = this.wrapperForCommLeadForm.CPAAppliPermanentRecord.Landmark__c;
            this.AppliPermanentState = this.wrapperForCommLeadForm.CPAAppliPermanentRecord.State__c;
            this.AppliPermanentCountry = this.wrapperForCommLeadForm.CPAAppliPermanentRecord.Country__c;
            
            if(this.wrapperForCommLeadForm.CPAAppliPermanentRecord.Same_as_Current_Address__c = true){
                this.AppliPermanentSameAsCurrent = this.wrapperForCommLeadForm.CPAAppliPermanentRecord.Same_as_Current_Address__c;
                this.makePermanentAddProofdisabled = true;
            }

            if(this.wrapperForCommLeadForm.AppliEduDetailsRecord.length > 0){
                this.listOfEducationalTable  = JSON.parse(JSON.stringify(this.wrapperForCommLeadForm.AppliEduDetailsRecord)); 
            }else{           
             let randomId = Math.random() * 16;
                let myNewElement = { Id: randomId,Education_Qualification__c: "", Year_Completed__c: "", Percentage_Marks_CGPA__c: "",School_College_University__c: ""};
                console.log("myNewElement===>" + myNewElement);        
                this.listOfEducationalTable = [myNewElement];
                console.log("this.listOfEducationalTable===>" + this.listOfEducationalTable);                 
            }            

            this.error = error;   
        }            
 
    }
    handleIsCommAddress(event){
        console.log("this.AppliPermanentCountry====  " + this.AppliPermanentCountry);
        if (event.target.name == "IsCommunicationAddress" && event.target.value != "") {
            this.AppliPermIsCommAddressvalue = event.target.value;
            console.log("this.AppliPermIsCommAddressvalue====  " + this.AppliPermIsCommAddressvalue);
        }       
        if((this.AppliPermanentCountry != 'INDIA' && this.AppliPermIsCommAddressvalue == 'Permanent Address')|| this.AppliCurrentCountry != 'INDIA' && this.AppliPermIsCommAddressvalue == 'Current Address'){
            console.log("Country is not India ");
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                message: 'Please enter country as India for communication address',
                variant: 'Error',
                }),
            );
        }            
    }

    get IsCommAddressoptions() {
        return [
            { label: 'Current Address', value: 'Current Address' },
            { label: 'Permanent Address', value: 'Permanent Address' },
        ];
    }
    handleSaveCoApplicant(){          
        console.log('listOfApplicants lenght',this.listOfApplicants[0].objeAcc)
        var isError1 = false;
        if(this.listOfApplicants.length > 0){
            console.log('Inside the coapppli if', JSON.stringify(this.listOfApplicants));

            for ( var i = 0; i < this.listOfApplicants.length; i++ ) {
                console.log('Inside the coapppli for');
                 var record = this.listOfApplicants[i].objeAcc;   
                 console.log('record Result:',JSON.stringify(record));      
                 console.log('record2:',record.FirstName);
                 console.log('record3:',record.MiddleName);
                 console.log('record4:',record.LastName);
                if(record.FirstName == '' || record.FirstName == undefined){
                    isError1 = true;
                    console.log('FirstName ifisError1', isError1);
                 }
                else if(record.MiddleName == '' || record.MiddleName == undefined){
                    isError1 = true;
                    console.log('MiddleName ifisError1', isError1);
                 }
                else if(record.LastName == '' || record.LastName == undefined){
                    isError1 = true;
                    console.log('LastName ifisError1', isError1);
                 }
                }                
        } 
        console.log('isError1 check after for:', isError1);
        if(!isError1){
            // this.listOfApplicants.forEach(res =>{
            //     if(!isNaN(res.Id)){
            //         res.Id = null;
            //         console.log(' res.Id====>' +   res.Id);
            //     }
            // });
        //Wrapper Class variable
        // let wrapperCommFormCoAppliRecord ={            
        //   //  accForCoAppli : JSON.stringify(AppliAccDataSaveRec),
        //   coAppliSecRecord : JSON.stringify(this.listOfApplicants)    
        // }
        // console.log('wrapperCommFormCoAppliRecord=====>' + JSON.stringify(wrapperCommFormCoAppliRecord));            
        // for(obj in this.listofapplicant){
        //     obj.objeAcc.Contact_Point_Addresses__r = rewriteSubquery(obj.objeAcc.Contact_Point_Addresses__r);
        //     obj.objApplicant.Account__r = rewriteSubquery(obj.objApplicant.Account__r);
        // }
        communityWrapperFormMethod({            
            wrapperCommFormCoAppliDetails : JSON.stringify(this.listOfApplicants)                
        })
            .then(response => {
                console.log(response);
                if(response != null){
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
        }else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please fill all the mandatory fields',
                    variant: 'Error',
                }),
            );
        }
    }  

    handleSaveLead(){

        if(this.AppliDOB == '' || this.AppliDOB == undefined || this.LAadharNumber == '' || this.LAadharNumber == undefined || 
        this.PANNumber == '' || this.PANNumber == undefined || this.leadSalutation == '' || this.leadSalutation == undefined || 
        this.leadFirstName == '' || this.leadFirstName == undefined ||  this.leadLastName == '' || this.leadLastName == undefined ||
        this.leadEmail == '' || this.leadEmail == undefined || this.leadMobile == '' || this.leadMobile == undefined ||
        this.AppliGender == '' || this.AppliGender == undefined || this.AppliFatherFirstName == '' || this.AppliFatherFirstName == undefined ||
        this.AppliIsIncomeConsiderIsFin == '' || this.AppliIsIncomeConsiderIsFin == undefined ||  this.AppliMotherFirstName == '' || this.AppliMotherFirstName == undefined ||
        this.AppliMaritlStatus == '' || this.AppliMaritlStatus == undefined || this.AppliSpouseFirstName == '' || this.AppliSpouseFirstName == undefined ||
        this.AppliCurrentAddress == '' || this.AppliCurrentAddress == undefined || this.AppliPermanentAddress == '' || this.AppliPermanentAddress == undefined ||
        this.AppliCurrentCity == '' || this.AppliCurrentCity == undefined || this.AppliCurrentTaluka == '' || this.AppliCurrentTaluka == undefined ||
        this.AppliCurrentTaluka == '' || this.AppliCurrentTaluka == undefined || this.AppliCurrentPincode == '' || this.AppliCurrentPincode == undefined ||
        this.AppliCurrentState == '' || this.AppliCurrentState == undefined || this.AppliPermanentCity == '' || this.AppliPermanentCity == undefined ||
        this.AppliPermanentTaluka == '' || this.AppliPermanentTaluka == undefined || this.AppliPermanentDistrict == '' || this.AppliPermanentDistrict == undefined ||
        this.AppliPermanentPincode == '' || this.AppliPermanentPincode == undefined || this.AppliPermanentState == '' || this.AppliPermanentState == undefined ||
        this.AppliPermanentCountry == '' || this.AppliPermanentCountry == undefined || this.AppliCurrentCountry == '' || this.AppliCurrentCountry == undefined){

            console.log("Date =========" +this.AppliDOB);
            console.log("Inside date condition");   
            this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Required fields are missing',
                        variant: 'Error',
                    }),
                );
        }
        else if((this.AppliPermanentCountry != 'INDIA' && this.AppliPermIsCommAddressvalue == 'Permanent Address') || (this.AppliCurrentCountry != 'INDIA' && this.AppliPermIsCommAddressvalue == 'Current Address')){
            console.log("Country is India  ");   
            this.dispatchEvent(
                     new ShowToastEvent({
                         title: 'Error!!',
                         message: 'Please enter country as India for communication address',
                         variant: 'Error',
                     }),
                 );        
         }
        else{
            console.log("Inside Handle save condition" );

        var leadupadteKYCdetails = {
            panNumber: this.PANNumber,
            aadharNumber: this.aadharLastFour,
            drivingLicence: this.Driving_License_Number__c,
            passportNumber: this.passportNumber,
            dateOfBirthLead: this.LDateOfBirth,
            leadId: this.leadID,
            voterId: this.voterId
        }; 
        console.log('leadupadteKYCdetails: ' +  JSON.stringify(leadupadteKYCdetails));     
  
        let LeadDataSaveRec = {
            Salutation: this.leadSalutation,
            FirstName: this.leadFirstName,
            MiddleName: this.leadMiddleName,
            LastName: this.leadLastName,
            MobilePhone: this.leadMobile,
            Email: this.leadEmail,                 
            Id : this.leadID                      
        }
        console.log('LeadDataSaveRec=====>' +  JSON.stringify(LeadDataSaveRec));   
        console.log("mother name" + this.AppliMotherFirstName);   

        let AppliAccDataSaveRec = {
            Father_First_Name__c: this.AppliFatherFirstName,
            Father_Middle_Name__c: this.AppliFatherMiddleName,
            Father_Last_Name__c: this.AppliFatherLastName,
            Gender__c:  this.AppliGender,
            Is_Income_Considered_Is_Financial__c: this.AppliIsIncomeConsiderIsFin,
            Mother_Frist_Name__c: this.AppliMotherFirstName,
            Mother_Middle_Name__c: this.AppliMotherMiddleName,
            Mother_Last_Name__c: this.AppliMotherLastName,
            Marital_Status__c: this.AppliMaritlStatus,
            Spouse_s_First_Name__c: this.AppliSpouseFirstName,
            Spouse_s_Middle_name__c: this.AppliSpouseMiddleName,
            Spouse_s_Last_Name__c: this.AppliSpouseLastName,
            Date_of_Birth__c: this.AppliDOB,
            Is_Communication_address__c: this.AppliPermIsCommAddressvalue,
            Id: this.AppliAccID
        }
        console.log('AppliAccDataSaveRec=====>' +  JSON.stringify(AppliAccDataSaveRec));

        let AppliCurrentAddSaveRec = {
            Name: this.AppliCurrentName,
            Address_Proof__c: this.AppliCurrentAddProof,
            Address_1__c: this.AppliCurrentAddress,
            City__c: this.AppliCurrentCity, 
            Taluka__c: this.AppliCurrentTaluka,
            District__c: this.AppliCurrentDistrict, 
            Pin_Code__c: this.AppliCurrentPincode, 
            Landmark__c: this.AppliCurrentLandmark, 
            State__c: this.AppliCurrentState, 
            Country__c: this.AppliCurrentCountry,            
            Id: this.AppliCurrentAddID,
            Address_Type__c: 'Current Address',
            Account__c: this.AppliAccID
            
        }
        console.log('AppliCurrentAddSaveRec=====>' +  JSON.stringify(AppliCurrentAddSaveRec));

        let AppliPermanentAddSaveRec = {
            Name: this.AppliPermanentName,
            Address_Proof__c: this.AppliPermanentAddProof,
            Address_1__c: this.AppliPermanentAddress,
            City__c: this.AppliPermanentCity, 
            Taluka__c: this.AppliPermanentTaluka,
            District__c: this.AppliPermanentDistrict, 
            Pin_Code__c: this.AppliPermanentPincode, 
            Landmark__c: this.AppliPermanentLandmark, 
            State__c: this.AppliPermanentState, 
            Country__c: this.AppliPermanentCountry,
            Id: this.AppliPermanentAddID, 
            Address_Type__c: 'Permanent Address',   
            Account__c: this.AppliAccID,
            Same_as_Current_Address__c: this.AppliPermanentSameAsCurrent
        }
        console.log('AppliPermanentAddSaveRec=====>' +  JSON.stringify(AppliPermanentAddSaveRec)); 

        //Wrapper Class variable
        let wrapperCommFormRecord ={
            leadSaveRec: JSON.stringify(LeadDataSaveRec),    
            appliAccSaveRec: JSON.stringify(AppliAccDataSaveRec), 
            appliCurrentAddSave: JSON.stringify(AppliCurrentAddSaveRec),
            appliPermanentAddSave: JSON.stringify(AppliPermanentAddSaveRec),    
            appliEduDetailsSave : JSON.stringify(this.listOfEducationalTable)    
        }
        console.log('wrapperCommFormRecord=====>' + JSON.stringify(wrapperCommFormRecord));    
        

        updateLeadFromCommunity({wrapperLeadKYCUpdateData : leadupadteKYCdetails})
            .then(result => {
                console.log('Data:'+ JSON.stringify(result));
            }) .catch(error => {
                console.log(error);
                this.error = error;
            });
        
        creatCommFormLeadRecords({            
            wrapperCommFormDetails : JSON.stringify(wrapperCommFormRecord)                
        })
            .then(response => {
                console.log(response);
                if(response != null){
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
        }
    }   
    handleSaveCourseEduSection(){        
        console.log('this.EducationDetails SAVE====>' , JSON.stringify(this.listOfEducationalTable));
        console.log('this.EducationDetails SAVE====>' , this.listOfEducationalTable.length);
        var isError = false;
        console.log('this.YearCompleted SAVE====>' , this.YearCompleted);
        console.log('this.PercentageMarks SAVE====>' , this.PercentageMarks);
        console.log('this.SchoolCollegeUniversity SAVE====>' , this.SchoolCollegeUniversity);
        if(this.CountryOfStudyValue == '' || this.CountryOfStudyValue == undefined || 
        this.AdmissionStatus == '' || this.AdmissionStatus == undefined || 
        this.universityName == '' || this.universityName == undefined || 
        this.courseCampus == '' || this.courseCampus == undefined ||
        this.InstituteId == '' || this.InstituteId == undefined || 
        this.CourseCategoryValue == '' || this.CourseCategoryValue == undefined || 
        this.CourseTypeValue == '' || this.CourseTypeValue == undefined ||
        this.CourseLevelValue == '' || this.CourseLevelValue == undefined ||
        this.CourseStreamValue == '' || this.CourseStreamValue == undefined ||
        this.LangScoreCategoryValue == '' || this.LangScoreCategoryValue == undefined ||
        this.langTestScore == '' || this.langTestScore == undefined || 
        this.AnalytScoreCategoryValue == '' || this.AnalytScoreCategoryValue == undefined ||
        this.analyticalTestScore == '' || this.analyticalTestScore == undefined ||
        this.courseName  == '' || this.courseName == undefined      
       )        
        { 
            isError = true;       
        }        
        if(this.listOfEducationalTable.length > 0){
            for ( var i = 0; i < this.listOfEducationalTable.length; i++ ) {
                  var record = this.listOfEducationalTable[i];
                 console.log('record:',record.Education_Qualification__c);
                 if(record.Education_Qualification__c == '' || record.Education_Qualification__c == undefined){
                    isError = true;
                 }
                else if(record.Percentage_Marks_CGPA__c == '' || record.Percentage_Marks_CGPA__c == undefined){
                    isError = true;
                 }
                else if(record.School_College_University__c == '' || record.School_College_University__c == undefined){
                    isError = true;
                 }
                else if(record.Year_Completed__c == '' || record.Year_Completed__c == undefined){
                    isError = true;
                 }
            }
        }
        if(!isError){
        this.isLoading = true;
        let CourseSecSaveRec = {                        
            Id : this.leadID,
            Institute_Name__c : this.InstituteId,
            Country_of_Study__c: this.CountryOfStudyValue,
            Admission_Status__c: this.AdmissionStatus,
            University_Name__c: this.universityName,
            Campus__c : this.courseCampus,
            Course_Category__c: this.CourseCategoryValue,
            Course_Type__c: this.CourseTypeValue,
            Course_Level__c: this.CourseLevelValue,
            Course_Stream__c: this.CourseStreamValue,
            Course_Start_Date__c: this.courseStartDate,
            Course_End_Date__c: this.courseEndDate,         
            Language_Score_Category__c: this.LangScoreCategoryValue,
            Language_Test_Score__c: this.langTestScore,
            Analytics_Score_Category__c: this.AnalytScoreCategoryValue,
            Analytics_Test_Score__c: this.analyticalTestScore           
        }
        console.log('CourseSecSaveRec=====>' +  JSON.stringify(CourseSecSaveRec));
        let CourseAppliAccDataSaveRec = {            
            Id: this.AppliAccID
        } 
        if(this.deleteEmpIds !== ''){
            this.deleteEmpIds = this.deleteEmpIds.substring(0);
        }
       
        this.listOfEducationalTable.forEach(res =>{
            if(!isNaN(res.Id)){
                res.Id = null;
                console.log(' res.Id====>' +   res.Id);
            }
        });
        console.log(' this.deleteEmpIds====>' +   this.deleteEmpIds);
        //Wrapper Class variable      
        let wrapperCommFormRecord ={
            leadSaveRec: JSON.stringify(CourseSecSaveRec),    
            appliEduDetailsSave : JSON.stringify(this.listOfEducationalTable),
            appliAccSaveRec: JSON.stringify(CourseAppliAccDataSaveRec),
            removeEducationIds : this.deleteEmpIds
        }
        console.log('wrapperCommFormRecord=====>' + JSON.stringify(wrapperCommFormRecord));            

        creatCommFormLeadRecords({            
            wrapperCommFormDetails : JSON.stringify(wrapperCommFormRecord),            
        })
            .then(response => {
                console.log(response);
                if(response != null){
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
        }else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please fill all the mandatory fields',
                    variant: 'Error',
                }),
            );
        }  
    } 
    rewriteSubquery(arrays) {
        if (arrays && !arrays.hasOwnProperty('records')) {
            var tempArray = arrays;
            arrays = {
                totalSize: tempArray.length,
                done: true,
                records: tempArray
            }
        }
        return arrays;
    };
}