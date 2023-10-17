import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import getPincodeRecord from '@salesforce/apex/LoanApplicationFormHelper.getPincodeRecord';
import getCoAppRecords from '@salesforce/apex/LeadCoapplicantEmploymentController.getCoapp';
import saveCoApplicant from '@salesforce/apex/LeadCoapplicantEmploymentController.saveCoApplicant';
import deleteCoApplicant from '@salesforce/apex/LeadCoapplicantEmploymentController.deleteCoApplicant';
import getApplicantAccoutId from '@salesforce/apex/LeadCoapplicantEmploymentController.getAccountIdFromCoApplicant';
import updateLeadTotalPercentage from '@salesforce/apex/DocumentVerification.updateLeadTotalPercentage';
import duplicateAccount from '@salesforce/apex/LeadCoapplicantEmploymentController.duplicateAccount';
import getSectionWeightage from '@salesforce/apex/LoanApplicationFormHelper.getSectionWeightage';
import getCheck from '@salesforce/apex/LeadCoapplicantEmploymentController.getCheck';
import updateCheck from '@salesforce/apex/LeadCoapplicantEmploymentController.updateCheck';
import Account from '@salesforce/schema/Account';
import Applicant from '@salesforce/schema/Co_Applicant__c';
import Address from '@salesforce/schema/ContactPointAddress';
import Marital_Status from '@salesforce/schema/Account.Marital_Status__c';
import Gender from '@salesforce/schema/Account.Gender__c';
import SALUTATION from '@salesforce/schema/Account.Salutation';
import DEMOGRAPHY from '@salesforce/schema/Demography__c';
import FATHER_SALUTATION from '@salesforce/schema/Demography__c.F_TITLE__c'; 
import MOTHER_SALUTATION from '@salesforce/schema/Demography__c.M_TITLE__c'; 
import Relation_with_applicant from '@salesforce/schema/Co_Applicant__c.Relation_with_applicant__c';
import Relation_proof from '@salesforce/schema/Co_Applicant__c.Relationship_Proof__c';
import Is_income from '@salesforce/schema/Co_Applicant__c.Is_Income_Considered_Financial__c';
import Address_Proof from '@salesforce/schema/ContactPointAddress.Address_Proof__c';
import Education_Qualification from '@salesforce/schema/Co_Applicant__c.QUALIFICATION__c';
import KarzaKycOcr from '@salesforce/apex/KarzaKycOcrController.getDocumentOcred';
import checkPinCodeAvailable from '@salesforce/apex/LeadCoapplicantEmploymentController.checkPinCodeAvailable';
import getPin from '@salesforce/apex/LeadApplicantDetails.getPin';
import updateKYCAccount from '@salesforce/apex/KarzaKycOcrController.updateKYCAccount';//Added by Rohit
import progressBar from '@salesforce/messageChannel/progressBar__c';
import SUBMITACTION from '@salesforce/messageChannel/submit__c';
import { publish, MessageContext } from 'lightning/messageService';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import ProfileName from '@salesforce/schema/User.Profile.Name';
import getApplicantEmailAndMobile from '@salesforce/apex/LeadCoapplicantEmploymentController.getApplicantEmailAndMobile';
import OtpRequest from '@salesforce/apex/EmailVerification.OtpRequest';
import OtpRequestMob from '@salesforce/apex/MobileVerification.OtpRequest';
import OtpVerify from '@salesforce/apex/EmailVerification.verify';
import OtpVerifyMob from '@salesforce/apex/MobileVerification.OtpVerify';
import updateCoapplicantRec from '@salesforce/apex/LeadApplicantDetails.updateEmailAndMobileVerified';// Added by Rohit 
import getQuestion from '@salesforce/apex/LeadCoapplicantEmploymentController.getQuestionFromLead';// Added by Rohit 
import updateQuestion from '@salesforce/apex/LeadCoapplicantEmploymentController.updateQuestionOnLead';// Added by Rohit 
export default class CoapplicantGuarantorChild extends LightningElement {
    @api leadRecordId;
    @api getApplicantMobile;
    @api getApplicantEmail;
    @track todaysDate;
    @track isStepOne = true;
    @track isLoading = false;
    @track currentStep = "1";
    activeSections = [''];
    @track ShowDemography;
    @track showButtonAadhar = false;
    @track ShowFieldsAppliSpouse = false;
    @track ShowFieldsApplicantCategory = false;
    @track ShowFieldsRelationWithAppliIfOther = false;
    @track ShowFieldsAppliDriveLicDateofExpiry = false;
    @track ShowFieldsCoAppliDriveLicDateofExpiry = false;
    @track LAadharNumber;
    @track PANNumber;
    @track passportNumber;
    @track passportFileNumber;
    @track driveLicenseNumber;
    @track voterId;
    @track LDateOfBirth;
    @track aadharLastFour = '';
    @track makeadhardisable = false;
    @track makepandisable = false;
    @track makedobdisable = false;
    @track makepassportdisable = false;
    @track makevoteriddisable = false;
    @track makedrivingdisable = false;
    @track duplicateAccountResult;
    @track makenamedisable = false;
    @track makeGenderdisable = false;
    @track makemiddlenamedisable = false;
    @track makelastnamedisable = false;
    @track errorMsgForDuplicate = false;
    @track makeCKYCdisable = false;
    @track makeNREGdisable = false;
    @track applicantAccountId;
    @track applicantMobileNumber;
    @track applicantEmail;
    @track firstnamenotvalid = false;
    @track middlenamenotvalid = false;
    @track lastnamenotvalid = false;
    @track pannotvalid = false;
    @track errorAadharInvalid = false;
    @track errorPanInvalid = false;
    @track errorDLInvalid = false;
    @track errorPassportInvalid = false;
    @track errorPasspostFilrInvalid = false;
    @track errorVoterIdInvalid = false;
    @track hideBasicSection = false;
    @track errorCKYCInvalid = false;
    @track errorNREGInvalid = false;
    @track testhidesavebutton = false;
    @track saleserrorAadharInvalid = false;
    @track salessmakeadhardisable = false;
    @track SalesLAadharNumber;
    @track isSalesUser = false;
    @track deleteAccId = '';
    @track showReAadharButton = false;
    @track panTemplate = false;
    @track makePermanentAddProofdisabled = false;
    @track coapplicantCheck = false;
    @track listOfAccounts;
    timeSpan = 60000;
    event1;
    @wire(MessageContext)
    messageContext;
    message;
    userId = Id;
    userProfileName;
    get recordTypeIdPA() {
        const rtis = this.objectInfo.data.recordTypeInfos;
        return Object.keys(rtis).find(rti => rtis[rti].name === 'Person Account');
    }

