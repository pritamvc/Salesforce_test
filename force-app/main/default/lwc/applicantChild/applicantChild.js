import { LightningElement, wire, api, track } from 'lwc';
import creatLeadRecord from '@salesforce/apex/QACommunityLeadFormController.creatLeadRecord';
import creatCommFormLeadRecords from '@salesforce/apex/QACommunityLeadFormController.creatCommFormLeadRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import getInstituteRecord from '@salesforce/apex/QACommunityLeadFormController.getInstituteRecord';
import getUniversityNameCourse from '@salesforce/apex/QACommunityLeadFormController.getUniversityNameCourse';
//import getWrapperClassCommFormLists from '@salesforce/apex/QACommunityLeadFormController.getWrapperClassCommFormList';
import getapplicantData from '@salesforce/apex/QACommunityLeadFormController.getWrapperClassCommFormList';
import getPin from '@salesforce/apex/QACommunityLeadFormController.getPin';

import getPincodeRecord from '@salesforce/apex/QACommunityLeadFormController.getPincodeRecord';
import OtpRequest from '@salesforce/apex/EmailVerification.OtpRequest';
// import updateLeadFromCommunity from '@salesforce/apex/AccountTriggerHandler.updateLeadFromCommunityForm';
import OtpRequestMob from '@salesforce/apex/MobileVerification.OtpRequest';
import OtpVerify from '@salesforce/apex/EmailVerification.verify';
import OtpVerifyMob from '@salesforce/apex/MobileVerification.OtpVerify';
import AadharVerification from '@salesforce/apex/DocumentVerification.AadharVerification';
import downloadAadhar from '@salesforce/apex/DocumentVerification.DownloadAadhar';
import panVerification from '@salesforce/apex/DocumentVerification.PanProfile';
import getLeadTotalPercentage from '@salesforce/apex/DocumentVerification.getLeadTotalPercentage';
import updateLeadTotalPercentage from '@salesforce/apex/DocumentVerification.updateLeadTotalPercentage';
// import getDeplicateAccout from '@salesforce/apex/AccountTriggerHandler.getDupAccountCommunityForm';
import getCoAppRecords from '@salesforce/apex/DemoCommunityLeadForm.getCoapp';
import duplicateAccount from '@salesforce/apex/DemoCommunityLeadForm.duplicateAccount';

import progressBar from '@salesforce/messageChannel/progressBar__c';
import {publish, MessageContext} from 'lightning/messageService';

import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
//import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import ProfileName from '@salesforce/schema/User.Profile.Name';

export default class CommunityFormARS extends LightningElement {
    @api leadRecordId;
    @track todaysDate;

    //progressbar
    @wire(MessageContext)
    messageContext;
    message;
    @api percentage = 30;

    @track firstCheck = false;
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

