import { LightningElement,track,api,wire } from 'lwc';
import getApplicantData from '@salesforce/apex/QACommunityLeadFormController.getWrapperClassCommFormList';
import getCourseEducationaData from '@salesforce/apex/TempControllerSohail.getWrapperClassCommFormList';
import getCoAppRecords from '@salesforce/apex/DemoCommunityLeadForm.getCoapp';
import getTermsAndConditionsCheck  from '@salesforce/apex/ProgressBarPercent.getTermsAndConditionsCheck';
import updateTermsAndConditionsCheck from '@salesforce/apex/ProgressBarPercent.updateTermsAndConditionsCheck';
import getapplicantData from '@salesforce/apex/QACommunityLeadFormController.getWrapperClassCommFormList';

import mandatoryDocumentCheck from '@salesforce/apex/CheckDocumentUpload.mandatoryDocumentCheck';
import DMS_NAMES from '@salesforce/apex/LoanApplicationFormHelper.DMSNames';
import getCoApplicant from '@salesforce/apex/CommunityLeadFormController.getleadWithApplicantsRec';



export default class LeadDocument extends LightningElement {

    leadRecordId='00QBi000004Y9kxMAC';
    
    //Applicant data
    @track wrapperForCommLeadForm;
    @track leadFirstName;
    @track leadLastName;
    @track leadAadharNumber;
    @track PANNumber;
    @track passportNumber;
    @track Driving_License_Number__c;
    @track voterId;
    @track CKYCNumber;
    @track NREGNumber;

    //Course and Education
    @track wrapperForCommLeadFormEducation;
    @track analyticalTestScore;
    @track quanTestScore;
    @track verbalTestScore;
    @track langTestScore;

    //Co-Applicant
    @track listOfAccounts;


    connectedCallback() {
        this.getApplicantData();
        this.getCourseEducationaFunction();
        this.getCoApplicant();
        this.loadTermsAndConditionsCheck();
       // this.getleadFileNames();
       // this.getAccFileNames();
        this.getRecord();
    }

    getApplicantData() {
        getApplicantData({ leadGetId: this.leadRecordId })
            .then(result => {
                
                this.wrapperForCommLeadForm = result;
                this.leadFirstName = this.wrapperForCommLeadForm.LeadRecords.FirstName;
                this.leadLastName = this.wrapperForCommLeadForm.LeadRecords.LastName;  
                this.leadAadharNumber = this.wrapperForCommLeadForm.LeadRecords.Aadhar_Number__c;
                this.PANNumber = this.wrapperForCommLeadForm.LeadRecords.PAN_Number__c;
                this.passportNumber = this.wrapperForCommLeadForm.LeadRecords.Passport_Number__c;
                this.passportFileNumber = this.wrapperForCommLeadForm.LeadRecords.Passport_File_Number__c;
                this.Driving_License_Number__c = this.wrapperForCommLeadForm.LeadRecords.Driving_License_Number__c;
                this.voterId = this.wrapperForCommLeadForm.LeadRecords.Voter_Id__c;
                this.CKYCNumber = this.wrapperForCommLeadForm.LeadRecords.CKYC_Number__c;
                this.NREGNumber = this.wrapperForCommLeadForm.LeadRecords.NREG_Number__c;

            })
            .catch(error => {
             console.log('Applicant Section found error => '+error);
            });    
    }

    getCourseEducationaFunction() {
        getCourseEducationaData({ leadGetId: this.leadRecordId })
            .then(result => {
                this.wrapperForCommLeadFormEducation = result;
                this.analyticalTestScore = this.wrapperForCommLeadFormEducation.LeadRecords.Analytics_Test_Score__c;
                this.quanTestScore = this.wrapperForCommLeadFormEducation.LeadRecords.Quantitative_Score__c;
                this.verbalTestScore = this.wrapperForCommLeadFormEducation.LeadRecords.Verbal_Score__c;
                this.langTestScore = this.wrapperForCommLeadFormEducation.LeadRecords.Language_Test_Score__c;

            })
            .catch(error => {
                console.log('Applicant Section found error => '+error);
            });
    }

