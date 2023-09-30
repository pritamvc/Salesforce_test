import { LightningElement, wire, api, track } from 'lwc';
import getWrapperClassApplicationForm from '@salesforce/apex/DealLeadLoanRequirements.getWrapperClassApplicationForm';
import saveUpdateLoanOnLead from '@salesforce/apex/DealLeadLoanRequirements.saveUpdateLoanOnLead';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateLeadTotalPercentage from '@salesforce/apex/DocumentVerification.updateLeadTotalPercentage';
import progressBar from '@salesforce/messageChannel/progressBar__c';
import { publish, MessageContext } from 'lightning/messageService';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import Opportunity from '@salesforce/schema/Opportunity';
import Repayment_Option from '@salesforce/schema/Opportunity.Repayment_Option__c';

export default class LeadDealLoanRequirements extends LightningElement {
    @api leadRecordId;
    @track isLoading = false;
    @wire(MessageContext)
    messageContext;
    message;

    @api leadIDLoan;
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

    @track expectedTuitionNotValid = false;
    @track livingExpensesNotValid = false;
    @track travellingExpensesNotValid = false;
    @track othersNotValid = false;
    @track ownSourceNotValid = false;
    @track scholarshipNotValid = false;
    @track otherFundsNotValid = false;
    @track repaymentvalue;
    @track loanTenure;
    @track loanTenureNotValid = false;

