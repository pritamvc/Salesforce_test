import { LightningElement, wire, api, track } from 'lwc';
import creatCommFormLeadRecords from '@salesforce/apex/LeadApplicantDetailsClone.creatUpdateApplicantRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import getapplicantData from '@salesforce/apex/LeadApplicantDetailsClone.getLeadRelatedRecord';
import getPin from '@salesforce/apex/LeadApplicantDetailsClone.getPin';
import getPincodeRecord from '@salesforce/apex/LoanApplicationFormHelper.getPincodeRecord';
import OtpRequest from '@salesforce/apex/EmailVerification.OtpRequest';
import OtpRequestMob from '@salesforce/apex/MobileVerification.OtpRequest';
import OtpVerify from '@salesforce/apex/EmailVerification.verify';
import OtpVerifyMob from '@salesforce/apex/MobileVerification.OtpVerify';
import AadharVerification from '@salesforce/apex/DocumentVerification.AadharVerification';
import downloadAadhar from '@salesforce/apex/DocumentVerification.DownloadAadhar';
import panVerification from '@salesforce/apex/DocumentVerification.PanProfile';
import getLeadTotalPercentage from '@salesforce/apex/DocumentVerification.getLeadTotalPercentage';
import updateLeadTotalPercentage from '@salesforce/apex/DocumentVerification.updateLeadTotalPercentage';
import duplicateAccount from '@salesforce/apex/LeadCoapplicantEmploymentController.duplicateAccount';
import progressBar from '@salesforce/messageChannel/progressBar__c';
import { publish, MessageContext } from 'lightning/messageService';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import ProfileName from '@salesforce/schema/User.Profile.Name';
import getSectionWeightage from '@salesforce/apex/LoanApplicationFormHelper.getSectionWeightage';
import KarzaKycOcr from '@salesforce/apex/KarzaKycOcrControllerClone.getDocumentOcred';//Added by Rohit
import getLeadFileNames from '@salesforce/apex/DocumentVerification.getLeadFileNames';//Added by Rohit
import DMS_NAMES from '@salesforce/apex/LoanApplicationFormHelper.DMSNames';//Added by Rohit
import checkPinCodeAvailable from '@salesforce/apex/LeadCoapplicantEmploymentController.checkPinCodeAvailable';//Added by Rohit
import isPassportUploaded from '@salesforce/apex/LeadApplicantDetailsClone.isPassportUploaded';// Added by Rohit 
import getCoApplicantAccoutId from '@salesforce/apex/LeadApplicantDetailsClone.getCoApplicant';// Added by Rohit 

import updateKYCAccount from '@salesforce/apex/KarzaKycOcrControllerClone.updateKYCAccount';// Added by Rohit 

export default class CommunityFormARS extends LightningElement {
    @api leadRecordId;
    @track todaysDate;
    @api financialCoApplicantMobile;
    @api financialCoApplicantEmail;

    //progressbar
    @wire(MessageContext)
    messageContext;
    message;
    @api percentage = 30;

    //@track firstCheck = false;
    @track applicantCheck = false;
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
    @track LAadharNumber;
    @track driveLicenseNumber;
    @track voterId;
    @track passportNumber;
    @track passportFileNumber;
    @track CKYCNumber;
    @track NREGNumber;
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

    //Appli Address Proof
    @track appliAddressProof;
    @api appliAddressProofField = 'Address_Proof__c';
    @track appliAddressProofLabel;
    @api appliAddressProofValue;
    @track appliAddressProofOptions;
    apiappliAddressProof;

    //Show Hide fields
    @track ShowFieldsAppliSpouse = false;
    @track ShowFieldsCourseUniversity = false;
    @track ShowFieldsCourseInstAndCampus = false;
    @track ShowFieldsApplicantCategory = false;
    @track ShowFieldsRelationWithAppliIfOther = false;
    @track ShowFieldsAppliDriveLicDateofExpiry = false;
    @track ShowFieldsCoAppliDriveLicDateofExpiry = false;
    @track errors;

    @track isLoading = false;
    //verification
    @track otpValue;
    @track otpValueMob;
    @track otpValueAadhar;
    @track errormsg = "";
    @track verified = false;
    @track buttonLabel = 'Verify Email';
    @track buttonStyle = 'display:none';
    @track verifiedMob = false;
    @track buttonLabelMob = 'Verify Mobile';
    @track buttonStyleMob = 'display:none';
    @track verifiedAadhar = false;
    @track buttonLabelAadhar = 'Verify Aadhar';
    @track buttonStyleAadhar = 'display:none';
    @track verifiedPan = false;
    @track buttonLabelPan = 'Verify PAN';
    @track buttonStylePan = 'display:none';;
    @track aadharLastFour = '';
    @track sumScore = 0;
    @track sumScorePercent = 0;
    @track matchText = '';
    @track verifiedbuttonAadhar = false;
    @track activeSections = [];
    @track isOpen1 = false;
    @track isOpen2 = false;
    @track isOpen3 = false;
    @track displayText = 'display:none;'
    @track displayTextMob = 'display:none;'
    @track displayTextAadhar = 'display:none;'
@track filename;//added by dhanashri
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

    //Contact Point Address for Applicant Section
    @api objectNameAddress = 'ContactPointAddress';
    @api recordTypeId5;

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
    @track requestIdTemp = '';
    @track requestIdMob = '';
    @track requestIdAadhar = '';
    @track consent = false;
    @track open = true;
    secFive = false;
    secSix = false;
    secSeven = false;
    secEight = false;
    secNine = false;
    secTen = false;
    @track EduIndex;

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
    @track AppliCurrentYear;
    @track Setcommunicationaddresscurrent = false;
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
    @track AppliPermanentYear;
    @track AppliPermanentSameAsCurrent;
    @track Setcommunicationaddresspernmanent = false;
    @track error;

    //error
    @track errorAadharInvalid = false;
    @track errorPanInvalid = false;
    @track errorDLInvalid = false;
    @track errorPassportInvalid = false;
    @track errorPasspostFilrInvalid = false;
    @track errorVoterIdInvalid = false;
    @track errorFirstNameInvalid = false;
    @track errorLastNameInvalid = false;
    @track errorFatherNameInvalid = false;
    @track errorMotherNameInvalid = false;
    @track errorCKYCInvalid = false;
    @track errorNREGInvalid = false;
    @track hideBasicSection = false;
    @track saleserrorAadharInvalid = false;
    @track salessmakeadhardisable = false;
    @track SalesLAadharNumber;

    userId = Id;
    userProfileName;

    @track isSalesUser = false;

    @wire(getRecord, { recordId: Id, fields: [ProfileName] })
    userDetails({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            if (data.fields.Profile.value != null) {
                this.userProfileName = data.fields.Profile.value.fields.Name.value;
                if (this.userProfileName == 'Sales Profile') {
                    //this.isSalesUser = true; Uncommnet after OCR added
                    this.isSalesUser = false;
                } else {
                    this.isSalesUser = false;
                }
            }
        }
    }

    closeModal() {
        this.showModal = false;
        this.otpValue = ""
    }
    closeModalMobile() {
        this.showModalMobile = false;
        this.otpValueMob = ""

    }
    closeModalAadhar() {
        this.showModalAadhar = false;
        this.otpValueAadhar = ""
    }
    closeModalforRe() {
        this.newModal = false;

    }
    @track firstEightAadhar;
    handleFirstEightAadhar(event) {
        this.firstEightAadhar = event.target.value;
    }
    @wire(getObjectInfo, { objectApiName: '$objectName' })
    getObjectData1({ error, data }) {
        if (data) {
            if (this.recordTypeId == null)
                this.recordTypeId = data.defaultRecordTypeId;
            this.apisalutation = this.objectName + '.' + this.salutationField;
            this.salutationLabel = data.fields[this.salutationField].label;
        } else if (error) {
        }
    }

