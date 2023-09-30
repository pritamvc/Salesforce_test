import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveBase64File from '@salesforce/apex/LoanApplicationFormHelper.saveBase64File';
import saveBase64FileAcc from '@salesforce/apex/LoanApplicationFormHelper.saveBase64FileAcc';
import getCoApplicant from '@salesforce/apex/LoanApplicationFormHelper.getleadWithApplicantsRec';
import getLeadPassportNum from '@salesforce/apex/LeadApplicantDetails.getLeadPassportNum';
import getAccountPassportNum from '@salesforce/apex/LeadApplicantDetails.getAccountPassportNum';
import getLeadOwnerInfo from '@salesforce/apex/LeadApplicantDetails.getLeadOwnerInfo';
import progressBar from '@salesforce/messageChannel/progressBar__c';
import SUBMITACTION from '@salesforce/messageChannel/submit__c';
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import getTermsAndConditionsCheck from '@salesforce/apex/ProgressBarPercent.getTermsAndConditionsCheck';
import updateTermsAndConditionsCheck from '@salesforce/apex/ProgressBarPercent.updateTermsAndConditionsCheck';
import updateLeadTotalPercentage from '@salesforce/apex/DocumentVerification.updateLeadTotalPercentage';
import mandatoryDocumentValidation from '@salesforce/apex/LeadDocument.mandatoryDocumentValidation';
import updateDocumentCheck from '@salesforce/apex/LeadDocument.updateDocumentCheck';
import getLeadWeightage from '@salesforce/apex/LeadDocument.getLeadWeightage';
import getFinancialCoApplicants from '@salesforce/apex/LeadDocument.getFinancialCoApplicants';
import getCheck from '@salesforce/apex/LeadCoapplicantEmploymentController.getCheck';
import getSectionWeightage from '@salesforce/apex/LoanApplicationFormHelper.getSectionWeightage';
import getFinancialCoApplicantsMobEmail from '@salesforce/apex/LeadApplicantDetails.getFinancialCoApplicants';
import createTask from '@salesforce/apex/LoanApplicationFormHelper.createTask';
import uploadPdfBinary from '@salesforce/apex/BankStatementAnalyzer.uploadBinaryPDF'
import getfinaltial from '@salesforce/apex/BankStatementAnalyzer.getIsIncomeConsideredFinancial'

export var PERCENTAGE = 0;
export default class DeveloperParentCommunityForm extends LightningElement {
    @track acceptedFormats = ['.png', '.pdf', '.jpg', '.jpeg'];
    @track isCheckedtnc = false;
    @api recordId;
    @api objectApiName;
    @track sendIdToChild;
    @track tncModal = false;
    //harsh
    @track password;
    @track fileName;
    //@api leadRecordId = this.recordId;

    @api getCourseData;
    @api getApplicantMobile;
    @api getApplicantEmail;
    @track financialCoApplicantMobile = [];
    @track financialCoApplicantEmail = [];

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
        this.connectedCallback();
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

