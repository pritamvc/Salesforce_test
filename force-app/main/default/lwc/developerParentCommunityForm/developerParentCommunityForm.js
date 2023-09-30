import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DMS_NAMES from '@salesforce/apex/LoanApplicationFormHelper.DMSNames';
import getleadWithApplicantsRecord from '@salesforce/apex/CommunityLeadFormController.getleadWithApplicantsRec';
import getapplicantData from '@salesforce/apex/QACommunityLeadFormController.getWrapperClassCommFormList';
import creatCommFormLeadRecords1 from '@salesforce/apex/CommunityLeadFormController.creatCommFormLeadRecord111';
import saveBase64File from '@salesforce/apex/CommunityLeadFormController.saveBase64File';
import saveBase64FileAcc from '@salesforce/apex/CommunityLeadFormController.saveBase64FileAcc';
import getCoApplicant from '@salesforce/apex/CommunityLeadFormController.getleadWithApplicantsRec';
import getLeadFileNames from '@salesforce/apex/DocumentVerification.getLeadFileNames';
import getAccountFileNames from '@salesforce/apex/DocumentVerification.getAccountFileNames';
import getCourseEducationaData from '@salesforce/apex/TempControllerSohail.getWrapperClassCommFormList';
import getLeadOwnerInfo from '@salesforce/apex/TempControllerSohail.getLeadOwnerInfo';
import mandatoryDocumentCheck from '@salesforce/apex/CheckDocumentUpload.mandatoryDocumentCheck';
import getLeadTotalPercentage from '@salesforce/apex/DocumentVerification.getLeadTotalPercentage';
import progressBar from '@salesforce/messageChannel/progressBar__c';
import SUBMITACTION from '@salesforce/messageChannel/submit__c';
import { publish,subscribe, MessageContext } from 'lightning/messageService';
import updateTermsAndConditionsCheck from '@salesforce/apex/ProgressBarPercent.updateTermsAndConditionsCheck';
import getTermsAndConditionsCheck  from '@salesforce/apex/ProgressBarPercent.getTermsAndConditionsCheck';
import mandatoryDocumentValidation  from '@salesforce/apex/LeadDocument.mandatoryDocumentValidation';
import updateDocumentCheck  from '@salesforce/apex/LeadDocument.updateDocumentCheck';
import getLeadWeightage  from '@salesforce/apex/LeadDocument.getLeadWeightage';
import getFinancialCoApplicants from '@salesforce/apex/LeadDocument.getFinancialCoApplicants';
import createTask from '@salesforce/apex/CommunityLeadFormController.createTask';
import getCheck  from '@salesforce/apex/LeadCoapplicantEmploymentController.getCheck';
import getSectionWeightage from '@salesforce/apex/LoanApplicationFormHelper.getSectionWeightage';
import updateLeadTotalPercentage from '@salesforce/apex/DocumentVerification.updateLeadTotalPercentage';
import getFinancialCoApplicantsMobEmail from '@salesforce/apex/QACommunityLeadFormController.getFinancialCoApplicants';
export var PERCENTAGE = 0;
export default class DeveloperParentCommunityForm extends LightningElement {
    @track acceptedFormats = ['.png', '.pdf', '.jpg', '.jpeg'];
    @track isCheckedtnc = false;
    @api recordId;
    @api objectApiName;
    @track sendIdToChild;
    @track tncModal = false;
    @track documentCheck = false;
    //@api leadRecordId = this.recordId;

    @api getCourseData;
    //@api getCountryOfStudy;
    @api getApplicantMobile;
    @api getApplicantEmail;
    @track financialCoApplicantMobile=[];
    @track financialCoApplicantEmail =[];

    @track activeChild = 1;
    @wire(MessageContext)
    messageContext;

    /******Next button****/

    
    handleNext(event) {
        this.activeChild = event.detail.nextValue;
        console.log('### handleNext===>' + this.activeChild);
    }
    
    @track activeTabLabel;
    handleTabActivated(event) {
        const activeTabValue = event.target.value;
        this.activeChild = activeTabValue;
        console.log('### ActiveChild11===>' + this.activeChild);
        console.log('### Active tab label111==>' + event.target.label);
        this.activeTabLabel=event.target.label;
        console.log('#####outside Label');
        if(event.target.label==='Documents'){
            this.getRecord();
            console.log('#####inside Label');
            this.connectedCallback();
        }

       
    
        // if(this.activeTabLabel === 'Applicant Details') {
        //     console.log('##### app child not IF')
        //     const childComponent = this.template.querySelector('c-dev-applicant-child');
        //     if (childComponent) {
        //         console.log('##### app child')
        //         childComponent.connectedCallback();
        //     }
        //     }
        //     else if(this.activeTabLabel === 'Loan Requirements') {
        //         console.log('#####activetabvalue inside loan if');
        //      const childComponentLoan =    this.template.querySelector('c-dev-loan-child')
        //         if (childComponentLoan) {
        //             console.log('######loan child')
        //            childComponentLoan.handleActive();
        //         }
        //     } 
    }
    
   

    /*****Message for submit*********/
    
    @track messageFields = {
        applicantSection: true,
        loanSection: true,
        courseandAcademicsSection: true,
        coApplicantSection: true,
        employmentSection: true,
        financialSection: true,
        collateralSection: true,
        referenceSection: true
    };

    subscribeHndler(){
        subscribe(this.messageContext,SUBMITACTION,(message)=>{
            this.messageFields = { ...this.messageFields, ...message };
        });
    }
    /*************/
    handleCheckboxChangetnc(event) {
        this.isCheckedtnc = event.target.checked;
        console.log('Checkbox is now ' + (this.isCheckedtnc ? 'checked' : 'unchecked'));
    }
    closeModaltnc() {
        this.tncModal = false;
    }
    openModalTnc() {
        this.tncModal = true;
    }

    @track PANAvaialble = false;
    @track PassPortAvaialble = false;
    @track DLAvaialble = false;
    @track VoterIdAvaialble = false;
    @track coAppliPan = false;
    @track coAppliAadhar = false;
    @track coAppliVoter = false;
    @track errorFromValidaton = false;
    @track submitfromvalidation = false;
    @track leadWeightagesubmit = false;
    @track errorMessageFromValidaton;
    @track submitDisabled = false;
    @track missingSectionInfo = false;
    @track leadWeightage;
    @track getFinancialCoApplicant = false;
    @track getFinancialCoApplicantSubmit = false;

  


