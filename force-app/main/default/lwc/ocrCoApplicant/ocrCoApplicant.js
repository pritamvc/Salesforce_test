import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import getPincodeRecord from '@salesforce/apex/LoanApplicationFormHelper.getPincodeRecord';
import getCoAppRecords from '@salesforce/apex/LeadCoapplicantEmploymentController.getCoapp';
import saveCoApplicant from '@salesforce/apex/LeadCoapplicantEmploymentController.saveCoApplicant';
import deleteCoApplicant from '@salesforce/apex/LeadCoapplicantEmploymentController.deleteCoApplicant';
import getApplicantAccoutId from '@salesforce/apex/LeadCoapplicantEmploymentController.getAccountIdFromCoApplicant';
import AadharVerification from '@salesforce/apex/DocumentVerification.AadharVerification';
import downloadAadhar from '@salesforce/apex/DocumentVerification.DownloadAadhar';
import panVerification from '@salesforce/apex/DocumentVerification.PanProfile';
import getLeadTotalPercentage from '@salesforce/apex/DocumentVerification.getLeadTotalPercentage';
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
import Relation_with_applicant from '@salesforce/schema/Co_Applicant__c.Relation_with_applicant__c';
import Relation_proof from '@salesforce/schema/Co_Applicant__c.Relationship_Proof__c';
import Is_income from '@salesforce/schema/Co_Applicant__c.Is_Income_Considered_Financial__c';
import Address_Proof from '@salesforce/schema/ContactPointAddress.Address_Proof__c';
import progressBar from '@salesforce/messageChannel/progressBar__c';
import SUBMITACTION from '@salesforce/messageChannel/submit__c';
import { publish, MessageContext } from 'lightning/messageService';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import ProfileName from '@salesforce/schema/User.Profile.Name';
import KarzaKycOcr from '@salesforce/apex/KarzaKycOcrController.getDocumentOcred';
import checkPinCodeAvailable from '@salesforce/apex/QACommunityLeadFormController.checkPinCodeAvailable';
import getPin from '@salesforce/apex/QACommunityLeadFormController.getPin';
import DMS_NAMES from '@salesforce/apex/DocumentNamesDms.DMSNames';

export default class CoapplicantGuarantorChild extends LightningElement {

    @track acceptedFormats = ['.png', '.pdf', '.jpg', '.jpeg'];
    @api leadRecordId;
    @track todaysDate;
    @track isStepOne = true;
    @track isLoading = false; s
    @track currentStep = "1";
    activeSections = [''];
    @track ShowDemography;
    @track showButtonAadhar = false;
    //Show Hide fields
    @track ShowFieldsAppliSpouse = false;
    @track ShowFieldsApplicantCategory = false;
    @track ShowFieldsRelationWithAppliIfOther = false;
    @track ShowFieldsAppliDriveLicDateofExpiry = false;
    @track ShowFieldsCoAppliDriveLicDateofExpiry = false;

    //for kyc section
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

    //For error Message wheen pattern not match
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
    @track isSalesUser;
    @track deleteAccId = '';
    @track showReAadharButton = false;
    @track panTemplate = false;
    @track makePermanentAddProofdisabled = false;
    //@track firstCheck = false;
    @track coapplicantCheck = false;
    @track listOfAccounts;
    timeSpan = 60000;
    event1;

    //progressbar
    @wire(MessageContext)
    messageContext;
    message;

    userId = Id;
    userProfileName;

    //Not used it for Account recordtype
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

    @wire(getObjectInfo, { objectApiName: Applicant })
    objectInfoApp;

    @wire(getPicklistValues, { recordTypeId: '$objectInfoApp.data.defaultRecordTypeId', fieldApiName: Relation_with_applicant })
    RelshipWithAppliPerAccOptions;

    @wire(getPicklistValues, { recordTypeId: '$objectInfoApp.data.defaultRecordTypeId', fieldApiName: Relation_proof })
    RelshipProofPerAccOptions;

    @wire(getPicklistValues, { recordTypeId: '$objectInfoApp.data.defaultRecordTypeId', fieldApiName: Is_income })
    isIncomeConsiderIsFinOptions;

    @wire(getObjectInfo, { objectApiName: Address })
    objectInfoAdd;

    @wire(getPicklistValues, { recordTypeId: '$objectInfoAdd.data.defaultRecordTypeId', fieldApiName: Address_Proof })
    AddProofCurrentPerAccOptions;

    //Get Current login user Profile
    @wire(getRecord, { recordId: Id, fields: [ProfileName] })
    userDetails({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            if (data.fields.Profile.value != null) {
                this.userProfileName = data.fields.Profile.value.fields.Name.value;

                if (this.userProfileName == 'Sales Profile') {
                    this.isSalesUser = true;
                } else {
                    this.isSalesUser = false;
                }
            }
        }
    }

    //Calls when component is loaded
    connectedCallback() {
        this.initData();
        this.getApplicant();
        this.namesRenderDMS();
        this.todaysDate = new Date().toISOString().split('T')[0];
    }