    getCoApplicant() {

        getCoAppRecords({ leadId: this.leadRecordId })
            .then(result => {
                if (result.length > 0) {
                    this.listOfAccounts = JSON.parse(JSON.stringify(result));
                    console.log('###this.listOfAccounts===> ' + JSON.stringify(this.listOfAccounts));
                    
                    this.listOfAccounts.forEach(function (account) {

                        try {
                            if (account.objApplicant.Type__c == 'Co-applicant') {
                            }
                            if (account.objeAcc.FirstName != undefined) {

                            }
                            if (account.objeAcc.LastName != undefined) {                               
                            }

                            if (account.objeAcc.Aadhar_Number__c != undefined) {
                            }
                            
                            if (account.objeAcc.PAN_Number__c != undefined) {                            
                            }
                            if (account.objeAcc.Passport_Number__c != undefined) {
                            
                            }
                            if (account.objeAcc.Driving_License_Number__c != undefined) {
                            
                            }
                            if (account.objeAcc.Voter_ID__c != undefined) {
                            
                            }
                            if (account.objeAcc.CKYC_Number__c != undefined) {
                            
                            }
                            if (account.objeAcc.NREG_Number__c != undefined) {
                            
                            }
                        } catch (error) { 
                            console.log('Error while fetching Co-Applicant inside' + error);
                        }

                    });
                }
            }).catch(error => {
                console.log('Error while fetching Co-applicant Names from SF' + error);
            });
    }

    loadTermsAndConditionsCheck() {
        getTermsAndConditionsCheck({ leadId: this.recordId })
            .then(result => {
                this.isCheckedtnc = result;
            })
            .catch(error => {
                // Handle error, such as showing an error message
                console.error(error);
            });
    }

     /******Next button****/

    handleNext(event) {
        this.activeChild = event.detail.nextValue;
    }
    handleTabActivated(event) {
        const activeTabValue = event.target.value;
        this.activeChild = activeTabValue;
    }
    closeModaltnc() {
        this.tncModal = false;
    }
    openModalTnc() {
        this.tncModal = true;
    }

