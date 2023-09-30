import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';

import getPincodeRecord from '@salesforce/apex/CommunityLeadFormController.getPincodeRecord';
import getCoAppRecords from '@salesforce/apex/DemoCommunityLeadForm.getCoapp';
import saveCoApplicant from '@salesforce/apex/DemoCommunityLeadForm.saveCoApplicant';
import deleteCoApplicant from '@salesforce/apex/DemoCommunityLeadForm.deleteCoApplicant';
import getApplicantAccoutId from '@salesforce/apex/DemoCommunityLeadForm.getAccountIdFromCoApplicant';
import Account from '@salesforce/schema/Account';
import Applicant from '@salesforce/schema/Co_Applicant__c';
import Address from '@salesforce/schema/ContactPointAddress';
import Marital_Status from '@salesforce/schema/Account.Marital_Status__c';
import Gender from '@salesforce/schema/Account.Gender__c';
import Relation_with_applicant from '@salesforce/schema/Co_Applicant__c.Relation_with_applicant__c';
import Relation_proof from '@salesforce/schema/Co_Applicant__c.Relationship_Proof__c';
import Is_income from '@salesforce/schema/Co_Applicant__c.Is_Income_Considered_Financial__c';
import Address_Proof from '@salesforce/schema/ContactPointAddress.Address_Proof__c';
// import getDeplicateAccout from '@salesforce/apex/AccountTriggerHandler.getDupAccountCommunityForm';
import duplicateAccount from '@salesforce/apex/DemoCommunityLeadForm.duplicateAccount';

import AadharVerification from '@salesforce/apex/DocumentVerification.AadharVerification';
import downloadAadhar from '@salesforce/apex/DocumentVerification.DownloadAadhar';
import panVerification from '@salesforce/apex/DocumentVerification.PanProfile';
import getLeadTotalPercentage from '@salesforce/apex/DocumentVerification.getLeadTotalPercentage';
import updateLeadTotalPercentage from '@salesforce/apex/DocumentVerification.updateLeadTotalPercentage';
import progressBar from '@salesforce/messageChannel/progressBar__c';
import {publish, MessageContext} from 'lightning/messageService';

import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import ProfileName from '@salesforce/schema/User.Profile.Name';

export default class CoapplicantGuarantorChild extends LightningElement {

    @api leadRecordId;
    @track todaysDate;
    @track isStepOne = true;
    @track isLoading = false;
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
    @track testhidesavebutton = false;

    @track saleserrorAadharInvalid = false;
    @track salessmakeadhardisable = false;
    @track SalesLAadharNumber;
    @track isSalesUser;
    @track firstCheck = false;

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
        // Returns a map of record type Ids 
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
                console.log('userProfileName' , this.userProfileName);

