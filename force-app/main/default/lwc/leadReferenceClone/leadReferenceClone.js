import { LightningElement, track, api, wire } from 'lwc';
import getReferenceAndAppList from '@salesforce/apex/LeadReferenceController.getReferenceAndAppList';
import getPincodeRecord from '@salesforce/apex/LeadReferenceController.getPincodeRecord';
import createReference from '@salesforce/apex/LeadReferenceController.createReferenceRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLeadTotalPercentage from '@salesforce/apex/DocumentVerification.getLeadTotalPercentage';
import updateLeadTotalPercentage from '@salesforce/apex/DocumentVerification.updateLeadTotalPercentage';
import progressBar from '@salesforce/messageChannel/progressBar__c';
import SUBMITACTION from '@salesforce/messageChannel/submit__c';
import { publish, MessageContext } from 'lightning/messageService';
import getSectionWeightage from '@salesforce/apex/LoanApplicationFormHelper.getSectionWeightage';
import getCheck from '@salesforce/apex/LeadCoapplicantEmploymentController.getCheck';
import updateReferenceCheck from '@salesforce/apex/LeadReferenceController.updateReferenceCheck';
import validateDocuments from '@salesforce/apex/ValidateDocumentUpload.validateDocuments';
import getFinancialCoApplicants from '@salesforce/apex/LeadDocument.getFinancialCoApplicants';
import getLeadWeightage from '@salesforce/apex/LeadDocument.getLeadWeightage';
import createTask from '@salesforce/apex/LoanApplicationFormHelper.createTask';
import updateDocumentCheck from '@salesforce/apex/LeadDocument.updateDocumentCheck';
export default class LeadReferences extends LightningElement {


    @api leadRecordId;
    @track isLoading = false;
    @track listOfReference;
    @track AreaPinCodeRef;
    @track AreaPinCodeResultRef;
    @track referenceCheck = false;
    @track missingSectionInfo = false;
    @track leadWeightagesubmit = false;
    @track getFinancialCoApplicant = false;
    @track getFinancialCoApplicantSubmit = false;
    @track submitfromvalidation = false;
    @track validationDoc = false;
    @track validationDocUpload;
    activeSectionName;