    handleFinalSubmit() {
        if(this.isCheckedtnc == false){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please check terms and condition',
                    variant: 'Error',
                }),
            );
        }else{
            updateTermsAndConditionsCheck({ leadId: this.recordId, isChecked: this.isCheckedtnc })
            .then(() => {
                // Handle success, such as showing a success message
                console.log('Lead updated successfully');
            })
            .catch(error => {
                // Handle error, such as showing an error message
                console.error(error);
            });

        getapplicantData({ leadGetId: this.recordId })
            .then(result => {
                debugger;
                this.wrapperForCommLeadForm = result;
                console.log('Account Lead Data', +this.wrapperForCommLeadForm);
                console.log(' dataaaaaa', JSON.stringify(this.wrapperForCommLeadForm));
                let coApplicants = this.wrapperForCommLeadForm.AccCoAppliRecords;
                console.log('Passport_Number__c', this.wrapperForCommLeadForm.LeadRecords.PAN_Number__c);
                for (var i in coApplicants) {
                    // if (coApplicants[i].PAN_Number__c) {
                    //     coApplicants[i].panAvailable = true; 
                    // }
                    // if (coApplicants[i].Aadhar_Number__c) {
                    //     coApplicants[i].aadharAvailable = true; 
                    // }
                    if (coApplicants[i].Account__r.PAN_Number__c != null || coApplicants[i].Account__r.PAN_Number__c != undefined) {
                        this.coAppliPan = true;
                    }
                    if (coApplicants[i].Account__r.Aadhar_Number__c != null) {
                        this.coAppliAadhar = true;
                    }
                    if (coApplicants[i].Account__r.Driving_License_Number__c != null) {
                        this.coAppliVoter = true;
                    }
                }
                if (this.wrapperForCommLeadForm.LeadRecords.PAN_Number__c != null) {
                    this.PANAvaialble = true;
                }
                if (this.wrapperForCommLeadForm.LeadRecords.Passport_Number__c != null) {
                    this.PassPortAvaialble = true;
                }
                if (this.wrapperForCommLeadForm.LeadRecords.Driving_License_Number__c != null) {
                    this.DLAvaialble = true;
                }
                if (this.wrapperForCommLeadForm.LeadRecords.Voter_Id__c != null) {
                    this.VoterIdAvaialble = true;
                }
            })
            .catch(error => {

            });

        if (this.wrapperForCommLeadForm != null) {
            console.log('INSIDE WRAPPER RESULT');

            console.log('this.PANAvaialble', this.PANAvaialble);
            console.log('doc6name' + this.doc6name);
            console.log('Record' + this.recordId);
            console.log('this.aadharFrontName', this.aadharFrontName);
            console.log('aadharBackName', this.aadharBackName);
            console.log('doc12name', this.doc12name);
            console.log('doc23name', this.doc23name);

            if (this.aadharFrontName == undefined || this.aadharFrontName == '' ||
                this.aadharBackName == undefined || this.aadharBackName == '' ||
                this.doc12name == undefined || this.doc12name == ''||
                ((this.doc23name == undefined || this.doc23name == '') && this.coAppliAadhar == true)
                ((this.doc28name == undefined || this.doc28name == '') && this.coAppliPan == true)
                ((this.doc29name == undefined || this.doc29name == '') && this.coAppliVoter == true)
            ) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Please upload required documents',
                        variant: 'Error',
                    }),
                );
            }

            else if ((this.doc23name == undefined || this.doc23name == '') && this.coAppliAadhar == true) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Please upload Aadhar',
                        variant: 'Error',
                    }),
                );
            }
            else if ((this.doc6name == undefined || this.doc6name == '') && this.PANAvaialble == true) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Please upload PAN',
                        variant: 'Error',
                    }),
                );
            }
            else if ((this.doc3name == undefined || this.doc3name == '' || this.doc4name == undefined || this.doc4name == '')
                && this.PassPortAvaialble == true) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Please upload Passport',
                        variant: 'Error',
                    }),
                );
            }
            else if ((this.doc9name == undefined || this.doc9name == '' || this.doc10name == undefined || this.doc10name == '')
                && this.DLAvaialble == true) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Please upload Driving License',
                        variant: 'Error',
                    }),
                );
            }
            else if ((this.doc7name == undefined || this.doc7name == '' || this.doc8name == undefined || this.doc8name == '')
                && this.VoterIdAvaialble == true) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Please upload Voter Id',
                        variant: 'Error',
                    }),
                );
            }
            else if ((this.doc28 == undefined || this.doc28 == '' || this.doc8name == undefined || this.doc8name == '')
                && this.coAppliPan == true) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Please upload PAN ',
                        variant: 'Error',
                    }),
                );
            }
            else {
                console.log('PAN NUMBER', this.wrapperForCommLeadForm.LeadRecords.PAN_Number__c);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success!!',
                        message: 'Successfully submitted',
                        variant: 'success',
                    }),
                );
            }

        }


       

    }
    }

    passRecordId() {
        this.sendIdToChild = this.recordId;
    }
    @track fileNamesLead;
    @track fileNamesAcc;

   
   

    handleFinalSubmit1() {
         if (this.isCheckedtnc == true) {
            console.log('documentcheck ' + this.documentCheck);
            if (this.documentCheck == false) {
                mandatoryDocumentCheck({ leadId: this.recordId })
                    .then(result => {
                        alert(result);
                        if (result === 'Success') {
                           
                        } else {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error!!',
                                    message: 'Please upload required documents',
                                    variant: 'Error',
                                }),
                            );
                        }
                    })
                    .catch(error => {
                    });
            }
            console.log("Submittting");
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please Agree to Terms and Condition',
                    variant: 'Error',
                }),
            );
        }
    }

    @api dmsNames;
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

    getRecord() {

        console.log('Lead Id', this.recordId);
        console.log('before calling getrecord method');

        getCoApplicant({ leadGetId: this.recordId })
            .then(result => {

                try {
                    // this.l_All_Types = data; 
                    let options = [];
                    let optionsisIncomeCon = [];
                    console.log('datatest2', result);
                    let newObj = [];
                    this.documentCheck = result[0].Lead__r.Document_Checked__c;

                    for (var gg in result) {
                        newObj.push({ value: result[gg].Id, type: result[gg].Type__c })
                        console.log("tryyyyy", newObj)
                    }

                    for (var key in result) {
                        // Here key will have index of list of records starting from 0,1,2,....
                        options.push({ label: result[key].Account__r.Name, value: result[key].Id, type: result[key].Type__c, accountId: result[key].Account__c, leadId: result[key].lead__c });
                        console.log('datatest3' + result[key].Account__r.Name + result[key].Id);
                        console.log('datatest33333', options);
                        // Here Name and Id are fields from sObject list.

                    }
                    let coApplicantCount = 0;
                    let guarantorCount = 0;
                    for (var i in options) {
                        if (options[i].type === "Guarantor") {
                            guarantorCount++;
                            options[i].index = guarantorCount;
                        }
                    }
                    for (var i in options) {
                        if (options[i].type === "Co-applicant") {
                            coApplicantCount++;
                            options[i].index = coApplicantCount;
                        }
                    }
                    this.TypeOptions = options;
                  

                  
                    console.log('this.TypeOptions======>  ' ,this.TypeOptions);

                    for (var keys in result) {
                        // Here key will have index of list of records starting from 0,1,2,....
                        optionsisIncomeCon.push({ label: result[keys].Name, value: result[keys].Lead__r.Is_Income_Considered_Is_Financial__c });
                        console.log('optionsisIncomeCondatatest4==>' + result[keys].Name + result[keys].Lead__r.Is_Income_Considered_Is_Financial__c);
                        // Here Name and Id are fields from sObject list.
                    }
                    this.isIncomeConsideroptions = optionsisIncomeCon;
                    console.log('this.isIncomeConsideroptions======>  ' + JSON.stringify(this.isIncomeConsideroptions));

                } catch (error) {
                    console.error('check error here', error);
                }
               

            }).catch(error => {
                console.log('Error while fetching Account Names from SF.');
            });

    }

    @track fileData = [];
    @track tempName;
    @track fileDataFront = false;
    openFrontfileUpload(event, fileName) {
        let file = event.target.files[0]
        let reader = new FileReader()
        reader.onload = () => {
            let base64 = reader.result.split(',')[1]
            console.log(base64);
            let fullName = fileName + file.type.split('/')[1];
            console.log('LEAD RECORD ID', this.recordId);
            console.log('LEAD  ID', this.lead_id);
            console.log('ACC  ID', this.accid);
            saveBase64File({
                leadId: this.recordId,
                // accountId:this.accid,
                base64File: base64,
                fileName: fullName,
            })
                .then(result => {
                    console.log('File saved successfully', result);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'File Uploaded Successfully',
                            variant: 'success',
                        })
                    );
                })
                .catch(error => {
                    console.error("error", error);
                    console.error(error.message);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Error Uploading File',
                            variant: 'error',
                        })
                    );
                });
            saveBase64FileAcc({
                // leadId:this.lead_id,
                accountId: this.accid,
                base64File: base64,
                fileName: fullName,
            })
                .then(result => {
                    console.log('File saved successfully', result);
                })
                .catch(error => {
                    console.error("error", error);
                });



            this.fileDataFront = true;
        }
        reader.onerror = () => {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'File Not Uploaded',
                variant: 'error',
            });
            this.dispatchEvent(event);
        };
        // Create a new file object with the renamed file
        const newFile = new File([file], fileName, { type: file.type });

        reader.readAsDataURL(newFile);
    }



    @track aadharTemp;
    @track apAadharback = false;
    aadharFrontName;
    aadharBackName;
    appdoc1 = false;
  //  @api percentage;
   // docPercentage = 0.7143;
    aadharFront(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.appdoc1 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi00000030ptMAA') {
                this.applicantAadhar = this.dmsNames[i].label;
            }
        }
        const fileName = this.applicantAadhar + ".";
        this.openFrontfileUpload(event, fileName);
        this.appdoc1 = true;
        this.aadharFrontName = file.name
      //  this.percentage = this.percentage + this.docPercentage;
    }
    }
    aadharBack(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.apAadharback = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi00000030ptMAA') {
                this.applicantAadhar = this.dmsNames[i].label;
            }
        }
        const fileName = this.applicantAadhar + ".";
        this.openFrontfileUpload(event, fileName);
        this.apAadharback = true;
        let file = event.target.files[0]
        this.aadharBackName = file.name;
     //   this.percentage = this.percentage + this.docPercentage;
    }
    }
    doc3;
    doc3name;
    applicantPass;
    passportFront(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.doc3 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi00000030rVMAQ') {
                this.applicantPass = this.dmsNames[i].label;
            }
        }
        const fileName = this.applicantPass + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc3 = true;
        let file = event.target.files[0]
        this.doc3name = file.name
     //   this.percentage = this.percentage + this.docPercentage;
    }
    }
    doc4;
    doc4name;
    passportBack(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.doc4 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi00000030rVMAQ') {
                this.applicantPass = this.dmsNames[i].label;
            }
        }
        const fileName = this.applicantPass + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc4 = true;
        let file = event.target.files[0]
        this.doc4name = file.name
     //   this.percentage = this.percentage + this.docPercentage;
    }
    }
    doc5;
    doc5name;
    visaApp(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.doc5 = false;
        }else{
        const fileName = "Visa_copy_App_1.";
        this.openFrontfileUpload(event, fileName);
        this.doc5 = true;
        let file = event.target.files[0]
        this.doc5name = file.name
    //    this.percentage = this.percentage + this.docPercentage;
        }
    }
    doc6;
    doc6name;
    applicantPan;
    panApp(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.doc6 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi00000030wLMAQ') {
                this.applicantPan = this.dmsNames[i].label;
            }
        }
        const fileName = this.applicantPan + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc6 = true;
        let file = event.target.files[0]
        this.doc6name = file.name
     //   this.percentage = this.percentage + this.docPercentage;
    }
    }
    doc7;
    doc7name;
    applicantVoter;
    voterFront(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.doc7 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi00000030ujMAA') {
                this.applicantVoter = this.dmsNames[i].label;
            }
        }
        const fileName = this.applicantVoter + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc7 = true;
        let file = event.target.files[0]
        this.doc7name = file.name
     //   this.percentage = this.percentage + this.docPercentage;
        }
    }
    doc8;
    doc8name;
    voterBack(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.doc8 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi00000030ujMAA') {
                this.applicantVoter = this.dmsNames[i].label;
            }
        }
        const fileName = this.applicantVoter + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc8 = true;
        let file = event.target.files[0]
        this.doc8name = file.name
     //   this.percentage = this.percentage + this.docPercentage;
    }
    }
    doc9;
    doc9name;
    applicantDl;
    dlFront(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.doc9 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi00000030t7MAA') {
                this.applicantDl = this.dmsNames[i].label;
            }
        }
        const fileName = this.applicantDl + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc9 = true;
        let file = event.target.files[0]
        this.doc9name = file.name
     //   this.percentage = this.percentage + this.docPercentage;
    }
    }
    doc10;
    doc10name;
    dlBack(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.doc10 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi00000030t7MAA') {
                this.applicantDl = this.dmsNames[i].label;
            }
        }
        const fileName = this.applicantDl + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc10 = true;
        let file = event.target.files[0]
        this.doc10name = file.name
     //   this.percentage = this.percentage + this.docPercentage;
    }}
    doc11;
    doc11name;
    bankStatementApplicant;
    bankStatementApp(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.doc11 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi00000031IvMAI') {
                this.bankStatementApplicant = this.dmsNames[i].label;
            }
        }
        const fileName = this.bankStatementApplicant + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc11 = true;
        let file = event.target.files[0]
        this.doc11name = file.name
    //    this.percentage = this.percentage + this.docPercentage;
    }
    }
    doc12;
    doc12name;
    photoApp(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.doc12 = false;
        }else{
        const fileName = "Photo_App_1.";
        this.openFrontfileUpload(event, fileName);
        this.doc12 = true;
        let file = event.target.files[0]
        this.doc12name = file.name;
    //    this.percentage = this.percentage + this.docPercentage;
        }
    }
    doc13;
    doc13name;
    incomeApplicant;
    incomeApp(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.doc13 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi00000031KXMAY') {
                this.incomeApplicant = this.dmsNames[i].label;
            }
        }
        const fileName = this.incomeApplicant + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc13 = true;
        let file = event.target.files[0]
        this.doc13name = file.name
     //   this.percentage = this.percentage + this.docPercentage;
    }
    }
    doc14;
    doc14name;
    otherApplicantDoc;
    otherApp1(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.doc14 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi00000031cHMAQ') {
                this.otherApplicantDoc = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherApplicantDoc + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc14 = true;
        let file = event.target.files[0]
        this.doc14name = file.name
     //   this.percentage = this.percentage + this.docPercentage;
    }
    }
    doc15;
    doc15name;
    otherApp2(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.doc15 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi00000031cHMAQ') {
                this.otherApplicantDoc = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherApplicantDoc + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc15 = true;
        let file = event.target.files[0]
        this.doc15name = file.name
     //   this.percentage = this.percentage + this.docPercentage;
    }
    }
    doc16;
    doc16name;
    otherApp3(event) { let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.doc16 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi00000031cHMAQ') {
                this.otherApplicantDoc = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherApplicantDoc + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc16 = true;
        let file = event.target.files[0]
        this.doc16name = file.name
     //   this.percentage = this.percentage + this.docPercentage;
    }
    }
    doc17;
    doc17name;
    sscdocapp;
    sscApp(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.doc17 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi00000031dtMAA') {
                this.sscdocapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.sscdocapp + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc17 = true;
        let file = event.target.files[0]
        this.doc17name = file.name
     //   this.percentage = this.percentage + this.docPercentage;
    }
    }
    consentEmail;
    consentEmailName;
    consentdocapp;
    emailConsent(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.consentEmail = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi0000003fMnMAI') {
                this.consentdocapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.consentdocapp + ".";
        this.openFrontfileUpload(event, fileName);
        this.consentEmail = true;
        let file = event.target.files[0]
        this.consentEmailName = file.name
     //   this.percentage = this.percentage + this.docPercentage;
    }
    }
    doc18;
    doc18name;
    hscdocapp;
    hscApp(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.doc18 = false;
        }else{

        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi00000031fVMAQ') {
                this.hscdocapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.hscdocapp + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc18 = true;
        let file = event.target.files[0]
        this.doc18name = file.name
     //   this.percentage = this.percentage + this.docPercentage;
    }
    }
    doc19;
    doc19name;
    graduationAppdoc;
    graduationApp(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.doc19= false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi00000031h7MAA') {
                this.graduationAppdoc = this.dmsNames[i].label;
            }
        }
        const fileName = this.graduationAppdoc + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc19 = true;
        let file = event.target.files[0]
        this.doc19name = file.name
     //   this.percentage = this.percentage + this.docPercentage;
    }}
    doc20;
    doc20name;
    otherGradapp;
    otherAppGradu(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.doc20 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi00000031AsMAI') {
                this.otherGradapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherGradapp + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc20 = true;
        let file = event.target.files[0]
        this.doc20name = file.name
     //   this.percentage = this.percentage + this.docPercentage;
    }}
    doc21;
    doc21name;
    testscoreapp;
    testScore(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.doc21 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi00000031FhMAI') {
                this.testscoreapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.testscoreapp + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc21 = true;
        let file = event.target.files[0]
        this.doc21name = file.name
     //   this.percentage = this.percentage + this.docPercentage;
    }}
    doc22;
    doc22name;
    anascoreapp;
    anaScore(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.doc22 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi00000031ijMAA') {
                this.anascoreapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.anascoreapp + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc22 = true;
        let file = event.target.files[0]
        this.doc22name = file.name
     //   this.percentage = this.percentage + this.docPercentage;
    }}
    //--------------Co-Applicants---------------//
    doc23;
    doc23name;
    aadharCoapp;
    aadharFront1(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.doc23 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi00000031M9MAI') {
                this.aadharCoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.aadharCoapp + this.coAppIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc23 = true;
        let file = event.target.files[0]
        this.doc23name = file.name
    //    this.percentage = this.percentage + this.docPercentage;
    }}
    doc24;
    doc24name;
    back1(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.doc24 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi00000031M9MAI') {
                this.aadharCoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.aadharCoapp + this.coAppIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc24 = true;
        let file = event.target.files[0]
        this.doc24name = file.name
    //    this.percentage = this.percentage + this.docPercentage;
    }}
    doc25;
    doc25name;
    passPortDoc;
    pass1(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.doc25 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi00000031NlMAI') {
                this.passPortDoc = this.dmsNames[i].label;
            }
        }
        const fileName = this.passPortDoc + this.coAppIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc25 = true;
        let file = event.target.files[0]
        this.doc25name = file.name
      //  this.percentage = this.percentage + this.docPercentage;
    }}
    doc26;
    doc26name;
    pass2(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.doc26 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi00000031NlMAI') {
                this.passPortDoc = this.dmsNames[i].label;
            }
        }
        const fileName = this.passPortDoc + this.coAppIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc26 = true;
        let file = event.target.files[0]
        this.doc26name = file.name
    //    this.percentage = this.percentage + this.docPercentage;
    }}
    doc27;
    doc27name;
    photo1(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.doc27 = false;
        }else{
        const fileName = "Photo_CoApp_" + this.coAppIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc27 = true;
        let file = event.target.files[0]
        this.doc27name = file.name
    //    this.percentage = this.percentage + this.docPercentage;
    }
    }
    doc28;
    doc28name;
    panCoapp;
    pan1(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.doc28 = false;
        }else{
        this.coAppliPan = false;
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi00000031SbMAI') {
                this.panCoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.panCoapp + this.coAppIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc28 = true;
        let file = event.target.files[0]
        this.doc28name = file.name
    //    this.percentage = this.percentage + this.docPercentage;
    }}
    doc29;
    doc29name;
    voterIdCoapp;
    vid1(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.doc29 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi00000031QzMAI') {
                this.voterIdCoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.voterIdCoapp + this.coAppIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc29 = true;
        let file = event.target.files[0]
        this.doc29name = file.name
    //    this.percentage = this.percentage + this.docPercentage;
    }}
    doc30;
    doc30name;
    vid2(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.doc30 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi00000031QzMAI') {
                this.voterIdCoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.voterIdCoapp + this.coAppIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc30 = true;
        let file = event.target.files[0]
        this.doc30name = file.name
     //   this.percentage = this.percentage + this.docPercentage;
    }}
    doc31;
    doc31name;
    bankCoapp;
    bank8(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.doc31 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi00000031afMAA') {
                this.bankCoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.bankCoapp + this.coAppIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc31 = true;
        let file = event.target.files[0]
        this.doc31name = file.name
    //    this.percentage = this.percentage + this.docPercentage;
    }}
    doc32;
    doc32name;
    otherincomecoapp;
    income1(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.doc32 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi00000031lxMAA') {
                this.otherincomecoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherincomecoapp + this.coAppIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc32 = true;
        let file = event.target.files[0]
        this.doc32name = file.name
    //    this.percentage = this.percentage + this.docPercentage;
    }}
    doc33;
    doc33name;
    ot11(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.doc33 = false;
        }else{
        const fileName = "other_doc1_CoApp_" + this.coAppIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc33 = true;
        let file = event.target.files[0]
        this.doc33name = file.name
    //    this.percentage = this.percentage + this.docPercentage;
    }}
    doc34;
    doc34name;
    ot22(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.doc34 = false;
        }else{
        const fileName = "other_doc2_CoApp_" + this.coAppIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc34 = true;
        let file = event.target.files[0]
        this.doc34name = file.name
    //    this.percentage = this.percentage + this.docPercentage;
    }}
    doc35;
    doc35name;
    ot33(event) {
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.doc35 = false;
        }else{
        const fileName = "other_doc3_CoApp_" + this.coAppIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc35 = true;
        let file = event.target.files[0]
        this.doc35name = file.name
     //   this.percentage = this.percentage + this.docPercentage;
    }}
     //---------------------for gurantor---------------//
     @track gdoc1name;
     @track gdoc2name;
     @track gdoc3name;
     @track gdoc4name;
     @track gdoc5name;
     @track gdoc6name;
     @track gdoc7name;
     @track gdoc8name;
     @track gdoc9name;
     @track gdoc10name;
     @track gdoc11name;
     @track gdoc12name;
     @track gdoc13name;
     @track gdoc1;
     @track gdoc2;
     @track gdoc3;
     @track gdoc4;
     @track gdoc5;
     @track gdoc6;
     @track gdoc7;
     @track gdoc7;
     @track gdoc8;
     @track gdoc9;
     @track gdoc10;
     @track gdoc11;
     @track gdoc12;
     @track gdoc13;
     gdoc1Aadhar(event){
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.gdoc1 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi0000003iPVMAY') {
                this.otherincomecoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherincomecoapp + '_'+this.GIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.gdoc1 = true;
        let file = event.target.files[0]
        this.gdoc1name = file.name
    //    this.percentage = this.percentage + this.docPercentage;
    }}
    gdoc2Aadharback(event){
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.gdoc2 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi0000003iPVMAY') {
                this.otherincomecoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherincomecoapp + '_'+this.GIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.gdoc2 = true;
        let file = event.target.files[0]
        this.gdoc2name = file.name
    //    this.percentage = this.percentage + this.docPercentage;
    }}
    gdoc3passport(event){
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.gdoc3 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi0000003iR7MAI') {
                this.otherincomecoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherincomecoapp + '_'+this.GIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.gdoc3 = true;
        let file = event.target.files[0]
        this.gdoc3name = file.name
    //    this.percentage = this.percentage + this.docPercentage;
    }}
    gdoc4passportback(event){
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.gdoc4 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi0000003iR7MAI') {
                this.otherincomecoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherincomecoapp + '_'+this.GIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.gdoc4 = true;
        let file = event.target.files[0]
        this.gdoc4name = file.name
    //    this.percentage = this.percentage + this.docPercentage;
    }}
    gdoc5photo(event){
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.gdoc5 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi0000003jDVMAY') {
                this.otherincomecoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherincomecoapp + '_'+this.GIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.gdoc5 = true;
        let file = event.target.files[0]
        this.gdoc5name = file.name
    //    this.percentage = this.percentage + this.docPercentage;
    }}
    gdoc6pan(event){
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.gdoc6 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi0000003ivlMAA') {
                this.otherincomecoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherincomecoapp + '_'+this.GIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.gdoc6 = true;
        let file = event.target.files[0]
        this.gdoc6name = file.name
    //    this.percentage = this.percentage + this.docPercentage;
    }}
    gdoc7vid(event){
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.gdoc7 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi0000003iULMAY') {
                this.otherincomecoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherincomecoapp + '_'+this.GIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.gdoc7 = true;
        let file = event.target.files[0]
        this.gdoc7name = file.name
    //    this.percentage = this.percentage + this.docPercentage;
    }}
    gdoc8vid2(event){
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.gdoc8 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi0000003iULMAY') {
                this.otherincomecoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherincomecoapp + '_'+this.GIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.gdoc8 = true;
        let file = event.target.files[0]
        this.gdoc8name = file.name
    //    this.percentage = this.percentage + this.docPercentage;
    }}
   
    gdoc9bank(event){
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.gdoc9 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi0000003j5RMAQ') {
                this.otherincomecoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherincomecoapp + '_'+this.GIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.gdoc9 = true;
        let file = event.target.files[0]
        this.gdoc9name = file.name
    //    this.percentage = this.percentage + this.docPercentage;
    }}
    gdoc10income(event){
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.gdoc10 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi0000003j73MAA') {
                this.otherincomecoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherincomecoapp + '_'+this.GIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.gdoc10 = true;
        let file = event.target.files[0]
        this.gdoc10name = file.name
    //    this.percentage = this.percentage + this.docPercentage;
    }}
    gdoc11ot(event){
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.gdoc11 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi0000003iyzMAA') {
                this.otherincomecoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherincomecoapp + '_'+this.GIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.gdoc11 = true;
        let file = event.target.files[0]
        this.gdoc11name = file.name
    //    this.percentage = this.percentage + this.docPercentage;
    }}
    gdoc12ot(event){
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.gdoc12 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi0000003j0bMAA') {
                this.otherincomecoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherincomecoapp + '_'+this.GIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.gdoc12 = true;
        let file = event.target.files[0]
        this.gdoc12name = file.name
    //    this.percentage = this.percentage + this.docPercentage;
    }}
    gdoc13ot(event){
        let file = event.target.files[0]
        const fileExtension = '.' + file.name.split('.').pop();
        console.log("exxtemsion "+fileExtension);
        if (!this.acceptedFormats.includes(fileExtension.toLowerCase())) {
            console.log("error");
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please upload file in .png ,.jpg, .jpeg and.pdf format',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.gdoc13 = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].id == 'm0RBi0000003j2DMAQ') {
                this.otherincomecoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherincomecoapp + '_'+this.GIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.gdoc13 = true;
        let file = event.target.files[0]
        this.gdoc13name = file.name
      //  this.percentage = this.percentage + this.docPercentage;
    }}
}