                if(this.userProfileName == 'Sales Profile'){
                    this.isSalesUser = true;
                }else{
                    this.isSalesUser = false;
                }
                console.log('isSalesUser' , this.isSalesUser);
            }
        }
    }

    connectedCallback() {
        this.initData();
        this.getApplicant();
        this.todaysDate = new Date().toISOString().split('T')[0];
    }

    handlePinCode(event) {
        var foundelement = this.listOfAccounts.find(ele => ele.appCurrentAdd.Id == event.target.dataset.id);
        if (event.target.value == '') {
            foundelement.appCurrentAdd.Pin_Code__c = '';
            foundelement.appCurrentAdd.City__c = '';
            foundelement.appCurrentAdd.District__c = '';
            foundelement.appCurrentAdd.State__c = '';
            foundelement.appCurrentAdd.Country__c = '';
        }
        else {

            getPincodeRecord({ pincode: event.target.value })
                .then(result => {
                    foundelement.appCurrentAdd.Pin_Code__c = result.Id;
                    foundelement.appCurrentAdd.City__c = result.City_Name__c;
                    foundelement.appCurrentAdd.District__c = result.Area_Name_Taluka__c;
                    foundelement.appCurrentAdd.State__c = result.State__c;
                    foundelement.appCurrentAdd.Country__c = result.Country__c;
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
        }
        else {

            getPincodeRecord({ pincode: event.target.value })
                .then(result => {
                    foundelement.appPermanentAdd.Pin_Code__c = result.Id;
                    foundelement.appPermanentAdd.City__c = result.City_Name__c;
                    foundelement.appPermanentAdd.District__c = result.Area_Name_Taluka__c;
                    foundelement.appPermanentAdd.State__c = result.State__c;
                    foundelement.appPermanentAdd.Country__c = result.Country__c;
                })
        }
    }

    getApplicant(){

        getApplicantAccoutId({leadId: this.leadRecordId})

        .then(result => {
            console.log('Result==>', result);
            if (result.length > 0) {
                this.applicantAccountId = result;
                console.log('this.applicantAccountId==> ', this.applicantAccountId);
            }
        }).catch(error => {
            console.log('Error while fetching Account Id from Applicant' +error);
        });
    }

    initData() {

        getCoAppRecords({leadId: this.leadRecordId})
            .then(result => {
                let randomId = Math.random() * 16;
                if (result.length > 0) {
                    debugger;
                    this.listOfAccounts = JSON.parse(JSON.stringify(result));
                    console.log('listaccountt===========', JSON.stringify(result));
                    console.log('listaccountt=5555555', JSON.stringify(this.listOfAccounts));

                    console.log('this.isSalesUser1111==' , this.isSalesUser);
                    var salesUserValue = this.isSalesUser;
                    
                    this.listOfAccounts.forEach((account) => {
                        this.firstCheck = true;
                        console.log('this.isSalesUser==' , salesUserValue);
                        try {
                            
                            if (account.objApplicant.Type__c == 'Co-applicant') {
                                account['ShowDemography'] = true;
                            } else {
                                account['ShowDemography'] = false;
                            }
                            
                            if(salesUserValue == false){
                                if (account.objeAcc.Aadhar_Number__c != undefined) {
                                    account.objeAcc['makeadhardisable'] = true;
                                    account['hideBasicSection'] = true;
                                } else {
                                    account.objeAcc['makeadhardisable'] = false;
                                }
                            }
                            else if(salesUserValue == true){
                                if (account.objeAcc.Aadhar_Number__c != undefined) {
                                    account.objeAcc['salessmakeadhardisable'] = true;
                                    account['hideBasicSection'] = true;
                                } else {
                                    account.objeAcc['salessmakeadhardisable'] = false;
                                }
                            }

                            console.log('hideBasicSection' , account.hideBasicSection);
                            console.log('hideBasicSectio2222' , account['hideBasicSection']);
                            
                            if (account.objeAcc.PAN_Number__c != undefined) {
                                console.log('if insidee pann acodndition');
                                account.objeAcc['makepandisable'] = true;
                                
                            } else {
                                account.objeAcc['makepandisable'] = false;
                            }
                            if (account.objeAcc.Passport_Number__c != undefined) {
                                console.log('if insidee passpoet acodndition');
                                account.objeAcc['makepassportdisable'] = true;
                            } else {
                                account.objeAcc['makepassportdisable'] = false;
                            }
                            if (account.objeAcc.Driving_License_Number__c != undefined) {
                                console.log('if insidee drivingg acodndition');
                                account.objeAcc['makedrivingdisable'] = true;
                            } else {
                                account.objeAcc['makedrivingdisable'] = false;
                            }
                            if (account.objeAcc.Voter_ID__c != undefined) {
                                console.log('if insidee voteerr acodndition');
                                account.objeAcc['makevoteriddisable'] = true;
                            } else {
                                account.objeAcc['makevoteriddisable'] = false;
                            }
                            if (account.objeAcc.CKYC_Number__c != undefined) {
                                account.objeAcc['makeCKYCdisable'] = true;
                            } else {
                                account.objeAcc['makeCKYCdisable'] = false;
                            }
                            if (account.objeAcc.NREG_Number__c != undefined) {
                                account.objeAcc['makeNREGdisable'] = true;
                            } else {
                                account.objeAcc['makeNREGdisable'] = false;
                            }
                            if (account.objeAcc.FirstName != undefined) {
                                account.objeAcc['makenamedisable'] = true;
                            } else {
                                account.objeAcc['makenamedisable'] = false;
                            }
                            if (account.objeAcc.Gender__c != undefined) {
                                account.objeAcc['makeGenderdisable'] = true;
                            } else {
                                account.objeAcc['makeGenderdisable'] = false;
                            }
                            if (account.objeAcc.MiddleName != undefined) {
                                account.objeAcc['makemiddlenamedisable'] = true;
                            } else {
                                account.objeAcc['makemiddlenamedisable'] = false;
                            }
                            if (account.objeAcc.LastName != undefined) {
                                account.objeAcc['makelastnamedisable'] = true;
                            } else {
                                account.objeAcc['makelastnamedisable'] = false;
                            }
                            if (account.appPermanentAdd.Same_as_Current_Address__c == true) {
                                console.log('insidee trureeee');
                                account.appPermanentAdd['makePermanentAddProofdisabled'] = true;
                            } else {
                                account.appPermanentAdd['makePermanentAddProofdisabled'] = false;

                            }
                            if (account.objApplicant.Relation_with_applicant__c == 'OTHER') {
                                console.log('insidee trureeee');
                                account['ShowFieldsRelationWithAppliIfOther'] = true;
                            } else {
                                account['ShowFieldsRelationWithAppliIfOther'] = false;

                            }

                        } catch (e) { }

                    });
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
                console.log('Error while fetching Account Names from SF.' + error);
            });
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
                "Id": randomId,
                "FirstName": "", "MiddleName": "", "LastName": "", "Date_of_Birth__c": "", "PersonMobilePhone": "", "PersonEmail": "",
                "Gender__c": "", "Marital_Status__c": "", "Passport_Number__c": "", "Aadhar_Number__c": "", "PAN_Number__c": "",
                "Driving_License_Number__c": "", "Passport_File_Number__c": ""
            }, "appDemography": { "Id": randomId, "Account__c": "", "Father_s_First_Name__c": "", "Mother_s_First_Name__c": "" }
        };
        this.listOfAccounts = [...this.listOfAccounts, myNewElement];
    }
    addNewRow() {
        this.createRow(this.listOfAccounts);
        this.buttonStyleAadhar="display:none";
        this.aadharInputStyle="display:none";
        this.buttonStylePan="display:none";
    }
    @track deleteAccId = '';
    removeTheRow(event) {
        if (isNaN(event.target.dataset.id)) {
            this.deleteAccId = this.deleteAccId + event.target.dataset.id;
        }

        if (this.listOfAccounts.length > 1) {
            this.listOfAccounts.splice(this.listOfAccounts.findIndex(row => row.Id === event.target.dataset.id), 1);

            this.isLoading = true;
            deleteCoApplicant({ accId: this.deleteAccId, leadId: this.leadRecordId })
                .then(result => {
                    this.isLoading = false;

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Deleted Successfully',
                            variant: 'Success',
                        }),
                    );

                    if (result.length > 0) {
                        this.listOfAccounts = JSON.parse(JSON.stringify(result));
                        console.log('listacccountttt===', JSON.stringify(this.listOfAccounts));

                        this.listOfAccounts.forEach(function (account) {

                            try {
                                if (account.objApplicant.Type__c == 'Co-applicant') {
                                    account['ShowDemography'] = true;
                                } else {
                                    account['ShowDemography'] = false;
                                }
                                if (account.objeAcc.Aadhar_Number__c != undefined) {
                                    console.log('if insidee adhardd acodndition');
                                    account.objeAcc['makeadhardisable'] = true;
                                    account['hideBasicSection'] = true;
                                } else {
                                    account.objeAcc['makeadhardisable'] = false;
                                }
                                if (account.objeAcc.PAN_Number__c != undefined) {
                                    console.log('if insidee pann acodndition');
                                    account.objeAcc['makepandisable'] = true;
                                    
                                    
                                } else {
                                    account.objeAcc['makepandisable'] = false;
                                }
                                if (account.objeAcc.Passport_Number__c != undefined) {
                                    console.log('if insidee passpoet acodndition');
                                    account.objeAcc['makepassportdisable'] = true;
                                } else {
                                    account.objeAcc['makepassportdisable'] = false;
                                }
                                if (account.objeAcc.Driving_License_Number__c != undefined) {
                                    console.log('if insidee drivingg acodndition');
                                    account.objeAcc['makedrivingdisable'] = true;
                                } else {
                                    account.objeAcc['makedrivingdisable'] = false;
                                }
                                if (account.objeAcc.Voter_ID__c != undefined) {
                                    console.log('if insidee voteerr acodndition');
                                    account.objeAcc['makevoteriddisable'] = true;
                                } else {
                                    account.objeAcc['makevoteriddisable'] = false;
                                }
                                if (account.objeAcc.FirstName != undefined) {
                                    account.objeAcc['makenamedisable'] = true;
                                } else {
                                    account.objeAcc['makenamedisable'] = false;
                                }
                                if (account.objeAcc.Gender__c != undefined) {
                                    account.objeAcc['makeGenderdisable'] = true;
                                } else {
                                    account.objeAcc['makeGenderdisable'] = false;
                                }
                                if (account.objeAcc.MiddleName != undefined) {
                                    account.objeAcc['makemiddlenamedisable'] = true;
                                } else {
                                    account.objeAcc['makemiddlenamedisable'] = false;
                                }
                                if (account.objeAcc.LastName != undefined) {
                                    account.objeAcc['makelastnamedisable'] = true;
                                } else {
                                    account.objeAcc['makelastnamedisable'] = false;
                                }
                                if (account.appPermanentAdd.Same_as_Current_Address__c == true) {
                                    console.log('insidee trureeee');
                                    account.appPermanentAdd['makePermanentAddProofdisabled'] = true;
                                } else {
                                    account.appPermanentAdd['makePermanentAddProofdisabled'] = false;
                                }
                                if (account.objeAcc.CKYC_Number__c != undefined) {
                                    account.objeAcc['makeCKYCdisable'] = true;
                                } else {
                                    account.objeAcc['makeCKYCdisable'] = false;
                                }
                                if (account.objeAcc.NREG_Number__c != undefined) {
                                    account.objeAcc['makeNREGdisable'] = true;
                                } else {
                                    account.objeAcc['makeNREGdisable'] = false;
                                }

                            } catch (e) { }

                        });
                    }
                })
                .catch(error => {
                    this.isLoading = false;
                    console.log('Error while saving data:' + JSON.stringify(error));
                })  
        }
    }