    @wire(getObjectInfo, { objectApiName: Account })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Marital_Status })
    MaritalStatusPerAccOptions;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Gender })
    GenderPerAccOptions;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: SALUTATION })
    SalutationPerAccOptions;

    @wire(getObjectInfo, { objectApiName: DEMOGRAPHY })
    DemographyObj;   
   
    @wire(getPicklistValues, { recordTypeId: '$DemographyObj.data.defaultRecordTypeId', fieldApiName: FATHER_SALUTATION })
    FatherSalutationOptions;  
    
    @wire(getPicklistValues, { recordTypeId: '$DemographyObj.data.defaultRecordTypeId', fieldApiName: MOTHER_SALUTATION })
    MotherSalutationOptions;

    @wire(getObjectInfo, { objectApiName: Applicant })
    objectInfoApp;

    @wire(getPicklistValues, { recordTypeId: '$objectInfoApp.data.defaultRecordTypeId', fieldApiName: Relation_with_applicant })
    RelshipWithAppliPerAccOptions;

    @wire(getPicklistValues, { recordTypeId: '$objectInfoApp.data.defaultRecordTypeId', fieldApiName: Relation_proof })
    RelshipProofPerAccOptions;

    @wire(getPicklistValues, { recordTypeId: '$objectInfoApp.data.defaultRecordTypeId', fieldApiName: Is_income })
    isIncomeConsiderIsFinOptions;
    
    @wire(getPicklistValues, { recordTypeId: '$objectInfoApp.data.defaultRecordTypeId', fieldApiName: Education_Qualification })
    educationQualificationOptions;

    @wire(getObjectInfo, { objectApiName: Address })
    objectInfoAdd;

    @wire(getPicklistValues, { recordTypeId: '$objectInfoAdd.data.defaultRecordTypeId', fieldApiName: Address_Proof })
    AddProofCurrentPerAccOptions;

    @api objectNamequestion = 'Lead';
    @api recordTypeId2;
    @api QuestionDetailsField = 'Why_Mother_Father_are_not_Co_Applicants__c';
    @track QuestionDetailsLabel;
    @track coapplicantquestionOptions;
    apiQuestionDetails;
    
    @wire(getObjectInfo, { objectApiName: '$objectNamequestion' })
    getObjectData3({ error, data }) {
        if (data) {
            if (this.recordTypeId2 == null)
                this.recordTypeId2 = data.defaultRecordTypeId;
            this.apiQuestionDetails = this.objectNamequestion + '.' + this.QuestionDetailsField;
            this.QuestionDetailsLabel = data.fields[this.QuestionDetailsField].label;
        } else if (error) {
        }
    }
    
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId2', fieldApiName: '$apiQuestionDetails' })
    getPicklistValues0001({ error, data }) {
        if (data) {
            this.coapplicantquestionOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };
            });
        } else if (error) {
        }
    }
    
    @wire(getRecord, { recordId: Id, fields: [ProfileName] })
    userDetails({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            if (data.fields.Profile.value != null) {
                this.userProfileName = data.fields.Profile.value.fields.Name.value;
                if (this.userProfileName == 'Sales Profile') {
                    this.isSalesUser = false;
                } else {
                    this.isSalesUser = false;
                }
            }
        }
    }
    connectedCallback() {
        this.QuestionFromLead();
        this.initData();
        this.getApplicant();
        this.getEmailAndMobile();
        this.todaysDate = new Date().toISOString().split('T')[0];
    }
    QuestionFromLead(){
        getQuestion({ leadId: this.leadRecordId })
        .then(result => {
            if(result.Why_Mother_Father_are_not_Co_Applicants__c != undefined){
                this.hideshowQuestion = true;
                this.QuesForcoapplicant = result.Why_Mother_Father_are_not_Co_Applicants__c;
                if(result.Other_Reason__c != undefined){
                    this.hideshowotherreason = true;
                    this.otherReason = result.Other_Reason__c;
                }
            }
        })
    }
    initData() {
        getCoAppRecords({ leadId: this.leadRecordId })
            .then(result => {
                let randomId = Math.random() * 16;
                if (result.length > 0) {
                    this.listOfAccounts = JSON.parse(JSON.stringify(result));
                    var salesUserValue = this.isSalesUser;
                    this.setCoApplicantRecord(this.listOfAccounts);
                } else {
                    let myNewElement = {
                        "appCurrentAdd": {
                            "Account__c": "", "Id": randomId, "Name": "", "Address_Type__c": "",
                            "Address_Proof__c": "", "Address_1__c": "", "Pin_Code__c": "", "City__c": "", "Taluka__c": "", "District__c": "",
                            "Landmark__c": "", "State__c": "", "Country__c": "", "Years_In_The_Address__c": "", "Same_as_Current_Address__c": ""
                        }, "appPermanentAdd":
                        {
                            "Account__c": "", "Id": randomId, "Name": "", "Address_Type__c": "", "Address_Proof__c": "",
                            "Address_1__c": "", "Pin_Code__c": "", "City__c": "", "Taluka__c": "", "District__c": "", "Landmark__c": "", "State__c": "",
                            "Country__c": "", "Years_In_The_Address__c": "", "Same_as_Current_Address__c": false
                        }, "objApplicant": {
                            "Id": randomId, "Account__c": "",
                            "Name": "", "Type__c": "", "Relation_with_applicant__c": "", "Is_Income_Considered_Financial__c": "",
                            "Relationship_Proof__c": ""
                        }, "objeAcc": {
                            "Id": randomId, "Salutation": "",
                            "FirstName": "", "MiddleName": "", "LastName": "", "Date_of_Birth__c": "", "Mobile_Abroad__c": "", "PersonMobilePhone": "", "PersonEmail": "",
                            "Gender__c": "", "Marital_Status__c": "", "Passport_Number__c": "", "Aadhar_Number__c": "", "PAN_Number__c": "",
                            "Driving_License_Number__c": "", "Passport_File_Number__c": "", "Passport_Number__c": ""
                        }, "appDemography": { "Id": randomId, "Account__c": "", "F_TITLE__c":"","M_TITLE__c":"","Father_s_First_Name__c": "", "Mother_s_First_Name__c": "" }
                    };
                    this.listOfAccounts = [myNewElement];
                }
            }).catch(error => {
            });

        getCheck({ leadId: this.leadRecordId })
            .then(result => {
                this.coapplicantCheck = result.Co_applicant_Section__c;
            })
    }
    getApplicant() {
        getApplicantAccoutId({ leadId: this.leadRecordId })
            .then(result => {
                if (result.length > 0) {
                    this.applicantAccountId = result;
                }
            })
            .catch(error => {
            });
    }
    getEmailAndMobile() {
        getApplicantEmailAndMobile({ leadId: this.leadRecordId })
            .then(result => {
                if (result != null) {
                    if (result.PersonMobilePhone != undefined) {
                        this.applicantMobileNumber = result.PersonMobilePhone;
                    }
                    if (result.PersonEmail != undefined) {
                        this.applicantEmail = result.PersonEmail;
                    }
                }
            })
            .catch(error => {
            });
    }
    handlePinCode(event) {
        var foundelement = this.listOfAccounts.find(ele => ele.appCurrentAdd.Id == event.target.dataset.id);
        if (event.target.value == '') {
            foundelement.appCurrentAdd.Pin_Code__c = '';
            foundelement.appCurrentAdd.City__c = '';
            foundelement.appCurrentAdd.District__c = '';
            foundelement.appCurrentAdd.State__c = '';
            foundelement.appCurrentAdd.Country__c = '';
        }else {
            getPincodeRecord({ pincode: event.target.value })
                .then(result => {
                    foundelement.appCurrentAdd.Pin_Code__c = result.Id;
                    foundelement.appCurrentAdd.City__c = result.City_Name__c;
                    foundelement.appCurrentAdd.District__c = result.Area_Name_Taluka__c;
                    foundelement.appCurrentAdd.State__c = result.State__c;
                    foundelement.appCurrentAdd.Country__c = result.Country__c;
                })
                .catch(error => {
                })
        }
    }
    handlePinCode1(event) {
        var foundelement = this.listOfAccounts.find(ele => ele.appPermanentAdd.Id == event.target.dataset.id);
        if (event.target.value == '') {
            foundelement.appPermanentAdd.Pin_Code__c = '';
            foundelement.appPermanentAdd.City__c = '';
            foundelement.appPermanentAdd.District__c = '';
            foundelement.appPermanentAdd.State__c = '';
            foundelement.appPermanentAdd.Country__c = '';
        }else {
            getPincodeRecord({ pincode: event.target.value })
                .then(result => {
                    foundelement.appPermanentAdd.Pin_Code__c = result.Id;
                    foundelement.appPermanentAdd.City__c = result.City_Name__c;
                    foundelement.appPermanentAdd.District__c = result.Area_Name_Taluka__c;
                    foundelement.appPermanentAdd.State__c = result.State__c;
                    foundelement.appPermanentAdd.Country__c = result.Country__c;
                })
                .catch(error => {
                })
        }
    }
    createRow(listOfAccounts) {
        let randomId = Math.random() * 16;
        let myNewElement = {
            "appCurrentAdd": {
                "Account__c": "", "Id": randomId, "Name": "", "Address_Type__c": "",
                "Address_Proof__c": "", "Address_1__c": "", "Pin_Code__c": "", "City__c": "", "Taluka__c": "", "District__c": "",
                "Landmark__c": "", "State__c": "", "Country__c": "", "Years_In_The_Address__c": "", "Same_as_Current_Address__c": ""
            }, "appPermanentAdd":
            {
                "Account__c": "", "Id": randomId, "Name": "", "Address_Type__c": "", "Address_Proof__c": "",
                "Address_1__c": "", "Pin_Code__c": "", "City__c": "", "Taluka__c": "", "District__c": "", "Landmark__c": "", "State__c": "",
                "Country__c": "", "Years_In_The_Address__c": "", "Same_as_Current_Address__c": false
            }, "objApplicant": {
                "Id": randomId, "Account__c": "",
                "Name": "", "Type__c": "", "Relation_with_applicant__c": "", "Is_Income_Considered_Financial__c": "",
                "Relationship_Proof__c": ""
            }, "objeAcc": {
                "Id": randomId, "Salutation": "",
                "FirstName": "", "MiddleName": "", "LastName": "", "Date_of_Birth__c": "", "Mobile_Abroad__c": "", "PersonMobilePhone": "", "PersonEmail": "",
                "Gender__c": "", "Marital_Status__c": "", "Passport_Number__c": "", "Aadhar_Number__c": "", "PAN_Number__c": "",
                "Driving_License_Number__c": "", "Passport_File_Number__c": ""
            }, "appDemography": { "Id": randomId, "Account__c": "", "F_TITLE__c":"","M_TITLE__c":"","Father_s_First_Name__c": "", "Mother_s_First_Name__c": "" }
        };
        this.listOfAccounts = [...this.listOfAccounts, myNewElement];
    }
    addNewRow() {
        this.createRow(this.listOfAccounts);
        this.buttonStyleAadhar = "display:none";
        this.aadharInputStyle = "display:none";
        this.buttonStylePan = "display:none";
    }
    removeTheRow(event) {
        if (isNaN(event.target.dataset.id)) {
            this.deleteAccId = this.deleteAccId + event.target.dataset.id;
        }
        if (this.listOfAccounts.length > 1) {
            this.listOfAccounts.splice(this.listOfAccounts.findIndex(row => row.objeAcc.Id == event.target.dataset.id), 1);
            this.isLoading = true;
            if (this.deleteAccId != '') {
                deleteCoApplicant({ accId: this.deleteAccId, leadId: this.leadRecordId })
                    .then(result => {
                        this.isLoading = false;
                        this.showToast("Success!!", 'Deleted Successfully', "Success")
                        if (result.length > 0) {
                            this.listOfAccounts = JSON.parse(JSON.stringify(result));
                            this.setCoApplicantRecord(this.listOfAccounts);
                        }
                    })
                    .catch(error => {
                        this.isLoading = false;
                    })
            }else {
                this.isLoading = false; //Added by Rohit 24/05/2023
                this.showToast("Success!!", 'Deleted Successfully', "Success")
            }
        }
        this.deleteAccId = '';
    }
    handleOnBlurMobilechange(event){
        var foundelement = this.listOfAccounts.find(ele => ele.objeAcc.Id == event.target.dataset.id);
        if (event.target.name === 'PersonMobilePhone') {
            let fieldValue = event.target.value;
            let pattern = /[0-9]{10}$/;
            if (this.applicantMobileNumber == event.target.value && pattern.test(fieldValue)) {
                this.showToast("Error!!", "Co-applicant or Guarantor Mobile Number cannot be same as applicant", "Error")
                foundelement.objeAcc.PersonMobilePhone = null;
                foundelement.objeAcc.buttonStyleMob = 'display:none';
            }
        }
        else if (event.target.name === 'PersonEmail') {
            let fieldValue = event.target.value;
            let pattern = /[A-Za-z0-9._-]+@[a-z0-9]+\.[a-z]{2,}$/;
            if (this.applicantEmail == event.target.value && pattern.test(fieldValue)) {
                this.showToast("Error!!", "Co-applicant or Guarantor Email cannot be same as applicant", "Error")
                foundelement.objeAcc.PersonEmail = null;
                foundelement.objeAcc.buttonStyle = 'display:none';
            }
        }
    }
    handlechangeAccount(event) {
        var foundelement = this.listOfAccounts.find(ele => ele.objeAcc.Id == event.target.dataset.id);
        if (event.target.name === 'Salutation') {            
                foundelement.objeAcc.Salutation = event.target.value;                
        }
        else if (event.target.name === 'FirstName') {           
                foundelement.objeAcc.FirstName = event.target.value;               
        }else if (event.target.name === 'MiddleName') {
                 foundelement.objeAcc.MiddleName = event.target.value;                
        }else if (event.target.name === 'LastName') {
                 foundelement.objeAcc.LastName = event.target.value;                
        }else if (event.target.name === 'Date_of_Birth__c') {
            foundelement.objeAcc.Date_of_Birth__c = event.target.value;
            this.LDateOfBirth = foundelement.objeAcc.Date_of_Birth__c;
            this.matchDateOfBirth = this.LDateOfBirth;        
        }else if (event.target.name === 'Mobile_Abroad__c') {
            foundelement.objeAcc.Mobile_Abroad__c = event.target.value;
        }else if (event.target.name === 'PersonMobilePhone') {
            let fieldValue = event.target.value;
            let pattern = /[0-9]{10}$/;
            foundelement.objeAcc.PersonMobilePhone = event.target.value;
                if (!pattern.test(fieldValue) && foundelement.objeAcc.mobileStatus != true){
                     foundelement.objeAcc.buttonStyleMob = 'display:none';
                }else{
                    foundelement.objeAcc.PersonMobilePhone = event.target.value;
                    foundelement.showverifyMobileButton = true;
                    foundelement.objeAcc.buttonStyleMob = 'display:block';
                }
            }
        else if (event.target.name === 'PersonEmail') {
            let fieldValue = event.target.value;
            let pattern = /[A-Za-z0-9._-]+@[a-z0-9]+\.[a-z]{2,}$/;
                foundelement.objeAcc.PersonEmail = event.target.value;
                if (!pattern.test(fieldValue) && foundelement.objeAcc.emailStatus != true){
                    foundelement.objeAcc.buttonStyle = 'display:none';
               }else{
                   foundelement.objeAcc.PersonEmail = event.target.value;
                   foundelement.objeAcc.buttonStyle = 'display:block';
                   foundelement.showverifyEmailButton = true;
               }
            }
        else if (event.target.name === 'Gender__c') {
            foundelement.objeAcc.Gender__c = event.target.value;
        }else if (event.target.name === 'Marital_Status__c') {
            foundelement.objeAcc.Marital_Status__c = event.target.value;
        }else if (event.target.name === 'Aadhar_Number__c') {
            foundelement.objeAcc.Aadhar_Number__c = event.target.value;
            this.LAadharNumber = foundelement.objeAcc.Aadhar_Number__c;
            let fieldValue = event.target.value;
            let pattern = /[0-9]{12}/;
            if (!pattern.test(fieldValue) && fieldValue != '') {
                foundelement.objeAcc.errorAadharInvalid = true;
            }else {
                let newvalue = this.LAadharNumber.slice(-4);
                let duplicateIndex = this.listOfAccounts.findIndex(ele => ele.objeAcc.Id !== foundelement.objeAcc.Id && ele.objeAcc.Aadhar_Number__c.slice(-4) === newvalue);
                if (duplicateIndex !== -1) {
                    this.showToast("Error!!", "Aadhar Number already present. Please Crosscheck", "Error")
                    foundelement.objeAcc.Aadhar_Number__c = null;
                }else {
                    foundelement.objeAcc.errorAadharInvalid = false;
                    foundelement.hideBasicSection = true;
                    this.lastFour = this.LAadharNumber.slice(-4);
                }
            }
        }else if (event.target.name === 'SalesLAadharNumber') {
            let fieldValue = event.target.value;
            let pattern = /[0-9]{4}/;
            if (!pattern.test(fieldValue)) {
                foundelement.objeAcc.saleserrorAadharInvalid = true;
            }else {
                foundelement.objeAcc.saleserrorAadharInvalid = false;
                foundelement.hideBasicSection = true;
                foundelement.objeAcc.Aadhar_Number__c = event.target.value;
                this.LAadharNumber = foundelement.objeAcc.Aadhar_Number__c;
            }
        }else if (event.target.name === 'PAN_Number__c') {
            foundelement.objeAcc.PAN_Number__c = event.target.value;
            this.PANNumber = foundelement.objeAcc.PAN_Number__c;
            let fieldValue = event.target.value;
            let pattern = /[A-Z]{5}[0-9]{4}[A-Z]{1}$/;
            if (this.PANNumber != '') {
                if (!pattern.test(fieldValue)) {
                    foundelement.objeAcc.pannotvalid = true;
                    foundelement.panTemplate = false;
                } else {
                    let newvalue = this.PANNumber;
                    let duplicateIndex = this.listOfAccounts.findIndex(ele => ele.objeAcc.Id !== foundelement.objeAcc.Id && ele.objeAcc.PAN_Number__c === newvalue);
                    if (duplicateIndex !== -1) {
                        this.showToast("Error!!", "PAN Number already present. Please Crosscheck", "Error")
                        foundelement.objeAcc.PAN_Number__c = null;
                    } else {
                        foundelement.objeAcc.pannotvalid = false;
                        this.buttonStylePan = 'display:block';
                        foundelement.panTemplate = true;
                    }
                }
            } else {
                foundelement.objeAcc.pannotvalid = false;
            }
        } else if (event.target.name === 'Passport_File_Number__c') {
            let fieldValue = event.target.value;
            let pattern = /^[A-Z]{4}[0-9]{8}$/;
            if (!pattern.test(fieldValue)) {
                foundelement.objeAcc.errorPasspostFilrInvalid = true;
            } else {
                foundelement.objeAcc.errorPasspostFilrInvalid = false;
                foundelement.objeAcc.Passport_File_Number__c = event.target.value;
                this.passportFileNumber = foundelement.objeAcc.Passport_File_Number__c;
            }
        } else if (event.target.name === 'Driving_License_Number__c') {
            let fieldValue = event.target.value;
            let pattern = /[A-Za-z]{2}[\d\s\-]{14}/;
            if (!pattern.test(fieldValue)) {
                foundelement.objeAcc.errorDLInvalid = true;
            } else {
                let newvalue = fieldValue;
                let duplicateIndex = this.listOfAccounts.findIndex(ele => ele.objeAcc.Id !== foundelement.objeAcc.Id && ele.objeAcc.Driving_License_Number__c === newvalue);
                if (duplicateIndex !== -1) {
                    this.showToast("Error!!", "Driving License already present. Please Crosscheck", "Error")
                    foundelement.objeAcc.Driving_License_Number__c = null;
                } else {
                    foundelement.objeAcc.errorDLInvalid = false;
                    foundelement.objeAcc.Driving_License_Number__c = event.target.value;
                    this.driveLicenseNumber = foundelement.objeAcc.Driving_License_Number__c;
                }
            }
        } else if (event.target.name === 'Passport_Number__c') {
            foundelement.objeAcc.Passport_Number__c = event.target.value;
            this.passportNumber = foundelement.objeAcc.Passport_Number__c;
            let fieldValue = event.target.value;
            let pattern = /^[A-Z]{1}[0-9]{7}$/;
            if (this.passportNumber != '') {
                if (!pattern.test(fieldValue)) {
                    foundelement.objeAcc.errorPassportInvalid = true;
                } else {
                    let newvalue = this.passportNumber;
                    let duplicateIndex = this.listOfAccounts.findIndex(ele => ele.objeAcc.Id !== foundelement.objeAcc.Id && ele.objeAcc.Passport_Number__c === newvalue);
                    if (duplicateIndex !== -1) {
                        this.showToast("Error!!", "Passport Number already present. Please Crosscheck", "Error")
                        foundelement.objeAcc.Passport_Number__c = null;
                    } else {
                        foundelement.objeAcc.errorPassportInvalid = false;
                    }
                }
            } else {
                foundelement.objeAcc.errorPassportInvalid = false;
            }
        } else if (event.target.name === 'Voter_ID__c') {
            let newvalue = event.target.value;
            let duplicateIndex = this.listOfAccounts.findIndex(ele => ele.objeAcc.Id !== foundelement.objeAcc.Id && ele.objeAcc.Voter_ID__c === newvalue);
            if (duplicateIndex !== -1) {
                this.showToast("Error!!", "Voter Id already present. Please Crosscheck", "Error")
                foundelement.objeAcc.Voter_ID__c = null;
            } else {
                foundelement.objeAcc.Voter_ID__c = event.target.value;
                this.voterId = foundelement.objeAcc.Voter_ID__c;
            }
        } else if (event.target.name === 'NREGNumber') {
            let fieldValue = event.target.value;
            let pattern = /[A-Z]{2}-\d{2}-\d{3}-\d{3}-\d{3}\/\d{3}/;
            if (!pattern.test(fieldValue) && fieldValue != '') {
                foundelement.objeAcc.errorNREGInvalid = true;
            } else {
                let newvalue = fieldValue;
                let duplicateIndex = this.listOfAccounts.findIndex(ele => ele.objeAcc.Id !== foundelement.objeAcc.Id && ele.objeAcc.NREG_Number__c === newvalue);
                if (duplicateIndex !== -1) {
                    this.showToast("Error!!", "NREG Number already present. Please Crosscheck", "Error")
                    foundelement.objeAcc.NREG_Number__c = null;
                } else {
                    foundelement.objeAcc.errorNREGInvalid = false;
                    foundelement.objeAcc.NREG_Number__c = event.target.value;
                }
            }
        } else if (event.target.name === 'CKYCNumber') {
            let fieldValue = event.target.value;
            let pattern = /[0-9]{14}/;
            if (!pattern.test(fieldValue) && fieldValue != '') {
                foundelement.objeAcc.errorCKYCInvalid = true;
            } else {
                let newvalue = fieldValue;
                let duplicateIndex = this.listOfAccounts.findIndex(ele => ele.objeAcc.Id !== foundelement.objeAcc.Id && ele.objeAcc.CKYC_Number__c === newvalue);
                if (duplicateIndex !== -1) {
                    this.showToast("Error!!", "CKYC Number already present. Please Crosscheck", "Error")
                    foundelement.objeAcc.CKYC_Number__c = null;
                } else {
                    foundelement.objeAcc.errorCKYCInvalid = false;
                    foundelement.objeAcc.CKYC_Number__c = event.target.value;
                }
            }
        }
    }
    handleChangeDemo(event) {
        var foundelement = this.listOfAccounts.find(ele => ele.appDemography.Id == event.target.dataset.id);
        if (event.target.name == 'F_TITLE__c') {
            foundelement.appDemography.F_TITLE__c = event.target.value;
        } else if (event.target.name == 'Father_s_First_Name__c') {
            foundelement.appDemography.Father_s_First_Name__c = event.target.value;
        } else if (event.target.name == 'M_TITLE__c') {
            foundelement.appDemography.M_TITLE__c = event.target.value;
        } else if (event.target.name == 'Mother_s_First_Name__c') {
            foundelement.appDemography.Mother_s_First_Name__c = event.target.value;
        }
    }
    handleApplicantCategory(event) {
        var foundelement = this.listOfAccounts.find(ele => ele.objApplicant.Id == event.target.dataset.id);
        if (this.coAadharStaus == true) {
            foundelement.objApplicant.Aadhar_Verified__c = this.coAadharStaus;
        }
        if (event.target.name == "ApplicantCategory") {
            foundelement.objApplicant.Type__c = event.target.value;
        } else if (event.target.name === 'Relation_with_applicant__c') {
            foundelement.objApplicant.Relation_with_applicant__c = event.target.value;
            if (event.target.value === 'OTHER') {
                foundelement.ShowFieldsRelationWithAppliIfOther = true;
            } else {
                foundelement.ShowFieldsRelationWithAppliIfOther = false;
            }
            if(event.target.value === 'Father' || event.target.value === 'Mother'){
                this.hideshowQuestion = false;
                this.hideshowotherreason = false;
                this.QuesForcoapplicant = '';
                this.otherReason = '';
            }
        } else if (event.target.name === 'Relation_others__c') {
            foundelement.objApplicant.Relation_others__c = event.target.value;
        } else if (event.target.name === 'Relationship_Proof__c') {
            foundelement.objApplicant.Relationship_Proof__c = event.target.value;
        } else if (event.target.name === 'Is_Income_Considered_Financial__c') {
            foundelement.objApplicant.Is_Income_Considered_Financial__c = event.target.value;
        }else if (event.target.name === 'QUALIFICATION__c') {
            foundelement.objApplicant.QUALIFICATION__c = event.target.value;
        } else {
            this.ShowFieldsApplicantCategory = false;
        }
    }
    handlechangeCurrent(event) {
        var foundelement = this.listOfAccounts.find(ele => ele.appCurrentAdd.Id == event.target.dataset.id);
        if (event.target.name === 'Address_Proof__c') {
            foundelement.appCurrentAdd.Address_Proof__c = event.target.value;
        } else if (event.target.name === 'Current_Address__c') {
            foundelement.appCurrentAdd.Address_1__c = event.target.value;
        } else if (event.target.name === 'City__c') {
            foundelement.appCurrentAdd.City__c = event.target.value;
        } else if (event.target.name === 'District__c') {
            foundelement.appCurrentAdd.District__c = event.target.value;
        } else if (event.target.name === 'State__c') {
            foundelement.appCurrentAdd.State__c = event.target.value;
        } else if (event.target.name === 'Country__c') {
            foundelement.appCurrentAdd.Country__c = event.target.value;
        } else if (event.target.name === 'Landmark__c') {
            foundelement.appCurrentAdd.Landmark__c = event.target.value;
        } else if (event.target.name === 'Years_In_The_Address__c') {
            foundelement.appCurrentAdd.Years_In_The_Address__c = event.target.value;
        }
    }
    @track errorCurrentAddressLandmark = false;
    @track errorPermanenetAddressLandmark = false;
    handleCurrentaddress(event){
        var foundelement = this.listOfAccounts.find(ele => ele.appCurrentAdd.Id == event.target.dataset.id);
        if (event.target.name == "Landmark__c") {
            if (foundelement.appCurrentAdd.Landmark__c.length > 50){
                this.showToast("Error!!", "Landmark for Current Address cannot be greater than 50 characters", "Error")
                foundelement.errorCurrentAddressLandmark = true;
            }else{
                foundelement.errorCurrentAddressLandmark = false;
                foundelement.appPermanentAdd.Landmark__c = event.target.value;
            }
        }
    }
    handlePermanentaddress(event){
        var foundelement = this.listOfAccounts.find(ele => ele.appPermanentAdd.Id == event.target.dataset.id);
        if (event.target.name == "Landmark_Permanent__pc") {
            if (foundelement.appPermanentAdd.Landmark__c.length > 50){
                this.showToast("Error!!", "Landmark for Permanent Address cannot be greater than 50 characters", "Error")
                foundelement.errorPermanenetAddressLandmark = true;
            }else{
                foundelement.errorPermanenetAddressLandmark = false;
            }
        }
    }

    handlechangePermanent(event) {
        var foundelement = this.listOfAccounts.find(ele => ele.appPermanentAdd.Id == event.target.dataset.id);
        if (event.target.name === 'Same_as_Current_Address__c') {
            foundelement.appPermanentAdd.Same_as_Current_Address__c = event.target.checked;
            if (foundelement.appPermanentAdd.Same_as_Current_Address__c == true) {
                foundelement.appPermanentAdd.Address_Proof__c = foundelement.appCurrentAdd.Address_Proof__c;
                foundelement.appPermanentAdd.Address_1__c = foundelement.appCurrentAdd.Address_1__c;
                foundelement.appPermanentAdd.Pin_Code__c = foundelement.appCurrentAdd.Pin_Code__c;
                foundelement.appPermanentAdd.City__c = foundelement.appCurrentAdd.City__c;
                foundelement.appPermanentAdd.District__c = foundelement.appCurrentAdd.District__c;
                foundelement.appPermanentAdd.State__c = foundelement.appCurrentAdd.State__c;
                foundelement.appPermanentAdd.Country__c = foundelement.appCurrentAdd.Country__c;
                foundelement.appPermanentAdd.Landmark__c = foundelement.appCurrentAdd.Landmark__c;
                foundelement.appPermanentAdd.Years_In_The_Address__c = foundelement.appCurrentAdd.Years_In_The_Address__c;
                if ((foundelement.appCurrentAdd.Country__c == 'INDIA' || foundelement.appCurrentAdd.Country__c == 'India') && foundelement.appPermanentAdd.Same_as_Current_Address__c == true) {
                    foundelement.appPermanentAdd.makePermanentAddProofdisabled = true;
                } else {
                    foundelement.appPermanentAdd.makePermanentAddProofdisabled = false;
                }
            } else {
                foundelement.appPermanentAdd.Address_Proof__c = '';
                foundelement.appPermanentAdd.Address_1__c = '';
                foundelement.appPermanentAdd.Pin_Code__c = '';
                foundelement.appPermanentAdd.City__c = '';
                foundelement.appPermanentAdd.District__c = '';
                foundelement.appPermanentAdd.State__c = '';
                foundelement.appPermanentAdd.Country__c = '';
                foundelement.appPermanentAdd.Landmark__c = '';
                foundelement.appPermanentAdd.Years_In_The_Address__c = '';
                foundelement.appPermanentAdd.makePermanentAddProofdisabled = false;
            }
        } else if (event.target.name === 'Address_Proof__c') {
            foundelement.appPermanentAdd.Address_Proof__c = event.target.value;
        } else if (event.target.name === 'Permanent_Address__c') {
            foundelement.appPermanentAdd.Address_1__c = event.target.value;
        } else if (event.target.name === 'City__c') {
            foundelement.appPermanentAdd.City__c = event.target.value;
        } else if (event.target.name === 'District__c') {
            foundelement.appPermanentAdd.District__c = event.target.value;
        } else if (event.target.name === 'State__c') {
            foundelement.appPermanentAdd.State__c = event.target.value;
        } else if (event.target.name === 'Country__c') {
            foundelement.appPermanentAdd.Country__c = event.target.value;
        } else if (event.target.name === 'Landmark_Permanent__pc') {
            foundelement.appPermanentAdd.Landmark__c = event.target.value;
        } else if (event.target.name === 'Years_In_The_Address__c') {
            foundelement.appPermanentAdd.Years_In_The_Address__c = event.target.value;
        }
    }

    get acceptedFormats() {
        return ['.pdf', '.png', '.jpeg', '.jpg'];
    }
    AppliCategoryvalue = '';
    get AppliCategoryOptions() {
        return this.appliOptions;
    }
    appliOptions = [
        { label: 'CoApplicant', value: 'CoApplicant' },
        { label: 'Guarantor', value: 'Guarantor' },
    ];
    get IsCommAddressoptions() {
        return [
            { label: 'Current Address', value: 'Current Address' },
            { label: 'Permanent Address', value: 'Permanent Address' },
        ];
    }

    @track coapplicantName;
    handleSaveCoApplicant(event) {
        var accSection;
        var addSection;
        var appSection;
        var kycSection;
        var duplicaterrorVoterId;
        var duplicaterrorAadharNumber;
        var duplicaterrorPANNumber;
        var duplicaterrorPassportNumber;
        var duplicaterrorDLNumber;
        var errorforfirsstName;
        var errorformiddleName;
        var errorforlastName;
        var errorInvalidPANNumber;
        var erroronapplicantdup;
        var passportFileInvalid;
        var passportNumberInvalid;
        var dlNumberInvalid;
        var aadharNumberInvalid;
        var CKYCNumberInvalid;
        var NREGNumberInvalid;
        var salesrAadharInvalid;
        var appSameMobile;
        var appSameEmail;
        let coApplicantMobileNo = [];
        let coApplicantEmail = [];
        let relationsWithApplicant = [];
        var noFatherMotherError;
        var errorInvalidCurrrentAddress;
        var errorInvalidPermanentAddress;
        var personEmailCheck = false;
        if (this.listOfAccounts.length > 0) {
            for (var i = 0; i < this.listOfAccounts.length; i++) {
                var element = this.listOfAccounts[i];
                this.coapplicantName = element.objeAcc.FirstName +' '+element.objeAcc.LastName;
                if(element.errorCurrentAddressLandmark == true){
                    errorInvalidCurrrentAddress = true;
                    if (errorInvalidCurrrentAddress)
                        break;
                }else if(element.errorPermanenetAddressLandmark == true){
                    errorInvalidPermanentAddress = true;
                    if (errorInvalidPermanentAddress)
                        break;
                }else if (element.applicantAccountDup == true) {
                    erroronapplicantdup = true;
                    if (erroronapplicantdup)
                        break;
                } else if (element.objeAcc.errorCKYCInvalid == true) {
                    CKYCNumberInvalid = true;
                    if (CKYCNumberInvalid)
                        break;
                } else if (element.objeAcc.errorNREGInvalid == true) {
                    NREGNumberInvalid = true;
                    if (NREGNumberInvalid)
                        break;
                } else if (element.objeAcc.saleserrorAadharInvalid == true) {
                    salesrAadharInvalid = true;
                    if (salesrAadharInvalid)
                        break;
                } else if (element.objeAcc.errorAadharInvalid == true) {
                    aadharNumberInvalid = true;
                    if (aadharNumberInvalid)
                        break;
                } else if (element.objeAcc.errorDLInvalid == true) {
                    dlNumberInvalid = true;
                    if (dlNumberInvalid)
                        break;
                } else if (element.objeAcc.pannotvalid == true) {
                    erroronapplicantdup = true;
                    if (erroronapplicantdup)
                        break;
                } else if (element.objeAcc.errorPassportInvalid == true) {
                    passportNumberInvalid = true;
                    if (passportFileInvalid)
                        break;
                } else if (element.objeAcc.errorPasspostFilrInvalid == true) {
                    passportFileInvalid = true;
                    if (passportFileInvalid)
                        break;                
                } else if (element.objeAcc.Aadhar_Number__c == element.matchValue && element.errorMsgForDuplicate == true) {
                    duplicaterrorAadharNumber = true;
                    if (duplicaterrorAadharNumber)
                        break;
                } else if (element.objeAcc.PAN_Number__c == element.matchValue && element.errorMsgForDuplicate == true) {
                    duplicaterrorPANNumber = true;
                    if (duplicaterrorPANNumber)
                        break;
                } else if (element.objeAcc.Passport_Number__c == element.matchValue && element.errorMsgForDuplicate == true) {
                    duplicaterrorPassportNumber = true;
                    if (duplicaterrorPassportNumber)
                        break;
                } else if (element.objeAcc.Driving_License_Number__c == element.matchValue && element.errorMsgForDuplicate == true) {
                    duplicaterrorDLNumber = true;
                    if (duplicaterrorDLNumber)
                        break;
                } else if (element.objeAcc.Voter_ID__c == element.matchValue && element.errorMsgForDuplicate == true) {
                    duplicaterrorVoterId = true;
                    if (duplicaterrorVoterId)
                        break;
                } else if (element.objeAcc.FirstName == '' || element.objeAcc.FirstName == undefined ||
                    element.objeAcc.LastName == '' || element.objeAcc.LastName == undefined ||
                    element.objeAcc.PersonMobilePhone == '' || element.objeAcc.PersonMobilePhone == undefined) {
                    accSection = true;
                    if (accSection)
                        break;
                } else if (element.objeAcc.Date_of_Birth__c == null || element.objeAcc.Date_of_Birth__c == '' || element.objeAcc.Date_of_Birth__c == undefined ||
                    element.objeAcc.Aadhar_Number__c == '' || element.objeAcc.Aadhar_Number__c == undefined || element.objeAcc.Aadhar_Number__c == null) {
                    kycSection = true;
                    if (kycSection)
                        break;
                } else if( (element.objeAcc.PersonEmail == '' || element.objeAcc.PersonEmail == undefined) && element.objeAcc.Is_Income_Considered_Financial__c == 'Yes'){
                        personEmailCheck = true;
                    if (personEmailCheck)
                        break;
                }else if ((element.appCurrentAdd.Address_Proof__c == '' || element.appCurrentAdd.Address_Proof__c == undefined
                    || element.appCurrentAdd.Address_1__c == '' || element.appCurrentAdd.Address_1__c == undefined ||
                    element.appCurrentAdd.Pin_Code__c == '' || element.appCurrentAdd.Pin_Code__c == undefined ||
                    element.appCurrentAdd.Years_In_The_Address__c == '' || element.appCurrentAdd.Years_In_The_Address__c == undefined) ||
                    (element.appPermanentAdd.Address_Proof__c == '' || element.appPermanentAdd.Address_Proof__c == undefined ||
                        element.appPermanentAdd.Address_1__c == '' || element.appPermanentAdd.Address_1__c == undefined ||
                        element.appPermanentAdd.Pin_Code__c == '' || element.appPermanentAdd.Pin_Code__c == undefined ||
                        element.appPermanentAdd.Years_In_The_Address__c == '' || element.appPermanentAdd.Years_In_The_Address__c == undefined)) {
                    addSection = true;
                    if (addSection)
                        break;
                }
            }
            this.listOfAccounts.forEach(res => {
                relationsWithApplicant.push(res.objApplicant.Relation_with_applicant__c);
                if (res.objApplicant.Is_Income_Considered_Financial__c == 'Yes') {
                    coApplicantMobileNo.push(res.objeAcc.PersonMobilePhone);
                    coApplicantEmail.push(res.objeAcc.PersonEmail)
                }
            });
            if (!relationsWithApplicant.includes('Father') && !relationsWithApplicant.includes('Mother') && (this.QuesForcoapplicant == undefined || this.QuesForcoapplicant == '')) {
                noFatherMotherError = true;
                this.hideshowQuestion = true;
            }
            if (coApplicantMobileNo.includes(this.getApplicantMobile)) {
                appSameMobile = true;
            }
            if (coApplicantEmail.includes(this.getApplicantEmail)) {
                appSameEmail = true;
            }
            if(errorInvalidCurrrentAddress){
                this.showToast("Error!!", "Landmark for Current Address cannot be greater than 50 characters for " +this.coapplicantName+"", "Error")
            }else if(errorInvalidPermanentAddress){
                this.showToast("Error!!", "Landmark for Permanent Address cannot be greater than 50 characters for " +this.coapplicantName+"", "Error")
            }else if(this.QuesForcoapplicant == 'Others' && (this.otherReason == undefined || this.otherReason == '')){
                this.showToast("Error!!", 'Please Fill required field "Other Reason"', "Error")
            }else if (salesrAadharInvalid) {
                this.showToast("Error!!", "Fill last 4 Digits of Aadhar Number", "Error")
            } else if (CKYCNumberInvalid) {
                this.showToast("Error!!", "Please enter valid CKYC Number", "Error")
            } else if (NREGNumberInvalid) {
                this.showToast("Error!!", "Please enter valid NREG Number", "Error")
            } else if (aadharNumberInvalid) {
                this.showToast("Error!!", "Please enter Valid Aadhar Number", "Error")
            } else if (errorInvalidPANNumber) {
                this.showToast("Error!!", "Please enter valid PAN Number", "Error")
            } else if (dlNumberInvalid) {
                this.showToast("Error!!", "Please enter Valid Driving Licence", "Error")
            } else if (passportNumberInvalid) {
                this.showToast("Error!!", "Please enter Valid Passport Number", "Error")
            } else if (passportFileInvalid) {
                this.showToast("Error!!", "Please enter Valid Passport File Number", "Error")
            } else if (errorforfirsstName) {
                this.showToast("Error!!", "Please enter Valid First Name", "Error")
            } else if (errorformiddleName) {
                this.showToast("Error!!", "Please enter Valid Middle Name", "Error")
            } else if (errorforlastName) {
                this.showToast("Error!!", "Please enter Valid Last Name", "Error")
            } else if (erroronapplicantdup) {
                this.showToast("Error!!", "Applicant and Co-Applicant details cannot be same. Kindly Crosscheck", "Error")
            } else if (duplicaterrorAadharNumber) {
                this.showToast("Error!!", "An account exists with the Aadhar provided. Kindly crosscheck", "Error")
            } else if (duplicaterrorPANNumber) {
                this.showToast("Error!!", "An account exists with the PAN Number provided. Kindly crosscheck", "Error")
                if (this.LAadharNumber != '' || this.LAadharNumber != undefined) {
                    this.showToast("Info!!", "Previous Aadhar number Updated", "info")
                }
            } else if (duplicaterrorPassportNumber) {
                this.showToast("Error!!", "An account exists with the Passport Number provided. Kindly crosscheck", "Error")
            } else if (duplicaterrorDLNumber) {
                this.showToast("Error!!", "An account exists with the Driving License provided. Kindly crosscheck", "Error")
            } else if (duplicaterrorVoterId) {
                this.showToast("Error!!", "An account exists with the Voter Id provided. Kindly crosscheck", "Error")
            } else if (kycSection) {
                this.showToast("Error!!", "Please fill KYC mandatory fields", "Error")
            } else if (accSection || appSection) {
                this.showToast("Error!!", "Please fill Co-Applicant mandatory fields", "Error")
            } else if (personEmailCheck) {
                this.showToast("Error!!", "Please fill Email field", "Error")
            } else if (addSection) {
                this.showToast("Error!!", "Please fill Address mandatory fields", "Error")
            } else if (appSameMobile) {
                this.showToast("Error!!", "Applicant and Financial Co-Applicant cannot have the same Mobile Number", "Error")
            } else if (noFatherMotherError) {
                this.showToast("Error!!", 'Please Fill required field "Mother/Father non Co-Applicant reason"', "Error")
            } else if (appSameEmail) {
                this.showToast("Error!!", "Applicant and Financial Co-Applicant cannot have the same Email", "Error")
            }
            else {
                this.listOfAccounts.forEach(res => {
                    try {
                        if (!isNaN(res.objeAcc.Id)) {
                            res.objeAcc.Id = null; 
                        }
                        if (!isNaN(res.objApplicant.Id)) {
                            res.objApplicant.Id = null;
                        }
                        if (!isNaN(res.appCurrentAdd.Id) || res.alreadyduplicatefound == true) {
                            res.appCurrentAdd.Name = res.objeAcc.FirstName + ' ' + res.objeAcc.LastName;
                            res.appCurrentAdd.Address_Type__c = 'Current Address';
                            res.appCurrentAdd.Id = null;
                        }else {
                            res.appCurrentAdd.Name = res.objeAcc.FirstName + ' ' + res.objeAcc.LastName;
                            res.appCurrentAdd.Address_Type__c = 'Current Address';
                        }
                        if (!isNaN(res.appPermanentAdd.Id) || res.alreadyduplicatefound == true) {
                            res.appPermanentAdd.Name = res.objeAcc.FirstName + ' ' + res.objeAcc.LastName;
                            res.appPermanentAdd.Address_Type__c = 'Permanent Address';
                            res.appPermanentAdd.Id = null;
                        }else {
                            res.appPermanentAdd.Name = res.objeAcc.FirstName + ' ' + res.objeAcc.LastName;
                            res.appPermanentAdd.Address_Type__c = 'Permanent Address';
                        }
                        if (!isNaN(res.appDemography.Id) || res.alreadyduplicatefound == true) {
                            res.appDemography.Id = null;
                        }
                    } catch (error) {
                    }
                });
                this.isLoading = true;
                saveCoApplicant({ coApplicantData: this.listOfAccounts, leadId: this.leadRecordId })
                    .then(result => {
                        this.isLoading = false;
                        updateQuestion({leadId: this.leadRecordId, questionAnswer: this.QuesForcoapplicant, otherReason : this.otherReason})
                        this.showToast("Success!!", "Successfully Saved", "Success")
                        if (result.length > 0) {
                            this.listOfAccounts = JSON.parse(JSON.stringify(result));
                            this.setCoApplicantRecord(this.listOfAccounts);
                        }
                    })
                    .catch(error => {
                        this.isLoading = false;
                        this.handleErrorMessage(error);
                    })
            }
        }
    }
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title, message, variant
            }),
        );
    }
    @track nextCoapplicantName;
    handleNextCoApplicant(event) {
        var accSection;
        var addSection;
        var appSection;
        var demoSection;
        var kycSection;
        var duplicaterrorVoterId;
        var duplicaterrorAadharNumber;
        var duplicaterrorPANNumber;
        var duplicaterrorPassportNumber;
        var duplicaterrorDLNumber;
        var errorforfirsstName;
        var errorformiddleName;
        var errorforlastName;
        var errorInvalidPANNumber;
        var erroronapplicantdup;
        var passportFileInvalid;
        var passportNumberInvalid;
        var dlNumberInvalid;
        var aadharNumberInvalid;
        var CKYCNumberInvalid;
        var NREGNumberInvalid;
        var PANMandatory;
        var salesrAadharInvalid;
        var noFatherMotherError;
        var appSameMobile;
        var appSameEmail;
        let relationsWithApplicant = [];
        let coApplicantMobileNo = [];
        let coApplicantEmail = [];
        var errorInvalidCurrrentAddress;
        var errorInvalidPermanentAddress;
        if (this.listOfAccounts.length > 0) {
            for (var i = 0; i < this.listOfAccounts.length; i++) {
                var element = this.listOfAccounts[i]; 
                this.nextCoapplicantName = element.objeAcc.FirstName +' '+element.objeAcc.LastName;
                if(element.errorCurrentAddressLandmark == true){
                    errorInvalidCurrrentAddress = true;
                    if (errorInvalidCurrrentAddress)
                        break;
                }else if(element.errorPermanenetAddressLandmark == true){
                    errorInvalidPermanentAddress = true;
                    if (errorInvalidPermanentAddress)
                        break;
                }else if (element.applicantAccountDup == true) {
                    erroronapplicantdup = true;
                    if (erroronapplicantdup)
                        break;
                } else if (element.objeAcc.errorCKYCInvalid == true) {
                    CKYCNumberInvalid = true;
                    if (CKYCNumberInvalid)
                        break;
                } else if (element.objeAcc.errorNREGInvalid == true) {
                    NREGNumberInvalid = true;
                    if (NREGNumberInvalid)
                        break;
                } else if (element.objeAcc.saleserrorAadharInvalid == true) {
                    salesrAadharInvalid = true;
                    if (salesrAadharInvalid)
                        break;
                } else if (element.objeAcc.errorAadharInvalid == true) {
                    aadharNumberInvalid = true;
                    if (aadharNumberInvalid)
                        break;
                } else if (element.objeAcc.errorDLInvalid == true) {
                    dlNumberInvalid = true;
                    if (dlNumberInvalid)
                        break;
                } else if (element.objeAcc.pannotvalid == true) {
                    erroronapplicantdup = true;
                    if (erroronapplicantdup)
                        break;
                } else if (element.objeAcc.errorPassportInvalid == true) {
                    passportNumberInvalid = true;
                    if (passportFileInvalid)
                        break;
                } else if (element.objeAcc.errorPasspostFilrInvalid == true) {
                    passportFileInvalid = true;
                    if (passportFileInvalid)
                        break;                
                } else if (element.objeAcc.Aadhar_Number__c == element.matchValue && element.errorMsgForDuplicate == true) {
                    duplicaterrorAadharNumber = true;
                    if (duplicaterrorAadharNumber)
                        break;
                } else if (element.objeAcc.PAN_Number__c == element.matchValue && element.errorMsgForDuplicate == true) {
                    duplicaterrorPANNumber = true;
                    if (duplicaterrorPANNumber)
                        break;
                } else if (element.objeAcc.Passport_Number__c == element.matchValue && element.errorMsgForDuplicate == true) {
                    duplicaterrorPassportNumber = true;
                    if (duplicaterrorPassportNumber)
                        break;
                } else if (element.objeAcc.Driving_License_Number__c == element.matchValue && element.errorMsgForDuplicate == true) {
                    duplicaterrorDLNumber = true;
                    if (duplicaterrorDLNumber)
                        break;
                } else if (element.objeAcc.Voter_ID__c == element.matchValue && element.errorMsgForDuplicate == true) {
                    duplicaterrorVoterId = true;
                    if (duplicaterrorVoterId)
                        break;
                } else if (element.objeAcc.Salutation == '' || element.objeAcc.Salutation == undefined || element.objeAcc.FirstName == '' || element.objeAcc.FirstName == undefined ||
                    element.objeAcc.LastName == '' || element.objeAcc.LastName == undefined ||
                    element.objeAcc.PersonMobilePhone == '' || element.objeAcc.PersonMobilePhone == undefined ||
                    element.objeAcc.PersonEmail == '' || element.objeAcc.PersonEmail == undefined ||
                    element.objeAcc.Gender__c == '' || element.objeAcc.Gender__c == undefined ||
                    element.objeAcc.Marital_Status__c == '' || element.objeAcc.Marital_Status__c == undefined) {
                    accSection = true;
                    if (accSection)
                        break;
                } else if (element.objeAcc.Date_of_Birth__c == null || element.objeAcc.Date_of_Birth__c == '' || element.objeAcc.Date_of_Birth__c == undefined ||
                    element.objeAcc.Aadhar_Number__c == '' || element.objeAcc.Aadhar_Number__c == undefined || element.objeAcc.Aadhar_Number__c == null) {
                    kycSection = true;
                    if (kycSection)
                        break;
                } else if (element.objApplicant.Type__c == '' || element.objApplicant.Type__c == undefined ||
                    element.objApplicant.Relation_with_applicant__c == '' || element.objApplicant.Relation_with_applicant__c == undefined ||
                    element.objApplicant.Relationship_Proof__c == '' || element.objApplicant.Relationship_Proof__c == undefined ||
                    element.objApplicant.QUALIFICATION__c == '' || element.objApplicant.QUALIFICATION__c == undefined ||
                    element.objApplicant.Is_Income_Considered_Financial__c == '' || element.objApplicant.Is_Income_Considered_Financial__c == undefined || 
                    (element.objApplicant.Relation_with_applicant__c == 'OTHER' && (element.objApplicant.Relation_others__c == '' || element.objApplicant.Relation_others__c == undefined))) {
                    appSection = true;
                    if (appSection)
                        break;
                } else if ((element.appDemography.F_TITLE__c == '' || element.appDemography.F_TITLE__c == undefined || element.appDemography.Father_s_First_Name__c == '' || element.appDemography.Father_s_First_Name__c == undefined || element.appDemography.M_TITLE__c == '' || element.appDemography.M_TITLE__c == undefined || element.appDemography.Mother_s_First_Name__c == '' || element.appDemography.Mother_s_First_Name__c == undefined)) {
                    demoSection = true;
                    if (demoSection)
                        break;
                } else if ((element.appCurrentAdd.Address_Proof__c == '' || element.appCurrentAdd.Address_Proof__c == undefined
                    || element.appCurrentAdd.Address_1__c == '' || element.appCurrentAdd.Address_1__c == undefined ||
                    element.appCurrentAdd.Pin_Code__c == '' || element.appCurrentAdd.Pin_Code__c == undefined ||
                    element.appCurrentAdd.Years_In_The_Address__c == '' || element.appCurrentAdd.Years_In_The_Address__c == undefined ||
                    element.appCurrentAdd.Landmark__c == '' || element.appCurrentAdd.Landmark__c == undefined ) ||
                    (element.appPermanentAdd.Address_Proof__c == '' || element.appPermanentAdd.Address_Proof__c == undefined ||
                        element.appPermanentAdd.Address_1__c == '' || element.appPermanentAdd.Address_1__c == undefined ||
                        element.appPermanentAdd.Pin_Code__c == '' || element.appPermanentAdd.Pin_Code__c == undefined ||
                        element.appPermanentAdd.Years_In_The_Address__c == '' || element.appPermanentAdd.Years_In_The_Address__c == undefined ||
                        element.appPermanentAdd.Landmark__c == '' || element.appPermanentAdd.Landmark__c == undefined )) {
                    addSection = true;
                    if (addSection)
                        break;
                } else if (element.objApplicant.Is_Income_Considered_Financial__c == 'Yes' &&
                    (element.objeAcc.PAN_Number__c == '' || element.objeAcc.PAN_Number__c == undefined || element.objeAcc.PAN_Number__c == null)) {
                    PANMandatory = true;
                    if (PANMandatory)
                        break;
                }
            }
            this.listOfAccounts.forEach(res => {
                relationsWithApplicant.push(res.objApplicant.Relation_with_applicant__c);
                if (res.objApplicant.Is_Income_Considered_Financial__c == 'Yes') {
                    coApplicantMobileNo.push(res.objeAcc.PersonMobilePhone);
                    coApplicantEmail.push(res.objeAcc.PersonEmail)
                }
            });
            if (!relationsWithApplicant.includes('Father') && !relationsWithApplicant.includes('Mother') && (this.QuesForcoapplicant == undefined || this.QuesForcoapplicant == '')) {
                noFatherMotherError = true;
                this.hideshowQuestion = true;
            }
            if (coApplicantMobileNo.includes(this.getApplicantMobile)) {
                appSameMobile = true;
            }
            if (coApplicantEmail.includes(this.getApplicantEmail)) {
                appSameEmail = true;
            }
            if(errorInvalidCurrrentAddress){
                this.showToast("Error!!", "Landmark for Current Address cannot be greater than 50 characters for "+this.nextCoapplicantName+"", "Error")
            }else if(errorInvalidPermanentAddress){
                this.showToast("Error!!", "Landmark for Permanent Address cannot be greater than 50 characters for "+this.nextCoapplicantName+"", "Error")
            }else if(this.QuesForcoapplicant == 'Others' && (this.otherReason == undefined || this.otherReason == '')){
                this.showToast("Error!!", 'Please Fill required field "Other Reason"', "Error")
            }else if (salesrAadharInvalid) {
                this.showToast("Error!!", 'Fill last 4 Digits of Aadhar Number', "Error")
            } else if (CKYCNumberInvalid) {
                this.showToast("Error!!", 'Please enter valid CKYC Number', "Error")
            } else if (NREGNumberInvalid) {
                this.showToast("Error!!", 'Please enter valid NREG Number', "Error")
            } else if (aadharNumberInvalid) {
                this.showToast("Error!!", 'Please enter Valid Aadhar Number', "Error")
            } else if (errorInvalidPANNumber) {
                this.showToast("Error!!", 'Please enter valid PAN Numberr', "Error")
            } else if (PANMandatory) {
                this.showToast("Error!!", 'Please enter PAN Number', "Error")
            } else if (dlNumberInvalid) {
                this.showToast("Error!!", 'Please enter Valid Driving Licence', "Error")
            } else if (passportNumberInvalid) {
                this.showToast("Error!!", 'Please enter Valid Passport Number', "Error")
            } else if (passportFileInvalid) {
                this.showToast("Error!!", 'Please enter Valid Passport File Number', "Error")
            } else if (errorforfirsstName) {
                this.showToast("Error!!", 'Please enter Valid First Name', "Error")
            } else if (errorformiddleName) {
                this.showToast("Error!!", 'Please enter Valid Middle Name', "Error")
            } else if (errorforlastName) {
                this.showToast("Error!!", 'Please enter Valid Last Name', "Error")
            } else if (erroronapplicantdup) {
                this.showToast("Error!!", 'Applicant and Co-Applicant details cannot be same. Kindly Crosscheck', "Error")
            } else if (duplicaterrorAadharNumber) {
                this.showToast("Error!!", 'An account exists with the Aadhar provided. Kindly crosscheck', "Error")
            } else if (duplicaterrorPANNumber) {
                this.showToast("Error!!", 'An account exists with the PAN Number provided. Kindly crosscheck', "Error")
                if (this.LAadharNumber != '' || this.LAadharNumber != undefined) {
                    this.showToast("Error!!", 'Previous Aadhar number Updated', "Error")
                }
            } else if (duplicaterrorPassportNumber) {
                this.showToast("Error!!", 'An account exists with the Passport Number provided. Kindly crosscheck', "Error")
            } else if (duplicaterrorDLNumber) {
                this.showToast("Error!!", 'An account exists with the Driving License provided. Kindly crosscheck', "Error")
            } else if (duplicaterrorVoterId) {
                this.showToast("Error!!", 'An account exists with the Voter Id provided. Kindly crosscheck', "Error")
            } else if (kycSection) {
                this.showToast("Error!!", 'Please fill KYC mandatory fields', "Error")
            } else if (accSection || appSection || demoSection) {
                this.showToast("Error!!", 'Please fill Co-Applicant mandatory fields', "Error")
            } else if (addSection) {
                this.showToast("Error!!", 'Please fill Address mandatory fields', "Error")
            } else if (noFatherMotherError) {
                this.showToast("Error!!", 'Please Fill required field "Mother/Father non Co-Applicant reason"', "Error")
            } else if (appSameMobile) {
                this.showToast("Error!!", "Applicant and Financial Co-Applicant cannot have the same Mobile Number", "Error")
            } else if (appSameEmail) {
                this.showToast("Error!!", "Applicant and Financial Co-Applicant cannot have the same Email", "Error")
            } else {
                this.listOfAccounts.forEach(res => {
                    try {
                        if (!isNaN(res.objeAcc.Id)) {
                            res.objeAcc.Id = null;
                        }
                        if (!isNaN(res.objApplicant.Id)) {
                            res.objApplicant.Id = null;
                        }
                        if (!isNaN(res.appCurrentAdd.Id) || res.alreadyduplicatefound == true) {
                            res.appCurrentAdd.Name = res.objeAcc.FirstName + ' ' + res.objeAcc.LastName;
                            res.appCurrentAdd.Address_Type__c = 'Current Address';
                            res.appCurrentAdd.Id = null;
                        }
                        if (!isNaN(res.appPermanentAdd.Id) || res.alreadyduplicatefound == true) {
                            res.appPermanentAdd.Name = res.objeAcc.FirstName + ' ' + res.objeAcc.LastName;
                            res.appPermanentAdd.Address_Type__c = 'Permanent Address';
                            res.appPermanentAdd.Id = null;
                        }
                        if (!isNaN(res.appDemography.Id) || res.alreadyduplicatefound == true) {
                            res.appDemography.Id = null;
                        }
                    } catch (error) {
                    }
                });
                this.isLoading = true;
                saveCoApplicant({ coApplicantData: this.listOfAccounts, leadId: this.leadRecordId })
                    .then(result => {
                        this.isLoading = false;
                        let sum;
                        updateQuestion({leadId: this.leadRecordId, questionAnswer: this.QuesForcoapplicant, otherReason : this.otherReason})
                        if (this.coapplicantCheck == true) {
                            sum = 0;
                        } else {
                            getSectionWeightage({ sectionName: 'Co-Applicant' })
                                .then(result => {
                                    sum = result;
                                    if (sum) {
                                        let newPerc = sum;
                                        updateLeadTotalPercentage({ leadId: this.leadRecordId, percentage: newPerc })
                                            .then(result => {
                                                let ProgrssValueOfLoanSection = { ProgrssValueOfLoanSection: result };
                                                publish(this.messageContext, progressBar, ProgrssValueOfLoanSection);
                                            })
                                            .catch(error => {
                                            });
                                    }
                                })
                                .catch(error => {
                                })
                            updateCheck({ leadId: this.leadRecordId, isCheck: true })
                                .then(result => {
                                    this.coapplicantCheck = result.Co_applicant_Section__c;
                                })
                        }
                        const onNextEvent = new CustomEvent('next', {
                            detail: {
                                nextValue: '5',
                            },
                        });
                        this.dispatchEvent(onNextEvent);
                        this.showToast("Success!!", 'Successfully Saved', "Success")
                        let coApplicantSection = false;
                        publish(this.messageContext, SUBMITACTION, {
                            coApplicantSection: coApplicantSection
                        });
                        if (result.length > 0) {
                            this.listOfAccounts = JSON.parse(JSON.stringify(result));
                            this.setCoApplicantRecord(this.listOfAccounts);
                        }
                    })
                    .catch(error => {
                        this.isLoading = false;
                        this.handleErrorMessage(error);
                    })
            }
        }
    }
    @track matchParameter;
    @track matchValue;
    @track matchDateOfBirth;
    @track alreadyduplicatefound = false;
    @track applicantAccountDup = false;
    @track newListofaccount;
    checkduplicate(event) {
        var foundelement = this.listOfAccounts.find(ele => ele.objeAcc.Id == event.target.dataset.id);
        let index = this.listOfAccounts.findIndex(ele => ele.objeAcc.Id == event.target.dataset.id);
        if (event.target.name === 'Aadhar_Number__c' || event.target.name === 'SalesLAadharNumber') {
            this.matchParameter = 'Aadhar Number';
            if (this.LAadharNumber == undefined || this.LAadharNumber == null) {
                this.matchValue = null;
            } else {
                if (this.LAadharNumber.length == 12) {
                    this.aadharLastFour = this.LAadharNumber.slice(-4);
                    this.matchValue = 'XXXXXXXX' + this.aadharLastFour;
                }else if (this.LAadharNumber.length == 4) {
                    this.matchValue = 'XXXXXXXX' + this.LAadharNumber;
                }else {
                    this.matchValue = null;
                }
            }
        }else if (event.target.name === 'PAN_Number__c') {
            this.matchParameter = 'PAN Number';
            this.matchValue = event.target.value;
        }else if (event.target.name === 'Passport_Number__c') {
            this.matchParameter = 'Passport Number';
            this.matchValue = event.target.value;
        }else if (event.target.name === 'Driving_License_Number__c') {
            this.matchParameter = 'Driving License Number';
            this.matchValue = event.target.value;
        }else if (event.target.name === 'Voter_ID__c') {
            this.matchParameter = 'Voter ID';
            this.matchValue = event.target.value;
        }
        duplicateAccount({ 'duplicateParameter': this.matchParameter, 'duplicateValue': this.matchValue, 'matchDOB': this.LDateOfBirth })
            .then((result) => {
                let randomId = Math.random() * 16;
                this.duplicateAccountResult = JSON.stringify(result);
                if (result != null) {
                    if (result.objeAcc.Id == this.applicantAccountId) {
                        this.showToast("Error!!", 'Applicant and Co-Applicant details cannot be same. Kindly Crosscheck', "Error")
                        this.listOfAccounts.forEach((account) => {
                            account['applicantAccountDup'] = true;
                        });
                    } else if ((foundelement.objeAcc.Id != result.objeAcc.Id) && (!isNaN(foundelement.objeAcc.Id)) &&
                        (foundelement.alreadyduplicatefound == false || foundelement.alreadyduplicatefound == undefined)) {
                        this.listOfAccounts[index] = result;
                        this.listOfAccounts[index].objApplicant.Id = randomId;
                        if (this.listOfAccounts[index].objeAcc.Aadhar_Number__c == this.matchValue) {
                            this.showToast("Info!!", 'Exisitng account found With your Aadhar Number', "info")
                        } else if (this.listOfAccounts[index].objeAcc.PAN_Number__c == this.matchValue) {
                            this.showToast("Info!!", 'Exisitng account found With your PAN Number', "info")
                        } else if (this.listOfAccounts[index].objeAcc.Passport_Number__c == this.matchValue) {
                            this.showToast("Info!!", 'Exisitng account found With your Passport Number', "info")
                        } else if (this.listOfAccounts[index].objeAcc.Driving_License_Number__c == this.matchValue) {
                            this.showToast("Info!!", 'Exisitng account found With your Driving license Number', "info")
                        } else if (this.listOfAccounts[index].objeAcc.Voter_ID__c == this.matchValue) {
                            this.showToast("Info!!", 'Exisitng account found With your Voter Id', "info")
                        }
                        this.listOfAccounts[index].alreadyduplicatefound = true;

                        if (this.listOfAccounts[index].objApplicant.Type__c == 'CoApplicant') {
                            this.listOfAccounts[index].ShowDemography = true;
                        }else {
                            this.listOfAccounts[index].ShowDemography = false;
                        }
                        if (this.isSalesUser == false) {
                            if (this.listOfAccounts[index].objeAcc.Aadhar_Number__c != undefined) {
                                this.listOfAccounts[index].objeAcc.makeadhardisable = true;
                                this.listOfAccounts[index].hideBasicSection = true;
                            } else {
                                this.listOfAccounts[index].objeAcc.makeadhardisable = false;
                            }
                        } else if (this.isSalesUser == true) {
                            if (this.listOfAccounts[index].objeAcc.Aadhar_Number__c != undefined) {
                                this.listOfAccounts[index].objeAcc.salessmakeadhardisable = true;
                                this.listOfAccounts[index].hideBasicSection = true;
                            } else {
                                this.listOfAccounts[index].objeAcc.salessmakeadhardisable = false;
                            }
                        }
                        if (this.listOfAccounts[index].objeAcc.PAN_Number__c != undefined) {
                            this.listOfAccounts[index].objeAcc.makepandisable = true;

                        } else {
                            this.listOfAccounts[index].objeAcc.makepandisable = false;
                        }
                        if (this.listOfAccounts[index].objeAcc.Passport_Number__c != undefined) {
                            this.listOfAccounts[index].objeAcc.makepassportdisable = true;
                        } else {
                            this.listOfAccounts[index].objeAcc.makepassportdisable = false;
                        }
                        if (this.listOfAccounts[index].objeAcc.Passport_File_Number__c != undefined) {
                            this.listOfAccounts[index].objeAcc.makepassportFiledisable = true;
                        } else {
                            this.listOfAccounts[index].objeAcc.makepassportFiledisable = false;
                        }
                        if (this.listOfAccounts[index].objeAcc.Driving_License_Number__c != undefined) {
                            this.listOfAccounts[index].objeAcc.makedrivingdisable = true;
                        } else {
                            this.listOfAccounts[index].objeAcc.makedrivingdisable = false;
                        }
                        if (this.listOfAccounts[index].objeAcc.Voter_ID__c != undefined) {
                            this.listOfAccounts[index].objeAcc.makevoteriddisable = true;
                        } else {
                            this.listOfAccounts[index].objeAcc.makevoteriddisable = false;
                        }
                        if (this.listOfAccounts[index].objeAcc.FirstName != undefined) {
                            this.listOfAccounts[index].objeAcc.makenamedisable = true;
                        } else {
                            this.listOfAccounts[index].objeAcc.makenamedisable = false;
                        }
                        if (this.listOfAccounts[index].objeAcc.Gender__c != undefined) {
                            this.listOfAccounts[index].objeAcc.makeGenderdisable = true;
                        } else {
                            this.listOfAccounts[index].objeAcc.makeGenderdisable = false;
                        }
                        if (this.listOfAccounts[index].objeAcc.MiddleName != undefined) {
                            this.listOfAccounts[index].objeAcc.makemiddlenamedisable = true;
                        } else {
                            this.listOfAccounts[index].objeAcc.makemiddlenamedisable = false;
                        }
                        if (this.listOfAccounts[index].objeAcc.LastName != undefined) {
                            this.listOfAccounts[index].objeAcc.makelastnamedisable = true;
                        } else {
                            this.listOfAccounts[index].objeAcc.makelastnamedisable = false;
                        }
                        if (this.listOfAccounts[index].appPermanentAdd.Same_as_Current_Address__c != undefined) {
                            this.listOfAccounts[index].appPermanentAdd.makePermanentAddProofdisabled = true;
                        } else {
                            this.listOfAccounts[index].appPermanentAdd.makePermanentAddProofdisabled = false;
                        }
                        if (this.listOfAccounts[index].objApplicant.Aadhar_Verified__c == true) {
                            this.listOfAccounts[index].showButtonAadhar = false;
                        } else {
                            this.listOfAccounts[index].showButtonAadhar = true;
                        }
                        if (this.listOfAccounts[index].objApplicant.Pan_verified__c == true) {
                            this.listOfAccounts[index].panTemplate = false;
                        } else {
                            this.listOfAccounts[index].panTemplate = true;
                        }
                        if (this.listOfAccounts[index].objeAcc.CKYC_Number__c != undefined) {
                            this.listOfAccounts[index].objeAcc.makeCKYCdisable = true;
                        } else {
                            this.listOfAccounts[index].objeAcc.makeCKYCdisable = false;
                        }
                        if (this.listOfAccounts[index].objeAcc.NREG_Number__c != undefined) {
                            this.listOfAccounts[index].objeAcc.makeNREGdisable = true;
                        } else {
                            this.listOfAccounts[index].objeAcc.makeNREGdisable = false;
                        }
                        if (this.listOfAccounts[index].objeAcc.Date_of_Birth__c != undefined) {
                            this.listOfAccounts[index].objeAcc.makedobdisable = true;
                        } else {
                            this.listOfAccounts[index].objeAcc.makedobdisable = false;
                        }
                    } else {
                        this.showToast("Error!!", `An account exists with the ${this.matchParameter} provided. Kindly crosscheck`, "Error")
                        this.listOfAccounts.forEach((account) => {
                            account['errorMsgForDuplicate'] = true;
                            account['matchValue'] = this.matchValue;
                        });
                    }
                }

            })
            .catch((error) => {
            })
    }
    @track lastFour;
    @track otpValueAadhar;
    @track verifiedbuttonAadhar = false;
    @track firstEightAadhar;
    @track coAadharStaus = true;
    @track Fullaadhar;
    @track buttonStylePan = 'display:none';
    @track sumScore;
    @track sumScorePercent;
    @track verifiedPan;
    @track matchText;

    setCoApplicantRecord(listOfAccounts) {
        var salesUserValue = this.isSalesUser;
        listOfAccounts.forEach(function (account) {
            try {
                account['ShowDemography'] = account.objApplicant.Type__c === 'CoApplicant' ? true : false;

                if (salesUserValue == false) {
                    account.objeAcc['makeadhardisable'] = account.objeAcc.Aadhar_Number__c !== undefined ? true : false;
                    account['hideBasicSection'] = account.objeAcc.Aadhar_Number__c !== undefined ? true : false;
                } else if (salesUserValue == true) {
                    account.objeAcc['salessmakeadhardisable'] = account.objeAcc.Aadhar_Number__c !== undefined ? true : false;
                    account['hideBasicSection'] = account.objeAcc.Aadhar_Number__c !== undefined ? true : false;
                }
                if (account.objeAcc.PAN_Number__c != undefined) {
                    if(account.objeAcc.PAN_Number__c != ''){
                        account.objeAcc['makepandisable'] = true;
                    }
                } else {
                    account.objeAcc['makepandisable'] = false;
                }
                if (account.objeAcc.Passport_Number__c != undefined) {
                    if(account.objeAcc.Passport_Number__c != ''){
                        account.objeAcc['makepassportdisable'] = true;
                    }
                } else {
                    account.objeAcc['makepassportdisable'] = false;
                }

                if (account.objeAcc.Driving_License_Number__c != undefined) {
                    if(account.objeAcc.Driving_License_Number__c != ''){
                        account.objeAcc['makedrivingdisable'] = true;
                    }
                } else {
                    account.objeAcc['makedrivingdisable'] = false;
                }

                account.objeAcc['makevoteriddisable'] = account.objeAcc.Voter_ID__c !== undefined ? true : false;
                account.objeAcc['makeCKYCdisable'] = account.objeAcc.CKYC_Number__c !== undefined ? true : false;
                account.objeAcc['makeNREGdisable'] = account.objeAcc.NREG_Number__c !== undefined ? true : false;
                account.objeAcc['makenamedisable'] = account.objeAcc.FirstName !== undefined ? true : false;
                account.objeAcc['makelastnamedisable'] = account.objeAcc.LastName !== undefined ? true : false;
                account.appPermanentAdd['makePermanentAddProofdisabled'] = account.appPermanentAdd.Same_as_Current_Address__c;              
                account['ShowFieldsRelationWithAppliIfOther'] = account.objApplicant.Relation_with_applicant__c === 'OTHER';
                account.objeAcc['makedobdisable'] = account.objeAcc.Date_of_Birth__c !== undefined ? true : false;

                if (account.objeAcc.MiddleName != undefined) {
                    if(account.objeAcc.MiddleName != ''){
                        account.objeAcc['makemiddlenamedisable'] = true;
                    }
                } else {
                    account.objeAcc['makemiddlenamedisable'] = false;
                }

                if(account.objeAcc.PersonMobilePhone != undefined){
                    if(account.objApplicant.Mobile_Number_Verified__c == true){
                        account.objeAcc['verifiedMob'] = true;
                        account.objeAcc['mobileStatus'] = true;
                        account['showverifyMobileButton'] = false;
                        account.objeAcc.buttonStyleMob = 'display:none';
                    }else{
                        account.objeAcc.buttonStyleMob = 'display:block';
                        account['showverifyMobileButton'] = true;
                    }
                }
                
                if(account.objeAcc.PersonEmail != undefined){
                    if(account.objApplicant.Email_Verified__c == true){
                        account.objeAcc['verified'] = true;
                        account.objeAcc['emailStatus'] = true;
                        account['showverifyEmailButton'] = false;
                        account.objeAcc.buttonStyle = 'display:none';
                    }else{
                        account.objeAcc.buttonStyle = 'display:block';
                        account['showverifyEmailButton'] = true;
                    }
                }
                
            } catch (e) {
            }
        });
    }

    @api dmsNames;
    doc23;
    doc23name;
    aadharCoapp;
    uploadAadhar(event) {
        var foundelement = this.listOfAccounts.find(ele => ele.objeAcc.Id == event.target.dataset.id);
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        const fileSize = file.size / (1024 * 1024);
        if (fileSize > 2.5) {
            this.showToast("Error!!", "File size exceeds the maximum limit of 2.5 MB", "Error");
            return;
        } else if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            this.showToast("Error!!", "Please upload file in .png ,.jpg, .jpeg and.pdf format", "Error")
            this.doc23 = false;
            foundelement.aadharList = [];
        } else {
            const docType = 'AADHAAR';
            this.doc23 = true;
            let file = event.target.files[0]
            this.doc23name = file.name;
            const fileName = file.name;
            foundelement.aadharList = [file.name];
            this.openFrontfileUpload(event, fileName, docType);
        }

        // Update the listOfAccounts
        const updatedListOfAccounts = this.listOfAccounts.map(item => {
            if (item.objeAcc.Id === foundelement.objeAcc.Id) {
                return foundelement;
            }
            return item;
        });
        this.listOfAccounts = updatedListOfAccounts;
    }

    doc28;
    doc28name;
    panCoapp;
    uploadPAN(event) {
        var foundelement = this.listOfAccounts.find(ele => ele.objeAcc.Id == event.target.dataset.id);
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        const fileSize = file.size / (1024 * 1024);
        if (fileSize > 2.5) {
            this.showToast("Error!!", "File size exceeds the maximum limit of 2.5 MB", "Error");
            return;
        } else if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            this.showToast("Error!!", "Please upload file in .png ,.jpg, .jpeg and.pdf format", "Error")
            this.doc28 = false;
            foundelement.panList = [];
        } else {
            this.coAppliPan = false;
            const docType = 'PAN';
            this.doc28 = true;
            let file = event.target.files[0]
            this.doc28name = file.name;
            foundelement.panList = [file.name];
            const fileName = file.name;
            this.openFrontfileUpload(event, fileName, docType);
        }

        const updatedListOfAccounts = this.listOfAccounts.map(item => {
            if (item.objeAcc.Id === foundelement.objeAcc.Id) {
                return foundelement;
            }
            return item;
        });
        this.listOfAccounts = updatedListOfAccounts;
    }

    passportdoc;
    passportdocname;
    passPortCoapp;
    uploadPassport(event) {
        var foundelement = this.listOfAccounts.find(ele => ele.objeAcc.Id == event.target.dataset.id);
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        const fileSize = file.size / (1024 * 1024);
        if (fileSize > 2.5) {
            this.showToast("Error!!", "File size exceeds the maximum limit of 2.5 MB", "Error");
            return;
        } else if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            this.showToast("Error!!", "Please upload file in .png ,.jpg, .jpeg and.pdf format", "Error")
            this.passportdoc = false;
            foundelement.passportList = [];
        } else {
            const docType = 'PASSPORT';
            this.passportdoc = true;
            let file = event.target.files[0]
            this.passportdocname = file.name;
            foundelement.passportList = [file.name];
            const fileName = file.name;
            this.openFrontfileUpload(event, fileName, docType);
        }

        const updatedListOfAccounts = this.listOfAccounts.map(item => {
            if (item.objeAcc.Id === foundelement.objeAcc.Id) {
                return foundelement;
            }
            return item;
        });
        this.listOfAccounts = updatedListOfAccounts;
    }

    ocrDocumentRecords = [];
    @track AppliAccID;
    @track currentId;
    @track accountdupcheckId;
    @track newAccountCreated = false;
    @track objApplicantId;
    openFrontfileUpload(event, fileName, docType) {
        var foundelement = this.listOfAccounts.find(ele => ele.objeAcc.Id == event.target.dataset.id);
        
        this.currentId = event.target.dataset.id;
        if (foundelement.objeAcc.Aadhar_Number__c.length == 12) {
            this.aadharLastFour = foundelement.objeAcc.Aadhar_Number__c.slice(-4);
        } else {
            this.aadharLastFour = foundelement.objeAcc.Aadhar_Number__c;
        }
        if (isNaN(foundelement.objeAcc.Id)) {
            this.AppliAccID = foundelement.objeAcc.Id;
        } else {
            this.AppliAccID = null;
        }
        if (isNaN(foundelement.objApplicant.Id)) {
            this.objApplicantId = foundelement.objApplicant.Id;
        } else {
            this.objApplicantId = null;
        }
        let file = event.target.files[0]
        let reader = new FileReader()
        reader.onload = () => {
            let base64 = reader.result.split(',')[1]
            let fullName = fileName;
            this.isLoading = true;
            KarzaKycOcr({
                leadId: this.leadRecordId,
                accId: this.AppliAccID,
                base64: base64,
                fileName: fullName,
                filedocType: docType,
                existingAadhar: this.aadharLastFour,
                existingPAN: foundelement.objeAcc.PAN_Number__c,
                existingVoter: foundelement.objeAcc.Voter_ID__c,
                exisitngPassport: foundelement.objeAcc.Passport_Number__c,
                existingDL: foundelement.objeAcc.Driving_License_Number__c,
                applicantType: 'CoApplicant',
                existingapplicantId: this.objApplicantId,
                coApplicantData: this.listOfAccounts
            })
                .then(async (result) => {
                    this.isLoading = false;
                    let responseObj = result;
                    if (responseObj.apistatusCode == 101) {
                        this.LDateOfBirth = responseObj.leadDOB;
                        this.accountdupcheckId = responseObj.accountId;
                        if (responseObj.newAccountCreated == true) {
                            this.newAccountCreated = true;
                        } else {
                            this.newAccountCreated = false;
                        }
                        if (responseObj.kycNameMatch == false) {
                            this.showToast("Error!!", "Uploaded Document Names does not match. Kindly Crosscheck & Upload correct document", "Error")
                        } else if (responseObj.kycAlreadyPresen == true && responseObj.apiDocumentType == 'AADHAAR') {
                            this.showToast("Error!!", "Aadhar Number already present. Please Crosscheck", "Error")
                        } else if (responseObj.kycAlreadyPresen == true && responseObj.apiDocumentType == 'PAN') {
                            this.showToast("Error!!", "PAN Number already present. Please Crosscheck", "Error")
                        } else if (responseObj.kycAlreadyPresen == true && responseObj.apiDocumentType == 'PASSPORT') {
                            this.showToast("Error!!", "Passport Number already present. Please Crosscheck", "Error")
                        }else if (responseObj.apiDocumentType == 'AADHAAR') {
                            this.apiaadharLastFour = responseObj.leadAadharNumber.slice(-4);
                            this.matchParameter = 'Aadhar Number';
                            this.matchValue = 'XXXXXXXX' + this.apiaadharLastFour;
                            this.checkOCRDuplicate(this.matchParameter, this.matchValue, this.LDateOfBirth)
                                .then(() => {
                                    if (this.matchParameterDuplicate == true) {
                                    }else if (this.aadharLastFour != this.apiaadharLastFour) {
                                        if (this.aadharLastFour == '' || this.aadharLastFour == undefined) {                                
                                            this.createAadharRecord(responseObj);
                                        } else {
                                            this.showToast("Error!!", "Uploaded Aadhar number does not match. Kindly Crosscheck & Upload correct document", "Error")
                                        }
                                    } else {
                                        this.createAadharRecord(responseObj);
                                    }
                                })
                                .catch((error) => {
                                });
                        } else if (responseObj.apiDocumentType == 'PAN') {
                            this.matchParameter = 'PAN Number';
                            this.matchValue = responseObj.apiPANNumber;
                            this.checkOCRDuplicate(this.matchParameter, this.matchValue, this.LDateOfBirth)
                                .then(() => {
                                    if (this.matchParameterDuplicate == true) {
                                    }else if (foundelement.objeAcc.PAN_Number__c != responseObj.apiPANNumber) {
                                        if (foundelement.objeAcc.PAN_Number__c == '' || foundelement.objeAcc.PAN_Number__c == undefined) {
                                            this.setRecord(responseObj);
                                        } else {
                                            this.showToast("Error!!", "Uploaded PAN number does not match. Kindly Crosscheck & Upload correct document", "Error")
                                        }
                                    } else {
                                        this.setRecord(responseObj);
                                    }
                                })
                                .catch((error) => {
                                });
                        } else if (responseObj.apiDocumentType == 'VOTER') {
                            this.matchParameter = 'Voter ID';
                            this.matchValue = responseObj.apiVoterNumber;

                            this.checkOCRDuplicate(this.matchParameter, this.matchValue, this.LDateOfBirth)
                                .then(() => {
                                    if (this.matchParameterDuplicate == true) {
                                    }else if (foundelement.objeAcc.Voter_ID__c != responseObj.apiVoterNumber) {
                                        if (foundelement.objeAcc.Voter_ID__c == undefined || foundelement.objeAcc.Voter_ID__c == '') {
                                            this.setRecord(responseObj);
                                        } else {
                                            this.showToast("Error!!", "Uploaded Voter Id does not match. Kindly Crosscheck & Upload correct document", "Error")
                                        }
                                    } else {
                                        this.setRecord(responseObj);
                                    }
                                })
                                .catch((error) => {
                                });

                        } else if (responseObj.apiDocumentType == 'PASSPORT') {
                            this.matchParameter = 'Passport Number';
                            this.matchValue = responseObj.apiPassportNumber;
                            this.checkOCRDuplicate(this.matchParameter, this.matchValue, this.LDateOfBirth)
                                .then(() => {
                                    if (this.matchParameterDuplicate == true) {
                                    }else if (foundelement.objeAcc.Passport_Number__c != responseObj.apiPassportNumber) {
                                        if (foundelement.objeAcc.Passport_Number__c == undefined || foundelement.objeAcc.Passport_Number__c == '') {
                                            this.setRecord(responseObj);
                                        } else {
                                            this.showToast("Error!!", "Uploaded Passport Number does not match. Kindly Crosscheck & Upload correct document", "Error")
                                        }
                                    } else {
                                        this.setRecord(responseObj);
                                    }
                                })
                                .catch((error) => {
                                });
                        } else if (responseObj.apiDocumentType == 'DL') {
                            this.matchParameter = 'Driving License Number';
                            this.matchValue = responseObj.apiDLNumber;

                            this.checkOCRDuplicate(this.matchParameter, this.matchValue, this.LDateOfBirth)
                                .then(() => {
                                    if (this.matchParameterDuplicate == true) {
                                    }else if (foundelement.objeAcc.Driving_License_Number__c != responseObj.apiDLNumber) {
                                        if (foundelement.objeAcc.Driving_License_Number__c == undefined || foundelement.objeAcc.Driving_License_Number__c == '') {
                                            this.setRecord(responseObj);
                                        } else {
                                            this.showToast("Error!!", "Uploaded Driving Licence does not match. Kindly Crosscheck & Upload correct document", "Error")
                                        }
                                    } else {
                                        this.setRecord(responseObj);
                                    }
                                })
                                .catch((error) => {
                                });
                        }
                    } else if (responseObj.apistatusCode == 102) {
                        this.showToast("Error!!", "Error Uploading File. Kindly Crosscheck the document and upload", "Error")
                    } else {                        
                        this.showToast("Error!!", 'Your request cannot be processed due to '+responseObj.apiError+'. Please contact Admin' , "Error")                    
                    }
                }).catch((error) => {
                    this.isLoading = false;
                    this.appdoc1 = false;
                })
        };
        reader.readAsDataURL(file);
    }
    async createAadharRecord(responseObj) {
        var foundelement = this.listOfAccounts.find(ele => ele.objeAcc.Id == this.currentId);
        if (foundelement.objeAcc.Aadhar_Number__c == '' || foundelement.objeAcc.Aadhar_Number__c == undefined) {
            if (this.isSalesUser == false) {
                foundelement.objeAcc.Aadhar_Number__c = 'XXXXXXXX' + this.apiaadharLastFour;
                foundelement.objeAcc.makeadhardisable = true;
            } else if (this.isSalesUser == true) {
                foundelement.objeAcc.Aadhar_Number__c = 'XXXXXXXX' + this.apiaadharLastFour;
                foundelement.objeAcc.salessmakeadhardisable = true;
            }
            foundelement.hideBasicSection = true;
        }
        foundelement.objeAcc.FirstName = responseObj.leadFirstName !== undefined ? responseObj.leadFirstName : foundelement.objeAcc.FirstName;
        foundelement.objeAcc.makenamedisable = foundelement.objeAcc.makenamedisable === true || responseObj.leadFirstName !== undefined;
        if (responseObj.leadLastName == undefined) {
            if (responseObj.leadMiddleName != null) {
                foundelement.objeAcc.LastName = responseObj.leadMiddleName;
                foundelement.objeAcc.makelastnamedisable = true;
            }
        } else {
            foundelement.objeAcc.MiddleName = responseObj.leadMiddleName;
            foundelement.objeAcc.LastName = responseObj.leadLastName;
            foundelement.objeAcc.makemiddlenamedisable = true;
            foundelement.objeAcc.makelastnamedisable = true;
        }
        foundelement.appDemography.Father_s_First_Name__c = responseObj.leadFatherFirstName !== undefined ? responseObj.leadFatherFirstName : foundelement.appDemography.Father_s_First_Name__c;
    
        foundelement.objeAcc.Gender__c = responseObj.leadGender !== undefined ? responseObj.leadGender : foundelement.objeAcc.Gender__c;
        foundelement.objeAcc.makeGenderdisable = foundelement.objeAcc.makeGenderdisable === true || responseObj.leadGender !== undefined;

        foundelement.objeAcc.Date_of_Birth__c = responseObj.leadDOB !== undefined ? responseObj.leadDOB : foundelement.objeAcc.Date_of_Birth__c;
        foundelement.objeAcc.makedobdisable = foundelement.objeAcc.makedobdisable === true || responseObj.leadDOB !== undefined;

        foundelement.objeAcc.Id = responseObj.accountId !== undefined ? responseObj.accountId : foundelement.objeAcc.Id;

        foundelement.objApplicant.Id = responseObj.applicantRecordID !== undefined ? responseObj.applicantRecordID : foundelement.objApplicant.Id;

        foundelement.objeAcc.PAN_Number__c = responseObj.leadPANNumber !== undefined ? responseObj.leadPANNumber : foundelement.objeAcc.PAN_Number__c;
        foundelement.objeAcc.makepandisable = foundelement.objeAcc.makepandisable === true || responseObj.leadPANNumber !== undefined;

        foundelement.objeAcc.Passport_Number__c = responseObj.leadPassportNumber !== undefined ? responseObj.leadPassportNumber : foundelement.objeAcc.Passport_Number__c;
        foundelement.objeAcc.makepassportdisable = foundelement.objeAcc.makepassportdisable === true || responseObj.leadPassportNumber !== undefined;

        foundelement.objeAcc.Passport_File_Number__c = responseObj.leadPassportFileNumber !== undefined ? responseObj.leadPassportFileNumber : foundelement.objeAcc.Passport_File_Number__c;
        foundelement.objeAcc.makepassportFiledisable = foundelement.objeAcc.makepassportFiledisable === true || responseObj.leadPassportFileNumber !== undefined;

        foundelement.objeAcc.Voter_ID__c = responseObj.leadVoterIdNumber !== undefined ? responseObj.leadVoterIdNumber : foundelement.objeAcc.Voter_ID__c;
        foundelement.objeAcc.makevoteriddisable = foundelement.objeAcc.makevoteriddisable === true || responseObj.leadVoterIdNumber !== undefined;

        foundelement.objeAcc.Driving_License_Number__c = responseObj.leadDLNumber !== undefined ? responseObj.leadDLNumber : foundelement.objeAcc.Driving_License_Number__c;
        foundelement.objeAcc.makedrivingdisable = foundelement.objeAcc.makedrivingdisable === true || responseObj.leadDLNumber !== undefined;

        foundelement.objeAcc.CKYC_Number__c = responseObj.leadCKYCNumber !== undefined ? responseObj.leadCKYCNumber : foundelement.objeAcc.CKYC_Number__c;
        foundelement.objeAcc.makeCKYCdisable = foundelement.objeAcc.makeCKYCdisable === true || responseObj.leadCKYCNumber !== undefined;

        foundelement.objeAcc.NREG_Number__c = responseObj.leadNREGNumber !== undefined ? responseObj.leadNREGNumber : foundelement.objeAcc.NREG_Number__c;
        foundelement.objeAcc.makeNREGdisable = foundelement.objeAcc.makeNREGdisable === true || responseObj.leadNREGNumber !== undefined;

        if (responseObj.leadPinCode != undefined) {
            this.AppliCurrentPincode = responseObj.leadPinCode;
            try {
                const isPinCodeAvailable = await checkPinCodeAvailable({ pin: this.AppliCurrentPincode });
                if (isPinCodeAvailable == true) {
                    const pinResult = await getPin({ pin: this.AppliCurrentPincode });
                    this.areaPinCoode = pinResult.Id;
                    const pincodeResult = await getPincodeRecord({ pincode: this.areaPinCoode });
                    this.AreaPinCodeResult = pincodeResult;
                    foundelement.appCurrentAdd.Pin_Code__c = this.AreaPinCodeResult.Id;
                    foundelement.appCurrentAdd.City__c = this.AreaPinCodeResult.City_Name__c;
                    foundelement.appCurrentAdd.State__c = this.AreaPinCodeResult.State__c;
                    foundelement.appCurrentAdd.Country__c = this.AreaPinCodeResult.Country__c;
                    foundelement.appCurrentAdd.District__c = this.AreaPinCodeResult.Area_Name_Taluka__c;
                    foundelement.appCurrentAdd.Address_Proof__c = 'Aadhar Card';
                }
                if (responseObj.leadCurrentAddress != undefined) {
                    foundelement.appCurrentAdd.Address_1__c = responseObj.leadCurrentAddress;
                } 
                if (responseObj.leadLandmark != undefined) {
                    foundelement.appCurrentAdd.Landmark__c = responseObj.leadLandmark;
                }
            } catch (error) {
                this.errors = error;
                this.isLoading = false;
                this.appdoc1 = true;
            }
        }
        this.showToast("Success!!", "Aadhar Uploded Successfully", "Success")
        foundelement.objeAcc.Name_Reference_From__c = 'Aadhar Card';
        updateKYCAccount({ accountId: foundelement.objeAcc.Id, docType: responseObj.apiDocumentType, value: foundelement.objeAcc.Aadhar_Number__c })
    }

    @track parametervalue;
    async setRecord(responseObj) {
        var foundelement = this.listOfAccounts.find(ele => ele.objeAcc.Id == this.currentId);
        if (responseObj.accountId != undefined) {
            foundelement.objeAcc.Id = responseObj.accountId;
        }
        if (responseObj.applicantRecordID != undefined) {
            foundelement.objApplicant.Id = responseObj.applicantRecordID;
        }
        if (responseObj.leadDOB != undefined) {
            foundelement.objeAcc.Date_of_Birth__c = responseObj.leadDOB;
            foundelement.objeAcc.makedobdisable = true;
        }
        if (foundelement.alreadyduplicatefound == true) {
            if (responseObj.leadLastName != undefined) {
                foundelement.objeAcc.LastName = responseObj.leadLastName;
            }
            if (responseObj.leadFirstName != undefined) {
                foundelement.objeAcc.FirstName = responseObj.leadFirstName;
            }
            if (responseObj.leadMiddleName != undefined) {
                foundelement.objeAcc.MiddleName = responseObj.leadMiddleName;
            }
        }
        if (responseObj.leadAadharNumber != undefined) {
            this.apiaadharLastFour = responseObj.leadAadharNumber.slice(-4);
            foundelement.objeAcc.Aadhar_Number__c = 'XXXXXXXX' + this.apiaadharLastFour;
            foundelement.objeAcc.makeadhardisable = true;
            foundelement.objeAcc.salessmakeadhardisable = true;
            foundelement.hideBasicSection = true;
        }
        if (responseObj.apiPANNumber != undefined) {
            foundelement.objeAcc.PAN_Number__c = responseObj.apiPANNumber;
            foundelement.objeAcc.makepandisable = true;
        } else if (responseObj.leadPANNumber != undefined) {
            foundelement.objeAcc.PAN_Number__c = responseObj.leadPANNumber;
            foundelement.objeAcc.makepandisable = true;
        }
        if (responseObj.apiPassportNumber != undefined) {
            foundelement.objeAcc.Passport_Number__c = responseObj.apiPassportNumber;
            foundelement.objeAcc.makepassportdisable = true;
        } else if (responseObj.leadPassportNumber != undefined) {
            foundelement.objeAcc.Passport_Number__c = responseObj.leadPassportNumber;
            foundelement.objeAcc.makepassportdisable = true;
        }
        if (responseObj.leadPassportFileNumber != undefined) {
            foundelement.objeAcc.Passport_File_Number__c = responseObj.leadPassportFileNumber;
        }
        if (responseObj.apiVoterNumber != undefined) {
            foundelement.objeAcc.Voter_ID__c = responseObj.apiVoterNumber;
            foundelement.objeAcc.makevoteriddisable = true;
        } else if (responseObj.leadVoterIdNumber != undefined) {
            foundelement.objeAcc.Voter_ID__c = responseObj.leadVoterIdNumber;
            foundelement.objeAcc.makevoteriddisable = true;
        }
        if (responseObj.apiDLNumber != undefined) {
            foundelement.objeAcc.Driving_License_Number__c = responseObj.apiDLNumber;
            foundelement.objeAcc.makedrivingdisable = true;
        } else if (responseObj.leadDLNumber != undefined) {
            foundelement.objeAcc.Driving_License_Number__c = responseObj.leadDLNumber;
            foundelement.objeAcc.makedrivingdisable = true;
        }

        foundelement.objeAcc.CKYC_Number__c = responseObj.leadCKYCNumber !== undefined ? responseObj.leadCKYCNumber : foundelement.objeAcc.CKYC_Number__c;
        foundelement.objeAcc.makeCKYCdisable = foundelement.objeAcc.makeCKYCdisable === true || responseObj.leadCKYCNumber !== undefined;

        foundelement.objeAcc.NREG_Number__c = responseObj.leadNREGNumber !== undefined ? responseObj.leadNREGNumber : foundelement.objeAcc.NREG_Number__c;
        foundelement.objeAcc.makeNREGdisable = foundelement.objeAcc.makeNREGdisable === true || responseObj.leadNREGNumber !== undefined;

        if (responseObj.leadPinCode != undefined) {
            this.AppliCurrentPincode = responseObj.leadPinCode;
            try {
                const isPinCodeAvailable = await checkPinCodeAvailable({ pin: this.AppliCurrentPincode });
                if (isPinCodeAvailable == true) {
                    const pinResult = await getPin({ pin: this.AppliCurrentPincode });
                    this.areaPinCoode = pinResult.Id;
                    const pincodeResult = await getPincodeRecord({ pincode: this.areaPinCoode });
                    this.AreaPinCodeResult = pincodeResult;
                    foundelement.appCurrentAdd.Pin_Code__c = this.AreaPinCodeResult.Id;
                    foundelement.appCurrentAdd.City__c = this.AreaPinCodeResult.City_Name__c;
                    foundelement.appCurrentAdd.State__c = this.AreaPinCodeResult.State__c;
                    foundelement.appCurrentAdd.Country__c = this.AreaPinCodeResult.Country__c;
                    foundelement.appCurrentAdd.District__c = this.AreaPinCodeResult.Area_Name_Taluka__c;
                    foundelement.appCurrentAdd.Address_Proof__c = 'Aadhar Card';
                }
                if (responseObj.leadhouse != undefined && responseObj.leadCurrentAddress != undefined) {
                    foundelement.appCurrentAdd.Address_1__c = responseObj.leadhouse + " " + responseObj.leadCurrentAddress;
                } else if (responseObj.leadCurrentAddress != undefined) {
                    foundelement.appCurrentAdd.Address_1__c = responseObj.leadCurrentAddress;
                } else if (responseObj.leadhouse != undefined) {
                    foundelement.appCurrentAdd.Address_1__c = responseObj.leadhouse;
                }
                if (responseObj.leadLandmark != undefined) {
                    foundelement.appCurrentAdd.Landmark__c = responseObj.leadLandmark;
                }
            } catch (error) {
                this.errors = error;
                this.isLoading = false;
                this.appdoc1 = true;
            }
        }
        if (responseObj.apiDocumentType == 'PAN') {
            this.parametervalue = responseObj.apiPANNumber;
            this.showToast("Success!!", "PAN Uploded Successfully", "Success")
        } else if (responseObj.apiDocumentType == 'VOTER') {
            this.showToast("Success!!", "Voter Id Uploded Successfully", "Success")
        } else if (responseObj.apiDocumentType == 'PASSPORT') {
            this.parametervalue = responseObj.apiPassportNumber;
            this.showToast("Success!!", "Passport Uploded Successfully", "Success")
        } else if (responseObj.apiDocumentType == 'DL') {
            this.showToast("Success!!", "Driving Licence Uploded Successfully", "Success")
        }
        updateKYCAccount({ accountId: foundelement.objeAcc.Id, docType: responseObj.apiDocumentType, value: this.parametervalue })
    }

    @track matchParameterDuplicate = false;
    @track dupkcateeteteteresult;
    checkOCRDuplicate(matchParameter, matchValue, LDateOfBirth) {
        return new Promise((resolve, reject) => {
            var foundelement = this.listOfAccounts.find(ele => ele.objeAcc.Id == this.currentId);
            let index = this.listOfAccounts.findIndex(ele => ele.objeAcc.Id == this.currentId);
            duplicateAccount({ 'duplicateParameter': matchParameter, 'duplicateValue': matchValue, 'matchDOB': LDateOfBirth })
                .then((result) => {
                    if (Object.keys(result).length != 0) {
                        if (this.newAccountCreated == false) {
                            if (result.objeAcc.Id == this.applicantAccountId) {
                                this.showToast("Error!!", "Applicant and Co-Applicant details cannot be the same. Kindly Crosscheck", "Error");
                                this.matchParameterDuplicate = true;
                            } else if ((foundelement.objeAcc.Id != result.objeAcc.Id) && (!isNaN(foundelement.objeAcc.Id)) &&
                                (foundelement.alreadyduplicatefound == false || foundelement.alreadyduplicatefound == undefined)) {
                                if (result.objeAcc.Aadhar_Number__c == matchValue) {
                                    this.showToast("Info!!", "Existing account found with your Aadhar Number", "info");
                                    foundelement.alreadyduplicatefound == true;
                                } else if (this.listOfAccounts[index].objeAcc.PAN_Number__c == matchValue) {
                                    this.showToast("Info!!", "Existing account found with your PAN Number", "info");
                                    foundelement.alreadyduplicatefound == true;
                                } else if (this.listOfAccounts[index].objeAcc.Passport_Number__c == matchValue) {
                                    this.showToast("Info!!", "Existing account found with your Passport Number", "info");
                                    foundelement.alreadyduplicatefound == true;
                                } else if (this.listOfAccounts[index].objeAcc.Driving_License_Number__c == matchValue) {
                                    this.showToast("Info!!", "Existing account found with your Driving License Number", "info");
                                    foundelement.alreadyduplicatefound == true;
                                } else if (this.listOfAccounts[index].objeAcc.Voter_ID__c == matchValue) {
                                    this.showToast("Info!!", "Existing account found with your Voter ID", "info");
                                    foundelement.alreadyduplicatefound == true;
                                }
                            } else if (foundelement.objeAcc.Id != result.objeAcc.Id) {
                                this.showToast("Error!!", `An account exists with the ${matchParameter} provided. Kindly crosscheck`, "Error");
                                this.matchParameterDuplicate = true;
                            }
                        }
                    } else {
                        this.matchParameterDuplicate = false;
                    }
                    resolve();
                })
                .catch((error) => {
                    reject(error);
                });
        });
    }

    handleErrorMessage(error) {
        let errorMessage = 'An error occurred';
        if (error.body && error.body.fieldErrors) {
            const fieldErrors = error.body.fieldErrors;
            const firstFieldName = Object.keys(fieldErrors)[0];
            if (fieldErrors[firstFieldName].length > 0) {
                errorMessage = fieldErrors[firstFieldName][0].message;
            }
        } else if (error.pageErrors && error.pageErrors.length > 0) {
            errorMessage = error.pageErrors[0].message;
        } else {
            errorMessage = error.statusText;
        }
        this.showToast("Error!!", errorMessage, "Error")
    }

    handleGetOTPMobile(event) {
        debugger;
        var foundelement = this.listOfAccounts.find(ele => ele.objeAcc.Id == event.target.dataset.id);
        foundelement.objeAcc.verifiedMob = true;
        setTimeout(() => {
            foundelement.objeAcc.verifiedMob = false;
        }, 5000)
        if (foundelement.objeAcc.PersonMobilePhone != "" && foundelement.objeAcc.PersonMobilePhone != undefined) {
            OtpRequestMob({ mobile: foundelement.objeAcc.PersonMobilePhone, consent: 'y', leadId: this.leadRecordId})
                .then((result) => {
                    let responseObj = JSON.parse(result);
                    foundelement.objeAcc.requestIdMob = responseObj.dataResponse['request_id'];
                    if (responseObj.dataResponse['status-code'] == 101) {
                        foundelement.objeAcc.showModalMobile = true;
                        this.showToast("Success!!", 'OTP sent successfully', "Success")
                    } else {
                        this.showToast("Error!!", 'Failed to send OTP. Please try again', "Error")
                    }
                })
                .catch((error) => {
                    this.showToast("Error!!", 'Failed to send OTP', "Error")
                });
        }
    }

    handleVerifyMob(event) {
        var foundelement = this.listOfAccounts.find(ele => ele.objeAcc.Id == event.target.dataset.id);
        OtpVerifyMob({ otp: foundelement.objeAcc.otpValueMob, request_Id: foundelement.objeAcc.requestIdMob, leadId: this.leadRecordId })
            .then((result) => {
                let responseObj = JSON.parse(result);
                if (responseObj.dataResponse['status-code'] == 101) {
                    let paramatervalue = 'Mobile';
                    foundelement.objeAcc.showModalMobile = false;
                    foundelement.objeAcc.mobileStatus = true;
                    foundelement.objApplicant.Mobile_Number_Verified__c = true;
                    this.displayTextMob = 'display:block;  color:green; font-weight:bold;'
                    foundelement.objeAcc.buttonStyleMob = 'display:none';
                    foundelement.objeAcc.verifiedMob = true;
                    this.showToast("Success!!", 'Mobile Number Verified', "Success")
                    updateCoapplicantRec({ 'parameter': paramatervalue, 'applicantId': foundelement.objApplicant.Id })
                } else {
                    this.showToast("Error!!", 'Failed to Verify! Please try again', "Error")
                }
            })
            .catch((error) => {
                this.showToast("Error!!", 'Failed to verify OTP', "Error")
            });
    }

    handleOtpforMob(event) {
        var foundelement = this.listOfAccounts.find(ele => ele.objeAcc.Id == event.target.dataset.id);
        foundelement.objeAcc.otpValueMob = event.target.value
    }

    @track showModalMobile = false;
    @track showModal = false;
    @track otpValueMob;
    @track verifiedMob = false;
    @track requestIdMob = '';
    @track displayTextMob = 'display:none;'
    @track buttonStyleMob = 'display:none';
    @track buttonLabelMob = 'Verify Mobile';
    @track errormsg = "";
    @track emailStatus;
    @track mobileStatus;
    @track verified = false;
    @track otpValue;
    @track buttonStyle = 'display:none';
    @track buttonLabel = 'Verify Email';
    @track showverifyMobileButton = false;
    @track showverifyEmailButton = false;

    closeModalMobile(event) {
        var foundelement = this.listOfAccounts.find(ele => ele.objeAcc.Id == event.target.dataset.id);
        foundelement.objeAcc.showModalMobile = false;
        foundelement.objeAcc.otpValueMob = "";
    }

    handleGetOTP(event) {
        var foundelement = this.listOfAccounts.find(ele => ele.objeAcc.Id == event.target.dataset.id);
        foundelement.objeAcc.verified = true;
        setTimeout(() => {
            foundelement.objeAcc.verified = false;
        }, 5000)
        if (foundelement.objeAcc.PersonEmail != undefined && foundelement.objeAcc.PersonEmail != "") {
            OtpRequest({ email: foundelement.objeAcc.PersonEmail, leadId: this.leadRecordId })
                .then((result) => {
                    let responseObj = JSON.parse(result);
                    foundelement.objeAcc.requestIdTemp = responseObj.dataResponse.requestId;
                    if (responseObj.dataResponse.statusCode == 101) {
                        foundelement.objeAcc.showModal = true;
                        this.showToast("Success!!", 'OTP sent successfully', "Success");
                    } else {
                        this.showToast("Error!!", 'Failed to send OTP. Please try again', "Error")
                    }
                })
                .catch((error) => {
                    this.showToast("Error!!", 'Failed to send OTP', "Error")
                });
        }
    }

    closeModal(event) {
        var foundelement = this.listOfAccounts.find(ele => ele.objeAcc.Id == event.target.dataset.id);
        foundelement.objeAcc.showModal = false;
        foundelement.objeAcc.otpValue = "";
    }
    handleOtpValueChange(event) {
        var foundelement = this.listOfAccounts.find(ele => ele.objeAcc.Id == event.target.dataset.id);
        foundelement.objeAcc.otpValue = event.target.value;
    }
    handleVerify(event) {
        var foundelement = this.listOfAccounts.find(ele => ele.objeAcc.Id == event.target.dataset.id);
        OtpVerify({ 'otp': foundelement.objeAcc.otpValue, 'requestId': foundelement.objeAcc.requestIdTemp, leadId: this.leadRecordId })
            .then((result) => {
                let responseObj = JSON.parse(result);
                if (responseObj.dataResponse.statusCode == 101) {
                    let paramatervalue = 'Email';
                    foundelement.objeAcc.showModal = false;
                    foundelement.objeAcc.verified = true;
                    foundelement.objApplicant.Email_Verified__c = true;
                    foundelement.objeAcc.buttonStyle = 'display:none'
                    this.displayText = 'display:block;  color:green; font-weight:bold;'
                    foundelement.objeAcc.emailStatus = true;
                    this.showToast("Success!!", 'Email Verified successfully', "Success");
                    updateCoapplicantRec({ 'parameter': paramatervalue, 'applicantId': foundelement.objApplicant.Id })
                } else {
                    this.showToast("Error!!", 'Please Enter Correct OTP', "Error")
                }
            })
            .catch((error) => {
                this.showToast("Error!!", 'Failed to verify OTP', "Error")
            });
    }
    @track QuesForcoapplicant;
    @track hideshowQuestion = false;
    @track hideshowotherreason = false;
    @track otherReason;
    handlecoapplicantquestion(event) {
        this.QuesForcoapplicant = event.target.value;
        if(this.QuesForcoapplicant == 'Others'){
            this.hideshowotherreason = true;
        }else{
            this.hideshowotherreason = false;
            this.otherReason = '';
        }
    }
    handlechangeotheReason(event) {
        this.otherReason = event.target.value;
    }
}