    //wire method used for messageChannel 
    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.getReferenceFunction();
        getCheck({ leadId: this.leadRecordId })
            .then(result => {
                this.referenceCheck = result.Reference_Section__c;
            })
    }

    handlechange(event) {
        //create a list and save the related record with considering dataset id is account id
        var foundelement = this.listOfReference.find(ele => ele.Account__c == event.target.dataset.id);
        if (event.target.name === 'Reference_First_Name__c') {
            foundelement.Reference_First_Name__c = event.target.value;
        } else if (event.target.name === 'Reference_Last_Name__c') {
            foundelement.Reference_Last_Name__c = event.target.value;
        } else if (event.target.name === 'Reference_Middle_Name__c') {
            foundelement.Reference_Middle_Name__c = event.target.value;
        } else if (event.target.name === 'Mobile_No__c') {
            foundelement.Mobile_No__c = event.target.value;
        } else if (event.target.name === 'Email_Id__c') {
            foundelement.Email_Id__c = event.target.value;
        } else if (event.target.name === 'Landline_No__c') {
            foundelement.Landline_No__c = event.target.value;
        } else if (event.target.name === 'Occupation__c') {
            foundelement.Occupation__c = event.target.value;
        } else if (event.target.name === 'Reference_Address_1__c') {
            foundelement.Reference_Address_1__c = event.target.value;
        } else if (event.target.name === 'Reference_Address_2__c') {
            foundelement.Reference_Address_2__c = event.target.value;
        } else if (event.target.name === 'Reference_Address_3__c') {
            foundelement.Reference_Address_3__c = event.target.value;
        } else if (event.target.name === 'City__c') {
            foundelement.City__c = event.target.value;
        } else if (event.target.name === 'District__c') {
            foundelement.District__c = event.target.value;
        } else if (event.target.name === 'State__c') {
            foundelement.State__c = event.target.value;
        } else if (event.target.name === 'Country__c') {
            foundelement.Country__c = event.target.value;
        } else if (event.target.name === 'Landmark__c') {
            foundelement.Landmark__c = event.target.value;
        }

    }
    handleRefPincode(event) {
        //create a list and save pincodes and related record record with considering dataset id is account id
        var foundelement1 = this.listOfReference.find(ele => ele.Account__c == event.target.dataset.id);
        if (event.target.name === 'Pin_Code__c') {
            foundelement1.Pin_Code__c = event.target.value;
            this.AreaPinCodeRef = foundelement1.Pin_Code__c;
        }
        if (this.AreaPinCodeRef == '') {
            foundelement1.Pin_Code__c = '';
            foundelement1.City__c = '';
            foundelement1.District__c = '';
            foundelement1.State__c = '';
            foundelement1.Country__c = '';
        } else {
            //call getPincodeRecord method this return the value of city,state,country,district and map
            getPincodeRecord({ pincode: this.AreaPinCodeRef })
                .then(result => {
                    this.AreaPinCodeResultRef = result;
                    foundelement1.Pin_Code__c = this.AreaPinCodeResultRef.Id;
                    foundelement1.City__c = this.AreaPinCodeResultRef.City_Name__c;
                    foundelement1.District__c = this.AreaPinCodeResultRef.Area_Name_Taluka__c;
                    foundelement1.State__c = this.AreaPinCodeResultRef.State__c;
                    foundelement1.Country__c = this.AreaPinCodeResultRef.Country__c;
                })
                .catch(error => {
                    this.errors = error;
                });
        }
    }
    getReferenceFunction() {
        // to send lead id and fetch Co-applicant and reference data related to this leadId 
        getReferenceAndAppList({ leadGetId: this.leadRecordId })
            .then(result => {
                if (result) {
                    this.listOfReference = JSON.parse(JSON.stringify(result));
                    if (this.listOfReference.length > 0) {

                        // modified the listOfReference list if Reference_First_Name__c is null then make this id is null For DML Purpose      
                        this.listOfReference = this.listOfReference.map(ref => {
                            console.log('$$$name ' + ref.Reference_First_Name__c);
                            if (!ref.Reference_First_Name__c) {
                                console.log('$$$name ' + ref.Reference_First_Name__c);
                                ref.Id = null;
                            }
                            if (ref.Reference_First_Name__c != undefined && this.firstCheck == false) {
                                console.log('$$$Data present');

                                //this.firstCheck = true;

                            }
                            return ref;
                        });
                        this.listOfReference = JSON.parse(JSON.stringify(this.listOfReference));
                    }
                }
            })
            .catch(error => {
            });

    }

    handleSaveReference() {
        var isError = false;

        if (this.listOfReference.length > 0) {
            //to check mand fields
            for (var i = 0; i < this.listOfReference.length; i++) {
                var record = this.listOfReference[i];
                if (record.Reference_First_Name__c == '' || record.Reference_First_Name__c == undefined) {
                    isError = true;
                }
            }
        }
        if (!isError) {
            this.isLoading = true;
            this.listOfReference.forEach(res => {
                if (!isNaN(res.Id)) {
                    res.Id = null;
                }
            });
            createReference({
                refRecordList: this.listOfReference,
                leadGetId: this.leadRecordId
            })
                .then(result => {
                    this.listOfReference = JSON.parse(JSON.stringify(result));
                    if (this.listOfReference.length > 0) {
                        this.listOfReference = JSON.parse(JSON.stringify(this.listOfReference));
                    }
                    this.isLoading = false;
                    const evt = new ShowToastEvent({
                        title: 'Reference',
                        message: 'Successfully Saved',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                }).catch(error => {
                    this.isLoading = false;
                    this.handleErrorMessage(error);
                })

        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please fill all the reference mandatory fields',
                    variant: 'Error',
                }),
            );
        }
    }

    handleNextReference() {
        var isError = false;

        if (this.listOfReference.length > 0) {
            //to check mand fields
            for (var i = 0; i < this.listOfReference.length; i++) {
                var record = this.listOfReference[i];
                if (record.Reference_First_Name__c == '' || record.Reference_First_Name__c == undefined) {
                    isError = true;
                }
                else if (record.Mobile_No__c == '' || record.Mobile_No__c == undefined) {
                    isError = true;
                }
                else if (record.Reference_Address_1__c == '' || record.Reference_Address_1__c == undefined) {
                    isError = true;
                }
                else if (record.Pin_Code__c == '' || record.Pin_Code__c == undefined) {
                    isError = true;
                }
                else if (record.Account__c == '' || record.Account__c == undefined) {
                    isError = true;
                }
            }
        }
        if (!isError) {
            this.isLoading = true;
            this.listOfReference.forEach(res => {
                if (!isNaN(res.Id)) {
                    res.Id = null;
                }
            });
            createReference({
                refRecordList: this.listOfReference,
                leadGetId: this.leadRecordId
            })
                .then(result => {
                    this.listOfReference = JSON.parse(JSON.stringify(result));
                    if (this.listOfReference.length > 0) {
                        this.listOfReference = JSON.parse(JSON.stringify(this.listOfReference));
                    }
                    this.isLoading = false;
                    //                     const evt = new ShowToastEvent({
                    //                         title: 'Reference',
                    //                         message: 'Successfully Saved',
                    //                         variant: 'success',
                    //                     });
                    //                     this.dispatchEvent(evt);

                    //send success msg to submit button 
                    let referenceSection = false;
                    publish(this.messageContext, SUBMITACTION, {
                        referenceSection: referenceSection
                    });
                    console.log('###Publishmsg is' + referenceSection);


                    console.log('### CHild CustomEvent' + this.nextbutton);
                    const onNextEvent = new CustomEvent('next', {
                        detail: {
                            nextValue: '9',
                        },
                    });
                    this.dispatchEvent(onNextEvent);
                    let sum;
                    if (this.referenceCheck == true) {
                        sum = 0;
                    }
                    else {
                        //Get the weightage for Reference Section
                        getSectionWeightage({ sectionName: 'Reference' })
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
                                            console.error(error);
                                        });
                                }
                            })
                        // sum = 10;
                        // this.firstCheck = true;

                        updateReferenceCheck({ leadId: this.leadRecordId, isCheck: true })
                            .then(result => {
                                this.referenceCheck = result.Reference_Section__c;
                            })
                    }
                }).catch(error => {
                    this.isLoading = false;
                    this.handleErrorMessage(error);
                })

            //Added By Rohit 20062023
            this.handleFinalSubmit();


        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please fill all the reference mandatory fields',
                    variant: 'Error',
                }),
            );
        }



    }

    handleSectionToggle(event) {
        const openSection = event.detail.openSections[0];

        if (openSection !== this.activeSectionName) {
            this.activeSectionName = openSection;

            const accordionSections = this.template.querySelectorAll('lightning-accordion-section');
            accordionSections.forEach((section) => {
                if (section.name !== this.activeSectionName) {
                    section.collapsed = true;
                }
            });
        }
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

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error!!',
                message: errorMessage,
                variant: 'Error',
            }),
        );
    }

    toastError(title) {
        const toastEvent = new ShowToastEvent({
            title,
            variant: "Error"
        })
        this.dispatchEvent(toastEvent);
    }

    async handleFinalSubmit() {
        debugger;
        console.log('INSDIE FINALA SUMBIT');

        const result = await validateDocuments({ leadRecordId: this.leadRecordId });

        if (result != null) {
            console.log('INSDIE FIRST IF');
            var error = result;
            this.validationDocUpload = result;
            this.validationDoc = true;
            // this.toastError(error);
        }
        console.log(result);

        const leadWeightageResult = await getLeadWeightage({ leadId: this.leadRecordId });
        if (leadWeightageResult < 75) {
            this.missingSectionInfo = true;
            this.submitfromvalidation = false;
        } else {
            this.missingSectionInfo = false;
            this.submitfromvalidation = true;
            this.leadWeightagesubmit = true;
        }

        const financialCoApplicantResult = await getFinancialCoApplicants({ leadId: this.leadRecordId });
        console.log('financial', financialCoApplicantResult);
        if (financialCoApplicantResult == 0) {
            this.getFinancialCoApplicant = true;
            this.getFinancialCoApplicantSubmit = false;
        } else {
            this.getFinancialCoApplicant = false;
            this.getFinancialCoApplicantSubmit = true;
        }

        console.log('this.validationDocUpload', this.validationDocUpload);
        console.log('this.validationDoc', this.validationDoc);
        if (this.missingSectionInfo) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!!',
                message: 'Please fill all section mandatory fields.',
                variant: 'Error'
            }));
        } else if (this.getFinancialCoApplicant && this.leadWeightagesubmit) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!!',
                message: 'At least one Financial Co-Applicant/Guarantor is required.',
                variant: 'Error'
            }));
        }
         else if (this.validationDoc) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!!',
                message: this.validationDocUpload,
                variant: 'Error'
            }));
        } else if (this.submitfromvalidation && this.leadWeightagesubmit && this.getFinancialCoApplicantSubmit) {
            console.log('submit');
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success!!',
                message: 'Successfully submitted',
                variant: 'success'
            }));

            //Create task APPLICATION_FORMALITIES_COMPLETED
            createTask({ leadId: this.leadRecordId, callResult: 'finalSubmit' })
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
                            updateLeadTotalPercentage({ leadId: this.leadRecordId, percentage: newPerc })
                                .then(result => {
                                    let ProgrssValueOfLoanSection = { ProgrssValueOfLoanSection: result };
                                    publish(this.messageContext, progressBar, ProgrssValueOfLoanSection);
                                })
                                .catch(error => {
                                    console.error(error);
                                });
                        }
                    })


                updateDocumentCheck({ leadId: this.leadRecordId, isCheck: true })
                    .then(result => {
                        this.documentCheck = result.Document_Checked__c;
                        console.log('Doc checked  ' + this.documentCheck);
                    })
            }
        }
    }

}