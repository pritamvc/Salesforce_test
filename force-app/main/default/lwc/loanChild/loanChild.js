import { LightningElement, wire, api, track } from 'lwc';
import getLeadData from '@salesforce/apex/QAChildControllerClass.getWrapperClassCommFormList';
import creatCommFormLeadRecords1 from '@salesforce/apex/QAChildControllerClass.creatCommFormLeadRecord111';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLeadTotalPercentage from '@salesforce/apex/DocumentVerification.getLeadTotalPercentage';
import updateLeadTotalPercentage from '@salesforce/apex/DocumentVerification.updateLeadTotalPercentage';
import progressBar from '@salesforce/messageChannel/progressBar__c';
import {publish, MessageContext} from 'lightning/messageService';

export default class CommunityFormARSChild extends LightningElement {
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
    @track firstCheck = false;

    connectedCallback() {
        this.getAllLoanDataFromLead();
    }
    handlechangeLoan(event) {

        if (event.target.name == 'ExpectedTuitionFees') {
            let fieldValue = event.target.value;            
            let pattern = /^[1-9][0-9]*$/;
            if (!pattern.test(fieldValue) && fieldValue != '') {
                console.log('inside invalid ExpectedTuitionFees');
                this.expectedTuitionNotValid = true;
            }else{
                console.log('valid pan number');
                this.loanExpecTuitionFees = event.target.value;
                this.expectedTuitionNotValid = false;
            }
            console.log('this.loanExpecTuitionFees handle changed' , this.loanExpecTuitionFees);  

        } else if (event.target.name === 'Living Expenses/Hostel and Food') {
            let fieldValue = event.target.value;  
            console.log('fieldValue==', fieldValue);
            let pattern = /^[1-9][0-9]*$/;
            if (!pattern.test(fieldValue) && fieldValue != '') {
                console.log('inside invalid loanLivExpHostelFoodExp');
                this.livingExpensesNotValid = true;
            }else{
                console.log('valid pan number');
                this.loanLivExpHostelFoodExp = event.target.value;
                this.livingExpensesNotValid = false;
            }
            console.log('this.loanLivExpHostelFoodExp handle changed' , this.loanLivExpHostelFoodExp);  
            console.log('livingExpensesNotValid==', this.livingExpensesNotValid);
        } else if (event.target.name === 'Travelling Expenses') {
            let fieldValue = event.target.value;            
            let pattern = /^[1-9][0-9]*$/;
            if (!pattern.test(fieldValue) && fieldValue != '') {
                console.log('inside invalid loanTravelExp');
                this.travellingExpensesNotValid = true;
            }else{
                console.log('valid pan number');
                this.loanTravelExp = event.target.value;
                this.travellingExpensesNotValid = false;
            }
            console.log('this.loanTravelExp handle changed' , this.loanTravelExp);  
        
        } else if (event.target.name === 'Others') {
            let fieldValue = event.target.value;            
            let pattern = /^[1-9][0-9]*$/;
            if (!pattern.test(fieldValue) && fieldValue != '') {
                console.log('inside invalid loanOtherCost');
                this.othersNotValid = true;
            }else{
                console.log('valid pan number');
                this.loanOtherCost = event.target.value;
                this.othersNotValid = false;
            }
            console.log('this.loanOtherCost handle changed' , this.loanOtherCost);             
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
            }else{            
                this.loanOwnSource = event.target.value;
                this.ownSourceNotValid = false;
            }          
           
        } else if (event.target.name === 'Scholarship') {
            let fieldValue = event.target.value;            
            let pattern = /^[1-9][0-9]*$/;
            if (!pattern.test(fieldValue) && fieldValue != '') {             
                this.scholarshipNotValid = true;
            }else{              
                this.loanScholarship = event.target.value;
                this.scholarshipNotValid = false;
            }      
           
        } else if (event.target.name === 'Other Funds') {
            let fieldValue = event.target.value;            
            let pattern = /^[1-9][0-9]*$/;
            if (!pattern.test(fieldValue) && fieldValue != '') {               
                this.otherFundsNotValid = true;
            }else{              
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
        console.log("New Data Loan 4");
        getLeadData({ leadGetId: this.leadRecordId })
            .then(result => {
                this.wrapperForCommLeadForm = result;

                //Applicant Loan requirement on Lead  
                this.leadIDLoan = this.wrapperForCommLeadForm.LeadRecords.Id;
                this.loanExpecTuitionFees = this.wrapperForCommLeadForm.LeadRecords.Tuition_Fees__c;

                if(this.wrapperForCommLeadForm.LeadRecords.Tuition_Fees__c != null){
                    this.firstCheck = true;
                }
               
                if(this.wrapperForCommLeadForm.LeadRecords.Living_Hostel_Food_Expenses__c == 0){

                    this.loanLivExpHostelFoodExp = '';
                }else{
                    this.loanLivExpHostelFoodExp = this.wrapperForCommLeadForm.LeadRecords.Living_Hostel_Food_Expenses__c;
                }             

                if(this.wrapperForCommLeadForm.LeadRecords.Traveling_Expenses__c == 0){
                    this.loanTravelExp = '';
                }else{
                    this.loanTravelExp = this.wrapperForCommLeadForm.LeadRecords.Traveling_Expenses__c;
                }               

                if(this.wrapperForCommLeadForm.LeadRecords.Other_Costs__c == 0){
                    this.loanOtherCost = '';
                }else{
                    this.loanOtherCost = this.wrapperForCommLeadForm.LeadRecords.Other_Costs__c;
                }         
            
                if(this.wrapperForCommLeadForm.LeadRecords.Total_Costs__c == 0){
                    this.loanTotalCostSum = '';
                }else{
                    this.loanTotalCostSum = this.wrapperForCommLeadForm.LeadRecords.Total_Costs__c;
                }   
                
                if(this.wrapperForCommLeadForm.LeadRecords.Own_Source__c == 0){
                    this.loanOwnSource = '';
                }else{
                    this.loanOwnSource = this.wrapperForCommLeadForm.LeadRecords.Own_Source__c;
                }   

                if(this.wrapperForCommLeadForm.LeadRecords.Scholarship__c == 0){
                    this.loanScholarship = '';
                }else{
                    this.loanScholarship = this.wrapperForCommLeadForm.LeadRecords.Scholarship__c;
                }  
                
                if(this.wrapperForCommLeadForm.LeadRecords.Others_Fund__c == 0){
                    this.loanOtherFunds = '';
                }else{
                    this.loanOtherFunds = this.wrapperForCommLeadForm.LeadRecords.Others_Fund__c;
                }                    
               
                // this.loanTotalFunndsSum = parseInt(this.loanOwnSource) + parseInt(this.loanScholarship) + parseInt(this.loanOtherFunds)
                if(this.wrapperForCommLeadForm.LeadRecords.Total_Funds__c == 0){
                    this.loanTotalFunndsSum = '';
                }else{
                    this.loanTotalFunndsSum = this.wrapperForCommLeadForm.LeadRecords.Total_Funds__c;
                }
                
                this.loanLoanRequiredAB = this.wrapperForCommLeadForm.LeadRecords.Loan_Required_A_B__c;
                console.log(error);
                this.error = error;

            })
            .catch(error => {

            });

    }

    handleSaveLeadLoan() {
        console.log('this.loanExpecTuitionFees=====>', this.loanExpecTuitionFees);
        console.log('LeadId == ', this.leadIDLoan);
        if (this.loanExpecTuitionFees == '' || this.loanExpecTuitionFees == undefined || this.loanExpecTuitionFees == 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter Expected Tuition Fees',
                    variant: 'Error',
                }),
            );
        } else if (this.expectedTuitionNotValid == true || this.livingExpensesNotValid == true || this.travellingExpensesNotValid == true || this.othersNotValid == true || this.ownSourceNotValid == true || this.scholarshipNotValid == true || this.otherFundsNotValid == true || this.loanExpecTuitionFees < 0 || this.loanLivExpHostelFoodExp < 0 || this.loanTravelExp < 0 || this.loanOtherCost < 0 || this.loanOwnSource < 0 ||
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
                    /****progress bar data pass****/
                //    debugger
                //    getLeadTotalPercentage({ leadId:this.leadRecordId })
                //    .then(result => {
                //        console.log('Total pppercentagee:', result);
                //        let newPerc = 15;
                //        let ProgrssValueOfLoanSection = {ProgrssValueOfLoanSection:newPerc };
                //        console.log('ProgressValueOfLoanSection +++' , ProgrssValueOfLoanSection);
                //        publish(this.messageContext, progressBar, ProgrssValueOfLoanSection);
                //        updateLeadTotalPercentage({ leadId: this.leadRecordId, percentage: newPerc })
                //        .then(result => {
                //            if (result === 'Success') {
                //                console.log('Lead updated successfully');
                //                // Add any success logic here
                //            } else {
                //                console.error('Failed to update Lead');
                //                // Add any failure logic here
                //            }
                //        })
                //        .catch(error => {
                //            console.error(error);
                //            // Add any error handling here
                //        });
                //    })
                //    .catch(error => {
                //        console.error(error);
                //    });
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Sucess',
                            message: 'Successfully Saved',
                            variant: 'Success',
                        }),
                    );
                }).catch(error => {
                    console.log(error);
                    this.isLoading = false;
                })
                
        }
    }

    handleNextLeadLoan() {
        console.log('this.loanExpecTuitionFees=====>', this.loanExpecTuitionFees);
        console.log('LeadId == ', this.leadIDLoan);
        if (this.loanExpecTuitionFees == '' || this.loanExpecTuitionFees == undefined || this.loanExpecTuitionFees == 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter Expected Tuition Fees',
                    variant: 'Error',
                }),
            );
        } else if (this.expectedTuitionNotValid == true || this.livingExpensesNotValid == true || this.travellingExpensesNotValid == true || this.othersNotValid == true || this.ownSourceNotValid == true || this.scholarshipNotValid == true || this.otherFundsNotValid == true || this.loanExpecTuitionFees < 0 || this.loanLivExpHostelFoodExp < 0 || this.loanTravelExp < 0 || this.loanOtherCost < 0 || this.loanOwnSource < 0 ||
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
                    /****progress bar data pass****/
                    let sum;
                    if(this.firstCheck == true){
                        sum = 0;
                    }
                    else{
                        sum = 9;
                        this.firstCheck = true;
                        
                        let newPerc = sum;
                        let ProgrssValueOfLoanSection = {ProgrssValueOfLoanSection:newPerc };
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
                   //debugger
                   
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
                }).catch(error => {
                    console.log(error);
                    this.isLoading = false;
                })
                
        }
    }
}