    handleFinalSubmit() {
        let errorMessageDisplayed = false;
        //This method to check doc validation;
            mandatoryDocumentValidation({ leadId: this.recordId })
                .then(result => {
                    if(result !='success'){
                        this.errorFromValidaton= true;
                        this.errorMessageFromValidaton = result;
                    }else{
                        this.submitfromvalidation = true;
                        this.errorFromValidaton = false;
                    }
                })
                .catch(error => {
                    console.error(error);
                });
         //to check lead weightage 75%       
            getLeadWeightage({ leadId: this.recordId })
            .then(result => {
                if(result < 75 ){
                    this.missingSectionInfo = true;
                    this.submitfromvalidation = false;
                   }else{
                    this.missingSectionInfo = false;
                    this.submitfromvalidation = true;
                    this.leadWeightagesubmit = true;
                   }

            })
            .catch(error => {
                console.error(error);
            });
        // to check financial co-applicant
            getFinancialCoApplicants({ leadId: this.recordId })
            .then(result => {
                console.log('financial'+result);
                if(result == 0 ){
                    this.getFinancialCoApplicant = true;
                    this.getFinancialCoApplicantSubmit = false;
                }else{
                    this.getFinancialCoApplicant = false;
                    this.getFinancialCoApplicantSubmit = true;
                }
            })
            .catch(error => {
                // Handle error, such as showing an error message
                console.error(error);
            });

            

               

             console.log('error test'+errorMessageDisplayed);  
             if(this.missingSectionInfo){
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please filled all section mandatory fields.',
                    variant: 'Error'
                }));
            } 
            else if(this.getFinancialCoApplicant && this.leadWeightagesubmit){
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Required at list one Financial Co-applicant .',
                    variant: 'Error'
                }));
            }
            else if (this.isCheckedtnc == false && this.leadWeightagesubmit  && this.getFinancialCoApplicantSubmit) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please check terms and condition',
                    variant: 'Error'
                }));
            }
            else if (this.errorFromValidaton && this.leadWeightagesubmit  && this.getFinancialCoApplicantSubmit) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please upload ' + this.errorMessageFromValidaton,
                    variant: 'Error'
                }));
            }
                else if(this.submitfromvalidation && this.leadWeightagesubmit && this.getFinancialCoApplicantSubmit){
                    console.log('submit');
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success!!',
                        message: 'Successfully submitted',
                        variant: 'success'
                    }));
                    updateTermsAndConditionsCheck({
                        leadId: this.recordId,
                        isChecked: this.isCheckedtnc
                    }).then(() => {
                        console.log('Lead updated successfully');
                    }).catch(error => {
                        console.error(error);
                    });
                    //Create task APPLICATION_FORMALITIES_COMPLETED
                        createTask({ leadId: this.recordId })
                        .then(result => {
                            console.log('APPLICATION_FORMALITIES_COMPLETED '+result);
                        })
                        .catch(error => {
                            console.error('APPLICATION_FORMALITIES_COMPLETED Error '+error);
                        });
                
            
                let sum;
                if(this.documentCheck == true){
                    sum = 0;
                }
                else{
                    getSectionWeightage({sectionName:'Documents'})
                    .then(result=>{  
                        sum = result;
                        if(sum){
                            let newPerc = sum;
                            console.log('Lead weightage'+newPerc);
                            updateLeadTotalPercentage({ leadId: this.recordId, percentage: newPerc })
                                .then(result => {
                                    let ProgrssValueOfLoanSection = {ProgrssValueOfLoanSection:result };
                                    publish(this.messageContext, progressBar, ProgrssValueOfLoanSection);                               
                                })
                                .catch(error => {
                                    console.error(error);
                                });
                        }
                    }) 
                    
                   
                updateDocumentCheck({leadId:this.recordId,isCheck:true})
                .then(result=>{
                    this.documentCheck = result.Document_Checked__c;
                    console.log('Doc checked  '+this.documentCheck);
                })
                }  
           

        }
        
        //commented by Vaibhav bcz for Validation messages comes from apex class
        
     /*     
        else{
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success!!',
                message: 'Successfully submitted',
                variant: 'success',
            }),
        );
        updateTermsAndConditionsCheck({ leadId: this.recordId, isChecked: this.isCheckedtnc })
            .then(() => {
                // Handle success, such as showing a success message
                console.log('Lead updated successfully');
            })
            .catch(error => {
                // Handle error, such as showing an error message
                console.error(error);
            });
        
      
        else{
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
  
    } */
    }

    // handleTabClick() {
    //     console.log('Call child component method');
    //     console.log('Only Record Id' +this.recordId);
    //     const childComponent = this.template.querySelector('c-employment-child');
    //     childComponent.callingFromParent();
    //   }

    /////// test logic
    connectedCallback() { 
        this.getleadFileNames();
        this.getAccFileNames();
        this.passRecordId();
        this.getRecord();
        this.namesRenderDMS();
        this.getLeadOwnerInfo();
        this.subscribeHndler();
        this.loadTermsAndConditionsCheck();
        console.log('Record' + this.recordId);
        console.log('#####');
        getCheck({leadId:this.recordId})
        .then(result=>{
            this.documentCheck = result.Document_Checked__c;
        })
        
        
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
    passRecordId() {
        this.sendIdToChild = this.recordId;
    }
    @track fileNamesLead;
    @track fileNamesAcc;
    getleadFileNames() {
        getLeadFileNames({ leadId: this.recordId })
            .then(result => {
                this.fileNamesLead = result;
                console.log("document names get lead ========>", result);
                for (let i = 0; i < this.fileNamesLead.length; i++) {
                    if (this.fileNamesLead[i].includes("SSC_score_App_1")) {
                        console.log(this.fileNamesLead[i]);
                        this.doc17 = true;
                        this.doc17name = this.fileNamesLead[i];
                    } else if (this.fileNamesLead[i].includes("Aadhar_card_front_App_1")) {
                        this.appdoc1 = true;
                        this.aadharFrontName = this.fileNamesLead[i];
                    } else if (this.fileNamesLead[i].includes("Aadhar_card_back_App_1")) {
                        this.apAadharback = true;
                        this.aadharBackName = this.fileNamesLead[i];
                    } else if (this.fileNamesLead[i].includes("passport_front_App_1")) {
                        this.doc3 = true;
                        this.doc3name = this.fileNamesLead[i];
                    } else if (this.fileNamesLead[i].includes("passport_back_App_1")) {
                        this.doc4 = true;
                        this.doc4name = this.fileNamesLead[i];
                    } else if (this.fileNamesLead[i].includes("Visa_copy_App_1")) {
                        this.doc5 = true;
                        this.doc5name = this.fileNamesLead[i];
                    } else if (this.fileNamesLead[i].includes("Email_consent_App_1")) {
                        this.consentEmail = true;
                        this.consentEmailName = this.fileNamesLead[i];
                    } else if (this.fileNamesLead[i].includes("pan_card_App_1")) {
                        this.doc6 = true;
                        this.doc6name = this.fileNamesLead[i];
                    } else if (this.fileNamesLead[i].includes("voter_card_front_App_1")) {
                        this.doc7 = true;
                        this.doc7name = this.fileNamesLead[i];
                    } else if (this.fileNamesLead[i].includes("voter_card_back_App_1")) {
                        this.doc8 = true;
                        this.doc8name = this.fileNamesLead[i];
                    } else if (this.fileNamesLead[i].includes("Driving_license_front_App_1")) {
                        this.doc9 = true;
                        this.doc9name = this.fileNamesLead[i];
                    } else if (this.fileNamesLead[i].includes("Driving_license_back_App_1")) {
                        this.doc10 = true;
                        this.doc10name = this.fileNamesLead[i];
                    } else if (this.fileNamesLead[i].includes("Bank_statement_App_1")) {
                        this.doc11 = true;
                        this.doc11name = this.fileNamesLead[i];
                    } else if (this.fileNamesLead[i].includes("Photo_App_1")) {
                        this.doc12 = true;
                        this.doc12name = this.fileNamesLead[i];
                    } else if (this.fileNamesLead[i].includes("Other_income_prrof_App_1")) {
                        this.doc13 = true;
                        this.doc13name = this.fileNamesLead[i];
                    } else if (this.fileNamesLead[i].includes("Other_addtional_document_App_1")) {
                        this.doc14 = true;
                        this.doc14name = this.fileNamesLead[i];
                    } else if (this.fileNamesLead[i].includes("Other_addtional_document1_App_1")) {
                        this.doc15 = true;
                        this.doc15name = this.fileNamesLead[i];
                    } else if (this.fileNamesLead[i].includes("Other_addtional_document2_App_1")) {
                        this.doc16 = true;
                        this.doc16name = this.fileNamesLead[i];
                    } else if (this.fileNamesLead[i].includes("HSC_score_App_1")) {
                        this.doc18 = true;
                        this.doc18name = this.fileNamesLead[i];
                    } else if (this.fileNamesLead[i].includes("Graduation_score_App_1")) {
                        this.doc19 = true;
                        this.doc19name = this.fileNamesLead[i];
                    } else if (this.fileNamesLead[i].includes("Other_score_App_1")) {
                        this.doc20 = true;
                        this.doc20name = this.fileNamesLead[i];
                    } else if (this.fileNamesLead[i].includes("Test_score_App_1")) {
                        this.doc21 = true;
                        this.doc21name = this.fileNamesLead[i];
                    } else if (this.fileNamesLead[i].includes("Analytical_score_App_1")) {
                        this.doc22 = true;
                        this.doc22name = this.fileNamesLead[i];
                    }
                    else {
                        console.log("hi");
                    }
                }
            })
            .catch(error => {
                console.error(error);
            });
    }
    getAccFileNames() {
        getAccountFileNames({ accountId: this.recordId })
            .then(result => {
                this.fileNamesAcc = result;
                console.log("document names get Acc ========>", result);
            })
            .catch(error => {
                console.error(error);
            });
    }
    /////////////////////

    @track isCheckedtnc = false;
    @track sendIdToChild;
    //@api leadRecordId = this.recordId;

    handleCheckboxChangetnc(event) {
        this.isCheckedtnc = event.target.checked;
        console.log('Checkbox is now ' + (this.isCheckedtnc ? 'checked' : 'unchecked'));
    }
 
    loanData = []

    handleFinalSubmit1() {
        console.log('######');
        console.log( '###applicantSection msg==>' + this.messageFields.applicantSection);
        console.log( '###loanSection msg==>'+ this.messageFields.loanSection);
        console.log( '###courseandAcademics msg==>'+ this.messageFields.courseandAcademicsSection);
        console.log( '###coApplicantSection msg==>'+ this.messageFields.coApplicantSection);
        console.log( '###employmentSection msg==>'+ this.messageFields.employmentSection);
        console.log( '###financialSection msg==>'+ this.messageFields.financialSection);
        console.log( '###collateralSection msg==>'+ this.messageFields.collateralSection);
        console.log( '###referenceSection msg==>'+ this.messageFields.referenceSection);
        console.log('##Record' + this.recordId);
        console.log('######');
        console.log('######44');
        /**********/
        this.loanData = [];
        const loanComponents = this.template.querySelectorAll('c-dev-loan-child');
        console.log('###loan Section'+ JSON.stringify(loanComponents));
        loanComponents.forEach(loanComponent => {
        const loan = loanComponent.loanExpecTuitionFees;
        console.log('####Child loan Data:', loan);
        console.log('######11');
    // Log fetched data for each child component
       });
      console.log('######66');
         /*********/
         const loanComponentss = this.template.querySelector('c-dev-loan-child');
        console.log('###loan Section'+ JSON.stringify(loanComponentss) );
        loanComponentss.forEach(loanComponent => {
        const loan = loanComponent.loanExpecTuitionFees;
        console.log('####Child loan Data:', loan);
        console.log('##check');
    // Log fetched data for each child component
       });
      console.log('######check66');

        if(this.messageFields.applicantSection){
            this.showToast("Error!!","Please submit Applicant section information","Error")
                           }
        else if(this.messageFields.loanSection){
            this.showToast("Error!!","Please submit Loan Requirements information","Error")
                           }
        else if(this.messageFields.courseandAcademicsSection){
            this.showToast("Error!!","Please submit  Course and Academics information","Error")
                           }
        else if(this.messageFields.coApplicantSection){
            this.showToast("Error!!","Please submit Co-Applicant/Guarantor information","Error")
                           }
        else if(this.messageFields.employmentSection){
            this.showToast("Error!!","Please submit Employment & Business information","Error")
                           }
        else if(this.messageFields.financialSection){
            this.showToast("Error!!","Please submit Financial information","Error")
                           }
        else if(this.messageFields.collateralSection){
            this.showToast("Error!!","Please submit Collateral information","Error")
                           }
        else if(this.messageFields.referenceSection){
            this.showToast("Error!!","Please submit Reference information","Error")
                           }

        else if (this.isCheckedtnc == true) {
            console.log('documentcheck ' + this.documentCheck);
            if (this.documentCheck == false) {
                mandatoryDocumentCheck({ leadId: this.recordId })
                    .then(result => {
                        debugger;
                        alert(result);
                        if (result === 'Success') {
                            //alert(result);
                            getLeadTotalPercentage({ leadId: this.recordId })
                                .then(result => {
                                    console.log('Result:' + result);
                                    let ProgrssValueOfLoanSection = { ProgrssValueOfLoanSection: result };
                                    publish(this.messageContext, progressBar, ProgrssValueOfLoanSection);
                                })
                                .catch(error => {
                                    console.log(error)
                                })
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
    showToast(title,message,variant){
		this.dispatchEvent(
            new ShowToastEvent({
            title,message,variant  
				}),
            );
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

    // handleTabClick() {
    //     console.log('Call child component method');
    //     console.log('Only Record Id' +this.recordId);
    //     const childComponent = this.template.querySelector('c-employment-child');
    //     childComponent.callingFromParent();
    //   }

    /////// test logic
    // connectedCallback(){
    //     this.passRecordId();
    //     this.getRecord();
    //     console.log('Record' +this.recordId); 
    // }
    // passRecordId(){
    //     this.sendIdToChild = this.recordId;
    // }
    /////////////////////


    @track applicantLead;
    @track appliWithLeadId;
    @track AppliWithLeadName;
    @api secFive;
    @api secSix;
    @api secSeven;
    @api secEight;
    @api secNine;
    @api secTen;
    //From Parent 
    @api mydata;

    @api leadRecordId;

    //Show/Hide 
    @track ShowFieldsEmpTypeStud = false;
    @track ShowFieldsEmpTypeHomemaker = false;
    @track ShowFieldsEmpTypeSalaried = false;
    @track ShowFieldsEmpTypeSEP = false;
    @track ShowFieldsEmpTypeSENonP = false;
    @track ShowFieldsEmpTypeRetired = false;
    @track ShowFieldsapplicantNameAssetIsIncome = false;
    @track ShowFieldsapplicantNameLiabilitiesIsIncome = false;

    //Lead Picklist values 
    @api objectName = 'Lead';
    @api recordTypeId;
    //Local Authority Lead 
    @track localAuthority;
    @api localAuthorityField = 'Local_Authority__c';
    @track localAuthorityLabel;
    @api localAuthorityValue;
    @track localAuthorityOptions;
    apilocalAuthority;

    //Table Add/Delete section data list
    @track listOfEmploymentTable;
    @track listOfAssetTable;
    @track listOfLiabilitiesTable;
    // @track listOfLoanTable;
    @track listOfFinancialTable;
    @track listOfCollateralTable;
    @track listOfReferenceTable;
    @track documentTable;

    //Account Picklist values 
    @api recordTypeId1;
    @api objectNameAcc = 'Account';
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
    //Account Type from Account from SFDC
    @track AccTypePerAcc;
    @api AccTypePerAccField = 'Account_Type__c';
    @track AccTypePerAccLabel;
    @api AccTypePerAccValue;
    @track AccTypePerAccOptions;
    apiAccTypePerAcc;
    //Account Type from Account from SFDC
    @track AssetTypePerAcc;
    @api AssetTypePerAccField = 'Asset_Type__c';
    @track AssetTypePerAccLabel;
    @api AssetTypePerAccValue;
    @track AssetTypePerAccOptions;
    apiAssetTypePerAcc;
    //Account Type from Account from SFDC
    @track LoanTypePerAcc;
    @api LoanTypePerAccField = 'Loan_Type__c';
    @track LoanTypePerAccLabel;
    @api LoanTypePerAccValue;
    @track LoanTypePerAccOptions;
    apiLoanTypePerAcc;
    AppliCategoryvalue = '';
    @track duplicateAccountResult;

    get AppliCategoryOptions() {
        return [
            { label: 'Co-applicant', value: 'Co-applicant' },
            { label: 'Guarantor', value: 'Guarantor' },
        ];
    }

  
    @track TypeOptions;
    @track isIncomeConsideroptions;



    getRecord() {
 //debugger;
        console.log('Lead Id', this.recordId);
        console.log('before calling getrecord method');

        getCoApplicant({ leadGetId: this.recordId })
            .then(result => {

                try {
                    console.log('size'+ result.length);
                    if(result.length > 0){
                        this.submitDisabled = true;
                        console.log('size');
                       } 


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

  


    handleTypeChange(event) {
        this.value = event.target.value;
        console.log('==============this.value  ' + this.value);

        //Show hide applicantNameAsset
        if (event.target.name === "applicantNameAsset" && event.target.value === "Yes") {
            this.ShowFieldsapplicantNameAssetIsIncome = true;
            console.log("this.ShowFieldsapplicantNameAssetIsIncome====  " + this.ShowFieldsapplicantNameAssetIsIncome);
        }
        else {
            this.ShowFieldsapplicantNameAssetIsIncome = false;
            console.log("this.ShowFieldsapplicantNameAssetIsIncome====  " + this.ShowFieldsapplicantNameAssetIsIncome);
        }

        //Show hide applicantNameLiabilities
        if (event.target.name === "applicantNameLiabilities" && event.target.value === "Yes") {
            this.ShowFieldsapplicantNameLiabilitiesIsIncome = true;
            console.log("this.ShowFieldsapplicantNameLiabilitiesIsIncome====  " + this.ShowFieldsapplicantNameLiabilitiesIsIncome);
        }
        else {
            this.ShowFieldsapplicantNameLiabilitiesIsIncome = false;
            console.log("this.ShowFieldsapplicantNameLiabilitiesIsIncome====  " + this.ShowFieldsapplicantNameLiabilitiesIsIncome);
        }

    }

    //Aqeel code put 28-Feb Loan Section

    
    @track leadIDLoan;
    @track loanExpecTuitionFees;
    @track loanLivExpHostelFoodExp;
    @track loanTravelExp;
    @track loanOtherCost;
    @track loanTotalCostSum;
    @track loanOwnSource;
    @track loanScholarship;
    @track loanOtherFunds;
    @track loanTotalFunndsSum;
    @track loanLoanRequiredAB;
    @api percentageAll = 10;
    @track documentCheck = false;

    

    handleSaveLeadLoan() {
        let loanSecLeadSaveRec = {
            Id: this.leadIDLoan,
            Tuition_Fees__c: this.loanExpecTuitionFees,
            Living_Hostel_Food_Expenses__c: this.loanLivExpHostelFoodExp,
            Traveling_Expenses__c: this.loanTravelExp,
            Other_Costs__c: this.loanOtherCost,
            Total_Costs__c: this.loanTotalCostSum,
            Own_Source__c: this.loanOwnSource,
            Scholarship__c: this.loanScholarship,
            Others_Fund__c: this.loanOtherFunds,
            Total_Funds__c: this.loanTotalFunndsSum,
            Loan_Required_A_B__c: this.loanLoanRequiredAB
        }
        console.log('loanSecLeadSaveRec=====>' + JSON.stringify(loanSecLeadSaveRec));

        //Wrapper Class variable
        let wrapperCommFormRecord1 = {
            loanSectionLeadRec: JSON.stringify(loanSecLeadSaveRec)
        }
        console.log('wrapperCommFormRecord1 child=====>' + JSON.stringify(wrapperCommFormRecord1));

        creatCommFormLeadRecords1({
            wrapperCommFormDetails111: JSON.stringify(wrapperCommFormRecord1)
        })
            .then(response => {
                console.log(response);
                if (response != null) {
                    console.log('child response inside if=====>' + response);
                }
                this.isLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Successfully Saved',
                        variant: 'Success',
                    }),
                );
            }).catch(error => {
                console.log(error);
                this.isLoading = false;
            })
    }
    @track temApplicant;
    @track temCoApplicant;
    @track typeofapp;

    @track IdDoc;
    categoryChange(event) {
        console.log(event.target.value)
        console.log("gggggggggg   " + JSON.stringify(this.TypeOptions))

        for (var i in this.TypeOptions) {
            let newpost = this.TypeOptions[i].value
            console.log("hiiaaiaiaiiiiiiiiiiiiii " + newpost);
            if (event.target.value == this.TypeOptions[i].value) {
                this.typeofapp = this.TypeOptions[i].type
                this.IdDoc = this.TypeOptions[i].value
                console.log("fgfgfgfggf " + this.typeofapp)
                console.log("idddddddd " + this.IdDoc)
            }
        }
        if (this.typeofapp == "Applicant") {
            this.temApplicant = true;
            console.log("hello I am applicant");
        } else {
            this.temApplicant = false;
        }
        if (this.typeofapp == "Co-applicant") {
            console.log("hello I am coooo---applicant");
            this.temCoApplicant = true;
        } else {
            this.temCoApplicant = false;
        }
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
                accountId:this.accid,
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
            // saveBase64FileAcc({
            //     leadId:this.lead_id,
            //     accountId: this.accid,
            //     base64File: base64,
            //     fileName: fullName,
            // })
            //     .then(result => {
            //         console.log('File saved successfully', result);
            //     })
            //     .catch(error => {
            //         console.error("error", error);
            //     });



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
    @api percentage;
    docPercentage = 0.7143;
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
            if (this.dmsNames[i].applicantType== 'Applicant' && this.dmsNames[i].documentType=="Aadhar Front" ) {
                this.applicantAadhar = this.dmsNames[i].label;
            }
        }
        const fileName = this.applicantAadhar + ".";
        this.openFrontfileUpload(event, fileName);
        this.appdoc1 = true;
        this.aadharFrontName = file.name
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Applicant'  && this.dmsNames[i].documentType=="Aadhar Back" ) {
                this.applicantAadhar = this.dmsNames[i].label;
            }
        }
        const fileName = this.applicantAadhar + ".";
        this.openFrontfileUpload(event, fileName);
        this.apAadharback = true;
        let file = event.target.files[0]
        this.aadharBackName = file.name;
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Applicant' && this.dmsNames[i].documentType=="Passport Front") {
                this.applicantPass = this.dmsNames[i].label;
            }
        }
        const fileName = this.applicantPass + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc3 = true;
        let file = event.target.files[0]
        this.doc3name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Applicant' && this.dmsNames[i].documentType=="Passport Back") {
                this.applicantPass = this.dmsNames[i].label;
            }
        }
        const fileName = this.applicantPass + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc4 = true;
        let file = event.target.files[0]
        this.doc4name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Applicant' && this.dmsNames[i].documentType=="Pan") {
                this.applicantPan = this.dmsNames[i].label;
            }
        }
        const fileName = this.applicantPan + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc6 = true;
        let file = event.target.files[0]
        this.doc6name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Applicant' && this.dmsNames[i].documentType=="Voter Front") {
                this.applicantVoter = this.dmsNames[i].label;
            }
        }
        const fileName = this.applicantVoter + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc7 = true;
        let file = event.target.files[0]
        this.doc7name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Applicant' && this.dmsNames[i].documentType=="Voter Back") {
                this.applicantVoter = this.dmsNames[i].label;
            }
        }
        const fileName = this.applicantVoter + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc8 = true;
        let file = event.target.files[0]
        this.doc8name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Applicant' && this.dmsNames[i].documentType=="Driving Licence Front") {
                this.applicantDl = this.dmsNames[i].label;
            }
        }
        const fileName = this.applicantDl + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc9 = true;
        let file = event.target.files[0]
        this.doc9name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Applicant' && this.dmsNames[i].documentType=="Driving Licence Back") {
                this.applicantDl = this.dmsNames[i].label;
            }
        }
        const fileName = this.applicantDl + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc10 = true;
        let file = event.target.files[0]
        this.doc10name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Applicant' && this.dmsNames[i].documentType=="Bank Statement") {
                this.bankStatementApplicant = this.dmsNames[i].label;
            }
        }
        const fileName = this.bankStatementApplicant + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc11 = true;
        let file = event.target.files[0]
        this.doc11name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Applicant' && this.dmsNames[i].documentType=="Income") {
                this.incomeApplicant = this.dmsNames[i].label;
            }
        }
        const fileName = this.incomeApplicant + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc13 = true;
        let file = event.target.files[0]
        this.doc13name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Applicant' && this.dmsNames[i].documentType=="Other Document 1") {
                this.otherApplicantDoc = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherApplicantDoc + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc14 = true;
        let file = event.target.files[0]
        this.doc14name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Applicant' && this.dmsNames[i].documentType=="Other Document 2") {
                this.otherApplicantDoc = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherApplicantDoc + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc15 = true;
        let file = event.target.files[0]
        this.doc15name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Applicant' && this.dmsNames[i].documentType=="Other Document 3") {
                this.otherApplicantDoc = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherApplicantDoc + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc16 = true;
        let file = event.target.files[0]
        this.doc16name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Applicant' && this.dmsNames[i].documentType=="SSC") {
                this.sscdocapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.sscdocapp + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc17 = true;
        let file = event.target.files[0]
        this.doc17name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Applicant' && this.dmsNames[i].documentType=="Email Consent") {
                this.consentdocapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.consentdocapp + ".";
        this.openFrontfileUpload(event, fileName);
        this.consentEmail = true;
        let file = event.target.files[0]
        this.consentEmailName = file.name
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Applicant' && this.dmsNames[i].documentType=="HSC") {
                this.hscdocapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.hscdocapp + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc18 = true;
        let file = event.target.files[0]
        this.doc18name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Applicant' && this.dmsNames[i].documentType=="Graduation") {
                this.graduationAppdoc = this.dmsNames[i].label;
            }
        }
        const fileName = this.graduationAppdoc + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc19 = true;
        let file = event.target.files[0]
        this.doc19name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Applicant' && this.dmsNames[i].documentType=="Other Graduation") {
                this.otherGradapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherGradapp + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc20 = true;
        let file = event.target.files[0]
        this.doc20name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Applicant' && this.dmsNames[i].documentType=="Test Score") {
                this.testscoreapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.testscoreapp + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc21 = true;
        let file = event.target.files[0]
        this.doc21name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Applicant' && this.dmsNames[i].documentType=="Analytical Score") {
                this.anascoreapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.anascoreapp + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc22 = true;
        let file = event.target.files[0]
        this.doc22name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Co-Applicant' && this.dmsNames[i].documentType=="Aadhar Front") {
                this.aadharCoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.aadharCoapp + this.coAppIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc23 = true;
        let file = event.target.files[0]
        this.doc23name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Co-Applicant' && this.dmsNames[i].documentType=="Aadhar Back") {
                this.aadharCoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.aadharCoapp + this.coAppIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc24 = true;
        let file = event.target.files[0]
        this.doc24name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Co-Applicant' && this.dmsNames[i].documentType=="Passport Front") {
                this.passPortDoc = this.dmsNames[i].label;
            }
        }
        const fileName = this.passPortDoc + this.coAppIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc25 = true;
        let file = event.target.files[0]
        this.doc25name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Co-Applicant' && this.dmsNames[i].documentType=="Passport Back") {
                this.passPortDoc = this.dmsNames[i].label;
            }
        }
        const fileName = this.passPortDoc + this.coAppIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc26 = true;
        let file = event.target.files[0]
        this.doc26name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Co-Applicant' && this.dmsNames[i].documentType=="Pan") {
                this.panCoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.panCoapp + this.coAppIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc28 = true;
        let file = event.target.files[0]
        this.doc28name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Co-Applicant' && this.dmsNames[i].documentType=="Voter Front") {
                this.voterIdCoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.voterIdCoapp + this.coAppIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc29 = true;
        let file = event.target.files[0]
        this.doc29name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Co-Applicant' && this.dmsNames[i].documentType=="Voter Back") {
                this.voterIdCoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.voterIdCoapp + this.coAppIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc30 = true;
        let file = event.target.files[0]
        this.doc30name = file.name
        this.percentage = this.percentage + this.docPercentage;
    }}
    @track coDocDLfront
    @track coDocDLfrontName
    coDLfront(event) {
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
            this.coDocDLfront = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].applicantType== 'Co-Applicant' && this.dmsNames[i].documentType=="Driving Licence Front") {
                this.voterIdCoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.voterIdCoapp + this.coAppIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.coDocDLfront = true;
        let file = event.target.files[0]
        this.coDocDLfrontName = file.name
        this.percentage = this.percentage + this.docPercentage;
    }}
    @track coDocDLback
    @track coDocDLbackName
    coDLback(event) {
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
            this.coDocDLback = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].applicantType== 'Co-Applicant' && this.dmsNames[i].documentType=="Driving Licence Back") {
                this.voterIdCoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.voterIdCoapp + this.coAppIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.coDocDLback = true;
        let file = event.target.files[0]
        this.coDocDLbackName = file.name
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Co-Applicant' && this.dmsNames[i].documentType=="Bank Statement") {
                this.bankCoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.bankCoapp + this.coAppIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc31 = true;
        let file = event.target.files[0]
        this.doc31name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Co-Applicant' && this.dmsNames[i].documentType=="Income") {
                this.otherincomecoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherincomecoapp + this.coAppIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.doc32 = true;
        let file = event.target.files[0]
        this.doc32name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
        this.percentage = this.percentage + this.docPercentage;
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
        this.percentage = this.percentage + this.docPercentage;
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
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Guarantor' && this.dmsNames[i].documentType=="Aadhar Front") {
                this.otherincomecoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherincomecoapp + '_'+this.GIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.gdoc1 = true;
        let file = event.target.files[0]
        this.gdoc1name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Guarantor' && this.dmsNames[i].documentType=="Aadhar Back") {
                this.otherincomecoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherincomecoapp + '_'+this.GIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.gdoc2 = true;
        let file = event.target.files[0]
        this.gdoc2name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Guarantor' && this.dmsNames[i].documentType=="Passport Front") {
                this.otherincomecoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherincomecoapp + '_'+this.GIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.gdoc3 = true;
        let file = event.target.files[0]
        this.gdoc3name = file.name
        this.percentage = this.percentage + this.docPercentage;
    }}
    gdoc4passportback(event){
        debugger
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
            if (this.dmsNames[i].applicantType== 'Guarantor' && this.dmsNames[i].documentType=="Passport Back") {
                this.otherincomecoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherincomecoapp + '_'+this.GIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.gdoc4 = true;
        let file = event.target.files[0]
        this.gdoc4name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Guarantor' && this.dmsNames[i].documentType=="Pan") {
                this.otherincomecoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherincomecoapp + '_'+this.GIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.gdoc6 = true;
        let file = event.target.files[0]
        this.gdoc6name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Guarantor' && this.dmsNames[i].documentType=="Voter Front") {
                this.otherincomecoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherincomecoapp + '_'+this.GIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.gdoc7 = true;
        let file = event.target.files[0]
        this.gdoc7name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Guarantor' && this.dmsNames[i].documentType=="Voter Back") {
                this.otherincomecoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherincomecoapp + '_'+this.GIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.gdoc8 = true;
        let file = event.target.files[0]
        this.gdoc8name = file.name
        this.percentage = this.percentage + this.docPercentage;
    }}
   @track dlfgrntr
   @track dlfgrntrname
    dlfrontGrntr(event){
        
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
            this.dlfgrntr = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].applicantType== 'Guarantor' && this.dmsNames[i].documentType=="Driving Licence Front") {
                this.otherincomecoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherincomecoapp + '_'+this.GIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.dlfgrntr = true;
        let file = event.target.files[0]
        this.dlfgrntrname = file.name
        this.percentage = this.percentage + this.docPercentage;
    }}
    @track dlbgrntr
    @track dlbgrntrname
    dlbackgrntr(event){
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
            this.dlbgrntr = false;
        }else{
        for (var i in this.dmsNames) {
            if (this.dmsNames[i].applicantType== 'Guarantor' && this.dmsNames[i].documentType=="Driving Licence Back") {
                this.otherincomecoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherincomecoapp + '_'+this.GIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.dlbgrntr = true;
        let file = event.target.files[0]
        this.dlbgrntrname = file.name
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Guarantor' && this.dmsNames[i].documentType=="Bank Statement") {
                this.otherincomecoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherincomecoapp + '_'+this.GIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.gdoc9 = true;
        let file = event.target.files[0]
        this.gdoc9name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Guarantor' && this.dmsNames[i].documentType=="Income") {
                this.otherincomecoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherincomecoapp + '_'+this.GIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.gdoc10 = true;
        let file = event.target.files[0]
        this.gdoc10name = file.name
        this.percentage = this.percentage + this.docPercentage;
    }}
    gdoc11ot(event){
        debugger
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
            if (this.dmsNames[i].applicantType== 'Guarantor' && this.dmsNames[i].documentType=="Other Document 1") {
                this.otherincomecoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherincomecoapp + '_'+this.GIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.gdoc11 = true;
        let file = event.target.files[0]
        this.gdoc11name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Guarantor' && this.dmsNames[i].documentType=="Other Document 2") {
                this.otherincomecoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherincomecoapp + '_'+this.GIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.gdoc12 = true;
        let file = event.target.files[0]
        this.gdoc12name = file.name
        this.percentage = this.percentage + this.docPercentage;
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
            if (this.dmsNames[i].applicantType== 'Guarantor' && this.dmsNames[i].documentType=="Other Document 3") {
                this.otherincomecoapp = this.dmsNames[i].label;
            }
        }
        const fileName = this.otherincomecoapp + '_'+this.GIndex + ".";
        this.openFrontfileUpload(event, fileName);
        this.gdoc13 = true;
        let file = event.target.files[0]
        this.gdoc13name = file.name
        this.percentage = this.percentage + this.docPercentage;
    }}

    @track toggler = false;
    @track Cotoggler = false;
    @track typeValue;
    @track coApp1Array;
    @track coApp2Array;
    @track coApp3Array;
    @track Grntr1Array;
    @track Grntr2Array;
    coAppIndex;
    GIndex;
    accid;
    lead_id;
    @track allDoc;
    handleAccordionClick(event) {
        debugger;
        getAccountFileNames({ accountId: this.recordId })
        .then(result => {
            this.allDoc = result;
            console.log("FullDocument==", this.allDoc);
             this.coApp1Array = result.filter(item => item.includes('CoApp_1'));
             this.coApp2Array = result.filter(item => item.includes('CoApp_2'));
             this.coApp3Array = result.filter(item => item.includes('CoApp_3'));
             this.Grntr1Array = result.filter(item => item.includes('Grntr_1'));
             this.Grntr2Array = result.filter(item => item.includes('Grntr_2'));    
            
        })
        .catch(error => {
            console.error(error);
        });
        this.doc23 = false;
        this.doc24 = false;
        this.doc25 = false;
        this.doc26 = false;
        this.doc27 = false;
        this.doc28 = false;
        this.doc29 = false;
        this.doc30 = false;
        this.doc31 = false;
        this.doc32 = false;
        this.doc33 = false;
        this.doc34 = false;
        this.doc35 = false;
       
        console.log("======" + this.recordId);
        for (var i in this.TypeOptions) {    
            console.log("for each type", this.TypeOptions[i]);
            if (event.detail.openSections == this.TypeOptions[i].value) {
                if (this.TypeOptions[i].index == 1 && this.TypeOptions[i].type =="Co-applicant") {
                    for (var j in this.coApp1Array) {
                        console.log("coooo" + this.coApp1Array[j]);
                        if ((this.coApp1Array[j].includes("Aadhar"))&&(this.coApp1Array[j].includes("front"))) {
                            this.doc23 = true;
                            this.doc23name = this.coApp1Array[j];
                        } else if (this.coApp1Array[j].includes("Aadhar")&&this.coApp1Array[j].includes("back")) {
                            this.doc24 = true;
                            this.doc24name = this.coApp1Array[j];
                        } else if (this.coApp1Array[j].includes("pan")) {
                            this.doc28 = true;
                            this.doc28name = this.coApp1Array[j];
                        } else if (this.coApp1Array[j].includes("passport")&&this.coApp1Array[j].includes("front")) {
                            this.doc25 = true;
                            this.doc25name = this.coApp1Array[j];
                        } else if (this.coApp1Array[j].includes("passport")&&this.coApp1Array[j].includes("back")) {
                            this.doc26 = true;
                            this.doc26name = this.coApp1Array[j];
                        } else if (this.coApp1Array[j].includes("voter")&&this.coApp1Array[j].includes("front")) {
                            this.doc29 = true;
                            this.doc29name = this.coApp1Array[j];
                        } else if (this.coApp1Array[j].includes("voter")&&this.coApp1Array[j].includes("back")) {
                            this.doc30 = true;
                            this.doc30name = this.coApp1Array[j];
                        } else if (this.coApp1Array[j].includes("Driving")&&this.coApp1Array[j].includes("front")) {
                            this.coDocDLfront = true;
                            this.coDocDLfrontName = this.coApp1Array[j];
                        } else if (this.coApp1Array[j].includes("Driving")&&this.coApp1Array[j].includes("back")) {
                            this.coDocDLback = true;
                            this.coDocDLbackName = this.coApp1Array[j];
                            
                        } else if (this.coApp1Array[j].includes("Bank_statement")) {
                            this.doc31 = true;
                            this.doc31name = this.coApp1Array[j];
                        } else if (this.coApp1Array[j].includes("Other_income")) {
                            this.doc32 = true;
                            this.doc32name = this.coApp1Array[j];
                        } else if (this.coApp1Array[j].includes("Photo")) {
                            this.doc27 = true;
                            this.doc27name = this.coApp1Array[j];
                        } else if (this.coApp1Array[j].includes("other_doc1")) {
                            this.doc33 = true;
                            this.doc33name = this.coApp1Array[j];
                        } else if (this.coApp1Array[j].includes("other_doc2")) {
                            this.doc34 = true;
                            this.doc34name = this.coApp1Array[j];
                        } else if (this.coApp1Array[j].includes("other_doc3")) {
                            this.doc35 = true;
                            this.doc35name = this.coApp1Array[j];
                        }
                    }
                } else
                if (this.TypeOptions[i].index == 2 && this.TypeOptions[i].type =="Co-applicant") {
                    for (var j in this.coApp2Array) {
                        console.log("coooo" + this.coApp2Array[j]);
                        if ((this.coApp2Array[j].includes("Aadhar"))&&(this.coApp2Array[j].includes("front"))) {
                            this.doc23 = true;
                            this.doc23name = this.coApp2Array[j];
                        } else if (this.coApp2Array[j].includes("Aadhar")&&this.coApp2Array[j].includes("back")) {
                            this.doc24 = true;
                            this.doc24name = this.coApp2Array[j];
                        } else if (this.coApp2Array[j].includes("pan")) {
                            this.doc28 = true;
                            this.doc28name = this.coApp2Array[j];
                        } else if (this.coApp2Array[j].includes("passport")&&this.coApp2Array[j].includes("front")) {
                            this.doc25 = true;
                            this.doc25name = this.coApp2Array[j];
                        } else if (this.coApp2Array[j].includes("passport")&&this.coApp2Array[j].includes("back")) {
                            this.doc26 = true;
                            this.doc26name = this.coApp2Array[j];
                        } else if (this.coApp2Array[j].includes("voter")&&this.coApp2Array[j].includes("front")) {
                            this.doc29 = true;
                            this.doc29name = this.coApp2Array[j];
                        } else if (this.coApp2Array[j].includes("voter")&&this.coApp2Array[j].includes("back")) {
                            this.doc30 = true;
                            this.doc30name = this.coApp2Array[j];
                        } else if (this.coApp2Array[j].includes("Driving")&&this.coApp2Array[j].includes("front")) {
                            this.coDocDLfront = true;
                            this.coDocDLfrontName = this.coApp2Array[j];
                        } else if (this.coApp2Array[j].includes("Driving")&&this.coApp2Array[j].includes("back")) {
                            this.coDocDLback = true;
                            this.coDocDLbackName = this.coApp2Array[j];
                        } else if (this.coApp2Array[j].includes("Bank_statement")) {
                            this.doc31 = true;
                            this.doc31name = this.coApp2Array[j];
                        } else if (this.coApp2Array[j].includes("Other_income")) {
                            this.doc32 = true;
                            this.doc32name = this.coApp2Array[j];
                        } else if (this.coApp2Array[j].includes("Photo")) {
                            this.doc27 = true;
                            this.doc27name = this.coApp2Array[j];
                        } else if (this.coApp2Array[j].includes("other_doc1")) {
                            this.doc33 = true;
                            this.doc33name = this.coApp2Array[j];
                        } else if (this.coApp2Array[j].includes("other_doc2")) {
                            this.doc34 = true;
                            this.doc34name = this.coApp2Array[j];
                        } else if (this.coApp2Array[j].includes("other_doc3")) {
                            this.doc35 = true;
                            this.doc35name = this.coApp2Array[j];
                        }
                    }
                }else
                if (this.TypeOptions[i].index == 3 && this.TypeOptions[i].type =="Co-applicant") {
                    for (var j in this.coApp3Array) {
                        console.log("coooo" + this.coApp3Array[j]);
                        if ((this.coApp3Array[j].includes("Aadhar"))&&(this.coApp3Array[j].includes("front"))) {
                            this.doc23 = true;
                            this.doc23name = this.coApp3Array[j];
                        } else if (this.coApp3Array[j].includes("Aadhar")&&this.coApp3Array[j].includes("back")) {
                            this.doc24 = true;
                            this.doc24name = this.coApp3Array[j];
                        } else if (this.coApp3Array[j].includes("pan")) {
                            this.doc28 = true;
                            this.doc28name = this.coApp3Array[j];
                        } else if (this.coApp3Array[j].includes("passport")&&this.coApp3Array[j].includes("front")) {
                            this.doc25 = true;
                            this.doc25name = this.coApp3Array[j];
                        } else if (this.coApp3Array[j].includes("passport")&&this.coApp3Array[j].includes("back")) {
                            this.doc26 = true;
                            this.doc26name = this.coApp3Array[j];
                        } else if (this.coApp3Array[j].includes("voter")&&this.coApp3Array[j].includes("front")) {
                            this.doc29 = true;
                            this.doc29name = this.coApp3Array[j];
                        } else if (this.coApp3Array[j].includes("voter")&&this.coApp3Array[j].includes("back")) {
                            this.doc30 = true;
                            this.doc30name = this.coApp3Array[j];
                        } else if (this.coApp3Array[j].includes("Driving")&&this.coApp3Array[j].includes("front")) {
                            this.coDocDLfront = true;
                            this.coDocDLfrontName = this.coApp3Array[j];
                        } else if (this.coApp3Array[j].includes("Driving")&&this.coApp3Array[j].includes("back")) {
                            this.coDocDLback = true;
                            this.coDocDLbackName = this.coApp3Array[j];
                        } else if (this.coApp3Array[j].includes("Bank_statement")) {
                            this.doc31 = true;
                            this.doc31name = this.coApp3Array[j];
                        } else if (this.coApp3Array[j].includes("Other_income")) {
                            this.doc32 = true;
                            this.doc32name = this.coApp3Array[j];
                        } else if (this.coApp3Array[j].includes("Photo")) {
                            this.doc27 = true;
                            this.doc27name = this.coApp3Array[j];
                        } else if (this.coApp3Array[j].includes("other_doc1")) {
                            this.doc33 = true;
                            this.doc33name = this.coApp3Array[j];
                        } else if (this.coApp3Array[j].includes("other_doc2")) {
                            this.doc34 = true;
                            this.doc34name = this.coApp3Array[j];
                        } else if (this.coApp3Array[j].includes("other_doc3")) {
                            this.doc35 = true;
                            this.doc35name = this.coApp3Array[j];
                        }
                    }
                }else
                if (this.TypeOptions[i].index == 1 && this.TypeOptions[i].type =="Guarantor") {
                    console.log("Grntr1Array", this.Grntr1Array);                   
                    for (var j in this.Grntr1Array) {
                        console.log("coooo" + this.Grntr1Array[j]);
                        if ((this.Grntr1Array[j].includes("Aadhar"))&&(this.Grntr1Array[j].includes("front"))) {
                            this.gdoc1 = true;
                            this.gdoc1name = this.Grntr1Array[j];
                        } else if (this.Grntr1Array[j].includes("Aadhar")&&this.Grntr1Array[j].includes("back")) {
                            this.gdoc2 = true;
                            this.gdoc2name = this.Grntr1Array[j];
                        } else if (this.Grntr1Array[j].includes("pan")) {
                            this.gdoc6 = true;
                            this.gdoc6name = this.Grntr1Array[j];
                        } else if (this.Grntr1Array[j].includes("passport")&&this.Grntr1Array[j].includes("front")) {
                            this.gdoc3 = true;
                            this.gdoc3name = this.Grntr1Array[j];
                        } else if (this.Grntr1Array[j].includes("passport")&&this.Grntr1Array[j].includes("back")) {
                            this.gdoc4 = true;
                            this.gdoc4name = this.Grntr1Array[j];
                        } else if (this.Grntr1Array[j].includes("voter")&&this.Grntr1Array[j].includes("front")) {
                            this.gdoc7 = true;
                            this.gdoc7name = this.Grntr1Array[j];
                        } else if (this.Grntr1Array[j].includes("voter")&&this.Grntr1Array[j].includes("back")) {
                             this.gdoc8 = true;
                            this.gdoc8name = this.Grntr1Array[j];
                        } else if (this.Grntr1Array[j].includes("Driving")&&this.Grntr1Array[j].includes("front")) {
                             this.dlfgrntr = true;
                            this.dlfgrntrname = this.Grntr1Array[j];
                        } else if (this.Grntr1Array[j].includes("Driving")&&this.Grntr1Array[j].includes("back")) {
                             this.dlbgrntr = true;
                            this.dlbgrntrname = this.Grntr1Array[j];
                        } else if (this.Grntr1Array[j].includes("Bank_statement")) {
                            this.gdoc9 = true;
                            this.gdoc9name = this.Grntr1Array[j];
                        } else if (this.Grntr1Array[j].includes("Other_income")) {
                            this.gdoc10 = true;
                            this.gdoc10name = this.Grntr1Array[j];
                        } else if (this.Grntr1Array[j].includes("Photo")) {
                            this.gdoc5 = true;
                            this.gdoc5name = this.Grntr1Array[j];
                        } else if (this.Grntr1Array[j].includes("Document_1")) {
                            this.gdoc11 = true;
                            this.gdoc11name = this.Grntr1Array[j];
                        } else if (this.Grntr1Array[j].includes("Document_2")) {
                            this.gdoc12 = true;
                            this.gdoc12name = this.Grntr1Array[j];
                        } else if (this.Grntr1Array[j].includes("Document_3")) {
                            this.gdoc13 = true;
                            this.gdoc13name = this.Grntr1Array[j];
                        }
                    }
                }else
                if (this.TypeOptions[i].index == 2 && this.TypeOptions[i].type =="Guarantor") {
                    console.log("Grntr2Array", this.Grntr2Array);                    
                    for (var j in this.Grntr2Array) {
                        console.log("coooo" + this.Grntr2Array[j]);
                        if ((this.Grntr2Array[j].includes("Aadhar"))&&(this.Grntr2Array[j].includes("front"))) {
                            this.gdoc1 = true;
                            this.gdoc1name = this.Grntr2Array[j];
                        } else if (this.Grntr2Array[j].includes("Aadhar")&&this.Grntr2Array[j].includes("back")) {
                            this.gdoc2 = true;
                            this.gdoc2name = this.Grntr2Array[j];
                        } else if (this.Grntr2Array[j].includes("pan")) {
                            this.gdoc6 = true;
                            this.gdoc6name = this.Grntr2Array[j];
                        } else if (this.Grntr2Array[j].includes("passport")&&this.Grntr2Array[j].includes("front")) {
                            this.gdoc3 = true;
                            this.gdoc3name = this.Grntr2Array[j];
                        } else if (this.Grntr2Array[j].includes("passport")&&this.Grntr2Array[j].includes("back")) {
                            this.gdoc4 = true;
                            this.gdoc4name = this.Grntr2Array[j];
                        } else if (this.Grntr2Array[j].includes("voter")&&this.Grntr2Array[j].includes("front")) {
                            this.gdoc7 = true;
                            this.gdoc7name = this.Grntr2Array[j];
                        } else if (this.Grntr2Array[j].includes("voter")&&this.Grntr2Array[j].includes("back")) {
                            this.gdoc8 = true;
                            this.gdoc8name = this.Grntr2Array[j];
                        } else if (this.Grntr2Array[j].includes("Driving")&&this.Grntr2Array[j].includes("front")) {
                            this.dlfgrntr = true;
                           this.dlfgrntrname = this.Grntr2Array[j];
                       } else if (this.Grntr2Array[j].includes("Driving")&&this.Grntr2Array[j].includes("back")) {
                            this.dlbgrntr = true;
                           this.dlbgrntrname = this.Grntr2Array[j];
                        } else if (this.Grntr2Array[j].includes("Bank_statement")) {
                            this.gdoc9 = true;
                            this.gdoc9name = this.Grntr2Array[j];
                        } else if (this.Grntr2Array[j].includes("Other_income")) {
                            this.gdoc10 = true;
                            this.gdoc10name = this.Grntr2Array[j];
                        } else if (this.Grntr2Array[j].includes("Photo")) {
                            this.gdoc5 = true;
                            this.gdoc5name = this.Grntr2Array[j];
                        } else if (this.Grntr2Array[j].includes("Document_1")) {
                            this.gdoc11 = true;
                            this.gdoc11name = this.Grntr2Array[j];
                        } else if (this.Grntr2Array[j].includes("Document_2")) {
                            this.gdoc12 = true;
                            this.gdoc12name = this.Grntr2Array[j];
                        } else if (this.Grntr2Array[j].includes("Document_3")) {
                            this.gdoc13 = true;
                            this.gdoc13name = this.Grntr2Array[j];
                        }
                    }
                }
                console.log("inside if  ");
                this.typeValue = this.TypeOptions[i].value;
                if (this.TypeOptions[i].type === "Applicant") {
                    this.toggler = true;
                    console.log(this.TypeOptions[i].type);
                    this.accid = this.TypeOptions[i].accountId
                    this.lead_id = this.TypeOptions[i].value

                } else {
                    this.toggler = false;
                   
                }
                if (this.TypeOptions[i].type === "Co-applicant") {
                    this.Cotoggler = true;
                    console.log(this.TypeOptions[i].type);
                    this.coAppIndex = this.TypeOptions[i].index;
                    this.accid = this.TypeOptions[i].accountId
                    this.lead_id = this.TypeOptions[i].value
                } else {
                    this.Cotoggler = false;
                    
                }
                if (this.TypeOptions[i].type === "Guarantor") {
                    this.Guarantor = true;
                    console.log(this.TypeOptions[i].type);
                    this.GIndex = this.TypeOptions[i].index;
                    this.accid = this.TypeOptions[i].accountId
                    this.lead_id = this.TypeOptions[i].value
                } else {
                    this.Guarantor = false;
                   
                }
            }
        }
    }
  
    getTabPassportNoFunc(event){
        this.getCourseEduData();
        this.handleTabActivated(event);
    }
    getCoAppMobEmailWithHandleActive(event){
        this.getFinancialCoApplicantMobileEmail();
        this.handleTabActivated(event);
        this.getCourseEduData();
    }    

    getCourseEduData() {

        getCourseEducationaData({ leadGetId: this.recordId })
            .then(result => {
                debugger;
                // if(result.LeadRecords.Country_of_Study__c != ''){
                //     this.getCountryOfStudy = result.LeadRecords.Country_of_Study__c;
                // }                
                this.getCourseData = result.LeadRecords.Passport_Number__c;            
                
                this.getApplicantMobile = result.LeadRecords.MobilePhone;
                this.getApplicantEmail = result.LeadRecords.Email;                
            })
            .catch(error => {
            });
    }
    getFinancialCoApplicantMobileEmail(){
        this.financialCoApplicantMobile=[];
        this.financialCoApplicantEmail=[];
    getFinancialCoApplicantsMobEmail({ leadGetId : this.recordId })
    .then(result => {
      for (let i = 0; i < result.length; i++) {
        const mobileNumber = result[i].Account__r.PersonMobilePhone;
        const email = result[i].Account__r.Email__c;
        this.financialCoApplicantMobile.push(mobileNumber);
        this.financialCoApplicantEmail.push(email);
      }
    })
    .catch(error => {
      console.log('errors=======> ' + error);
    });
   }
    @track LeadOwnerName;
    @track LeadOwnerMobile;
    getLeadOwnerInfo() {
        getLeadOwnerInfo({ leadGetId: this.recordId })
            .then(result => {
                console.log('getLeadOwnerInfo result parent:', JSON.stringify(result));

                this.LeadOwnerName = result.Name;
                console.log('LeadOwnerName result parent:', this.LeadOwnerName);
                this.LeadOwnerMobile = result.MobilePhone;
                console.log('LeadOwnerMobile result parent:', this.LeadOwnerMobile);

            })
            .catch(error => {
            });
    }




}