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
import getTermsAndConditionsCheck  from '@salesforce/apex/ProgressBarPercent.getTermsAndConditionsCheck';
import updateTermsAndConditionsCheck from '@salesforce/apex/ProgressBarPercent.updateTermsAndConditionsCheck';

export var PERCENTAGE = 0;
export default class DeveloperParentCommunityForm extends LightningElement {
    @track acceptedFormats = ['.png', '.pdf', '.jpg', '.jpeg'];
    @track isCheckedtnc = false;
    @api recordId;
    @api objectApiName;
    @track sendIdToChild;
    @track tncModal = false;
    //@api leadRecordId = this.recordId;

    @api getCourseData;

    @track activeChild = 1;
    @wire(MessageContext)
    messageContext;

    /******Next button****/

    handleNext(event) {
        this.activeChild = event.detail.nextValue;
        console.log('### handleNext===>' + this.activeChild);
    }
    handleTabActivated(event) {
        const activeTabValue = event.target.value;
        this.activeChild = activeTabValue;
        console.log('### ActiveChild===>' + this.activeChild);
        console.log('### Active tab label==>' + event.target.label)
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


    handleFinalSubmit() {
        debugger
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
                    } else if (this.fileNamesLead[i].includes("Aadhar_card_App_1")) {
                        this.appdoc1 = true;
                        this.aadharFrontName = this.fileNamesLead[i];
                        this.apAadharback = true;
                        this.aadharBackName = this.fileNamesLead[i];
                    } else if (this.fileNamesLead[i].includes("passport_App_1")) {
                        this.doc3 = true;
                        this.doc3name = this.fileNamesLead[i];
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
                    } else if (this.fileNamesLead[i].includes("voter_card_App_1")) {
                        this.doc7 = true;
                        this.doc7name = this.fileNamesLead[i];
                        this.doc8 = true;
                        this.doc8name = this.fileNamesLead[i];
                    } else if (this.fileNamesLead[i].includes("Driving_license_App_1")) {
                        this.doc9 = true;
                        this.doc9name = this.fileNamesLead[i];
                        this.doc10 = true;
                        this.doc10name = this.fileNamesLead[i];
                    } else if (this.fileNamesLead[i].includes("Bank_statement_App_1")) {
                        this.doc11 = true;
                        this.doc11name = this.fileNamesLead[i];
                    } else if (this.fileNamesLead[i].includes("Photo_App_1")) {
                        this.doc12 = true;
                        this.doc12name = this.fileNamesLead[i];
                    } else if (this.fileNamesLead[i].includes("Other_income_proof_App_1")) {
                        this.doc13 = true;
                        this.doc13name = this.fileNamesLead[i];
                    } else if (this.fileNamesLead[i].includes("Other_addtional_document_App_1")) {
                        this.doc14 = true;
                        this.doc14name = this.fileNamesLead[i];
                        this.doc15 = true;
                        this.doc15name = this.fileNamesLead[i];
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

   

   

    initData() {
        let listOfEmploymentTable = [];
        this.createRowEmployment(listOfEmploymentTable);
        this.listOfEmploymentTable = listOfEmploymentTable;

        // let listOfLoanTable = [];
        // this.createRowLoan(listOfLoanTable);
        // this.listOfLoanTable = listOfLoanTable;

        let listOfFinancialTable = [];
        this.createRowFinancial(listOfFinancialTable);
        this.listOfFinancialTable = listOfFinancialTable;
        let documentTable = [];
        this.createRowFinancial(documentTable);
        this.documentTable = documentTable;

        let listOfAssetTable = [];
        this.createRowAsset(listOfAssetTable);
        this.listOfAssetTable = listOfAssetTable;

        let listOfLiabilitiesTable = [];
        this.createRowLiabilities(listOfLiabilitiesTable);
        this.listOfLiabilitiesTable = listOfLiabilitiesTable;

        let listOfCollateralTable = [];
        this.createRowCollateral(listOfCollateralTable);
        this.listOfCollateralTable = listOfCollateralTable;

        let listOfReferenceTable = [];
        this.createRowReference(listOfReferenceTable);
        this.listOfReferenceTable = listOfReferenceTable;
    }

    //Employment Table List for Add/Delete
    createRowEmployment(listOfEmploymentTable) {
        let EmploymentData = {};
        if (listOfEmploymentTable.length > 0) {
            EmploymentData.index = listOfEmploymentTable[listOfEmploymentTable.length - 1].index + 1;
            console.log("EmploymentData====>" + JSON.stringify(EmploymentData));
            console.log("listOfEmploymentTable====>" + JSON.stringify(listOfEmploymentTable));
        } else {
            EmploymentData.index = 1;
        }

        // this.ShowFieldsEmpTypeSalaried =false;
        EmploymentData.Asset_Type__c = null;
        EmploymentData.Asset_Value__c = null;
        EmploymentData.Asset_Description__c = null;
        listOfEmploymentTable.push(EmploymentData);
    }
    addNewRowEmployment() {
        this.createRowEmployment(this.listOfEmploymentTable);
        // this.ShowFieldsEmpTypeSalaried=false;
        console.log("Clickkkkkkkkkk")

    }
    removeTheRowEmployment(event) {
        let sum = 0;

        for (let i = 0; i < this.listOfEmploymentTable.length; i++) {
            sum += this.listOfEmploymentTable[i].index;
        }
        if (sum == 1) {
            console.log("Not Possible")
        } else {
            let toBeDeletedRowIndex = event.target.name;

            let listOfEmploymentTable = [];
            for (let i = 0; i < this.listOfEmploymentTable.length; i++) {
                let tempRecord = Object.assign({}, this.listOfEmploymentTable[i]); //cloning object
                if (tempRecord.index !== toBeDeletedRowIndex) {
                    listOfEmploymentTable.push(tempRecord);
                }
            }

            for (let i = 0; i < listOfEmploymentTable.length; i++) {
                listOfEmploymentTable[i].index = i + 1;
            }

            this.listOfEmploymentTable = listOfEmploymentTable;
        }
    }

    //Loan Details Table List for Add/Delete
    // createRowLoan(listOfLoanTable) {
    //     let LoanData = {};
    //     if (listOfLoanTable.length > 0) {
    //         LoanData.index = listOfLoanTable[listOfLoanTable.length - 1].index + 1;
    //     } else {
    //         LoanData.index = 1;
    //     }
    //     LoanData.Asset_Type__c = null;
    //     LoanData.Asset_Value__c = null;
    //     LoanData.Asset_Description__c = null;
    //     listOfLoanTable.push(LoanData);
    // }
    // addNewRowLoan() {
    //     this.createRowLoan(this.listOfLoanTable);
    // }
    // removeTheRowLoan(event) {
    //     let toBeDeletedRowIndex = event.target.name;

    //     let listOfLoanTable = [];
    //     for (let i = 0; i < this.listOfLoanTable.length; i++) {
    //         let tempRecord = Object.assign({}, this.listOfLoanTable[i]); //cloning object
    //         if (tempRecord.index !== toBeDeletedRowIndex) {
    //             listOfLoanTable.push(tempRecord);
    //         }
    //     }

    //     for (let i = 0; i < listOfLoanTable.length; i++) {
    //         listOfLoanTable[i].index = i + 1;
    //     }

    //     this.listOfLoanTable = listOfLoanTable;
    // }

    // Financial Details Table List for Add/Delete
    createRowFinancial(listOfFinancialTable) {
        let FinancialData = {};
        if (listOfFinancialTable.length > 0) {
            FinancialData.index = listOfFinancialTable[listOfFinancialTable.length - 1].index + 1;
        } else {
            FinancialData.index = 1;
        }
        FinancialData.Asset_Type__c = null;
        FinancialData.Asset_Value__c = null;
        FinancialData.Asset_Description__c = null;
        listOfFinancialTable.push(FinancialData);
    }
    addNewRowFinancial() {
        this.createRowFinancial(this.listOfFinancialTable);

    }
    removeTheRowFinancial(event) {
        let sum = 0;

        for (let i = 0; i < this.listOfFinancialTable.length; i++) {
            sum += this.listOfFinancialTable[i].index;
        }
        if (sum == 1) {
            console.log("Not Possible")
        } else {

            let toBeDeletedRowIndex = event.target.name;

            let listOfFinancialTable = [];
            for (let i = 0; i < this.listOfFinancialTable.length; i++) {
                let tempRecord = Object.assign({}, this.listOfFinancialTable[i]); //cloning object
                if (tempRecord.index !== toBeDeletedRowIndex) {
                    listOfFinancialTable.push(tempRecord);
                }
            }

            for (let i = 0; i < listOfFinancialTable.length; i++) {
                listOfFinancialTable[i].index = i + 1;
            }

            this.listOfFinancialTable = listOfFinancialTable;
        }
    }
    createRowDocument(documentTable) {
        let documentData = {};
        if (documentTable.length > 0) {
            documentData.index = documentTable[documentTable.length - 1].index + 1;
        } else {
            documentData.index = 1;
        }

        documentTable.push(documentData);
    }
    addNewRowDocument() {
        this.createRowDocument(this.documentTable);

    }
    removeTheRowDocument(event) {
        let sum = 0;

        for (let i = 0; i < this.documentTable.length; i++) {
            sum += this.documentTable[i].index;
        }
        if (sum == 1) {
            console.log("Not Possible")
        } else {

            let toBeDeletedRowIndex = event.target.name;

            let listOfDocumentTable = [];
            for (let i = 0; i < this.documentTable.length; i++) {
                let tempRecord = Object.assign({}, this.documentTable[i]); //cloning object
                if (tempRecord.index !== toBeDeletedRowIndex) {
                    listOfDocumentTable.push(tempRecord);
                }
            }

            for (let i = 0; i < listOfDocumentTable.length; i++) {
                listOfDocumentTable[i].index = i + 1;
            }

            this.documentTable = listOfDocumentTable;
        }
    }

    //Asset Table List for Add/Delete
    createRowAsset(listOfAssetTable) {
        let assetData = {};
        if (listOfAssetTable.length > 0) {
            assetData.index = listOfAssetTable[listOfAssetTable.length - 1].index + 1;
        } else {
            assetData.index = 1;
        }
        assetData.Asset_Type__c = null;
        assetData.Asset_Value__c = null;
        assetData.Asset_Description__c = null;
        listOfAssetTable.push(assetData);
    }
    addNewRowAsset() {
        this.createRowAsset(this.listOfAssetTable);
    }
    removeTheRowAsset(event) {
        let sum = 0;

        for (let i = 0; i < this.listOfAssetTable.length; i++) {
            sum += this.listOfAssetTable[i].index;
        }

        if (sum == 1) {
            console.log("Not Possible")

        } else {

            let toBeDeletedRowIndex = event.target.name;

            let listOfAssetTable = [];
            for (let i = 0; i < this.listOfAssetTable.length; i++) {
                let tempRecord = Object.assign({}, this.listOfAssetTable[i]); //cloning object
                if (tempRecord.index !== toBeDeletedRowIndex) {
                    listOfAssetTable.push(tempRecord);
                }
            }

            for (let i = 0; i < listOfAssetTable.length; i++) {
                listOfAssetTable[i].index = i + 1;
            }

            this.listOfAssetTable = listOfAssetTable;
        }
    }
    //Liabilities Table List for Add/Delete
    createRowLiabilities(listOfLiabilitiesTable) {
        let LiabilitiesData = {};
        if (listOfLiabilitiesTable.length > 0) {
            LiabilitiesData.index = listOfLiabilitiesTable[listOfLiabilitiesTable.length - 1].index + 1;
        } else {
            LiabilitiesData.index = 1;
        }
        LiabilitiesData.Asset_Type__c = null;
        LiabilitiesData.Asset_Value__c = null;
        LiabilitiesData.Asset_Description__c = null;
        listOfLiabilitiesTable.push(LiabilitiesData);
    }
    addNewRowLiabilities() {
        this.createRowAsset(this.listOfLiabilitiesTable);
    }
    removeTheRowLiabilities(event) {
        let sum = 0;

        for (let i = 0; i < this.listOfLiabilitiesTable.length; i++) {
            sum += this.listOfLiabilitiesTable[i].index;
        }
        if (sum == 1) {
            console.log("Not Possible")
        } else {

            let toBeDeletedRowIndex = event.target.name;

            let listOfLiabilitiesTable = [];
            for (let i = 0; i < this.listOfLiabilitiesTable.length; i++) {
                let tempRecord = Object.assign({}, this.listOfLiabilitiesTable[i]); //cloning object
                if (tempRecord.index !== toBeDeletedRowIndex) {
                    listOfLiabilitiesTable.push(tempRecord);
                }
            }

            for (let i = 0; i < listOfLiabilitiesTable.length; i++) {
                listOfLiabilitiesTable[i].index = i + 1;
            }

            this.listOfLiabilitiesTable = listOfLiabilitiesTable;
        }
    }

    //Collateral Table List for Add/Delete
    createRowCollateral(listOfCollateralTable) {
        let CollateralData = {};
        if (listOfCollateralTable.length > 0) {
            CollateralData.index = listOfCollateralTable[listOfCollateralTable.length - 1].index + 1;
        } else {
            CollateralData.index = 1;
        }
        CollateralData.Asset_Type__c = null;
        CollateralData.Asset_Value__c = null;
        CollateralData.Asset_Description__c = null;
        listOfCollateralTable.push(CollateralData);
    }
    addNewRowCollateral() {
        this.createRowCollateral(this.listOfCollateralTable);
    }
    removeTheRowCollateral(event) {
        let sum = 0;

        for (let i = 0; i < this.listOfCollateralTable.length; i++) {
            sum += this.listOfCollateralTable[i].index;
        }
        if (sum == 1) {
            console.log("Not Possible")
        } else {

            let toBeDeletedRowIndex = event.target.name;

            let listOfCollateralTable = [];
            for (let i = 0; i < this.listOfCollateralTable.length; i++) {
                let tempRecord = Object.assign({}, this.listOfCollateralTable[i]); //cloning object
                if (tempRecord.index !== toBeDeletedRowIndex) {
                    listOfCollateralTable.push(tempRecord);
                }
            }

            for (let i = 0; i < listOfCollateralTable.length; i++) {
                listOfCollateralTable[i].index = i + 1;
            }

            this.listOfCollateralTable = listOfCollateralTable;
        }
    }

    //Reference Table List for Add/Delete
    createRowReference(listOfReferenceTable) {
        let ReferenceData = {};
        if (listOfReferenceTable.length > 0) {
            ReferenceData.index = listOfReferenceTable[listOfReferenceTable.length - 1].index + 1;
        } else {
            ReferenceData.index = 1;
        }
        ReferenceData.Asset_Type__c = null;
        ReferenceData.Asset_Value__c = null;
        ReferenceData.Asset_Description__c = null;
        listOfReferenceTable.push(ReferenceData);
    }
    addNewRowReference() {
        this.createRowReference(this.listOfReferenceTable);
    }
    removeTheRowReference(event) {
        let sum = 0;

        for (let i = 0; i < this.listOfReferenceTable.length; i++) {
            sum += this.listOfReferenceTable[i].index;
        }
        if (sum == 1) {
            console.log("Not Possible")
        } else {

            let toBeDeletedRowIndex = event.target.name;

            let listOfReferenceTable = [];
            for (let i = 0; i < this.listOfReferenceTable.length; i++) {
                let tempRecord = Object.assign({}, this.listOfReferenceTable[i]); //cloning object
                if (tempRecord.index !== toBeDeletedRowIndex) {
                    listOfReferenceTable.push(tempRecord);
                }
            }

            for (let i = 0; i < listOfReferenceTable.length; i++) {
                listOfReferenceTable[i].index = i + 1;
            }

            this.listOfReferenceTable = listOfReferenceTable;
        }
    }
    handleEmploymentTypeSelect(event) {
        //TABLE TARGETS FORMAT
        let index = event.target.dataset.id;
        console.log('Index' + index);
        let fieldName = event.target.name;
        let value = event.target.value;
        console.log('value' + value);
        //Employment table handlechange
        // for(let i = 0; i < this.listOfEmploymentTable.length; i++) {
        //     if(this.listOfEmploymentTable[i].index === parseInt(index)) {
        //         this.listOfEmploymentTable[i][fieldName] = value;
        //         console.log("event.target.valueaaa====  " + this.listOfEmploymentTable[i][fieldName]);        
        //     }
        // }    
        console.log('fieldName' + fieldName);
        console.log('this.listOfEmploymentTable[index][fieldName]' + this.listOfEmploymentTable[index - 1]);
        this.listOfEmploymentTable[index - 1][fieldName] = value;
        console.log('this.listOfEmploymentTable[index][fieldName]' + this.listOfEmploymentTable[index - 1][fieldName]);
        //Show hide Salaried
        if (event.target.value === "Salaried") {
            this.ShowFieldsEmpTypeSalaried = true;
            console.log("this.ShowFieldsEmpTypeSalaried====  " + this.ShowFieldsEmpTypeSalaried);
            // console.log("indeeeexxxxx " + this.index);
        }
        else {
            this.ShowFieldsEmpTypeSalaried = false;
            console.log("this.ShowFieldsEmpTypeSalaried====  " + this.ShowFieldsEmpTypeSalaried);
        }

        // //Show hide Homemaker
        // if (event.target.value !=="Homemaker"){
        //     this.ShowFieldsEmpTypeStud = true;
        //     console.log("this.ShowFieldsEmpTypeStud====  " + this.ShowFieldsEmpTypeStud);
        // } 
        // else{
        //     this.ShowFieldsEmpTypeStud = false;
        //     console.log("this.ShowFieldsEmpTypeStud====  " + this.ShowFieldsEmpTypeStud);
        // }  

        // //Show hide Student
        // if (event.target.value !=="Student"){
        //     this.ShowFieldsEmpTypeHomemaker = true;
        //     console.log("this.ShowFieldsEmpTypeHomemaker====  " + this.ShowFieldsEmpTypeHomemaker);
        // } 
        // else{
        //     this.ShowFieldsEmpTypeHomemaker = false;
        //     console.log("this.ShowFieldsEmpTypeHomemaker====  " + this.ShowFieldsEmpTypeHomemaker);
        // }          

        //Show hide Self Employed Professional(SEP)
        if (event.target.value === "Self Employed Professional(SEP)") {
            this.ShowFieldsEmpTypeSEP = true;
            console.log("this.ShowFieldsEmpTypeSEP====  " + this.ShowFieldsEmpTypeSEP);
        }
        else {
            this.ShowFieldsEmpTypeSEP = false;
            console.log("this.ShowFieldsEmpTypeSEP====  " + this.ShowFieldsEmpTypeSEP);
        }

        //Show hide Self Employed Non Professional(SENP)
        if (event.target.value === "Self Employed Non Professional(SENP)") {
            this.ShowFieldsEmpTypeSENonP = true;
            console.log("this.ShowFieldsEmpTypeSENonP====  " + this.ShowFieldsEmpTypeSENonP);
        }
        else {
            this.ShowFieldsEmpTypeSENonP = false;
            console.log("this.ShowFieldsEmpTypeSENonP====  " + this.ShowFieldsEmpTypeSENonP);
        }

        //Show hide Retired
        if (event.target.value === "Retired") {
            this.ShowFieldsEmpTypeRetired = true;
            console.log("this.ShowFieldsEmpTypeRetired====  " + this.ShowFieldsEmpTypeRetired);
        }
        else {
            this.ShowFieldsEmpTypeRetired = false;
            console.log("this.ShowFieldsEmpTypeRetired====  " + this.ShowFieldsEmpTypeRetired);
        }
    }

    handleEmpTypeSalaried(event) {
        //TABLE TARGETS FORMAT
        let index = event.target.dataset.id;
        let fieldName = event.target.name;
        let value = event.target.value;

        //Employment table handlechange
        for (let i = 0; i < this.listOfEmploymentTable.length; i++) {
            if (this.listOfEmploymentTable[i].index === parseInt(index)) {
                this.listOfEmploymentTable[i][fieldName] = value;
                console.log("event.target.valueaaa====  " + this.listOfEmploymentTable[i][fieldName]);
            }
        }

    }

    handleEmpTypeSEP(event) {
        //TABLE TARGETS FORMAT
        let index = event.target.dataset.id;
        let fieldName = event.target.name;
        let value = event.target.value;

        //Employment table handlechange
        for (let i = 0; i < this.listOfEmploymentTable.length; i++) {
            if (this.listOfEmploymentTable[i].index === parseInt(index)) {
                this.listOfEmploymentTable[i][fieldName] = value;
                console.log("event.target.valueaaa====  " + this.listOfEmploymentTable[i][fieldName]);
            }
        }
    }

    handleEmpTypeSENP(event) {
        //TABLE TARGETS FORMAT
        let index = event.target.dataset.id;
        let fieldName = event.target.name;
        let value = event.target.value;

        //Employment table handlechange
        for (let i = 0; i < this.listOfEmploymentTable.length; i++) {
            if (this.listOfEmploymentTable[i].index === parseInt(index)) {
                this.listOfEmploymentTable[i][fieldName] = value;
                console.log("event.target.valueaaa====  " + this.listOfEmploymentTable[i][fieldName]);
            }
        }
    }

    handleEmpTypeRetired(event) {
        //TABLE TARGETS FORMAT
        let index = event.target.dataset.id;
        let fieldName = event.target.name;
        let value = event.target.value;

        //Employment table handlechange
        for (let i = 0; i < this.listOfEmploymentTable.length; i++) {
            if (this.listOfEmploymentTable[i].index === parseInt(index)) {
                this.listOfEmploymentTable[i][fieldName] = value;
                console.log("event.target.valueaaa====  " + this.listOfEmploymentTable[i][fieldName]);
            }
        }
    }

    handlechange(event) {

        //TABLE TARGETS FORMAT
        let index = event.target.dataset.id;
        let fieldName = event.target.name;
        let value = event.target.value;

        //Loan table handlechange
        // for (let i = 0; i < this.listOfLoanTable.length; i++) {
        //     if (this.listOfLoanTable[i].index === parseInt(index)) {
        //         this.listOfLoanTable[i][fieldName] = value;
        //         console.log("event.target.valueaaa====  " + this.listOfLoanTable[i][fieldName]);
        //     }
        // }

        //Financial table handlechange
        for (let i = 0; i < this.listOfFinancialTable.length; i++) {
            if (this.listOfFinancialTable[i].index === parseInt(index)) {
                this.listOfFinancialTable[i][fieldName] = value;
                console.log("event.target.valueaaa====  " + this.listOfFinancialTable[i][fieldName]);
            }
        }
        for (let i = 0; i < this.documentTable.length; i++) {
            if (this.documentTable[i].index === parseInt(index)) {
                this.documentTable[i][fieldName] = value;
                console.log("event.target.valueaaa====  " + this.documentTable[i][fieldName]);
            }
        }

        //Asset table handlechange
        for (let i = 0; i < this.listOfAssetTable.length; i++) {
            if (this.listOfAssetTable[i].index === parseInt(index)) {
                this.listOfAssetTable[i][fieldName] = value;
                console.log("event.target.valueaaa====  " + this.listOfAssetTable[i][fieldName]);
            }
        }

        //Liabilities table handlechange
        for (let i = 0; i < this.listOfLiabilitiesTable.length; i++) {
            if (this.listOfLiabilitiesTable[i].index === parseInt(index)) {
                this.listOfLiabilitiesTable[i][fieldName] = value;
                console.log("event.target.valueaaa====  " + this.listOfLiabilitiesTable[i][fieldName]);
            }
        }

        //Collateral table handlechange
        for (let i = 0; i < this.listOfCollateralTable.length; i++) {
            if (this.listOfCollateralTable[i].index === parseInt(index)) {
                this.listOfCollateralTable[i][fieldName] = value;
                console.log("event.target.valueaaa====  " + this.listOfCollateralTable[i][fieldName]);
            }
        }

        //Reference table handlechange
        for (let i = 0; i < this.listOfReferenceTable.length; i++) {
            if (this.listOfReferenceTable[i].index === parseInt(index)) {
                this.listOfReferenceTable[i][fieldName] = value;
                console.log("event.target.valueaaa====  " + this.listOfReferenceTable[i][fieldName]);
            }
        }


    }
    // @track applicantFieldLookField;
    // get applicantFieldLook() {
    //     return [
    //         { label: this.salutation + " "+ this.LfNName, value: this.salutation + " "+ this.LfNName },

    //     ];
    // }
    //  @track AppliWithLeadNameoptions;
    //  @track Picklist_Value;
    //@track l_All_Types;
    @track TypeOptions;
    @track isIncomeConsideroptions;



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
            if (this.dmsNames[i].id == 'm0RBi00000030ptMAA') {
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
            if (this.dmsNames[i].id == 'm0RBi00000030ptMAA') {
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
            if (this.dmsNames[i].id == 'm0RBi00000030rVMAQ') {
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
            if (this.dmsNames[i].id == 'm0RBi00000030rVMAQ') {
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
            if (this.dmsNames[i].id == 'm0RBi00000030wLMAQ') {
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
            if (this.dmsNames[i].id == 'm0RBi00000030ujMAA') {
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
            if (this.dmsNames[i].id == 'm0RBi00000030ujMAA') {
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
            if (this.dmsNames[i].id == 'm0RBi00000030t7MAA') {
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
            if (this.dmsNames[i].id == 'm0RBi00000030t7MAA') {
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
            if (this.dmsNames[i].id == 'm0RBi00000031IvMAI') {
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
            if (this.dmsNames[i].id == 'm0RBi00000031KXMAY') {
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
            if (this.dmsNames[i].id == 'm0RBi00000031cHMAQ') {
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
            if (this.dmsNames[i].id == 'm0RBi00000031cHMAQ') {
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
            if (this.dmsNames[i].id == 'm0RBi00000031cHMAQ') {
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
            if (this.dmsNames[i].id == 'm0RBi00000031dtMAA') {
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
            if (this.dmsNames[i].id == 'm0RBi0000003fMnMAI') {
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
            if (this.dmsNames[i].id == 'm0RBi00000031fVMAQ') {
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
            if (this.dmsNames[i].id == 'm0RBi00000031h7MAA') {
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
            if (this.dmsNames[i].id == 'm0RBi00000031AsMAI') {
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
            if (this.dmsNames[i].id == 'm0RBi00000031FhMAI') {
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
            if (this.dmsNames[i].id == 'm0RBi00000031ijMAA') {
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
            if (this.dmsNames[i].id == 'm0RBi00000031M9MAI') {
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
            if (this.dmsNames[i].id == 'm0RBi00000031M9MAI') {
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
            if (this.dmsNames[i].id == 'm0RBi00000031NlMAI') {
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
            if (this.dmsNames[i].id == 'm0RBi00000031NlMAI') {
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
            if (this.dmsNames[i].id == 'm0RBi00000031SbMAI') {
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
            if (this.dmsNames[i].id == 'm0RBi00000031QzMAI') {
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
            if (this.dmsNames[i].id == 'm0RBi00000031QzMAI') {
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
            if (this.dmsNames[i].id == 'm0RBi00000031lxMAA') {
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
            if (this.dmsNames[i].id == 'm0RBi0000003iPVMAY') {
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
            if (this.dmsNames[i].id == 'm0RBi0000003iPVMAY') {
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
            if (this.dmsNames[i].id == 'm0RBi0000003iR7MAI') {
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
            if (this.dmsNames[i].id == 'm0RBi0000003ivlMAA') {
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
            if (this.dmsNames[i].id == 'm0RBi0000003iULMAY') {
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
            if (this.dmsNames[i].id == 'm0RBi0000003iULMAY') {
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
            if (this.dmsNames[i].id == 'm0RBi0000003j73MAA') {
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
            if (this.dmsNames[i].id == 'm0RBi0000003j0bMAA') {
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
            if (this.dmsNames[i].id == 'm0RBi0000003j2DMAQ') {
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
        getAccountFileNames({ accountId: this.recordId })
        .then(result => {
            // debugger;
            this.allDoc = result;
            console.log("FullDocument==", this.allDoc);
             this.coApp1Array = result.filter(item => item.includes('CoApp_1'));
             this.coApp2Array = result.filter(item => item.includes('CoApp_2'));
             this.coApp3Array = result.filter(item => item.includes('CoApp_3'));
             this.Grntr1Array = result.filter(item => item.includes('Grntr_1'));
             this.Grntr2Array = result.filter(item => item.includes('Grntr_2'));
            // let appArray = result.filter(item => item.includes('App_1'));
            // console.log("co-app 1", coApp1Array);
            console.log("co-app 2", this.Grntr1Array);
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
        console.log("accordion click", this.TypeOptions);

        debugger
        console.log("this is new", event.detail.openSections);
        console.log("this is new", event.target.key);
        console.log("======" + this.recordId);
        for (var i in this.TypeOptions) {
debugger
            console.log("for each type", this.TypeOptions[i]);
            if (event.detail.openSections == this.TypeOptions[i].value) {
                if (this.TypeOptions[i].index == 1 && this.TypeOptions[i].type =="Co-applicant") {
                    for (var j in this.coApp1Array) {
                        console.log("coooo" + this.coApp1Array[j]);
                        if (this.coApp1Array[j].includes("Aadhar")) {
                            this.doc23 = true;
                            this.doc23name = this.coApp1Array[j];
                            this.doc24 = true;
                            this.doc24name = this.coApp1Array[j];
                        } else if (this.coApp1Array[j].includes("pan")) {
                            this.doc28 = true;
                            this.doc28name = this.coApp1Array[j];
                        } else if (this.coApp1Array[j].includes("passport")) {
                            this.doc25 = true;
                            this.doc25name = this.coApp1Array[j];
                            this.doc26 = true;
                            this.doc26name = this.coApp1Array[j];
                        } else if (this.coApp1Array[j].includes("voter")) {
                            this.doc29 = true;
                            this.doc29name = this.coApp1Array[j];
                            this.doc30 = true;
                            this.doc30name = this.coApp1Array[j];
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
                        if (this.coApp2Array[j].includes("Aadhar")) {
                            this.doc23 = true;
                            this.doc23name = this.coApp2Array[j];
                            this.doc24 = true;
                            this.doc24name = this.coApp2Array[j];
                        } else if (this.coApp2Array[j].includes("pan")) {
                            this.doc28 = true;
                            this.doc28name = this.coApp2Array[j];
                        } else if (this.coApp2Array[j].includes("passport")) {
                            this.doc25 = true;
                            this.doc25name = this.coApp2Array[j];
                            this.doc26 = true;
                            this.doc26name = this.coApp2Array[j];
                        } else if (this.coApp2Array[j].includes("voter")) {
                            this.doc29 = true;
                            this.doc29name = this.coApp2Array[j];
                            this.doc30 = true;
                            this.doc30name = this.coApp2Array[j];
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
                        if (this.coApp3Array[j].includes("Aadhar")) {
                            this.doc23 = true;
                            this.doc23name = this.coApp3Array[j];
                            this.doc24 = true;
                            this.doc24name = this.coApp3Array[j];
                        } else if (this.coApp3Array[j].includes("pan")) {
                            this.doc28 = true;
                            this.doc28name = this.coApp3Array[j];
                        } else if (this.coApp3Array[j].includes("passport")) {
                            this.doc25 = true;
                            this.doc25name = this.coApp3Array[j];
                            this.doc26 = true;
                            this.doc26name = this.coApp3Array[j];
                        } else if (this.coApp3Array[j].includes("voter")) {
                            this.doc29 = true;
                            this.doc29name = this.coApp3Array[j];
                            this.doc30 = true;
                            this.doc30name = this.coApp3Array[j];
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
                    // let grntrDoc = this.TypeOptions[i].document;
                    for (var j in this.Grntr1Array) {
                        console.log("coooo" + this.Grntr1Array[j]);
                        if (this.Grntr1Array[j].includes("Aadhar")) {
                            this.gdoc1 = true;
                            this.gdoc1name = this.Grntr1Array[j];
                            this.gdoc2 = true;
                            this.gdoc2name = this.Grntr1Array[j];
                        } else if (this.Grntr1Array[j].includes("pan")) {
                            this.gdoc6 = true;
                            this.gdoc6name = this.Grntr1Array[j];
                        } else if (this.Grntr1Array[j].includes("passport")) {
                            this.gdoc3 = true;
                            this.gdoc3name = this.Grntr1Array[j];
                            this.gdoc4 = true;
                            this.gdoc4name = this.Grntr1Array[j];
                        } else if (this.Grntr1Array[j].includes("voter")) {
                            this.gdoc7 = true;
                            this.gdoc7name = this.Grntr1Array[j];
                            this.gdoc8 = true;
                            this.gdoc8name = this.Grntr1Array[j];
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
                }
                if (this.TypeOptions[i].index == 2 && this.TypeOptions[i].type =="Guarantor") {
                    console.log("Grntr1Array", this.Grntr2Array);
                    // let grntrDoc = this.TypeOptions[i].document;
                    for (var j in this.Grntr2Array) {
                        console.log("coooo" + this.Grntr2Array[j]);
                        if (this.Grntr2Array[j].includes("Aadhar")) {
                            this.gdoc1 = true;
                            this.gdoc1name = this.Grntr2Array[j];
                            this.gdoc2 = true;
                            this.gdoc2name = this.Grntr2Array[j];
                        } else if (this.Grntr2Array[j].includes("pan")) {
                            this.gdoc6 = true;
                            this.gdoc6name = this.Grntr2Array[j];
                        } else if (this.Grntr2Array[j].includes("passport")) {
                            this.gdoc3 = true;
                            this.gdoc3name = this.Grntr2Array[j];
                            this.gdoc4 = true;
                            this.gdoc4name = this.Grntr2Array[j];
                        } else if (this.Grntr2Array[j].includes("voter")) {
                            this.gdoc7 = true;
                            this.gdoc7name = this.Grntr2Array[j];
                            this.gdoc8 = true;
                            this.gdoc8name = this.Grntr2Array[j];
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
    // handleTabset(event) {
    //     const tabValue = event.detail.value;
    //     console.log(`Tab ${tabValue} is now active.`);

    //     // perform any desired actions here
    // }
    
    getTabPassportNoFunc(event){
        this.getCourseEduData();
        this.handleTabActivated(event);
    }

    getCourseEduData() {

        getCourseEducationaData({ leadGetId: this.recordId })
            .then(result => {
                debugger;
                this.getCourseData = result.LeadRecords.Passport_Number__c;
                console.log('this.getCourseData parent:', this.getCourseData);
                // refreshApex(this.getCourseData);         
            })
            .catch(error => {
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