    //Initializing the data
    initData() {
        //Calling to fetch data of co-applicant on load
        getCoAppRecords({ leadId: this.leadRecordId })
            .then(result => {
                let randomId = Math.random() * 16;

                //If we get the data of co-applicant for this lead
                if (result.length > 0) {
                    //debugger;
                    this.listOfAccounts = JSON.parse(JSON.stringify(result));
                    console.log('this.listOfAccounts', this.listOfAccounts);

                    // for (var key in result) {
                    //     // Here key will have index of list of records starting from 0,1,2,....
                    //     options.push({ label: result[key].Account__r.Name, value: result[key].Id, type: result[key].Type__c, accountId: result[key].Account__c, leadId: result[key].lead__c });
                    //     console.log('datatest3' + result[key].Account__r.Name + result[key].Id);
                    //     console.log('datatest33333', options);
                    //     // Here Name and Id are fields from sObject list.

                    // }
                    // let coApplicantCount = 0;
                    // let guarantorCount = 0;
                    // for (var i in options) {
                    //     if (options[i].type === "Guarantor") {
                    //         guarantorCount++;
                    //         options[i].index = guarantorCount;
                    //     }
                    // }
                    // for (var i in options) {
                    //     if (options[i].type === "Co-applicant") {
                    //         coApplicantCount++;
                    //         options[i].index = coApplicantCount;
                    //     }
                    // }

                    // this.TypeOptions = options;

                    //this.firstCheck = true;

                    this.setCoApplicantRecord(this.listOfAccounts);

                }
                else {
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
                            "Id": randomId,
                            "FirstName": "", "MiddleName": "", "LastName": "", "Date_of_Birth__c": "", "PersonMobilePhone": "", "PersonEmail": "",
                            "Gender__c": "", "Marital_Status__c": "", "Passport_Number__c": "", "Aadhar_Number__c": "", "PAN_Number__c": "",
                            "Driving_License_Number__c": "", "Passport_File_Number__c": "", "Passport_Number__c": ""
                        }, "appDemography": { "Id": randomId, "Account__c": "", "Father_s_First_Name__c": "", "Mother_s_First_Name__c": "" }
                    };
                    this.listOfAccounts = [myNewElement];
                }
            }).catch(error => {
                console.log('Error while fetching data from SF:' + JSON.stringify(error));
            });

        //Calling to get check
        getCheck({ leadId: this.leadRecordId })
            .then(result => {
                this.coapplicantCheck = result.Co_applicant_Section__c;

            })
    }

    //Getting Account Id of Appliant
    getApplicant() {
        getApplicantAccoutId({ leadId: this.leadRecordId })
            .then(result => {
                console.log('result accoutnt Id=>' , result);
                if (result.length > 0) {
                    this.applicantAccountId = result;

                }
            })
            .catch(error => {
                console.log('Error while getting Account Id of applicant: ' + JSON.stringify(error));
            });
    }

    //Handle change method for pincode in Current Address
    handlePinCode(event) {
        var foundelement = this.listOfAccounts.find(ele => ele.appCurrentAdd.Id == event.target.dataset.id);
        //If removed then remove from all fields
        if (event.target.value == '') {
            foundelement.appCurrentAdd.Pin_Code__c = '';
            foundelement.appCurrentAdd.City__c = '';
            foundelement.appCurrentAdd.District__c = '';
            foundelement.appCurrentAdd.State__c = '';
            foundelement.appCurrentAdd.Country__c = '';
        }
        //Or get from system and assign to fields
        else {
            getPincodeRecord({ pincode: event.target.value })
                .then(result => {
                    foundelement.appCurrentAdd.Pin_Code__c = result.Id;
                    foundelement.appCurrentAdd.City__c = result.City_Name__c;
                    foundelement.appCurrentAdd.District__c = result.Area_Name_Taluka__c;
                    foundelement.appCurrentAdd.State__c = result.State__c;
                    foundelement.appCurrentAdd.Country__c = result.Country__c;
                })
                .catch(error => {
                    console.log('Error while getting pincode data from system: ' + JSON.stringify(error));
                })
        }
    }

    //Handle change method for pincode in Permanent Address
    handlePinCode1(event) {
        var foundelement = this.listOfAccounts.find(ele => ele.appPermanentAdd.Id == event.target.dataset.id);
        //If removed then remove from all fields
        if (event.target.value == '') {
            foundelement.appPermanentAdd.Pin_Code__c = '';
            foundelement.appPermanentAdd.City__c = '';
            foundelement.appPermanentAdd.District__c = '';
            foundelement.appPermanentAdd.State__c = '';
            foundelement.appPermanentAdd.Country__c = '';
        }
        //Or get from system and assign to fields
        else {
            getPincodeRecord({ pincode: event.target.value })
                .then(result => {
                    foundelement.appPermanentAdd.Pin_Code__c = result.Id;
                    foundelement.appPermanentAdd.City__c = result.City_Name__c;
                    foundelement.appPermanentAdd.District__c = result.Area_Name_Taluka__c;
                    foundelement.appPermanentAdd.State__c = result.State__c;
                    foundelement.appPermanentAdd.Country__c = result.Country__c;
                })
                .catch(error => {
                    console.log('Error while getting pincode data from system: ' + JSON.stringify(error));
                })
        }
    }

    //To Create one new row in table 
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
                "Id": randomId,
                "FirstName": "", "MiddleName": "", "LastName": "", "Date_of_Birth__c": "", "PersonMobilePhone": "", "PersonEmail": "",
                "Gender__c": "", "Marital_Status__c": "", "Passport_Number__c": "", "Aadhar_Number__c": "", "PAN_Number__c": "",
                "Driving_License_Number__c": "", "Passport_File_Number__c": ""
            }, "appDemography": { "Id": randomId, "Account__c": "", "Father_s_First_Name__c": "", "Mother_s_First_Name__c": "" }
        };
        this.listOfAccounts = [...this.listOfAccounts, myNewElement];
    }

    //Method to call createRow
    addNewRow() {
        this.createRow(this.listOfAccounts);
        this.buttonStyleAadhar = "display:none";
        this.aadharInputStyle = "display:none";
        this.buttonStylePan = "display:none";
    }

    //To remove the row from the table
    removeTheRow(event) {
        //Get the Ids of record to delete
        if (isNaN(event.target.dataset.id)) {
            this.deleteAccId = this.deleteAccId + event.target.dataset.id;
        }

        if (this.listOfAccounts.length > 1) {
            this.listOfAccounts.splice(this.listOfAccounts.findIndex(row => row.objeAcc.Id == event.target.dataset.id), 1);
            this.isLoading = true;

            //Call apex method to delete the co-applicant record
            if (this.deleteAccId != '') {
                deleteCoApplicant({ accId: this.deleteAccId, leadId: this.leadRecordId })
                    .then(result => {
                        this.isLoading = false;

                        this.showToast("Success!!", "Deleted Successfully", "Success")

                        if (result.length > 0) {
                            this.listOfAccounts = JSON.parse(JSON.stringify(result));

                            this.setCoApplicantRecord(this.listOfAccounts);
                        }
                    })
                    .catch(error => {
                        this.isLoading = false;
                        console.log('Error while saving data:' + JSON.stringify(error));
                    })
            }
            else {
                this.showToast("Success!!", "Deleted Successfully", "Success")
            }
        }
        this.deleteAccId = '';
    }

    //Handle change method for Account fields
    handlechangeAccount(event) {
        var foundelement = this.listOfAccounts.find(ele => ele.objeAcc.Id == event.target.dataset.id);

        if (event.target.name === 'FirstName') {
            let fieldValue = event.target.value;
            let pattern = /^[a-zA-Z\s]*$/;
            if (!pattern.test(fieldValue)) {
                foundelement.objeAcc.firstnamenotvalid = true;
            } else {
                foundelement.objeAcc.FirstName = event.target.value;
                foundelement.objeAcc.firstnamenotvalid = false;
            }
        }
        else if (event.target.name === 'MiddleName') {
            let fieldValue = event.target.value;
            let pattern = /^[a-zA-Z\s]*$/;
            if (!pattern.test(fieldValue)) {
                foundelement.objeAcc.middlenamenotvalid = true;
            } else {
                foundelement.objeAcc.MiddleName = event.target.value;
                foundelement.objeAcc.middlenamenotvalid = false;
            }
        }
        else if (event.target.name === 'LastName') {
            let fieldValue = event.target.value;
            let pattern = /^[a-zA-Z\s]*$/;
            if (!pattern.test(fieldValue)) {
                foundelement.objeAcc.lastnamenotvalid = true;
            } else {
                foundelement.objeAcc.LastName = event.target.value;
                foundelement.objeAcc.lastnamenotvalid = false;
            }
        }
        else if (event.target.name === 'Date_of_Birth__c') {
            foundelement.objeAcc.Date_of_Birth__c = event.target.value;
            this.LDateOfBirth = foundelement.objeAcc.Date_of_Birth__c;
            this.matchDateOfBirth = this.LDateOfBirth;
        }
        else if (event.target.name === 'PersonMobilePhone') {
            foundelement.objeAcc.PersonMobilePhone = event.target.value;
        }
        else if (event.target.name === 'PersonEmail') {
            foundelement.objeAcc.PersonEmail = event.target.value;
        }
        else if (event.target.name === 'Gender__c') {
            foundelement.objeAcc.Gender__c = event.target.value;
        }
        else if (event.target.name === 'Marital_Status__c') {
            foundelement.objeAcc.Marital_Status__c = event.target.value;
        }
        else if (event.target.name === 'Aadhar_Number__c') {
            foundelement.objeAcc.Aadhar_Number__c = event.target.value;
            this.LAadharNumber = foundelement.objeAcc.Aadhar_Number__c;

            let fieldValue = event.target.value;
            let pattern = /[0-9]{12}/;
            if (!pattern.test(fieldValue)) {
                foundelement.objeAcc.errorAadharInvalid = true;
            } else {
                foundelement.objeAcc.errorAadharInvalid = false;
                foundelement.hideBasicSection = true;
            }
            if (this.LAadharNumber.length === 12 && this.LAadharNumber.slice(0, 4) != "XXXX") {
                this.buttonStyleAadhar = "display:block"
                this.aadharInputStyle = "display:none";
                foundelement.showButtonAadhar = true;
                this.lastFour = this.LAadharNumber.slice(-4);
            } else {
                this.buttonStyleAadhar = "display:none"
                foundelement.showButtonAadhar = false;
            }
            if (this.LAadharNumber.slice(0, 4) === "XXXX") {
                this.aadharInputStyle = "display:block"
                this.buttonStyleAadhar = "display:none"
                foundelement.showReAadharButton = true;
            } else {
                this.aadharInputStyle = "display:none"
                foundelement.showReAadharButton = false;
            }

        }
        else if (event.target.name === 'SalesLAadharNumber') {
            let fieldValue = event.target.value;
            let pattern = /[0-9]{4}/;
            if (!pattern.test(fieldValue)) {
                foundelement.objeAcc.saleserrorAadharInvalid = true;
            } else {
                foundelement.objeAcc.saleserrorAadharInvalid = false;
                foundelement.hideBasicSection = true;
                foundelement.objeAcc.Aadhar_Number__c = event.target.value;
                this.LAadharNumber = foundelement.objeAcc.Aadhar_Number__c;
                this.lastFour = foundelement.objeAcc.Aadhar_Number__c;
            }
        }
        else if (event.target.name === 'PAN_Number__c') {
            foundelement.objeAcc.PAN_Number__c = event.target.value;
            this.PANNumber = foundelement.objeAcc.PAN_Number__c;
            let fieldValue = event.target.value;
            let pattern = /[A-Z]{5}[0-9]{4}[A-Z]{1}$/;
            if (!pattern.test(fieldValue)) {
                foundelement.objeAcc.pannotvalid = true;
                foundelement.panTemplate = false;
            } else {
                foundelement.objeAcc.pannotvalid = false;
                this.buttonStylePan = 'display:block';
                foundelement.panTemplate = true;
            }
            console.log('PANNumber=>' , foundelement.objeAcc.PAN_Number__c);
        }
        else if (event.target.name === 'Passport_File_Number__c') {
            foundelement.objeAcc.Passport_File_Number__c = event.target.value;
            this.passportFileNumber = foundelement.objeAcc.Passport_File_Number__c;
            let fieldValue = event.target.value;
            let pattern = /^[A-Z]{4}[0-9]{8}$/;
            if (!pattern.test(fieldValue)) {
                foundelement.objeAcc.errorPasspostFilrInvalid = true;
            } else {
                foundelement.objeAcc.errorPasspostFilrInvalid = false;
            }
        }
        else if (event.target.name === 'Driving_License_Number__c') {
            foundelement.objeAcc.Driving_License_Number__c = event.target.value;
            this.driveLicenseNumber = foundelement.objeAcc.Driving_License_Number__c;
            let fieldValue = event.target.value;
            let pattern = /[A-Za-z]{2}[\d\s\-]{14}/;
            if (!pattern.test(fieldValue)) {
                foundelement.objeAcc.errorDLInvalid = true;
            } else {
                foundelement.objeAcc.errorDLInvalid = false;
            }

        }
        else if (event.target.name === 'Passport_Number__c') {
            foundelement.objeAcc.Passport_Number__c = event.target.value;
            this.passportNumber = foundelement.objeAcc.Passport_Number__c;
            let fieldValue = event.target.value;
            let pattern = /^[A-Z]{1}[0-9]{7}$/;
            if (!pattern.test(fieldValue)) {
                foundelement.objeAcc.errorPassportInvalid = true;
            } else {
                foundelement.objeAcc.errorPassportInvalid = false;
                
            }

        }
        else if (event.target.name === 'Voter_ID__c') {
            foundelement.objeAcc.Voter_ID__c = event.target.value;
            this.voterId = foundelement.objeAcc.Voter_ID__c;
        }
        else if (event.target.name === 'NREGNumber') {
            let fieldValue = event.target.value;
            let pattern = /[A-Z]{2}-\d{2}-\d{3}-\d{3}-\d{3}\/\d{3}/;
            if (!pattern.test(fieldValue)) {
                foundelement.objeAcc.errorNREGInvalid = true;
            } else {
                foundelement.objeAcc.errorNREGInvalid = false;
                foundelement.objeAcc.NREG_Number__c = event.target.value;
            }
        }
        else if (event.target.name === 'CKYCNumber') {
            let fieldValue = event.target.value;
            let pattern = /[0-9]{14}/;
            if (!pattern.test(fieldValue) || fieldValue < 14) {
                foundelement.objeAcc.errorCKYCInvalid = true;
            } else {
                foundelement.objeAcc.errorCKYCInvalid = false;
                foundelement.objeAcc.CKYC_Number__c = event.target.value;
            }
        }
    }

    //Handle change method for Demography fields
    handleChangeDemo(event) {
        var foundelement = this.listOfAccounts.find(ele => ele.appDemography.Id == event.target.dataset.id);
        if (event.target.name == 'Father_s_First_Name__c') {
            foundelement.appDemography.Father_s_First_Name__c = event.target.value;
        }
        else if (event.target.name == 'Mother_s_First_Name__c') {
            foundelement.appDemography.Mother_s_First_Name__c = event.target.value;
        }
    }

    //Handle change method for Applicant fields
    handleApplicantCategory(event) {
        var foundelement = this.listOfAccounts.find(ele => ele.objApplicant.Id == event.target.dataset.id);
        if (this.coAadharStaus == true) {
            foundelement.objApplicant.Aadhar_Verified__c = this.coAadharStaus;
        }
        if (event.target.name == "ApplicantCategory") {
            foundelement.objApplicant.Type__c = event.target.value;
            if (event.target.value === 'Co-applicant') {
                foundelement.ShowDemography = true;
            }
            else {
                foundelement.ShowDemography = false;
            }
        }

        else if (event.target.name === 'Relation_with_applicant__c') {
            foundelement.objApplicant.Relation_with_applicant__c = event.target.value;
            if (event.target.value === 'OTHER') {
                foundelement.ShowFieldsRelationWithAppliIfOther = true;
            }
            else {
                foundelement.ShowFieldsRelationWithAppliIfOther = false;
            }
        }
        else if (event.target.name === 'Relation_others__c') {
            foundelement.objApplicant.Relation_others__c = event.target.value;
        }
        else if (event.target.name === 'Relationship_Proof__c') {
            foundelement.objApplicant.Relationship_Proof__c = event.target.value;
        }
        else if (event.target.name === 'Is_Income_Considered_Financial__c') {
            foundelement.objApplicant.Is_Income_Considered_Financial__c = event.target.value;
        }
        else {
            this.ShowFieldsApplicantCategory = false;
        }
    }

    //Handle change method for Current address fields
    handlechangeCurrent(event) {
        var foundelement = this.listOfAccounts.find(ele => ele.appCurrentAdd.Id == event.target.dataset.id);

        if (event.target.name === 'Address_Proof__c') {
            foundelement.appCurrentAdd.Address_Proof__c = event.target.value;
        }
        else if (event.target.name === 'Current_Address__c') {
            foundelement.appCurrentAdd.Address_1__c = event.target.value;
        }
        else if (event.target.name === 'City__c') {
            foundelement.appCurrentAdd.City__c = event.target.value;
        }
        else if (event.target.name === 'District__c') {
            foundelement.appCurrentAdd.District__c = event.target.value;
        }
        else if (event.target.name === 'State__c') {
            foundelement.appCurrentAdd.State__c = event.target.value;
        }
        else if (event.target.name === 'Country__c') {
            foundelement.appCurrentAdd.Country__c = event.target.value;
        }
        else if (event.target.name === 'Landmark__c') {
            foundelement.appCurrentAdd.Landmark__c = event.target.value;
        }
        else if (event.target.name === 'Years_In_The_Address__c') {
            foundelement.appCurrentAdd.Years_In_The_Address__c = event.target.value;
        }
    }

    //Handle change method for Permanent address fields
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
            }
            else {
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
        }
        else if (event.target.name === 'Address_Proof__c') {
            foundelement.appPermanentAdd.Address_Proof__c = event.target.value;
        }
        else if (event.target.name === 'Permanent_Address__c') {
            foundelement.appPermanentAdd.Address_1__c = event.target.value;
        }
        else if (event.target.name === 'City__c') {
            foundelement.appPermanentAdd.City__c = event.target.value;
        }
        else if (event.target.name === 'District__c') {
            foundelement.appPermanentAdd.District__c = event.target.value;
        }
        else if (event.target.name === 'State__c') {
            foundelement.appPermanentAdd.State__c = event.target.value;
        }
        else if (event.target.name === 'Country__c') {
            foundelement.appPermanentAdd.Country__c = event.target.value;
        }
        else if (event.target.name === 'Landmark__c') {
            foundelement.appPermanentAdd.Landmark__c = event.target.value;
        }
        else if (event.target.name === 'Years_In_The_Address__c') {
            foundelement.appPermanentAdd.Years_In_The_Address__c = event.target.value;
        }
    }

    // Aadhar File Upload 
    get acceptedFormats() {
        return ['.pdf', '.png', '.jpeg'];
    }

    //To get the type of Applicant Type
    AppliCategoryvalue = '';
    get AppliCategoryOptions() {
        return this.appliOptions;
    }

    //Values for Applicant type
    appliOptions = [
        { label: 'Co-applicant', value: 'Co-applicant' },
        { label: 'Guarantor', value: 'Guarantor' },
    ];

    //Get the Options for Address
    get IsCommAddressoptions() {
        return [
            { label: 'Current Address', value: 'Current Address' },
            { label: 'Permanent Address', value: 'Permanent Address' },
        ];
    }

    //Handle method to save co-applicant as draft
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

        if (this.listOfAccounts.length > 0) {
            for (var i = 0; i < this.listOfAccounts.length; i++) {
                var element = this.listOfAccounts[i];

                if (element.applicantAccountDup == true) {
                    erroronapplicantdup = true;
                    if (erroronapplicantdup)
                        break;
                }
                else if (element.objeAcc.errorCKYCInvalid == true) {
                    CKYCNumberInvalid = true;
                    if (CKYCNumberInvalid)
                        break;
                }
                else if (element.objeAcc.errorNREGInvalid == true) {
                    NREGNumberInvalid = true;
                    if (NREGNumberInvalid)
                        break;
                }
                else if (element.objeAcc.saleserrorAadharInvalid == true) {
                    salesrAadharInvalid = true;
                    if (salesrAadharInvalid)
                        break;
                }
                else if (element.objeAcc.errorAadharInvalid == true) {
                    aadharNumberInvalid = true;
                    if (aadharNumberInvalid)
                        break;
                }
                else if (element.objeAcc.errorDLInvalid == true) {
                    dlNumberInvalid = true;
                    if (dlNumberInvalid)
                        break;
                }
                else if (element.objeAcc.pannotvalid == true) {
                    erroronapplicantdup = true;
                    if (erroronapplicantdup)
                        break;
                }
                else if (element.objeAcc.errorPassportInvalid == true) {
                    passportNumberInvalid = true;
                    if (passportFileInvalid)
                        break;
                }
                else if (element.objeAcc.errorPasspostFilrInvalid == true) {
                    passportFileInvalid = true;
                    if (passportFileInvalid)
                        break;
                }
                else if (element.objeAcc.firstnamenotvalid == true) {
                    errorforfirsstName = true;
                    if (errorforfirsstName)
                        break;
                }
                else if (element.objeAcc.middlenamenotvalid == true) {
                    errorformiddleName = true;
                    if (errorformiddleName)
                        break;
                }
                else if (element.objeAcc.lastnamenotvalid == true) {
                    errorforlastName = true;
                    if (errorforlastName)
                        break;
                }
                else if (element.objeAcc.Aadhar_Number__c == element.matchValue && element.errorMsgForDuplicate == true) {
                    duplicaterrorAadharNumber = true;
                    if (duplicaterrorAadharNumber)
                        break;
                }
                else if (element.objeAcc.PAN_Number__c == element.matchValue && element.errorMsgForDuplicate == true) {
                    duplicaterrorPANNumber = true;
                    if (duplicaterrorPANNumber)
                        break;
                }
                else if (element.objeAcc.Passport_Number__c == element.matchValue && element.errorMsgForDuplicate == true) {
                    duplicaterrorPassportNumber = true;
                    if (duplicaterrorPassportNumber)
                        break;
                }
                else if (element.objeAcc.Driving_License_Number__c == element.matchValue && element.errorMsgForDuplicate == true) {
                    duplicaterrorDLNumber = true;
                    if (duplicaterrorDLNumber)
                        break;
                }
                else if (element.objeAcc.Voter_ID__c == element.matchValue && element.errorMsgForDuplicate == true) {
                    duplicaterrorVoterId = true;
                    if (duplicaterrorVoterId)
                        break;
                }
                else if (element.objeAcc.FirstName == '' || element.objeAcc.FirstName == undefined ||
                    element.objeAcc.LastName == '' || element.objeAcc.LastName == undefined ||
                    element.objeAcc.PersonMobilePhone == '' || element.objeAcc.PersonMobilePhone == undefined ||
                    element.objeAcc.PersonEmail == '' || element.objeAcc.PersonEmail == undefined) {
                    accSection = true;
                    if (accSection)
                        break;
                }
                else if (element.objeAcc.Date_of_Birth__c == null || element.objeAcc.Date_of_Birth__c == '' || element.objeAcc.Date_of_Birth__c == undefined ||
                    element.objeAcc.Aadhar_Number__c == '' || element.objeAcc.Aadhar_Number__c == undefined || element.objeAcc.Aadhar_Number__c == null) {
                    kycSection = true;
                    if (kycSection)
                        break;
                }
                else if ((element.appCurrentAdd.Address_Proof__c == '' || element.appCurrentAdd.Address_Proof__c == undefined
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
            if (salesrAadharInvalid) {
                this.showToast("Error!!", "Fill last 4 Digits of Aadhar Number", "Error")
            }
            else if (CKYCNumberInvalid) {
                this.showToast("Error!!", "Please enter valid CKYC Number", "Error")
            }
            else if (NREGNumberInvalid) {
                this.showToast("Error!!", "Please enter valid NREG Number", "Error")
            }

            else if (aadharNumberInvalid) {
                this.showToast("Error!!", "Please enter Valid Aadhar Number", "Error")
            }

            else if (errorInvalidPANNumber) {
                this.showToast("Error!!", "Please enter valid PAN Number", "Error")
            }

            else if (dlNumberInvalid) {
                this.showToast("Error!!", "Please enter Valid Driving Licence", "Error")
            }

            else if (passportNumberInvalid) {
                this.showToast("Error!!", "Please enter Valid Passport Number", "Error")
            }

            else if (passportFileInvalid) {
                this.showToast("Error!!", "Please enter Valid Passport File Number", "Error")
            }

            else if (errorforfirsstName) {
                this.showToast("Error!!", "Please enter Valid First Name", "Error")
            }

            else if (errorformiddleName) {
                this.showToast("Error!!", "Please enter Valid Middle Name", "Error")
            }

            else if (errorforlastName) {
                this.showToast("Error!!", "Please enter Valid Last Name", "Error")
            }

            else if (erroronapplicantdup) {
                this.showToast("Error!!", "Applicant and Co-Applicant details cannot be same. Kindly Crosscheck", "Error")
            }

            else if (duplicaterrorAadharNumber) {
                this.showToast("Error!!", "An account exists with the Aadhar provided. Kindly crosscheck", "Error")
            }

            else if (duplicaterrorPANNumber) {
                this.showToast("Error!!", "An account exists with the PAN Number provided. Kindly crosscheck", "Error")

                if (this.LAadharNumber != '' || this.LAadharNumber != undefined) {
                    this.showToast("Info!!", "Previous Aadhar number Updated", "info")
                }
            }

            else if (duplicaterrorPassportNumber) {
                this.showToast("Error!!", "An account exists with the Passport Number provided. Kindly crosscheck", "Error")
            }

            else if (duplicaterrorDLNumber) {
                this.showToast("Error!!", "An account exists with the Driving License provided. Kindly crosscheck", "Error")
            }

            else if (duplicaterrorVoterId) {
                this.showToast("Error!!", "An account exists with the Voter Id provided. Kindly crosscheck", "Error")
            }

            else if (kycSection) {
                this.showToast("Error!!", "Please fill KYC mandatory fields", "Error")
            }

            else if (accSection || appSection) {
                this.showToast("Error!!", "Please fill Co-Applicant mandatory fields", "Error")
            }

            else if (addSection) {
                this.showToast("Error!!", "Please fill Address mandatory fields", "Error")
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
                        console.log('An error occurred: ', error);
                    }
                });

                this.isLoading = true;
                saveCoApplicant({ coApplicantData: this.listOfAccounts, leadId: this.leadRecordId })
                    .then(result => {
                        this.isLoading = false;

                        this.showToast("Success!!", "Successfully Saved", "Success")

                        if (result.length > 0) {
                            this.listOfAccounts = JSON.parse(JSON.stringify(result));

                            this.setCoApplicantRecord(this.listOfAccounts);
                        }
                    })
                    .catch(error => {
                        this.isLoading = false;
                        console.log('Error while saving data:' + JSON.stringify(error));
                    })
            }
        }
    }

    //To display a toast message
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title, message, variant
            }),
        );
    }

    //Handle method to save co-applicant and move to next section
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
        // var coApplicantSection = true;
        // Define a new array to store relations with the applicant
        let relationsWithApplicant = [];

        if (this.listOfAccounts.length > 0) {
            for (var i = 0; i < this.listOfAccounts.length; i++) {
                var element = this.listOfAccounts[i];

                if (element.applicantAccountDup == true) {
                    erroronapplicantdup = true;
                    if (erroronapplicantdup)
                        break;
                }
                else if (element.objeAcc.errorCKYCInvalid == true) {
                    CKYCNumberInvalid = true;
                    if (CKYCNumberInvalid)
                        break;
                }
                else if (element.objeAcc.errorNREGInvalid == true) {
                    NREGNumberInvalid = true;
                    if (NREGNumberInvalid)
                        break;
                }
                else if (element.objeAcc.saleserrorAadharInvalid == true) {
                    salesrAadharInvalid = true;
                    if (salesrAadharInvalid)
                        break;
                }
                else if (element.objeAcc.errorAadharInvalid == true) {
                    aadharNumberInvalid = true;
                    if (aadharNumberInvalid)
                        break;
                }
                else if (element.objeAcc.errorDLInvalid == true) {
                    dlNumberInvalid = true;
                    if (dlNumberInvalid)
                        break;
                }
                else if (element.objeAcc.pannotvalid == true) {
                    erroronapplicantdup = true;
                    if (erroronapplicantdup)
                        break;
                }
                else if (element.objeAcc.errorPassportInvalid == true) {
                    passportNumberInvalid = true;
                    if (passportFileInvalid)
                        break;
                }
                else if (element.objeAcc.errorPasspostFilrInvalid == true) {
                    passportFileInvalid = true;
                    if (passportFileInvalid)
                        break;
                }
                else if (element.objeAcc.firstnamenotvalid == true) {
                    errorforfirsstName = true;
                    if (errorforfirsstName)
                        break;
                }
                else if (element.objeAcc.middlenamenotvalid == true) {
                    errorformiddleName = true;
                    if (errorformiddleName)
                        break;
                }
                else if (element.objeAcc.lastnamenotvalid == true) {
                    errorforlastName = true;
                    if (errorforlastName)
                        break;
                }
                else if (element.objeAcc.Aadhar_Number__c == element.matchValue && element.errorMsgForDuplicate == true) {
                    duplicaterrorAadharNumber = true;
                    if (duplicaterrorAadharNumber)
                        break;
                }
                else if (element.objeAcc.PAN_Number__c == element.matchValue && element.errorMsgForDuplicate == true) {
                    duplicaterrorPANNumber = true;
                    if (duplicaterrorPANNumber)
                        break;
                }
                else if (element.objeAcc.Passport_Number__c == element.matchValue && element.errorMsgForDuplicate == true) {
                    duplicaterrorPassportNumber = true;
                    if (duplicaterrorPassportNumber)
                        break;
                }
                else if (element.objeAcc.Driving_License_Number__c == element.matchValue && element.errorMsgForDuplicate == true) {
                    duplicaterrorDLNumber = true;
                    if (duplicaterrorDLNumber)
                        break;
                }
                else if (element.objeAcc.Voter_ID__c == element.matchValue && element.errorMsgForDuplicate == true) {
                    duplicaterrorVoterId = true;
                    if (duplicaterrorVoterId)
                        break;
                }
                else if (element.objeAcc.FirstName == '' || element.objeAcc.FirstName == undefined ||
                    element.objeAcc.MiddleName == '' || element.objeAcc.MiddleName == undefined ||
                    element.objeAcc.LastName == '' || element.objeAcc.LastName == undefined ||
                    element.objeAcc.PersonMobilePhone == '' || element.objeAcc.PersonMobilePhone == undefined ||
                    element.objeAcc.PersonEmail == '' || element.objeAcc.PersonEmail == undefined ||
                    element.objeAcc.Gender__c == '' || element.objeAcc.Gender__c == undefined ||
                    element.objeAcc.Marital_Status__c == '' || element.objeAcc.Marital_Status__c == undefined) {
                    accSection = true;
                    // coApplicantSection = true;
                    if (accSection)
                        break;
                }
                else if (element.objeAcc.Date_of_Birth__c == null || element.objeAcc.Date_of_Birth__c == '' || element.objeAcc.Date_of_Birth__c == undefined ||
                    element.objeAcc.Aadhar_Number__c == '' || element.objeAcc.Aadhar_Number__c == undefined || element.objeAcc.Aadhar_Number__c == null) {
                    kycSection = true;
                    if (kycSection)
                        break;
                }
                else if (element.objApplicant.Type__c == '' || element.objApplicant.Type__c == undefined ||
                    element.objApplicant.Relation_with_applicant__c == '' || element.objApplicant.Relation_with_applicant__c == undefined ||
                    element.objApplicant.Relationship_Proof__c == '' || element.objApplicant.Relationship_Proof__c == undefined ||
                    element.objApplicant.Is_Income_Considered_Financial__c == '' || element.objApplicant.Is_Income_Considered_Financial__c == undefined ||
                    (element.objApplicant.Relation_with_applicant__c == 'OTHER' && (element.objApplicant.Relation_others__c == '' || element.objApplicant.Relation_others__c == undefined))) {
                    appSection = true;
                    if (appSection)
                        break;
                }
                else if (element.objApplicant.Type__c == 'Co-applicant' &&
                    (element.appDemography.Father_s_First_Name__c == '' || element.appDemography.Father_s_First_Name__c == undefined ||
                        element.appDemography.Mother_s_First_Name__c == '' || element.appDemography.Mother_s_First_Name__c == undefined)) {
                    demoSection = true;
                    if (demoSection)
                        break;
                }
                else if ((element.appCurrentAdd.Address_Proof__c == '' || element.appCurrentAdd.Address_Proof__c == undefined
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
                else if (element.objApplicant.Is_Income_Considered_Financial__c == 'Yes' &&
                    (element.objeAcc.PAN_Number__c == '' || element.objeAcc.PAN_Number__c == undefined || element.objeAcc.PAN_Number__c == null)) {
                    PANMandatory = true;
                    if (PANMandatory)
                        break;
                }
            }
            // Iterate through the accounts and add their relations with the applicant to the array
            this.listOfAccounts.forEach(res => {
                relationsWithApplicant.push(res.objApplicant.Relation_with_applicant__c);
            });
            if (!relationsWithApplicant.includes('FATHER') && !relationsWithApplicant.includes('MOTHER')) {
                noFatherMotherError = true;
            }

            if (salesrAadharInvalid) {
                this.showToast("Error!!", "Fill last 4 Digits of Aadhar Number", "Error")
            }
            else if (CKYCNumberInvalid) {
                this.showToast("Error!!", "Please enter valid CKYC Number", "Error")
            }
            else if (NREGNumberInvalid) {
                this.showToast("Error!!", "Please enter valid NREG Numberr", "Error")
            }
            else if (aadharNumberInvalid) {
                this.showToast("Error!!", "Please enter Valid Aadhar Number", "Error")
            }
            else if (errorInvalidPANNumber) {
                this.showToast("Error!!", "Please enter valid PAN Number", "Error")
            }
            else if (PANMandatory) {
                this.showToast("Error!!", "Please enter PAN Number", "Error")
            }
            else if (dlNumberInvalid) {
                this.showToast("Error!!", "Please enter Valid Driving Licence", "Error")
            }
            else if (passportNumberInvalid) {
                this.showToast("Error!!", "Please enter Valid Passport Number", "Error")
            }
            else if (passportFileInvalid) {
                this.showToast("Error!!", "Please enter Valid Passport File Number", "Error")
            }
            else if (errorforfirsstName) {
                this.showToast("Error!!", "Please enter Valid First Name", "Error")
            }
            else if (errorformiddleName) {
                this.showToast("Error!!", "Please enter Valid Middle Name", "Error")
            }
            else if (errorforlastName) {
                this.showToast("Error!!", "Please enter Valid Last Name", "Error")
            }
            else if (erroronapplicantdup) {
                this.showToast("Error!!", "Applicant and Co-Applicant details cannot be same. Kindly Crosscheck", "Error")
            }
            else if (duplicaterrorAadharNumber) {
                this.showToast("Error!!", "An account exists with the Aadhar provided. Kindly crosscheck", "Error")
            }
            else if (duplicaterrorPANNumber) {
                this.showToast("Error!!", "An account exists with the PAN Number provided. Kindly crosscheck", "Error")
                if (this.LAadharNumber != '' || this.LAadharNumber != undefined) {
                    this.showToast("Error!!", "Previous Aadhar number Updated", "Error")
                }
            }
            else if (duplicaterrorPassportNumber) {
                this.showToast("Error!!", "An account exists with the Passport Number provided. Kindly crosscheck", "Error")
            }
            else if (duplicaterrorDLNumber) {
                this.showToast("Error!!", "An account exists with the Driving License provided. Kindly crosscheck", "Error")
            }
            else if (duplicaterrorVoterId) {
                this.showToast("Error!!", "An account exists with the Voter Id provided. Kindly crosscheck", "Error")
            }
            else if (kycSection) {
                this.showToast("Error!!", "Please fill KYC mandatory fields", "Error")
            }
            else if (accSection || appSection || demoSection) {
                this.showToast("Error!!", "Please fill Co-Applicant mandatory fields", "Error")
            }
            else if (addSection) {
                this.showToast("Error!!", "Please fill Address mandatory fields", "Error")
            }
            else if (noFatherMotherError) {
                this.showToast("Error!!", "Required either Father or Mother as financial co-applicant")
            }
            else {
                //debugger;
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
                        console.log('An error occurred: ', error);
                    }

                });

                this.isLoading = true;
                saveCoApplicant({ coApplicantData: this.listOfAccounts, leadId: this.leadRecordId })
                    .then(result => {

                        this.isLoading = false;

                        //Progress bar update
                        let sum;
                        if (this.coapplicantCheck == true) {
                            sum = 0;
                        }
                        else {
                            //Get the weightage for CoApplicant Section
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
                                                console.error('Error while updating lead percentage:' + JSON.stringify(error));

                                            });
                                    }
                                })
                                .catch(error => {
                                    console.log('Error while getting weightage:' + JSON.stringify(error));
                                })
                            //sum = 14;
                            //this.firstCheck = true;


                            //Update the check 
                            updateCheck({ leadId: this.leadRecordId, isCheck: true })
                                .then(result => {
                                    this.coapplicantCheck = result.Co_applicant_Section__c;
                                })
                        }

                        /***************/
                        /*****Next Child Component*****/
                        const onNextEvent = new CustomEvent('next', {
                            detail: {
                                nextValue: '5',
                            },
                        });
                        this.dispatchEvent(onNextEvent);
                        /***************/

                        this.showToast("Success!!", "Successfully Saved", "Success")

                        /****Publish message Use for submit buttton*****/
                        // coApplicantSection = false;
                        let coApplicantSection = false;
                        publish(this.messageContext, SUBMITACTION, {
                            coApplicantSection: coApplicantSection
                        });
                        /***********/
                        if (result.length > 0) {
                            this.listOfAccounts = JSON.parse(JSON.stringify(result));
                            this.setCoApplicantRecord(this.listOfAccounts);
                        }
                    })
                    .catch(error => {
                        this.isLoading = false;
                        console.log('Error while saving data:' + JSON.stringify(error));
                    })
            }
        }
    }

    /****************/
    @track matchParameter;
    @track matchValue;
    @track matchDateOfBirth;
    @track alreadyduplicatefound = false;
    @track applicantAccountDup = false;
    @track newListofaccount;

    /*********Get DuplicateAccount ******************/
    checkduplicate(event) {
        //debugger;
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
                }
                else if (this.LAadharNumber.length == 4) {
                    this.matchValue = 'XXXXXXXX' + this.LAadharNumber;
                } else {
                    this.matchValue = null;
                }
            }
        }
        else if (event.target.name === 'PAN_Number__c') {
            this.matchParameter = 'PAN Number';
            this.matchValue = event.target.value;
        }
        else if (event.target.name === 'Passport_Number__c') {
            this.matchParameter = 'Passport Number';
            this.matchValue = event.target.value;
        }
        else if (event.target.name === 'Driving_License_Number__c') {
            this.matchParameter = 'Driving License Number';
            this.matchValue = event.target.value;
        }
        else if (event.target.name === 'Voter_ID__c') {
            this.matchParameter = 'Voter ID';
            this.matchValue = event.target.value;
        }
        duplicateAccount({ 'duplicateParameter': this.matchParameter, 'duplicateValue': this.matchValue, 'matchDOB': this.LDateOfBirth })
            .then((result) => {

                let randomId = Math.random() * 16;

                this.duplicateAccountResult = JSON.stringify(result);
                if (result != null) {

                    if (result.objeAcc.Id == this.applicantAccountId) {

                        this.showToast("Error!!", "Applicant and Co-Applicant details cannot be same. Kindly Crosscheck", "Error")

                        this.listOfAccounts.forEach((account) => {
                            account['applicantAccountDup'] = true;

                        });

                    }

                    else if ((foundelement.objeAcc.Id != result.objeAcc.Id) && (!isNaN(foundelement.objeAcc.Id)) &&
                        (foundelement.alreadyduplicatefound == false || foundelement.alreadyduplicatefound == undefined)) {
                        this.listOfAccounts[index] = result;
                        this.listOfAccounts[index].objApplicant.Id = randomId;


                        if (this.listOfAccounts[index].objeAcc.Aadhar_Number__c == this.matchValue) {
                            this.showToast("Info!!", "Exisitng account found With your Aadhar Number", "info")
                        } else if (this.listOfAccounts[index].objeAcc.PAN_Number__c == this.matchValue) {
                            this.showToast("Info!!", "Exisitng account found With your PAN Number", "info")
                        } else if (this.listOfAccounts[index].objeAcc.Passport_Number__c == this.matchValue) {
                            this.showToast("Info!!", "Exisitng account found With your Passport Number", "info")
                        } else if (this.listOfAccounts[index].objeAcc.Driving_License_Number__c == this.matchValue) {
                            this.showToast("Info!!", "Exisitng account found With your Driving license Number", "info")
                        } else if (this.listOfAccounts[index].objeAcc.Voter_ID__c == this.matchValue) {
                            this.showToast("Info!!", "Exisitng account found With your Voter Id", "info")
                        }

                        this.listOfAccounts[index].alreadyduplicatefound = true;

                        if (this.listOfAccounts[index].objApplicant.Type__c == 'Co-applicant') {
                            this.listOfAccounts[index].ShowDemography = true;
                        }
                        else {
                            this.listOfAccounts[index].ShowDemography = false;
                        }

                        if (this.isSalesUser == false) {
                            if (this.listOfAccounts[index].objeAcc.Aadhar_Number__c != undefined) {
                                this.listOfAccounts[index].objeAcc.makeadhardisable = true;
                                this.listOfAccounts[index].hideBasicSection = true;
                            }
                            else {
                                this.listOfAccounts[index].objeAcc.makeadhardisable = false;
                            }
                        }
                        else if (this.isSalesUser == true) {
                            if (this.listOfAccounts[index].objeAcc.Aadhar_Number__c != undefined) {
                                this.listOfAccounts[index].objeAcc.salessmakeadhardisable = true;
                                this.listOfAccounts[index].hideBasicSection = true;
                            }
                            else {
                                this.listOfAccounts[index].objeAcc.salessmakeadhardisable = false;
                            }
                        }

                        if (this.listOfAccounts[index].objeAcc.PAN_Number__c != undefined) {
                            this.listOfAccounts[index].objeAcc.makepandisable = true;

                        }
                        else {
                            this.listOfAccounts[index].objeAcc.makepandisable = false;
                        }

                        if (this.listOfAccounts[index].objeAcc.Passport_Number__c != undefined) {
                            this.listOfAccounts[index].objeAcc.makepassportdisable = true;
                        }
                        else {
                            this.listOfAccounts[index].objeAcc.makepassportdisable = false;
                        }

                        if (this.listOfAccounts[index].objeAcc.Driving_License_Number__c != undefined) {
                            this.listOfAccounts[index].objeAcc.makedrivingdisable = true;
                        }
                        else {
                            this.listOfAccounts[index].objeAcc.makedrivingdisable = false;
                        }

                        if (this.listOfAccounts[index].objeAcc.Voter_ID__c != undefined) {
                            this.listOfAccounts[index].objeAcc.makevoteriddisable = true;
                        }
                        else {
                            this.listOfAccounts[index].objeAcc.makevoteriddisable = false;
                        }

                        if (this.listOfAccounts[index].objeAcc.FirstName != undefined) {
                            this.listOfAccounts[index].objeAcc.makenamedisable = true;
                        }
                        else {
                            this.listOfAccounts[index].objeAcc.makenamedisable = false;
                        }
                        /****************/
                        if (this.listOfAccounts[index].objeAcc.Gender__c != undefined) {
                            this.listOfAccounts[index].objeAcc.makeGenderdisable = true;
                        }
                        else {
                            this.listOfAccounts[index].objeAcc.makeGenderdisable = false;
                        }

                        if (this.listOfAccounts[index].objeAcc.MiddleName != undefined) {
                            this.listOfAccounts[index].objeAcc.makemiddlenamedisable = true;
                        }
                        else {
                            this.listOfAccounts[index].objeAcc.makemiddlenamedisable = false;
                        }

                        if (this.listOfAccounts[index].objeAcc.LastName != undefined) {
                            this.listOfAccounts[index].objeAcc.makelastnamedisable = true;
                        }
                        else {
                            this.listOfAccounts[index].objeAcc.makelastnamedisable = false;
                        }

                        if (this.listOfAccounts[index].appPermanentAdd.Same_as_Current_Address__c != undefined) {
                            this.listOfAccounts[index].appPermanentAdd.makePermanentAddProofdisabled = true;
                        }
                        else {
                            this.listOfAccounts[index].appPermanentAdd.makePermanentAddProofdisabled = false;
                        }

                        if (this.listOfAccounts[index].objApplicant.Aadhar_Verified__c == true) {
                            this.listOfAccounts[index].showButtonAadhar = false;
                        }
                        else {
                            this.listOfAccounts[index].showButtonAadhar = true;
                        }

                        if (this.listOfAccounts[index].objApplicant.Pan_verified__c == true) {
                            this.listOfAccounts[index].panTemplate = false;
                        }
                        else {
                            this.listOfAccounts[index].panTemplate = true;
                        }

                        if (this.listOfAccounts[index].objeAcc.CKYC_Number__c != undefined) {
                            this.listOfAccounts[index].objeAcc.makeCKYCdisable = true;
                        }
                        else {
                            this.listOfAccounts[index].objeAcc.makeCKYCdisable = false;
                        }

                        if (this.listOfAccounts[index].objeAcc.NREG_Number__c != undefined) {
                            this.listOfAccounts[index].objeAcc.makeNREGdisable = true;
                        }
                        else {
                            this.listOfAccounts[index].objeAcc.makeNREGdisable = false;
                        }

                    } else {
                        this.showToast("Success!!", `An account exists with the ${this.matchParameter} provided. Kindly crosscheck`, "Success")
                        this.listOfAccounts.forEach((account) => {
                            account['errorMsgForDuplicate'] = true;
                            account['matchValue'] = this.matchValue;
                        });
                    }
                }

            })
            .catch((error) => {
                console.log('Error while cheking duplicate co-applicant: ' + JSON.stringify(error));
            })
    }

    //==================== karza integration ================
    @track ConewModal = false;
    @track CoshowModalAadhar = false;
    @track CoconsentYes = false;
    @track CoverifiedAadhar = false;
    @track CoaadharInput;
    @track requestIdAadhar;
    @track aadharInputStyle = 'display:none';
    @track buttonStyleAadhar = 'display:none';
    @track lastFour;

    CoconsentChange(event) {
        if (event.target.checked == true) {
            this.CoconsentYes = true;
        } else {
            this.CoconsentYes = false;
        }
    }

    //To close the aadhar modal
    closeModalAadhar() {
        this.CoshowModalAadhar = false;
        this.otpValueAadhar = ""
    }

    //To get the OTP
    CoGetOtpAadhar(event) {
        if (this.LAadharNumber.slice(0, 4) === "XXXX" && this.CoconsentYes == true) {
            this.ConewModal = true;
            this.CoshowModalAadhar = false;
        } else
            if (this.CoconsentYes == true) {
                this.CoverifiedAadhar = true;
                setTimeout(() => {
                    this.CoverifiedAadhar = false;
                }, 9000)

                if (this.LAadharNumber != "" && this.LAadharNumber != undefined) {
                    AadharVerification({ aadhaarNo: this.LAadharNumber, consent: 'y' })
                        .then((result) => {
                            let responseObj = JSON.parse(result);
                            this.requestIdAadhar = responseObj.requestId;

                            if (responseObj.statusCode == 101) {
                                this.CoshowModalAadhar = true;
                                this.showToast("Success!!", "OTP sent successfully!", "Success")

                            } else {
                                this.showToast("Success!!", "Failed to send OTP. Please try again!", "Success")
                            }
                        })
                        .catch((error) => {
                            console.log('Error while getting OTP: ' + JSON.stringify(error));
                            this.showToast("Success!!", "Failed to send OTP", "Success")
                        })
                }
            } else {
                this.showToast("Success!!", "Please check consent", "Success")
            }
    }

    @track otpValueAadhar;
    @track verifiedbuttonAadhar = false;
    @track firstEightAadhar;
    @track coAadharStaus = true;

    handleVerifyAadhar(event) {
        var foundelement = this.listOfAccounts.find(ele => ele.objeAcc.Id == event.target.dataset.id);
        this.verifiedbuttonAadhar = true;
        setTimeout(() => {
            this.verifiedbuttonAadhar = false;
        }, 7000)

        downloadAadhar({ 'otp': this.otpValueAadhar, 'aadhaarNo': this.LAadharNumber.slice(0, 4) === "XXXX" ? this.firstEightAadhar + this.lastFour : this.LAadharNumber, 'requestId': this.requestIdAadhar, 'consent': 'y' })
            .then((result) => {
                let responseObj = JSON.parse(result);
                this.aadharResponse = responseObj;

                if (responseObj.statusCode == 101) {
                    this.CoshowModalAadhar = false;

                    this.buttonStyleAadhar = 'display:none';
                    this.aadharInputStyle = 'display:none';
                    this.makeadhardisable = true;
                    this.coAadharStaus = true;

                    this.showToast("Success!!", "Aadhar verified successfully!", "Success")

                    this.CoverifiedAadhar = true;
                    this.makeadhardisable = true;
                    this.aadharStatus = true;
                    this.aadharLastFour = this.LAadharNumber.slice(-4)
                    this.LAadharNumber = 'XXXXXXXX' + this.aadharLastFour;
                } else {
                    this.showToast("Success!!", "Please enter correct OTPy", "Success")
                }
            })
            .catch((error) => {
                this.showToast("Success!!", "Failed to verify", "Success")
            });
    }

    //Handle method to get entered OTP
    handleAadharOtp(event) {
        this.otpValueAadhar = event.target.value
    }

    //Method to re-enter aadhar
    inputAadhar() {
        if (this.CoconsentYes == true) {
            this.ConewModal = true;
            this.CoshowModalAadhar = false;
            this.lastFour = this.LAadharNumber.slice(-4);
        } else {
            this.showToast("Success!!", "Please check consent", "Success")
        }
    }

    //Close re-enter aadhar modal 
    closeModalforRe() {
        this.ConewModal = false;
        this.firstEightAadhar = '';
    }

    handleFirstEightAadhar(event) {
        this.firstEightAadhar = event.target.value;
    }

    @track Fullaadhar;
    RehandleVerifyAadhar() {
        this.CoverifiedAadhar = true;
        setTimeout(() => {
            this.CoverifiedAadhar = false;
        }, 5000)
        // debugger
        if (this.firstEightAadhar != "" && this.firstEightAadhar != undefined) {
            this.Fullaadhar = this.firstEightAadhar + this.lastFour
            AadharVerification({ aadhaarNo: this.Fullaadhar, consent: 'y' })
                .then((result) => {
                    let responseObj = JSON.parse(result);
                    this.requestIdAadhar = responseObj.requestId;

                    if (responseObj.statusCode == 101) {
                        this.ConewModal = false;
                        this.CoshowModalAadhar = true;

                        this.showToast("Success!!", "OTP sent successfully", "Success")

                    } else {
                        this.showToast("Error!!", "Failed to send OTP. Please try again", "Error")
                    }
                })
                .catch((error) => {
                    console.log('Error while aadhar verification: ' + JSON.stringify(error));
                    this.showToast("Error!!", "Failed to send OTP", "Error")
                })
        }
    }

    @track buttonStylePan = 'display:none';
    @track sumScore;
    @track sumScorePercent;
    @track verifiedPan;
    @track matchText;

    //Method to verify PAN
    panVerification(event) {
        if (this.LAadharNumber == '' || this.LAadharNumber == undefined) {
            this.showToast("Error!!", "Please Fill Aadhar Number!!", "Error")
        }
        if (this.PANNumber != "" && this.PANNumber != undefined) {
            this.aadharLastFour = this.LAadharNumber.slice(-4)
            panVerification({ 'pan': this.PANNumber, 'aadhaarLastFour': this.aadharLastFour, 'dob': this.LDateOfBirth, 'name': this.LfNName + ' ' + this.LLastName, 'address': this.ApplicurrentAddress + " " + this.appliCurrentCity, 'getContactDetails': 'y', 'PANStatus': 'y', 'consent': 'y' })
                .then((result) => {
                    let responseObj = JSON.parse(result);
                    if (responseObj.dataResponse.statusCode == 101) {
                        let profileMatch = responseObj.dataResponse.result.profileMatch;
                        for (let i = 0; i < profileMatch.length; i++) {
                            this.sumScore += profileMatch[i].matchScore;
                        }
                        this.sumScorePercent = (this.sumScore / 2) * 100;
                        this.sumScorePercent = Math.floor(this.sumScorePercent * 100) / 100;

                        this.showToast("Success!!", "PAN verified", "Success")

                        this.buttonLabelPan = 'Verified';
                        this.verifiedPan = true;
                        this.makepandisable = true;
                        this.makeadhardisable = true;
                        this.buttonStylePan = 'display:none; font-weight:bold;'
                    } else {
                        this.showToast("Error!!", "PAN not verified please try again with correct details", "Error")
                    }
                })
                .catch((error) => {
                    this.showToast("Error!!", "Failed to verify", "Error")
                })
        }
    }

    @api dmsNames;
    doc23;
    doc23name;
    aadharCoapp;
    uploadAadhar(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            this.showToast("Error!!", "Please upload file in .png ,.jpg, .jpeg and.pdf format", "Error")
            this.doc23 = false;
        } else {
            for (var i in this.dmsNames) {
                if (this.dmsNames[i].applicantType == 'Co-Applicant' && this.dmsNames[i].documentType == "Aadhar Front") {
                    this.aadharCoapp = this.dmsNames[i].label;
                }
            }
            //const fileName = this.aadharCoapp + this.coAppIndex + ".";
            const fileName = 'Co-Applicant Aadhar';
            console.log('fileName==>>>', fileName);
            const docType = 'AADHAAR';
            this.openFrontfileUpload(event, fileName, docType);
            this.doc23 = true;
            let file = event.target.files[0]
            this.doc23name = file.name
            //this.percentage = this.percentage + this.docPercentage;
        }
    }

    doc28;
    doc28name;
    panCoapp;
    uploadPAN(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            this.showToast("Error!!", "Please upload file in .png ,.jpg, .jpeg and.pdf format", "Error")
            this.doc28 = false;
        } else {
            this.coAppliPan = false;
            for (var i in this.dmsNames) {
                if (this.dmsNames[i].id == 'm0RBi00000031SbMAI') {
                    this.panCoapp = this.dmsNames[i].label;
                }
            }
            const fileName = this.panCoapp + this.coAppIndex + ".";
            const docType = 'PAN';
            this.openFrontfileUpload(event, fileName, docType);
            this.doc28 = true;
            let file = event.target.files[0]
            this.doc28name = file.name
            //this.percentage = this.percentage + this.docPercentage;
        }
    }

    dldoc;
    dldocname;
    dlCoapp;
    uploadDL(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            this.showToast("Error!!", "Please upload file in .png ,.jpg, .jpeg and.pdf format", "Error")
            this.dldoc = false;
        } else {
            this.coAppliPan = false;
            for (var i in this.dmsNames) {
                if (this.dmsNames[i].id == 'm0RBi00000031SbMAI') {//NEED TO CHANGE Id FOR DL ADDED BY ROHIT
                    this.dlCoapp = this.dmsNames[i].label;
                }
            }
            const fileName = this.dlCoapp + this.coAppIndex + ".";
            const docType = 'DL';
            this.openFrontfileUpload(event, fileName, docType);
            this.dldoc = true;
            let file = event.target.files[0]
            this.dldocname = file.name
        }
    }

    passportdoc;
    passportdocname;
    passPortCoapp;
    uploadPassport(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            this.showToast("Error!!", "Please upload file in .png ,.jpg, .jpeg and.pdf format", "Error")
            this.passportdoc = false;
        } else {
            for (var i in this.dmsNames) {
                if (this.dmsNames[i].id == 'm0RBi00000031NlMAI') {
                    this.passPortCoapp = this.dmsNames[i].label;
                }
            }
            const fileName = this.passPortCoapp + this.coAppIndex + ".";
            const docType = 'PASSPORT';
            this.openFrontfileUpload(event, fileName, docType);
            this.passportdoc = true;
            let file = event.target.files[0]
            this.passportdocname = file.name
        }
    }

    voterdoc;
    voterdocname;
    voterIdCoapp;
    uploadVoterId(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            this.showToast("Error!!", "Please upload file in .png ,.jpg, .jpeg and.pdf format", "Error")
            this.voterdoc = false;
        } else {
            for (var i in this.dmsNames) {
                if (this.dmsNames[i].id == 'm0RBi00000031QzMAI') {
                    this.voterIdCoapp = this.dmsNames[i].label;
                }
            }
            const fileName = this.voterIdCoapp + this.coAppIndex + ".";
            const docType = 'VOTER';
            this.openFrontfileUpload(event, fileName);
            this.voterdoc = true;
            let file = event.target.files[0]
            this.voterdocname = file.name
            this.percentage = this.percentage + this.docPercentage;
        }
    }

    @track AppliAccID;
    @track currentId;
    @track accountdupcheckId;
    @track newAccountCreated = false;
    openFrontfileUpload(event, fileName, docType) {
        debugger;
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

        let file = event.target.files[0]
        let reader = new FileReader()
        reader.onload = () => {
            let base64 = reader.result.split(',')[1]
            console.log(base64);
            let fullName = fileName + file.type.split('/')[1];

            console.log('fullName', fullName);

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
                existingDL: foundelement.objeAcc.Driving_License_Number__c
            })
                .then(async (result) => {
                    this.isLoading = false;
                    let responseObj = result;
                    console.log('responseObj==>', JSON.stringify(responseObj));
                    if (responseObj.apistatusCode == 101) {
                        this.LDateOfBirth = responseObj.leadDOB;
                        this.accountdupcheckId = responseObj.accountId;
                        if(responseObj.newAccountCreated == true){
                            this.newAccountCreated = true;
                        }else{
                            this.newAccountCreated = false;
                        }
                        if (responseObj.apiDocumentType == 'AADHAAR') {
                            this.apiaadharLastFour = responseObj.leadAadharNumber.slice(-4);
                            this.matchParameter = 'Aadhar Number';
                            this.matchValue = 'XXXXXXXX' + this.apiaadharLastFour;

                            this.checkOCRDuplicate(this.matchParameter, this.matchValue, this.LDateOfBirth)
                                .then(() => {
                                    console.log('matchParameterDuplicate', this.matchParameterDuplicate);
                                    if (this.matchParameterDuplicate == true) {
                                        console.log('Inside matchParameterDuplicate true');
                                    }
                                    else if (this.aadharLastFour != this.apiaadharLastFour) {
                                        if (this.aadharLastFour == '' || this.aadharLastFour == undefined) {
                                            console.log('INSIDE aadharLastFour NULL');
                                            this.createAadharRecord(responseObj);
                                        } else {
                                            this.showToast("Error!!", "Uploaded Aadhar number does not match. Kindly Crosscheck & Upload correct document", "Error")
                                        }

                                    } else {
                                        this.createAadharRecord(responseObj);
                                    }
                                })
                                .catch((error) => {
                                    console.error(error);
                                });
                        } else if (responseObj.apiDocumentType == 'PAN') {
                            this.matchParameter = 'PAN Number';
                            this.matchValue = responseObj.apiPANNumber;

                            this.checkOCRDuplicate(this.matchParameter, this.matchValue, this.LDateOfBirth)
                                .then(() => {
                                    console.log('matchParameterDuplicate', this.matchParameterDuplicate);
                                    console.log('foundelement.objeAcc.PAN_Number__c' , foundelement.objeAcc.PAN_Number__c);
                                    if (this.matchParameterDuplicate == true) {
                                        console.log('Inside matchParameterDuplicate true');
                                    }
                                    else if (foundelement.objeAcc.PAN_Number__c != responseObj.apiPANNumber) {
                                        if (foundelement.objeAcc.PAN_Number__c == '' || foundelement.objeAcc.PAN_Number__c == undefined) {
                                            //this.createPANRecord(responseObj);
                                            this.setRecord(responseObj);
                                        } else {
                                            this.showToast("Error!!", "Uploaded PAN number does not match. Kindly Crosscheck & Upload correct document", "Error")
                                        }

                                    } else {
                                        this.setRecord(responseObj);
                                        //this.createPANRecord(responseObj);
                                    }
                                })
                                .catch((error) => {
                                    console.error(error);
                                });
                        } else if (responseObj.apiDocumentType == 'VOTER') {
                            this.matchParameter = 'Voter ID';
                            this.matchValue = responseObj.apiVoterNumber;

                            this.checkOCRDuplicate(this.matchParameter, this.matchValue, this.LDateOfBirth)
                                .then(() => {
                                    console.log('matchParameterDuplicate', this.matchParameterDuplicate);
                                    if (this.matchParameterDuplicate == true) {
                                        console.log('Inside matchParameterDuplicate true');
                                    }
                                    else if (foundelement.objeAcc.Voter_ID__c != responseObj.apiVoterNumber) {
                                        if (foundelement.objeAcc.Voter_ID__c == undefined || foundelement.objeAcc.Voter_ID__c == '') {
                                            //this.createVoterRecord(responseObj);
                                            this.setRecord(responseObj);
                                        } else {
                                            this.showToast("Error!!", "Uploaded Voter Id does not match. Kindly Crosscheck & Upload correct document", "Error")
                                        }
                                    } else {
                                        //this.createVoterRecord(responseObj);
                                        this.setRecord(responseObj);
                                    }
                                })
                                .catch((error) => {
                                    console.error(error);
                                });

                        } else if (responseObj.apiDocumentType == 'PASSPORT') {
                            this.matchParameter = 'Passport Number';
                            this.matchValue = responseObj.apiPassportNumber;

                            this.checkOCRDuplicate(this.matchParameter, this.matchValue, this.LDateOfBirth)
                                .then(() => {
                                    console.log('matchParameterDuplicate', this.matchParameterDuplicate);
                                    if (this.matchParameterDuplicate == true) {
                                        console.log('Inside matchParameterDuplicate true');
                                    }
                                    else if (foundelement.objeAcc.Passport_Number__c != responseObj.apiPassportNumber) {
                                        if (foundelement.objeAcc.Passport_Number__c == undefined || foundelement.objeAcc.Passport_Number__c == '') {
                                            //this.createPassportRecord(responseObj);
                                            this.setRecord(responseObj);
                                        } else {
                                            this.showToast("Error!!", "Uploaded Passport Number does not match. Kindly Crosscheck & Upload correct document", "Error")
                                        }
                                    } else {
                                        //this.createPassportRecord(responseObj);
                                        this.setRecord(responseObj);
                                    }
                                })
                                .catch((error) => {
                                    console.error(error);
                                });


                        } else if (responseObj.apiDocumentType == 'DL') {
                            this.matchParameter = 'Driving License Number';
                            this.matchValue = responseObj.apiDLNumber;

                            this.checkOCRDuplicate(this.matchParameter, this.matchValue, this.LDateOfBirth)
                                .then(() => {
                                    console.log('matchParameterDuplicate', this.matchParameterDuplicate);
                                    if (this.matchParameterDuplicate == true) {
                                        console.log('Inside matchParameterDuplicate true');
                                    }
                                    else if (foundelement.objeAcc.Driving_License_Number__c != responseObj.apiDLNumber) {
                                        if (foundelement.objeAcc.Driving_License_Number__c == undefined || foundelement.objeAcc.Driving_License_Number__c == '') {
                                            //this.createDrivignLicenceRecord(responseObj);
                                            this.setRecord(responseObj);
                                        } else {
                                            this.showToast("Error!!", "Uploaded Driving Licence does not match. Kindly Crosscheck & Upload correct document", "Error")
                                        }
                                    } else {
                                        //this.createDrivignLicenceRecord(responseObj);
                                        this.setRecord(responseObj);
                                    }
                                })
                                .catch((error) => {
                                    console.error(error);
                                });
                        }
                    } else if (responseObj.statusCode != 101) {
                        this.showToast("Error!!", "Error Uploading File. Kindly Crosscheck the document and upload", "Error")
                    }

                }).catch((error) => {
                    console.error("error", error);
                    this.isLoading = false;
                    this.appdoc1 = false;
                })
        };
        reader.readAsDataURL(file);
    }

    async createAadharRecord(responseObj) {
        console.log('INSIDE createAadharRecord');
        var foundelement = this.listOfAccounts.find(ele => ele.objeAcc.Id == this.currentId);
        console.log('this.currentId==>>>' , this.currentId);
        console.log('foundelement==>' , JSON.stringify(foundelement));
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

        foundelement.objeAcc.MiddleName = responseObj.leadMiddleName !== undefined ? responseObj.leadMiddleName : foundelement.objeAcc.MiddleName;
        foundelement.objeAcc.makemiddlenamedisable = foundelement.objeAcc.makemiddlenamedisable === true || responseObj.leadMiddleName !== undefined;

        foundelement.objeAcc.LastName = responseObj.leadLastName !== undefined ? responseObj.leadLastName : foundelement.objeAcc.LastName;
        foundelement.objeAcc.makelastnamedisable = foundelement.objeAcc.makelastnamedisable === true || responseObj.leadLastName !== undefined;

        foundelement.appDemography.Father_s_First_Name__c = responseObj.leadFatherFirstName !== undefined ? responseObj.leadFatherFirstName : foundelement.appDemography.Father_s_First_Name__c;
        foundelement.appDemography.makeFatherFirstNamedisable = foundelement.objeAcc.makeFatherFirstNamedisable === true || responseObj.leadFatherFirstName !== undefined;

        foundelement.objeAcc.Gender__c = responseObj.leadGender !== undefined ? responseObj.leadGender : foundelement.objeAcc.Gender__c;
        foundelement.objeAcc.makeGenderdisable = foundelement.objeAcc.makeGenderdisable === true || responseObj.leadGender !== undefined;

        foundelement.objeAcc.Date_of_Birth__c = responseObj.leadDOB !== undefined ? responseObj.leadDOB : foundelement.objeAcc.Date_of_Birth__c;
        foundelement.objeAcc.makeDOBdisable = foundelement.objeAcc.makeDOBdisable === true || responseObj.leadDOB !== undefined;

        foundelement.objeAcc.Id = responseObj.accountId !== undefined ? responseObj.accountId : foundelement.objeAcc.Id;

        foundelement.objeAcc.PAN_Number__c = responseObj.leadPANNumber !== undefined ? responseObj.leadPANNumber : foundelement.objeAcc.PAN_Number__c;
        //foundelement.objeAcc.makepandisable = responseObj.leadPANNumber !== undefined;
        foundelement.objeAcc.makepandisable = foundelement.objeAcc.makepandisable === true || responseObj.leadPANNumber !== undefined;

        foundelement.objeAcc.Passport_Number__c = responseObj.leadPANNumber !== undefined ? responseObj.leadPANNumber : foundelement.objeAcc.Passport_Number__c;
        foundelement.objeAcc.makepassportdisable = foundelement.objeAcc.makepassportdisable === true || responseObj.leadPANNumber !== undefined;

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
                    foundelement.appCurrentAdd.Address_1__c = responseObj.leadhouse + " " + responseObj.leadCurrentAddress;
                    foundelement.appCurrentAdd.Landmark__c = responseObj.leadLandmark;
                }


            } catch (error) {
                this.errors = error;
                this.isLoading = false;
                this.appdoc1 = true;
            }
        }

        this.showToast("Success!!", "Aadhar Uploded Successfully", "Success")
    }

    async setRecord(responseObj) {
        debugger;
        var foundelement = this.listOfAccounts.find(ele => ele.objeAcc.Id == this.currentId);
        console.log('foundelement=>', JSON.stringify(foundelement));
        console.log('responseObj.leadVoterIdNumber=>', responseObj.leadVoterIdNumber);
        console.log('responseObj.leadPANNumber=>', responseObj.leadPANNumber);
        console.log('responseObj.leadPassportNumber=>', responseObj.leadPassportNumber);
        console.log('responseObj.leadPassportFileNumber=>', responseObj.leadPassportFileNumber);
        console.log('responseObj.leadDLNumber=>', responseObj.leadDLNumber);
        console.log('responseObj.leadCKYCNumber=>', responseObj.leadCKYCNumber);

        if (responseObj.accountId != undefined) {
            foundelement.objeAcc.Id = responseObj.accountId;
        }

        if(responseObj.leadDOB != undefined){
            foundelement.objeAcc.Date_of_Birth__c = responseObj.leadDOB;
            foundelement.objeAcc.makeDOBdisable = true;
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
                    foundelement.appCurrentAdd.Address_1__c = responseObj.leadhouse + " " + responseObj.leadCurrentAddress;
                    foundelement.appCurrentAdd.Landmark__c = responseObj.leadLandmark;
                }


            } catch (error) {
                this.errors = error;
                this.isLoading = false;
                this.appdoc1 = true;
            }
        }

        if (responseObj.apiDocumentType == 'PAN') {
            this.showToast("Success!!", "PAN Uploded Successfully", "Success")
        } else if (responseObj.apiDocumentType == 'VOTER') {
            this.showToast("Success!!", "Voter Id Uploded Successfully", "Success")
        } else if (responseObj.apiDocumentType == 'PASSPORT') {
            this.showToast("Success!!", "Passport Uploded Successfully", "Success")
        } else if (responseObj.apiDocumentType == 'DL') {
            this.showToast("Success!!", "Driving Licence Uploded Successfully", "Success")
        }
    }

    @track matchParameterDuplicate = false;
    @track dupkcateeteteteresult;
    checkOCRDuplicate(matchParameter, matchValue, LDateOfBirth) {
        return new Promise((resolve, reject) => {
            var foundelement = this.listOfAccounts.find(ele => ele.objeAcc.Id == this.currentId);
            let index = this.listOfAccounts.findIndex(ele => ele.objeAcc.Id == this.currentId);
            console.log('foundelement.objeAcc.Id=>' ,foundelement.objeAcc.Id);
            duplicateAccount({ 'duplicateParameter': matchParameter, 'duplicateValue': matchValue, 'matchDOB': LDateOfBirth })
                .then((result) => {
                    if (Object.keys(result).length != 0) {
                        console.log('INSIDE result length > 0');
                        if (this.newAccountCreated == false){
                            console.log('INSIDE newAccountCreated true CONDITION');
                            if (result.objeAcc.Id == this.applicantAccountId) {
                                console.log('applicant and Co-Applicant details cannot be the same');
                                this.showToast("Error!!", "Applicant and Co-Applicant details cannot be the same. Kindly Crosscheck", "Error");
                                this.matchParameterDuplicate = true;
                            }
                             else if ((foundelement.objeAcc.Id != result.objeAcc.Id) && (!isNaN(foundelement.objeAcc.Id)) &&
                                (foundelement.alreadyduplicatefound == false || foundelement.alreadyduplicatefound == undefined)) {
                                console.log('INSIDE ELSE IF');
                                //this.listOfAccounts[index] = result;
                                //this.listOfAccounts[index].objApplicant.Id = randomId;
                                console.log('resultaadharNumber', result.objeAcc.Aadhar_Number__c);
                                console.log('matchValue=>', matchValue);
                                //foundelement.objeAcc.Id = this.accountdupcheckId;

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
                            }else if(foundelement.objeAcc.Id != result.objeAcc.Id){
                                console.log('An account exists with the paramaterr');
                                this.showToast("Error!!", `An account exists with the ${matchParameter} provided. Kindly crosscheck`, "Error");
                                this.matchParameterDuplicate = true;
                            }
                        }
                    } else {
                        console.log('INSIDE lasttt ELSE');
                        this.matchParameterDuplicate = false;
                    }
                    resolve(); // Resolve the promise
                })
                .catch((error) => {
                    console.log('Error while checking duplicate co-applicant: ' + JSON.stringify(error));
                    reject(error); // Reject the promise with the error
                });
        });
    }

    setCoApplicantRecord(listOfAccounts) {
        debugger;
        console.log('listOfAccounts====>', JSON.stringify(listOfAccounts));
        var salesUserValue = this.isSalesUser;
        listOfAccounts.forEach(function (account) {
            console.log('INSIDE LOPPPPPPP');
            try {
                //If Type is Co-applicant then then demography fields
                if (account.objApplicant.Type__c == 'Co-applicant') {
                    account['ShowDemography'] = true;
                }
                else {
                    account['ShowDemography'] = false;
                }

                if (salesUserValue == false) {
                    if (account.objeAcc.Aadhar_Number__c != undefined) {
                        account.objeAcc['makeadhardisable'] = true;
                        account['hideBasicSection'] = true;
                    }
                    else {
                        account.objeAcc['makeadhardisable'] = false;
                    }
                }
                else if (salesUserValue == true) {
                    if (account.objeAcc.Aadhar_Number__c != undefined) {
                        account.objeAcc['salessmakeadhardisable'] = true;
                        account['hideBasicSection'] = true;
                    }
                    else {
                        account.objeAcc['salessmakeadhardisable'] = false;
                    }
                }

                if (account.objeAcc.PAN_Number__c != undefined) {
                    account.objeAcc['makepandisable'] = true;

                }
                else {
                    account.objeAcc['makepandisable'] = false;
                }

                if (account.objeAcc.Passport_Number__c != undefined) {
                    account.objeAcc['makepassportdisable'] = true;
                }
                else {
                    account.objeAcc['makepassportdisable'] = false;
                }

                if (account.objeAcc.Driving_License_Number__c != undefined) {
                    account.objeAcc['makedrivingdisable'] = true;
                }
                else {
                    account.objeAcc['makedrivingdisable'] = false;
                }

                if (account.objeAcc.Voter_ID__c != undefined) {
                    account.objeAcc['makevoteriddisable'] = true;
                }
                else {
                    account.objeAcc['makevoteriddisable'] = false;
                }

                if (account.objeAcc.CKYC_Number__c != undefined) {
                    account.objeAcc['makeCKYCdisable'] = true;
                }
                else {
                    account.objeAcc['makeCKYCdisable'] = false;
                }

                if (account.objeAcc.NREG_Number__c != undefined) {
                    account.objeAcc['makeNREGdisable'] = true;
                }
                else {
                    account.objeAcc['makeNREGdisable'] = false;
                }

                if (account.objeAcc.FirstName != undefined) {
                    account.objeAcc['makenamedisable'] = true;
                }
                else {
                    account.objeAcc['makenamedisable'] = false;
                }

                if (account.objeAcc.Gender__c != undefined) {
                    account.objeAcc['makeGenderdisable'] = true;
                }
                else {
                    account.objeAcc['makeGenderdisable'] = false;
                }

                if (account.objeAcc.MiddleName != undefined) {
                    account.objeAcc['makemiddlenamedisable'] = true;
                }
                else {
                    account.objeAcc['makemiddlenamedisable'] = false;
                }

                if (account.objeAcc.LastName != undefined) {
                    account.objeAcc['makelastnamedisable'] = true;
                }
                else {
                    account.objeAcc['makelastnamedisable'] = false;
                }

                if (account.appPermanentAdd.Same_as_Current_Address__c == true) {
                    account.appPermanentAdd['makePermanentAddProofdisabled'] = true;
                }
                else {
                    account.appPermanentAdd['makePermanentAddProofdisabled'] = false;
                }

                if (account.objApplicant.Relation_with_applicant__c == 'OTHER') {
                    account['ShowFieldsRelationWithAppliIfOther'] = true;
                }
                else {
                    account['ShowFieldsRelationWithAppliIfOther'] = false;
                }

            } catch (e) {
                console.log('Exception while loading data: ' + e);
            }
        });

    }

    @api applicantAadhar;
    namesRenderDMS() {
        DMS_NAMES()
            .then((result) => {
                this.dmsNames = JSON.parse(result);
                console.log('DMS Names:', this.dmsNames);
            })
            .catch((error) => {
                console.error(error);
            });
    }
}