    @track isSalesUser;

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
    handleFirstEightAadhar(event){
        console.log("1st eight digit")
        this.firstEightAadhar = event.target.value;
    }
    @wire(getObjectInfo, { objectApiName: '$objectName' })
    getObjectData1({ error, data }) {
        if (data) {
            if (this.recordTypeId == null)
                this.recordTypeId = data.defaultRecordTypeId;
            
            //Salutation 
            this.apisalutation = this.objectName + '.' + this.salutationField;
            this.salutationLabel = data.fields[this.salutationField].label;

        } else if (error) {
            // Handle error
            console.log('==============Error ');
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

  //Contact Point Address Picklist field from SFDC
  @wire(getObjectInfo, { objectApiName: '$objectNameAddress' })
  getObjectData500({ error, data }) {
      console.log('Inside objectApiName: ContactPointAddress');
      console.log('objectApiName' + this.objectNameAddress);
      if (data) {
          console.log('Inside if');
          if (this.recordTypeId5 == null)
          console.log('Inside recordTypeId5');
              this.recordTypeId5 = data.defaultRecordTypeId;
              console.log('Inside this.recordTypeId5' + this.recordTypeId5); //its Non indivial acc recordtpye

              //Address Proof From ContactPointAddress
              this.apiappliAddressProof = this.objectNameAddress + '.' + this.appliAddressProofField;
              this.appliAddressProofLabel = data.fields[this.appliAddressProofField].label;  

      } else if (error) {
          // Handle error
          console.log('==============Error Account Picklist ' + JSON.stringify(error));    
      
      }     
  }

  //Address Prrof  - Contact Point Address object    
  @wire(getPicklistValues, { recordTypeId: '$recordTypeId5', fieldApiName: '$apiappliAddressProof' })
  getPicklistValues501({ error, data }) {
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
        console.log('Lemail', this.LEmail);
        this.verified = true;
        setTimeout(() => {
            this.verified = false;
        }, 5000)
        if (this.LEmail != undefined && this.LEmail != "") {
            OtpRequest({ email: this.LEmail })
            .then((result) => {
                console.log("suc", result);
                let responseObj = JSON.parse(result);
                this.requestIdTemp = responseObj.dataResponse.requestId;
                console.log(this.requestIdTemp);
                if (responseObj.dataResponse.statusCode == 101) {
                        this.showModal = true;
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
                    console.error("er", error);
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: 'Failed to send OTP',
                        variant: 'error',
                    });
                    this.dispatchEvent(event);
                });
        }
    }
    handleVerify() {
        console.log("ver req", this.otpValue);
        console.log(" reqid", this.requestIdTemp);
        OtpVerify({ 'otp': this.otpValue, 'requestId': this.requestIdTemp })
            .then((result) => {
                let responseObj = JSON.parse(result);
                if (responseObj.dataResponse.statusCode == 101) {
                    this.showModal = false;
                    this.verified = true;
                    this.buttonStyle = 'display:none'
                    this.displayText = 'display:block;  color:green; font-weight:bold;'
                    this.emailStatus = true;
                    const event = new ShowToastEvent({
                        title: 'Success',
                        message: 'Email Verified successfully!',
                        variant: 'success',
                    });
                    this.dispatchEvent(event);
                    this.buttonLabel = 'Verified';
                } else {
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: 'Please Enter Correct OTP',
                        variant: 'error',
                    });
                    this.dispatchEvent(event);
                }
                console.log("result log", result);
            })
            .catch((error) => {
                console.error("er", error);
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: 'Failed to verify OTP',
                    variant: 'error',
                });
                this.dispatchEvent(event);
            });
        console.log("Email Verification Done");
    }
    @track makeadhardisable;
    @track aadharResponse;
    @track aadharStatus;
    handleVerifyAadhar() {
        this.verifiedbuttonAadhar = true;
        setTimeout(() => {
            this.verifiedbuttonAadhar = false;
        }, 6000)
        console.log("otp", this.otpValueAadhar);
        console.log("LAadharNumber", this.LAadharNumber);
        console.log("requestIdAadhar", this.requestIdAadhar);
        downloadAadhar({ 'otp': this.otpValueAadhar, 'aadhaarNo': this.LAadharNumber.slice(0, 4) === "XXXX"?this.firstEightAadhar+this.lastFour:this.LAadharNumber, 'requestId': this.requestIdAadhar, 'consent': 'y' })
            .then((result) => {
                console.log("result===" + result);
                
                let responseObj = JSON.parse(result);
                this.aadharResponse = responseObj;
                console.log("result log", responseObj);
                if (responseObj.statusCode == 101) {
                    // this.verifiedbuttonAadhar = false;
                // if (responseObj.dataResponse.statusCode == 101) {
                  //data response to be added
                    responseObj.result.dataFromAadhaar.dob != undefined ?
                        this.AppliDOB = responseObj.result.dataFromAadhaar.dob : '';
                    console.log("this.Aplidob------" + this.AppliDOB);
                    responseObj.result.dataFromAadhaar.address.splitAddress.pincode != undefined ?
                        this.AppliCurrentPincode = responseObj.result.dataFromAadhaar.address.splitAddress.pincode : '';
                    console.log("this.pin------" + this.AppliCurrentPincode);
                    getPin({pin:this.AppliCurrentPincode})
                    .then((res)=>{
                        this.AppliCurrentPincode = res.Id;
                    })

                    const address = responseObj.result.dataFromAadhaar.address.splitAddress;
                    this.AppliCurrentAddProof = 'Aadhar Card';
                    this.AppliCurrentAddress = address.street;
                    this.AppliCurrentCity = address.postOffice;
                    this.AppliCurrentTaluka = address.subdistrict;
                    this.AppliCurrentDistrict = address.district;
                    this.AppliCurrentLandmark = address.landmark;
                    this.AppliCurrentState =  address.state;
                    this.AppliCurrentCountry = address.country;
                    
                    console.log('Address:'+address);
                    console.log('street ='+address.street);
                    console.log('houseNumber ='+ address.houseNumber);
                    console.log('landmark ='+ address.landmark);
                    console.log('location ='+ address.location);
                    console.log('subdistrict ='+ address.subdistrict);
                    console.log('district ='+ address.district);
                    console.log('state ='+ address.state);
                    console.log('pincode ='+ address.pincode);
                    console.log('country ='+ address.country);

                    if (responseObj.result.dataFromAadhaar.gender != undefined) {
                        if (responseObj.result.dataFromAadhaar.gender == "M") {
                            this.AppliGender = "Male";
                        } else {
                            this.AppliGender = "Female";
                        }
                    }
                    console.log("this.gender------" + this.AppliGender);
                    this.showModalAadhar = false;
                    
                    this.buttonLabelAadhar = 'Verified';
                    this.buttonStyleAadhar = 'display:none';
                    this.displayTextAadhar = 'display:block;  color:green; font-weight:bold;'
                    const event = new ShowToastEvent({
                        title: 'Success',
                        message: 'Aadhar verified successfully!',
                        variant: 'success',
                    });
                    this.verifiedAadhar = true;
                    this.makeadhardisable = true;
                    this.dispatchEvent(event);
                    this.aadharStatus=true;
                    this.aadharLastFour = this.LAadharNumber.slice(-4)
                    this.LAadharNumber = 'XXXXXXXX'+this.aadharLastFour;
                    this.aadharInputStyle='display:none';
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
    @track Fullaadhar;
    RehandleVerifyAadhar(){
        this.verifiedAadhar = true;
        setTimeout(() => {
            this.verifiedAadhar = false;
        }, 5000)
        //debugger
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
                        this.newModal=false;
                        this.showModalAadhar = true;
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
    GetOtpAadhar() {
        if(this.LAadharNumber.slice(0, 4) === "XXXX"&&this.consentYes==true){
            this.newModal=true;
            this.showModalAadhar=false
        }else
        if(this.consentYes==true ){
            this.verifiedAadhar = true;
            setTimeout(() => {
                this.verifiedAadhar = false;
            }, 5000)
            console.log(this.LAadharNumber);
            if (this.LAadharNumber != "" && this.LAadharNumber != undefined) {
                AadharVerification({ aadhaarNo: this.LAadharNumber, consent: 'y' })
                    .then((result) => {
                        console.log("result===" + result);
                        let responseObj = JSON.parse(result);
                        console.log(responseObj);
                        this.requestIdAadhar = responseObj.requestId;
                        //console.log('Address: '+responseObj.dataResponse.splitAddress);
                        //console.log('Country:'+responseObj.dataResponse.splitAddress.country);
    
                        if (responseObj.statusCode == 101) {
                            this.showModalAadhar = true;
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

        }else{
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please check consent',
                variant: 'error',
            });
            this.dispatchEvent(event);
        }
      
    }
    @track duplicateAccountResult;
    @track makeadhardisable = false;
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
            console.log(this.aadharLastFour);
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
                        this.sumScorePercent = (this.sumScore / 3) * 100;
                        this.sumScorePercent = Math.floor(this.sumScorePercent * 100) / 100;
                        console.log('this.sumScore', this.sumScore);
                        console.log('this.sumScore percent', this.sumScorePercent);
                        console.log("Pan Verification done!!");
                        this.panStatus = true;
                        console.log("MAKESSSS===" + this.makepandisable);
                        const event = new ShowToastEvent({
                            title: 'Success',
                            message: 'PAN verified!!',
                            variant: 'success',
                        });
                        this.dispatchEvent(event);
                        this.buttonLabelPan = 'Verified';
                        this.verifiedPan = true;
                        this.makepandisable = true;
                        this.makeadhardisable = true;
                        this.buttonStylePan = 'display:none;'
                        this.matchText = this.sumScorePercent + '% PROFILE MATCHED';
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

    handleGetOTPMobile() {
        this.verifiedMob = true;
        setTimeout(() => {
            this.verifiedMob = false;
        }, 5000)
        if (this.LMobile != "" && this.LMobile != undefined) {
            OtpRequestMob({ mobile: this.LMobile, consent: 'y' })
                .then((result) => {
                    console.log("full", result);
                    let responseObj = JSON.parse(result);
                    console.log(responseObj);
                    this.requestIdMob = responseObj.dataResponse['request_id'];
                    console.log("reqid", this.requestIdMob);
                    if (responseObj.dataResponse['status-code'] == 101) {
                        this.showModalMobile = true;
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
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: 'Failed to send OTP',
                        variant: 'error',
                    });
                    this.dispatchEvent(event);
                });
        }
    }


    handleVerifyMob() {
        console.log("this.otpValueMob", this.otpValueMob);
        console.log("this.requestIdMob", this.requestIdMob);
        OtpVerifyMob({ otp: this.otpValueMob, request_Id: this.requestIdMob })
            .then((result) => {
                console.log("full", result);
                let responseObj = JSON.parse(result);
                console.log(responseObj);
                if (responseObj.dataResponse['status-code'] == 101) {
                    this.showModalMobile = false;
                    this.mobileStatus = true;
                    this.displayTextMob = 'display:block;  color:green; font-weight:bold;'
                    this.buttonStyleMob = 'display:none';
                    this.verifiedMob = true;
                    const event = new ShowToastEvent({
                        title: 'Success',
                        message: 'Mobile Number Verified!',
                        variant: 'success',
                    });
                    this.dispatchEvent(event);
                } else {
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: 'Failed to Verify! Please try again!',
                        variant: 'error',
                    });
                    this.dispatchEvent(event);
                }
            })
            .catch((error) => {
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: 'Failed to verify OTP',
                    variant: 'error',
                });
                this.dispatchEvent(event);
            });
        console.log("mobile Verification Done");
    }

    connectedCallback() {
        //this.userProfileName = getFieldValue(this.userRecord.data, ProfileName);
        //console.log('userProfileName' , this.userProfileName);
        this.getAllApplicantData();
        this.activesectionname ='0';
        this.todaysDate = new Date().toISOString().split('T')[0];
    }
    @track newModal= false;
    inputAadhar(){
        if(this.consentYes==true){
            this.newModal = true;
            this.showModalAadhar=false;
        }else{
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please check consent',
                variant: 'error',
            });
            this.dispatchEvent(event);
        }
    }
   