    @wire(getObjectInfo, { objectApiName: Opportunity })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Repayment_Option })
    RepaymentOption;
    
    connectedCallback() {
        this.getAllLoanDataFromLead();
    }

    handlechangeLoan(event) {
        if (event.target.name == 'ExpectedTuitionFees') {
            let fieldValue = event.target.value;
            let pattern = /^[1-9][0-9]*$/;
            if (!pattern.test(fieldValue) && fieldValue != '') {
                this.expectedTuitionNotValid = true;
            } else {
                this.loanExpecTuitionFees = event.target.value;
                this.expectedTuitionNotValid = false;
            }

        } 
        else if (event.target.name === 'Living Expenses/Hostel and Food') {
            let fieldValue = event.target.value;
            let pattern = /^[1-9][0-9]*$/;
            if (!pattern.test(fieldValue) && fieldValue != '') {
                this.livingExpensesNotValid = true;
            } 
            else {
                this.loanLivExpHostelFoodExp = event.target.value;
                this.livingExpensesNotValid = false;
            }
        } 
        else if (event.target.name === 'Travelling Expenses') {
            let fieldValue = event.target.value;
            let pattern = /^[1-9][0-9]*$/;
            if (!pattern.test(fieldValue) && fieldValue != '') {
                this.travellingExpensesNotValid = true;
            } 
            else {
                this.loanTravelExp = event.target.value;
                this.travellingExpensesNotValid = false;
            }
        }
        else if (event.target.name === 'Others') {
            let fieldValue = event.target.value;
            let pattern = /^[1-9][0-9]*$/;
            if (!pattern.test(fieldValue) && fieldValue != '') {
                this.othersNotValid = true;
            } 
            else {
                this.loanOtherCost = event.target.value;
                this.othersNotValid = false;
            }
        }
        else if(event.target.name === 'Repayment_Option__c'){
            this.repaymentvalue = event.target.value;
        }
        else if(event.target.name === 'Loan Tenure (Months)'){
            let fieldValue = event.target.value;
            let pattern =  /^(?!0+$)\d+$/;
            if (!pattern.test(fieldValue) && fieldValue != '') {
                this.loanTenureNotValid = true;
            } 
            else {
                this.loanTenure = event.target.value;
                this.loanTenureNotValid = false;
            }
        }

        this.total();
        this.calculateLoanRequired();
    }

    handlechangeFund(event) {
        if (event.target.name === 'Own Source') {
            let fieldValue = event.target.value;
            let pattern = /^[1-9][0-9]*$/;
            if (!pattern.test(fieldValue) && fieldValue != '') {
                this.ownSourceNotValid = true;
            } 
            else {
                this.loanOwnSource = event.target.value;
                this.ownSourceNotValid = false;
            }
        } 
        else if (event.target.name === 'Scholarship') {
            let fieldValue = event.target.value;
            let pattern = /^[1-9][0-9]*$/;
            if (!pattern.test(fieldValue) && fieldValue != '') {
                this.scholarshipNotValid = true;
            }
            else {
                this.loanScholarship = event.target.value;
                this.scholarshipNotValid = false;
            }
        } 
        else if (event.target.name === 'Other Funds') {
            let fieldValue = event.target.value;
            let pattern = /^[1-9][0-9]*$/;
            if (!pattern.test(fieldValue) && fieldValue != '') {
                this.otherFundsNotValid = true;
            } 
            else {
                this.loanOtherFunds = event.target.value;
                this.otherFundsNotValid = false;
            }
        }

        this.loanTotalFunndsSum = parseFloat(this.loanOwnSource || 0) + parseFloat(this.loanScholarship || 0)
            + parseFloat(this.loanOtherFunds || 0);
        this.calculateLoanRequired();
    }

    total() {
        var totalCost = parseFloat(this.loanExpecTuitionFees || 0) +
            parseFloat(this.loanLivExpHostelFoodExp || 0) +
            parseFloat(this.loanTravelExp || 0) +
            parseFloat(this.loanOtherCost || 0);
        if (this.loanExpecTuitionFees == '' || this.loanExpecTuitionFees == undefined) {
            this.loanTotalCostSum = '';
        } else {
            this.loanTotalCostSum = totalCost;
        }
    }

    calculateLoanRequired() {
        if (this.loanTotalCostSum == 0 && this.loanTotalFunndsSum == '') {
            this.loanLoanRequiredAB = 0;
        } else {
            this.loanLoanRequiredAB = this.loanTotalCostSum - this.loanTotalFunndsSum;
        }
    }

    getAllLoanDataFromLead() {
        getWrapperClassApplicationForm({ leadGetId: this.leadRecordId })
            .then(result => {
                this.wrapperForCommLeadForm = result;

                //Applicant Loan requirement on Lead  
                this.leadIDLoan = this.wrapperForCommLeadForm.leadLoanRecords.Id;                
                this.loanExpecTuitionFees = this.wrapperForCommLeadForm.leadLoanRecords.Tuition_Fees__c;
                this.repaymentvalue = this.wrapperForCommLeadForm.leadLoanRecords.Repayment_Option__c;
                this.loanTenure = this.wrapperForCommLeadForm.leadLoanRecords.Loan_Tenure_Months__c;

                if (this.wrapperForCommLeadForm.leadLoanRecords.Living_Hostel_Food_Expenses__c == 0) {
                    this.loanLivExpHostelFoodExp = '';
                } else {
                    this.loanLivExpHostelFoodExp = this.wrapperForCommLeadForm.leadLoanRecords.Living_Hostel_Food_Expenses__c;
                }

                if (this.wrapperForCommLeadForm.leadLoanRecords.Traveling_Expenses__c == 0) {
                    this.loanTravelExp = '';
                } else {
                    this.loanTravelExp = this.wrapperForCommLeadForm.leadLoanRecords.Traveling_Expenses__c;
                }

                if (this.wrapperForCommLeadForm.leadLoanRecords.Other_Costs__c == 0) {
                    this.loanOtherCost = '';
                } else {
                    this.loanOtherCost = this.wrapperForCommLeadForm.leadLoanRecords.Other_Costs__c;
                }

                if (this.wrapperForCommLeadForm.leadLoanRecords.Total_Costs__c == 0) {
                    this.loanTotalCostSum = '';
                } else {
                    this.loanTotalCostSum = this.wrapperForCommLeadForm.leadLoanRecords.Total_Costs__c;
                }

                if (this.wrapperForCommLeadForm.leadLoanRecords.Own_Source__c == 0) {
                    this.loanOwnSource = '';
                } else {
                    this.loanOwnSource = this.wrapperForCommLeadForm.leadLoanRecords.Own_Source__c;
                }

                if (this.wrapperForCommLeadForm.leadLoanRecords.Scholarship__c == 0) {
                    this.loanScholarship = '';
                } else {
                    this.loanScholarship = this.wrapperForCommLeadForm.leadLoanRecords.Scholarship__c;
                }

                if (this.wrapperForCommLeadForm.leadLoanRecords.Others_Fund__c == 0) {
                    this.loanOtherFunds = '';
                } else {
                    this.loanOtherFunds = this.wrapperForCommLeadForm.leadLoanRecords.Others_Fund__c;
                }

                // this.loanTotalFunndsSum = parseInt(this.loanOwnSource) + parseInt(this.loanScholarship) + parseInt(this.loanOtherFunds)
                if (this.wrapperForCommLeadForm.leadLoanRecords.Total_Funds__c == 0) {
                    this.loanTotalFunndsSum = '';
                } else {
                    this.loanTotalFunndsSum = this.wrapperForCommLeadForm.leadLoanRecords.Total_Funds__c;
                }

                this.loanLoanRequiredAB = this.wrapperForCommLeadForm.leadLoanRecords.Loan_Required_A_B__c;
                console.log(error);
                this.error = error;

            })
            .catch(error => {
            });
    }

    handleSaveLeadLoan() {
        if (this.loanExpecTuitionFees == '' || this.loanExpecTuitionFees == undefined || this.loanExpecTuitionFees == 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter Expected Tuition Fees',
                    variant: 'Error',
                }),
            );
        } else if (this.loanTenureNotValid == true) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter valid Loan Tenure (Months)',
                    variant: 'Error',
                }),
            );
        }else if (this.expectedTuitionNotValid == true) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter valid Tuition fees in Loan requirement section.',
                    variant: 'Error',
                }),
            );
        } else if (this.livingExpensesNotValid == true || this.travellingExpensesNotValid == true || this.othersNotValid == true || this.ownSourceNotValid == true || this.scholarshipNotValid == true || this.otherFundsNotValid == true || this.loanExpecTuitionFees < 0 || this.loanLivExpHostelFoodExp < 0 || this.loanTravelExp < 0 || this.loanOtherCost < 0 || this.loanOwnSource < 0 ||
            this.loanScholarship < 0 || this.loanOtherFunds < 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please ensure the number should valid.',
                    variant: 'Error',
                }),
            );
        } else if (this.loanLoanRequiredAB < 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please ensure the Loan Required value should not be negative.',
                    variant: 'Error',
                }),
            );
        } else {
            this.isLoading = true;
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
                Loan_Required_A_B__c: this.loanLoanRequiredAB,
                Loan_Amount_Required__c: this.loanLoanRequiredAB,
                Repayment_Option__c : this.repaymentvalue,
                Loan_Tenure_Months__c : this.loanTenure
            }

            //Wrapper Class variable
            let wrapperCommFormRecord1 = {
                loanSectionLeadRec: JSON.stringify(loanSecLeadSaveRec)
            }

            saveUpdateLoanOnLead({
                wrapperClassInstance: JSON.stringify(wrapperCommFormRecord1)
            })
                .then(response => {
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
                    this.handleErrorMessage(error);
                })
        }
    }

    handleNextLeadLoan() {
        if (this.loanTenureNotValid == true) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter valid Loan Tenure (Months)',
                    variant: 'Error',
                }),
            );
        }
        else if(this.loanTenure == '' || this.loanTenure == undefined){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter Loan Tenure (Months)',
                    variant: 'Error',
                }),
            );
        }
        else if(this.repaymentvalue == '' || this.repaymentvalue == undefined){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please select Repayment Option',
                    variant: 'Error',
                }),
            );
        }
        else if (this.loanExpecTuitionFees == '' || this.loanExpecTuitionFees == undefined || this.loanExpecTuitionFees == 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter Expected Tuition Fees',
                    variant: 'Error',
                }),
            );
        } else if (this.expectedTuitionNotValid == true) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter valid Tuition fees in Loan requirement section.',
                    variant: 'Error',
                }),
            );
        } else if (this.livingExpensesNotValid == true || this.travellingExpensesNotValid == true || this.othersNotValid == true || this.ownSourceNotValid == true || this.scholarshipNotValid == true || this.otherFundsNotValid == true || this.loanExpecTuitionFees < 0 || this.loanLivExpHostelFoodExp < 0 || this.loanTravelExp < 0 || this.loanOtherCost < 0 || this.loanOwnSource < 0 ||
            this.loanScholarship < 0 || this.loanOtherFunds < 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please ensure the number should valid.',
                    variant: 'Error',
                }),
            );
        } else if (this.loanLoanRequiredAB < 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please ensure the Loan Required value should not be negative.',
                    variant: 'Error',
                }),
            );
        } else {
            this.isLoading = true;
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
                Loan_Required_A_B__c: this.loanLoanRequiredAB,
                Loan_Amount_Required__c: this.loanLoanRequiredAB,
                Repayment_Option__c : this.repaymentvalue,
                Loan_Tenure_Months__c : this.loanTenure
            }

            //Wrapper Class variable
            let wrapperCommFormRecord1 = {
                loanSectionLeadRec: JSON.stringify(loanSecLeadSaveRec)
            }

            saveUpdateLoanOnLead({
                wrapperClassInstance: JSON.stringify(wrapperCommFormRecord1)
            })
                .then(response => {
                    
                    this.isLoading = false;

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Successfully Saved',
                            variant: 'Success',
                        }),
                    );
                    const onNextEvent = new CustomEvent('next', {
                        detail: {
                            nextValue: '3',
                        },
                    });
                    this.dispatchEvent(onNextEvent);
                    // let newPerc = 0;

                    // updateLeadTotalPercentage({ leadId: this.leadRecordId, percentage: newPerc })
                    //     .then(result => {
                    //         let ProgrssValueOfLoanSection = { ProgrssValueOfLoanSection: result };
                    //         publish(this.messageContext, progressBar, ProgrssValueOfLoanSection);
                    //     })
                    //     .catch(error => {
                    //         console.error(error);
                    //     });
                }).catch(error => {
                    console.log(error);
                    this.isLoading = false;
                    this.handleErrorMessage(error);
                })
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
}