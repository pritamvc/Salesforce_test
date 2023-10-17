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
import getCoAppRecords from '@salesforce/apex/DemoCommunityLeadForm.getCoapp';


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
   //Coapplicant fields
   //Co-appli Address Current
   @track coApplicurrentAddress;
   @track coAppliCurrentCity;
   @track coAppliCurrentTaluka;
   @track coAppliCurrentDistrict;
   @track coAppliCurrentPincode;
   @track coAppliCurrentLandmark;
   @track coAppliCurrentState;
   @track coAppliCurrentCountry;
   //Co-appli Address Permanent
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
   
    //Show Hide fields
    @track ShowFieldsAppliSpouse = false;
    @track ShowFieldsCourseUniversity = false;
    @track ShowFieldsCourseInstAndCampus = false;
    @track ShowFieldsApplicantCategory = false;    
    @track ShowFieldsRelationWithAppliIfOther = false;
    @track ShowFieldsAppliDriveLicDateofExpiry = false;
    @track ShowFieldsCoAppliDriveLicDateofExpiry = false;
    //Same as Current Address checkbox
    //@track checkboxVal;

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
    //Path variable
    @track currentPath = "1";
    // Accordians Veriable
     @track activeSectionMessage = 'A';
    @track coapplicantName;     
    @track coAppFatherSpouseName;
    @track coApplicantDOB;
    @track motherFullName;
    @track CoAppEmail;
    @track CoAppMobile;
    //Table section list
    @track listOfCoappliAccTable;   
    @track listOfEducationalTable;
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
    //Relationship with Applicant from Account from SFDC
    @track RelshipWithAppliPerAcc;
    @api RelshipWithAppliPerAccField = 'Relationship_with_Applicant__c';
    @track RelshipWithAppliPerAccLabel;    
    @api RelshipWithAppliPerAccValue;
    @track RelshipWithAppliPerAccOptions;
     apiRelshipWithAppliPerAcc;
    //Relationship Proof from Account from SFDC
    @track RelshipProofPerAcc;
    @api RelshipProofPerAccField = 'Relationship_Proof__c';
    @track RelshipProofPerAccLabel;    
    @api RelshipProofPerAccValue;
    @track RelshipProofPerAccOptions;
    apiRelshipProofPerAcc;
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

       console.log('Employ record ==>' + this.listOfFinancialTable);

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
 // error handling
 console.log("error");
 }
 if (data) {
 // success handling
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

                //Gender
                this.apiFieldName = this.objectName + '.' + this.fieldName;
                this.fieldLabel = data.fields[this.fieldName].label;

                //Country of study
                this.apiCountryOfStudyObjFieldName = this.objectName + '.' + this.CountryOfStudyField;
                this.CountryOfStudyLabel = data.fields[this.CountryOfStudyField].label;

                //Admission Status
                this.apiAdmissionStatus = this.objectName + '.' + this.AdmissionStatusField;
                this.AdmissionStatusLabel = data.fields[this.AdmissionStatusField].label;

                //Course Category
                this.apiCourseCategory = this.objectName + '.' + this.CourseCategoryField;
                this.CourseCategoryLabel = data.fields[this.CourseCategoryField].label;

                 //Course Type
                 this.apiCourseType = this.objectName + '.' + this.CourseTypeField;
                 this.CourseTypeLabel = data.fields[this.CourseTypeField].label;

                  //Course Level
                  this.apiCourseLevel = this.objectName + '.' + this.CourseLevelField;
                  this.CourseLevelLabel = data.fields[this.CourseLevelField].label;

                  //Course Stream
                  this.apiCourseStream = this.objectName + '.' + this.CourseStreamField;
                  this.CourseStreamLabel = data.fields[this.CourseStreamField].label;

                  //Language Score Category
                  this.apiLangScoreCategory = this.objectName + '.' + this.LangScoreCategoryField;
                  this.LangScoreCategoryLabel = data.fields[this.LangScoreCategoryField].label;

                  //Analytics Score Category
                  this.apiAnalytScoreCategory = this.objectName + '.' + this.AnalytScoreCategoryField;
                  this.AnalytScoreCategoryLabel = data.fields[this.AnalytScoreCategoryField].label;

                   //Salutation 
                   this.apisalutation = this.objectName + '.' + this.salutationField;
                   this.salutationLabel = data.fields[this.salutationField].label;

                    //Is Income Considered / Is Financial 
                    this.apiisIncomeConsiderIsFin = this.objectName + '.' + this.isIncomeConsiderIsFinField;
                    this.isIncomeConsiderIsFinLabel = data.fields[this.isIncomeConsiderIsFinField].label;

                    //Marital Status
                    this.apimaritalStatus = this.objectName + '.' + this.maritalStatusField;
                    this.maritalStatusLabel = data.fields[this.maritalStatusField].label;

                    //Appli Address Type
                    this.apiappliAddressType = this.objectName + '.' + this.appliAddressTypeField;
                    this.appliAddressTypeLabel = data.fields[this.appliAddressTypeField].label;

                     //Appli Address Proof
                     this.apiappliAddressProof = this.objectName + '.' + this.appliAddressProofField;
                     this.appliAddressProofLabel = data.fields[this.appliAddressProofField].label;
        } else if (error) {
            // Handle error
            console.log('==============Error ');
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
            // Handle error
            console.log('==============Error  ' + error);
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
            // Handle error
            console.log('==============Error  ' + error);
            console.log(error);
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
            // Handle error
            console.log('==============Error  ' + error);
            console.log(error);
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
            // Handle error
            console.log('==============Error  ' + error);
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
            // Handle error
            console.log('==============Error  ' + error);
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
            // Handle error
            console.log('==============Error  ' + error);
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
            // Handle error
            console.log('==============Error  ' + error);
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
            // Handle error
            console.log('==============Error  ' + error);
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
            // Handle error
            console.log('==============Error  ' + error);
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
            // Handle error
            console.log('==============Error  ' + error);
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
            // Handle error
            console.log('==============Error  ' + error);
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
            // Handle error
            console.log('==============Error  ' + error);
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
            // Handle error
            console.log('==============Error  ' + error);
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
             // Handle error
             console.log('==============Error  ' + error);
             console.log(error);
         }
     }   

    //Not used it for Account recordtype
    get recordTypeIdPA() {
        // Returns a map of record type Ids 
        const rtis = this.objectInfo.data.recordTypeInfos;
        return Object.keys(rtis).find(rti => rtis[rti].name === 'Person Account');
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
                //Acc-Marital Status
                this.apiMaritalStatusPerAcc = this.objectNameAcc + '.' + this.MaritalStatusPerAccField;
                this.MaritalStatusPerAccLabel = data.fields[this.MaritalStatusPerAccField].label;  
                
                //Acc-Gender 
                this.apiGenderPerAcc = this.objectNameAcc + '.' + this.GenderPerAccField;
                this.GenderPerAccLabel = data.fields[this.GenderPerAccField].label;   

                //Relationship with Applicant from Account from SFDC
                this.apiRelshipWithAppliPerAcc = this.objectNameAcc + '.' + this.RelshipWithAppliPerAccField;
                this.RelshipWithAppliPerAccLabel = data.fields[this.RelshipWithAppliPerAccField].label;   

                //Relationship Proof from Account from SFDC
                this.apiRelshipProofPerAcc = this.objectNameAcc + '.' + this.RelshipProofPerAccField;
                this.RelshipProofPerAccLabel = data.fields[this.RelshipProofPerAccField].label;   
                
                //Address Proof Current from Account from SFDC
                this.apiAddProofCurrentPerAcc = this.objectNameAcc + '.' + this.AddProofCurrentPerAccField;
                this.AddProofCurrentPerAccLabel = data.fields[this.AddProofCurrentPerAccField].label;   

                //Address Proof Permanent from Account from SFDC
                this.apiAddProofPermantPerAcc = this.objectNameAcc + '.' + this.AddProofPermantPerAccField;
                this.AddProofPermantPerAccLabel = data.fields[this.AddProofPermantPerAccField].label;   

                //Employment Type from Account from SFDC
                this.apiEmploymentTypePerAcc = this.objectNameAcc + '.' + this.EmploymentTypePerAccField;
                this.EmploymentTypePerAccLabel = data.fields[this.EmploymentTypePerAccField].label; 
                
                //No. of Years with current employer from Account from SFDC 
                this.apiNumYearsCurrEmployerPerAcc = this.objectNameAcc + '.' + this.NumYearsCurrEmployerPerAccField;
                this.NumYearsCurrEmployerPerAccLabel = data.fields[this.NumYearsCurrEmployerPerAccField].label; 

                //Type of Company from Account from SFDC
                this.apiTypeOfCompanyPerAcc = this.objectNameAcc + '.' + this.TypeOfCompanyPerAccField;
                this.TypeOfCompanyPerAccLabel = data.fields[this.TypeOfCompanyPerAccField].label; 

                //Role in Organization from Account from SFDC
                this.apiRoleInOrgPerAcc = this.objectNameAcc + '.' + this.RoleInOrgPerAccField;
                this.RoleInOrgPerAccLabel = data.fields[this.RoleInOrgPerAccField].label; 

               //Is Income Considered / Is Financial from Account from SFDC
                this.apiisIncomeConsiderIsFinPerAcc = this.objectNameAcc + '.' + this.isIncomeConsiderIsFinPerAccField;
                this.isIncomeConsiderIsFinPerAccLabel = data.fields[this.isIncomeConsiderIsFinPerAccField].label; 

        } else if (error) {
            // Handle error
            console.log('==============Error ');
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
            // Handle error
            console.log('==============Error  ' + error);
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
            // Handle error
            console.log('==============Error  ' + error);
            console.log(error);
        }
    }

    //Relationship with Student- Account
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId1', fieldApiName: '$apiRelshipWithAppliPerAcc' })
    getPicklistValues013({ error, data }) {
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
            // Handle error
            console.log('==============Error  ' + error);
            console.log(error);
        }
    }

     //Relationship Proof - Account
     @wire(getPicklistValues, { recordTypeId: '$recordTypeId1', fieldApiName: '$apiRelshipProofPerAcc' })
     getPicklistValues014({ error, data }) {
         if (data) {
             // Map picklist values
             this.RelshipProofPerAccOptions = data.values.map(plValue => {
                 return {
                     label: plValue.label,
                     value: plValue.value
                 };               
             });
             console.log('==============RelshipProofOptions  ' + data);
 
         } else if (error) {
             // Handle error
             console.log('==============Error  ' + error);
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
             // Handle error
             console.log('==============Error  ' + error);
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
             // Handle error
             console.log('==============Error  ' + error);
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
             // Handle error
             console.log('==============Error  ' + error);
             console.log(error);
         }
     }

     //No. of Years with current employer - Account
     @wire(getPicklistValues, { recordTypeId: '$recordTypeId1', fieldApiName: '$apiNumYearsCurrEmployerPerAcc' })
     getPicklistValues018({ error, data }) {
         if (data) {
             // Map picklist values
             this.NumYearsCurrEmployerPerAccOptions = data.values.map(plValue => {
                 return {
                     label: plValue.label,
                     value: plValue.value
                 };               
             });
             console.log('==============NumYearsCurrEmployerPerAccOptions  ' + data);
 
         } else if (error) {
             // Handle error
             console.log('==============Error  ' + error);
             console.log(error);
         }
     }

     //Type of Company - Account
     @wire(getPicklistValues, { recordTypeId: '$recordTypeId1', fieldApiName: '$apiTypeOfCompanyPerAcc' })
     getPicklistValues019({ error, data }) {
         if (data) {
             // Map picklist values
             this.TypeOfCompanyPerAccOptions = data.values.map(plValue => {
                 return {
                     label: plValue.label,
                     value: plValue.value
                 };               
             });
             console.log('==============TypeOfCompanyPerAccOptions  ' + data);
 
         } else if (error) {
             // Handle error
             console.log('==============Error  ' + error);
             console.log(error);
         }
     }
     //Role in organisation - Account
     @wire(getPicklistValues, { recordTypeId: '$recordTypeId1', fieldApiName: '$apiRoleInOrgPerAcc' })
     getPicklistValues020({ error, data }) {
         if (data) {
             // Map picklist values
             this.RoleInOrgPerAccOptions = data.values.map(plValue => {
                 return {
                     label: plValue.label,
                     value: plValue.value
                 };               
             });
             console.log('==============RoleInOrgPerAccOptions  ' + data);
 
         } else if (error) {
             // Handle error
             console.log('==============Error  ' + error);
             console.log(error);
         }
     }
     //Co-Applicant or Guarator Category - Account
     @wire(getPicklistValues, { recordTypeId: '$recordTypeId1', fieldApiName: '$apiAppliCategoryPerAcc' })
     getPicklistValues021({ error, data }) {
         if (data) {
             // Map picklist values
             this.AppliCategoryPerAccOptions = data.values.map(plValue => {
                 return {
                     label: plValue.label,
                     value: plValue.value
                 };               
             });
             console.log('==============AppliCategoryPerAccOptions  ' + data);
 
         } else if (error) {
             // Handle error
             console.log('==============Error  ' + error);
             console.log(error);
         }
     }    
    //Is Income Considered / Is Financial - Account 
     @wire(getPicklistValues, { recordTypeId: '$recordTypeId1', fieldApiName: '$apiisIncomeConsiderIsFinPerAcc' })
     getPicklistValues022({ error, data }) {
         if (data) {
             // Map picklist values
             this.isIncomeConsiderIsFinPerAccOptions = data.values.map(plValue => {
                 return {
                     label: plValue.label,
                     value: plValue.value
                 };               
             });
             console.log('==============isIncomeConsiderIsFinPerAccOptions  ' + data);
 
         } else if (error) {
             // Handle error
             console.log('==============Error  ' + error);
             console.log(error);
         }
     }    
      //Education Details Picklist field from SFDC
    @wire(getObjectInfo, { objectApiName: '$objectNameEduDetails' })
    getObjectData2({ error, data }) {
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
    console.log("ver req",this.otpValue);
    console.log(" reqid",this.requestIdTemp);
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
       console.log("otp",this.otpValueAadhar);
       console.log("LAadharNumber",this.LAadharNumber);
       console.log("requestIdAadhar",this.requestIdAadhar);
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
        console.log(this.aadharLastFour);
        console.log("dob",this.LDateOfBirth);
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
                
                console.log('this.sumScore',this.sumScore);
                console.log('this.sumScore percent',this.sumScorePercent);
                console.log("Pan Verification done!!");
                
                console.log("MAKESSSS===" +this.makepandisable);
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
        console.log("this.passportNumber====  " + this.passportNumber);
    }
    if (event.target.name == "Driving_License_Number__c" && event.target.value !="") {
        this.Driving_License_Number__c = event.target.value;
        console.log("this.Driving_License_Number__c====  " + this.Driving_License_Number__c);
    }
    if (event.target.name == "voterId" && event.target.value != "") {
            this.voterId = event.target.value;
             console.log("this.voterId====  " + this.voterId);
    }


      /*********Get DuplicateAccount ******************/
      getDeplicateAccout({'adharNumber':this.LAadharNumber , 'panNumber':this.PANNumber,'dateOfBirth':this.LDateOfBirth})
    .then((result) => {
        //let dupaccountresult = JSON.stringify(result);

        this.duplicateAccountResult = result;
        console.log(this.duplicateAccountResult);

            if (this.duplicateAccountResult.Passport_Number__c != null) {
                this.passportNumber =  this.duplicateAccountResult.Passport_Number__c;
                this.makepassportdisable =true;
            }
            console.log("PASSWORDNUMBER==  " +this.Passport_Number__c);  

            if (this.duplicateAccountResult.Driving_License_Number__c != null) {
                this.Driving_License_Number__c =  this.duplicateAccountResult.Driving_License_Number__c;
                this.makedrivingdisable = true;
            }
            console.log("Driving License Number ==  " +this.Driving_License_Number__c); 

            if (this.duplicateAccountResult.Voter_ID__c != null) {
                this.voterId =  this.duplicateAccountResult.Voter_ID__c;
                this.makevoteriddisable = true;
            }
            console.log("Driving License Number ==  " +this.Voter_ID__c);
            
        
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
                this.dispatchEvent(event);
         }
        })
        .catch((error) => {
            console.error("error",error);
        });
    }
 }
 
 
 handleVerifyMob(){
    console.log("this.otpValueMob",this.otpValueMob);
    console.log("this.requestIdMob",this.requestIdMob);
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
        console.log('Record in Timeout');   
        this.initData();
        this.todaysDate = new Date().toISOString().split('T')[0];        
    }

    triggerEventOnce() {        
          this.event1 = setInterval(() => {
            if(this.LLastName !=null && (this.LEmail !=null || this.LMobile !=null)){
          this.handleSaveTwo(creatLeadRecord);
          this.isLoading = false;
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

    initData() {
        let listOfCoappliAccTable = [];
        this.createRow(listOfCoappliAccTable);
        this.listOfCoappliAccTable = listOfCoappliAccTable;

    }

    createRow(listOfCoappliAccTable) {
        let accountObject = {};
        if(listOfCoappliAccTable.length > 0) {
            accountObject.index = listOfCoappliAccTable[listOfCoappliAccTable.length - 1].index + 1;
        } else {
            accountObject.index = 1;
        }
        accountObject.LastName = null;
        accountObject.Father_Spouse_Name__pc = null;
        accountObject.Date_of_Birth__pc = null;
        accountObject.Mother_Name__pc = null;
        accountObject.PersonEmail = null;
        accountObject.Mobile_No__pc = null;
        listOfCoappliAccTable.push(accountObject);
    }   
    addNewRow() {
        this.createRow(this.listOfCoappliAccTable);
    }
    removeTheRow(event) {
        let sum = 0;
        for (let i = 0; i < this.listOfCoappliAccTable.length; i++) {
          sum += this.listOfCoappliAccTable[i].index;
        }
        console.log("dlelelelelel",sum)
        if(sum == 1){
        console.log("Not Posssible")
        }else{
            let toBeDeletedRowIndex = event.target.name;

            let listOfCoappliAccTable = [];
            for(let i = 0; i < this.listOfCoappliAccTable.length; i++) {
                let tempRecord = Object.assign({}, this.listOfCoappliAccTable[i]);
                if(tempRecord.index !== toBeDeletedRowIndex) {
                    listOfCoappliAccTable.push(tempRecord);
                }
            }    
            for(let i = 0; i < listOfCoappliAccTable.length; i++) {
                listOfCoappliAccTable[i].index = i + 1;
            }    
            this.listOfCoappliAccTable = listOfCoappliAccTable;
        }        
    }
  
    addRow() {
        let randomId = Math.random() * 16;
        console.log("randomId===>" + randomId);
        let myNewElement = {Education_Qualification__c: "", Year_Completed__c: "", Percentage_Marks_CGPA__c: "",School_College_University__c: ""};
        console.log("myNewElement===>" + myNewElement);
        this.listOfEducationalTable = [...this.listOfEducationalTable, myNewElement];
        console.log("this.listOfEducationalTableaddRow===>" + this.listOfEducationalTable);
    }

    @track deleteConatctIds = '';
    removeTheRowEducational(event) {
        console.log("Remove clicked ")
        if(isNaN(event.target.dataset.id)){
            this.deleteConatctIds = this.deleteConatctIds + ',' + event.target.dataset.id;
        }
        this.listOfEducationalTable.splice(this.listOfEducationalTable.findIndex(row => row.Id === event.target.dataset.id), 1);
        console.log("row.Id remove row==> " + row.Id)
        console.log("event.target.dataset.id remove row==> " + event.target.dataset.id)

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
            console.log(event.target.value);
            this.leadSalutation = event.target.value;
            console.log("this.leadSalutation====  " + this.leadSalutation);
        }   
        if (event.target.name == "firstName") {
            console.log(event.target.value);
            this.leadFirstName = event.target.value;
            console.log("this.leadFirstName====  " + this.leadFirstName);
        }
        if (event.target.name == "LastName1" ) {
            this.leadLastName = event.target.value;
            console.log("this.leadLastName====  " + this.leadLastName);
        }
        if (event.target.name == "middleName" && event.target.value != "") {
            this.leadMiddleName = event.target.value;
            console.log("this.leadMiddleName====  " + this.leadMiddleName);
        }
        if (event.target.name == "Email") {
            this.leadEmail = event.target.value;
            console.log("this.leadEmail====  " + this.leadEmail);
        }
        if (event.target.name == "MotherFirstName") {
            this.AppliMotherFirstName = event.target.value;
            console.log("this.AppliMotherFirstName====  " + this.AppliMotherFirstName);
        }   
        if (event.target.name == "MotherMiddleName" && event.target.value != "") {
            this.AppliMotherMiddleName = event.target.value;
            console.log("this.AppliMotherMiddleName====  " + this.AppliMotherMiddleName);
        }                 
        if (event.target.name == "MotherLastName" && event.target.value != "") {
            this.AppliMotherLastName = event.target.value;
            console.log("this.AppliMotherLastName====  " + this.AppliMotherLastName);
        }
        if (event.target.name == "Date of Birth" && event.target.value != "") {
            this.AppliDOB = event.target.value;
            console.log("this.AppliDOB====  " + this.AppliDOB);
        }
        if (event.target.name == "AadharNumber" && event.target.value != "") {
            this.LAadharNumber = event.target.value;
            console.log("this.LAadharNumber====  " + this.LAadharNumber);
        }    
        if (event.target.name == "Gender" && event.target.value != "") {
            this.AppliGender = event.target.value;
            console.log("this.AppliGender====  " + this.AppliGender);
        }
        if (event.target.name == "Mobile" ) {
            this.leadMobile = event.target.value;
            console.log("this.leadMobile====  " + this.leadMobile);
        }
        if (event.target.name == "FatherFirstName" ) {
            this.AppliFatherFirstName = event.target.value;
            console.log("this.AppliFatherFirstName====  " + this.AppliFatherFirstName);
        } 
        if (event.target.name == "FatherMiddleName" && event.target.value != "") {
            this.AppliFatherMiddleName = event.target.value;
            console.log("this.AppliFatherMiddleName====  " + this.AppliFatherMiddleName);
        } 
        if (event.target.name == "FatherLastName" && event.target.value != "") {
            this.AppliFatherLastName = event.target.value;
            console.log("this.AppliFatherLastName====  " + this.AppliFatherLastName);
        }
        if (event.target.name == "SpouseFirstName") {
            this.AppliSpouseFirstName = event.target.value;
            console.log("this.AppliSpouseFirstName====  " + this.AppliSpouseFirstName);
        }
        if (event.target.name == "SpouseMiddleName" && event.target.value != "") {
            this.AppliSpouseMiddleName = event.target.value;
            console.log("this.AppliSpouseMiddleName====  " + this.AppliSpouseMiddleName);
        }
        if (event.target.name == "SpouseLastName" && event.target.value != "") {
            this.AppliSpouseLastName = event.target.value;
            console.log("this.AppliSpouseLastName====  " + this.AppliSpouseLastName);
        }  
        if (event.target.name == "PANNumber" && event.target.value != "") {
            this.PANNumber = event.target.value;
            console.log("this.PANNumber====  " + this.PANNumber);
        }  
        if (event.target.name == "ckycNumber" && event.target.value != "") {
            this.ckycNumber = event.target.value;
            console.log("this.ckycNumber====  " + this.ckycNumber);
        }   
        if (event.target.name == "voterId" && event.target.value != "") {
            this.voterId = event.target.value;
            console.log("this.voterId====  " + this.voterId);
        }   
        if (event.target.name == "passportNumber" && event.target.value != "") {
            this.passportNumber = event.target.value;
            console.log("this.passportNumber====  " + this.passportNumber);
        }   
        if (event.target.name == "Is Income Considered/Is Financial" && event.target.value != "") {
            this.AppliIsIncomeConsiderIsFin = event.target.value;
            console.log("this.AppliIsIncomeConsiderIsFin====  " + this.AppliIsIncomeConsiderIsFin);
        }
        if (event.target.name == "appliCurrentAddProof") {
            this.AppliCurrentAddProof = event.target.value;
            console.log("this.AppliCurrentAddProof====  " + this.AppliCurrentAddProof);
        }   
        if (event.target.name == "ApplicurrentAddress") {
            this.AppliCurrentAddress = event.target.value;
            console.log("this.ApplicurrentAddress====  " + this.AppliCurrentAddress);
        }   
        if (event.target.name == "appliCurrentCity") {
            this.AppliCurrentCity = event.target.value;
            console.log("this.AppliCurrentCity====  " + this.AppliCurrentCity);
        }  
        if (event.target.name == "appliCurrentTaluka") {
            this.AppliCurrentTaluka = event.target.value;
            console.log("this.AppliCurrentTaluka====  " + this.AppliCurrentTaluka);
        }   
         if (event.target.name == "appliCurrentDistrict" && event.target.value != "") {
             this.AppliCurrentDistrict = event.target.value;
             console.log("this.AppliCurrentDistrict====  " + this.AppliCurrentDistrict);
         }   
        if (event.target.name == "appliCurrentPincode") {
            this.AppliCurrentPincode = event.target.value;
            console.log("this.AppliCurrentPincode====  " + this.AppliCurrentPincode);
        }   
        if (event.target.name == "appliCurrentLandmark") {
            this.AppliCurrentLandmark = event.target.value;
            console.log("this.AppliCurrentLandmark====  " + this.AppliCurrentLandmark);
        }   
        if (event.target.name == "appliCurrentState" ) {
            this.AppliCurrentState = event.target.value;
            console.log("this.AppliCurrentState====  " + this.AppliCurrentState);
        }   
        if (event.target.name == "appliCurrentCountry" ) {
            this.AppliCurrentCountry = event.target.value.toUpperCase();
            console.log("this.AppliCurrentCountry====  " + this.AppliCurrentCountry);
        }   
        if (event.target.name == "appliPermanentAddressProof") {
            this.AppliPermanentAddProof = event.target.value;
            console.log("this.AppliPermanentAddProof====  " + this.AppliPermanentAddProof);
        }  
        if (event.target.name == "permanentAddress") {
            this.AppliPermanentAddress = event.target.value;
            console.log("this.AppliPermanentAddress====  " + this.AppliPermanentAddress);
        }   
        if (event.target.name == "appliPermanentCity" ) {
            this.AppliPermanentCity = event.target.value;
            console.log("this.AppliPermanentCity====  " + this.AppliPermanentCity);
        }   
        if (event.target.name == "appliPermanentTaluka" ) {
            this.AppliPermanentTaluka = event.target.value;
            console.log("this.AppliPermanentTaluka====  " + this.AppliPermanentTaluka);
        }   
        if (event.target.name == "appliPermanentDistrict" ) {
            this.AppliPermanentDistrict = event.target.value;
            console.log("this.AppliPermanentDistrict====  " + this.AppliPermanentDistrict);
        }   
        if (event.target.name == "appliPermanentPincode" ) {
            this.AppliPermanentPincode = event.target.value;
            console.log("this.AppliPermanentPincode====  " + this.AppliPermanentPincode);
        }   
        if (event.target.name == "appliPermanentLandmark" ) {
            this.AppliPermanentLandmark = event.target.value;
            console.log("this.AppliPermanentLandmark====  " + this.AppliPermanentLandmark);
        }   
        if (event.target.name == "appliPermanentState" ) {
            this.AppliPermanentState = event.target.value;
            console.log("this.AppliPermanentState====  " + this.AppliPermanentState);
        }   
        if (event.target.name == "appliPermanentCountry" ) {
            this.AppliPermanentCountry = event.target.value.toUpperCase();
            console.log("this.AppliPermanentCountry====  " + this.AppliPermanentCountry);
        }   
        if (event.target.name == "Country of Study" && event.target.value != "") {
            this.CountryOfStudyValue = event.target.value;
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
        if (event.target.name == "courseName" && event.target.value != "") {
            this.courseName = event.target.value;
            console.log("this.courseName====  " + this.courseName);
        }
        if (event.target.name == "Campus" && event.target.value != "") {
            this.courseCampus = event.target.value;
            console.log("this.courseCampus====  " + this.courseCampus);
        }
        if (event.target.name == "Course Category" && event.target.value != "") {
            this.CourseCategoryValue = event.target.value;
            console.log("this.CourseCategoryValue====  " + this.CourseCategoryValue);
        }
        if (event.target.name == "Course Type" && event.target.value != "") {
            this.CourseTypeValue = event.target.value;
            console.log("this.CourseTypeValue====  " + this.CourseTypeValue);
        }
        if (event.target.name == "Course Level" && event.target.value != "") {
            this.CourseLevelValue = event.target.value;
            console.log("this.CourseLevelValue====  " + this.CourseLevelValue);
        }
        if (event.target.name == "Course Stream" && event.target.value != "") {
            this.CourseStreamValue = event.target.value;
            console.log("this.CourseStreamValue====  " + this.CourseStreamValue);
        }
        if (event.target.name == "courseStartDate" && event.target.value != "") {
            this.courseStartDate = event.target.value;
            console.log("this.courseStartDate====  " + this.courseStartDate);
        }
        if (event.target.name == "courseEndDate" && event.target.value != "") {
            this.courseEndDate = event.target.value;
            console.log("this.courseEndDate====  " + this.courseEndDate);
        }
        if (event.target.name == "Language Score Category" && event.target.value != "") {
            this.LangScoreCategoryValue = event.target.value;
            console.log("this.LangScoreCategoryValue====  " + this.LangScoreCategoryValue);
        }
        if (event.target.name == "langTestScore" && event.target.value != "") {
            this.langTestScore = event.target.value;
            console.log("this.langTestScore====  " + this.langTestScore);
        }
        if (event.target.name == "Analytics Score Category" && event.target.value != "") {
            this.AnalytScoreCategoryValue = event.target.value;
            console.log("this.AnalytScoreCategoryValue====  " + this.AnalytScoreCategoryValue);
        }
        if (event.target.name == "analyticalTestScore" && event.target.value != "") {
            this.analyticalTestScore = event.target.value;
            console.log("this.analyticalTestScore====  " + this.analyticalTestScore);
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
   
     //update table row values in list
     updateValues(event){
        console.log('this.listOfEducationalTable valuessss===>' + JSON.stringify(this.listOfEducationalTable));
        var foundelement = this.listOfEducationalTable.find(ele => ele.Id == event.target.dataset.id);
        console.log('foundelement' + JSON.stringify(foundelement));
        if(event.target.name === 'EducationDetails'){
            foundelement.Education_Qualification__c = event.target.value;
           // console.log('foundelement.Education_Qualification__c' + foundelement.Education_Qualification__c);
        } else if(event.target.name === 'YearCompleted'){
            foundelement.Year_Completed__c = event.target.value;
           // console.log('foundelement.Year_Completed__c' + foundelement.Year_Completed__c);
        } else if(event.target.name === 'PercentageMarks'){
            foundelement.Percentage_Marks_CGPA__c = event.target.value;
          //  console.log('foundelement.Percentage_Marks_CGPA__c' + foundelement.Percentage_Marks_CGPA__c);
        } else if(event.target.name === 'SchoolCollegeUniversity'){
            foundelement.School_College_University__c = event.target.value;
          //  console.log('foundelement.School_College_University__c' + foundelement.School_College_University__c);
        }
    }

    handleCoappliAcc(event) {  
        let index = event.target.dataset.id;
        console.log('event.target' + event.target);
        console.log('Index' + index);
        let fieldName = event.target.name;
        let value = event.target.value;
        console.log('value' + value);
        console.log('fieldName' + fieldName);
        console.log('this.listOfCoappliAccTable[index][fieldName]' + JSON.stringify(this.listOfCoappliAccTable[index - 1]));
        this.listOfCoappliAccTable[index - 1][fieldName] = value;
        console.log('this.listOfCoappliAccTable[index][fieldName]' + this.listOfCoappliAccTable[index - 1][fieldName]);
    }
   
    handleSave() {
         this.isLoading = true;
        if (this.LLastName != null && this.LLastName != null && this.LEmail != null && this.LMobile != null &&
            this.LMotherName != null && this.LMotherLastName != null && this.LDateOfBirth != null && this.LGender != null && this.LAadharNumber != null) {
            const { base64Front, filenameFront } = this.fileDataFront
            const { base64Back, filenameBack } = this.fileDataBack
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
                base64Front: base64Front,
                filenameFront: filenameFront,
                base64Back: base64Back,
                filenameBack: filenameBack,
                personAccStr: JSON.stringify(this.listOfCoappliAccTable),
            }

            creatLeadRecord({
                wrapperDetails : JSON.stringify(wrapperAllRecord)
            })
                .then(response => {
                    this.initData();
                    this.newToast('Success', "Application has been submitted successfully.", 'success');
                    this.salutation = "";
                    this.LfNName = "";
                    this.middleName = "";
                    this.LLastName = "";
                    this.LEmail = "";
                    this.LMobile = "";
                    this.LMotherName = "";
                    this.LMotherMiddleName = "";
                    this.LMotherLastName = "";
                    this.maritalStatus ="";
                    this.LDateOfBirth = "";
                    this.LGender = "";
                    this.LAadharNumber = "";
                    this.FatherFirstName = "";
                    this.FatherMiddleName = "";
                    this.FatherLastName = "";
                    this.SpouseFirstName = "";
                    this.SpouseMiddleName = "";
                    this.SpouseLastName = "";
                    this.PANNumber = "";
                    this.ckycNumber = "";
                    this.driveLicenseNumber = "";
                    this.voterId = "";
                    this.passportNumber = "";
                    this.appliCurrentAddType = "";
                    this.appliCurrentAddProof = "";
                    this.ApplicurrentAddress = "";
                    this.appliCurrentCity = "";
                    this.appliCurrentTaluka = "";
                   // this.appliCurrentDistrict = "";
                    this.appliCurrentPincode = "";
                    this.appliCurrentLandmark = "";
                    this.appliCurrentState = "";
                    this.appliCurrentCountry = "";
                    this.appliPermanentAddType = "";
                    this.appliPermanentAddProof = "";
                    this.permanentAddress = "";
                    this.appliPermanentCity = "";
                    this.appliPermanentTaluka = "";
                    this.appliPermanentDistrict = "";
                    this.appliPermanentPincode = "";
                    this.appliPermanentLandmark = "";
                    this.appliPermanentState = "";
                    this.appliPermanentCountry = "";
                    this.CountryOfStudyValue = "";
                    this.AdmissionStatus = "";
                    this.universityName = "";
                    this.InstituteId = "";                       
                    this.courseTel = "";
                    this.URLWeb = "";
                    this.contPersonInstitute = "";
                    this.contPersonNum = "";
                    this.contPersonEmail = "";
                    this.courseName = "";
                    this.CourseCategoryValue = "";
                    this.CourseTypeValue = "";
                    this.CourseStreamValue = "";    
                    this.courseStartDate = "";
                    this.courseEndDate = ""; 
                    this.LangScoreCategoryValue = "";
                    this.langTestScore = "";
                    this.AnalytScoreCategoryValue = "";
                    this.analyticalTestScore = "";                  
                    this.instAdderess = "";
                    this.instCity = "";
                    this.instState = "";
                    this.instCountry = "";
                    this.instPINCode = "";
                    this.InstituteId = "";
                    this.value = "";
                    this.fileDataFront = "";
                    this.fileDataBack = "";
                    console.log(response);
                    this.isLoading = false;
                }).catch(error => {
                    this.isLoading = false;
                     this.newToast('Error', 'An Unexpected Error Occured', error);
                })
        }
        else {
            this.isLoading = false;
            this.newToast('Error', "Please enter all required fields.", error);
            
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

    AppliCategoryvalue = '';

    get AppliCategoryOptions() {
        return [
            { label: 'Co-applicant', value: 'Co-applicant' },
            { label: 'Guarantor', value: 'Guarantor' },
        ];
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

    handleCoAppliCurrentPincode(event){
        if (event.target.name == "City__c" && event.target.value != "") {
            this.City__c = event.target.value;
            console.log("this.City__c checking value=====  " + this.City__c);
        } 
         
        this.AreaPinCode = event.target.value;
        console.log('result'+this.AreaPinCode);
        getPincodeRecord({ pincode: this.AreaPinCode }) //this parameter is passed to Class-CommunityLeadFormController.getPincodeRecord
            .then(result => {
                console.log('In pincode section',JSON.stringify(result));
                this.AreaPinCodeResult = result;
                
                console.log('pincodeResult=======> ' + JSON.stringify(this.AreaPinCodeResult));
                this.Pin_Code__c = this.AreaPinCodeResult.Id;
                console.log('Pin_Code__c=======> ' + this.Pin_Code__c);
                this.City__c = this.AreaPinCodeResult.City_Name__c;
                console.log('errthis.City__cors=======> ' + this.City__c);
            })
            .catch(error => {
                this.errors = error;
                console.log('errorsCoappli=======> ' + this.errors);
            });
    }

   
    @track listOfApplicants;
    
     @wire(getCoAppRecords, {})
    getCoapp({ error, data }) {
    
     console.log('getCoapp====>' + JSON.stringify(data));
     if (data) {
    //debugger;
    console.log('data inside If' + data);
    let checks = data[0].objeAcc;
    console.log('checks' + JSON.stringify(checks));
  this.listOfApplicants = JSON.parse((JSON.stringify(data)));
    console.log('this.listOfApplicants data' + JSON.stringify(this.listOfApplicants));
    
    
    }
    }
    

  //  @track listOfCoappliAcc;
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
            //    let listOfEducationalTable = [];
             //   this.addRow(listOfEducationalTable);
             let randomId = Math.random() * 16;
                let myNewElement = { Id: randomId,Education_Qualification__c: "", Year_Completed__c: "", Percentage_Marks_CGPA__c: "",School_College_University__c: ""};
                console.log("myNewElement===>" + myNewElement);        
                this.listOfEducationalTable = [myNewElement];
                console.log("this.listOfEducationalTable===>" + this.listOfEducationalTable); 
                //this.listOfEducationalTable = listOfEducationalTable;
            }
            //this.listOfEducationalTable  = JSON.parse(JSON.stringify(this.wrapperForCommLeadForm.AppliEduDetailsRecord)); 
            console.log('this.listOfEducationalTable data' + JSON.stringify(this.listOfEducationalTable));

         //   this.listOfCoappliAccTable = this.wrapperForCommLeadForm.AccCoAppliRecords;
            console.log('this.listOfCoappliAccTable data' + JSON.stringify(this.listOfCoappliAccTable));

            this.error = error;   
            console.log('eRRORR' +JSON.stringify(error));
            console.log('eRROR5555R' +JSON.stringify(this.error));
  
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


}