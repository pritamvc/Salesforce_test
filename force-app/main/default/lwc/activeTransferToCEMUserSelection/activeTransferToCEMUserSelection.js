import { LightningElement, track, api, wire } from 'lwc';
import getActiveTransferToCEMUserSelection from '@salesforce/apex/ActiveTransferToCEMUserSelection.getActiveTransferToCEMUserSelection';
import getUserList from '@salesforce/apex/ActiveTransferToCEMUserSelection.getUserList';
import updateLeadRecord from '@salesforce/apex/ActiveTransferToCEMUserSelection.updateLeadRecord';
import getServiceBarnchFromLead from '@salesforce/apex/ActiveTransferToCEMUserSelection.getServiceBarnchFromLead';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ActiveTransferToCEMUserSelection extends NavigationMixin(LightningElement) {
    @api recordId;
    @track serviceBranch;
    @track serviceBranchOptions = [];
    @track usersForSelectionOption = [];
    @track selectedBranchName;
    @track selectedBranchUser;
    @track returnMessage;
    @track checkUser =false;
    @track checkServiceBranch =false;
    noUsersMessage ='No user available in selected service branch';
    noServiceBranchMessage ='Please select a service branch';

    // @wire(getServiceBarnchFromLead, { leadId: '$recordId' })
    // getServiceBarnchFromLead({ error, data }) {
    //     if (data) {
    //         this.serviceBranch = data;
    //         this.selectedBranchName = this.serviceBranch;
    //         if (this.serviceBranch) {
    //             getUserList({ selectedBranch: this.serviceBranch })
    //                 .then(result => {
    //                     this.usersForSelectionOption = result.map(User => ({
    //                         label: User.Name,
    //                         value: User.Id
    //                     }));
    //                 })
    //                 .catch(error => {
    //                     console.log(error);
    //                 });
    //         }
    //     } else if (error) {
    //         console.log('Error fetching service branch: ' + JSON.stringify(error));
    //     }
    // }
    connectedCallback() {
        this.getserviceBranch();
    }
    getserviceBranch(){
        getServiceBarnchFromLead({ leadId:this.recordId })
        .then(result => {
            if (result.length > 0) {
                this.checkServiceBranch = true;
                this.serviceBranch = result;
                this.selectedBranchName = this.serviceBranch;
                this.getUserslist();
            }else {
                this.checkServiceBranch = false; // If no users, set checkUser to false
            }
        })
        .catch(error => {
            console.log('Error fetching service branch: ' + JSON.stringify(error));
        });
    }
    getUserslist(){
        getUserList({ selectedBranch: this.serviceBranch })
        .then(result => {
            if (result.length > 0) {
                this.checkUser = true; 
                this.usersForSelectionOption = result.map(User => ({
                    label: User.Name,
                    value: User.Id
                }));
            } else {
                this.checkUser = false; // If no users, set checkUser to false
                this.usersForSelectionOption = []; // Reset the user list
            }
        })
        .catch(error => {
            console.log(error);
        });
    }

    @wire(getActiveTransferToCEMUserSelection)
    wiredActiveTransferToCEMUserSelection({ error, data }) {
        if (data) {
            // Map the Service Branch Name values to an array of objects for use in the picklist
            this.serviceBranchOptions = data.map(record => ({
                label: record.Service_Branch_Name__c,
                value: record.Service_Branch_Name__c
            }));
        } else if (error) {
            console.error(error);
        }
    }

    handleServiceBranchChange(event) {
        if (event.target.name == 'serviceBranch') {
            const selectedValue = event.detail.value;
            this.selectedBranchName = selectedValue;
            getUserList({ selectedBranch: selectedValue })
                .then(result => {
                    this.usersForSelectionOption = result.map(User => ({
                        label: User.Name,
                        value: User.Id
                    }));
                })
                .catch(error => {
                    console.log(error);
                });
        }
        if (event.target.name == 'serviceBranchUser') {
            this.selectedBranchUser = event.detail.value;
        }
    }
    handleSubmit() {
        if (this.selectedBranchName == '' || this.selectedBranchName == undefined) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please select Service Branch (Hub) on lead detail page',
                    variant: 'Error',
                }),
            );
        } else if (this.selectedBranchUser == '' || this.selectedBranchUser == undefined) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please select Service Branch User',
                    variant: 'Error',
                }),
            );
        }
        else {
        updateLeadRecord({ leadId: this.recordId, serviceBranchName: this.selectedBranchName, userName: this.selectedBranchUser })
                .then(result => {
                    this.returnMessage = result;
                    if (this.returnMessage == '' || this.returnMessage == undefined) {
                    this.closeAction();
                    this.updateRecordView();
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success!!',
                            message: 'Lead updated successfully !!',
                            variant: 'Success',
                        }),
                    );
                }else{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!!',
                            message: this.returnMessage,
                            variant: 'Error',
                        }),
                    );
                }
                this.navigateToObjectHome();
            })
            
                .catch(error => {
                    console.log(error);
                });
        }
    }

    showNotification(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        dispatchEvent(evt);
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    updateRecordView() {
        setTimeout(() => {
            eval("$A.get('e.force:refreshView').fire();");
        }, 1000);
    }
    navigateToObjectHome() {
        // Navigate to the Account home page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Lead',
                actionName: 'view',
            },
        });
    }

}