@track aadharInput=true;
@track aadharInputStyle = 'display:none';
@track lastFour;
@track emailStatus;
@track mobileStatus;
    getAllApplicantData() {
        console.log('Lead Id', this.leadRecordId);
        getapplicantData({ leadGetId: this.leadRecordId })
            .then(result => {
                //debugger;
                
                this.wrapperForCommLeadForm = result;
                console.log('Account Lead Data', +this.wrapperForCommLeadForm);
                console.log('wrapperForCommLeadForm' , JSON.stringify(this.wrapperForCommLeadForm));
    
                this.leadID = this.wrapperForCommLeadForm.LeadRecords.Id;
                console.log('this.leadID data===>' + this.leadID);
                this.leadSalutation = this.wrapperForCommLeadForm.LeadRecords.Salutation;
                if (this.wrapperForCommLeadForm.LeadRecords.FirstName != null) {
                    this.leadFirstName = this.wrapperForCommLeadForm.LeadRecords.FirstName;
                }
                console.log('this.leadFirstName data===>' + this.leadFirstName);
                this.leadMiddleName = this.wrapperForCommLeadForm.LeadRecords.MiddleName;
                this.leadLastName = this.wrapperForCommLeadForm.LeadRecords.LastName;
                // this.leadDOB = this.wrapperForCommLeadForm.LeadRecords.Date_of_Birth__c;            
                this.leadMobile = this.wrapperForCommLeadForm.LeadRecords.MobilePhone;
                this.leadEmail = this.wrapperForCommLeadForm.LeadRecords.Email;
                this.consentYes = this.wrapperForCommLeadForm.LeadRecords.KYC_Consent__c;
                this.aadharStatus=this.wrapperForCommLeadForm.AccRecords.Aadhar_Verified__c;
                this.panStatus=this.wrapperForCommLeadForm.AccRecords.Pan_verified__c;
                this.emailStatus=this.wrapperForCommLeadForm.AccRecords.Email_Verified__c;
                this.mobileStatus=this.wrapperForCommLeadForm.AccRecords.Mobile_Number_Verified__c;
                
                if(this.wrapperForCommLeadForm.AccRecords.Email_Verified__c==true){
                        this.buttonStyle = 'display:none';
               }else{
                    this.buttonStyle = 'display:block';
                }
                if(this.wrapperForCommLeadForm.AccRecords.Pan_verified__c==true){
                        this.buttonStylePan = 'display:none';
                }else{
                   this.buttonStylePan = 'display:block';
                }
                if(this.wrapperForCommLeadForm.AccRecords.Mobile_Number_Verified__c==true){
                        this.buttonStyleMob = 'display:none';
                }else{
                   this.buttonStyleMob = 'display:block';
                }

               if (this.wrapperForCommLeadForm.LeadRecords.Aadhar_Number__c != null) {
                    this.hideBasicSection = true;

                    if(this.isSalesUser == false){
                    this.LAadharNumber = this.wrapperForCommLeadForm.LeadRecords.Aadhar_Number__c;
                    this.makeadhardisable = true;
                    if(this.aadharStatus==false){
                        if(this.LAadharNumber.slice(0, 4) === "XXXX"){
                            this.lastFour = this.LAadharNumber.slice(-4);
                            this.aadharInputStyle='display:block';
                            this.aadharInput = false;
                        }
                    }
                    }else if(this.isSalesUser == true){
                                this.SalesLAadharNumber = this.wrapperForCommLeadForm.LeadRecords.Aadhar_Number__c;
                                this.salessmakeadhardisable = true;
                    }
                }
                if (this.wrapperForCommLeadForm.LeadRecords.PAN_Number__c != null) {
                    this.PANNumber = this.wrapperForCommLeadForm.LeadRecords.PAN_Number__c;
                    this.makepandisable = true;
                }
                if (this.wrapperForCommLeadForm.LeadRecords.Passport_Number__c != null) {
                    this.passportNumber = this.wrapperForCommLeadForm.LeadRecords.Passport_Number__c;
                    this.makepassportdisable = true;
                }
                //Added by Avadhut
                if (this.wrapperForCommLeadForm.LeadRecords.Passport_File_Number__c != null) {
                    this.passportFileNumber = this.wrapperForCommLeadForm.LeadRecords.Passport_File_Number__c;
                    this.makepassportFiledisable = true;
                }
                if (this.wrapperForCommLeadForm.LeadRecords.Driving_License_Number__c != null) {
                    this.Driving_License_Number__c = this.wrapperForCommLeadForm.LeadRecords.Driving_License_Number__c;
                    this.makedrivingdisable = true;
                }
                if (this.wrapperForCommLeadForm.LeadRecords.Voter_Id__c != null) {
                    this.voterId = this.wrapperForCommLeadForm.LeadRecords.Voter_Id__c;
                    this.makevoteriddisable = true;
                }
                if (this.wrapperForCommLeadForm.LeadRecords.CKYC_Number__c != null) {
                    this.CKYCNumber = this.wrapperForCommLeadForm.LeadRecords.CKYC_Number__c;
                    this.makeCKYCdisable = true;
                }
                if (this.wrapperForCommLeadForm.LeadRecords.NREG_Number__c != null) {
                    this.NREGNumber = this.wrapperForCommLeadForm.LeadRecords.NREG_Number__c;
                    this.makeNREGdisable = true;
                }
    
                //Applicant Account
                this.AppliAccID = this.wrapperForCommLeadForm.AccRecords.Account__c;
                this.AppliFullName = this.wrapperForCommLeadForm.LeadRecords.FirstName;
                this.AppliGender = this.wrapperForCommLeadForm.AccRecords.Account__r.Gender__c;
                this.AppliIsIncomeConsiderIsFin = this.wrapperForCommLeadForm.AccRecords.Account__r.Is_Income_Considered_Is_Financial__c;
                this.AppliMaritlStatus = this.wrapperForCommLeadForm.AccRecords.Account__r.Marital_Status__c;
                this.AppliDOB = this.wrapperForCommLeadForm.AccRecords.Account__r.Date_of_Birth__c;
    
                //Check if Marital status is Marriend then show Spouse fields
                if (this.AppliMaritlStatus == "Married") {
                    this.ShowFieldsAppliSpouse = true;
                }
                else {
                    this.ShowFieldsAppliSpouse = false;
                }
    
                //Applicant Current Address
                this.AppliCurrentAddID = this.wrapperForCommLeadForm.CPAAppliCurrentRecord.Id;
                this.AppliCurrentName = this.wrapperForCommLeadForm.CPAAppliCurrentRecord.Name;
                this.AppliCurrentAddProof = this.wrapperForCommLeadForm.CPAAppliCurrentRecord.Address_Proof__c;
                this.AppliCurrentAddress = this.wrapperForCommLeadForm.CPAAppliCurrentRecord.Address_1__c;
                this.AppliCurrentCity = this.wrapperForCommLeadForm.CPAAppliCurrentRecord.City__c;
                //this.AppliCurrentTaluka = this.wrapperForCommLeadForm.CPAAppliCurrentRecord.Taluka__c;
                this.AppliCurrentDistrict = this.wrapperForCommLeadForm.CPAAppliCurrentRecord.District__c;
                this.AppliCurrentYear = this.wrapperForCommLeadForm.CPAAppliCurrentRecord.Years_In_The_Address__c;
                this.AppliCurrentPincode = this.wrapperForCommLeadForm.CPAAppliCurrentRecord.Pin_Code__c;
                this.AppliCurrentLandmark = this.wrapperForCommLeadForm.CPAAppliCurrentRecord.Landmark__c;
                this.AppliCurrentState = this.wrapperForCommLeadForm.CPAAppliCurrentRecord.State__c;
                this.AppliCurrentCountry = this.wrapperForCommLeadForm.CPAAppliCurrentRecord.Country__c;
    
                //Applicant Permanent Address
                this.AppliPermanentAddID = this.wrapperForCommLeadForm.CPAAppliPermanentRecord.Id;
                this.AppliPermanentName = this.wrapperForCommLeadForm.CPAAppliPermanentRecord.Name;
                this.AppliPermanentAddProof = this.wrapperForCommLeadForm.CPAAppliPermanentRecord.Address_Proof__c;
                this.AppliPermanentAddress = this.wrapperForCommLeadForm.CPAAppliPermanentRecord.Address_1__c;
                this.AppliPermanentCity = this.wrapperForCommLeadForm.CPAAppliPermanentRecord.City__c;
                //this.AppliPermanentTaluka = this.wrapperForCommLeadForm.CPAAppliPermanentRecord.Taluka__c;
                this.AppliPermanentDistrict = this.wrapperForCommLeadForm.CPAAppliPermanentRecord.District__c;
                this.AppliPermanentYear = this.wrapperForCommLeadForm.CPAAppliPermanentRecord.Years_In_The_Address__c;
                this.AppliPermanentPincode = this.wrapperForCommLeadForm.CPAAppliPermanentRecord.Pin_Code__c;
               this.AppliPermanentLandmark = this.wrapperForCommLeadForm.CPAAppliPermanentRecord.Landmark__c;
                this.AppliPermanentState = this.wrapperForCommLeadForm.CPAAppliPermanentRecord.State__c;
                this.AppliPermanentCountry = this.wrapperForCommLeadForm.CPAAppliPermanentRecord.Country__c;
                            
                if(this.wrapperForCommLeadForm.CPAAppliCurrentRecord.Is_Communication_address__c == true){
                    this.AppliPermIsCommAddressvalue = 'Current Address';
                }
                else if(this.wrapperForCommLeadForm.CPAAppliPermanentRecord.Is_Communication_address__c == true){
                    this.AppliPermIsCommAddressvalue = 'Permanent Address';
                }
    
                if (this.wrapperForCommLeadForm.CPAAppliPermanentRecord.Same_as_Current_Address__c == true) {
                    this.AppliPermanentSameAsCurrent = true;
                    this.makePermanentAddProofdisabled = true;
                }
                else{
                    this.AppliPermanentSameAsCurrent = false;
                    this.makePermanentAddProofdisabled = false;
                }
    
                //Demography
                this.DemographyID = this.wrapperForCommLeadForm.DemographyRecord.Id;
                this.AppliFatherFirstName = this.wrapperForCommLeadForm.DemographyRecord.Father_s_First_Name__c;
                this.AppliFatherMiddleName = this.wrapperForCommLeadForm.DemographyRecord.Father_s_Middle_Name__c;
                this.AppliFatherLastName = this.wrapperForCommLeadForm.DemographyRecord.Father_s_Last_Name__c;
                this.AppliMotherFirstName = this.wrapperForCommLeadForm.DemographyRecord.Mother_s_First_Name__c;
                this.AppliMotherMiddleName = this.wrapperForCommLeadForm.DemographyRecord.Mother_s_Middle_Name__c;
                this.AppliMotherLastName = this.wrapperForCommLeadForm.DemographyRecord.Mother_s_Last_Name__c;
                this.AppliSpouseFirstName = this.wrapperForCommLeadForm.DemographyRecord.Spouse_s_First_Name__c;
                this.AppliSpouseMiddleName = this.wrapperForCommLeadForm.DemographyRecord.Spouse_s_Middle_name__c;
                this.AppliSpouseLastName = this.wrapperForCommLeadForm.DemographyRecord.Spouse_s_Last_Name__c;

                if(this.wrapperForCommLeadForm.CPAAppliPermanentRecord.Id != null && this.wrapperForCommLeadForm.CPAAppliCurrentRecord.Id != null){
                    this.firstCheck = true;
                }
    
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
        if (this.LEmail.match(/[A-Za-z0-9._-]+@[a-z0-9]+\.[a-z]{2,}$/)&&this.emailStatus != true) {
            this.buttonStyle = 'display:block';
        } else {
            this.buttonStyle = 'display:none';
        }
    }
    newChangeMob(event) {
        this.LMobile = event.target.value;
        if (this.LMobile.match(/^(?:\+[\d]{1,3})?(?:[\d]{10,13})$/)&&this.mobileStatus!=true) {
            this.buttonStyleMob = 'display:block';
        } else {
            this.buttonStyleMob = 'display:none';
        }
    }

    @track finalAadharNumberToSave;
    newChangeAadhar(event) {
        this.LAadharNumber = event.target.value;
       if(this.LAadharNumber != ''){
        if (this.LAadharNumber.match(/^[0-9]{12}$/)&&this.aadharStatus!=true) {
            this.buttonStyleAadhar = 'display:block';
            this.errorAadharInvalid = false;
            this.hideBasicSection = true;
        } else {
            this.buttonStyleAadhar = 'display:none';
            this.errorAadharInvalid = true;
            this.hideBasicSection = false;
        } 
    }
    else{
        this.errorAadharInvalid = false;
    }

       this.aadharLastFour = this.LAadharNumber.slice(-4);
        this.finalAadharNumberToSave = 'XXXXXXXX'+this.aadharLastFour;

    }

    salesChangeAadhar(event) {
        this.SalesLAadharNumber = event.target.value;
        
        if(this.SalesLAadharNumber != ''){
        if (this.SalesLAadharNumber.match(/^[0-9]{4}$/)) {
            this.saleserrorAadharInvalid = false;
            this.hideBasicSection = true;
        } else {
            this.saleserrorAadharInvalid = true;
            this.hideBasicSection = false;
        } 
    }
    else{
        this.saleserrorAadharInvalid = false;
    }
        this.finalAadharNumberToSave = 'XXXXXXXX'+this.SalesLAadharNumber;

    }


    newChangePan(event) {
        this.PANNumber = event.target.value.toUpperCase();
      
        if(this.PANNumber != ''){
        if (this.PANNumber.match(/[A-Z]{5}[0-9]{4}[A-Z]{1}$/) && this.panStatus!=true ) {
            this.buttonStylePan = 'display:block';
            this.errorPanInvalid = false;
        } else {
            this.buttonStylePan = 'display:none';
            this.errorPanInvalid = true;
        }
    }else{
        this.errorPanInvalid = false;
    }

   }

    @track errormessagetrue = false;
    @track errorfield;
    @track calculatePercent = 0;
    @track increasePercent = 1.20;

    handlechange(event) {

        if (event.target.name == "Salutation") {
            console.log(event.target.value);
            this.leadSalutation = event.target.value;
            if(event.target.value==''||event.target.value==undefined){
                //this.calculatePercent = this.calculatePercent- this.increasePercent;
                if(this.calculatePercent < 0 ){
                    this.calculatePercent = 0;
                }
            }else{
                //this.calculatePercent = this.calculatePercent + this.increasePercent;
           }
           
        }
        if (event.target.name == "firstName") {
            if(event.target.value==''||event.target.value==undefined){
                //this.calculatePercent = this.calculatePercent- this.increasePercent;
                if(this.calculatePercent < 0 ){
                    this.calculatePercent = 0;
                }
            }else{
                //this.calculatePercent = this.calculatePercent + this.increasePercent;
            }
            console.log(event.target.value);
            let fieldValue = event.target.value;
            let pattern = /^[a-zA-Z\s]*$/;
            if (!pattern.test(fieldValue)) {
            this.errorFirstNameInvalid = true;
            
            }else{
                this.leadFirstName = event.target.value;
                this.errorFirstNameInvalid = false;
            }
        }
        if (event.target.name == "LastName1") {
            let fieldValue = event.target.value;
            if(event.target.value==''||event.target.value==undefined){
                //this.calculatePercent = this.calculatePercent- this.increasePercent;
                if(this.calculatePercent < 0 ){
                    this.calculatePercent = 0;
                }
            }else{
                //this.calculatePercent = this.calculatePercent + this.increasePercent;
            }
            let pattern = /^[a-zA-Z\s]*$/;
            if (!pattern.test(fieldValue)) {
            this.errorLastNameInvalid = true;
           
            }else{
                this.leadLastName = event.target.value;
               this.errorLastNameInvalid = false;
            }  
        }
        if (event.target.name == "middleName") {
            this.leadMiddleName = event.target.value;
        }
        if (event.target.name == "Email") {
            this.leadEmail = event.target.value;
            if(event.target.value==''||event.target.value==undefined){
                //this.calculatePercent = this.calculatePercent- this.increasePercent;
                if(this.calculatePercent < 0 ){
                    this.calculatePercent = 0;
                }
            }else{
                //this.calculatePercent = this.calculatePercent + this.increasePercent;
            }
        }
        if (event.target.name == "MotherFirstName") {
            
            let fieldValue = event.target.value;
            if(event.target.value==''||event.target.value==undefined){
                //this.calculatePercent = this.calculatePercent- this.increasePercent;
                if(this.calculatePercent < 0 ){
                    this.calculatePercent = 0;
                }
           }else{
                //this.calculatePercent = this.calculatePercent + this.increasePercent;
            }

            let pattern = /^[a-zA-Z\s]*$/;
            if (!pattern.test(fieldValue)) {
            this.errorMotherNameInvalid = true;
            }else{
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
            if(event.target.value==''||event.target.value==undefined){
                //this.calculatePercent = this.calculatePercent- this.increasePercent;
                if(this.calculatePercent < 0 ){
                    this.calculatePercent = 0;
                }
            }else{
                //this.calculatePercent = this.calculatePercent + this.increasePercent;
            }
        }
        if (event.target.name == "Mobile") {
            this.leadMobile = event.target.value;
            if(event.target.value==''||event.target.value==undefined){
                //this.calculatePercent = this.calculatePercent- this.increasePercent;
                if(this.calculatePercent < 0 ){
                    this.calculatePercent = 0;
                }
           }else{
                //this.calculatePercent = this.calculatePercent + this.increasePercent;
            }
        }
        if (event.target.name == "FatherFirstName") {
            
            let fieldValue = event.target.value;
            if(event.target.value==''||event.target.value==undefined){
                //this.calculatePercent = this.calculatePercent- this.increasePercent;
                if(this.calculatePercent < 0 ){
                    this.calculatePercent = 0;
                }
           }else{
                //this.calculatePercent = this.calculatePercent + this.increasePercent;
            }

            let pattern = /^[a-zA-Z\s]*$/;
            if (!pattern.test(fieldValue)) {
            this.errorFatherNameInvalid = true;
            }else{ 
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
            if(this.voterId != ''){
            if (this.voterId.length > 20) {
                this.errorVoterIdInvalid = true;
            }
            else{
                this.errorVoterIdInvalid = false;
            }
        }else{
            this.errorVoterIdInvalid = false;
        }
       }   
        if (event.target.name == "passportNumber") {
            this.passportNumber = event.target.value;
            if(this.passportNumber != ''){
            if(this.passportNumber.match(/^[A-Z]{1}[0-9]{7}$/)){
                this.errorPassportInvalid = false;
            }
            else{
                this.errorPassportInvalid = true;
            }
        }else{
            this.errorPassportInvalid = false;
        }
       }   
        //Added by Avadhut 
        if (event.target.name == "passportFileNumber" ) {
            this.passportFileNumber = event.target.value;
            if(this.passportFileNumber != ''){
            if(this.passportFileNumber.match(/^[A-Z]{4}[0-9]{8}$/)){
                this.errorPasspostFilrInvalid = false;
            }
            else{
                this.errorPasspostFilrInvalid = true;
            }
        }else{
            this.errorPasspostFilrInvalid = false;
        }
        }   
        if (event.target.name == "appliCurrentAddProof") {
            this.AppliCurrentAddProof = event.target.value;
            if(event.target.value==''||event.target.value==undefined){
                //this.calculatePercent = this.calculatePercent- this.increasePercent;
                if(this.calculatePercent < 0 ){
                    this.calculatePercent = 0;
                }
            }else{
                //this.calculatePercent = this.calculatePercent + this.increasePercent;
           }
        }
        if (event.target.name == "ApplicurrentAddress") {
            this.AppliCurrentAddress = event.target.value;
            if(event.target.value==''||event.target.value==undefined){
                //this.calculatePercent = this.calculatePercent- this.increasePercent;
                if(this.calculatePercent < 0 ){
                    this.calculatePercent = 0;
                }
                console.log("emply calculatePercent",this.calculatePercent);
            }else{
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
            if(event.target.value==''||event.target.value==undefined){
                if(this.calculatePercent < 0 ){
                    this.calculatePercent = 0;
                }
            }else{
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
            }else{
                this.errorCKYCInvalid = false;
            }
        }
        if (event.target.name == "NREGNumber") {
            this.NREGNumber = event.target.value;
            let pattern = /[A-Z]{2}-\d{2}-\d{3}-\d{3}-\d{3}\/\d{3}/;
            if (!pattern.test(this.NREGNumber)) {
            this.errorNREGInvalid = true;
            }else{
                this.errorNREGInvalid = false;
            }
        }    
    }

    handleAppliSpouseShowHide(event) {
        if(event.target.value==''||event.target.value==undefined){
            //this.calculatePercent = this.calculatePercent- this.increasePercent;
            if(this.calculatePercent < 0 ){
                this.calculatePercent = 0;
            }
        }else{
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
        if(this.Driving_License_Number__c != ''){
        if (this.Driving_License_Number__c.match(/[A-Za-z]{2}[\d\s\-]{14}/)) {
            this.errorDLInvalid = false;
        }
        else{
            this.errorDLInvalid = true;
        }
    }else{
        this.errorDLInvalid = false;
    }
    }

    @track makePermanentAddProofdisabled = false;

    handleAppliPermanentAddBox(event) {
        //Same as Current address checkbox   
        this.AppliPermanentSameAsCurrent = event.target.checked;
        console.log("Chhecked: " + event.target.checked);
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
            
        }else{
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
        return ['.pdf', '.png', '.jpeg'];
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
        if(event.target.value==''||event.target.value==undefined){
            //this.calculatePercent = this.calculatePercent- this.increasePercent;
            if(this.calculatePercent < 0 ){
                this.calculatePercent = 0;
            }
        }else{
            //this.calculatePercent = this.calculatePercent + this.increasePercent;
        }
        this.AreaPinCode = event.target.value;
        if(this.AreaPinCode ==''){           
            this.AppliCurrentCity = '';
            this.AppliCurrentState = '';
            this.AppliCurrentCountry = '';
            this.AppliCurrentDistrict = '';
            this.AppliCurrentTaluka = '';
        }else{
        getPincodeRecord({ pincode: this.AreaPinCode }) //this parameter is passed to Class-QACommunityLeadFormController.getPincodeRecord
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
        if(this.AreaPinCode ==''){ 
            this.AppliPermanentCity = '';
            this.AppliPermanentState = '';
            this.AppliPermanentCountry = '';
            this.AppliPermanentDistrict = '';
            this.AppliPermanentTaluka = '';
        }else{
        getPincodeRecord({ pincode: this.AreaPinCode }) //this parameter is passed to Class-QACommunityLeadFormController.getPincodeRecord
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

    handleSaveApplicant() {

        if(this.alreadyduplicatefound == true && this.checkResponse == true){
            this.AppliCurrentAddID = null;
            this.AppliPermanentAddID = null;
            this.DemographyID = null;
        }
    
        if(this.AppliPermIsCommAddressvalue == 'Current Address'){
            this.Setcommunicationaddresscurrent = true;
        }
        else if(this.AppliPermIsCommAddressvalue == 'Permanent Address'){
            this.Setcommunicationaddresspernmanent = true;
        }

        if(this.saleserrorAadharInvalid == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Fill last 4 Digits of Aadhar Number',
                    variant: 'Error',
                }),
            );
        }
        else if(this.AppliIsIncomeConsiderIsFin == 'Yes' && (this.PANNumber == '' || this.PANNumber == undefined)){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter PAN Number',
                    variant: 'Error',
                }),
            );
        }
        else if(this.errorCKYCInvalid == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter Valid CKYC Number',
                    variant: 'Error',
                }),
            );
        }
        else if(this.errorFirstNameInvalid == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter Valid First Name',
                    variant: 'Error',
                }),
            );
        }
        else if(this.errorLastNameInvalid == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter Valid Last Name',
                    variant: 'Error',
                }),
            );
        }
        else if(this.errorFatherNameInvalid == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter Valid Father First Name',
                    variant: 'Error',
                }),
            );
        }
        else if(this.errorMotherNameInvalid == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter Valid Mother First Name',
                    variant: 'Error',
                }),
            );
        }
        else if(this.errorAadharInvalid == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter Valid Aadhar Number',
                    variant: 'Error',
                }),
            );
        }
        else if(this.errorPanInvalid == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter Valid PAN Number',
                    variant: 'Error',
                }),
            );
        }
        else if(this.errorDLInvalid == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter Valid Driving Licence',
                    variant: 'Error',
                }),
            );
        }
        else if(this.errorPassportInvalid == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter Valid Passport Number',
                    variant: 'Error',
                }),
            );
        }
        else if(this.errorPasspostFilrInvalid == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter Valid Passport File Number',
                    variant: 'Error',
                }),
            );
        }
        else if(this.errorVoterIdInvalid == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter Valid Voter Id',
                    variant: 'Error',
                }),
            );
        }
        else if(this.errormessagetrue == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: `Please enter valid ${this.errorfield}`,
                    variant: 'Error',
                }),
            );
        }
        else if(this.LAadharNumber == this.duplicatevalue && this.errorMsgForDuplicate == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'An account exists with the Aadhar provided. Kindly crosscheck',
                    variant: 'Error',
                }),
            );
        }
        else if(this.PANNumber == this.duplicatevalue && this.errorMsgForDuplicate == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'An account exists with the PAN Number provided. Kindly crosscheck',
                    variant: 'Error',
                }),
            );
        }
        else if(this.passportNumber == this.duplicatevalue && this.errorMsgForDuplicate == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'An account exists with the Passport Number provided. Kindly crosscheck',
                    variant: 'Error',
                }),
            );
        }
        else if(this.Driving_License_Number__c == this.duplicatevalue && this.errorMsgForDuplicate == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'An account exists with the Driving License provided. Kindly crosscheck',
                    variant: 'Error',
                }),
            );
        }
        else if(this.voterId == this.duplicatevalue && this.errorMsgForDuplicate == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'An account exists with the Voter Id provided. Kindly crosscheck',
                    variant: 'Error',
                }),
            );
        }
        else if (this.AppliDOB == '' || this.AppliDOB == undefined || (this.isSalesUser == false && (this.LAadharNumber == '' || this.LAadharNumber == undefined)) ||
            this.leadFirstName == '' || this.leadFirstName == undefined || this.leadLastName == '' || this.leadLastName == undefined ||
            this.leadEmail == '' || this.leadEmail == undefined || this.leadMobile == '' || this.leadMobile == undefined 
          ){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Required details are not provided.',
                    variant: 'Error',
                }),
            );
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
        ){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter Current and Permanent Address.',
                    variant: 'Error',
                }),
            );
        }
        else if ((this.AppliPermanentCountry.toUpperCase() != 'INDIA' && this.AppliPermIsCommAddressvalue == 'Permanent Address') || (this.AppliCurrentCountry.toUpperCase() != 'INDIA' && this.AppliPermIsCommAddressvalue == 'Current Address')) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter country as India for communication address',
                    variant: 'Error',
                }),
            );
        }
        else {
            let LeadDataSaveRec = {
                Salutation: this.leadSalutation,
                FirstName: this.leadFirstName,
                MiddleName: this.leadMiddleName,
                LastName: this.leadLastName,
                MobilePhone: this.leadMobile,
                Email: this.leadEmail,
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
                Course_Start_Date__c: this.courseStartDate,
                Course_End_Date__c: this.courseEndDate,
                Language_Score_Category__c: this.LangScoreCategoryValue,
                Language_Test_Score__c: this.langTestScore,
                Analytics_Score_Category__c: this.AnalytScoreCategoryValue,
                Analytics_Test_Score__c: this.analyticalTestScore,
                Aadhar_Number__c: this.finalAadharNumberToSave,
                PAN_Number__c: this.PANNumber,
                Voter_Id__c: this.voterId,
                Passport_Number__c: this.passportNumber,
                Driving_License_Number__c: this.Driving_License_Number__c,
                CKYC_Number__c : this.CKYCNumber,
                NREG_Number__c : this.NREGNumber,
                KYC_Consent__c : this.consentYes,
                Passport_File_Number__c : this.passportFileNumber,
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
                Aadhar_Verified__c:this.aadharStatus,
                Email_Verified__c:this.emailStatus,
                Mobile_Number_Verified__c:this.mobileStatus,
                Pan_verified__c:this.panStatus,
                Passport_File_Number__c : this.passportFileNumber,
                CKYC_Number__c : this.CKYCNumber,
                NREG_Number__c : this.NREGNumber,
            }
            let AppliCurrentAddSaveRec = {
                Name: this.leadFirstName+' '+this.leadLastName,
                Address_Proof__c: this.AppliCurrentAddProof,
                Address_1__c: this.AppliCurrentAddress,
                City__c: this.AppliCurrentCity,
                //Taluka__c: this.AppliCurrentTaluka,
                District__c: this.AppliCurrentDistrict,
                Years_In_The_Address__c : this.AppliCurrentYear,
                Pin_Code__c: this.AppliCurrentPincode,
                Landmark__c: this.AppliCurrentLandmark,
                State__c: this.AppliCurrentState,
                Country__c: this.AppliCurrentCountry,
                Id: this.AppliCurrentAddID,
                Address_Type__c: 'Current Address',
                Account__c: this.AppliAccID,
                Is_Communication_address__c : this.Setcommunicationaddresscurrent                
            }
            let AppliPermanentAddSaveRec = {
                Name: this.leadFirstName+' '+this.leadLastName,
                Address_Proof__c: this.AppliPermanentAddProof,
                Address_1__c: this.AppliPermanentAddress,
                City__c: this.AppliPermanentCity,
                //Taluka__c: this.AppliPermanentTaluka,
                District__c: this.AppliPermanentDistrict,
                Years_In_The_Address__c : this.AppliPermanentYear,
                Pin_Code__c: this.AppliPermanentPincode,
                Landmark__c: this.AppliPermanentLandmark,
                State__c: this.AppliPermanentState,
                Country__c: this.AppliPermanentCountry,
                Id: this.AppliPermanentAddID,
                Address_Type__c: 'Permanent Address',
                Account__c: this.AppliAccID,
                Same_as_Current_Address__c: this.AppliPermanentSameAsCurrent,
                Is_Communication_address__c : this.Setcommunicationaddresspernmanent
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
            console.log('wrapperCommFormRecord=====>' + JSON.stringify(wrapperCommFormRecord));
    
            this.isLoading = true;
                   /****progress bar data pass****/
                   getLeadTotalPercentage({ leadId:this.leadRecordId })
                   .then(result => {
                       let newPerc = 12;
                       let ProgrssValueOfLoanSection = {ProgrssValueOfLoanSection:newPerc };
                       publish(this.messageContext, progressBar, ProgrssValueOfLoanSection);
                       updateLeadTotalPercentage({ leadId: this.leadRecordId, percentage: newPerc })
                       .then(result => {
                           if (result === 'Success') {
                               console.log('Lead updated successfully');
                           } else {
                               console.error('Failed to update Lead');
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
            
            creatCommFormLeadRecords({
                wrapperCommFormDetails: JSON.stringify(wrapperCommFormRecord)
            })
                .then(response => {
                    this.isLoading = false;
                    if (response != null) {
                        this.wrapperForCommLeadForm = response;
                        this.checkResponse = false;
                        this.leadID = this.wrapperForCommLeadForm.LeadRecords.Id;
                        this.AppliAccID = this.wrapperForCommLeadForm.AccRecords.Account__c;
                        this.AppliCurrentAddID = this.wrapperForCommLeadForm.CPAAppliCurrentRecord.Id;
                        this.AppliPermanentAddID = this.wrapperForCommLeadForm.CPAAppliPermanentRecord.Id;
                        this.DemographyID = this.wrapperForCommLeadForm.DemographyRecord.Id;
                    }
                    
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Successfully Saved',
                            variant: 'Success',
                        }),
                    );
                    
                   
                }).catch(error => {
                    console.log('Error: '+JSON.stringify(error));
                    this.isLoading = false;
                })
        }
    }

    handleNextApplicant() {
        if(this.alreadyduplicatefound == true && this.checkResponse == true){
            console.log('INSDIE TRUE DUPLICATE RECORD');
            this.AppliCurrentAddID = null;
            this.AppliPermanentAddID = null;
            this.DemographyID = null;
        }
    
        if(this.AppliPermIsCommAddressvalue == 'Current Address'){
            this.Setcommunicationaddresscurrent = true;
        }
        else if(this.AppliPermIsCommAddressvalue == 'Permanent Address'){
            this.Setcommunicationaddresspernmanent = true;
        }
        if(this.errorNREGInvalid == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter Valid NREG Number',
                    variant: 'Error',
                }),
            );
        }
        else if(this.saleserrorAadharInvalid == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Fill last 4 Digits of Aadhar Number',
                    variant: 'Error',
                }),
            );
        }
        else if(this.AppliIsIncomeConsiderIsFin == 'Yes' && (this.PANNumber == '' || this.PANNumber == undefined)){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter PAN Number',
                    variant: 'Error',
                }),
            );
        }
        else if(this.errorCKYCInvalid == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter Valid CKYC Number',
                    variant: 'Error',
                }),
            );
        }
        else if(this.errorFirstNameInvalid == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter Valid First Name',
                    variant: 'Error',
                }),
            );
        }
        else if(this.errorLastNameInvalid == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter Valid Last Name',
                    variant: 'Error',
                }),
            );
        }
        else if(this.errorFatherNameInvalid == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter Valid Father First Name',
                    variant: 'Error',
                }),
            );
        }
        else if(this.errorMotherNameInvalid == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter Valid Mother First Name',
                    variant: 'Error',
                }),
            );
        }
        else if(this.errorAadharInvalid == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter Valid Aadhar Number',
                    variant: 'Error',
                }),
            );
        }
        else if(this.errorPanInvalid == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter Valid PAN Number',
                    variant: 'Error',
                }),
            );
        }
        else if(this.errorDLInvalid == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter Valid Driving Licence',
                    variant: 'Error',
                }),
            );
        }
        else if(this.errorPassportInvalid == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter Valid Passport Number',
                    variant: 'Error',
                }),
            );
        }
        else if(this.errorPasspostFilrInvalid == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter Valid Passport File Number',
                    variant: 'Error',
                }),
            );
        }
        else if(this.errorVoterIdInvalid == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter Valid Voter Id',
                    variant: 'Error',
                }),
            );
        }
        else if(this.errormessagetrue == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: `Please enter valid ${this.errorfield}`,
                    variant: 'Error',
                }),
            );
        }
        else if(this.LAadharNumber == this.duplicatevalue && this.errorMsgForDuplicate == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'An account exists with the Aadhar provided. Kindly crosscheck',
                    variant: 'Error',
                }),
            );
        }
        else if(this.PANNumber == this.duplicatevalue && this.errorMsgForDuplicate == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'An account exists with the PAN Number provided. Kindly crosscheck',
                    variant: 'Error',
                }),
            );
        }
        else if(this.passportNumber == this.duplicatevalue && this.errorMsgForDuplicate == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'An account exists with the Passport Number provided. Kindly crosscheck',
                    variant: 'Error',
                }),
            );
        }
        else if(this.Driving_License_Number__c == this.duplicatevalue && this.errorMsgForDuplicate == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'An account exists with the Driving License provided. Kindly crosscheck',
                    variant: 'Error',
                }),
            );
        }
        else if(this.voterId == this.duplicatevalue && this.errorMsgForDuplicate == true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'An account exists with the Voter Id provided. Kindly crosscheck',
                    variant: 'Error',
                }),
            );
        }
        else if (this.AppliDOB == '' || this.AppliDOB == undefined || (this.isSalesUser == false && (this.LAadharNumber == '' || this.LAadharNumber == undefined)) ||
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
            this.AppliCurrentAddProof == '' || this.AppliCurrentAddProof == undefined || this.AppliPermanentAddProof == '' || this.AppliPermanentAddProof == undefined){
    
            console.log("Inside date condition");
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Required details are not provided.',
                    variant: 'Error',
                }),
            );
        }
        else if ((this.AppliPermanentCountry.toUpperCase() != 'INDIA' && this.AppliPermIsCommAddressvalue == 'Permanent Address') || (this.AppliCurrentCountry.toUpperCase() != 'INDIA' && this.AppliPermIsCommAddressvalue == 'Current Address')) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter country as India for communication address',
                    variant: 'Error',
                }),
            );
        }
        else {
            let LeadDataSaveRec = {
                Salutation: this.leadSalutation,
                FirstName: this.leadFirstName,
                MiddleName: this.leadMiddleName,
                LastName: this.leadLastName,
                MobilePhone: this.leadMobile,
                Email: this.leadEmail,
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
                Course_Start_Date__c: this.courseStartDate,
                Course_End_Date__c: this.courseEndDate,
                Language_Score_Category__c: this.LangScoreCategoryValue,
                Language_Test_Score__c: this.langTestScore,
                Analytics_Score_Category__c: this.AnalytScoreCategoryValue,
                Analytics_Test_Score__c: this.analyticalTestScore,
                Aadhar_Number__c: this.finalAadharNumberToSave,
                PAN_Number__c: this.PANNumber,
                Voter_Id__c: this.voterId,
                Passport_Number__c: this.passportNumber,
                Driving_License_Number__c: this.Driving_License_Number__c,
                CKYC_Number__c : this.CKYCNumber,
                NREG_Number__c : this.NREGNumber,
                KYC_Consent__c : this.consentYes,
                Passport_File_Number__c : this.passportFileNumber,
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
                Aadhar_Verified__c:this.aadharStatus,
                Email_Verified__c:this.emailStatus,
                Mobile_Number_Verified__c:this.mobileStatus,
                Pan_verified__c:this.panStatus,
                Passport_File_Number__c : this.passportFileNumber,
                CKYC_Number__c : this.CKYCNumber,
                NREG_Number__c : this.NREGNumber,
            }
            let AppliCurrentAddSaveRec = {
                Name: this.leadFirstName+' '+this.leadLastName,
                Address_Proof__c: this.AppliCurrentAddProof,
                Address_1__c: this.AppliCurrentAddress,
                City__c: this.AppliCurrentCity,
                //Taluka__c: this.AppliCurrentTaluka,
                District__c: this.AppliCurrentDistrict,
                Years_In_The_Address__c : this.AppliCurrentYear,
                Pin_Code__c: this.AppliCurrentPincode,
                Landmark__c: this.AppliCurrentLandmark,
                State__c: this.AppliCurrentState,
                Country__c: this.AppliCurrentCountry,
                Id: this.AppliCurrentAddID,
                Address_Type__c: 'Current Address',
                Account__c: this.AppliAccID,
                Is_Communication_address__c : this.Setcommunicationaddresscurrent
                
            }
            let AppliPermanentAddSaveRec = {
                Name: this.leadFirstName+' '+this.leadLastName,
                Address_Proof__c: this.AppliPermanentAddProof,
                Address_1__c: this.AppliPermanentAddress,
                City__c: this.AppliPermanentCity,
                //Taluka__c: this.AppliPermanentTaluka,
                District__c: this.AppliPermanentDistrict,
                Years_In_The_Address__c : this.AppliPermanentYear,
                Pin_Code__c: this.AppliPermanentPincode,
                Landmark__c: this.AppliPermanentLandmark,
                State__c: this.AppliPermanentState,
                Country__c: this.AppliPermanentCountry,
                Id: this.AppliPermanentAddID,
                Address_Type__c: 'Permanent Address',
                Account__c: this.AppliAccID,
                Same_as_Current_Address__c: this.AppliPermanentSameAsCurrent,
                Is_Communication_address__c : this.Setcommunicationaddresspernmanent
            }
            console.log('AppliPermanentAddSaveRec=====>' + JSON.stringify(AppliPermanentAddSaveRec));
    
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
                    console.log(response);
                    if (response != null) {
                        this.wrapperForCommLeadForm = response;
                        this.checkResponse = false;
                        this.leadID = this.wrapperForCommLeadForm.LeadRecords.Id;
                        this.AppliAccID = this.wrapperForCommLeadForm.AccRecords.Account__c;
                        this.AppliCurrentAddID = this.wrapperForCommLeadForm.CPAAppliCurrentRecord.Id;
                        this.AppliPermanentAddID = this.wrapperForCommLeadForm.CPAAppliPermanentRecord.Id;
                        this.DemographyID = this.wrapperForCommLeadForm.DemographyRecord.Id;
                    }
                    
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Successfully Saved',
                            variant: 'Success',
                        }),
                    );
                    const onNextEvent = new CustomEvent('next', {
                        detail: {
                            nextValue: '2',
                        },
                        });
                        this.dispatchEvent(onNextEvent); 

                    //Progress bar update
                    let sum;
                    if(this.firstCheck == true){
                        sum = 0;
                    }
                    else{
                        sum = 12;
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
                        
                }).catch(error => {
                    console.log('Error: '+JSON.stringify(error));
                    this.isLoading = false;
                })
        }
    }
    


    handleIsCommAddress(event) {  
        //debugger;      
        if (event.target.name == "IsCommunicationAddress") {
            this.AppliPermIsCommAddressvalue = event.target.value;
            console.log("this.AppliPermIsCommAddressvalue====  " + this.AppliPermIsCommAddressvalue);
        }
        if((this.AppliPermanentCountry.toUpperCase() != 'INDIA' && this.AppliPermIsCommAddressvalue == 'Permanent Address') || (this.AppliCurrentCountry.toUpperCase() != 'INDIA' && this.AppliPermIsCommAddressvalue == 'Current Address')){
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
    if(event.target.value==''||event.target.value==undefined){
        //this.calculatePercent = this.calculatePercent- this.increasePercent;
        if(this.calculatePercent < 0 ){
            this.calculatePercent = 0;
        }
    }else{
        //this.calculatePercent = this.calculatePercent + this.increasePercent;
   }
    // debugger;
   
        if (event.target.name === 'LAadharNumber' || event.target.name === 'SalesLAadharNumber') {
            
            this.matchParameter = 'Aadhar Number';
            if((this.isSalesUser == false && (this.LAadharNumber == undefined || this.LAadharNumber == null)) ||
                (this.isSalesUser == true && (this.SalesLAadharNumber == undefined || this.SalesLAadharNumber == null))){
                this.matchValue = null;   
            }else{
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

                if (result != null) {
              
                    if((this.AppliAccID != this.duplicateAccountResult.objeAcc.Id) && (this.AppliAccID == null || this.AppliAccID  == undefined) && 
                        (this.alreadyduplicatefound == false || this.alreadyduplicatefound == undefined)){
                            console.log('inside condition of duplicate record');
                        

                            if(this.duplicateAccountResult.objeAcc.Aadhar_Number__c == this.matchValue){
                                this.dispatchEvent(
                                        new ShowToastEvent({
                                            title: 'Info',
                                            message: 'Exisitng account found With your Aadhar Number',
                                            variant: 'info',
                                        }),
                                    );
                            }else if(this.duplicateAccountResult.objeAcc.PAN_Number__c == this.matchValue){
                                   this.dispatchEvent(
                                        new ShowToastEvent({
                                            title: 'Info',
                                            message: 'Exisitng account found With your PAN Number',
                                            variant: 'info',
                                        }),
                                    );
                            }else if(this.duplicateAccountResult.objeAcc.Passport_Number__c == this.matchValue){
                                   this.dispatchEvent(
                                        new ShowToastEvent({
                                            title: 'Info',
                                            message: 'Exisitng account found With your Passport Number',
                                            variant: 'info',
                                        }),
                                    );
                            }else if(this.duplicateAccountResult.objeAcc.Driving_License_Number__c == this.matchValue){
                                    this.dispatchEvent(
                                        new ShowToastEvent({
                                            title: 'Info',
                                            message: 'Exisitng account found With your Driving license Number',
                                            variant: 'info',
                                        }),
                                    );
                            }else if(this.duplicateAccountResult.objeAcc.Voter_ID__c == this.matchValue){
                                    this.dispatchEvent(
                                        new ShowToastEvent({
                                            title: 'Info',
                                            message: 'Exisitng account found With your Voter Id',
                                            variant: 'info',
                                        }),
                                    );
                                }

                                if (this.duplicateAccountResult.objeAcc.Aadhar_Number__c != null) {
                                    //debugger;
                                    this.hideBasicSection = true;

                                    if(this.isSalesUser == false){                                   
                                    if(this.LAadharNumber==''||this.LAadharNumber==undefined){
                                       this.LAadharNumber = this.duplicateAccountResult.objeAcc.Aadhar_Number__c;
                                        this.lastFour = this.LAadharNumber.slice(-4);
                                        this.makeadhardisable = true;
                                        this.buttonStyleAadhar= "display:block";
                                        this.verifiedAadhar=false;
                                        // this.verifiedAadhar=false;
                                        this.buttonLabelAadhar="Verify Aadhar";
                                        
                                    }else{
                                        this.LAadharNumber = this.duplicateAccountResult.objeAcc.Aadhar_Number__c;
                                        this.lastFour = this.LAadharNumber.slice(-4);
                                        this.makeadhardisable = true;
                                        this.dispatchEvent(
                                            new ShowToastEvent({
                                                title: 'Info',
                                                message: 'Previous Aadhar number Updated',
                                                variant: 'info',
                                            }),
                                        );
                                        this.buttonStyleAadhar= "display:block";
                                        this.verifiedAadhar=false;
                                        // this.verifiedAadhar=false;
                                        this.buttonLabelAadhar="Verify Aadhar";
                                    }

                                }else if(this.isSalesUser == true){
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
            this.AppliDOB = this.duplicateAccountResult.objeAcc.Date_of_Birth__c;
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
           if(this.duplicateAccountResult.appCurrentAdd.Is_Communication_address__c == true){
                this.AppliPermIsCommAddressvalue = 'Current Address';
            }
            else if(this.duplicateAccountResult.appPermanentAdd.Is_Communication_address__c == true){
                this.AppliPermIsCommAddressvalue = 'Permanent Address';
            }            
            if (this.duplicateAccountResult.appPermanentAdd.Same_as_Current_Address__c == true) {
                this.AppliPermanentSameAsCurrent = true;
                this.makePermanentAddProofdisabled = true;
            }
            else{
                this.AppliPermanentSameAsCurrent = false;
                this.makePermanentAddProofdisabled = false;
            }
            //Demography
            this.DemographyID = this.duplicateAccountResult.appDemography.Id;
            this.AppliFatherFirstName = this.duplicateAccountResult.appDemography.Father_s_First_Name__c;
            this.AppliFatherMiddleName =this.duplicateAccountResult.appDemography.Father_s_Middle_Name__c;
            this.AppliFatherLastName = this.duplicateAccountResult.appDemography.Father_s_Last_Name__c;
            this.AppliMotherFirstName = this.duplicateAccountResult.appDemography.Mother_s_First_Name__c;
            this.AppliMotherMiddleName = this.duplicateAccountResult.appDemography.Mother_s_Middle_Name__c;
            this.AppliMotherLastName = this.duplicateAccountResult.appDemography.Mother_s_Last_Name__c;
            this.AppliSpouseFirstName = this.duplicateAccountResult.appDemography.Spouse_s_First_Name__c;
            this.AppliSpouseMiddleName = this.duplicateAccountResult.appDemography.Spouse_s_Middle_name__c;
            this.AppliSpouseLastName = this.duplicateAccountResult.appDemography.Spouse_s_Last_Name__c;
            this.alreadyduplicatefound = true;
                }
                else{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!!',
                            message: `An account exists with the ${this.matchParameter} provided. Kindly crosscheck`,
                            variant: 'Error',
                        }),
                    );
                    this.errorMsgForDuplicate = true;
                    this.duplicatevalue = this.matchValue;
                }
                }

            })
            .catch((error) => {
                console.log(error);
            })
    
}
  @track activesectionname='1';
    handleSectionToggleer(event) {
        for(var i in event.detail.openSections){
        }
       if(this.LAadharNumber==undefined||this.LAadharNumber==""){
         this.activesectionname ='0'
       }else{
        this.activesectionname='1,A'
       }
    }
    dobBlur(event){
        if(event.target.value==''||event.target.value==undefined){
           if(this.calculatePercent < 0 ){
                this.calculatePercent = 0;
            }
        }else{
        }
        let enteredDate = new Date(event.target.value);
        let currentDate = new Date();
        const minDate = new Date('1900-01-01');

            if (enteredDate > currentDate) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Entered date should not be Greated than current date',
                        variant: 'Error',
                    }),
                );
                event.target.value='';
            } else if (enteredDate < minDate) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Entered date should be valid',
                        variant: 'Error',
                    }),
                );
                event.target.value='';
              }else {
                this.AppliDOB = event.target.value;
            }
    }
}