    //Salutation
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: '$apisalutation' })
    getPicklistValues10({ error, data }) {
        if (data) {
            this.salutationOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };
            });
        } else if (error) {
        }
    }

    //Contact Point Address Picklist field from SFDC
    @wire(getObjectInfo, { objectApiName: '$objectNameAddress' })
    getObjectData500({ error, data }) {
        if (data) {
            if (this.recordTypeId5 == null)
                this.recordTypeId5 = data.defaultRecordTypeId;
            this.apiappliAddressProof = this.objectNameAddress + '.' + this.appliAddressProofField;
            this.appliAddressProofLabel = data.fields[this.appliAddressProofField].label;
        } else if (error) {
            console.log('Error Account Picklist ' + JSON.stringify(error));
        }
    }

    //Address Prrof  - Contact Point Address object    
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId5', fieldApiName: '$apiappliAddressProof' })
    getPicklistValues501({ error, data }) {
        if (data) {
            this.appliAddressProofOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };
            });
        } else if (error) {
            console.log('Error  ' + error);
        }
    }

    //Account Picklist field from SFDC
    @wire(getObjectInfo, { objectApiName: '$objectNameAcc' })
    getObjectData2({ error, data }) {
        if (data) {
            if (this.recordTypeId1 == null)
                this.recordTypeId1 = data.defaultRecordTypeId;
            //Acc-Marital Status
            this.apiMaritalStatusPerAcc = this.objectNameAcc + '.' + this.MaritalStatusPerAccField;
            this.MaritalStatusPerAccLabel = data.fields[this.MaritalStatusPerAccField].label;
            //Acc-Gender 
            this.apiGenderPerAcc = this.objectNameAcc + '.' + this.GenderPerAccField;
            this.GenderPerAccLabel = data.fields[this.GenderPerAccField].label;
            //Is Income Considered / Is Financial from Account from SFDC
            this.apiisIncomeConsiderIsFinPerAcc = this.objectNameAcc + '.' + this.isIncomeConsiderIsFinPerAccField;
            this.isIncomeConsiderIsFinPerAccLabel = data.fields[this.isIncomeConsiderIsFinPerAccField].label;
        } else if (error) {
        }
    }

    //Marital Status - Account
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId1', fieldApiName: '$apiMaritalStatusPerAcc' })
    getPicklistValues011({ error, data }) {
        if (data) {
            this.MaritalStatusPerAccOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };
            });
        } else if (error) {
        }
    }

    //Gender - Account
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId1', fieldApiName: '$apiGenderPerAcc' })
    getPicklistValues012({ error, data }) {
        if (data) {
            this.GenderPerAccOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };
            });
        } else if (error) {
            console.log('Error  ' + error);
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
        } else if (error) {
            console.log('Error  ' + error);
        }
    }
    //TABLE FORMAT CODE 22-Jan    
    handleOtpValueChange(event) {
        this.otpValue = event.target.value;
    }
    handleOtpforMob(event) {
        this.otpValueMob = event.target.value
    }
    handleAadharOtp(event) {
        this.otpValueAadhar = event.target.value
    }
    handleGetOTP() {
        this.verified = true;
        setTimeout(() => {
            this.verified = false;
        }, 5000)
        if (this.LEmail != undefined && this.LEmail != "") {
            OtpRequest({ email: this.LEmail })
                .then((result) => {
                    let responseObj = JSON.parse(result);
                    this.requestIdTemp = responseObj.dataResponse.requestId;
                    if (responseObj.dataResponse.statusCode == 101) {
                        this.showModal = true;
                        this.showToast("Success!!", 'OTP sent successfully', "Success");
                    } else {
                        this.showToast("Error!!", 'Failed to send OTP. Please try again', "Error")
                    }
                })
                .catch((error) => {
                    console.error("er", error);
                    this.showToast("Error!!", 'Failed to send OTP', "Error")
                });
        }
    }
    handleVerify() {
        OtpVerify({ 'otp': this.otpValue, 'requestId': this.requestIdTemp })
            .then((result) => {
                let responseObj = JSON.parse(result);
                if (responseObj.dataResponse.statusCode == 101) {
                    this.showModal = false;
                    this.verified = true;
                    this.buttonStyle = 'display:none'
                    this.displayText = 'display:block;  color:green; font-weight:bold;'
                    this.emailStatus = true;
                    this.showToast("Success!!", 'Email Verified successfully', "Success");
                    this.buttonLabel = 'Verified';
                } else {
                    this.showToast("Error!!", 'Please Enter Correct OTP', "Error")
                }
            })
            .catch((error) => {
                console.error("er", error);
                this.showToast("Error!!", 'Failed to verify OTP', "Error")
            });
    }

    @track aadharResponse;
    @track aadharStatus;
    handleVerifyAadhar() {
        this.verifiedbuttonAadhar = true;
        setTimeout(() => {
            this.verifiedbuttonAadhar = false;
        }, 6000)

        downloadAadhar({ 'otp': this.otpValueAadhar, 'aadhaarNo': this.LAadharNumber.slice(0, 4) === "XXXX" ? this.firstEightAadhar + this.lastFour : this.LAadharNumber, 'requestId': this.requestIdAadhar, 'consent': 'y' })
            .then((result) => {
                let responseObj = JSON.parse(result);
                this.aadharResponse = responseObj;
                if (responseObj.statusCode == 101) {
                    responseObj.result.dataFromAadhaar.dob != undefined ?
                        this.AppliDOB = responseObj.result.dataFromAadhaar.dob : '';
                    this.makedobdisable = true;
                    responseObj.result.dataFromAadhaar.address.splitAddress.pincode != undefined ?
                        this.AppliCurrentPincode = responseObj.result.dataFromAadhaar.address.splitAddress.pincode : '';
                    getPin({ pin: this.AppliCurrentPincode })
                        .then((res) => {
                            this.AppliCurrentPincode = res.Id;
                        })
                    const address = responseObj.result.dataFromAadhaar.address.splitAddress;
                    this.AppliCurrentAddProof = 'Aadhar Card';
                    this.AppliCurrentAddress = address.street;
                    this.AppliCurrentCity = address.postOffice;
                    this.AppliCurrentTaluka = address.subdistrict;
                    this.AppliCurrentDistrict = address.district;
                    this.AppliCurrentLandmark = address.landmark;
                    this.AppliCurrentState = address.state;
                    this.AppliCurrentCountry = address.country;

                    if (responseObj.result.dataFromAadhaar.gender != undefined) {
                        if (responseObj.result.dataFromAadhaar.gender == "M") {
                            this.AppliGender = "Male";
                        } else {
                            this.AppliGender = "Female";
                        }
                    }
                    this.showModalAadhar = false;
                    this.buttonLabelAadhar = 'Verified';
                    this.buttonStyleAadhar = 'display:none';
                    this.displayTextAadhar = 'display:block;  color:green; font-weight:bold;'
                    this.showToast("Success!!", 'Aadhar verified successfully', "Success")
                    this.verifiedAadhar = true;
                    this.makeadhardisable = true;
                    this.aadharStatus = true;
                    this.aadharLastFour = this.LAadharNumber.slice(-4)
                    this.LAadharNumber = 'XXXXXXXX' + this.aadharLastFour;
                    this.aadharInputStyle = 'display:none';
                } else {
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: responseObj.error,
                        variant: 'error',
                    });
                    this.dispatchEvent(event);
                }
            })
            .catch((error) => {
                this.showToast("Error!!", 'Failed to verify', "Error")
                console.error("error", error);
            });
    }
    @track Fullaadhar;
    RehandleVerifyAadhar() {
        this.verifiedAadhar = true;
        setTimeout(() => {
            this.verifiedAadhar = false;
        }, 5000)

        if (this.firstEightAadhar != "" && this.firstEightAadhar != undefined) {
            this.Fullaadhar = this.firstEightAadhar + this.lastFour
            AadharVerification({ aadhaarNo: this.Fullaadhar, consent: 'y' })
                .then((result) => {
                    let responseObj = JSON.parse(result);
                    this.requestIdAadhar = responseObj.requestId;
                    if (responseObj.statusCode == 101) {
                        this.newModal = false;
                        this.showModalAadhar = true;
                        this.showToast("Success!!", 'OTP sent successfully', "Success")
                    } else {
                        this.showToast("Error!!", 'Failed to send OTP. Please try again', "Error")
                    }
                })
                .catch((error) => {
                    console.log(error);
                    this.showToast("Error!!", 'Failed to send OTP', "Error")
                })
        }
    }
    GetOtpAadhar() {
        if (this.LAadharNumber.slice(0, 4) === "XXXX" && this.consentYes == true) {
            this.newModal = true;
            this.showModalAadhar = false
        } else
            if (this.consentYes == true) {
                this.verifiedAadhar = true;
                setTimeout(() => {
                    this.verifiedAadhar = false;
                }, 5000)
                if (this.LAadharNumber != "" && this.LAadharNumber != undefined) {
                    AadharVerification({ aadhaarNo: this.LAadharNumber, consent: 'y' })
                        .then((result) => {
                            let responseObj = JSON.parse(result);
                            this.requestIdAadhar = responseObj.requestId;

                            if (responseObj.statusCode == 101) {
                                this.showModalAadhar = true;
                                this.showToast("Success!!", 'OTP sent successfully', "Success")
                            } else {
                                this.showToast("Error!!", 'Failed to send OTP. Please try again', "Error")
                            }
                        })
                        .catch((error) => {
                            this.showToast("Error!!", 'Failed to send OTP', "Error")
                        })
                }

            } else {
                this.showToast("Error!!", 'Please check consent', "Error")
            }

    }
    @track duplicateAccountResult;
    @track makeadhardisable = false;
    @track makedobdisable = false;//Added by Rohit on 25052023
    @track makepandisable = false;
    @track makepassportdisable = false;
    @track makepassportFiledisable = false;
    @track makevoteriddisable = false;
    @track makedrivingdisable = false;
    @track makeCKYCdisable = false;
    @track makeNREGdisable = false;
    @track panStatus;

    panVerification(event) {
        if (this.LAadharNumber == undefined || this.LAadharNumber == undefined) {
            this.showToast("Error!!", 'Please Fill Aadhar Number', "Error")
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
                        this.sumScorePercent = (this.sumScore / 3) * 100;
                        this.sumScorePercent = Math.floor(this.sumScorePercent * 100) / 100;
                        this.panStatus = true;
                        this.showToast("Success!!", 'PAN verified', "Success")
                        this.buttonLabelPan = 'Verified';
                        this.verifiedPan = true;
                        this.makepandisable = true;
                        this.makeadhardisable = true;
                        this.buttonStylePan = 'display:none;'
                        this.matchText = this.sumScorePercent + '% PROFILE MATCHED';
                    } else {
                        this.showToast("Error!!", 'PAN not verified please try again with correct details', "Error")
                    }
                })
                .catch((error) => {
                    console.log(error);
                    this.showToast("Error!!", 'Failed to verify', "Error")
                })
        }
    }

    handleGetOTPMobile() {
        this.verifiedMob = true;
        setTimeout(() => {
            this.verifiedMob = false;
        }, 5000)
        if (this.LMobile != "" && this.LMobile != undefined) {
            OtpRequestMob({ mobile: this.LMobile, consent: 'y' })
                .then((result) => {
                    let responseObj = JSON.parse(result);
                    this.requestIdMob = responseObj.dataResponse['request_id'];
                    if (responseObj.dataResponse['status-code'] == 101) {
                        this.showModalMobile = true;
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

    handleVerifyMob() {
        OtpVerifyMob({ otp: this.otpValueMob, request_Id: this.requestIdMob })
            .then((result) => {
                let responseObj = JSON.parse(result);
                if (responseObj.dataResponse['status-code'] == 101) {
                    this.showModalMobile = false;
                    this.mobileStatus = true;
                    this.displayTextMob = 'display:block;  color:green; font-weight:bold;'
                    this.buttonStyleMob = 'display:none';
                    this.verifiedMob = true;
                    this.showToast("Success!!", 'Mobile Number Verified', "Success")
                } else {
                    this.showToast("Error!!", 'Failed to Verify! Please try again', "Error")
                }
            })
            .catch((error) => {
                this.showToast("Error!!", 'Failed to verify OTP', "Error")
            });
    }

    connectedCallback() {
        this.getAllApplicantData();
      //  this.getleadFileNames();

        this.namesRenderDMS();
        this.getPassportDoc();
        this.getCoApplicant();
        this.activesectionname = '0';
        this.todaysDate = new Date().toISOString().split('T')[0];
    }
    @track newModal = false;
    inputAadhar() {
        if (this.consentYes == true) {
            this.newModal = true;
            this.showModalAadhar = false;
        } else {
            this.showToast("Error!!", 'Please check consent', "Error")
        }
    }

    @track aadharInput = true;
    @track aadharInputStyle = 'display:none';
    @track lastFour;
    @track emailStatus;
    @track mobileStatus;
    getAllApplicantData() {
        getapplicantData({ leadGetId: this.leadRecordId })
            .then(result => {
                console.log('result::::',JSON.stringify(result));
                this.wrapperForCommLeadForm = result;
                this.setApplicantRecords(this.wrapperForCommLeadForm);//Added by rohit 25052023
            })
            .catch(error => {
            });
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

    newChange(event) {
        this.LEmail = event.target.value;
        if (this.LEmail.match(/[A-Za-z0-9._-]+@[a-z0-9]+\.[a-z]{2,}$/) && this.emailStatus != true) {
            this.buttonStyle = 'display:block';
        } else {
            this.buttonStyle = 'display:none';
        }
    }
    newChangeMob(event) {
        this.LMobile = event.target.value;
        if (this.LMobile.match(/^(?:\+[\d]{1,3})?(?:[\d]{10,13})$/) && this.mobileStatus != true) {
            this.buttonStyleMob = 'display:block';
        } else {
            this.buttonStyleMob = 'display:none';
        }
    }

    @track finalAadharNumberToSave;
    newChangeAadhar(event) {
        this.LAadharNumber = event.target.value;
        if (this.LAadharNumber != '') {
            if (this.LAadharNumber.match(/^[0-9]{12}$/) && this.aadharStatus != true) {
                // this.buttonStyleAadhar = 'display:block';
                this.errorAadharInvalid = false;
                this.hideBasicSection = true;
            } else {
                this.buttonStyleAadhar = 'display:none';
                this.errorAadharInvalid = true;
                this.hideBasicSection = false;
            }
        }
        else {
            this.errorAadharInvalid = false;
        }

        this.aadharLastFour = this.LAadharNumber.slice(-4);
        this.finalAadharNumberToSave = 'XXXXXXXX' + this.aadharLastFour;

    }

    salesChangeAadhar(event) {
        this.SalesLAadharNumber = event.target.value;

        if (this.SalesLAadharNumber != '') {
            if (this.SalesLAadharNumber.match(/^[0-9]{4}$/)) {
                this.saleserrorAadharInvalid = false;
                this.hideBasicSection = true;
            } else {
                this.saleserrorAadharInvalid = true;
                this.hideBasicSection = false;
            }
        }
        else {
            this.saleserrorAadharInvalid = false;
        }
        this.finalAadharNumberToSave = 'XXXXXXXX' + this.SalesLAadharNumber;
    }


    newChangePan(event) {
        this.PANNumber = event.target.value.toUpperCase();
        if (this.PANNumber != '') {
            if (this.PANNumber.match(/[A-Z]{5}[0-9]{4}[A-Z]{1}$/) && this.panStatus != true) {
                // this.buttonStylePan = 'display:block';
                this.errorPanInvalid = false;
            } else {
                this.buttonStylePan = 'display:none';
                this.errorPanInvalid = true;
            }
        } else {
            this.errorPanInvalid = false;
        }
    }

    @track errormessagetrue = false;
    @track errorfield;
    @track calculatePercent = 0;
    @track increasePercent = 1.20;

    handlechange(event) {

        if (event.target.name == "Salutation") {
            this.leadSalutation = event.target.value;
            if (event.target.value == '' || event.target.value == undefined) {
                if (this.calculatePercent < 0) {
                    this.calculatePercent = 0;
                }
            }
        }
        if (event.target.name == "firstName") {
            if (event.target.value == '' || event.target.value == undefined) {
                if (this.calculatePercent < 0) {
                    this.calculatePercent = 0;
                }
            }
            let fieldValue = event.target.value;
            let pattern = /^[a-zA-Z\s]*$/;
            if (!pattern.test(fieldValue)) {
                this.errorFirstNameInvalid = true;

            } else {
                this.leadFirstName = event.target.value;
                this.errorFirstNameInvalid = false;
            }
        }
        if (event.target.name == "LastName1") {
            let fieldValue = event.target.value;
            if (event.target.value == '' || event.target.value == undefined) {
                if (this.calculatePercent < 0) {
                    this.calculatePercent = 0;
                }
            }
            let pattern = /^[a-zA-Z\s]*$/;
            if (!pattern.test(fieldValue)) {
                this.errorLastNameInvalid = true;

            } else {
                this.leadLastName = event.target.value;
                this.errorLastNameInvalid = false;
            }
        }
        if (event.target.name == "middleName") {
            this.leadMiddleName = event.target.value;
        }
        if (event.target.name == "Email") {
            this.leadEmail = event.target.value;
            if (event.target.value == '' || event.target.value == undefined) {
                if (this.calculatePercent < 0) {
                    this.calculatePercent = 0;
                }
            }
        }
        if (event.target.name == "MotherFirstName") {

            let fieldValue = event.target.value;
            if (event.target.value == '' || event.target.value == undefined) {
                if (this.calculatePercent < 0) {
                    this.calculatePercent = 0;
                }
            }
            let pattern = /^[a-zA-Z\s]*$/;
            if (!pattern.test(fieldValue)) {
                this.errorMotherNameInvalid = true;
            } else {
                this.errorMotherNameInvalid = false;
                this.AppliMotherFirstName = event.target.value;
            }

        }
        if (event.target.name == "MotherMiddleName") {
            this.AppliMotherMiddleName = event.target.value;
        }
        if (event.target.name == "MotherLastName") {
            this.AppliMotherLastName = event.target.value;
        }
        if (event.target.name == "Date of Birth") {
            this.AppliDOB = event.target.value;
        }
        if (event.target.name == "Gender") {
            this.AppliGender = event.target.value;
            if (event.target.value == '' || event.target.value == undefined) {
                if (this.calculatePercent < 0) {
                    this.calculatePercent = 0;
                }
            }
        }
        if (event.target.name == "Mobile") {
            this.leadMobile = event.target.value;
            if (event.target.value == '' || event.target.value == undefined) {
                if (this.calculatePercent < 0) {
                    this.calculatePercent = 0;
                }
            }
        }
        if (event.target.name == "FatherFirstName") {
            let fieldValue = event.target.value;
            if (event.target.value == '' || event.target.value == undefined) {
                if (this.calculatePercent < 0) {
                    this.calculatePercent = 0;
                }
            }
            let pattern = /^[a-zA-Z\s]*$/;
            if (!pattern.test(fieldValue)) {
                this.errorFatherNameInvalid = true;
            } else {
                this.errorFatherNameInvalid = false;
                this.AppliFatherFirstName = event.target.value;
            }
        }
        if (event.target.name == "FatherMiddleName") {
            this.AppliFatherMiddleName = event.target.value;
        }
        if (event.target.name == "FatherLastName") {
            this.AppliFatherLastName = event.target.value;
        }
        if (event.target.name == "SpouseFirstName") {
            this.AppliSpouseFirstName = event.target.value;
        }
        if (event.target.name == "SpouseMiddleName") {
            this.AppliSpouseMiddleName = event.target.value;
        }
        if (event.target.name == "SpouseLastName") {
            this.AppliSpouseLastName = event.target.value;
        }
        if (event.target.name == "voterId") {
            this.voterId = event.target.value;
            if (this.voterId != '') {
                if (this.voterId.length > 20) {
                    this.errorVoterIdInvalid = true;
                }
                else {
                    this.errorVoterIdInvalid = false;
                }
            } else {
                this.errorVoterIdInvalid = false;
            }
        }
        if (event.target.name == "passportNumber") {
            this.passportNumber = event.target.value;
            if (this.passportNumber != '') {
                if (this.passportNumber.match(/^[A-Z]{1}[0-9]{7}$/)) {
                    this.errorPassportInvalid = false;
                }
                else {
                    this.errorPassportInvalid = true;
                }
            } else {
                this.errorPassportInvalid = false;
            }
        }
        //Added by Avadhut 
        if (event.target.name == "passportFileNumber") {
            this.passportFileNumber = event.target.value;
            if (this.passportFileNumber != '') {
                if (this.passportFileNumber.match(/^[A-Z]{4}[0-9]{8}$/)) {
                    this.errorPasspostFilrInvalid = false;
                }
                else {
                    this.errorPasspostFilrInvalid = true;
                }
            } else {
                this.errorPasspostFilrInvalid = false;
            }
        }
        if (event.target.name == "appliCurrentAddProof") {
            this.AppliCurrentAddProof = event.target.value;
            if (event.target.value == '' || event.target.value == undefined) {
                //this.calculatePercent = this.calculatePercent- this.increasePercent;
                if (this.calculatePercent < 0) {
                    this.calculatePercent = 0;
                }
            } else {
                //this.calculatePercent = this.calculatePercent + this.increasePercent;
            }
        }
        if (event.target.name == "ApplicurrentAddress") {
            this.AppliCurrentAddress = event.target.value;
            if (event.target.value == '' || event.target.value == undefined) {
                //this.calculatePercent = this.calculatePercent- this.increasePercent;
                if (this.calculatePercent < 0) {
                    this.calculatePercent = 0;
                }
            } else {
                //this.calculatePercent = this.calculatePercent + this.increasePercent;
            }
        }
        if (event.target.name == "appliCurrentCity") {
            this.AppliCurrentCity = event.target.value;
        }
        if (event.target.name == "appliCurrentDistrict") {
            this.AppliCurrentDistrict = event.target.value;
        }
        if (event.target.name == "appliCurrentPincode") {
            this.AppliCurrentPincode = event.target.value;
        }
        if (event.target.name == "appliCurrentLandmark") {
            this.AppliCurrentLandmark = event.target.value;
        }
        if (event.target.name == "appliCurrentState") {
            this.AppliCurrentState = event.target.value;
        }
        if (event.target.name == "appliCurrentCountry") {
            this.AppliCurrentCountry = event.target.value.toUpperCase();
        }
        if (event.target.name == "appliCurrentyear") {
            this.AppliCurrentYear = event.target.value;
            if (event.target.value == '' || event.target.value == undefined) {
                if (this.calculatePercent < 0) {
                    this.calculatePercent = 0;
                }
            } else {
                //this.calculatePercent = this.calculatePercent + this.increasePercent;
            }
        }
        if (event.target.name == "appliPermanentAddressProof") {
            this.AppliPermanentAddProof = event.target.value;
        }
        if (event.target.name == "permanentAddress") {
            this.AppliPermanentAddress = event.target.value;
        }
        if (event.target.name == "appliPermanentCity") {
            this.AppliPermanentCity = event.target.value;
        }
        if (event.target.name == "appliPermanentDistrict") {
            this.AppliPermanentDistrict = event.target.value;
        }
        if (event.target.name == "appliPermanentPincode") {
            this.AppliPermanentPincode = event.target.value;
        }
        if (event.target.name == "appliPermanentLandmark") {
            this.AppliPermanentLandmark = event.target.value;
        }
        if (event.target.name == "appliPermanentState") {
            this.AppliPermanentState = event.target.value;
        }
        if (event.target.name == "appliPermanentCountry") {
            this.AppliPermanentCountry = event.target.value.toUpperCase();
        }
        if (event.target.name == "appliPermanentyear") {
            this.AppliPermanentYear = event.target.value;
        }
        if (event.target.name == "CKYCNumber") {
            this.CKYCNumber = event.target.value;
            let pattern = /[0-9]{14}/;
            if (!pattern.test(this.CKYCNumber) || this.CKYCNumber.length < 14) {
                this.errorCKYCInvalid = true;
            } else {
                this.errorCKYCInvalid = false;
            }
        }
        if (event.target.name == "NREGNumber") {
            this.NREGNumber = event.target.value;
            let pattern = /[A-Z]{2}-\d{2}-\d{3}-\d{3}-\d{3}\/\d{3}/;
            if (!pattern.test(this.NREGNumber)) {
                this.errorNREGInvalid = true;
            } else {
                this.errorNREGInvalid = false;
            }
        }
    }

    handleAppliSpouseShowHide(event) {
        if (event.target.value == '' || event.target.value == undefined) {
            //this.calculatePercent = this.calculatePercent- this.increasePercent;
            if (this.calculatePercent < 0) {
                this.calculatePercent = 0;
            }
        } else {
            //this.calculatePercent = this.calculatePercent + this.increasePercent;
        }
        if (event.target.name == "Marital Status" && event.target.value != "") {
            this.AppliMaritlStatus = event.target.value;
        }
        if (event.target.value === "Married") {
            this.ShowFieldsAppliSpouse = true;
        }
        else {
            this.ShowFieldsAppliSpouse = false;
        }
    }

    handleCoAppliDriveLicDateOfExpiry(event) {
        this.Driving_License_Number__c = event.target.value;
        if (this.Driving_License_Number__c != '') {
            if (this.Driving_License_Number__c.match(/[A-Za-z]{2}[\d\s\-]{14}/)) {
                this.errorDLInvalid = false;
            }
            else {
                this.errorDLInvalid = true;
            }
        } else {
            this.errorDLInvalid = false;
        }
    }

    @track makePermanentAddProofdisabled = false;

    handleAppliPermanentAddBox(event) {
        //Same as Current address checkbox   
        this.AppliPermanentSameAsCurrent = event.target.checked;
        if (this.AppliPermanentSameAsCurrent == true) {
            this.AppliPermanentAddProof = this.AppliCurrentAddProof;
            this.AppliPermanentAddress = this.AppliCurrentAddress;
            this.AppliPermanentCity = this.AppliCurrentCity;
            this.AppliPermanentTaluka = this.AppliCurrentTaluka;
            this.AppliPermanentDistrict = this.AppliCurrentDistrict;
            this.AppliPermanentYear = this.AppliCurrentYear;
            this.AppliPermanentPincode = this.AppliCurrentPincode;
            this.AppliPermanentLandmark = this.AppliCurrentLandmark;
            this.AppliPermanentState = this.AppliCurrentState;
            this.AppliPermanentCountry = this.AppliCurrentCountry;

            if (this.AppliCurrentCountry == 'INDIA' || this.AppliCurrentCountry == 'India') {
                this.AppliPermIsCommAddressvalue = 'Current Address';
                this.makePermanentAddProofdisabled = true;
            }

        } else {
            this.AppliPermanentAddProof = '';
            this.AppliPermanentAddress = '';
            this.AppliPermanentCity = '';
            this.AppliPermanentDistrict = '';
            this.AppliPermanentYear = '';
            this.AppliPermanentPincode = '';
            this.AppliPermanentLandmark = '';
            this.AppliPermanentState = '';
            this.AppliPermanentCountry = '';
            this.makePermanentAddProofdisabled = false;
        }
    }

    @track SetAppliIsIncomeConsiderYes;
    @track SetAppliIsIncomeConsiderNo;

    handleAppliIsIncomeConsiderIsFin(event) {
        this.AppliIsIncomeConsiderIsFin = event.target.value;
    }

    // Aadhar File Upload 
    get acceptedFormats() {
        return ['.pdf', '.png', '.jpeg', '.jpg'];
    }

    newToast(title, message, varient) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: varient,
        });
        this.dispatchEvent(evt);

    }

    value = 10;
    radius = "circular";
    size = "medium";
    showDescription = true;
    description = "Progress..";
    variant = "error";
    customColor;
    code = "";

    //Demography
    @track DemographyID;
    @track City__c;
    handlePincodeSelection(event) {
        console.log('Inside handlePincodeSelection');
        if (event.target.value == '' || event.target.value == undefined) {
            //this.calculatePercent = this.calculatePercent- this.increasePercent;
            if (this.calculatePercent < 0) {
                this.calculatePercent = 0;
            }
        } else {
            //this.calculatePercent = this.calculatePercent + this.increasePercent;
        }
        this.AreaPinCode = event.target.value;
        console.log('Inside AreaPinCode', this.AreaPinCode);
        if (this.AreaPinCode == '') {
            this.AppliCurrentCity = '';
            this.AppliCurrentState = '';
            this.AppliCurrentCountry = '';
            this.AppliCurrentDistrict = '';
            this.AppliCurrentTaluka = '';
        } else {
            getPincodeRecord({ pincode: this.AreaPinCode }) //this parameter is passed to Class-LeadApplicantDetails.getPincodeRecord
                .then(result => {
                    this.AreaPinCodeResult = result;
                    this.AppliCurrentPincode = this.AreaPinCodeResult.Id;
                    this.AppliCurrentCity = this.AreaPinCodeResult.City_Name__c;
                    this.AppliCurrentState = this.AreaPinCodeResult.State__c;
                    this.AppliCurrentCountry = this.AreaPinCodeResult.Country__c;
                    this.AppliCurrentDistrict = this.AreaPinCodeResult.Area_Name_Taluka__c;
                    this.AppliCurrentTaluka = this.AreaPinCodeResult.Area_Name_Taluka__c;
                })
                .catch(error => {
                    this.errors = error;
                });
        }
    }

    handlePincodeSelection1(event) {
        this.AreaPinCode = event.target.value;
        if (this.AreaPinCode == '') {
            this.AppliPermanentCity = '';
            this.AppliPermanentState = '';
            this.AppliPermanentCountry = '';
            this.AppliPermanentDistrict = '';
            this.AppliPermanentTaluka = '';
        } else {
            getPincodeRecord({ pincode: this.AreaPinCode }) //this parameter is passed to Class-LeadApplicantDetails.getPincodeRecord
                .then(result => {
                    this.AreaPinCodeResult = result;
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
    }

    @track incrementPercentage = 0.75;
    @track consentYes;
    @api percentageAll;
    consentChange(event) {
        if (event.target.checked == true) {
            this.consentYes = true;
            //this.percentageAll = this.incrementPercentage + this.percentageAll;
        } else {
            this.consentYes = false;
            //this.percentageAll = this.percentageAll - this.incrementPercentage;
        }

    }
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title, message, variant
            }),
        );
    }

    handleSaveApplicant() {
        var appSameMobile;
        var appSameEmail;
        if (this.financialCoApplicantMobile.includes(this.leadMobile)) {
            appSameMobile = true;
        }
        if (this.financialCoApplicantEmail.includes(this.leadEmail)) {
            appSameEmail = true;
        }

        if (this.alreadyduplicatefound == true && this.checkResponse == true) {
            this.AppliCurrentAddID = null;
            this.AppliPermanentAddID = null;
            this.DemographyID = null;
        }

        if (this.AppliPermIsCommAddressvalue == 'Current Address') {
            this.Setcommunicationaddresscurrent = true;
        }
        else if (this.AppliPermIsCommAddressvalue == 'Permanent Address') {
            this.Setcommunicationaddresspernmanent = true;
        }

        if(this.alreadyduplicatefound == true){
            this.showToast("Error!!", 'Applicant and Co-Applicant details cannot be the same. Kindly Crosscheck', "Error")
        }
        else if (this.saleserrorAadharInvalid == true) {
            this.showToast("Error!!", 'Fill last 4 Digits of Aadhar Number', "Error")
        }
        else if (this.AppliIsIncomeConsiderIsFin == 'Yes' && (this.PANNumber == '' || this.PANNumber == undefined)) {
            this.showToast("Error!!", 'Please enter PAN Number', "Error")
        }
        else if (this.errorCKYCInvalid == true) {
            this.showToast("Error!!", 'Please enter Valid CKYC Number', "Error")
        }
        else if (this.errorFirstNameInvalid == true) {
            this.showToast("Error!!", 'Please enter Valid First Name', "Error")
        }
        else if (this.errorLastNameInvalid == true) {
            this.showToast("Error!!", 'Please enter Valid Last Name', "Error")
        }
        else if (this.errorFatherNameInvalid == true) {
            this.showToast("Error!!", 'Please enter Valid Father First Name', "Error")
        }
        else if (this.errorMotherNameInvalid == true) {
            this.showToast("Error!!", 'Please enter Valid Mother First Name', "Error")
        }
        else if (this.errorAadharInvalid == true) {
            this.showToast("Error!!", 'Please enter Valid Aadhar Number', "Error")
        }
        else if (this.errorPanInvalid == true) {
            this.showToast("Error!!", 'Please enter Valid PAN Number', "Error")
        }
        else if (this.errorDLInvalid == true) {
            this.showToast("Error!!", 'Please enter Valid Driving Licence', "Error")
        }
        else if (this.errorPassportInvalid == true) {
            this.showToast("Error!!", 'Please enter Valid Passport Number', "Error")
        }
        else if (this.errorPasspostFilrInvalid == true) {
            this.showToast("Error!!", 'Please enter Valid Passport File Number', "Error")
        }
        else if (this.errorVoterIdInvalid == true) {
            this.showToast("Error!!", 'Please enter Valid Voter Id', "Error")
        }
        else if (this.errormessagetrue == true) {
            this.showToast("Error!!", `Please enter valid ${this.errorfield}`, "Error")
        }
        else if (this.LAadharNumber == this.duplicatevalue && this.errorMsgForDuplicate == true) {
            this.showToast("Error!!", 'An account exists with the Aadhar provided. Kindly crosscheck', "Error")
        }
        else if (this.PANNumber == this.duplicatevalue && this.errorMsgForDuplicate == true) {
            this.showToast("Error!!", 'An account exists with the PAN Number provided. Kindly crosscheck', "Error")
        }
        else if (this.passportNumber == this.duplicatevalue && this.errorMsgForDuplicate == true) {
            this.showToast("Error!!", 'An account exists with the Passport Number provided. Kindly crosscheck', "Error")
        }
        else if (this.Driving_License_Number__c == this.duplicatevalue && this.errorMsgForDuplicate == true) {
            this.showToast("Error!!", 'An account exists with the Driving License provided. Kindly crosscheck', "Error")
        }
        else if (this.voterId == this.duplicatevalue && this.errorMsgForDuplicate == true) {
            this.showToast("Error!!", 'An account exists with the Voter Id provided. Kindly crosscheck', "Error")
        }
        else if (this.AppliDOB == '' || this.AppliDOB == undefined || (this.isSalesUser == false && (this.LAadharNumber == '' || this.LAadharNumber == undefined)) ||
            this.leadFirstName == '' || this.leadFirstName == undefined || this.leadLastName == '' || this.leadLastName == undefined ||
            this.leadEmail == '' || this.leadEmail == undefined || this.leadMobile == '' || this.leadMobile == undefined
        ) {
            this.showToast("Error!!", 'Required details are not provided', "Error")
        }
        else if (
            this.AppliCurrentCity == '' || this.AppliCurrentCity == undefined ||
            this.AppliCurrentPincode == '' || this.AppliCurrentPincode == undefined ||
            this.AppliCurrentState == '' || this.AppliCurrentState == undefined ||
            this.AppliPermanentCity == '' || this.AppliPermanentCity == undefined ||
            this.AppliPermanentDistrict == '' || this.AppliPermanentDistrict == undefined ||
            this.AppliCurrentDistrict == '' || this.AppliCurrentDistrict == undefined ||
            this.AppliPermanentPincode == '' || this.AppliPermanentPincode == undefined ||
            this.AppliPermanentState == '' || this.AppliPermanentState == undefined ||
            this.AppliPermanentCountry == '' || this.AppliPermanentCountry == undefined ||
            this.AppliCurrentCountry == '' || this.AppliCurrentCountry == undefined
        ) {
            this.showToast("Error!!", 'Please enter Current and Permanent Address', "Error")
        }
        else if ((this.AppliPermanentCountry.toUpperCase() != 'INDIA' && this.AppliPermIsCommAddressvalue == 'Permanent Address') || (this.AppliCurrentCountry.toUpperCase() != 'INDIA' && this.AppliPermIsCommAddressvalue == 'Current Address')) {
            this.showToast("Error!!", 'Please enter country as India for communication address', "Error")
        }
        else if (appSameMobile) {
            this.showToast("Error!!", "Applicant and Financial CoApplicant cannot have the same Mobile Number", "Error")
        }
        else if (appSameEmail) {
            this.showToast("Error!!", "Applicant and Financial CoApplicant cannot have the same Email", "Error");
        }
        else {
            let LeadDataSaveRec = {
                Salutation: this.leadSalutation,
                FirstName: this.leadFirstName,
                MiddleName: this.leadMiddleName,
                LastName: this.leadLastName,
                MobilePhone: this.leadMobile,
                Email: this.leadEmail,
                Id: this.leadRecordId,
                Aadhar_Number__c: this.finalAadharNumberToSave,
                PAN_Number__c: this.PANNumber,
                Voter_Id__c: this.voterId,
                Passport_Number__c: this.passportNumber,
                Driving_License_Number__c: this.Driving_License_Number__c,
                CKYC_Number__c: this.CKYCNumber,
                NREG_Number__c: this.NREGNumber,
                KYC_Consent__c: this.consentYes,
                Passport_File_Number__c: this.passportFileNumber,
                Applicant_Section__c: this.applicantCheck,
                Gender__c: this.AppliGender,
                Date_of_Birth__c: this.AppliDOB
            }

            let AppliAccDataSaveRec = {
                Salutation: this.leadSalutation,
                FirstName: this.leadFirstName,
                MiddleName: this.leadMiddleName,
                LastName: this.leadLastName,
                PersonEmail: this.leadEmail,
                PersonMobilePhone: this.leadMobile,
                Marital_Status__c: this.AppliMaritlStatus,
                Gender__c: this.AppliGender,
                Is_Income_Considered_Is_Financial__c: this.AppliIsIncomeConsiderIsFin,
                Date_of_Birth__c: this.AppliDOB,
                Id: this.AppliAccID,
                Aadhar_Number__c: this.finalAadharNumberToSave,
                PAN_Number__c: this.PANNumber,
                Voter_Id__c: this.voterId,
                Passport_Number__c: this.passportNumber,
                Driving_License_Number__c: this.Driving_License_Number__c,
                Aadhar_Verified__c: this.aadharStatus,
                Email_Verified__c: this.emailStatus,
                Mobile_Number_Verified__c: this.mobileStatus,
                Pan_verified__c: this.panStatus,
                Passport_File_Number__c: this.passportFileNumber,
                CKYC_Number__c: this.CKYCNumber,
                NREG_Number__c: this.NREGNumber,
            }
            let AppliCurrentAddSaveRec = {
                Name: this.leadFirstName + ' ' + this.leadLastName,
                Address_Proof__c: this.AppliCurrentAddProof,
                Address_1__c: this.AppliCurrentAddress,
                City__c: this.AppliCurrentCity,
                District__c: this.AppliCurrentDistrict,
                Years_In_The_Address__c: this.AppliCurrentYear,
                Pin_Code__c: this.AppliCurrentPincode,
                Landmark__c: this.AppliCurrentLandmark,
                State__c: this.AppliCurrentState,
                Country__c: this.AppliCurrentCountry,
                Id: this.AppliCurrentAddID,
                Address_Type__c: 'Current Address',
                Account__c: this.AppliAccID,
                Is_Communication_address__c: this.Setcommunicationaddresscurrent
            }
            let AppliPermanentAddSaveRec = {
                Name: this.leadFirstName + ' ' + this.leadLastName,
                Address_Proof__c: this.AppliPermanentAddProof,
                Address_1__c: this.AppliPermanentAddress,
                City__c: this.AppliPermanentCity,
                //Taluka__c: this.AppliPermanentTaluka,
                District__c: this.AppliPermanentDistrict,
                Years_In_The_Address__c: this.AppliPermanentYear,
                Pin_Code__c: this.AppliPermanentPincode,
                Landmark__c: this.AppliPermanentLandmark,
                State__c: this.AppliPermanentState,
                Country__c: this.AppliPermanentCountry,
                Id: this.AppliPermanentAddID,
                Address_Type__c: 'Permanent Address',
                Account__c: this.AppliAccID,
                Same_as_Current_Address__c: this.AppliPermanentSameAsCurrent,
                Is_Communication_address__c: this.Setcommunicationaddresspernmanent
            }
            let DemographyAddSaveRec = {
                Id: this.DemographyID,
                Father_s_First_Name__c: this.AppliFatherFirstName,
                Father_s_Middle_Name__c: this.AppliFatherMiddleName,
                Father_s_Last_Name__c: this.AppliFatherLastName,
                Mother_s_First_Name__c: this.AppliMotherFirstName,
                Mother_s_Middle_Name__c: this.AppliMotherMiddleName,
                Mother_s_Last_Name__c: this.AppliMotherLastName,
                Spouse_s_First_Name__c: this.AppliSpouseFirstName,
                Spouse_s_Middle_name__c: this.AppliSpouseMiddleName,
                Spouse_s_Last_Name__c: this.AppliSpouseLastName
            }
            //Wrapper Class variable
            let wrapperCommFormRecord = {
                leadSaveRec: JSON.stringify(LeadDataSaveRec),
                appliAccSaveRec: JSON.stringify(AppliAccDataSaveRec),
                appliCurrentAddSave: JSON.stringify(AppliCurrentAddSaveRec),
                appliPermanentAddSave: JSON.stringify(AppliPermanentAddSaveRec),
                demoSaveRec: JSON.stringify(DemographyAddSaveRec)
            }
            this.isLoading = true;
            creatCommFormLeadRecords({
                wrapperCommFormDetails: JSON.stringify(wrapperCommFormRecord)
            })
                .then(response => {
                    this.isLoading = false;
                    if (response != null) {
                        this.wrapperForCommLeadForm = response;
                        this.checkResponse = false;
                        this.setApplicantRecords(this.wrapperForCommLeadForm);
                    }
                    this.showToast("Success!!", 'Successfully Saved', "Success")
                }).catch(error => {
                    console.log('Error: ' + JSON.stringify(error));
                    this.isLoading = false;
                })
        }
    }

    handleNextApplicant() {
        var appSameMobile;
        var appSameEmail;
        if (this.financialCoApplicantMobile.includes(this.leadMobile)) {
            appSameMobile = true;
        }
        if (this.financialCoApplicantEmail.includes(this.leadEmail)) {
            appSameEmail = true;
        }
        if (this.alreadyduplicatefound == true && this.checkResponse == true) {
            this.AppliCurrentAddID = null;
            this.AppliPermanentAddID = null;
            this.DemographyID = null;
        }

        if (this.AppliPermIsCommAddressvalue == 'Current Address') {
            this.Setcommunicationaddresscurrent = true;
        }else if (this.AppliPermIsCommAddressvalue == 'Permanent Address') {
            this.Setcommunicationaddresspernmanent = true;
        }
        if(this.alreadyduplicatefound == true){
            this.showToast("Error!!", 'Applicant and Co-Applicant details cannot be the same. Kindly Crosscheck', "Error")
        }else if (this.errorNREGInvalid == true) {
            this.showToast("Error!!", 'Please enter Valid NREG Number', "Error")
        }else if (this.saleserrorAadharInvalid == true) {
            this.showToast("Error!!", 'Fill last 4 Digits of Aadhar Number', "Error")
        }else if (this.AppliIsIncomeConsiderIsFin == 'Yes' && (this.PANNumber == '' || this.PANNumber == undefined)) {
            this.showToast("Error!!", 'Please enter PAN Number', "Error")
        }else if (this.errorCKYCInvalid == true) {
            this.showToast("Error!!", 'Please enter Valid CKYC Number', "Error")
        }else if (this.errorFirstNameInvalid == true) {
            this.showToast("Error!!", 'Please enter Valid First Name', "Error")
        }else if (this.errorLastNameInvalid == true) {
            this.showToast("Error!!", 'Please enter Valid Last Name', "Error")
        }else if (this.errorFatherNameInvalid == true) {
            this.showToast("Error!!", 'Please enter Valid Father First Name', "Error")
        }else if (this.errorMotherNameInvalid == true) {
            this.showToast("Error!!", 'Please enter Valid Mother First Name', "Error")
        }else if (this.errorAadharInvalid == true) {
            this.showToast("Error!!", 'Please enter Valid Aadhar Number', "Error")
        }else if (this.errorPanInvalid == true) {
            this.showToast("Error!!", 'Please enter Valid PAN Number', "Error")
        }else if (this.errorDLInvalid == true) {
            this.showToast("Error!!", 'Please enter Valid Driving Licence', "Error")
        }else if (this.errorPassportInvalid == true) {
            this.showToast("Error!!", 'Please enter Valid Passport Number', "Error")
        }else if (this.errorPasspostFilrInvalid == true) {
            this.showToast("Error!!", 'Please enter Valid Passport File Number', "Error")
        }else if (this.errorVoterIdInvalid == true) {
            this.showToast("Error!!", 'Please enter Valid Voter Id', "Error")
        }else if (this.errormessagetrue == true) {
            this.showToast("Error!!", `Please enter valid ${this.errorfield}`, "Error")
        }else if (this.LAadharNumber == this.duplicatevalue && this.errorMsgForDuplicate == true) {
            this.showToast("Error!!", 'An account exists with the Aadhar provided. Kindly crosscheck', "Error")
        }else if (this.PANNumber == this.duplicatevalue && this.errorMsgForDuplicate == true) {
            this.showToast("Error!!", 'An account exists with the PAN Number provided. Kindly crosscheck', "Error")
        }else if (this.passportNumber == this.duplicatevalue && this.errorMsgForDuplicate == true) {
            this.showToast("Error!!", 'An account exists with the Passport Number provided. Kindly crosscheck', "Error")
        }else if (this.Driving_License_Number__c == this.duplicatevalue && this.errorMsgForDuplicate == true) {
            this.showToast("Error!!", 'An account exists with the Driving License provided. Kindly crosscheck', "Error")
        }else if (this.voterId == this.duplicatevalue && this.errorMsgForDuplicate == true) {
            this.showToast("Error!!", 'An account exists with the Voter Id provided. Kindly crosscheck', "Error")
        }else if (this.AppliDOB == '' || this.AppliDOB == undefined || (this.isSalesUser == false && (this.LAadharNumber == '' || this.LAadharNumber == undefined)) ||
            this.leadSalutation == '' || this.leadSalutation == undefined ||
            this.leadFirstName == '' || this.leadFirstName == undefined || this.leadLastName == '' || this.leadLastName == undefined ||
            this.leadEmail == '' || this.leadEmail == undefined || this.leadMobile == '' || this.leadMobile == undefined ||
            this.AppliGender == '' || this.AppliGender == undefined || this.AppliFatherFirstName == '' || this.AppliFatherFirstName == undefined ||
            this.AppliMotherFirstName == '' || this.AppliMotherFirstName == undefined ||
            this.AppliMaritlStatus == '' || this.AppliMaritlStatus == undefined || (this.AppliMaritlStatus == 'Married' && (this.AppliSpouseFirstName == '' || this.AppliSpouseFirstName == undefined)) ||
            this.AppliCurrentAddress == '' || this.AppliCurrentAddress == undefined || this.AppliPermanentAddress == '' || this.AppliPermanentAddress == undefined ||
            this.AppliCurrentCity == '' || this.AppliCurrentCity == undefined || this.AppliCurrentYear == '' || this.AppliCurrentYear == undefined ||
            this.AppliCurrentPincode == '' || this.AppliCurrentPincode == undefined || this.AppliPermIsCommAddressvalue == '' || this.AppliPermIsCommAddressvalue == undefined ||
            this.AppliCurrentState == '' || this.AppliCurrentState == undefined || this.AppliPermanentCity == '' || this.AppliPermanentCity == undefined ||
            this.AppliPermanentDistrict == '' || this.AppliPermanentDistrict == undefined || this.AppliPermanentYear == '' || this.AppliPermanentYear == undefined ||
            this.AppliPermanentPincode == '' || this.AppliPermanentPincode == undefined || this.AppliPermanentState == '' || this.AppliPermanentState == undefined ||
            this.AppliPermanentCountry == '' || this.AppliPermanentCountry == undefined || this.AppliCurrentCountry == '' || this.AppliCurrentCountry == undefined ||
            this.AppliCurrentAddProof == '' || this.AppliCurrentAddProof == undefined || this.AppliPermanentAddProof == '' || this.AppliPermanentAddProof == undefined) {

            this.showToast("Error!!", 'Required details are not provided', "Error")
        }
        else if ((this.AppliPermanentCountry.toUpperCase() != 'INDIA' && this.AppliPermIsCommAddressvalue == 'Permanent Address') || (this.AppliCurrentCountry.toUpperCase() != 'INDIA' && this.AppliPermIsCommAddressvalue == 'Current Address')) {
            this.showToast("Error!!", 'Please enter country as India for communication address', "Error")
        }
        else if (appSameMobile) {
            this.showToast("Error!!", "Applicant and Financial CoApplicant cannot have the same Mobile Number", "Error")
        }
        else if (appSameEmail) {
            this.showToast("Error!!", "Applicant and Financial CoApplicant cannot have the same Email", "Error");
        }
        else {
            //this.applicantCheck = true;
            let sum = 0;
            if (this.applicantCheck == true) {
                sum = 0;
            }
            else {
                //Get the weightage for Applicant Section
                getSectionWeightage({ sectionName: 'Applicant' })
                    .then(result => {
                        sum = result;
                    })
                    .catch(error => {
                    })
            }
            let LeadDataSaveRec = {
                Salutation: this.leadSalutation,
                FirstName: this.leadFirstName,
                MiddleName: this.leadMiddleName,
                LastName: this.leadLastName,
                MobilePhone: this.leadMobile,
                Email: this.leadEmail,
                Id: this.leadRecordId,
                Aadhar_Number__c: this.finalAadharNumberToSave,
                PAN_Number__c: this.PANNumber,
                Voter_Id__c: this.voterId,
                Passport_Number__c: this.passportNumber,
                Driving_License_Number__c: this.Driving_License_Number__c,
                CKYC_Number__c: this.CKYCNumber,
                NREG_Number__c: this.NREGNumber,
                KYC_Consent__c: this.consentYes,
                Passport_File_Number__c: this.passportFileNumber,
                Applicant_Section__c: true,
                Gender__c: this.AppliGender,
                Date_of_Birth__c: this.AppliDOB
            }

            let AppliAccDataSaveRec = {
                Salutation: this.leadSalutation,
                FirstName: this.leadFirstName,
                MiddleName: this.leadMiddleName,
                LastName: this.leadLastName,
                PersonEmail: this.leadEmail,
                PersonMobilePhone: this.leadMobile,
                Marital_Status__c: this.AppliMaritlStatus,
                Gender__c: this.AppliGender,
                Is_Income_Considered_Is_Financial__c: this.AppliIsIncomeConsiderIsFin,
                Date_of_Birth__c: this.AppliDOB,
                //Is_Communication_address__c: this.AppliPermIsCommAddressvalue,
                Id: this.AppliAccID,
                Aadhar_Number__c: this.finalAadharNumberToSave,
                PAN_Number__c: this.PANNumber,
                Voter_Id__c: this.voterId,
                Passport_Number__c: this.passportNumber,
                Driving_License_Number__c: this.Driving_License_Number__c,
                Aadhar_Verified__c: this.aadharStatus,
                Email_Verified__c: this.emailStatus,
                Mobile_Number_Verified__c: this.mobileStatus,
                Pan_verified__c: this.panStatus,
                Passport_File_Number__c: this.passportFileNumber,
                CKYC_Number__c: this.CKYCNumber,
                NREG_Number__c: this.NREGNumber,
            }
            let AppliCurrentAddSaveRec = {
                Name: this.leadFirstName + ' ' + this.leadLastName,
                Address_Proof__c: this.AppliCurrentAddProof,
                Address_1__c: this.AppliCurrentAddress,
                City__c: this.AppliCurrentCity,
                //Taluka__c: this.AppliCurrentTaluka,
                District__c: this.AppliCurrentDistrict,
                Years_In_The_Address__c: this.AppliCurrentYear,
                Pin_Code__c: this.AppliCurrentPincode,
                Landmark__c: this.AppliCurrentLandmark,
                State__c: this.AppliCurrentState,
                Country__c: this.AppliCurrentCountry,
                Id: this.AppliCurrentAddID,
                Address_Type__c: 'Current Address',
                Account__c: this.AppliAccID,
                Is_Communication_address__c: this.Setcommunicationaddresscurrent

            }
            let AppliPermanentAddSaveRec = {
                Name: this.leadFirstName + ' ' + this.leadLastName,
                Address_Proof__c: this.AppliPermanentAddProof,
                Address_1__c: this.AppliPermanentAddress,
                City__c: this.AppliPermanentCity,
                //Taluka__c: this.AppliPermanentTaluka,
                District__c: this.AppliPermanentDistrict,
                Years_In_The_Address__c: this.AppliPermanentYear,
                Pin_Code__c: this.AppliPermanentPincode,
                Landmark__c: this.AppliPermanentLandmark,
                State__c: this.AppliPermanentState,
                Country__c: this.AppliPermanentCountry,
                Id: this.AppliPermanentAddID,
                Address_Type__c: 'Permanent Address',
                Account__c: this.AppliAccID,
                Same_as_Current_Address__c: this.AppliPermanentSameAsCurrent,
                Is_Communication_address__c: this.Setcommunicationaddresspernmanent
            }

            let DemographyAddSaveRec = {
                Id: this.DemographyID,
                Father_s_First_Name__c: this.AppliFatherFirstName,
                Father_s_Middle_Name__c: this.AppliFatherMiddleName,
                Father_s_Last_Name__c: this.AppliFatherLastName,
                Mother_s_First_Name__c: this.AppliMotherFirstName,
                Mother_s_Middle_Name__c: this.AppliMotherMiddleName,
                Mother_s_Last_Name__c: this.AppliMotherLastName,
                Spouse_s_First_Name__c: this.AppliSpouseFirstName,
                Spouse_s_Middle_name__c: this.AppliSpouseMiddleName,
                Spouse_s_Last_Name__c: this.AppliSpouseLastName
            }
            //Wrapper Class variable
            let wrapperCommFormRecord = {
                leadSaveRec: JSON.stringify(LeadDataSaveRec),
                appliAccSaveRec: JSON.stringify(AppliAccDataSaveRec),
                appliCurrentAddSave: JSON.stringify(AppliCurrentAddSaveRec),
                appliPermanentAddSave: JSON.stringify(AppliPermanentAddSaveRec),
                demoSaveRec: JSON.stringify(DemographyAddSaveRec)
            }

            this.isLoading = true;
            creatCommFormLeadRecords({
                wrapperCommFormDetails: JSON.stringify(wrapperCommFormRecord)
            })
                .then(response => {
                    this.isLoading = false;
                    if (response != null) {
                        this.wrapperForCommLeadForm = response;
                        this.checkResponse = false;
                        this.setApplicantRecords(this.wrapperForCommLeadForm);

                    }
                    this.showToast("Success!!", 'Successfully Saved', "Success")
                    const onNextEvent = new CustomEvent('next', {
                        detail: {
                            nextValue: '2',
                        },
                    });
                    this.dispatchEvent(onNextEvent);

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
                }).catch(error => {
                    console.log('Error: ' + JSON.stringify(error));
                    this.isLoading = false;
                })
        }
    }

    handleIsCommAddress(event) {

        if (event.target.name == "IsCommunicationAddress") {
            this.AppliPermIsCommAddressvalue = event.target.value;
        }
        if ((this.AppliPermanentCountry.toUpperCase() != 'INDIA' && this.AppliPermIsCommAddressvalue == 'Permanent Address') || (this.AppliCurrentCountry.toUpperCase() != 'INDIA' && this.AppliPermIsCommAddressvalue == 'Current Address')) {
            this.showToast("Error!!", 'Please enter country as India for communication address', "Error")
        }
    }

    get IsCommAddressoptions() {
        return [
            { label: 'Current Address', value: 'Current Address' },
            { label: 'Permanent Address', value: 'Permanent Address' },
        ];
    }

    @track matchParameter;
    @track matchValue;
    @track matchDateOfBirth;
    @track alreadyduplicatefound = false;
    @track newListofaccount;
    @track errorMsgForDuplicate = false;
    @track duplicatevalue;
    @track checkResponse = true;

    /*********Get DuplicateAccount ******************/
    checkduplicate(event) {
        if (event.target.value == '' || event.target.value == undefined) {
            //this.calculatePercent = this.calculatePercent- this.increasePercent;
            if (this.calculatePercent < 0) {
                this.calculatePercent = 0;
            }
        } else {
            //this.calculatePercent = this.calculatePercent + this.increasePercent;
        }

        if (event.target.name === 'LAadharNumber' || event.target.name === 'SalesLAadharNumber') {
            this.matchParameter = 'Aadhar Number';
            if ((this.isSalesUser == false && (this.LAadharNumber == undefined || this.LAadharNumber == null)) ||
                (this.isSalesUser == true && (this.SalesLAadharNumber == undefined || this.SalesLAadharNumber == null))) {
                this.matchValue = null;
            } else {
                this.matchValue = this.finalAadharNumberToSave;
            }

        }
        else if (event.target.name === 'PANNumber') {
            this.matchParameter = 'PAN Number';
            this.matchValue = event.target.value;
        }
        else if (event.target.name === 'passportNumber') {
            this.matchParameter = 'Passport Number';
            this.matchValue = event.target.value;
        }
        else if (event.target.name === 'Driving_License_Number__c') {
            this.matchParameter = 'Driving License Number';
            this.matchValue = event.target.value;
        }
        else if (event.target.name === 'voterId') {
            this.matchParameter = 'Voter ID';
            this.matchValue = event.target.value;
        }

        duplicateAccount({ 'duplicateParameter': this.matchParameter, 'duplicateValue': this.matchValue, 'matchDOB': this.AppliDOB })
            .then((result) => {
                this.duplicateAccountResult = result;

                console.log('coApplicantAccountId=>' , this.coApplicantAccountId);
                console.log('result.objeAcc.Id=>' , result.objeAcc.Id);
                if (result != null) {
                    if(result.objeAcc.Id == this.coApplicantAccountId){
                        console.log('INSIDE Co-Applicant anad Applicant are same');
                        this.showToast("Error!!", 'Applicant and Co-Applicant details cannot be same. Kindly Crosscheck', "Error")
                        this.alreadyduplicatefound = true;
                    }else if ((this.AppliAccID != this.duplicateAccountResult.objeAcc.Id) && (this.AppliAccID == null || this.AppliAccID == undefined) &&
                        (this.alreadyduplicatefound == false || this.alreadyduplicatefound == undefined)) {
                        if (this.duplicateAccountResult.objeAcc.Aadhar_Number__c == this.matchValue) {
                            this.showToast("Info!!", 'Exisitng account found With your Aadhar Number', "info")
                        } else if (this.duplicateAccountResult.objeAcc.PAN_Number__c == this.matchValue) {
                            this.showToast("Info!!", 'Exisitng account found With your PAN Number', "info")
                        } else if (this.duplicateAccountResult.objeAcc.Passport_Number__c == this.matchValue) {
                            this.showToast("Info!!", 'Exisitng account found With your Aadhar Number', "info")
                        } else if (this.duplicateAccountResult.objeAcc.Driving_License_Number__c == this.matchValue) {
                            this.showToast("Info!!", 'Exisitng account found With your Driving license Number', "info")
                        } else if (this.duplicateAccountResult.objeAcc.Voter_ID__c == this.matchValue) {
                            this.showToast("Info!!", 'Exisitng account found With your Voter Id', "info")
                        }

                        if (this.duplicateAccountResult.objeAcc.Aadhar_Number__c != null) {
                            this.hideBasicSection = true;
                            if (this.isSalesUser == false) {
                                if (this.LAadharNumber == '' || this.LAadharNumber == undefined) {
                                    this.LAadharNumber = this.duplicateAccountResult.objeAcc.Aadhar_Number__c;
                                    this.lastFour = this.LAadharNumber.slice(-4);
                                    this.makeadhardisable = true;
                                    // this.buttonStyleAadhar= "display:block";
                                    this.verifiedAadhar = false;
                                    // this.verifiedAadhar=false;
                                    this.buttonLabelAadhar = "Verify Aadhar";

                                } else {
                                    this.LAadharNumber = this.duplicateAccountResult.objeAcc.Aadhar_Number__c;
                                    this.lastFour = this.LAadharNumber.slice(-4);
                                    this.makeadhardisable = true;
                                    this.showToast("Info!!", 'Previous Aadhar number Updated', "info")
                                    // this.buttonStyleAadhar= "display:block";
                                    this.verifiedAadhar = false;
                                    // this.verifiedAadhar=false;
                                    this.buttonLabelAadhar = "Verify Aadhar";
                                }

                            } else if (this.isSalesUser == true) {
                                this.SalesLAadharNumber = this.duplicateAccountResult.objeAcc.Aadhar_Number__c;
                                this.salessmakeadhardisable = true;
                            }
                        }
                        if (this.duplicateAccountResult.objeAcc.PAN_Number__c != null) {
                            this.PANNumber = this.duplicateAccountResult.objeAcc.PAN_Number__c;
                            this.makepandisable = true;
                        }

                        if (this.duplicateAccountResult.objeAcc.Passport_Number__c != null) {
                            this.passportNumber = this.duplicateAccountResult.objeAcc.Passport_Number__c;
                            this.makepassportdisable = true;
                        }
                        //Added bu Avadhut
                        if (this.duplicateAccountResult.objeAcc.Passport_File_Number__c != null) {
                            this.passportFileNumber = this.duplicateAccountResult.objeAcc.Passport_File_Number__c;
                            this.makepassportFiledisable = true;
                        }

                        if (this.duplicateAccountResult.objeAcc.Driving_License_Number__c != null) {
                            this.Driving_License_Number__c = this.duplicateAccountResult.objeAcc.Driving_License_Number__c;
                            this.makedrivingdisable = true;
                        }

                        if (this.duplicateAccountResult.objeAcc.Voter_ID__c != null) {
                            this.voterId = this.duplicateAccountResult.objeAcc.Voter_ID__c;
                            this.makevoteriddisable = true;
                        }

                        if (this.duplicateAccountResult.objeAcc.NREG_Number__c != null) {
                            this.NREGNumber = this.duplicateAccountResult.objeAcc.NREG_Number__c;
                            this.makeNREGdisable = true;
                        }

                        if (this.duplicateAccountResult.objeAcc.CKYC_Number__c != null) {
                            this.CKYCNumber = this.duplicateAccountResult.objeAcc.CKYC_Number__c;
                            this.makeCKYCdisable = true;
                        }

                        //Applicant Account
                        this.AppliAccID = this.duplicateAccountResult.objeAcc.Id;
                        //this.AppliFullName = this.wrapperForCommLeadForm.LeadRecords.FirstName;
                        this.AppliGender = this.duplicateAccountResult.objeAcc.Gender__c;
                        this.AppliIsIncomeConsiderIsFin = this.duplicateAccountResult.objeAcc.Is_Income_Considered_Is_Financial__c;
                        this.AppliMaritlStatus = this.duplicateAccountResult.objeAcc.Marital_Status__c;
                        if(this.duplicateAccountResult.objeAcc.Date_of_Birth__c != null){
                            this.AppliDOB = this.duplicateAccountResult.objeAcc.Date_of_Birth__c;
                            this.makedobdisable = true;
                        }
                        
                        if (this.AppliMaritlStatus == "Married") {
                            this.ShowFieldsAppliSpouse = true;
                        }
                        else {
                            this.ShowFieldsAppliSpouse = false;
                        }

                        //Applicant Current Address
                        this.AppliCurrentAddID = this.duplicateAccountResult.appCurrentAdd.Id;
                        //this.AppliCurrentName = this.duplicateAccountResult.appCurrentAdd.Name;
                        this.AppliCurrentAddProof = this.duplicateAccountResult.appCurrentAdd.Address_Proof__c;
                        this.AppliCurrentAddress = this.duplicateAccountResult.appCurrentAdd.Address_1__c;
                        this.AppliCurrentCity = this.duplicateAccountResult.appCurrentAdd.City__c;
                        //this.AppliCurrentTaluka = this.duplicateAccountResult.appCurrentAdd.Taluka__c;
                        this.AppliCurrentDistrict = this.duplicateAccountResult.appCurrentAdd.District__c;
                        this.AppliCurrentYear = this.duplicateAccountResult.appCurrentAdd.Years_In_The_Address__c;
                        this.AppliCurrentPincode = this.duplicateAccountResult.appCurrentAdd.Pin_Code__c;
                        this.AppliCurrentLandmark = this.duplicateAccountResult.appCurrentAdd.Landmark__c;
                        this.AppliCurrentState = this.duplicateAccountResult.appCurrentAdd.State__c;
                        this.AppliCurrentCountry = this.duplicateAccountResult.appCurrentAdd.Country__c;

                        //Applicant Permanent Address
                        this.AppliPermanentAddID = this.duplicateAccountResult.appPermanentAdd.Id;
                        this.AppliPermanentName = this.duplicateAccountResult.appPermanentAdd.Name;
                        this.AppliPermanentAddProof = this.duplicateAccountResult.appPermanentAdd.Address_Proof__c;
                        this.AppliPermanentAddress = this.duplicateAccountResult.appPermanentAdd.Address_1__c;
                        this.AppliPermanentCity = this.duplicateAccountResult.appPermanentAdd.City__c;
                        this.AppliPermanentDistrict = this.duplicateAccountResult.appPermanentAdd.District__c;
                        this.AppliPermanentYear = this.duplicateAccountResult.appPermanentAdd.Years_In_The_Address__c;
                        this.AppliPermanentPincode = this.duplicateAccountResult.appPermanentAdd.Pin_Code__c;
                        this.AppliPermanentLandmark = this.duplicateAccountResult.appPermanentAdd.Landmark__c;
                        this.AppliPermanentState = this.duplicateAccountResult.appPermanentAdd.State__c;
                        this.AppliPermanentCountry = this.duplicateAccountResult.appPermanentAdd.Country__c;
                        if (this.duplicateAccountResult.appCurrentAdd.Is_Communication_address__c == true) {
                            this.AppliPermIsCommAddressvalue = 'Current Address';
                        }
                        else if (this.duplicateAccountResult.appPermanentAdd.Is_Communication_address__c == true) {
                            this.AppliPermIsCommAddressvalue = 'Permanent Address';
                        }
                        if (this.duplicateAccountResult.appPermanentAdd.Same_as_Current_Address__c == true) {
                            this.AppliPermanentSameAsCurrent = true;
                            this.makePermanentAddProofdisabled = true;
                        }
                        else {
                            this.AppliPermanentSameAsCurrent = false;
                            this.makePermanentAddProofdisabled = false;
                        }
                        //Demography
                        this.DemographyID = this.duplicateAccountResult.appDemography.Id;
                        this.AppliFatherFirstName = this.duplicateAccountResult.appDemography.Father_s_First_Name__c;
                        this.AppliFatherMiddleName = this.duplicateAccountResult.appDemography.Father_s_Middle_Name__c;
                        this.AppliFatherLastName = this.duplicateAccountResult.appDemography.Father_s_Last_Name__c;
                        this.AppliMotherFirstName = this.duplicateAccountResult.appDemography.Mother_s_First_Name__c;
                        this.AppliMotherMiddleName = this.duplicateAccountResult.appDemography.Mother_s_Middle_Name__c;
                        this.AppliMotherLastName = this.duplicateAccountResult.appDemography.Mother_s_Last_Name__c;
                        this.AppliSpouseFirstName = this.duplicateAccountResult.appDemography.Spouse_s_First_Name__c;
                        this.AppliSpouseMiddleName = this.duplicateAccountResult.appDemography.Spouse_s_Middle_name__c;
                        this.AppliSpouseLastName = this.duplicateAccountResult.appDemography.Spouse_s_Last_Name__c;
                        this.alreadyduplicatefound = true;
                    }
                    else {
                        this.showToast("Error!!", `An account exists with the ${this.matchParameter} provided. Kindly crosscheck`, "Error")
                        this.errorMsgForDuplicate = true;
                        this.duplicatevalue = this.matchValue;
                    }
                }else{
                    this.alreadyduplicatefound = false;
                }

            })
            .catch((error) => {
                console.log(error);
                this.alreadyduplicatefound = false;
            })

    }
    @track activesectionname = '1';
    handleSectionToggleer(event) {
        for (var i in event.detail.openSections) {
        }
        if (this.LAadharNumber == undefined || this.LAadharNumber == "") {
            this.activesectionname = '0'
        } else {
            this.activesectionname = '1,A'
        }
    }
    dobBlur(event) {
        if (event.target.value == '' || event.target.value == undefined) {
            if (this.calculatePercent < 0) {
                this.calculatePercent = 0;
            }
        } else {
        }
        let enteredDate = new Date(event.target.value);
        let currentDate = new Date();
        const minDate = new Date('1900-01-01');

        if (enteredDate > currentDate) {
            this.showToast("Error!!", 'Entered date should not be Greated than current date', "Error")
            event.target.value = '';
        } else if (enteredDate < minDate) {
            this.showToast("Error!!", 'Entered date should be valid', "Error")
            event.target.value = '';
        } else {
            this.AppliDOB = event.target.value;
        }
    }

    @track aadharList;
    @track panList;
    @track passportList;
    //Added by Rohit 25052023
    @track applicantId;
    setApplicantRecords(wrapperForCommLeadForm) {
        this.leadID = wrapperForCommLeadForm.LeadRecords.Id;
        this.leadSalutation = wrapperForCommLeadForm.LeadRecords.Salutation;
        if(wrapperForCommLeadForm.aadharList != null){
            this.aadharList = wrapperForCommLeadForm.aadharList;

        }
        if(wrapperForCommLeadForm.panList != null){
            this.panList = wrapperForCommLeadForm.panList;

        }
        if(wrapperForCommLeadForm.passportList != null){
            this.passportList = wrapperForCommLeadForm.passportList;

        }
        if (wrapperForCommLeadForm.LeadRecords.FirstName != null) {
            this.leadFirstName = wrapperForCommLeadForm.LeadRecords.FirstName;
            this.makeFirstNamedisable = true;
        }
        if (this.wrapperForCommLeadForm.LeadRecords.MiddleName != null) {
            this.leadMiddleName = this.wrapperForCommLeadForm.LeadRecords.MiddleName;
            this.makeMiddleNamedisable = true;
        }
        if (this.wrapperForCommLeadForm.LeadRecords.LastName != null) {
            this.leadLastName = this.wrapperForCommLeadForm.LeadRecords.LastName;
            this.makeLastNameDisable = true;
        }
        if(wrapperForCommLeadForm.AccRecords.Account__r.PersonMobilePhone != null){
            this.leadMobile = wrapperForCommLeadForm.AccRecords.Account__r.PersonMobilePhone;
        }else{
            this.leadMobile = wrapperForCommLeadForm.LeadRecords.MobilePhone;
        }

        if(wrapperForCommLeadForm.AccRecords.Account__r.PersonEmail != null){
            this.leadEmail = wrapperForCommLeadForm.AccRecords.Account__r.PersonEmail;
        }else{
            this.leadEmail = wrapperForCommLeadForm.LeadRecords.Email;
        }
        this.consentYes = wrapperForCommLeadForm.LeadRecords.KYC_Consent__c;
        this.applicantCheck = wrapperForCommLeadForm.LeadRecords.Applicant_Section__c;
        this.aadharStatus = wrapperForCommLeadForm.AccRecords.Aadhar_Verified__c;
        this.panStatus = wrapperForCommLeadForm.AccRecords.Pan_verified__c;
        this.emailStatus = wrapperForCommLeadForm.AccRecords.Email_Verified__c;
        this.mobileStatus = wrapperForCommLeadForm.AccRecords.Mobile_Number_Verified__c;

        if (wrapperForCommLeadForm.AccRecords.Email_Verified__c == true) {
            this.verified = true;
            this.buttonStyle = 'display:none';
        } else {
            this.buttonStyle = 'display:block';
        }
        if (wrapperForCommLeadForm.AccRecords.Pan_verified__c == true) {
            this.buttonStylePan = 'display:none';
        } else {
            //    this.buttonStylePan = 'display:block';
        }
        if (wrapperForCommLeadForm.AccRecords.Mobile_Number_Verified__c == true) {
            this.verifiedMob = true;
            this.buttonStyleMob = 'display:none';
        } else {
            this.buttonStyleMob = 'display:block';
        }
        if (wrapperForCommLeadForm.AccRecords.Account__r.Aadhar_Number__c != null) {
            this.hideBasicSection = true;
            if (this.isSalesUser == false) {
                this.LAadharNumber = wrapperForCommLeadForm.AccRecords.Account__r.Aadhar_Number__c;
                this.makeadhardisable = true;
                if (this.aadharStatus == false) {
                    if (this.LAadharNumber.slice(0, 4) === "XXXX") {
                        this.lastFour = this.LAadharNumber.slice(-4);
                        this.aadharInputStyle = 'display:block';
                        this.aadharInput = false;
                    }
                }
            } else if (this.isSalesUser == true) {
                this.SalesLAadharNumber = wrapperForCommLeadForm.AccRecords.Account__r.Aadhar_Number__c;
                this.salessmakeadhardisable = true;
            }
        }
        if (wrapperForCommLeadForm.AccRecords.Account__r.PAN_Number__c != null) {
            this.PANNumber = wrapperForCommLeadForm.AccRecords.Account__r.PAN_Number__c;
            this.makepandisable = true;
        }
        if (wrapperForCommLeadForm.AccRecords.Account__r.Passport_Number__c != null) {
            this.passportNumber = wrapperForCommLeadForm.AccRecords.Account__r.Passport_Number__c;
            this.makepassportdisable = true;
        }
        //Added by Avadhut
        if (wrapperForCommLeadForm.AccRecords.Account__r.Passport_File_Number__c != null) {
            this.passportFileNumber = wrapperForCommLeadForm.AccRecords.Account__r.Passport_File_Number__c;
            this.makepassportFiledisable = true;
        }
        if (wrapperForCommLeadForm.AccRecords.Account__r.Driving_License_Number__c != null) {
            this.Driving_License_Number__c = wrapperForCommLeadForm.AccRecords.Account__r.Driving_License_Number__c;
            this.makedrivingdisable = true;
        }
        if (wrapperForCommLeadForm.AccRecords.Account__r.Voter_Id__c != null) {
            this.voterId = wrapperForCommLeadForm.AccRecords.Account__r.Voter_Id__c;
            this.makevoteriddisable = true;
        }
        if (wrapperForCommLeadForm.AccRecords.Account__r.CKYC_Number__c != null) {
            this.CKYCNumber = wrapperForCommLeadForm.AccRecords.Account__r.CKYC_Number__c;
            this.makeCKYCdisable = true;
        }
        if (wrapperForCommLeadForm.AccRecords.Account__r.NREG_Number__c != null) {
            this.NREGNumber = wrapperForCommLeadForm.AccRecords.Account__r.NREG_Number__c;
            this.makeNREGdisable = true;
        }
        //Applicant Account
        this.applicantId = wrapperForCommLeadForm.AccRecords.Id;
        this.AppliAccID = wrapperForCommLeadForm.AccRecords.Account__c;
        this.AppliFullName = wrapperForCommLeadForm.LeadRecords.FirstName;
        this.AppliGender = wrapperForCommLeadForm.AccRecords.Account__r.Gender__c;
        this.AppliIsIncomeConsiderIsFin = wrapperForCommLeadForm.AccRecords.Account__r.Is_Income_Considered_Is_Financial__c;
        this.AppliMaritlStatus = wrapperForCommLeadForm.AccRecords.Account__r.Marital_Status__c;
        if (wrapperForCommLeadForm.AccRecords.Account__r.Date_of_Birth__c != null) {
            this.AppliDOB = wrapperForCommLeadForm.AccRecords.Account__r.Date_of_Birth__c;
            this.makedobdisable = true;
        }
        //Check if Marital status is Marriend then show Spouse fields
        if (this.AppliMaritlStatus == "Married") {
            this.ShowFieldsAppliSpouse = true;
        }
        else {
            this.ShowFieldsAppliSpouse = false;
        }
        //Applicant Current Address
        this.AppliCurrentAddID = wrapperForCommLeadForm.CPAAppliCurrentRecord.Id;
        this.AppliCurrentName = wrapperForCommLeadForm.CPAAppliCurrentRecord.Name;
        this.AppliCurrentAddProof = wrapperForCommLeadForm.CPAAppliCurrentRecord.Address_Proof__c;
        this.AppliCurrentAddress = wrapperForCommLeadForm.CPAAppliCurrentRecord.Address_1__c;
        this.AppliCurrentCity = wrapperForCommLeadForm.CPAAppliCurrentRecord.City__c;
        this.AppliCurrentDistrict = wrapperForCommLeadForm.CPAAppliCurrentRecord.District__c;
        this.AppliCurrentYear = wrapperForCommLeadForm.CPAAppliCurrentRecord.Years_In_The_Address__c;
        this.AppliCurrentPincode = wrapperForCommLeadForm.CPAAppliCurrentRecord.Pin_Code__c;
        this.AppliCurrentLandmark = wrapperForCommLeadForm.CPAAppliCurrentRecord.Landmark__c;
        this.AppliCurrentState = wrapperForCommLeadForm.CPAAppliCurrentRecord.State__c;
        this.AppliCurrentCountry = wrapperForCommLeadForm.CPAAppliCurrentRecord.Country__c;
        //Applicant Permanent Address
        this.AppliPermanentAddID = wrapperForCommLeadForm.CPAAppliPermanentRecord.Id;
        this.AppliPermanentName = wrapperForCommLeadForm.CPAAppliPermanentRecord.Name;
        this.AppliPermanentAddProof = wrapperForCommLeadForm.CPAAppliPermanentRecord.Address_Proof__c;
        this.AppliPermanentAddress = wrapperForCommLeadForm.CPAAppliPermanentRecord.Address_1__c;
        this.AppliPermanentCity = wrapperForCommLeadForm.CPAAppliPermanentRecord.City__c;
        this.AppliPermanentDistrict = wrapperForCommLeadForm.CPAAppliPermanentRecord.District__c;
        this.AppliPermanentYear = wrapperForCommLeadForm.CPAAppliPermanentRecord.Years_In_The_Address__c;
        this.AppliPermanentPincode = wrapperForCommLeadForm.CPAAppliPermanentRecord.Pin_Code__c;
        this.AppliPermanentLandmark = wrapperForCommLeadForm.CPAAppliPermanentRecord.Landmark__c;
        this.AppliPermanentState = wrapperForCommLeadForm.CPAAppliPermanentRecord.State__c;
        this.AppliPermanentCountry = wrapperForCommLeadForm.CPAAppliPermanentRecord.Country__c;

        if (wrapperForCommLeadForm.CPAAppliCurrentRecord.Is_Communication_address__c == true) {
            this.AppliPermIsCommAddressvalue = 'Current Address';
        }
        else if (wrapperForCommLeadForm.CPAAppliPermanentRecord.Is_Communication_address__c == true) {
            this.AppliPermIsCommAddressvalue = 'Permanent Address';
        }
        if (wrapperForCommLeadForm.CPAAppliPermanentRecord.Same_as_Current_Address__c == true) {
            this.AppliPermanentSameAsCurrent = true;
            this.makePermanentAddProofdisabled = true;
        }
        else {
            this.AppliPermanentSameAsCurrent = false;
            this.makePermanentAddProofdisabled = false;
        }
        //Demography
        this.DemographyID = wrapperForCommLeadForm.DemographyRecord.Id;
        this.AppliFatherFirstName = wrapperForCommLeadForm.DemographyRecord.Father_s_First_Name__c;
        this.AppliFatherMiddleName = wrapperForCommLeadForm.DemographyRecord.Father_s_Middle_Name__c;
        this.AppliFatherLastName = wrapperForCommLeadForm.DemographyRecord.Father_s_Last_Name__c;
        this.AppliMotherFirstName = wrapperForCommLeadForm.DemographyRecord.Mother_s_First_Name__c;
        this.AppliMotherMiddleName = wrapperForCommLeadForm.DemographyRecord.Mother_s_Middle_Name__c;
        this.AppliMotherLastName = wrapperForCommLeadForm.DemographyRecord.Mother_s_Last_Name__c;
        this.AppliSpouseFirstName = wrapperForCommLeadForm.DemographyRecord.Spouse_s_First_Name__c;
        this.AppliSpouseMiddleName = wrapperForCommLeadForm.DemographyRecord.Spouse_s_Middle_name__c;
        this.AppliSpouseLastName = wrapperForCommLeadForm.DemographyRecord.Spouse_s_Last_Name__c;
    }

    //Added by Rohit
    @track areaPinCoode;
    aadharFrontName;
    aadharBackName;
    appdoc1 = false;
    @track apiaadharLastFour;
    @track isPinCodeAvailable = false;
    @track makeFirstNamedisable = false;
    @track makeMiddleNamedisable = false;
    @track makeLastNameDisable = false;
    @track makeFatherFirstNamedisable = false;
    @track makeFatherLastNamedisable = false;
    @track makeGenderdisable = false;
    @track makeDOBdisable = false;

    //Added by Rohit
    @track apAadharback;
    aadharFront(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        const fileSize = file.size / (1024 * 1024);
        if (fileSize > 2.5) {
            this.showToast("Error!!", "File size exceeds the maximum limit of 2.5 MB", "Error");
            this.doc23 = false;
            return;
        } else if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            this.showToast("Error!!", "Please upload file in .png ,.jpg, .jpeg and.pdf format", "Error")
            this.doc23 = false;
        } else {
           // const uploadedFiles = event.detail.files;
           // this.filename = uploadedFiles[0].name;
            //const fileName = 'Applicant Aadhar' + ".";
            const docType = 'AADHAAR';
            this.appdoc1 = true;
            let file = event.target.files[0]
            console.log('file' , file);
           // this.aadharFrontName = file.name
           this.aadharFrontName = event.target.files[0].name;
           this.aadharList = [file.name];
           const fileName = file.name;
           console.log('fileName=====' ,fileName);
           this.openFrontfileUpload(event, fileName, docType);
        }

    }

    //Added by Rohit
    doc6;
    doc6name;
    applicantPan;
    panApp(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        const fileSize = file.size / (1024 * 1024);
        if (fileSize > 2.5) {
            this.showToast("Error!!", "File size exceeds the maximum limit of 2.5 MB", "Error");
            this.doc23 = false;
            return;
        }
        else if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            this.showToast("Error!!", "Please upload file in .png ,.jpg, .jpeg and.pdf format", "Error")
            this.doc23 = false;
        } else {
            //const fileName = 'Applicant PAN' + ".";
            const docType = 'PAN';
            this.doc6 = true;
            let file = event.target.files[0]
            this.doc6name = file.name
            this.panList = [file.name];
            const fileName = file.name;
            console.log('fileName=====' ,fileName);
            this.openFrontfileUpload(event, fileName, docType);
            console.log('doc6name', this.doc6name);
            console.log('aadharFrontName', this.aadharFrontName);
        }

    }

    //Added by Rohit
    doc3;
    doc3name;
    applicantPass;
    passportFront(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        const fileSize = file.size / (1024 * 1024);
        if (fileSize > 2.5) {
            this.showToast("Error!!", "File size exceeds the maximum limit of 2.5 MB", "Error");
            this.doc23 = false;
            return;
        }
        else if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            this.showToast("Error!!", "Please upload file in .png ,.jpg, .jpeg and.pdf format", "Error")
            this.doc23 = false;
        } else {
            //const fileName = 'Applicant Passport' + ".";
            const docType = 'PASSPORT';
            this.doc3 = true;
            let file = event.target.files[0]
            console.log('file' , file);
            this.doc3name = file.name
            this.passportList = [file.name];
            const fileName = file.name;
            console.log('fileName=====' ,fileName);
            this.openFrontfileUpload(event, fileName, docType);
        }
    }

    //Added by Rohit
    @track newAccountCreated = false;
    openFrontfileUpload(event, fileName, docType) {
        let file = event.target.files[0]
        let reader = new FileReader()
        reader.onload = () => {
            let base64 = reader.result.split(',')[1]
            console.log(base64);
            //let fullName = fileName + file.type.split('/')[1];
            let fullName = fileName;
            console.log('fullName' , fullName);
            this.isLoading = true;
            KarzaKycOcr({
                leadId: this.leadRecordId,
                accId: this.AppliAccID,
                base64: base64,
                fileName: fullName,
                filedocType: docType,
                existingAadhar: this.aadharLastFour,
                existingPAN: this.PANNumber,
                existingVoter: this.voterId,
                exisitngPassport: this.passportNumber,
                existingDL: this.Driving_License_Number__c,
                applicantType : 'Applicant',
                existingapplicantId : this.applicantId

            })
                .then(async (result) => {
                    this.isLoading = false;
                    let responseObj = result;
                    console.log('responseObj==>', JSON.stringify(responseObj));
                    if (responseObj.apistatusCode == 101) {
                        if (responseObj.newAccountCreated == true) {
                            this.newAccountCreated = true;
                        } else {
                            this.newAccountCreated = false;
                        }
                        this.LDateOfBirth = responseObj.leadDOB;
                        console.log('kycNameMatch==>' , responseObj.kycNameMatch);
                        if(responseObj.kycNameMatch == false){
                            this.showToast("Error!!", "Applicant name and Uploaded Document Name does not match. Kindly Crosscheck & Upload correct document", "Error")
                        }
                        else if (responseObj.apiDocumentType == 'AADHAAR') {
                            this.apiaadharLastFour = responseObj.leadAadharNumber.slice(-4);
                            this.matchParameter = 'Aadhar Number';
                            this.matchValue = 'XXXXXXXX' + this.apiaadharLastFour;
                            console.log('this.LAadharNumber=>' , this.LAadharNumber);
                            if(this.LAadharNumber != undefined){
                                this.aadharLastFour = this.LAadharNumber.slice(-4);
                            }
                            this.checkOCRDuplicate(this.matchParameter, this.matchValue, this.LDateOfBirth)
                                .then(() => {
                                    if (this.matchParameterDuplicate == true) {
                                        console.log('Inside matchParameterDuplicate true');
                                    }
                                    else if (this.aadharLastFour != this.apiaadharLastFour) {
                                        // if(this.aadharLastFour == '' || this.aadharLastFour == undefined){
                                            if(this.LAadharNumber == '' || this.LAadharNumber == undefined){
                                            this.setRecord(responseObj);
                                        } else {
                                            this.showToast("Error!!", "Uploaded Aadhar number does not match. Kindly Crosscheck & Upload correct document", "Error")
                                        }
                                    }
                                    else {
                                        this.setRecord(responseObj);
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
                                    if (this.matchParameterDuplicate == true) {
                                    }
                                    else if (this.PANNumber != responseObj.apiPANNumber) {
                                        if (this.PANNumber == '' || this.PANNumber == undefined) {
                                            this.setRecord(responseObj);
                                        } else {
                                            this.showToast("Error!!", "Uploaded PAN number does not match. Kindly Crosscheck & Upload correct document", "Error")
                                        }
                                    } else {
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
                                    else if (this.passportNumber != responseObj.apiPassportNumber) {
                                        if (this.passportNumber == undefined || this.passportNumber == '') {
                                            this.setRecord(responseObj);
                                        } else {
                                            this.showToast("Error!!", "Uploaded Passport Number does not match. Kindly Crosscheck & Upload correct document", "Error")
                                        }
                                    } else {
                                        this.setRecord(responseObj);
                                    }
                                })
                                .catch((error) => {
                                    console.error(error);
                                });
                        }
                    } else if (responseObj.apistatusCode == 102) {
                        this.showToast("Error!!", "Error Uploading File. Kindly Crosscheck the document and upload", "Error")
                    } else {
                        this.showToast("Error!!", "API credit limit has exceeded. Please contact Admin", "Error")
                    }
                }).catch((error) => {
                    console.error("error", error);
                    this.isLoading = false;
                    this.appdoc1 = false;
                })
        };
        reader.readAsDataURL(file);
    }

    @track passportUploded = false;
    @track aadharUploded = false;
    @track panUploaded = false;
    @track pincodecheck;
    @track parametervalue;

    //Added by Rohit
    async setRecord(responseObj) {
        if (responseObj.leadAadharNumber != undefined) {
            if (this.LAadharNumber == '' || this.LAadharNumber == undefined || this.SalesLAadharNumber == '' || this.SalesLAadharNumber == undefined) {
                if (this.apiaadharLastFour != undefined) {
                    if (this.isSalesUser == false) {
                        this.LAadharNumber = 'XXXXXXXX' + this.apiaadharLastFour;
                        this.finalAadharNumberToSave = 'XXXXXXXX' + this.apiaadharLastFour;
                        console.log('this.finalAadharNumberToSave', this.finalAadharNumberToSave);
                        this.makeadhardisable = true;
                    } else if (this.isSalesUser == true) {
                        this.SalesLAadharNumber = 'XXXXXXXX' + this.apiaadharLastFour;
                        this.finalAadharNumberToSave = 'XXXXXXXX' + this.apiaadharLastFour;
                        console.log('this.finalAadharNumberToSave', this.finalAadharNumberToSave);
                        this.salessmakeadhardisable = true;
                    }
                } else {
                    this.LAadharNumber = responseObj.leadAadharNumber;
                    this.makeadhardisable = true;
                    this.salessmakeadhardisable = true;
                }
                this.hideBasicSection = true;
            }
        }

        if (this.passportUploded == false && responseObj.apiDocumentType != 'PAN') {
            if (responseObj.leadFirstName != undefined) {
                this.leadFirstName = responseObj.leadFirstName;
                this.makeFirstNamedisable = true;
            }
            if(responseObj.leadLastName == undefined){
                if(responseObj.leadMiddleName != null){
                    this.leadLastName = responseObj.leadMiddleName;
                    this.makeLastNameDisable = true;
                }
            }else{
                this.leadMiddleName = responseObj.leadMiddleName;
                this.makeMiddleNamedisable = true;
                this.leadLastName = responseObj.leadLastName;
                this.makeLastNameDisable = true;
            }
        }
        if (responseObj.leadFatherFirstName != undefined) {
            this.AppliFatherFirstName = responseObj.leadFatherFirstName;
            this.makeFatherFirstNamedisable = true;
        }
        if (responseObj.leadFatherLastName != undefined) {
            this.AppliFatherLastName = responseObj.leadFatherLastName;
            this.makeFatherLastNamedisable = true;
        }
        if (responseObj.leadGender != undefined) {
            this.AppliGender = responseObj.leadGender;
            this.makeGenderdisable = true;
        }
        if (responseObj.accountId != undefined) {
            this.AppliAccID = responseObj.accountId;
        }
        if(responseObj.applicantRecordID != undefined){
            this.applicantId = responseObj.applicantRecordID;
        }
        if (responseObj.leadDOB != undefined) {
            this.AppliDOB = responseObj.leadDOB;
            this.makedobdisable = true;
        }
        if (responseObj.apiPANNumber != undefined) {
            this.PANNumber = responseObj.apiPANNumber;
            this.makepandisable = true;
        }
        else if (responseObj.leadPANNumber != undefined) {
            this.PANNumber = responseObj.leadPANNumber;
            this.makepandisable = true;
        }
        if (responseObj.apiPassportNumber != undefined) {
            this.passportNumber = responseObj.apiPassportNumber;
            this.makepassportdisable = true;
        }
        else if (responseObj.leadPassportNumber != undefined) {
            this.passportNumber = responseObj.leadPassportNumber;
            this.makepassportdisable = true;
        }
        if (responseObj.leadPassportFileNumber != undefined) {
            this.passportFileNumber = responseObj.leadPassportFileNumber;
        }
        if (responseObj.apiVoterNumber != undefined) {
            this.voterId = responseObj.apiVoterNumber;
            this.makevoteriddisable = true;
        }
        else if (responseObj.leadVoterIdNumber != undefined) {
            this.voterId = responseObj.leadVoterIdNumber;
            this.makevoteriddisable = true;
        }
        if (responseObj.apiDLNumber != undefined) {
            this.Driving_License_Number__c = responseObj.apiDLNumber;
            this.makedrivingdisable = true;
        }
        else if (responseObj.leadDLNumber != undefined) {
            this.Driving_License_Number__c = responseObj.leadDLNumber;
            this.makedrivingdisable = true;
        }
        if (responseObj.leadCKYCNumber != undefined) {
            this.CKYCNumber = responseObj.leadCKYCNumber;
            this.makeCKYCdisable = true;
        }
        if (responseObj.leadNREGNumber != undefined) {
            this.NREGNumber = responseObj.leadNREGNumber;
            this.makeNREGdisable = true;
        }
        if (responseObj.leadPinCode != undefined) {
            this.pincodecheck = responseObj.leadPinCode;
            console.log('pincodecheck', this.pincodecheck);
            try {
                const isPinCodeAvailable = await checkPinCodeAvailable({ pin: this.pincodecheck });
                console.log('isPinCodeAvailable=>', isPinCodeAvailable);
                if (isPinCodeAvailable == true) {
                    const pinResult = await getPin({ pin: this.pincodecheck });
                    this.areaPinCoode = pinResult.Id;
                    const pincodeResult = await getPincodeRecord({ pincode: this.areaPinCoode });
                    this.AreaPinCodeResult = pincodeResult;
                    this.AppliCurrentPincode = this.AreaPinCodeResult.Id;
                    this.AppliCurrentCity = this.AreaPinCodeResult.City_Name__c;
                    this.AppliCurrentState = this.AreaPinCodeResult.State__c;
                    this.AppliCurrentCountry = this.AreaPinCodeResult.Country__c;
                    this.AppliCurrentDistrict = this.AreaPinCodeResult.Area_Name_Taluka__c;
                    this.AppliCurrentTaluka = this.AreaPinCodeResult.Area_Name_Taluka__c;
                    this.AppliCurrentAddProof = 'Aadhar Card';
                }

                if (responseObj.leadhouse != undefined && responseObj.leadCurrentAddress != undefined) {
                    this.AppliCurrentAddress = responseObj.leadhouse + " " + responseObj.leadCurrentAddress;
                }else if(responseObj.leadCurrentAddress != undefined){
                    this.AppliCurrentAddress = responseObj.leadCurrentAddress;
                }else if(responseObj.leadhouse != undefined){
                    this.AppliCurrentAddress = responseObj.leadhouse;
                }

                if(responseObj.leadLandmark != undefined){
                    this.AppliCurrentLandmark = responseObj.leadLandmark;
                }
                
            } catch (error) {
                this.errors = error;
                this.isLoading = false;
                this.appdoc1 = true;
            }
        }

        if (responseObj.apiDocumentType == 'AADHAAR') {
            this.parametervalue = this.finalAadharNumberToSave;
            this.showToast("Success!!", "Aadhar Uploded Successfully", "Success")
        } else if (responseObj.apiDocumentType == 'PAN') {
            this.parametervalue = responseObj.apiPANNumber;
            this.showToast("Success!!", "PAN Uploded Successfully", "Success")
        } else if (responseObj.apiDocumentType == 'VOTER') {
            this.showToast("Success!!", "Voter Id Uploded Successfully", "Success")
        } else if (responseObj.apiDocumentType == 'PASSPORT') {
            this.parametervalue = responseObj.apiPassportNumber;
            this.passportUploded = true;
            this.showToast("Success!!", "Passport Uploded Successfully", "Success")
        } else if (responseObj.apiDocumentType == 'DL') {
            this.showToast("Success!!", "Driving Licence Uploded Successfully", "Success")
        }

        updateKYCAccount({ accountId : this.AppliAccID,  docType : responseObj.apiDocumentType, value : this.parametervalue})
    }

    //Added by Rohit
    @track matchParameterDuplicate = false;
    @track dupkcateeteteteresult;
    checkOCRDuplicate(matchParameter, matchValue, LDateOfBirth) {
        return new Promise((resolve, reject) => {
            duplicateAccount({ 'duplicateParameter': matchParameter, 'duplicateValue': matchValue, 'matchDOB': LDateOfBirth })
                .then((result) => {
                    this.duplicateAccountResult = result;
                    if (Object.keys(result).length != 0) {
                        console.log('objeAccId=> ', this.duplicateAccountResult.objeAcc.Id);
                        console.log('this.AppliAccID=> ', this.AppliAccID);
                        console.log('this.alreadyduplicatefound=> ', this.alreadyduplicatefound);
                        console.log('coApplicantAccountId=>' , this.coApplicantAccountId);
                        console.log('newAccountCreated==>', this.newAccountCreated);
                        if (this.newAccountCreated == false) {
                            console.log('INSIDE newAccountCreated true CONDITION');
                            if (result.objeAcc.Id == this.coApplicantAccountId) {
                                console.log('applicant and Co-Applicant details cannot be the same');
                                this.showToast("Error!!", "Applicant and Co-Applicant details cannot be the same. Kindly Crosscheck", "Error");
                                this.matchParameterDuplicate = true;
                            }
                            else if ((this.AppliAccID != this.duplicateAccountResult.objeAcc.Id) && (this.AppliAccID == null || this.AppliAccID == undefined) &&
                                (this.alreadyduplicatefound == false || this.alreadyduplicatefound == undefined)) {
                                if (this.duplicateAccountResult.objeAcc.Aadhar_Number__c == matchValue) {
                                    this.showToast("Info!!", "Existing account found with your Aadhar Number", "info");
                                } else if (this.duplicateAccountResult.objeAcc.PAN_Number__c == matchValue) {
                                    this.showToast("Info!!", "Existing account found with your PAN Number", "info");
                                } else if (this.duplicateAccountResult.objeAcc.Passport_Number__c == matchValue) {
                                    this.showToast("Info!!", "Existing account found with your Passport Number", "info");
                                } else if (this.duplicateAccountResult.objeAcc.Driving_License_Number__c == matchValue) {
                                    this.showToast("Info!!", "Existing account found with your Driving License Number", "info");
                                } else if (this.duplicateAccountResult.objeAcc.Voter_ID__c == matchValue) {
                                    this.showToast("Info!!", "Existing account found with your Voter ID", "info");
                                }
                                this.alreadyduplicatefound = true;
                            } else if (this.AppliAccID != this.duplicateAccountResult.objeAcc.Id) {
                                console.log('An account exists with the paramaterr');
                                this.showToast("Error!!", `An account exists with the ${matchParameter} provided. Kindly crosscheck`, "Error")
                                this.matchParameterDuplicate = true;
                            }
                        }else{
                            this.matchParameterDuplicate = false;
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

    //Added by Rohit
    getPassportDoc() {
        isPassportUploaded({ leadId: this.leadRecordId })
            .then(result => {
                this.passportUploded = result;
            })
            .catch(error => {
            });
    }

    //Added by Rohit
   

    //Added by Rohit
    @api dmsNames;
    @api applicantAadhar;
    namesRenderDMS() {
        DMS_NAMES()
            .then((result) => {
                this.dmsNames = JSON.parse(result);
            })
            .catch((error) => {
                console.error(error);
            });
    }

    @track coApplicantAccountId;
    //Getting Account Id of Appliant
    getCoApplicant() {
        getCoApplicantAccoutId({ leadId: this.leadRecordId })
            .then(result => {
                if (result.length > 0) {
                    this.coApplicantAccountId = result;
                }
            })
            .catch(error => {
                console.log('Error while getting Account Id of Co-Applicant: '+JSON.stringify(error));
            });
    }
}