    subscribeHndler() {
        subscribe(this.messageContext, SUBMITACTION, (message) => {
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
    @track errorMessageFromValidaton;
    @track submitfromvalidation = false;
    @track submitDisabled = false;
    @track missingSectionInfo = false;
    @track leadWeightagesubmit = false;
    @track getFinancialCoApplicant = false;
    @track getFinancialCoApplicantSubmit = false;

    //Method inserted by Vaibhav 23.05.2023
    handleFinalSubmit() {

        let errorMessageDisplayed = false;
        //This method to check doc validation;
        mandatoryDocumentValidation({ leadId: this.recordId })
            .then(result => {
                if (result != 'success') {
                    this.errorFromValidaton = true;
                    this.errorMessageFromValidaton = result;
                } else {
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
                if (result < 75) {
                    this.missingSectionInfo = true;
                    this.submitfromvalidation = false;
                } else {
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
                console.log('financial' + result);
                if (result == 0) {
                    this.getFinancialCoApplicant = true;
                    this.getFinancialCoApplicantSubmit = false;
                } else {
                    this.getFinancialCoApplicant = false;
                    this.getFinancialCoApplicantSubmit = true;
                }
            })
            .catch(error => {
                // Handle error, such as showing an error message
                console.error(error);
            });

        console.log('error test' + errorMessageDisplayed);
        if (this.missingSectionInfo) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!!',
                message: 'Please filled all section mandatory fields.',
                variant: 'Error'
            }));
        }
        else if (this.getFinancialCoApplicant && this.leadWeightagesubmit) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!!',
                message: 'Atleast one Financial  Co-Applicant/Guarantor is required.',
                variant: 'Error'
            }));
        }
        else if (this.isCheckedtnc == false && this.leadWeightagesubmit && this.getFinancialCoApplicantSubmit) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!!',
                message: 'Please check terms and condition',
                variant: 'Error'
            }));
        }
        else if (this.errorFromValidaton && this.leadWeightagesubmit && this.getFinancialCoApplicantSubmit) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!!',
                message: 'Please upload ' + this.errorMessageFromValidaton,
                variant: 'Error'
            }));
        }
        else if (this.submitfromvalidation && this.leadWeightagesubmit && this.getFinancialCoApplicantSubmit) {
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
            createTask({ leadId: this.recordId, callResult: 'finalSubmit' })
                .then(result => {
                    console.log('APPLICATION_FORMALITIES_COMPLETED ' + result);
                })
                .catch(error => {
                    console.error('APPLICATION_FORMALITIES_COMPLETED Error ' + error);
                });


            let sum;
            if (this.documentCheck == true) {
                sum = 0;
            }
            else {
                getSectionWeightage({ sectionName: 'Documents' })
                    .then(result => {
                        sum = result;
                        if (sum) {
                            let newPerc = sum;
                            console.log('Lead weightage' + newPerc);
                            updateLeadTotalPercentage({ leadId: this.recordId, percentage: newPerc })
                                .then(result => {
                                    let ProgrssValueOfLoanSection = { ProgrssValueOfLoanSection: result };
                                    publish(this.messageContext, progressBar, ProgrssValueOfLoanSection);
                                })
                                .catch(error => {
                                    console.error(error);
                                });
                        }
                    })


                updateDocumentCheck({ leadId: this.recordId, isCheck: true })
                    .then(result => {
                        this.documentCheck = result.Document_Checked__c;
                        console.log('Doc checked  ' + this.documentCheck);
                    })
            }
        }
    }
    //handleFinalSubmit commented by Vaibhav bcz for Validation messages comes from apex class

    // handleTabClick() {
    //     console.log('Call child component method');
    //     console.log('Only Record Id' +this.recordId);
    //     const childComponent = this.template.querySelector('c-employment-child');
    //     childComponent.callingFromParent();
    //   }

    /////// test logic
    connectedCallback() {
        this.passRecordId();
        this.getRecord();
        this.getLeadOwnerInfo();
        this.subscribeHndler();
        this.loadTermsAndConditionsCheck();
        getCheck({ leadId: this.recordId })
            .then(result => {
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

    @track isCheckedtnc = false;
    @track sendIdToChild;
    //@api leadRecordId = this.recordId;

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title, message, variant
            }),
        );
    }

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
        getCoApplicant({ leadGetId: this.recordId })
            .then(result => {
                try {
                    console.log('size' + result.length);
                    if (result.length > 0) {
                        this.submitDisabled = true;
                    }
                    // this.l_All_Types = data; 
                    let options = [];
                    let optionsisIncomeCon = [];
                    console.log('datatest2', result);
                    let newObj = [];
                   // this.documentCheck = result[0].Lead__r.Document_Checked__c;

                    for (var key in result) {
                        // Here key will have index of list of records starting from 0,1,2,....
                        options.push({ label: result[key].Account__r.Name, value: result[key].Id, type: result[key].Type__c, accountId: result[key].Account__c, leadId: result[key].Lead__c });
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
                    for (var keys in result) {
                        // Here key will have index of list of records starting from 0,1,2,....
                        optionsisIncomeCon.push({ label: result[keys].Name, value: result[keys].Lead__r.Is_Income_Considered_Is_Financial__c });
                        console.log('optionsisIncomeCondatatest4==>' + result[keys].Name + result[keys].Lead__r.Is_Income_Considered_Is_Financial__c);
                        // Here Name and Id are fields from sObject list.
                    }
                    this.isIncomeConsideroptions = optionsisIncomeCon;

                } catch (error) {
                    console.error('check error here', error);
                }
            }).catch(error => {
                console.log('Error while fetching Account Names from SF.');
            });

    }

    handleTypeChange(event) {
        this.value = event.target.value;
        //Show hide applicantNameAsset
        if (event.target.name === "applicantNameAsset" && event.target.value === "Yes") {
            this.ShowFieldsapplicantNameAssetIsIncome = true;
        }
        else {
            this.ShowFieldsapplicantNameAssetIsIncome = false;
        }

        //Show hide applicantNameLiabilities
        if (event.target.name === "applicantNameLiabilities" && event.target.value === "Yes") {
            this.ShowFieldsapplicantNameLiabilitiesIsIncome = true;
        }
        else {
            this.ShowFieldsapplicantNameLiabilitiesIsIncome = false;
           
        }
    }

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
    @track temApplicant;
    @track temCoApplicant;
    @track typeofapp;
    @track IdDoc;

    categoryChange(event) {
        for (var i in this.TypeOptions) {
            let newpost = this.TypeOptions[i].value
            if (event.target.value == this.TypeOptions[i].value) {
                this.typeofapp = this.TypeOptions[i].type
                this.IdDoc = this.TypeOptions[i].value
            }
        }
        if (this.typeofapp == "Applicant") {
            this.temApplicant = true;
        } else {
            this.temApplicant = false;
        }
        if (this.typeofapp == "Co-applicant") {
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
                accountId: this.accid,
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
                    //Create task Ready to Apply
                    createTask({ leadId: this.recordId, callResult: 'docSubmit' })
                        .then(result => {
                            console.log('Ready to Apply 1' + result);
                        })
                        .catch(error => {
                            console.error('Ready to Apply 2' + error);
                        });
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
                leadId: this.lead_id,
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

    bankStatement(event, fileName) {
        let file = event.target.files[0]
        this.openFrontfileUpload(event, fileName);
        let Is_Income_Considered_Financial;
        let reader = new FileReader();
        let fullName = fileName + file.type.split('/')[1];
        getfinaltial({
            leadId: this.recordId,
            accId: this.accid
        })
            .then(async (result) => {
                this.isLoading = false;
                Is_Income_Considered_Financial = result;
                if (Is_Income_Considered_Financial == 'Yes') {
                    //Don't delet this commented part
                    //password check
                    // if(this.password =='' || this.password==undefined)
                    // {
                    //     console.log('in if password=====>',this.password);
                    //     //this.showToast('Error', 'Please enter a password.', 'error');
                    //     this.dispatchEvent(
                    //         new ShowToastEvent({
                    //             title: 'Please enter a password.',
                    //             message: 'Please enter a password.',
                    //             variant: 'Error',
                    //         }),
                    //     );
                    // }
                    reader.onload = async () => {
                        let base64 = reader.result.split(',')[1];
                        if (this.password == '' || this.password == undefined) {
                            this.password = 'None';
                        }
                        uploadPdfBinary({
                            leadId: this.recordId,
                            accId: this.accid,
                            apiName: 'Upload PDF Binary',
                            base64PDFData: base64,
                            password: this.password,
                            fileName: fullName

                        })
                            .then(async (result) => {
                                this.isLoading = false;
                                let responseObj = JSON.parse(result);
                                var bankResponseStatus = responseObj.status;
                                var documentId = responseObj.docId;
                                if (responseObj.status === 'Submitted') {
                                    console.log("submitted");
                                }
                                else if (responseObj.status === 'Rejected') {
                                    this.dispatchEvent(
                                        new ShowToastEvent({
                                            title: 'Error!!',
                                            message: responseObj.message,
                                            variant: 'Error'
                                        }),
                                    );
                                }
                                else {
                                    console.log('responseObj.bankResponse', responseObj.bankResponse);
                                }


                            })

                    }
                    reader.onerror = function () {
                        console.log("Error occurred while reading file");
                    };

                    reader.onabort = function () {
                        console.log("File reading was aborted");
                    };

                    reader.readAsDataURL(file);
                }
                else {
                    var Note = 'If "Is_Income_Considered_Financial" is currently set to "NO," please update it to "YES".';
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!!',
                            message: Note,
                            variant: 'Error'
                        }),
                    );

                }
            })
    }


    @track toggler = false;
    @track Cotoggler = false;
    @track typeValue;
    @track coApp1Array;
    @track coApp2Array;
    @track coApp3Array;
    @track coApp4Array;
    @track Grntr1Array;
    @track Grntr2Array;
    coAppIndex;
    GIndex;
    accid;
    lead_id;
    @track allDoc;

    getTabPassportNoFunc(event) {
        this.getLeadData();
        this.handleTabActivated(event);
        this.getAccountPassportNumFunction();
    }
    getCoAppMobEmailWithHandleActive(event) {
        this.getFinancialCoApplicantMobileEmail();
        this.handleTabActivated(event);
    }

    getLeadData() {
        getLeadPassportNum({ leadGetId: this.recordId })
            .then(result => {
              //  this.getCourseData = result.Passport_Number__c;
                this.getApplicantMobile = result.MobilePhone;
                this.getApplicantEmail = result.Email;
                // refreshApex(this.getCourseData);         
            })
            .catch(error => {
            });
    }
    //Avadhut added for Account Passport Number - 03-Jul-23
    getAccountPassportNumFunction() {
        getAccountPassportNum({ leadGetId: this.recordId })
            .then(result => {
                console.log('getAccountPassportNumFunction',result)
                this.getCourseData = result.Account__r.Passport_Number__c;      
                console.log('this.getCourseData',this.getCourseData)              
            })
            .catch(error => {
            });
    }

    getFinancialCoApplicantMobileEmail() {
        this.financialCoApplicantMobile = [];
        this.financialCoApplicantEmail = [];
        getFinancialCoApplicantsMobEmail({ leadGetId: this.recordId })
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
                this.LeadOwnerName = result.Name;
                this.LeadOwnerMobile = result.MobilePhone;
            })
            .catch(error => {
            });
    }
}