@track showReAadharButton=false;
@track panTemplate=false;

    handlechangeAccount(event) {
        // debugger;
        var foundelement = this.listOfAccounts.find(ele => ele.objeAcc.Id == event.target.dataset.id);

        if (event.target.name === 'FirstName') {
            let fieldValue = event.target.value;
            let pattern = /^[a-zA-Z\s]*$/;
            if (!pattern.test(fieldValue)) {
                foundelement.objeAcc.firstnamenotvalid = true;
                console.log('');
            } else {
                foundelement.objeAcc.FirstName = event.target.value;
                console.log('foundelement.objeAcc.FirstName', foundelement.objeAcc.FirstName);
                foundelement.objeAcc.firstnamenotvalid = false;
            }
            console.log('foundelement.objeAcc.firstnamenotvalid', foundelement.objeAcc.firstnamenotvalid);
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
            console.log('LDateOfBirth = ', this.LDateOfBirth);
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

            console.log('errorAadharInvalid=== ' ,foundelement.objeAcc.errorAadharInvalid);

            if (this.LAadharNumber.length === 12 && this.LAadharNumber.slice(0, 4) != "XXXX") {
                console.log("12 success");
                this.buttonStyleAadhar = "display:block"
                this.aadharInputStyle = "display:none";
                foundelement.showButtonAadhar = true;
                this.lastFour= this.LAadharNumber.slice(-4);
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
            }

            console.log('errorAadharInvalid=== ' ,foundelement.objeAcc.errorAadharInvalid);

        }
        else if (event.target.name === 'PAN_Number__c') {
            let fieldValue = event.target.value;
            let pattern = /[A-Z]{5}[0-9]{4}[A-Z]{1}$/;
            if (!pattern.test(fieldValue)) {
                console.log('inside invalid pan number');
                foundelement.objeAcc.pannotvalid = true;
                foundelement.panTemplate = false;
            } else {
                console.log('valid pan number');
                foundelement.objeAcc.PAN_Number__c = event.target.value;
                this.PANNumber = foundelement.objeAcc.PAN_Number__c;
                foundelement.objeAcc.pannotvalid = false;
                
                this.buttonStylePan ='display:block';
                foundelement.panTemplate = true;
            }
            
            console.log('this.PANNumber', this.PANNumber);
        }
        else if (event.target.name === 'Passport_File_Number__c') {
            let fieldValue = event.target.value;
            let pattern = /^[A-Z]{4}[0-9]{8}$/;
            if (!pattern.test(fieldValue)) {
                foundelement.objeAcc.errorPasspostFilrInvalid = true;
            } else {
                foundelement.objeAcc.errorPasspostFilrInvalid = false;
                foundelement.objeAcc.Passport_File_Number__c = event.target.value;
                this.passportFileNumber = foundelement.objeAcc.Passport_File_Number__c;
            }
            
            console.log('this.passportFileNumber', this.passportFileNumber);
        }
        else if (event.target.name === 'Driving_License_Number__c') {
            let fieldValue = event.target.value;
            let pattern = /[A-Za-z]{2}[\d\s\-]{14}/;
            if (!pattern.test(fieldValue)) {
                foundelement.objeAcc.errorDLInvalid = true;
            } else {
                foundelement.objeAcc.errorDLInvalid = false;
                foundelement.objeAcc.Driving_License_Number__c = event.target.value;
                this.driveLicenseNumber = foundelement.objeAcc.Driving_License_Number__c;
            }
            
        }
        else if (event.target.name === 'Passport_Number__c') {
            let fieldValue = event.target.value;
            let pattern = /^[A-Z]{1}[0-9]{7}$/;
            if (!pattern.test(fieldValue)) {
                foundelement.objeAcc.errorPassportInvalid = true;
            } else {
                foundelement.objeAcc.errorPassportInvalid = false;
                foundelement.objeAcc.Passport_Number__c = event.target.value;
                this.passportNumber = foundelement.objeAcc.Passport_Number__c;
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

    handleChangeDemo(event) {
        var foundelement = this.listOfAccounts.find(ele => ele.appDemography.Id == event.target.dataset.id);

        if (event.target.name == 'Father_s_First_Name__c') {
            console.log('###Father name');
            foundelement.appDemography.Father_s_First_Name__c = event.target.value;
        }
        else if (event.target.name == 'Mother_s_First_Name__c') {
            console.log('###Mother name');
            foundelement.appDemography.Mother_s_First_Name__c = event.target.value;
        }
    }

    handleApplicantCategory(event) {
        var foundelement = this.listOfAccounts.find(ele => ele.objApplicant.Id == event.target.dataset.id);
        if(this.coAadharStaus == true){
            foundelement.objApplicant.Aadhar_Verified__c = this.coAadharStaus;
        }
        if (event.target.name == "ApplicantCategory") {
            console.log('event.target.value', event.target.value);
            foundelement.objApplicant.Type__c = event.target.value;
            if (event.target.value === 'Co-applicant') {
                foundelement.ShowDemography = true;
            }
            else {
                foundelement.ShowDemography = false;
            }

            console.log('foundelement.ShowDemography', foundelement.ShowDemography);
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

    @track makePermanentAddProofdisabled = false;
    handlechangePermanent(event) {
        var foundelement = this.listOfAccounts.find(ele => ele.appPermanentAdd.Id == event.target.dataset.id);

        if (event.target.name === 'Same_as_Current_Address__c') {
            foundelement.appPermanentAdd.Same_as_Current_Address__c = event.target.checked;
            if(foundelement.appPermanentAdd.Same_as_Current_Address__c == true){
                console.log('Same_as_Current_Address__c==', foundelement.appPermanentAdd.Same_as_Current_Address__c);
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
            else{
                console.log('Same_as_Curre==', foundelement.appPermanentAdd.Same_as_Current_Address__c);
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
            console.log('years in addresss');
            console.log('adsvdvsdvsvs', event.target.value);
            foundelement.appPermanentAdd.Years_In_The_Address__c = event.target.value;
            console.log('years in addresss========', foundelement.appPermanentAdd.Years_In_The_Address__c);
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
    appliOptions = [
        { label: 'Co-applicant', value: 'Co-applicant' },
        { label: 'Guarantor', value: 'Guarantor' },
    ];

    get IsCommAddressoptions() {
        return [
            { label: 'Current Address', value: 'Current Address' },
            { label: 'Permanent Address', value: 'Permanent Address' },
        ];
    }

    handleSaveCoApplicant(event) {
         //debugger;
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

                if(element.applicantAccountDup == true){
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
                else if(element.objeAcc.saleserrorAadharInvalid == true){
                    salesrAadharInvalid = true;
                    if(salesrAadharInvalid)
                        break;
                }
                else if (element.objeAcc.errorAadharInvalid == true) {
                    aadharNumberInvalid = true;
                    if (aadharNumberInvalid)
                        break;
                }
                else if(element.objeAcc.errorDLInvalid == true){
                    dlNumberInvalid =true;
                    if (dlNumberInvalid)
                        break;
                }
                else if (element.objeAcc.pannotvalid == true) {
                    erroronapplicantdup = true;
                    if (erroronapplicantdup)
                        break;
                }
                else if(element.objeAcc.errorPassportInvalid == true){
                    passportNumberInvalid = true;
                    if (passportFileInvalid)
                        break;
                }
                else if(element.objeAcc.errorPasspostFilrInvalid == true){
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
                else  if(element.objeAcc.FirstName == '' || element.objeAcc.FirstName == undefined || 
                       element.objeAcc.LastName == '' || element.objeAcc.LastName == undefined ||
                       element.objeAcc.PersonMobilePhone == '' || element.objeAcc.PersonMobilePhone == undefined ||
                       element.objeAcc.PersonEmail == '' || element.objeAcc.PersonEmail == undefined ){
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
                else if (element.objApplicant.Type__c == '' || element.objApplicant.Type__c == undefined ||
                       element.objApplicant.Relation_with_applicant__c == '' || element.objApplicant.Relation_with_applicant__c == undefined ||
                       (element.objApplicant.Relation_with_applicant__c == 'OTHER' && (element.objApplicant.Relation_others__c == '' || element.objApplicant.Relation_others__c == undefined))) {
                       appSection = true;
                       if (appSection)
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
            
                    if(salesrAadharInvalid){
                this.showToast("Error!!","Fill last 4 Digits of Aadhar Number","Error")
                           }
                    else if(CKYCNumberInvalid){
                this.showToast("Error!!","Please enter valid CKYC Number","Error")
                          }
                    else if (NREGNumberInvalid) {
                        this.showToast("Error!!", "Please enter valid NREG Number", "Error")
                    }
                    else if(aadharNumberInvalid){
                this.showToast("Error!!","Please enter Valid Aadhar Number","Error")
                           }

                    else if(errorInvalidPANNumber){
                this.showToast("Error!!","Please enter valid PAN Number","Error")
                           }

                    else if(dlNumberInvalid){
                this.showToast("Error!!","Please enter Valid Driving Licence","Error")
                           }

                    else if(passportNumberInvalid){
                this.showToast("Error!!","Please enter Valid Passport Number","Error")
                           }

                    else if(passportFileInvalid){
                this.showToast("Error!!","Please enter Valid Passport File Number","Error")
                           }

                    else if(errorforfirsstName){
                this.showToast("Error!!","Please enter Valid First Name","Error")
                           }

                    else if(errorformiddleName){
                this.showToast("Error!!","Please enter Valid Middle Name","Error")
                           } 

                    else if(errorforlastName){
                this.showToast("Error!!","Please enter Valid Last Name","Error")
                           } 
   
                    else if(erroronapplicantdup){
                this.showToast("Error!!","Applicant and Co-Applicant details cannot be same. Kindly Crosscheck","Error")
                           }

                    else if (duplicaterrorAadharNumber) {
                this.showToast("Error!!","An account exists with the Aadhar provided. Kindly crosscheck","Error")
                           }

                    else if (duplicaterrorPANNumber) {
                this.showToast("Error!!","An account exists with the PAN Number provided. Kindly crosscheck","Error")
                              
                         if(this.LAadharNumber!=''||this.LAadharNumber!=undefined){
                    this.showToast("Info!!","Previous Aadhar number Updated","info")
                               }
                           }

                    else if (duplicaterrorPassportNumber) {
                this.showToast("Error!!","An account exists with the Passport Number provided. Kindly crosscheck","Error")
                           }

                    else if (duplicaterrorDLNumber) {
                this.showToast("Error!!","An account exists with the Driving License provided. Kindly crosscheck","Error")
                           }

                    else if (duplicaterrorVoterId) {
                this.showToast("Error!!","An account exists with the Voter Id provided. Kindly crosscheck","Error")
                           }

                    else if (kycSection) {
                this.showToast("Error!!","Please fill KYC mandatory fields","Error")
                           }

                    else if (accSection || appSection) {
                this.showToast("Error!!","Please fill Co-Applicant mandatory fields","Error")
                          }

                    else if (addSection) {
                        this.showToast("Error!!","Please fill Address mandatory fields","Error")
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
                              console.log('An error occurred: '+ error);
                        }
                });

                this.isLoading = true;
                saveCoApplicant({ coApplicantData: this.listOfAccounts, leadId: this.leadRecordId })
                    .then(result => {
                        this.isLoading = false;

                        /****progress bar data pass****/
                   
                        this.showToast( "Success!!","Successfully Saved","Success" )
                        

                        if (result.length > 0) {
                            this.listOfAccounts = JSON.parse(JSON.stringify(result));

                            this.listOfAccounts.forEach(function (account) {

                                try {
                                    if (account.objApplicant.Type__c == 'Co-applicant') {
                                        account['ShowDemography'] = true;
                                    } else {
                                        account['ShowDemography'] = false;
                                    }
                                    if (account.objeAcc.Aadhar_Number__c != undefined) {
                                        account.objeAcc['makeadhardisable'] = true;
                                        account.objeAcc['salessmakeadhardisable'] = true;
                                        account['hideBasicSection'] = true;
                                    } else {
                                        account.objeAcc['makeadhardisable'] = false;
                                        account.objeAcc['salessmakeadhardisable'] = false;
                                    }
                                    if (account.objeAcc.PAN_Number__c != undefined) {
                                        account.objeAcc['makepandisable'] = true;
                                        
                                        
                                    } else {
                                        account.objeAcc['makepandisable'] = false;
                                    }
                                    if (account.objeAcc.Passport_Number__c != undefined) {
                                        account.objeAcc['makepassportdisable'] = true;
                                    } else {
                                        account.objeAcc['makepassportdisable'] = false;
                                    }
                                    if (account.objeAcc.Driving_License_Number__c != undefined) {
                                        account.objeAcc['makedrivingdisable'] = true;
                                    } else {
                                        account.objeAcc['makedrivingdisable'] = false;
                                    }
                                    if (account.objeAcc.Voter_ID__c != undefined) {
                                        account.objeAcc['makevoteriddisable'] = true;
                                    } else {
                                        account.objeAcc['makevoteriddisable'] = false;
                                    }
                                    if (account.objeAcc.FirstName != undefined) {
                                        account.objeAcc['makenamedisable'] = true;
                                    } else {
                                        account.objeAcc['makenamedisable'] = false;
                                    }
                                    if (account.objeAcc.Gender__c != undefined) {
                                        account.objeAcc['makeGenderdisable'] = true;
                                    } else {
                                        account.objeAcc['makeGenderdisable'] = false;
                                    }
                                    if (account.objeAcc.MiddleName != undefined) {
                                        account.objeAcc['makemiddlenamedisable'] = true;
                                    } else {
                                        account.objeAcc['makemiddlenamedisable'] = false;
                                    }
                                    if (account.objeAcc.LastName != undefined) {
                                        account.objeAcc['makelastnamedisable'] = true;
                                    } else {
                                        account.objeAcc['makelastnamedisable'] = false;
                                    }
                                    if (account.appPermanentAdd.Same_as_Current_Address__c == true) {
                                        account.appPermanentAdd['makePermanentAddProofdisabled'] = true;
                                    } else {
                                        account.appPermanentAdd['makePermanentAddProofdisabled'] = false;
                                    }
                                    if (account.objeAcc.CKYC_Number__c != undefined) {
                                        account.objeAcc['makeCKYCdisable'] = true;
                                    } else {
                                        account.objeAcc['makeCKYCdisable'] = false;
                                    }
                                    if (account.objeAcc.NREG_Number__c != undefined) {
                                        account.objeAcc['makeNREGdisable'] = true;
                                    } else {
                                        account.objeAcc['makeNREGdisable'] = false;
                                    }

                                } catch (e) { }

                            });
                        }
                    })
                    .catch(error => {
                        this.isLoading = false;
                        console.log('Error while saving data:' + JSON.stringify(error));
                    })
            }
        }
    }
    //Toast msg display method
    showToast(title,message,variant){
		this.dispatchEvent(
            new ShowToastEvent({
            title,message,variant  
				}),
            );
		}

    handleNextCoApplicant(event){
            debugger;
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
                       // Define a new array to store relations with the applicant
            let relationsWithApplicant = [];
   
           if (this.listOfAccounts.length > 0) {
               for (var i = 0; i < this.listOfAccounts.length; i++) {
                   var element = this.listOfAccounts[i];  
                   if(element.applicantAccountDup == true){
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
                   else if(element.objeAcc.saleserrorAadharInvalid == true){
                       salesrAadharInvalid = true;
                       if(salesrAadharInvalid)
                           break;
                   }
                   else if (element.objeAcc.errorAadharInvalid == true) {
                       aadharNumberInvalid = true;
                       if (aadharNumberInvalid)
                           break;
                   }
                   else if(element.objeAcc.errorDLInvalid == true){
                       dlNumberInvalid =true;
                       if (dlNumberInvalid)
                           break;
                   }
                   else if (element.objeAcc.pannotvalid == true) {
                       erroronapplicantdup = true;
                       if (erroronapplicantdup)
                           break;
                   }
                   else if(element.objeAcc.errorPassportInvalid == true){
                       passportNumberInvalid = true;
                       if (passportFileInvalid)
                           break;
                   }
                   else if(element.objeAcc.errorPasspostFilrInvalid == true){
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
                             element.objeAcc.Marital_Status__c == '' || element.objeAcc.Marital_Status__c == undefined){
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
                           element.appDemography.Mother_s_First_Name__c == ''|| element.appDemography.Mother_s_First_Name__c == undefined)) {
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
                   else if ((element.objApplicant.Is_Income_Considered_Financial__c == 'Yes' && 
                           (element.objeAcc.PAN_Number__c == '' || element.objeAcc.PAN_Number__c == undefined || element.objeAcc.PAN_Number__c == null))) {
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

               if(salesrAadharInvalid){
                   this.dispatchEvent(
                       new ShowToastEvent({
                           title: 'Error!!',
                           message: 'Fill last 4 Digits of Aadhar Number',
                           variant: 'Error',
                       }),
                   );
               }
               else if(CKYCNumberInvalid){
                   this.dispatchEvent(
                       new ShowToastEvent({
                           title: 'Error!!',
                           message: 'Please enter valid CKYC Number',
                           variant: 'Error',
                       }),
                   );
               }
               else if (NREGNumberInvalid) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Please enter valid NREG Number',
                        variant: 'Error',
                    }),
                );
            }
               else if(aadharNumberInvalid){
                   this.dispatchEvent(
                       new ShowToastEvent({
                           title: 'Error!!',
                           message: 'Please enter Valid Aadhar Number',
                           variant: 'Error',
                       }),
                   );
               }
               else if(errorInvalidPANNumber){
                   this.dispatchEvent(
                       new ShowToastEvent({
                           title: 'Error!!',
                           message: 'Please enter valid PAN Number',
                           variant: 'Error',
                       }),
                   );
               }
               else if(PANMandatory){
                   this.dispatchEvent(
                       new ShowToastEvent({
                           title: 'Error!!',
                           message: 'Please enter PAN Number',
                           variant: 'Error',
                       }),
                   );
               }
               else if(dlNumberInvalid){
                   this.dispatchEvent(
                       new ShowToastEvent({
                           title: 'Error!!',
                           message: 'Please enter Valid Driving Licence',
                           variant: 'Error',
                       }),
                   );
               }
               else if(passportNumberInvalid){
                   this.dispatchEvent(
                       new ShowToastEvent({
                           title: 'Error!!',
                           message: 'Please enter Valid Passport Number',
                           variant: 'Error',
                       }),
                   );
               }
               else if(passportFileInvalid){
                   this.dispatchEvent(
                       new ShowToastEvent({
                           title: 'Error!!',
                           message: 'Please enter Valid Passport File Number',
                           variant: 'Error',
                       }),
                   );
               }
               else if(errorforfirsstName){
                   this.dispatchEvent(
                       new ShowToastEvent({
                           title: 'Error!!',
                           message: 'Please enter Valid First Name',
                           variant: 'Error',
                       }),
                   );
               }
               else if(errorformiddleName){
                   this.dispatchEvent(
                       new ShowToastEvent({
                           title: 'Error!!',
                           message: 'Please enter Valid Middle Name',
                           variant: 'Error',
                       }),
                   );
               } 
               else if(errorforlastName){
                   this.dispatchEvent(
                       new ShowToastEvent({
                           title: 'Error!!',
                           message: 'Please enter Valid Last Name',
                           variant: 'Error',
                       }),
                   );
               }    
               else if(erroronapplicantdup){
                   this.dispatchEvent(
                       new ShowToastEvent({
                           title: 'Error!!',
                           message: 'Applicant and Co-Applicant details cannot be same. Kindly Crosscheck',
                           variant: 'Error',
                       }),
                   );
               } 
               else if (duplicaterrorAadharNumber) {
                   this.dispatchEvent(
                       new ShowToastEvent({
                           title: 'Error!!',
                           message: 'An account exists with the Aadhar provided. Kindly crosscheck',
                           variant: 'Error',
                       }),
                   );
               }
               else if (duplicaterrorPANNumber) {
                   //debugger;
                   this.dispatchEvent(
                       new ShowToastEvent({
                           title: 'Error!!',
                           message: 'An account exists with the PAN Number provided. Kindly crosscheck',
                           variant: 'Error',
                       }),
                   );
                   if(this.LAadharNumber!=''||this.LAadharNumber!=undefined){
                       this.dispatchEvent(
                           new ShowToastEvent({
                               title: 'Info',
                               message: 'Previous Aadhar number Updated',
                               variant: 'info',
                           }),
                       );
                   }
               }
               else if (duplicaterrorPassportNumber) {
                   this.dispatchEvent(
                       new ShowToastEvent({
                           title: 'Error!!',
                           message: 'An account exists with the Passport Number provided. Kindly crosscheck',
                           variant: 'Error',
                       }),
                   );
               }
               else if (duplicaterrorDLNumber) {
                   this.dispatchEvent(
                       new ShowToastEvent({
                           title: 'Error!!',
                           message: 'An account exists with the Driving License provided. Kindly crosscheck',
                           variant: 'Error',
                       }),
                   );
               }
               else if (duplicaterrorVoterId) {
                   this.dispatchEvent(
                       new ShowToastEvent({
                           title: 'Error!!',
                           message: 'An account exists with the Voter Id provided. Kindly crosscheck',
                           variant: 'Error',
                       }),
                   );
               }
               else if (kycSection) {
                   this.dispatchEvent(
                       new ShowToastEvent({
                           title: 'Error!!',
                           message: 'Please fill KYC mandatory fields',
                           variant: 'Error',
                       }),
                   );
               }
               else if (accSection || appSection || demoSection) {
                   this.dispatchEvent(
                       new ShowToastEvent({
                           title: 'Error!!',
                           message: 'Please fill Co-Applicant mandatory fields',
                           variant: 'Error',
                       }),
                   );
               }
               else if (addSection) {
                   this.dispatchEvent(
                       new ShowToastEvent({
                           title: 'Error!!',
                           message: 'Please fill Address mandatory fields',
                           variant: 'Error',
                       }),
                   );
               }
               else if (noFatherMotherError) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!!',
                            message: 'Required either Father or Mother as financial co-applicant',
                            variant: 'Error',
                       }),
                     );
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
                              console.log('An error occurred: '+ error);
                        }
                   });
   
                   this.isLoading = true;
                   saveCoApplicant({ coApplicantData: this.listOfAccounts, leadId: this.leadRecordId })
                       .then(result => {
                           this.isLoading = false;
   
                           /****progress bar data pass****/
                      //debugger
                      if(this.nextPage){
                       let sum;
                       if(this.firstCheck == true){
                           sum = 0;
                       }
                       else{
                           sum = 14;
                           this.firstCheck = true;
                           
                          let newPerc = sum;    
                          updateLeadTotalPercentage({ leadId: this.leadRecordId, percentage: newPerc })
                          .then(result => {
                               let ProgrssValueOfLoanSection = {ProgrssValueOfLoanSection:result };
                               publish(this.messageContext, progressBar, ProgrssValueOfLoanSection);
                              
                          })
                          .catch(error => {
                              console.error(error);
                              // Add any error handling here
                          });
                      
                       }
                      }
                      
                           this.dispatchEvent(
                               new ShowToastEvent({
                                   title: 'Success',
                                   message: 'Successfully Saved',
                                   variant: 'Success',
                               }),
                           );
                           
                               /*****Next Child Component*****/
                                  const onNextEvent = new CustomEvent('next', {
                                    detail: {
                                        nextValue: '5',
                                    },
                                    });
                                    this.dispatchEvent(onNextEvent);
                                    /***************/
   
                           if (result.length > 0) {
                               this.listOfAccounts = JSON.parse(JSON.stringify(result));
                               this.listOfAccounts.forEach(function (account) {
   
                                   try {
                                       if (account.objApplicant.Type__c == 'Co-applicant') {
                                           account['ShowDemography'] = true;
                                       } else {
                                           account['ShowDemography'] = false;
                                       }
                                       if (account.objeAcc.Aadhar_Number__c != undefined) {
                                           account.objeAcc['makeadhardisable'] = true;
                                           account['hideBasicSection'] = true;
                                       } else {
                                           account.objeAcc['makeadhardisable'] = false;
                                       }
                                       if (account.objeAcc.PAN_Number__c != undefined) {
                                           account.objeAcc['makepandisable'] = true;
                                           
                                           
                                       } else {
                                           account.objeAcc['makepandisable'] = false;
                                       }
                                       if (account.objeAcc.Passport_Number__c != undefined) {
                                           account.objeAcc['makepassportdisable'] = true;
                                       } else {
                                           account.objeAcc['makepassportdisable'] = false;
                                       }
                                       if (account.objeAcc.Driving_License_Number__c != undefined) {
                                           account.objeAcc['makedrivingdisable'] = true;
                                       } else {
                                           account.objeAcc['makedrivingdisable'] = false;
                                       }
                                       if (account.objeAcc.Voter_ID__c != undefined) {
                                           account.objeAcc['makevoteriddisable'] = true;
                                       } else {
                                           account.objeAcc['makevoteriddisable'] = false;
                                       }
                                       if (account.objeAcc.FirstName != undefined) {
                                           account.objeAcc['makenamedisable'] = true;
                                       } else {
                                           account.objeAcc['makenamedisable'] = false;
                                       }
                                       if (account.objeAcc.Gender__c != undefined) {
                                           account.objeAcc['makeGenderdisable'] = true;
                                       } else {
                                           account.objeAcc['makeGenderdisable'] = false;
                                       }
                                       if (account.objeAcc.MiddleName != undefined) {
                                           account.objeAcc['makemiddlenamedisable'] = true;
                                       } else {
                                           account.objeAcc['makemiddlenamedisable'] = false;
                                       }
                                       if (account.objeAcc.LastName != undefined) {
                                           account.objeAcc['makelastnamedisable'] = true;
                                       } else {
                                           account.objeAcc['makelastnamedisable'] = false;
                                       }
                                       if (account.appPermanentAdd.Same_as_Current_Address__c == true) {
                                           account.appPermanentAdd['makePermanentAddProofdisabled'] = true;
                                       } else {
                                           account.appPermanentAdd['makePermanentAddProofdisabled'] = false;   
                                       }
                                       if (account.objeAcc.CKYC_Number__c != undefined) {
                                        account.objeAcc['makeCKYCdisable'] = true;
                                        } else {
                                        account.objeAcc['makeCKYCdisable'] = false;
                                        }
                                        if (account.objeAcc.NREG_Number__c != undefined) {
                                            account.objeAcc['makeNREGdisable'] = true;
                                        } else {
                                            account.objeAcc['makeNREGdisable'] = false;
                                        }
                                   } catch (e) { }
   
                               });
                           }
                       })
                       .catch(error => {
                           this.isLoading = false;
                           console.log('Error while saving data:' + JSON.stringify(error));
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

    /*********Get DuplicateAccount ******************/
    checkduplicate(event) {
        //debugger;
        console.log('check pan duplicate on blur');

        console.log('ID' + event.target.dataset.id);

        var foundelement = this.listOfAccounts.find(ele => ele.objeAcc.Id == event.target.dataset.id);

        let index = this.listOfAccounts.findIndex(ele => ele.objeAcc.Id == event.target.dataset.id);

        console.log('event.target.dataset.id', event.target.dataset.id);


        if (event.target.name === 'Aadhar_Number__c' || event.target.name === 'SalesLAadharNumber') {
            this.matchParameter = 'Aadhar Number';

            if (this.LAadharNumber == undefined || this.LAadharNumber == null) {
                this.matchValue = null;
            } else {
                
                if(this.LAadharNumber.length == 12){
                    this.aadharLastFour = this.LAadharNumber.slice(-4);
                    this.matchValue = 'XXXXXXXX' + this.aadharLastFour;
                }
                else if(this.LAadharNumber.length == 4){
                    this.matchValue = 'XXXXXXXX' + this.LAadharNumber;
                }else{
                    this.matchValue = null;
                }
                
            }

            console.log('adhar = ', this.matchValue);
        }
        else if (event.target.name === 'PAN_Number__c') {
            this.matchParameter = 'PAN Number';
            this.matchValue = event.target.value;
            console.log('this.PANNumber', this.matchValue);
        }
        else if (event.target.name === 'Passport_Number__c') {
            this.matchParameter = 'Passport Number';
            this.matchValue = event.target.value;
            console.log('this.passportFileNumber', this.matchValue);
        }
        else if (event.target.name === 'Driving_License_Number__c') {
            this.matchParameter = 'Driving License Number';
            this.matchValue = event.target.value;
            console.log('this.Driving_License_Number__c', this.matchValue);
        }
        else if (event.target.name === 'Voter_ID__c') {
            this.matchParameter = 'Voter ID';
            this.matchValue = event.target.value;
            console.log('this.Voter_ID__c', this.matchValue);
        }

        console.log('BEFORE CALLING APEX METOHD');
        console.log('matchDOB', this.LDateOfBirth);
        duplicateAccount({ 'duplicateParameter': this.matchParameter, 'duplicateValue': this.matchValue, 'matchDOB': this.LDateOfBirth })
            .then((result) => {

                let randomId = Math.random() * 16;

                this.duplicateAccountResult = JSON.stringify(result);
                console.log('result', this.duplicateAccountResult);
                console.log('this.duplicateAccou' , result.objeAcc.Id);

                if (result != null) {

                    if(result.objeAcc.Id == this.applicantAccountId){
                        console.log('INSIDE applicant record dulicate');

                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error!!',
                                message: `Applicant and Co-Applicant details cannot be same. Kindly Crosscheck`,
                                variant: 'Error',
                            }),
                        );

                        this.listOfAccounts.forEach((account) => {
                            account['applicantAccountDup'] = true;
                            
                        });

                    }

                    else if ((foundelement.objeAcc.Id != result.objeAcc.Id) && (!isNaN(foundelement.objeAcc.Id)) &&
                        (foundelement.alreadyduplicatefound == false || foundelement.alreadyduplicatefound == undefined)) {

                        console.log('inside condition of duplicate record');

                        this.listOfAccounts[index] = result;
                        this.listOfAccounts[index].objApplicant.Id = randomId;


                        if (this.listOfAccounts[index].objeAcc.Aadhar_Number__c == this.matchValue) {
                            console.log('INSIDE AADHAR CONDITION');
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Info',
                                    message: 'Exisitng account found With your Aadhar Number',
                                    variant: 'info',
                                }),
                            );
                        } else if (this.listOfAccounts[index].objeAcc.PAN_Number__c == this.matchValue) {
                            console.log('INSIDE PAN MATCH CONDITION');
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Info',
                                    message: 'Exisitng account found With your PAN Number',
                                    variant: 'info',
                                }),
                            );
                        } else if (this.listOfAccounts[index].objeAcc.Passport_Number__c == this.matchValue) {
                            console.log('INSIDE passport MATCH CONDITION');
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Info',
                                    message: 'Exisitng account found With your Passport Number',
                                    variant: 'info',
                                }),
                            );
                        } else if (this.listOfAccounts[index].objeAcc.Driving_License_Number__c == this.matchValue) {
                            console.log('INSIDE Driving license MATCH CONDITION');
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Info',
                                    message: 'Exisitng account found With your Driving license Number',
                                    variant: 'info',
                                }),
                            );
                        } else if (this.listOfAccounts[index].objeAcc.Voter_ID__c == this.matchValue) {
                            console.log('INSIDE voter Id MATCH CONDITION');
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Info',
                                    message: 'Exisitng account found With your Voter Id',
                                    variant: 'info',
                                }),
                            );
                        }

                        this.listOfAccounts[index].alreadyduplicatefound = true;

                        console.log('bfssfvsvsvvds = ', JSON.stringify(this.listOfAccounts));


                        if(this.listOfAccounts[index].objApplicant.Type__c == 'Co-applicant'){
                            this.listOfAccounts[index].ShowDemography = true;
                        }
                        else{
                            this.listOfAccounts[index].ShowDemography = false;
                        }

                        if(this.isSalesUser == false){
                            if(this.listOfAccounts[index].objeAcc.Aadhar_Number__c != undefined){
                                this.listOfAccounts[index].objeAcc.makeadhardisable = true;
                                this.listOfAccounts[index].hideBasicSection = true;
                            }
                            else{
                                this.listOfAccounts[index].objeAcc.makeadhardisable = false;
                            }
                        }
                        else if(this.isSalesUser == true){
                            if(this.listOfAccounts[index].objeAcc.Aadhar_Number__c != undefined){
                                this.listOfAccounts[index].objeAcc.salessmakeadhardisable = true;
                                this.listOfAccounts[index].hideBasicSection = true;
                            }
                            else{
                                this.listOfAccounts[index].objeAcc.salessmakeadhardisable = false;
                            }
                        }
                        
                        if(this.listOfAccounts[index].objeAcc.PAN_Number__c != undefined){
                            this.listOfAccounts[index].objeAcc.makepandisable = true;
                            
                        }
                        else{
                            this.listOfAccounts[index].objeAcc.makepandisable = false; 
                        }

                        if(this.listOfAccounts[index].objeAcc.Passport_Number__c != undefined){
                            this.listOfAccounts[index].objeAcc.makepassportdisable = true;
                        }
                        else{
                            this.listOfAccounts[index].objeAcc.makepassportdisable = false;
                        }

                        if(this.listOfAccounts[index].objeAcc.Driving_License_Number__c != undefined){
                            this.listOfAccounts[index].objeAcc.makedrivingdisable = true;
                        }
                        else{
                            this.listOfAccounts[index].objeAcc.makedrivingdisable = false;
                        }

                        if(this.listOfAccounts[index].objeAcc.Voter_ID__c != undefined){
                            this.listOfAccounts[index].objeAcc.makevoteriddisable = true;
                        }
                        else{
                            this.listOfAccounts[index].objeAcc.makevoteriddisable = false;
                        }

                        if(this.listOfAccounts[index].objeAcc.FirstName != undefined){
                            this.listOfAccounts[index].objeAcc.makenamedisable = true;
                        }
                        else{
                            this.listOfAccounts[index].objeAcc.makenamedisable = false;
                        }
                        if(this.listOfAccounts[index].objeAcc.Gender__c != undefined){
                            this.listOfAccounts[index].objeAcc.makeGenderdisable = true;
                        }
                        else{
                            this.listOfAccounts[index].objeAcc.makeGenderdisable = false;
                        }
                        if(this.listOfAccounts[index].objeAcc.MiddleName != undefined){
                            this.listOfAccounts[index].objeAcc.makemiddlenamedisable = true;
                        }
                        else{
                            this.listOfAccounts[index].objeAcc.makemiddlenamedisable = false;
                        }

                        if(this.listOfAccounts[index].objeAcc.LastName != undefined){
                            this.listOfAccounts[index].objeAcc.makelastnamedisable = true;
                        }
                        else{
                            this.listOfAccounts[index].objeAcc.makelastnamedisable = false;
                        }

                        if(this.listOfAccounts[index].appPermanentAdd.Same_as_Current_Address__c != undefined){
                            this.listOfAccounts[index].appPermanentAdd.makePermanentAddProofdisabled = true;
                        }
                        else{
                            this.listOfAccounts[index].appPermanentAdd.makePermanentAddProofdisabled = false;
                        }

                        if(this.listOfAccounts[index].objApplicant.Aadhar_Verified__c == true){
                            this.listOfAccounts[index].showButtonAadhar = false;
                        }
                        else{
                            this.listOfAccounts[index].showButtonAadhar = true;
                        }

                        if(this.listOfAccounts[index].objApplicant.Pan_verified__c == true){
                            this.listOfAccounts[index].panTemplate = false;
                        }
                        else{
                            this.listOfAccounts[index].panTemplate = true;
                        }

                        if(this.listOfAccounts[index].objeAcc.CKYC_Number__c != undefined){
                            this.listOfAccounts[index].objeAcc.makeCKYCdisable = true;
                        }
                        else{
                            this.listOfAccounts[index].objeAcc.makeCKYCdisable = false;
                        }

                        if(this.listOfAccounts[index].objeAcc.NREG_Number__c != undefined){
                            this.listOfAccounts[index].objeAcc.makeNREGdisable = true;
                        }
                        else{
                            this.listOfAccounts[index].objeAcc.makeNREGdisable = false;
                        }


                        // this.listOfAccounts.forEach(element => {
                        //     console.log('fdafdaf== ', element.objeAcc.Aadhar_Number__c);
                        //     console.log('fdafdaf== ', element.objeAcc.PAN_Number__c);
                        //     console.log('fdafdaf== ', element.objeAcc.Passport_Number__c);
                        //     console.log('fdafdaf== ', element.objeAcc.Driving_License_Number__c);
                        //     console.log('fdafdaf== ', element.objeAcc.Voter_ID__c);
                        //     //element.alreadyduplicatefound = true;
                        //     if (element.objApplicant.Type__c == 'Co-applicant') {
                        //         element.ShowDemography = true;
                        //     }
                        //     if (element.objeAcc.Aadhar_Number__c != undefined) {
                        //         console.log('INSIDE ADHAR DISSABLE CONDITION');
                        //         element.objeAcc.makeadhardisable = true;
                        //     }
                        //     if (element.objeAcc.PAN_Number__c != undefined) {
                        //         console.log('INSIDE PAN DISSABLE CONDITION');
                        //         element.objeAcc.makepandisable = true;
                        //     }
                        //     if (element.objeAcc.Passport_Number__c != undefined) {
                        //         console.log('INSIDE PASSPORT DISSABLE CONDITION');
                        //         element.objeAcc.makepassportdisable = true;
                        //     }
                        //     if (element.objeAcc.Driving_License_Number__c != undefined) {
                        //         console.log('INSIDE DRIVING DISSABLE CONDITION');
                        //         element.objeAcc.makedrivingdisable = true;
                        //     }
                        //     if (element.objeAcc.Voter_ID__c != undefined) {
                        //         console.log('INSIDE VOTER DISSABLE CONDITION');
                        //         element.objeAcc.makevoteriddisable = true;
                        //     }
                        //     if (element.objeAcc.FirstName != undefined) {
                        //         console.log('INSIDE firstName DISSABLE CONDITION');
                        //         element.objeAcc.makenamedisable = true;
                        //     }
                        //     if (element.objeAcc.MiddleName != undefined) {
                        //         console.log('INSIDE middlename DISSABLE CONDITION');
                        //         element.objeAcc.makemiddlenamedisable = true;
                        //     }
                        //     if (element.objeAcc.LastName != undefined) {
                        //         console.log('INSIDE middlename DISSABLE CONDITION');
                        //         element.objeAcc.makelastnamedisable = true;
                        //     }
                        //     if (element.appPermanentAdd.Same_as_Current_Address__c == true) {
                        //         console.log('insidee trureeee');
                        //         element.appPermanentAdd.makePermanentAddProofdisabled = true;
                        //     } else {
                        //         element.appPermanentAdd.makePermanentAddProofdisabled = false;

                        //     }
                        //     if (account.objApplicant.Relation_with_applicant__c == 'OTHER') {
                        //         console.log('insidee trureeee');
                        //         account['ShowFieldsRelationWithAppliIfOther'] = true;
                        //     } else {
                        //         account['ShowFieldsRelationWithAppliIfOther'] = false;

                        //     }
                        //     if (account.objApplicant.Aadhar_Verified__c == true) {
                        //         console.log('insidee trureeee');
                        //         account['showButtonAadhar'] = false;
                        //     } else {
                        //         account['showButtonAadhar'] = true;

                        //     }
                        //     if (account.objApplicant.Pan_verified__c == true) {
                        //         console.log('insidee trureeee');
                        //         account['panTemplate'] = false;
                        //     } else {
                        //         account['panTemplate'] = true;

                        //     }

                        // })

                    } else {

                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error!!',
                                message: `An account exists with the ${this.matchParameter} provided. Kindly crosscheck`,
                                variant: 'Error',
                            }),
                        );

                        this.listOfAccounts.forEach((account) => {
                            account['errorMsgForDuplicate'] = true;
                            account['matchValue'] = this.matchValue;
                        });

                        console.log('listaccounttt=== ', JSON.stringify(this.listOfAccounts));
                    }
                }

            })
            .catch((error) => {
                console.log(error);
            })
    }
    //==================== karza integration ================
    @track ConewModal = false;
    @track CoshowModalAadhar = false;
    @track CoconsentYes = false;
    @track CoverifiedAadhar=false;
    @track CoaadharInput;
    @track requestIdAadhar;
    @track aadharInputStyle = 'display:none';
    @track buttonStyleAadhar = 'display:none';
    @track lastFour;

    CoconsentChange(event) {
        console.log("event  for consent" + event.target.checked);
        if (event.target.checked == true) {
            this.CoconsentYes = true;
        } else {
            this.CoconsentYes = false;
        }
    }
    closeModalAadhar() {
        this.CoshowModalAadhar = false;
        this.otpValueAadhar = ""
    }
    CoGetOtpAadhar(event) {
        //debugger
        // var foundelement = this.listOfAccounts.find(ele => ele.objApplicant.Id == event.target.dataset.id);
        // console.log("checking status ===",event.target.dataset.id);
        // let obj = JSON.parse(foundelement);
        // console.log("checking ===",obj);

        if (this.LAadharNumber.slice(0, 4) === "XXXX" && this.CoconsentYes == true) {
            this.ConewModal = true;
            this.CoshowModalAadhar = false;
        } else
            if (this.CoconsentYes == true) {
                this.CoverifiedAadhar = true;
                setTimeout(() => {
                    this.CoverifiedAadhar = false;
                }, 9000)
                console.log(this.LAadharNumber);

                if (this.LAadharNumber != "" && this.LAadharNumber != undefined) {
                    console.log("VerificationStarted ---- " + this.LAadharNumber);

                    AadharVerification({ aadhaarNo: this.LAadharNumber, consent: 'y' })
                        .then((result) => {
                            console.log("result===" + result);
                            let responseObj = JSON.parse(result);
                            console.log(responseObj);
                            this.requestIdAadhar = responseObj.requestId;
                            console.log("requestId======" + this.requestIdAadhar);
                            if (responseObj.statusCode == 101) {
                                this.CoshowModalAadhar = true;
                                const event = new ShowToastEvent({
                                    title: 'Success',
                                    message: 'OTP sent successfully!',
                                    variant: 'success',
                                });
                                this.dispatchEvent(event);

                            } else {
                                const event = new ShowToastEvent({
                                    title: 'Error',
                                    message: 'Failed to send OTP. Please try again!',
                                    variant: 'error',
                                });
                                this.dispatchEvent(event);
                            }
                        })
                        .catch((error) => {
                            console.log(error);
                            const event = new ShowToastEvent({
                                title: 'Error',
                                message: 'Failed to send OTP',
                                variant: 'error',
                            });
                            this.dispatchEvent(event);
                        })
                }
            } else {
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: 'Please check consent',
                    variant: 'error',
                });
                this.dispatchEvent(event);
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
        console.log("otp", this.otpValueAadhar);
        console.log("LAadharNumber", this.LAadharNumber);
        console.log("requestIdAadhar", this.requestIdAadhar);
       
        downloadAadhar({ 'otp': this.otpValueAadhar, 'aadhaarNo': this.LAadharNumber.slice(0, 4) === "XXXX" ? this.firstEightAadhar + this.lastFour : this.LAadharNumber, 'requestId': this.requestIdAadhar, 'consent': 'y' })
            .then((result) => {
                console.log("result===" + result);
                console.log(this.aadharResponse);
                let responseObj = JSON.parse(result);
                this.aadharResponse = responseObj;
                console.log("result log", responseObj);
                if (responseObj.statusCode == 101) {
                    // if (responseObj.dataResponse.statusCode == 101) {
                    //data response to be added
                    // responseObj.result.dataFromAadhaar.dob != undefined ?
                    //     this.AppliDOB = responseObj.result.dataFromAadhaar.dob : '';
                    // console.log("this.Aplidob------" + this.AppliDOB);
                    // responseObj.result.dataFromAadhaar.address.splitAddress.pincode != undefined ?
                    //     this.AppliCurrentPincode = responseObj.result.dataFromAadhaar.address.splitAddress.pincode : '';
                    // console.log("this.pin------" + this.AppliCurrentPincode);
                    // getPin({pin:this.AppliCurrentPincode})
                    // .then((res)=>{
                    //     this.AppliCurrentPincode = res.Id;
                    // })

                    // const address = responseObj.result.dataFromAadhaar.address.splitAddress;
                    // this.AppliCurrentAddProof = 'Aadhar Card';
                    // this.AppliCurrentAddress = address.street;
                    // this.AppliCurrentCity = address.postOffice;
                    // this.AppliCurrentTaluka = address.subdistrict;
                    // this.AppliCurrentDistrict = address.district;
                    // this.AppliCurrentLandmark = address.landmark;
                    // this.AppliCurrentState =  address.state;
                    // this.AppliCurrentCountry = address.country;

                    // console.log('Address:'+address);
                    // console.log('street ='+address.street);
                    // console.log('houseNumber ='+ address.houseNumber);
                    // console.log('landmark ='+ address.landmark);
                    // console.log('location ='+ address.location);
                    // console.log('subdistrict ='+ address.subdistrict);
                    // console.log('district ='+ address.district);
                    // console.log('state ='+ address.state);
                    // console.log('pincode ='+ address.pincode);
                    // console.log('country ='+ address.country);

                    // if (responseObj.result.dataFromAadhaar.gender != undefined) {
                    //     if (responseObj.result.dataFromAadhaar.gender == "M") {
                    //         this.AppliGender = "Male";
                    //     } else {
                    //         this.AppliGender = "Female";
                    //     }
                    // }
                    // console.log("this.gender------" + this.AppliGender);
                    this.CoshowModalAadhar = false;
                    
                    this.buttonStyleAadhar = 'display:none';
                    this.aadharInputStyle = 'display:none';
                    this.makeadhardisable = true;
                    this.coAadharStaus = true;
                  
                    const event = new ShowToastEvent({
                        title: 'Success',
                        message: 'Aadhar verified successfully!',
                        variant: 'success',
                    });
                    this.dispatchEvent(event);
                    this.CoverifiedAadhar = true;
                    this.makeadhardisable = true;
                    this.aadharStatus = true;
                    this.aadharLastFour = this.LAadharNumber.slice(-4)
                    this.LAadharNumber = 'XXXXXXXX' + this.aadharLastFour;
                } else {
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: 'Please enter correct OTP',
                        variant: 'error',
                    });
                    this.dispatchEvent(event);
                }
            })
            .catch((error) => {
                console.error("error", error);
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: 'Failed to verify',
                    variant: 'error',
                });
                this.dispatchEvent(event);
            });
        console.log("aadhar Verification");
    }
    handleAadharOtp(event) {
        this.otpValueAadhar = event.target.value
        console.log("otp----" + this.otpValueAadhar);
    }
    inputAadhar() {
        console.log("Re-enter Aadhar Number");
        if (this.CoconsentYes == true) {
            this.ConewModal = true;
            this.CoshowModalAadhar = false;
            this.lastFour =this.LAadharNumber.slice(-4);
        } else {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please check consent',
                variant: 'error',
            });
            this.dispatchEvent(event);
        }
    }
    closeModalforRe() {
        this.ConewModal = false;
        this.firstEightAadhar = '';
        
    }
    handleFirstEightAadhar(event){
        this.firstEightAadhar = event.target.value;
    }
    @track Fullaadhar;
    RehandleVerifyAadhar(){
        this.CoverifiedAadhar = true;
        setTimeout(() => {
            this.CoverifiedAadhar = false;
        }, 5000)
        // debugger
        if (this.firstEightAadhar != "" && this.firstEightAadhar != undefined) {
            this.Fullaadhar = this.firstEightAadhar + this.lastFour
            console.log("fulll aadhar "+this.Fullaadhar);
            AadharVerification({ aadhaarNo:this.Fullaadhar, consent: 'y' })
                .then((result) => {
                    console.log("result===" + result);
                    let responseObj = JSON.parse(result);
                    console.log(responseObj);
                    this.requestIdAadhar = responseObj.requestId;
                    if (responseObj.statusCode == 101) {
                        this.ConewModal=false;
                        this.CoshowModalAadhar = true;
                        const event = new ShowToastEvent({
                            title: 'Success',
                            message: 'OTP sent successfully',
                            variant: 'success',
                        });
                        this.dispatchEvent(event);
                    } else {
                        const event = new ShowToastEvent({
                            title: 'Error',
                            message: 'Failed to send OTP. Please try again',
                            variant: 'error',
                        });
                        this.dispatchEvent(event);
                    }
                })
                .catch((error) => {
                    console.log(error);
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: 'Failed to send OTP',
                        variant: 'error',
                    });
                    this.dispatchEvent(event);
                })
        }
    }
    @track buttonStylePan='display:none';
    @track sumScore;
    @track sumScorePercent;
    @track verifiedPan;
    @track matchText;
    panVerification(event) {
        //debugger
        if (this.LAadharNumber == '' || this.LAadharNumber == undefined) {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please Fill Aadhar Number!!',
                variant: 'error',
            });
            this.dispatchEvent(event);
        }
        console.log("Pan Verification Started");
        if (this.PANNumber != "" && this.PANNumber != undefined) {
            this.aadharLastFour = this.LAadharNumber.slice(-4)
            console.log("---last four digit=== "+this.aadharLastFour);
            console.log("dob", this.LDateOfBirth);
            panVerification({ 'pan': this.PANNumber, 'aadhaarLastFour': this.aadharLastFour, 'dob': this.LDateOfBirth, 'name': this.LfNName + ' ' + this.LLastName, 'address': this.ApplicurrentAddress + " " + this.appliCurrentCity, 'getContactDetails': 'y', 'PANStatus': 'y', 'consent': 'y' })
                .then((result) => {
                    let responseObj = JSON.parse(result);
                    console.log(responseObj);
                    if (responseObj.dataResponse.statusCode == 101) {
                        let profileMatch = responseObj.dataResponse.result.profileMatch;
                        for (let i = 0; i < profileMatch.length; i++) {
                            this.sumScore += profileMatch[i].matchScore;
                        }
                        this.sumScorePercent = (this.sumScore / 2) * 100;
                        this.sumScorePercent = Math.floor(this.sumScorePercent * 100) / 100;
                        console.log('this.sumScore', this.sumScore);
                        console.log('this.sumScore percent', this.sumScorePercent);
                        console.log("Pan Verification done!!");

                        console.log("MAKESSSS===" + this.makepandisable);
                        const event = new ShowToastEvent({
                            title: 'Success',
                            message: 'PAN verified',
                            variant: 'success',
                        });
                        this.dispatchEvent(event);
                        this.buttonLabelPan = 'Verified';
                        this.verifiedPan = true;
                        this.makepandisable = true;
                        this.makeadhardisable = true;
                        this.buttonStylePan = 'display:none; font-weight:bold;'
                        // this.matchText = this.sumScorePercent + '% PROFILE MATCHED';
                    } else {
                        const event = new ShowToastEvent({
                            title: 'Error',
                            message: 'PAN not verified please try again with correct details',
                            variant: 'error',
                        });
                        this.dispatchEvent(event);
                    }
                })
                .catch((error) => {
                    console.log(error);
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: 'Failed to verify',
                        variant: 'error',
                    });
                    this.dispatchEvent(event);
                })

        }
    }
}